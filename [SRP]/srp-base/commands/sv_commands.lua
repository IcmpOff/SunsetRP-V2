RegisterNetEvent('srp-base:setRank')
AddEventHandler('srp-base:setRank', function(target, rank)
    local source = source
    if target ~= nil then
        TriggerClientEvent('srp-base:setRank', target, rank)
    end
end)
        
RegisterNetEvent('srp-base:setJob')
AddEventHandler('srp-base:setJob', function(target, job)
    local source = source
    if target ~= nil then
        TriggerClientEvent('srp-base:setJob', target, job)
    end
end)