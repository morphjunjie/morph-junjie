local chatOpen = false
local bubbles = {}

local function send(action, data)
    SendNUIMessage({ action = action, data = data })
end

local function openChat()
    if chatOpen then return end
    chatOpen = true
    SetNuiFocus(true, true)
    send('open', {})
end

RegisterCommand('morph_chat_open', function() openChat() end, false)
RegisterKeyMapping('morph_chat_open', 'Open chat', 'keyboard', Config.OpenKey)

RegisterNUICallback('chatResult', function(data, cb)
    chatOpen = false
    SetNuiFocus(false, false)
    local message = data and data.message
    if type(message) == 'string' and message ~= '' then
        if message:sub(1, 1) == '/' then
            ExecuteCommand(message:sub(2))
        else
            TriggerServerEvent('_chat:messageEntered', GetPlayerName(PlayerId()), { 255, 255, 255 }, message)
        end
    end
    cb('ok')
end)

RegisterNUICallback('chatClose', function(_, cb)
    chatOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('nuiReady', function(_, cb)
    local d = Locales[Config.Locale] or Locales['en'] or {}
    send('init', {
        position = Config.Position,
        timestamps = Config.Timestamps,
        sounds = Config.Sounds,
        emojis = Config.Emojis,
        fadeDelay = Config.FadeDelay,
        maxMessages = Config.MaxMessages,
        me = GetPlayerName(PlayerId()),
        locale = d,
    })
    TriggerServerEvent('chat:init')
    cb('ok')
end)

RegisterNetEvent('chat:addMessage', function(msg)
    if type(msg) == 'string' then msg = { args = { msg } } end
    send('message', msg)
end)

RegisterNetEvent('chat:addSuggestions', function(list)
    send('suggestions', list)
end)

RegisterNetEvent('chat:addSuggestion', function(name, help, params)
    send('suggestion', { name = name, help = help, params = params })
end)

RegisterNetEvent('chat:removeSuggestion', function(name)
    send('removeSuggestion', { name = name })
end)

RegisterNetEvent('chat:clear', function()
    send('clear', {})
end)

RegisterNetEvent('chat:addTemplate', function(id, html)
    send('template', { id = id, html = html })
end)

RegisterNetEvent('morph_chat:head', function(data)
    if not data or not data.sid then return end
    bubbles[data.sid] = {
        mtype = data.mtype,
        text = data.text,
        name = data.name,
        height = data.height or 1.0,
        expire = GetGameTimer() + (data.duration or 8000),
    }
end)

CreateThread(function()
    while true do
        local any = false
        local out = {}
        local now = GetGameTimer()
        for sid, b in pairs(bubbles) do
            if now >= b.expire then
                bubbles[sid] = nil
            else
                local ply = GetPlayerFromServerId(sid)
                local ped = ply ~= -1 and GetPlayerPed(ply) or 0
                if ped ~= 0 and DoesEntityExist(ped) then
                    any = true
                    local head = GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0)
                    local wx, wy, wz = head.x, head.y, head.z + (b.height or 0.35)
                    local on, sx, sy = World3dToScreen2d(wx, wy, wz)
                    if on then
                        local dist = #(GetGameplayCamCoord() - vector3(wx, wy, wz))
                        local scale = 8.0 / (dist > 0.1 and dist or 0.1)
                        if scale > 1.15 then scale = 1.15 elseif scale < 0.5 then scale = 0.5 end
                        local left = b.expire - now
                        local alpha = left >= 900 and 1.0 or (left / 900)
                        out[#out + 1] = { id = tostring(sid), x = sx, y = sy, scale = scale, alpha = alpha, mtype = b.mtype, text = b.text }
                    end
                end
            end
        end
        send('bubbles', out)
        Wait(any and 0 or 300)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
