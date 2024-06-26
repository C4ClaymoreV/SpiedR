FLF_VEND = {} -- global table across clients for values for the vending machine
FLF_VEND["357"] =                   {index = 1, price = 1000, amt = 6,  display = "357"}
FLF_VEND["Pistol"] =                {index = 2, price = 800, amt = 15, display = "Pistol"}
FLF_VEND["SMG1"] =                  {index = 3, price = 1000, amt = 30, display = "SMG"}
FLF_VEND["AR2"] =                   {index = 4, price = 1500, amt = 30, display = "Rifle"}
FLF_VEND["AirboatGun"] =            {index = 5, price = 2000, amt = 12, display = "Winchester"}
FLF_VEND["SniperPenetratedRound"] = {index = 6, price = 3500, amt = 8,  display = "Sniper"}
FLF_VEND["Buckshot"] =              {index = 7, price = 1250, amt = 12, display = "Shotgun"}
FLF_VEND.Equipt =                   {index = 8, price = 1000, amt = 12, display = "Equipt"} -- ammo and amount will never be used
if SERVER then

    local whitelist = { -- whitelist can be accessed in two ways; whitelist[1] ==> ["357"] ==> (true for filtering)
        "357",
        "Pistol",
        "SMG1",
        "AR2",
        "AirboatGun",
        "SniperPenetratedRound",
        "Buckshot"
    }

    for i, v in ipairs(whitelist) do -- now whitelist has double values (one that can be indexed)
        whitelist[v] = true
    end

    net.Receive("vend_use", function(_, ply)
        local index = net.ReadInt(5)
        local amt =   net.ReadInt(5)
        local class = game.GetAmmoName( ply:GetActiveWeapon():GetPrimaryAmmoType() )
        if not whitelist[class] and index == 8 then ply:ChatPrint("Your Weapon's ammo is not on sale!") return
        elseif index ~= 8 then class = whitelist[index] end

        local price = FLF_VEND[class].price * amt

        if ply:getDarkRPVar("money") < price then ply:ChatPrint( "You do not have enough money to make this purchase!" ) return end
        if ply:GetAmmoCount(class) >= 9999 then ply:ChatPrint( "You already have the maximum ammo of this type! ") return end
        ply:GiveAmmo(amt * FLF_VEND[class].amt, class)
        ply:addMoney(-price)
    end)
end