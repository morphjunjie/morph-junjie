Animation = {}

Animation.List = {
    "uwu",
    "smoke2",
    "foldarms2",
    "bookc",
    "dancedrink2",
    "sipshaked"
}

Animation.ScenarioList = {
    "WORLD_HUMAN_SMOKING",
    "WORLD_HUMAN_SMOKING_POT",
}

Animation.Export = function(emoteName)
    Wait(1000)
    if GetResourceState('morph_emote') == 'started' then
        pcall(function() exports["morph_emote"]:EmoteCommandStart(emoteName) end)
        return
    elseif GetResourceState('morph_emote') == 'started' then
        pcall(function() exports["morph_emote"]:EmoteCommandStart(emoteName) end)
    elseif GetResourceState('morph_emote') == 'started' then
        pcall(function() exports.morph_emote:playEmoteByCommand(emoteName) end)
    else
        ExecuteCommand(('e %s'):format(emoteName))
    end
end

Animation.Stop = function()
    if GetResourceState('morph_emote') == 'started' then
        pcall(function() exports["morph_emote"]:EmoteCancel(true) end)
        return
    elseif GetResourceState('morph_emote') == 'started' then
        pcall(function() exports["morph_emote"]:EmoteCancel(true) end)
    elseif GetResourceState('morph_emote') == 'started' then
        pcall(function() exports.morph_emote:cancelEmote() end)
    else
        ClearPedTasks(cache.ped)
    end
end
