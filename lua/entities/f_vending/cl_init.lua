include("shared.lua")

local pan = "Main"
local sel = 0
local buttons = {}
local button = {}

button.Register = function( panel, index, x, y, w, h, text, func )
    buttons[panel] = buttons[panel] or {}
    buttons[panel][index] = {x= x or 0, y= y or 0, w= w or 0, h= h or 0, text= text or "", func= func or function() return end}
end 

button.Draw = function( panel, index, col)
    local b = buttons[panel][index] or nil
    if not b then return end

    surface.SetDrawColor(col)
    surface.DrawRect(b.x, b.y, b.w, b.h)

    surface.SetDrawColor(255, 255, 255, col["a"])
    surface.DrawOutlinedRect(b.x, b.y, b.w, b.h)

    draw.DrawText(b.text, nil, b.x + b.w/2, b.y + b.h/2 - 8, Color(255, 255, 255, col["a"]), TEXT_ALIGN_CENTER)
end

button.DrawPanel = function( panel, col, filter )
    local filter = filter or function() return true end

    for i, v in pairs( buttons[panel] ) do
        if filter(i) then 
            button.Draw(panel, i, col)
        end
    end
end

button.FindInside = function(panel, pos )
    for i, v in pairs(buttons[panel]) do
        if v.x < pos.x and v.x + v.w > pos.x and v.y < pos.y and v.y + v.h > pos.y then return i end
    end
end

button.Use = function( panel , index )
    buttons[panel][index].func()
end

net.Receive( "vend_use", function () button.Use(pan, sel) end)

button.Register("Background", 0, 0, 0, 85, 500) -- kinda cheating


for i = 1, 8 do -- button registeration
    button.Register("Main", i,       2, 2 + (i-1)*62,   80, 45, "test",  function() print("you're so awesome") end)
    button.Register("Main", i + 8,   2, 2 + (i)*62 -15, 56, 13, "buy 1", function() print("you're so awesome") end)
    button.Register("Main", i + 16, 60, 2 + (i)*62 -15, 22, 13, "5x",    function() print("you're so awesome") end)
end

function ENT:Draw()
    self:DrawModel()

    local dist = LocalPlayer():GetPos():DistToSqr(self:GetPos())

    local phase = math.Clamp( 255 - dist/100, 0, 255)

    cam.Start3D2D(self:LocalToWorld( Vector(17.5, 17.5, 32) ), self:LocalToWorldAngles( Angle(0, 90, 90) ), 0.10)

        button.Draw("Background", 0, Color(21, 21, 21))

        if dist < 10000 then 
            local ftrace = util.IntersectRayWithPlane( EyePos(), EyeVector(), self:LocalToWorld( Vector(17.5, 17.5, 32) ), self:LocalToWorldAngles( Angle(0, 90, 90)):Up() )
            if ftrace == nil then cam.End3D2D() return end
            ftrace = self:WorldToLocal(ftrace)
        
            c_pos = { x = (ftrace[2] - 17.5) * 10, y = (-ftrace[3] + 32) * 10 } -- transforms based off of offset and scale for the render hook

            sel = button.FindInside(pan, c_pos)
        else sel = 0 end

        if dist > 25000 then cam.End3D2D() return end

        button.DrawPanel(pan, Color(50, 50, 50,    phase), function(index) return sel ~= index end)
        button.Draw(pan, sel, Color(100, 100, 100, phase))

	cam.End3D2D()
end