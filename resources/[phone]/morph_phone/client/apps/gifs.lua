---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxyCallback = require 'client.nui'

-- Thin delegates into server/gifs: read-only GIF-picker lookups.
proxyCallback('morph_phone:gifs:categories', 'morph_phone:server:gifs:categories')
proxyCallback('morph_phone:gifs:featured',   'morph_phone:server:gifs:featured')
proxyCallback('morph_phone:gifs:search',     'morph_phone:server:gifs:search')
