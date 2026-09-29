lib.versionCheck('Renewed-Scripts/morph_small')

RegisterNetEvent('morph_small:server:SyncState', function(vehNet)
    local veh = NetworkGetEntityFromNetworkId(vehNet)

    if veh == 0 or not DoesEntityExist(veh) then return end

    local state = Entity(veh).state

	if state.stateEnsured then  return end

	state:set('stateEnsured', true, true)
	state:set('sirenMode', 0, true)
	state:set('horn', false, true)
	state:set('lightsOn', false, true)
end)