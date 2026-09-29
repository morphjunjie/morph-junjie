Citizen.CreateThread(function()
    if DamageConfig and DamageConfig.Weapons then
        for i, v in pairs(DamageConfig.Weapons) do
            SetWeaponDamageModifier(v.weapon_name, v.damage_multiplier)
        end
    else
        print("^1[ERROR]^7 Config.Weapons tidak ditemukan!")
    end
end)

-- ANTI HEADSHOT
-- MATIKAN HEADSHOT DEFAULT GTA
CreateThread(function()
    while true do
        Wait(2000)

        SetPedSuffersCriticalHits(PlayerPedId(), false)

        for _, ped in pairs(GetGamePool("CPed")) do
            if DoesEntityExist(ped) then
                SetPedSuffersCriticalHits(ped, false)
            end
        end
    end
end)

-- CUSTOM HEADSHOT DAMAGE
local HEAD_BONE = 31086
local HEADSHOT_MULTIPLIER = 5.5

AddEventHandler('gameEventTriggered', function(eventName, args)
    if eventName ~= "CEventNetworkEntityDamage" then return end

    local victim = args[1]
    local attacker = args[2]
    local weaponHash = args[7]

    if attacker ~= PlayerPedId() then return end
    if not DoesEntityExist(victim) then return end
    if not IsEntityAPed(victim) then return end

    -- cek bone terakhir yang kena
    local success, bone = GetPedLastDamageBone(victim)
    if not success then return end

    if bone == HEAD_BONE then
        local health = GetEntityHealth(victim)

        local baseDamage = 20 -- sesuaikan kalau perlu
        local bonusDamage = math.floor(baseDamage * (HEADSHOT_MULTIPLIER - 1.0))

        SetEntityHealth(victim, health - bonusDamage)
    end
end)