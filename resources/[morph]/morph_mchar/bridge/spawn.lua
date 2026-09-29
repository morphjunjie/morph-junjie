local apartmentStart = GetConvar('um:NewPlayerApartmentInsideStart', 'false') == 'true'

function GetApartmentInsideStartSpawnUI(src, newData)
    if not apartmentStart then
        TriggerClientEvent('morph_mchar:client:defaultSpawn', src)
        Debug('New player spawn: default (apartment start disabled)')
        return
    end

    if GetResourceState('um-spawn') == 'started' then
        TriggerClientEvent('um-spawn:client:startSpawnUI', src, newData)
        Debug('New player spawn: um-spawn')
    elseif GetResourceState('ps-housing') == 'started' then
        if GetResourceState('morph_property') == 'started' then
            TriggerClientEvent('apartments:client:setupSpawnUI', src)
            Debug('New player spawn: ps-housing + morph_property')
            return
        end
        TriggerClientEvent('ps-housing:client:setupSpawnUI', src, newData, true, true)
        Debug('New player spawn: ps-housing')
    elseif GetResourceState('okokSpawnSelector') == 'started' then
        TriggerClientEvent('okokSpawnSelector:spawnMenu', src, true)
        Debug('New player spawn: okokSpawnSelector')
    elseif GetResourceState('vms_spawnselector') == 'started' then
        TriggerClientEvent('vms_spawnselector:open', src, true)
        Debug('New player spawn: vms_spawnselector')
    elseif GetResourceState('qb-apartments') == 'started' then
        TriggerClientEvent('apartments:client:setupSpawnUI', src, newData, true, true)
        Debug('New player spawn: qb-apartments')
    elseif GetResourceState('morph_property') == 'started' then
        TriggerClientEvent('apartments:client:setupSpawnUI', src)
        Debug('New player spawn: morph_property')
    elseif GetResourceState('qbx_apartments') == 'started' then
        TriggerClientEvent('apartments:client:setupSpawnUI', src, newData)
        Debug('New player spawn: qbx_apartments')
    elseif GetResourceState('0r-apartment') == 'started' then
        TriggerClientEvent('apartments:client:setupSpawnUI', src, newData, true, true)
        Debug('New player spawn: 0r-apartment')
    else
        TriggerClientEvent('morph_mchar:client:defaultSpawn', src)
        Debug('New player spawn: default (no resource found)')
    end
end

function GetCharacterReadySpawnUI(src, cData)
    if Config.NoSpawnMenuOnlyLastLocation.Status then
        TriggerClientEvent("morph_mchar:client:spawnLastCoords", src, json.decode(cData.position))
        Debug('Character spawn: last location')
        return
    end

    if GetResourceState('um-spawn') == 'started' then
        TriggerClientEvent('um-spawn:client:startSpawnUI', src, cData)
        Debug('Character spawn: um-spawn')
    elseif GetResourceState('okokSpawnSelector') == 'started' then
        TriggerClientEvent('okokSpawnSelector:spawnMenu', src, false, json.decode(cData.position))
        Debug('Character spawn: okokSpawnSelector')
    elseif GetResourceState('vms_spawnselector') == 'started' then
        TriggerClientEvent('vms_spawnselector:open', src)
        Debug('Character spawn: vms_spawnselector')
    elseif GetResourceState('morph_spawn') == 'started' then
        TriggerClientEvent('qb-spawn:client:setupSpawns', src, cData?.citizenid)
        TriggerClientEvent('qb-spawn:client:openUI', src, true)
        Debug('Character spawn: morph_spawn')
    elseif GetResourceState('qb-spawn') == 'started' then
        TriggerClientEvent('qb-spawn:client:setupSpawns', src, cData?.citizenid)
        TriggerClientEvent('qb-spawn:client:openUI', src, true)
        Debug('Character spawn: qb-spawn')
    else
        TriggerClientEvent("morph_mchar:client:spawnLastCoords", src, json.decode(cData.position))
        Debug('Character spawn: last location (no resource found)')
    end
end