local chicken = vehicleBaseRepairCost

RegisterServerEvent('srp-bennys:attemptPurchase')
AddEventHandler('srp-bennys:attemptPurchase', function(cid, cash, type, upgradeLevel)
    local source = source
    if type == "repair" then
        if cash >= chicken then
            TriggerClientEvent('srp-bennys:purchaseSuccessful', source, chicken)
        else
            TriggerClientEvent('srp-bennys:purchaseFailed', source)
        end
    elseif type == "performance" then
        if cash >= vehicleCustomisationPrices[type].prices[upgradeLevel] then
            TriggerClientEvent('srp-bennys:purchaseSuccessful', source, vehicleCustomisationPrices[type].prices[upgradeLevel])
        else
            TriggerClientEvent('srp-bennys:purchaseFailed', source)
        end
    else
        if cash >= vehicleCustomisationPrices[type].price then
            TriggerClientEvent('srp-bennys:purchaseSuccessful', source, vehicleCustomisationPrices[type].price)
        else
            TriggerClientEvent('srp-bennys:purchaseFailed', source)
        end
    end
end)

RegisterServerEvent('srp-bennys:updateRepairCost')
AddEventHandler('srp-bennys:updateRepairCost', function(cost)
    chicken = cost
end)

RegisterServerEvent('updateVehicle')
AddEventHandler('updateVehicle', function(myCar)
    exports.ghmattimysql:execute('UPDATE `__vehicles` SET `vehicle` = @vehicle WHERE `plate` = @plate',
	{
		['@plate']   = myCar.plate,
		['@vehicle'] = json.encode(myCar)
	})
end)