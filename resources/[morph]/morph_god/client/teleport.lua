local lastCoords

local function teleport(x, y, z)
    if cache.vehicle then
        return SetPedCoordsKeepVehicle(cache.ped, x, y, z)
    end

    SetEntityCoords(cache.ped, x, y, z, false, false, false, false)
end

-- Teleport to player
RegisterNetEvent('morph_god:client:TeleportToPlayer', function(coords)
    lastCoords = GetEntityCoords(cache.ped)
    SetPedCoordsKeepVehicle(cache.ped, coords.x, coords.y, coords.z)
end)

-- Teleport to coords
RegisterNetEvent('morph_god:client:TeleportToCoords', function(data, selectedData)
    local coordsStr = selectedData["Coords"].value
    local x, y, z, heading

    x, y, z, heading = coordsStr:match("(-?%d+%.?%d*),%s*(-?%d+%.?%d*),?%s*(-?%d*%.?%d*),?%s*(-?%d*%.?%d*)")

    if not x or not y then
        x, y, z, heading = coordsStr:match("(-?%d+%.?%d*)%s+(-?%d+%.?%d*)%s*(-?%d*%.?%d*)%s*(-?%d*%.?%d*)")
    end

    x = tonumber(x)
    y = tonumber(y)
    z = tonumber(z or 0)
    heading = tonumber(heading or 0)

    if x and y then
        lastCoords = GetEntityCoords(cache.ped)
        if heading and heading ~= 0 then
            SetEntityHeading(cache.ped, heading)
        end
        SetPedCoordsKeepVehicle(cache.ped, x, y, z)
    end
end)

-- Teleport to Locaton
RegisterNetEvent('morph_god:client:TeleportToLocation', function(data, selectedData)
    local coords = selectedData["Location"].value

    lastCoords = GetEntityCoords(cache.ped)
    SetPedCoordsKeepVehicle(cache.ped, coords.x, coords.y, coords.z)
end)

-- Teleport back
RegisterNetEvent('morph_god:client:TeleportBack', function(data)
    if lastCoords then
        local coords = GetEntityCoords(cache.ped)
        teleport(lastCoords.x, lastCoords.y, lastCoords.z)
        lastCoords = coords
    end
end)
