---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxy = require 'client.nui'

-- Thin delegates: directory, duty + contact toggles, company account, and roster management all
-- proxy straight into server callbacks.
proxy('morph_phone:services:directory',   'morph_phone:server:services:directory')
proxy('morph_phone:services:setDuty',        'morph_phone:server:services:setDuty')
proxy('morph_phone:services:setJobCalls',    'morph_phone:server:services:setJobCalls')
proxy('morph_phone:services:setJobMessages', 'morph_phone:server:services:setJobMessages')
proxy('morph_phone:services:deposit',     'morph_phone:server:services:deposit')
proxy('morph_phone:services:withdraw',    'morph_phone:server:services:withdraw')
proxy('morph_phone:services:hire',        'morph_phone:server:services:hire')
proxy('morph_phone:services:fire',        'morph_phone:server:services:fire')
proxy('morph_phone:services:promote',     'morph_phone:server:services:promote')
proxy('morph_phone:services:demote',      'morph_phone:server:services:demote')
proxy('morph_phone:services:quit',        'morph_phone:server:services:quit')

-- Thin delegates: company calls and the company message inbox.
proxy('morph_phone:services:callCompany',    'morph_phone:server:services:callCompany')
proxy('morph_phone:services:inbox',          'morph_phone:server:services:inbox')
proxy('morph_phone:services:markRead',       'morph_phone:server:services:markRead')
proxy('morph_phone:services:messageCompany', 'morph_phone:server:services:messageCompany')
proxy('morph_phone:services:replyCompany',   'morph_phone:server:services:replyCompany')

-- Thin delegates for the Jobs tab (multi-job): list saved jobs + offers, switch active job,
-- accept/decline an offer.
proxy('morph_phone:services:listJobs',       'morph_phone:server:services:listJobs')
proxy('morph_phone:services:switchJob',      'morph_phone:server:services:switchJob')
proxy('morph_phone:services:removeJob',      'morph_phone:server:services:removeJob')
proxy('morph_phone:services:acceptInvite',   'morph_phone:server:services:acceptInvite')
proxy('morph_phone:services:declineInvite',  'morph_phone:server:services:declineInvite')

-- Thin delegates for business invoicing: send/list/cancel from the business side, received/pay
-- from the target's Banking app.
proxy('morph_phone:services:invoices:list',     'morph_phone:server:services:invoices:list')
proxy('morph_phone:services:invoices:create',   'morph_phone:server:services:invoices:create')
proxy('morph_phone:services:invoices:cancel',   'morph_phone:server:services:invoices:cancel')
proxy('morph_phone:services:invoices:received', 'morph_phone:server:services:invoices:received')
proxy('morph_phone:services:invoices:pay',      'morph_phone:server:services:invoices:pay')

---Server nudge: re-pull invoices (a new one was sent, paid, or cancelled). No payload.
RegisterNetEvent('morph_phone:client:services:invoices', function()
    SendNUIMessage({ action = 'morph_phone:services:invoices' })
end)

---Server nudge: re-pull the jobs/offers list. No payload.
RegisterNetEvent('morph_phone:client:services:jobsChanged', function()
    SendNUIMessage({ action = 'morph_phone:services:jobsChanged' })
end)

---Server nudge: a boss should re-pull the employee roster (someone joined/left/ranked).
RegisterNetEvent('morph_phone:client:services:rosterChanged', function()
    SendNUIMessage({ action = 'morph_phone:services:rosterChanged' })
end)

---Server nudge: re-pull the company inbox (new company message / staff reply).
RegisterNetEvent('morph_phone:client:services:inbox', function()
    SendNUIMessage({ action = 'morph_phone:services:inbox' })
end)

---Drops a GPS waypoint on the company's coords; nil-guarded.
---@param payload table { coords: { x: number, y: number } }
RegisterNUICallback('morph_phone:services:locate', function(payload, cb)
    local c = payload and payload.coords
    if c and c.x and c.y then
        SetNewWaypoint(c.x + 0.0, c.y + 0.0)
        cb({ success = true })
    else
        cb({ success = false, message = 'No location set' })
    end
end)

---Relays server-pushed duty changes into the app.
---@param data table duty-change payload from the server
RegisterNetEvent('morph_phone:client:services:dutyChanged', function(data)
    SendNUIMessage({ action = 'morph_phone:services:dutyChanged', data = data })
end)
