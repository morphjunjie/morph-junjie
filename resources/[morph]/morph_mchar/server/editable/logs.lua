local selectedLogger = Config.Logs.Logger or 'discord'

---@param src string
---@param type string
---@param message string
---@param color? string
---@param webhook? string
function AddLogs(src, type, message, color, webhook)
    if not Config.Logs.Status then return end

    if not src then return end

    if selectedLogger == 'discord' then
        DiscordWebHook(src, type, message, color, webhook)
        return
    end

    lib.logger(src, type, message)
end
