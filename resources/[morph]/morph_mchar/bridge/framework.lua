-- Shared Events

Framework = {
    Events = {
        loadedC = 'QBCore:Client:OnPlayerLoaded',
        loadedS = 'QBCore:Server:OnPlayerLoaded',
        loadedSP = 'QBCore:Server:PlayerLoaded',
        unload = 'QBCore:Server:OnPlayerUnload',
        house = 'qb-houses:client:LastLocationHouse',
        houseS = 'qb-houses:server:SetInsideMeta',
        apart = 'qb-apartments:client:LastLocationHouse',
        apartS = 'qb-apartments:server:SetInsideMeta',
        logout = 'qb-houses:server:LogoutLocation',
    }
}

if GetResourceState('morph_junjie') ~= 'started' then
    Debug('QBCore loaded')

    function Framework:Core()
        QBCore = exports['qb-core']:GetCoreObject()
        return QBCore
    end

    function Framework:GetPlayerData()
        return QBCore?.Functions.GetPlayerData() or Debug('GetPlayerData failed')
    end

    if IsDuplicityVersion() then
        Debug('Server functions loaded')

        function Framework:GetPlayer(src)
            return QBCore?.Functions.GetPlayer(src) or Debug('GetPlayer failed')
        end

        function Framework:GetIdentifier(src)
            return QBCore?.Functions.GetIdentifier(src, 'license') or Debug('GetIdentifier failed')
        end

        function Framework:GetPlayerQuery(src)
            return MySQL.query.await('SELECT citizenid, cid, charinfo, money, job, position FROM players WHERE license = ?', { Framework:GetIdentifier(src) })
        end

        function Framework:Login(src, any, new)
            return QBCore?.Player.Login(src, any, new) or Debug('Login failed')
        end

        function Framework:RefreshCommand(src)
            QBCore?.Commands.Refresh(src)
            Debug('Commands refreshed')
        end

        function Framework:Logout(src)
            QBCore?.Player.Logout(src)
            Debug('Character logged out')
        end
    end
else
    Debug('M.A.D. District loaded')

    function Framework:Core()
        QBX = exports.morph_junjie
        return QBX
    end

    function Framework:GetPlayerData()
        return QBX:GetPlayerData() or Debug('GetPlayerData failed')
    end

    if IsDuplicityVersion() then
        Debug('Server functions loaded')

        function Framework:GetPlayer(src)
            return QBX:GetPlayer(src) or Debug('GetPlayer failed')
        end

        function Framework:GetIdentifier(src)
            local license = GetPlayerIdentifierByType(src, 'license')
            local license2 = GetPlayerIdentifierByType(src, 'license2')
            return license, license2
        end

        function Framework:GetPlayerQuery(src)
            return MySQL.query.await('SELECT citizenid, cid, charinfo, money, job, position FROM players WHERE license = ? OR license = ?', { GetPlayerIdentifierByType(src, 'license'), GetPlayerIdentifierByType(src, 'license2') })
        end

        function Framework:Login(src, any, new)
            return QBX:Login(src, any, new) or Debug('Login failed')
        end

        function Framework:RefreshCommand(src)
            Debug('Commands refreshed')
        end

        function Framework:Logout(src)
            QBX:Logout(src)
            Debug('Character logged out')
        end
    end
end