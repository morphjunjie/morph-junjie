---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxyCallback = require 'client.nui'

-- Thin delegates into server/cherry: profile CRUD, deck swipes, match threads, reactions and
-- blocking.
proxyCallback('morph_phone:cherry:state',         'morph_phone:server:cherry:state')
proxyCallback('morph_phone:cherry:saveProfile',   'morph_phone:server:cherry:saveProfile')
proxyCallback('morph_phone:cherry:swipe',         'morph_phone:server:cherry:swipe')
proxyCallback('morph_phone:cherry:rewind',        'morph_phone:server:cherry:rewind')
proxyCallback('morph_phone:cherry:resetDeck',     'morph_phone:server:cherry:resetDeck')
proxyCallback('morph_phone:cherry:thread',        'morph_phone:server:cherry:thread')
proxyCallback('morph_phone:cherry:send',          'morph_phone:server:cherry:send')
proxyCallback('morph_phone:cherry:react',         'morph_phone:server:cherry:react')
proxyCallback('morph_phone:cherry:unmatch',       'morph_phone:server:cherry:unmatch')
proxyCallback('morph_phone:cherry:block',         'morph_phone:server:cherry:block')
proxyCallback('morph_phone:cherry:blockedList',   'morph_phone:server:cherry:blockedList')
proxyCallback('morph_phone:cherry:unblock',       'morph_phone:server:cherry:unblock')
proxyCallback('morph_phone:cherry:watch',         'morph_phone:server:cherry:watch')
proxyCallback('morph_phone:cherry:deleteAccount', 'morph_phone:server:cherry:deleteAccount')

---Server push: relays a message that arrived in one of our match threads.
---@param payload table { matchId, message } from server/cherry/actions.lua
RegisterNetEvent('morph_phone:client:cherry:message', function(payload)
    SendNUIMessage({ action = 'morph_phone:cherry:message', data = payload })
end)

---Server push: relays a fresh match card.
---@param payload table serialized match record from server/cherry/actions.lua
RegisterNetEvent('morph_phone:client:cherry:match', function(payload)
    SendNUIMessage({ action = 'morph_phone:cherry:match', data = payload })
end)

---Server push: relays an updated thread-message reaction set.
---@param payload table reaction patch from server/cherry/actions.lua
RegisterNetEvent('morph_phone:client:cherry:reaction', function(payload)
    SendNUIMessage({ action = 'morph_phone:cherry:reaction', data = payload })
end)

---Server push: relays a matched partner's fresh profile card.
---@param payload table { username, partner } from server/cherry/actions.lua
RegisterNetEvent('morph_phone:client:cherry:partner', function(payload)
    SendNUIMessage({ action = 'morph_phone:cherry:partner', data = payload })
end)

---Server push: relays an unmatch/block notice.
---@param payload table { matchId } from server/cherry/actions.lua
RegisterNetEvent('morph_phone:client:cherry:unmatch', function(payload)
    SendNUIMessage({ action = 'morph_phone:cherry:unmatch', data = payload })
end)
