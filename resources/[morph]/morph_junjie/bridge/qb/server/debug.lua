---@deprecated Call lib.print.debug() instead
---@param tbl any
RegisterServerEvent('QBCore:DebugSomething', function(tbl)
    local resource = GetInvokingResource() or 'morph_junjie'
    lib.print.debug(resource, tbl)
end)
