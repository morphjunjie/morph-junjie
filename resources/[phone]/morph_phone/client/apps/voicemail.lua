---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxyCallback = require 'client.nui'

-- Thin delegates into server/voicemail. `upload` blocks for as long as the CDN takes, which is
-- why the recorder shows its own progress state until the envelope comes back.
proxyCallback('morph_phone:voicemail:list',    'morph_phone:server:voicemail:list')
proxyCallback('morph_phone:voicemail:seen',    'morph_phone:server:voicemail:seen')
proxyCallback('morph_phone:voicemail:delete',  'morph_phone:server:voicemail:delete')
proxyCallback('morph_phone:voicemail:leave',   'morph_phone:server:voicemail:leave')
proxyCallback('morph_phone:voicemail:upload',  'morph_phone:server:voicemail:upload')
proxyCallback('morph_phone:voicemail:enabled', 'morph_phone:server:voicemail:enabled')

---Server push: someone left us a voicemail. Relays the row so the Voicemail tab can show it
---without a refetch.
---@param vm table voicemail record from server/voicemail
RegisterNetEvent('morph_phone:client:voicemail:new', function(vm)
    SendNUIMessage({ action = 'morph_phone:voicemail:new', data = vm })
end)

-- Direct upload. The base64 route above carries the whole recording in one ordinary callback,
-- which is an un-paced event underneath and stalls the net thread for everyone while it arrives.
-- These put it on HTTPS instead, with that route kept as the fallback.
proxyCallback('morph_phone:voicemail:uploadSlot', 'morph_phone:server:voicemail:uploadSlot')
proxyCallback('morph_phone:voicemail:uploadDone', 'morph_phone:server:voicemail:uploadDone')
