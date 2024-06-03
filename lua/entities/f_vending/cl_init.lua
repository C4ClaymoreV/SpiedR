include("shared.lua")

-- Client-side draw function for the entity

function ENT:Draw()
    self:DrawModel()

    local dist = LocalPlayer():GetPos():DistToSqr(self:GetPos())

    if dist > 160000 then return end

    local phaseA = 300 -  (dist / 160000)*255

    cam.Start3D2D(self:LocalToWorld( Vector(17.5, 17.5, 32) ), self:LocalToWorldAngles( Angle(0, 90, 90) ), 0.10)
	
		surface.SetDrawColor(21,21,21, phaseA)
		surface.DrawRect (0, 0, 85,500)
	
		surface.SetDrawColor(255, 255, 255, phaseA)
		surface.DrawOutlinedRect ( 0, 0, 85, 500)
		
		surface.SetTextColor(255, 255, 255, phaseA)
		surface.SetTextPos( 4, 4 ) 
		surface.DrawText( "KYS" ) 
		
	cam.End3D2D()
end