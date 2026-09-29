---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxy = require 'client.nui'

-- Thin delegates into server/notes: note CRUD and nearby sharing.
proxy('morph_phone:notes:list',   'morph_phone:server:notes:list')
proxy('morph_phone:notes:save',   'morph_phone:server:notes:save')
proxy('morph_phone:notes:delete', 'morph_phone:server:notes:delete')
proxy('morph_phone:notes:share',  'morph_phone:server:notes:share')

---Server push: a note shared to us was accepted server-side; relays it to the open app.
---@param note table note record from server/notes/actions.lua
RegisterNetEvent('morph_phone:client:notes:added', function(note)
    SendNUIMessage({ action = 'morph_phone:notes:added', data = note })
end)
