---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxy = require 'client.nui'

-- Thin delegates into server/documents: folder + document CRUD, moves, duplication, image
-- import and nearby sharing.
proxy('morph_phone:documents:list',         'morph_phone:server:documents:list')
proxy('morph_phone:documents:get',          'morph_phone:server:documents:get')
proxy('morph_phone:documents:createFolder', 'morph_phone:server:documents:createFolder')
proxy('morph_phone:documents:createDoc',    'morph_phone:server:documents:createDoc')
proxy('morph_phone:documents:save',         'morph_phone:server:documents:save')
proxy('morph_phone:documents:rename',       'morph_phone:server:documents:rename')
proxy('morph_phone:documents:renameFolder', 'morph_phone:server:documents:renameFolder')
proxy('morph_phone:documents:move',         'morph_phone:server:documents:move')
proxy('morph_phone:documents:delete',       'morph_phone:server:documents:delete')
proxy('morph_phone:documents:deleteFolder', 'morph_phone:server:documents:deleteFolder')
proxy('morph_phone:documents:duplicate',    'morph_phone:server:documents:duplicate')
proxy('morph_phone:documents:importImage',  'morph_phone:server:documents:importImage')
proxy('morph_phone:documents:signature:get', 'morph_phone:server:documents:signature:get')
proxy('morph_phone:documents:signature:set', 'morph_phone:server:documents:signature:set')
proxy('morph_phone:documents:sign',          'morph_phone:server:documents:sign')
proxy('morph_phone:documents:share',        'morph_phone:server:documents:share')
proxy('morph_phone:documents:signRequest:send',    'morph_phone:server:documents:requestSignature')
proxy('morph_phone:documents:signRequest:respond', 'morph_phone:server:documents:signRequest:respond')

---Server push: a document was created for us elsewhere (an export or another resource); relays
---it to the open app so the listing updates live.
---@param data table { doc } from server/documents
RegisterNetEvent('morph_phone:client:documents:added', function(data)
    SendNUIMessage({ action = 'morph_phone:documents:added', data = data })
end)

---Server push: an AirShared document was accepted into our library; relays the copy plus the
---sender's name.
---@param data table { doc, fromName } from server/documents
RegisterNetEvent('morph_phone:client:documents:receive', function(data)
    SendNUIMessage({ action = 'morph_phone:documents:receive', data = data })
end)

---Server push: an accepted signature request; relays the preview + sign prompt payload.
---@param data table { requestId, fromName, doc } from server/documents
RegisterNetEvent('morph_phone:client:documents:signRequest', function(data)
    SendNUIMessage({ action = 'morph_phone:documents:signRequest', data = data })
end)
