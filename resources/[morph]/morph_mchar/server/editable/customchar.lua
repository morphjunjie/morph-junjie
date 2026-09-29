local Slots = require 'server.list.slotslist'

function GetNumberCharactersSlot(src)
    if Slots.DiscordPerm.status then
        local numOfChars = ReqDiscord(src)
        return numOfChars
    end

    local list = Slots.List
    local characterSlot = Config.DefaultSlots

    if not next(list) then
        Debug('No slots list found return config default slots', 'info')
        return characterSlot
    end

    local license, license2 = Framework:GetIdentifier(src)

    for i = 1, #list do
        local v = list[i]
        if v.license == license or v.license == license2 then
            characterSlot = v.totalSlot
            Debug('Found slot list total slot' .. characterSlot, 'info')
            break
        end
    end

    return characterSlot
end

lib.callback.register('morph_mchar:callback:CustomDeleteCharacterAccess', function(source)
    if not source then return end

    if not next(Slots.CustomDeleteCharacterAccess.list) or not Slots.CustomDeleteCharacterAccess.status then
        return Config.DeleteButton
    end

    local license, license2 = Framework:GetIdentifier(source)

    for i = 1, #Slots.CustomDeleteCharacterAccess.list do
        local list = Slots.CustomDeleteCharacterAccess.list[i]
        if list == license or list == license2 then
            return true
        end
    end

    return false
end)
