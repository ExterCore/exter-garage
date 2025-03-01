Fuels = {
    {
        ResourceName = "LegacyFuel",
        SetFuel = function(vehicle, fuel) return exports["LegacyFuel"]:SetFuel(vehicle, fuel) end,
        GetFuel = function(vehicle) return exports["LegacyFuel"]:GetFuel(vehicle) end
    },
    {
        ResourceName = "cdn-fuel",
        SetFuel = function(vehicle, fuel) return exports["cdn-fuel"]:SetFuel(vehicle, fuel) end,
        GetFuel = function(vehicle) return exports["cdn-fuel"]:GetFuel(vehicle) end
    },
    {
        ResourceName = "frkn-fuelstationv4",
        SetFuel = function(vehicle, fuel) return exports["frkn-fuelstationv4"]:SetFuel(vehicle, fuel) end,
        GetFuel = function(vehicle) return exports["frkn-fuelstationv4"]:GetFuel(vehicle) end
    },
    {
        ResourceName = "vFuel",
        SetFuel = function(vehicle, fuel) return exports["vFuel"]:SetFuel(vehicle, fuel) end,
        GetFuel = function(vehicle) return exports["vFuel"]:GetFuel(vehicle) end
    },
    {
        ResourceName = "cd-fuel",
        SetFuel = function(vehicle, fuel) return exports["cd-fuel"]:SetFuel(vehicle, fuel) end,
        GetFuel = function(vehicle) return exports["cd-fuel"]:GetFuel(vehicle) end
    },
    {
        ResourceName = "frfuel",
        SetFuel = function(vehicle, fuel) return exports["frfuel"]:SetFuel(vehicle, fuel) end,
        GetFuel = function(vehicle) return exports["frfuel"]:GetFuel(vehicle) end
    },
    {
        ResourceName = "ox_fuel",
        SetFuel = function(vehicle, fuel) Entity(vehicle).state.fuel = fuel end,
        GetFuel = function(vehicle) return Entity(vehicle).state.fuel end
    }
}