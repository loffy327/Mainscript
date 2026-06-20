local PremiumLib = {}
PremiumLib.__index = PremiumLib

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local DefaultTheme = {
	Background        = Color3.fromRGB(15, 15, 22),
	BackgroundAlt     = Color3.fromRGB(20, 20, 30),
	Surface           = Color3.fromRGB(25, 25, 38),
	SurfaceHover      = Color3.fromRGB(32, 32, 48),
	SurfaceActive     = Color3.fromRGB(38, 38, 55),
	Accent            = Color3.fromRGB(99, 102, 241),
	AccentHover       = Color3.fromRGB(129, 132, 255),
	AccentDark        = Color3.fromRGB(67, 70, 200),
	AccentGlow        = Color3.fromRGB(99, 102, 241),
	TextPrimary       = Color3.fromRGB(237, 237, 245),
	TextSecondary     = Color3.fromRGB(148, 148, 168),
	TextMuted         = Color3.fromRGB(88, 88, 108),
	Border            = Color3.fromRGB(40, 40, 58),
	BorderHover       = Color3.fromRGB(60, 60, 85),
	Success           = Color3.fromRGB(34, 197, 94),
	Warning           = Color3.fromRGB(250, 204, 21),
	Error             = Color3.fromRGB(239, 68, 68),
	Info              = Color3.fromRGB(56, 189, 248),
	Shadow            = Color3.fromRGB(0, 0, 0),
	Divider           = Color3.fromRGB(35, 35, 52),
	ScrollBar         = Color3.fromRGB(55, 55, 78),
	FontMain          = Enum.Font.GothamBold,
	FontBody          = Enum.Font.GothamMedium,
	FontMono          = Enum.Font.Code,
	CornerRadius      = UDim.new(0, 8),
	CornerRadiusSmall = UDim.new(0, 6),
	CornerRadiusLarge = UDim.new(0, 12),
	TweenSpeed        = 0.25,
	TweenEasing       = Enum.EasingStyle.Quint,
}

local function Tween(obj, props, duration, easingStyle, easingDir)
	local info = TweenInfo.new(
		duration or DefaultTheme.TweenSpeed,
		easingStyle or DefaultTheme.TweenEasing,
		easingDir or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(obj, info, props)
	tween:Play()
	return tween
end

local function CreateInstance(className, properties, children)
	local inst = Instance.new(className)
	if properties then
		for prop, value in pairs(properties) do
			inst[prop] = value
		end
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end
	return inst
end

local function AddCorner(parent, radius)
	return CreateInstance("UICorner", {
		CornerRadius = radius or DefaultTheme.CornerRadius,
		Parent = parent
	})
end

local function AddStroke(parent, color, thickness, transparency)
	return CreateInstance("UIStroke", {
		Color = color or DefaultTheme.Border,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		Parent = parent
	})
end

local function AddPadding(parent, top, right, bottom, left)
	return CreateInstance("UIPadding", {
		PaddingTop = UDim.new(0, top or 8),
		PaddingRight = UDim.new(0, right or 8),
		PaddingBottom = UDim.new(0, bottom or 8),
		PaddingLeft = UDim.new(0, left or 8),
		Parent = parent
	})
end

local function AddShadow(parent)
	return CreateInstance("ImageLabel", {
		Name = "Shadow",
		BackgroundTransparency = 1,
		Image = "rbxassetid://6014261993",
		ImageColor3 = DefaultTheme.Shadow,
		ImageTransparency = 0.5,
		Size = UDim2.new(1, 30, 1, 30),
		Position = UDim2.new(0, -15, 0, -15),
		ZIndex = -1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		Parent = parent
	})
end

local function RippleEffect(button)
	local ripple = CreateInstance("Frame", {
		Name = "Ripple",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.8,
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = button,
		ZIndex = button.ZIndex + 1
	})
	AddCorner(ripple, UDim.new(1, 0))
	Tween(ripple, {Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1}, 0.5)
	task.delay(0.5, function() ripple:Destroy() end)
end

function PremiumLib:CreateWindow(config)
	config = config or {}

	local Theme = config.Theme or DefaultTheme
	local WindowConfig = {
		Title        = config.Title or "Premium Library",
		Subtitle     = config.Subtitle or "v2.0",
		Size         = config.Size or UDim2.new(0, 580, 0, 420),
		MinSize      = config.MinSize or UDim2.new(0, 580, 0, 60),
		LogoId       = config.LogoId or nil,
		AccentColor  = config.AccentColor or Theme.Accent,
		ConfigName   = config.ConfigName or "PremiumConfig",
		KeyBind      = config.KeyBind or Enum.KeyCode.RightShift,
		TutorialMode = (config.TutorialMode == nil) and true or config.TutorialMode,
	}

	if config.AccentColor then
		Theme.Accent = config.AccentColor
		Theme.AccentGlow = config.AccentColor
	end

	local WindowState = {
		Minimized = false,
		Maximized = false,
		Dragging = false,
		DragStart = nil,
		StartPos = nil,
		ActiveTab = nil,
		Tabs = {},
		Configs = {},
	}

	local ScreenGui = CreateInstance("ScreenGui", {
		Name = "PremiumLibrary",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
		IgnoreGuiInset = true,
		Parent = Player:WaitForChild("PlayerGui")
	})

	local MainFrame = CreateInstance("Frame", {
		Name = "MainFrame",
		BackgroundColor3 = Theme.Background,
		Size = WindowConfig.Size,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ClipsDescendants = true,
		Parent = ScreenGui
	})
	AddCorner(MainFrame, Theme.CornerRadiusLarge)
	AddStroke(MainFrame, Theme.Border, 1, 0.5)
	AddShadow(MainFrame)

	MainFrame.Size = UDim2.new(0, 0, 0, 0)
	MainFrame.BackgroundTransparency = 1
	Tween(MainFrame, {Size = WindowConfig.Size, BackgroundTransparency = 0}, 0.6, Enum.EasingStyle.Back)

	local GlowLine = CreateInstance("Frame", {
		Name = "GlowLine",
		BackgroundColor3 = Theme.Accent,
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 0, 0),
		BorderSizePixel = 0,
		Parent = MainFrame
	})

	local GlowGradient = CreateInstance("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.5, Theme.Accent),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		}),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 0.8)
		}),
		Parent = GlowLine
	})

	task.spawn(function()
		while GlowLine and GlowLine.Parent do
			Tween(GlowGradient, {Offset = Vector2.new(1, 0)}, 2, Enum.EasingStyle.Linear)
			task.wait(2)
			GlowGradient.Offset = Vector2.new(-1, 0)
		end
	end)

	local TitleBar = CreateInstance("Frame", {
		Name = "TitleBar",
		BackgroundColor3 = Theme.BackgroundAlt,
		BackgroundTransparency = 0.3,
		Size = UDim2.new(1, 0, 0, 48),
		Position = UDim2.new(0, 0, 0, 2),
		BorderSizePixel = 0,
		Parent = MainFrame
	})

	CreateInstance("Frame", {
		Name = "BottomBorder",
		BackgroundColor3 = Theme.Divider,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BorderSizePixel = 0,
		Parent = TitleBar
	})

	local LogoFrame = CreateInstance("Frame", {
		Name = "Logo",
		BackgroundColor3 = Theme.Accent,
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(0, 14, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Parent = TitleBar
	})
	AddCorner(LogoFrame, UDim.new(0, 6))

	local LogoIcon = CreateInstance("TextLabel", {
		Name = "LogoIcon",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Theme.FontMain,
		Text = config.LogoText or "P",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 16,
		Parent = LogoFrame
	})

	if WindowConfig.LogoId then
		LogoIcon.Visible = false
		CreateInstance("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0.7, 0, 0.7, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = WindowConfig.LogoId,
			Parent = LogoFrame
		})
	end

	CreateInstance("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -60, 0.5, 0),
		Position = UDim2.new(0, 52, 0, 4),
		Font = Theme.FontMain,
		Text = WindowConfig.Title,
		TextColor3 = Theme.TextPrimary,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TitleBar
	})

	CreateInstance("TextLabel", {
		Name = "Subtitle",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -60, 0.5, 0),
		Position = UDim2.new(0, 52, 0.5, -2),
		Font = Theme.FontBody,
		Text = WindowConfig.Subtitle,
		TextColor3 = Theme.TextMuted,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TitleBar
	})

	local ControlsFrame = CreateInstance("Frame", {
		Name = "Controls",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 100, 0, 30),
		Position = UDim2.new(1, -110, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Parent = TitleBar
	})

	CreateInstance("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
		Parent = ControlsFrame
	})

	local function CreateControlButton(name, symbol, color, hoverColor, callback)
		local btn = CreateInstance("TextButton", {
			Name = name,
			BackgroundColor3 = Theme.Surface,
			Size = UDim2.new(0, 28, 0, 28),
			Font = Theme.FontMain,
			Text = symbol,
			TextColor3 = color,
			TextSize = 14,
			AutoButtonColor = false,
			Parent = ControlsFrame
		})
		AddCorner(btn, UDim.new(0, 6))
		btn.MouseEnter:Connect(function()
			Tween(btn, {BackgroundColor3 = hoverColor, TextColor3 = Color3.fromRGB(255,255,255)}, 0.15)
		end)
		btn.MouseLeave:Connect(function()
			Tween(btn, {BackgroundColor3 = Theme.Surface, TextColor3 = color}, 0.15)
		end)
		btn.MouseButton1Click:Connect(function()
			RippleEffect(btn)
			if callback then callback() end
		end)
		return btn
	end

	CreateControlButton("Minimize", "-", Theme.TextSecondary, Theme.Warning, function()
		WindowState.Minimized = not WindowState.Minimized
		if WindowState.Minimized then
			Tween(MainFrame, {Size = WindowConfig.MinSize}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		else
			local targetSize = WindowState.Maximized and UDim2.new(1, -40, 1, -40) or WindowConfig.Size
			Tween(MainFrame, {Size = targetSize}, 0.35, Enum.EasingStyle.Back)
		end
	end)

	CreateControlButton("Maximize", "+", Theme.TextSecondary, Theme.Success, function()
		if WindowState.Minimized then WindowState.Minimized = false end
		WindowState.Maximized = not WindowState.Maximized
		if WindowState.Maximized then
			Tween(MainFrame, {Size = UDim2.new(1, -40, 1, -40), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.35, Enum.EasingStyle.Back)
		else
			Tween(MainFrame, {Size = WindowConfig.Size, Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.35, Enum.EasingStyle.Back)
		end
	end)

	CreateControlButton("Close", "X", Theme.TextSecondary, Theme.Error, function()
		Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		task.delay(0.45, function() ScreenGui:Destroy() end)
	end)

	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			WindowState.Dragging = true
			WindowState.DragStart = input.Position
			WindowState.StartPos = MainFrame.Position
		end
	end)

	TitleBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			WindowState.Dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if WindowState.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - WindowState.DragStart
			MainFrame.Position = UDim2.new(
				WindowState.StartPos.X.Scale, WindowState.StartPos.X.Offset + delta.X,
				WindowState.StartPos.Y.Scale, WindowState.StartPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == WindowConfig.KeyBind then
			MainFrame.Visible = not MainFrame.Visible
		end
	end)

	local BodyFrame = CreateInstance("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -50),
		Position = UDim2.new(0, 0, 0, 50),
		Parent = MainFrame
	})

	local Sidebar = CreateInstance("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = Theme.BackgroundAlt,
		BackgroundTransparency = 0.2,
		Size = UDim2.new(0, 155, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BorderSizePixel = 0,
		Parent = BodyFrame
	})

	CreateInstance("Frame", {
		BackgroundColor3 = Theme.Divider,
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		BorderSizePixel = 0,
		Parent = Sidebar
	})

	local SidebarScroll = CreateInstance("ScrollingFrame", {
		Name = "TabList",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -8, 1, -16),
		Position = UDim2.new(0, 4, 0, 8),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.ScrollBar,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
		Parent = Sidebar
	})

	CreateInstance("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 3),
		Parent = SidebarScroll
	})

	local ContentArea = CreateInstance("Frame", {
		Name = "ContentArea",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -156, 1, 0),
		Position = UDim2.new(0, 156, 0, 0),
		ClipsDescendants = true,
		Parent = BodyFrame
	})

	local NotifHolder = CreateInstance("Frame", {
		Name = "Notifications",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 300, 1, -20),
		Position = UDim2.new(1, -310, 0, 10),
		Parent = ScreenGui
	})

	CreateInstance("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Parent = NotifHolder
	})

	local function Notify(options)
		options = options or {}
		local notifType = options.Type or "Info"
		local colors = {Info = Theme.Info, Success = Theme.Success, Warning = Theme.Warning, Error = Theme.Error}
		local accentColor = colors[notifType] or Theme.Accent

		local NotifFrame = CreateInstance("Frame", {
			Name = "Notification",
			BackgroundColor3 = Theme.Surface,
			Size = UDim2.new(1, 0, 0, 70),
			Parent = NotifHolder
		})
		AddCorner(NotifFrame, Theme.CornerRadius)
		AddStroke(NotifFrame, accentColor, 1, 0.5)

		local accentBar = CreateInstance("Frame", {
			BackgroundColor3 = accentColor,
			Size = UDim2.new(0, 3, 0.7, 0),
			Position = UDim2.new(0, 6, 0.15, 0),
			BorderSizePixel = 0,
			Parent = NotifFrame
		})
		AddCorner(accentBar, UDim.new(1, 0))

		CreateInstance("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -30, 0, 20),
			Position = UDim2.new(0, 18, 0, 10),
			Font = Theme.FontMain,
			Text = options.Title or "Notification",
			TextColor3 = Theme.TextPrimary,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = NotifFrame
		})

		CreateInstance("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -30, 0, 30),
			Position = UDim2.new(0, 18, 0, 30),
			Font = Theme.FontBody,
			Text = options.Content or "",
			TextColor3 = Theme.TextSecondary,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Parent = NotifFrame
		})

		NotifFrame.Position = UDim2.new(1, 50, 0, 0)
		NotifFrame.BackgroundTransparency = 0.5
		Tween(NotifFrame, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, 0.35)

		local duration = options.Duration or 4
		task.delay(duration, function()
			Tween(NotifFrame, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}, 0.35)
			task.delay(0.4, function() NotifFrame:Destroy() end)
		end)
	end

	local Window = {}
	Window.Notify = Notify

	function Window:CreateTab(tabConfig)
		tabConfig = tabConfig or {}
		local tabName = tabConfig.Name or "Tab"
		local tabIcon = tabConfig.Icon or ""
		local tabOrder = tabConfig.LayoutOrder or (#WindowState.Tabs + 1)

		local TabButton = CreateInstance("TextButton", {
			Name = "Tab_" .. tabName,
			BackgroundColor3 = Theme.Surface,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -8, 0, 38),
			Font = Theme.FontBody,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = tabOrder,
			Parent = SidebarScroll
		})
		AddCorner(TabButton, Theme.CornerRadiusSmall)

		local TabIcon = CreateInstance("TextLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 30, 1, 0),
			Position = UDim2.new(0, 8, 0, 0),
			Font = Theme.FontBody,
			Text = tabIcon,
			TextColor3 = Theme.TextMuted,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = TabButton
		})

		local TabLabel = CreateInstance("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -48, 1, 0),
			Position = UDim2.new(0, 40, 0, 0),
			Font = Theme.FontBody,
			Text = tabName,
			TextColor3 = Theme.TextSecondary,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = TabButton
		})

		local ActiveIndicator = CreateInstance("Frame", {
			Name = "ActiveIndicator",
			BackgroundColor3 = Theme.Accent,
			Size = UDim2.new(0, 3, 0, 0),
			Position = UDim2.new(0, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BorderSizePixel = 0,
			Parent = TabButton
		})
		AddCorner(ActiveIndicator, UDim.new(1, 0))

		local TabPage = CreateInstance("ScrollingFrame", {
			Name = "Page_" .. tabName,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -16, 1, -16),
			Position = UDim2.new(0, 8, 0, 8),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.ScrollBar,
			BorderSizePixel = 0,
			Visible = false,
			Parent = ContentArea
		})

		CreateInstance("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
			Parent = TabPage
		})
		AddPadding(TabPage, 4, 4, 4, 4)

		local tabData = {
			Button = TabButton, Page = TabPage, Name = tabName,
			Indicator = ActiveIndicator, Icon = TabIcon, Label = TabLabel,
		}
		table.insert(WindowState.Tabs, tabData)

		local function SelectTab()
			for _, t in ipairs(WindowState.Tabs) do
				t.Page.Visible = false
				Tween(t.Button, {BackgroundTransparency = 1}, 0.2)
				Tween(t.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
				Tween(t.Label, {TextColor3 = Theme.TextSecondary}, 0.2)
				Tween(t.Icon, {TextColor3 = Theme.TextMuted}, 0.2)
			end
			tabData.Page.Visible = true
			Tween(tabData.Button, {BackgroundTransparency = 0.6}, 0.2)
			Tween(tabData.Indicator, {Size = UDim2.new(0, 3, 0, 20)}, 0.25, Enum.EasingStyle.Back)
			Tween(tabData.Label, {TextColor3 = Theme.TextPrimary}, 0.2)
			Tween(tabData.Icon, {TextColor3 = Theme.Accent}, 0.2)
			WindowState.ActiveTab = tabData
		end

		TabButton.MouseEnter:Connect(function()
			if WindowState.ActiveTab ~= tabData then
				Tween(TabButton, {BackgroundTransparency = 0.7}, 0.15)
			end
		end)
		TabButton.MouseLeave:Connect(function()
			if WindowState.ActiveTab ~= tabData then
				Tween(TabButton, {BackgroundTransparency = 1}, 0.15)
			end
		end)
		TabButton.MouseButton1Click:Connect(SelectTab)

		if #WindowState.Tabs == 1 then SelectTab() end

		local Tab = {}

		function Tab:CreateSection(sectionName)
			local SectionFrame = CreateInstance("Frame", {
				Name = "Section_" .. (sectionName or ""),
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 28),
				LayoutOrder = (#TabPage:GetChildren()),
				Parent = TabPage
			})

			CreateInstance("Frame", {
				BackgroundColor3 = Theme.Divider,
				Size = UDim2.new(0, 20, 0, 1),
				Position = UDim2.new(0, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BorderSizePixel = 0,
				Parent = SectionFrame
			})

			CreateInstance("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.6, 0, 1, 0),
				Position = UDim2.new(0, 28, 0, 0),
				Font = Theme.FontMain,
				Text = string.upper(sectionName or "SECTION"),
				TextColor3 = Theme.TextMuted,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = SectionFrame
			})

			CreateInstance("Frame", {
				BackgroundColor3 = Theme.Divider,
				Size = UDim2.new(0.5, -10, 0, 1),
				Position = UDim2.new(0.5, 10, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BorderSizePixel = 0,
				Parent = SectionFrame
			})
		end

		function Tab:CreateToggle(options)
			options = options or {}
			local toggleState = options.Default or false

			local ToggleFrame = CreateInstance("Frame", {
				Name = "Toggle_" .. (options.Name or ""),
				BackgroundColor3 = Theme.Surface,
				Size = UDim2.new(1, 0, 0, 42),
				LayoutOrder = (#TabPage:GetChildren()),
				Parent = TabPage
			})
			AddCorner(ToggleFrame, Theme.CornerRadiusSmall)

			CreateInstance("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.7, -20, 0.5, 0),
				Position = UDim2.new(0, 14, 0, 4),
				Font = Theme.FontBody,
				Text = options.Name or "Toggle",
				TextColor3 = Theme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = ToggleFrame
			})

			if options.Description then
				CreateInstance("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0.7, -20, 0.5, 0),
					Position = UDim2.new(0, 14, 0.5, -2),
					Font = Theme.FontBody,
					Text = options.Description,
					TextColor3 = Theme.TextMuted,
					TextSize = 10,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = ToggleFrame
				})
			end

			local SwitchOuter = CreateInstance("Frame", {
				BackgroundColor3 = toggleState and Theme.Accent or Theme.SurfaceActive,
				Size = UDim2.new(0, 42, 0, 22),
				Position = UDim2.new(1, -56, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Parent = ToggleFrame
			})
			AddCorner(SwitchOuter, UDim.new(1, 0))

			local SwitchKnob = CreateInstance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.new(0, 16, 0, 16),
				Position = toggleState and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Parent = SwitchOuter
			})
			AddCorner(SwitchKnob, UDim.new(1, 0))

			local function UpdateToggle()
				if toggleState then
					Tween(SwitchOuter, {BackgroundColor3 = Theme.Accent}, 0.2)
					Tween(SwitchKnob, {Position = UDim2.new(1, -19, 0.5, 0)}, 0.2, Enum.EasingStyle.Back)
				else
					Tween(SwitchOuter, {BackgroundColor3 = Theme.SurfaceActive}, 0.2)
					Tween(SwitchKnob, {Position = UDim2.new(0, 3, 0.5, 0)}, 0.2, Enum.EasingStyle.Back)
				end
				if options.Callback then options.Callback(toggleState) end
			end

			ToggleFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					Tween(ToggleFrame, {BackgroundColor3 = Theme.SurfaceHover}, 0.15)
				end
			end)
			ToggleFrame.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					Tween(ToggleFrame, {BackgroundColor3 = Theme.Surface}, 0.15)
				end
			end)

			local clickBtn = CreateInstance("TextButton", {
				BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", Parent = ToggleFrame
			})
			clickBtn.MouseButton1Click:Connect(function()
				toggleState = not toggleState
				UpdateToggle()
			end)

			local ToggleAPI = {}
			function ToggleAPI:Set(value) toggleState = value; UpdateToggle() end
			function ToggleAPI:Get() return toggleState end
			return ToggleAPI
		end

		function Tab:CreateButton(options)
			options = options or {}
			local ButtonFrame = CreateInstance("Frame", {
				Name = "Button_" .. (options.Name or ""),
				BackgroundColor3 = Theme.Surface,
				Size = UDim2.new(1, 0, 0, 38),
				LayoutOrder = (#TabPage:GetChildren()),
				Parent = TabPage
			})
			AddCorner(ButtonFrame, Theme.CornerRadiusSmall)

			CreateInstance("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.7, -10, 1, 0),
				Position = UDim2.new(0, 14, 0, 0),
				Font = Theme.FontBody,
				Text = options.Name or "Button",
				TextColor3 = Theme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = ButtonFrame
			})

			local ActionBtn = CreateInstance("TextButton", {
				BackgroundColor3 = Theme.Accent,
				Size = UDim2.new(0, 70, 0, 26),
				Position = UDim2.new(1, -82, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Font = Theme.FontMain,
				Text = options.ButtonText or "Run",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 11,
				AutoButtonColor = false,
				Parent = ButtonFrame
			})
			AddCorner(ActionBtn, Theme.CornerRadiusSmall)

			ActionBtn.MouseEnter:Connect(function() Tween(ActionBtn, {BackgroundColor3 = Theme.AccentHover}, 0.15) end)
			ActionBtn.MouseLeave:Connect(function() Tween(ActionBtn, {BackgroundColor3 = Theme.Accent}, 0.15) end)
			ActionBtn.MouseButton1Click:Connect(function()
				RippleEffect(ActionBtn)
				if options.Callback then options.Callback() end
			end)

			ButtonFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(ButtonFrame, {BackgroundColor3 = Theme.SurfaceHover}, 0.15) end
			end)
			ButtonFrame.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(ButtonFrame, {BackgroundColor3 = Theme.Surface}, 0.15) end
			end)
		end

		function Tab:CreateSlider(options)
			options = options or {}
			local min = options.Min or 0
			local max = options.Max or 100
			local default = options.Default or min
			local increment = options.Increment or 1
			local currentValue = default

			local SliderFrame = CreateInstance("Frame", {
				Name = "Slider_" .. (options.Name or ""),
				BackgroundColor3 = Theme.Surface,
				Size = UDim2.new(1, 0, 0, 52),
				LayoutOrder = (#TabPage:GetChildren()),
				Parent = TabPage
			})
			AddCorner(SliderFrame, Theme.CornerRadiusSmall)

			CreateInstance("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.6, -10, 0, 20),
				Position = UDim2.new(0, 14, 0, 6),
				Font = Theme.FontBody,
				Text = options.Name or "Slider",
				TextColor3 = Theme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = SliderFrame
			})

			local ValueLabel = CreateInstance("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.3, -14, 0, 20),
				Position = UDim2.new(0.7, 0, 0, 6),
				Font = Theme.FontMono,
				Text = tostring(currentValue),
				TextColor3 = Theme.Accent,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = SliderFrame
			})

			local Track = CreateInstance("Frame", {
				BackgroundColor3 = Theme.SurfaceActive,
				Size = UDim2.new(1, -28, 0, 6),
				Position = UDim2.new(0, 14, 0, 36),
				Parent = SliderFrame
			})
			AddCorner(Track, UDim.new(1, 0))

			local initialFill = (default - min) / (max - min)
			local Fill = CreateInstance("Frame", {
				BackgroundColor3 = Theme.Accent,
				Size = UDim2.new(initialFill, 0, 1, 0),
				Parent = Track
			})
			AddCorner(Fill, UDim.new(1, 0))

			local Knob = CreateInstance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Size = UDim2.new(0, 14, 0, 14),
				Position = UDim2.new(initialFill, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ZIndex = 2,
				Parent = Track
			})
			AddCorner(Knob, UDim.new(1, 0))
			AddStroke(Knob, Theme.Accent, 2)

			local dragging = false
			local function UpdateSlider(inputPos)
				local trackAbsPos = Track.AbsolutePosition.X
				local trackAbsSize = Track.AbsoluteSize.X
				local relative = math.clamp((inputPos - trackAbsPos) / trackAbsSize, 0, 1)
				local rawValue = min + (max - min) * relative
				currentValue = math.floor(rawValue / increment + 0.5) * increment
				currentValue = math.clamp(currentValue, min, max)
				local fillPercent = (currentValue - min) / (max - min)
				Fill.Size = UDim2.new(fillPercent, 0, 1, 0)
				Knob.Position = UDim2.new(fillPercent, 0, 0.5, 0)
				ValueLabel.Text = tostring(currentValue)
				if options.Callback then options.Callback(currentValue) end
			end

			Track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					UpdateSlider(input.Position.X)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					UpdateSlider(input.Position.X)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)

			SliderFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(SliderFrame, {BackgroundColor3 = Theme.SurfaceHover}, 0.15) end
			end)
			SliderFrame.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(SliderFrame, {BackgroundColor3 = Theme.Surface}, 0.15) end
			end)

			local SliderAPI = {}
			function SliderAPI:Set(value)
				currentValue = math.clamp(value, min, max)
				local fp = (currentValue - min) / (max - min)
				Fill.Size = UDim2.new(fp, 0, 1, 0)
				Knob.Position = UDim2.new(fp, 0, 0.5, 0)
				ValueLabel.Text = tostring(currentValue)
			end
			function SliderAPI:Get() return currentValue end
			return SliderAPI
		end

		function Tab:CreateDropdown(options)
			options = options or {}
			local items = options.Items or {}
			local defaultItem = options.Default or (items[1] or "")
			local currentItem = defaultItem
			local expanded = false

			local DropdownFrame = CreateInstance("Frame", {
				Name = "Dropdown_" .. (options.Name or ""),
				BackgroundColor3 = Theme.Surface,
				Size = UDim2.new(1, 0, 0, 42),
				ClipsDescendants = true,
				LayoutOrder = (#TabPage:GetChildren()),
				Parent = TabPage
			})
			AddCorner(DropdownFrame, Theme.CornerRadiusSmall)

			CreateInstance("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.45, 0, 0, 42),
				Position = UDim2.new(0, 14, 0, 0),
				Font = Theme.FontBody,
				Text = options.Name or "Dropdown",
				TextColor3 = Theme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = DropdownFrame
			})

			local SelectedBtn = CreateInstance("TextButton", {
				BackgroundColor3 = Theme.SurfaceActive,
				Size = UDim2.new(0.48, -14, 0, 28),
				Position = UDim2.new(0.52, 0, 0, 7),
				Font = Theme.FontBody,
				Text = currentItem .. "  v",
				TextColor3 = Theme.TextSecondary,
				TextSize = 12,
				AutoButtonColor = false,
				Parent = DropdownFrame
			})
			AddCorner(SelectedBtn, Theme.CornerRadiusSmall)

			local ItemsContainer = CreateInstance("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -10, 0, 0),
				Position = UDim2.new(0, 5, 0, 44),
				Parent = DropdownFrame
			})
			CreateInstance("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2),
				Parent = ItemsContainer
			})

			local function RefreshItems()
				for _, child in ipairs(ItemsContainer:GetChildren()) do
					if child:IsA("TextButton") then child:Destroy() end
				end
				for i, item in ipairs(items) do
					local ItemBtn = CreateInstance("TextButton", {
						BackgroundColor3 = Theme.SurfaceHover,
						BackgroundTransparency = 0.4,
						Size = UDim2.new(1, 0, 0, 28),
						Font = Theme.FontBody,
						Text = item,
						TextColor3 = (item == currentItem) and Theme.Accent or Theme.TextSecondary,
						TextSize = 12,
						AutoButtonColor = false,
						LayoutOrder = i,
						Parent = ItemsContainer
					})
					AddCorner(ItemBtn, Theme.CornerRadiusSmall)
					ItemBtn.MouseEnter:Connect(function() Tween(ItemBtn, {BackgroundTransparency = 0, TextColor3 = Theme.TextPrimary}, 0.1) end)
					ItemBtn.MouseLeave:Connect(function() Tween(ItemBtn, {BackgroundTransparency = 0.4, TextColor3 = (item == currentItem) and Theme.Accent or Theme.TextSecondary}, 0.1) end)
					ItemBtn.MouseButton1Click:Connect(function()
						currentItem = item
						SelectedBtn.Text = item .. "  v"
						expanded = false
						Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 42)}, 0.25)
						RefreshItems()
						if options.Callback then options.Callback(item) end
					end)
				end
			end
			RefreshItems()

			SelectedBtn.MouseButton1Click:Connect(function()
				expanded = not expanded
				if expanded then
					Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 44 + (#items * 30) + 8)}, 0.3, Enum.EasingStyle.Back)
					SelectedBtn.Text = currentItem .. "  ^"
				else
					Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 42)}, 0.25)
					SelectedBtn.Text = currentItem .. "  v"
				end
			end)

			DropdownFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(DropdownFrame, {BackgroundColor3 = Theme.SurfaceHover}, 0.15) end
			end)
			DropdownFrame.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(DropdownFrame, {BackgroundColor3 = Theme.Surface}, 0.15) end
			end)

			local DropdownAPI = {}
			function DropdownAPI:Set(value) currentItem = value; SelectedBtn.Text = value .. "  v"; RefreshItems() end
			function DropdownAPI:Refresh(newItems, newDefault)
				items = newItems
				if newDefault then currentItem = newDefault; SelectedBtn.Text = newDefault .. "  v" end
				RefreshItems()
			end
			function DropdownAPI:Get() return currentItem end
			return DropdownAPI
		end

		function Tab:CreateInput(options)
			options = options or {}
			local InputFrame = CreateInstance("Frame", {
				Name = "Input_" .. (options.Name or ""),
				BackgroundColor3 = Theme.Surface,
				Size = UDim2.new(1, 0, 0, 42),
				LayoutOrder = (#TabPage:GetChildren()),
				Parent = TabPage
			})
			AddCorner(InputFrame, Theme.CornerRadiusSmall)

			CreateInstance("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.4, 0, 1, 0),
				Position = UDim2.new(0, 14, 0, 0),
				Font = Theme.FontBody,
				Text = options.Name or "Input",
				TextColor3 = Theme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = InputFrame
			})

			local TextBox = CreateInstance("TextBox", {
				BackgroundColor3 = Theme.SurfaceActive,
				Size = UDim2.new(0.55, -14, 0, 28),
				Position = UDim2.new(0.45, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Font = Theme.FontBody,
				PlaceholderText = options.Placeholder or "Enter value...",
				PlaceholderColor3 = Theme.TextMuted,
				Text = options.Default or "",
				TextColor3 = Theme.TextPrimary,
				TextSize = 12,
				ClearTextOnFocus = options.ClearOnFocus or false,
				Parent = InputFrame
			})
			AddCorner(TextBox, Theme.CornerRadiusSmall)
			AddPadding(TextBox, 0, 8, 0, 8)
			local inputStroke = AddStroke(TextBox, Theme.Border, 1, 0.5)

			TextBox.Focused:Connect(function() Tween(inputStroke, {Color = Theme.Accent, Transparency = 0}, 0.2) end)
			TextBox.FocusLost:Connect(function(enterPressed)
				Tween(inputStroke, {Color = Theme.Border, Transparency = 0.5}, 0.2)
				if options.Callback then options.Callback(TextBox.Text, enterPressed) end
			end)

			InputFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(InputFrame, {BackgroundColor3 = Theme.SurfaceHover}, 0.15) end
			end)
			InputFrame.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(InputFrame, {BackgroundColor3 = Theme.Surface}, 0.15) end
			end)

			local InputAPI = {}
			function InputAPI:Set(value) TextBox.Text = value end
			function InputAPI:Get() return TextBox.Text end
			return InputAPI
		end

		function Tab:CreateLabel(options)
			options = options or {}
			local LabelFrame = CreateInstance("Frame", {
				BackgroundColor3 = Theme.Surface,
				BackgroundTransparency = 0.3,
				Size = UDim2.new(1, 0, 0, 32),
				LayoutOrder = (#TabPage:GetChildren()),
				Parent = TabPage
			})
			AddCorner(LabelFrame, Theme.CornerRadiusSmall)

			local accentDot = CreateInstance("Frame", {
				BackgroundColor3 = Theme.Accent,
				Size = UDim2.new(0, 6, 0, 6),
				Position = UDim2.new(0, 12, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Parent = LabelFrame
			})
			AddCorner(accentDot, UDim.new(1, 0))

			local LabelText = CreateInstance("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -30, 1, 0),
				Position = UDim2.new(0, 26, 0, 0),
				Font = Theme.FontBody,
				Text = options.Text or "Label",
				TextColor3 = Theme.TextSecondary,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = LabelFrame
			})

			local LabelAPI = {}
			function LabelAPI:Set(text) LabelText.Text = text end
			return LabelAPI
		end

		function Tab:CreateKeybind(options)
			options = options or {}
			local currentKey = options.Default or Enum.KeyCode.E
			local listening = false

			local KeybindFrame = CreateInstance("Frame", {
				Name = "Keybind_" .. (options.Name or ""),
				BackgroundColor3 = Theme.Surface,
				Size = UDim2.new(1, 0, 0, 42),
				LayoutOrder = (#TabPage:GetChildren()),
				Parent = TabPage
			})
			AddCorner(KeybindFrame, Theme.CornerRadiusSmall)

			CreateInstance("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.6, 0, 1, 0),
				Position = UDim2.new(0, 14, 0, 0),
				Font = Theme.FontBody,
				Text = options.Name or "Keybind",
				TextColor3 = Theme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = KeybindFrame
			})

			local KeyBtn = CreateInstance("TextButton", {
				BackgroundColor3 = Theme.SurfaceActive,
				Size = UDim2.new(0, 70, 0, 26),
				Position = UDim2.new(1, -82, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Font = Theme.FontMono,
				Text = currentKey.Name,
				TextColor3 = Theme.Accent,
				TextSize = 12,
				AutoButtonColor = false,
				Parent = KeybindFrame
			})
			AddCorner(KeyBtn, Theme.CornerRadiusSmall)
			AddStroke(KeyBtn, Theme.Border, 1, 0.5)

			KeyBtn.MouseButton1Click:Connect(function()
				listening = true
				KeyBtn.Text = "..."
				Tween(KeyBtn, {BackgroundColor3 = Theme.Accent}, 0.15)
				KeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			end)

			UserInputService.InputBegan:Connect(function(input, processed)
				if listening and input.UserInputType == Enum.UserInputType.Keyboard then
					listening = false
					currentKey = input.KeyCode
					KeyBtn.Text = currentKey.Name
					Tween(KeyBtn, {BackgroundColor3 = Theme.SurfaceActive}, 0.15)
					KeyBtn.TextColor3 = Theme.Accent
					if options.Callback then options.Callback(currentKey) end
				end
			end)

			KeybindFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(KeybindFrame, {BackgroundColor3 = Theme.SurfaceHover}, 0.15) end
			end)
			KeybindFrame.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(KeybindFrame, {BackgroundColor3 = Theme.Surface}, 0.15) end
			end)

			local KeybindAPI = {}
			function KeybindAPI:Set(key) currentKey = key; KeyBtn.Text = key.Name end
			function KeybindAPI:Get() return currentKey end
			return KeybindAPI
		end

		function Tab:CreateColorPicker(options)
			options = options or {}
			local currentColor = options.Default or Color3.fromRGB(255, 255, 255)

			local ColorFrame = CreateInstance("Frame", {
				Name = "ColorPicker_" .. (options.Name or ""),
				BackgroundColor3 = Theme.Surface,
				Size = UDim2.new(1, 0, 0, 42),
				LayoutOrder = (#TabPage:GetChildren()),
				Parent = TabPage
			})
			AddCorner(ColorFrame, Theme.CornerRadiusSmall)

			CreateInstance("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.6, 0, 1, 0),
				Position = UDim2.new(0, 14, 0, 0),
				Font = Theme.FontBody,
				Text = options.Name or "Color",
				TextColor3 = Theme.TextPrimary,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = ColorFrame
			})

			local ColorPreview = CreateInstance("Frame", {
				BackgroundColor3 = currentColor,
				Size = UDim2.new(0, 28, 0, 28),
				Position = UDim2.new(1, -42, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Parent = ColorFrame
			})
			AddCorner(ColorPreview, UDim.new(0, 6))
			AddStroke(ColorPreview, Theme.Border, 1)

			ColorFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(ColorFrame, {BackgroundColor3 = Theme.SurfaceHover}, 0.15) end
			end)
			ColorFrame.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(ColorFrame, {BackgroundColor3 = Theme.Surface}, 0.15) end
			end)

			local ColorAPI = {}
			function ColorAPI:Set(color)
				currentColor = color
				ColorPreview.BackgroundColor3 = color
				if options.Callback then options.Callback(color) end
			end
			function ColorAPI:Get() return currentColor end
			return ColorAPI
		end

		return Tab
	end

	function Window:SaveConfig(name)
		local configData = {}
		for key, value in pairs(WindowState.Configs) do configData[key] = value end
		Notify({Title = "Config Saved", Content = "Configuration '" .. (name or WindowConfig.ConfigName) .. "' saved successfully.", Type = "Success", Duration = 3})
		return configData
	end

	function Window:LoadConfig(name, data)
		if data and type(data) == "table" then
			for key, value in pairs(data) do WindowState.Configs[key] = value end
			Notify({Title = "Config Loaded", Content = "Configuration '" .. (name or "External") .. "' loaded.", Type = "Info", Duration = 3})
		end
	end

	function Window:SetConfigValue(key, value) WindowState.Configs[key] = value end
	function Window:GetConfigValue(key) return WindowState.Configs[key] end

	function Window:Destroy()
		Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		task.delay(0.5, function() ScreenGui:Destroy() end)
	end

	if WindowConfig.TutorialMode then
		task.spawn(function()
			task.wait(0.8)

			local TutorialPages = {
				{
					Title = "Welcome to Premium Library",
					Lines = {
						"Thank you for using Premium Library v2.0!",
						"",
						"This tutorial will walk you through",
						"how to create your own UI with this library.",
						"",
						"You can disable this tutorial by setting:",
					},
					Code = 'TutorialMode = false',
				},
				{
					Title = "Step 1 - Create a Window",
					Lines = {
						"First, load the module and create a window.",
						"The window is the main container for your UI.",
					},
					Code = 'local Lib = loadstring(game:HttpGet("URL"))()\\n\\nlocal Window = Lib:CreateWindow({\\n    Title        = "My Script Hub",\\n    Subtitle     = "v1.0",\\n    AccentColor  = Color3.fromRGB(99, 102, 241),\\n    KeyBind      = Enum.KeyCode.RightShift,\\n    TutorialMode = true,\\n})',
				},
				{
					Title = "Step 2 - Create Tabs",
					Lines = {
						"Tabs appear in the sidebar on the left.",
						"Each tab has its own content page.",
					},
					Code = 'local MainTab = Window:CreateTab({\\n    Name = "Main",\\n    Icon = "",\\n})\\n\\nlocal SettingsTab = Window:CreateTab({\\n    Name = "Settings",\\n    Icon = "",\\n})',
				},
				{
					Title = "Step 3 - Sections and Elements",
					Lines = {
						"Use CreateSection() to group elements.",
						"Then add interactive elements inside each tab.",
					},
					Code = 'MainTab:CreateSection("Combat")\\n\\nMainTab:CreateToggle({\\n    Name        = "Auto Farm",\\n    Description = "Farm automatically",\\n    Default     = false,\\n    Callback    = function(value)\\n        print("Toggle:", value)\\n    end\\n})',
				},
				{
					Title = "Step 4 - More Elements",
					Lines = {
						"Available element types you can add to any tab:",
					},
					Code = 'Tab:CreateSlider({\\n    Name = "Speed", Min = 0, Max = 100,\\n    Default = 16, Increment = 1,\\n    Callback = function(v) end\\n})\\n\\nTab:CreateButton({\\n    Name = "Execute", ButtonText = "Run",\\n    Callback = function() end\\n})\\n\\nTab:CreateDropdown({\\n    Name = "Mode",\\n    Items = {"Option A", "Option B"},\\n    Callback = function(v) end\\n})\\n\\nTab:CreateInput({\\n    Name = "Target",\\n    Placeholder = "Enter name...",\\n    Callback = function(text, enter) end\\n})\\n\\nTab:CreateKeybind({\\n    Name = "Toggle Key",\\n    Default = Enum.KeyCode.E,\\n    Callback = function(key) end\\n})\\n\\nTab:CreateLabel({ Text = "Info line" })',
				},
				{
					Title = "Step 5 - Notifications and Config",
					Lines = {
						"Send notifications and manage saved configs.",
					},
					Code = 'Window:Notify({\\n    Title    = "Hello!",\\n    Content  = "This is a notification.",\\n    Type     = "Success",\\n    Duration = 4,\\n})\\n\\nWindow:SaveConfig("MyConfig")\\nWindow:LoadConfig("MyConfig", dataTable)\\n\\nWindow:SetConfigValue("speed", 50)\\nprint(Window:GetConfigValue("speed"))',
				},
				{
					Title = "Step 6 - Fire Remotes",
					Lines = {
						"How to add remote execution to your UI.",
						"Use FireServer to call server-side remotes.",
						"Use InvokeServer for functions that return data.",
					},
					Code = 'local RS = game:GetService("ReplicatedStorage")\\n\\nTab:CreateButton({\\n    Name = "Fire Remote Event",\\n    ButtonText = "Fire",\\n    Callback = function()\\n        local remote = RS:FindFirstChild("MyRemoteEvent")\\n        if remote then\\n            remote:FireServer("arg1", 123, true)\\n            Window:Notify({\\n                Title = "Remote Fired",\\n                Content = "MyRemoteEvent sent to server.",\\n                Type = "Success",\\n            })\\n        end\\n    end\\n})\\n\\nTab:CreateInput({\\n    Name = "Remote Name",\\n    Placeholder = "RemoteEvent name...",\\n    Callback = function(text, enter)\\n        if enter then\\n            local remote = RS:FindFirstChild(text)\\n            if remote and remote:IsA("RemoteEvent") then\\n                remote:FireServer()\\n            end\\n        end\\n    end\\n})\\n\\nTab:CreateButton({\\n    Name = "Invoke Remote Function",\\n    ButtonText = "Invoke",\\n    Callback = function()\\n        local rf = RS:FindFirstChild("MyRemoteFunction")\\n        if rf then\\n            local result = rf:InvokeServer("getData")\\n            print("Server returned:", result)\\n        end\\n    end\\n})',
				},
				{
					Title = "You Are All Set!",
					Lines = {
						"You now know everything to build your UI.",
						"",
						"Quick tips:",
						"  Press RightShift (default) to toggle UI",
						"  Drag the title bar to move the window",
						"  Use  -  +  X  buttons to min / max / close",
						"",
						"To disable this tutorial, add to your config:",
					},
					Code = 'TutorialMode = false',
				},
			}

			local currentPage = 1

			local TutorialOverlay = CreateInstance("Frame", {
				Name = "TutorialOverlay",
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.45,
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 50,
				Parent = ScreenGui
			})

			local TutorialCard = CreateInstance("Frame", {
				Name = "TutorialCard",
				BackgroundColor3 = Theme.Background,
				Size = UDim2.new(0, 500, 0, 440),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ClipsDescendants = true,
				ZIndex = 51,
				Parent = ScreenGui
			})
			AddCorner(TutorialCard, Theme.CornerRadiusLarge)
			AddStroke(TutorialCard, Theme.Accent, 1, 0.3)
			AddShadow(TutorialCard)

			TutorialCard.Size = UDim2.new(0, 0, 0, 0)
			TutorialCard.BackgroundTransparency = 1
			TutorialOverlay.BackgroundTransparency = 1
			Tween(TutorialOverlay, {BackgroundTransparency = 0.45}, 0.4)
			Tween(TutorialCard, {Size = UDim2.new(0, 500, 0, 440), BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Back)

			CreateInstance("Frame", {
				BackgroundColor3 = Theme.Accent,
				Size = UDim2.new(1, 0, 0, 3),
				BorderSizePixel = 0,
				ZIndex = 52,
				Parent = TutorialCard
			})

			local TutHeader = CreateInstance("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 50),
				Position = UDim2.new(0, 0, 0, 6),
				ZIndex = 52,
				Parent = TutorialCard
			})

			local TutTitleLabel = CreateInstance("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -60, 0, 26),
				Position = UDim2.new(0, 18, 0, 8),
				Font = Theme.FontMain,
				Text = "Welcome to Premium Library",
				TextColor3 = Theme.TextPrimary,
				TextSize = 17,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 52,
				Parent = TutHeader
			})

			local TutPageIndicator = CreateInstance("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -60, 0, 16),
				Position = UDim2.new(0, 18, 0, 34),
				Font = Theme.FontBody,
				Text = "Step 1 of " .. #TutorialPages,
				TextColor3 = Theme.TextMuted,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 52,
				Parent = TutHeader
			})

			local TutCloseBtn = CreateInstance("TextButton", {
				Name = "TutClose",
				BackgroundColor3 = Theme.Surface,
				Size = UDim2.new(0, 30, 0, 30),
				Position = UDim2.new(1, -42, 0, 12),
				Font = Theme.FontMain,
				Text = "X",
				TextColor3 = Theme.TextSecondary,
				TextSize = 14,
				AutoButtonColor = false,
				ZIndex = 53,
				Parent = TutHeader
			})
			AddCorner(TutCloseBtn, UDim.new(0, 6))

			TutCloseBtn.MouseEnter:Connect(function()
				Tween(TutCloseBtn, {BackgroundColor3 = Theme.Error, TextColor3 = Color3.fromRGB(255,255,255)}, 0.15)
			end)
			TutCloseBtn.MouseLeave:Connect(function()
				Tween(TutCloseBtn, {BackgroundColor3 = Theme.Surface, TextColor3 = Theme.TextSecondary}, 0.15)
			end)

			CreateInstance("Frame", {
				BackgroundColor3 = Theme.Divider,
				Size = UDim2.new(1, -32, 0, 1),
				Position = UDim2.new(0, 16, 0, 58),
				BorderSizePixel = 0,
				ZIndex = 52,
				Parent = TutorialCard
			})

			local TutBody = CreateInstance("ScrollingFrame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -32, 1, -120),
				Position = UDim2.new(0, 16, 0, 64),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = Theme.ScrollBar,
				BorderSizePixel = 0,
				ZIndex = 52,
				Parent = TutorialCard
			})

			CreateInstance("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
				Parent = TutBody
			})

			local ProgressBarBg = CreateInstance("Frame", {
				BackgroundColor3 = Theme.SurfaceActive,
				Size = UDim2.new(1, -32, 0, 4),
				Position = UDim2.new(0, 16, 1, -52),
				BorderSizePixel = 0,
				ZIndex = 52,
				Parent = TutorialCard
			})
			AddCorner(ProgressBarBg, UDim.new(1, 0))

			local ProgressBarFill = CreateInstance("Frame", {
				BackgroundColor3 = Theme.Accent,
				Size = UDim2.new(1 / #TutorialPages, 0, 1, 0),
				BorderSizePixel = 0,
				ZIndex = 53,
				Parent = ProgressBarBg
			})
			AddCorner(ProgressBarFill, UDim.new(1, 0))

			local TutFooter = CreateInstance("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -32, 0, 36),
				Position = UDim2.new(0, 16, 1, -44),
				ZIndex = 52,
				Parent = TutorialCard
			})

			local BackBtn = CreateInstance("TextButton", {
				BackgroundColor3 = Theme.Surface,
				Size = UDim2.new(0, 80, 0, 34),
				Position = UDim2.new(0, 0, 0, 0),
				Font = Theme.FontBody,
				Text = "< Back",
				TextColor3 = Theme.TextSecondary,
				TextSize = 12,
				AutoButtonColor = false,
				Visible = false,
				ZIndex = 53,
				Parent = TutFooter
			})
			AddCorner(BackBtn, Theme.CornerRadiusSmall)

			BackBtn.MouseEnter:Connect(function() Tween(BackBtn, {BackgroundColor3 = Theme.SurfaceHover}, 0.15) end)
			BackBtn.MouseLeave:Connect(function() Tween(BackBtn, {BackgroundColor3 = Theme.Surface}, 0.15) end)

			local NextBtn = CreateInstance("TextButton", {
				BackgroundColor3 = Theme.Accent,
				Size = UDim2.new(0, 80, 0, 34),
				Position = UDim2.new(1, -80, 0, 0),
				Font = Theme.FontMain,
				Text = "Next >",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 13,
				AutoButtonColor = false,
				ZIndex = 53,
				Parent = TutFooter
			})
			AddCorner(NextBtn, Theme.CornerRadiusSmall)

			NextBtn.MouseEnter:Connect(function() Tween(NextBtn, {BackgroundColor3 = Theme.AccentHover}, 0.15) end)
			NextBtn.MouseLeave:Connect(function() Tween(NextBtn, {BackgroundColor3 = Theme.Accent}, 0.15) end)

			local dots = {}
			local DotsFrame = CreateInstance("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, #TutorialPages * 16, 0, 10),
				Position = UDim2.new(0.5, 0, 1, -56),
				AnchorPoint = Vector2.new(0.5, 0),
				ZIndex = 52,
				Parent = TutorialCard
			})
			CreateInstance("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 6),
				Parent = DotsFrame
			})
			for i = 1, #TutorialPages do
				local dot = CreateInstance("Frame", {
					BackgroundColor3 = (i == 1) and Theme.Accent or Theme.SurfaceActive,
					Size = (i == 1) and UDim2.new(0, 18, 0, 6) or UDim2.new(0, 6, 0, 6),
					ZIndex = 53,
					Parent = DotsFrame
				})
				AddCorner(dot, UDim.new(1, 0))
				table.insert(dots, dot)
			end

			local lastCodeContent = ""

			local function RenderPage(pageIndex)
				local page = TutorialPages[pageIndex]
				if not page then return end

				TutTitleLabel.Text = page.Title or "Tutorial"
				TutPageIndicator.Text = "Step " .. pageIndex .. " of " .. #TutorialPages

				Tween(ProgressBarFill, {Size = UDim2.new(pageIndex / #TutorialPages, 0, 1, 0)}, 0.3)

				for i, dot in ipairs(dots) do
					if i == pageIndex then
						Tween(dot, {BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 18, 0, 6)}, 0.25)
					else
						Tween(dot, {BackgroundColor3 = Theme.SurfaceActive, Size = UDim2.new(0, 6, 0, 6)}, 0.25)
					end
				end

				BackBtn.Visible = (pageIndex > 1)
				if pageIndex == #TutorialPages then
					NextBtn.Text = "Finish"
					Tween(NextBtn, {BackgroundColor3 = Theme.Success}, 0.2)
				else
					NextBtn.Text = "Next >"
					Tween(NextBtn, {BackgroundColor3 = Theme.Accent}, 0.2)
				end

				for _, child in ipairs(TutBody:GetChildren()) do
					if not child:IsA("UIListLayout") then child:Destroy() end
				end

				for idx, line in ipairs(page.Lines) do
					if line == "" then
						CreateInstance("Frame", {
							BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 6),
							LayoutOrder = idx, ZIndex = 52, Parent = TutBody
						})
					else
						CreateInstance("TextLabel", {
							BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16),
							Font = Theme.FontBody, Text = line, TextColor3 = Theme.TextSecondary,
							TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
							TextWrapped = true, LayoutOrder = idx, ZIndex = 52, Parent = TutBody
						})
					end
				end

				if page.Code then
					lastCodeContent = page.Code:gsub("\\n", "\n")

					CreateInstance("Frame", {
						BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 4),
						LayoutOrder = 100, ZIndex = 52, Parent = TutBody
					})

					local codeLines = string.split(page.Code, "\\n")
					local codeHeight = math.max(#codeLines * 16 + 16, 40)

					local CodeContainer = CreateInstance("Frame", {
						BackgroundColor3 = Color3.fromRGB(12, 12, 18),
						Size = UDim2.new(1, 0, 0, codeHeight + 28),
						ClipsDescendants = true,
						LayoutOrder = 101, ZIndex = 52, Parent = TutBody
					})
					AddCorner(CodeContainer, Theme.CornerRadius)
					AddStroke(CodeContainer, Theme.Border, 1, 0.6)

					local CodeHeader = CreateInstance("Frame", {
						BackgroundColor3 = Color3.fromRGB(18, 18, 28),
						Size = UDim2.new(1, 0, 0, 26),
						BorderSizePixel = 0, ZIndex = 53, Parent = CodeContainer
					})

					for d = 0, 2 do
						local dotColor = ({Color3.fromRGB(255, 95, 87), Color3.fromRGB(255, 189, 46), Color3.fromRGB(39, 201, 63)})[d + 1]
						local codeDot = CreateInstance("Frame", {
							BackgroundColor3 = dotColor,
							Size = UDim2.new(0, 8, 0, 8),
							Position = UDim2.new(0, 10 + d * 16, 0.5, 0),
							AnchorPoint = Vector2.new(0, 0.5),
							ZIndex = 54, Parent = CodeHeader
						})
						AddCorner(codeDot, UDim.new(1, 0))
					end

					CreateInstance("TextLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(0.4, 0, 1, 0),
						Position = UDim2.new(0, 65, 0, 0),
						Font = Theme.FontMono, Text = "example.lua",
						TextColor3 = Theme.TextMuted, TextSize = 10,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 54, Parent = CodeHeader
					})

					local CopyBtn = CreateInstance("TextButton", {
						BackgroundColor3 = Theme.SurfaceActive,
						Size = UDim2.new(0, 50, 0, 18),
						Position = UDim2.new(1, -58, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						Font = Theme.FontBody, Text = "Copy",
						TextColor3 = Theme.TextSecondary, TextSize = 10,
						AutoButtonColor = false, ZIndex = 54, Parent = CodeHeader
					})
					AddCorner(CopyBtn, UDim.new(0, 4))

					CopyBtn.MouseEnter:Connect(function() Tween(CopyBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(255,255,255)}, 0.15) end)
					CopyBtn.MouseLeave:Connect(function() Tween(CopyBtn, {BackgroundColor3 = Theme.SurfaceActive, TextColor3 = Theme.TextSecondary}, 0.15) end)
					CopyBtn.MouseButton1Click:Connect(function()
						local copyText = lastCodeContent
						pcall(function()
							if setclipboard then
								setclipboard(copyText)
							elseif toclipboard then
								toclipboard(copyText)
							end
						end)
						CopyBtn.Text = "Done!"
						Tween(CopyBtn, {BackgroundColor3 = Theme.Success}, 0.15)
						task.delay(1.5, function()
							CopyBtn.Text = "Copy"
							Tween(CopyBtn, {BackgroundColor3 = Theme.SurfaceActive}, 0.15)
						end)
					end)

					CreateInstance("Frame", {
						BackgroundColor3 = Theme.Divider,
						Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0),
						BorderSizePixel = 0, ZIndex = 54, Parent = CodeHeader
					})

					local formattedCode = ""
					for i, codeLine in ipairs(codeLines) do
						formattedCode = formattedCode .. string.format("%2d", i) .. "  " .. codeLine
						if i < #codeLines then formattedCode = formattedCode .. "\n" end
					end

					CreateInstance("TextLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -20, 1, -32),
						Position = UDim2.new(0, 10, 0, 30),
						Font = Theme.FontMono, Text = formattedCode,
						TextColor3 = Color3.fromRGB(180, 210, 255),
						TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true,
						ZIndex = 53, Parent = CodeContainer
					})
				end
			end

			local function CloseTutorial()
				Tween(TutorialCard, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
				Tween(TutorialOverlay, {BackgroundTransparency = 1}, 0.35)
				task.delay(0.4, function()
					TutorialOverlay:Destroy()
					TutorialCard:Destroy()
				end)
				Notify({Title = "Tutorial Complete", Content = "Set TutorialMode = false in config to hide this next time.", Type = "Info", Duration = 5})
			end

			TutCloseBtn.MouseButton1Click:Connect(function() CloseTutorial() end)

			NextBtn.MouseButton1Click:Connect(function()
				RippleEffect(NextBtn)
				if currentPage >= #TutorialPages then
					CloseTutorial()
				else
					currentPage = currentPage + 1
					RenderPage(currentPage)
				end
			end)

			BackBtn.MouseButton1Click:Connect(function()
				RippleEffect(BackBtn)
				if currentPage > 1 then
					currentPage = currentPage - 1
					RenderPage(currentPage)
				end
			end)

			RenderPage(1)
		end)
	end

	return Window
end

return PremiumLib
