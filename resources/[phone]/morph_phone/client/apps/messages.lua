---@type fun(nuiAction: string, serverEvent: string, onAccepted?: fun(), transform?: fun(res: table)) NUI->server pass-through registrar (client.nui).
local proxyCallback = require 'client.nui'
---@type fun(res: table) Completes an HTTP upload slot with this client's server address (client.uploadurl).
local uploadUrl = require 'client.uploadurl'

-- Thin delegates into server/messages: thread listing, sending, group management, read
-- receipts, deletes and reactions.
proxyCallback('morph_phone:messages:list',        'morph_phone:server:messages:list')
proxyCallback('morph_phone:messages:thread',      'morph_phone:server:messages:thread')
proxyCallback('morph_phone:messages:send',        'morph_phone:server:messages:send')
proxyCallback('morph_phone:messages:uploadVoice', 'morph_phone:server:messages:uploadVoice')
proxyCallback('morph_phone:messages:voiceSlot', 'morph_phone:server:messages:voiceSlot')
proxyCallback('morph_phone:messages:voiceDone', 'morph_phone:server:messages:voiceDone')
proxyCallback('morph_phone:messages:httpSlot', 'morph_phone:server:messages:httpSlot', nil, uploadUrl)
proxyCallback('morph_phone:messages:createGroup', 'morph_phone:server:messages:createGroup')
proxyCallback('morph_phone:messages:addGroupMember', 'morph_phone:server:messages:addGroupMember')
proxyCallback('morph_phone:messages:updateGroup', 'morph_phone:server:messages:updateGroup')
proxyCallback('morph_phone:messages:removeGroupMember', 'morph_phone:server:messages:removeGroupMember')
proxyCallback('morph_phone:messages:markRead',    'morph_phone:server:messages:markRead')
proxyCallback('morph_phone:messages:typing',      'morph_phone:server:messages:typing')
proxyCallback('morph_phone:messages:delete',      'morph_phone:server:messages:delete')
proxyCallback('morph_phone:messages:react',       'morph_phone:server:messages:react')

---Server push: relays an updated conversation slice.
---@param conversation table conversation slice from server/messages
RegisterNetEvent('morph_phone:client:messages:incoming', function(conversation)
    SendNUIMessage({ action = 'morph_phone:messages:incoming', data = conversation })
end)

---Server push: relays an updated reaction set for our copy of a message.
---@param payload table reaction patch from server/messages
RegisterNetEvent('morph_phone:client:messages:reaction', function(payload)
    SendNUIMessage({ action = 'morph_phone:messages:reaction', data = payload })
end)

---Server push: relays a group-removal notice.
---@param payload table removal notice from server/messages
RegisterNetEvent('morph_phone:client:messages:removed', function(payload)
    SendNUIMessage({ action = 'morph_phone:messages:removed', data = payload })
end)

---Server push: relays a request-card meta patch.
---@param payload table meta patch from server/messages
RegisterNetEvent('morph_phone:client:messages:meta', function(payload)
    SendNUIMessage({ action = 'morph_phone:messages:meta', data = payload })
end)

---Server push: relays a peer's live typing indicator for one thread.
---@param payload table typing notice from server/messages
RegisterNetEvent('morph_phone:client:messages:typing', function(payload)
    SendNUIMessage({ action = 'morph_phone:messages:typing', data = payload })
end)

---Server push: relays the moment a peer read our side of a 1:1 thread.
---@param payload table read receipt from server/messages
RegisterNetEvent('morph_phone:client:messages:seen', function(payload)
    SendNUIMessage({ action = 'morph_phone:messages:seen', data = payload })
end)
