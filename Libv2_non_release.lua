--[[
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                   Libv2 (Non-Release)                        ║
║           Roblox Luau UI Library  |  Full Source             ║
║                                                              ║
║   Developer  :  loffy327                                     ║
║   Version    :  2.0.0 (Exclusive Build)                      ║
║   License    :  Full Source  -  6,000,000 VND                ║
║                                                              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║   NEW IN Libv2 (6M VND TIER):                                ║
║   - Floating Circular Avatar Toggle (supports rbxassetid)    ║
║   - Glassmorphism & Glossy UI aesthetic                      ║
║   - CreateImage / CreateImageButton for rbxassetid support   ║
║   - Pristine drop shadows and blur effects                   ║
║   - Full logic from V3 (MultiDropdowns, Input Sliders, etc)  ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
]]

local Libv2 = {}
Libv2.__index = Libv2
Libv2.Version = "2.0.0-NR"

-- ================================================================
--  SERVICES
-- ================================================================

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ================================================================
--  DEFAULT THEME (Glassmorphism / Premium)
-- ================================================================

local DefaultTheme = {
    -- Backgrounds
    BG          = Color3.fromRGB(18, 18, 25),
    BGAlt       = Color3.fromRGB(24, 24, 34),
    Surface     = Color3.fromRGB(30, 30, 42),
    SurfaceHov  = Color3.fromRGB(38, 38, 52),
    SurfaceAct  = Color3.fromRGB(48, 48, 65),

    -- Accent
    Accent      = Color3.fromRGB(114, 137, 218),
    AccentHov   = Color3.fromRGB(134, 157, 238),
    AccentDim   = Color3.fromRGB(80, 100, 180),

    -- Text
    TxtHigh     = Color3.fromRGB(250, 250, 255),
    TxtMid      = Color3.fromRGB(180, 180, 195),
    TxtLow      = Color3.fromRGB(110, 110, 125),

    -- Borders
    Border      = Color3.fromRGB(55, 55, 75),
    BorderHov   = Color3.fromRGB(80, 80, 105),

    -- Status
    Green       = Color3.fromRGB(46, 204, 113),
    Yellow      = Color3.fromRGB(241, 196, 15),
    Red         = Color3.fromRGB(231, 76, 60),
    Blue        = Color3.fromRGB(52, 152, 219),

    -- Misc
    Divider     = Color3.fromRGB(40, 40, 55),
    Scrollbar   = Color3.fromRGB(65, 65, 85),

    -- Font
    FontBold    = Enum.Font.GothamBold,
    FontMed     = Enum.Font.GothamMedium,
    FontMono    = Enum.Font.Code,

    -- Radius
    RadiusLg    = UDim.new(0, 12),
    RadiusMd    = UDim.new(0, 8),
    RadiusSm    = UDim.new(0, 6),
    RadiusXs    = UDim.new(0, 4),

    -- Timing
    TweenTime   = 0.25,
    TweenStyle  = Enum.EasingStyle.Quint,
}

-- ================================================================
--  INTERNAL UTILITIES
-- ================================================================

local Util = {}

function Util.Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(
        t     or DefaultTheme.TweenTime,
        style or DefaultTheme.TweenStyle,
        dir   or Enum.EasingDirection.Out
    )
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

function Util.New(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
    return obj
end

function Util.Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or DefaultTheme.RadiusMd
    c.Parent = parent
    return c
end

function Util.Stroke(parent, color, thick, transp)
    local s = Instance.new("UIStroke")
    s.Color        = color or DefaultTheme.Border
    s.Thickness    = thick or 1
    s.Transparency = transp or 0
    s.Parent       = parent
    return s
end

function Util.Padding(parent, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 8)
    p.PaddingRight  = UDim.new(0, r or 8)
    p.PaddingBottom = UDim.new(0, b or 8)
    p.PaddingLeft   = UDim.new(0, l or 8)
    p.Parent = parent
    return p
end

function Util.ListLayout(parent, dir, halign, valign, pad)
    local l = Instance.new("UIListLayout")
    l.FillDirection         = dir    or Enum.FillDirection.Vertical
    l.HorizontalAlignment   = halign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment     = valign or Enum.VerticalAlignment.Top
    l.Padding               = pad    or UDim.new(0, 6)
    l.SortOrder             = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

function Util.Shadow(parent)
    local s = Util.New("ImageLabel", {
        Name               = "_Shadow",
        BackgroundTransparency = 1,
        Image              = "rbxassetid://6014261993",
        ImageColor3        = Color3.new(0, 0, 0),
        ImageTransparency  = 0.5,
        Size               = UDim2.new(1, 40, 1, 40),
        Position           = UDim2.new(0, -20, 0, -20),
        ZIndex             = parent.ZIndex - 1,
        ScaleType          = Enum.ScaleType.Slice,
        SliceCenter        = Rect.new(49, 49, 450, 450),
        Parent             = parent,
    })
    return s
end

function Util.Ripple(btn, color)
    local rip = Util.New("Frame", {
        Name                = "_Ripple",
        BackgroundColor3    = color or Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        Size                = UDim2.new(0, 0, 0, 0),
        Position            = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint         = Vector2.new(0.5, 0.5),
        ZIndex              = btn.ZIndex + 5,
        Parent              = btn,
    })
    Util.Corner(rip, UDim.new(1, 0))
    Util.Tween(rip, {
        Size = UDim2.new(2.5, 0, 2.5, 0),
        BackgroundTransparency = 1
    }, 0.5, Enum.EasingStyle.Quad)
    task.delay(0.6, function()
        if rip and rip.Parent then rip:Destroy() end
    end)
end

function Util.HoverBind(frame, normal, hover, prop)
    prop = prop or "BackgroundColor3"
    frame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then
            Util.Tween(frame, {[prop] = hover}, 0.15)
        end
    end)
    frame.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then
            Util.Tween(frame, {[prop] = normal}, 0.15)
        end
    end)
end

function Util.GetTextBounds(text, font, size, bounds)
    local textLabel = Util.New("TextLabel", {
        Text = text,
        Font = font,
        TextSize = size,
        Size = UDim2.new(0, bounds.X, 0, bounds.Y),
        TextWrapped = true,
    })
    local result = textLabel.TextBounds
    textLabel:Destroy()
    return result
end

function Util.MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        Util.Tween(frame, {
            Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        }, 0.1, Enum.EasingStyle.Linear)
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
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
            update(input)
        end
    end)
end

-- ================================================================
--  CREATE WINDOW
-- ================================================================

function Libv2:CreateWindow(cfg)
    cfg = cfg or {}

    local T = cfg.Theme or DefaultTheme

    if cfg.AccentColor then
        T = {}
        for k, v in pairs(DefaultTheme) do T[k] = v end
        T.Accent    = cfg.AccentColor
        T.AccentHov = cfg.AccentColor
        T.AccentDim = cfg.AccentColor
    end

    local WCfg = {
        Title        = cfg.Title        or "Libv2 Menu",
        Subtitle     = cfg.Subtitle     or "Premium",
        LogoText     = cfg.LogoText     or "V2",
        LogoImage    = cfg.LogoImage    or nil,
        AvatarImage  = cfg.AvatarImage  or "rbxassetid://13589139360",
        Size         = cfg.Size         or UDim2.new(0, 650, 0, 480),
        MinSize      = cfg.MinSize      or UDim2.new(0, 650, 0, 52),
        ConfigKey    = cfg.ConfigKey    or "Libv2Config",
        ToggleKey    = cfg.ToggleKey    or Enum.KeyCode.RightShift,
        TutorialMode = (cfg.TutorialMode == nil) and true or cfg.TutorialMode,
    }

    -- ============================================================
    --  STATE
    -- ============================================================

    local State = {
        Minimized   = false,
        Maximized   = false,
        MenuVisible = false,
        ActiveTab   = nil,
        Tabs        = {},
        Data        = {},
        Elements    = {}, -- Track for Search
    }

    -- ============================================================
    --  SCREEN GUI & ANTI-DUPLICATION
    -- ============================================================
    
    local CoreGui = game:GetService("CoreGui")
    local success = pcall(function() return CoreGui.Name end)
    local GuiParent = success and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

    if GuiParent:FindFirstChild("Libv2_Premium") then
        GuiParent:FindFirstChild("Libv2_Premium"):Destroy()
    end

    local Gui = Util.New("ScreenGui", {
        Name            = "Libv2_Premium",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        DisplayOrder    = 999,
        IgnoreGuiInset  = true,
        Parent          = GuiParent,
    })

    -- ============================================================
    --  FLOATING AVATAR TOGGLE
    -- ============================================================
    local AvatarToggle = Util.New("ImageButton", {
        Name = "AvatarToggle",
        BackgroundColor3 = T.Surface,
        Size = UDim2.new(0, 60, 0, 60),
        Position = UDim2.new(0.5, 0, 0.1, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = WCfg.AvatarImage,
        AutoButtonColor = false,
        ZIndex = 100,
        Parent = Gui
    })
    Util.Corner(AvatarToggle, UDim.new(1, 0))
    Util.Stroke(AvatarToggle, T.Accent, 2, 0)
    Util.Shadow(AvatarToggle)

    task.spawn(function()
        local t = 0
        while AvatarToggle and AvatarToggle.Parent do
            t = t + task.wait()
            local offset = math.sin(t * 2) * 5
            AvatarToggle.UIStroke.Transparency = 0.2 + math.sin(t * 3) * 0.2
        end
    end)

    Util.MakeDraggable(AvatarToggle)

    -- ============================================================
    --  MAIN WINDOW
    -- ============================================================

    local Win = Util.New("Frame", {
        Name              = "Window",
        BackgroundColor3  = T.BG,
        Size              = UDim2.new(0, 0, 0, 0),
        Position          = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint       = Vector2.new(0.5, 0.5),
        ClipsDescendants  = true,
        BackgroundTransparency = 1,
        Visible           = false,
        Parent            = Gui,
    })
    Util.Corner(Win, T.RadiusLg)
    Util.Stroke(Win, T.Border, 1, 0.4)
    Util.Shadow(Win)

    -- Glassmorphism look
    Win.BackgroundTransparency = 0.05

    AvatarToggle.MouseButton1Click:Connect(function()
        State.MenuVisible = not State.MenuVisible
        if State.MenuVisible then
            Win.Visible = true
            Util.Tween(Win, {Size = WCfg.Size}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            Util.Tween(Win, {Size = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.delay(0.45, function() Win.Visible = false end)
        end
    end)

    -- ============================================================
    --  TOP ACCENT LINE (Glow)
    -- ============================================================

    local AccentLine = Util.New("Frame", {
        BackgroundColor3 = T.Accent,
        Size             = UDim2.new(1, 0, 0, 3),
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = Win,
    })

    do
        local g = Util.New("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,   Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(0.5, T.Accent),
                ColorSequenceKeypoint.new(1,   Color3.new(1,1,1)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0,   0.9),
                NumberSequenceKeypoint.new(0.5, 0),
                NumberSequenceKeypoint.new(1,   0.9),
            }),
            Parent = AccentLine,
        })
        task.spawn(function()
            while AccentLine and AccentLine.Parent do
                Util.Tween(g, {Offset = Vector2.new(1, 0)}, 2, Enum.EasingStyle.Linear)
                task.wait(2)
                g.Offset = Vector2.new(-1, 0)
            end
        end)
    end

    -- ============================================================
    --  TITLE BAR
    -- ============================================================

    local TitleBar = Util.New("Frame", {
        Name             = "TitleBar",
        BackgroundColor3 = T.BGAlt,
        BackgroundTransparency = 0.2,
        Size             = UDim2.new(1, 0, 0, 52),
        Position         = UDim2.new(0, 0, 0, 3),
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = Win,
    })

    Util.New("Frame", {
        BackgroundColor3 = T.Divider,
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = TitleBar,
    })

    -- Logo badge
    local LogoBadge = Util.New("Frame", {
        BackgroundColor3 = T.Accent,
        Size             = UDim2.new(0, 32, 0, 32),
        Position         = UDim2.new(0, 16, 0.5, 0),
        AnchorPoint      = Vector2.new(0, 0.5),
        ZIndex           = 4,
        Parent           = TitleBar,
    })
    Util.Corner(LogoBadge, UDim.new(0, 8))

    if WCfg.LogoImage then
        Util.New("ImageLabel", {
            BackgroundTransparency = 1,
            Size        = UDim2.new(0.7, 0, 0.7, 0),
            Position    = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image       = WCfg.LogoImage,
            ZIndex      = 5,
            Parent      = LogoBadge,
        })
    else
        Util.New("TextLabel", {
            BackgroundTransparency = 1,
            Size        = UDim2.new(1, 0, 1, 0),
            Font        = T.FontBold,
            Text        = WCfg.LogoText,
            TextColor3  = Color3.new(1, 1, 1),
            TextSize    = 18,
            ZIndex      = 5,
            Parent      = LogoBadge,
        })
    end

    -- Title text
    Util.New("TextLabel", {
        BackgroundTransparency = 1,
        Size        = UDim2.new(0.45, -55, 0, 22),
        Position    = UDim2.new(0, 60, 0, 8),
        Font        = T.FontBold,
        Text        = WCfg.Title,
        TextColor3  = T.TxtHigh,
        TextSize    = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex      = 4,
        Parent      = TitleBar,
    })

    Util.New("TextLabel", {
        BackgroundTransparency = 1,
        Size        = UDim2.new(0.45, -55, 0, 14),
        Position    = UDim2.new(0, 60, 0, 30),
        Font        = T.FontMed,
        Text        = WCfg.Subtitle,
        TextColor3  = T.TxtLow,
        TextSize    = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex      = 4,
        Parent      = TitleBar,
    })

    -- Search Bar
    local SearchWrap = Util.New("Frame", {
        BackgroundColor3 = T.SurfaceAct,
        Size = UDim2.new(0, 180, 0, 28),
        Position = UDim2.new(1, -320, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 5,
        Parent = TitleBar
    })
    Util.Corner(SearchWrap, T.RadiusSm)
    Util.Stroke(SearchWrap, T.Border, 1)

    local SearchIcon = Util.New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 26, 1, 0),
        Position = UDim2.new(0, 2, 0, 0),
        Font = T.FontMed, Text = "🔍", TextColor3 = T.TxtLow, TextSize = 13,
        ZIndex = 6, Parent = SearchWrap
    })

    local SearchBox = Util.New("TextBox", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.new(0, 26, 0, 0),
        Font = T.FontMed, Text = "", PlaceholderText = "Search features...",
        TextColor3 = T.TxtHigh, PlaceholderColor3 = T.TxtLow, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 6, Parent = SearchWrap
    })

    Util.MakeDraggable(Win, TitleBar)

    -- ============================================================
    --  WINDOW CONTROLS  [Minimize]  [Maximize]  [Close]
    -- ============================================================

    local CtrlFrame = Util.New("Frame", {
        BackgroundTransparency = 1,
        Size        = UDim2.new(0, 114, 0, 34),
        Position    = UDim2.new(1, -122, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex      = 5,
        Parent      = TitleBar,
    })

    Util.New("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
        Padding             = UDim.new(0, 8),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = CtrlFrame,
    })

    local function MakeCtrlBtn(name, label, hoverCol, layoutOrder, cb)
        local btn = Util.New("TextButton", {
            Name             = name,
            BackgroundColor3 = T.SurfaceAct,
            Size             = UDim2.new(0, 34, 0, 34),
            Font             = T.FontBold,
            Text             = label,
            TextColor3       = T.TxtMid,
            TextSize         = 16,
            AutoButtonColor  = false,
            LayoutOrder      = layoutOrder,
            ZIndex           = 6,
            Parent           = CtrlFrame,
        })
        Util.Corner(btn, T.RadiusSm)

        btn.MouseEnter:Connect(function()
            Util.Tween(btn, {BackgroundColor3 = hoverCol, TextColor3 = Color3.new(1,1,1)}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Util.Tween(btn, {BackgroundColor3 = T.SurfaceAct, TextColor3 = T.TxtMid}, 0.15)
        end)
        btn.MouseButton1Click:Connect(function()
            Util.Ripple(btn)
            if cb then cb() end
        end)

        return btn
    end

    -- [1] Minimize
    MakeCtrlBtn("Minimize", "-", T.Yellow, 1, function()
        State.Minimized = not State.Minimized
        if State.Minimized then
            Util.Tween(Win, {Size = WCfg.MinSize}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        else
            local target = State.Maximized and UDim2.new(1,-40,1,-40) or WCfg.Size
            Util.Tween(Win, {Size = target}, 0.35, Enum.EasingStyle.Back)
        end
    end)

    -- [2] Maximize
    MakeCtrlBtn("Maximize", "+", T.Green, 2, function()
        if State.Minimized then State.Minimized = false end
        State.Maximized = not State.Maximized
        if State.Maximized then
            Util.Tween(Win, {Size = UDim2.new(1,-40,1,-40), Position = UDim2.new(0.5,0,0.5,0)}, 0.35, Enum.EasingStyle.Back)
        else
            Util.Tween(Win, {Size = WCfg.Size, Position = UDim2.new(0.5,0,0.5,0)}, 0.35, Enum.EasingStyle.Back)
        end
    end)

    -- [3] Close
    MakeCtrlBtn("Close", "X", T.Red, 3, function()
        Util.Tween(Win, {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        State.MenuVisible = false
    end)

    -- Toggle key bindings
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == WCfg.ToggleKey then
            State.MenuVisible = not State.MenuVisible
            if State.MenuVisible then
                Win.Visible = true
                Util.Tween(Win, {Size = WCfg.Size}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            else
                Util.Tween(Win, {Size = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                task.delay(0.45, function() Win.Visible = false end)
            end
        end
    end)

    -- ============================================================
    --  BODY  (Sidebar | Content)
    -- ============================================================

    local Body = Util.New("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, 0, 1, -55),
        Position = UDim2.new(0, 0, 0, 55),
        ZIndex   = 2,
        Parent   = Win,
    })

    -- ---- SIDEBAR ----

    local Sidebar = Util.New("Frame", {
        BackgroundColor3       = T.BGAlt,
        BackgroundTransparency = 0.3,
        Size        = UDim2.new(0, 180, 1, 0),
        BorderSizePixel = 0,
        ZIndex      = 2,
        Parent      = Body,
    })

    Util.New("Frame", {
        BackgroundColor3 = T.Divider,
        Size        = UDim2.new(0, 1, 1, 0),
        Position    = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0,
        ZIndex      = 3,
        Parent      = Sidebar,
    })

    local SideScroll = Util.New("ScrollingFrame", {
        BackgroundTransparency  = 1,
        Size        = UDim2.new(1, -12, 1, -16),
        Position    = UDim2.new(0, 6, 0, 8),
        CanvasSize  = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ScrollBarThickness     = 2,
        ScrollBarImageColor3   = T.Scrollbar,
        BorderSizePixel = 0,
        ZIndex      = 2,
        Parent      = Sidebar,
    })
    Util.ListLayout(SideScroll, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, UDim.new(0, 4))

    -- ---- CONTENT ----

    local Content = Util.New("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, -180, 1, 0),
        Position = UDim2.new(0, 180, 0, 0),
        ClipsDescendants = true,
        ZIndex   = 2,
        Parent   = Body,
    })

    -- Search Page
    local SearchPage = Util.New("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size        = UDim2.new(1, -16, 1, -16),
        Position    = UDim2.new(0, 8, 0, 8),
        CanvasSize  = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness  = 3,
        ScrollBarImageColor3 = T.Scrollbar,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex  = 3,
        Parent  = Content,
    })
    Util.ListLayout(SearchPage, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, UDim.new(0, 8))
    Util.Padding(SearchPage, 6, 6, 6, 6)

    SearchBox.Changed:Connect(function(prop)
        if prop == "Text" then
            local q = string.lower(SearchBox.Text)
            if q == "" then
                SearchPage.Visible = false
                if State.ActiveTab then State.ActiveTab.Page.Visible = true end
                -- Restore all elements
                for _, el in ipairs(State.Elements) do
                    if el.Row and el.OriginalPage then
                        el.Row.Parent = el.OriginalPage
                    end
                end
                State.Elements = {}
            else
                if State.ActiveTab then State.ActiveTab.Page.Visible = false end
                SearchPage.Visible = true
                
                -- Index elements on first search
                if #State.Elements == 0 then
                    for _, tab in ipairs(State.Tabs) do
                        for _, row in ipairs(tab.Page:GetChildren()) do
                            if row:IsA("Frame") or row:IsA("TextButton") then
                                local name = ""
                                for _, c in ipairs(row:GetChildren()) do
                                    if c:IsA("TextLabel") and c.Text ~= "" then
                                        name = name .. " " .. c.Text
                                    end
                                end
                                table.insert(State.Elements, { Name = name, Row = row, OriginalPage = tab.Page })
                            end
                        end
                    end
                end

                for _, el in ipairs(State.Elements) do
                    if string.find(string.lower(el.Name), q) then
                        el.Row.Parent = SearchPage
                    else
                        el.Row.Parent = nil
                    end
                end
            end
        end
    end)

    -- ============================================================
    --  NOTIFICATION SYSTEM
    -- ============================================================

    local NotifContainer = Util.New("Frame", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 320, 1, -20),
        Position = UDim2.new(1, -330, 0, 10),
        ZIndex   = 100,
        Parent   = Gui,
    })
    do
        local nl = Instance.new("UIListLayout")
        nl.SortOrder           = Enum.SortOrder.LayoutOrder
        nl.VerticalAlignment   = Enum.VerticalAlignment.Bottom
        nl.Padding             = UDim.new(0, 10)
        nl.Parent              = NotifContainer
    end

    local NotifCount = 0

    local function Notify(opts)
        opts = opts or {}
        NotifCount = NotifCount + 1

        local typeMap = {
            Success = T.Green,
            Warning = T.Yellow,
            Error   = T.Red,
            Info    = T.Blue,
        }
        local barColor = typeMap[opts.Type] or T.Accent

        local nf = Util.New("Frame", {
            BackgroundColor3 = T.Surface,
            Size    = UDim2.new(1, 0, 0, 75),
            ZIndex  = 101,
            LayoutOrder = NotifCount,
            Parent  = NotifContainer,
        })
        Util.Corner(nf, T.RadiusMd)
        Util.Stroke(nf, barColor, 1, 0.6)

        local bar = Util.New("Frame", {
            BackgroundColor3 = barColor,
            Size     = UDim2.new(0, 4, 0.65, 0),
            Position = UDim2.new(0, 8, 0.175, 0),
            BorderSizePixel = 0,
            ZIndex   = 102,
            Parent   = nf,
        })
        Util.Corner(bar, UDim.new(1, 0))

        Util.New("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -30, 0, 20),
            Position = UDim2.new(0, 22, 0, 10),
            Font     = T.FontBold,
            Text     = opts.Title   or "Notification",
            TextColor3 = T.TxtHigh,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex   = 102,
            Parent   = nf,
        })
        Util.New("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -30, 0, 34),
            Position = UDim2.new(0, 22, 0, 32),
            Font     = T.FontMed,
            Text     = opts.Content or "",
            TextColor3 = T.TxtMid,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex   = 102,
            Parent   = nf,
        })

        nf.Position = UDim2.new(1, 50, 0, 0)
        nf.BackgroundTransparency = 0.5
        Util.Tween(nf, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, 0.35)

        task.delay(opts.Duration or 4, function()
            Util.Tween(nf, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}, 0.35)
            task.delay(0.4, function()
                if nf and nf.Parent then nf:Destroy() end
            end)
        end)
    end

    -- ============================================================
    --  WATERMARK & OVERLAY
    -- ============================================================

    local Watermark = Util.New("Frame", {
        Name = "Watermark",
        BackgroundColor3 = T.BGAlt,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(0, 300, 0, 32),
        Position = UDim2.new(0, 20, 0, 20),
        ZIndex = 100,
        Parent = Gui
    })
    Util.Corner(Watermark, T.RadiusSm)
    Util.Stroke(Watermark, T.Accent, 1, 0.4)
    Util.Shadow(Watermark)
    Util.MakeDraggable(Watermark, Watermark)

    local WMText = Util.New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Font = T.FontMed,
        Text = WCfg.Title .. " | FPS: 60 | Ping: 0ms | 00:00:00",
        TextColor3 = T.TxtHigh,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101,
        Parent = Watermark
    })

    local RunService = game:GetService("RunService")
    local lastTick = tick()
    local frames = 0
    local currentFPS = 60
    
    local rsConn = RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - lastTick >= 1 then
            currentFPS = frames
            frames = 0
            lastTick = tick()
            
            local ping = 0
            pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            
            local timeStr = os.date("%X")
            WMText.Text = WCfg.Title .. " | FPS: " .. tostring(currentFPS) .. " | Ping: " .. tostring(ping) .. "ms | " .. timeStr
            
            -- Auto scale width
            local bounds = Util.GetTextBounds(WMText.Text, T.FontMed, 13, Vector2.new(1000, 32))
            Util.Tween(Watermark, {Size = UDim2.new(0, bounds.X + 26, 0, 32)}, 0.2)
        end
    end)

    -- ============================================================
    --  WINDOW API
    -- ============================================================

    local Window = {}
    Window.Notify = Notify

    -- ============================================================
    --  TAB BUILDER
    -- ============================================================

    function Window:CreateTab(tabCfg)
        tabCfg = tabCfg or {}
        local tabName  = tabCfg.Name  or "Tab"
        local tabIcon  = tabCfg.Icon  or ""
        local tabOrder = tabCfg.Order or (#State.Tabs + 1)

        -- Sidebar button
        local TabBtn = Util.New("TextButton", {
            BackgroundColor3       = T.Surface,
            BackgroundTransparency = 1,
            Size        = UDim2.new(1, -4, 0, 42),
            Font        = T.FontMed,
            Text        = "",
            AutoButtonColor = false,
            LayoutOrder = tabOrder,
            ZIndex      = 3,
            Parent      = SideScroll,
        })
        Util.Corner(TabBtn, T.RadiusSm)

        local TabIconLbl = Util.New("TextLabel", {
            BackgroundTransparency = 1,
            Size        = UDim2.new(0, 34, 1, 0),
            Position    = UDim2.new(0, 8, 0, 0),
            Font        = T.FontMed,
            Text        = tabIcon,
            TextColor3  = T.TxtLow,
            TextSize    = 16,
            ZIndex      = 4,
            Parent      = TabBtn,
        })

        local TabLbl = Util.New("TextLabel", {
            BackgroundTransparency = 1,
            Size        = UDim2.new(1, -50, 1, 0),
            Position    = UDim2.new(0, 42, 0, 0),
            Font        = T.FontMed,
            Text        = tabName,
            TextColor3  = T.TxtMid,
            TextSize    = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex      = 4,
            Parent      = TabBtn,
        })

        local TabIndicator = Util.New("Frame", {
            BackgroundColor3 = T.Accent,
            Size        = UDim2.new(0, 4, 0, 0),
            Position    = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BorderSizePixel = 0,
            ZIndex      = 4,
            Parent      = TabBtn,
        })
        Util.Corner(TabIndicator, UDim.new(1, 0))

        -- Content page
        local Page = Util.New("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size        = UDim2.new(1, -16, 1, -16),
            Position    = UDim2.new(0, 8, 0, 8),
            CanvasSize  = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness  = 3,
            ScrollBarImageColor3 = T.Scrollbar,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex  = 2,
            Parent  = Content,
        })
        Util.ListLayout(Page, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, UDim.new(0, 8))
        Util.Padding(Page, 6, 6, 6, 6)

        local td = {
            Btn = TabBtn, Page = Page,
            Ind = TabIndicator, IconLbl = TabIconLbl, Lbl = TabLbl,
        }
        table.insert(State.Tabs, td)

        local function Select()
            for _, t in ipairs(State.Tabs) do
                t.Page.Visible = false
                Util.Tween(t.Btn,     {BackgroundTransparency = 1},       0.2)
                Util.Tween(t.Ind,     {Size = UDim2.new(0, 4, 0, 0)},    0.2)
                Util.Tween(t.Lbl,     {TextColor3 = T.TxtMid},            0.2)
                Util.Tween(t.IconLbl, {TextColor3 = T.TxtLow},            0.2)
            end
            td.Page.Visible = true
            State.ActiveTab = td
            Util.Tween(td.Btn,     {BackgroundTransparency = 0.5},    0.2)
            Util.Tween(td.Ind,     {Size = UDim2.new(0, 4, 0, 24)},  0.25, Enum.EasingStyle.Back)
            Util.Tween(td.Lbl,     {TextColor3 = T.TxtHigh},          0.2)
            Util.Tween(td.IconLbl, {TextColor3 = T.Accent},           0.2)
        end

        TabBtn.MouseEnter:Connect(function()
            if State.ActiveTab ~= td then
                Util.Tween(TabBtn, {BackgroundTransparency = 0.75}, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if State.ActiveTab ~= td then
                Util.Tween(TabBtn, {BackgroundTransparency = 1}, 0.15)
            end
        end)
        TabBtn.MouseButton1Click:Connect(Select)

        if #State.Tabs == 1 then Select() end

        -- ============================================================
        --  TAB ELEMENTS API
        -- ============================================================

        local Tab = {}

        -- ---- SUB-TAB SYSTEM (V2 NR) ----
        local SubTabBar = nil
        local SubTabs = {}

        function Tab:CreateSubTab(opts)
            opts = opts or {}
            local subName = opts.Name or "SubTab"

            if not SubTabBar then
                SubTabBar = Util.New("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.X,
                    ScrollBarThickness = 0,
                    LayoutOrder = -999,
                    Parent = Page
                })
                Util.ListLayout(SubTabBar, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center, UDim.new(0, 6))
            end

            local SubBtn = Util.New("TextButton", {
                BackgroundColor3 = T.Surface,
                Size = UDim2.new(0, 100, 1, -4),
                Font = T.FontMed,
                Text = subName,
                TextColor3 = T.TxtMid,
                TextSize = 13,
                AutoButtonColor = false,
                Parent = SubTabBar
            })
            Util.Corner(SubBtn, T.RadiusSm)

            local SubPage = Util.New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Visible = false,
                LayoutOrder = #SubTabs + 1,
                Parent = Page
            })
            Util.ListLayout(SubPage, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, UDim.new(0, 8))

            local subData = { Btn = SubBtn, Page = SubPage }
            table.insert(SubTabs, subData)

            local function SelectSubTab()
                for _, s in ipairs(SubTabs) do
                    s.Page.Visible = false
                    Util.Tween(s.Btn, {BackgroundColor3 = T.Surface, TextColor3 = T.TxtMid}, 0.2)
                end
                SubPage.Visible = true
                Util.Tween(SubBtn, {BackgroundColor3 = T.Accent, TextColor3 = Color3.new(1,1,1)}, 0.2)
            end
            SubBtn.MouseButton1Click:Connect(SelectSubTab)
            if #SubTabs == 1 then SelectSubTab() end

            local SubTabAPI = setmetatable({}, {
                __index = function(_, key)
                    if Tab[key] then
                        return function(_, ...)
                            local oldPage = Page
                            Page = SubPage
                            local res = Tab[key](Tab, ...)
                            Page = oldPage
                            return res
                        end
                    end
                end
            })
            return SubTabAPI
        end

        -- ---- SECTION ----
        function Tab:CreateSection(name)
            local sf = Util.New("Frame", {
                BackgroundTransparency = 1,
                Size        = UDim2.new(1, 0, 0, 30),
                LayoutOrder = #Page:GetChildren(),
                ZIndex      = 3,
                Parent      = Page,
            })

            Util.New("Frame", {
                BackgroundColor3 = T.Divider,
                Size     = UDim2.new(0, 24, 0, 1),
                Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BorderSizePixel = 0,
                ZIndex   = 3,
                Parent   = sf,
            })

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.65, -5, 1, 0),
                Position = UDim2.new(0, 32, 0, 0),
                Font     = T.FontBold,
                Text     = string.upper(name or "SECTION"),
                TextColor3 = T.TxtLow,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 3,
                Parent   = sf,
            })

            Util.New("Frame", {
                BackgroundColor3 = T.Divider,
                Size     = UDim2.new(0.42, 0, 0, 1),
                Position = UDim2.new(0.58, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BorderSizePixel = 0,
                ZIndex   = 3,
                Parent   = sf,
            })
        end

        -- ---- IMAGE (NEW for V2 NR) ----
        function Tab:CreateImage(opts)
            local imgF = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size = UDim2.new(1, -4, 0, 180),
                LayoutOrder = #Page:GetChildren(),
                Parent = Page
            })
            Util.Corner(imgF, T.RadiusMd)
            Util.Stroke(imgF, T.Border, 1, 0.3)
            
            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 14, 0, 5),
                Font = T.FontMed,
                Text = opts.Name or "Image",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = imgF
            })

            local iL = Util.New("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -28, 1, -45),
                Position = UDim2.new(0.5, 0, 1, -10),
                AnchorPoint = Vector2.new(0.5, 1),
                Image = opts.Image or "",
                ScaleType = Enum.ScaleType.Fit,
                Parent = imgF
            })
            Util.Corner(iL, T.RadiusSm)
        end

        -- ---- IMAGE BUTTON (NEW for V2 NR) ----
        function Tab:CreateImageButton(opts)
            local imgF = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size = UDim2.new(1, -4, 0, 180),
                LayoutOrder = #Page:GetChildren(),
                Parent = Page
            })
            Util.Corner(imgF, T.RadiusMd)
            Util.Stroke(imgF, T.Border, 1, 0.3)
            
            local title = Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 14, 0, 5),
                Font = T.FontMed,
                Text = opts.Name or "Image Button",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = imgF
            })

            local btn = Util.New("ImageButton", {
                BackgroundColor3 = T.SurfaceAct,
                Size = UDim2.new(1, -28, 1, -45),
                Position = UDim2.new(0.5, 0, 1, -10),
                AnchorPoint = Vector2.new(0.5, 1),
                Image = opts.Image or "",
                ScaleType = Enum.ScaleType.Crop,
                AutoButtonColor = false,
                Parent = imgF
            })
            Util.Corner(btn, T.RadiusSm)

            btn.MouseEnter:Connect(function()
                Util.Tween(btn, {ImageColor3 = Color3.fromRGB(200, 200, 200)}, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                Util.Tween(btn, {ImageColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
            end)
            btn.MouseButton1Click:Connect(function()
                Util.Ripple(btn)
                if opts.Callback then opts.Callback() end
            end)
        end

        -- ---- TOGGLE ----
        function Tab:CreateToggle(opts)
            opts = opts or {}
            local val = opts.Default or false

            local row = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 46),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)
            Util.HoverBind(row, T.Surface, T.SurfaceHov)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.65, -14, 0, 20),
                Position = UDim2.new(0, 16, 0, opts.Description and 5 or 13),
                Font     = T.FontMed,
                Text     = opts.Name or "Toggle",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            if opts.Description then
                Util.New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(0.65, -14, 0, 14),
                    Position = UDim2.new(0, 16, 0, 26),
                    Font     = T.FontMed,
                    Text     = opts.Description,
                    TextColor3 = T.TxtLow,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex   = 4,
                    Parent   = row,
                })
            end

            local track = Util.New("Frame", {
                BackgroundColor3 = val and T.Accent or T.SurfaceAct,
                Size     = UDim2.new(0, 48, 0, 26),
                Position = UDim2.new(1, -64, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ZIndex   = 4,
                Parent   = row,
            })
            Util.Corner(track, UDim.new(1, 0))
            Util.Stroke(track, T.Border, 1)

            local knob = Util.New("Frame", {
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size     = UDim2.new(0, 20, 0, 20),
                Position = val and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ZIndex   = 5,
                Parent   = track,
            })
            Util.Corner(knob, UDim.new(1, 0))
            Util.Shadow(knob)

            local function Refresh()
                if val then
                    Util.Tween(track, {BackgroundColor3 = T.Accent}, 0.25)
                    Util.Tween(knob,  {Position = UDim2.new(1, -23, 0.5, 0)}, 0.25, Enum.EasingStyle.Back)
                else
                    Util.Tween(track, {BackgroundColor3 = T.SurfaceAct}, 0.25)
                    Util.Tween(knob,  {Position = UDim2.new(0, 3, 0.5, 0)}, 0.25, Enum.EasingStyle.Back)
                end
                if opts.Callback then opts.Callback(val) end
            end

            local clickZone = Util.New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "", ZIndex = 5, Parent = row,
            })
            clickZone.MouseButton1Click:Connect(function()
                val = not val
                Refresh()
            end)

            local API = {}
            function API:Set(v) val = v; Refresh() end
            function API:Get() return val end
            return API
        end

        -- ---- SLIDER (With Text Input) ----
        function Tab:CreateSlider(opts)
            opts = opts or {}
            local min  = opts.Min      or 0
            local max  = opts.Max      or 100
            local cur  = opts.Default  or min
            local step = opts.Increment or 1

            local row = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 56),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)
            Util.HoverBind(row, T.Surface, T.SurfaceHov)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.65, -14, 0, 20),
                Position = UDim2.new(0, 16, 0, 6),
                Font     = T.FontMed,
                Text     = opts.Name or "Slider",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            local ValInput = Util.New("TextBox", {
                BackgroundColor3 = T.SurfaceAct,
                Size     = UDim2.new(0, 60, 0, 22),
                Position = UDim2.new(1, -76, 0, 5),
                Font     = T.FontMono,
                Text     = tostring(cur),
                TextColor3 = T.Accent,
                TextSize = 12,
                ZIndex   = 5,
                Parent   = row,
            })
            Util.Corner(ValInput, T.RadiusXs)
            Util.Stroke(ValInput, T.Border, 1)

            local track = Util.New("Frame", {
                BackgroundColor3 = T.SurfaceAct,
                Size     = UDim2.new(1, -32, 0, 6),
                Position = UDim2.new(0, 16, 0, 40),
                ZIndex   = 4,
                Parent   = row,
            })
            Util.Corner(track, UDim.new(1, 0))

            local pct0 = (cur - min) / (max - min)

            local fill = Util.New("Frame", {
                BackgroundColor3 = T.Accent,
                Size     = UDim2.new(pct0, 0, 1, 0),
                ZIndex   = 5,
                Parent   = track,
            })
            Util.Corner(fill, UDim.new(1, 0))

            local knob = Util.New("Frame", {
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size     = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(pct0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ZIndex   = 6,
                Parent   = track,
            })
            Util.Corner(knob, UDim.new(1, 0))
            Util.Stroke(knob, T.Accent, 2)
            Util.Shadow(knob)

            local dragging = false

            local function UpdateVisuals()
                local pct = (cur - min) / (max - min)
                fill.Size     = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, 0, 0.5, 0)
                ValInput.Text   = tostring(cur)
                if opts.Callback then opts.Callback(cur) end
            end

            local function ApplyX(px)
                local abs  = track.AbsolutePosition.X
                local sz   = track.AbsoluteSize.X
                local rel  = math.clamp((px - abs) / sz, 0, 1)
                local raw  = min + (max - min) * rel
                cur = math.clamp(math.floor(raw / step + 0.5) * step, min, max)
                UpdateVisuals()
            end

            track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    ApplyX(inp.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    ApplyX(inp.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            ValInput.FocusLost:Connect(function()
                local num = tonumber(ValInput.Text)
                if num then
                    cur = math.clamp(math.floor(num / step + 0.5) * step, min, max)
                end
                UpdateVisuals()
            end)

            local API = {}
            function API:Set(v)
                cur = math.clamp(v, min, max)
                UpdateVisuals()
            end
            function API:Get() return cur end
            return API
        end

        -- ---- RANGE SLIDER ----
        function Tab:CreateRangeSlider(opts)
            opts = opts or {}
            local min  = opts.Min      or 0
            local max  = opts.Max      or 100
            local step = opts.Increment or 1
            local curMin = opts.DefaultMin or min
            local curMax = opts.DefaultMax or max

            local row = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 56),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)
            Util.HoverBind(row, T.Surface, T.SurfaceHov)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.4, -14, 0, 20),
                Position = UDim2.new(0, 16, 0, 6),
                Font     = T.FontMed,
                Text     = opts.Name or "Range",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            local ValDisplay = Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.5, 0, 0, 20),
                Position = UDim2.new(0.5, -16, 0, 6),
                Font     = T.FontMono,
                Text     = tostring(curMin) .. " - " .. tostring(curMax),
                TextColor3 = T.Accent,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex   = 4,
                Parent   = row,
            })

            local track = Util.New("Frame", {
                BackgroundColor3 = T.SurfaceAct,
                Size     = UDim2.new(1, -32, 0, 6),
                Position = UDim2.new(0, 16, 0, 40),
                ZIndex   = 4,
                Parent   = row,
            })
            Util.Corner(track, UDim.new(1, 0))

            local fill = Util.New("Frame", {
                BackgroundColor3 = T.Accent,
                Size     = UDim2.new(0, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                ZIndex   = 5,
                Parent   = track,
            })
            Util.Corner(fill, UDim.new(1, 0))

            local knobMin = Util.New("Frame", {
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size     = UDim2.new(0, 16, 0, 16),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ZIndex   = 6,
                Parent   = track,
            })
            Util.Corner(knobMin, UDim.new(1, 0))
            Util.Stroke(knobMin, T.Accent, 2)
            Util.Shadow(knobMin)

            local knobMax = Util.New("Frame", {
                BackgroundColor3 = Color3.new(1, 1, 1),
                Size     = UDim2.new(0, 16, 0, 16),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ZIndex   = 6,
                Parent   = track,
            })
            Util.Corner(knobMax, UDim.new(1, 0))
            Util.Stroke(knobMax, T.Accent, 2)
            Util.Shadow(knobMax)

            local dragMin, dragMax = false, false

            local function UpdateVisuals()
                local pctMin = (curMin - min) / (max - min)
                local pctMax = (curMax - min) / (max - min)
                
                knobMin.Position = UDim2.new(pctMin, 0, 0.5, 0)
                knobMax.Position = UDim2.new(pctMax, 0, 0.5, 0)
                
                fill.Position = UDim2.new(pctMin, 0, 0, 0)
                fill.Size = UDim2.new(pctMax - pctMin, 0, 1, 0)
                
                ValDisplay.Text = tostring(curMin) .. " - " .. tostring(curMax)
                
                if opts.Callback then opts.Callback(curMin, curMax) end
            end
            UpdateVisuals()

            local function ApplyX(px, isMin)
                local abs = track.AbsolutePosition.X
                local sz = track.AbsoluteSize.X
                local rel = math.clamp((px - abs) / sz, 0, 1)
                local raw = min + (max - min) * rel
                local val = math.clamp(math.floor(raw / step + 0.5) * step, min, max)

                if isMin then
                    curMin = math.min(val, curMax)
                else
                    curMax = math.max(val, curMin)
                end
                UpdateVisuals()
            end

            knobMin.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragMin = true
                end
            end)
            knobMax.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragMax = true
                end
            end)

            UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    if dragMin then ApplyX(inp.Position.X, true) end
                    if dragMax then ApplyX(inp.Position.X, false) end
                end
            end)

            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragMin = false
                    dragMax = false
                end
            end)

            local API = {}
            function API:Set(mn, mx)
                curMin = math.clamp(mn, min, max)
                curMax = math.clamp(mx, min, max)
                if curMin > curMax then curMin, curMax = curMax, curMin end
                UpdateVisuals()
            end
            function API:Get() return curMin, curMax end
            return API
        end

        -- ---- PLAYER CARD ----
        function Tab:CreatePlayerCard(opts)
            opts = opts or {}
            
            local row = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 70),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)
            Util.Stroke(row, T.Border, 1, 0.4)
            Util.HoverBind(row, T.Surface, T.SurfaceHov)

            local UserId = opts.UserId or 1
            local Username = opts.Username or "Roblox"
            local DisplayName = opts.DisplayName or "Roblox"

            local avatar = Util.New("ImageLabel", {
                BackgroundColor3 = T.SurfaceAct,
                Size = UDim2.new(0, 50, 0, 50),
                Position = UDim2.new(0, 10, 0, 10),
                Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(UserId) .. "&w=150&h=150",
                ZIndex = 4,
                Parent = row
            })
            Util.Corner(avatar, UDim.new(1, 0))
            Util.Stroke(avatar, T.Border, 1)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.5, 0, 0, 20),
                Position = UDim2.new(0, 72, 0, 14),
                Font     = T.FontBold,
                Text     = DisplayName,
                TextColor3 = T.TxtHigh,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.5, 0, 0, 16),
                Position = UDim2.new(0, 72, 0, 36),
                Font     = T.FontMed,
                Text     = "@" .. Username,
                TextColor3 = T.TxtLow,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            if opts.Callback then
                local btn = Util.New("TextButton", {
                    BackgroundColor3 = T.Accent,
                    Size = UDim2.new(0, 80, 0, 30),
                    Position = UDim2.new(1, -90, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Font = T.FontBold,
                    Text = opts.ButtonText or "Action",
                    TextColor3 = Color3.new(1,1,1),
                    TextSize = 13,
                    AutoButtonColor = false,
                    ZIndex = 5,
                    Parent = row
                })
                Util.Corner(btn, T.RadiusSm)
                
                btn.MouseEnter:Connect(function() Util.Tween(btn, {BackgroundColor3 = T.AccentHov}, 0.15) end)
                btn.MouseLeave:Connect(function() Util.Tween(btn, {BackgroundColor3 = T.Accent}, 0.15) end)
                btn.MouseButton1Click:Connect(function()
                    Util.Ripple(btn)
                    opts.Callback(UserId)
                end)
            end
        end

        -- ---- BUTTON ----
        function Tab:CreateButton(opts)
            opts = opts or {}

            local row = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 42),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)
            Util.HoverBind(row, T.Surface, T.SurfaceHov)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.65, -14, 1, 0),
                Position = UDim2.new(0, 16, 0, 0),
                Font     = T.FontMed,
                Text     = opts.Name or "Button",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            local btn = Util.New("TextButton", {
                BackgroundColor3 = T.Accent,
                Size     = UDim2.new(0, 76, 0, 30),
                Position = UDim2.new(1, -92, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Font     = T.FontBold,
                Text     = opts.ButtonText or "Run",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 13,
                AutoButtonColor = false,
                ZIndex   = 5,
                Parent   = row,
            })
            Util.Corner(btn, T.RadiusSm)

            btn.MouseEnter:Connect(function() Util.Tween(btn, {BackgroundColor3 = T.AccentHov}, 0.15) end)
            btn.MouseLeave:Connect(function() Util.Tween(btn, {BackgroundColor3 = T.Accent},    0.15) end)
            btn.MouseButton1Click:Connect(function()
                Util.Ripple(btn)
                if opts.Callback then opts.Callback() end
            end)
        end

        -- ---- DROPDOWN (Scrollable) ----
        function Tab:CreateDropdown(opts)
            opts = opts or {}
            local items   = opts.Items   or {}
            local current = opts.Default or (items[1] or "")
            local open    = false

            local wrap = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 44),
                ClipsDescendants = true,
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(wrap, T.RadiusSm)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.45, -8, 0, 44),
                Position = UDim2.new(0, 16, 0, 0),
                Font     = T.FontMed,
                Text     = opts.Name or "Dropdown",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = wrap,
            })

            local selBtn = Util.New("TextButton", {
                BackgroundColor3 = T.SurfaceAct,
                Size     = UDim2.new(0.5, -16, 0, 30),
                Position = UDim2.new(0.5, 0, 0, 7),
                Font     = T.FontMed,
                Text     = current .. "  v",
                TextColor3 = T.TxtMid,
                TextSize = 13,
                AutoButtonColor = false,
                ZIndex   = 5,
                Parent   = wrap,
            })
            Util.Corner(selBtn, T.RadiusXs)
            Util.Stroke(selBtn, T.Border, 1)

            local itemScroll = Util.New("ScrollingFrame", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 46),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = T.Scrollbar,
                BorderSizePixel = 0,
                ZIndex   = 5,
                Parent   = wrap,
            })
            Util.ListLayout(itemScroll, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, UDim.new(0, 4))
            Util.Padding(itemScroll, 0, 4, 4, 0)

            local function BuildItems()
                for _, c in ipairs(itemScroll:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for i, item in ipairs(items) do
                    local ib = Util.New("TextButton", {
                        BackgroundColor3 = T.SurfaceHov,
                        BackgroundTransparency = 0.5,
                        Size     = UDim2.new(1, 0, 0, 30),
                        Font     = T.FontMed,
                        Text     = item,
                        TextColor3 = item == current and T.Accent or T.TxtMid,
                        TextSize = 13,
                        AutoButtonColor = false,
                        LayoutOrder = i,
                        ZIndex   = 6,
                        Parent   = itemScroll,
                    })
                    Util.Corner(ib, T.RadiusXs)
                    ib.MouseEnter:Connect(function() Util.Tween(ib, {BackgroundTransparency = 0, TextColor3 = T.TxtHigh}, 0.15) end)
                    ib.MouseLeave:Connect(function() Util.Tween(ib, {BackgroundTransparency = 0.5, TextColor3 = item == current and T.Accent or T.TxtMid}, 0.15) end)
                    ib.MouseButton1Click:Connect(function()
                        current = item
                        selBtn.Text = item .. "  v"
                        open = false
                        Util.Tween(wrap, {Size = UDim2.new(1, 0, 0, 44)}, 0.25)
                        BuildItems()
                        if opts.Callback then opts.Callback(item) end
                    end)
                end
            end
            BuildItems()

            selBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    local listHeight = math.min(#items * 34, 140)
                    Util.Tween(itemScroll, {Size = UDim2.new(1, -16, 0, listHeight)}, 0.25)
                    Util.Tween(wrap, {Size = UDim2.new(1, 0, 0, 46 + listHeight)}, 0.3, Enum.EasingStyle.Back)
                    selBtn.Text = current .. "  ^"
                else
                    Util.Tween(wrap, {Size = UDim2.new(1, 0, 0, 44)}, 0.25)
                    selBtn.Text = current .. "  v"
                end
            end)

            local API = {}
            function API:Set(v) current = v; selBtn.Text = v .. "  v"; BuildItems() end
            function API:Refresh(list, def)
                items = list
                if def then current = def; selBtn.Text = def .. "  v" end
                BuildItems()
            end
            function API:Get() return current end
            return API
        end

        -- ---- MULTI-DROPDOWN ----
        function Tab:CreateMultiDropdown(opts)
            opts = opts or {}
            local items   = opts.Items   or {}
            local current = opts.Default or {}
            local open    = false

            if type(current) ~= "table" then current = {current} end
            
            local function IsSelected(item)
                for _, v in ipairs(current) do
                    if v == item then return true end
                end
                return false
            end

            local wrap = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 44),
                ClipsDescendants = true,
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(wrap, T.RadiusSm)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.45, -8, 0, 44),
                Position = UDim2.new(0, 16, 0, 0),
                Font     = T.FontMed,
                Text     = opts.Name or "Multi Dropdown",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = wrap,
            })

            local function GetPreviewText()
                if #current == 0 then return "None  v" end
                if #current == 1 then return current[1] .. "  v" end
                return #current .. " Selected  v"
            end

            local selBtn = Util.New("TextButton", {
                BackgroundColor3 = T.SurfaceAct,
                Size     = UDim2.new(0.5, -16, 0, 30),
                Position = UDim2.new(0.5, 0, 0, 7),
                Font     = T.FontMed,
                Text     = GetPreviewText(),
                TextColor3 = T.TxtMid,
                TextSize = 13,
                AutoButtonColor = false,
                ZIndex   = 5,
                Parent   = wrap,
            })
            Util.Corner(selBtn, T.RadiusXs)
            Util.Stroke(selBtn, T.Border, 1)

            local itemScroll = Util.New("ScrollingFrame", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 46),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = T.Scrollbar,
                BorderSizePixel = 0,
                ZIndex   = 5,
                Parent   = wrap,
            })
            Util.ListLayout(itemScroll, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, UDim.new(0, 4))
            Util.Padding(itemScroll, 0, 4, 4, 0)

            local function BuildItems()
                for _, c in ipairs(itemScroll:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for i, item in ipairs(items) do
                    local selected = IsSelected(item)
                    local ib = Util.New("TextButton", {
                        BackgroundColor3 = T.SurfaceHov,
                        BackgroundTransparency = 0.5,
                        Size     = UDim2.new(1, 0, 0, 30),
                        Font     = T.FontMed,
                        Text     = item,
                        TextColor3 = selected and T.Accent or T.TxtMid,
                        TextSize = 13,
                        AutoButtonColor = false,
                        LayoutOrder = i,
                        ZIndex   = 6,
                        Parent   = itemScroll,
                    })
                    Util.Corner(ib, T.RadiusXs)
                    
                    local check = Util.New("Frame", {
                        BackgroundColor3 = selected and T.Accent or T.SurfaceAct,
                        Size = UDim2.new(0, 16, 0, 16),
                        Position = UDim2.new(1, -24, 0.5, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        ZIndex = 7,
                        Parent = ib,
                    })
                    Util.Corner(check, T.RadiusXs)

                    ib.MouseEnter:Connect(function() Util.Tween(ib, {BackgroundTransparency = 0, TextColor3 = T.TxtHigh}, 0.15) end)
                    ib.MouseLeave:Connect(function() Util.Tween(ib, {BackgroundTransparency = 0.5, TextColor3 = selected and T.Accent or T.TxtMid}, 0.15) end)
                    
                    ib.MouseButton1Click:Connect(function()
                        if IsSelected(item) then
                            for idx, v in ipairs(current) do
                                if v == item then table.remove(current, idx); break end
                            end
                        else
                            table.insert(current, item)
                        end
                        selBtn.Text = string.gsub(GetPreviewText(), "v", open and "^" or "v")
                        BuildItems()
                        if opts.Callback then opts.Callback(current) end
                    end)
                end
            end
            BuildItems()

            selBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    local listHeight = math.min(#items * 34, 140)
                    Util.Tween(itemScroll, {Size = UDim2.new(1, -16, 0, listHeight)}, 0.25)
                    Util.Tween(wrap, {Size = UDim2.new(1, 0, 0, 46 + listHeight)}, 0.3, Enum.EasingStyle.Back)
                    selBtn.Text = string.gsub(selBtn.Text, "v", "^")
                else
                    Util.Tween(wrap, {Size = UDim2.new(1, 0, 0, 44)}, 0.25)
                    selBtn.Text = string.gsub(selBtn.Text, "%^", "v")
                end
            end)

            local API = {}
            function API:Set(v) current = type(v) == "table" and v or {v}; selBtn.Text = GetPreviewText(); BuildItems() end
            function API:Refresh(list, def)
                items = list
                if def then current = type(def) == "table" and def or {def}; selBtn.Text = GetPreviewText() end
                BuildItems()
            end
            function API:Get() return current end
            return API
        end

        -- ---- INPUT ----
        function Tab:CreateInput(opts)
            opts = opts or {}

            local row = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 44),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)
            Util.HoverBind(row, T.Surface, T.SurfaceHov)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.4, -8, 1, 0),
                Position = UDim2.new(0, 16, 0, 0),
                Font     = T.FontMed,
                Text     = opts.Name or "Input",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            local box = Util.New("TextBox", {
                BackgroundColor3 = T.SurfaceAct,
                Size     = UDim2.new(0.55, -16, 0, 30),
                Position = UDim2.new(0.45, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Font     = T.FontMed,
                PlaceholderText  = opts.Placeholder or "Type here...",
                PlaceholderColor3 = T.TxtLow,
                Text     = opts.Default or "",
                TextColor3 = T.TxtHigh,
                TextSize = 13,
                ClearTextOnFocus = opts.ClearOnFocus or false,
                ZIndex   = 5,
                Parent   = row,
            })
            Util.Corner(box, T.RadiusXs)
            Util.Padding(box, 0, 8, 0, 8)
            local bstroke = Util.Stroke(box, T.Border, 1, 0.5)

            box.Focused:Connect(function()
                Util.Tween(bstroke, {Color = T.Accent, Transparency = 0}, 0.2)
            end)
            box.FocusLost:Connect(function(enter)
                Util.Tween(bstroke, {Color = T.Border, Transparency = 0.5}, 0.2)
                if opts.Callback then opts.Callback(box.Text, enter) end
            end)

            local API = {}
            function API:Set(v) box.Text = v end
            function API:Get() return box.Text end
            return API
        end

        -- ---- KEYBIND ----
        function Tab:CreateKeybind(opts)
            opts = opts or {}
            local key      = opts.Default or Enum.KeyCode.E
            local listening = false

            local row = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 44),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)
            Util.HoverBind(row, T.Surface, T.SurfaceHov)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.65, -14, 1, 0),
                Position = UDim2.new(0, 16, 0, 0),
                Font     = T.FontMed,
                Text     = opts.Name or "Keybind",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            local kbtn = Util.New("TextButton", {
                BackgroundColor3 = T.SurfaceAct,
                Size     = UDim2.new(0, 80, 0, 30),
                Position = UDim2.new(1, -96, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Font     = T.FontMono,
                Text     = key.Name,
                TextColor3 = T.Accent,
                TextSize = 13,
                AutoButtonColor = false,
                ZIndex   = 5,
                Parent   = row,
            })
            Util.Corner(kbtn, T.RadiusXs)
            Util.Stroke(kbtn, T.Border, 1, 0.5)

            kbtn.MouseButton1Click:Connect(function()
                listening = true
                kbtn.Text = "..."
                Util.Tween(kbtn, {BackgroundColor3 = T.Accent}, 0.15)
                kbtn.TextColor3 = Color3.new(1, 1, 1)
            end)

            UserInputService.InputBegan:Connect(function(inp, gpe)
                if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    key = inp.KeyCode
                    kbtn.Text = key.Name
                    Util.Tween(kbtn, {BackgroundColor3 = T.SurfaceAct}, 0.15)
                    kbtn.TextColor3 = T.Accent
                    if opts.Callback then opts.Callback(key) end
                end
            end)

            local API = {}
            function API:Set(k) key = k; kbtn.Text = k.Name end
            function API:Get() return key end
            return API
        end

        -- ---- LABEL ----
        function Tab:CreateLabel(opts)
            opts = opts or {}

            local row = Util.New("Frame", {
                BackgroundColor3       = T.Surface,
                BackgroundTransparency = 0.35,
                Size     = UDim2.new(1, 0, 0, 34),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)

            local dot = Util.New("Frame", {
                BackgroundColor3 = T.Accent,
                Size     = UDim2.new(0, 6, 0, 6),
                Position = UDim2.new(0, 14, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ZIndex   = 4,
                Parent   = row,
            })
            Util.Corner(dot, UDim.new(1, 0))

            local lbl = Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -34, 1, 0),
                Position = UDim2.new(0, 28, 0, 0),
                Font     = T.FontMed,
                Text     = opts.Text or "Label",
                TextColor3 = T.TxtMid,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            local API = {}
            function API:Set(v) lbl.Text = v end
            function API:Get() return lbl.Text end
            return API
        end

        -- ---- PARAGRAPH ----
        function Tab:CreateParagraph(opts)
            opts = opts or {}
            local text = opts.Text or "Paragraph text"
            local title = opts.Title or "Information"

            local row = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 60),
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(row, T.RadiusSm)
            Util.Stroke(row, T.Border, 1, 0.5)

            local titleLbl = Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -24, 0, 20),
                Position = UDim2.new(0, 12, 0, 8),
                Font     = T.FontBold,
                Text     = title,
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 4,
                Parent   = row,
            })

            local textLbl = Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -24, 0, 0),
                Position = UDim2.new(0, 12, 0, 30),
                Font     = T.FontMed,
                Text     = text,
                TextColor3 = T.TxtMid,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                ZIndex   = 4,
                Parent   = row,
            })

            local function AdjustSize()
                local bounds = Util.GetTextBounds(textLbl.Text, T.FontMed, 13, Vector2.new(Page.AbsoluteSize.X - 40, 10000))
                textLbl.Size = UDim2.new(1, -24, 0, bounds.Y)
                row.Size = UDim2.new(1, 0, 0, bounds.Y + 42)
            end
            task.delay(0.1, AdjustSize)

            local API = {}
            function API:Set(newProps) 
                if newProps.Title then titleLbl.Text = newProps.Title end
                if newProps.Text then textLbl.Text = newProps.Text end
                AdjustSize()
            end
            return API
        end

        -- ---- COLOR PICKER ----
        function Tab:CreateColorPicker(opts)
            opts = opts or {}
            local color = opts.Default or Color3.new(1, 1, 1)
            local h, s, v = Color3.toHSV(color)

            local wrap = Util.New("Frame", {
                BackgroundColor3 = T.Surface,
                Size     = UDim2.new(1, 0, 0, 44),
                ClipsDescendants = true,
                LayoutOrder = #Page:GetChildren(),
                ZIndex   = 3,
                Parent   = Page,
            })
            Util.Corner(wrap, T.RadiusSm)

            local row = Util.New("TextButton", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, 0, 0, 44),
                Text     = "",
                AutoButtonColor = false,
                ZIndex   = 4,
                Parent   = wrap,
            })
            Util.HoverBind(wrap, T.Surface, T.SurfaceHov)

            Util.New("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0.65, -14, 1, 0),
                Position = UDim2.new(0, 16, 0, 0),
                Font     = T.FontMed,
                Text     = opts.Name or "Color",
                TextColor3 = T.TxtHigh,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 5,
                Parent   = row,
            })

            local swatch = Util.New("Frame", {
                BackgroundColor3 = color,
                Size     = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(1, -48, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                ZIndex   = 6,
                Parent   = row,
            })
            Util.Corner(swatch, UDim.new(0, 6))
            Util.Stroke(swatch, T.Border, 1)

            local PickerArea = Util.New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 130),
                Position = UDim2.new(0, 0, 0, 44),
                ZIndex = 4,
                Parent = wrap
            })

            local HueMap = Util.New("ImageLabel", {
                Size = UDim2.new(0, 150, 0, 110),
                Position = UDim2.new(0, 16, 0, 10),
                Image = "rbxassetid://4155801252",
                ZIndex = 5,
                Parent = PickerArea
            })
            Util.Corner(HueMap, T.RadiusXs)
            local HueRing = Util.New("Frame", {
                BackgroundColor3 = Color3.new(1,1,1),
                Size = UDim2.new(0, 6, 0, 6),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(1 - h, 0, 1 - s, 0),
                ZIndex = 6,
                Parent = HueMap
            })
            Util.Corner(HueRing, UDim.new(1,0))
            Util.Stroke(HueRing, Color3.new(0,0,0), 1)

            local ValSlider = Util.New("Frame", {
                Size = UDim2.new(0, 16, 0, 110),
                Position = UDim2.new(0, 176, 0, 10),
                ZIndex = 5,
                Parent = PickerArea
            })
            Util.Corner(ValSlider, T.RadiusXs)
            local ValUIG = Util.New("UIGradient", {
                Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.new(0,0,0))}),
                Rotation = 90,
                Parent = ValSlider
            })
            local ValRing = Util.New("Frame", {
                BackgroundColor3 = Color3.new(1,1,1),
                Size = UDim2.new(1, 4, 0, 4),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 1 - v, 0),
                ZIndex = 6,
                Parent = ValSlider
            })
            Util.Stroke(ValRing, Color3.new(0,0,0), 1)

            local HexWrap = Util.New("Frame", {
                BackgroundColor3 = T.SurfaceAct,
                Size = UDim2.new(0, 70, 0, 26),
                Position = UDim2.new(0, 202, 0, 10),
                ZIndex = 5,
                Parent = PickerArea
            })
            Util.Corner(HexWrap, T.RadiusXs)
            Util.Stroke(HexWrap, T.Border, 1)

            local HexPrefix = Util.New("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(0, 20, 1, 0),
                Font = T.FontMono, Text = "#", TextColor3 = T.TxtLow, TextSize = 13,
                ZIndex = 6, Parent = HexWrap
            })
            local HexInput = Util.New("TextBox", {
                BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 20, 0, 0),
                Font = T.FontMono, Text = color:ToHex(), TextColor3 = T.TxtHigh, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false, ZIndex = 6, Parent = HexWrap
            })

            local function UpdateColor()
                color = Color3.fromHSV(h, s, v)
                swatch.BackgroundColor3 = color
                HexInput.Text = color:ToHex()
                ValUIG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(h, s, 1)), ColorSequenceKeypoint.new(1, Color3.new(0,0,0))})
                if opts.Callback then opts.Callback(color) end
            end

            local draggingMap = false
            local draggingVal = false

            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local p = input.Position
                    if p.X >= HueMap.AbsolutePosition.X and p.X <= HueMap.AbsolutePosition.X + HueMap.AbsoluteSize.X and p.Y >= HueMap.AbsolutePosition.Y and p.Y <= HueMap.AbsolutePosition.Y + HueMap.AbsoluteSize.Y then
                        draggingMap = true
                    elseif p.X >= ValSlider.AbsolutePosition.X and p.X <= ValSlider.AbsolutePosition.X + ValSlider.AbsoluteSize.X and p.Y >= ValSlider.AbsolutePosition.Y and p.Y <= ValSlider.AbsolutePosition.Y + ValSlider.AbsoluteSize.Y then
                        draggingVal = true
                    end
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingMap = false
                    draggingVal = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if draggingMap then
                        local relX = math.clamp(input.Position.X - HueMap.AbsolutePosition.X, 0, HueMap.AbsoluteSize.X)
                        local relY = math.clamp(input.Position.Y - HueMap.AbsolutePosition.Y, 0, HueMap.AbsoluteSize.Y)
                        HueRing.Position = UDim2.new(0, relX, 0, relY)
                        h = 1 - (relX / HueMap.AbsoluteSize.X)
                        s = 1 - (relY / HueMap.AbsoluteSize.Y)
                        UpdateColor()
                    elseif draggingVal then
                        local relY = math.clamp(input.Position.Y - ValSlider.AbsolutePosition.Y, 0, ValSlider.AbsoluteSize.Y)
                        ValRing.Position = UDim2.new(0.5, 0, 0, relY)
                        v = 1 - (relY / ValSlider.AbsoluteSize.Y)
                        UpdateColor()
                    end
                end
            end)

            HexInput.FocusLost:Connect(function()
                local txt = HexInput.Text
                local success, col = pcall(function() return Color3.fromHex(txt) end)
                if success and col then
                    h, s, v = Color3.toHSV(col)
                    HueRing.Position = UDim2.new(1 - h, 0, 1 - s, 0)
                    ValRing.Position = UDim2.new(0.5, 0, 1 - v, 0)
                    UpdateColor()
                else
                    HexInput.Text = color:ToHex()
                end
            end)

            local open = false
            row.MouseButton1Click:Connect(function()
                open = not open
                Util.Tween(wrap, {Size = UDim2.new(1, 0, 0, open and 184 or 44)}, 0.3, Enum.EasingStyle.Back)
            end)
            UpdateColor()

            local API = {}
            function API:Set(c)
                h, s, v = Color3.toHSV(c)
                HueRing.Position = UDim2.new(1 - h, 0, 1 - s, 0)
                ValRing.Position = UDim2.new(0.5, 0, 1 - v, 0)
                UpdateColor()
            end
            function API:Get() return color end
            return API
        end

        return Tab
    end


    function Window:FetchAPI(url, decodeJSON)
        local success, res = pcall(function()
            return game:HttpGet(url)
        end)
        if not success then
            Notify({Title = "API Error", Content = "Failed to fetch: " .. tostring(res), Type = "Error", Duration = 5})
            return nil
        end
        
        if decodeJSON then
            local s2, parsed = pcall(function()
                return HttpService:JSONDecode(res)
            end)
            if not s2 then
                Notify({Title = "JSON Error", Content = "Failed to parse API response.", Type = "Error", Duration = 5})
                return nil
            end
            return parsed
        end
        return res
    end

    -- ============================================================
    --  CONFIG API
    -- ============================================================

    function Window:SetValue(k, v) State.Data[k] = v end
    function Window:GetValue(k)    return State.Data[k] end

    function Window:SaveConfig(name)
        local out = {}
        for k, v in pairs(State.Data) do out[k] = v end
        pcall(function()
            if writefile then
                writefile((name or WCfg.ConfigKey) .. ".json", HttpService:JSONEncode(out))
            end
        end)
        Notify({Title = "Config Saved", Content = (name or WCfg.ConfigKey) .. ".json written.", Type = "Success", Duration = 3})
        return out
    end

    function Window:LoadConfig(name, data)
        if type(data) == "table" then
            for k, v in pairs(data) do State.Data[k] = v end
            Notify({Title = "Config Loaded", Content = "Loaded " .. (name or "config") .. ".", Type = "Info", Duration = 3})
        else
            pcall(function()
                if readfile and isfile then
                    local path = (name or WCfg.ConfigKey) .. ".json"
                    if isfile(path) then
                        local tbl = HttpService:JSONDecode(readfile(path))
                        for k, v in pairs(tbl) do State.Data[k] = v end
                        Notify({Title = "Config Loaded", Content = path .. " loaded.", Type = "Info", Duration = 3})
                    end
                end
            end)
        end
    end

    function Window:Destroy()
        Util.Tween(Win, {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.4, function() Gui:Destroy() end)
    end

    -- ============================================================
    --  TUTORIAL OVERLAY
    -- ============================================================

    if WCfg.TutorialMode then
        task.spawn(function()
            task.wait(1)

            local Pages = {
                {
                    Title = "Welcome to Libv2 Non-Release",
                    Body  = {
                        "Welcome to the 6M VND Tier of PremiumMenu.",
                        "This features completely new glassmorphism aesthetics,",
                        "along with floating circular toggle buttons.",
                        "",
                        "To disable this guide, add to your config:",
                    },
                    Code = "TutorialMode = false",
                },
                {
                    Title = "Step 1  |  New Avatar Initialization",
                    Body  = {
                        "You can now set a floating avatar button.",
                        "Pass AvatarImage inside CreateWindow.",
                    },
                    Code = 'local Libv2 = loadstring(game:HttpGet("URL_HERE"))()\n\nlocal Window = Libv2:CreateWindow({\n    Title        = "My Premium Hub",\n    Subtitle     = "v2.0",\n    AvatarImage  = "rbxassetid://13589139360",\n    AccentColor  = Color3.fromRGB(114, 137, 218),\n})',
                },
                {
                    Title = "Step 2  |  Using Image Elements",
                    Body  = {
                        "Two new functions have been added to tabs:",
                        "CreateImage and CreateImageButton.",
                    },
                    Code = 'Tab:CreateImage({\n    Name = "My Logo",\n    Image = "rbxassetid://123456789"\n})\n\nTab:CreateImageButton({\n    Name = "Clickable Logo",\n    Image = "rbxassetid://123456789",\n    Callback = function()\n        print("Image Clicked!")\n    end\n})',
                },
                {
                    Title = "Step 3  |  Everything Else Works The Same",
                    Body  = {
                        "All of the PremiumMenu v3 elements are preserved perfectly.",
                        "Toggles, Sliders, MultiDropdowns all function as normal.",
                    },
                    Code = 'Tab:CreateToggle({ Name = "Auto Farm", Default = true })\n\nTab:CreateSlider({ Name = "Speed", Max = 100 })\n\nTab:CreateDropdown({ Name = "Target", Items = {"A", "B"} })\n\nTab:CreateMultiDropdown({ Name = "ESP", Items = {"Players", "Chests"} })',
                }
            }

            local pageIdx = 1
            local Overlay = Util.New("Frame", {
                BackgroundColor3       = Color3.new(0, 0, 0),
                BackgroundTransparency = 1,
                Size   = UDim2.new(1, 0, 1, 0),
                ZIndex = 60,
                Parent = Gui,
            })
            local Card = Util.New("Frame", {
                BackgroundColor3 = T.BG,
                Size     = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint      = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                ZIndex  = 61,
                Parent  = Gui,
            })
            Util.Corner(Card, T.RadiusLg)
            Util.Stroke(Card, T.Accent, 1, 0.3)
            Util.Shadow(Card)

            Util.Tween(Overlay, {BackgroundTransparency = 0.4}, 0.38)
            Util.Tween(Card, {Size = UDim2.new(0, 540, 0, 480), BackgroundTransparency = 0}, 0.48, Enum.EasingStyle.Back)

            local Hdr = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 56), ZIndex = 62, Parent = Card })
            local HdrTitle = Util.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -60, 0, 26), Position = UDim2.new(0, 20, 0, 8), Font = T.FontBold, TextColor3 = T.TxtHigh, TextSize = 17, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 63, Parent = Hdr })
            local HdrSub = Util.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -60, 0, 16), Position = UDim2.new(0, 20, 0, 36), Font = T.FontMed, TextColor3 = T.TxtLow, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 63, Parent = Hdr })
            
            local XBtn = Util.New("TextButton", { BackgroundColor3 = T.SurfaceAct, Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(1, -48, 0, 12), Font = T.FontBold, Text = "X", TextColor3 = T.TxtMid, TextSize = 15, AutoButtonColor = false, ZIndex = 64, Parent = Hdr })
            Util.Corner(XBtn, T.RadiusSm)
            XBtn.MouseButton1Click:Connect(function()
                Util.Tween(Card, {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                Util.Tween(Overlay, {BackgroundTransparency = 1}, 0.35)
                task.delay(0.4, function() Overlay:Destroy() Card:Destroy() end)
            end)

            local Body2 = Util.New("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.new(1, -36, 1, -140), Position = UDim2.new(0, 18, 0, 68), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4, ScrollBarImageColor3 = T.Scrollbar, BorderSizePixel = 0, ZIndex = 62, Parent = Card })
            Util.ListLayout(Body2, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top, UDim.new(0, 6))

            local Footer = Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -36, 0, 38), Position = UDim2.new(0, 18, 1, -48), ZIndex = 62, Parent = Card })
            local NextBtn2 = Util.New("TextButton", { BackgroundColor3 = T.Accent, Size = UDim2.new(0, 90, 0, 36), Position = UDim2.new(1, -90, 0, 0), Font = T.FontBold, TextColor3 = Color3.new(1,1,1), TextSize = 14, AutoButtonColor = false, ZIndex = 63, Parent = Footer })
            Util.Corner(NextBtn2, T.RadiusSm)
            local BackBtn2 = Util.New("TextButton", { BackgroundColor3 = T.Surface, Size = UDim2.new(0, 90, 0, 36), Font = T.FontMed, Text = "< Back", TextColor3 = T.TxtMid, TextSize = 14, AutoButtonColor = false, Visible = false, ZIndex = 63, Parent = Footer })
            Util.Corner(BackBtn2, T.RadiusSm)

            local function DrawPage(idx)
                local pg = Pages[idx]
                HdrTitle.Text = pg.Title
                HdrSub.Text = "Step " .. idx .. " of " .. #Pages
                BackBtn2.Visible = idx > 1
                NextBtn2.Text = (idx == #Pages) and "Finish" or "Next >"

                for _, c in ipairs(Body2:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end

                for i2, line in ipairs(pg.Body) do
                    if line == "" then
                        Util.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 6), LayoutOrder = i2, Parent = Body2 })
                    else
                        Util.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Font = T.FontMed, Text = line, TextColor3 = T.TxtMid, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i2, Parent = Body2 })
                    end
                end

                if pg.Code then
                    local lines = string.split(pg.Code, "\n")
                    local codeH = math.max(#lines * 17 + 20, 48)
                    local CodeWrap = Util.New("Frame", { BackgroundColor3 = Color3.fromRGB(12,12,18), Size = UDim2.new(1, 0, 0, codeH + 30), ClipsDescendants = true, LayoutOrder = 101, Parent = Body2 })
                    Util.Corner(CodeWrap, T.RadiusMd)
                    Util.Stroke(CodeWrap, T.Border, 1, 0.6)
                    
                    local formatted = ""
                    for li, codeLine in ipairs(lines) do formatted = formatted .. string.format("%3d  ", li) .. codeLine .. (li < #lines and "\n" or "") end
                    Util.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, -10), Position = UDim2.new(0, 10, 0, 10), Font = T.FontMono, Text = formatted, TextColor3 = Color3.fromRGB(180,215,255), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = CodeWrap })
                end
            end

            NextBtn2.MouseButton1Click:Connect(function()
                if pageIdx >= #Pages then
                    XBtn:Fire()
                else
                    pageIdx = pageIdx + 1
                    DrawPage(pageIdx)
                end
            end)
            BackBtn2.MouseButton1Click:Connect(function()
                if pageIdx > 1 then
                    pageIdx = pageIdx - 1
                    DrawPage(pageIdx)
                end
            end)
            
            DrawPage(1)
        end)
    end

    -- ============================================================
    --  VISUAL CONFIG MANAGER (AUTO-TAB)
    -- ============================================================
    local SettingsTab = Window:CreateTab({ Name = "⚙ Settings", Order = 9999 })
    
    local configNameInput = ""
    local ConfigInput = SettingsTab:CreateInput({
        Name = "Config Name",
        Placeholder = "e.g. best_legit",
        Callback = function(val) configNameInput = val end
    })

    local function GetConfigs()
        local list = {}
        if listfiles then
            pcall(function()
                for _, f in ipairs(listfiles("")) do
                    if f:match("%.json$") then
                        local clean = f:gsub("%.json$", "")
                        if clean:find("\\") then clean = clean:match(".*\\(.*)") end
                        if clean:find("/") then clean = clean:match(".*/(.*)") end
                        table.insert(list, clean)
                    end
                end
            end)
        end
        return list
    end

    local ConfigDrop
    ConfigDrop = SettingsTab:CreateDropdown({
        Name = "Available Configs",
        Items = GetConfigs(),
        Callback = function(val) 
            configNameInput = val
            ConfigInput:Set(val)
        end
    })

    SettingsTab:CreateButton({
        Name = "Refresh List",
        Callback = function()
            ConfigDrop:Refresh(GetConfigs())
        end
    })

    SettingsTab:CreateButton({
        Name = "💾 Save / Overwrite",
        Callback = function()
            if configNameInput ~= "" then
                Window:SaveConfig(configNameInput)
                ConfigDrop:Refresh(GetConfigs())
            else
                Notify({Title="Error", Content="Enter config name!", Type="Error", Duration=3})
            end
        end
    })

    SettingsTab:CreateButton({
        Name = "📂 Load Config",
        Callback = function()
            if configNameInput ~= "" then
                Window:LoadConfig(configNameInput)
            else
                Notify({Title="Error", Content="Select a config to load!", Type="Error", Duration=3})
            end
        end
    })

    SettingsTab:CreateButton({
        Name = "🗑️ Delete Config",
        Callback = function()
            if configNameInput ~= "" and delfile then
                pcall(function() delfile(configNameInput .. ".json") end)
                Notify({Title="Deleted", Content="Deleted: " .. configNameInput, Type="Warning", Duration=3})
                ConfigDrop:Refresh(GetConfigs())
                configNameInput = ""
                ConfigInput:Set("")
            else
                Notify({Title="Error", Content="Cannot delete config.", Type="Error", Duration=3})
            end
        end
    })

    return Window
end

return Libv2
