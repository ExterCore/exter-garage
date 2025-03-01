local garageZones = {}
local vehicleLimits = nil
local listenForKey = false
-- Handlers
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    CreateBlipsZones()
end)

RegisterNetEvent('esx:playerLoaded', function()
    CreateBlipsZones()
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    while CoreReady == false do Citizen.Wait(0) end
    CreateBlipsZones()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if Config.RadialMenu.Enable then
            Config.RemoveRadialOptions()
        end
    end
end)

AddEventHandler('gameEventTriggered', function(event, data)
    local ignore = "'_./ '" 
    if event == "CEventNetworkVehicleUndrivable" then
        local vehicle = data[1]
        local plate = GetVehicleNumberPlateText(vehicle):gsub("["..ignore.."]+", "")
        TriggerServerEvent('exter-garage:vehicleDestroyed:server', NetworkGetNetworkIdFromEntity(vehicle), plate)
    end
    if event == "CEventNetworkEntityDamage" then
        local vehicle = data[1]
        if GetVehicleBodyHealth(vehicle) == 0 then
            local plate = GetVehicleNumberPlateText(vehicle):gsub("["..ignore.."]+", "")
            TriggerServerEvent('exter-garage:vehicleDestroyed:server', NetworkGetNetworkIdFromEntity(vehicle), plate)
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
    PlayerGang = gang
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    PlayerJob = job
end)

-- Functions
function round(num, numDecimalPlaces)
    return tonumber(string.format('%.' .. (numDecimalPlaces or 0) .. 'f', num))
end

local currentZoneData = nil
RegisterNetEvent('exter-garage:openMenu', function(data)
    if currentZoneData then
        if GetVehiclePedIsUsing(PlayerPedId()) ~= 0 then
            if currentZoneData.type == 'depot' then return end
            local currentVehicle = GetVehiclePedIsUsing(PlayerPedId())
            if not IsVehicleAllowed(currentZoneData.category, currentVehicle) then
                Notify(Lang:t('error.not_correct_type'), 3500, 'error')
                return
            end
            DepositVehicle(currentVehicle, currentZoneData)
        else
            OpenGarageMenu(currentZoneData)
        end
    else
        Notify(Lang:t('error.no_garage_nearby'), 5000, 'error')
    end
end)

function OpenGarageMenu(data)
    if data.type == "jobfree" then
        local vehicles = {}
        playerGrade = GetPlayerGrade()
        for k, v in pairs(Config.Garages[data.indexgarage].vehiclesData[playerGrade].vehicles) do
            local vname = nil
            if CoreName == "es_extended" then
                vehicle = string.lower(v)
                state = "Stored"
            else
                vehicle = v
                state = "Stored"
            end
            if vehiclesData[vehicle] then
                pcall(function()
                    vname = vehiclesData[vehicle].name
                end)
                if vehiclesData[vehicle].brand then
                    vname = vehiclesData[vehicle].brand .. " " .. vehiclesData[vehicle].name
                end
            else
                vname = vehicle
            end
            local plate = v
            if Config.Garages[data.indexgarage].vehiclesData[playerGrade].customPlate then
                if Config.Garages[data.indexgarage].vehiclesData[playerGrade].customPlate.enable then
                    plate = Config.Garages[data.indexgarage].vehiclesData[playerGrade].customPlate.plate()
                end
            end
            table.insert(vehicles, {
                vehicle = v,
                state = 1,
                depotPrice = 0,
                vehicleLabel = vname or vehicle,
                type = data.type,
                index = data.indexgarage,
                engine = 1000,
                body = 1000,
                fuel = 100,
                plate = plate,
                plateIndex = 2,
                limit = Config.Garages[data.indexgarage].vehiclesData[playerGrade].limit,
                shared = false
            })
        end
        if vehicleLimits == nil then
            vehicleLimits = Config.Garages[data.indexgarage].vehiclesData[playerGrade].limit
        end
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'VehicleListJob',
            garageLabel = Config.Garages[data.indexgarage].label,
            vehicles = vehicles,
            vehNum = Config.Garages[data.indexgarage].vehiclesData[playerGrade].limit,
            limit = vehicleLimits,
            garageType = "job",
            useCarImg = Config.VehicleImages.Enable,
            useCustomCarImg = Config.VehicleImages.UseCustomImages
        })
    else
        PlayerData = GetPlayerData()
        PlayerGang = PlayerData.gang
        PlayerJob = PlayerData.job
        if data.job then
            if data.type == "job" then
                if PlayerJob.name ~= data.job then
                    return false
                end
            elseif data.type == "gang" then
                if PlayerGang.name ~= data.job then
                    return false
                end
            end
        end
        TriggerCallback('exter-garage:server:GetGarageVehicles', function(result)
            if result == nil then return Notify(Lang:t('error.no_vehicles'), 5000, 'error') end
            local formattedVehicles = {}
            for _, v in pairs(result) do
                local enginePercent = round(v.engine, 0)
                local bodyPercent = round(v.body, 0)
                local vname = nil
                if CoreName == "es_extended" then
                    local vehData = json.decode(v.vehicle)
                    if vehData and next(vehData) then
                        vehicle = string.lower(GetDisplayNameFromVehicleModel(vehData.model))
                    else
                        vehicle = v.vehicle
                    end
                    state = v.stored
                else
                    vehicle = v.vehicle
                    state = v.state
                end
                if vehiclesData[vehicle] then
                    pcall(function()
                        vname = vehiclesData[vehicle].name
                    end)
                    if vehiclesData[vehicle].brand then
                        vname = vehiclesData[vehicle].brand .. " " .. vehiclesData[vehicle].name
                    end
                else
                    vname = vehicle
                end
                local mods = json.decode(v.mods) or {}
                local logs = json.decode(v.logs)
                table.sort(logs, function(a, b) return a.time > b.time end)
                formattedVehicles[#formattedVehicles + 1] = {
                    vehicle = vehicle,
                    vehClass = GetVehicleClassFromName(GetHashKey(vehicle)),
                    vehicleLabel = vname or vehicle,
                    plate = v.plate,
                    plateIndex = mods.plateIndex or 0,
                    state = state,
                    fuel = v.fuel or 100,
                    engine = enginePercent or 1000,
                    body = bodyPercent or 1000,
                    distance = v.drivingdistance or 0,
                    garage = Config.Garages[data.indexgarage],
                    type = data.type,
                    index = data.indexgarage,
                    depotPrice = v.depotprice or 0,
                    balance = v.balance or 0,
                    logs = logs,
                    shared = v.shared or false
                }
            end
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'VehicleList',
                garageLabel = Config.Garages[data.indexgarage].label,
                vehicles = formattedVehicles,
                vehNum = #formattedVehicles,
                garageType = data.type,
                useCarImg = Config.VehicleImages.Enable,
                useCustomCarImg = Config.VehicleImages.UseCustomImages
            })
        end, data.indexgarage, data.type, data.category)
    end
end

function IsVehicleAllowed(classList, vehicle)
    if not Config.ClassSystem then return true end
    for _, class in ipairs(classList) do
        if GetVehicleClass(vehicle) == class then
            return true
        end
    end
    return false
end

function CreateBlips(setloc)
    local Garage = AddBlipForCoord(setloc.takeVehicle.x, setloc.takeVehicle.y, setloc.takeVehicle.z)
    SetBlipSprite(Garage, setloc.blipNumber)
    SetBlipDisplay(Garage, 4)
    SetBlipScale(Garage, 0.60)
    SetBlipAsShortRange(Garage, true)
    SetBlipColour(Garage, setloc.blipColor)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(setloc.blipName)
    EndTextCommandSetBlipName(Garage)
end

function CreateZone(index, garage, zoneType, job)
    if zoneType == "job" or zoneType == "jobfree" or zoneType == "gang" then
        local zone = CircleZone:Create(garage.takeVehicle, 10.0, {
            name = zoneType .. '_' .. index,
            debugPoly = false,
            useZ = true,
            data = {
                indexgarage = index,
                type = garage.type,
                category = garage.category,
                job = job,
                type = zoneType
            }
        })
        return zone
    else
        local zone = CircleZone:Create(garage.takeVehicle, 10.0, {
            name = zoneType .. '_' .. index,
            debugPoly = false,
            useZ = true,
            data = {
                indexgarage = index,
                type = garage.type,
                category = garage.category
            }
        })
        return zone
    end
end

function CreateBlipsZones()
    while CoreReady == false do Citizen.Wait(0) end
    PlayerData = GetPlayerData()
    PlayerGang = PlayerData.gang
    PlayerJob = PlayerData.job
    for index, garage in pairs(Config.Garages) do
        local zone
        if garage.showBlip then
            CreateBlips(garage)
        end
        if garage.type == 'job' then
            zone = CreateZone(index, garage, garage.type, garage.job)
        elseif garage.type == 'gang' then
            zone = CreateZone(index, garage, 'gang', garage.job)
        elseif garage.type == 'jobfree' then
            zone = CreateZone(index, garage, garage.type, garage.job)
        elseif garage.type == 'depot' then
            if Config.DepotMenuType == "menu" then
                zone = CreateDepotZone(index, garage, 'depot')
            else
                garage.Interaction = {}
                garage.takeVehicle = vector3(garage.takeVehicle.x, garage.takeVehicle.y, garage.takeVehicle.z)
                zone = CreateZone(index, garage, 'depot')
            end
        elseif garage.type == 'public' then
            zone = CreateZone(index, garage, 'public')
        end
        if zone then
            garageZones[#garageZones + 1] = zone
        end
    end
    local comboZone = ComboZone:Create(garageZones, { name = 'garageCombo', debugPoly = false })
    comboZone:onPlayerInOut(function(isPointInside, _, zone)
        if isPointInside then
            currentZoneData = zone.data
            -- if zone.data.job then
            --     if zone.data.type == "job" then
            --         if not PlayerJob.name == zone.data.job then
            --             return false
            --         end
            --     elseif zone.data.type == "gang" then
            --         if not PlayerGang.name == zone.data.job then
            --             return false
            --         end
            --     end
            -- end
            listenForKey = true
            CreateThread(function()
                while listenForKey do
                    Citizen.Wait(0)
                    if IsControlJustReleased(0, 38) then
                        if GetVehiclePedIsUsing(PlayerPedId()) ~= 0 then
                            if zone.data.type == 'depot' then return end
                            local currentVehicle = GetVehiclePedIsUsing(PlayerPedId())
                            if not IsVehicleAllowed(zone.data.category, currentVehicle) then
                                Notify(Lang:t('error.not_correct_type'), 3500, 'error')
                                return
                            end
                            DepositVehicle(currentVehicle, zone.data)
                        else
                            OpenGarageMenu(zone.data)
                        end
                    end
                end
            end)

            local displayText = Lang:t('info.car_e')
            if zone.data.vehicle == 'sea' then
                displayText = Lang:t('info.sea_e')
            elseif zone.data.vehicle == 'air' then
                displayText = Lang:t('info.air_e')
            elseif zone.data.vehicle == 'rig' then
                displayText = Lang:t('info.rig_e')
            elseif zone.data.type == 'depot' then
                displayText = Lang:t('info.depot_e')
            end
            if Config.RadialMenu.Enable then
                listenForKey = false
                Config.AddRadialOptions(zone.data)
                if Config.RadialMenu.DrawText then
                    SendNUIMessage({action = "textUI", show = true, text = displayText, key = Config.RadialMenu.KeyLabel}) 
                end
            else
                SendNUIMessage({action = "textUI", show = true, text = displayText}) 
            end
        else
            currentZoneData = nil
            if Config.RadialMenu.Enable then
                Config.RemoveRadialOptions()
                if Config.RadialMenu.DrawText then
                    SendNUIMessage({action = "textUI", show = false})
                end
            else
                listenForKey = false
                SendNUIMessage({action = "textUI", show = false})
            end
        end
    end)
end

RegisterNetEvent('exter-garage:DepositVehicle:client', function(args)
    if GetVehiclePedIsUsing(PlayerPedId()) ~= 0 then
        if args.zData.type == 'depot' then return end
        local currentVehicle = GetVehiclePedIsUsing(PlayerPedId())
        if not IsVehicleAllowed(args.zData.category, currentVehicle) then
            Notify(Lang:t('error.not_correct_type'), 3500, 'error')
            return
        end
        DepositVehicle(currentVehicle, args.zData)
    else
        OpenGarageMenu(args.zData)
    end
end)

function DepositVehicle(veh, data)
    local ignore = "'_./ '" 
    local plate = GetVehicleNumberPlateText(veh):gsub("["..ignore.."]+", "")
    if data.type == "jobfree" then
        CheckPlayers(veh)
        if not vehicleLimits then
            vehicleLimits = 0
        end
        vehicleLimits = vehicleLimits + 1
        return
    end
    TriggerCallback('exter-garage:server:canDeposit', function(canDeposit)
        if canDeposit then
            local vehicleData = string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(veh)))
            local bodyDamage = math.ceil(GetVehicleBodyHealth(veh))
            local engineDamage = math.ceil(GetVehicleEngineHealth(veh))
            local totalFuel = GetFuel(veh)
            local props = GetVehicleProperties(veh)
            Citizen.Wait(500)
            TriggerServerEvent('exter-garage:server:updateVehicleStats', plate, totalFuel, engineDamage, bodyDamage, props)
            TriggerServerEvent('exter-garage:server:UpdateOutsideVehicle', plate, nil)
            for i = -1, 5, 1 do
                local seat = GetPedInVehicleSeat(veh, i)
                if seat then
                    TaskLeaveVehicle(seat, veh, 0)
                end
            end
            Citizen.Wait(1500)
            NetworkFadeOutEntity(veh, false, true)
            Citizen.Wait(2000)
            CheckPlayers(veh)
            TriggerServerEvent('exter-garage:addGarageLog:server', {plate = plate, garage = Config.Garages[data.indexgarage].label, type = "Stored"})
            if vehiclesData[vehicleData] then
            else
            end
        else
            Notify(Lang:t('error.not_owned'), 3500, 'error')
        end
    end, plate, data.type, data.indexgarage, 1)
end

function CheckPlayers(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

function doCarDamage(currentVehicle, stats, props)
    local engine = stats.engine + 0.0
    local body = stats.body + 0.0
    SetVehicleEngineHealth(currentVehicle, engine)
    SetVehicleBodyHealth(currentVehicle, body)
    if not next(props) then return end
    if props.doorStatus then
        for k, v in pairs(props.doorStatus) do
            if v then SetVehicleDoorBroken(currentVehicle, tonumber(k), true) end
        end
    end
    if props.tireBurstState then
        for k, v in pairs(props.tireBurstState) do
            if v then SetVehicleTyreBurst(currentVehicle, tonumber(k), true) end
        end
    end
    if props.windowStatus then
        for k, v in pairs(props.windowStatus) do
            if not v then SmashVehicleWindow(currentVehicle, tonumber(k)) end
        end
    end
end

function GetSpawnPoint(garage)
    local location = nil
    if garage then
        if #garage.spawnPoint > 1 then
            local maxTries = #garage.spawnPoint
            for i = 1, maxTries do
                local randomIndex = math.random(1, #garage.spawnPoint)
                local chosenSpawnPoint = garage.spawnPoint[randomIndex]
                local isOccupied = IsPositionOccupied(
                    chosenSpawnPoint.x,
                    chosenSpawnPoint.y,
                    chosenSpawnPoint.z,
                    5.0,   -- range
                    false,
                    true,  -- checkVehicles
                    false, -- checkPeds
                    false,
                    false,
                    0,
                    false
                )
                if not isOccupied then
                    location = chosenSpawnPoint
                    break
                end
            end
        elseif #garage.spawnPoint == 1 then
            location = garage.spawnPoint[1]
        end
    end
    if not location then
        Notify(Lang:t('error.vehicle_occupied'), 7500, 'error')
    end
    return location
end

-- Events
RegisterNetEvent('exter-garage:client:trackVehicle', function(coords)
    SetNewWaypoint(coords.x, coords.y)
end)

local function CheckPlate(vehicle, plateToSet)
    local vehiclePlate = promise.new()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500)
            -- local plateToSet = plateToSet:gsub(" $", "")
            -- local plateVeh = GetVehicleNumberPlateText(vehicle):gsub(" $", "")
            local ignore = "'_./ '" 
            local plateToSet = plateToSet:gsub("["..ignore.."]+", "")
            local plateVeh = GetVehicleNumberPlateText(vehicle):gsub("["..ignore.."]+", "")
            if plateVeh == plateToSet then
                vehiclePlate:resolve(true)
                return
            else
                SetVehicleNumberPlateText(vehicle, plateToSet)
            end
        end
    end)
    return vehiclePlate
end

RegisterNetEvent('exter-garage:client:takeOutGarage', function(data)
    if data.type == "jobfree" then
        local location = GetSpawnPoint(Config.Garages[data.index])
        if not location then return end
        if vehicleLimits == 0 then return Notify(Lang:t('error.not_enough_limits'), 5000, 'error') end
        TriggerCallback('exter-garage:server:spawnvehicle', function(netId, properties, vehPlate)
            while not NetworkDoesNetworkIdExist(netId) do Wait(10) end
            local veh = NetToVeh(netId)
            --SetVehicleProperties(veh, properties)
            SetFuel(veh, data.stats.fuel)
            local ignore = "'_./ '" 
            local vehPlateKey = GetVehicleNumberPlateText(veh) 
            vehPlateKey = vehPlateKey:gsub("["..ignore.."]+", "") -- Don't edit or delete
            GiveKey(veh, vehPlateKey)
            if Config.Warp then TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1) end
            SetVehicleEngineOn(veh, true, true, false)
            vehicleLimits = vehicleLimits - 1
            Config.Garages[data.index].vehiclesData[tonumber(playerGrade)].setVehMods(veh)
            Config.OnVehicleSpawn(veh)
        end, data.plate, data.vehicle, location, true)
    else
        TriggerCallback('exter-garage:server:IsSpawnOk', function(spawn)
            if spawn then
                local location = GetSpawnPoint(Config.Garages[data.index])
                if not location then return end
                TriggerCallback('exter-garage:server:spawnvehicle', function(netId, properties, vehPlate)
                    while not NetworkDoesNetworkIdExist(netId) do Wait(10) end
                    local veh = NetToVeh(netId)
                    while not DoesEntityExist(veh) do Citizen.Wait(0) end
                    local ignore = "'_./ '" 
                    vehPlate = vehPlate:gsub("["..ignore.."]+", "")
                    Citizen.Await(CheckPlate(veh, vehPlate))
                    SetVehicleProperties(veh, properties)
                    SetFuel(veh, data.stats.fuel)
                    TriggerServerEvent('exter-garage:server:updateVehicleState', 0, vehPlate)
                    local ignore = "'_./ '" 
                    local vehPlateKey = GetVehicleNumberPlateText(veh) 
                    vehPlateKey = vehPlateKey:gsub("["..ignore.."]+", "") -- Don't edit or delete
                    GiveKey(veh, vehPlateKey)
                    if Config.Warp then TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1) end
                    if Config.VisuallyDamageCars then doCarDamage(veh, data.stats, properties) end
                    SetVehicleEngineOn(veh, true, true, false)
                    if data.type == "depot" then
                        TriggerServerEvent('exter-garage:addGarageLog:server', {plate = vehPlate, garage = Config.Garages[data.index].label, type = "Take Depot"})
                    else
                        TriggerServerEvent('exter-garage:addGarageLog:server', {plate = vehPlate, garage = Config.Garages[data.index].label, type = "Take Out"})
                    end
                    Config.OnVehicleSpawn(veh)
                end, data.plate, data.vehicle, location, true)
            else
                Notify(Lang:t('error.not_depot'), 5000, 'error')
            end
        end, data.plate, data.type)
    end
end)

-- Housing functions
local houseGarageZones = {}
local listenForKeyHouse = false
local houseComboZones = nil

local function CreateHouseZone(index, garage, zoneType, houseName)
    local houseZone = CircleZone:Create(garage.takeVehicle, 5.0, {
        name = zoneType .. '_' .. index,
        debugPoly = false,
        useZ = true,
        data = {
            indexgarage = index,
            type = zoneType,
            category = garage.category,
            houseName = houseName
        }
    })

    if houseZone then
        houseGarageZones[#houseGarageZones + 1] = houseZone

        if not houseComboZones then
            houseComboZones = ComboZone:Create(houseGarageZones, { name = 'houseComboZones', debugPoly = false })
        else
            houseComboZones:AddZone(houseZone)
        end
    end

    houseComboZones:onPlayerInOut(function(isPointInside, _, zone)
        if isPointInside then
            listenForKeyHouse = true
            CreateThread(function()
                while listenForKeyHouse do
                    Wait(0)
                    if IsControlJustReleased(0, 38) then
                        if GetVehiclePedIsUsing(PlayerPedId()) ~= 0 then
                            local currentVehicle = GetVehiclePedIsUsing(PlayerPedId())
                            DepositVehicle(currentVehicle, zone.data)
                        else
                            OpenGarageMenu(zone.data)
                        end
                    end
                end
            end)
            SendNUIMessage({action = "textUI", show = true, text = Lang:t('info.house_garage')})
        else
            listenForKeyHouse = false
            SendNUIMessage({action = "textUI", show = false})
        end
    end)
end

local function ZoneExists(zoneName)
    for _, zone in ipairs(houseGarageZones) do
        if zone.name == zoneName then
            return true
        end
    end
    return false
end

local function RemoveHouseZone(zoneName)
    local removedZone = houseComboZones:RemoveZone(zoneName)
    if removedZone then
        removedZone:destroy()
    end
    for index, zone in ipairs(houseGarageZones) do
        if zone.name == zoneName then
            table.remove(houseGarageZones, index)
            break
        end
    end
end

RegisterNetEvent('exter-garage:client:setHouseGarage', function(house, hasKey) -- event sent periodically from housing
    if not house then return end
    local formattedHouseName = string.gsub(string.lower(house), ' ', '')
    local zoneName = 'house_' .. formattedHouseName
    if Config.Garages[formattedHouseName] then
        if hasKey and not ZoneExists(zoneName) then
            CreateHouseZone(formattedHouseName, Config.Garages[formattedHouseName], 'house', formattedHouseName)
        elseif not hasKey and ZoneExists(zoneName) then
            RemoveHouseZone(zoneName)
        end
    else
        TriggerCallback('exter-garage:server:getHouseGarage', function(garageInfo) -- create garage if not exist
            local garageCoords = json.decode(garageInfo.garage)
            if garageCoords then
                Config.Garages[formattedHouseName] = {
                    houseName = house,
                    takeVehicle = vector3(garageCoords.x, garageCoords.y, garageCoords.z),
                    spawnPoint = {
                        vector4(garageCoords.x, garageCoords.y, garageCoords.z, garageCoords.w or garageCoords.h)
                    },
                    label = garageInfo.label,
                    type = 'house',
                    category = Config.VehicleClasses['all']
                }
                TriggerServerEvent('exter-garage:server:syncGarage', Config.Garages)
            end
        end, house)
    end
end)

RegisterNetEvent('qb-garages:client:setHouseGarage', function(house, hasKey) -- event sent periodically from housing
    if not house then return end
    local formattedHouseName = string.gsub(string.lower(house), ' ', '')
    local zoneName = 'house_' .. formattedHouseName
    if Config.Garages[formattedHouseName] then
        if hasKey and not ZoneExists(zoneName) then
            CreateHouseZone(formattedHouseName, Config.Garages[formattedHouseName], 'house', formattedHouseName)
        elseif not hasKey and ZoneExists(zoneName) then
            RemoveHouseZone(zoneName)
        end
    else
        TriggerCallback('exter-garage:server:getHouseGarage', function(garageInfo) -- create garage if not exist
            local garageCoords = json.decode(garageInfo.garage)
            if garageCoords then
                Config.Garages[formattedHouseName] = {
                    houseName = house,
                    takeVehicle = vector3(garageCoords.x, garageCoords.y, garageCoords.z),
                    spawnPoint = {
                        vector4(garageCoords.x, garageCoords.y, garageCoords.z, garageCoords.w or garageCoords.h)
                    },
                    label = garageInfo.label,
                    type = 'house',
                    category = Config.VehicleClasses['all']
                }
                TriggerServerEvent('exter-garage:server:syncGarage', Config.Garages)
            end
        end, house)
    end
end)

RegisterNetEvent('exter-garage:client:houseGarageConfig', function(houseGarages)
    for _, garageConfig in pairs(houseGarages) do
        local formattedHouseName = string.gsub(string.lower(garageConfig.label), ' ', '')
        if garageConfig.takeVehicle and garageConfig.takeVehicle.x and garageConfig.takeVehicle.y and garageConfig.takeVehicle.z and garageConfig.takeVehicle.w then
            Config.Garages[formattedHouseName] = {
                houseName = house,
                takeVehicle = vector3(garageConfig.takeVehicle.x, garageConfig.takeVehicle.y, garageConfig.takeVehicle.z),
                spawnPoint = {
                    vector4(garageConfig.takeVehicle.x, garageConfig.takeVehicle.y, garageConfig.takeVehicle.z, garageConfig.takeVehicle.w)
                },
                label = garageConfig.label,
                type = 'house',
                category = Config.VehicleClasses['all']
            }
        end
    end
    TriggerServerEvent('exter-garage:server:syncGarage', Config.Garages)
end)

RegisterNetEvent('qb-garages:client:houseGarageConfig', function(houseGarages)
    for _, garageConfig in pairs(houseGarages) do
        local formattedHouseName = string.gsub(string.lower(garageConfig.label), ' ', '')
        if garageConfig.takeVehicle and garageConfig.takeVehicle.x and garageConfig.takeVehicle.y and garageConfig.takeVehicle.z and garageConfig.takeVehicle.w then
            Config.Garages[formattedHouseName] = {
                houseName = house,
                takeVehicle = vector3(garageConfig.takeVehicle.x, garageConfig.takeVehicle.y, garageConfig.takeVehicle.z),
                spawnPoint = {
                    vector4(garageConfig.takeVehicle.x, garageConfig.takeVehicle.y, garageConfig.takeVehicle.z, garageConfig.takeVehicle.w)
                },
                label = garageConfig.label,
                type = 'house',
                category = Config.VehicleClasses['all']
            }
        end
    end
    TriggerServerEvent('exter-garage:server:syncGarage', Config.Garages)
end)

RegisterNetEvent('exter-garage:client:addHouseGarage', function(house, garageInfo) -- event from housing on garage creation
    local formattedHouseName = string.gsub(string.lower(house), ' ', '')
    Config.Garages[formattedHouseName] = {
        houseName = house,
        takeVehicle = vector3(garageInfo.takeVehicle.x, garageInfo.takeVehicle.y, garageInfo.takeVehicle.z),
        spawnPoint = {
            vector4(garageInfo.takeVehicle.x, garageInfo.takeVehicle.y, garageInfo.takeVehicle.z, garageInfo.takeVehicle.w)
        },
        label = garageInfo.label,
        type = 'house',
        category = Config.VehicleClasses['all']
    }
    TriggerServerEvent('exter-garage:server:syncGarage', Config.Garages)
end)

RegisterNetEvent('qb-garages:client:addHouseGarage', function(house, garageInfo) -- event from housing on garage creation
    local formattedHouseName = string.gsub(string.lower(house), ' ', '')
    Config.Garages[formattedHouseName] = {
        houseName = house,
        takeVehicle = vector3(garageInfo.takeVehicle.x, garageInfo.takeVehicle.y, garageInfo.takeVehicle.z),
        spawnPoint = {
            vector4(garageInfo.takeVehicle.x, garageInfo.takeVehicle.y, garageInfo.takeVehicle.z, garageInfo.takeVehicle.w)
        },
        label = garageInfo.label,
        type = 'house',
        category = Config.VehicleClasses['all']
    }
    TriggerServerEvent('qb-garages:server:syncGarage', Config.Garages)
end)

-- NUI Functions
RegisterNUICallback('callback', function(data)
    if data.action == "nuiFocus" then
        SetNuiFocus(false, false)
    elseif data.action == "takeOutVehicle" then
        TriggerEvent('exter-garage:client:takeOutGarage', data.data)
    elseif data.action == "takeOutDepo" then
        local depotPrice = data.data.depotPrice
        if depotPrice ~= 0 then
            --TriggerServerEvent('exter-garage:server:PayDepotPrice', data.data)
            data.data.moneyType = "bank"
            data.data.moneyAmount = depotPrice
            TriggerServerEvent('exter-garage:removeMoney:server', data.data)
        else
            TriggerEvent('exter-garage:client:takeOutGarage', data.data)
        end
    end
end)

function CreateDepotZone(index, garage)
    local garageData = Config.Garages[index]
    local model = "a_m_y_hasjew_01"
    local hash = type(model) == "number" and model or joaat(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(0)
    end
    garageData.ped = CreatePed(0, hash, garage.takeVehicle.x, garage.takeVehicle.y, garage.takeVehicle.z - 1, garage.takeVehicle.w, false, true)
    FreezeEntityPosition(garageData.ped, true)
    SetEntityInvincible(garageData.ped, true)
    SetBlockingOfNonTemporaryEvents(garageData.ped, true)
    PlaceObjectOnGroundProperly(garageData.ped)
    SetEntityAsMissionEntity(garageData.ped, false, false)
    SetPedCanPlayAmbientAnims(garageData.ped, false) 
    SetModelAsNoLongerNeeded(hash)
    if garage.Interaction.Target.Enable then
        if GetResourceState('ox_target') == 'started' or GetResourceState('qb-target') == 'started' then
            Config.AddTarget({
                target = "ox",
                label = garageData.Interaction.Target.Label,
                icon = garageData.Interaction.Target.Icon,
                distance = garageData.Interaction.Target.Distance,
                ped = garageData.ped,
                onSelect = function()
                    openDepot(index, garage.type, garage.category)
                end
            })
        elseif GetResourceState('qb-target') == 'started' then
            Config.AddTarget({
                target = "qb",
                label = garageData.Interaction.Target.Label,
                icon = garageData.Interaction.Target.Icon,
                distance = garageData.Interaction.Target.Distance,
                ped = garageData.ped,
                action = function()
                    openDepot(index, garage.type, garage.category)
                end
            })
        end
    end
end

function openDepot(index, gtype, category)
    local vehTable = {}
    TriggerCallback('exter-garage:server:GetGarageVehicles', function(result)
        if result then
            if GetResourceState('qb-menu') == 'started' then
                table.insert(vehTable, {
                    header = "Depot Vehicles",
                    txt = "Which car do you want to take out?",
                    isMenuHeader = true, -- Set to true to make a nonclickable title
                })
                for _, v in pairs(result) do
                    local vname = nil
                    if CoreName == "es_extended" then
                        vehData = json.decode(v.vehicle)
                        vehicle = string.lower(GetDisplayNameFromVehicleModel(vehData.model))
                    else
                        vehicle = v.vehicle
                        state = v.state
                    end
                    if vehiclesData[vehicle] then
                        pcall(function()
                            vname = vehiclesData[vehicle].name
                        end)
                        if vehiclesData[vehicle].brand then
                            vname = vehiclesData[vehicle].brand .. " " .. vehiclesData[vehicle].name
                        end
                    else
                        vname = vehicle
                    end
                    local vehicleStats = {
                        fuel = v.fuel,
                        engine = v.engine,
                        body = v.body,
                    }
                    table.insert(vehTable, {
                        header = vname,
                        txt = "Plate: " .. v.plate,
                        icon = "fas fa-car",
                        params = {
                            isAction = true,
                            event = openDepotMenu,
                            args = {
                                plate = v.plate,
                                name = vname,
                                vehicle = vehicle,
                                index = index,
                                stats = vehicleStats
                            }
                        }
                    })
                end
                Citizen.Wait(500)
                exports["qb-menu"]:openMenu(vehTable)
            elseif GetResourceState('esx_menu_default') == 'started' then
                for _, v in pairs(result) do
                    local vname = nil
                    if CoreName == "es_extended" then
                        vehData = json.decode(v.vehicle)
                        vehicle = string.lower(GetDisplayNameFromVehicleModel(vehData.model))
                    else
                        vehicle = v.vehicle
                        state = v.state
                    end
                    if vehiclesData[vehicle] then
                        pcall(function()
                            vname = vehiclesData[vehicle].name
                        end)
                        if vehiclesData[vehicle].brand then
                            vname = vehiclesData[vehicle].brand .. " " .. vehiclesData[vehicle].name
                        end
                    else
                        vname = vehicle
                    end
                    local vehicleStats = {
                        fuel = v.fuel,
                        engine = v.engine,
                        body = v.body,
                    }
                    table.insert(vehTable, {
                        label = vname,
                        txt = "Plate: " .. v.plate,
                        icon = "fas fa-car",
                        args = {
                            plate = v.plate,
                            name = vname,
                            vehicle = vehicle,
                            index = index,
                            stats = vehicleStats
                        }
                    })
                end
                Citizen.Wait(500)
                Core.UI.Menu.Open("default", GetCurrentResourceName(), "exter-garage-depot-menu-main", {
                    title = "Depot Vehicles",
                    description = "Which car do you want to take out?",
                    align    = 'top-left',
                    elements = vehTable
                }, function(data,menu) -- OnSelect Function
                    menu.close()
                    openDepotMenu(data.current.args)
                end, function(data, menu) -- Cancel Function
                    menu.close() -- close menu
                end)
            end
        else
            return Notify(Lang:t('error.no_vehicles'), 5000, 'error')
        end
    end, index, gtype, category)
end

function openDepotMenu(data)
    if GetResourceState('qb-menu') == 'started' then
        exports["qb-menu"]:openMenu({
            {
                header = "Take Out " .. data.name,
                txt = "Choose payment type.",
                isMenuHeader = true, -- Set to true to make a nonclickable title
            },
            {
                header = "Bank",
                txt = "The amount you have to pay: " .. Config.DepotPrice .. "$.",
                icon = "fas fa-university",
                params = {
                    event = "exter-garage:removeMoney:server",
                    isServer = true,
                    args = {
                        removeMoney = true,
                        moneyType = "bank",
                        moneyAmount = Config.DepotPrice,
                        plate = data.plate,
                        vehicle = data.vehicle,
                        index = data.index,
                        type = "depot",
                        stats = data.stats
                    }
                }
            },
            {
                header = "Cash",
                txt = "The amount you have to pay: " .. Config.DepotPrice .. "$.",
                icon = "fas fa-sack-dollar",
                params = {
                    event = "exter-garage:removeMoney:server",
                    isServer = true,
                    args = {
                        removeMoney = true,
                        moneyType = "cash",
                        moneyAmount = Config.DepotPrice,
                        plate = data.plate,
                        vehicle = data.vehicle,
                        index = data.index,
                        type = "depot",
                        stats = data.stats
                    }
                }
            }
        })
    elseif GetResourceState('esx_menu_default') == 'started' then
        Core.UI.Menu.Open("default", GetCurrentResourceName(), "exter-garage-depot-menu-payment-type", {
            title = "Take Out " .. data.name,
            description = "Choose payment type.",
            align    = 'top-left',
            elements = {
                {
                    label = "Bank",
                    txt = "The amount you have to pay: " .. Config.DepotPrice .. "$.",
                    icon = "fas fa-university",
                    args = {
                        removeMoney = true,
                        moneyType = "bank",
                        moneyAmount = Config.DepotPrice,
                        plate = data.plate,
                        vehicle = data.vehicle,
                        index = data.index,
                        type = "depot",
                        stats = data.stats
                    }
                },
                {
                    label = "Cash",
                    txt = "The amount you have to pay: " .. Config.DepotPrice .. "$.",
                    icon = "fas fa-sack-dollar",
                    args = {
                        removeMoney = true,
                        moneyType = "cash",
                        moneyAmount = Config.DepotPrice,
                        plate = data.plate,
                        vehicle = data.vehicle,
                        index = data.index,
                        type = "depot",
                        stats = data.stats
                    }
                }
            }
        }, function(data,menu) -- OnSelect Function
            menu.close()
            TriggerServerEvent('exter-garage:removeMoney:server', data.current.args)
        end, function(data, menu) -- Cancel Function
            menu.close() -- close menu
        end)
    end
end

Citizen.CreateThread(function()
	for k, v in pairs(Config.ShareKeyAreas) do
        if v.ped.enable then
            local pedHash2 = type(v.ped.hash) == "number" and v.ped.hash or joaat(v.ped.hash)
            RequestModel(pedHash2)
            while not HasModelLoaded(pedHash2) do
                Citizen.Wait(0)
            end
            v.ped.ped = CreatePed(0, pedHash2, v.ped.coords.x, v.ped.coords.y, v.ped.coords.z - 1, v.ped.coords.w, false, true)
            FreezeEntityPosition(v.ped.ped, true)
            SetEntityInvincible(v.ped.ped, true)
            SetBlockingOfNonTemporaryEvents(v.ped.ped, true)
            PlaceObjectOnGroundProperly(v.ped.ped)
            SetEntityAsMissionEntity(v.ped.ped, false, false)
            SetPedCanPlayAmbientAnims(v.ped.ped, false) 
            SetModelAsNoLongerNeeded(pedHash2)
            if v.interaction.target.enable then
                if GetResourceState('ox_target') == 'started' or GetResourceState('qb-target') == 'started' then
                    Config.AddTarget({
                        target = "ox",
                        label = v.interaction.target.label,
                        icon = v.interaction.target.icon,
                        distance = v.interaction.target.distance,
                        ped = v.ped.ped,
                        onSelect = function()
                            openShareKeyMenu()
                        end
                    })
                elseif GetResourceState('qb-target') == 'started' then
                    Config.AddTarget({
                        target = "qb",
                        label = v.interaction.target.label,
                        icon = v.interaction.target.icon,
                        distance = v.interaction.target.distance,
                        ped = v.ped.ped,
                        action = function()
                            openShareKeyMenu()
                        end
                    })
                end
            end
        end
		if v.blip.enable then
			local blip = AddBlipForCoord(v.blip.coords.x, v.blip.coords.y, v.blip.coords.z)
			SetBlipSprite(blip, v.blip.sprite)
			SetBlipScale(blip, v.blip.scale)
			SetBlipDisplay(blip, 4)
			SetBlipColour(blip, v.blip.color)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName(v.blip.text)
			EndTextCommandSetBlipName(blip)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		local sleep = 1000
		local playerCoords = GetEntityCoords(PlayerPedId())
		for k, v in pairs(Config.ShareKeyAreas) do
			if not menuState then
				local dist = #(playerCoords - vector3(v.ped.coords.x, v.ped.coords.y, v.ped.coords.z))
				if v.interaction.text.enable then
					if dist <= v.interaction.text.distance then
						sleep = 0
						ShowFloatingHelpNotification(v.interaction.text.label, v.ped.coords)
						if IsControlJustReleased(0, 38) then openShareKeyMenu() end
					end
				end
			end
		end
		Citizen.Wait(sleep)
	end
end)

closestShareKeyArea = {}
local showTextUI = false
Citizen.CreateThread(function()
	while true do
		local sleep = 100
		if not menuState then
			playerPed = PlayerPedId()
			playerCoords = GetEntityCoords(playerPed)
			if not closestShareKeyArea.id then
				for k, v in pairs(Config.ShareKeyAreas) do
                    if v.interaction.drawText.enable then
                        local dist = #(playerCoords - vector3(v.ped.coords.x, v.ped.coords.y, v.ped.coords.z))
                        if dist <= v.interaction.drawText.distance then
                            function currentShow2()
                                v.interaction.drawText.Show()
                                showTextUI = true
                            end
                            function currentHide2()
                                v.interaction.drawText.Hide()
                            end
                            closestShareKeyArea = {id = k, distance = dist, maxDist = v.interaction.drawText.distance, data = {coords = vector3(v.ped.coords.x, v.ped.coords.y, v.ped.coords.z)}}
                        end
                    end
				end
			end
			if closestShareKeyArea.id then
				while LocalPlayer.state.isLoggedIn do
					playerCoords = GetEntityCoords(playerPed)
					closestShareKeyArea.distance = #(vector3(closestShareKeyArea.data.coords.x, closestShareKeyArea.data.coords.y, closestShareKeyArea.data.coords.z) - playerCoords)
					if closestShareKeyArea.distance < closestShareKeyArea.maxDist then
						if IsControlJustReleased(0, 38) then
							openShareKeyMenu()
						end
						if not showTextUI then
							currentShow2()
						end
					else
						currentHide2()
						break
					end
					Citizen.Wait(0)
				end
				showTextUI = false
				closestShareKeyArea = {}
				sleep = 0
			end
		end
		Citizen.Wait(sleep)
	end
end)

function openShareKeyMenu()
    if GetResourceState('qb-menu') == 'started' then
        exports["qb-menu"]:openMenu({
            {
                header = "Manage Vehicles",
                isMenuHeader = true, -- Set to true to make a nonclickable title
            },
            {
                header = "Share Keys",
                txt = "Share vehicle keys with nearby players.",
                icon = "fas fa-user-plus",
                params = {
                    isAction = true,
                    event = addKeysMenu,
                }
            },
            {
                header = "Remove Keys",
                txt = "Remove shared vehicle keys.",
                icon = "fas fa-user-times",
                params = {
                    isAction = true,
                    event = removeKeysMenu,
                }
            }
        })
    elseif GetResourceState('esx_menu_default') == 'started' then
        Core.UI.Menu.Open("default", GetCurrentResourceName(), "exter-garage-share-key-menu", {
            title = "Manage Vehicles",
            align    = 'top-left',
            elements = {
                {label = "Share Keys", txt = "Share vehicle keys with nearby players.", icon = "fas fa-user-plus", name = "sharekeys"},
                {label = "Remove Keys", txt = "Remove shared vehicle keys.", icon = "fas fa-user-times", name = "removekeys"},
            }
        }, function(data,menu) -- OnSelect Function
            if data.current.name == "sharekeys" then
                menu.close()
                addKeysMenu()
            elseif data.current.name == "removekeys" then
                menu.close()
                removeKeysMenu()
            end
        end, function(data, menu) -- Cancel Function
            menu.close() -- close menu
        end)
    end
end

function addKeysMenu()
    local vehTable = {}
    TriggerCallback('exter-garage:server:GetPlayerVehicles', function(result)
        if result then
            if GetResourceState('qb-menu') == 'started' then
                table.insert(vehTable, {
                    header = "Share Vehicle Keys",
                    txt = "Which car key do you want to share?",
                    isMenuHeader = true, -- Set to true to make a nonclickable title
                })
                for _, v in pairs(result) do
                    table.insert(vehTable, {
                        header = v.fullname,
                        txt = "Plate: " .. v.plate,
                        icon = "fas fa-key",
                        params = {
                            isAction = true,
                            event = openShareMenu,
                            args = {plate = v.plate, model = v.model}
                        }
                    })
                end
                Citizen.Wait(500)
                exports["qb-menu"]:openMenu(vehTable)
            elseif GetResourceState('esx_menu_default') == 'started' then
                for _, v in pairs(result) do
                    local model = string.lower(GetDisplayNameFromVehicleModel(v.model))
                    v.model = vehiclesData[model].brand .. ' ' .. vehiclesData[model].name
                    table.insert(vehTable, {
                        label = v.model,
                        txt = "Plate: " .. v.plate,
                        icon = "fas fa-key",
                        args = {plate = v.plate, model = v.model}
                    })
                end
                Citizen.Wait(500)
                Core.UI.Menu.Open("default", GetCurrentResourceName(), "exter-garage-add-key-menu", {
                    title = "Share Vehicle Keys",
                    description = "Which car key do you want to share?",
                    align    = 'top-left',
                    elements = vehTable
                }, function(data, menu) -- OnSelect Function
                    menu.close()
                    openShareMenu(data.current.args)
                end, function(data, menu) -- Cancel Function
                    menu.close() -- close menu
                end)
            end
        end
    end)
end

function removeKeysMenu()
    local vehTable = {}
    TriggerCallback('exter-garage:server:GetPlayerVehicles', function(result)
        if result then
            if GetResourceState('qb-menu') == 'started' then
                table.insert(vehTable, {
                    header = "Remove Shared Keys",
                    txt = "Which shared car key do you want to remove?",
                    isMenuHeader = true, -- Set to true to make a nonclickable title
                })
                for _, v in pairs(result) do
                    table.insert(vehTable, {
                        header = v.fullname,
                        txt = "Plate: " .. v.plate,
                        icon = "fas fa-key",
                        params = {
                            isAction = true,
                            event = openRemoveMenu,
                            args = {plate = v.plate, model = v.model}
                        }
                    })
                end
                Citizen.Wait(500)
                exports["qb-menu"]:openMenu(vehTable)
            elseif GetResourceState('esx_menu_default') == 'started' then
                for _, v in pairs(result) do
                    local model = string.lower(GetDisplayNameFromVehicleModel(v.model))
                    v.model = vehiclesData[model].brand .. ' ' .. vehiclesData[model].name
                    table.insert(vehTable, {
                        label = v.model,
                        txt = "Plate: " .. v.plate,
                        icon = "fas fa-key",
                        args = {plate = v.plate, model = v.model}
                    })
                end
                Citizen.Wait(500)
                Core.UI.Menu.Open("default", GetCurrentResourceName(), "exter-garage-remove-key-menu", {
                    title = "Remove Shared Keys",
                    description = "Which shared car key do you want to remove?",
                    align    = 'top-left',
                    elements = vehTable
                }, function(data,menu) -- OnSelect Function
                    menu.close()
                    openRemoveMenu(data.current.args)
                end, function(data, menu) -- Cancel Function
                    menu.close() -- close menu
                end)
            end
        end
    end)
end

function openRemoveMenu(data)
    local keysTable = {}
    TriggerCallback('exter-garage:getSharedVehicleKeys:server', function(result)
        if next(result) then
            if GetResourceState('qb-menu') == 'started' then
                table.insert(keysTable, {
                    header = "Remove Shared Keys",
                    txt = "From which player you want to delete the key?",
                    isMenuHeader = true, -- Set to true to make a nonclickable title
                })
                for _, v in pairs(result) do
                    table.insert(keysTable, {
                        header = v.name .. " | " .. v.cid,
                        txt = "Plate: " .. v.plate,
                        icon = "fas fa-key",
                        params = {
                            isServer = true,
                            event = "exter-garage:removeVehicleKey:server",
                            args = {plate = v.plate, id = data.id, cid = v.cid}
                        }
                    })
                end
                Citizen.Wait(500)
                exports["qb-menu"]:openMenu(keysTable)
            elseif GetResourceState('esx_menu_default') == 'started' then
                for _, v in pairs(result) do
                    table.insert(keysTable, {
                        label = v.name .. " | " .. v.cid,
                        txt = "Plate: " .. v.plate,
                        icon = "fas fa-key",
                        args = {plate = v.plate,id = data.id, cid = v.cid}
                    })
                end
                Citizen.Wait(500)
                Core.UI.Menu.Open("default", GetCurrentResourceName(), "exter-garage-remove-key-menu2", {
                    title = "Remove Shared Keys",
                    description = "From which player you want to delete the key?",
                    align    = 'top-left',
                    elements = keysTable
                }, function(data,menu) -- OnSelect Function
                    menu.close()
                    TriggerServerEvent('exter-garage:removeVehicleKey:server', data.current.args)
                end, function(data, menu) -- Cancel Function
                    menu.close() -- close menu
                end)
            end
        else
            Notify(Lang:t("error.no_shared_key"), 7500, "error")
        end
    end, data.plate)
end

function openShareMenu(data)
    local menu = {}
    nearbyPlayers = GetPlayersInArea(GetEntityCoords(PlayerPedId()), 5.0)
    if next(nearbyPlayers) ~= nil and next(nearbyPlayers) then
        TriggerCallback('exter-garage:getNearbyPlayerDatas:server', function(nearbyPlayers2)
            if GetResourceState('qb-menu') == 'started' then
                table.insert(menu, {
                    header = "Share " .. data.model .. " Key",
                    txt = "Choose the player that you want to share key. (Plate: " .. data.plate .. ")",
                    isMenuHeader = true, -- Set to true to make a nonclickable title
                })
                for _, v in pairs(nearbyPlayers2) do
                    table.insert(menu, {
                        header = v.name,
                        txt = "ID: " .. v.id,
                        icon = "fas fa-user",
                        params = {
                            isAction = true,
                            event = openConfirmMenu,
                            args = {
                                plate = data.plate,
                                name = v.name,
                                id = v.id,
                                model = data.model,
                                cid = v.cid
                            }
                        }
                    })
                end
                Citizen.Wait(500)
                exports["qb-menu"]:openMenu(menu)
            elseif GetResourceState('esx_menu_default') == 'started' then
                for _, v in pairs(nearbyPlayers2) do
                    table.insert(menu, {
                        label = v.name,
                        txt = "ID: " .. v.id,
                        icon = "fas fa-user",
                        args = {
                            plate = data.plate,
                            name = v.name,
                            id = v.id,
                            model = data.model,
                            cid = v.cid
                        }
                    })
                end
                Citizen.Wait(500)
                Core.UI.Menu.Open("default", GetCurrentResourceName(), "exter-garage-remove-key-menu3", {
                    title = "Share " .. data.model .. " Key",
                    description = "Choose the player that you want to share key. (Plate: " .. data.plate .. ")",
                    align    = 'top-left',
                    elements = menu
                }, function(data,menu) -- OnSelect Function
                    menu.close()
                    openConfirmMenu(data.current.args)
                end, function(data, menu) -- Cancel Function
                    menu.close() -- close menu
                end)
            end
        end, nearbyPlayers)
    else
        Notify("No players nearby.", 7500, "error")
    end
end

function openConfirmMenu(data)
    if GetResourceState('qb-menu') == 'started' then
        exports["qb-menu"]:openMenu({
            {
                header = "Share " .. data.model .. " Key",
                txt = "You sure you want to share keys to " .. data.name .. "?",
                isMenuHeader = true, -- Set to true to make a nonclickable title
            },
            {
                header = "Confirm",
                --txt = "The amount you have to pay: " .. Config.DepotPrice .. "$.",
                icon = "fas fa-check",
                params = {
                    event = "exter-garage:shareVehicleKey:server",
                    isServer = true,
                    args = {cid = data.cid, targetId = data.id, plate = data.plate}
                }
            },
            {
                header = "Decline",
                --txt = "The amount you have to pay: " .. Config.DepotPrice .. "$.",
                icon = "fas fa-times",
                params = {
                    event = "qb-menu:client:closeMenu"
                }
            }
        })
    elseif GetResourceState('esx_menu_default') == 'started' then
        Core.UI.Menu.Open("default", GetCurrentResourceName(), "exter-garage-remove-key-menu4", {
            title = "Share " .. tostring(data.model) .. " Key",
            description = "You sure you want to share keys to " .. tostring(data.name) .. "?",
            align    = 'top-left',
            elements = {
                {
                    label = "Confirm",
                    icon = "fas fa-check",
                    name = "confirm",
                    args = {cid = data.cid, targetId = data.id, plate = data.plate}
                },
                {
                    label = "Decline",
                    name = "decline",
                    icon = "fas fa-times"
                }
            }
        }, function(data,menu) -- OnSelect Function
            menu.close()
            if data.current.name == "confirm" then
                TriggerServerEvent('exter-garage:shareVehicleKey:server', data.current.args)
            end
        end, function(data, menu) -- Cancel Function
            menu.close() -- close menu
        end)
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for k, v in pairs(Config.ShareKeyAreas) do
        DeletePed(v.ped.ped)
	end
    for k, v in pairs(Config.Garages) do
        if DoesEntityExist(v.ped) then
            DeletePed(v.ped)
        end
	end
end)

function GetPlayers(onlyOtherPlayers, returnKeyValue, returnPeds)
    local players, myPlayer = {}, PlayerId()
    local active = GetActivePlayers()
    for i = 1, #active do
        local currentPlayer = active[i]
        local ped = GetPlayerPed(currentPlayer)
        if DoesEntityExist(ped) and ((onlyOtherPlayers and currentPlayer ~= myPlayer) or not onlyOtherPlayers) then
            if returnKeyValue then
                players[currentPlayer] = {entity = ped, id = GetPlayerServerId(currentPlayer)}
            else
                players[#players + 1] = returnPeds and ped or currentPlayer
            end
        end
    end
    return players
end

function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
    local nearbyEntities = {}
    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        local playerPed = PlayerPedId()
        coords = GetEntityCoords(playerPed)
    end
    for k, v in pairs(entities) do
        local distance = #(coords - GetEntityCoords(v.entity))
        if distance <= maxDistance then
            nearbyEntities[#nearbyEntities + 1] = v.id
        end
    end
    return nearbyEntities
end

function GetPlayersInArea(coords, maxDistance)
    return EnumerateEntitiesWithinDistance(GetPlayers(true, true), true, coords, maxDistance)
end

if Config.DepotMenuType == "menu" then
    Citizen.CreateThread(function()
        while true do
            local sleep = 1000
            local playerCoords = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.Garages) do
                if v.type == "depot" then
                    if v.Interaction.Text.Enable then
                        local dist = #(playerCoords - vector3(v.takeVehicle.x, v.takeVehicle.y, v.takeVehicle.z))
                        if dist <= v.Interaction.Text.Distance then
                            sleep = 0
                            ShowFloatingHelpNotification(v.Interaction.Text.Label, vector3(v.takeVehicle.x, v.takeVehicle.y, v.takeVehicle.z))
                            if IsControlJustReleased(0, 38) then openDepot(k, v.type, v.category) end
                        end
                    end
                end
            end
            Citizen.Wait(sleep)
        end
    end)

    function ShowFloatingHelpNotification(msg, coords)
        AddTextEntry('exter-garage-FloatingHelpNotification', msg)
        SetFloatingHelpTextWorldPosition(1, coords)
        SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
        BeginTextCommandDisplayHelp('exter-garage-FloatingHelpNotification')
        EndTextCommandDisplayHelp(2, false, false, -1)
    end

    closestDepot = {}
    local showTextUI = false
    Citizen.CreateThread(function()
        while true do
            local sleep = 100
            if not menuState then
                playerPed = PlayerPedId()
                playerCoords = GetEntityCoords(playerPed)
                if not closestDepot.id then
                    for k, v in pairs(Config.Garages) do
                        if v.type == "depot" then
                            if v.Interaction.DrawText.Enable then
                                local dist = #(playerCoords - vector3(v.takeVehicle.x, v.takeVehicle.y, v.takeVehicle.z))
                                if dist <= v.Interaction.DrawText.Distance then
                                    function currentShow()
                                        v.Interaction.DrawText.Show()
                                        showTextUI = true
                                    end
                                    function currentHide()
                                        v.Interaction.DrawText.Hide()
                                    end
                                    closestDepot = {id = k, distance = dist, maxDist = v.Interaction.DrawText.Distance, data = {coords = vector3(v.takeVehicle.x, v.takeVehicle.y, v.takeVehicle.z), type = v.type, category = v.category}}
                                end
                            end
                        end
                    end
                end
                if closestDepot.id then
                    while LocalPlayer.state.isLoggedIn do
                        playerCoords = GetEntityCoords(playerPed)
                        closestDepot.distance = #(vector3(closestDepot.data.coords.x, closestDepot.data.coords.y, closestDepot.data.coords.z) - playerCoords)
                        if closestDepot.distance < closestDepot.maxDist then
                            if IsControlJustReleased(0, 38) then
                                openDepot(closestDepot.id, closestDepot.data.type, closestDepot.data.category)
                            end
                            if not showTextUI then
                                currentShow()
                            end
                        else
                            currentHide()
                            break
                        end
                        Citizen.Wait(0)
                    end
                    showTextUI = false
                    closestDepot = {}
                    sleep = 0
                end
            end
            Citizen.Wait(sleep)
        end
    end)
end