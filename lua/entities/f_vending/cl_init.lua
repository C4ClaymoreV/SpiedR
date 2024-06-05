include("shared.lua")

local pan = "Main"
local sel = 0
local buttons = {}
local button = {}

local function DrawIcon(model)

end

button.Register = function( panel, index, x, y, w, h, text, func )
    buttons[panel] = buttons[panel] or {}
    buttons[panel][index] = {x= x or 0, y= y or 0, w= w or 0, h= h or 0, text= text or "", func= func or function() end}
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
    if not buttons[panel][index] then return end
    buttons[panel][index].func()
end

net.Receive( "vend_use", function () button.Use(pan, sel) end)

button.Register("Background", 0, 0, 0, 85, 500) -- kinda cheating
button.Register("Background", 1, 0, 0, 412, 939)


for i = 1, 8 do -- button registeration
    button.Register("Main", i,       2, 2 + (i - 1)*117,   204, 116, "ITEM",  function() print("you're so awesome") end)
    button.Register("Main", i + 8,   206, 2 + (i - 1)*117, 204, 58, "BUY 5", function() print("you're so awesome") end)
    button.Register("Main", i + 16,  206, 2 + (i - 1)*117 + 58, 204, 58, "BUY 10x",    function() print("you're so awesome") end)
end

function ENT:Draw()
    self:DrawModel()

    local dist = LocalPlayer():GetPos():DistToSqr(self:GetPos())

    local phase = math.Clamp( 255 - dist/100, 0, 255)

    cam.Start3D2D(self:LocalToWorld( Vector(17.5, 17.5, 32) ), self:LocalToWorldAngles( Angle(0, 90, 90) ), 0.10)

        button.Draw("Background", 0, Color(21, 21, 21))

        

    
    cam.End3D2D()

    cam.Start3D2D(self:LocalToWorld( Vector(19, -25, 46.4) ), self:LocalToWorldAngles( Angle(0, 90, 90)), 0.10)

        button.Draw("Background", 1, Color(21, 21, 21))

        if dist < 10000 then 
            local ftrace = util.IntersectRayWithPlane( EyePos(), EyeVector(), self:LocalToWorld( Vector(19, -25, 46.3) ), self:LocalToWorldAngles( Angle(0, 90, 90)):Up() )
            if ftrace == nil then goto EndSelection end
            ftrace = self:WorldToLocal(ftrace)
        
            c_pos = { x = (ftrace[2] + 25) * 10, y = (-ftrace[3] + 46.4) * 10 } -- transforms based off of offset and scale for the render hook
            if c_pos.x < -10 or c_pos.x > 949 or c_pos.y < -10 or c_pos.y > 422 then goto EndSelection end -- saves the need for a recursive find

            sel = button.FindInside(pan, c_pos)
        else sel = 0 end
        ::EndSelection::
        if dist > 25000 then goto EndMainPanel end

        button.DrawPanel(pan, Color(50, 50, 50,    phase), function(index) return sel ~= index end)
        button.Draw(pan, sel, Color(100, 100, 100, phase))

        ::EndMainPanel::
    cam.End3D2D()
end