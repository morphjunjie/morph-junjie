---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxyCallback = require 'client.nui'

-- Thin delegates into server/apps: the installable-app catalogue, install/uninstall state and
-- the home-screen layout.
proxyCallback('morph_phone:apps:list',       'morph_phone:server:apps:list')
proxyCallback('morph_phone:apps:install',    'morph_phone:server:apps:install')
proxyCallback('morph_phone:apps:uninstall',  'morph_phone:server:apps:uninstall')
proxyCallback('morph_phone:apps:saveLayout', 'morph_phone:server:apps:saveLayout')
