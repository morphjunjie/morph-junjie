---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxy = require 'client.nui'
---@type table Job bridge (bridge.client.job): live job name/grade off the framework's own events.
local job = require 'bridge.client.job'

-- Thin delegates into server/weazelnews: the public feed plus the boss-gated newsroom
-- (article CRUD, the breaking ticker).
proxy('morph_phone:weazelnews:feed',        'morph_phone:server:weazelnews:feed')
proxy('morph_phone:weazelnews:watch',       'morph_phone:server:weazelnews:watch')
proxy('morph_phone:weazelnews:view',        'morph_phone:server:weazelnews:view')
proxy('morph_phone:weazelnews:save',        'morph_phone:server:weazelnews:save')
proxy('morph_phone:weazelnews:delete',      'morph_phone:server:weazelnews:delete')
proxy('morph_phone:weazelnews:reschedule',  'morph_phone:server:weazelnews:reschedule')
proxy('morph_phone:weazelnews:publishNow',  'morph_phone:server:weazelnews:publishNow')
proxy('morph_phone:weazelnews:setBreaking', 'morph_phone:server:weazelnews:setBreaking')

-- The newsroom gate rides on the feed, which the app reads once when it mounts, and the switcher
-- keeps that instance alive across a close. Server pushes only ever follow a content change, so a
-- player hired onto (or fired from) a news job would hold the old gate until the app was killed
-- from the switcher. Every job change replays the push the app already refetches on.
job.onChange(function()
    SendNUIMessage({ action = 'morph_phone:weazelnews:feed', data = { type = 'job' } })
end)
