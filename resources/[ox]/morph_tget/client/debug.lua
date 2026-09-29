AddEventHandler('morph_tget:debug', function(data)
    if data.entity and GetEntityType(data.entity) > 0 then
        data.archetype = GetEntityArchetypeName(data.entity)
        data.model = GetEntityModel(data.entity)
    end

	print(json.encode(data, {indent=true}))
end)

if GetConvarInt('morph_tget:debug', 0) ~= 1 then return end

local morph_tget = exports.morph_tget
local drawZones = true

morph_tget:addBoxZone({
    coords = vec3(442.5363, -1017.666, 28.85637),
    size = vec3(3, 3, 3),
    rotation = 45,
    debug = drawZones,
    drawSprite = true,
    options = {
        {
            name = 'debug_box',
            event = 'morph_tget:debug',
            icon = 'fa-solid fa-cube',
            label = locale('debug_box'),
        }
    }
})

morph_tget:addSphereZone({
    coords = vec3(440.5363, -1015.666, 28.85637),
    radius = 3,
    debug = drawZones,
    drawSprite = true,
    options = {
        {
            name = 'debug_sphere',
            event = 'morph_tget:debug',
            icon = 'fa-solid fa-circle',
            label = locale('debug_sphere'),
        }
    }
})

morph_tget:addModel(`police`, {
    {
        name = 'debug_model',
        event = 'morph_tget:debug',
        icon = 'fa-solid fa-handcuffs',
        label = locale('debug_police_car'),
    }
})

morph_tget:addGlobalPed({
    {
        name = 'debug_ped',
        event = 'morph_tget:debug',
        icon = 'fa-solid fa-male',
        label = locale('debug_ped'),
    }
})

morph_tget:addGlobalVehicle({
    {
        name = 'debug_vehicle',
        event = 'morph_tget:debug',
        icon = 'fa-solid fa-car',
        label = locale('debug_vehicle'),
    }
})

morph_tget:addGlobalObject({
    {
        name = 'debug_object',
        event = 'morph_tget:debug',
        icon = 'fa-solid fa-bong',
        label = locale('debug_object'),
    }
})

morph_tget:addGlobalOption({
    {
        name = 'debug_global',
        icon = 'fa-solid fa-globe',
        label = locale('debug_global'),
        openMenu = 'debug_global'
    }
})

morph_tget:addGlobalOption({
    {
        name = 'debug_global2',
        event = 'morph_tget:debug',
        icon = 'fa-solid fa-globe',
        label = locale('debug_global') .. ' 2',
        menuName = 'debug_global'
    }
})