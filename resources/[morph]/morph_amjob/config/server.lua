return {
    doctorCallCooldown = 1, -- Time in minutes for cooldown between doctors calls
    wipeInvOnRespawn = true, -- Enable to disable removing all items from player on respawn
    depositSociety = function(society, amount)
        exports['morph_bank']:addAccountMoney(society, amount)
    end
}