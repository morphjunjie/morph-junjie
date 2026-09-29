local Core = nil
local frameworkName = nil

local function detect()
    local forced = Config.Framework
    local function started(res) return GetResourceState(res) == 'started' end
    if forced == 'standalone' then frameworkName = 'standalone' return end
    if (forced == 'auto' or forced == 'esx') and started('es_extended') then
        local ok, core = pcall(function() return exports['es_extended']:getSharedObject() end)
        if ok and core then frameworkName = 'esx' Core = core return end
    end
    if (forced == 'auto' or forced == 'qbox') and started('morph_junjie') then
        frameworkName = 'qbox' return
    end
    if (forced == 'auto' or forced == 'qb') and started('qb-core') then
        local ok, core = pcall(function() return exports['qb-core']:GetCoreObject() end)
        if ok and core then frameworkName = 'qb' Core = core return end
    end
    frameworkName = frameworkName or 'standalone'
end

CreateThread(function()
    Wait(500)
    detect()
    local tries = 0
    while frameworkName == 'standalone' and Config.Framework == 'auto' and tries < 40 do
        Wait(250)
        detect()
        tries = tries + 1
    end
end)

local function getJob(src)
    if frameworkName == 'esx' and Core then
        local ok, xp = pcall(function() return Core.GetPlayerFromId(src) end)
        if ok and xp and xp.getJob then return xp.getJob().name end
    elseif frameworkName == 'qb' and Core then
        local ok, p = pcall(function() return Core.Functions.GetPlayer(src) end)
        if ok and p and p.PlayerData and p.PlayerData.job then return p.PlayerData.job.name end
    elseif frameworkName == 'qbox' then
        local ok, p = pcall(function() return exports.morph_junjie:GetPlayer(src) end)
        if ok and p and p.PlayerData and p.PlayerData.job then return p.PlayerData.job.name end
    end
    return nil
end

local function esc(s)
    if type(s) ~= 'string' then s = tostring(s) end
    s = s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('"', '&quot;'):gsub("'", '&#39;')
    return s
end

local function T(key)
    local d = Locales[Config.Locale] or Locales['en'] or {}
    return d[key] or (Locales['en'] and Locales['en'][key]) or key
end

local function stamp()
    return os.date('%H:%M')
end

local function identity(src)
    local name = GetPlayerName(src) or 'Player'
    local job = getJob(src)
    local aceTag, jobTag
    for key, t in pairs(Config.Tags) do
        if t.ace and IsPlayerAceAllowed(src, t.ace) then
            aceTag = { label = t.label, color = t.color }
        elseif job and job == key then
            jobTag = { label = t.label, color = t.color }
        end
    end
    local tag = aceTag or jobTag
    return name, tag, (tag and tag.color) or Config.DefaultNameColor
end

local function nearby(src, range)
    local ped = GetPlayerPed(src)
    if ped == 0 then return { src } end
    local origin = GetEntityCoords(ped)
    local list = {}
    for _, p in ipairs(GetPlayers()) do
        p = tonumber(p)
        local pp = GetPlayerPed(p)
        if pp ~= 0 and #(GetEntityCoords(pp) - origin) <= range then
            list[#list + 1] = p
        end
    end
    return list
end

local function staffPlayers()
    local list = {}
    for _, p in ipairs(GetPlayers()) do
        p = tonumber(p)
        if IsPlayerAceAllowed(p, 'morph_chat.staff') or IsPlayerAceAllowed(p, 'morph_chat.admin') or IsPlayerAceAllowed(p, 'morph_chat.mod') then
            list[#list + 1] = p
        end
    end
    return list
end

local function sendTo(targets, msg)
    if targets == -1 then
        TriggerClientEvent('chat:addMessage', -1, msg)
    else
        for _, t in ipairs(targets) do
            TriggerClientEvent('chat:addMessage', t, msg)
        end
    end
end

local function sysTo(target, text)
    TriggerClientEvent('chat:addMessage', target, { jrmy = true, mtype = 'system', ts = stamp(), body = text })
end

local lastMsg = {}
local function spamOk(src)
    if not Config.AntiSpam.enabled then return true end
    if IsPlayerAceAllowed(src, 'morph_chat.staff') then return true end
    local now = GetGameTimer()
    if lastMsg[src] and now - lastMsg[src] < Config.AntiSpam.cooldown then return false end
    lastMsg[src] = now
    return true
end

AddEventHandler('playerDropped', function()
    lastMsg[source] = nil
end)

RegisterNetEvent('_chat:messageEntered', function(author, color, message)
    local src = source
    if type(message) ~= 'string' or message == '' then return end
    if not spamOk(src) then sysTo(src, T('too_fast')) return end
    local name, tag, nameColor = identity(src)
    sendTo(-1, { jrmy = true, mtype = 'normal', ts = stamp(), tag = tag, name = name, nameColor = nameColor, body = esc(message) })
end)

local function headBubble(src, mtype, text)
    if not Config.HeadText.enabled then return end
    local payload = { sid = src, mtype = mtype, text = esc(text), duration = Config.HeadText.duration, height = Config.HeadText.height }
    if Config.HeadText.range > 0 then
        for _, t in ipairs(nearby(src, Config.HeadText.range)) do
            TriggerClientEvent('morph_chat:head', t, payload)
        end
    else
        TriggerClientEvent('morph_chat:head', -1, payload)
    end
end

local function proximityTargets(mtype)
    local cfg = Config.Types[mtype]
    return (cfg and cfg.proximity and cfg.proximity > 0)
end

local function rp(src, mtype, text)
    if type(text) ~= 'string' or text == '' then return end
    if not spamOk(src) then sysTo(src, T('too_fast')) return end
    local name, tag, nameColor = identity(src)
    local msg = { jrmy = true, mtype = mtype, ts = stamp(), name = name, tag = tag, nameColor = nameColor, body = esc(text) }
    local targets = proximityTargets(mtype) and nearby(src, Config.Types[mtype].proximity) or -1
    sendTo(targets, msg)
    return name
end

RegisterCommand('me', function(src, args)
    if src == 0 then return end
    local text = table.concat(args, ' ')
    if text == '' then
        sysTo(src, 'Usage: /me [action]')
        return
    end
    if not spamOk(src) then sysTo(src, T('too_fast')) return end
    local msg = { jrmy = true, mtype = 'me', ts = stamp(), name = 'Anon', body = esc(text) }
    local targets = proximityTargets('me') and nearby(src, Config.Types['me'].proximity) or -1
    sendTo(targets, msg)
    headBubble(src, 'me', text, 'Anon')
end, false)

RegisterCommand('do', function(src, args)
    if src == 0 then return end
    local text = table.concat(args, ' ')
    if text == '' then
        sysTo(src, 'Usage: /do [action]')
        return
    end
    if not spamOk(src) then sysTo(src, T('too_fast')) return end
    local msg = { jrmy = true, mtype = 'do', ts = stamp(), name = 'Anon', body = esc(text) }
    local targets = proximityTargets('do') and nearby(src, Config.Types['do'].proximity) or -1
    sendTo(targets, msg)
    headBubble(src, 'do', text, 'Anon')
end, false)

RegisterCommand('ooc', function(src, args)
    if src == 0 then return end
    rp(src, 'ooc', table.concat(args, ' '))
end, false)

RegisterCommand('ad', function(src, args)
    if src == 0 then return end
    rp(src, 'ad', table.concat(args, ' '))
end, false)

RegisterCommand('report', function(src, args)
    if src == 0 then return end
    local text = table.concat(args, ' ')
    if text == '' then return end
    if not spamOk(src) then sysTo(src, T('too_fast')) return end
    local name = identity(src)
    local msg = { jrmy = true, mtype = 'report', ts = stamp(), name = name, body = esc(text) }
    local staff = staffPlayers()
    if #staff == 0 then sysTo(src, T('no_staff')) return end
    for _, t in ipairs(staff) do TriggerClientEvent('chat:addMessage', t, msg) end
    sysTo(src, T('report_sent'))
end, false)

RegisterCommand('dm', function(src, args)
    if src == 0 then return end
    local target = tonumber(args[1])
    table.remove(args, 1)
    local text = table.concat(args, ' ')
    if not target or text == '' then sysTo(src, T('dm_usage')) return end
    if not spamOk(src) then sysTo(src, T('too_fast')) return end
    if GetPlayerName(target) == nil then sysTo(src, T('no_player')) return end
    local name = identity(src)
    local tname = GetPlayerName(target)
    TriggerClientEvent('chat:addMessage', target, { jrmy = true, mtype = 'dm', ts = stamp(), name = name, body = esc(text), dmDir = 'from' })
    TriggerClientEvent('chat:addMessage', src, { jrmy = true, mtype = 'dm', ts = stamp(), name = tname, body = esc(text), dmDir = 'to' })
end, false)

local function rpSuggestions()
    return {
        { name = '/me', help = T('sug_me') },
        { name = '/do', help = T('sug_do') },
        { name = '/ooc', help = T('sug_ooc') },
        { name = '/ad', help = T('sug_ad') },
        { name = '/report', help = T('sug_report') },
        { name = '/dm', help = T('sug_dm') },
    }
end

RegisterNetEvent('chat:init', function()
    local src = source
    local sugg = {}
    for _, cmd in ipairs(GetRegisteredCommands()) do
        local nm = cmd.name
        if nm and IsPlayerAceAllowed(src, 'command.' .. nm) then
            sugg[#sugg + 1] = { name = '/' .. nm, help = '' }
        end
    end
    TriggerClientEvent('chat:addSuggestions', src, sugg)
    TriggerClientEvent('chat:addSuggestions', src, rpSuggestions())
end)

AddEventHandler('chatMessage', function(src, author, text)
    if type(text) ~= 'string' then return end
    sendTo(-1, { jrmy = true, mtype = 'normal', ts = stamp(), name = author or 'Server', nameColor = Config.DefaultNameColor, body = esc(text) })
end)

exports('addMessage', function(target, msg)
    TriggerClientEvent('chat:addMessage', target or -1, msg)
end)
exports('registerMessageHook', function() end)
exports('registerMode', function() end)