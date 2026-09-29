-- server.lua

local cfgFile = require 'morph_rcjob.config'
local config = setmetatable(cfgFile.server, { __index = cfgFile.shared })

local eventRateLimit = {}
local playerCooldowns = {}
local playerJobState = {} -- [src] = { onDuty = bool, hasPackage = bool }
local activeSessions = {} -- [src] = { type = 'pickup'|'drop', startedAt = ms }
local strikes = {}        -- [src] = count

-- Toleransi buffer supaya lag/ping normal nggak ke-flag sebagai exploit.
local DURATION_BUFFER = 700 -- ms, boleh dianggap selesai sedikit lebih cepat dari durasi asli
local MAX_STRIKES = 3       -- baru di-ban setelah 3x pelanggaran sesi, bukan sekali

local function getState(src)
    if not playerJobState[src] then playerJobState[src] = { onDuty = false, hasPackage = false } end
    return playerJobState[src]
end

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
    local window = config.spamWindowSecs or 60
    local warnAt = config.spamWarnCount or 10
    local banAt = config.spamBanCount or 15

    if not eventRateLimit[key] then eventRateLimit[key] = { count = 1, firstTime = currentTime } return false end
    local data = eventRateLimit[key]
    local timeDiff = currentTime - data.firstTime
    if timeDiff > window then eventRateLimit[key] = { count = 1, firstTime = currentTime } return false end
    data.count = data.count + 1
    if data.count >= warnAt then print(('^3[WARNING] Player %s suspicious recycle activity (%s): %d in %ds'):format(source, action, data.count, timeDiff)) end
    if data.count >= banAt then exports.morph_junjie:ExploitBan(source, 'Executor Recycle Job'); eventRateLimit[key] = nil; return true end
    return false
end

local function onCooldown(source, action)
    local currentTime = os.time()
    local key = source .. '_cooldown_' .. action
    local cooldown = config.cooldownSeconds or 10
    if playerCooldowns[key] and currentTime - playerCooldowns[key] < cooldown then return true end
    playerCooldowns[key] = currentTime
    return false
end

-- true kalau posisi ped 'src' ada dalam radius dari salah satu titik di 'locations'
local function isNearAnyLocation(src, locations, radius)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end
    local pos = GetEntityCoords(ped)
    for _, loc in pairs(locations) do
        if #(pos - vector3(loc.x, loc.y, loc.z)) <= radius then return true end
    end
    return false
end

local function isNearLocation(src, location, radius)
    return isNearAnyLocation(src, { location }, radius)
end

-- Client wajib minta sesi ini SEBELUM progress bar pickup/drop mulai.
-- Server cek status onDuty/hasPackage + posisi saat itu, dan nyimpen jam
-- mulainya buat dicocokin lagi pas reward diklaim -- ini yang nutup
-- celah "skip animasi, langsung trigger event reward".
lib.callback.register('morph_rcjob:server:startAction', function(source, actionType)
    local state = getState(source)

    if actionType == 'pickup' then
        if not state.onDuty or state.hasPackage then return false end
        if not isNearAnyLocation(source, config.pickupLocations, config.pickupRadius or 3.0) then
            addStrike(source, 'Exploiting Recycle Job (pickup start out of range)')
            return false
        end
    elseif actionType == 'drop' then
        if not state.hasPackage then return false end
        if not isNearLocation(source, config.dropLocation, config.dropRadius or 3.0) then
            addStrike(source, 'Exploiting Recycle Job (drop start out of range)')
            return false
        end
    else
        return false
    end

    activeSessions[source] = { type = actionType, startedAt = GetGameTimer() }
    return true
end)

-- Validasi sesi: harus ada, tipe harus cocok, durasi yang beneran lewat
-- harus mendekati durasi minimum yang mungkin (dikurangi buffer). Sesi
-- dikonsumsi begitu dipakai (single-use).
local function validateSession(source, actionType, minDuration)
    local session = activeSessions[source]
    if not session or session.type ~= actionType then
        addStrike(source, 'Exploiting Recycle Job (no valid session)')
        return false
    end

    local elapsed = GetGameTimer() - session.startedAt
    if elapsed < minDuration then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Recycle Job (reward claimed too fast)')
        return false
    end

    activeSessions[source] = nil -- consume, single-use
    return true
end

local function giveRewardItems(src)
    local maxAllowed = (config.maxItemsReceived or 5) * (config.maxItemReceivedQty or 6) + 4
    local totalItems = 0
    local loopCount = math.random(1, config.maxItemsReceived or 5)

    for _ = 1, loopCount do
        local randItem = config.itemTable[math.random(1, #config.itemTable)]
        local amount = math.random(config.minItemReceivedQty or 2, config.maxItemReceivedQty or 6)
        totalItems = totalItems + amount
        if totalItems > maxAllowed then exports.morph_junjie:Notify(src, locale('error.overweight_check'), 'error'); return end
        if exports.morph_inv:CanCarryItem(src, randItem, amount) then
            exports.morph_inv:AddItem(src, randItem, amount)
            Wait(500)
        else
            exports.morph_junjie:Notify(src, locale('error.overweight_check'), 'error')
        end
    end

    local chance = math.random(1, 100)
    if chance < 7 then
        totalItems = totalItems + 1
        if totalItems > maxAllowed then return end
        if exports.morph_inv:CanCarryItem(src, config.chanceItem, 1) then
            exports.morph_inv:AddItem(src, config.chanceItem, 1)
        else
            exports.morph_junjie:Notify(src, locale('error.overweight_check'), 'error')
        end
    end

    local luck = math.random(1, 10)
    local odd = math.random(1, 10)
    if luck == odd then
        local random = math.random(1, 3)
        totalItems = totalItems + random
        if totalItems > maxAllowed then return end
        if exports.morph_inv:CanCarryItem(src, config.luckyItem, random) then
            exports.morph_inv:AddItem(src, config.luckyItem, random)
        else
            exports.morph_junjie:Notify(src, locale('error.overweight_check'), 'error')
        end
    end
end

-- dipanggil client saat clock in/out. Menyimpan status di server supaya
-- pickup/drop bisa divalidasi, bukan cuma dipercaya dari client.
RegisterNetEvent('morph_rcjob:server:setDuty', function(status)
    local src = source
    local state = getState(src)
    state.onDuty = status and true or false
    if not state.onDuty then state.hasPackage = false end
end)

-- dipanggil client setelah animasi pickup selesai. Server cek ulang:
-- sesi pickup valid (durasi + posisi), player memang onDuty, belum bawa
-- barang, dan memang ada di salah satu titik pickup.
RegisterNetEvent('morph_rcjob:server:pickupPackage', function()
    local src = source
    if checkEventSpamming(src, 'pickup') then return end
    if not validateSession(src, 'pickup', (config.pickupActionDurationMin or 4000) - DURATION_BUFFER) then return end

    local state = getState(src)
    if not state.onDuty or state.hasPackage then return end
    if not isNearAnyLocation(src, config.pickupLocations, config.pickupRadius or 3.0) then return end

    state.hasPackage = true
    resetStrikes(src)
end)

-- reward job. Divalidasi: sesi drop valid (durasi + posisi), player harus
-- punya hasPackage = true (cuma didapat lewat event pickup yang
-- tervalidasi di atas) dan harus berada dekat dropLocation. Nama event
-- dipertahankan biar kompatibel kalau ada resource lain yang bergantung
-- padanya.
RegisterNetEvent('qbx_recycle:server:getItem', function()
    local src = source
    if checkEventSpamming(src, 'getItem') then return end
    if onCooldown(src, 'getItem') then print(('^3[WARNING] Player %s on cooldown'):format(src)); return end
    if not validateSession(src, 'drop', (config.deliveryActionDuration or 5000) - DURATION_BUFFER) then return end

    local state = getState(src)
    if not state.hasPackage then return end
    if not isNearLocation(src, config.dropLocation, config.dropRadius or 3.0) then return end

    state.hasPackage = false
    resetStrikes(src)
    giveRewardItems(src)
end)

AddEventHandler('playerDropped', function()
    local src = source
    eventRateLimit[src .. '_event_getItem'] = nil
    eventRateLimit[src .. '_event_pickup'] = nil
    playerCooldowns[src .. '_cooldown_getItem'] = nil
    playerJobState[src] = nil
    activeSessions[src] = nil
    strikes[src] = nil
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then
        eventRateLimit = {}
        playerCooldowns = {}
        playerJobState = {}
        activeSessions = {}
        strikes = {}
    end
end)

print("^2[RECYCLE JOB] Server loaded with anti-cheat!^7")