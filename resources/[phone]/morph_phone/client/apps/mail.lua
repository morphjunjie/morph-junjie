---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxyCallback = require 'client.nui'

-- Thin delegates into server/mail: account session, mailbox listing, composing, drafts,
-- flags and folder moves.
proxyCallback('morph_phone:mail:list',       'morph_phone:server:mail:list')
proxyCallback('morph_phone:mail:signUp',     'morph_phone:server:mail:signUp')
proxyCallback('morph_phone:mail:signIn',     'morph_phone:server:mail:signIn')
proxyCallback('morph_phone:mail:signOut',    'morph_phone:server:mail:signOut')
proxyCallback('morph_phone:mail:send',       'morph_phone:server:mail:send')
proxyCallback('morph_phone:mail:saveDraft',  'morph_phone:server:mail:saveDraft')
proxyCallback('morph_phone:mail:markRead',   'morph_phone:server:mail:markRead')
proxyCallback('morph_phone:mail:markManyRead', 'morph_phone:server:mail:markManyRead')
proxyCallback('morph_phone:mail:toggleFlag', 'morph_phone:server:mail:toggleFlag')
proxyCallback('morph_phone:mail:moveToBin',  'morph_phone:server:mail:moveToBin')
proxyCallback('morph_phone:mail:discardDraft', 'morph_phone:server:mail:discardDraft')
proxyCallback('morph_phone:mail:saveAttachment', 'morph_phone:server:mail:saveAttachment')
proxyCallback('morph_phone:mail:attachmentSaveStates', 'morph_phone:server:mail:attachmentSaveStates')
proxyCallback('morph_phone:mail:move',       'morph_phone:server:mail:move')
proxyCallback('morph_phone:mail:deleteAccount', 'morph_phone:server:mail:deleteAccount')
proxyCallback('morph_phone:mail:savedEmails', 'morph_phone:server:mail:savedEmails')
proxyCallback('morph_phone:mail:saveEmail',   'morph_phone:server:mail:saveEmail')
proxyCallback('morph_phone:mail:declineEmail', 'morph_phone:server:mail:declineEmail')
proxyCallback('morph_phone:mail:removeSavedEmail', 'morph_phone:server:mail:removeSavedEmail')

---Server push: a mail landed in our signed-in inbox; relays it to the app.
---@param message table mail record from server/mail
RegisterNetEvent('morph_phone:client:mail:received', function(message)
    SendNUIMessage({ action = 'morph_phone:mail:received', data = message })
end)
