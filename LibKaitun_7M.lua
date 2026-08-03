-- ==============================================================================
-- 👑 LIB KAITUN (7M VND TIER) - ONE-TAP DASHBOARD
-- ==============================================================================
local Lib = {}

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ================================================================
--  THEME CONFIGURATION (Dark Hacker / Glassmorphism)
-- ================================================================
local T = {
    BG          = Color3.fromRGB(15, 15, 20),
    Surface     = Color3.fromRGB(22, 22, 28),
    SurfaceAct  = Color3.fromRGB(30, 30, 40),
    Accent      = Color3.fromRGB(220, 50, 60), -- Crimson Red
    AccentHov   = Color3.fromRGB(250, 70, 80),
    TxtHigh     = Color3.fromRGB(255, 255, 255),
    TxtMid      = Color3.fromRGB(180, 180, 190),
    TxtLow      = Color3.fromRGB(100, 100, 110),
    Border      = Color3.fromRGB(45, 45, 55),
    Green       = Color3.fromRGB(46, 204, 113),
    RadiusMd    = UDim.new(0, 8),
    RadiusSm    = UDim.new(0, 4),
    Font        = Enum.Font.GothamMedium,
    FontBold    = Enum.Font.GothamBold,
    FontMono    = Enum.Font.Code,
}

-- ================================================================
--  UTILITIES
-- ================================================================
local Util = {}

function Util.New(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
    -- Auto Glassmorphism Effect
    if obj:IsA("GuiObject") and not (props and props.BackgroundTransparency) then
        local s, bgCol = pcall(function() return obj.BackgroundColor3 end)
        if s then
            if bgCol == T.Surface or bgCol == T.SurfaceAct then
                obj.BackgroundTransparency = 0.3
            elseif bgCol == T.BG then
                obj.BackgroundTransparency = 0.15
            end
        end
    end
    return obj
end

function Util.Tween(obj, props, time, style)
    local tw = TweenService:Create(obj, TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

function Util.Corner(parent, radius)
    return Util.New("UICorner", { CornerRadius = radius or T.RadiusMd, Parent = parent })
end

function Util.Stroke(parent, color, transp, thick)
    return Util.New("UIStroke", { Color = color or T.Border, Transparency = transp or 0.2, Thickness = thick or 1, Parent = parent })
end

function Util.MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Util.Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1, Enum.EasingStyle.Linear)
        end
    end)
end

function Util.Shadow(parent)
    return Util.New("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993", ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.5,
        Size = UDim2.new(1, 40, 1, 40), Position = UDim2.new(0, -20, 0, -20),
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = parent.ZIndex - 1, Parent = parent
    })
end

-- ================================================================
--  MAIN LIBRARY INIT
-- ================================================================
function Lib:CreateWindow(cfg)
    cfg = cfg or {}
    local Title = cfg.Title or "Kaitun Hub"
    local Avatar = cfg.AvatarImage or "rbxassetid://13589139360"
    local UseFPSBoost = cfg.FPS or false

    -- 1. Anti-Duplication
    local s = pcall(function() return CoreGui.Name end)
    local GuiParent = s and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    if GuiParent:FindFirstChild("LibKaitun_7M") then
        GuiParent.LibKaitun_7M:Destroy()
    end

    -- 2. Anti-Lag (FPS Boost) System
    if UseFPSBoost then
        task.spawn(function()
            pcall(function()
                local Lighting = game:GetService("Lighting")
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Material = Enum.Material.SmoothPlastic
                        v.Reflectance = 0
                        v.CastShadow = false
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v.Transparency = 1
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        v.Enabled = false
                    end
                end
                
                workspace.DescendantAdded:Connect(function(v)
                    if v:IsA("BasePart") then
                        v.Material = Enum.Material.SmoothPlastic
                        v.CastShadow = false
                    end
                end)
            end)
        end)
    end

    -- 3. UI Construction
    local Gui = Util.New("ScreenGui", {
        Name = "LibKaitun_7M", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999, IgnoreGuiInset = true, Parent = GuiParent
    })

    -- Circular Avatar Toggle (Mini Menu)
    local AvatarToggle = Util.New("ImageButton", {
        BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 1,
        Size = UDim2.new(0, 80, 0, 80), Position = UDim2.new(0.5, 0, 0.1, 0),
        AnchorPoint = Vector2.new(0.5, 0.5), Image = Avatar,
        ZIndex = 100, Parent = Gui
    })
    Util.Corner(AvatarToggle, UDim.new(1,0))
    Util.Stroke(AvatarToggle, T.Accent, 0, 2)
    Util.Shadow(AvatarToggle)
    Util.MakeDraggable(AvatarToggle)

    -- Pulsing Stroke for Avatar
    task.spawn(function()
        local t = 0
        while AvatarToggle and AvatarToggle.Parent do
            t = t + task.wait()
            AvatarToggle.UIStroke.Transparency = 0.2 + math.sin(t * 3) * 0.2
        end
    end)

    -- Main Dashboard Window
    local Win = Util.New("Frame", {
        BackgroundColor3 = T.BG, Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true, Visible = false, Parent = Gui
    })
    Util.Corner(Win, T.RadiusMd)
    Util.Stroke(Win, T.Border)
    Util.Shadow(Win)

    local TargetSize = UDim2.new(0, 680, 0, 420)
    local IsOpen = false

    AvatarToggle.MouseButton1Click:Connect(function()
        IsOpen = not IsOpen
        if IsOpen then
            Win.Visible = true
            Util.Tween(Win, {Size = TargetSize}, 0.5, Enum.EasingStyle.Back)
        else
            Util.Tween(Win, {Size = UDim2.new(0,0,0,0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.delay(0.45, function() Win.Visible = false end)
        end
    end)

    -- Title Bar
    local TitleBar = Util.New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Parent = Win
    })
    Util.MakeDraggable(Win, TitleBar)
    
    Util.New("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 20, 0, 0),
        Font = T.FontBold, Text = Title, TextColor3 = T.TxtHigh, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Parent = TitleBar
    })

    -- Layout Columns
    local Body = Util.New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, -50), Position = UDim2.new(0, 10, 0, 40), Parent = Win
    })
    Util.New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), Parent = Body
    })

    -- LEFT COLUMN (Profile & Big Button)
    local LeftCol = Util.New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(0, 220, 1, 0), Parent = Body
    })
    
    local ProfileBox = Util.New("Frame", {
        BackgroundColor3 = T.Surface, Size = UDim2.new(1, 0, 0, 260), Parent = LeftCol
    })
    Util.Corner(ProfileBox)
    Util.Stroke(ProfileBox)
    
    local ProfImg = Util.New("ImageLabel", {
        BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 0, 100), Position = UDim2.new(0.5, 0, 0, 20),
        AnchorPoint = Vector2.new(0.5, 0), Image = Avatar, Parent = ProfileBox
    })
    Util.Corner(ProfImg, UDim.new(1,0))
    Util.Stroke(ProfImg, T.Accent, 0, 2)

    local PlayerName = Util.New("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 130),
        Font = T.FontBold, Text = LocalPlayer.Name, TextColor3 = T.TxtHigh, TextSize = 16, Parent = ProfileBox
    })

    local StatsWrap = Util.New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 90), Position = UDim2.new(0, 10, 0, 160), Parent = ProfileBox
    })
    Util.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 4), Parent = StatsWrap })

    local function MakeStatLine(icon, name, initVal, col)
        local f = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Parent = StatsWrap })
        Util.New("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0),
            Font = T.Font, Text = icon .. " " .. name, TextColor3 = T.TxtMid, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = f
        })
        local vLbl = Util.New("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0),
            Font = T.FontBold, Text = initVal, TextColor3 = col or T.TxtHigh, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Parent = f
        })
        return vLbl
    end

    local StatLevel = MakeStatLine("📈", "Level:", "1", T.Green)
    local StatBeli  = MakeStatLine("💲", "Beli:", "$0", T.Green)
    local StatFrag  = MakeStatLine("🔮", "Frags:", "0", Color3.fromRGB(155, 89, 182))
    local StatRace  = MakeStatLine("🧬", "Race:", "Human", T.TxtHigh)

    local KaitunBtn = Util.New("TextButton", {
        BackgroundColor3 = T.Accent, Size = UDim2.new(1, 0, 1, -270), Position = UDim2.new(0, 0, 0, 270),
        Font = T.FontBold, Text = "START KAITUN", TextColor3 = Color3.new(1,1,1), TextSize = 20, AutoButtonColor = false, Parent = LeftCol
    })
    Util.Corner(KaitunBtn)
    Util.Shadow(KaitunBtn)

    local IsKaituning = false
    KaitunBtn.MouseButton1Click:Connect(function()
        if not IsKaituning then
            IsKaituning = true
            Util.Tween(KaitunBtn, {BackgroundColor3 = T.Border}, 0.2)
            KaitunBtn.Text = "KAITUN ACTIVE"
        end
    end)

    -- RIGHT COLUMN (Status & Toggles)
    local RightCol = Util.New("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -230, 1, 0), Parent = Body
    })

    -- Status Box
    local StatusBox = Util.New("Frame", {
        BackgroundColor3 = T.Surface, Size = UDim2.new(1, 0, 0, 100), Parent = RightCol
    })
    Util.Corner(StatusBox)
    Util.Stroke(StatusBox)

    Util.New("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 10),
        Font = T.FontBold, Text = "⚡ TRẠNG THÁI HIỆN TẠI", TextColor3 = T.TxtHigh, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = StatusBox
    })

    local CurrTaskLbl = Util.New("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 10, 0, 35),
        Font = T.FontBold, Text = "Waiting to Start...", TextColor3 = T.Accent, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Parent = StatusBox
    })

    local ProgressBG = Util.New("Frame", {
        BackgroundColor3 = T.BG, Size = UDim2.new(1, -20, 0, 14), Position = UDim2.new(0, 10, 0, 70), Parent = StatusBox
    })
    Util.Corner(ProgressBG, UDim.new(1,0))
    local ProgressFill = Util.New("Frame", {
        BackgroundColor3 = T.Accent, Size = UDim2.new(0, 0, 1, 0), Parent = ProgressBG
    })
    Util.Corner(ProgressFill, UDim.new(1,0))
    local ProgressTxt = Util.New("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
        Font = T.FontBold, Text = "0%", TextColor3 = Color3.new(1,1,1), TextSize = 10, Parent = ProgressBG
    })

    -- Scrollable Toggles Area
    local Scroll = Util.New("ScrollingFrame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -110), Position = UDim2.new(0, 0, 0, 110),
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = T.Border, Parent = RightCol
    })
    Util.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8), Parent = Scroll })

    -- API EXPORT
    local KaitunAPI = {}
    
    function KaitunAPI:SetStatus(text)
        CurrTaskLbl.Text = tostring(text)
    end

    function KaitunAPI:UpdateProgress(current, max)
        local pct = math.clamp(current / max, 0, 1)
        Util.Tween(ProgressFill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.2)
        ProgressTxt.Text = math.floor(pct * 100) .. "% (" .. current .. "/" .. max .. ")"
    end

    function KaitunAPI:UpdateStats(stats)
        if stats.Level then StatLevel.Text = tostring(stats.Level) end
        if stats.Beli then StatBeli.Text = tostring(stats.Beli) end
        if stats.Fragments then StatFrag.Text = tostring(stats.Fragments) end
        if stats.Race then StatRace.Text = tostring(stats.Race) end
    end

    function KaitunAPI:OnStart(cb)
        local Fired = false
        KaitunBtn.MouseButton1Click:Connect(function()
            if not Fired and cb then
                Fired = true
                cb(true)
            end
        end)
    end

    function KaitunAPI:CreateToggle(opts)
        opts = opts or {}
        local state = opts.Default or false

        local btn = Util.New("TextButton", {
            BackgroundColor3 = T.Surface, Size = UDim2.new(1, -10, 0, 44),
            Text = "", AutoButtonColor = false, Parent = Scroll
        })
        Util.Corner(btn, T.RadiusSm)
        Util.Stroke(btn)

        local title = Util.New("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 14, 0, 0),
            Font = T.Font, Text = opts.Name or "Toggle", TextColor3 = T.TxtHigh, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn
        })

        local switchBG = Util.New("Frame", {
            BackgroundColor3 = state and T.Accent or T.BG, Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -54, 0.5, -10), Parent = btn
        })
        Util.Corner(switchBG, UDim.new(1,0))
        Util.Stroke(switchBG, T.Border)

        local dot = Util.New("Frame", {
            BackgroundColor3 = Color3.new(1,1,1), Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, state and 23 or 3, 0.5, -7), Parent = switchBG
        })
        Util.Corner(dot, UDim.new(1,0))

        btn.MouseButton1Click:Connect(function()
            state = not state
            Util.Tween(switchBG, {BackgroundColor3 = state and T.Accent or T.BG}, 0.2)
            Util.Tween(dot, {Position = UDim2.new(0, state and 23 or 3, 0.5, -7)}, 0.2)
            if opts.Callback then opts.Callback(state) end
        end)

        return {
            Set = function(self, val)
                state = val
                Util.Tween(switchBG, {BackgroundColor3 = state and T.Accent or T.BG}, 0.2)
                Util.Tween(dot, {Position = UDim2.new(0, state and 23 or 3, 0.5, -7)}, 0.2)
                if opts.Callback then opts.Callback(state) end
            end,
            Get = function() return state end
        }
    end

    -- Open immediately on load
    IsOpen = true
    Win.Visible = true
    Win.Size = TargetSize

    return KaitunAPI
end

return Lib
