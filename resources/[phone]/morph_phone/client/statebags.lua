---@type table Self-export proxy for the morph_phone client surface.
local sd = exports['morph_phone']

---Reports the shell state only the client can know to the server, which does the replicated state
---bag write. First-party rather than part of any one compat shim: several shims read these bags,
---and hanging the feed off one of them makes the others silently depend on it being enabled.
---@param open boolean whether the phone shell is open
local function report(open)
    TriggerServerEvent('morph_phone:server:statebags:report', {
        open    = open,
        soft    = sd:isCompanionOpen() == true,
        battery = sd:getBattery(),
    })
end

AddEventHandler('morph_phone:client:openState', function(open) report(open == true) end)

---Publishes the cosmetic battery percentage on the same cadence the UI drains it.
AddEventHandler('morph_phone:client:battery', function(level)
    TriggerServerEvent('morph_phone:server:statebags:report', { battery = level })
end)

-- A resource restart lands mid-session, where no open/close edge is coming.
CreateThread(function() report(sd:isOpen() == true) end)
