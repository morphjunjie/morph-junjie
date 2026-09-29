---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxy = require 'client.nui'

-- Thin delegates into server/banking: the account overview and phone transfers.
proxy('morph_phone:banking:overview', 'morph_phone:server:banking:overview')
proxy('morph_phone:banking:send',     'morph_phone:server:banking:send')
proxy('morph_phone:banking:setCardStyle', 'morph_phone:server:banking:setCardStyle')

-- Standing orders (server/banking/standing.lua).
proxy('morph_phone:banking:standing:list',   'morph_phone:server:banking:standing:list')
proxy('morph_phone:banking:standing:create', 'morph_phone:server:banking:standing:create')
proxy('morph_phone:banking:standing:update', 'morph_phone:server:banking:standing:update')
proxy('morph_phone:banking:standing:delete', 'morph_phone:server:banking:standing:delete')

-- Person-to-person invoicing (server/services/invoices.lua personal handlers).
proxy('morph_phone:banking:invoices:create', 'morph_phone:server:banking:invoices:create')
proxy('morph_phone:banking:invoices:sent',   'morph_phone:server:banking:invoices:sent')
proxy('morph_phone:banking:invoices:cancel', 'morph_phone:server:banking:invoices:cancel')

---Server push: another player transferred money to us; relays it to the Wallet.
---@param data table { amount, from } from server/banking/actions.lua
RegisterNetEvent('morph_phone:client:bankReceived', function(data)
    SendNUIMessage({ action = 'morph_phone:bank:received', data = data })
end)

---Server push: a transaction was recorded outside the app (an external debit/credit); nudges
---the Wallet to refetch.
RegisterNetEvent('morph_phone:client:bankTxAdded', function()
    SendNUIMessage({ action = 'morph_phone:bank:txAdded' })
end)

---@type boolean True while a balance-refresh nudge is already scheduled.
local nudgePending = false

---Debounced Wallet refresh: framework money events burst (paycheck plus tax), one refetch does.
local function nudgeWallet()
    if nudgePending then return end
    nudgePending = true
    SetTimeout(500, function()
        nudgePending = false
        SendNUIMessage({ action = 'morph_phone:bank:txAdded' })
    end)
end

-- Framework money-change broadcasts, so the balance ticks live even when ANOTHER script moves
-- money. Whichever framework is absent simply never fires its event; the handlers are inert.
RegisterNetEvent('hud:client:OnMoneyChange', nudgeWallet)
RegisterNetEvent('QBCore:Client:OnMoneyChange', nudgeWallet)
RegisterNetEvent('esx:setAccountMoney', nudgeWallet)
