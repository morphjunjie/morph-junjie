-- server.lua
local Config = require 'morph_vehicleinsurance.config'

local state = {
    phase = 'idle',       -- 'idle' | 'warning'
    warningEndsAt = nil,  -- GetGameTimer() timestamp pas warning-nya selesai
}

local isRunningCycle = false

-- true kalau vehicle-nya lagi ada orang di dalam (cek semua kursi, bukan
-- cuma driver). GetVehicleNumberOfPassengers itu native client-only, jadi
-- nggak bisa dipanggil dari server -- makanya pakai loop GetPedInVehicleSeat.
local function isVehicleOccupied(veh)
    for seat = -1, 16 do
        local ped = GetPedInVehicleSeat(veh, seat)
        if ped and ped ~= 0 then
            return true
        end
    end
    return false
end

-- match qb-vehiclekeys' own convention exactly: only status 2 counts as
-- "locked", everything else (including other lock-ish statuses like
-- lockout/can't-be-entered) is treated as unlocked by that system too.
local function isVehicleLocked(veh)
    local status = GetVehicleDoorLockStatus(veh)
    return status == 2
end

-- Sama persis kayak getVehicleId di morph_junjie/server/vehicle-persistence.lua:
-- kalau ini nil, berarti kendaraan itu gak tercatat sebagai kendaraan player
-- di database morph_vehicles - artinya NPC/ambient atau kendaraan job yang
-- cuma "spawn aja" tanpa masuk DB. Kendaraan kayak gitu di-skip total,
-- gak masuk hitungan delete sama sekali.
local function getVehicleId(veh, plate)
    local vehicleId = Entity(veh).state.vehicleid
    if vehicleId then return vehicleId end

    local ok, id = pcall(function()
        return exports.morph_vehicles:GetVehicleIdByPlate(plate)
    end)

    if ok then return id end
    return nil
end

local function deleteUnoccupiedVehicles()
    local vehicles = GetAllVehicles()
    local deletedCount = 0
    local skippedOccupied = 0
    local skippedLocked = 0
    local skippedNotOwned = 0

    print(('^3[Vehicle Insurance] Found %d vehicle(s) in the world.^7'):format(#vehicles))

    for i = 1, #vehicles do
        local veh = vehicles[i]

        if DoesEntityExist(veh) then
            local netId = NetworkGetNetworkIdFromEntity(veh)
            local plate = GetVehicleNumberPlateText(veh)
            local rawLockStatus = GetVehicleDoorLockStatus(veh)

            local vehicleId = getVehicleId(veh, plate)

            if not vehicleId then
                -- bukan kendaraan player yang tercatat di database - ini
                -- NPC/ambient atau kendaraan job (misal spawn pizza delivery).
                -- Insurance ini cuma buat kendaraan player, jadi skip total.
                skippedNotOwned += 1
                print(('^5[Vehicle Insurance] SKIP (bukan kendaraan player/tidak ada di DB) - netId: %s, plate: %s^7'):format(netId, plate))
            else
                local ok, occupied, locked = pcall(function()
                    return isVehicleOccupied(veh), isVehicleLocked(veh)
                end)

                if not ok then
                    print(('^1[Vehicle Insurance] Failed to check vehicle %s (plate: %s): %s^7'):format(veh, plate, tostring(occupied)))
                elseif occupied then
                    skippedOccupied += 1
                    print(('^6[Vehicle Insurance] SKIP (occupied) - netId: %s, plate: %s, lockStatus: %s^7'):format(netId, plate, rawLockStatus))
                elseif locked then
                    skippedLocked += 1
                    print(('^6[Vehicle Insurance] SKIP (locked) - netId: %s, plate: %s, lockStatus: %s^7'):format(netId, plate, rawLockStatus))
                else
                    -- KUNCI FIX FLAPPING:
                    -- SetEntityOrphanMode(veh, 2) DULU sebelum DeleteEntity.
                    -- Ini bikin entity langsung "lepas" dari network ownership
                    -- semua client, jadi gak ada client yang bisa re-stream
                    -- entity balik ke server. Delete jadi instan, no flapping.
                    if DoesEntityExist(veh) then
                        SetEntityOrphanMode(veh, 2)
                        DeleteEntity(veh)
                    end

                    deletedCount += 1
                    print(('^2[Vehicle Insurance] Deleted - netId: %s, plate: %s, lockStatus: %s^7'):format(netId, plate, rawLockStatus))

                    -- kasih 1 frame biar delete ke-apply sebelum lanjut ke vehicle berikutnya
                    Wait(0)
                end
            end
        end
    end

    print(('^2[Vehicle Insurance] Deleted %d. Skipped %d (occupied), %d (locked), %d (bukan kendaraan player).^7'):format(deletedCount, skippedOccupied, skippedLocked, skippedNotOwned))

    return deletedCount
end

local function runInsuranceCycle()
    if isRunningCycle then return end
    isRunningCycle = true

    state.phase = 'warning'
    state.warningEndsAt = GetGameTimer() + Config.WarningDuration
    TriggerClientEvent('vehicleinsurance:client:startWarning', -1, Config.WarningDuration)

    Wait(Config.WarningDuration)

    local deletedCount = deleteUnoccupiedVehicles()

    state.phase = 'idle'
    state.warningEndsAt = nil
    isRunningCycle = false

    TriggerClientEvent('vehicleinsurance:client:warningEnd', -1, deletedCount)
end

-- dipanggil pas player baru connect/load, biar yang connect di tengah
-- countdown langsung liat sisa waktu yang bener, bukan mulai dari awal
lib.callback.register('vehicleinsurance:server:getState', function(source)
    local remaining = nil
    if state.phase == 'warning' and state.warningEndsAt then
        remaining = math.max(0, state.warningEndsAt - GetGameTimer())
    end
    return { phase = state.phase, remaining = remaining }
end)

CreateThread(function()
    local silentDuration = math.max(0, Config.CycleInterval - Config.WarningDuration)
    while true do
        Wait(silentDuration)
        runInsuranceCycle()
    end
end)

lib.addCommand('testinsurance', {
    help = 'Force trigger the vehicle insurance cycle (admin testing only)',
    restricted = true, -- morph_ui checks the 'command.testinsurance' ace permission for this
    params = {}
}, function(source)
    local src = source
    print(('^3[Vehicle Insurance] /testinsurance triggered by %s^7'):format(src))
    if isRunningCycle then
        TriggerClientEvent('chat:addMessage', src, { args = { '^3[Insurance]', 'A cycle is already running.' } })
        return
    end
    CreateThread(runInsuranceCycle)
end)

print("^2[Vehicle Insurance] Server loaded^7")