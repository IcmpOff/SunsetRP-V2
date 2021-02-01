useNativeAudio = false
use3dAudio = true
useSendingRangeOnly = true
local activeUsers = {}
-- local maxChannel = 512--GetMaxChunkId() << 1 -- Double the max just in case


AddEventHandler("onResourceStart", function(resName) -- Initialises the script, sets up voice related convars
	if GetCurrentResourceName() ~= resName then
		return
	end

	-- Set voice related convars
	SetConvarReplicated("voice_useNativeAudio", useNativeAudio and "true" or "false")
	SetConvarReplicated("voice_use2dAudio", use3dAudio and "false" or "true")
	SetConvarReplicated("voice_use3dAudio", use3dAudio and "true" or "false")	
	SetConvarReplicated("voice_useSendingRangeOnly", useSendingRangeOnly and "true" or "false")	

	-- for i = 1, maxChannel do
	-- 	MumbleCreateChannel(i)
	-- end

	Debug("Initialised Script")
end)


RegisterNetEvent("irp-voice:connection:state")
AddEventHandler("irp-voice:connection:state", function(state)
	TriggerClientEvent('irp-voice:connection:state', -1, source, state)
end)


RegisterNetEvent("irp-voice:transmission:state")
AddEventHandler("irp-voice:transmission:state", function(group, context, transmitting)
	print('transmission')
	--print( type(group))
	if type(group) == 'table' then
		for k,v in pairs(group) do
			print(v)
			print(k)
			TriggerClientEvent('irp-voice:transmission:state', v, source, context, transmitting)
		end
	else
	end
end)


function Debug(msg, ...)
    if not Config.enableDebug then return end

    local params = {}

    for _, param in ipairs({ ... }) do
        if type(param) == "table" then
            param = json.encode(param)
        end

        table.insert(params, param)
    end

    print((msg):format(table.unpack(params)))
end
