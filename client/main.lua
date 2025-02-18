local QBCore =  exports['qb-core']:GetCoreObject()

local forceDraw = false
local shouldDraw = false
local nearbyPlayers = nil

RegisterNetEvent('qb-showid:id', function()
    forceDraw = not forceDraw
end)

local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

CreateThread(function()
    while true do
        Wait(2000)

        nearbyPlayers = GetNeareastPlayers()
    end
end)

CreateThread(function()
    while true do
        Wait(1)

        if Config.Key.Enabled then
            shouldDraw = IsControlPressed(0, Config.Key.Code)
        end

        if shouldDraw or forceDraw then            
            if nearbyPlayers ~= nil then
                for _, v in pairs(nearbyPlayers) do
                    local x, y, z = table.unpack(v.coords)
                    Draw3DText(x, y, z + 1.1, v.playerId)
                end
            end
        end
    end
end)

CreateThread(function()
    local animationState = false
    local clipboardEntity

    while true do
        Wait(100)

        if animationState ~= shouldDraw then
            animationState = shouldDraw

            if animationState then
                local playerPed = GetPlayerPed(-1)

                loadAnimDict("missheistdockssetup1clipboard@base")
                TaskPlayAnim(playerPed, 'missheistdockssetup1clipboard@base', 'base', 8.0, -8, -1, 49, 0, 0, 0, 0)

                clipboardEntity = CreateObject(GetHashKey("p_amb_clipboard_01"), x, y, z, true)

                AttachEntityToEntity(clipboardEntity, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(PlayerId()), 18905), Config.Coords.x, Config.Coords.y, Config.Coords.z, Config.Rotation.x, Config.Rotation.y, Config.Rotation.z, 1, 1, 0, 1, 0, 1)
            else
                ClearPedTasks(GetPlayerPed(-1))

                if clipboardEntity ~= nil then
                    DeleteEntity(clipboardEntity)
                    clipboardEntity = nil
                end
            end
        end
    end
end)

function GetNeareastPlayers()
    local playerPed = PlayerPedId()
    local players, _ = QBCore.Functions.GetPlayers(GetEntityCoords(playerPed), Config.DrawDistance)

    local players_clean = {}

    for i = 1, #players, 1 do
        table.insert(players_clean, { playerName = GetPlayerName(players[i]), playerId = GetPlayerServerId(players[i]), coords = GetEntityCoords(GetPlayerPed(players[i])) })
    end

    return players_clean
end

function Draw3DText(x, y, z, text)
    -- Check if coords are visible and get 2D screen coords
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        -- Calculate text scale to use
        local dist = GetDistanceBetweenCoords(GetGameplayCamCoords(), x, y, z, 1)
        local scale = 1 * (1 / dist) * (1 / GetGameplayCamFov()) * 100

        -- Draw text on screen
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropShadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end