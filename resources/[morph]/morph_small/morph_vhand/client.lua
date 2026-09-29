if not lib then print('^1morph_ui must be started before this resource.^0') return end
lib.locale()

---@class Handler : OxClass
local Handler = require 'morph_vhand.modules.handler'
local Settings <const> = lib.load('morph_vhand.data.vehicle')
local Units <const> = Settings.units == 'mph' and 2.23694 or 3.6

---@param vehicle number
local function startThread(vehicle)
    if not vehicle then return end
    if not Handler or Handler:isActive() then return end

    Handler:setActive(true)

    local oxfuel = Handler:isFuelOx()
    local electric = Handler:isElectric()
    local class = Handler:getClass()
    local model = Handler:getModel()

    CreateThread(function()
        while (cache.vehicle == vehicle) and (cache.seat == -1) do

            -- Retrieve latest vehicle data
            local engine, body, speed = Handler:setData({
                ['engine'] = GetVehicleEngineHealth(vehicle),
                ['body'] = GetVehicleBodyHealth(vehicle),
                ['speed'] = GetEntitySpeed(vehicle) * Units
            })

            -- Prevent negative engine health & driveability handler (engine)
            if engine <= 0 then
                if engine < 0 then
                    SetVehicleEngineHealth(cache.vehicle, 0.0)
                end

                if IsVehicleDriveable(vehicle, true) then
                    SetVehicleUndriveable(vehicle, true)
                end
            end

            -- Prevent negative body health
            if body < 0 then
                SetVehicleBodyHealth(cache.vehicle, 0.0)
            end

            -- Driveability handler (fuel)
            if not electric and class ~= 14 then
                local fuel = oxfuel and Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle)

                if fuel <= 7 then
                    if IsVehicleDriveable(vehicle, true) then
                        SetVehicleUndriveable(vehicle, true)
                    end
                end
            end

            -- Reduce torque after half-life
            if not Handler:isLimited() and engine < 500 then
                Handler:setLimited(true)

                CreateThread(function()
                    while cache.vehicle == vehicle and cache.seat == -1 do
                        local engineLevel = Handler:getData('engine')
                        if engineLevel >= 500 then break end

                        SetVehicleCheatPowerIncrease(vehicle, (engineLevel + 500) / 1100)
                        Wait(1)
                    end

                    Handler:setLimited(false)
                end)
            end

            -- Prevent rotation controls while flipped/airborne
            if Settings.regulated[class] and not Settings.exclusions[model] then
                local roll, airborne = 0.0, false

                if speed < 2.0 then
                    roll = GetEntityRoll(vehicle)
                else
                    airborne = IsEntityInAir(vehicle)
                end

                if (roll > 75.0 or roll < -75.0) or airborne then
                    if Handler:canControl() then
                        Handler:setControl(false)

                        CreateThread(function()
                            while not Handler:canControl() and cache.seat == -1 do
                                DisableControlAction(2, 59, true) -- Disable left/right
                                DisableControlAction(2, 60, true) -- Disable up/down
                                Wait(1)
                            end

                            if not Handler:canControl() then Handler:setControl(true) end
                        end)
                    end
                else
                    if not Handler:canControl() then Handler:setControl(true) end
                end
            end

            Wait(300)
        end

        Handler:setActive(false)

        -- Retrigger thread if admin spawns a new vehicle while in one
        if cache.vehicle and cache.seat == -1 then
            startThread(cache.vehicle)
        end
    end)
end

---@param victim number
---@param weapon number | string
AddEventHandler('entityDamaged', function(victim, _, weapon, _)
    if not Handler or not Handler:isActive() then return end
    if victim ~= cache.vehicle then return end

    -- Damage from weapons - reduced to allow engine to slow down gradually instead of dying instantly
    local weaponGroup = GetWeapontypeGroup(weapon)
    if weaponGroup == 416676503 or weaponGroup == 268538723 or weaponGroup == 1548507267 then
        -- 416676503 = guns, 268538723 = melee, 1548507267 = explosives
        local currentEngine = GetVehicleEngineHealth(cache.vehicle)
        local newEngine = currentEngine - 80.0 -- Reduced from 300 to allow gradual degradation

        if newEngine > 0 then
            SetVehicleEngineHealth(cache.vehicle, newEngine)
        end
    end

    -- Collision damage handler - gradually reduces engine instead of killing it
    local bodyDiff = Handler:getData('body') - GetVehicleBodyHealth(cache.vehicle)
    if bodyDiff > 0 then
        local bodyDamage = bodyDiff * Settings.globalmultiplier * Settings.classmultiplier[Handler:getClass()]
        local newEngine = GetVehicleEngineHealth(cache.vehicle) - bodyDamage

        if newEngine > 0 and newEngine ~= Handler:getData('engine') then
            SetVehicleEngineHealth(cache.vehicle, newEngine)
        elseif newEngine <= 0 and Handler:getData('engine') > 0 then
            -- Set to minimum instead of 0 to allow engine to keep running
            SetVehicleEngineHealth(cache.vehicle, math.max(50.0, newEngine))
        end
    end

    -- Impact handler - breaks tires on impact but allows engine to keep running
    local speedDiff = Handler:getData('speed') - (GetEntitySpeed(cache.vehicle) * Units)
    if speedDiff >= Settings.threshold.speed then
        if Settings.breaktire then
            if bodyDiff >= Settings.threshold.health then
                math.randomseed(GetGameTimer())
                Handler:breakTire(cache.vehicle, math.random(0, 1))
            end
        end

        -- Heavy impacts reduce engine health significantly but don't kill it instantly
        if speedDiff >= Settings.threshold.heavy then
            local currentEngine = GetVehicleEngineHealth(cache.vehicle)
            local heavyImpactDamage = currentEngine * 0.4 -- Reduce engine by 40% on heavy impact
            SetVehicleEngineHealth(cache.vehicle, math.max(100.0, currentEngine - heavyImpactDamage))
        end
    end
end)


---@param fixtype string
---@return boolean | nil success
lib.callback.register('morph_vhand:basicfix', function(fixtype)
    if not Handler then return end
    return Handler:basicfix(fixtype)
end)

---@return boolean | nil success
lib.callback.register('morph_vhand:basicwash', function()
    if not Handler then return end
    return Handler:basicwash()
end)

---@return boolean | nil success
lib.callback.register('morph_vhand:adminfix', function()
    if not Handler or not Handler:isActive() then return end
    return Handler:adminfix()
end)

---@return boolean | nil success
lib.callback.register('morph_vhand:adminwash', function()
    if not Handler or not Handler:isActive() then return end
    return Handler:adminwash()
end)

---@param newlevel number
---@return boolean | nil success
lib.callback.register('morph_vhand:adminfuel', function(newlevel)
    if not Handler or not Handler:isActive() then return end
    return Handler:adminfuel(newlevel)
end)

---@param seat number
lib.onCache('seat', function(seat)
    if seat == -1 then
        startThread(cache.vehicle)
    end
end)

CreateThread(function()
    Handler = Handler:new()

    if cache.seat == -1 then
        startThread(cache.vehicle)
    end
end)