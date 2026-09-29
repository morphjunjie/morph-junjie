return {
    Framework = 'qbx',
    -- Jobs allowed to create bills
    AllowedJobs = {
        ["police"] = true,
        ["ambulance"] = true,
        ["mechanic"] = true,
    },
    -- Default invoices per job
    DefaultInvoices = {
        ["police"] = {
            {description = "Speeding Fine", amount = 500},
            {description = "Parking Fine", amount = 300},
            {description = "Serious Offense", amount = 1000},
        },
        ["ambulance"] = {
            {description = "Medical Service", amount = 750},
            {description = "Emergency Transport", amount = 1200},
        },
        ["mechanic"] = {
            {description = "Vehicle Repair", amount = 1500},
            {description = "Parts Replacement", amount = 800},
        },
    },
    -- Maximum invoice amount if custom
    MaxAmount = 100000 -- 100k max
}