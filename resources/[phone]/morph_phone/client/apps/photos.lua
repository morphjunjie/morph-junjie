---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxyCallback = require 'client.nui'

-- Thin delegates into server/photos: photo listing, deletion, favourites, URL saves and album
-- CRUD.
proxyCallback('morph_phone:photos:list',        'morph_phone:server:photos:list')
proxyCallback('morph_phone:photos:delete',      'morph_phone:server:photos:delete')
proxyCallback('morph_phone:photos:setFavorite', 'morph_phone:server:photos:setFavorite')
proxyCallback('morph_phone:photos:saveUrl',     'morph_phone:server:photos:saveUrl')
proxyCallback('morph_phone:photos:share',       'morph_phone:server:photos:share')

proxyCallback('morph_phone:albums:list',        'morph_phone:server:albums:list')
proxyCallback('morph_phone:albums:create',      'morph_phone:server:albums:create')
proxyCallback('morph_phone:albums:delete',      'morph_phone:server:albums:delete')
proxyCallback('morph_phone:albums:addPhotos',   'morph_phone:server:albums:addPhotos')
proxyCallback('morph_phone:albums:removePhoto', 'morph_phone:server:albums:removePhoto')
proxyCallback('morph_phone:albums:photos',      'morph_phone:server:albums:photos')

---Server push: a photo finished saving (camera shutter or clip upload); relays it to the
---gallery and any app listening for a fresh capture.
---@param photo table photo record from server/photos/init.lua
RegisterNetEvent('morph_phone:client:photos:added', function(photo)
    SendNUIMessage({ action = 'morph_phone:photos:added', data = photo })
end)

---Server push: a capture upload will not arrive. Carries a stable reason code the Camera turns
---into a translated line, so the shutter overlay can say why instead of timing out in silence.
---@param payload { code: string } reason token from server/photos/init.lua
RegisterNetEvent('morph_phone:client:photos:uploadFailed', function(payload)
    SendNUIMessage({ action = 'morph_phone:photos:uploadFailed', data = payload })
end)
