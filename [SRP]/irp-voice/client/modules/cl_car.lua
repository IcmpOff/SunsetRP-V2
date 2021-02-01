_inVeh = false
_currentvehicle = nil
local _passengers = {}

function LoadCarModule()

    RegisterModuleContext("car", 0)
    UpdateContextVolume("car", -1.0)

    AddEventHandler('baseevents:enteredVehicle',function(currentVehicle, currentSeat, vehicle_name, netId)
        _inVeh = true
        _currentvehicle = currentVehicle
        UpdateContextVolume("car", 1.0)
        startVehThread()
    end)
    
    AddEventHandler('baseevents:leftVehicle',function(leftVehicle, netId)
        _inVeh = false
        _currentvehicle = nil
        _passengers = {}
        UpdateContextVolume("car", -1.0)
    end)
end

function startVehThread()
    while _inVeh do
        local passengerCount, passengers = GetVehiclePassengers(_currentvehicle)
        local passengerID 

        for k, v in pairs(_passengers) do
            if not passengers[v] then
                print("Passenger removed: ".. k) 
                RemovePlayerFromTargetList(k, "car", false, true)
                MumbleSetVolumeOverrideByServerId(k, -1.0)
                 _passengers[k] = nil
            end
        end

        for passenger, _ in pairs(passengers) do
            passengerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed((passenger)))
            if not _passengers[passengerID] and passengerID ~= _myServerId and passengerID ~= 0 then
                print("Passenger added: " .. passengerID)
                AddPlayerToTargetList(passengerID, "car", false)
                MumbleSetVolumeOverrideByServerId(passengerID, 0.8)
                _passengers[passengerID] = passenger
            end
        end

        Citizen.Wait(1000)
    end
end

RegisterCommand("getp", function()
    local passengerCount, passengers = GetVehiclePassengers(_currentvehicle)
    print(DumpTable(passengers))
    --print(DumpTable(GetVehiclePassengers(_currentvehicle)))
end)

function GetVehiclePassengers(vehicle)
	local passengers = {}
	local passengerCount = 0
	local seatCount = GetVehicleNumberOfPassengers(vehicle)

	for seat = -1, seatCount do
		if not IsVehicleSeatFree(vehicle, seat) then
			passengers[GetPedInVehicleSeat(vehicle, seat)] = true
			passengerCount = passengerCount + 1
		end
	end

	return passengerCount, passengers
end