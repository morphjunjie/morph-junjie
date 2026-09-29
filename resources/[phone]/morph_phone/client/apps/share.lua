---The reusable ShareSheet's "who's nearby" query. Thin forward into server/share, which reads
---player distances server-side.
RegisterNUICallback('morph_phone:share:nearby', function(_, cb)
    cb(lib.callback.await('morph_phone:server:share:nearby', false) or { success = false, data = { targets = {} } })
end)

---Server push: an incoming AirShare request; relays it to the NUI's accept/decline popup and,
---when the phone is closed, surfaces a notification.
---@param data table { kind, fromName, ... } request from server/share/core.lua
RegisterNetEvent('morph_phone:client:airshare:request', function(data)
    SendNUIMessage({ action = 'morph_phone:airshare', data = data })

    local ok, open = pcall(function() return exports['morph_phone']:isOpen() end)
    if ok and not open then
        local kind = (data and data.kind == 'voice') and 'voice memo' or 'contact'
        SendNUIMessage({ action = 'morph_phone:notification', data = {
            app   = 'phone',
            title = 'AirShare',
            body  = ('%s wants to share a %s. Open your phone to respond.'):format((data and data.fromName) or 'Someone', kind),
        } })
    end
end)

---Accept or decline a pending AirShare. Thin forward into server/share.
RegisterNUICallback('morph_phone:airshare:respond', function(payload, cb)
    cb(lib.callback.await('morph_phone:server:airshare:respond', false, payload) or { success = false })
end)
