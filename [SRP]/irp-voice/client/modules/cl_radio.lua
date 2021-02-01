RadioChannels, IsRadioOn, IsTalkingOnRadio, RadioVolume, CurrentChannel = {}, false, false, Config.settings.radioVolume

local function AddRadioSubscriber(radioID, serverID)
    if not RadioChannels[radioID] then return end

    local channel = RadioChannels[radioID]

    -- print("sub data")
    -- print(radioID)
    -- print(serverID)
    if not channel:subscriberExists(serverID) then
        channel:addSubscriber(serverID)

        --print("ADDED SUB")
        if CurrentChannel.id == radioID then  --IsTalkingOnRadio and
            AddPlayerToTargetList(serverID, "radio", true)
        end

        Debug("[Radio] Subscriber Added | Radio ID: %s | Player: %s ", radioID, serverID)
    end
end


local function RemoveRadioSubscriber(radioID, serverID)
    if not RadioChannels[radioID] then return end

    local channel = RadioChannels[radioID]

    if channel:subscriberExists(serverID) then
        channel:removeSubscriber(serverID)

        if CurrentChannel.id == radioID then --IsTalkingOnRadio and
            RemovePlayerFromTargetList(serverID, "radio", true, true)
        end

        Debug("[Radio] Subscriber Removed | Radio ID: %s | Player: %s ", radioID, serverID)
    end
end


local function ConnectToRadio (radioID, subscribers)
    if RadioChannels[radioID] then return end

    local channel = RadioChannel:new(radioID)

    print(DumpTable(subscribers))
    for _, subscriber in pairs(subscribers) do
        channel:addSubscriber(subscriber)
    end

    RadioChannels[radioID] = channel

    SetRadioChannel(radioID)

    -- for _, subscriber in pairs(subscribers) do
    --     AddRadioSubscriber(radioID, subscriber)
    -- end

    Debug("[Radio] Connected | Radio ID: %s", radioID)
end

local function DisconnectFromRadio (radioID)
    if not RadioChannels[radioID] then return end

    RadioChannels[radioID] = nil

    -- for _, subscriber in pairs(CurrentChannel.subscribers) do
    --     RemoveRadioSubscriber(radioID, subscriber)
    -- end

    if CurrentChannel.id == radioID then
        CycleRadioChannels()
    end

    Debug("[Radio] Disconnected | ID %s", radioID)
end

function SetRadioChannel(radioID)
    CurrentChannel = RadioChannels[radioID]

    Debug("[Radio] Channel Changed | Radio ID: %s", radioID)
end

function StartTransmission()
    -- print(IsRadioOn)
    -- print(CurrentChannel)
    if not IsRadioOn or not CurrentChannel or Throttled("radio:transmit") or _isDead then return end

    if not IsTalkingOnRadio then
        IsTalkingOnRadio = true

        -- print('subs')
        -- print(DumpTable(CurrentChannel.subscribers))
        AddGroupToTargetList(CurrentChannel.subscribers, "radio")

        StartRadioTask()

        PlayLocalRadioClick(true)
        TriggerEvent('yeahradio:ofc', true)

        Debug("[Radio] Transmission | Sending: %s | Radio ID: %s", IsTalkingOnRadio, CurrentChannel.id)
    end

    if RadioTimeout then
        RadioTimeout:resolve(false)
    end
end

function StopTransmission(forced)
    if not IsTalkingOnRadio or RadioTimeout then return end

    RadioTimeout = TimeOut(300):next(function (continue)
        RadioTimeout = nil

        if forced ~= true and not continue then return end

        IsTalkingOnRadio = false

        RemoveGroupFromTargetList(CurrentChannel.subscribers, "radio")

        PlayLocalRadioClick(false)

        Throttled("radio:transmit", 300)
        TriggerEvent('yeahradio:ofc', false)

        Debug("[Radio] Transmission | Sending: %s | Radio ID: %s", IsTalkingOnRadio, CurrentChannel.id)
    end)

    return RadioTimeout
end

function IncreaseRadioVolume()
  local currentVolume = RadioVolume * 10
  SetRadioVolume(currentVolume + 1)
end

function DecreaseRadioVolume()
  local currentVolume = RadioVolume * 10
  SetRadioVolume(currentVolume - 1)
end

function SetRadioVolume(volume)
    if volume <= 0 then return end

    RadioVolume = _C(volume > 10, 1.0, volume * 0.1)

    if almostEqual(0.0, volume, 0.01) then RadioVolume = 0.0 end

    if IsRadioOn then
      UpdateContextVolume("radio", RadioVolume)
    end

    --TriggerEvent("DoLongHudText", ("New volume %s"):format(RadioVolume))
    print("New volume " .. RadioVolume)

    Debug("[Radio] Volume Changed | Current: %s", RadioVolume)
end

function SetRadioPowerState(state)
    IsRadioOn = state

    local volume = _C(IsRadioOn, RadioVolume, -1.0)

    UpdateContextVolume("radio", volume)

    if not IsRadioOn and IsTalkingOnRadio then
        StopTransmission(true)
    end

    UpdateRadioPowerState(IsRadioOn)

    Debug("[Radio] Power State | Powered On: %s", IsRadioOn)
end

function CycleRadioChannels()
    if not IsRadioOn then return end

    local firstEntry, lastEntry, nextChannel

    if IsTalkingOnRadio then
        Citizen.Await(StopTransmission(true))
    end

    for radioID, _ in pairs(RadioChannels) do
        if firstEntry == nil then
            firstEntry = radioID
        end

        if CurrentChannel == nil then
            nextChannel = radioID
            break
        elseif lastEntry == CurrentChannel.id then
            nextChannel = radioID
            break
        end

        lastEntry = radioID
    end

    local radioID = _C(nextChannel ~= nil, nextChannel, firstEntry)

    if radioID then
        SetRadioChannel(radioID)
    else
        CurrentChannel = nil
    end
end

function StartRadioTask()
    Citizen.CreateThread(function()
        local lib = "random@arrests"
        local anim = "generic_radio_chatter"

        LoadAnimDict("random@arrests")

        while IsTalkingOnRadio do
            if not IsEntityPlayingAnim(Player, lib, anim, 3) then
                TaskPlayAnim(Player, lib, anim, 8.0, 0.0, -1, 49, 0, false, false, false)
            end

            SetControlNormal(0, 249, 1.0)

            Citizen.Wait(0)
        end

        StopAnimTask(Player, lib, anim, 3.0)
    end)
end

function LoadRadioModule()
    RegisterModuleContext("radio", 2)
    UpdateContextVolume("radio", -1.0)

    RegisterKeyMapping('+transmitToRadio', "Radio PTT", 'keyboard', Config.transmitToRadioHotkey)
    RegisterCommand('+transmitToRadio', StartTransmission, false)
    RegisterCommand('-transmitToRadio', StopTransmission, false)

    RegisterKeyMapping('+secondaryTransmitToRadio', "Secondary Radio PTT", 'keyboard', "")
    RegisterCommand('+secondaryTransmitToRadio', StartTransmission, false)
    RegisterCommand('-secondaryTransmitToRadio', StopTransmission, false)

    if Config.enableMultiFrequency then
        RegisterKeyMapping('+cycleChannels', "Cycle Radio Channels", 'keyboard', Config.cycleRadioChannelHotkey)
        RegisterCommand('+cycleChannels', CycleRadioChannels, false)
        RegisterCommand('-cycleChannels', function() end, false)
    end

    RegisterNetEvent("irp-voice:radio:connect")
    AddEventHandler("irp-voice:radio:connect", ConnectToRadio)

    RegisterNetEvent("irp-voice:radio:disconnect")
    AddEventHandler("irp-voice:radio:disconnect", DisconnectFromRadio)

    RegisterNetEvent("irp-voice:radio:added")
    AddEventHandler("irp-voice:radio:added", AddRadioSubscriber)

    RegisterNetEvent("irp-voice:radio:removed")
    AddEventHandler("irp-voice:radio:removed", RemoveRadioSubscriber)

    RegisterNetEvent("irp-voice:radio:power")
    AddEventHandler("irp-voice:radio:power", SetRadioPowerState)

    RegisterNetEvent("irp-voice:radio:volume")
    AddEventHandler("irp-voice:radio:volume", SetRadioVolume)

    exports("SetRadioPowerState", SetRadioPowerState)
    exports("SetRadioVolume", SetRadioVolume)
    exports("IncreaseRadioVolume", IncreaseRadioVolume)
    exports("DecreaseRadioVolume", DecreaseRadioVolume)
    exports("getCurrentChannelId", getCurrentChannelId)

     if Config.enableFilters.radio then
         local filters = {
             {filterType = "biquad",	type = "highpass", frequency = 300.0, q = 1.0,	gain = 0.0 },
             {filterType = "biquad",	type = "lowpass", frequency = 3000.0, q = 1.0,	gain = 0.0 },
             {filterType = "biquad",	type = "notch", frequency = 3000.0, q = 0.5,	gain = 5.0 },
             {filterType = "waveshaper",	type = "curve", distortion = 10, curve = GetDistortionCurve(10) },
         }

         UpdateContextFilter("radio", filters)
     end

    TriggerEvent("irp-voice:radio:ready")

    Debug("[Radio] Module Loaded")
end


RegisterCommand("IncreaseRadioVolume", function(src, args, raw)
    IncreaseRadioVolume()
end, true)

RegisterCommand("DecreaseRadioVolume", function(src, args, raw)
    DecreaseRadioVolume()
end, true)

function getCurrentChannelId()
    return CurrentChannel.id
end