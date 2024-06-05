AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString( "vend_use" )

-- Server-side initialization function for the entity
function ENT:Initialize()
    self:SetModel( "models/props_interiors/VendingMachineSoda01a.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    local phys = self:GetPhysicsObject() 
    self:SetUseType(SIMPLE_USE)
    
    if phys:IsValid() then
        phys:Wake()
    end
end

if SERVER then
    function ENT:Use(ply)
        net.Start("vend_use")
        net.Send(ply)
    end
end