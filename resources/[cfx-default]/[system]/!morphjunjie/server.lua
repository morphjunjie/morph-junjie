RegisterServerEvent('!morphjunjie:onPlayerDied')
RegisterServerEvent('!morphjunjie:onPlayerKilled')
RegisterServerEvent('!morphjunjie:onPlayerWasted')
RegisterServerEvent('!morphjunjie:enteringVehicle')
RegisterServerEvent('!morphjunjie:enteringAborted')
RegisterServerEvent('!morphjunjie:enteredVehicle')
RegisterServerEvent('!morphjunjie:leftVehicle')

AddEventHandler('!morphjunjie:onPlayerKilled', function(killedBy, data)
	local victim = source

	RconLog({msgType = 'playerKilled', victim = victim, attacker = killedBy, data = data})
end)

AddEventHandler('!morphjunjie:onPlayerDied', function(killedBy, pos)
	local victim = source

	RconLog({msgType = 'playerDied', victim = victim, attackerType = killedBy, pos = pos})
end)