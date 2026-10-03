---@type fun(nuiAction: string, serverEvent: string, onAccepted?: fun(), transform?: fun(res: table)) NUI->server pass-through registrar (client.nui).
local proxy = require 'client.nui'
---@type fun(res: table) Completes an HTTP upload slot with this client's server address (client.uploadurl).
local uploadUrl = require 'client.uploadurl'

-- Thin delegates into server/callrec.
proxy('morph_phone:callrec:list',    'morph_phone:server:callrec:list')
proxy('morph_phone:callrec:rename',  'morph_phone:server:callrec:rename')
proxy('morph_phone:callrec:delete',  'morph_phone:server:callrec:delete')
proxy('morph_phone:callrec:enabled', 'morph_phone:server:callrec:enabled')

---Uploads a finished call recording and returns immediately; the outcome arrives on the
---callrec:added / callrec:failed pushes below. The whole file goes in one event because a
---recording has no live viewer waiting on it, unlike the bodycam relay.
---@param payload table { audio: string, duration: number, oneSided: boolean, peerNumber: string, ... }
RegisterNUICallback('morph_phone:callrec:upload', function(payload, cb)
    TriggerServerEvent('morph_phone:server:callrec:upload', payload)
    cb('ok')
end)

---Server push: a recording finished uploading and was saved.
---@param rec table recording record from server/callrec
RegisterNetEvent('morph_phone:client:callrec:added', function(rec)
    SendNUIMessage({ action = 'morph_phone:callrec:added', data = rec })
end)

---Server push: an upload was rejected or the upstream host failed.
---@param message string human-readable failure reason from server/callrec/init.lua
RegisterNetEvent('morph_phone:client:callrec:failed', function(message)
    SendNUIMessage({ action = 'morph_phone:callrec:failed', data = { message = message } })
end)

-- Direct upload. Same reasoning as the voice memo pair: the event path above carries the whole
-- recording in one ordinary event, and at a 24 MB ceiling that is a long stall for every player
-- on the server. These put it on ordinary HTTPS instead, with the event path as the fallback.
proxy('morph_phone:callrec:uploadSlot', 'morph_phone:server:callrec:uploadSlot')
proxy('morph_phone:callrec:uploadDone', 'morph_phone:server:callrec:uploadDone')

-- HTTP upload: the recording goes to the server over its HTTP port instead of a game network event.
proxy('morph_phone:callrec:httpSlot', 'morph_phone:server:callrec:httpSlot', nil, uploadUrl)
