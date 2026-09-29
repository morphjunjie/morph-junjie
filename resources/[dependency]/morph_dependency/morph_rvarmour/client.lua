local armourRemoving = false
local function Notify(desc, type) lib.notify({ title = 'Armour Management', description = desc, type = type or 'info', duration = 3000 }) end
local function playRemoveAnim() local ped = PlayerPedId() lib.requestAnimDict('clothingshirt') TaskPlayAnim(ped, 'clothingshirt', 'try_shirt_positive_d', 8.0, -8.0, 4000, 49, 0, false, false, false) end
local function stopAnim() ClearPedTasks(PlayerPedId()) end
RegisterNetEvent('morph_armour:client:removeArmour', function()
    local ped = PlayerPedId()
    local currentArmour = GetPedArmour(ped)
    if armourRemoving then Notify('Already removing armour!', 'error') return end
    if currentArmour <= 0 then Notify('You don\'t have any armour!', 'error') return end
    armourRemoving = true
    playRemoveAnim()
    local success = lib.progressBar({ duration = 4000, label = 'Removing armour...', useWhileDead = false, canCancel = true, disable = { car = true, move = true, combat = true } })
    stopAnim()
    armourRemoving = false
    if not success then Notify('Action cancelled.', 'error') return end
    SetPedArmour(ped, 0)
    Notify('Armour removed successfully!', 'success')
end)
AddEventHandler('onResourceStop', function(resource) if GetCurrentResourceName() ~= resource then return end stopAnim() armourRemoving = false end)