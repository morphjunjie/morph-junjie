local SpawnedNPCs = {}

CreateThread(function()
    for k, npc in pairs(NpcConfig.NPCs) do
        local model = joaat(npc.model)
        lib.requestModel(model)
        
        local c = npc.coords
        local ped = CreatePed(0, model, c.x, c.y, c.z - 1.0, c.w, false, true)
        
        SpawnedNPCs[k] = { ped = ped, data = npc, streamed = false }
        
        SetEntityAsMissionEntity(ped, true, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetPedDiesWhenInjured(ped, false)
        SetPedCanRagdoll(ped, false)
        SetPedCanBeTargetted(ped, false)
        SetEntityProofs(ped, true, true, true, true, true, true, true, true)
        
        SetEntityVisible(ped, false, false)
        SetEntityAlpha(ped, 0, false)
        
        if npc.scenario then
            TaskStartScenarioInPlace(ped, npc.scenario, 0, true)
        end
        
        if npc.animation then
            lib.requestAnimDict(npc.animation.dict)
            lib.playAnim(ped, npc.animation.dict, npc.animation.anim, 8.0, -8.0, -1, 1, 0, 0, 0, 0)
        end
        
        if npc.prop then
            local propModel = joaat(npc.prop.model)
            lib.requestModel(propModel)
            
            local prop = CreateObject(propModel, 1.0, 1.0, 1.0, true, true, false)
            AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, npc.prop.bone),
                npc.prop.coords.x, npc.prop.coords.y, npc.prop.coords.z,
                npc.prop.rotation.x, npc.prop.rotation.y, npc.prop.rotation.z,
                true, true, false, true, 1, true)
        end
        
        Wait(100)
    end
end)

CreateThread(function()
    while true do
        local sleep = 500
        local playerCoords = GetEntityCoords(PlayerPedId())
        local streamDist = NpcConfig.StreamDistance or 50.0
        local textDist = NpcConfig.TextDistance or 7.0
        
        for _, npc in pairs(SpawnedNPCs) do
            if DoesEntityExist(npc.ped) then
                local pedCoords = GetEntityCoords(npc.ped)
                local dist = #(playerCoords - pedCoords)
                
                if dist < streamDist then
                    if not npc.streamed then
                        SetEntityVisible(npc.ped, true, false)
                        SetEntityAlpha(npc.ped, 255, false)
                        npc.streamed = true
                        sleep = 0
                    end
                    
                    if npc.data.text and dist < textDist then
                        sleep = 0
                        local headBone = GetPedBoneIndex(npc.ped, 0x796E)
                        local boneCoords = GetWorldPositionOfEntityBone(npc.ped, headBone)
                        
                        SetDrawOrigin(boneCoords.x, boneCoords.y, boneCoords.z + 0.50, 0)
                        
                        SetTextScale(0.35, 0.35)
                        SetTextFont(4)
                        SetTextCentre(true)
                        SetTextProportional(1)
                        
                        local color = npc.data.text.color or {255, 255, 255, 255}
                        SetTextColour(color[1], color[2], color[3], color[4])
                        SetTextOutline()
                        SetTextDropShadow(1, 0, 0, 0, 255)
                        
                        SetTextEntry("STRING")
                        AddTextComponentString(npc.data.text.label)
                        DrawText(0.0, 0.0)
                        
                        ClearDrawOrigin()
                    end
                elseif npc.streamed then
                    SetEntityVisible(npc.ped, false, false)
                    SetEntityAlpha(npc.ped, 0, false)
                    npc.streamed = false
                end
            end
        end
        
        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    for _, npc in pairs(SpawnedNPCs) do
        if npc.ped and DoesEntityExist(npc.ped) then
            DeleteEntity(npc.ped)
        end
    end
    
    SpawnedNPCs = {}
end)