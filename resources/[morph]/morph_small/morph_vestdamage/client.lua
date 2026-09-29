local config = require 'morph_vestdamage.config'

-- Melee Armour Damage Script (PvP + NPC, configurable)

-- PvP handler (player vs player)
AddEventHandler('gameEventTriggered', function(name, args)
    if name == "CEventNetworkEntityDamage" then
        local victim = args[1]
        local attacker = args[2]
        local weaponHash = args[7]

        if IsEntityAPed(victim) and IsPedAPlayer(victim) and IsPedAPlayer(attacker) then
            if weaponHash == GetHashKey("WEAPON_UNARMED") then
                local armour = GetPedArmour(victim)
                local health = GetEntityHealth(victim)
                local damage = Config.PvPDamage

                if armour > 0 then
                    local newArmour = armour - damage
                    if newArmour < 0 then
                        local leftover = math.abs(newArmour)
                        SetPedArmour(victim, 0)
                        SetEntityHealth(victim, health - leftover)
                    else
                        SetPedArmour(victim, newArmour)
                    end
                else
                    SetEntityHealth(victim, health - damage)
                end

                CancelEvent()
            end
        end
    end
end)

-- NPC vs Player handler (loop monitor)
Citizen.CreateThread(function()
    local ped = PlayerPedId()
    local lastHealth = GetEntityHealth(ped)

    while true do
        Citizen.Wait(0)
        ped = PlayerPedId()
        local health = GetEntityHealth(ped)
        local armour = GetPedArmour(ped)

        if health < lastHealth and armour > 0 then
            local damage
            if Config.UseFixedNPCDamage then
                damage = Config.NPCDamage
            else
                damage = lastHealth - health
            end

            -- balikin health
            SetEntityHealth(ped, lastHealth)
            -- kurangi armour
            local newArmour = armour - damage
            if newArmour < 0 then
                SetPedArmour(ped, 0)
                SetEntityHealth(ped, lastHealth - math.abs(newArmour))
            else
                SetPedArmour(ped, newArmour)
            end
        end

        lastHealth = GetEntityHealth(ped)
    end
end)
