Config = {}

-- ================================
-- LIST WEAPON YANG BIKIN AUTO-BAN
-- Pakai weapon hash (nama weapon GTA V), tinggal tambah/hapus sesuai kebutuhan
-- ================================
Config.BannedWeapons = {
    [`WEAPON_MINIGUN`]        = true,
    [`WEAPON_RAILGUN`]        = true,
    [`WEAPON_RAILGUNXM3`]     = true,
    [`WEAPON_RPG`]            = true,
    [`WEAPON_GRENADELAUNCHER`] = true,
    [`WEAPON_HOMINGLAUNCHER`] = true,
    [`WEAPON_COMPACTLAUNCHER`] = true,
    [`WEAPON_EMPLAUNCHER`]    = true,
    [`WEAPON_FIREWORK`]       = true,
    [`WEAPON_COMBATMG`]       = true,
    [`WEAPON_COMBATMG_MK2`]   = true,
    [`WEAPON_MG`]             = true,
    [`WEAPON_HEAVYSNIPER`]    = true,
    [`WEAPON_HEAVYSNIPER_MK2`] = true,
    [`WEAPON_RAYPISTOL`]      = true,
    [`WEAPON_RAYCARBINE`]     = true,
    [`WEAPON_RAYMINIGUN`]     = true,
    -- tambahkan weapon lain di sini, format: [`WEAPON_NAME`] = true,
}

-- ================================
-- SIAPA AJA YANG KEBAL / EXEMPTED DARI AUTO-BAN
-- (misal admin lagi testing, atau job tertentu yang emang legal pegang weapon itu)
-- ================================
Config.Exempted = {
    -- exempt berdasarkan identifier spesifik (license, discord, steam, dll)
    Identifiers = {
        ['license2:53f07d145e796c146fc0c0b9f8de3d47313c0f4a'] = true,
    },

    -- exempt berdasarkan job (job.name di morph_junjie)
    Jobs = {
        -- ['police'] = true,
        -- ['admin']  = true,
    },

    -- exempt berdasarkan ACE (morph_junjie pakai ACE, bukan lagi Player.PlayerData.permission)
    -- WAJIB isi persis nama ace yang di-grant di permissions.cfg lo, contoh:
    --   add_ace group.admin admin allow    -> isi 'admin'
    --   add_ace group.mod mod allow        -> isi 'mod'
    --   add_ace group.support support allow -> isi 'support'
    AceNames = {
        --['admin']   = true,
        --['mod']     = true,
        --['support'] = true,
    },
}

-- Interval client mengecek weapon yang lagi dipegang (ms)
Config.CheckInterval = 1500

-- Alasan yang dicatat di ban record (jadi origin/reason untuk ExploitBan)
Config.BanReason = 'Illegal weapon detected'

-- Kalau true, kirim notif ke semua admin online sebelum player kena ban (opsional, butuh morph_junjie:Notify / ACE check)
Config.NotifyAdmins = true