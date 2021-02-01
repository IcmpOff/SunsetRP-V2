SRP.Events = SRP.Events or {}
SRP.Events.Total = 0
SRP.Events.Active = {}

function SRP.Events.Trigger(self, event, args, callback)
    local id = SRP.Events.Total + 1
    SRP.Events.Total = id

    id = event .. ":" .. id

    if SRP.Events.Active[id] then return end

    SRP.Events.Active[id] = {cb = callback}
    
    --TriggerServerEvent("np-events:listenEvent", id, event, args)
end

RegisterNetEvent("np-events:listenEvent")
AddEventHandler("np-events:listenEvent", function(id, data)
    local ev = SRP.Events.Active[id]
    
    if ev then
        ev.cb(data)
        SRP.Events.Active[id] = nil
    end
end)