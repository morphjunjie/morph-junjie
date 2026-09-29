local Config = lib.require('morph_bill.shared.config')
local Framework = lib.require('morph_bill.bridge.cl_bridge')


RegisterCommand('bill', function()
    local player = Framework.PlayerData()
    local job = Framework.PlayerJob(player)
    local JobName = job.name

    if not Config.AllowedJobs[JobName] then
        return lib.notify({type = 'error', description = 'You cannot send bills'})
    end

    -- Show inputDialog
    local response = lib.inputDialog('Send Bill', {
        { 
            type = 'input', 
            label = 'Player ID', 
            placeholder = 'Enter target player ID', 
            required = true,
            icon = 'fa-solid fa-user'
        },
        { 
            type = 'select', 
            label = 'Account', 
            required = true, 
            icon = 'fa-solid fa-wallet', 
            options = {
                { value = 'cash', label = 'Cash' },
                { value = 'bank', label = 'Bank' },
            }
        },
        { 
            type = "number", 
            label = "Amount", 
            icon = 'fa-solid fa-hand-holding-dollar', 
            placeholder = "$", 
            min = 1, 
            required = true   
        },
        { 
            type = "input", 
            label = "Description", 
            icon = 'fa-solid fa-file-invoice', 
            placeholder = "Enter description for the bill", 
            required = true
        }
    })

    if not response then return end

    local targetId = tonumber(response[1])
    local accountType = response[2]
    local amount = tonumber(response[3])
    local description = response[4] or "Service Fee"

    if not targetId or targetId <= 0 then
        return lib.notify({type = 'error', description = 'Invalid Player ID'})
    end
    TriggerServerEvent('billing:addBill' , targetId, amount, description, accountType)
end)


RegisterCommand('mybill', function()
    local bills = lib.callback.await('billing:getMyBills')
    if not bills or #bills == 0 then
        return lib.notify({ type = 'info', description = 'You have no bills' })
    end

    local options = {}

    for _, bill in ipairs(bills) do
        local paid = bill.paid == true or bill.paid == 1

        table.insert(options, {
            title = string.format(
                "%s %s - $%s",
                paid and "[PAID]" or "[UNPAID]",
                bill.description or "No description",
                bill.amount or 0
            ),
            description = string.format(
                "From: %s | Account: %s",
                bill.sender or "Unknown",
                bill.account or "bank"
            ),
            icon = paid and 'fa-solid fa-check' or 'fa-solid fa-file-invoice-dollar',
            disabled = paid,
            args = bill.id,
            onSelect = function(data)
                print(json.encode(data))
                TriggerServerEvent('billing:payBill', bill.id , bill.amount , bill.account , bill.job)
            end
        })
    end

    lib.registerContext({
        id = 'mybills_menu',
        title = 'My Bills',
        canClose = true,
        options = options
    })

    lib.showContext('mybills_menu')
end)
