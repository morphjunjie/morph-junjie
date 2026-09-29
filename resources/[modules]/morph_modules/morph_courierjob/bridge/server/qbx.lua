if GetResourceState('morph_junjie') ~= 'started' then return end


function GetPlayer(id)
    return exports.morph_junjie:GetPlayer(id)
end

function DoNotification(src, text, nType)
    exports.morph_junjie:Notify(src, text, nType)
end

function AddMoney(Player, moneyType, amount)
    Player.Functions.AddMoney(moneyType, amount, "Courier Delivery")
end

function handleExploit(id, reason)
    exports.morph_junjie:ExploitBan(id, reason)
end

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(source)
    ServerOnLogout(source)
end)