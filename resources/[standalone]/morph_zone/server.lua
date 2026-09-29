local eventPrefix = '__morph_zone__:'

function triggerZoneEvent(eventName, ...)
  TriggerClientEvent(eventPrefix .. eventName, -1, ...)
end

RegisterNetEvent("morph_zone:TriggerZoneEvent")
AddEventHandler("morph_zone:TriggerZoneEvent", triggerZoneEvent)

exports("TriggerZoneEvent", triggerZoneEvent)