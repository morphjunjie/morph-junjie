-- server.lua
local Config = require 'morph_chicken.config'

local eventRateLimit = {}
local activeSessions = {}   -- [src] = { type = 'take'|'meat'|'pack', startedAt = ms, auto = bool }
local strikes = {}          -- [src] = count

local CFG_BY_TYPE = {
    take = Config.TakeChicken,
    meat = Config.ProcessChicken,
    pack = Config.PackChicken,
}

local AUTO_CFG_BY_TYPE = {
    take = Config.AutoTakeChicken,
    meat = Config.AutoProcessMeat,
    pack = Config.AutoProcessPack,
}

-- Toleransi buffer supaya lag/ping normal nggak ke-flag sebagai exploit.
local DIST_BUFFER = 1.5     -- meter ekstra di atas targetDistance
local DURATION_BUFFER = 700 -- ms, boleh dianggap selesai sedikit lebih cepat dari durasi asli
local MAX_STRIKES = 3       -- baru di-ban setelah 3x pelanggaran, bukan sekali

local function isNearCoords(source, coords, maxDist)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end
    local pos = GetEntityCoords(ped)
    return #(pos - coords) <= (maxDist or 5.0)
end

-- Nambah strike. Baru ban kalau udah nyampe MAX_STRIKES dalam siklus
-- yang belum di-reset oleh aksi valid. Ini yang bikin 1x anomali (lag,
-- desync posisi sesaat, dll) nggak langsung nge-ban player biasa.
local function addStrike(source, reason)
    strikes[source] = (strikes[source] or 0) + 1
    if strikes[source] >= MAX_STRIKES then
        exports.morph_junjie:ExploitBan(source, reason)
        strikes[source] = nil
    end
end

local function resetStrikes(source)
    strikes[source] = nil
end

local function checkEventSpamming(source, action)
    local currentTime = os.time()
    local key = source .. '_event_' .. action
    -- Limit ini sekarang cuma jaring pengaman kedua (defense in depth).
    -- Pertahanan utama ada di sistem sesi di bawah.
    local limits = {
        takeReward = 20,
        processMeatReward = 20,
        processPackReward = 20
    }
    local limit = limits[action] or 20

    if not eventRateLimit[key] then
        eventRateLimit[key] = { count = 1, firstTime = currentTime }
        return false
    end

    local data = eventRateLimit[key]
    local timeDiff = currentTime - data.firstTime

    if timeDiff > 60 then
        eventRateLimit[key] = { count = 1, firstTime = currentTime }
        return false
    end

    data.count = data.count + 1
    if data.count >= limit then
        addStrike(source, 'Executor Chicken Farm (rate limit)')
        eventRateLimit[key] = nil
        return true
    end

    return false
end

lib.callback.register('chicken:server:canCarry', function(src, item, amount)
    if amount > 100 then return false end
    return exports.morph_inv:CanCarryItem(src, item, amount)
end)

lib.callback.register('chicken:server:checkItems', function(src, item, amount)
    if not item or not amount then return true end
    return exports.morph_inv:Search(src, 'count', item) >= amount
end)

-- Client wajib minta sesi ini SEBELUM progress bar mulai jalan.
-- Server cek posisi saat itu dan nyimpen jam mulai + tipe kerjaan.
-- Tanpa sesi valid, event reward di bawah bakal ditolak.
lib.callback.register('chicken:server:startAction', function(source, actionType, isAuto)
    local cfg = CFG_BY_TYPE[actionType]
    if not cfg then return false end

    local maxDist = (cfg.targetDistance or Config.targetDistance or 3.0) + DIST_BUFFER
    if not isNearCoords(source, cfg.coords, maxDist) then
        addStrike(source, 'Exploiting Chicken Farm (start out of range)')
        return false
    end

    activeSessions[source] = {
        type = actionType,
        startedAt = GetGameTimer(),
        auto = isAuto and true or false,
    }
    return true
end)

local function expectedDuration(actionType, isAuto)
    local cfg = CFG_BY_TYPE[actionType]
    local autoCfg = AUTO_CFG_BY_TYPE[actionType]
    if isAuto and autoCfg then
        return autoCfg.duration
    end
    return cfg.duration
end

-- Validasi sesi: harus ada, tipe harus cocok, durasi yang beneran lewat
-- harus mendekati durasi asli (dikurangi buffer), dan posisi masih di
-- lokasi. Sesi dikonsumsi (dihapus) begitu dipakai, jadi nggak bisa
-- direplay buat klaim reward berkali-kali dari 1 sesi yang sama.
local function validateSession(source, actionType)
    local session = activeSessions[source]
    if not session or session.type ~= actionType then
        addStrike(source, 'Exploiting Chicken Farm (no valid session)')
        return false
    end

    local elapsed = GetGameTimer() - session.startedAt
    local minDuration = expectedDuration(actionType, session.auto) - DURATION_BUFFER
    if elapsed < minDuration then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Chicken Farm (reward claimed too fast)')
        return false
    end

    local cfg = CFG_BY_TYPE[actionType]
    local maxDist = (cfg.targetDistance or Config.targetDistance or 3.0) + DIST_BUFFER
    if not isNearCoords(source, cfg.coords, maxDist) then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Chicken Farm (out of range on claim)')
        return false
    end

    activeSessions[source] = nil -- consume, single-use
    return true
end

local function processTakeReward(src)
    local amount = math.random(Config.TakeChicken.outputMin, Config.TakeChicken.outputMax)
    if not exports.morph_inv:CanCarryItem(src, Config.TakeChicken.outputItem, amount) then return false end
    if exports.morph_inv:GetItemCount(src, Config.TakeChicken.outputItem) + amount > Config.TakeChicken.maxStack then return false end
    exports.morph_inv:AddItem(src, Config.TakeChicken.outputItem, amount)
    return true
end

local function processMeatReward(src)
    local cfg = Config.ProcessChicken
    if exports.morph_inv:GetItemCount(src, cfg.inputItem) < cfg.inputAmount then
        addStrike(src, 'Exploiting Chicken Farm (missing input)')
        return false
    end
    if not exports.morph_inv:CanCarryItem(src, cfg.outputItem, cfg.outputAmount) then return false end
    if exports.morph_inv:GetItemCount(src, cfg.outputItem) + cfg.outputAmount > cfg.maxStack then return false end

    exports.morph_inv:RemoveItem(src, cfg.inputItem, cfg.inputAmount)
    exports.morph_inv:AddItem(src, cfg.outputItem, cfg.outputAmount)

    if math.random(1, 100) <= cfg.eggChance then
        local eggAmount = math.random(cfg.eggMin, cfg.eggMax)
        if exports.morph_inv:CanCarryItem(src, cfg.eggItem, eggAmount) then
            if exports.morph_inv:GetItemCount(src, cfg.eggItem) + eggAmount <= cfg.maxStack then
                exports.morph_inv:AddItem(src, cfg.eggItem, eggAmount)
            end
        end
    end
    return true
end

local function processPackReward(src)
    local cfg = Config.PackChicken
    if exports.morph_inv:GetItemCount(src, cfg.inputItem) < cfg.inputAmount then
        addStrike(src, 'Exploiting Chicken Farm (missing input)')
        return false
    end
    if not exports.morph_inv:CanCarryItem(src, cfg.outputItem, cfg.outputAmount) then return false end
    if exports.morph_inv:GetItemCount(src, cfg.outputItem) + cfg.outputAmount > cfg.maxStack then return false end

    exports.morph_inv:RemoveItem(src, cfg.inputItem, cfg.inputAmount)
    exports.morph_inv:AddItem(src, cfg.outputItem, cfg.outputAmount)
    return true
end

RegisterNetEvent('chicken:server:takeReward', function()
    local src = source
    if checkEventSpamming(src, 'takeReward') then return end
    if not validateSession(src, 'take') then return end
    if processTakeReward(src) then resetStrikes(src) end
end)

RegisterNetEvent('chicken:server:processMeatReward', function()
    local src = source
    if checkEventSpamming(src, 'processMeatReward') then return end
    if not validateSession(src, 'meat') then return end
    if processMeatReward(src) then resetStrikes(src) end
end)

RegisterNetEvent('chicken:server:processPackReward', function()
    local src = source
    if checkEventSpamming(src, 'processPackReward') then return end
    if not validateSession(src, 'pack') then return end
    if processPackReward(src) then resetStrikes(src) end
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then
        eventRateLimit = {}
        activeSessions = {}
        strikes = {}
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    activeSessions[src] = nil
    strikes[src] = nil
    for key in pairs(eventRateLimit) do
        if key:match('^' .. src .. '_event_') then
            eventRateLimit[key] = nil
        end
    end
end)

print("^2[CHICKEN FARM] Server loaded.^7")