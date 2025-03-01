Cores = {
    {
        Name = "QBCore",
        ResourceName = "qb-core",
        GetFramework = function() return exports["qb-core"]:GetCoreObject() end
    },
    {
        Name = "QBXCore",
        ResourceName = "qbx_core",
        GetFramework = function() return exports["qbx_core"]:GetCoreObject() end
    }
}