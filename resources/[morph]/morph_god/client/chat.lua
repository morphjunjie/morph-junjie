local function getMessagesCallBack()
	return lib.callback.await('morph_god:callback:GetMessages', false)
end

RegisterNUICallback("GetMessages", function(_, cb)
	local data = getMessagesCallBack()
	if next(data) then
		SendNUIMessage({
			action = "setMessages",
			data = data
		})
	end
	cb(1)
end)

RegisterNUICallback("SendMessage", function(msgData, cb)
	local message = msgData.message
	print(message, PlayerData.citizenid, PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname )

	TriggerServerEvent("morph_god:server:sendMessageServer", message, PlayerData.citizenid, PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname)

	local data = getMessagesCallBack()
	SendNUIMessage({
		action = "setMessages",
		data = data
	})
	cb(1)
end)