RegisterServerEvent('srp-interactions:putInVehicle')
AddEventHandler('srp-interactions:putInVehicle', function(target)
    TriggerClientEvent('srp-interactions:putInVehicle', target)
end)

RegisterServerEvent('srp-interactions:outOfVehicle')
AddEventHandler('srp-interactions:outOfVehicle', function(target)
    TriggerClientEvent('srp-interactions:outOfVehicle', target)
end)

RegisterServerEvent('srp-policejob:drag')
AddEventHandler('srp-policejob:drag', function(target)
    local src = source
	TriggerClientEvent('srp-policejob:drag', target, src)
end)
