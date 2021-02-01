function PlayRemoteRadioClick(transmitting)
    if transmitting and Config.settings.remoteClickOn or not transmitting and Config.settings.remoteClickOff then
        SendNUIMessage({ type = 'remoteClick', state = transmitting})
    end
end

function PlayLocalRadioClick(transmitting)
    -- print("TEST")
    -- print(transmitting)
    -- print(Config.settings.localClickOn)
    if transmitting and Config.settings.localClickOn or not transmitting and Config.settings.localClickOff then
        --print("2")
        SendNUIMessage({ type = 'localClick', state = transmitting})
        TriggerEvent("hud:voice:transmitting", transmitting)
    end
end

function UpdateRadioPowerState(state)
    SendNUIMessage({ type = 'radioPowerState', state = state })
end
