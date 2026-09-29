lib.callback.register('morph_spawn:server:getLastLocation', function(source)
    local player = exports.morph_junjie:GetPlayer(source)

    -- UNIX_TIMESTAMP() converts the players table's last_updated column
    -- straight into a unix timestamp so we can diff it against os.time().
    -- Rename the column here if your schema uses a different name.
    local queryResult = MySQL.single.await(
        'SELECT position, UNIX_TIMESTAMP(last_updated) AS last_updated FROM players WHERE citizenid = ?',
        { player.PlayerData.citizenid }
    )

    if not queryResult or not queryResult.position or not queryResult.last_updated then
        return nil, nil
    end

    local minutesSinceUpdate = (os.time() - queryResult.last_updated) / 60

    -- Last location expires after 60 minutes, player falls back to the
    -- normal spawn list (config spawns + properties) once this happens.
    if minutesSinceUpdate > 60 then
        return nil, nil
    end

    local position = json.decode(queryResult.position)
    local currentPropertyId = player.PlayerData.metadata.currentPropertyId

    return position, currentPropertyId
end)

lib.callback.register('morph_spawn:server:getProperties', function(source)
    if not GetResourceState('morph_properties'):find('start') then
        return {}
    end

    local player = exports.morph_junjie:GetPlayer(source)
    local houseData = {}
    local properties = MySQL.query.await('SELECT id, property_name, coords FROM properties WHERE owner = ?', { player.PlayerData.citizenid })

    for i = 1, #properties do
        local property = properties[i]

        houseData[#houseData + 1] = {
            label = property.property_name,
            coords = json.decode(property.coords),
            propertyId = property.id,
        }
    end

    return houseData
end)