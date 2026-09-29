---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxyCallback = require 'client.nui'
---@type table morph_phone config root (configs/config.lua): AllowMovement for keep-input restore.
local config = require 'configs.config'

---@type boolean True while the admin panel NUI is on screen.
local adminOpen = false
---@type boolean Mirror of the phone's open state (morph_phone:client:openState).
local phoneOpen = false

AddEventHandler('morph_phone:client:openState', function(open)
    phoneOpen = open and true or false
    -- The phone releases NUI focus when it closes; re-assert it while the panel is still up.
    if not phoneOpen and adminOpen then
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)
    end
end)

-- A wipe reloads the NUI, destroying the admin-panel React tree. Clear our open flag so the
-- openState handler above won't re-assert focus over a panel that no longer exists; main.lua
-- drops the actual focus.
AddEventHandler('morph_phone:client:wipeFocus', function()
    adminOpen = false
end)

---Opens the panel. Fired by the server-side /phoneadmin command (server/admin/init.lua), which
---is the permission gate - this event never opens anything the callbacks wouldn't refuse.
---Keep-input is forced off so the game gets no movement/camera input while the panel is up
---(the phone's AllowMovement mode leaves it on).
---@param adminName string acting admin's display name for the panel header
---@param simActive boolean|nil unique-phones mode flag (shows the Numbers page)
---@param racingOn boolean|nil whether the racing app runs here (shows the Racing page)
RegisterNetEvent('morph_phone:client:admin:open', function(adminName, simActive, racingOn)
    if adminOpen then return end
    adminOpen = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        action = 'morph_phone:admin:open',
        data   = { adminName = adminName, sim = simActive == true, racing = racingOn == true },
    })
end)

---React to Lua: the panel requests to close (X button / Escape). With the phone still open,
---focus stays and its movement-mode keep-input is restored; otherwise focus is released.
---@param _ table|nil unused payload
---@param cb fun(result: table) NUI response
RegisterNUICallback('morph_phone:admin:close', function(_, cb)
    adminOpen = false
    if phoneOpen then
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(config.Phone.AllowMovement == true)
    else
        SetNuiFocus(false, false)
    end
    cb({ ok = true })
end)

-- Thin delegates into server/admin: every callback re-checks the admin ace server-side.
proxyCallback('morph_phone:admin:search',               'morph_phone:server:admin:search')
proxyCallback('morph_phone:admin:overview',             'morph_phone:server:admin:overview')
proxyCallback('morph_phone:admin:setNumber',            'morph_phone:server:admin:setNumber')
proxyCallback('morph_phone:admin:resetPasscode',        'morph_phone:server:admin:resetPasscode')
proxyCallback('morph_phone:admin:setApp',               'morph_phone:server:admin:setApp')
proxyCallback('morph_phone:admin:resetAccountPassword', 'morph_phone:server:admin:resetAccountPassword')
proxyCallback('morph_phone:admin:forceLogout',          'morph_phone:server:admin:forceLogout')
proxyCallback('morph_phone:admin:birdyPosts',           'morph_phone:server:admin:birdyPosts')
proxyCallback('morph_phone:admin:birdyDeletePost',      'morph_phone:server:admin:birdyDeletePost')
proxyCallback('morph_phone:admin:birdySetVerified',     'morph_phone:server:admin:birdySetVerified')
proxyCallback('morph_phone:admin:content',              'morph_phone:server:admin:content')
proxyCallback('morph_phone:admin:contentDelete',        'morph_phone:server:admin:contentDelete')
proxyCallback('morph_phone:admin:contentThread',        'morph_phone:server:admin:contentThread')
proxyCallback('morph_phone:admin:contentThreadDelete',  'morph_phone:server:admin:contentThreadDelete')
proxyCallback('morph_phone:admin:media',                'morph_phone:server:admin:media')
proxyCallback('morph_phone:admin:livePositions',        'morph_phone:server:admin:livePositions')
proxyCallback('morph_phone:admin:flags',                'morph_phone:server:admin:flags')
proxyCallback('morph_phone:admin:flagsScan',            'morph_phone:server:admin:flagsScan')
proxyCallback('morph_phone:admin:flagResolve',          'morph_phone:server:admin:flagResolve')
proxyCallback('morph_phone:admin:bin',                  'morph_phone:server:admin:bin')
proxyCallback('morph_phone:admin:binRestore',           'morph_phone:server:admin:binRestore')
proxyCallback('morph_phone:admin:messages',             'morph_phone:server:admin:messages')
proxyCallback('morph_phone:admin:calls',                'morph_phone:server:admin:calls')
proxyCallback('morph_phone:admin:mute',                 'morph_phone:server:admin:mute')
proxyCallback('morph_phone:admin:unmute',               'morph_phone:server:admin:unmute')
proxyCallback('morph_phone:admin:mutes',                'morph_phone:server:admin:mutes')
proxyCallback('morph_phone:admin:wipePhone',            'morph_phone:server:admin:wipePhone')
proxyCallback('morph_phone:admin:audit',                'morph_phone:server:admin:audit')
proxyCallback('morph_phone:admin:stats',                'morph_phone:server:admin:stats')
proxyCallback('morph_phone:admin:simLookup',            'morph_phone:server:admin:simLookup')
proxyCallback('morph_phone:admin:giveSim',              'morph_phone:server:admin:giveSim')
proxyCallback('morph_phone:admin:numbers',              'morph_phone:server:admin:numbers')
proxyCallback('morph_phone:admin:migrateScan',          'morph_phone:server:admin:migrateScan')
proxyCallback('morph_phone:admin:migrateState',         'morph_phone:server:admin:migrateState')
proxyCallback('morph_phone:admin:migrateStart',         'morph_phone:server:admin:migrateStart')
proxyCallback('morph_phone:admin:migrateStop',          'morph_phone:server:admin:migrateStop')
proxyCallback('morph_phone:admin:migrateWatch',         'morph_phone:server:admin:migrateWatch')

---Server to React: one migration progress push. The server only sends these to admins who asked
---to watch, so this relays whatever arrives without a gate of its own.
---@param payload table { state?: table, lines?: table[], reset?: boolean }
RegisterNetEvent('morph_phone:client:migrate:push', function(payload)
    SendNUIMessage({ action = 'morph_phone:admin:migrate', data = payload })
end)
