local Gym = { inGym = false, isTraining = false, cooldown = false, textShown = false, playerStress = 0 }

local function Notify(desc, type) lib.notify({ title = 'Morph Gym Activity', description = desc, type = type or 'info', duration = 3000 }) end
local function Progress(duration, label) return lib.progressBar({ duration = duration, label = label, canCancel = true, disable = { move = true, car = true, combat = true } }) end
local function Emote(name) exports['morph_emote']:EmoteCommandStart(name) end
local function EmoteCancel() exports['morph_emote']:EmoteCancel() end
local function ShowTextUI(text)
    lib.showTextUI(text, { position = 'left-center', icon = 'dumbbell' })
end
local function HideTextUI() lib.hideTextUI() end

function Gym:toggleUI(show)
    if show and not self.textShown then ShowTextUI('E - Start Workout'); self.textShown = true
    elseif not show and self.textShown then HideTextUI(); self.textShown = false end
end

function Gym:updateInteraction()
    local shouldShow = self.inGym and not self.isTraining and not self.cooldown and self.playerStress > 0
    self:toggleUI(shouldShow)
end

-- Coba beberapa sumber stress secara berurutan, karena beda server bisa pakai
-- state bag, HUD resource, atau event sendiri buat nyimpen nilai stress.
local function getStressLevel()
    local state = LocalPlayer.state
    local val = state.stress or state.stressLevel or state.stressAmount
    if val then return val end
    if GetResourceState('morph_hud') == 'started' then
        local success, result = pcall(function() return exports['morph_hud']:GetStress() end)
        if success then return result end
    end
    return 0
end

RegisterNetEvent('hud:client:UpdateStress', function(newStress) Gym.playerStress = newStress or 0; Gym:updateInteraction() end)
AddStateBagChangeHandler('stress', ('player:%s'):format(cache.serverId), function(_, _, value) Gym.playerStress = value or 0; Gym:updateInteraction() end)
RegisterNetEvent('stress:update', function(amount) Gym.playerStress = amount or 0; Gym:updateInteraction() end)

CreateThread(function()
    if not GymConfig or not GymConfig.Zone then print('^1[GYM] Config missing!^7'); return end
    local gymZone = morph_zone:Create(GymConfig.Zone, {
        name = 'gym_zone',
        minZ = GymConfig.MinZ or -10,
        maxZ = GymConfig.MaxZ or 10,
        debugPoly = false
    })
    gymZone:onPlayerInOut(function(isInside)
        Gym.inGym = isInside
        Gym:updateInteraction()
    end)
end)

CreateThread(function()
    while true do
        local sleep = 500
        if Gym.inGym and not Gym.isTraining and not Gym.cooldown then sleep = 0; if IsControlJustPressed(0, 38) then Gym:openMenu() end end
        Wait(sleep)
    end
end)

function Gym:openMenu()
    if (self.playerStress or 0) <= 0 then Notify('Already relaxed. No workout needed.', 'info'); return end
    local options = {}
    local activities = { { id = 'pushup', label = 'Push Up', icon = 'fa-solid fa-hand-fist' }, { id = 'situp', label = 'Sit Up', icon = 'fa-solid fa-person-walking' }, { id = 'weights', label = 'Weights', icon = 'fa-solid fa-dumbbell' } }
    for _, v in ipairs(activities) do
        local cfg = GymConfig.Activities[v.id]
        if cfg then
            local durSec = math.floor((cfg.duration or 0) / 1000)
            table.insert(options, { title = v.label, description = string.format('Reduce stress: %d | Duration: %ds', cfg.stressRelief or 0, durSec), icon = v.icon, onSelect = function() self:startWorkout(v.id) end })
        end
    end
    -- di-floor dulu sebelum %d, soalnya playerStress bisa aja desimal
    -- tergantung sumbernya (HUD resource lain, state bag, dll)
    local stress = math.floor(tonumber(self.playerStress) or 0)
    table.insert(options, { title = 'Check Stress', description = string.format('Current stress: %d', stress), icon = 'fa-solid fa-heart-pulse', readOnly = true, metadata = { { label = 'Status', value = stress > 50 and 'High' or 'Normal' } } })
    lib.registerContext({ id = 'gym_menu', title = 'Gym Activity', options = options })
    lib.showContext('gym_menu')
end

function Gym:startWorkout(activity)
    if self.isTraining or self.cooldown or self.playerStress <= 0 then return end
    local cfg = GymConfig.Activities[activity]
    if not cfg then return end
    self.isTraining = true; self:toggleUI(false)
    local ped = PlayerPedId()
    SetPedCanRagdoll(ped, false); Emote(cfg.emote)
    local label = string.format('Doing %s...', activity:sub(1,1):upper() .. activity:sub(2))
    local success = Progress(cfg.duration, label)
    EmoteCancel(); SetPedCanRagdoll(ped, true); self.isTraining = false
    if success then
        local stressReduction = cfg.stressRelief
        -- bonus relief kalau stress lagi tinggi banget
        if self.playerStress > 50 then stressReduction = stressReduction + math.random(2, 5) end
        local stressBefore = math.floor(tonumber(self.playerStress) or 0)
        self.playerStress = math.max(0, stressBefore - stressReduction)
        TriggerServerEvent('hud:server:RelieveStress', stressReduction)
        Notify(string.format('Stress reduced: %d → %d (-%d)', stressBefore, math.floor(self.playerStress), math.floor(stressReduction)), 'success')
        self.cooldown = true
        SetTimeout(GymConfig.Cooldown or 5000, function() self.cooldown = false; self:updateInteraction() end)
    else
        Notify('Workout cancelled', 'info')
        self:updateInteraction()
    end
end

local busyCategories, categoryIndexes = {}, {}
local function getNextCategoryId() for i = 50, 51 do if not categoryIndexes[i] then categoryIndexes[i] = true; return i end end end
local function setBlipCategory(blip, name) local id = busyCategories[name] or getNextCategoryId(); if not id then return end; if not busyCategories[name] then busyCategories[name] = id; AddTextEntry("BLIP_CAT_" .. id, name) end; SetBlipCategory(blip, id) end
exports('setBlipCategory', setBlipCategory); Blip = { setBlipCategory = setBlipCategory }

CreateThread(function()
    local cfg = GymConfig.Blip
    if not cfg then return end
    local blip = AddBlipForCoord(cfg.coords.x, cfg.coords.y, cfg.coords.z)
    SetBlipSprite(blip, cfg.sprite); SetBlipDisplay(blip, 4); SetBlipScale(blip, cfg.scale); SetBlipColour(blip, cfg.colour); SetBlipAsShortRange(blip, true)
    setBlipCategory(blip, "Morph Property")
    BeginTextCommandSetBlipName('STRING'); AddTextComponentString(cfg.name); EndTextCommandSetBlipName(blip)
    Wait(1000); Gym.playerStress = getStressLevel()
end)

print("^2[Morph Gym] System ready^7")