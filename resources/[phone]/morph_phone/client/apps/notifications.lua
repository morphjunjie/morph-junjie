---Shows one iOS-style banner in the React app; drops anything without a table payload and a
---string title. Fields: app, image, title (required), body, time, appId.
---@param data table notification payload
local function push(data)
    if type(data) ~= 'table' or type(data.title) ~= 'string' then return end
    SendNUIMessage({ action = 'morph_phone:notification', data = data })
end

---Landing point for the server notify export; shape-checked by push.
---@param data table notification payload
RegisterNetEvent('morph_phone:client:notify', function(data)
    push(data)
end)

---Client-side direct banner for scripts on this machine:
---exports['morph_phone']:showNotification({ title = '...', body = '...' }).
exports('showNotification', push)

-- Home-screen badges: server-computed unread counts; snapshot on phone open, pushes on change.

---Server push: a fresh badge snapshot (counts changed); relay it unchanged.
---@param snap table per-app unread counts
RegisterNetEvent('morph_phone:client:badges', function(snap)
    SendNUIMessage({ action = 'morph_phone:badges', data = snap })
end)

---Server push: one app's count changed; relay it as a patch the store merges over the rest.
---@param patch table single-entry { [appId] = count }
RegisterNetEvent('morph_phone:client:badgePatch', function(patch)
    SendNUIMessage({ action = 'morph_phone:badges:patch', data = patch })
end)

---React to server: badge snapshot fetched on phone open, with a zeroed fallback.
RegisterNUICallback('morph_phone:badges:get', function(_, cb)
    local snap = lib.callback.await('morph_phone:server:badges:get', false)
    cb(snap or { messages = 0, phone = 0 })
end)

---React to server: the Phone app opened - acknowledges missed calls.
RegisterNUICallback('morph_phone:calls:seen', function(_, cb)
    local result = lib.callback.await('morph_phone:server:calls:seen', false)
    cb(result or { success = false })
end)

---/phonenotif [app] - fires a sample banner; the optional first arg picks the app icon.
RegisterCommand('phonenotif', function(_, args)
    local app = args[1] or 'messages'
    push({
        app   = app,
        title = 'Notification',
        body  = 'This is a test notification 👋  Tap to open, or swipe up to dismiss.',
        time  = 'now',
        appId = app,
    })
end, false)
