--[[
    ╔════════════════════════════════════════════╗
    ║     CORRECT USAGE FOR ROBLOX EXECUTOR      ║
    ╚════════════════════════════════════════════╝
    
    STEP 1: Upload file PremiumLib.lua lên GitHub repo
            VD: github.com/loffy327/Mainscript/PremiumLib.lua
    
    STEP 2: Lấy link RAW (phải có .lua ở cuối)
            VD: https://raw.githubusercontent.com/loffy327/Mainscript/main/PremiumLib.lua
    
    STEP 3: Dùng code bên dưới
--]]

-- ══════════════════════════════════════════════
-- LOAD THƯ VIỆN (chỉ cần 1 dòng này, KHÔNG cần require)
-- ══════════════════════════════════════════════

local PremiumLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/loffy327/Mainscript/main/PremiumLib.lua"
))()

-- ══════════════════════════════════════════════
-- TẠO WINDOW (TutorialMode nằm TRONG config table)
-- ══════════════════════════════════════════════

local Window = PremiumLib:CreateWindow({
    Title        = "My Hub",
    Subtitle     = "v1.0 | by loffy327",
    AccentColor  = Color3.fromRGB(99, 102, 241),
    KeyBind      = Enum.KeyCode.RightShift,
    TutorialMode = true,   -- ← ĐẶT Ở ĐÂY, true = hiện tutorial, false = tắt
})

-- ══════════════════════════════════════════════
-- TẠO TAB
-- ══════════════════════════════════════════════

local MainTab = Window:CreateTab({ Name = "Main", Icon = "⚡" })

-- ══════════════════════════════════════════════
-- TẠO SECTION + ELEMENTS
-- ══════════════════════════════════════════════

MainTab:CreateSection("Features")

MainTab:CreateToggle({
    Name        = "Auto Farm",
    Description = "Enable auto farming",
    Default     = false,
    Callback    = function(value)
        print("Auto Farm:", value)
    end
})

MainTab:CreateSlider({
    Name      = "Speed",
    Min       = 16,
    Max       = 200,
    Default   = 16,
    Increment = 1,
    Callback  = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

MainTab:CreateButton({
    Name       = "Print Hello",
    ButtonText = "Run",
    Callback   = function()
        print("Hello World!")
        Window:Notify({
            Title   = "Success",
            Content = "Button clicked!",
            Type    = "Success",
            Duration = 3,
        })
    end
})

-- ══════════════════════════════════════════════
-- NOTIFICATION CHÀO MỪNG
-- ══════════════════════════════════════════════

Window:Notify({
    Title    = "Welcome!",
    Content  = "Script loaded successfully.",
    Type     = "Success",
    Duration = 4,
})
