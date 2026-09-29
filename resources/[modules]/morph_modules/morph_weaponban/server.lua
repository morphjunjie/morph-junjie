local QBX = exports.morph_junjie

---Cek apakah player exempted (kebal) dari auto-ban
---@param src number
---@return boolean
local function isExempted(src)
    -- cek identifier (license/discord/steam/dll)
    for _, id in pairs(GetPlayerIdentifiers(src)) do
        if Config.Exempted.Identifiers[id] then
            return true
        end
    end

    -- cek job lewat morph_junjie
    local player = QBX:GetPlayer(src)
    if player and player.PlayerData and player.PlayerData.job then
        local jobName = player.PlayerData.job.name
        if Config.Exempted.Jobs[jobName] then
            return true
        end
    end

    -- cek ACE (cocokin persis dengan nama ace yang di-grant di permissions.cfg)
    for aceName, _ in pairs(Config.Exempted.AceNames) do
        if IsPlayerAceAllowed(src, aceName) then
            return true
        end
    end

    return false
end

---Notify semua admin online (opsional, pakai morph_junjie:Notify + ACE check admin)
---@param message string
local function notifyAdmins(message)
    if not Config.NotifyAdmins then return end

    for _, playerId in pairs(GetPlayers()) do
        if IsPlayerAceAllowed(playerId, 'admin') then
            QBX:Notify(playerId, message, 'error', 8000)
        end
    end
end

RegisterNetEvent('weaponautoban:server:reportWeapon', function(reportedWeaponHash)
    local src = source

    -- jangan percaya begitu saja apa yang dikirim client:
    -- validasi ulang weapon yang ACTUALLY sedang dipegang lewat native server-side
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end

    local actualWeaponHash = GetSelectedPedWeapon(ped)

    if actualWeaponHash ~= reportedWeaponHash then
        -- data ga cocok, kemungkinan delay/desync, skip dulu
        return
    end

    if not Config.BannedWeapons[actualWeaponHash] then
        return
    end

    if isExempted(src) then
        return
    end

    local player = QBX:GetPlayer(src)
    local citizenid = (player and player.PlayerData and player.PlayerData.citizenid) or 'unknown'
    local playerName = GetPlayerName(src) or 'unknown'

    print(('[WEAPON-AUTOBAN] Banning %s (citizenid: %s, source: %s) - reason: illegal weapon hash %s')
        :format(playerName, citizenid, src, actualWeaponHash))

    notifyAdmins(('%s (%s) auto-banned karena weapon terlarang.'):format(playerName, citizenid))

    -- eksekusi ban lewat morph_junjie
    -- exports.morph_junjie:ExploitBan(playerId, origin)
    QBX:ExploitBan(src, Config.BanReason)
end)
