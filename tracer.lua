
local targ = Entity(2)
hook.Add("CreateMove", "", function(cmd) -- aimbot to test with :OO
    if not targ:IsValid() then return end

    if not input.IsMouseDown(MOUSE_4) then return end

    local pos = targ:GetPos() + targ:OBBCenter()

    local curAng = LocalPlayer():EyeAngles()
    local targAng = (pos - LocalPlayer():GetShootPos()):Angle()
    local aimAng = LerpAngle(FrameTime()*6, curAng, targAng)

    cmd:SetViewAngles(aimAng)
end)

local traceData = {}
local prevAngle = LocalPlayer():EyeAngles()
local curAngle

local triggerKey = KEY_LALT
local maxLength = 5000

hook.Add("HUDPaint", "", function()
    curAngle = LocalPlayer():EyeAngles()
    local diffX = math.NormalizeAngle(-(prevAngle.x - curAngle.x))
    local diffY = math.NormalizeAngle(-(curAngle.y - prevAngle.y))
    local mult = 6 --math.sqrt((diffX * diffX) + (diffY * diffY))

    local cx, cy = ScrW()/2, ScrH()/2
    local x = (diffY)*mult
    local y = (diffX)*mult

    local len = #traceData
    if x ~= 0 or y ~= 0 and input.IsKeyDown(triggerKey) and len < maxLength then
        table.insert(traceData, {x, y})
    end

    local oX, oY = cx, cy

    for i = 1, len do
        local dat = traceData[i]
        local x_, y_ = dat[1], dat[2]
        x_ = oX + x_
        y_ = oY + y_
        surface.SetDrawColor(
            255-((i/len)*255), 
            (i/len)*255, 
            0
        )
        surface.DrawLine(oX, oY, x_, y_)
        oX = x_
        oY = y_
    end

    -- draw.SimpleText(diffX, "DermaLarge", 500, 500)
    -- draw.SimpleText(diffY, "DermaLarge", 500, 520)

    prevAngle = LocalPlayer():EyeAngles()
end)
