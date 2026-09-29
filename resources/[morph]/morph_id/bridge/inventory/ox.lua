if GetResourceState('morph_inv') ~= 'started' then return end

local morph_inv = exports.morph_inv

function setMetaDataInventory(src, item, mugShot)
    item.metadata.mugShot = mugShot
    morph_inv:SetMetadata(src, item.slot, item.metadata)
end

function addItemInventory(src, itemName, metadata)
    morph_inv:AddItem(src, itemName, 1, metadata)
end

function removeItemInventory(src, itemName, slot)
    if slot then
        morph_inv:RemoveItem(src, itemName, 1, nil, slot)
        return
    end
    local item = morph_inv:GetSlotWithItem(src, itemName)
    if not item then return end
    morph_inv:RemoveItem(src, itemName, 1, nil, item.slot)
end
