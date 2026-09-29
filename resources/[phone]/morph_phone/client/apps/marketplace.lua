---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxy = require 'client.nui'

-- Thin delegates into server/marketplace: listing CRUD.
proxy('morph_phone:marketplace:list',   'morph_phone:server:marketplace:list')
proxy('morph_phone:marketplace:create', 'morph_phone:server:marketplace:create')
proxy('morph_phone:marketplace:update', 'morph_phone:server:marketplace:update')
proxy('morph_phone:marketplace:delete', 'morph_phone:server:marketplace:delete')
proxy('morph_phone:marketplace:reschedule', 'morph_phone:server:marketplace:reschedule')
proxy('morph_phone:marketplace:publishNow', 'morph_phone:server:marketplace:publishNow')
proxy('morph_phone:marketplace:watch',  'morph_phone:server:marketplace:watch')

---Server push (fan-out to every other open phone): another player posted / edited / removed a
---listing. Forwarded straight to the NUI.
---@param payload table feed patch from server/marketplace
RegisterNetEvent('morph_phone:client:marketplace:feed', function(payload)
    SendNUIMessage({ action = 'morph_phone:marketplace:feed', data = payload })
end)
