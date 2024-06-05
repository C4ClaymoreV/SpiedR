include("shared.lua")

local pan = "Main"
local phase = 0
local buttons = {}
local button = {}

button.Register = function( panel, index, x, y, w, h, text, func )
    buttons[panel] = buttons[panel] or {}
    buttons[panel][index] = {x= x, y= y, w= w, h= h, text= text, func= func}
end 

button.Draw = function( panel, index, col)
    local b = buttons[panel][index] or nil
    if not b then return end
    local phase = buttons.phase

    surface.SetDrawColor(col[1], col[2], col[3], phase)
    surface.DrawRect(b.x, b.y, b.w, b.h)

    surface.SetDrawColor(255, 255, 255, phase)
    surface.DrawOutlinedRect(b.x, b.y, b.w, b.h)

    draw.DrawText(b.text or "", nil, b.x + b.w/2, b.y + b.h/2 - 8, Color(255, 255, 255, phase), TEXT_ALIGN_CENTER)
end

button.DrawPanel = function( panel, col, filter )
    local filter = filter or function() return true end
    local phase = buttons.phase

    for i, v in pairs(buttons[panel]) do
        if filter(i) then 
            button.Draw(panel, i, col)
        end
    end
end

button.FindInside = function(panel, pos)
    for i, v in pairs(buttons[panel]) do
        if v.x < pos.x and v.x + v.w > pos.x and v.y < pos.y and v.y + v.h > pos.y then return i end
    end
end

button.Use = function( panel , index)
    buttons[panel][index].func()
end


button.Register("Background", 0, 0, 0, 85, 500) -- kinda cheating

for i = 1, 8 do -- button registeration
    button.Register("Main", i,       2, 2 + (i-1)*62,   80, 45, "test",  function() print("you're so awesome") end)
    button.Register("Main", i + 8,   2, 2 + (i)*62 -15, 56, 13, "buy 1", function() print("you're so awesome") end)
    button.Register("Main", i + 16, 60, 2 + (i)*62 -15, 22, 13, "5x",    function() print("you're so awesome") end)
end

function ENT:Draw()
    self:DrawModel()

    local dist = LocalPlayer():GetPos():DistToSqr(self:GetPos())
    if dist > 160000 then return end

    phase = 300 -  (dist / 160000)*255

    cam.Start3D2D(self:LocalToWorld( Vector(17.5, 17.5, 32) ), self:LocalToWorldAngles( Angle(0, 90, 90) ), 0.10)

        button.Draw("Background", 0, {21, 21, 21})

        if dist > 16000 then cam.End3D2D() return end -- too far away to select the screen

        local ftrace = util.IntersectRayWithPlane( EyePos(), EyeVector(), self:LocalToWorld( Vector(17.5, 17.5, 32) ), self:LocalToWorldAngles( Angle(0, 90, 90)):Up() )
        if ftrace == nil then cam.End3D2D() return end

        ftrace = self:WorldToLocal(ftrace) - Vector() -- localize
        c_pos = { x = (ftrace[2] - 17.5) * 10, y = (-ftrace[3] + 32) * 10 } -- transforms based off of offset and scale for the render hook

        local sel = button.FindInside(pan, c_pos)

        button.DrawPanel(pan, {50, 50, 50}, function(index) return sel ~= index end)
        button.Draw(pan, sel, {100, 100, 100})

	cam.End3D2D()
end