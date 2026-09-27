local ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - Config.HellLocation)

        if distance < Config.HellRadius then
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                if GetEntityModel(vehicle) == GetHashKey(Config.KartModel) then
                    TriggerServerEvent('HellKartScript:EnterHell')
                end
            end
        end
    end
end)

RegisterNetEvent('HellKartScript:SpawnKart')
AddEventHandler('HellKartScript:SpawnKart', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local heading = Config.KartHeading

    ESX.Game.SpawnVehicle(Config.KartModel, Config.KartSpawn, heading, function(vehicle)
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    end)
end)

RegisterNetEvent('HellKartScript:Notify')
AddEventHandler('HellKartScript:Notify', function(message)
    ESX.ShowNotification(message)
end)