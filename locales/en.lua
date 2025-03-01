local Translations = {
    error = {
        no_vehicles = 'There are no vehicles in this location!',
        not_depot = 'Your vehicle is not in depot',
        not_owned = 'This vehicle can\'t be stored',
        not_correct_type = 'You can\'t store this type of vehicle here',
        not_enough = 'Not enough money',
        no_garage = 'None',
        vehicle_occupied = 'You can\'t store this vehicle as it is not empty',
        vehicle_not_tracked = 'Could not track vehicle',
        no_spawn = 'Area too crowded',
        not_enough_limits = 'You don\'t have enough limits to spawn a new job vehicle.',
        already_has_key = "%{name} already has this vehicle's key.",
        no_shared_key = "No shared key found for this vehicle.",
        no_garage_nearby = "No garages nearby."
    },
    success = {
        vehicle_parked = 'Vehicle Stored',
        vehicle_tracked = 'Vehicle Tracked',
        key_removed = 'The car key was removed from %{name}.',
        key_shared = 'The car key was shared with %{name}.',
        received_key_for_vehicle = 'You took the keys to the %{plate} licence plate.'
    },
    status = {
        out = 'Out',
        garaged = 'Garaged',
        impound = 'Impounded By Police',
        house = 'House',
    },
    info = {
        car_e = 'Garage',
        sea_e = 'Boathouse',
        air_e = 'Hangar',
        rig_e = 'Rig Lot',
        depot_e = 'Depot',
        house_garage = 'House Garage',
        house = "House"
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})