---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxy = require 'client.nui'

-- Thin delegates into server/darkchat: room lifecycle, membership, messaging, reactions and
-- nicknames.
proxy('morph_phone:darkchat:rooms',    'morph_phone:server:darkchat:rooms')
proxy('morph_phone:darkchat:open',     'morph_phone:server:darkchat:open')
proxy('morph_phone:darkchat:close',    'morph_phone:server:darkchat:close')
proxy('morph_phone:darkchat:send',     'morph_phone:server:darkchat:send')
proxy('morph_phone:darkchat:react',    'morph_phone:server:darkchat:react')
proxy('morph_phone:darkchat:create',   'morph_phone:server:darkchat:create')
proxy('morph_phone:darkchat:join',     'morph_phone:server:darkchat:join')
proxy('morph_phone:darkchat:leave',    'morph_phone:server:darkchat:leave')
proxy('morph_phone:darkchat:nickname', 'morph_phone:server:darkchat:nickname')
proxy('morph_phone:darkchat:exit',     'morph_phone:server:darkchat:exit')
proxy('morph_phone:darkchat:roomInfo', 'morph_phone:server:darkchat:roomInfo')
proxy('morph_phone:darkchat:notifications', 'morph_phone:server:darkchat:notifications')
proxy('morph_phone:darkchat:kick',     'morph_phone:server:darkchat:kick')
proxy('morph_phone:darkchat:ban',      'morph_phone:server:darkchat:ban')
proxy('morph_phone:darkchat:unban',    'morph_phone:server:darkchat:unban')
proxy('morph_phone:darkchat:regenCode', 'morph_phone:server:darkchat:regenCode')

---Server push: a message landed in a room we're a member of; relays it to an open room.
---@param data table message record from server/darkchat
RegisterNetEvent('morph_phone:client:darkchat:message', function(data)
    SendNUIMessage({ action = 'morph_phone:darkchat:message', data = data })
end)

---Server push: a room's active-member presence changed; relays the updated presence.
---@param data table presence patch from server/darkchat
RegisterNetEvent('morph_phone:client:darkchat:active', function(data)
    SendNUIMessage({ action = 'morph_phone:darkchat:active', data = data })
end)

---Server push: a reaction changed on a message in one of our rooms; relays the updated set.
---@param data table reaction patch from server/darkchat
RegisterNetEvent('morph_phone:client:darkchat:reaction', function(data)
    SendNUIMessage({ action = 'morph_phone:darkchat:reaction', data = data })
end)

---Server push: the room's creator removed us; relays it so the app drops the room live.
---@param data table { roomId } from server/darkchat
RegisterNetEvent('morph_phone:client:darkchat:kicked', function(data)
    SendNUIMessage({ action = 'morph_phone:darkchat:kicked', data = data })
end)

---Server push: a room we belong to got a fresh join code; relays it so the app shows the
---current one everywhere.
---@param data table { roomId, code } from server/darkchat
RegisterNetEvent('morph_phone:client:darkchat:code', function(data)
    SendNUIMessage({ action = 'morph_phone:darkchat:code', data = data })
end)

---Server push: a private room's member count changed (join/leave/kick/ban); relays the
---authoritative count so the list and chat header update live.
---@param data table { roomId, members } from server/darkchat
RegisterNetEvent('morph_phone:client:darkchat:members', function(data)
    SendNUIMessage({ action = 'morph_phone:darkchat:members', data = data })
end)
