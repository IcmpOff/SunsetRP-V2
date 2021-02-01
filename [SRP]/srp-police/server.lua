RegisterServerEvent('srp-policejob:handcuff')
AddEventHandler('srp-policejob:handcuff', function(target)
	TriggerClientEvent('srp-policejob:handcuff', target)
end)

RegisterServerEvent('srp-policejob:drag')
AddEventHandler('srp-policejob:drag', function(target)
	TriggerClientEvent('srp-policejob:drag', target, source)
end)

RegisterServerEvent('srp-policejob:putInVehicle')
AddEventHandler('srp-policejob:putInVehicle', function(target)
	TriggerClientEvent('srp-policejob:putInVehicle', target)
end)

RegisterServerEvent('srp-policejob:OutVehicle')
AddEventHandler('srp-policejob:OutVehicle', function(target)
	TriggerClientEvent('srp-policejob:OutVehicle', target)
end)

RegisterServerEvent('srp-policejob:requestarrest')
AddEventHandler('srp-policejob:requestarrest', function(targetid, playerheading, playerCoords,  playerlocation)
    _source = source
    TriggerClientEvent('srp-policejob:getarrested', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('srp-policejob:doarrested', _source)
end)

RegisterServerEvent('srp-policejob:requestrelease')
AddEventHandler('srp-policejob:requestrelease', function(targetid, playerheading, playerCoords,  playerlocation)
    _source = source
    TriggerClientEvent('srp-policejob:getuncuffed', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('srp-policejob:douncuffing', _source)
end)

RegisterServerEvent('srp-policejob:requesthard')
AddEventHandler('srp-policejob:requesthard', function(targetid, playerheading, playerCoords,  playerlocation)
    _source = source
    TriggerClientEvent('srp-policejob:getarrestedhard', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('srp-policejob:doarrested', _source)
end)

AddEventHandler('playerDropped', function()
	-- Save the source in case we lose it (which happens a lot)
    local _source = source
    local steam = GetPlayerIdentifiers(_source)[1]
    local userData = promise:new()

    exports.ghmattimysql:execute('SELECT uid FROM __users WHERE steam = ?', {steam}, function(data)
        userData:resolve(data)
    end)

    local uid = Citizen.Await(userData)
    local user = exports['srp-base']:getModule("Player")
    local char = user:getCurrentCharacter(uid[1].uid)
	if char.job == 'Police' then
		Citizen.Wait(5000)
        TriggerClientEvent('srp-policejob:updateBlip', -1)
    end
end)

RegisterServerEvent('srp-policejob:spawned')
AddEventHandler('srp-policejob:spawned', function()
	local _source = source
    local steam = GetPlayerIdentifiers(_source)[1]
    local userData = promise:new()

    exports.ghmattimysql:execute('SELECT uid FROM __users WHERE steam = ?', {steam}, function(data)
        userData:resolve(data)
    end)

    local uid = Citizen.Await(userData)
    local user = exports['srp-base']:getModule("Player")
    local char = user:getCurrentCharacter(uid[1].uid)
	if char.job == 'Police' then
		Citizen.Wait(5000)
        TriggerClientEvent('srp-policejob:updateBlip', -1)
    end
end)

RegisterServerEvent('srp-policejob:forceBlip')
AddEventHandler('srp-policejob:forceBlip', function()
	TriggerClientEvent('srp-policejob:updateBlip', -1)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(5000)
		TriggerClientEvent('srp-policejob:updateBlip', -1)
	end
end)