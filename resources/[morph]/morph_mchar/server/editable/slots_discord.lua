local SlotsDiscordPerm = require 'server.list.slotslist'.DiscordPerm

if not SlotsDiscordPerm.status then return end

local defaultSlots = Config.DefaultSlots

local url = 'https://canary.discord.com/api/v10/guilds/%s/members/%s'

local discordConfig = {
    guild_id = '',
    bot_token = '', -- Don't share or show the token with anyone, even if it's us
}

-- @see error_codes_defined from here: https://github.com/JaredScar/Badger_Discord_API/blob/main/server.lua#L3
local error_codes_defined = {
    [200] = 'OK - The request was completed successfully..!',
    [204] = 'OK - No Content',
    [400] = "^1[Discord Request Error] - The request was improperly formatted, or the server couldn't understand it..!",
    [401] =
    '^1[Discord Request Error] - The Authorization header was missing or invalid..! Your Discord Token is probably wrong or does not have correct permissions attributed to it.',
    [403] =
    '^1[Discord Request Error] - The Authorization token you passed did not have permission to the resource..! Your Discord Token is probably wrong or does not have correct permissions attributed to it.',
    [404] = '^1[Discord Request Error] - The resource at the location specified doesn\'t exist.',
    [429] =
    '^1[Discord Request Error] - Too many requests, you hit the Discord rate limit. https://discord.com/developers/docs/topics/rate-limits',
    [502] = '^1[Discord Request Error] - Discord API may be down?...'
}

local function getDiscordID(src)
    local discordID = GetPlayerIdentifierByType(src, 'discord') or 'undefined'
    if discordID:find('discord' .. ':') then
        discordID = discordID:gsub('discord' .. ':', '')
    end
    return discordID
end

local function HttpRequestAwait(url, method, data, headers, options)
    local p = promise.new()
    PerformHttpRequest(url, function(...)
        p:resolve({ ... })
    end, method, data, headers, options)

    Citizen.Await(p)
    return table.unpack(p.value)
end

function ReqDiscord(src)
    local discord = getDiscordID(src)

    if discord == 'undefined' then
        warn('^1Discord ID not found')
        return defaultSlots
    end

    local status, data = HttpRequestAwait((url):format(discordConfig.guild_id, discord), 'GET', '', {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = ('Bot %s'):format(discordConfig.bot_token)
    })

    if status ~= 200 then
        print(error_codes_defined[status] or "^1Unknown HTTP error occurred")
        return defaultSlots
    end

    if data then
        local responseData = json.decode(data)
        local roles = responseData.roles or {}
        for i = 1, #roles do
            local role = roles[i]
            for j = 1, #SlotsDiscordPerm.role do
                local slotRole = SlotsDiscordPerm.role[j]
                if tostring(role) == tostring(slotRole.id) then
                    return defaultSlots + slotRole.addExtraSlot
                end
            end
        end
    end

    return defaultSlots
end
