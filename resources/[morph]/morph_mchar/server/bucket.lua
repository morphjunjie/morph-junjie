local function setRoutingBucket(src, tag)
  if not src then
    return Debug("Source is nil", "error")
  end
  local bucket = tonumber(src) + 1000
  local label = tag or "UNKWN"
  SetPlayerRoutingBucket(src, bucket)
  Debug(label .. " Player Routing Bucket Set: " .. tostring(source) .. " - " .. bucket .. "")
end

lib.callback.register("um-multi:bucket:setRandomBucket", function(src)
  setRoutingBucket(src, "Started: ")
end)

RegisterNetEvent(Framework.Events.logout, function()
  setRoutingBucket(source, "Logout Event House")
end)
