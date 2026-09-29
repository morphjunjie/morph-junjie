-- config.lua
-- Config gabungan: 'shared' dipakai bareng client & server, 'client' khusus
-- sisi client, 'server' khusus sisi server. Cara pakai:
--   local cfgFile = require 'morph_wine.config'
--   local config  = setmetatable(cfgFile.client, { __index = cfgFile.shared })
-- (server.lua pakai cfgFile.server dengan pola yang sama)

local shared = {
    grapesNeeded = 10,
    grapeJuicesNeeded = 20,

    -- durasi progress bar, dipakai client buat tampilan DAN server buat
    -- validasi durasi minimum sesi (harus sinkron)
    pickDuration = 9000,
    processDuration = 8000,

    -- berapa lama titik anggur regrow setelah dipetik
    regrowTime = 6 * 60 * 1000, -- 6 menit

    vineyard = {
        coords = vec3(-1928.8, 2059.75, 141.0),
        blipName = 'Vineyard Job',
        blipIcon = 827
    },

    grapeLocations = {
        vec3(-1875.41, 2100.37, 138.86),
        vec3(-1908.69, 2107.48, 131.31),
        vec3(-1866.04, 2112.64, 134.41),
        vec3(-1907.76, 2125.35, 124.03),
        vec3(-1850.31, 2142.95, 122.30),
        vec3(-1888.22, 2164.51, 114.81),
        vec3(-1835.52, 2180.59, 104.88),
        vec3(-1891.98, 2208.35, 94.56),
        vec3(-1720.37, 2182.03, 106.18),
        vec3(-1808.52, 2173.14, 107.63),
        vec3(-1784.22, 2222.80, 92.86),
        vec3(-1889.13, 2250.05, 79.63),
        vec3(-1861.16, 2254.32, 81.04),
        vec3(-1886.75, 2272.45, 70.81),
        vec3(-1845.49, 2274.63, 73.33),
        vec3(-1687.28, 2195.76, 97.87),
        vec3(-1741.18, 2173.22, 114.39),
        vec3(-1743.17, 2141.11, 121.18),
        vec3(-1813.84, 2089.57, 134.21),
        vec3(-1698.71, 2150.65, 110.41),
        vec3(-1868.17, 2158.31, 119.15),
        vec3(-1868.43, 2144.44, 123.61),
        vec3(-1859.97, 2130.32, 128.23),
        vec3(-1887.58, 2119.0, 132.0),
        vec3(-1853.11, 2107.3, 135.36),
        vec3(-1845.39, 2094.13, 139.27),
        vec3(-1833.25, 2100.71, 137.96),
        vec3(-1822.81, 2101.33, 137.09),
        vec3(-1850.23, 2085.62, 139.62),
        vec3(-1838.19, 2087.29, 138.04),
        vec3(-1826.43, 2094.06, 136.58),
        vec3(-1816.5, 2100.13, 135.92),
        vec3(-1798.1, 2110.76, 133.33),
        vec3(-1780.0, 2121.19, 128.93),
        vec3(-1767.79, 2128.46, 125.37),
        vec3(-1755.44, 2135.43, 123.62),
        vec3(-1740.24, 2144.67, 121.34),
        vec3(-1726.04, 2147.07, 118.48),
        vec3(-1740.44, 2139.23, 119.83),
        vec3(-1754.22, 2131.12, 122.25),
        vec3(-1771.91, 2120.72, 126.18),
        vec3(-1785.59, 2112.83, 129.71),
        vec3(-1811.34, 2097.78, 134.69),
        vec3(-1780.01, 2159.81, 118.93),
        vec3(-1791.61, 2159.68, 117.14),
        vec3(-1813.43, 2159.75, 114.42),
        vec3(-1822.41, 2159.58, 113.86),
        vec3(-1809.6, 2164.25, 112.43),
        vec3(-1791.73, 2163.91, 115.14),
        vec3(-1765.54, 2164.21, 119.35),
        vec3(-1738.77, 2164.3, 118.45),
        vec3(-1710.33, 2164.18, 112.6),
        vec3(-1706.59, 2168.87, 110.33),
        vec3(-1764.86, 2168.66, 117.6),
        vec3(-1777.56, 2168.87, 115.75),
        vec3(-1791.94, 2168.64, 112.92),
        vec3(-1781.51, 2168.85, 114.82),
        vec3(-1762.87, 2168.62, 117.6),
        vec3(-1777.41, 2173.12, 114.08),
        vec3(-1801.03, 2173.01, 109.27),
        vec3(-1785.07, 2186.88, 106.6),
        vec3(-1864.62, 2199.42, 102.13),
        vec3(-1879.81, 2201.84, 101.02),
        vec3(-1863.14, 2203.67, 100.09),
        vec3(-1845.11, 2205.06, 94.02),
        vec3(-1866.4, 2208.99, 98.16),
        vec3(-1796.94, 2261.48, 77.75),
        vec3(-1771.63, 2261.58, 81.97),
    }
}

return {
    shared = shared,

    client = {
        debugPoly = false,
        useBlips = true,
        useTarget = true,
        grapeBlipRange = 150.0, -- radius meter
    },

    server = {
        grapeAmount = { min = 15, max = 25 },
        grapeJuiceAmount = { min = 8, max = 15 },
        wineAmount = { min = 10, max = 20 },

        -- radius (meter) buat validasi posisi player
        grapeRadius = 2.5,
        vineyardRadius = 3.0,
    },
}