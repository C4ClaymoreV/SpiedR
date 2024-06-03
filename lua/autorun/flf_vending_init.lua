if SERVER then
    util.AddNetworkString( "vend_whitelist_add" )
    util.AddNetworkString( "vend_whitelist_remove" )

    sql.Query( "CREATE TABLE IF NOT EXISTS flf_vending_whitelist( Class STRING )" )

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