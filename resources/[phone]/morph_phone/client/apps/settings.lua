---@type fun(nuiAction: string, serverEvent: string, onAccepted?: fun()) NUI->server pass-through registrar (client.nui).
local proxyCallback = require 'client.nui'

---Announces an accepted settings write, so listeners can re-read the snapshot.
local function announce()
    TriggerEvent('morph_phone:client:settingsUpdated')
end

---Registers a settings write: the read pass-through plus the announcement.
---@param nuiAction string
---@param serverEvent string
local function writeCallback(nuiAction, serverEvent)
    proxyCallback(nuiAction, serverEvent, announce)
end

-- Thin delegates into server/settings: per-player setting reads/writes persisted to the
-- phone_settings table. Writes go through writeCallback so they announce afterwards.
proxyCallback('morph_phone:settings:get',      'morph_phone:server:settings:get')
writeCallback('morph_phone:settings:setTones', 'morph_phone:server:settings:setTones')
writeCallback('morph_phone:settings:tones:add',    'morph_phone:server:settings:tones:add')
writeCallback('morph_phone:settings:tones:remove', 'morph_phone:server:settings:tones:remove')
writeCallback('morph_phone:settings:setAirplane',  'morph_phone:server:settings:setAirplane')
writeCallback('morph_phone:settings:setFocus',        'morph_phone:server:settings:setFocus')
writeCallback('morph_phone:settings:setRotationLock', 'morph_phone:server:settings:setRotationLock')
writeCallback('morph_phone:settings:setHour24',    'morph_phone:server:settings:setHour24')
writeCallback('morph_phone:settings:setCallerId',  'morph_phone:server:settings:setCallerId')
writeCallback('morph_phone:settings:setStreamerMode', 'morph_phone:server:settings:setStreamerMode')
writeCallback('morph_phone:settings:setStreamerHide', 'morph_phone:server:settings:setStreamerHide')
proxyCallback('morph_phone:settings:resetCooldown', 'morph_phone:server:settings:resetCooldown')
writeCallback('morph_phone:settings:setReopenApp', 'morph_phone:server:settings:setReopenApp')
writeCallback('morph_phone:settings:setSetupDone', 'morph_phone:server:settings:setSetupDone')
writeCallback('morph_phone:settings:setTheme',     'morph_phone:server:settings:setTheme')
writeCallback('morph_phone:settings:setDarkTheme', 'morph_phone:server:settings:setDarkTheme')
writeCallback('morph_phone:settings:setLightTheme', 'morph_phone:server:settings:setLightTheme')
writeCallback('morph_phone:settings:setAccent', 'morph_phone:server:settings:setAccent')
writeCallback('morph_phone:settings:setShell', 'morph_phone:server:settings:setShell')
writeCallback('morph_phone:settings:setGameTime', 'morph_phone:server:settings:setGameTime')
writeCallback('morph_phone:settings:setIconTheme',    'morph_phone:server:settings:setIconTheme')
writeCallback('morph_phone:settings:saveCustomIconTheme',   'morph_phone:server:settings:saveCustomIconTheme')
writeCallback('morph_phone:settings:deleteCustomIconTheme', 'morph_phone:server:settings:deleteCustomIconTheme')
writeCallback('morph_phone:settings:savePalette',   'morph_phone:server:settings:savePalette')
writeCallback('morph_phone:settings:deletePalette', 'morph_phone:server:settings:deletePalette')
writeCallback('morph_phone:settings:setShowAppNames', 'morph_phone:server:settings:setShowAppNames')
writeCallback('morph_phone:settings:setLockClock', 'morph_phone:server:settings:setLockClock')
writeCallback('morph_phone:settings:setSecurity',  'morph_phone:server:settings:setSecurity')
writeCallback('morph_phone:settings:setWallpaper', 'morph_phone:server:settings:setWallpaper')
writeCallback('morph_phone:settings:setBlur',      'morph_phone:server:settings:setBlur')
writeCallback('morph_phone:settings:setIslandPet', 'morph_phone:server:settings:setIslandPet')
writeCallback('morph_phone:settings:wallpapers:add',    'morph_phone:server:settings:wallpapers:add')
writeCallback('morph_phone:settings:wallpapers:remove', 'morph_phone:server:settings:wallpapers:remove')
writeCallback('morph_phone:settings:setChatTextScale', 'morph_phone:server:settings:setChatTextScale')
writeCallback('morph_phone:settings:setAccessibility', 'morph_phone:server:settings:setAccessibility')
writeCallback('morph_phone:settings:setAppLabels',     'morph_phone:server:settings:setAppLabels')
writeCallback('morph_phone:settings:setHomeDensity',   'morph_phone:server:settings:setHomeDensity')
writeCallback('morph_phone:settings:setHomeIconScale', 'morph_phone:server:settings:setHomeIconScale')
writeCallback('morph_phone:settings:setPhoneScale',    'morph_phone:server:settings:setPhoneScale')
writeCallback('morph_phone:settings:setBrightness',    'morph_phone:server:settings:setBrightness')
writeCallback('morph_phone:settings:setPhoneAlign',    'morph_phone:server:settings:setPhoneAlign')
writeCallback('morph_phone:settings:setPhoneTilt',     'morph_phone:server:settings:setPhoneTilt')
writeCallback('morph_phone:settings:setInterface',     'morph_phone:server:settings:setInterface')
writeCallback('morph_phone:settings:setVolumes',       'morph_phone:server:settings:setVolumes')
writeCallback('morph_phone:settings:setLocale',        'morph_phone:server:settings:setLocale')
proxyCallback('morph_phone:settings:versionInfo',  'morph_phone:server:settings:versionInfo')
proxyCallback('morph_phone:settings:getNotifPref', 'morph_phone:server:settings:getNotifPref')
proxyCallback('morph_phone:settings:getNotifPrefs', 'morph_phone:server:settings:getNotifPrefs')
writeCallback('morph_phone:settings:setNotifPref', 'morph_phone:server:settings:setNotifPref')
writeCallback('morph_phone:settings:factoryReset', 'morph_phone:server:settings:factoryReset')
