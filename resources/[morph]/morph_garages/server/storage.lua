---@async
local function moveOutVehiclesIntoGarages()
    MySQL.update('UPDATE player_vehicles SET state = ? WHERE state = ?', {VehicleState.GARAGED, VehicleState.OUT})
end

---@param vehicleId integer
---@param garageName string
---@param state VehicleState
---@return integer numRowsAffected
local function setVehicleGarage(vehicleId, garageName, state)
    return MySQL.update('UPDATE player_vehicles SET garage = ?, state = ? WHERE id = ?', {
        garageName,
        state,
        vehicleId
    })
end

---@param vehicleId integer
---@param depotPrice integer
---@return integer numRowsAffected
local function setVehicleDepotPrice(vehicleId, depotPrice)
    return MySQL.update('UPDATE player_vehicles SET depotPrice = ? WHERE id = ? AND state != ?', {
        depotPrice,
        vehicleId,
        VehicleState.GARAGED
    })
end

---@param vehicleId integer
---@param releaseAt integer
local function setImpoundRelease(vehicleId, releaseAt)
    MySQL.update('UPDATE player_vehicles SET impound_release_at = ? WHERE id = ?', {releaseAt, vehicleId})
end

---@param vehicleId integer
---@return integer? releaseAt
local function getImpoundRelease(vehicleId)
    local result = MySQL.scalar.await('SELECT impound_release_at FROM player_vehicles WHERE id = ?', {vehicleId})
    return result
end

---@param vehicleId integer
local function clearImpoundTimer(vehicleId)
    MySQL.update('UPDATE player_vehicles SET impound_release_at = 0 WHERE id = ?', {vehicleId})
end

---@return table[] impoundedVehicles
local function getAllImpoundedVehicles()
    return MySQL.query.await('SELECT id, impound_release_at FROM player_vehicles WHERE impound_release_at > 0 AND state = ?', {VehicleState.IMPOUNDED})
end

return {
    moveOutVehiclesIntoGarages = moveOutVehiclesIntoGarages,
    setVehicleGarage = setVehicleGarage,
    setVehicleDepotPrice = setVehicleDepotPrice,
    setImpoundRelease = setImpoundRelease,
    getImpoundRelease = getImpoundRelease,
    clearImpoundTimer = clearImpoundTimer,
    getAllImpoundedVehicles = getAllImpoundedVehicles,
}