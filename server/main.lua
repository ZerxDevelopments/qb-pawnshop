local QBCore = exports['qb-core']:GetCoreObject()

local function exploitBan(id, reason)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {
            GetPlayerName(id),
            QBCore.Functions.GetIdentifier(id, 'license'),
            QBCore.Functions.GetIdentifier(id, 'discord'),
            QBCore.Functions.GetIdentifier(id, 'ip'),
            reason,
            2147483647,
            'qb-pawnshop'
        })
    TriggerEvent('qb-log:server:CreateLog', 'pawnshop', 'Player Banned', 'red',
        string.format('%s was banned by %s for %s', GetPlayerName(id), 'qb-pawnshop', reason), true)
    DropPlayer(id, 'You were permanently banned by the server for: Exploiting')
end

RegisterNetEvent('qb-pawnshop:server:sellPawnItems', function(itemName, itemAmount, itemPrice)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local totalPrice = (tonumber(itemAmount) * itemPrice)
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local dist
    for _, value in pairs(Config.PawnLocation) do
        dist = #(playerCoords - value.coords)
        if #(playerCoords - value.coords) < 2 then
            dist = #(playerCoords - value.coords)
            break
        end
    end
    if dist > 5 then
        exploitBan(src, 'sellPawnItems Exploiting')
        return
    end
    if exports['karma_inventory']:RemoveItem(src, itemName, tonumber(itemAmount), false, 'qb-pawnshop:server:sellPawnItems') then
        if Config.BankMoney then
            Player.Functions.AddMoney('bank', totalPrice, 'qb-pawnshop:server:sellPawnItems')
        else
            Player.Functions.AddMoney('cash', totalPrice, 'qb-pawnshop:server:sellPawnItems')
        end
        TriggerClientEvent('QBCore:Notify', src, Lang:t('success.sold', { value = tonumber(itemAmount), value2 = QBCore.Shared.Items[itemName].label, value3 = totalPrice }), 'success')
        TriggerClientEvent('karma_inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'remove')
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.no_items'), 'error')
    end
    TriggerClientEvent('qb-pawnshop:client:openMenu', src)
end)

QBCore.Functions.CreateCallback('qb-pawnshop:server:getInv', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local inventory = Player.PlayerData.items
    return cb(inventory)
end)
