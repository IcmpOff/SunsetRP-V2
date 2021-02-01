RegisterServerEvent('admin:revivePlayer')
AddEventHandler('admin:revivePlayer', function(target)
    if target ~= nil then
        TriggerClientEvent('admin:revivePlayerClient', target)
        TriggerClientEvent('srp-hospital:client:RemoveBleed', target) 
        TriggerClientEvent('srp-hospital:client:ResetLimbs', target)
    end
end)