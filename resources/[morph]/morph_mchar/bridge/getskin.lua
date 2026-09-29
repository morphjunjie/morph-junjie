lib.callback.register("morph_mchar:server:getSkin", function(_, cid)
    if GetResourceState('bl_appearance') == 'started' then
        local appearance = exports.bl_appearance:GetPlayerAppearance(cid)

        if not appearance then
            return nil, nil
        end

        return appearance.model, appearance
    elseif GetResourceState('rcore_clothing') == 'started' then
        local skin = exports.rcore_clothing:getSkinByIdentifier(cid)

        if not skin then
            return nil, nil
        end

        return skin.ped_model, skin.skin
    else
        local skinQuery = MySQL.single.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = ? LIMIT 1',
            { cid, 1 })

        if skinQuery ~= nil then
            local skin = json.decode(skinQuery.skin)
            return skinQuery.model or skin.model or nil, skin
        end

        return nil, nil
    end
end)
