local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('HellKartScript:CheckKartOwnership', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerId = xPlayer.identifier

    MySQL.Async.fetchScalar('SELECT kart_owned FROM hell_kart_players WHERE player_id = @player_id', {
        ['@player_id'] = playerId
    }, function(result)
        if result then
            cb(result)
        else
            cb(false)
        end
    end)
end)

ESX.RegisterServerCallback('HellKartScript:CheckCooldown', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerId = xPlayer.identifier

    MySQL.Async.fetchScalar('SELECT last_hell_entry FROM hell_kart_players WHERE player_id = @player_id', {
        ['@player_id'] = playerId
    }, function(result)
        if result then
            local currentTime = os.time()
            local lastEntryTime = os.time({year = result.year, month = result.month, day = result.day, hour = result.hour, min = result.min, sec = result.sec})
            local timeDiff = currentTime - lastEntryTime

            if timeDiff < Config.CooldownTime then
                cb(false)
            else
                cb(true)
            end
        else
            cb(true)
        end
    end)
end)

RegisterServerEvent('HellKartScript:EnterHell')
AddEventHandler('HellKartScript:EnterHell', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerId = xPlayer.identifier

    ESX.TriggerServerCallback('HellKartScript:CheckKartOwnership', function(hasKart)
        if hasKart then
            ESX.TriggerServerCallback('HellKartScript:CheckCooldown', function(canEnter)
                if canEnter then
                    if xPlayer.getAccount('bank').money >= Config.HellEntryFee then
                        xPlayer.removeAccountMoney('bank', Config.HellEntryFee)
                        MySQL.Async.execute('UPDATE hell_kart_players SET last_hell_entry = NOW() WHERE player_id = @player_id', {
                            ['@player_id'] = playerId
                        })
                        TriggerClientEvent('HellKartScript:Notify', source, 'You have entered the Hell Kart!')
                    else
                        TriggerClientEvent('HellKartScript:Notify', source, 'You do not have enough money to enter the Hell Kart!')
                    end
                else
                    TriggerClientEvent('HellKartScript:Notify', source, 'You must wait before entering the Hell Kart again!')
                end
            end)
        else
            TriggerClientEvent('HellKartScript:Notify', source, 'You do not own a Hell Kart!')
        end
    end)
end)

ESX.RegisterServerCallback('HellKartScript:BuyKart', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerId = xPlayer.identifier

    if xPlayer.getAccount('bank').money >= Config.KartPrice then
        xPlayer.removeAccountMoney('bank', Config.KartPrice)
        MySQL.Async.execute('UPDATE hell_kart_players SET kart_owned = TRUE WHERE player_id = @player_id', {
            ['@player_id'] = playerId
        })
        TriggerClientEvent('HellKartScript:SpawnKart', source)
        cb(true)
    else
        cb(false)
    end
end)