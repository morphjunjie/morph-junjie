---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxy = require 'client.nui'

-- Thin delegates into server/pages: listing CRUD.
proxy('morph_phone:pages:list',   'morph_phone:server:pages:list')
proxy('morph_phone:pages:create', 'morph_phone:server:pages:create')
proxy('morph_phone:pages:update', 'morph_phone:server:pages:update')
proxy('morph_phone:pages:delete', 'morph_phone:server:pages:delete')
proxy('morph_phone:pages:reschedule', 'morph_phone:server:pages:reschedule')
proxy('morph_phone:pages:publishNow', 'morph_phone:server:pages:publishNow')
proxy('morph_phone:pages:watch',  'morph_phone:server:pages:watch')

---Server push (fan-out to the other phones with Pages open): another player posted / edited /
---removed a listing. Forwarded straight to the NUI.
---@param payload table feed patch from server/pages
RegisterNetEvent('morph_phone:client:pages:feed', function(payload)
    SendNUIMessage({ action = 'morph_phone:pages:feed', data = payload })
end)
