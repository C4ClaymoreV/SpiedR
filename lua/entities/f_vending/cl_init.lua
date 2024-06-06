include("shared.lua")

local pan = "Main"
local sel = 0
local buttons = {}
local button = {}
local slots = ENT.Slots

button.Register = function( panel, index, x, y, w, h, text, price, func )
    buttons[panel] = buttons[panel] or {}
    buttons[panel][index] = {x = x or 0, y = y or 0, w = w or 0, h = h or 0, text = text or "", price = price or 0, func = func or function() end}
end 

button.Draw = function( panel, index, col)
    local b = buttons[panel][index] or nil
    if not b then return end
    local wep = slots[game.GetAmmoName( LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType() )]

    surface.SetDrawColor(col)
    surface.DrawRect(b.x, b.y, b.w, b.h)

    surface.SetDrawColor(255, 255, 255, col["a"])
    surface.DrawOutlinedRect(b.x, b.y, b.w, b.h)

    draw.DrawText(b.text, "HudDefault", b.x + b.w/2, b.y + b.h/2 - 18, Color(255, 255, 255, col["a"]), TEXT_ALIGN_CENTER)
    local price = b.price
    if price ~= 0 then 
        if index == 8 or index == 16 or index == 24 then price = slots[game.GetAmmoName( LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType() )].price end
        if index == 16 then price = price * 5 elseif index == 24 then price = price * 10 end
        draw.DrawText("$" .. price, nil, b.x + b.w/2, b.y + b.h/2 + 6, Color(255, 255, 255, col["a"]), TEXT_ALIGN_CENTER)
    end
end

button.DrawPanel = function( panel, col, filter )
    local filter = filter or function() return true end

    for i, v in pairs( buttons[panel] ) do
        if filter(i) then 
            button.Draw(panel, i, col)
        end
    end
end

button.FindInside = function( panel, pos )
    for i, v in pairs(buttons[panel]) do
        if v.x < pos.x and v.x + v.w > pos.x and v.y < pos.y and v.y + v.h > pos.y then 
            pan = panel
            return i 
        end
    end
    return
end

button.Use = function( panel , index )
    if not buttons[panel][index] then return end
    buttons[panel][index].func()
end

button.GenericBuy = function( index, amount )
    net.Start("vend_use")
        net.WriteInt( index,   5 )
        net.WriteInt( amount, 5 )
    net.SendToServer()
end

net.Receive( "vend_use", function () button.Use(pan, sel) end)

button.Register("Background", 0, 0, 0, 85, 500) -- kinda cheating
button.Register("Background", 1, 0, 0, 412, 939)

for i, v in pairs( slots ) do
    if i == "Equipt" then
        button.Register("Equipt", v.index,      2,   2 + (v.index - 1)*117,      204, 116, v.display .. " (" .. v.amt .. ")", 1000, function() button.GenericBuy(v.index, 1 ) end)
        button.Register("Equipt", v.index + 8,  206, 2 + (v.index - 1)*117,      204, 58,  "BUY 5x" .. " (" .. v.amt*5 .. ")",  1000, function() button.GenericBuy(v.index, 5 ) end)
        button.Register("Equipt", v.index + 16, 206, 2 + (v.index - 1)*117 + 58, 204, 58,  "BUY 10x" .. " (" .. v.amt*10 .. ")", 1000, function() button.GenericBuy(v.index, 10) end)
    else
        button.Register("Main", v.index,      2,   2 + (v.index - 1)*117,      204, 116, v.display .. " (" .. v.amt .. ")", v.price,      function() button.GenericBuy(v.index, 1 ) end)
        button.Register("Main", v.index + 8,  206, 2 + (v.index - 1)*117,      204, 58,  "BUY 5x" .. " (" .. v.amt*5 .. ")",  v.price * 5,  function() button.GenericBuy(v.index, 5 ) end)
        button.Register("Main", v.index + 16, 206, 2 + (v.index - 1)*117 + 58, 204, 58,  "BUY 10x" .. " (" .. v.amt*10 .. ")", v.price * 10, function() button.GenericBuy(v.index, 10) end)
    end
end

function ENT:Draw()
    self:DrawModel()

    local dist = LocalPlayer():GetPos():DistToSqr(self:GetPos())
    if dist > 4194304 then return end -- greater than 2048 units away
    local phase = math.Clamp( 255 - dist/100, 0, 255)

    cam.Start3D2D(self:LocalToWorld( Vector(19, -25, 46.4) ), self:LocalToWorldAngles( Angle(0, 90, 90)), 0.10)

        button.Draw("Background", 1, Color(21, 21, 21))

        if dist < 10000 then -- tile selection distance
            local ftrace = util.IntersectRayWithPlane( EyePos(), EyeVector(), self:LocalToWorld( Vector(19, -25, 46.3) ), self:LocalToWorldAngles( Angle(0, 90, 90)):Up() )
            if ftrace == nil then goto EndSelection end
            ftrace = self:WorldToLocal(ftrace)
        
            c_pos = { x = (ftrace[2] + 25) * 10, y = (-ftrace[3] + 46.4) * 10 } -- transforms based off of offset and scale for the render hook
            if c_pos.x < -10 or c_pos.x > 422 or c_pos.y < -10 or c_pos.y > 949 then sel = 0 goto EndSelection end -- saves the need for a recursive find

            sel = button.FindInside("Main", c_pos) or button.FindInside("Equipt", c_pos)

        else sel = 0 end
        ::EndSelection::
        if dist > 25000 then goto EndMainPanel end -- save drawing buttons since alpha is 0

        button.DrawPanel("Main", Color(50, 50, 50,    phase), function(index) return sel ~= index end)
        button.Draw("Main", sel, Color(100, 100, 100, phase))
        if slots[game.GetAmmoName( LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType() )] then
            button.DrawPanel("Equipt", Color(50, 50, 50,    phase), function(index) return sel ~= index end)
            button.Draw("Equipt", sel, Color(100, 100, 100, phase))
        else sel = 0 end

        ::EndMainPanel::
    cam.End3D2D()
end