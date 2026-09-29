---@type fun(nuiAction: string, serverEvent: string) NUI->server proxy factory (client.nui).
local proxy = require 'client.nui'

-- Settings -> SIM & Backup (unique-phones mode): panel snapshot, SIM eject, cloud backup.
proxy('morph_phone:sim:get',            'morph_phone:server:sim:get')
proxy('morph_phone:sim:eject',          'morph_phone:server:sim:eject')
proxy('morph_phone:sim:backup:set',     'morph_phone:server:sim:backup:set')
proxy('morph_phone:sim:backup:sync',    'morph_phone:server:sim:backup:sync')
proxy('morph_phone:sim:backup:setAuto', 'morph_phone:server:sim:backup:setAuto')
proxy('morph_phone:sim:backup:delete',  'morph_phone:server:sim:backup:delete')
proxy('morph_phone:sim:backup:restore', 'morph_phone:server:sim:backup:restore')

---Opens the SIM tray of the phone in `slot`. Exported for the phone item's morph_inv `buttons`
---entry (see the README); the server re-derives the tray from the slot and force-opens it.
---@param slot number inventory slot holding the phone
exports('openSimTray', function(slot)
    TriggerServerEvent('morph_phone:server:sim:openTray', slot)
end)
