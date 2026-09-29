local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1546444787060707360/3sOIrtC2q1dysIhKungeWuJAhpHAwaVOiQAYVTgkPjC20i-dANjegNl6qAGuFCozsoBI"
local ROLE_ID = "1515932804947644482"

local AVATAR_BOT = "https://cdn.discordapp.com/attachments/1446426469554323619/1543298112813015170/Matching_Icons_.jpg?ex=6a9af35f&is=6a99a1df&hm=d71c8dc57f09e075ac75295557b11fa41d1aa152266ff63a94686baa2b37d1ee&"

local ENABLE_MAINTENANCE = true   -- true = aktif, false = mati
local ENABLE_SERVER_UP = false    -- true = aktif, false = mati

local hasNotified = false   -- flag buat announcement + discord log (30 menit)
local hasKicked = false     -- flag buat auto kick (2 menit)

local function SendToDiscord(message)
    PerformHttpRequest(DISCORD_WEBHOOK, function() end, 'POST',
        json.encode({
            username = "M.A.D. DISTRICT",
            avatar_url = AVATAR_BOT,
            content = message
        }),
        { ['Content-Type'] = 'application/json' }
    )
end

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if not ENABLE_MAINTENANCE then return end

    local secondsRemaining = eventData.secondsRemaining
    local minutesRemaining = math.floor(secondsRemaining / 60)

    -- === DISCORD LOG (30 menit) ===
    if minutesRemaining <= 30 and not hasNotified then
        hasNotified = true

        -- discord log
        local restartTimestamp = os.time() + secondsRemaining
        local msg = string.format(
            "**SERVER MAINTENANCE**\n" ..
            "Scheduled maintenance begins **<t:%s:R>**.\n\n" ..
            "**MAINTENANCE DETAILS:**\n" ..
            "> System optimization and stability improvements\n" ..
            "> All services will be temporarily paused\n" ..
            "> Estimated downtime: 30-70 minutes\n\n" ..
            "**PLAYER GUIDANCE:**\n" ..
            "> Park your vehicles safely to avoid loss\n" ..
            "> Log out to save your progress\n\n" ..
            "**IMPORTANT NOTICE:**\n" ..
            "> Real Money Trading (RMT) is strictly forbidden at all times, including during maintenance and downtime.\n" ..
            "> This includes buying, selling, or trading in-game currency, items, accounts, or services for real-world money outside official, approved channels.\n" ..
            "> Any player found engaging in RMT will face a permanent ban without warning.\n" ..
            "> The server and its management bear no responsibility for any loss, scam, or dispute resulting from RMT. You engage in it entirely at your own risk.\n\n" ..
            "We appreciate your patience and understanding during this time.\n\n" ..
            "<@&%s>",
            restartTimestamp, ROLE_ID
        )
        SendToDiscord(msg)

        print("^2[Morph] Maintenance notification sent!^7")
    end

    -- === AUTO KICK 2 MENIT SEBELUM RESTART (TIDAK di-log ke Discord) ===
    if minutesRemaining <= 2 and not hasKicked then
        hasKicked = true

        local kickReason = "You have been automatically disconnected.\n" ..
            "This kick prevents data loss or rollback caused by the upcoming scheduled server restart.\n" ..
            "The server will be back online shortly, please rejoin after the restart completes."

        for _, playerId in ipairs(GetPlayers()) do
            DropPlayer(playerId, kickReason)
        end

        print("^2[Morph] All players auto-kicked before restart (2 minutes remaining)!^7")
    end

    if minutesRemaining <= 0 then
        hasNotified = false
        hasKicked = false
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if not ENABLE_SERVER_UP then return end

    if GetCurrentResourceName() == resourceName then
        Wait(15000)

        local msg = string.format(
            "**SERVER ONLINE**\n" ..
            "Maintenance complete. All systems are now operational.\n\n" ..
            "**SYSTEM STATUS:**\n" ..
            "> All services restored and verified\n" ..
            "> Performance optimization successful\n" ..
            "> Connection gateway: <#1521307355059322910>\n\n" ..
            "**GETTING STARTED:**\n" ..
            "> Check <#1535399933396394034> for updates\n" ..
            "> Check <#1535400340118179961> for latest sub announcements\n" ..
            "> Report issues in <#1515932806944129185>\n\n" ..
            "**IMPORTANT NOTICE:**\n" ..
            "> Real Money Trading (RMT) is strictly forbidden on this server.\n" ..
            "> This includes buying, selling, or trading in-game currency, items, accounts, or services for real-world money outside official, approved channels.\n" ..
            "> Any player found engaging in RMT will face a permanent ban without warning.\n" ..
            "> The server and its management bear no responsibility for any loss, scam, or dispute resulting from RMT. You engage in it entirely at your own risk.\n\n" ..
            "The city is ready for your adventures. Welcome back, citizens.\n\n" ..
            "<@&%s>",
            ROLE_ID
        )

        SendToDiscord(msg)
        print("^2[Morph] Server Up notification sent!^7")
    end
end)

print("^2[Morph] Server Notifier Ready!^7")
print("^2[Morph] Maintenance: " .. (ENABLE_MAINTENANCE and "✅ ON" or "❌ OFF"))
print("^2[Morph] Server Up: " .. (ENABLE_SERVER_UP and "✅ ON" or "❌ OFF"))