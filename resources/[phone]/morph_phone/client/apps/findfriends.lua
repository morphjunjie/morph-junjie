---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxyCallback = require 'client.nui'

-- Thin delegates into server/friends: roster CRUD, share requests and the watch toggle.
proxyCallback('morph_phone:friends:list',    'morph_phone:server:friends:list')
proxyCallback('morph_phone:friends:add',     'morph_phone:server:friends:add')
proxyCallback('morph_phone:friends:remove',  'morph_phone:server:friends:remove')
proxyCallback('morph_phone:friends:share',   'morph_phone:server:friends:share')
proxyCallback('morph_phone:friends:respond', 'morph_phone:server:friends:respond')
proxyCallback('morph_phone:friends:status',  'morph_phone:server:friends:status')
proxyCallback('morph_phone:friends:watch',   'morph_phone:server:friends:watch')

---Server push: a fresh friends snapshot (positions + share state), streamed while watching.
---Forwarded under the maps action name.
---@param data table { friends = snapshot } from server/friends/init.lua
RegisterNetEvent('morph_phone:client:friends:update', function(data)
    SendNUIMessage({ action = 'morph_phone:maps:friends:update', data = data })
end)
