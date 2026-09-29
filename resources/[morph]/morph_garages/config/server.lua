return {
    autoRespawn = false,
    warpInVehicle = true,
    doorsLocked = false,
    distanceCheck = 5.0,
    impoundWaitTime = 60,
    calculateImpoundFee = require 'server.default-calculate-impound-fee',
    logging = { webhook = { error = nil, default = 'https://discord.com/api/webhooks/1544563806292672522/Mo-zsJCsCO1vUgaPjCe2Jh_N7dY3_Rw79MoXyRs7c7x28IXPAWVFjw9C3viTxuMLoJtV', anticheat = nil } },

    garages = {
        -- PUBLIC GARAGES
        citygarage = {
            label = 'City Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vector3(-297.27, -903.67, 31.2), vector3(-341.74, -894.23, 31.2), vector3(-340.19, -887.74, 31.07), vector3(-347.37, -885.73, 31.2), vector3(-344.69, -872.06, 31.07), vector3(-283.16, -884.92, 31.21), vector3(-284.66, -891.29, 31.08), vector3(-288.16, -890.56, 31.08), vector3(-289.61, -898.33, 31.2), vector3(-296.07, -897.07, 31.08) }, minZ = 29.0, maxZ = 33.0 },
            accessPoints = { { blip = { name = 'City Garage', sprite = 357, color = 5 }, coords = vec4(-314.35, -888.73, 31.08, 255.66) } }
        },
        pillboxgarage = {
            label = 'Pillbox Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vec3(200.2, -805.6, 30.0), vec3(218.9, -753.9, 30.0), vec3(263.6, -770.5, 30.0), vec3(239.5, -820.0, 30.0) }, minZ = 26.0, maxZ = 33.0 },
            accessPoints = { { blip = { name = 'PillBox Garage', sprite = 357, color = 5 }, coords = vec4(231.0, -787.0, 30.5, 160.0) } }
        },
        policepublicgarage = {
            label = 'Police Public Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vec3(405.61, -975.12, 29.27), vec3(410.76, -979.38, 29.41), vec3(410.97, -1007.69, 29.41), vec3(405.06, -1012.24, 29.41) }, minZ = 25.0, maxZ = 35.0 },
            accessPoints = { { blip = { name = 'Police Public Garage', sprite = 357, color = 5 }, coords = vec4(408.45, -992.29, 29.27, 104.47) } }
        },
        airportgarage = {
            label = 'Airport Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vector3(-1039.06, -2681.57, 13.83), vector3(-1049.97, -2672.78, 13.98), vector3(-1054.72, -2666.24, 13.98), vector3(-1058.38, -2658.06, 13.98), vector3(-1059.45, -2654.29, 13.98), vector3(-1054.21, -2652.23, 13.83), vector3(-1052.85, -2650.0, 13.83), vector3(-1049.33, -2651.89, 13.83), vector3(-1046.73, -2647.39, 13.83), vector3(-1026.2, -2659.24, 13.83), vector3(-1030.44, -2666.42, 13.83), vector3(-1047.82, -2655.24, 13.83), vector3(-1049.9, -2657.35, 13.83), vector3(-1047.99, -2661.17, 13.83), vector3(-1045.64, -2664.75, 13.83), vector3(-1042.64, -2668.11, 13.83), vector3(-1034.86, -2675.26, 13.83) }, minZ = 12.0, maxZ = 16.0 },
            accessPoints = { { blip = { name = 'Airport Garage', sprite = 357, color = 5 }, coords = vector4(-1041.43, -2663.18, 13.83, 40.76) } }
        },
        carnaval = {
            label = 'Carnaval Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vec3(-1706.61, -1119.16, 13.15), vec3(-1715.16, -1127.8, 13.16), vec3(-1729.8, -1116.97, 13.14), vec3(-1717.8, -1102.72, 13.15) }, minZ = 12.0, maxZ = 15.0 },
            accessPoints = { { blip = { name = 'Carnaval Garage', sprite = 357, color = 5 }, coords = vec4(-1718.53, -1115.93, 13.15, 49.4) } }
        },
        paletobaygarage = {
            label = 'Paleto Bay Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vector3(-23.01, 6323.87, 31.23), vector3(-17.97, 6315.63, 31.23), vector3(-8.04, 6321.14, 31.24), vector3(-6.97, 6320.17, 31.24), vector3(2.86, 6326.21, 31.24), vector3(6.5, 6315.49, 31.23), vector3(40.59, 6334.76, 31.23), vector3(35.47, 6350.4, 31.24), vector3(43.69, 6357.44, 31.24), vector3(46.37, 6354.89, 31.24), vector3(57.55, 6366.48, 31.24), vector3(61.0, 6368.84, 31.24), vector3(60.66, 6370.92, 31.24), vector3(65.44, 6374.76, 31.24), vector3(69.33, 6357.11, 31.23), vector3(83.21, 6363.63, 31.23), vector3(81.64, 6370.66, 31.23), vector3(92.29, 6375.73, 31.23), vector3(93.82, 6368.83, 31.23), vector3(104.43, 6373.87, 31.23), vector3(103.0, 6380.24, 31.23), vector3(89.12, 6382.77, 31.23), vector3(79.17, 6391.23, 31.23), vector3(84.66, 6396.92, 31.23), vector3(73.29, 6407.91, 31.23), vector3(68.73, 6403.55, 31.23), vector3(63.79, 6410.73, 31.23), vector3(55.58, 6402.49, 31.23), vector3(59.48, 6396.51, 31.23), vector3(55.45, 6393.0, 31.23), vector3(50.03, 6397.81, 31.23), vector3(33.72, 6380.9, 31.23), vector3(37.54, 6375.43, 31.23), vector3(30.5, 6368.77, 31.23), vector3(26.44, 6374.23, 31.23), vector3(5.69, 6351.81, 31.23), vector3(8.96, 6346.46, 31.23), vector3(3.04, 6340.04, 31.23), vector3(-0.77, 6346.09, 31.23) }, minZ = 29.0, maxZ = 34.0 },
            accessPoints = { { blip = { name = 'Paleto Bay Garage', sprite = 357, color = 5 }, coords = vector4(31.52, 6349.26, 31.24, 280.04) } }
        },
        galileogarage = {
            label = 'Galileo Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vec3(-378.9, 1222.66, 325.76), vec3(-378.66, 1219.25, 325.76), vec3(-386.7, 1190.52, 325.76), vec3(-424.73, 1200.78, 325.76), vec3(-412.97, 1243.0, 325.76), vec3(-393.55, 1236.92, 325.76), vec3(-388.94, 1231.0, 325.64), vec3(-386.43, 1227.88, 325.64), vec3(-380.74, 1224.81, 325.64) }, minZ = 300.0, maxZ = 330.0 },
            accessPoints = { { blip = { name = 'Galileo Garage', sprite = 357, color = 5 }, coords = vec4(-399.55, 1212.59, 325.9, 89.3) } }
        },

        -- JOB GARAGES
        garbagejobgarage = {
            label = 'Garbage Job Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vec3(-318.16, -1513.66, 27.59), vec3(-317.84, -1518.99, 27.56), vec3(-330.76, -1518.99, 27.54), vec3(-330.78, -1514.26, 27.57) }, minZ = 15.0, maxZ = 33.0 },
            accessPoints = { { blip = { name = 'Garbage Job Garage', sprite = 357, color = 5 }, coords = vec4(-324.44, -1516.66, 27.54, 178.71) } }
        },
        courierjobgarage = {
            label = 'Courier Job Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vec3(74.86, 102.13, 79.19), vec3(70.18, 88.34, 78.84), vec3(83.47, 83.75, 78.62), vec3(88.35, 97.12, 79.19) }, minZ = 69.0, maxZ = 87.0 },
            accessPoints = { { blip = { name = 'Courier Job Garage', sprite = 357, color = 5 }, coords = vec4(79.06, 93.09, 78.91, 234.99) } }
        },
        mininggarage = {
            label = 'Mining Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vec3(2943.59, 2749.31, 43.27), vec3(2952.28, 2729.91, 45.93), vec3(2961.63, 2735.06, 43.84), vec3(2956.6, 2752.65, 43.71) }, minZ = 30.0, maxZ = 50.0 },
            accessPoints = { { blip = { name = 'Mining Garage', sprite = 357, color = 5 }, coords = vec4(2956.2, 2743.72, 43.66, 295.54) } }
        },
        processmininggarage = {
            label = 'Process Mining Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vector3(1016.39, -1964.29, 31.12), vector3(1016.38, -1970.42, 31.1), vector3(994.0, -1970.36, 30.68), vector3(994.11, -1964.04, 30.73), vector3(986.9, -1964.17, 30.74), vector3(986.63, -1958.91, 30.75), vector3(986.58, -1952.22, 30.82), vector3(981.28, -1952.25, 30.83), vector3(981.28, -1941.42, 31.09), vector3(1003.65, -1941.38, 31.13), vector3(1003.71, -1952.18, 31.0), vector3(1009.06, -1952.33, 31.21), vector3(1008.97, -1959.07, 31.07), vector3(1008.98, -1964.04, 31.05), vector3(1016.56, -1963.96, 31.13) }, minZ = 27.0, maxZ = 38.0 },
            accessPoints = { { blip = { name = 'Process Mining Garage', sprite = 357, color = 5 }, coords = vector4(997.02, -1953.01, 30.84, 161.16) } }
        },
        lumberjackgarage = {
            label = 'Lumberjack Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vector3(-581.8, 5260.09, 70.49), vector3(-567.56, 5252.59, 70.49), vector3(-568.84, 5246.71, 70.47), vector3(-569.32, 5245.13, 70.47), vector3(-566.72, 5241.74, 70.47), vector3(-569.19, 5235.9, 70.48), vector3(-576.13, 5230.49, 70.58), vector3(-579.64, 5234.64, 70.47), vector3(-578.27, 5239.38, 70.47), vector3(-580.83, 5244.32, 70.47), vector3(-584.0, 5241.03, 70.47), vector3(-589.77, 5244.71, 70.46) }, minZ = 45.0, maxZ = 80.0 },
            accessPoints = { { blip = { name = 'Lumberjack Garage', sprite = 357, color = 5 }, coords = vector4(-575.6, 5248.77, 70.47, 211.6) } }
        },
        porkfarmgarage = {
            label = 'Pork Farm Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vec3(2410.68, 5026.9, 46.15), vec3(2402.3, 5018.29, 46.11), vec3(2393.69, 5026.95, 46.07), vec3(2401.32, 5035.41, 45.99) }, minZ = 38.0, maxZ = 48.0 },
            accessPoints = { { blip = { name = 'Pork Farm Garage', sprite = 357, color = 5 }, coords = vec4(2402.36, 5027.42, 45.99, 306.45) } }
        },
        processporkgarage = {
            label = 'Process Pork Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vec3(959.1, -2103.33, 30.76), vec3(958.34, -2116.46, 30.55), vec3(948.27, -2115.82, 30.55), vec3(948.17, -2103.1, 30.65) }, minZ = 28.0, maxZ = 34.0 },
            accessPoints = { { blip = { name = 'Process Pork Garage', sprite = 357, color = 5 }, coords = vec4(953.73, -2108.55, 30.55, 312.06) } }
        },
        vineyardjobgarage = {
            label = 'Vineyard Job Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vector3(-1909.4, 1998.23, 142.13), vector3(-1909.21, 2023.33, 140.75), vector3(-1902.9, 2023.29, 140.76), vector3(-1903.0, 1998.14, 141.95) }, minZ = 138.0, maxZ = 143.0 },
            accessPoints = { { blip = { name = 'Vineyard Job Garage', sprite = 357, color = 5 }, coords = vector4(-1906.27, 2010.33, 141.48, 261.41) } }
        },
        pizzajobgarage = {
            label = 'Pizza Job Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vector3(602.43, 103.23, 92.91), vector3(599.71, 95.82, 92.91), vector3(595.36, 97.61, 92.91), vector3(599.5, 109.33, 92.91), vector3(597.21, 110.58, 92.91), vector3(605.25, 132.8, 92.9), vector3(612.83, 130.05, 92.9), vector3(611.44, 125.94, 92.9), vector3(627.55, 119.66, 92.52), vector3(630.58, 128.18, 92.9), vector3(637.62, 125.64, 92.9), vector3(626.5, 96.6, 91.64), vector3(620.96, 98.88, 92.26), vector3(620.01, 97.78, 92.27), vector3(604.8, 103.27, 92.88) }, minZ = 70.0, maxZ = 96.0 },
            accessPoints = { { blip = { name = 'Pizza Job Garage', sprite = 357, color = 5 }, coords = vector4(616.34, 111.36, 92.87, 68.21) } }
        },
        huntingjobgarages = {
            label = 'Hunting Job Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vector3(-764.71, 5551.57, 33.49), vector3(-750.31, 5551.27, 33.49), vector3(-750.05, 5541.75, 33.49), vector3(-745.63, 5543.64, 33.49), vector3(-740.71, 5534.8, 33.49), vector3(-765.57, 5520.12, 33.49), vector3(-771.03, 5529.5, 33.48), vector3(-765.04, 5534.85, 33.48), vector3(-764.77, 5545.0, 33.49) }, minZ = 28.0, maxZ = 34.7 },
            accessPoints = { { blip = { name = 'Hunting Job Garage', sprite = 357, color = 5 }, coords = vector4(-755.97, 5539.24, 33.49, 313.18) } }
        },
        tailorjobgarage = {
            label = 'Tailor Job Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vector3(2065.51, 3420.19, 44.42), vector3(2064.98, 3424.51, 44.36), vector3(2066.04, 3431.76, 44.07), vector3(2066.27, 3439.13, 43.92), vector3(2065.33, 3445.41, 43.84), vector3(2063.05, 3450.66, 43.79), vector3(2060.11, 3454.3, 43.76), vector3(2055.73, 3457.31, 43.74), vector3(2051.62, 3459.0, 43.73), vector3(2046.95, 3459.94, 43.74), vector3(2041.45, 3460.06, 43.75), vector3(2037.08, 3458.6, 43.78), vector3(2033.1, 3456.03, 43.82), vector3(2029.66, 3452.59, 43.87), vector3(2026.48, 3447.13, 43.94), vector3(2025.13, 3442.83, 44.02), vector3(2024.0, 3437.26, 44.12), vector3(2023.63, 3432.63, 44.2), vector3(2023.94, 3426.39, 44.3), vector3(2027.36, 3417.29, 44.38), vector3(2032.21, 3421.7, 44.38), vector3(2030.06, 3426.25, 44.32), vector3(2029.24, 3430.96, 44.25), vector3(2029.38, 3437.19, 44.14), vector3(2030.38, 3441.66, 44.05), vector3(2031.71, 3445.45, 43.99), vector3(2034.07, 3449.4, 43.92), vector3(2037.2, 3452.4, 43.88), vector3(2044.16, 3454.42, 43.84), vector3(2052.93, 3452.77, 43.82), vector3(2056.14, 3450.54, 43.85), vector3(2058.64, 3447.85, 43.87), vector3(2060.03, 3444.15, 43.91), vector3(2060.45, 3440.85, 43.95), vector3(2060.4, 3436.73, 44.02), vector3(2060.47, 3432.67, 44.11), vector3(2059.41, 3419.22, 44.44) }, minZ = 39.5, maxZ = 45.8 },
            accessPoints = { { blip = { name = 'Tailor Job Garage', sprite = 357, color = 5 }, coords = vector4(2045.58, 3434.02, 43.98, 321.89) } }
        },
        processtailorgarage = {
            label = 'Process Tailor Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vector3(696.88, -975.85, 24.08), vector3(702.6, -975.93, 24.19), vector3(703.11, -976.57, 24.19), vector3(710.27, -976.63, 24.13), vector3(714.78, -981.26, 24.12), vector3(711.32, -982.13, 24.11), vector3(706.86, -982.22, 24.11), vector3(702.36, -982.19, 24.11) }, minZ = 20.0, maxZ = 26.0 },
            accessPoints = { { blip = { name = 'Process Tailor Garage', sprite = 357, color = 5 }, coords = vector4(706.29, -978.61, 24.14, 12.48) } }
        },
        processoilgarage = {
            label = 'Process Oil Garage',
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vector3(2656.09, 1720.71, 24.49), vector3(2656.59, 1658.38, 24.49), vector3(2676.89, 1658.41, 24.49), vector3(2676.7, 1665.73, 24.49), vector3(2670.58, 1665.5, 24.49), vector3(2670.75, 1676.86, 24.49), vector3(2677.0, 1677.07, 24.49), vector3(2676.57, 1720.89, 24.49) }, minZ = 20.0, maxZ = 26.0 },
            accessPoints = { { blip = { name = 'Process Oil Garage', sprite = 357, color = 5 }, coords = vector4(2665.87, 1688.05, 24.49, 181.98) } }
        },

        -- AIR GARAGES (HANGAR)
        hangarcity = {
            label = 'Hangar City',
            vehicleType = VehicleType.AIR,
            garageZone = { points = { vector3(-971.33, -3045.13, 13.95), vector3(-929.74, -2974.81, 13.95), vector3(-978.36, -2947.0, 13.95), vector3(-1019.85, -3017.03, 13.95) }, minZ = 10.0, maxZ = 16.0 },
            accessPoints = { { blip = { name = 'Hangar City', sprite = 359, color = 5 }, coords = vector4(-971.06, -2997.01, 13.95, 40.86) } }
        },
        hangarsandyshores = {
            label = 'Hangar Sandy Shores',
            vehicleType = VehicleType.AIR,
            garageZone = { points = { vector3(1760.08, 3245.93, 41.79), vector3(1763.88, 3229.89, 42.38), vector3(1780.47, 3233.84, 42.43), vector3(1776.54, 3249.89, 41.95) }, minZ = 39.0, maxZ = 43.0 },
            accessPoints = { { blip = { name = 'Hangar Sandy Shores', sprite = 359, color = 5 }, coords = vector4(1770.59, 3239.86, 42.13, 111.77) } }
        },

        -- SEA GARAGES (MARINE)
        marinecitygarage = {
            label = 'Marine City Garage',
            vehicleType = VehicleType.SEA,
            garageZone = { points = { vector3(-779.99, -1503.44, 1.2), vector3(-784.5, -1491.15, 1.2), vector3(-805.69, -1498.78, -0.47), vector3(-801.94, -1511.41, -0.47) }, minZ = -1.0, maxZ = 5.0 },
            accessPoints = { { blip = { name = 'Marine City Garage', sprite = 356, color = 28 }, coords = vector4(-795.43, -1500.49, -0.47, 104.61) } }
        },

        -- GANG GARAGES
        cartelgarage = {
            label = 'Cartel Garage',
            vehicleType = VehicleType.CAR,
            groups = 'cartel',
            garageZone = { points = { vec3(1416.83, 1122.66, 114.84), vec3(1416.66, 1114.99, 114.84), vec3(1402.7, 1114.72, 114.84), vec3(1402.91, 1122.7, 114.84) }, minZ = 110.0, maxZ = 118.0 },
            accessPoints = { { blip = false, coords = vec4(1410.21, 1118.06, 114.84, 256.73) } }
        },

        -- IMPOUNDS
        citycarimpound = {
            label = 'City Car Impound',
            type = GarageType.DEPOT,
            states = { VehicleState.OUT, VehicleState.IMPOUNDED },
            skipGarageCheck = true,
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vector3(835.49, -1255.32, 26.36), vector3(835.47, -1264.43, 26.32), vector3(840.98, -1265.07, 26.38), vector3(840.87, -1274.63, 26.44), vector3(820.45, -1274.58, 26.39), vector3(820.28, -1268.57, 26.23), vector3(826.5, -1268.63, 26.26), vector3(826.53, -1261.69, 26.27), vector3(820.64, -1261.45, 26.23), vector3(820.95, -1255.19, 26.37) }, minZ = 20.0, maxZ = 27.0 },
            accessPoints = { { blip = { name = 'City Car Impound', sprite = 369, color = 57 }, coords = vector4(830.58, -1265.23, 26.28, 231.98) } }
        },
        sandyshoresimpound = {
            label = 'Sandy Shores Impound',
            type = GarageType.DEPOT,
            states = { VehicleState.OUT, VehicleState.IMPOUNDED },
            skipGarageCheck = true,
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vector3(1067.92, 2661.76, 39.55), vector3(1062.07, 2661.67, 39.56), vector3(1062.35, 2672.9, 39.55), vector3(1067.85, 2672.73, 39.55) }, minZ = 36.0, maxZ = 42.0 },
            accessPoints = { { blip = { name = 'Sandy Shores Impound', sprite = 369, color = 57 }, coords = vector4(1065.11, 2667.3, 39.55, 179.99) } }
        },
        paletocarimpound = {
            label = 'Paleto Car Impound',
            type = GarageType.DEPOT,
            states = { VehicleState.OUT, VehicleState.IMPOUNDED },
            skipGarageCheck = true,
            vehicleType = VehicleType.CAR,
            garageZone = { points = { vector3(-31.2, 6534.95, 31.49), vector3(-63.21, 6566.91, 31.49), vector3(-67.63, 6562.49, 31.49), vector3(-75.35, 6571.33, 31.49), vector3(-88.93, 6559.64, 31.49), vector3(-84.8, 6555.22, 31.49), vector3(-86.84, 6553.95, 31.49), vector3(-87.5, 6555.46, 31.49), vector3(-94.37, 6548.62, 31.49), vector3(-84.88, 6539.05, 31.49), vector3(-78.39, 6545.58, 31.49), vector3(-81.27, 6550.76, 31.49), vector3(-71.04, 6559.9, 31.49), vector3(-40.49, 6530.68, 31.49) }, minZ = 28.0, maxZ = 34.0 },
            accessPoints = { { blip = { name = 'Paleto Car Impound', sprite = 369, color = 57 }, coords = vector4(-66.16, 6550.07, 31.55, 94.13) } }
        },
        hangarcityimpound = {
            label = 'Hangar City Impound',
            type = GarageType.DEPOT,
            states = { VehicleState.OUT, VehicleState.IMPOUNDED },
            skipGarageCheck = true,
            vehicleType = VehicleType.AIR,
            garageZone = { points = { vec3(-1288.48, -3357.65, 12.94), vec3(-1243.72, -3383.52, 12.94), vec3(-1259.54, -3412.04, 12.94), vec3(-1303.81, -3386.14, 12.94) }, minZ = 10.0, maxZ = 26.0 },
            accessPoints = { { blip = { name = 'Hangar City Impound', sprite = 372, color = 57 }, coords = vec4(-1274.85, -3386.66, 12.94, 75.26) } }
        },
        marinecityimpound = {
            label = 'Marine City Impound',
            type = GarageType.DEPOT,
            states = { VehicleState.OUT, VehicleState.IMPOUNDED },
            skipGarageCheck = true,
            vehicleType = VehicleType.SEA,
            garageZone = { points = { vector3(-759.36, -1377.43, 1.6), vector3(-765.38, -1372.28, 1.6), vector3(-772.26, -1379.52, -0.47), vector3(-765.77, -1384.96, -0.47) }, minZ = -1.0, maxZ = 5.0 },
            accessPoints = { { blip = { name = 'Marine City Impound', sprite = 371, color = 57 }, coords = vector4(-764.11, -1377.14, 1.6, 144.91), spawn = vec4(-729.77, -1355.49, 1.19, 142.5) } }
        }
    }
}