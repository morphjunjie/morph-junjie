---@type fun(nuiAction: string, serverEvent: string) NUI->server pass-through registrar (client.nui).
local proxy = require 'client.nui'

-- Thin delegates into server/stocks: market snapshot, cash deposits/withdrawals and trades.
proxy('morph_phone:stocks:market',   'morph_phone:server:stocks:market')
proxy('morph_phone:stocks:deposit',  'morph_phone:server:stocks:deposit')
proxy('morph_phone:stocks:withdraw', 'morph_phone:server:stocks:withdraw')
proxy('morph_phone:stocks:buy',      'morph_phone:server:stocks:buy')
proxy('morph_phone:stocks:sell',     'morph_phone:server:stocks:sell')
proxy('morph_phone:stocks:holders',  'morph_phone:server:stocks:holders')
proxy('morph_phone:stocks:watch',    'morph_phone:server:stocks:watch')

---Server push: a live price tick; relays it to open charts and tickers.
---@param data table price snapshot from server/stocks
RegisterNetEvent('morph_phone:client:stocks:prices', function(data)
    SendNUIMessage({ action = 'morph_phone:stocks:prices', data = data })
end)
