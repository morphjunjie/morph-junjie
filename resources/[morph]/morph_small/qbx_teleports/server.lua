-- server.lua
lib.callback.register('qbx_teleports:server:hasItem', function(source, item)
    local Player = exports.morph_junjie:GetPlayer(source)
    if not Player then return false end
    return Player.Functions.GetItemByName(item) ~= nil
end)