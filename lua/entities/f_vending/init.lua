AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("vend_use")

-- Server-side initialization function for the entity
function ENT:Initialize()
    self:SetModel( "models/flf/vending/vendingmachine1.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
    local phys = self:GetPhysicsObject()
    
    if phys:IsValid() then
        phys:Wake()
    end
end

if SERVER then
    function ENT:Use( ply, user )
        if user ~= ply then return end -- naughty user exploits will never be a thing
        net.Start( "vend_use" )
        net.Send( ply )
    end
end