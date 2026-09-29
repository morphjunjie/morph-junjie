Framework.Core(Framework)

local skinCache = {}
RegisterNetEvent("um-clearCacheSkin", function()
  skinCache = {}
  Debug("Skin cache cleared")
end)

local firstHideDone = false
RegisterNUICallback("characterGenerate", function(citizenid, cb)
  if not firstHideDone then
    SetEntityVisible(cache.ped, false, false)
    firstHideDone = true
  end
  if not citizenid then
    warn("Citizenid is nil")
    return
  end
  if not skinCache[citizenid] then
    local modelSM, skinData = lib.callback.await("morph_mchar:server:getSkin", false, citizenid)
    if modelSM and skinData then
      skinCache[citizenid] = { modelSM = modelSM, skinData = skinData }
      Debug("Skin data loaded")
    else
      SetEntityVisible(cache.ped, false, false)
      warn("Failed to load skin data, check the SQL > your character skin data")
      return cb(1)
    end
  end
  local data = skinCache[citizenid]
  if data then
    SetModel(data.modelSM)
    ClothingExports(PlayerPedId(), data.skinData)
    cache.set(cache, "ped", PlayerPedId())
    AnimationPlay()
    SetEntityVisible(cache.ped, true, false)
    Debug("Character generated")
  end
  cb(1)
  Particle()
end)

local function preparePlayTransition()
  SetNui(false)
  SendNUIMessage({ ui = false, bgMusic = Config.BackgroundMusic })
  while IsNuiFocused() do
    Wait(0)
  end
  CamShake()
  DoScreenFadeOut(2000)
  while not IsScreenFadedOut() do
    Wait(0)
  end
end

RegisterNUICallback("createNewCharacter", function(payload, cb)
  cb("ok")
  local ok = lib.callback.await("morph_mchar:callback:inputCheck", 2000, payload)
  if not ok then
    return
  end
  preparePlayTransition()
  if payload.gender == "male" then
    payload.gender = 0
    SetModel("mp_m_freemode_01")
  else
    if payload.gender == "female" then
      payload.gender = 1
      SetModel("mp_f_freemode_01")
    end
  end
  lib.callback.await("morph_mchar:server:createCharacter", 5000, payload)
  ClearAndPlay()
end)

RegisterNUICallback("playGame", function(payload, cb)
  cb("ok")
  preparePlayTransition()
  local data = payload.data
  lib.callback.await("morph_mchar:server:loadUserData", 5000, data)
  ClearAndPlay()
end)

RegisterNUICallback("photoFilter", function(filterName, cb)
  cb("ok")
  Debug("Filter: " .. filterName)
  SetTimecycleModifier(filterName)
  SetTimecycleModifierStrength(1.0)
end)

RegisterNUICallback("deleteCharacter", function(citizenid, cb)
  cb("ok")
  if not citizenid then
    return
  end
  preparePlayTransition()
  lib.callback.await("morph_mchar:server:deleteCharacter", 5000, citizenid)
  ClearAndPlay()
end)

RegisterNUICallback("exit", function(_, cb)
  cb("ok")
  TriggerServerEvent("morph_mchar:server:disconnect")
end)
