---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxy = require 'client.nui'

-- Thin delegates into server/cookie: cookie-clicker save/load, the leaderboard and the
-- leaderboard nickname.
proxy('morph_phone:cookie:load',        'morph_phone:server:cookie:load')
proxy('morph_phone:cookie:save',        'morph_phone:server:cookie:save')
proxy('morph_phone:cookie:leaderboard', 'morph_phone:server:cookie:leaderboard')
proxy('morph_phone:cookie:nickname',    'morph_phone:server:cookie:nickname')
