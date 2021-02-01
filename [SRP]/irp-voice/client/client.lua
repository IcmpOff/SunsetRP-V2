Transmissions, Targets, Channels, Settings = Context:new(), Context:new(), Context:new(), {}
CurrentTarget, CurrentInstance, CurrentProximity, CurrentVoiceChannel, Player, PlayerCoords, PreviousCoords, VoiceEnabled = 1, 0, 1, 0
_myServerId = nil
_isDead = false

AddEventHandler("tcm_player:updateDeathStatus", function(isDead)
    _isDead = isDead
end)

Citizen.CreateThread(function()
    RegisterKeyMapping('+cycleProximity', "Cycle Proximity Range", 'keyboard', Config.cycleProximityHotkey)
    RegisterCommand('+cycleProximity', CycleVoiceProximity, false)
    RegisterCommand('-cycleProximity', function() end, false)

    NetworkSetTalkerProximity(0.01)
    Wait(5000)

    for i = 1, 4 do
        MumbleClearVoiceTarget(i)
    end

    if Config.enableGrids then
        LoadGridModule()
    end

    if Config.enableRadio then
        LoadRadioModule()
    end

    if Config.enablePhone then
        LoadPhoneModule()
    end

    if Config.enableCar then
        LoadCarModule()
    end

    SetVoiceProximity(2)
    TriggerEvent("irp-voice:ready")
    voiceThread()
end)

function voiceThread()
    Citizen.CreateThread(function()
        while true do
            local idle = 100
            Player = PlayerPedId()
            PlayerCoords = GetEntityCoords(Player)
            local isVoiceActive = GetConvar('profile_voiceEnable', 0) == '1' --NetworkIsPlayerTalking(PlayerId())
    
            if PlayerCoords ~= PreviousCoords then
                idle = 50
            end
    
            PreviousCoords = PlayerCoords
    
            if isVoiceActive and not VoiceEnabled then
                TriggerEvent('irp-voice:state', true)
            elseif not isVoiceActive and VoiceEnabled then
                TriggerEvent('irp-voice:state', false)
            end
    
            if isVoiceActive and NetworkIsPlayerTalking(PlayerId()) then
                TriggerEvent('yeahlol:ofc', true)
            else
                TriggerEvent('yeahlol:ofc', false)
            end
    
            Citizen.Wait(idle)
        end
    end)
end


AddEventHandler('irp-voice:state', function (state)
    VoiceEnabled = state

    TriggerServerEvent("irp-voice:connection:state", state)

    if VoiceEnabled then
        _myServerId = GetPlayerServerId(PlayerId())
        while MumbleGetVoiceChannelFromServerId(_myServerId) == 0 do
            NetworkSetVoiceChannel(CurrentVoiceChannel)
            Citizen.Wait(100)
        end

        RefreshTargets()
    end
end)

function RegisterModuleContext(context, priority)
    Transmissions:registerContext(context)
    Targets:registerContext(context)
    Channels:registerContext(context)
    Transmissions:setContextData(context, "priority", priority)

    Debug("[Main] Context Added | ID: %s | Priority: %s", context, priority)
end

function ChangeVoiceTarget(targetID)
    CurrentTarget = targetID
    MumbleSetVoiceTarget(targetID)
end

function SetVoiceChannel(channelID)
    NetworkSetVoiceChannel(channelID)
    Debug("[Main] Current Channel: %s | Previous: %s | Target: %s ", channelID, CurrentVoiceChannel, CurrentTarget)
    CurrentVoiceChannel = channelID
end

function IsPlayerInTargetChannel(serverID)
    local found = false

    if Config.enableGrids then
        local gridChannel = GetGridChannel(GetPlayerCoords(serverID), Config.gridSize)
        found = Channels:targetHasAnyActiveContext(gridChannel) == true
    end

    return found
end

function SetVoiceTargets(targetID)
    local players, channels = {}, {}

    Channels:contextIterator(function(channel)
        if not channels[channel] then
            channels[channel] = true
            MumbleAddVoiceTargetChannel(targetID, channel)
        end
    end)

    Targets:contextIterator(function(serverID)
        if not players[serverID] and not IsPlayerInTargetChannel(serverID) then
            players[serverID] = true
            MumbleAddVoiceTargetPlayerByServerId(targetID, serverID)
        end
    end)
end

function RefreshTargets()
    local voiceTarget = _C(CurrentTarget == 1, 2, 1)
    MumbleClearVoiceTarget(voiceTarget)
    SetVoiceTargets(voiceTarget)
    ChangeVoiceTarget(voiceTarget)
end


function AddPlayerToTargetList(serverID, context, transmit)
    if not Targets:targetContextExist(serverID, context) then

        if transmit then
            TriggerServerEvent("irp-voice:transmission:state", serverID, context, true)
        end

        if not Targets:targetHasAnyActiveContext(serverID) and not IsPlayerInTargetChannel(serverID) and _myServerId ~= serverID then
            MumbleAddVoiceTargetPlayerByServerId(CurrentTarget, serverID)
        end

        Targets:add(serverID, context)

        Debug("[Main] Target Added | Player: %s | Context: %s ", serverID, context)
    end
end

function RemovePlayerFromTargetList(serverID, context, transmit, refresh)
    if Targets:targetContextExist(serverID, context) then
        Targets:remove(serverID, context)

        if transmit then
            TriggerServerEvent("irp-voice:transmission:state", serverID, context, false)
        end

        if refresh then
            RefreshTargets()
        end

        Debug("[Main] Target Removed | Player: %s | Context: %s ", serverID, context)
    end
end

function AddGroupToTargetList(group, context)
    if not Targets:contextExists(context) then return end

    for serverID, active in pairs(group) do
        if active then
            AddPlayerToTargetList(serverID, context, false)
        end
    end

    TriggerServerEvent("irp-voice:transmission:state", group, context, true)
end

function RemoveGroupFromTargetList(group, context)
    if not Targets:contextExists(context) then return end

    for serverID, active in pairs(group) do
        if active then
            RemovePlayerFromTargetList(serverID, context, false, false)
        end
    end

    RefreshTargets()

    TriggerServerEvent("irp-voice:transmission:state", group, context, false)
end

function AddChannelToTargetList(channel, context)
    if not Channels:targetContextExist(channel, context) then
        --print("ADDING " .. CurrentTarget)
        if not Channels:targetHasAnyActiveContext(channel) then
            --MUMBLE_ADD_VOICE_CHANNEL_LISTEN
            --MumbleAddVoiceChannelListen(channel)
            --print("ADDING " .. CurrentTarget .. " " .. channel)
            MumbleAddVoiceTargetChannel(CurrentTarget, channel)
        end

        Channels:add(channel, context)

        Debug("[Main] Channel Added | ID: %s | Context: %s ", channel, context)
    end
end

function RemoveChannelFromTargetList(channel, context, refresh)
    if Channels:targetContextExist(channel, context) then
        Channels:remove(channel, context)

        --MumbleRemoveVoiceChannelListen(channel)
        if refresh then
            RefreshTargets()
        end

        Debug("[Main] Channel Removed | ID: %s | Context: %s ", channel, context)
    end
end

function AddChannelGroupToTargetList(group, context)
    if not Channels:contextExists(context) then return end

    for _, channel in pairs(group) do
        AddChannelToTargetList(channel, context)
    end
end

function RemoveChannelGroupFromTargetList(group, context)
    if not Channels:contextExists(context) then return end

    for _, channel in pairs(group) do
        RemoveChannelFromTargetList(channel, context, false)
    end

    RefreshTargets()
end

function CycleVoiceProximity()
    local newProximity = CurrentProximity + 1

    local proximity = _C(Config.voiceRanges[newProximity] ~= nil, newProximity, 1)

    SetVoiceProximity(proximity)
end

function SetVoiceProximity(proximity)
    local voiceProximity = Config.voiceRanges[proximity]

    CurrentProximity = proximity
    NetworkSetTalkerProximity(voiceProximity.range + .0)

    TriggerEvent('carhud:tok', voiceProximity.name)
    Debug("[Main] Proximity Range | Proximity: %s | Range: %s", voiceProximity.name, voiceProximity.range)
end

function GetTransmissionVolume(serverID)
    local _, contexts = Transmissions:getTargetContexts(serverID)

    local volume = -1.0

    for _, context in pairs(contexts) do
        if context.volume and context.volume > volume then
            volume = context.volume
        end
    end

    return volume
end

function GetPriorityContextData(serverID)
    local _, contexts = Transmissions:getTargetContexts(serverID)

    local context = { volume = -1.0, priority = 0 }

    for _, ctx in pairs(contexts) do
        if ctx.priority >= context.priority and (ctx.volume == -1 or ctx.volume >= context.volume) then
            context = ctx
        end
    end

    return context
end

function UpdateContextVolume(context, volume)
    Transmissions:setContextData(context, "volume", volume)

    Transmissions:contextIterator(function(targetID, tContext)
        if tContext == context then
            local context = GetPriorityContextData(targetID)

            MumbleSetVolumeOverrideByServerId(targetID, context.volume)
        end
    end)
end

RegisterNetEvent("irp-voice:transmission:state")
AddEventHandler("irp-voice:transmission:state", function(serverID, context, transmitting)

    if not Transmissions:contextExists(context) then
        return
    end

    if transmitting then
        Transmissions:add(serverID, context)
    else
        Transmissions:remove(serverID, context)
    end

    local data = GetPriorityContextData(serverID)

    if not transmitting then
        MumbleSetVolumeOverrideByServerId(serverID, data.volume)
        Citizen.Wait(0)
    end

    -- if (Config.enableFilters.phone or Config.enableFilters.radio) and CanUseFilter(transmitting, context) then
    --     SetTransmissionFilters(serverID, data)
    -- end

    if transmitting then
        Citizen.Wait(0)
        MumbleSetVolumeOverrideByServerId(serverID, data.volume)
    end

    if context == "radio" and IsRadioOn then
        PlayRemoteRadioClick(transmitting)
    end

    if (Config.enableFilters.phone or Config.enableFilters.radio) and CanUseFilter(transmitting, context) then
        --Wait(500)
        SetTransmissionFilters(serverID, data)
    end

    Debug("[Main] Transmission | Origin: %s | Vol: %s | Ctx: %s | Active: %s", serverID, data.volume, context, transmitting)
end)

RegisterNetEvent('irp-voice:targets:player:add')
AddEventHandler('irp-voice:targets:player:add', AddPlayerToTargetList)

RegisterNetEvent('irp-voice:targets:player:remove')
AddEventHandler('irp-voice:targets:player:remove', RemovePlayerFromTargetList)
