include("shared.lua")

local buttons = {}
local button = {
    register = function(panel, index, x, y, w, h, col, text, func)
        buttons[panel] = buttons[panel] or {}
        buttons[panel][index] = {x= x, y= y, w= w, h= h, text= text, func= func}
    end,

    draw = function(panel, phase, index, col)
        if index then 
            
            local b = buttons[panel][index]
            surface.SetDrawColor(col[1], col[2], col[3], phase)
            surface.DrawRect(b.x, b.y, b.w, b.h)

            surface.SetDrawColor(255, 255, 255, phase)
            surface.DrawOutlinedRect(b.x, b.y, b.w, b.h)

            draw.DrawText(b.text, nil, b.x + b.w/2, b.y + b.h/2 - 8, Color(255, 255, 255, phase), TEXT_ALIGN_CENTER)

        else -- too lazy to be clever
            for i, b in pairs(buttons[panel]) do

                surface.SetDrawColor(col[1], col[2], col[3], phase)
                surface.DrawRect(b.x, b.y, b.w, b.h)

                surface.SetDrawColor(255, 255, 255, phase)
                surface.DrawOutlinedRect(b.x, b.y, b.w, b.h)

                draw.DrawText(b.text, nil, b.x + b.w/2, b.y + b.h/2 - 8, Color(255, 255, 255, phase), TEXT_ALIGN_CENTER)

            end
        end
    end,

    findInside = function(panel, pos)
        for i, v in pairs(buttons[panel]) do
            if v.x < pos.x and v.x + v.w > pos.x and v.y < pos.y and v.y + v.h > pos.y then return i end
        end
    end,

    doClick = function(panel, index)
        buttons[panel][index].func()
    end
}

for i = 1, 8 do -- button registeration
    button.register("Main", i, 2, 2 + (i-1)*62, 80, 45, {50, 50, 50}, "test", function() print("you're so awesome") end)
    button.register("Main", i + 8, 2, 2 + (i)*62 -15, 56, 13, {50, 50, 50}, "buy 1", function() print("you're so awesome") end)
    button.register("Main", i + 16, 60, 2 + (i)*62 -15, 22, 13, {50, 50, 50}, "5x", function() print("you're so awesome") end)
end

local selected = {}

function ENT:Draw()
    self:DrawModel()

    local dist = LocalPlayer():GetPos():DistToSqr(self:GetPos())

    if dist > 160000 then return end

    local phaseA = 300 -  (dist / 160000)*255

    cam.Start3D2D(self:LocalToWorld( Vector(17.5, 17.5, 32) ), self:LocalToWorldAngles( Angle(0, 90, 90) ), 0.10)
	
		surface.SetDrawColor(21,21,21, phaseA)
		surface.DrawRect (0, 0, 85,500)
	
		surface.SetDrawColor(255, 255, 255, phaseA)
		surface.DrawOutlinedRect( 0, 0, 85, 500)

        if dist > 16000 then cam.End3D2D() return end -- too far away to select the screen

        local ftrace = util.IntersectRayWithPlane( EyePos(), EyeVector(), self:LocalToWorld( Vector(17.5, 17.5, 32) ), self:LocalToWorldAngles( Angle(0, 90, 90)):Up() )
        if ftrace == nil then cam.End3D2D() return end
        ftrace = self:WorldToLocal(ftrace) - Vector()
        c_pos = { x = (ftrace[2] - 17.5) * 10, y = (-ftrace[3] + 32) * 10 }

        --if c_pos.x < -10 or c_pos.x > 95 or c_pos.y < -10 or c_pos.y > 510 then cam.End3D2D() return end -- outer bounds disable further trace functions

        local sel = button.findInside("Main", c_pos) or 0
        selected = {"Main", sel}

        for i, v in pairs(buttons["Main"]) do
            if i ~= sel then
                button.draw("Main", phasea, i, {50, 50, 50})
            else         
                button.draw("Main", phasea, sel, {100, 100, 100})
            end
        end

	cam.End3D2D()
end