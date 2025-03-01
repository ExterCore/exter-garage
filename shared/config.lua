Config = {
    ServerCallbacks = {}, -- Don't edit or change
    RadialMenu = {
        Enable = false,
        ResourceName = "qb-radialmenu",
        KeyLabel = "F3",
        DrawText = true,
    },
    VehicleImages = {
        Enable = false, -- If true you will see original vehicle images at UI, if false you will just see a car icon
        UseCustomImages = false, -- If false, a default car photo is shown instead of the one without a photo, if true, the photo from the html/cars file is used.
    },
    AutoRestoreVehicles = false, -- If true stores cars in garage on restart, if false doesnt modify car states
    VisuallyDamageCars = true, -- If true damage car on spawn, if false no damage on spawn
    SharedGarages = true, -- If true take any car from any garage, if false only take car from garage stored in
    ClassSystem = false, -- If true restrict vehicles by class, if false any vehicle class in any garage
    Warp = true, -- If true warp player into vehicle, if false vehicle spawns without warping
    DepotPrice = 500,
    DepotMenuType = "ui", -- If it's menu it opens QB/ESX menu if it's ui it opens garage menu
    VehicleClasses = {
        all = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22},
        car = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 13, 18, 22},
        air = {15, 16},
        sea = {14},
        rig = {10, 11, 17, 19, 20},
        emergency = {18, 19}
    },
    OnVehicleSpawn = function(vehicle)
        -- You can write here smth
        -- FreezeEntityPosition(vehicle, false)
    end
}

-- Garages
Config.Garages = {
    motelgarage = {
        label = 'Motel Parking',
        takeVehicle = vector3(274.29, -334.15, 44.92),
        spawnPoint = {
            vector4(265.96, -332.3, 44.51, 250.68)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public', -- public, gang, job, depot
        category = Config.VehicleClasses['car']
    },
    casinogarage = {
        label = 'Casino Parking',
        takeVehicle = vector3(883.96, -4.71, 78.76),
        spawnPoint = {
            vector4(895.39, -4.75, 78.35, 146.85)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['car']
    },
    sapcounsel = {
        label = 'San Andreas Parking',
        takeVehicle = vector3(-330.01, -780.33, 33.96),
        spawnPoint = {
            vector4(-341.57, -767.45, 33.56, 92.61)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['car']
    },
    spanishave = {
        label = 'Spanish Ave Parking',
        takeVehicle = vector3(-1160.86, -741.41, 19.63),
        spawnPoint = {
            vector4(-1145.2, -745.42, 19.26, 108.22)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['car']
    },
    caears24 = {
        label = 'Caears 24 Parking',
        takeVehicle = vector3(69.84, 12.6, 68.96),
        spawnPoint = {
            vector4(60.8, 17.54, 68.82, 339.7)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['car']
    },
    caears242 = {
        label = 'Caears 24 Parking',
        takeVehicle = vector3(-453.7, -786.78, 30.56),
        spawnPoint = {
            vector4(-472.39, -787.71, 30.14, 180.52)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['car']
    },
    lagunapi = {
        label = 'Laguna Parking',
        takeVehicle = vector3(364.37, 297.83, 103.49),
        spawnPoint = {
            vector4(375.09, 294.66, 102.86, 164.04)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['car']
    },
    airportp = {
        label = 'Airport Parking',
        takeVehicle = vector3(-773.12, -2033.04, 8.88),
        spawnPoint = {
            vector4(-779.77, -2040.18, 8.47, 315.34)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['car']
    },
    beachp = {
        label = 'Beach Parking',
        takeVehicle = vector3(-1185.32, -1500.64, 4.38),
        spawnPoint = {
            vector4(-1188.14, -1487.95, 3.97, 124.06)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['car']
    },
    themotorhotel = {
        label = 'The Motor Hotel Parking',
        takeVehicle = vector3(1137.77, 2663.54, 37.9),
        spawnPoint = {
            vector4(1127.7, 2647.84, 37.58, 1.41)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['car']
    },
    liqourparking = {
        label = 'Liqour Parking',
        takeVehicle = vector3(883.99, 3649.67, 32.87),
        spawnPoint = {
            vector4(898.38, 3649.41, 32.36, 90.75)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['car']
    },
    shoreparking = {
        label = 'Shore Parking',
        takeVehicle = vector3(1737.03, 3718.88, 34.05),
        spawnPoint = {
            vector4(1725.4, 3716.78, 34.15, 20.54)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['car']
    },
    haanparking = {
        label = 'Bell Farms Parking',
        takeVehicle = vector3(76.88, 6397.3, 31.23),
        spawnPoint = {
            vector4(62.15, 6403.41, 30.81, 211.38)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['car']
    },
    dumbogarage = {
        label = 'Dumbo Private Parking',
        takeVehicle = vector3(165.75, -3227.2, 5.89),
        spawnPoint = {
            vector4(168.34, -3236.1, 5.43, 272.05)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['car']
    },
    pillboxgarage = {
        label = 'Pillbox Garage Parking',
        takeVehicle = vector3(213.2, -796.05, 30.86),
        spawnPoint = {
            vector4(222.02, -804.19, 30.26, 248.19),
            vector4(223.93, -799.11, 30.25, 248.53),
            vector4(226.46, -794.33, 30.24, 248.29),
            vector4(232.33, -807.97, 30.02, 69.17),
            vector4(234.42, -802.76, 30.04, 67.2)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['car']
    },
    grapeseedgarage = {
        label = 'Grapeseed Parking',
        takeVehicle = vector3(2552.68, 4671.8, 33.95),
        spawnPoint = {
            vector4(2550.17, 4681.96, 33.81, 17.05)
        },
        showBlip = true,
        blipName = 'Public Parking',
        blipNumber = 357,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['car']
    },
    depotLot = {
        label = 'Depot Lot',
        takeVehicle = vector4(408.96, -1622.77, 29.29, 229.8),
        spawnPoint = {
            vector4(396.55, -1643.93, 28.88, 321.91)
        },
        showBlip = true,
        blipName = 'Depot Lot',
        blipNumber = 68,
        blipColor = 3,
        type = 'depot',
        category = Config.VehicleClasses['car'],
        Interaction = {
            Target = {
                Enable = false,
                Distance = 2.0,
                Label = "Open Depot",
                Icon = "fa-solid fa-address-book"
            },
            Text = {
                Enable = true,
                Distance = 3.0,
                Label = "[E] Open Depot"
            },
            DrawText = {
                Enable = false,
                Distance = 3.0,
                Show = function()
                    exports["qb-core"]:DrawText("Open Depot", "left")
                end,
                Hide = function()
                    exports["qb-core"]:HideText()
                end
            }
        }
    },
    ballas = {
        label = 'Ballas',
        takeVehicle = vector3(87.51, -1969.1, 20.75),
        spawnPoint = {
            vector4(93.78, -1961.73, 20.34, 319.11)
        },
        showBlip = false,
        blipName = 'Ballas',
        blipNumber = 357,
        blipColor = 3,
        type = 'gang',
        category = Config.VehicleClasses['car'], --car, air, sea, rig
        job = 'ballas',
        jobType = 'ballas'
    },
    families = {
        label = 'Families',
        takeVehicle = vector3(-23.89, -1436.03, 30.65),
        spawnPoint = {
            vector4(-25.47, -1445.76, 30.24, 178.5)
        },
        showBlip = false,
        blipName = 'Families',
        blipNumber = 357,
        blipColor = 3,
        type = 'gang',
        category = Config.VehicleClasses['car'], --car, air, sea, rig
        job = 'families',
        jobType = 'families'
    },
    lostmc = {
        label = 'Lost MC',
        takeVehicle = vector3(985.83, -138.14, 73.09),
        spawnPoint = {
            vector4(977.65, -133.02, 73.34, 59.39)
        },
        showBlip = false,
        blipName = 'Lost MC',
        blipNumber = 357,
        blipColor = 3,
        type = 'gang',
        category = Config.VehicleClasses['car'], --car, air, sea, rig
        job = 'lostmc',
        jobType = 'lostmc'
    },
    cartel = {
        label = 'Cartel',
        takeVehicle = vector3(1411.67, 1117.8, 114.84),
        spawnPoint = {
            vector4(1403.01, 1118.25, 114.84, 88.69)
        },
        showBlip = false,
        blipName = 'Cartel',
        blipNumber = 357,
        blipColor = 3,
        type = 'gang',
        category = Config.VehicleClasses['car'],
        job = 'cartel',
        jobType = 'cartel'
    },
    police = {
        label = 'Police',
        takeVehicle = vector3(462.83, -1019.52, 28.1),
        spawnPoint = {
            vector4(446.16, -1025.79, 28.23, 6.59)
        },
        showBlip = false,
        blipName = 'Police',
        blipNumber = 357,
        blipColor = 3,
        type = 'job',
        category = Config.VehicleClasses['emergency'], --car, air, sea, rig
        job = 'police',
        jobType = 'leo'
    },
    police2 = {
        label = 'Police',
        takeVehicle = vector3(472.04, -1078.23, 29.35),
        spawnPoint = {
            vector4(471.49, -1089.02, 28.96, 92.97)
        },
        showBlip = false,
        blipName = 'Police',
        blipNumber = 357,
        blipColor = 3,
        type = 'jobfree',
        vehiclesData = {
            [0] = { -- Grade 0 for polices
                limit = 1,
                customPlate = {
                    enable = true,
                    plate = function()
                        return "POL" .. math.random(1000, 9999) -- Generates a random number between 1000 and 9999
                    end
                },
                setVehMods = function(veh)
                    SetVehicleLivery(veh, 2)
                end,
                vehicles = {"police", "police2", "police3", "fbi"}
            },
            [1] = { -- Grade 1 for polices
                limit = 1,
                customPlate = {
                    enable = true,
                    plate = function()
                        return "POL" .. math.random(1000, 9999) -- Generates a random number between 1000 and 9999
                    end
                },
                setVehMods = function(veh)
                    SetVehicleLivery(veh, 3)
                end,
                vehicles = {"police", "police2", "police3", "fbi"}
            },
            [2] = { -- Grade 2 for polices
                limit = 1,
                customPlate = {
                    enable = true,
                    plate = function()
                        return "POL" .. math.random(1000, 9999) -- Generates a random number between 1000 and 9999
                    end
                },
                setVehMods = function(veh)
                    SetVehicleLivery(veh, 2)
                end,
                vehicles = {"police", "police2", "police3", "fbi"}
            },
            [3] = { -- Grade 3 for polices
                limit = 1,
                customPlate = {
                    enable = true,
                    plate = function()
                        return "POL" .. math.random(1000, 9999) -- Generates a random number between 1000 and 9999
                    end
                },
                setVehMods = function(veh)
                    SetVehicleLivery(veh, 3)
                end,
                vehicles = {"police", "police2", "police3", "fbi"}
            },
            [4] = { -- Grade 4 for polices
                limit = 5,
                customPlate = {
                    enable = true,
                    plate = function()
                        return "POL" .. math.random(1000, 9999) -- Generates a random number between 1000 and 9999
                    end
                },
                setVehMods = function(veh)
                    SetVehicleLivery(veh, 1)
                    SetVehicleDirtLevel(veh, 0.0)
                end,
                vehicles = {"ambulance", "police2", "police3", "fbi"}
            },
            [5] = { -- Grade 5 for polices
                limit = 5,
                customPlate = {
                    enable = true,
                    plate = function()
                        return "POL" .. math.random(1000, 9999) -- Generates a random number between 1000 and 9999
                    end
                },
                setVehMods = function(veh)
                    SetVehicleLivery(veh, 2)
                end,
                vehicles = {"police", "police2", "police3", "fbi"}
            },
            [6] = { -- Grade 6 for polices
                limit = 5,
                customPlate = {
                    enable = true,
                    plate = function()
                        return "POL" .. math.random(1000, 9999) -- Generates a random number between 1000 and 9999
                    end
                },
                setVehMods = function(veh)
                    SetVehicleLivery(veh, 2)
                end,
                vehicles = {"police", "police2", "police3", "fbi"}
            },
        },
        category = Config.VehicleClasses['emergency'], --car, air, sea, rig
        job = 'police',
        jobType = 'leo'
    },
    intairport = {
        label = 'Airport Hangar',
        takeVehicle = vector3(-979.06, -2995.48, 13.95),
        spawnPoint = {
            vector4(-998.37, -2985.01, 13.95, 61.09)
        },
        showBlip = true,
        blipName = 'Hangar',
        blipNumber = 360,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['air']
    },
    higginsheli = {
        label = 'Higgins Helitours',
        takeVehicle = vector3(-722.15, -1472.79, 5.0),
        spawnPoint = {
            vector4(-745.22, -1468.72, 5.39, 319.84),
            vector4(-724.36, -1443.61, 5.39, 135.78)
        },
        showBlip = true,
        blipName = 'Hangar',
        blipNumber = 360,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['air']
    },
    airsshores = {
        label = 'Sandy Shores Hangar',
        takeVehicle = vector3(1737.89, 3288.13, 41.14),
        spawnPoint = {
            vector4(1742.83, 3266.83, 41.24, 102.64)
        },
        showBlip = true,
        blipName = 'Hangar',
        blipNumber = 360,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['air']
    },
    airzancudo = {
        label = 'Fort Zancudo Hangar',
        takeVehicle = vector3(-1828.25, 2975.44, 32.81),
        spawnPoint = {
            vector4(-1828.25, 2975.44, 32.81, 57.24)
        },
        showBlip = true,
        blipName = 'Hangar',
        blipNumber = 360,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['air']
    },
    airdepot = {
        label = 'Air Depot',
        takeVehicle = vector3(-1270.01, -3377.53, 14.33),
        spawnPoint = {
            vector4(-1270.01, -3377.53, 14.33, 329.25)
        },
        showBlip = true,
        blipName = 'Air Depot',
        blipNumber = 359,
        blipColor = 3,
        type = 'depot',
        category = Config.VehicleClasses['air'],
        Interaction = {
            Target = {
                Enable = false,
                Distance = 2.0,
                Label = "Open Depot",
                Icon = "fa-solid fa-address-book"
            },
            Text = {
                Enable = true,
                Distance = 3.0,
                Label = "[E] Open Depot"
            },
            DrawText = {
                Enable = false,
                Distance = 3.0,
                Show = function()
                    exports["qb-core"]:DrawText("Open Depot", "left")
                end,
                Hide = function()
                    exports["qb-core"]:HideText()
                end
            }
        }
    },
    lsymc = {
        label = 'LSYMC Boathouse',
        takeVehicle = vector3(-785.95, -1497.84, -0.09),
        spawnPoint = {
            vector4(-796.64, -1502.6, -0.09, 111.49)
        },
        showBlip = true,
        blipName = 'Boathouse',
        blipNumber = 356,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['sea']
    },
    paleto = {
        label = 'Paleto Boathouse',
        takeVehicle = vector3(-278.21, 6638.13, 7.55),
        spawnPoint = {
            vector4(-289.2, 6637.96, 1.01, 45.5)
        },
        showBlip = true,
        blipName = 'Boathouse',
        blipNumber = 356,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['sea']
    },
    millars = {
        label = 'Millars Boathouse',
        takeVehicle = vector3(1298.56, 4212.42, 33.25),
        spawnPoint = {
            vector4(1297.82, 4209.61, 30.12, 253.5)
        },
        showBlip = true,
        blipName = 'Boathouse',
        blipNumber = 356,
        blipColor = 3,
        type = 'public',
        category = Config.VehicleClasses['sea']
    },
    seadepot = {
        label = 'LSYMC Depot',
        takeVehicle = vector3(-742.95, -1407.58, 5.5),
        spawnPoint = {
            vector4(-729.77, -1355.49, 1.19, 142.5)
        },
        showBlip = true,
        blipName = 'LSYMC Depot',
        blipNumber = 356,
        blipColor = 3,
        type = 'depot',
        category = Config.VehicleClasses['sea'],
        Interaction = {
            Target = {
                Enable = false,
                Distance = 2.0,
                Label = "Open Depot",
                Icon = "fa-solid fa-address-book"
            },
            Text = {
                Enable = true,
                Distance = 3.0,
                Label = "[E] Open Depot"
            },
            DrawText = {
                Enable = false,
                Distance = 3.0,
                Show = function()
                    exports["qb-core"]:DrawText("Open Depot", "left")
                end,
                Hide = function()
                    exports["qb-core"]:HideText()
                end
            }
        }
    },
    rigdepot = {
        label = 'Big Rig Depot',
        takeVehicle = vector3(2334.42, 3118.62, 48.2),
        spawnPoint = {
            vector4(2324.57, 3117.79, 48.21, 4.05)
        },
        showBlip = true,
        blipName = 'Big Rig Depot',
        blipNumber = 68,
        blipColor = 2,
        type = 'depot',
        category = Config.VehicleClasses['rig'],
        Interaction = {
            Target = {
                Enable = false,
                Distance = 2.0,
                Label = "Open Depot",
                Icon = "fa-solid fa-address-book"
            },
            Text = {
                Enable = true,
                Distance = 3.0,
                Label = "[E] Open Depot"
            },
            DrawText = {
                Enable = false,
                Distance = 3.0,
                Show = function()
                    exports["qb-core"]:DrawText("Open Depot", "left")
                end,
                Hide = function()
                    exports["qb-core"]:HideText()
                end
            }
        }
    },
    dumborigparking = {
        label = 'Dumbo Big Rig Parking',
        takeVehicle = vector3(161.23, -3188.73, 5.97),
        spawnPoint = {
            vector4(167.0, -3203.89, 5.94, 271.27)
        },
        showBlip = true,
        blipName = 'Big Rig Parking',
        blipNumber = 357,
        blipColor = 2,
        type = 'public',
        category = Config.VehicleClasses['rig']
    },
    popsrigparking = {
        label = 'Pop\'s Big Rig Parking',
        takeVehicle = vector3(137.67, 6632.99, 31.67),
        spawnPoint = {
            vector4(127.69, 6605.84, 31.93, 223.67)
        },
        showBlip = true,
        blipName = 'Big Rig Parking',
        blipNumber = 357,
        blipColor = 2,
        type = 'public',
        category = Config.VehicleClasses['rig']
    },
    ronsrigparking = {
        label = 'Ron\'s Big Rig Parking',
        takeVehicle = vector3(-2529.37, 2342.67, 33.06),
        spawnPoint = {
            vector4(-2521.61, 2326.45, 33.13, 88.7)
        },
        showBlip = true,
        blipName = 'Big Rig Parking',
        blipNumber = 357,
        blipColor = 2,
        type = 'public',
        category = Config.VehicleClasses['rig']
    },
    ronsrigparking2 = {
        label = 'Ron\'s Big Rig Parking',
        takeVehicle = vector3(2561.67, 476.68, 108.49),
        spawnPoint = {
            vector4(2561.67, 476.68, 108.49, 177.86)
        },
        showBlip = true,
        blipName = 'Big Rig Parking',
        blipNumber = 357,
        blipColor = 2,
        type = 'public',
        category = Config.VehicleClasses['rig']
    },
    ronsrigparking3 = {
        label = 'Ron\'s Big Rig Parking',
        takeVehicle = vector3(-41.24, -2550.63, 6.01),
        spawnPoint = {
            vector4(-39.39, -2527.81, 6.08, 326.18)
        },
        showBlip = true,
        blipName = 'Big Rig Parking',
        blipNumber = 357,
        blipColor = 2,
        type = 'public',
        category = Config.VehicleClasses['rig']
    },
}

Config.ShareKeyAreas = {
    {
        type = Config.VehicleClasses['car'],
        ped = {
            enable = true,
            coords = vector4(237.79, -413.18, 48.11, 341.96),
            hash = "a_m_y_hasjew_01" -- Check here https://docs.fivem.net/docs/game-references/ped-models/
        },
        blip = { -- https://docs.fivem.net/docs/game-references/blips/
            enable = false,
            coords = vector3(-982.1, -256.03, 9.09),
            sprite = 59,
            color = 2,
            scale = 0.5,
            text = "Blip Text"
        },
        interaction = {
            target = {
                enable = false,
                distance = 2.0,
                label = "Remove/Share Keys",
                icon = "fa-solid fa-address-book"
            },
            text = {
                enable = false,
                distance = 3.0,
                label = "[E] Remove/Share Keys"
            },
            drawText = {
                enable = true,
                distance = 3.0,
                Show = function()
                    exports["qb-core"]:DrawText("Remove/Share Keys", "left")
                end,
                Hide = function()
                    exports["qb-core"]:HideText()
                end
            }
        }
    }
}

local MenuItemId1 = nil
local MenuItemId2 = nil
function Config.RemoveRadialOptions()
    if MenuItemId1 ~= nil then
        exports[Config.RadialMenu.ResourceName]:RemoveOption(MenuItemId1)
        MenuItemId1 = nil
    end
    if MenuItemId2 ~= nil then
        exports[Config.RadialMenu.ResourceName]:RemoveOption(MenuItemId2)
        MenuItemId2 = nil
    end
end

function Config.AddRadialOptions(data)
    MenuItemId1 = exports[Config.RadialMenu.ResourceName]:AddOption({
        id = 'garageoption',
        title = displayText,
        icon = 'square-parking',
        type = 'client',
        event = 'exter-garage:DepositVehicle:client',
        zData = data,
        shouldClose = true
    }, MenuItemId1)
end

function Config.AddTarget(data)
    if data.target == "ox" then
        exports['ox_target']:addLocalEntity(data.ped, {
            [1] = {
                label = data.label,
                icon = data.icon,
                distance = data.distance,
                onSelect = function()
                    data.onSelect()
                end
            },
        })
    elseif data.target == "qb" then
        exports['qb-target']:AddTargetEntity(data.ped, {
            options = {
                {
                    label = data.label,
                    icon = data.icon,
                    action = function()
                        data.onSelect()
                    end
                },
            },
            distance = distance
        })
    end
end