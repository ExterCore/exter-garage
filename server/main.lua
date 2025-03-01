Table = nil
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        while Table == nil do Citizen.Wait(0) end
        if Config.AutoRestoreVehicles then
            if Table == "player_vehicles" then
                MySQL.update('UPDATE player_vehicles SET state = 1, depotprice = 0 WHERE state = 0 OR depotprice = 500', {})
            else
                MySQL.update('UPDATE owned_vehicles SET stored = 1, pound = 0 WHERE stored = 0', {})
            end
        else
            if Table == "player_vehicles" then
                MySQL.update('UPDATE player_vehicles SET depotprice = ' .. Config.DepotPrice .. ' WHERE state = 0', {})
            else
                MySQL.update('UPDATE owned_vehicles SET pound = ' .. Config.DepotPrice .. ' WHERE stored = 1', {})
            end
        end
    end
end)

-- Functions
local SharedKeys = {}
local OutsideVehicles = {}
local vehicleClasses = {
    compacts = 0,
    sedans = 1,
    suvs = 2,
    coupes = 3,
    muscle = 4,
    sportsclassics = 5,
    sports = 6,
    super = 7,
    motorcycles = 8,
    offroad = 9,
    industrial = 10,
    utility = 11,
    vans = 12,
    cycles = 13,
    boats = 14,
    helicopters = 15,
    planes = 16,
    service = 17,
    emergency = 18,
    military = 19,
    commercial = 20,
    trains = 21,
    openwheel = 22,
}

function arrayToSet(array)
    local set = {}
    for _, item in ipairs(array) do
        set[item] = true
    end
    return set
end

function filterVehiclesByCategory(vehicles, category)
    local filtered = {}
    local categorySet = arrayToSet(category)
    for _, vehicle in pairs(vehicles) do
        local vehicleData = vehiclesData[vehicle.vehicle]
        local vehicleCategoryString = vehicleData and vehicleData.category or 'compacts'
        local vehicleCategoryNumber = vehicleClasses[vehicleCategoryString]
        if vehicleCategoryNumber and categorySet[vehicleCategoryNumber] then
            filtered[#filtered + 1] = vehicle
        end
    end
    return filtered
end

CreateCallback('exter-garage:server:getHouseGarage', function(_, cb, house)
    local houseInfo = MySQL.single.await('SELECT * FROM houselocations WHERE name = ?', {house})
    cb(houseInfo)
end)

CreateCallback('exter-garage:server:GetGarageVehicles', function(source, cb, garage, type, category)
    local vehicles = {}
    local Player = GetPlayer(source)
    if not Player then return end
    local citizenId = GetPlayerCid(source)
    
    local function addVehiclesToTable(vehiclesData, shared)
        for _, v in pairs(vehiclesData) do
            table.insert(vehicles, {
                id = v.id,
                depotprice = v.depotprice,
                garage = v.garage,
                citizenid = v.citizenId,
                hash = v.hash,
                paymentsleft = v.paymentsleft,
                plate = v.plate,
                body = v.body,
                mods = v.mods,
                paymentamount = v.paymentamount,
                balance = v.balance,
                logs = v.logs,
                engine = v.engine,
                vehicle = v.vehicle,
                state = v.state,
                license = v.license,
                fuel = v.fuel,
                financetime = v.financetime,
                shared = shared
            })
        end
    end

    -- Shared Key Check
    if SharedKeys[citizenId] then
        for _, v in pairs(SharedKeys[citizenId]) do
            local vehiclesData
            if type == 'depot' then
                if Table == "player_vehicles" then
                    vehiclesData = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE plate = ? AND depotprice > 0', {v})
                else
                    vehiclesData = MySQL.rawExecute.await('SELECT * FROM owned_vehicles WHERE plate = ? AND pound > 0', {v})
                end
            elseif Config.SharedGarages then
                if Table == "player_vehicles" then
                    vehiclesData = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE plate = ?', {v})
                else
                    vehiclesData = MySQL.rawExecute.await('SELECT * FROM owned_vehicles WHERE plate = ?', {v})
                end
            else
                if Table == "player_vehicles" then
                    vehiclesData = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE plate = ? AND garage = ?', {v, garage})
                else
                    vehiclesData = MySQL.rawExecute.await('SELECT * FROM owned_vehicles WHERE plate = ? AND garage = ?', {v, garage})
                end
            end
            if vehiclesData and #vehiclesData > 0 then
                addVehiclesToTable(vehiclesData, true)
            end
        end
    end

    local vehiclesData
    if type == 'depot' then
        if Table == "player_vehicles" then
            vehiclesData = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE citizenid = ? AND depotprice > 0', {citizenId})
        else
            vehiclesData = MySQL.rawExecute.await('SELECT * FROM owned_vehicles WHERE owner = ? AND pound > 0', {citizenId})
        end
    elseif Config.SharedGarages then
        if Table == "player_vehicles" then
            vehiclesData = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE citizenid = ?', {citizenId})
        else
            vehiclesData = MySQL.rawExecute.await('SELECT * FROM owned_vehicles WHERE owner = ?', {citizenId})
        end
    else
        if Table == "player_vehicles" then
            vehiclesData = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE citizenid = ? AND garage = ?', {citizenId, garage})
        else
            vehiclesData = MySQL.rawExecute.await('SELECT * FROM owned_vehicles WHERE owner = ? AND garage = ?', {citizenId, garage})
        end
    end
    if vehiclesData and #vehiclesData > 0 then
        addVehiclesToTable(vehiclesData, false)
    end

    if #vehicles == 0 then
        cb(nil)
        return
    end

    if Config.ClassSystem then
        local filteredVehicles = filterVehiclesByCategory(vehicles, category)
        cb(filteredVehicles)
    else
        cb(vehicles)
    end
end)

-- CreateCallback('exter-garage:server:GetGarageVehicles', function(source, cb, garage, type, category)
--     local vehicles = {}
--     local Player = GetPlayer(source)
--     if not Player then return end
--     local citizenId = GetPlayerCid(source)
--     -- Shared Key Check
--     if SharedKeys[citizenId] then
--         for k, v in pairs(SharedKeys[citizenId]) do
--             if type == 'depot' then
--                 if Table == "player_vehicles" then
--                     local vehiclesData = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE plate = ? AND depotprice > 0', {v})
--                     if #vehiclesData >= 1 then
--                         for k, v in pairs(vehiclesData) do
--                             table.insert(vehicles, {
--                                 id = v.id,
--                                 depotprice = v.depotprice,
--                                 garage = v.garage,
--                                 citizenid = v.citizenId,
--                                 hash = v.hash,
--                                 paymentsleft = v.paymentsleft,
--                                 plate = v.plate,
--                                 body = v.body,
--                                 mods = v.mods,
--                                 paymentamount = v.paymentamount,
--                                 balance = v.balance,
--                                 logs = v.logs,
--                                 engine = v.engine,
--                                 vehicle = v.vehicle,
--                                 state = v.state,
--                                 license = v.license,
--                                 fuel = v.fuel,
--                                 financetime = v.financetime,
--                                 shared = true
--                             })
--                         end
--                     end
--                 else
--                     local vehiclesData = MySQL.rawExecute.await('SELECT * FROM owned_vehicles WHERE plate = ? AND pound > 0', {v})
--                     if #vehiclesData >= 1 then
--                         for k, v in pairs(vehiclesData) do
--                             table.insert(vehicles, {
--                                 id = v.id,
--                                 depotprice = v.depotprice,
--                                 garage = v.garage,
--                                 citizenid = v.citizenId,
--                                 hash = v.hash,
--                                 paymentsleft = v.paymentsleft,
--                                 plate = v.plate,
--                                 body = v.body,
--                                 mods = v.mods,
--                                 paymentamount = v.paymentamount,
--                                 balance = v.balance,
--                                 logs = v.logs,
--                                 engine = v.engine,
--                                 vehicle = v.vehicle,
--                                 stored = v.stored,
--                                 license = v.license,
--                                 fuel = v.fuel,
--                                 financetime = v.financetime,
--                                 shared = true
--                             })
--                         end
--                     end
--                 end
--             elseif Config.SharedGarages then
--                 if Table == "player_vehicles" then
--                     local vehiclesData = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE plate = ?', {v})
--                     if #vehiclesData >= 1 then
--                         for k, v in pairs(vehiclesData) do
--                             table.insert(vehicles, {
--                                 id = v.id,
--                                 depotprice = v.depotprice,
--                                 garage = v.garage,
--                                 citizenid = v.citizenId,
--                                 hash = v.hash,
--                                 paymentsleft = v.paymentsleft,
--                                 plate = v.plate,
--                                 body = v.body,
--                                 mods = v.mods,
--                                 paymentamount = v.paymentamount,
--                                 balance = v.balance,
--                                 logs = v.logs,
--                                 engine = v.engine,
--                                 vehicle = v.vehicle,
--                                 state = v.state,
--                                 license = v.license,
--                                 fuel = v.fuel,
--                                 financetime = v.financetime,
--                                 shared = true
--                             })
--                         end
--                     end
--                 else
--                     local vehiclesData = MySQL.rawExecute.await('SELECT * FROM owned_vehicles WHERE plate = ?', {v})
--                     if #vehiclesData >= 1 then
--                         for k, v in pairs(vehiclesData) do
--                             table.insert(vehicles, {
--                                 id = v.id,
--                                 depotprice = v.depotprice,
--                                 garage = v.garage,
--                                 citizenid = v.citizenId,
--                                 hash = v.hash,
--                                 paymentsleft = v.paymentsleft,
--                                 plate = v.plate,
--                                 body = v.body,
--                                 mods = v.mods,
--                                 paymentamount = v.paymentamount,
--                                 balance = v.balance,
--                                 logs = v.logs,
--                                 engine = v.engine,
--                                 vehicle = v.vehicle,
--                                 stored = v.stored,
--                                 license = v.license,
--                                 fuel = v.fuel,
--                                 financetime = v.financetime,
--                                 shared = true
--                             })
--                         end
--                     end
--                 end
--             else
--                 if Table == "player_vehicles" then
--                     local vehiclesData = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE plate = ? AND garage = ?', {v, garage})
--                     if #vehiclesData >= 1 then
--                         for k, v in pairs(vehiclesData) do
--                             table.insert(vehicles, {
--                                 id = v.id,
--                                 depotprice = v.depotprice,
--                                 garage = v.garage,
--                                 citizenid = v.citizenId,
--                                 hash = v.hash,
--                                 paymentsleft = v.paymentsleft,
--                                 plate = v.plate,
--                                 body = v.body,
--                                 mods = v.mods,
--                                 paymentamount = v.paymentamount,
--                                 balance = v.balance,
--                                 logs = v.logs,
--                                 engine = v.engine,
--                                 vehicle = v.vehicle,
--                                 state = v.state,
--                                 license = v.license,
--                                 fuel = v.fuel,
--                                 financetime = v.financetime,
--                                 shared = true
--                             })
--                         end
--                     end
--                 else
--                     local vehiclesData = MySQL.rawExecute.await('SELECT * FROM owned_vehicles WHERE plate = ? AND garage = ?', {v, garage})
--                     if #vehiclesData >= 1 then
--                         for k, v in pairs(vehiclesData) do
--                             table.insert(vehicles, {
--                                 id = v.id,
--                                 depotprice = v.depotprice,
--                                 garage = v.garage,
--                                 citizenid = v.citizenId,
--                                 hash = v.hash,
--                                 paymentsleft = v.paymentsleft,
--                                 plate = v.plate,
--                                 body = v.body,
--                                 mods = v.mods,
--                                 paymentamount = v.paymentamount,
--                                 balance = v.balance,
--                                 logs = v.logs,
--                                 engine = v.engine,
--                                 vehicle = v.vehicle,
--                                 stored = v.stored,
--                                 license = v.license,
--                                 fuel = v.fuel,
--                                 financetime = v.financetime,
--                                 shared = true
--                             })
--                         end
--                     end
--                 end
--             end
--         end
--     end
--     -- Functions
--     if type == 'depot' then
--         if Table == "player_vehicles" then
--             local vehiclesData = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE citizenid = ? AND depotprice > 0', {citizenId})
--             if #vehiclesData >= 1 then
--                 for k, v in pairs(vehiclesData) do
--                     table.insert(vehicles, {
--                         id = v.id,
--                         depotprice = v.depotprice,
--                         garage = v.garage,
--                         citizenid = v.citizenId,
--                         hash = v.hash,
--                         paymentsleft = v.paymentsleft,
--                         plate = v.plate,
--                         body = v.body,
--                         mods = v.mods,
--                         paymentamount = v.paymentamount,
--                         balance = v.balance,
--                         logs = v.logs,
--                         engine = v.engine,
--                         vehicle = v.vehicle,
--                         state = v.state,
--                         license = v.license,
--                         fuel = v.fuel,
--                         financetime = v.financetime
--                     })
--                 end
--             end
--         else
--             local vehiclesData = MySQL.rawExecute.await('SELECT * FROM owned_vehicles WHERE owner = ? AND pound > 0', {citizenId})
--             if #vehiclesData >= 1 then
--                 for k, v in pairs(vehiclesData) do
--                     table.insert(vehicles, {
--                         id = v.id,
--                         depotprice = v.depotprice,
--                         garage = v.garage,
--                         citizenid = v.citizenId,
--                         hash = v.hash,
--                         paymentsleft = v.paymentsleft,
--                         plate = v.plate,
--                         body = v.body,
--                         mods = v.mods,
--                         paymentamount = v.paymentamount,
--                         balance = v.balance,
--                         logs = v.logs,
--                         engine = v.engine,
--                         vehicle = v.vehicle,
--                         stored = v.stored,
--                         license = v.license,
--                         fuel = v.fuel,
--                         financetime = v.financetime
--                     })
--                 end
--             end
--         end
--     elseif Config.SharedGarages then
--         if Table == "player_vehicles" then
--             local vehiclesData = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE citizenid = ?', {citizenId})
--             if #vehiclesData >= 1 then
--                 for k, v in pairs(vehiclesData) do
--                     table.insert(vehicles, {
--                         id = v.id,
--                         depotprice = v.depotprice,
--                         garage = v.garage,
--                         citizenid = v.citizenId,
--                         hash = v.hash,
--                         paymentsleft = v.paymentsleft,
--                         plate = v.plate,
--                         body = v.body,
--                         mods = v.mods,
--                         paymentamount = v.paymentamount,
--                         balance = v.balance,
--                         logs = v.logs,
--                         engine = v.engine,
--                         vehicle = v.vehicle,
--                         state = v.state,
--                         license = v.license,
--                         fuel = v.fuel,
--                         financetime = v.financetime
--                     })
--                 end
--             end
--         else
--             local vehiclesData = MySQL.rawExecute.await('SELECT * FROM owned_vehicles WHERE owner = ?', {citizenId})
--             if #vehiclesData >= 1 then
--                 for k, v in pairs(vehiclesData) do
--                     table.insert(vehicles, {
--                         id = v.id,
--                         depotprice = v.depotprice,
--                         garage = v.garage,
--                         citizenid = v.citizenId,
--                         hash = v.hash,
--                         paymentsleft = v.paymentsleft,
--                         plate = v.plate,
--                         body = v.body,
--                         mods = v.mods,
--                         paymentamount = v.paymentamount,
--                         balance = v.balance,
--                         logs = v.logs,
--                         engine = v.engine,
--                         vehicle = v.vehicle,
--                         stored = v.stored,
--                         license = v.license,
--                         fuel = v.fuel,
--                         financetime = v.financetime
--                     })
--                 end
--             end
--         end
--     else
--         if Table == "player_vehicles" then
--             local vehiclesData = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE citizenid = ? AND garage = ?', {citizenId, garage})
--             if #vehiclesData >= 1 then
--                 for k, v in pairs(vehiclesData) do
--                     table.insert(vehicles, {
--                         id = v.id,
--                         depotprice = v.depotprice,
--                         garage = v.garage,
--                         citizenid = v.citizenId,
--                         hash = v.hash,
--                         paymentsleft = v.paymentsleft,
--                         plate = v.plate,
--                         body = v.body,
--                         mods = v.mods,
--                         paymentamount = v.paymentamount,
--                         balance = v.balance,
--                         logs = v.logs,
--                         engine = v.engine,
--                         vehicle = v.vehicle,
--                         state = v.state,
--                         license = v.license,
--                         fuel = v.fuel,
--                         financetime = v.financetime
--                     })
--                 end
--             end
--         else
--             local vehiclesData = MySQL.rawExecute.await('SELECT * FROM owned_vehicles WHERE owner = ? AND garage = ?', {citizenId, garage})
--             if #vehiclesData >= 1 then
--                 for k, v in pairs(vehiclesData) do
--                     table.insert(vehicles, {
--                         id = v.id,
--                         depotprice = v.depotprice,
--                         garage = v.garage,
--                         citizenid = v.citizenId,
--                         hash = v.hash,
--                         paymentsleft = v.paymentsleft,
--                         plate = v.plate,
--                         body = v.body,
--                         mods = v.mods,
--                         paymentamount = v.paymentamount,
--                         balance = v.balance,
--                         logs = v.logs,
--                         engine = v.engine,
--                         vehicle = v.vehicle,
--                         stored = v.stored,
--                         license = v.license,
--                         fuel = v.fuel,
--                         financetime = v.financetime
--                     })
--                 end
--             end
--         end
--     end
--     if #vehicles == 0 then
--         cb(nil)
--         return
--     end
--     if Config.ClassSystem then
--         local filteredVehicles = filterVehiclesByCategory(vehicles, category)
--         cb(filteredVehicles)
--     else
--         cb(vehicles)
--     end
-- end)

CreateCallback('exter-garage:server:GetPlayerVehicles', function(source, cb)
    local citizenId = GetPlayerCid(source)
    local VehiclesData = {}
    if Table == "player_vehicles" then
        MySQL.rawExecute('SELECT * FROM player_vehicles WHERE citizenid = ?', {citizenId}, function(result)
            if result[1] then
                for _, v in pairs(result) do
                    local VehicleData = vehiclesData[v.vehicle]
                    local VehicleGarage = Lang:t('error.no_garage')
                    if v.garage ~= nil then
                        if Config.Garages[v.garage] ~= nil then
                            VehicleGarage = Config.Garages[v.garage].label
                        else
                            VehicleGarage = Lang:t('info.house')
                        end
                    end
                    local stateTranslation
                    if v.state == 0 then
                        stateTranslation = Lang:t('status.out')
                    elseif v.state == 1 then
                        stateTranslation = Lang:t('status.garaged')
                    elseif v.state == 2 then
                        stateTranslation = Lang:t('status.impound')
                    end
                    local fullname
                    if VehicleData and VehicleData['brand'] then
                        fullname = VehicleData['brand'] .. ' ' .. VehicleData['name']
                    else
                        fullname = VehicleData and VehicleData['name'] or 'Unknown Vehicle'
                    end
                    VehiclesData[#VehiclesData + 1] = {
                        fullname = fullname,
                        brand = VehicleData and VehicleData['brand'] or '',
                        model = VehicleData and VehicleData['name'] or '',
                        plate = v.plate,
                        garage = VehicleGarage,
                        state = stateTranslation,
                        fuel = v.fuel,
                        engine = v.engine,
                        body = v.body
                    }
                end
                cb(VehiclesData)
            else
                cb(nil)
            end
        end)
    else
        MySQL.rawExecute('SELECT * FROM owned_vehicles WHERE owner = ?', {citizenId}, function(result)
            if result[1] then
                for _, v in pairs(result) do
                    local VehicleData = vehiclesData[v.vehicle.model]
                    local VehicleGarage = Lang:t('error.no_garage')
                    if v.garage ~= nil then
                        if Config.Garages[v.garage] ~= nil then
                            VehicleGarage = Config.Garages[v.garage].label
                        else
                            VehicleGarage = Lang:t('info.house')
                        end
                    end
                    local stateTranslation
                    if v.stored == 0 then
                        stateTranslation = Lang:t('status.out')
                    elseif v.stored == 1 then
                        stateTranslation = Lang:t('status.garaged')
                    elseif v.stored == 2 then
                        stateTranslation = Lang:t('status.impound')
                    end
                    local fullname
                    if VehicleData and VehicleData['brand'] then
                        fullname = VehicleData['brand'] .. ' ' .. VehicleData['name']
                    else
                        fullname = VehicleData and VehicleData['name'] or 'Unknown Vehicle'
                    end
                    VehiclesData[#VehiclesData + 1] = {
                        fullname = fullname,
                        brand = VehicleData and VehicleData['brand'] or '',
                        model = json.decode(v.vehicle).model,
                        plate = v.plate,
                        garage = VehicleGarage,
                        state = stateTranslation,
                        fuel = v.fuel,
                        engine = v.engine,
                        body = v.body
                    }
                end
                cb(VehiclesData)
            else
                cb(nil)
            end
        end)
    end
end)

local vehicleTypes = { -- https://docs.fivem.net/natives/?_0xA273060E
    motorcycles = 'bike',
    boats = 'boat',
    helicopters = 'heli',
    planes = 'plane',
    submarines = 'submarine',
    trailer = 'trailer',
    train = 'train'
}

function GetVehicleTypeByModel(model)
    local vehicleData = vehiclesData[model]
    if not vehicleData then return 'automobile' end
    local category = vehicleData.category
    local vehicleType = vehicleTypes[category]
    return vehicleType or 'automobile'
end

CreateCallback('exter-garage:server:spawnvehicle', function(source, cb, plate, vehicle, coords)
    local vehType = vehiclesData[vehicle] and vehiclesData[vehicle].type or GetVehicleTypeByModel(vehicle)
    local veh = CreateVehicleServerSetter(GetHashKey(vehicle), vehType, coords.x, coords.y, coords.z, coords.w)
    local netId = NetworkGetNetworkIdFromEntity(veh)
    local ignore = "'_./ '" 
    local plate = plate:gsub("["..ignore.."]+", "")
    SetVehicleNumberPlateText(veh, plate)
    local vehProps = {}
    if Table == "player_vehicles" then
        result = MySQL.rawExecute.await('SELECT mods FROM player_vehicles WHERE plate = ?', { plate })
    else
        result = MySQL.rawExecute.await('SELECT mods FROM owned_vehicles WHERE plate = ?', { plate })
    end
    if result and result[1] and result[1].mods then
        vehProps = json.decode(result[1].mods) 
    else
        vehProps = {}
    end
    OutsideVehicles[plate] = {netID = netId, entity = veh, plate = plate}
    
    local start = GetGameTimer()
    local timeout = 5000 -- 5 seconds timeout

    while not DoesEntityExist(veh) and (GetGameTimer() - start) < timeout do
        Citizen.Wait(0)
    end
    
    if DoesEntityExist(veh) then
        cb(netId, vehProps, plate)
    else
        DeleteEntity(veh)
        OutsideVehicles[plate] = nil
        cb(nil, nil, nil)
    end
end)

-- CreateCallback('exter-garage:server:spawnvehicle', function(source, cb, plate, vehicle, coords)
--     local vehType = vehiclesData[vehicle] and vehiclesData[vehicle].type or GetVehicleTypeByModel(vehicle)
--     local veh = CreateVehicleServerSetter(GetHashKey(vehicle), vehType, coords.x, coords.y, coords.z, coords.w)
--     local netId = NetworkGetNetworkIdFromEntity(veh)
--     local ignore = "'_./ '" 
--     local plate = plate:gsub("["..ignore.."]+", "")
--     SetVehicleNumberPlateText(veh, plate)
--     local vehProps = {}
--     if Table == "player_vehicles" then
--         result = MySQL.rawExecute.await('SELECT mods FROM player_vehicles WHERE plate = ?', { plate })
--     else
--         result = MySQL.rawExecute.await('SELECT mods FROM owned_vehicles WHERE plate = ?', { plate })
--     end
--     -- local citizenId = GetPlayerCid(source)
--     -- -- Shared Key Check
--     -- if SharedKeys[citizenId] then
--     --     for k, v in pairs(SharedKeys[citizenId]) do
--     --         if Table == "player_vehicles" then
--     --             result = MySQL.rawExecute.await('SELECT mods FROM player_vehicles WHERE plate = ?', { v })
--     --         else
--     --             result = MySQL.rawExecute.await('SELECT mods FROM owned_vehicles WHERE plate = ?', { v })
--     --         end
--     --     end
--     -- end
--     if result and result[1] and result[1].mods then
--         vehProps = json.decode(result[1].mods) 
--     else
--         vehProps = {}
--     end
--     OutsideVehicles[plate] = {netID = netId, entity = veh, plate = plate}
--     cb(netId, vehProps, plate)
-- end)

CreateCallback('exter-garage:server:IsSpawnOk', function(_, cb, plate, type)
    if OutsideVehicles[plate] and DoesEntityExist(OutsideVehicles[plate].entity) then
        cb(false)
        return
    end
    cb(true)
end)

CreateCallback('exter-garage:server:canDeposit', function(source, cb, plate, type, garage, state)
    local src = source
    local Player = GetPlayer(src)
    -- local ignore = "'_./ '" 
    -- local plate = plate:gsub("["..ignore.."]+", "")
    if Table == "player_vehicles" then
        isOwned = MySQL.scalar.await('SELECT citizenid FROM player_vehicles WHERE plate = ? LIMIT 1', { plate })
    else
        isOwned = MySQL.scalar.await('SELECT owner FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
    end
    local citizenId = GetPlayerCid(src)
    if isVehicleOwned(src, plate) == false and isVehicleOwned2(src, plate) == false then
        return cb(false)
    end
    if type == 'house' and not exports['qb-houses']:hasKey(Player.PlayerData.license, citizenId, Config.Garages[garage].houseName) then
        cb(false)
        return
    end
    if state == 1 then
        if OutsideVehicles[plate] then
            OutsideVehicles[plate] = nil
        end
        if Table == "player_vehicles" then
            MySQL.update('UPDATE player_vehicles SET state = ?, depotprice = ?, garage = ? WHERE plate = ?', {state, 0, garage, plate})
        else
            MySQL.update('UPDATE owned_vehicles SET stored = ?, pound = ?, garage = ? WHERE plate = ?', {state, 0, garage, plate})
        end
        cb(true)
    else
        cb(false)
    end
end)

function isVehicleOwned(source, plate)
    local citizenId = GetPlayerCid(source)
    if Table == "player_vehicles" then
        isOwned = MySQL.scalar.await('SELECT citizenid FROM player_vehicles WHERE plate = ? LIMIT 1', { plate })
    else
        isOwned = MySQL.scalar.await('SELECT owner FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
    end
    if isOwned ~= citizenId then
        return false
    end
    return true
end

function isVehicleOwned2(source, plate)
    local citizenId = GetPlayerCid(source)
    -- Shared Key Check
    if SharedKeys[citizenId] then
        for k, v in pairs(SharedKeys[citizenId]) do
            if v == plate then
                return true
            end
        end
    else
        return false
    end
    return false
end

-- Events
RegisterNetEvent('exter-garage:server:updateVehicleStats', function(plate, fuel, engine, body, vehicleProps)
    local src = source
    if Table == "player_vehicles" then
        local vehExist = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = ?', {plate})
        if not vehExist[1] or not vehExist then
            print("vehicle doesn't exist: " .. plate)
        end
        MySQL.update('UPDATE player_vehicles SET fuel = ?, engine = ?, body = ?, mods = ? WHERE plate = ?', {fuel, engine, body, json.encode(vehicleProps), plate})
    else
        local vehExist = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ?', {plate})
        if not vehExist[1] or not vehExist then
            print("vehicle doesn't exist: " .. plate)
        end
        MySQL.update('UPDATE owned_vehicles SET fuel = ?, engine = ?, body = ?, mods = ? WHERE plate = ?', {fuel, engine, body, json.encode(vehicleProps), plate})
    end
end)

RegisterNetEvent('exter-garage:server:updateVehicleState', function(state, plate)
    local src = source
    if Table == "player_vehicles" then
        MySQL.update('UPDATE player_vehicles SET state = ?, depotprice = ? WHERE plate = ?', {state, 0, plate})
    else
        MySQL.update('UPDATE owned_vehicles SET stored = ?, pound = ? WHERE plate = ?', {state, 0, plate})
    end
end)

RegisterNetEvent('exter-garage:server:UpdateOutsideVehicle', function(plate, vehicleNetID)
    OutsideVehicles[plate] = nil
end)

-- House Garages
RegisterNetEvent('exter-garage:server:syncGarage', function(updatedGarages)
    Config.Garages = updatedGarages
end)

-- Log
RegisterNetEvent('exter-garage:addGarageLog:server', function(data)
    local src = source
    local Player = GetPlayer(src)
    local citizenId = GetPlayerCid(src)
    if Table == "player_vehicles" then
        vehicleLogs = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ?', {citizenId, data.plate})
    else
        vehicleLogs = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ?', {citizenId, data.plate})
    end
    if vehicleLogs[1] then
        local logData = json.decode(vehicleLogs[1].logs)
        local logs = {}
        if next(logData) and next(logData) ~= nil then
            for k, v in pairs(logData) do
                logs[#logs + 1] = {
                    garage = v.garage, 
                    time = v.time, 
                    type = v.type
                }
            end
        end
        logs[#logs + 1] = {
            garage = data.garage, 
            time = os.date("!%Y-%m-%d-%H:%M"), 
            type = data.type
        }
        if Table == "player_vehicles" then
            MySQL.update('UPDATE player_vehicles SET logs = ? WHERE citizenid = ? AND plate = ?', {json.encode(logs), citizenId, data.plate})
        else
            MySQL.update('UPDATE owned_vehicles SET logs = ? WHERE owner = ? AND plate = ?', {json.encode(logs), citizenId, data.plate})
        end
    end
end)

--Call from qb-phone
while CoreReady == false do Citizen.Wait(0) end
if CoreName == "qb-core" or CoreName == "qbx_core" then
    Core.Functions.CreateCallback('exter-garage:server:GetPlayerVehicles', function(source, cb)
        local Player = GetPlayer(source)
        local VehiclesData = {}
        MySQL.rawExecute('SELECT * FROM player_vehicles WHERE citizenid = ?', { Player.PlayerData.citizenid }, function(result)
            if result[1] then
                for _, v in pairs(result) do
                    local VehicleData = vehiclesData[v.vehicle]
                    local VehicleGarage = Lang:t('error.no_garage')
                    if v.garage ~= nil then
                        if Config.Garages[v.garage] ~= nil then
                            VehicleGarage = Config.Garages[v.garage].label
                        else
                            VehicleGarage = Lang:t('info.house')
                        end
                    end
                    local stateTranslation
                    if v.state == 0 then
                        stateTranslation = Lang:t('status.out')
                    elseif v.state == 1 then
                        stateTranslation = Lang:t('status.garaged')
                    elseif v.state == 2 then
                        stateTranslation = Lang:t('status.impound')
                    end
                    local fullname
                    if VehicleData and VehicleData['brand'] then
                        fullname = VehicleData['brand'] .. ' ' .. VehicleData['name']
                    else
                        fullname = VehicleData and VehicleData['name'] or 'Unknown Vehicle'
                    end
                    VehiclesData[#VehiclesData + 1] = {
                        fullname = fullname,
                        brand = VehicleData and VehicleData['brand'] or '',
                        model = VehicleData and VehicleData['name'] or '',
                        plate = v.plate,
                        garage = VehicleGarage,
                        state = stateTranslation,
                        fuel = v.fuel,
                        engine = v.engine,
                        body = v.body
                    }
                end
                cb(VehiclesData)
            else
                cb(nil)
            end
        end)
    end)
end

function getAllGarages()
    local garages = {}
    for k, v in pairs(Config.Garages) do
        garages[#garages + 1] = {
            name = k,
            label = v.label,
            type = v.type,
            takeVehicle = v.takeVehicle,
            putVehicle = v.putVehicle,
            spawnPoint = v.spawnPoint,
            showBlip = v.showBlip,
            blipName = v.blipName,
            blipNumber = v.blipNumber,
            blipColor = v.blipColor,
            vehicle = v.vehicle
        }
    end
    return garages
end

exports('getAllGarages', getAllGarages)

RegisterNetEvent('exter-garage:wasabi:impound', function(plate)
    if Table == "player_vehicles" then
        MySQL.update('UPDATE player_vehicles SET state = 0, depotprice = ' .. Config.DepotPrice .. ' WHERE plate = ?', {plate})
    else
        MySQL.update('UPDATE owned_vehicles SET stored = 0, depotprice = ' .. Config.DepotPrice .. ' WHERE plate = ?', {plate})
    end
end)

AddEventHandler('entityRemoved', function(entity)
    for k, v in pairs(OutsideVehicles) do
        if v.netID == NetworkGetNetworkIdFromEntity(entity) then
            if Table == "player_vehicles" then
                MySQL.update('UPDATE player_vehicles SET state = ?, depotprice = ? WHERE plate = ?', { 0, Config.DepotPrice, v.plate })
            else
                MySQL.update('UPDATE owned_vehicles SET stored = ?, pound = ? WHERE plate = ? AND owner = ?', { 0, Config.DepotPrice, v.plate })
            end
            OutsideVehicles[k] = nil
        end
    end
end)

RegisterNetEvent('exter-garage:vehicleDestroyed:server', function(netId, plate)
    for k, v in pairs(OutsideVehicles) do
        if v.netID == netId then
            if Table == "player_vehicles" then
                MySQL.update('UPDATE player_vehicles SET state = ?, depotprice = ? WHERE plate = ?', { 0, Config.DepotPrice, plate })
            else
                MySQL.update('UPDATE owned_vehicles SET stored = ?, pound = ? WHERE plate = ? AND owner = ?', { 0, Config.DepotPrice, plate })
            end
            OutsideVehicles[k] = nil
        end
    end
end)

RegisterNetEvent('exter-garage:removeMoney:server', function(data)
    local src = source
    local playerMoney = GetPlayerMoney(src, data.moneyType)
    if playerMoney < data.moneyAmount then return Notify(src, Lang:t('error.not_enough'), 7500, 'error') end
    RemoveMoney(src, data.moneyType, data.moneyAmount, "paid-depot")
    TriggerClientEvent('exter-garage:client:takeOutGarage', src, data)
end)

CreateCallback('exter-garage:getNearbyPlayerDatas:server', function(source, cb, nearbyPlayers)
    local nearbyPlayers2 = {}
    for _, id in pairs(nearbyPlayers) do
        local numPlayerId = tonumber(id)
        local numPlayerName = GetCharName(numPlayerId)
        local numPlayerCitizenId = GetPlayerCid(numPlayerId)
        table.insert(nearbyPlayers2, {
            id = numPlayerId,
            name = numPlayerName,
            cid = numPlayerCitizenId
        })
    end
    cb(nearbyPlayers2)
end)

RegisterNetEvent('exter-garage:shareVehicleKey:server', function(data)
    local src = source
    local citizenId = GetPlayerCid(src)
    -- Shared Key Check
    local sharedVehicleKeys = MySQL.query.await('SELECT * FROM exter_garage_shared_keys WHERE plate = ?', {data.plate})
    if sharedVehicleKeys[1] then
        local playersTable = {}
        local name = GetPlayerNameByS(data.cid)
        for _, v in pairs(sharedVehicleKeys) do
            v.players = json.decode(v.players)
            for _, p in pairs(v.players) do
                if p == data.cid then
                    return Notify(src, Lang:t("error.already_has_key", {name = name}), 7500, "error")
                else
                    table.insert(playersTable, p)
                    if not SharedKeys[data.cid] then SharedKeys[data.cid] = {} end
                    table.insert(SharedKeys[p], data.plate)
                end
            end
        end
        Notify(src, Lang:t("success.key_shared", {name = name}), 7500, "success")
        if data.targetId then
            Notify(data.targetId, Lang:t("success.received_key_for_vehicle", {plate = data.plate}), 7500, "success")
        end
        playersTable[#playersTable + 1] = data.cid
        MySQL.update('UPDATE exter_garage_shared_keys SET players = ? WHERE plate = ?', {json.encode(playersTable), data.plate})
    else
        local playersTable = {}
        playersTable[#playersTable + 1] = data.cid
        local name = GetPlayerNameByS(data.cid)
        if not SharedKeys[data.cid] then SharedKeys[data.cid] = {} end
        table.insert(SharedKeys[data.cid], data.plate)
        Notify(src, Lang:t("success.key_shared", {name = name}), 7500, "success")
        if data.targetId then
            Notify(data.targetId, Lang:t("success.received_key_for_vehicle", {plate = data.plate}), 7500, "success")
        end
        MySQL.insert('INSERT INTO exter_garage_shared_keys (owner, plate, players) VALUES (:owner, :plate, :players)', {
            owner = citizenId,
            plate = data.plate,
            players = json.encode(playersTable)
        })
    end
end)

RegisterNetEvent('exter-garage:removeVehicleKey:server', function(data)
    local src = source
    local citizenId = GetPlayerCid(src)
    -- Shared Key Check
    local sharedVehicleKeys = MySQL.query.await('SELECT * FROM exter_garage_shared_keys WHERE plate = ?', {data.plate})
    if sharedVehicleKeys[1] then
        local playersTable = {}
        for _, v in pairs(sharedVehicleKeys) do
            v.players = json.decode(v.players)
            for _, p in pairs(v.players) do
                if not p == data.cid then
                    table.insert(playersTable, p)
                end
            end
        end
        local playerKeys = SharedKeys[data.cid]
        SharedKeys[data.cid] = {}
        for k, v in pairs(playerKeys) do
            if v ~= data.plate then
                table.insert(SharedKeys[data.cid], v)
            end
        end
        local name = GetPlayerNameByS(data.cid)
        Notify(src, Lang:t("success.key_removed", {name = name}), 7500, "success")
        --Notify(data.id, Lang:t("success.received_key_for_vehicle", {plate = plate}), 7500, "success")
        if next(playersTable) then
            MySQL.update('UPDATE exter_garage_shared_keys SET players = ? WHERE plate = ?', {json.encode(playersTable), data.plate})
        else
            MySQL.rawExecute.await('DELETE FROM exter_garage_shared_keys WHERE plate = ?', {data.plate})
        end
    end
end)

CreateCallback('exter-garage:getSharedVehicleKeys:server', function(source, cb, plate)
    -- Shared Key Check
    local playersTable = {}
    local sharedVehicleKeys = MySQL.query.await('SELECT * FROM exter_garage_shared_keys WHERE plate = ?', {plate})
    if sharedVehicleKeys[1] then
        for k, v in pairs(sharedVehicleKeys) do
            v.players = json.decode(v.players)
            for _, p in pairs(v.players) do
                local name = GetPlayerNameByS(p)
                table.insert(playersTable, {
                    plate = v.plate,
                    name = name,
                    cid = p
                })
            end
        end
    end
    cb(playersTable)
end)

Citizen.CreateThread(function()
    local sharedVehicleKeys = MySQL.query.await('SELECT * FROM exter_garage_shared_keys', {})
    for _, v in pairs(sharedVehicleKeys) do
        v.players = json.decode(v.players)
        for _, p in pairs(v.players) do
            if not SharedKeys[p] then
                SharedKeys[p] = {}
            end
            table.insert(SharedKeys[p], v.plate)
        end
    end
end)

AddEventHandler('onResourceSop', function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(OutsideVehicles) do
            if Table == "player_vehicles" then
                MySQL.update('UPDATE player_vehicles SET state = ?, depotprice = ? WHERE plate = ?', {0, Config.DepotPrice, v})
            else
                MySQL.update('UPDATE owned_vehicles SET stored = ?, pound = ? WHERE plate = ? AND owner = ?', {0, Config.DepotPrice, v})
            end
        end
    end
end)

function getGarages()
    return Config.Garages
end

exports('getGarages', getGarages)

Citizen.CreateThread(function()
    while not CoreReady do Citizen.Wait(0) end
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        Core.Commands.Add('setplate', 'Set vehicle plate', {{name = 'Plate', help = 'Number plate text for search'}, {name = 'Plate', help = 'Number plate text for changing'}}, true, function(source, args)
            if args[1] and args[2] then
                local vehicleData = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE plate = ?', {args[1]})
                if vehicleData[1] then
                    local mods = json.decode(vehicleData[1].mods)
                    mods.plate = args[2]
                    print("Plate successfuly changed from: " .. args[1] .. ", to: " .. args[2])
                    MySQL.update('UPDATE player_vehicles SET plate = ?, mods = ? WHERE plate = ?', {args[2], json.encode(mods), args[1]})
                    local sharedVehicleKeys = MySQL.query.await('SELECT * FROM exter_garage_shared_keys WHERE plate = ?', {args[1]})
                    if sharedVehicleKeys[1] then
                        MySQL.update('UPDATE exter_garage_shared_keys SET plate = ? WHERE plate = ?', {args[2], args[1]})
                        sharedVehicleKeys[1].players = json.decode(sharedVehicleKeys[1].players)
                        for _, p in pairs(sharedVehicleKeys[1].players) do
                            local playerKeys = SharedKeys[p]
                            SharedKeys[p] = {}
                            for k, v in pairs(playerKeys) do
                                if v ~= args[1] then
                                    table.insert(SharedKeys[p], v)
                                end
                            end
                            table.insert(SharedKeys[p], args[2])
                        end
                    end
                    if OutsideVehicles[args[1]] then
                        DeleteEntity(OutsideVehicles[args[1]].entity)
                        OutsideVehicles[args[1]] = nil
                        MySQL.update('UPDATE player_vehicles SET state = ?, depotprice = ? WHERE plate = ?', {1, 0, args[2]})
                    end 
                end
            end
        end, 'admin')
    elseif CoreName == "es_extended" then
        Core.RegisterCommand("setplate", "admin", function(xPlayer, args, showError)
            if args.plate and args.plate2 then
                local vehicleData = MySQL.rawExecute.await('SELECT * FROM player_vehicles WHERE plate = ?', {args.plate})
                if vehicleData[1] then
                    local mods = json.decode(vehicleData[1].mods)
                    mods.plate = args.plate2
                    print("Plate successfuly changed from: " .. args.plate .. ", to: " .. args.plate2)
                    MySQL.update('UPDATE player_vehicles SET plate = ?, mods = ? WHERE plate = ?', {args.plate2, json.encode(mods), args.plate})
                    local sharedVehicleKeys = MySQL.query.await('SELECT * FROM exter_garage_shared_keys WHERE plate = ?', {args[1]})
                    if sharedVehicleKeys[1] then
                        MySQL.update('UPDATE exter_garage_shared_keys SET plate = ? WHERE plate = ?', {args.plate2, args.plate})
                        sharedVehicleKeys[1].players = json.decode(sharedVehicleKeys[1].players)
                        for _, p in pairs(sharedVehicleKeys[1].players) do
                            local playerKeys = SharedKeys[p]
                            SharedKeys[p] = {}
                            for k, v in pairs(playerKeys) do
                                if v ~= args.plate then
                                    table.insert(SharedKeys[p], v)
                                end
                            end
                            table.insert(SharedKeys[p], args.plate2)
                        end
                    end
                    if OutsideVehicles[args.plate] then
                        DeleteEntity(OutsideVehicles[args.plate].entity)
                        OutsideVehicles[args.plate] = nil
                        MySQL.update('UPDATE player_vehicles SET state = ?, depotprice = ? WHERE plate = ?', {1, 0, args.plate2})
                    end 
                end
            end
        end, true, {
            help = 'Set vehicle plate',
            validate = true,
            arguments = {
                {name = "plate", help = 'Number plate text for search', type = "string"},
                {name = "plate2", help = 'Number plate text for changing', type = "string"}
            },
        }
    )
    end
end)