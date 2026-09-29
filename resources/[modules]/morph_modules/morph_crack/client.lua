local QBCore = exports['qb-core']:GetCoreObject()

function StartMinigame(combo)
	local Coords = GetEntityCoords(PlayerPedId(), false)
	local Object = GetClosestObjectOfType(Coords.x, Coords.y, Coords.z, 5.0, `v_ilev_gangsafedoor`, false, false, false)
	local ObjectHeading = GetEntityHeading(Object)
	local txd = CreateRuntimeTxd(morph_crack.Config.TextureDict)
	for i = 1, 2 do CreateRuntimeTextureFromImage(txd, tostring(i), "LockPart" .. i .. ".PNG") end
	loadAnimDict("mini@safe_cracking")
	TaskPlayAnim(PlayerPedId(), "mini@safe_cracking", "dial_turn_anti_fast_1", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
	FreezeEntityPosition(PlayerPedId(), true)
	SetEntityHeading(PlayerPedId(), ObjectHeading)
	morph_crack.MinigameOpen = true
	morph_crack.SoundID 	  = GetSoundId() 
	morph_crack.Timer 		  = GetGameTimer()
  	morph_crack.StayClosed = false

	if not RequestAmbientAudioBank(morph_crack.Config.AudioBank, false) then RequestAmbientAudioBank(morph_crack.Config.AudioBankName, false); end
	if not HasStreamedTextureDictLoaded(morph_crack.Config.TextureDict, false) then RequestStreamedTextureDict(morph_crack.Config.TextureDict, false); end
	CreateThread(function() 
		Update(combo)
	end)
end

RegisterNetEvent('morph_crack:StartMinigame', function(combo)
	StartMinigame(combo); 
end)

function Update(combo)
	CreateThread(function() HandleMinigame(combo); end)
	while morph_crack.MinigameOpen do
		InputCheck()  
		if IsEntityDead(PlayerPedId()) then EndMinigame(false, false); end
		Wait(0)
	end
end

function InputCheck()
    local leftKeyPressed = IsControlPressed( 0, 174) or 0 -- Left
    local rightKeyPressed = IsControlPressed( 0, 175) or 0 -- Right
    if IsControlPressed( 0, 322) then -- Esc
        EndMinigame(false)
    end
    if IsControlPressed( 0, 20) then -- Z
        rotSpeed = 0.1
        modifier = 33
    elseif IsControlPressed( 0, 21) then -- Left Shift
        rotSpeed = 1.0
        modifier = 50
    else
        rotSpeed = 0.4
        modifier = 90
    end
	
    local lockRotation = math.max(modifier / rotSpeed, 0.1)

	if leftKeyPressed ~= 0 or rightKeyPressed ~= 0 then
		
    	morph_crack.LockRotation = morph_crack.LockRotation - ( rotSpeed * tonumber( leftKeyPressed ) )
    	morph_crack.LockRotation = morph_crack.LockRotation + ( rotSpeed * tonumber( rightKeyPressed ) )
    	if (GetGameTimer() - morph_crack.Timer) > lockRotation then 
    		PlaySoundFrontend(0, morph_crack.Config.SafeTurnSound, morph_crack.Config.SafeSoundset, false)
    		morph_crack.Timer = GetGameTimer() 
    	end
    end
end

function HandleMinigame(combo) 
    local correctGuesses = {}
    
    -- Validasi combo adalah table
    if type(combo) ~= "table" then
        print("Error: combo is not a table")
        EndMinigame(false)
        morph_crack.MinigameOpen = false
        return
    end
    
    if combo[1] <= 149 then
        lockRot = math.random(150, 359)
    else
        lockRot = math.random(1, 149)
    end

    local correctCount = 1
    local hasRandomized = false

    morph_crack.LockRotation = 0.0 + lockRot
    while morph_crack.MinigameOpen do
        DrawSprite(morph_crack.Config.TextureDict, "1", 0.8, 0.5, 0.15, 0.26, -morph_crack.LockRotation, 255, 255, 255, 255)
        DrawSprite(morph_crack.Config.TextureDict, "2", 0.8, 0.5, 0.176, 0.306, -0.0, 255, 255, 255, 255)

        hasRandomized = true

        local lockVal = math.floor(morph_crack.LockRotation)

        if correctCount > 1 and correctCount < (#combo + 1) and lockVal + (morph_crack.Config.LockTolerance * 3.60) < combo[correctCount - 1] and combo[correctCount - 1] < combo[correctCount] then 
            EndMinigame(false)
            morph_crack.MinigameOpen = false
        elseif correctCount > 1 and correctCount < (#combo + 1) and lockVal - (morph_crack.Config.LockTolerance * 3.60) > combo[correctCount - 1] and combo[correctCount - 1] > combo[correctCount] then 
            EndMinigame(false)
            morph_crack.MinigameOpen = false
        elseif correctCount > #combo then 
            EndMinigame(true)
        end

        for k, v in pairs(combo) do
            if not hasRandomized then 
                morph_crack.LockRotation = lockRot
            end
            if lockVal == v and correctCount == k then
                local canAdd = true
                for key, val in pairs(correctGuesses) do
                    if val == lockVal and key == correctCount then
                        canAdd = false
                    end
                end

                if canAdd then
                    PlaySoundFrontend(-1, morph_crack.Config.SafePinSound, morph_crack.Config.SafeSoundset, true)
                    correctGuesses[correctCount] = lockVal
                    correctCount = correctCount + 1
                end
            end
        end
        Wait(0)
    end
end


function EndMinigame(won)
	morph_crack.MinigameOpen = false
	if won then 
		PlaySoundFrontend(morph_crack.SoundID, morph_crack.Config.SafeFinalSound, morph_crack.Config.SafeSoundset, true)
		QBCore.Functions.Notify("Safe opened..", "success")
	else
		QBCore.Functions.Notify("Safe opening failed..", "error")
	end
  	TriggerEvent('morph_crack:EndMinigame', won)
	FreezeEntityPosition(PlayerPedId(), false)
	ClearPedTasksImmediately(PlayerPedId())
end

RegisterNetEvent('morph_crack:EndGame', function()
	EndMinigame();
end)

function OpenSafeDoor()
  CreateThread(function(...)
    local objs = {}
    local doorHash = (GetHashKey(morph_crack.SafeModels.Door) % 0x100000000)
    for k,v in pairs(objs) do
      if (GetEntityModel(v)% 0x100000000) == doorHash then 

        local doorHeading = GetEntityPhysicsHeading(v)
        local doorPosition = GetEntityCoords(v)

        SetEntityCollision(v, false, false)
        FreezeEntityPosition(v, false)

        local targetHeading = doorHeading + 150
        local tick = 0
        while targetHeading > GetEntityHeading(v) and tick < 500 do    
          tick = tick + 1
          SetEntityHeading(v, GetEntityHeading(v) + 0.3)
          SetEntityCoords(v, doorPosition, false, false, false, false)
          Wait(0)
        end

        if not (GetEntityHeading(v) >= targetHeading) then SetEntityHeading(v, targetHeading); end
      end
    end  
  end)
end

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Wait( 5 )
    end
end 

function SpawnSafeObject(table, position, heading)
	if not table then table = morph_crack.SafeObjects; end
	if not table or not position or not heading then return; end
	if type(table) ~= 'table' or type(position) ~= 'vector3' or type(heading) ~= 'number' then return; end

	LoadModelTable(morph_crack.SafeModels)

	local retTable = {}
	local i = 0
	for k,v in pairs(table) do
		i = i + 1
		local hash = GetHashKey(v.ModelName) % 0x100000000
		local newHeading = heading + v.Heading

		local newObj = CreateObject(hash, v.Pos.x + position.x, v.Pos.y + position.y, v.Pos.z + position.z, false, false, false)

		if v.ModelName == morph_crack.SafeModels.Door then 
			morph_crack.DoorObj = newObj
			morph_crack.DoorHeading = GetEntityHeading(morph_crack.DoorObj)
		end

		SetEntityAsMissionEntity(newObj, true)
		FreezeEntityPosition(newObj, true)
		SetEntityHeading(newObj, newHeading)

		if v.Rot.x ~= 0.0 or v.Rot.y ~= 0.0 or v.Rot.z ~= 0.0 then SetEntityRotation(newObj, v.Rot.x, v.Rot.y, v.Rot.z, 1, true); end
		retTable[v.ModelName] = newObj		
	end

	ReleaseModelTable(morph_crack.SafeModels)
	morph_crack.Objects = retTable
	return retTable
end

function DelSafe()
	for k,v in pairs(morph_crack.Objects) do DeleteObject(v); end
end

RegisterNetEvent('morph_crack:SpawnSafe', function(tab, pos, heading, cb)
if cb then cb(SpawnSafeObject(tab,pos,heading)) else SpawnSafeObject(tab,pos,heading); end; end)

function LoadModelTable(table)
  if type(table) ~= 'table' then return false; end
  for k,v in pairs(table) do
    if type(v) == 'string' then
      local hk = GetHashKey(v) % 0x100000000
      while not HasModelLoaded(hk) do
        RequestModel(hk)
        Wait(0)
      end
    end
  end
  return true
end

function ReleaseModelTable(table)
  if type(table) ~= 'table' then return false; end
  for k,v in pairs(table) do
    if type(v) == 'string' then
      local hk = GetHashKey(v) % 0x100000000
      if HasModelLoaded(hk) then
        SetModelAsNoLongerNeeded(hk)
      end
    end
  end
  return true
end
