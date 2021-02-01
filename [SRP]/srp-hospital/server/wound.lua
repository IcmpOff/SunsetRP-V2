local playerInjury = {}

function GetCharsInjuries(source)
    return playerInjury[source]
end

RegisterServerEvent('srp-hospital:server:SyncInjuries')
AddEventHandler('srp-hospital:server:SyncInjuries', function(data)
    playerInjury[source] = data
end)