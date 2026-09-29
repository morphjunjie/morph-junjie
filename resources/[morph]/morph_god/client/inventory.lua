-- Open Inventory
RegisterNetEvent('morph_god:client:openInventory', function(data, selectedData)
    local player = selectedData["Player"].value

    if Config.Inventory == 'morph_inv' then
        TriggerServerEvent("morph_god:server:OpenInv", player)
    else
        TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", player)
    end
end)

-- Open Stash
RegisterNetEvent('morph_god:client:openStash', function(data, selectedData)
    local stash = selectedData["Stash"].value

    if Config.Inventory == 'morph_inv' then
        TriggerServerEvent("morph_god:server:OpenStash", stash)
    else
        TriggerServerEvent("inventory:server:OpenInventory", "stash", tostring(stash))
        TriggerEvent("inventory:client:SetCurrentStash", tostring(stash))
    end
end)

-- Open Trunk
RegisterNetEvent('morph_god:client:openTrunk', function(data, selectedData)
    local vehiclePlate = selectedData["Plate"].value

    if Config.Inventory == 'morph_inv' then
        TriggerServerEvent("morph_god:server:OpenTrunk", vehiclePlate)
    else
        TriggerServerEvent("inventory:server:OpenInventory", "trunk", tostring(vehiclePlate))
        TriggerEvent("inventory:client:SetCurrentStash", tostring(vehiclePlate))
    end
end)
