---Job names must be lower case (top level table key)
---@type table<string, Job>
return {
    ['unemployed'] = {
        label = 'Civilian',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Freelancer',
                payment = 5
            },
        },
    },
    ['police'] = {
        label = 'LSPD',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 50
            },
            [1] = {
                name = 'Officer',
                payment = 75
            },
            [2] = {
                name = 'Sergeant',
                payment = 100
            },
            [3] = {
                name = 'Lieutenant',
                payment = 125
            },
            [4] = {
                name = 'Captain',
                payment = 150
            },
            [5] = {
                name = 'Deputy Chief',
                payment = 175
            },
            [6] = {
                name = 'Assistant Chief',
                payment = 200
            },
            [7] = {
                name = 'Chief',
                isboss = true,
                bankAuth = true,
                payment = 225
            },
        },
    },
    ['ambulance'] = {
        label = 'EMS',
        type = 'ems',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 50
            },
            [1] = {
                name = 'Paramedic',
                payment = 75
            },
            [2] = {
                name = 'Doctor',
                payment = 100
            },
            [3] = {
                name = 'Surgeon',
                payment = 125
            },
            [4] = {
                name = 'Senior Surgeon',
                payment = 150
            },
            [5] = {
                name = 'Assistant Director',
                payment = 175
            },
            [6] = {
                name = 'Deputy Chief',
                payment = 200
            },
            [7] = {
                name = 'Chief',
                isboss = true,
                bankAuth = true,
                payment = 225
            },
        },
    },
    ['mechanic'] = {
        label = 'Mechanic',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Recruit',
                payment = 50
            },
            [1] = {
                name = 'Novice',
                payment = 75
            },
            [2] = {
                name = 'Experienced',
                payment = 100
            },
            [3] = {
                name = 'Advanced',
                payment = 125
            },
            [4] = {
                name = 'Specialist',
                payment = 150
            },
            [5] = {
                name = 'Senior Technician',
                payment = 175
            },
            [6] = {
                name = 'Assistant Manager',
                payment = 200
            },
            [7] = {
                name = 'Manager',
                isboss = true,
                bankAuth = true,
                payment = 225
            },
        },
    },
}