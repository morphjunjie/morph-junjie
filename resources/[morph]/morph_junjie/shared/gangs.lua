---Gang names must be lower case (top level table key)
---@type table<string, Gang>
return {
    ['none'] = { label = 'No Gang', grades = { [0] = { name = 'Unaffiliated' } } },
    ['lostmc'] = { label = 'The Lost MC', grades = {
        [0] = { name = 'Recruit' }, [1] = { name = 'Enforcer' }, [2] = { name = 'Shot Caller' }, [3] = { name = 'Boss', isboss = true, bankAuth = true }
    } },
    ['ballas'] = { label = 'Ballas', grades = {
        [0] = { name = 'Recruit' }, [1] = { name = 'Enforcer' }, [2] = { name = 'Shot Caller' }, [3] = { name = 'Boss', isboss = true, bankAuth = true }
    } },
    ['vagos'] = { label = 'Vagos', grades = {
        [0] = { name = 'Recruit' }, [1] = { name = 'Enforcer' }, [2] = { name = 'Shot Caller' }, [3] = { name = 'Boss', isboss = true, bankAuth = true }
    } },
    ['hightables'] = { label = 'High Tables', grades = {
        [0] = { name = 'Street Rat' }, [1] = { name = 'Lookout' }, [2] = { name = 'Runner' }, [3] = { name = 'Bagman' }, [4] = { name = 'Earner' },
        [5] = { name = 'Made Man' }, [6] = { name = 'Soldier' }, [7] = { name = 'Veteran Soldier' }, [8] = { name = 'Enforcer' }, [9] = { name = 'Hitman' },
        [10] = { name = 'Crew Chief' }, [11] = { name = 'Skipper' }, [12] = { name = 'Caporegime' }, [13] = { name = 'Senior Capo' }, [14] = { name = 'Street Boss' },
        [15] = { name = 'Lieutenant' }, [16] = { name = 'Captain' }, [17] = { name = 'Major' }, [18] = { name = 'Underboss' }, [19] = { name = 'Consigliere', bankAuth = true },
        [20] = { name = 'Sottocapo' }, [21] = { name = 'Don', bankAuth = true }, [22] = { name = 'High Table Member' }, [23] = { name = 'High Table Elder' }, [24] = { name = 'The Godfather', isboss = true, bankAuth = true }
    } },
    ['cartel'] = { label = 'Cartel', grades = {
        [0] = { name = 'Recruit' }, [1] = { name = 'Enforcer' }, [2] = { name = 'Shot Caller' }, [3] = { name = 'Boss', isboss = true, bankAuth = true }
    } },
    ['families'] = { label = 'Families', grades = {
        [0] = { name = 'Recruit' }, [1] = { name = 'Enforcer' }, [2] = { name = 'Shot Caller' }, [3] = { name = 'Boss', isboss = true, bankAuth = true }
    } },
    ['triads'] = { label = 'Triads', grades = {
        [0] = { name = 'Recruit' }, [1] = { name = 'Enforcer' }, [2] = { name = 'Shot Caller' }, [3] = { name = 'Boss', isboss = true, bankAuth = true }
    } }
}