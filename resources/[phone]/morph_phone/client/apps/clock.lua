---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxy = require 'client.nui'

-- Thin delegates into server/clock: alarm CRUD and the recent-timers list.
proxy('morph_phone:clock:alarms:list',   'morph_phone:server:clock:alarms:list')
proxy('morph_phone:clock:alarms:save',   'morph_phone:server:clock:alarms:save')
proxy('morph_phone:clock:alarms:delete', 'morph_phone:server:clock:alarms:delete')
proxy('morph_phone:clock:recents:list',  'morph_phone:server:clock:recents:list')
proxy('morph_phone:clock:recents:add',   'morph_phone:server:clock:recents:add')
