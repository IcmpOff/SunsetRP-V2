function SRP.Core.Initialize(self)
    Citizen.CreateThread(function()
        while true do
            if NetworkIsSessionStarted() then
                TriggerEvent("srp-base:playerSessionStarted")
                --TriggerServerEvent("srp-base:playerSessionStarted")
                break
            end
        end
    end)
end
SRP.Core:Initialize()

AddEventHandler("srp-base:playerSessionStarted", function()
    SRP.SpawnManager:Initialize()
end)

RegisterNetEvent("srp-base:waitForExports")
AddEventHandler("srp-base:waitForExports", function()
    if not SRP.Core.ExportsReady then return end

    while true do
        Citizen.Wait(0)
        if exports and exports["srp-base"] then
            TriggerEvent("srp-base:exportsReady")
            return
        end
    end
end)
 
function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            players[#players+1]= i
        end
    end

    return players
end

RegisterNetEvent("customNotification")
AddEventHandler("customNotification", function(msg, length, type)

	TriggerEvent("chatMessage","SYSTEM",4,msg)
end)