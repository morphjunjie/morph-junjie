lib.versionCheck('communityox/morph_tget')

if not lib.checkDependency('morph_ui', '3.30.0', true) then return end

---@type table<number, EntityInterface>
local entityStates = {}

---@param netId number
RegisterNetEvent('morph_tget:setEntityHasOptions', function(netId)
    local entity = Entity(NetworkGetEntityFromNetworkId(netId))
    entity.state.hasTargetOptions = true
    entityStates[netId] = entity
end)

---@param netId number
---@param door number
RegisterNetEvent('morph_tget:toggleEntityDoor', function(netId, door)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then return end

    local owner = NetworkGetEntityOwner(entity)
    TriggerClientEvent('morph_tget:toggleEntityDoor', owner, netId, door)
end)

CreateThread(function()
    local arr = {}
    local num = 0

    while true do
        Wait(10000)

        for netId, entity in pairs(entityStates) do
            if not DoesEntityExist(entity.__data) or not entity.state.hasTargetOptions then
                entityStates[netId] = nil
                num += 1

                arr[num] = netId
            end
        end

        if num > 0 then
            TriggerClientEvent('morph_tget:removeEntity', -1, arr)
            table.wipe(arr)

            num = 0
        end
    end
end)
