if not lib.checkDependency('morph_junjie', '1.18.0', true) then return end

local QBX = exports.morph_junjie
local utils = require 'client.utils'

---@diagnostic disable-next-line: duplicate-set-field
function utils.hasPlayerGotGroup(filter)
    return QBX:HasGroup(filter)
end
