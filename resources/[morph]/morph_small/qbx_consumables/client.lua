-- EFFECT BASE
local function trevorEffect()
    CreateThread(function()
        local ped = PlayerPedId()
        RequestAnimSet("move_m@drunk@moderatedrunk")
        while not HasAnimSetLoaded("move_m@drunk@moderatedrunk") do Wait(10) end
        SetPedMovementClipset(ped, "move_m@drunk@moderatedrunk", 1.0)
        AnimpostfxPlay("FocusIn", 2000, false)
        Wait(2000)
        AnimpostfxPlay("DrugsDrivingIn", 2000, false)
        Wait(2000)
        AnimpostfxPlay("DrugsDriving", 56000, false)
        Wait(56000)
        AnimpostfxPlay("DrugsDrivingOut", 2000, false)
        Wait(2000)
        AnimpostfxPlay("FocusOut", 2000, false)
        Wait(2000)
        AnimpostfxStop("DrugsDriving")
        AnimpostfxStop("DrugsDrivingIn")
        AnimpostfxStop("DrugsDrivingOut")
        AnimpostfxStop("FocusIn")
        AnimpostfxStop("FocusOut")
        ResetPedMovementClipset(ped, 1.0)
        ResetPedStrafeClipset(ped)
        ResetPedWeaponMovementClipset(ped)
    end)
end

exports('TrevorEffect', trevorEffect)

-- GLOBAL COOLDOWNS
local cooldowns = {
    meth = { active = false, ends = 0, item = 15 * 60 * 1000 },
    weed = { active = false, ends = 0, item = 2 * 25 * 1000 },
    cocaine = { active = false, ends = 0, item = 5 * 60 * 1000 },
    crack = { active = false, ends = 0, item = 5 * 60 * 1000 }
}
local crossCooldownEnd = 0
local CROSS_COOLDOWN_TIME = 65 * 1000

local drugEffects = {
    meth = { active = false, thread = nil },
    cocaine = { active = false, thread = nil },
    crack = { active = false, thread = nil }
}

local function resetAllCooldownsAndEffects()
    for drug, data in pairs(cooldowns) do data.active = false; data.ends = 0 end
    crossCooldownEnd = 0
    
    for drug, data in pairs(drugEffects) do
        data.active = false
        if data.thread then
            TerminateThread(data.thread)
            data.thread = nil
        end
    end
    
    local ped = PlayerPedId()
    ResetPedMovementClipset(ped, 1.0)
    ResetPedStrafeClipset(ped)
    ResetPedWeaponMovementClipset(ped)
    local playerId = PlayerId()
    SetRunSprintMultiplierForPlayer(playerId, 1.0)
    SetSwimMultiplierForPlayer(playerId, 1.0)
    AnimpostfxStop('DrugsTrevorClownsFight')
    AnimpostfxStop('DrugsTrevorClownsFightIn')
    AnimpostfxStop('DrugsTrevorClownsFightOut')
    AnimpostfxStop('DrugsDriving')
    AnimpostfxStop('DrugsDrivingIn')
    AnimpostfxStop('DrugsDrivingOut')
    AnimpostfxStop('FocusIn')
    AnimpostfxStop('FocusOut')
    StopScreenEffect("DrugsTrevorClownsFight")
    StopGameplayCamShaking(true)
    SetPedMotionBlur(ped, false)
end

RegisterNetEvent('!morphjunjie:onPlayerDied', function()
    resetAllCooldownsAndEffects()
end)

RegisterNetEvent('!morphjunjie:onPlayerWasted', function()
    resetAllCooldownsAndEffects()
end)

local function isOnCooldown(drug)
    local now = GetGameTimer()
    if cooldowns[drug].active and now < cooldowns[drug].ends then
        return true, math.floor((cooldowns[drug].ends - now) / 1000)
    end
    return false, 0
end

local function isCrossBlocked()
    local now = GetGameTimer()
    if now < crossCooldownEnd then return true, math.floor((crossCooldownEnd - now) / 1000) end
    return false, 0
end

local function setCooldown(drug)
    local now = GetGameTimer()
    cooldowns[drug].active = true
    cooldowns[drug].ends = now + cooldowns[drug].item
    crossCooldownEnd = now + CROSS_COOLDOWN_TIME
end

local function playEmote()
    exports["morph_emote"]:EmoteCommandStart("smokeweed", 0)
    Wait(2000)
    exports["morph_emote"]:EmoteCancel()
end

-- METH
RegisterNetEvent('consumables:client:meth', function()
    local blocked, remain = isOnCooldown('meth')
    if blocked then return lib.notify({ title="Meth", description=("Meth cooldown: %ss remaining"):format(remain), type="error" }) end
    local cross, remainCross = isCrossBlocked()
    if cross then return lib.notify({ title="Meth", description=("Global cooldown: %ss remaining"):format(remainCross), type="error" }) end
    
    if not lib.callback.await('consumables:server:usedItem', false, 'meth_bag') then return end
    
    playEmote()
    trevorEffect()
    TriggerEvent('evidence:client:SetStatus', 'widepupils', 300)
    TriggerEvent('evidence:client:SetStatus', 'agitated', 300)
    lib.notify({ title="Meth", description="Anti-Stress active 15 minutes", type="success" })
    TriggerServerEvent("morph_consumables:ActivateMethBlock")
    setCooldown('meth')
    
    drugEffects.meth.active = true
    drugEffects.meth.thread = CreateThread(function()
        Wait(15 * 60 * 1000)
        if drugEffects.meth.active then
            lib.notify({ title="Meth", description="Anti-Stress effect has ended", type="error" })
            drugEffects.meth.active = false
        end
    end)
end)

-- WEED
RegisterNetEvent('consumables:client:weed', function()
    local blocked, remain = isOnCooldown('weed')
    if blocked then return lib.notify({ title="Weed", description=("Weed cooldown: %ss remaining"):format(remain), type="error" }) end
    local cross, remainCross = isCrossBlocked()
    if cross then return lib.notify({ title="Weed", description=("Global cooldown: %ss remaining"):format(remainCross), type="error" }) end
    
    if not lib.callback.await('consumables:server:usedItem', false, 'weed_bag') then return end
    
    playEmote()
    trevorEffect()
    
    local ped = PlayerPedId()
    local currentArmour = GetPedArmour(ped)
    local maxArmour = 75
    local addArmour = 15
    
    if currentArmour >= maxArmour then
        lib.notify({ title="Weed", description="Your armour is already maxed at 75!", type="error" })
        return
    end
    
    local newArmour = math.min(currentArmour + addArmour, maxArmour)
    SetPedArmour(ped, newArmour)
    
    lib.notify({ title="Weed", description=string.format("You get %d armour (Total: %d/75)", newArmour - currentArmour, newArmour), type="success" })
    TriggerEvent('evidence:client:SetStatus', 'weedsmell', 300)
    setCooldown('weed')
end)

-- COCAINE
RegisterNetEvent('consumables:client:Cocainebaggy', function()
    local blocked, remain = isOnCooldown('cocaine')
    if blocked then return lib.notify({ title="Cocaine", description=("Cocaine cooldown: %ss remaining"):format(remain), type="error" }) end
    local cross, remainCross = isCrossBlocked()
    if cross then return lib.notify({ title="Cocaine", description=("Global cooldown: %ss remaining"):format(remainCross), type="error" }) end
    
    if not lib.callback.await('consumables:server:usedItem', false, 'cocaine_bag') then return end
    
    playEmote()
    trevorEffect()
    lib.notify({ title="Cocaine", description="Health regen 5 minutes", type="success" })
    
    local ped, maxHealth = PlayerPedId(), GetEntityMaxHealth(PlayerPedId())
    drugEffects.cocaine.active = true
    drugEffects.cocaine.thread = CreateThread(function()
        local start = GetGameTimer()
        while GetGameTimer() - start < 5 * 60 * 1000 and drugEffects.cocaine.active do
            Wait(1500)
            if IsEntityDead(PlayerPedId()) then break end
            SetEntityHealth(PlayerPedId(), math.min(GetEntityHealth(PlayerPedId()) + 5, maxHealth))
        end
        if not IsEntityDead(PlayerPedId()) and drugEffects.cocaine.active then
            lib.notify({ title="Cocaine", description="Health regeneration ended", type="error" })
        end
        drugEffects.cocaine.active = false
    end)
    
    TriggerEvent('evidence:client:SetStatus', 'cocainesmell', 300)
    setCooldown('cocaine')
end)

-- CRACK EFFECT
local function crackEffect()
    local ped = PlayerPedId()
    StartScreenEffect("DrugsTrevorClownsFight", 0, true)
    ShakeGameplayCam("DRUNK_SHAKE", 1.0)
    SetPedMotionBlur(ped, true)
end

local function stopCrackEffect()
    local ped = PlayerPedId()
    StopScreenEffect("DrugsTrevorClownsFight")
    ShakeGameplayCam("DRUNK_SHAKE", 0.0)
    SetPedMotionBlur(ped, false)
end

-- CRACK
RegisterNetEvent('consumables:client:Crackbaggy', function()
    local blocked, remain = isOnCooldown('crack')
    if blocked then return lib.notify({ title="Crack", description=("Crack cooldown: %ss remaining"):format(remain), type="error" }) end
    local crossBlocked, crossRemain = isCrossBlocked()
    if crossBlocked then return lib.notify({ title="Crack", description=("Global cooldown: %ss remaining"):format(crossRemain), type="error" }) end
    
    if not lib.callback.await('consumables:server:usedItem', false, 'crack_bag') then return end
    
    playEmote()
    
    local playerId, ped = PlayerId(), PlayerPedId()
    SetRunSprintMultiplierForPlayer(playerId, 1.35)
    SetSwimMultiplierForPlayer(playerId, 1.25)
    lib.notify({ title="Crack", description="Speed boost active 5 minutes", type="success" })
    
    crackEffect()
    
    drugEffects.crack.active = true
    drugEffects.crack.thread = CreateThread(function()
        local startTime = GetGameTimer()
        local duration = 5 * 60 * 1000
        while drugEffects.crack.active do
            Wait(1000)
            if IsEntityDead(PlayerPedId()) then break end
            if GetGameTimer() - startTime >= duration then break end
            if not drugEffects.crack.active then break end
            if not IsEntityDead(PlayerPedId()) then RestorePlayerStamina(playerId, 1.0) end
        end
        SetRunSprintMultiplierForPlayer(playerId, 1.0)
        SetSwimMultiplierForPlayer(playerId, 1.0)
        stopCrackEffect()
        if drugEffects.crack.active then
            lib.notify({ title="Crack", description="Speed boost ended", type="error" })
        end
        drugEffects.crack.active = false
    end)
    
    TriggerEvent('evidence:client:SetStatus', 'cracksmell', 300)
    setCooldown('crack')
end)