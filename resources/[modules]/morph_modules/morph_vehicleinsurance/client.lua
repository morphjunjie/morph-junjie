-- client.lua
local isCountingDown = false
local pendingDeletedCount = nil

local function Notify(desc, type)
    lib.notify({ title = 'Morph Insurance', description = desc, type = type or 'info', duration = 4000 })
end

local function formatTime(ms)
    local totalSeconds = math.max(0, math.ceil(ms / 1000))
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    return string.format('%02d:%02d', minutes, seconds)
end

local function startCountdown(durationMs, silent)
    if isCountingDown then return end
    isCountingDown = true
    pendingDeletedCount = nil

    if not silent then
        Notify('Unclaimed vehicles will be removed in 5 minutes. Lock your vehicle to keep it safe.', 'info')
    end

    local endTime = GetGameTimer() + durationMs

    CreateThread(function()
        while isCountingDown do
            if pendingDeletedCount ~= nil then
                break
            end

            local remaining = endTime - GetGameTimer()
            if remaining <= 0 then
                break
            end

            lib.showTextUI(('Morph Insurance in: %s'):format(formatTime(remaining)), { position = 'left-center', icon = 'car-burst' })
            Wait(math.min(1000, remaining))
        end

        lib.hideTextUI()
        isCountingDown = false

        if pendingDeletedCount ~= nil then
            Notify(string.format('Vehicle insurance cycle complete. %d vehicle(s) were removed.', pendingDeletedCount), 'info')
            pendingDeletedCount = nil
        end
    end)
end

RegisterNetEvent('vehicleinsurance:client:startWarning', function(durationMs)
    startCountdown(durationMs, false)
end)

RegisterNetEvent('vehicleinsurance:client:warningEnd', function(deletedCount)
    pendingDeletedCount = deletedCount or 0

    if not isCountingDown then
        lib.hideTextUI()
        Notify(string.format('Vehicle insurance cycle complete. %d vehicle(s) were removed.', pendingDeletedCount), 'info')
        pendingDeletedCount = nil
    end
end)

CreateThread(function()
    local result = lib.callback.await('vehicleinsurance:server:getState', false)
    if result and result.phase == 'warning' and result.remaining and result.remaining > 0 then
        startCountdown(result.remaining, true)
    end
end)