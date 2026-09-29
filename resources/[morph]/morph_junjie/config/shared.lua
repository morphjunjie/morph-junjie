return {
    serverName = 'Server',
    defaultSpawn = vec4(-540.58, -212.02, 37.65, 208.88),
    notifyPosition = 'bottom', -- 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left'
    ---@type { name: string, amount: integer, metadata: fun(source: number): table }[]
    starterItems = { -- Character starting items
        { name = 'phone', amount = 1 },
        { name = 'id_card', amount = 1, metadata = function(source)
                assert(GetResourceState('morph_id') == 'started', 'morph_id resource not found. Required to give an id_card as a starting item')
                return exports.morph_id:GetMetaLicense(source, {'id_card'})
            end
        },
        { name = 'driver_license', amount = 1, metadata = function(source)
                assert(GetResourceState('morph_id') == 'started', 'morph_id resource not found. Required to give an id_card as a starting item')
                return exports.morph_id:GetMetaLicense(source, {'driver_license'})
            end
        },
    }
}
