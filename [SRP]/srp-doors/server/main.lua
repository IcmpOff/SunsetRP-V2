local DoorInfo	= {}

RegisterServerEvent('srp-doors:updateState')
AddEventHandler('srp-doors:updateState', function(doorID, state)
	if type(doorID) ~= 'number' then
		return
	end
	-- make each door a table, and clean it when toggled
	DoorInfo[doorID] = {}

	-- assign information
	DoorInfo[doorID].state = state
	DoorInfo[doorID].doorID = doorID

	TriggerClientEvent('srp-doors:setState', -1, doorID, state)
end)

RegisterServerEvent("srp-doors:jailbreak")
AddEventHandler("srp-doors:jailbreak", function()
    local _source = source
	TriggerClientEvent('srp-alerts:jailinProgress', -1)
	TriggerClientEvent('srp-doors:UseRedKeycard2',source)
end)

RegisterServerEvent("srp-doors:jailbreak2")
AddEventHandler("srp-doors:jailbreak2", function()
    local _source = source
	TriggerClientEvent('srp-doors:UseRedKeycard3',source)
end)

RegisterServerEvent("srp-doors:jailbreak3")
AddEventHandler("srp-doors:jailbreak3", function()
    local _source = source
	TriggerClientEvent('srp-doors:UseRedKeycard4',source)
end)

RegisterServerEvent('srp-doors:getDoorInfo')
AddEventHandler('srp-doors:getDoorInfo', function()
	local src = source
	TriggerClientEvent('srp-doors:getDoorInfo', src, DoorInfo, #DoorInfo)
end)

function IsAuthorized(jobName, doorID)
	for i=1, #doorID.authorizedJobs, 1 do
		if doorID.authorizedJobs[i] == jobName then
			return true
		end
	end

	return false
end