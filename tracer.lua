
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
local lastExport = 0

local bExporting = false
local tExportData = {}
local function Export()
    tExportData = table.Copy(traceData)
    bExporting = true
end

local function DrawLine(x1, y1, x2, y2, thickness)
    thickness = math.ceil(thickness / 2)
    for x = -thickness, thickness, 1 do
        for y = -thickness, thickness, 1 do
            surface.DrawLine(x1 + x, y1 + y, x2 + x, y2 + y)
        end
    end
end

hook.Add("PostRender", "", function()
    if bExporting then
        cam.Start2D()
        
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(0, 0, ScrW(), ScrH())

        -- surface.SetDrawColor(255, 0, 0)
        -- surface.DrawRect(10, 10, 20, 20)

        -- PrintTable(traceData)
        local len = #traceData
        local cx, cy = ScrW()/2, ScrH()/2
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
            ::boop::
    
            DrawLine(oX, oY, x_, y_, 2)
            oX = x_
            oY = y_
        end

        cam.End2D()

        local img = render.Capture({
            format = "png", 
            x = 0, y = 0,
            w = ScrW(), h = ScrH(),
            quality = 100
        })

        file.Write("eye_trace_export.png", img)

        bExporting = false
        return true
    end
end)

hook.Add("HUDPaint", "", function()
    if bExporting then surface.SetDrawColor(0, 0, 0) surface.DrawRect(0, 0, w, h) draw.SimpleText("Exporting as PNG", "DermaLarge", ScrW()/2, ScrH()/2, color_white, 1, 1) return end
    if input.IsKeyDown(KEY_INSERT) and SysTime() - lastExport > 5 then
        Export()
        lastExport = SysTime()
        return
    end

    curAngle = LocalPlayer():EyeAngles()
    local diffX = math.NormalizeAngle(-(prevAngle.x - curAngle.x))
    local diffY = math.NormalizeAngle(-(curAngle.y - prevAngle.y))

    
    local mult = 6 --math.sqrt((diffX * diffX) + (diffY * diffY))
    
    local x = (diffY)*mult
    local y = (diffX)*mult
    
    local cx, cy = ScrW()/2, ScrH()/2
    
    local len = #traceData
    if (x ~= 0 or y ~= 0) and input.IsKeyDown(triggerKey) and len < maxLength then
        local ang = (Vector(cx, cy)-Vector(cx+x, cy+y)):Angle() -- not exactly a cheap calculation so it's going in here
        table.insert(traceData, {x, y, ang})
    end
    
    -- print(ang:Forward())
    local oX, oY = cx, cy
    for i = 1, len do
        local dat = traceData[i]
        local x_, y_ = dat[1], dat[2]
        x_ = oX + x_
        y_ = oY + y_

        -- Aimbot detection WIP
        --
        -- local ang = dat[3]
        -- local prevAng = traceData[i-1]
        -- prevAng = prevAng and prevAng[3]
        -- if prevAng then
        --     local diff = prevAng - ang
        --     local dx, dy = diff.x, diff.y
        --     if dx < 0.00001 and dy < 0.00001 then
        --         surface.SetDrawColor(0, 0, 255)
        --         goto boop
        --     end
        -- end

        surface.SetDrawColor(
            255-((i/len)*255), 
            (i/len)*255, 
            0
        )
        ::boop::

        DrawLine(oX, oY, x_, y_, 2)
        oX = x_
        oY = y_
    end

    -- draw.SimpleText(diffX, "DermaLarge", 500, 500)
    -- draw.SimpleText(diffY, "DermaLarge", 500, 520)

    prevAngle = LocalPlayer():EyeAngles()
end)
