GymConfig = {}

-- GYM ZONE (POLYZONE)
GymConfig.Zone = {
    vec2(-1192.25, -1571.85),
    vec2(-1203.33, -1555.88),
    vec2(-1210.89, -1556.79),
    vec2(-1212.45, -1562.11),
    vec2(-1206.35, -1570.87),
    vec2(-1204.61, -1573.19),
    vec2(-1199.31, -1580.91),
    vec2(-1194.82, -1578.04),
    vec2(-1196.58, -1575.09),
    vec2(-1192.22, -1572.01)
}

GymConfig.MinZ = 1.0
GymConfig.MaxZ = 10.0 -- Bagus, cukup lebar biar gak false-exit

-- PROGRESS & COOLDOWN
GymConfig.Cooldown = 1 * 1000     -- 1 detik cooldown antar aktivitas

-- STRESS RELIEF PER GERAKAN (BALANCED)
GymConfig.Activities = {
    pushup = {
        duration = 10 * 1000,      -- 10 detik (gerakan ringan, cepat)
        stressRelief = 6,          -- Kurang stress (ringan)
        emote = "pushup"
    },
    situp = {
        duration = 17 * 1000,      -- 17 detik (gerakan sedang)
        stressRelief = 8,          -- Stress relief sedang
        emote = "situp"
    },
    weights = {
        duration = 26 * 1000,      -- 26 detik (gerakan berat, lama)
        stressRelief = 14,         -- Relief maksimal (berat)
        emote = "weights"
    }
}

-- BLIP
GymConfig.Blip = {
    coords = vec4(-1202.63, -1566.20, 9.91, 214.19),
    sprite = 311,      -- Dumbbell (icon gym)
    scale  = 0.7,        -- Ukuran blip sedang
    colour = 6,        -- Warna hijau terang
    name   = 'Area Gym'
}