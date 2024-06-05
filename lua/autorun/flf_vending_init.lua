if SERVER then
    util.AddNetworkString( "vend_whitelist_add" )
    util.AddNetworkString( "vend_whitelist_remove" )

    sql.Query( "CREATE TABLE IF NOT EXISTS flf_vending_whitelist( Class STRING )" )

    local vend_whitelist = {}
    local function updateWhitelist()
        for i, v in pairs(sql.Query( "SELECT * FROM flf_vending_whitelist" )) do
            vend_whitelist[v["Class"]] = true
        end
    end
    updateWhitelist()

    net.Receive("vend_whitelist_add", function(_, ply)

        if not ply:IsSuperAdmin() then 
            ply:ChatPrint("Missing Permission")
            return 
        end

        local args = net.ReadTable()

        for _, arg in pairs(args) do
            local data = sql.Query( "SELECT * FROM flf_vending_whitelist WHERE Class = " .. sql.SQLStr( arg ) .. ";")
            if data then
                ply:ChatPrint( arg .. " is already on the whitelist!" )
            else
                sql.Query( "INSERT INTO flf_vending_whitelist ( Class ) VALUES( " .. sql.SQLStr( arg ) .. " )" )
                ply:ChatPrint( arg .. " has been added to the whitelist!")
                print( ply:Nick() .. "(" .. ply:SteamID() .. ")" .. " has added " .. arg .. " to the whitelist." )
            end
        end
        updateWhitelist()
    end)

    net.Receive("vend_whitelist_remove", function(_, ply)

        if not ply:IsSuperAdmin() then 
            ply:ChatPrint("Missing Permission")
            return 
        end
        
        local args = net.ReadTable()

        for _, arg in pairs(args) do
            local data = sql.Query( "SELECT * FROM flf_vending_whitelist WHERE Class = " .. sql.SQLStr( arg ) .. ";")
            if data then
                sql.Query( "DELETE FROM flf_vending_whitelist WHERE Class = " .. sql.SQLStr( arg ) .. ";" )
                ply:ChatPrint(arg .. " has been removed from the whitelist!")
                print( ply:Nick() .. "(" .. ply:SteamID() .. ")" .. " has removed " .. arg .. " from the whitelist." )
            else
                ply:ChatPrint(arg .. " does not exist in the whitelist!")
            end
        end
        updateWhitelist()
    end)

    net.Receive("vend_set_slot", function(_, ply)
        
        local vend =   net.ReadEntity()
        local slotid = net.ReadInt()
        local class  = net.ReadString()

        if vend:GetOwner() ~= ply then return end -- needs to be entity owner
        if slotid < 1 or slotid > 8 then return end -- not a valid slot
        if not vend_whitelist[class] then return end -- if the item is not whitelisted

        vend.Slots[slotid] = class
    end)

    net.Receive("vend_req_slots", function(_, ply)
        local vend = net.ReadEntity()
        net.Start("vend_update_slots")
            net.WriteTable(vend.Slots)
        net.Send(ply)
    end)

end

if CLIENT then

    concommand.Add("vend_whitelist_add", function(ply, _, args)
        net.Start("vend_whitelist_add")
            net.WriteTable(args)
        net.SendToServer()
    end)

    concommand.Add("vend_whitelist_remove", function(ply, _, args)
        net.Start("vend_whitelist_remove")
            net.WriteTable(args)
        net.SendToServer()
    end)
end