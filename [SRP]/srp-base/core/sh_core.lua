SRP.Core = SRP.Core or {}

function SRP.Core.ConsoleLog(self, msg, mod)
    if not tostring(msg) then return end
    if not tostring(mod) then mod = "No Module" end
    
    local pMsg = string.format("[SRP LOG - %s] %s", mod, msg)
    if not pMsg then return end

    print(pMsg)
end

RegisterNetEvent("srp-base:consoleLog")
AddEventHandler("srp-base:consoleLog", function(msg, mod)
    SRP.Core:ConsoleLog(msg, mod)
end)

function getModule(module)
    if not SRP[module] then print("Warning: '" .. tostring(module) .. "' module doesn't exist") return false end
    return SRP[module]
end

function addModule(module, tbl)
    if SRP[module] then print("Warning: '" .. tostring(module) .. "' module is being overridden") end
    SRP[module] = tbl
end

SRP.Core.ExportsReady = false

function SRP.Core.WaitForExports(self)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if exports and exports["srp-base"] then
                TriggerEvent("srp-base:exportsReady")
                SRP.Core.ExportsReady = true
                return
            end
        end
    end)
end

SRP.Core:WaitForExports()