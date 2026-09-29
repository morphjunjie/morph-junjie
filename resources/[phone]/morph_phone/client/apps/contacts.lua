---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxyCallback = require 'client.nui'

-- Thin delegates into server/contacts: contact CRUD, favourites, sharing, the call log and
-- number blocking.
proxyCallback('morph_phone:contacts:list',         'morph_phone:server:contacts:list')
proxyCallback('morph_phone:contacts:add',          'morph_phone:server:contacts:add')
proxyCallback('morph_phone:contacts:update',       'morph_phone:server:contacts:update')
proxyCallback('morph_phone:contacts:delete',       'morph_phone:server:contacts:delete')
proxyCallback('morph_phone:contacts:favorite',     'morph_phone:server:contacts:favorite')
proxyCallback('morph_phone:contacts:share',        'morph_phone:server:contacts:share')
proxyCallback('morph_phone:contacts:logCall',      'morph_phone:server:contacts:logCall')
proxyCallback('morph_phone:contacts:deleteRecent', 'morph_phone:server:contacts:deleteRecent')
proxyCallback('morph_phone:contacts:clearRecents', 'morph_phone:server:contacts:clearRecents')
proxyCallback('morph_phone:contacts:block',        'morph_phone:server:contacts:block')
proxyCallback('morph_phone:contacts:unblock',      'morph_phone:server:contacts:unblock')
proxyCallback('morph_phone:contacts:blockedList',  'morph_phone:server:contacts:blockedList')
proxyCallback('morph_phone:contacts:isBlocked',    'morph_phone:server:contacts:isBlocked')
proxyCallback('morph_phone:contacts:saveCard',     'morph_phone:server:contacts:saveCard')

---Server push: a nearby player shared a contact card with us; relays it to the list.
---@param contact table serialized contact from server/contacts/actions.lua
RegisterNetEvent('morph_phone:client:contacts:shared', function(contact)
    SendNUIMessage({ action = 'morph_phone:contacts:shared', data = contact })
end)

---Server push: another resource removed our contacts matching a number; relays it to the list.
---@param data { phone: string } bare-digits number whose contacts were removed
RegisterNetEvent('morph_phone:client:contacts:removed', function(data)
    SendNUIMessage({ action = 'morph_phone:contacts:removed', data = data })
end)
