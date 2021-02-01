local playersHealing = {}

RegisterServerEvent('srp-ambulancejob:revive')
AddEventHandler('srp-ambulancejob:revive', function(data, target)

	if Player.job == 'EMS' then
		xPlayer.addMoney(Config.ReviveReward)
		TriggerClientEvent('admin:revivePlayerClient', target)
	else
	end
end)

RegisterServerEvent('srp-ambulancejob:revivePD')
AddEventHandler('srp-ambulancejob:revivePD', function(data, target)
	local Player = data

	if Player.job == 'Police' then
		TriggerClientEvent('admin:revivePlayerClient', target)
	else
	end
end)

RegisterServerEvent('admin:revivePlayer')
AddEventHandler('admin:revivePlayer', function(target)
	if target ~= nil then
		TriggerClientEvent('admin:revivePlayerClient', target)
		TriggerClientEvent('srp-hospital:client:RemoveBleed', target) 
        TriggerClientEvent('srp-hospital:client:ResetLimbs', target)
	end
end)

RegisterServerEvent('admin:healPlayer')
AddEventHandler('admin:healPlayer', function(target)
	if target ~= nil then
		TriggerClientEvent('srp_basicneeds:healPlayer', target)
	end
end)

RegisterServerEvent('srp-ambulancejob:heal')
AddEventHandler('srp-ambulancejob:heal', function(data, target, type)

	if Player.job == 'EMS' and type == 'small' then
		TriggerClientEvent('srp-ambulancejob:heal', target, type)

		TriggerClientEvent('srp-hospital:client:RemoveBleed', target) 	
	elseif
	Player.job == 'EMS' and type == 'big' then
		TriggerClientEvent('srp-ambulancejob:heal', target, type)
		--TriggerClientEvent('MF_SkeletalSystem:HealBones', target, "all")
		TriggerClientEvent('srp-hospital:client:RemoveBleed', target) 
		TriggerClientEvent('srp-hospital:client:ResetLimbs', target)
	else
	end
end)

RegisterServerEvent('srp-ambulancejob:putInVehicle')
AddEventHandler('srp-ambulancejob:putInVehicle', function(data, target)

	if Player.job == 'EMS' then
		TriggerClientEvent('srp-ambulancejob:putInVehicle', target)
	else
	end
end)

RegisterServerEvent('srp-ambulancejob:pullOutVehicle')
AddEventHandler('srp-ambulancejob:pullOutVehicle', function(data, target)

	if Player.job == 'EMS' then
		TriggerClientEvent('srp-ambulancejob:pullOutVehicle', target)
	end
end)

RegisterServerEvent('srp-ambulancejob:drag')
AddEventHandler('srp-ambulancejob:drag', function(data, target)
	_source = source
	if Player.job == 'EMS' then
		TriggerClientEvent('srp-ambulancejob:drag', target, _source)
	else
	end
end)

RegisterServerEvent('srp-ambulancejob:undrag')
AddEventHandler('srp-ambulancejob:undrag', function(data, target)
	_source = source
	if Player.job == 'EMS' then
		TriggerClientEvent('srp-ambulancejob:un_drag', target, _source)
	else
	end
end)

function getPriceFromHash(hashKey, jobGrade, type)
	if type == 'helicopter' then
		local vehicles = Config.AuthorizedHelicopters[jobGrade]

		for k,v in ipairs(vehicles) do
			if GetHashKey(v.model) == hashKey then
				return v.price
			end
		end
	elseif type == 'car' then
		local vehicles = Config.AuthorizedVehicles[jobGrade]

		for k,v in ipairs(vehicles) do
			if GetHashKey(v.model) == hashKey then
				return v.price
			end
		end
	end

	return 0
end

RegisterServerEvent('srp-ambulancejob:drag')
AddEventHandler('srp-ambulancejob:drag', function(target)
	TriggerClientEvent('srp-ambulancejob:drag', target, source)
end)



