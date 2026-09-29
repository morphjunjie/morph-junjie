local QBCore = exports.morph_junjie
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1521588876861374586/KKelM1vovxPAe8VIiVSLML1mqDuBvnl3lI8QPTGRe23vJu_3WFuDe-F5tB1xmQs9Acgi"

-- Sends a starter pack claim log to Discord (identifiers are for moderation purposes)
local function SendDetailedLog(src, vehicleLabel, plate)
    if DISCORD_WEBHOOK == "" then return end

    local Player = QBCore:GetPlayer(src)
    local pName = GetPlayerName(src)
    local identifiers = { ip = "N/A", discord = "N/A", steam = "N/A", license = "N/A", fivem = "N/A" }

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, "ip:") then identifiers.ip = id:gsub("ip:", "")
        elseif string.find(id, "discord:") then identifiers.discord = "<@" .. id:gsub("discord:", "") .. ">"
        elseif string.find(id, "steam:") then identifiers.steam = id
        elseif string.find(id, "license:") then identifiers.license = id
        elseif string.find(id, "fivem:") then identifiers.fivem = id:gsub("fivem:", "") end
    end

    local embed = { {
        ["title"] = "Starter Pack Claimed",
        ["color"] = 5763719,
        ["fields"] = {
            { ["name"] = "Player", ["value"] = string.format("Name: %s\nCID: %s\nCharacter: %s %s", pName, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname), ["inline"] = false },
            { ["name"] = "Vehicle", ["value"] = string.format("Model: %s\nPlate: %s", vehicleLabel, plate), ["inline"] = true },
            { ["name"] = "IP Address", ["value"] = string.format("||%s||", identifiers.ip), ["inline"] = true },
            { ["name"] = "Identifiers", ["value"] = string.format("Discord: %s\nSteam: %s\nLicense: %s\nFiveM: %s", identifiers.discord, identifiers.steam, identifiers.license, identifiers.fivem), ["inline"] = false }
        },
        ["footer"] = { ["text"] = "M.A.D. DISTRICT " .. os.date("%Y-%m-%d %H:%M:%S") },
        ["thumbnail"] = { ["url"] = "https://cdn.discordapp.com/attachments/1446433346790887496/1474040270378242048/Morph_empire.png" }
    } }

    PerformHttpRequest(DISCORD_WEBHOOK, function(err, text, headers) end, 'POST', json.encode({ username = "M.A.D. District", embeds = embed }), { ['Content-Type'] = 'application/json' })
end

RegisterNetEvent('morph_new:server:claimStarter', function(vehicleModel)
    local src = source
    local Player = QBCore:GetPlayer(src)
    if not Player then return end

    if Player.PlayerData.metadata.starterpack then
        TriggerClientEvent('morph_ui:notify', src, { title = 'Starter Pack', description = 'You have already claimed your starter pack!', type = 'error' })
        return
    end

    local vehicleData = nil
    for _, v in ipairs(NewConfig.StarterVehicles) do
        if v.model == vehicleModel then
            vehicleData = v
            break
        end
    end
    if not vehicleData then return end

    local plate = ("MAD %04d"):format(math.random(0, 9999))
    local success = exports.morph_vehicles:CreatePlayerVehicle({
        citizenid = Player.PlayerData.citizenid,
        model = vehicleModel,
        garage = NewConfig.DefaultGarage,
        props = {
            fuelLevel = 100.0,
            engineHealth = 1000.0,
            bodyHealth = 1000.0,
            plate = plate
        }
    })

    if success then
        Player.Functions.SetMetaData('starterpack', true)
        TriggerClientEvent('morph_ui:notify', src, { title = 'Success', description = string.format('%s claimed successfully. Plate: %s', vehicleData.label, plate), type = 'success' })
        SendDetailedLog(src, vehicleData.label, plate)
        TriggerClientEvent('morph_new:client:teleportGarage', src, NewConfig.DefaultGarage, vehicleData.label, plate)
    else
        TriggerClientEvent('morph_ui:notify', src, { title = 'Failed', description = 'Unable to claim vehicle. Contact staff.', type = 'error' })
    end
end)