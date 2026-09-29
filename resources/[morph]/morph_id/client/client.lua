local config = require('config')
local openID = false
local animDict, anim = 'paper_1_rcm_alt1-9', 'player_one_dual-9'

function nuiFocus(bool)
    SetNuiFocusKeepInput(bool)
    SetNuiFocus(bool, false)
    openID = bool
end

local function getCardProp(cardtype)
    if not cardtype then return warn('No Card Type') end

    local license = config.licenses[cardtype]
    if not license then return warn('Invalid Card Type: ' .. tostring(cardtype)) end

    local prop = license.prop
    if not prop then return warn('Card Type: ' .. cardtype .. ' No Prop') end

    return prop
end

local function startAnim(prop)
    lib.requestModel(prop)
    local playerCoords = GetEntityCoords(cache.ped)
    local createProp = CreateObject(prop, playerCoords.x, playerCoords.y, playerCoords.z + 0.2, true, true, true)

    AttachEntityToEntity(createProp, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.1000, 0.0200, -0.0300, -90.000,
        170.000, 78.999, true, true, false, true, 1, true)

    lib.requestAnimDict(animDict)
    TaskPlayAnim(cache.ped, animDict, anim, 3.0, -1, -1, 50, -1, false, false, false)
    SetModelAsNoLongerNeeded(prop)

    SetTimeout(3000, function()
        DeleteEntity(createProp)
        ClearPedTasks(cache.ped)
        RemoveAnimDict(animDict)
    end)
end

-- Events
RegisterNetEvent('morph_id:client:sendData', function(metadata)
    if GetInvokingResource() then return end
    if openID then return end
    if not getCardProp(metadata.cardtype) then return end

    nuiFocus(true)
    SendNUIMessage({ type = 'playerData', playerData = metadata })
end)

RegisterNetEvent('morph_id:client:animStart', function(metadata)
    if GetInvokingResource() then return end

    local prop = getCardProp(metadata.cardtype)
    if not prop then return end

    startAnim(prop)
end)
