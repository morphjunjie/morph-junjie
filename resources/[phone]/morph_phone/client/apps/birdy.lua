---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxyCallback = require 'client.nui'

-- Thin delegates into server/birdy: account session, profiles, the feed, posting, likes,
-- follows, notifications and DMs.
proxyCallback('morph_phone:birdy:me',            'morph_phone:server:birdy:me')
proxyCallback('morph_phone:birdy:register',      'morph_phone:server:birdy:register')
proxyCallback('morph_phone:birdy:login',         'morph_phone:server:birdy:login')
proxyCallback('morph_phone:birdy:logout',        'morph_phone:server:birdy:logout')
proxyCallback('morph_phone:birdy:profile',        'morph_phone:server:birdy:profile')
proxyCallback('morph_phone:birdy:profilePosts',   'morph_phone:server:birdy:profilePosts')
proxyCallback('morph_phone:birdy:search',         'morph_phone:server:birdy:search')
proxyCallback('morph_phone:birdy:trending',       'morph_phone:server:birdy:trending')
proxyCallback('morph_phone:birdy:hashtag',        'morph_phone:server:birdy:hashtag')
proxyCallback('morph_phone:birdy:updateProfile',  'morph_phone:server:birdy:updateProfile')
proxyCallback('morph_phone:birdy:changePassword', 'morph_phone:server:birdy:changePassword')
proxyCallback('morph_phone:birdy:deleteAccount',  'morph_phone:server:birdy:deleteAccount')
proxyCallback('morph_phone:birdy:verificationOffer',    'morph_phone:server:birdy:verificationOffer')
proxyCallback('morph_phone:birdy:purchaseVerification', 'morph_phone:server:birdy:purchaseVerification')
proxyCallback('morph_phone:birdy:feed',          'morph_phone:server:birdy:feed')
proxyCallback('morph_phone:birdy:post',          'morph_phone:server:birdy:post')
proxyCallback('morph_phone:birdy:create',        'morph_phone:server:birdy:create')
proxyCallback('morph_phone:birdy:reply',         'morph_phone:server:birdy:reply')
proxyCallback('morph_phone:birdy:toggleLike',    'morph_phone:server:birdy:toggleLike')
proxyCallback('morph_phone:birdy:deletePost',    'morph_phone:server:birdy:deletePost')
proxyCallback('morph_phone:birdy:toggleFollow',  'morph_phone:server:birdy:toggleFollow')
proxyCallback('morph_phone:birdy:toggleRepost', 'morph_phone:server:birdy:toggleRepost')
proxyCallback('morph_phone:birdy:vote',          'morph_phone:server:birdy:vote')
proxyCallback('morph_phone:birdy:followList',    'morph_phone:server:birdy:followList')
proxyCallback('morph_phone:birdy:notifications', 'morph_phone:server:birdy:notifications')
proxyCallback('morph_phone:birdy:notificationCount', 'morph_phone:server:birdy:notificationCount')
proxyCallback('morph_phone:birdy:dmResolve',     'morph_phone:server:birdy:dmResolve')
proxyCallback('morph_phone:birdy:dmList',        'morph_phone:server:birdy:dmList')
proxyCallback('morph_phone:birdy:dmThread',      'morph_phone:server:birdy:dmThread')
proxyCallback('morph_phone:birdy:dmSend',        'morph_phone:server:birdy:dmSend')
proxyCallback('morph_phone:birdy:dmReact',       'morph_phone:server:birdy:dmReact')
proxyCallback('morph_phone:birdy:watch',         'morph_phone:server:birdy:watch')

---Server push: relays a DM that arrived for our logged-in Birdy account.
---@param data table DM record from server/birdy/init.lua
RegisterNetEvent('morph_phone:client:birdy:dmReceived', function(data)
    SendNUIMessage({ action = 'morph_phone:birdy:dmReceived', data = data })
end)

---Server push: relays an updated DM reaction set.
---@param data table reaction patch from server/birdy/init.lua
RegisterNetEvent('morph_phone:client:birdy:dmReaction', function(data)
    SendNUIMessage({ action = 'morph_phone:birdy:dmReaction', data = data })
end)

---Server push: relays a notification nudge (like, reply, follow).
---@param data table notification nudge from server/birdy/init.lua (currently empty)
RegisterNetEvent('morph_phone:client:birdy:notification', function(data)
    SendNUIMessage({ action = 'morph_phone:birdy:notification', data = data })
end)

---Server push: somebody posted, reposted or voted, so any open feed is now stale. A vote carries
---{ postId, poll } so the timeline patches that one card; anything else is empty and refetches.
---@param data table patch or empty payload from server/birdy/actions.lua
RegisterNetEvent('morph_phone:client:birdy:feedChanged', function(data)
    SendNUIMessage({ action = 'morph_phone:birdy:feedChanged', data = data or {} })
end)
