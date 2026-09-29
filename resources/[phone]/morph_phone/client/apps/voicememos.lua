---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxy = require 'client.nui'

-- Thin delegates into server/voicememos.
proxy('morph_phone:voice:list',   'morph_phone:server:voice:list')
proxy('morph_phone:voice:rename', 'morph_phone:server:voice:rename')
proxy('morph_phone:voice:delete', 'morph_phone:server:voice:delete')
proxy('morph_phone:voice:share',  'morph_phone:server:voice:share')

---Uploads the base64 recording via a fire-and-forget server event and returns immediately.
---The outcome arrives on the voice:added / voice:uploadFailed pushes below.
---@param payload table { audio: string, ... } base64 recording from the NUI
RegisterNUICallback('morph_phone:voice:upload', function(payload, cb)
    TriggerServerEvent('morph_phone:server:voice:upload', payload)
    cb('ok')
end)

---Server push: a memo was saved for us (our own upload finished, or a nearby player shared
---one). Relays it to the list.
---@param memo table memo record from server/voicememos
RegisterNetEvent('morph_phone:client:voice:added', function(memo)
    SendNUIMessage({ action = 'morph_phone:voice:added', data = memo })
end)

---Server push: our upload was rejected (bad payload, too long, or the upstream upload
---failed); relays the reason to the app.
---@param message string human-readable failure reason from server/voicememos/init.lua
RegisterNetEvent('morph_phone:client:voice:uploadFailed', function(message)
    SendNUIMessage({ action = 'morph_phone:voice:uploadFailed', data = { message = message } })
end)

-- Direct upload. The event path above hands the whole recording to the server in one ordinary
-- event, which blocks the net thread for everyone while it arrives; these two let the phone put
-- it on the CDN itself over HTTPS instead. The server mints the slot and checks what comes back,
-- and the event path stays as the fallback for whenever that cannot run.
proxy('morph_phone:voice:uploadSlot', 'morph_phone:server:voice:uploadSlot')
proxy('morph_phone:voice:uploadDone', 'morph_phone:server:voice:uploadDone')
