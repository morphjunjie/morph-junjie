Framework.Core(Framework)

local readyPlayers = {}
local createGate = {}
local deleteList = require("server.list.deletelist")

local function deleteCharacterForPlayer(src, citizenid)
  local id1, id2 = Framework:GetIdentifier(src)
  if not id1 then
    return
  end
  local license2 = GetPlayerIdentifierByType(src, "license2")
  local cmp = license2 or id2
  if not license2 then
    cmp = id1
  end
  local dbLicense = MySQL.scalar.await("SELECT license FROM players WHERE citizenid = ? LIMIT 1", { citizenid })
  if id1 == dbLicense or cmp == dbLicense then
    local qShowTable = "SHOW TABLES LIKE ?"
    local qShowColumnFmt = "SHOW COLUMNS FROM %s LIKE ?"
    local qDeleteFmt = "DELETE FROM %s WHERE %s = ?"
    local queries = {}
    for i = 1, #deleteList, 1 do
      local item = deleteList[i]
      local tableExists = MySQL.scalar.await(qShowTable, { item.table })
      if tableExists == item.table then
        local colExists = MySQL.scalar.await(string.format(qShowColumnFmt, item.table), { item.column })
        if colExists then
          local key = item.type
          key = citizenid or key
          if key ~= "citizenid" or not citizenid then
            key = GetPlayerIdentifierByType(src, item.type)
          end
          table.insert(queries, {
            query = string.format(qDeleteFmt, item.table, item.column),
            values = { key }
          })
        else
          Debug("Column " .. item.column .. " does not exist in table " .. item.table)
        end
      else
        Debug("Table " .. item.table .. " does not exist.")
      end
    end
    if #queries > 0 then
      local ok = MySQL.transaction.await(queries)
      if ok then
        TriggerClientEvent("qb-multicharacter:client:chooseChar", src)
        Debug("Character Deleted" .. citizenid)
        AddLogs(src, "[DELETE]", "Character Deleted | CitizenID: " .. citizenid, "red", "deletecharacter")
      end
    end
  else
    AddLogs(src, "[EXPLOIT!!!!]", "User tried to delete character that does not belong to him", "red", "exploit")
    SetTimeout(5000, function()
      DropPlayer(src, "Exploit Attempt 2")
    end)
  end
end

lib.callback.register("morph_mchar:server:GetCharacters", function(src)
  if not src then
    return
  end
  local out = {}
  local totalSlots = GetNumberCharactersSlot(src)
  local rows = Framework:GetPlayerQuery(src)
  local first = rows[1]
  if nil ~= first then
    for i = 1, #rows, 1 do
      rows[i].charinfo = json.decode(rows[i].charinfo)
      rows[i].money = json.decode(rows[i].money)
      rows[i].job = json.decode(rows[i].job)
      local cid = rows[i].cid or tonumber(rows[i].charinfo.cid)
      out[cid] = rows[i]
    end
    Debug("Characters loaded for " .. GetPlayerName(src) .. " (" .. src .. ")")
    return out, totalSlots
  else
    Debug("Not Characters Data | New Player")
    return nil, Config.DefaultSlots
  end
end)

lib.callback.register("morph_mchar:server:loadUserData", function(src, data)
  if not src then
    return
  end
  local player = src
  local ok = Framework:Login(player, data.citizenid)
  if ok then
    repeat
      Wait(10)
    until readyPlayers[player]
    print("^2[PLAY GAME]^7 " .. GetPlayerName(player) .. " (Citizen ID: " .. data.citizenid .. ") user has joined the server ")
    Framework:RefreshCommand(player)
    loadHouseData(player)
    GetCharacterReadySpawnUI(player, data)
    SetPlayerRoutingBucket(player, 0)
    AddLogs(player, "[PLAY GAME]", "User has joined the server | CitizenID: " .. data.citizenid, "green", "playgame")
  end
end)

lib.callback.register("morph_mchar:server:createCharacter", function(src, payload)
  if not src then
    return
  end
  local gate = createGate[src]
  if not gate then
    AddLogs(src, "[EXPLOIT!!!!]", "User using cheats!!!!!", "red", "exploit")
    DropPlayer(src, "Exploit Attempt 3")
    return
  end
  createGate[src] = nil
  local player = src
  local char = { cid = payload.cid, charinfo = payload }
  local ok = Framework:Login(player, false, char)
  if ok then
    repeat
      Wait(10)
    until readyPlayers[player]
    print("^2[CREATE CHARACTER]^7 " .. GetPlayerName(player) .. " User has created new character")
    Framework:RefreshCommand(player)
    loadHouseData(player)
    GetApartmentInsideStartSpawnUI(player, char)
    GiveStarterItems(player)
    SetPlayerRoutingBucket(player, 0)
  end
  AddLogs(player, "[CREATE]", "User has created new character | Name: " .. (payload and payload.firstname) .. " | " .. (payload and payload.lastname), "purple", "createcharacter")
end)

lib.callback.register("morph_mchar:server:deleteCharacter", function(src, citizenid)
  if not src or not citizenid then
    return
  end
  deleteCharacterForPlayer(src, citizenid)
end)

RegisterNetEvent("morph_mchar:server:disconnect", function()
  DropPlayer(source, "Multicharacter Disconnect")
end)

AddEventHandler(Framework.Events.loadedSP, function(data)
  Wait(1000)
  local s = data.PlayerData.source
  readyPlayers[s] = true
end)

AddEventHandler(Framework.Events.unload, function(src)
  readyPlayers[src] = false
end)

local dobLowest = Config.Dob.Lowest
local dobHighest = Config.Dob.Highest
local dobNotify = Config.Dob.Notify

local function hasInvalidChars(s)
  return string.find(s, "[\"'%;%=%*]")
end

lib.callback.register("morph_mchar:callback:inputCheck", function(src, payload)
  if not src or not payload then
    return
  end

  local yearStr = payload.birthdate:match("^(%d%d%d%d)")
  local y = tonumber(yearStr)

  if not y then
      TriggerClientEvent("morph_ui:notify", src, { title = dobNotify.invalid:format(yearStr or "null"), type = "error" })
      return false
  end

  if (y < dobLowest) or (y > dobHighest) then
      TriggerClientEvent("morph_ui:notify", src, { title = dobNotify.invalid:format(yearStr), type = "error" })
      return false
  end

  local fields = { payload.cid, payload.gender, payload.firstname, payload.lastname, payload.nationality, payload.birthdate }
  for i = 1, #fields do
      local v = fields[i]
      if not v then
          TriggerClientEvent("morph_ui:notify", src, { title = dobNotify.invalid:format("null"), type = "error" })
          return false
      end
      if hasInvalidChars(v) then
          TriggerClientEvent("morph_ui:notify", src, { title = dobNotify.exploit:format(v), type = "error" })
          return false
      end
  end

  if not createGate[src] then
    createGate[src] = true
  end

  return true
end)
