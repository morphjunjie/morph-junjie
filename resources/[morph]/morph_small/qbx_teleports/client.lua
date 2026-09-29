---@class Teleport
---@field coords vector3 | vector4
---@field drawText string
---@field allowVehicle boolean?
---@field ignoreGround boolean?
---@field requiredItem string?
---@field requiredItemLabel string?

---@type { teleports: Teleport[][] }
local config = lib.loadJson('qbx_teleports.config')
if #config.teleports == 0 then return end

local toRemove = {}
for i = 1, #config.teleports do
    local passage = config.teleports[i]
    if #passage > 1 then
        for level = 1, #passage do
            local data = passage[level]
            if #data.coords == 4 then data.coords = vec4(data.coords[1], data.coords[2], data.coords[3], data.coords[4])
            else data.coords = vec3(data.coords[1], data.coords[2], data.coords[3]) end
        end
    else toRemove[#toRemove + 1] = i end
end
if #toRemove ~= 0 then for i = 1, #toRemove do table.remove(config.teleports, toRemove[i]) end end

local currentLevel = {0, 0}
local function getLevelIcon(level, total) return level == 1 and 'fas fa-arrow-down' or level == total and 'fas fa-arrow-up' or 'fas fa-arrow-up-down' end

local function teleportToLevel(newLevel, teleports)
    local dest = teleports[newLevel]
    local z = dest.coords.z
    if not dest.ignoreGround then local safe, ground = GetGroundZFor_3dCoord(dest.coords.x, dest.coords.y, dest.coords.z, false); if safe then z = ground end end
    if dest.allowVehicle and cache.vehicle then SetPedCoordsKeepVehicle(cache.ped, dest.coords.x, dest.coords.y, z); SetVehicleOnGroundProperly(cache.vehicle)
    else SetEntityCoords(cache.ped, dest.coords.x, dest.coords.y, z, true, false, false, false) end
    if type(dest.coords) == 'vector4' then SetEntityHeading(cache.ped, dest.coords.w) end
    currentLevel[2] = newLevel
end

local function showElevatorMenu()
    if currentLevel[1] == 0 or currentLevel[2] == 0 then return end
    local teleports = config.teleports[currentLevel[1]]
    local cur = teleports[currentLevel[2]]
    local total = #teleports
    if cur.requiredItem and not lib.callback.await('qbx_teleports:server:hasItem', false, cur.requiredItem) then
        lib.notify({ title = 'Elevator', description = string.format('Need %s', cur.requiredItemLabel or 'Lab Key'), type = 'error' })
        return
    end
    local opts = {}
    for i = 1, total do
        local isCurrent = i == currentLevel[2]
        opts[#opts + 1] = { title = ('%s%s'):format(locale('info.teleport_level_select', i), isCurrent and (' %s'):format(locale('info.teleport_current_level_indication')) or ''), icon = isCurrent and 'fas fa-circle-dot' or getLevelIcon(i, total), onSelect = function() if not isCurrent then teleportToLevel(i, teleports) end end }
    end
    lib.registerContext({ id = 'elevator_interact_menu', title = cur.drawText, options = opts })
    lib.showContext('elevator_interact_menu')
end

CreateThread(function()
    for i = 1, #config.teleports do
        local passage = config.teleports[i]
        local total = #passage
        for level = 1, total do
            local entrance = passage[level]
            exports.morph_tget:addSphereZone({ coords = entrance.coords.xyz, radius = 2.0, options = { { name = 'elevator_' .. i .. '_' .. level, icon = getLevelIcon(level, total), label = entrance.drawText, distance = 2.0, onSelect = function()
                if entrance.requiredItem then
                    lib.callback('qbx_teleports:server:hasItem', false, function(has)
                        if not has then lib.notify({ title = 'Elevator', description = string.format('Need %s', entrance.requiredItemLabel or 'Lab Key'), type = 'error' }); return end
                        currentLevel = {i, level}; showElevatorMenu()
                    end, entrance.requiredItem)
                else currentLevel = {i, level}; showElevatorMenu() end
            end } } })
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() ~= res then return end
    for i = 1, #config.teleports do for level = 1, #config.teleports[i] do exports.morph_tget:removeZone('elevator_' .. i .. '_' .. level) end end
end)