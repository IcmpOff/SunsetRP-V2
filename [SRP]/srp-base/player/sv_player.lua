SRP.Player = SRP.Player or {}
SRP.Player.Characters = SRP.Player.Characters or {}
SRP.LocalPlayer = SRP.LocalPlayer or {}



local function GetUser()
    return SRP.Player
end

function SRP.Player.InsertCharacter(self, data)
    if not data then return end

    table.insert(SRP.Player.Characters, data)

end

function SRP.Player.RemoveCharacter(self, uid)
    if not uid then return end

    for k, v in pairs(SRP.Player.Characters) do
        if v.uid == uid then table.remove(SRP.Player.Characters, k) end
    end

end

function SRP.Player.setVar(self, var, data)
    GetUser()[var] = data
end

function SRP.Player.getVar(self, var)
    return GetUser()[var]
end

function SRP.Player.getCurrentCharacter(self, uid)
    for k, v in pairs(SRP.Player.Characters) do
        if v.uid == uid then return v end
    end
end

local function getUserId(source)
    src = srouce 
end

function SRP.Player.setCurrentCharacter(self, data, source)
    local _src = source
    if not data then return end
    GetUser():setVar("character", data)
    GetUser():setVar("source", _src)
end

function SRP.Player.getCharacterFromCid(self, cid)
    for k, v in pairs(SRP.Player.Characters) do
        if v.id == cid then return v, k end
    end
end

function SRP.Player.getCharacterNameFromSource(self, source)
    for k, v in pairs(SRP.Player.Characters) do
        if v.playerSrc == tonumber(source) then return v.first_name, v.last_name, v.id end
    end
end

RegisterNetEvent('srp-base:updateJobLogs')
AddEventHandler('srp-base:updateJobLogs', function(tSource, nRank, jId)
    print('dick')
    local tSource = tSource

    local tFirstName, tLastName, tCid = SRP.Player:getCharacterNameFromSource(tSource)

    print(tFirstName, tLastName, tCid)

    if not tFirstName or not tLastName then return end

    exports.ghmattimysql:execute('INSERT INTO __employees VALUES(?, ?, ?, ?, ?)', {tCid, tFirstName .. ' ' .. tLastName, 'Government', nRank, jId})

    TriggerClientEvent("DoLongHudText", tSource, "You have been apointed a new job.", 1)

end)

RegisterNetEvent('srp-base:updateCharacterBank')
AddEventHandler('srp-base:updateCharacterBank', function(nBank, uCid, tStatus, cAmount)
    local tCharacter, tCharacterIndex = SRP.Player:getCharacterFromCid(tonumber(uCid))

    if not tCharacter then return end

    local cSource = tCharacter.playerSrc

    TriggerClientEvent('srp-phone:groupManageUpdateBank', cSource, uCid, nBank)
    if tStatus then
        TriggerClientEvent('banking:addBalance', cSource, cAmount)
    else
        TriggerClientEvent('banking:removeBalance', cSource, cAmount)
    end

end)

RegisterNetEvent('srp-base:setServerCharacter')
AddEventHandler('srp-base:setServerCharacter', function(data)

    local source = source
    data['playerSrc'] = source

    print(json.encode(data))
    local character = data
    local _src = source
    SRP.Player:InsertCharacter(data)

    exports.ghmattimysql:execute('SELECT * FROM __emotes WHERE cid= ?', {data.id}, function(result)
        if result[1] ~= nil then
            TriggerClientEvent('emote:setEmotesFromDB', _src, result[1].emote_data)
        end
    end)

end)

RegisterServerEvent('player:setJob')
AddEventHandler('player:setJob', function(cid, job)

    local src = source

    exports.ghmattimysql:execute('UPDATE __characters SET job= ? WHERE id= ?', {job, cid})
end)

RegisterServerEvent('player:setRank')
AddEventHandler('player:setRank', function(cid, rank)

    local src = source

    exports.ghmattimysql:execute('UPDATE __characters SET `rank`= ? WHERE `id`= ?', {tonumber(rank), cid})
end)

RegisterServerEvent('player:removeCash')
AddEventHandler('player:removeCash', function(cid, amount)

    local src = source

    exports.ghmattimysql:execute('UPDATE __characters SET cash= ? WHERE id= ?', {amount, cid})
end)

RegisterServerEvent('player:addCash')
AddEventHandler('player:addCash', function(cid, amount)

    local src = source

    exports.ghmattimysql:execute('UPDATE __characters SET cash= ? WHERE id= ?', {amount, cid})
end)

RegisterServerEvent('player:setCash')
AddEventHandler('player:setCash', function(cid, amount)

    local src = source

    exports.ghmattimysql:execute('UPDATE __characters SET cash= ? WHERE id= ?', {amount, cid})
end)

RegisterServerEvent('player:removeBank')
AddEventHandler('player:removeBank', function(cid, amount)

    local src = source

    exports.ghmattimysql:execute('UPDATE __characters SET bank= ? WHERE id= ?', {amount, cid})
end)

RegisterServerEvent('player:addBank')
AddEventHandler('player:addBank', function(cid, amount)

    local src = source

    exports.ghmattimysql:execute('UPDATE __characters SET bank= ? WHERE id= ?', {amount, cid})
end)

RegisterServerEvent('player:setBank')
AddEventHandler('player:setBank', function(cid, amount)

    local src = source

    exports.ghmattimysql:execute('UPDATE __characters SET bank= ? WHERE id= ?', {amount, cid})
end)

RegisterServerEvent('player:setServerMeta')
AddEventHandler('player:setServerMeta', function(armor, thirst, hunger)

    local src = source
    local steam = GetPlayerIdentifiers(src)[1]
    local userData = promise:new()

    exports.ghmattimysql:execute('SELECT uid FROM __users WHERE steam = ?', {steam}, function(data)
        userData:resolve(data)
    end)

    local uid = Citizen.Await(userData)
    local user = SRP.Player
    local char = user:getCurrentCharacter(uid[1].uid)
    local characterId = char.id

    exports.ghmattimysql:execute('UPDATE __characters SET armor= ?, water= ?, food= ? WHERE id= ?', {armor, thirst, hunger, characterId})
end)

AddEventHandler("onResourceStart", function(resourceName)
	if ("srp-base" == resourceName) then
        SRP.Player.Characters = {}
    end
end)

AddEventHandler('playerDropped', function (reason)
    local source = source
    local steam = GetPlayerIdentifiers(source)[1]

    print('\27[32m[srp-base]\27[0m: Saved ' .. GetPlayerName(source) .. ' |  Disconnected (Reason: ' .. reason .. ')')

    local userData = promise:new()

    exports.ghmattimysql:execute('SELECT uid FROM __users WHERE steam = ?', {steam}, function(data)
        userData:resolve(data)
    end)
    TriggerClientEvent('hud:saveCurrentMeta', source)

    local uid = Citizen.Await(userData)
    Citizen.Wait(2500)
    SRP.Player:RemoveCharacter(tonumber(uid[1].uid))
end)

RegisterServerEvent('server:GroupPayment')
AddEventHandler('server:GroupPayment', function(job, amount)
    TriggerClientEvent('client:GroupPayment', -1, job, amount)
end)