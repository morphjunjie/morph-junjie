return {
    discordWebhook = nil, -- Replace nil with your webhook if you chose to use discord logging over morph_ui logging
    minOnDutyLogTimeMinutes = 30,
    formatDateTime = '%m-%d-%Y %H:%M',

    -- While the config boss menu creation still works, it is recommended to use the runtime export instead.
    -- Single menu: { coords = ..., size = ..., rotation = ..., type = ... }
    -- Multiple menus: { { coords = ..., size = ..., rotation = ..., type = ... }, { ... }  }
    ---@alias GroupName string
    ---@type table<GroupName, ZoneInfo|ZoneInfo[]>
    menus = {
        lostmc = {
            {
                coords = vec3(983.69, -90.92, 74.85),
                size = vec3(1.5, 1.5, 1.5),
                rotation = 39.68,
                type = 'gang',
            },
        },
        police = {
            coords = vector3(446.83, -974.32, 30.71),
            size = vector3(1.5, 1.5, 1.5),
            rotation = 39.68,
            type = 'job',
        },
    },
}
