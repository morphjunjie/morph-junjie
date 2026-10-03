---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxyCallback = require 'client.nui'

-- Thin delegates into server/accounts: the shared app-accounts engine (registration, login,
-- password resets, the saved-passwords vault) every account-based app authenticates through.
proxyCallback('morph_phone:accounts:register',     'morph_phone:server:accounts:register')
proxyCallback('morph_phone:accounts:login',        'morph_phone:server:accounts:login')
proxyCallback('morph_phone:accounts:logout',       'morph_phone:server:accounts:logout')
proxyCallback('morph_phone:accounts:signOutAll',   'morph_phone:server:accounts:signOutAll')
proxyCallback('morph_phone:accounts:capacity',     'morph_phone:server:accounts:capacity')
proxyCallback('morph_phone:accounts:me',           'morph_phone:server:accounts:me')
proxyCallback('morph_phone:accounts:signInOptions', 'morph_phone:server:accounts:signInOptions')
proxyCallback('morph_phone:accounts:switchable',   'morph_phone:server:accounts:switchable')
proxyCallback('morph_phone:accounts:switch',       'morph_phone:server:accounts:switch')
proxyCallback('morph_phone:accounts:requestReset', 'morph_phone:server:accounts:requestReset')
proxyCallback('morph_phone:accounts:confirmReset', 'morph_phone:server:accounts:confirmReset')
proxyCallback('morph_phone:accounts:changePassword', 'morph_phone:server:accounts:changePassword')
proxyCallback('morph_phone:accounts:suggestCode',  'morph_phone:server:accounts:suggestCode')
proxyCallback('morph_phone:accounts:myNumber',     'morph_phone:server:accounts:myNumber')
proxyCallback('morph_phone:accounts:myEmail',      'morph_phone:server:accounts:myEmail')
proxyCallback('morph_phone:accounts:savePassword',   'morph_phone:server:accounts:savePassword')
proxyCallback('morph_phone:accounts:saveCustomPassword', 'morph_phone:server:accounts:saveCustomPassword')
proxyCallback('morph_phone:accounts:listPasswords',  'morph_phone:server:accounts:listPasswords')
proxyCallback('morph_phone:accounts:deletePassword', 'morph_phone:server:accounts:deletePassword')
