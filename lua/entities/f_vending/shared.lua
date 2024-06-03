-- Defines the entity's type, base, printable name, and author for shared access (both server and client)
ENT.Type = "anim" -- Sets the entity type to 'anim', indicating it's an animated entity.
ENT.Base = "base_gmodentity" -- Specifies that this entity is based on the 'base_gmodentity', inheriting its functionality.
ENT.PrintName = "Flof's Vending" -- The name that will appear in the spawn menu.
ENT.Author = "Flof" -- The author's name for this entity.
ENT.Category = "Test entities" -- The category for this entity in the spawn menu.
ENT.Contact = "FloffenWaffles" -- The contact details for the author of this entity.
ENT.Purpose = "To test the creation of entities." -- The purpose of this entity.
ENT.Spawnable = true -- Specifies whether this entity can be spawned by players in the spawn menu.

ENT.Slots = {}

local slotWhitelist = {
    ammo_pistol = true,
    ammo_ar2    = true
}

concommand.Add("vend_whitelist_add", function(ply, _, args)

    if not ply:IsSuperAdmin() then return end
        
    if slotWhitelist[args[1]] == true then
        ply:ChatPrint( args[1] .. " is already on the whitelist!" )
        return
    end
    slotWhitelist[args[1]] = true
    ply:ChatPrint( args[1] .. " has been added to vending whitelist!" )

end)

if SERVER then

    local function vendError( ply, err )
        ply:ChatPrint(err)
    end

    net.Receive( "Flf_Fetch_Vend", function(_, ply)
        net.Start( "Flf_Vend_Slots" )
            net.WriteTable(ENT.Slots)
        net.Send(ply)
    end)

    net.Receive( "Flf_Vend_Set ", function(_, ply)
        local slot      = net.ReadInt()
        local class_Str = net.ReadString()
        if slot <= 0 or slot > 8 then 
            vendError(ply, "slot index out of bounds!" )
            return
        elseif not slotWhitelist[class_str] then 
            vendError(ply, "That class is not on the whitelist!" )
            return
        end

        ENT.Slots[slot] = class_Str

    end)
end

if CLIENT then
    net.Receive( "flf_Vend_Slots", function()
        ENT.Slots = net.ReadTable()
    end)
end