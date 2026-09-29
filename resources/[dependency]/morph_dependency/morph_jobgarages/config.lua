-- config.lua
return {
    AllowedJobs = {
        ['police'] = true,
        ['ambulance'] = true,
    },
    
    NotifyTitle = 'Job Garage',
    Cooldown = 5000,
    FuelAmount = 100.0,
    EngineHealth = 1000.0,
    BodyHealth = 1000.0,
    MaxGrade = 7,
    
    Jobs = {
        police = {
            label = 'Police Garage',
            platePrefix = 'LSPD',
            groundTarget = {
                coords = vec3(441.91, -1013.56, 28.63),
                size = vec3(1.5, 1.5, 2.0),
                rotation = 0,
                distance = 2.0,
            },
            groundSpawn = vec4(442.35, -1018.91, 28.68, 87.71),
            heliTarget = {
                coords = vec3(463.65, -982.42, 43.69),
                size = vec3(1.5, 1.5, 2.0),
                rotation = 0,
                distance = 2.0,
            },
            heliSpawn = vec4(449.24, -981.25, 43.69, 179.82),
            Categories = {
                {
                    id = 'cars',
                    label = 'Cars',
                    icon = 'fa-solid fa-car',
                    spawnType = 'ground',
                    vehicles = {
                        { label = 'Police Cruiser', model = 'police', grade = 0, livery = 0 },
                        { label = 'Police Interceptor', model = 'police2', grade = 1, livery = 0 },
                        { label = 'Police Riot', model = 'riot', grade = 2, livery = 0 },
                        { label = 'Police Buffalo', model = 'police3', grade = 3, livery = 0 },
                        { label = 'Police Rancher', model = 'police4', grade = 4, livery = 0 },
                        { label = 'FBI', model = 'fbi', grade = 5, livery = 0 },
                        { label = 'FBI2', model = 'fbi2', grade = 6, livery = 0 },
                    }
                },
                {
                    id = 'motorcycles',
                    label = 'Motorcycles',
                    icon = 'fa-solid fa-motorcycle',
                    spawnType = 'ground',
                    vehicles = {
                        { label = 'Police Bike', model = 'policeb', grade = 1, livery = 0 },
                        { label = 'Police Bati', model = 'policeb2', grade = 3, livery = 0 },
                    }
                },
                {
                    id = 'bicycles',
                    label = 'Bicycles',
                    icon = 'fa-solid fa-bicycle',
                    spawnType = 'ground',
                    vehicles = {
                        { label = 'BMX', model = 'bmx', grade = 0 },
                        { label = 'Scorcher', model = 'scorcher', grade = 0 },
                    }
                },
                {
                    id = 'helicopters',
                    label = 'Helicopters',
                    icon = 'fa-solid fa-helicopter',
                    spawnType = 'heli',
                    vehicles = {
                        { label = 'Police Maverick', model = 'polmav', grade = 5 },
                        { label = 'Police Buzzard', model = 'buzzard2', grade = 7, livery = 0 },
                    }
                },
            },
        },
        
        ambulance = {
            label = 'Ambulance Garage',
            platePrefix = 'EMS',
            groundTarget = {
                coords = vec3(299.9, -571.43, 43.26),
                size = vec3(1.5, 1.5, 2.0),
                rotation = 0,
                distance = 2.0,
            },
            groundSpawn = vec4(294.54, -574.7, 43.18, 60.95),
            heliTarget = {
                coords = vector3(337.49, -586.51, 74.17),
                size = vec3(1.5, 1.5, 2.0),
                rotation = 0,
                distance = 2.0,
            },
            heliSpawn = vec4(352.01, -587.89, 74.17, 180.07),
            Categories = {
                {
                    id = 'ambulances',
                    label = 'Ambulances',
                    icon = 'fa-solid fa-truck-medical',
                    spawnType = 'ground',
                    vehicles = {
                        { label = 'Ambulance', model = 'ambulance', grade = 0, livery = 0 },
                        { label = 'Ambulance 2', model = 'ambulance2', grade = 2, livery = 0 },
                    }
                },
                {
                    id = 'cars',
                    label = 'Response Cars',
                    icon = 'fa-solid fa-car',
                    spawnType = 'ground',
                    vehicles = {
                        { label = 'EMS SUV', model = 'emssuv', grade = 1, livery = 0 },
                        { label = 'EMS Car', model = 'emscar', grade = 3, livery = 0 },
                    }
                },
                {
                    id = 'helicopters',
                    label = 'Helicopters',
                    icon = 'fa-solid fa-helicopter',
                    spawnType = 'heli',
                    vehicles = {
                        { label = 'Medical Helicopter', model = 'polmav', grade = 5, livery = 1 },
                        { label = 'Air Ambulance', model = 'buzzard2', grade = 7, livery = 0 },
                    }
                },
            },
        },
    },
}