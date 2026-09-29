local minZ, maxZ = nil, nil

local function handleInput(center)
  local rot = GetGameplayCamRot(2)
  center = handleArrowInput(center, rot.z)
  return center
end

function polyStart(name)
  local coords = GetEntityCoords(PlayerPedId())
  createdZone = morph_zone:Create({vector2(coords.x, coords.y)}, {name = tostring(name), useGrid=false})
  Citizen.CreateThread(function()
    while createdZone do
      -- Have to convert the point to a vector3 prior to calling handleInput,
      -- then convert it back to vector2 afterwards
      lastPoint = createdZone.points[#createdZone.points]
      lastPoint = vector3(lastPoint.x, lastPoint.y, 0.0)
      lastPoint = handleInput(lastPoint)
      createdZone.points[#createdZone.points] = lastPoint.xy
      Wait(0)
    end
  end)
  minZ, maxZ = coords.z, coords.z
end

function polyFinish()
  TriggerServerEvent("morph_zone:printPoly",
    {name=createdZone.name, points=createdZone.points, minZ=minZ, maxZ=maxZ})
end

RegisterNetEvent("morph_zone:pzadd")
AddEventHandler("morph_zone:pzadd", function()
  if createdZone == nil or createdZoneType ~= 'poly' then
    return
  end

  local coords = GetEntityCoords(PlayerPedId())

  if (coords.z > maxZ) then
    maxZ = coords.z
  end

  if (coords.z < minZ) then
    minZ = coords.z
  end

  createdZone.points[#createdZone.points + 1] = vector2(coords.x, coords.y)
end)

RegisterNetEvent("morph_zone:pzundo")
AddEventHandler("morph_zone:pzundo", function()
  if createdZone == nil or createdZoneType ~= 'poly' then
    return
  end

  createdZone.points[#createdZone.points] = nil
  if #createdZone.points == 0 then
    TriggerEvent("morph_zone:pzcancel")
  end
end)