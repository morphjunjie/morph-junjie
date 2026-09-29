local logger = require '@morph_junjie.modules.logger'

local defaultCalculateImpoundFee = function(vehicleId, modelName)
    local vehicleInfo = VEHICLES[modelName]

    if not vehicleInfo then
        logger.log({
            message = string.format(
                "The model name %s does not exist in the vehicle list. Cannot calculate impound fee.",
                modelName
            ),
            webhook = Config.logging.webhook.error,
            event = 'error',
            color = 'red'
        })

        return 0
    end

    local price = vehicleInfo.price

    local impoundFee = qbx.math.round(price * 0.005) -- 0.5% of the vehicle price

    logger.log({
        message = string.format(
            "Calculated impound fee for vehicle model %s (ID: %d) is: %d.",
            modelName,
            vehicleId,
            impoundFee
        ),
        webhook = Config.logging.webhook.default,
        event = 'info',
        color = 'blue'
    })

    return impoundFee
end

return defaultCalculateImpoundFee