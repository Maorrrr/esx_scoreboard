-- Remake credit - Maor#2003

ESX = nil
local connectedPlayers = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_scoreboard:getConnectedPlayers', function(source, cb)
	cb(connectedPlayers)
end)

AddEventHandler('esx:setJob', function(playerId, job, lastJob)
	connectedPlayers[playerId].job = job.name

	TriggerClientEvent('esx_scoreboard:updateConnectedPlayers', -1, connectedPlayers)
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	AddPlayerToScoreboard(xPlayer, true)
end)

AddEventHandler('esx:playerDropped', function(playerId)
	connectedPlayers[playerId] = nil

	TriggerClientEvent('esx_scoreboard:updateConnectedPlayers', -1, connectedPlayers)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		UpdatePing()
	end
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.CreateThread(function()
			Citizen.Wait(1000)
			AddPlayersToScoreboard()
		end)
	end
end)

----------------------
--- Bad-ServerList ---
----------------------
--- CONFIG ---
BotToken = 'ODE3MzMxNDAyNzg5NjE3Njk1.YEH9Lw.a0mh0vfQ23j16G3phImQynvmx_0'-- Add discord bot token here

--- CODE ---
function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
        data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = "Bot " .. BotToken})

    while data == nil do
        Citizen.Wait(0)
    end
    
    return data
end
avatars = {}
discordNames = {}
RegisterNetEvent('Bad-ServerList:SetupImg')
AddEventHandler('Bad-ServerList:SetupImg', function()
    -- Add their avatar 
    local src = source;
    local license = ExtractIdentifiers(src).license;
    -- Only run this code if they have not been set up already 
    if avatars[license] == nil then 
        local ava = GetAvatar(src);
        local discordName = GetDiscordName(src);
        if (ava ~= nil) then 
            avatars[license] = ava;
        else 
            avatars[license] = "https://media4.giphy.com/media/3zhxq2ttgN6rEw8SDx/giphy.gif";
        end
        if (discordName ~= nil) then 
            discordNames[license] = discordName;
        else 
            discordNames[license] = "Not Found";
        end
    end
end)
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        -- It's this resource 
        for _, id in pairs(GetPlayers()) do 
            TriggerEvent('Bad-ServerList:SetupRestart', id);
        end
    end
end)
RegisterNetEvent('Bad-ServerList:SetupRestart')
AddEventHandler('Bad-ServerList:SetupRestart', function(src)
    -- Add their avatar 
    local ava = GetAvatar(src);
    local discordName = GetDiscordName(src);
    local license = ExtractIdentifiers(src).license;
    if (ava ~= nil) then 
        avatars[license] = ava;
    else 
        avatars[license] = "https://media4.giphy.com/media/3zhxq2ttgN6rEw8SDx/giphy.gif";;
    end
    if (discordName ~= nil) then 
        discordNames[license] = discordName;
    else 
        discordNames[license] = "Not Found";
    end
end)
Citizen.CreateThread(function()
    while true do 
        Wait((1000 * 5)); -- Every 5 seconds, update 
        local avatarIDs = {};
        local pings = {};
        local players = {};
        local discords = {};
        for _, id in ipairs(GetPlayers()) do 
            local license = ExtractIdentifiers(id).license;
            local ping = GetPlayerPing(id); 
            players[id] = GetPlayerName(id);
            pings[id] = ping;
            if (avatars[license] ~= nil) then 
                avatarIDs[id] = avatars[license];
            else 
                avatarIDs[id] = "https://media4.giphy.com/media/3zhxq2ttgN6rEw8SDx/giphy.gif";
            end
            if (discordNames[license] ~= nil) then 
                discords[id] = discordNames[license]
            else 
                discords[id] = "Not Found";
            end
        end
        TriggerClientEvent('Bad-ServerList:PlayerUpdate', -1, players)
        TriggerClientEvent('Bad-ServerList:PingUpdate', -1, pings)
        TriggerClientEvent('Bad-ServerList:ClientUpdate', -1, avatarIDs)
        TriggerClientEvent('Bad-ServerList:DiscordUpdate', -1, discords)
    end
end)


function GetAvatar(user) 
    local discordId = nil
    local imgURL = nil;
    for _, id in ipairs(GetPlayerIdentifiers(user)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            print("Found discord id: "..discordId)
            break
        end
    end
    if discordId then 
        local endpoint = ("users/%s"):format(discordId)
        local member = DiscordRequest("GET", endpoint, {})
        if member.code == 200 then
            local data = json.decode(member.data)
            if data ~= nil and data.avatar ~= nil then 
                -- It is valid data 
                --print("The data for User " .. GetPlayerName(user) .. " is: ");
                --print(data.avatar);
                if (data.avatar:sub(1, 1) and data.avatar:sub(2, 2) == "_") then 
                    --print("IMG URL: " .. "https://cdn.discordapp.com/avatars/" .. discordId .. "/" .. data.avatar .. ".gif")
                    imgURL = "https://cdn.discordapp.com/avatars/" .. discordId .. "/" .. data.avatar .. ".gif";
                else 
                    --print("IMG URL: " .. "https://cdn.discordapp.com/avatars/" .. discordId .. "/" .. data.avatar .. ".png")
                    imgURL = "https://cdn.discordapp.com/avatars/" .. discordId .. "/" .. data.avatar .. ".png"
                end
                --print("---")
            end
        end
    end
    return imgURL;
end
function GetDiscordName(user) 
    local discordId = nil
    local nameData = nil;
    for _, id in ipairs(GetPlayerIdentifiers(user)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            print("Found discord id: "..discordId)
            break
        end
    end
    if discordId then 
        local endpoint = ("users/%s"):format(discordId)
        local member = DiscordRequest("GET", endpoint, {})
        if member.code == 200 then
            local data = json.decode(member.data)
            if data ~= nil then 
                -- It is valid data 
                --print("The data for User " .. GetPlayerName(user) .. " is: ");
                --print(data.avatar);
                nameData = data.username .. "#" .. data.discriminator;
                --print("---")
            end
        end
    end
    return nameData;
end

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    --Loop over all identifiers
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        --Convert it to a nice table.
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end

--[[local FormattedToken = "Bot NzYxNTg0MjIxNTgzNzA0MTI2.X3cukw.cFTR9W9IDMX1sCHtHo61s5PgtOs"
function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
        data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = "Bot NzYxNTg0MjIxNTgzNzA0MTI2.X3cukw.cFTR9W9IDMX1sCHtHo61s5PgtOs"})

    while data == nil do
        Citizen.Wait(0)
    end
    
    return data
end --]]

--[[function getDiscord(source)
    local discordId = nil
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
        end
    end

    local endpoint = ("users/%s"):format(discordId)
	local member = DiscordRequest("GET", endpoint, {})
	if member.code == 200 then
        local data = json.decode(member.data)
        return data
    else 
        return nil
    end
end --]]

function AddPlayerToScoreboard(xPlayer, update)
	local playerId = xPlayer.source
--	local discord = getDiscord(playerId)
	--print(discord)
	connectedPlayers[playerId] = {}
	connectedPlayers[playerId].ping = GetPlayerPing(playerId)
	connectedPlayers[playerId].id = playerId
	connectedPlayers[playerId].name = GetDiscordName(playerId) or GetPlayerName(playerId)
	connectedPlayers[playerId].job = xPlayer.job.name
	
	connectedPlayers[playerId].discordAvatar = GetAvatar(playerId) 

	if update then
		TriggerClientEvent('esx_scoreboard:updateConnectedPlayers', -1, connectedPlayers)
	end

	if xPlayer.player.getGroup() == 'user' then
		Citizen.CreateThread(function()
			Citizen.Wait(3000)
			TriggerClientEvent('esx_scoreboard:toggleID', playerId, false)
		end)
	end
end

function AddPlayersToScoreboard()
	local players = ESX.GetPlayers()

	for i=1, #players, 1 do
		local xPlayer = ESX.GetPlayerFromId(players[i])
		AddPlayerToScoreboard(xPlayer, false)
	end

	TriggerClientEvent('esx_scoreboard:updateConnectedPlayers', -1, connectedPlayers)
end

function UpdatePing()
	for k,v in pairs(connectedPlayers) do
		v.ping = GetPlayerPing(k)
	end

	TriggerClientEvent('esx_scoreboard:updatePing', -1, connectedPlayers)
end

TriggerEvent('es:addGroupCommand', 'screfresh', 'superadmin', function(source, args, user)
	AddPlayersToScoreboard()
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = "Refresh esx_scoreboard names!"})

TriggerEvent('es:addGroupCommand', 'sctoggle', 'admin', function(source, args, user)
	TriggerClientEvent('esx_scoreboard:toggleID', source)
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = "Toggle ID column on the scoreboard!"})
