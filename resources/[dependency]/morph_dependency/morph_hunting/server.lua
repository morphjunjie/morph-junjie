-- server.lua
local Config = require 'morph_hunting.config'

local eventRateLimit = {}
local activeSessions = {}     -- [src] = { index = deerId, startedAt = ms }
local strikes = {}            -- [src] = count
local butcheredIndices = {}   -- [src] = { [deerId] = true }  -- cegah 1 deer id diklaim 2x

-- Toleransi buffer supaya lag/ping normal nggak ke-flag sebagai exploit.
local DURATION_BUFFER = 700   -- ms, boleh dianggap selesai sedikit lebih cepat dari durasi asli
local AREA_BUFFER = 15.0      -- meter ekstra di atas radius hunting
local MAX_STRIKES = 3         -- baru di-ban setelah 3x pelanggaran, bukan sekali

local function isInHuntingArea(source)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end
    local pos = GetEntityCoords(ped)
    return #(pos - Config.Deer.spawnCenter) <= (Config.Deer.spawnRadius + AREA_BUFFER)
end

-- Nambah strike, baru ban kalau nyampe MAX_STRIKES. Ini yang bikin 1x
-- anomali (lag, desync posisi sesaat, dll) nggak langsung nge-ban
-- player biasa; cuma pola pelanggaran berulang yang ke-ban.
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

local function checkSpam(source, action)
    local now, key = os.time(), source .. '_' .. action
    if not eventRateLimit[key] then eventRateLimit[key] = { count = 1, firstTime = now } return false end
    local data = eventRateLimit[key]
    if now - data.firstTime > 60 then eventRateLimit[key] = { count = 1, firstTime = now } return false end
    data.count = data.count + 1
    if data.count >= 15 then addStrike(source, 'Hunting spam'); eventRateLimit[key] = nil; return true end
    return false
end

lib.callback.register('hunting:server:canCarry', function(src, item, amount)
    if amount > 100 then
        addStrike(src, 'Hunting executor (canCarry amount)')
        return false
    end
    return exports.morph_inv:CanCarryItem(src, item, amount)
end)

-- Client wajib minta sesi ini SEBELUM progress bar mulai. Server cek
-- player beneran ada di dalam area hunting, dan deer id ini belum
-- pernah diklaim sebelumnya oleh player ini. Tanpa sesi valid, event
-- reward di bawah bakal ditolak.
lib.callback.register('hunting:server:startAction', function(source, deerId)
    if not deerId then return false end

    if not isInHuntingArea(source) then
        addStrike(source, 'Exploiting Hunting (start out of area)')
        return false
    end

    local butchered = butcheredIndices[source]
    if butchered and butchered[deerId] then
        addStrike(source, 'Exploiting Hunting (deer already claimed)')
        return false
    end

    activeSessions[source] = { index = deerId, startedAt = GetGameTimer() }
    return true
end)

-- Validasi sesi: harus ada, index harus cocok, durasi yang beneran
-- lewat harus mendekati durasi asli (dikurangi buffer), dan player
-- masih di dalam area. Sesi dikonsumsi begitu dipakai (single-use),
-- dan index-nya dicatat biar nggak bisa diklaim ulang.
local function validateSession(source, deerId)
    local session = activeSessions[source]
    if not session or session.index ~= deerId then
        addStrike(source, 'Exploiting Hunting (no valid session)')
        return false
    end

    local elapsed = GetGameTimer() - session.startedAt
    if elapsed < (Config.Butcher.duration - DURATION_BUFFER) then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Hunting (reward claimed too fast)')
        return false
    end

    if not isInHuntingArea(source) then
        activeSessions[source] = nil
        addStrike(source, 'Exploiting Hunting (out of area on claim)')
        return false
    end

    activeSessions[source] = nil -- consume, single-use
    return true
end

RegisterNetEvent('hunting:server:butcherDeer', function(index)
    local src = source
    if checkSpam(src, 'butcherDeer') then return end
    if not validateSession(src, index) then return end

    local hasKnife = exports.morph_inv:Search(src, 'slots', Config.StartHunting.requiredItem)
    if not hasKnife or #hasKnife == 0 then
        addStrike(src, 'Hunting executor (no knife)')
        return
    end

    local meatAmount = math.random(Config.Butcher.meatMin, Config.Butcher.meatMax)
    local skinAmount = math.random(Config.Butcher.skinMin, Config.Butcher.skinMax)

    if not exports.morph_inv:CanCarryItem(src, Config.Butcher.meatItem, meatAmount) then return end
    if not exports.morph_inv:CanCarryItem(src, Config.Butcher.skinItem, skinAmount) then return end
    if exports.morph_inv:GetItemCount(src, Config.Butcher.meatItem) + meatAmount > 500 then return end
    if exports.morph_inv:GetItemCount(src, Config.Butcher.skinItem) + skinAmount > 500 then return end

    exports.morph_inv:AddItem(src, Config.Butcher.meatItem, meatAmount)
    exports.morph_inv:AddItem(src, Config.Butcher.skinItem, skinAmount)

    butcheredIndices[src] = butcheredIndices[src] or {}
    butcheredIndices[src][index] = true

    resetStrikes(src)
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then
        eventRateLimit = {}
        activeSessions = {}
        strikes = {}
        butcheredIndices = {}
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    activeSessions[src] = nil
    strikes[src] = nil
    butcheredIndices[src] = nil
    for key in pairs(eventRateLimit) do
        if key:match('^' .. src .. '_') then
            eventRateLimit[key] = nil
        end
    end
end)

print("^2[HUNTING JOB] Server loaded^7")