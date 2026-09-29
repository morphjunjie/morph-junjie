Config = Config or {}

Config.Core = "morph_junjie"        -- "qb-core" or "morph_junjie"
Config.Fuel = "morph_fuel"        -- "ps-fuel", "LegacyFuel", "morph_fuel"
Config.ResourcePerms = 'admin' -- permission to control resource(start stop restart)
Config.ShowCommandsPerms = 'admin' -- permission to show all commands
Config.RenewedPhone = false    -- if you use qb-phone from renewed. (multijob)

-- Key Bindings
Config.Keybindings = true
Config.AdminKey = "PageDown"
Config.NoclipKey = "PageUp"

-- Give Car
Config.DefaultGarage = "airportgarage" -- default garage to store vehicles if no garage is specified

Config.Actions = {
    ["admin_car"] = {
        label = "Admin Car",
        type = "client",
        event = "morph_god:client:Admincar",
        perms = "admin",
    },

    ["ban_player"] = {
        label = "Ban Player",
        perms = "admin",
        dropdown = {
            { label = "Player", option = "dropdown", data = "players" },
            { label = "Reason", option = "text" },
            {
                label = "Duration",
                option = "dropdown",
                data = {
                    { label = "Permanent",  value = "2147483647" },
                    { label = "10 Minutes", value = "600" },
                    { label = "30 Minutes", value = "1800" },
                    { label = "1 Hour",     value = "3600" },
                    { label = "6 Hours",    value = "21600" },
                    { label = "12 Hours",   value = "43200" },
                    { label = "1 Day",      value = "86400" },
                    { label = "3 Days",     value = "259200" },
                    { label = "1 Week",     value = "604800" },
                    { label = "3 Week",     value = "1814400" },
                },
            },
            { label = "Confirm", option = "button", type = "server", event = "morph_god:server:BanPlayer" },
        },
    },

    ["bring_player"] = {
        label = "Bring Player",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:BringPlayer" },
        },
    },

    ["change_weather"] = {
        label = "Change Weather",
        perms = "mod",
        dropdown = {
            {
                label = "Weather",
                option = "dropdown",
                data = {
                    { label = "Extrasunny", value = "Extrasunny" },
                    { label = "Clear",      value = "Clear" },
                    { label = "Neutral",    value = "Neutral" },
                    { label = "Smog",       value = "Smog" },
                    { label = "Foggy",      value = "Foggy" },
                    { label = "Overcast",   value = "Overcast" },
                    { label = "Clouds",     value = "Clouds" },
                    { label = "Clearing",   value = "Clearing" },
                    { label = "Rain",       value = "Rain" },
                    { label = "Thunder",    value = "Thunder" },
                    { label = "Snow",       value = "Snow" },
                    { label = "Blizzard",   value = "Blizzard" },
                    { label = "Snowlight",  value = "Snowlight" },
                    { label = "Xmas",       value = "Xmas" },
                    { label = "Halloween",  value = "Halloween" },
                },
            },
            { label = "Confirm", option = "button", type = "client", event = "morph_god:client:ChangeWeather" },
        },
    },

    ["change_time"] = {
        label = "Change Time",
        perms = "mod",
        dropdown = {
            {
                label = "Time Events",
                option = "dropdown",
                data = {
                    { label = "Sunrise", value = "06" },
                    { label = "Morning", value = "09" },
                    { label = "Noon",    value = "12" },
                    { label = "Sunset",  value = "21" },
                    { label = "Evening", value = "22" },
                    { label = "Night",   value = "24" },
                },
            },
            { label = "Confirm", option = "button", type = "client", event = "morph_god:client:ChangeTime" },
        },
    },

    ["change_plate"] = {
        label = "Change Plate",
        perms = "admin",
        dropdown = {
            { label = "Plate",   option = "text" },
            { label = "Confirm", option = "button", type = "client", event = "morph_god:client:ChangePlate" },
        },
    },

    ["clear_inventory"] = {
        label = "Clear Inventory",
        perms = "admin",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:ClearInventory" },
        },
    },

    ["clear_inventory_offline"] = {
        label = "Clear Inventory Offline",
        perms = "admin",
        dropdown = {
            { label = "Citizen ID", option = "text",   data = "players" },
            { label = "Confirm",    option = "button", type = "server", event = "morph_god:server:ClearInventoryOffline" },
        },
    },

    ["clothing_menu"] = {
        label = "Give Clothing Menu",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:ClothingMenu" },
        },
    },

    ["set_ped"] = {
        label = "Set Ped",
        perms = "mod",
        dropdown = {
            { label = "Player",     option = "dropdown", data = "players" },
            { label = "Ped Models", option = "dropdown", data = "pedlist" },
            { label = "Confirm",    option = "button",   type = "server", event = "morph_god:server:setPed" },
        },
    },

    ["copy_coords"] = {
        label = "Copy Coords",
        perms = "mod",
        dropdown = {
            {
                label = "Copy Coords",
                option = "dropdown",
                data = {
                    { label = "Copy Vector2", value = "vector2" },
                    { label = "Copy Vector3", value = "vector3" },
                    { label = "Copy Vector4",    value = "vector4" },
                    { label = "Copy Heading",  value = "heading" },
                },
            },
            { label = "Copy to Clipboard", option = "button", type = "client", event = "morph_god:client:copyToClipboard"},
        },
    },

    ["delete_vehicle"] = {
        label = "Delete Vehicle",
        type = "command",
        event = "dv",
        perms = "mod",
    },

    ["freeze_player"] = {
        label = "Freeze Player",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:FreezePlayer" },
        },
    },

    ["drunk_player"] = {
        label = "Make Player Drunk",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:DrunkPlayer" },
        },
    },

    ["remove_stress"] = {
        label = "Remove Stress",
        perms = "mod",
        dropdown = {
            { label = "Player (Optional)", option = "dropdown", data = "players" },
            { label = "Confirm",           option = "button",   type = "server", event = "morph_god:server:RemoveStress" },
        },
    },

    ["set_ammo"] = {
        label = "Set Ammo",
        perms = "admin",
        dropdown = {
            { label = "Ammo Amount", option = "text" },
            { label = "Confirm",      option = "button", type = "client", event = "morph_god:client:SetAmmo" },
        },
    },

    -- ["nui_focus"] = {
    --     label = "Give NUI Focus",
    --     perms = "mod",
    --     dropdown = {
    --         { label = "Player",  option = "dropdown", data = "players" },
    --         { label = "Confirm", option = "button",   type = "client", event = "" },
    --     },
    -- },

    ["god_mode"] = {
        label = "God Mode",
        type = "client",
        event = "morph_god:client:ToggleGodmode",
        perms = "admin",
    },

    ["give_car"] = {
        label = "Give Car",
        perms = "admin",
        dropdown = {
            { label = "Vehicle",           option = "dropdown", data = "vehicles" },
            { label = "Player",            option = "dropdown", data = "players" },
            { label = "Plate (Optional)",  option = "text" },
            { label = "Garage (Optional)", option = "text" },
            { label = "Confirm",           option = "button",   type = "server",  event = "morph_god:server:givecar" },
        }
    },

    ["invisible"] = {
        label = "Invisible",
        type = "client",
        event = "morph_god:client:ToggleInvisible",
        perms = "mod",
    },

    ["blackout"] = {
        label = "Toggle Blackout",
        type = "server",
        event = "morph_god:server:ToggleBlackout",
        perms = "mod",
    },

    ["toggle_duty"] = {
        label = "Toggle Duty",
        type = "server",
        event = "QBCore:ToggleDuty",
        perms = "mod",
    },

    ["toggle_laser"] = {
        label = "Toggle Laser",
        type = "client",
        event = "morph_god:client:ToggleLaser",
        perms = "mod",
    },

    ["set_perms"] = {
        label = "Set Perms",
        perms = "admin",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            {
                label = "Permissions",
                option = "dropdown",
                data = {
                    { label = "Mod",   value = "mod" },
                    { label = "Admin", value = "admin" },
                    { label = "God",   value = "god" },
                },
            },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:SetPerms" },
        },
    },

    ["set_bucket"] = {
        label = "Set Routing Bucket",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Bucket",  option = "text" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:SetBucket" },
        },
    },

    ["get_bucket"] = {
        label = "Get Routing Bucket",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:GetBucket" },
        },
    },

    ["mute_player"] = {
        label = "Mute Player",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "client", event = "morph_god:client:MutePlayer" },
        },
    },

    ["noclip"] = {
        label = "Noclip",
        type = "client",
        event = "morph_god:client:ToggleNoClip",
        perms = "mod",
    },

    ["open_inventory"] = {
        label = "Open Inventory",
        perms = "admin",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "client", event = "morph_god:client:openInventory" },
        },
    },

    ["open_stash"] = {
        label = "Open Stash",
        perms = "mod",
        dropdown = {
            { label = "Stash",   option = "text" },
            { label = "Confirm", option = "button", type = "client", event = "morph_god:client:openStash" },
        },
    },

    ["open_trunk"] = {
        label = "Open Trunk",
        perms = "mod",
        dropdown = {
            { label = "Plate",   option = "text" },
            { label = "Confirm", option = "button", type = "client", event = "morph_god:client:openTrunk" },
        },
    },

    ["change_vehicle_state"] = {
        label = "Set Vehicle Garage State",
        perms = "mod",
        dropdown = {
            { label = "Plate",   option = "text" },
            {
                label = "State",
                option = "dropdown",
                data = {
                    { label = "In",  value = "1" },
                    { label = "Out", value = "0" },
                },
            },
            { label = "Confirm", option = "button", type = "server", event = "morph_god:server:SetVehicleState" },
        },
    },

    ["revive_all"] = {
        label = "Revive All",
        type = "server",
        event = "morph_god:server:ReviveAll",
        perms = "admin",
    },

    ["revive_player"] = {
        label = "Revive Player",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:Revive" },
        },
    },

    ["revive_radius"] = {
        label = "Revive Radius",
        type = "server",
        event = "morph_god:server:ReviveRadius",
        perms = "mod",
    },

    ["refuel_vehicle"] = {
        label = "Refuel Vehicle",
        type = "client",
        event = "morph_god:client:RefuelVehicle",
        perms = "mod",
    },

    ["set_job"] = {
        label = "Set Job",
        perms = "admin",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Job",     option = "dropdown", data = "jobs" },
            { label = "Grade",   option = "text",     data = "grades" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:SetJob" },
        },
    },

    ["set_gang"] = {
        label = "Set Gang",
        perms = "admin",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Gang",    option = "dropdown", data = "gangs" },
            { label = "Grade",   option = "text",     data = "grades" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:SetGang" },
        },
    },

    ["give_money"] = {
        label = "Give Money",
        perms = "admin",
        dropdown = {
            { label = "Player", option = "dropdown", data = "players" },
            { label = "Amount", option = "text" },
            {
                label = "Type",
                option = "dropdown",
                data = {
                    { label = "Cash",   value = "cash" },
                    { label = "Bank",   value = "bank" },
                    { label = "Crypto", value = "crypto" },
                },
            },
            { label = "Confirm", option = "button", type = "server", event = "morph_god:server:GiveMoney" },
        },
    },

    ["give_money_all"] = {
        label = "Give Money to All",
        perms = "admin",
        dropdown = {
            { label = "Amount",  option = "text" },
            {
                label = "Type",
                option = "dropdown",
                data = {
                    { label = "Cash",   value = "cash" },
                    { label = "Bank",   value = "bank" },
                    { label = "Crypto", value = "crypto" },
                },
            },
            { label = "Confirm", option = "button", type = "server", event = "morph_god:server:GiveMoneyAll" },
        },
    },

    ["remove_money"] = {
        label = "Remove Money",
        perms = "admin",
        dropdown = {
            { label = "Player", option = "dropdown", data = "players" },
            { label = "Amount", option = "text" },
            {
                label = "Type",
                option = "dropdown",
                data = {
                    { label = "Cash", value = "cash" },
                    { label = "Bank", value = "bank" },
                },
            },
            { label = "Confirm", option = "button", type = "server", event = "morph_god:server:TakeMoney" },
        },
    },

    ["give_item"] = {
        label = "Give Item",
        perms = "admin",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Item",    option = "dropdown", data = "items" },
            { label = "Amount",  option = "text" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:GiveItem" },
        },
    },

    ["give_item_all"] = {
        label = "Give Item to All",
        perms = "admin",
        dropdown = {
            { label = "Item",    option = "dropdown", data = "items" },
            { label = "Amount",  option = "text" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:GiveItemAll" },
        },
    },

    ["spawn_vehicle"] = {
        label = "Spawn Vehicle",
        perms = "mod",
        dropdown = {
            { label = "Vehicle", option = "dropdown", data = "vehicles" },
            { label = "Confirm", option = "button",   type = "client",  event = "morph_god:client:SpawnVehicle" },
        },
    },

    ["fix_vehicle"] = {
        label = "Fix Vehicle",
        type = "command",
        event = "fix",
        perms = "mod",
    },

    ["fix_vehicle_for"] = {
        label = "Fix Vehicle for player",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:FixVehFor" },
        },
    },

    ["spectate_player"] = {
        label = "Spectate Player",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:SpectateTarget" },
        },
    },

    ["telport_to_player"] = {
        label = "Teleport to Player",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:TeleportToPlayer" },
        },
    },

    ["telport_to_coords"] = {
        label = "Teleport to Coords",
        perms = "mod",
        dropdown = {
            { label = "Coords",  option = "text" },
            { label = "Confirm", option = "button", type = "client", event = "morph_god:client:TeleportToCoords" },
        },
    },

    ["teleport_to_location"] = {
        label = "Teleport to Location",
        perms = "mod",
        dropdown = {
            { label = "Location", option = "dropdown", data = "locations" },
            { label = "Confirm",  option = "button",   type = "client",   event = "morph_god:client:TeleportToLocation" },
        },
    },

    ["teleport_to_marker"] = {
        label = "Teleport to Marker",
        type = "command",
        event = "tpm",
        perms = "mod",
    },

    ["teleport_back"] = {
        label = "Teleport Back",
        type = "client",
        event = "morph_god:client:TeleportBack",
        perms = "mod",
    },

    ["vehicle_dev"] = {
        label = "Vehicle Dev Menu",
        type = "client",
        event = "morph_god:client:ToggleVehDevMenu",
        perms = "mod",
    },

    ["toggle_coords"] = {
        label = "Toggle Coords",
        type = "client",
        event = "morph_god:client:ToggleCoords",
        perms = "mod",
    },

    ["toggle_blips"] = {
        label = "Toggle Blips",
        type = "client",
        event = "morph_god:client:toggleBlips",
        perms = "mod",
    },

    ["toggle_names"] = {
        label = "Toggle Names",
        type = "client",
        event = "morph_god:client:toggleNames",
        perms = "mod",
    },

    ["toggle_cuffs"] = {
        label = "Toggle Cuffs",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:CuffPlayer" },
        },
    },

    ["max_mods"] = {
        label = "Max Vehicle Mods",
        type = "client",
        event = "morph_god:client:maxmodVehicle",
        perms = "mod",
    },

    ["warn_player"] = {
        label = "Warn Player",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Reason",  option = "text" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:WarnPlayer" },
        },
    },

    ["infinite_ammo"] = {
        label = "Infinite Ammo",
        type = "client",
        event = "morph_god:client:setInfiniteAmmo",
        perms = "admin",
    },

    ["kick_player"] = {
        label = "Kick Player",
        perms = "mod",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Reason",  option = "text" },
            { label = "Confirm", option = "button",   type = "server", event = "morph_god:server:KickPlayer" },
        },
    },


    ["play_sound"] = {
        label = "Play Sound",
        perms = "mod",
        dropdown = {
            { label = "Player",     option = "dropdown", data = "players" },
            {
                label = "Sound",
                option = "dropdown",
                data = {
                    { label = "Alert",      value = "alert" },
                    { label = "Cuff",       value = "cuff" },
                    { label = "Air Wrench", value = "airwrench" },
                },
            },
            { label = "Play Sound", option = "button",   type = "client", event = "morph_god:client:PlaySound" },
        },
    },
}

Config.PlayerActions = {
    ["teleportToPlayer"] = {
        label = "Teleport to Player",
        type = "server",
        event = "morph_god:server:TeleportToPlayer",
        perms = "mod",
    },
    ["bringPlayer"] = {
        label = "Bring Player",
        type = "server",
        event = "morph_god:server:BringPlayer",
        perms = "mod",
    },
    ["revivePlayer"] = {
        label = "Revive Player",
        event = "morph_god:server:Revive",
        perms = "mod",
        type = "server"
    },
    ["spawnPersonalVehicle"] = {
        label = "Spawn Personal Vehicle",
        event = "morph_god:client:SpawnPersonalVehicle",
        perms = "mod",
        type = "client"
    },
    ["banPlayer"] = {
        label = "Ban Player",
        event = "morph_god:server:BanPlayer",
        perms = "mod",
        type = "server"
    },
    ["kickPlayer"] = {
        label = "Kick Player",
        event = "morph_god:server:KickPlayer",
        perms = "mod",
        type = "server"
    }
}

Config.OtherActions = {
    ["toggleDevmode"] = {
        type = "client",
        event = "morph_god:client:ToggleDev",
        perms = "admin",
        label = "Toggle Devmode"
    }
}

if GetResourceState('morph_inv') == 'started' then
    Config.Inventory = 'morph_inv'
elseif GetResourceState('ps-inventory') == 'started' then
    Config.Inventory = 'ps-inventory'
elseif GetResourceState('lj-inventory') == 'started' then
    Config.Inventory = 'lj-inventory'
elseif GetResourceState('qb-inventory') == 'started' then
    Config.Inventory = 'qb-inventory'
end
