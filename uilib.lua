-- Vxizi UI Library
-- Standalone Roblox Lua UI library.
-- Usage:
-- local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/user/repo/main/uilib.lua"))()
-- local window = UI:CreateWindow({ Title = "Vxizi", Icon = "rbxassetid://0" })

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player and player:WaitForChild("PlayerGui")

local DarkUI = {}
DarkUI.__index = DarkUI
DarkUI.Version = "1.1.0"

local function getFont(fontName, fallback)
	local ok, font = pcall(function()
		return Enum.Font[fontName]
	end)

	return ok and font or fallback
end

DarkUI.Fonts = {
	Title = getFont("BuilderSansBold", getFont("GothamBold", Enum.Font.SourceSansBold)),
	Bold = getFont("BuilderSansMedium", getFont("GothamSemibold", getFont("GothamBold", Enum.Font.SourceSansBold))),
	Body = getFont("BuilderSans", getFont("Gotham", Enum.Font.SourceSans)),
}
DarkUI.TextScale = 1
DarkUI.TextStrokeColor = Color3.fromRGB(27, 30, 35)
DarkUI.TextStrokeTransparency = 1

DarkUI.ThemePresets = {
	Dark = {
		Background = Color3.fromRGB(25, 25, 26),
		Surface = Color3.fromRGB(32, 32, 33),
		Panel = Color3.fromRGB(28, 28, 29),
		PanelLight = Color3.fromRGB(36, 36, 38),
		Tab = Color3.fromRGB(26, 26, 27),
		TabActive = Color3.fromRGB(30, 43, 37),
		Stroke = Color3.fromRGB(66, 67, 71),
		Text = Color3.fromRGB(234, 236, 239),
		Muted = Color3.fromRGB(141, 146, 154),
		Accent = Color3.fromRGB(21, 233, 137),
		Success = Color3.fromRGB(56, 219, 142),
		Warning = Color3.fromRGB(250, 204, 21),
		Error = Color3.fromRGB(248, 93, 106),
	},
	Midnight = {
		Background = Color3.fromRGB(6, 8, 16),
		Surface = Color3.fromRGB(11, 15, 27),
		Panel = Color3.fromRGB(16, 22, 36),
		PanelLight = Color3.fromRGB(24, 32, 50),
		Tab = Color3.fromRGB(10, 13, 24),
		TabActive = Color3.fromRGB(17, 25, 42),
		Stroke = Color3.fromRGB(34, 44, 66),
		Text = Color3.fromRGB(235, 240, 248),
		Muted = Color3.fromRGB(135, 147, 166),
		Accent = Color3.fromRGB(96, 165, 250),
		Success = Color3.fromRGB(52, 211, 153),
		Warning = Color3.fromRGB(251, 191, 36),
		Error = Color3.fromRGB(251, 113, 133),
	},
	Emerald = {
		Background = Color3.fromRGB(7, 12, 11),
		Surface = Color3.fromRGB(12, 19, 18),
		Panel = Color3.fromRGB(17, 26, 25),
		PanelLight = Color3.fromRGB(24, 38, 36),
		Tab = Color3.fromRGB(10, 16, 15),
		TabActive = Color3.fromRGB(18, 31, 29),
		Stroke = Color3.fromRGB(35, 57, 52),
		Text = Color3.fromRGB(232, 241, 237),
		Muted = Color3.fromRGB(129, 154, 146),
		Accent = Color3.fromRGB(52, 211, 153),
		Success = Color3.fromRGB(74, 222, 128),
		Warning = Color3.fromRGB(250, 204, 21),
		Error = Color3.fromRGB(248, 113, 113),
	},
	Crimson = {
		Background = Color3.fromRGB(13, 8, 10),
		Surface = Color3.fromRGB(20, 13, 16),
		Panel = Color3.fromRGB(29, 18, 23),
		PanelLight = Color3.fromRGB(41, 25, 31),
		Tab = Color3.fromRGB(16, 10, 13),
		TabActive = Color3.fromRGB(34, 19, 25),
		Stroke = Color3.fromRGB(60, 35, 44),
		Text = Color3.fromRGB(245, 235, 239),
		Muted = Color3.fromRGB(164, 132, 143),
		Accent = Color3.fromRGB(248, 93, 106),
		Success = Color3.fromRGB(74, 222, 128),
		Warning = Color3.fromRGB(250, 204, 21),
		Error = Color3.fromRGB(248, 113, 113),
	},
	Violet = {
		Background = Color3.fromRGB(11, 9, 17),
		Surface = Color3.fromRGB(17, 14, 25),
		Panel = Color3.fromRGB(24, 20, 36),
		PanelLight = Color3.fromRGB(34, 28, 50),
		Tab = Color3.fromRGB(14, 12, 22),
		TabActive = Color3.fromRGB(29, 24, 44),
		Stroke = Color3.fromRGB(51, 43, 73),
		Text = Color3.fromRGB(240, 236, 248),
		Muted = Color3.fromRGB(148, 136, 166),
		Accent = Color3.fromRGB(168, 85, 247),
		Success = Color3.fromRGB(74, 222, 128),
		Warning = Color3.fromRGB(250, 204, 21),
		Error = Color3.fromRGB(248, 113, 113),
	},
}

DarkUI.Theme = DarkUI.ThemePresets.Dark

local function copyTable(source)
	local nextTable = {}

	for key, value in pairs(source or {}) do
		nextTable[key] = value
	end

	return nextTable
end

local function make(className, props, children)
	local instance = Instance.new(className)

	for key, value in pairs(props or {}) do
		instance[key] = value
	end

	for _, child in ipairs(children or {}) do
		child.Parent = instance
	end

	return instance
end

local function corner(radius)
	return make("UICorner", {
		CornerRadius = UDim.new(0, radius),
	})
end

local function stroke(color, transparency, thickness)
	return make("UIStroke", {
		Color = color,
		Transparency = transparency or 0,
		Thickness = thickness or 1,
	})
end

local function tween(instance, props, duration)
	local tweenInfo = TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local activeTween = TweenService:Create(instance, tweenInfo, props)
	activeTween:Play()
	return activeTween
end

local function safe(callback, ...)
	if not callback then
		return
	end

	local args = { ... }
	task.spawn(function()
		pcall(function()
			callback(table.unpack(args))
		end)
	end)
end

local function normalizeColor(value, fallback)
	if typeof(value) == "Color3" then
		return value
	end

	if type(value) == "table" then
		if value.R and value.G and value.B then
			return Color3.fromRGB(value.R, value.G, value.B)
		end

		if value[1] and value[2] and value[3] then
			return Color3.fromRGB(value[1], value[2], value[3])
		end
	end

	return fallback
end

local function colorToTable(color)
	return {
		R = math.floor(color.R * 255 + 0.5),
		G = math.floor(color.G * 255 + 0.5),
		B = math.floor(color.B * 255 + 0.5),
	}
end

function DarkUI:Text(props)
	props = props or {}

	return make("TextLabel", {
		BackgroundTransparency = 1,
		Font = props.Font or self.Fonts.Body,
		LayoutOrder = props.LayoutOrder or 0,
		Position = props.Position or UDim2.new(),
		RichText = props.RichText or false,
		Size = props.Size or UDim2.new(1, 0, 1, 0),
		Text = props.Text or "",
		TextColor3 = props.TextColor3 or self.Theme.Text,
		TextSize = props.TextSize or 12,
		TextStrokeColor3 = props.TextStrokeColor3 or self.TextStrokeColor,
		TextStrokeTransparency = props.TextStrokeTransparency or self.TextStrokeTransparency,
		TextTransparency = props.TextTransparency or 0,
		TextWrapped = props.TextWrapped or false,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
		Parent = props.Parent,
	})
end

function DarkUI:CreateWindow(config)
	config = config or {}

	local themeName = config.Theme or "Dark"
	local theme = copyTable(DarkUI.ThemePresets[themeName] or DarkUI.ThemePresets.Dark)
	if typeof(config.Accent) == "Color3" then
		theme.Accent = config.Accent
	end

	local guiName = config.Name or "VxiziUILibrary"
	local parent = config.Parent or playerGui

	if config.RemoveOld ~= false and parent then
		local oldGui = parent:FindFirstChild(guiName)
		if oldGui then
			oldGui:Destroy()
		end
	end

	local window = {
		Theme = theme,
		ThemeName = themeName,
		TextScale = config.TextScale or DarkUI.TextScale,
		ConfigFolder = config.ConfigFolder or "VxiziUI",
		ConfigName = config.ConfigName or "default.json",
		ConfigValues = {},
		Connections = {},
		Renderers = {},
		Pages = {},
		TabButtons = {},
		TabOrder = {},
		SearchItems = {},
		Sections = {},
		SelectedTab = nil,
		FooterButtons = {},
		FooterRole = "Home",
		FooterHomeTab = nil,
		FooterSettingsTab = nil,
		Destroyed = false,
	}

	local screenGui = make("ScreenGui", {
		Name = guiName,
		DisplayOrder = config.DisplayOrder or 100,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		Parent = parent,
	})

	local function connect(signal, callback)
		local connection = signal:Connect(callback)
		table.insert(window.Connections, connection)
		return connection
	end

	function window:Connect(signal, callback)
		return connect(signal, callback)
	end

	local function styledBackground(instance, key)
		instance:SetAttribute("DarkUIBackground", key)
		instance.BackgroundColor3 = window.Theme[key]
		return instance
	end

	local function styledText(instance, key)
		instance:SetAttribute("DarkUIText", key)
		instance.TextColor3 = window.Theme[key]

		if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
			if not instance:GetAttribute("DarkUITextScaled") then
				instance.TextSize = math.floor((instance.TextSize * window.TextScale) + 0.5)
				instance:SetAttribute("DarkUITextScaled", true)
			end

			instance.TextStrokeColor3 = DarkUI.TextStrokeColor
			instance.TextStrokeTransparency = 1
		end

		return instance
	end

	local function styledStroke(instance, key)
		instance:SetAttribute("DarkUIStroke", key)
		instance.Color = window.Theme[key]
		return instance
	end

	local function registerRenderer(callback)
		table.insert(window.Renderers, callback)
		callback()
	end

	local function getScale(guiObject)
		local scale = guiObject:FindFirstChild("DarkUIScale")
		if not scale then
			scale = make("UIScale", {
				Name = "DarkUIScale",
				Scale = 1,
				Parent = guiObject,
			})
		end

		return scale
	end

	local function pop(guiObject, pressedScale, returnScale)
		local scale = getScale(guiObject)
		tween(scale, {
			Scale = pressedScale or 0.96,
		}, 0.06)
		task.delay(0.07, function()
			if scale.Parent then
				tween(scale, {
					Scale = returnScale or 1,
				}, 0.13)
			end
		end)
	end

	local function attachPress(guiObject, pressedScale)
		connect(guiObject.InputBegan, function(input)
			if guiObject:GetAttribute("Disabled") then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				pop(guiObject, pressedScale)
			end
		end)
	end

	local function attachHover(guiObject, normalKey, hoverKey, hoverScale)
		connect(guiObject.MouseEnter, function()
			if guiObject:GetAttribute("Disabled") then
				return
			end

			if normalKey and hoverKey then
				tween(guiObject, {
					BackgroundColor3 = window.Theme[hoverKey],
				}, 0.12)
			end

			if hoverScale then
				tween(getScale(guiObject), {
					Scale = hoverScale,
				}, 0.12)
			end
		end)

		connect(guiObject.MouseLeave, function()
			if normalKey then
				tween(guiObject, {
					BackgroundColor3 = window.Theme[normalKey],
				}, 0.12)
			end

			if hoverScale then
				tween(getScale(guiObject), {
					Scale = 1,
				}, 0.12)
			end
		end)
	end

	local headerHeight = 46
	local tabHeight = 52
	local searchHeight = config.Search == false and 0 or 44
	local footerHeight = config.Footer == false and 0 or 56
	local navWidth = config.NavWidth or 210
	local windowSize = config.Size or UDim2.fromOffset(820, 510)
	local collapsedSize = UDim2.fromOffset(windowSize.X.Offset, headerHeight)
	local windowPosition = config.Position or UDim2.fromScale(0.5, 0.5)
	local minWindowSize = config.MinSize or Vector2.new(560, 360)
	local resizable = config.Resizable ~= false
	local gripSize = math.max(30, tonumber(config.ResizeGripSize) or 44)

	local function glowSize(size)
		return UDim2.new(size.X.Scale, size.X.Offset + 12, size.Y.Scale, size.Y.Offset + 12)
	end

	local shadow = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.68,
		BorderSizePixel = 0,
		Position = UDim2.new(windowPosition.X.Scale, windowPosition.X.Offset + 6, windowPosition.Y.Scale, windowPosition.Y.Offset + 6),
		Size = windowSize,
		Parent = screenGui,
	}, {
		corner(11),
	})

	local glowStroke = stroke(theme.Accent, 0.72, 1)
	glowStroke.Name = "DarkUIGlowStroke"
	local glow = make("Frame", {
		Name = "DarkUIGlow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = 0.965,
		BorderSizePixel = 0,
		Position = windowPosition,
		Size = glowSize(windowSize),
		Parent = screenGui,
	}, {
		corner(13),
		glowStroke,
	})

	local root = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = windowPosition,
		Size = windowSize,
		Parent = screenGui,
	}, {
		corner(10),
		stroke(theme.Stroke, 0.14, 1),
	})
	root:SetAttribute("DarkUIBackground", "Background")
	root.UIStroke:SetAttribute("DarkUIStroke", "Stroke")

	local rootScale = make("UIScale", {
		Scale = 0.96,
		Parent = root,
	})

	tween(rootScale, { Scale = 1 }, 0.25)

	local header = styledBackground(make("Frame", {
		Name = "Header",
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, headerHeight),
		ZIndex = 50,
		Parent = root,
	}, {
		corner(10),
	}), "Surface")

	styledBackground(make("Frame", {
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -9),
		Size = UDim2.new(1, 0, 0, 9),
		ZIndex = 50,
		Parent = header,
	}), "Surface")

	make("Frame", {
		Name = "DarkUIAccent",
		BorderSizePixel = 0,
		BackgroundColor3 = theme.Accent,
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 51,
		Parent = header,
	})

	if config.Icon then
		make("ImageLabel", {
			BackgroundTransparency = 1,
			Image = config.Icon,
			Position = UDim2.fromOffset(16, 8),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromOffset(30, 30),
			ZIndex = 52,
			Parent = header,
		})
	end

	local titleOffset = config.Icon and 52 or 16
	local title = styledText(DarkUI:Text({
		Font = DarkUI.Fonts.Title,
		Parent = header,
		Position = UDim2.fromOffset(titleOffset, 2),
		RichText = true,
		Size = UDim2.new(1, -200 - titleOffset, 0, 23),
		Text = config.Title or "Vxizi Hub",
		TextSize = 20,
	}), "Text")
	title.ZIndex = 52

	local subtitle = styledText(DarkUI:Text({
		Font = DarkUI.Fonts.Body,
		Parent = header,
		Position = UDim2.fromOffset(titleOffset, 24),
		Size = UDim2.new(1, -200 - titleOffset, 0, 17),
		Text = config.Subtitle or "clean dark interface",
		TextSize = 12,
	}), "Muted")
	subtitle.ZIndex = 52

	local statusPill = styledBackground(make("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		BorderSizePixel = 0,
		Font = DarkUI.Fonts.Bold,
		Position = UDim2.new(1, -92, 0.5, 0),
		Size = UDim2.fromOffset(90, 28),
		Text = "WORKING",
		TextSize = 12,
		ZIndex = 52,
		Parent = header,
	}, {
		corner(7),
	}), "Panel")
	styledText(statusPill, "Accent")

	local minimizeButton = styledBackground(make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = DarkUI.Fonts.Bold,
		Position = UDim2.new(1, -50, 0.5, 0),
		Size = UDim2.fromOffset(30, 28),
		Text = "-",
		TextSize = 18,
		ZIndex = 52,
		Parent = header,
	}, {
		corner(8),
	}), "PanelLight")
	styledText(minimizeButton, "Text")
	attachHover(minimizeButton, "PanelLight", "Panel", 1.04)
	attachPress(minimizeButton, 0.88)

	local closeButton = styledBackground(make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = DarkUI.Fonts.Bold,
		Position = UDim2.new(1, -15, 0.5, 0),
		Size = UDim2.fromOffset(30, 28),
		Text = "x",
		TextSize = 15,
		ZIndex = 52,
		Parent = header,
	}, {
		corner(8),
	}), "PanelLight")
	styledText(closeButton, "Text")
	attachHover(closeButton, "PanelLight", "Panel", 1.04)
	attachPress(closeButton, 0.88)

	local body = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, headerHeight + 1),
		Size = UDim2.new(1, 0, 1, -(headerHeight + 1)),
		ZIndex = 1,
		Parent = root,
	})

	local resizeHandle = make("TextButton", {
		AnchorPoint = Vector2.new(1, 1),
		Active = true,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -2, 1, -2),
		Size = UDim2.fromOffset(gripSize, gripSize),
		Text = "",
		ZIndex = 220,
		Visible = resizable,
		Parent = root,
	})

	local gripVisual = make("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -2, 1, -2),
		Size = UDim2.fromOffset(26, 26),
		ZIndex = 221,
		Parent = resizeHandle,
	})

	for index = 0, 2 do
		styledBackground(make("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 0.26 + (index * 0.16),
			BorderSizePixel = 0,
			Position = UDim2.new(1, -3 - (index * 6), 1, -3),
			Rotation = -45,
			Size = UDim2.fromOffset(13 + (index * 5), 2),
			ZIndex = 222,
			Parent = gripVisual,
		}, {
			corner(999),
		}), "Accent")
	end

	local navPanel = styledBackground(make("Frame", {
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.new(0, navWidth, 1, -footerHeight),
		Parent = body,
	}, {
		corner(10),
	}), "Surface")

	local navBrandText = tostring(config.NavBrand or "")
	local hasNavBrand = navBrandText ~= ""
	local navHeaderHeight = hasNavBrand and 48 or 0
	local navHeader = make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, navHeaderHeight),
		Parent = navPanel,
	})

	local navHeaderOffset = 12
	if hasNavBrand and config.Icon then
		make("ImageLabel", {
			BackgroundTransparency = 1,
			Image = config.Icon,
			Position = UDim2.fromOffset(10, 9),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromOffset(24, 24),
			Parent = navHeader,
		})
		navHeaderOffset = 38
	end

	if hasNavBrand then
		styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Title,
			Parent = navHeader,
			Position = UDim2.fromOffset(navHeaderOffset, 9),
			Size = UDim2.new(1, -navHeaderOffset - 10, 0, 24),
			Text = navBrandText,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
		}), "Text")
	end

	if hasNavBrand then
		make("Frame", {
			Name = "DarkUIAccent",
			BorderSizePixel = 0,
			BackgroundColor3 = theme.Accent,
			Position = UDim2.fromOffset(0, navHeaderHeight),
			Size = UDim2.new(1, 0, 0, 1),
			Parent = navPanel,
		})
	end

	local navTabsTopOffset = hasNavBrand and 6 or 0
	local navTabsStartY = navHeaderHeight + navTabsTopOffset
	local tabs = make("ScrollingFrame", {
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarImageColor3 = theme.Accent,
		ScrollBarImageTransparency = 0.42,
		ScrollBarThickness = 2,
		Position = UDim2.fromOffset(0, navTabsStartY),
		Size = UDim2.new(1, 0, 1, -(navTabsStartY + 6)),
		Parent = navPanel,
	}, {
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		}),
		make("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
		}),
	})

	local contentPanel = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, navWidth + 8, 0, 8),
		Size = UDim2.new(1, -navWidth - 16, 1, -footerHeight - 8),
		Parent = body,
	})

	local searchBox
	local searchClear
	if config.Search ~= false then
		local searchStroke = styledStroke(stroke(theme.Stroke, 0.35, 1), "Stroke")
		local searchBar = styledBackground(make("Frame", {
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 0, 36),
			Parent = contentPanel,
		}, {
			corner(7),
			searchStroke,
		}), "Panel")

		styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Bold,
			Parent = searchBar,
			Position = UDim2.fromOffset(13, 0),
			Size = UDim2.fromOffset(54, 36),
			Text = "Search",
			TextSize = 13,
		}), "Muted")

		searchBox = make("TextBox", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClearTextOnFocus = false,
			Font = DarkUI.Fonts.Bold,
			PlaceholderColor3 = theme.Muted,
			PlaceholderText = "Find a module...",
			Position = UDim2.fromOffset(70, 0),
			Size = UDim2.new(1, -106, 1, 0),
			Text = "",
			TextColor3 = theme.Text,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = searchBar,
		})
		styledText(searchBox, "Text")

		searchClear = styledBackground(make("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Font = DarkUI.Fonts.Bold,
			Position = UDim2.new(1, -8, 0.5, 0),
			Size = UDim2.fromOffset(24, 24),
			Text = "x",
			TextSize = 12,
			Visible = false,
			Parent = searchBar,
		}, {
			corner(5),
		}), "Surface")
		styledText(searchClear, "Muted")
		attachHover(searchClear, "Surface", "PanelLight", 1.05)
		attachPress(searchClear, 0.86)

		connect(searchBox.Focused, function()
			tween(searchStroke, {
				Color = window.Theme.Accent,
				Transparency = 0.05,
			}, 0.12)
		end)

		connect(searchBox.FocusLost, function()
			tween(searchStroke, {
				Color = window.Theme.Stroke,
				Transparency = 0.35,
			}, 0.12)
		end)
	end

	local contentTopOffset = (config.Search ~= false) and (searchHeight + 6) or 0
	local pagesHolder = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, contentTopOffset),
		Size = UDim2.new(1, 0, 1, -contentTopOffset),
		Parent = contentPanel,
	})

	local footer = nil
	local footerButtons = {}
	local footerActiveRole = "Home"

	local function isSettingsTabName(tabName)
		local lowered = string.lower(tostring(tabName or ""))
		return string.find(lowered, "setting", 1, true) ~= nil
			or string.find(lowered, "config", 1, true) ~= nil
	end

	local function resolveHomeTabName()
		if window.FooterHomeTab and window.Pages[window.FooterHomeTab] then
			return window.FooterHomeTab
		end

		if config.HomeTabName and window.Pages[config.HomeTabName] then
			return config.HomeTabName
		end

		return window.TabOrder[1]
	end

	local function resolveSettingsTabName()
		if window.FooterSettingsTab and window.Pages[window.FooterSettingsTab] then
			return window.FooterSettingsTab
		end

		if config.SettingsTabName and window.Pages[config.SettingsTabName] then
			return config.SettingsTabName
		end

		for _, tabName in ipairs(window.TabOrder) do
			if isSettingsTabName(tabName) then
				return tabName
			end
		end

		return nil
	end

	local function footerRoleForTab(tabName)
		local settingsTabName = resolveSettingsTabName()
		if settingsTabName and tabName == settingsTabName then
			return "Setting"
		end

		return "Home"
	end

	local function setFooterActive(role, animated)
		footerActiveRole = role or "Home"
		window.FooterRole = footerActiveRole

		for buttonRole, refs in pairs(footerButtons) do
			local active = buttonRole == footerActiveRole
			local targetBackground = window.Theme[active and "Panel" or "Surface"]
			local targetIconColor = window.Theme[active and "Accent" or "Muted"]
			local targetTextColor = window.Theme[active and "Text" or "Muted"]
			local strokeObject = refs.Button:FindFirstChildOfClass("UIStroke")

			refs.Button:SetAttribute("DarkUIBackground", active and "Panel" or "Surface")
			refs.Label:SetAttribute("DarkUIText", active and "Text" or "Muted")
			refs.Icon:SetAttribute("DarkUIFooterIconState", active and "Active" or "Muted")
			refs.Button:SetAttribute("DarkUIFooterActive", active)

			if animated then
				tween(refs.Button, {
					BackgroundColor3 = targetBackground,
				}, 0.14)
				tween(refs.Icon, {
					ImageColor3 = targetIconColor,
				}, 0.14)
				tween(refs.Label, {
					TextColor3 = targetTextColor,
				}, 0.14)
				if strokeObject then
					tween(strokeObject, {
						Transparency = active and 0.16 or 0.4,
					}, 0.14)
				end
			else
				refs.Button.BackgroundColor3 = targetBackground
				refs.Icon.ImageColor3 = targetIconColor
				refs.Label.TextColor3 = targetTextColor
				if strokeObject then
					strokeObject.Transparency = active and 0.16 or 0.4
				end
			end
		end
	end

	if footerHeight > 0 then
		footer = styledBackground(make("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, footerHeight),
			Parent = body,
		}, {
			corner(10),
		}), "Surface")

		make("Frame", {
			Name = "DarkUIAccent",
			BorderSizePixel = 0,
			BackgroundColor3 = theme.Accent,
			Size = UDim2.new(1, 0, 0, 1),
			Parent = footer,
		})

		local footerCenter = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(220, 44),
			Parent = footer,
		}, {
			make("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 10),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		})

		local function createFooterButton(roleName, titleText, iconAssetId, active)
			local button = styledBackground(make("TextButton", {
				Name = "DarkUIFooterButton",
				AutoButtonColor = false,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(96, 38),
				Text = "",
				Parent = footerCenter,
			}, {
				corner(8),
				styledStroke(stroke(theme.Stroke, active and 0.16 or 0.4, 1), "Stroke"),
			}), active and "Panel" or "Surface")
			button:SetAttribute("DarkUIFooterRole", roleName)
			button:SetAttribute("DarkUIFooterActive", active)

			local footerIcon = make("ImageLabel", {
				Name = "DarkUIFooterIcon",
				BackgroundTransparency = 1,
				Image = "rbxassetid://" .. tostring(iconAssetId),
				ImageColor3 = active and theme.Accent or theme.Muted,
				Position = UDim2.new(0.5, -8, 0, 4),
				Size = UDim2.fromOffset(16, 16),
				Parent = button,
			})
			footerIcon:SetAttribute("DarkUIFooterIconState", active and "Active" or "Muted")

			local footerLabel = styledText(DarkUI:Text({
				Font = DarkUI.Fonts.Bold,
				Parent = button,
				Position = UDim2.fromOffset(0, 19),
				Size = UDim2.new(1, 0, 0, 17),
				Text = titleText,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Center,
			}), active and "Text" or "Muted")
			footerLabel.Name = "DarkUIFooterLabel"

			footerButtons[roleName] = {
				Button = button,
				Icon = footerIcon,
				Label = footerLabel,
			}
			window.FooterButtons[roleName] = button

			connect(button.MouseEnter, function()
				tween(getScale(button), {
					Scale = 1.02,
				}, 0.12)
				if not button:GetAttribute("DarkUIFooterActive") then
					tween(button, {
						BackgroundColor3 = window.Theme.Panel,
					}, 0.12)
				end
			end)

			connect(button.MouseLeave, function()
				tween(getScale(button), {
					Scale = 1,
				}, 0.12)
				if button:GetAttribute("DarkUIFooterActive") then
					tween(button, {
						BackgroundColor3 = window.Theme.Panel,
					}, 0.12)
				else
					tween(button, {
						BackgroundColor3 = window.Theme.Surface,
					}, 0.12)
				end
			end)

			attachPress(button, 0.92)
			connect(button.MouseButton1Click, function()
				if roleName == "Setting" then
					local settingsTabName = resolveSettingsTabName()
					if settingsTabName then
						window:SelectTab(settingsTabName)
					end
				else
					local homeTabName = resolveHomeTabName()
					if homeTabName then
						window:SelectTab(homeTabName)
					end
				end
			end)
		end

		createFooterButton("Home", "Home", "170940874", true)
		createFooterButton("Setting", "Setting", "17824369886", false)
		setFooterActive("Home", false)
	end

	local notifications = make("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -18, 1, -18),
		Size = UDim2.fromOffset(300, 240),
		Parent = screenGui,
	}, {
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}),
	})

	local tooltip = styledBackground(make("Frame", {
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(180, 30),
		Visible = false,
		ZIndex = 80,
		Parent = screenGui,
	}, {
		corner(6),
		styledStroke(stroke(theme.Stroke, 0.25, 1), "Stroke"),
	}), "Surface")

	local tooltipText = styledText(DarkUI:Text({
		Font = DarkUI.Fonts.Body,
		Parent = tooltip,
		Position = UDim2.fromOffset(9, 0),
		Size = UDim2.new(1, -18, 1, 0),
		TextSize = 12,
		TextWrapped = true,
	}), "Text")
	tooltipText.ZIndex = 81

	window.Gui = screenGui
	window.Root = root
	window.Shadow = shadow
	window.Glow = glow
	window.Header = header
	window.Body = body
	window.NavPanel = navPanel
	window.Footer = footer
	window.StatusPill = statusPill
	window.SearchBox = searchBox

	function window:_applyTheme()
		for _, descendant in ipairs(screenGui:GetDescendants()) do
			local backgroundKey = descendant:GetAttribute("DarkUIBackground")
			local textKey = descendant:GetAttribute("DarkUIText")
			local strokeKey = descendant:GetAttribute("DarkUIStroke")

			if backgroundKey and descendant:IsA("GuiObject") then
				descendant.BackgroundColor3 = self.Theme[backgroundKey]
			end

			if textKey and (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) then
				descendant.TextColor3 = self.Theme[textKey]
				descendant.TextStrokeColor3 = DarkUI.TextStrokeColor
				descendant.TextStrokeTransparency = 1
				if descendant:IsA("TextBox") then
					descendant.PlaceholderColor3 = self.Theme.Muted
				end
			end

			if strokeKey and descendant:IsA("UIStroke") then
				descendant.Color = self.Theme[strokeKey]
			end

			if descendant.Name == "DarkUIAccent" and descendant:IsA("Frame") and not backgroundKey then
				descendant.BackgroundColor3 = self.Theme.Accent
			elseif descendant.Name == "DarkUIAccentGradient" and descendant:IsA("UIGradient") then
				descendant.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 58, 58)),
					ColorSequenceKeypoint.new(0.5, self.Theme.Accent),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(58, 58, 58)),
				})
			elseif descendant.Name == "DarkUITabActiveGlow" and descendant:IsA("Frame") then
				descendant.BackgroundColor3 = self.Theme.Accent
			elseif descendant.Name == "DarkUIGlow" and descendant:IsA("Frame") then
				descendant.BackgroundColor3 = self.Theme.Accent
			elseif descendant.Name == "DarkUIGlowStroke" and descendant:IsA("UIStroke") then
				descendant.Color = self.Theme.Accent
			elseif descendant.Name == "DarkUIFooterIcon" and descendant:IsA("ImageLabel") then
				local mode = descendant:GetAttribute("DarkUIFooterIconState")
				descendant.ImageColor3 = mode == "Active" and self.Theme.Accent or self.Theme.Muted
			elseif descendant:IsA("ScrollingFrame") then
				descendant.ScrollBarImageColor3 = self.Theme.Accent
			end
		end

		for _, renderer in ipairs(self.Renderers) do
			renderer()
		end

		if self.SelectedTab then
			self:SelectTab(self.SelectedTab)
		end
	end

	function window:SetAccentColor(color)
		self.Theme.Accent = normalizeColor(color, self.Theme.Accent)
		self:_applyTheme()
	end

	function window:SetTheme(nameOrTheme)
		if type(nameOrTheme) == "string" and DarkUI.ThemePresets[nameOrTheme] then
			self.ThemeName = nameOrTheme
			self.Theme = copyTable(DarkUI.ThemePresets[nameOrTheme])
		elseif type(nameOrTheme) == "table" then
			for key, value in pairs(nameOrTheme) do
				self.Theme[key] = value
			end
		end

		self:_applyTheme()
	end

	function window:SetStatus(text, good)
		statusPill.Text = text or "READY"
		statusPill:SetAttribute("DarkUIText", good == false and "Error" or "Accent")
		statusPill.TextColor3 = good == false and self.Theme.Error or self.Theme.Accent
	end

	function window:AttachTooltip(guiObject, text)
		if not text or text == "" then
			return
		end

		local function move(x, y)
			tooltip.Position = UDim2.fromOffset(x + 12, y + 14)
		end

		connect(guiObject.MouseEnter, function(x, y)
			tooltipText.Text = text
			tooltip.Size = UDim2.fromOffset(math.clamp(#text * 6 + 24, 130, 260), 32)
			move(x, y)
			tooltip.Visible = true
		end)

		connect(guiObject.MouseMoved, move)
		connect(guiObject.MouseLeave, function()
			tooltip.Visible = false
		end)
	end

	local function getFileApi()
		return type(writefile) == "function"
			and type(readfile) == "function"
			and type(isfile) == "function"
	end

	local function configPath()
		return window.ConfigFolder .. "/" .. window.ConfigName
	end

	local function setConfigName(name)
		if name and name ~= "" then
			name = tostring(name)
			if not string.find(name, "%.json$") then
				name = name .. ".json"
			end
			window.ConfigName = name
		end
	end

	function window:RegisterConfig(flag, control)
		if flag then
			self.ConfigValues[flag] = control
		end
	end

	function window:GetConfig()
		local data = {}

		for flag, control in pairs(self.ConfigValues) do
			if type(control.Get) == "function" then
				data[flag] = control:Get()
			end
		end

		data.__theme = self.ThemeName
		data.__accent = colorToTable(self.Theme.Accent)
		return data
	end

	function window:ApplyConfig(data)
		if type(data) ~= "table" then
			return false
		end

		if data.__theme then
			self:SetTheme(data.__theme)
		end

		if data.__accent then
			self:SetAccentColor(normalizeColor(data.__accent, self.Theme.Accent))
		end

		for flag, value in pairs(data) do
			local control = self.ConfigValues[flag]
			if control and type(control.Set) == "function" then
				control:Set(value, true, true)
			end
		end

		return true
	end

	function window:SaveConfig(name)
		setConfigName(name)

		if not getFileApi() then
			self:Notify("Config", "File API is not available.", "Warning")
			return false
		end

		if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(self.ConfigFolder) then
			local ok = pcall(function()
				makefolder(self.ConfigFolder)
			end)

			if not ok then
				self:Notify("Config", "Could not create config folder.", "Error")
				return false
			end
		end

		local ok = pcall(function()
			writefile(configPath(), HttpService:JSONEncode(self:GetConfig()))
		end)

		self:Notify("Config", ok and "Settings saved." or "Settings could not be saved.", ok and "Success" or "Error")
		return ok
	end

	function window:LoadConfig(name)
		setConfigName(name)

		if not getFileApi() then
			self:Notify("Config", "File API is not available.", "Warning")
			return false
		end

		if not isfile(configPath()) then
			self:Notify("Config", "No saved config found.", "Warning")
			return false
		end

		local ok, decoded = pcall(function()
			return HttpService:JSONDecode(readfile(configPath()))
		end)

		if ok then
			self:ApplyConfig(decoded)
		end

		self:Notify("Config", ok and "Settings loaded." or "Config could not be read.", ok and "Success" or "Error")
		return ok
	end

	function window:DeleteConfig(name)
		setConfigName(name)

		if type(delfile) ~= "function" or type(isfile) ~= "function" then
			self:Notify("Config", "Delete file API is not available.", "Warning")
			return false
		end

		if isfile(configPath()) then
			delfile(configPath())
		end

		self:Notify("Config", "Config deleted.", "Success")
		return true
	end

	function window:Notify(titleText, message, notifyType, duration)
		notifyType = notifyType or "Info"
		local colorKey = notifyType == "Success" and "Success"
			or notifyType == "Warning" and "Warning"
			or notifyType == "Error" and "Error"
			or "Accent"

		local note = styledBackground(make("Frame", {
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Size = UDim2.fromOffset(300, 0),
			Parent = notifications,
		}, {
			corner(8),
			styledStroke(stroke(theme.Stroke, 0.25, 1), "Stroke"),
		}), "Surface")
		local noteScale = make("UIScale", {
			Scale = 0.94,
			Parent = note,
		})

		local accent = make("Frame", {
			Name = "DarkUIAccent",
			BackgroundColor3 = self.Theme[colorKey],
			BorderSizePixel = 0,
			Size = UDim2.new(0, 3, 1, 0),
			Parent = note,
		})
		accent:SetAttribute("DarkUIBackground", colorKey)

		styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Bold,
			Parent = note,
			Position = UDim2.fromOffset(15, 8),
			Size = UDim2.new(1, -30, 0, 20),
			Text = titleText or notifyType,
			TextSize = 15,
		}), "Text")

		styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Body,
			Parent = note,
			Position = UDim2.fromOffset(15, 31),
			Size = UDim2.new(1, -30, 0, 34),
			Text = message or "",
			TextSize = 13,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		}), "Muted")

		tween(note, { Size = UDim2.fromOffset(300, 74) }, 0.22)
		tween(noteScale, { Scale = 1 }, 0.22)

		task.delay(duration or 2.6, function()
			if note.Parent then
				tween(noteScale, { Scale = 0.96 }, 0.18)
				tween(note, { Size = UDim2.fromOffset(300, 0), BackgroundTransparency = 1 }, 0.18)
				task.wait(0.2)
				if note.Parent then
					note:Destroy()
				end
			end
		end)
	end

	function window:Confirm(options)
		options = options or {}

		local overlay = make("Frame", {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 100,
			Parent = screenGui,
		})

		local dialog = styledBackground(make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(340, 156),
			ZIndex = 101,
			Parent = overlay,
		}, {
			corner(9),
			styledStroke(stroke(theme.Stroke, 0.15, 1), "Stroke"),
		}), "Surface")
		local dialogScale = make("UIScale", {
			Scale = 0.92,
			Parent = dialog,
		})
		tween(dialogScale, {
			Scale = 1,
		}, 0.18)
		tween(overlay, {
			BackgroundTransparency = 0.35,
		}, 0.16)

		local confirmTitle = styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Bold,
			Parent = dialog,
			Position = UDim2.fromOffset(18, 14),
			Size = UDim2.new(1, -36, 0, 24),
			Text = options.Title or "Confirm",
			TextSize = 18,
		}), "Text")
		confirmTitle.ZIndex = 102

		local confirmBody = styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Body,
			Parent = dialog,
			Position = UDim2.fromOffset(18, 44),
			Size = UDim2.new(1, -36, 0, 52),
			Text = options.Text or options.Message or "Are you sure?",
			TextSize = 14,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		}), "Muted")
		confirmBody.ZIndex = 102

		local cancel = styledBackground(make("TextButton", {
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Font = DarkUI.Fonts.Bold,
			Position = UDim2.new(1, -198, 1, -48),
			Size = UDim2.fromOffset(84, 32),
			Text = options.CancelText or "Cancel",
			TextSize = 14,
			ZIndex = 102,
			Parent = dialog,
		}, {
			corner(6),
		}), "PanelLight")
		styledText(cancel, "Text")
		attachHover(cancel, "PanelLight", "Panel", 1.03)
		attachPress(cancel, 0.92)

		local confirm = styledBackground(make("TextButton", {
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Font = DarkUI.Fonts.Bold,
			Position = UDim2.new(1, -104, 1, -48),
			Size = UDim2.fromOffset(86, 32),
			Text = options.ConfirmText or "Confirm",
			TextSize = 14,
			ZIndex = 102,
			Parent = dialog,
		}, {
			corner(6),
		}), "PanelLight")
		styledText(confirm, "Accent")
		attachHover(confirm, "PanelLight", "Panel", 1.03)
		attachPress(confirm, 0.92)

		connect(cancel.MouseButton1Click, function()
			overlay:Destroy()
			safe(options.CancelCallback)
		end)

		connect(confirm.MouseButton1Click, function()
			overlay:Destroy()
			safe(options.Callback or options.ConfirmCallback)
		end)

		return overlay
	end

	local function setSearchText(row, text)
		row:SetAttribute("SearchText", string.lower(tostring(text or "")))
	end

	function window:ApplySearch(query)
		query = string.lower(tostring(query or ""))

		if searchClear then
			searchClear.Visible = query ~= ""
		end

		for _, item in ipairs(self.SearchItems) do
			local row = item.Row
			local baseVisible = row:GetAttribute("BaseVisible") ~= false
			local matches = query == "" or string.find(row:GetAttribute("SearchText") or "", query, 1, true) ~= nil
			row.Visible = baseVisible and matches
		end

		for _, section in ipairs(self.Sections) do
			section:UpdateVisibility()
		end
	end

	if searchBox then
		connect(searchBox:GetPropertyChangedSignal("Text"), function()
			window:ApplySearch(searchBox.Text)
		end)

		connect(searchClear.MouseButton1Click, function()
			searchBox.Text = ""
		end)
	end

	function window:SelectTab(name)
		for tabName, page in pairs(self.Pages) do
			local selected = tabName == name
			page.Visible = selected

			local tabButton = self.TabButtons[tabName]
			if tabButton then
				tween(tabButton, {
					BackgroundColor3 = selected and self.Theme.TabActive or self.Theme.Surface,
				}, 0.14)

				local tabTitle = tabButton:FindFirstChild("TabTitle")
				if tabTitle then
					tween(tabTitle, {
						TextColor3 = selected and self.Theme.Text or Color3.fromRGB(
							math.floor((self.Theme.Text.R * 255) * 0.84 + 0.5),
							math.floor((self.Theme.Text.G * 255) * 0.84 + 0.5),
							math.floor((self.Theme.Text.B * 255) * 0.84 + 0.5)
						),
					}, 0.14)
				end

				local tabDesc = tabButton:FindFirstChild("TabDesc")
				if tabDesc then
					tween(tabDesc, {
						TextColor3 = self.Theme.Muted,
						TextTransparency = selected and 0.1 or 0.42,
					}, 0.14)
				end

				local activeGlow = tabButton:FindFirstChild("DarkUITabActiveGlow")
				if activeGlow then
					tween(activeGlow, {
						BackgroundTransparency = selected and 0 or 1,
					}, 0.14)
				end

				local accent = tabButton:FindFirstChild("DarkUIAccent")
				if accent then
					if selected then
						accent.Visible = true
					end
					tween(accent, {
						Size = selected and UDim2.new(0, 3, 1, -14) or UDim2.new(0, 3, 0, 0),
						BackgroundTransparency = selected and 0 or 0.4,
					}, 0.16)
					if not selected then
						task.delay(0.16, function()
							if accent.Parent and self.SelectedTab ~= tabName then
								accent.Visible = false
							end
						end)
					end
				end
			end
		end

		self.SelectedTab = name
		setFooterActive(footerRoleForTab(name), true)
		self:ApplySearch(searchBox and searchBox.Text or "")
	end

	local function buildControlApi(row, render)
		row:SetAttribute("BaseVisible", true)

		local control = {
			Row = row,
			Disabled = false,
			Changed = {},
		}

		function control:SetDisabled(disabled)
			self.Disabled = disabled == true
			row:SetAttribute("Disabled", self.Disabled)
			row.BackgroundTransparency = self.Disabled and 0.35 or 0

			for _, descendant in ipairs(row:GetDescendants()) do
				if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
					descendant.TextTransparency = self.Disabled and 0.38 or 0
				end
			end

			if render then
				render(true)
			end
		end

		function control:SetVisible(visible)
			row:SetAttribute("BaseVisible", visible ~= false)
			window:ApplySearch(searchBox and searchBox.Text or "")
		end

		function control:OnChanged(callback)
			table.insert(self.Changed, callback)
			return function()
				for index, current in ipairs(self.Changed) do
					if current == callback then
						table.remove(self.Changed, index)
						break
					end
				end
			end
		end

		function control:_fire(value)
			for _, callback in ipairs(self.Changed) do
				safe(callback, value)
			end
		end

		function control:DependsOn(otherControl, expected, mode)
			local function evaluate(value)
				local passed
				if type(expected) == "function" then
					passed = expected(value)
				elseif expected == nil then
					passed = value == true
				else
					passed = value == expected
				end

				if mode == "Disable" then
					self:SetDisabled(not passed)
				else
					self:SetVisible(passed)
				end
			end

			if otherControl and type(otherControl.Get) == "function" then
				evaluate(otherControl:Get())
				return otherControl:OnChanged(evaluate)
			end
		end

		return control
	end

	function window:CreateTab(tabConfig, icon)
		if type(tabConfig) == "string" then
			tabConfig = {
				Name = tabConfig,
				Icon = icon,
			}
		end

		tabConfig = tabConfig or {}
		local tabName = tabConfig.Name or ("Tab " .. tostring(#self.TabButtons + 1))

		local tabDescription = tabConfig.Description or tabConfig.Subtitle
		if not tabDescription or tabDescription == "" then
			local loweredName = string.lower(tabName)
			if string.find(loweredName, "setting", 1, true) then
				tabDescription = "UI tools, themes, config"
			elseif string.find(loweredName, "webhook", 1, true) then
				tabDescription = "Discord log and payload"
			else
				tabDescription = "Auto farm and more..."
			end
		end
		local tabButton = styledBackground(make("TextButton", {
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Font = DarkUI.Fonts.Bold,
			Size = UDim2.new(1, -2, 0, tabConfig.Height or 56),
			Text = "",
			Parent = tabs,
		}, {
			corner(6),
		}), "Surface")
		attachPress(tabButton, 0.97)

		local activeGlow = make("Frame", {
			Name = "DarkUITabActiveGlow",
			BackgroundColor3 = self.Theme.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Parent = tabButton,
		}, {
			corner(6),
			make("UIGradient", {
				Rotation = 0,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.86),
					NumberSequenceKeypoint.new(0.45, 0.92),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),
		})

		local textOffset = tabConfig.Icon and 42 or 14
		if tabConfig.Icon then
			make("ImageLabel", {
				BackgroundTransparency = 1,
				Image = tabConfig.Icon,
				Position = UDim2.fromOffset(12, 11),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromOffset(18, 18),
				Parent = tabButton,
			})
		end

		local titleLabel = styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Bold,
			Parent = tabButton,
			Position = UDim2.fromOffset(textOffset, 8),
			Size = UDim2.new(1, -textOffset - 12, 0, 20),
			Text = tabName,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}), "Text")
		titleLabel.Name = "TabTitle"

		local descLabel = styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Body,
			Parent = tabButton,
			Position = UDim2.fromOffset(textOffset, 28),
			Size = UDim2.new(1, -textOffset - 12, 0, 17),
			Text = tabDescription,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
		}), "Muted")
		descLabel.Name = "TabDesc"
		descLabel.TextTransparency = 0.42

		make("Frame", {
			Name = "DarkUIAccent",
			AnchorPoint = Vector2.new(0, 0),
			BackgroundColor3 = self.Theme.Accent,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 7),
			Size = UDim2.new(0, 3, 0, 0),
			Visible = false,
			Parent = tabButton,
		}, {
			corner(999),
		})

		connect(tabButton.MouseEnter, function()
			if window.SelectedTab ~= tabName then
				tween(tabButton, {
					BackgroundColor3 = window.Theme.Tab,
				}, 0.12)
				tween(getScale(tabButton), {
					Scale = 1.006,
				}, 0.12)
			end
		end)

		connect(tabButton.MouseLeave, function()
			if window.SelectedTab ~= tabName then
				tween(tabButton, {
					BackgroundColor3 = window.Theme.Surface,
				}, 0.12)
			end
			tween(getScale(tabButton), {
				Scale = 1,
			}, 0.12)
		end)

		local page = make("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			Parent = pagesHolder,
		}, {
			make("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})

		local left = make("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			LayoutOrder = 1,
			ScrollBarImageColor3 = self.Theme.Accent,
			ScrollBarImageTransparency = 0.4,
			ScrollBarThickness = 2,
			Size = UDim2.new(0.5, -5, 1, 0),
			Parent = page,
		}, {
			make("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			make("UIPadding", {
				PaddingBottom = UDim.new(0, 6),
				PaddingTop = UDim.new(0, 4),
			}),
		})

		local right = make("ScrollingFrame", {
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			LayoutOrder = 2,
			ScrollBarImageColor3 = self.Theme.Accent,
			ScrollBarImageTransparency = 0.4,
			ScrollBarThickness = 2,
			Size = UDim2.new(0.5, -5, 1, 0),
			Parent = page,
		}, {
			make("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			make("UIPadding", {
				PaddingBottom = UDim.new(0, 6),
				PaddingTop = UDim.new(0, 4),
			}),
		})

		self.Pages[tabName] = page
		self.TabButtons[tabName] = tabButton
		table.insert(self.TabOrder, tabName)

		if not self.FooterHomeTab then
			self.FooterHomeTab = tabName
		end

		if not self.FooterSettingsTab and isSettingsTabName(tabName) then
			self.FooterSettingsTab = tabName
		end

		local tab = {
			Name = tabName,
			Page = page,
			Window = self,
			Columns = { left, right },
			SectionOrder = 0,
		}

		function tab:AddSection(options)
			if type(options) == "string" then
				options = {
					Title = options,
				}
			end

			options = options or {}
			self.SectionOrder += 1

			local target
			if options.Side == "Right" then
				target = self.Columns[2]
			elseif options.Side == "Left" then
				target = self.Columns[1]
			else
				target = self.Columns[((self.SectionOrder - 1) % #self.Columns) + 1]
			end

			local section = styledBackground(make("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0,
				LayoutOrder = self.SectionOrder,
				Size = UDim2.new(1, -4, 0, 0),
				Parent = target,
			}, {
				corner(11),
				styledStroke(stroke(window.Theme.Stroke, 0.18, 1), "Stroke"),
				make("UIPadding", {
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingTop = UDim.new(0, 9),
				}),
				make("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 9),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			}), "Surface")

			local headerButton = make("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				LayoutOrder = 0,
				Size = UDim2.new(1, 0, 0, 38),
				Text = "",
				Parent = section,
			})

			styledText(DarkUI:Text({
				Font = DarkUI.Fonts.Bold,
				Parent = headerButton,
				Position = UDim2.fromOffset(6, 1),
				Size = UDim2.new(1, -12, 0, 24),
				Text = options.Title or "Section",
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Left,
			}), "Text")

			local isCollapsible = options.Collapsible ~= false
			local foldIcon = make("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -5, 0, 3),
				Rotation = options.DefaultOpen == false and 90 or 0,
				Size = UDim2.fromOffset(22, 22),
				Visible = isCollapsible,
				Parent = headerButton,
			})
			local foldIconScale = make("UIScale", {
				Scale = 1,
				Parent = foldIcon,
			})
			local foldHorizontal = styledBackground(make("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(12, 2),
				Parent = foldIcon,
			}, {
				corner(999),
			}), "Muted")
			local foldVertical = styledBackground(make("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = options.DefaultOpen == false and 0 or 1,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(2, 12),
				Parent = foldIcon,
			}, {
				corner(999),
			}), "Muted")

			make("Frame", {
				Name = "DarkUIAccent",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = window.Theme.Accent,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 1, -2),
				Size = UDim2.new(1, -4, 0, 3),
				Parent = headerButton,
			}, {
				make("UIGradient", {
					Name = "DarkUIAccentGradient",
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 58, 58)),
						ColorSequenceKeypoint.new(0.5, window.Theme.Accent),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(58, 58, 58)),
					}),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.86),
						NumberSequenceKeypoint.new(0.5, 0),
						NumberSequenceKeypoint.new(1, 0.86),
					}),
				}),
			})

			local bodyFrame = make("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 0),
				Visible = options.DefaultOpen ~= false,
				Parent = section,
			}, {
				make("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 8),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			})

			local sectionApi = {
				Container = section,
				Body = bodyFrame,
				Header = headerButton,
				Window = window,
				ItemOrder = 0,
				Collapsed = options.DefaultOpen == false,
			}

			function sectionApi:UpdateVisibility()
				local anyVisible = false
				for _, child in ipairs(self.Body:GetChildren()) do
					if child:IsA("GuiObject") and child.Visible then
						anyVisible = true
						break
					end
				end

				self.Container.Visible = anyVisible or not searchBox or searchBox.Text == ""
			end

			function sectionApi:SetCollapsed(collapsed)
				if not isCollapsible then
					return
				end

				self.Collapsed = collapsed == true
				self.Body.Visible = not self.Collapsed
				tween(foldIconScale, {
					Scale = 0.82,
				}, 0.07)
				tween(foldIcon, {
					Rotation = self.Collapsed and 90 or 0,
				}, 0.18)
				tween(foldVertical, {
					BackgroundTransparency = self.Collapsed and 0 or 1,
				}, 0.14)
				tween(foldHorizontal, {
					BackgroundTransparency = 0,
				}, 0.14)
				task.delay(0.07, function()
					if foldIconScale.Parent then
						tween(foldIconScale, {
							Scale = 1,
						}, 0.12)
					end
				end)
			end

			function sectionApi:NextOrder()
				self.ItemOrder += 1
				return self.ItemOrder
			end

			local function addSearchRow(row, text)
				setSearchText(row, text)
				table.insert(window.SearchItems, {
					Row = row,
					Section = sectionApi,
				})
			end

			local function createRow(options, height)
				options = options or {}

				local row = styledBackground(make("Frame", {
					BorderSizePixel = 0,
					LayoutOrder = sectionApi:NextOrder(),
					Size = UDim2.new(1, 0, 0, height),
					Parent = bodyFrame,
				}, {
					corner(8),
					styledStroke(stroke(window.Theme.Stroke, 0.26, 1), "Stroke"),
				}), "Tab")

				attachHover(row, "Tab", "Surface")
				addSearchRow(row, (options.Title or "") .. " " .. (options.Description or "") .. " " .. (options.SearchText or ""))
				return row
			end

			connect(headerButton.MouseButton1Click, function()
				pop(headerButton, 0.985)
				sectionApi:SetCollapsed(not sectionApi.Collapsed)
			end)

			table.insert(window.Sections, sectionApi)

			function sectionApi:AddLabel(text)
				local label = styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Body,
					LayoutOrder = self:NextOrder(),
					Parent = bodyFrame,
					Size = UDim2.new(1, 0, 0, 20),
					Text = text or "Label",
					TextSize = 13,
				}), "Muted")
				addSearchRow(label, text or "Label")
				return label
			end

			function sectionApi:AddDivider()
				return styledBackground(make("Frame", {
					BorderSizePixel = 0,
					LayoutOrder = self:NextOrder(),
					Size = UDim2.new(1, 0, 0, 1),
					Parent = bodyFrame,
				}), "Stroke")
			end

			function sectionApi:AddParagraph(options)
				options = options or {}
				local row = createRow(options, 72)
				row:SetAttribute("DarkUIBackground", "Surface")
				row.BackgroundColor3 = window.Theme.Surface

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(14, 8),
					Size = UDim2.new(1, -28, 0, 18),
					Text = options.Title or "Info",
					TextSize = 14,
				}), "Text")

				local bodyText = styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Body,
					Parent = row,
					Position = UDim2.fromOffset(14, 31),
					Size = UDim2.new(1, -28, 0, 34),
					Text = options.Text or "",
					TextSize = 13,
					TextWrapped = true,
					TextYAlignment = Enum.TextYAlignment.Top,
				}), "Muted")

				local control = buildControlApi(row)
				function control:Set(text)
					bodyText.Text = text
					setSearchText(row, (options.Title or "") .. " " .. text)
				end

				return control
			end

			function sectionApi:AddButton(options)
				options = options or {}
				local row = createRow(options, 44)

				local button = styledBackground(make("TextButton", {
					AutoButtonColor = false,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Font = DarkUI.Fonts.Bold,
					Size = UDim2.fromScale(1, 1),
					Text = "",
					Parent = row,
				}), "Panel")

				if options.Icon then
					make("ImageLabel", {
						BackgroundTransparency = 1,
						Image = options.Icon,
						Position = UDim2.fromOffset(14, 12),
						ScaleType = Enum.ScaleType.Fit,
						Size = UDim2.fromOffset(20, 20),
						Parent = button,
					})
				end

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = button,
					Position = UDim2.fromOffset(options.Icon and 42 or 0, 0),
					Size = UDim2.new(1, options.Icon and -56 or 0, 1, 0),
					Text = options.Title or "Button",
					TextSize = 15,
					TextXAlignment = options.Icon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
				}), "Text")

				local control = buildControlApi(row)
				attachPress(row, 0.985)
				connect(button.MouseButton1Click, function()
					if not control.Disabled then
						safe(options.Callback)
					end
				end)

				window:AttachTooltip(row, options.Tooltip)
				return control
			end

			function sectionApi:AddToggle(options)
				options = options or {}
				local value = options.Default == true
				local hasDescription = options.Description and options.Description ~= ""
				local row = createRow(options, hasDescription and 70 or 48)

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(14, hasDescription and 8 or 0),
					Size = UDim2.new(1, -66, 0, hasDescription and 18 or 48),
					Text = options.Title or "Toggle",
					TextSize = 15,
				}), "Text")

				if hasDescription then
					styledText(DarkUI:Text({
						Font = DarkUI.Fonts.Body,
						Parent = row,
						Position = UDim2.fromOffset(14, 29),
						Size = UDim2.new(1, -76, 0, 34),
						Text = options.Description,
						TextSize = 12,
						TextWrapped = true,
						TextYAlignment = Enum.TextYAlignment.Top,
					}), "Muted")
				end

				local shellStroke = stroke(window.Theme.Stroke, 0.12, 2)
				local shell = styledBackground(make("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					AutoButtonColor = false,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -16, 0.5, 0),
					Size = UDim2.fromOffset(30, 30),
					Text = "",
					Parent = row,
				}, {
					corner(6),
					shellStroke,
				}), "Surface")

				local innerStroke = stroke(window.Theme.Stroke, 0.22, 1)
				local innerBox = make("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(8, 9, 12),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(22, 22),
					Parent = shell,
				}, {
					corner(5),
					innerStroke,
				})

				local check = make("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(18, 16),
					Parent = innerBox,
				}, {
					make("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(6, 10),
						Rotation = 45,
						Size = UDim2.fromOffset(7, 3),
					}, {
						corner(999),
					}),
					make("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(11, 8),
						Rotation = -45,
						Size = UDim2.fromOffset(13, 3),
					}, {
						corner(999),
					}),
				})
				local checkScale = make("UIScale", {
					Scale = value and 1 or 0.72,
					Parent = check,
				})

				local control
				local function render(animated)
					local onColor = window.Theme.Accent
					local shellProps = {
						BackgroundColor3 = window.Theme.Surface,
					}
					local shellStrokeProps = {
						Color = value and onColor or window.Theme.Stroke,
						Transparency = value and 0.02 or 0.12,
					}
					local innerProps = {
						BackgroundColor3 = value and onColor or Color3.fromRGB(8, 9, 12),
					}
					local innerStrokeProps = {
						Color = value and onColor or Color3.fromRGB(54, 60, 76),
						Transparency = value and 0 or 0.12,
					}

					if value then
						check.Visible = true
					end

					if animated then
						tween(shell, shellProps, 0.14)
						tween(shellStroke, shellStrokeProps, 0.14)
						tween(innerBox, innerProps, 0.14)
						tween(innerStroke, innerStrokeProps, 0.14)
						tween(checkScale, {
							Scale = value and 1 or 0.72,
						}, 0.13)
						for _, child in ipairs(check:GetChildren()) do
							if child:IsA("Frame") then
								tween(child, {
									BackgroundTransparency = value and 0 or 1,
								}, 0.1)
							end
						end
						if not value then
							task.delay(0.11, function()
								if check.Parent and not value then
									check.Visible = false
								end
							end)
						end
					else
						shell.BackgroundColor3 = shellProps.BackgroundColor3
						shellStroke.Color = shellStrokeProps.Color
						shellStroke.Transparency = shellStrokeProps.Transparency
						innerBox.BackgroundColor3 = innerProps.BackgroundColor3
						innerStroke.Color = innerStrokeProps.Color
						innerStroke.Transparency = innerStrokeProps.Transparency
						checkScale.Scale = value and 1 or 0.72
						check.Visible = value
						for _, child in ipairs(check:GetChildren()) do
							if child:IsA("Frame") then
								child.BackgroundTransparency = value and 0 or 1
							end
						end
					end
				end

				control = buildControlApi(row, render)

				function control:Set(nextValue, silent)
					value = nextValue == true
					render(true)
					if not silent then
						safe(options.Callback, value)
						self:_fire(value)
					end
				end

				function control:Get()
					return value
				end

				function control:Toggle()
					if not self.Disabled then
						self:Set(not value)
					end
				end

				local lastToggle = 0
				local function requestToggle()
					local now = os.clock()
					if now - lastToggle < 0.05 then
						return
					end

					lastToggle = now
					pop(shell, 0.88)
					control:Toggle()
				end

				connect(row.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						requestToggle()
					end
				end)

				connect(shell.MouseButton1Click, function()
					requestToggle()
				end)

				registerRenderer(render)
				window:RegisterConfig(options.Flag, control)
				window:AttachTooltip(row, options.Tooltip)
				return control
			end

			function sectionApi:AddSlider(options)
				options = options or {}
				local minValue = options.Min or 0
				local maxValue = options.Max or 100
				if maxValue < minValue then
					minValue, maxValue = maxValue, minValue
				end

				local decimals = options.Decimals or 0
				local factor = 10 ^ decimals
				local value = math.clamp(options.Default or minValue, minValue, maxValue)
				local row = createRow(options, 64)

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(12, 6),
					Size = UDim2.new(1, -24, 0, 18),
					Text = options.Title or "Slider",
					TextSize = 14,
				}), "Text")

				local valueBoxStroke = styledStroke(stroke(window.Theme.Stroke, 0.45, 1), "Stroke")
				local valueBox = styledBackground(make("TextBox", {
					AnchorPoint = Vector2.new(1, 0.5),
					BorderSizePixel = 0,
					ClearTextOnFocus = false,
					Font = DarkUI.Fonts.Bold,
					PlaceholderColor3 = window.Theme.Muted,
					PlaceholderText = "0",
					Position = UDim2.new(1, -12, 0, 43),
					Size = UDim2.fromOffset(72, 28),
					Text = tostring(value),
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Center,
					Parent = row,
				}, {
					corner(6),
					valueBoxStroke,
				}), "Surface")
				styledText(valueBox, "Accent")
				local valueBoxFocused = false

				local track = styledBackground(make("Frame", {
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(12, 42),
					Size = UDim2.new(1, -104, 0, 6),
					Parent = row,
				}, {
					corner(999),
				}), "Tab")

				local fill = make("Frame", {
					Name = "DarkUIAccent",
					BackgroundColor3 = window.Theme.Accent,
					BorderSizePixel = 0,
					Size = UDim2.fromScale(0, 1),
					Parent = track,
				}, {
					corner(999),
				})

				local knob = make("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = window.Theme.Accent,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.fromOffset(15, 15),
					Parent = track,
				}, {
					corner(999),
				})
				knob.Name = "DarkUIAccent"

				local dragging = false
				local control

				local function round(nextValue)
					return math.floor((nextValue * factor) + 0.5) / factor
				end

				local function render(animated)
					local percent = maxValue == minValue and 0 or math.clamp((value - minValue) / (maxValue - minValue), 0, 1)
					if not valueBoxFocused then
						valueBox.Text = tostring(value)
					end
					if animated then
						tween(fill, {
							Size = UDim2.fromScale(percent, 1),
						}, 0.08)
						tween(knob, {
							Position = UDim2.fromScale(percent, 0.5),
						}, 0.08)
					else
						fill.Size = UDim2.fromScale(percent, 1)
						knob.Position = UDim2.fromScale(percent, 0.5)
					end
				end

				local function applyTextValue()
					local nextValue = tonumber(valueBox.Text)
					if nextValue then
						control:Set(nextValue)
					else
						valueBox.Text = tostring(value)
					end
				end

				local function updateFromInput(input)
					local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					control:Set(minValue + ((maxValue - minValue) * percent))
				end

				control = buildControlApi(row, render)

				function control:Set(nextValue, silent)
					value = round(math.clamp(tonumber(nextValue) or minValue, minValue, maxValue))
					render(true)
					if not silent then
						safe(options.Callback, value)
						self:_fire(value)
					end
				end

				function control:Get()
					return value
				end

				connect(valueBox.Focused, function()
					valueBoxFocused = true
					if not control.Disabled then
						tween(valueBoxStroke, {
							Color = window.Theme.Accent,
							Transparency = 0.08,
						}, 0.12)
						pop(valueBox, 0.98)
					end
				end)

				connect(valueBox.FocusLost, function()
					valueBoxFocused = false
					tween(valueBoxStroke, {
						Color = window.Theme.Stroke,
						Transparency = 0.45,
					}, 0.12)
					if not control.Disabled then
						applyTextValue()
					end
				end)

				connect(track.InputBegan, function(input)
					if control.Disabled then
						return
					end

					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						tween(getScale(knob), {
							Scale = 1.18,
						}, 0.1)
						updateFromInput(input)
					end
				end)

				connect(UserInputService.InputChanged, function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						updateFromInput(input)
					end
				end)

				connect(UserInputService.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
						tween(getScale(knob), {
							Scale = 1,
						}, 0.12)
					end
				end)

				registerRenderer(render)
				window:RegisterConfig(options.Flag, control)
				window:AttachTooltip(row, options.Tooltip)
				return control
			end

			local function makeDropdown(options, multi)
				options = options or {}
				local items = options.Items or {}
				local selected = multi and {} or options.Default or items[1]
				local searchable = options.Searchable ~= false
				if multi then
					for _, item in ipairs(options.Default or {}) do
						selected[tostring(item)] = true
					end
				end

				local row = createRow(options, 44)
				local open = false
				local listHeight = 0
				local filteredCount = #items
				local searchQuery = ""

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(0.42, -12, 0, 44),
					Text = options.Title or "Dropdown",
					TextSize = 14,
				}), "Text")

				local button = styledBackground(make("TextButton", {
					AnchorPoint = Vector2.new(1, 0),
					AutoButtonColor = false,
					BorderSizePixel = 0,
					Font = DarkUI.Fonts.Bold,
					Position = UDim2.new(1, -12, 0, 8),
					Size = UDim2.new(0.58, -8, 0, 28),
					Text = "",
					Parent = row,
				}, {
					corner(6),
					styledStroke(stroke(window.Theme.Stroke, 0.55, 1), "Stroke"),
				}), "Surface")

				local selectedText = styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = button,
					Position = UDim2.fromOffset(9, 0),
					Size = UDim2.new(1, -32, 1, 0),
					Text = "",
					TextSize = 13,
				}), "Text")

				local arrow = make("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -9, 0.5, 0),
					Size = UDim2.fromOffset(20, 18),
					Parent = button,
				}, {
					styledBackground(make("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(7, 9),
						Rotation = 45,
						Size = UDim2.fromOffset(11, 3),
					}, {
						corner(999),
					}), "Accent"),
					styledBackground(make("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(13, 9),
						Rotation = -45,
						Size = UDim2.fromOffset(11, 3),
					}, {
						corner(999),
					}), "Accent"),
				})
				attachHover(button, "Surface", "PanelLight", 1.01)
				attachPress(button, 0.96)

				local list = make("Frame", {
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Position = UDim2.fromOffset(12, 42),
					Size = UDim2.new(1, -24, 0, 0),
					Parent = row,
				}, {
					make("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						Padding = UDim.new(0, 5),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
				})

				local searchBox
				if searchable then
					searchBox = styledBackground(make("TextBox", {
						BorderSizePixel = 0,
						ClearTextOnFocus = false,
						Font = DarkUI.Fonts.Bold,
						LayoutOrder = 0,
						PlaceholderColor3 = window.Theme.Muted,
						PlaceholderText = "Search...",
						Size = UDim2.new(1, 0, 0, 30),
						Text = "",
						TextSize = 13,
						Parent = list,
					}, {
						corner(5),
						styledStroke(stroke(window.Theme.Stroke, 0.55, 1), "Stroke"),
						make("UIPadding", {
							PaddingLeft = UDim.new(0, 8),
							PaddingRight = UDim.new(0, 8),
						}),
					}), "Surface")
					styledText(searchBox, "Text")
				end

				local control
				local itemButtons = {}
				local itemChecks = {}

				local function selectedList()
					local listItems = {}
					for _, item in ipairs(items) do
						if selected[tostring(item)] then
							table.insert(listItems, item)
						end
					end
					return listItems
				end

				local function renderText()
					if multi then
						local values = selectedList()
						selectedText.Text = #values == 0 and "None" or table.concat(values, ", ")
					else
						selectedText.Text = tostring(selected or "None")
					end

					for key, itemButton in pairs(itemButtons) do
						local active = multi and selected[key] == true or tostring(selected) == key
						itemButton.BackgroundColor3 = active and window.Theme.TabActive or window.Theme.Surface
						if itemChecks[key] then
							itemChecks[key].Visible = active
						end
					end
				end

				local function setOpen(nextOpen)
					open = nextOpen == true
					local searchHeight = searchable and 35 or 0
					listHeight = open and (searchHeight + (filteredCount * 41)) or 0
					tween(row, {
						Size = UDim2.new(1, 0, 0, 44 + listHeight),
					}, 0.16)
					tween(list, {
						Size = UDim2.new(1, -24, 0, listHeight),
					}, 0.16)
					tween(arrow, {
						Rotation = open and 180 or 0,
					}, 0.16)
				end

				local function rebuild()
					for _, child in ipairs(list:GetChildren()) do
						if child:IsA("GuiObject") and child ~= searchBox then
							child:Destroy()
						end
					end

					itemButtons = {}
					itemChecks = {}
					filteredCount = 0

					local normalizedQuery = string.lower(searchQuery)
					for index, item in ipairs(items) do
						local itemKey = tostring(item)
						local matches = normalizedQuery == "" or string.find(string.lower(itemKey), normalizedQuery, 1, true) ~= nil
						local itemButton = styledBackground(make("TextButton", {
							AutoButtonColor = false,
							BorderSizePixel = 0,
							Font = DarkUI.Fonts.Bold,
							LayoutOrder = searchable and (index + 1) or index,
							Size = UDim2.new(1, 0, 0, 36),
							Text = "",
							TextSize = 10,
							Visible = matches,
							Parent = list,
						}, {
							corner(5),
						}), "Surface")

						styledText(DarkUI:Text({
							Font = DarkUI.Fonts.Bold,
							Parent = itemButton,
							Position = UDim2.fromOffset(12, 0),
							Size = UDim2.new(1, -48, 1, 0),
							Text = itemKey,
							TextSize = 14,
						}), "Text")

						local itemCheck = make("Frame", {
							AnchorPoint = Vector2.new(1, 0.5),
							BackgroundTransparency = 1,
							Position = UDim2.new(1, -9, 0.5, 0),
							Size = UDim2.fromOffset(20, 20),
							Visible = false,
							Parent = itemButton,
						}, {
							styledBackground(make("Frame", {
								AnchorPoint = Vector2.new(0.5, 0.5),
								BorderSizePixel = 0,
								Position = UDim2.fromOffset(7, 12),
								Rotation = 45,
								Size = UDim2.fromOffset(8, 3),
							}, {
								corner(999),
							}), "Accent"),
							styledBackground(make("Frame", {
								AnchorPoint = Vector2.new(0.5, 0.5),
								BorderSizePixel = 0,
								Position = UDim2.fromOffset(13, 9),
								Rotation = -45,
								Size = UDim2.fromOffset(14, 3),
							}, {
								corner(999),
							}), "Accent"),
						})

						itemButtons[itemKey] = itemButton
						itemChecks[itemKey] = itemCheck
						if matches then
							filteredCount += 1
						end
						attachHover(itemButton, "Surface", "PanelLight", 1.01)
						attachPress(itemButton, 0.96)
						connect(itemButton.MouseLeave, function()
							local active = multi and selected[itemKey] == true or tostring(selected) == itemKey
							tween(itemButton, {
								BackgroundColor3 = active and window.Theme.TabActive or window.Theme.Surface,
							}, 0.1)
						end)

						connect(itemButton.MouseButton1Click, function()
							if control.Disabled then
								return
							end

							if multi then
								selected[itemKey] = not selected[itemKey]
								control:Set(selectedList())
							else
								control:Set(item)
								setOpen(false)
							end
						end)
					end

					if open then
						setOpen(true)
					end
				end

				control = buildControlApi(row, renderText)

				function control:Set(nextValue, silent)
					if multi then
						selected = {}
						for _, item in ipairs(nextValue or {}) do
							selected[tostring(item)] = true
						end
					else
						selected = nextValue
					end

					renderText()
					if not silent then
						safe(options.Callback, self:Get())
						self:_fire(self:Get())
					end
				end

				function control:Get()
					return multi and selectedList() or selected
				end

				function control:SetItems(nextItems)
					items = nextItems or {}
					rebuild()
					setOpen(open)
				end

				connect(button.MouseButton1Click, function()
					if not control.Disabled then
						setOpen(not open)
					end
				end)

				if searchBox then
					connect(searchBox:GetPropertyChangedSignal("Text"), function()
						searchQuery = searchBox.Text or ""
						rebuild()
						renderText()
					end)
				end

				rebuild()
				renderText()
				registerRenderer(renderText)
				window:RegisterConfig(options.Flag, control)
				window:AttachTooltip(row, options.Tooltip)
				return control
			end

			function sectionApi:AddDropdown(options)
				return makeDropdown(options, false)
			end

			function sectionApi:AddMultiDropdown(options)
				return makeDropdown(options, true)
			end

			function sectionApi:AddTextBox(options)
				options = options or {}
				local row = createRow(options, 44)

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(0.42, -12, 1, 0),
					Text = options.Title or "Text",
					TextSize = 14,
				}), "Text")

				local boxStroke = styledStroke(stroke(window.Theme.Stroke, 0.55, 1), "Stroke")
				local box = styledBackground(make("TextBox", {
					AnchorPoint = Vector2.new(1, 0.5),
					BorderSizePixel = 0,
					ClearTextOnFocus = false,
					Font = DarkUI.Fonts.Bold,
					PlaceholderColor3 = window.Theme.Muted,
					PlaceholderText = options.Placeholder or "Type...",
					Position = UDim2.new(1, -12, 0.5, 0),
					Size = UDim2.new(0.58, -8, 0, 28),
					Text = options.Default or "",
					TextSize = 13,
					Parent = row,
				}, {
					corner(6),
					make("UIPadding", {
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
					}),
					boxStroke,
				}), "Surface")
				styledText(box, "Text")

				local control = buildControlApi(row)
				function control:Set(text, silent)
					box.Text = tostring(text or "")
					if not silent then
						safe(options.Callback, box.Text)
						self:_fire(box.Text)
					end
				end

				function control:Get()
					return box.Text
				end

				connect(box.FocusLost, function()
					tween(boxStroke, {
						Color = window.Theme.Stroke,
						Transparency = 0.55,
					}, 0.12)
					if not control.Disabled then
						control:Set(box.Text)
					end
				end)

				connect(box.Focused, function()
					if not control.Disabled then
						tween(boxStroke, {
							Color = window.Theme.Accent,
							Transparency = 0.1,
						}, 0.12)
						pop(box, 0.985)
					end
				end)

				window:RegisterConfig(options.Flag, control)
				window:AttachTooltip(row, options.Tooltip)
				return control
			end

			function sectionApi:AddKeybind(options)
				options = options or {}
				local key = options.Default or Enum.KeyCode.RightShift
				local listening = false
				local row = createRow(options, 44)

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(1, -120, 1, 0),
					Text = options.Title or "Keybind",
					TextSize = 14,
				}), "Text")

				local keyButton = styledBackground(make("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					AutoButtonColor = false,
					BorderSizePixel = 0,
					Font = DarkUI.Fonts.Bold,
					Position = UDim2.new(1, -12, 0.5, 0),
					Size = UDim2.fromOffset(96, 28),
					Text = key.Name,
					TextSize = 13,
					Parent = row,
				}, {
					corner(6),
					styledStroke(stroke(window.Theme.Stroke, 0.55, 1), "Stroke"),
				}), "Surface")
				styledText(keyButton, "Text")
				attachHover(keyButton, "Surface", "PanelLight", 1.02)
				attachPress(keyButton, 0.94)

				local control = buildControlApi(row)
				function control:Set(nextKey, silent)
					if typeof(nextKey) == "EnumItem" then
						key = nextKey
					elseif type(nextKey) == "string" and Enum.KeyCode[nextKey] then
						key = Enum.KeyCode[nextKey]
					end

					keyButton.Text = key.Name
					if not silent then
						safe(options.Callback, key)
						self:_fire(key)
					end
				end

				function control:Get()
					return key.Name
				end

				connect(keyButton.MouseButton1Click, function()
					if control.Disabled then
						return
					end
					listening = true
					keyButton.Text = "..."
					pop(keyButton, 0.9)
				end)

				connect(UserInputService.InputBegan, function(input, processed)
					if listening and not processed and input.KeyCode ~= Enum.KeyCode.Unknown then
						listening = false
						control:Set(input.KeyCode)
					elseif not listening and not processed and input.KeyCode == key then
						safe(options.Pressed or options.Callback, key)
					end
				end)

				window:RegisterConfig(options.Flag, control)
				window:AttachTooltip(row, options.Tooltip)
				return control
			end

			function sectionApi:AddColorPicker(options)
				options = options or {}
				local colors = options.Colors or {
					Color3.fromRGB(173, 206, 255),
					Color3.fromRGB(96, 165, 250),
					Color3.fromRGB(52, 211, 153),
					Color3.fromRGB(168, 85, 247),
					Color3.fromRGB(248, 93, 106),
					Color3.fromRGB(250, 204, 21),
					Color3.fromRGB(232, 236, 243),
				}
				local selected = normalizeColor(options.Default, colors[1])
				local row = createRow(options, 72)

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(12, 6),
					Size = UDim2.new(1, -58, 0, 18),
					Text = options.Title or "Color",
					TextSize = 14,
				}), "Text")

				local preview = make("Frame", {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundColor3 = selected,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -12, 0, 8),
					Size = UDim2.fromOffset(28, 16),
					Parent = row,
				}, {
					corner(5),
					styledStroke(stroke(window.Theme.Stroke, 0.25, 1), "Stroke"),
				})

				local swatches = make("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(12, 34),
					Size = UDim2.new(1, -24, 0, 28),
					Parent = row,
				}, {
					make("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 7),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
				})

				local control = buildControlApi(row)
				function control:Set(color, silent)
					selected = normalizeColor(color, selected)
					tween(preview, {
						BackgroundColor3 = selected,
					}, 0.12)
					pop(preview, 0.86)
					if not silent then
						safe(options.Callback, selected)
						self:_fire(selected)
					end
				end

				function control:Get()
					return colorToTable(selected)
				end

				for index, color in ipairs(colors) do
					local swatch = make("TextButton", {
						AutoButtonColor = false,
						BackgroundColor3 = color,
						BorderSizePixel = 0,
						LayoutOrder = index,
						Size = UDim2.fromOffset(26, 26),
						Text = "",
						Parent = swatches,
					}, {
						corner(6),
						styledStroke(stroke(window.Theme.Stroke, 0.25, 1), "Stroke"),
					})
					attachHover(swatch, nil, nil, 1.12)
					attachPress(swatch, 0.82)

					connect(swatch.MouseButton1Click, function()
						if not control.Disabled then
							control:Set(color)
						end
					end)
				end

				window:RegisterConfig(options.Flag, control)
				window:AttachTooltip(row, options.Tooltip)
				return control
			end

			function sectionApi:AddStatGrid(names)
				local statGrid = make("Frame", {
					BackgroundTransparency = 1,
					LayoutOrder = self:NextOrder(),
					Size = UDim2.new(1, 0, 0, math.ceil(#names / 3) * 52),
					Parent = bodyFrame,
				}, {
					make("UIGridLayout", {
						CellPadding = UDim2.fromOffset(10, 10),
						CellSize = UDim2.new(0.333, -8, 0, 42),
						FillDirectionMaxCells = 3,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
				})
				addSearchRow(statGrid, table.concat(names, " "))

				local stats = {}
				for index, name in ipairs(names) do
					local stat = styledBackground(make("Frame", {
						BorderSizePixel = 0,
						LayoutOrder = index,
						Parent = statGrid,
					}, {
						corner(9),
						styledStroke(stroke(window.Theme.Stroke, 0.62, 1), "Stroke"),
					}), "Panel")
					attachHover(stat, "Panel", "PanelLight")

					styledText(DarkUI:Text({
						Font = DarkUI.Fonts.Bold,
						Parent = stat,
						Position = UDim2.fromOffset(10, 4),
						Size = UDim2.new(1, -20, 0, 14),
						Text = name,
						TextSize = 11,
					}), "Muted")

					local valueLabel = styledText(DarkUI:Text({
						Font = DarkUI.Fonts.Bold,
						Parent = stat,
						Position = UDim2.fromOffset(10, 20),
						Size = UDim2.new(1, -20, 0, 18),
						Text = "--",
						TextSize = 15,
					}), "Text")

					stats[name] = {
						Label = valueLabel,
						Set = function(_, nextValue, color)
							valueLabel.Text = tostring(nextValue)
							valueLabel.TextColor3 = color or window.Theme.Text
						end,
					}
				end

				return stats
			end

			function sectionApi:AddThemeManager()
				local themes = {}
				for name in pairs(DarkUI.ThemePresets) do
					table.insert(themes, name)
				end

				self:AddDropdown({
					Title = "Theme",
					Items = themes,
					Default = window.ThemeName,
					Flag = "ui_theme",
					Callback = function(value)
						window:SetTheme(value)
					end,
				})

				self:AddColorPicker({
					Title = "Accent",
					Default = window.Theme.Accent,
					Flag = "ui_accent",
					Callback = function(color)
						window:SetAccentColor(color)
					end,
				})
			end

			function sectionApi:AddConfigManager()
				local configName = self:AddTextBox({
					Title = "Config",
					Default = string.gsub(window.ConfigName, "%.json$", ""),
					Placeholder = "default",
				})

				self:AddButton({
					Title = "Save Config",
					Callback = function()
						window:SaveConfig(configName:Get())
					end,
				})

				self:AddButton({
					Title = "Load Config",
					Callback = function()
						window:LoadConfig(configName:Get())
					end,
				})

				self:AddButton({
					Title = "Delete Config",
					Callback = function()
						window:Confirm({
							Title = "Delete Config",
							Text = "Delete this config profile?",
							ConfirmText = "Delete",
							Callback = function()
								window:DeleteConfig(configName:Get())
							end,
						})
					end,
				})
			end

			return sectionApi
		end

		connect(tabButton.MouseButton1Click, function()
			window:SelectTab(tabName)
		end)

		if not self.SelectedTab then
			self:SelectTab(tabName)
		end

		return tab
	end

	function window:AddThemeManager(section)
		if section and section.AddThemeManager then
			section:AddThemeManager()
		end
	end

	function window:AddConfigManager(section)
		if section and section.AddConfigManager then
			section:AddConfigManager()
		end
	end

	function window:Destroy()
		if self.Destroyed then
			return
		end

		self.Destroyed = true
		for _, connection in ipairs(self.Connections) do
			pcall(function()
				connection:Disconnect()
			end)
		end

		self.Connections = {}
		tween(rootScale, { Scale = 0.94 }, 0.12)
		tween(root, { BackgroundTransparency = 1 }, 0.12)
		tween(shadow, { BackgroundTransparency = 1 }, 0.12)
		tween(glow, { BackgroundTransparency = 1 }, 0.12)
		task.delay(0.14, function()
			if screenGui.Parent then
				screenGui:Destroy()
			end
		end)
	end

	local expanded = true
	connect(minimizeButton.MouseButton1Click, function()
		expanded = not expanded
		minimizeButton.Text = expanded and "-" or "+"
		body.Visible = expanded
		tween(root, { Size = expanded and windowSize or collapsedSize }, 0.2)
		tween(shadow, { Size = expanded and windowSize or collapsedSize }, 0.2)
		tween(glow, { Size = expanded and glowSize(windowSize) or glowSize(collapsedSize) }, 0.2)
	end)

	connect(closeButton.MouseButton1Click, function()
		window:Confirm({
			Title = "Close UI",
			Text = "Close this window?",
			ConfirmText = "Close",
			Callback = function()
				window:Destroy()
			end,
		})
	end)

	local dragging = false
	local resizing = false
	local dragStart
	local startPosition
	local resizeStart
	local resizeStartSize
	local resizeStartPosition

	local function setWindowGeometry(size, position)
		windowSize = size
		collapsedSize = UDim2.fromOffset(windowSize.X.Offset, headerHeight)
		root.Size = expanded and windowSize or collapsedSize
		shadow.Size = root.Size
		glow.Size = glowSize(root.Size)

		if position then
			root.Position = position
			shadow.Position = UDim2.new(position.X.Scale, position.X.Offset + 6, position.Y.Scale, position.Y.Offset + 6)
			glow.Position = position
		end
	end

	connect(header.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if resizing then
				return
			end
			dragging = true
			dragStart = input.Position
			startPosition = root.Position
		end
	end)

	connect(resizeHandle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not expanded then
				expanded = true
				minimizeButton.Text = "-"
				body.Visible = true
			end

			resizing = true
			dragging = false
			resizeStart = input.Position
			resizeStartSize = windowSize
			resizeStartPosition = root.Position
			tween(getScale(resizeHandle), { Scale = 1.1 }, 0.1)
		end
	end)

	connect(UserInputService.InputChanged, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		if resizing then
			local delta = input.Position - resizeStart
			local nextWidth = math.max(minWindowSize.X, resizeStartSize.X.Offset + delta.X)
			local nextHeight = math.max(minWindowSize.Y, resizeStartSize.Y.Offset + delta.Y)
			local nextPosition = UDim2.new(
				resizeStartPosition.X.Scale,
				resizeStartPosition.X.Offset + ((nextWidth - resizeStartSize.X.Offset) / 2),
				resizeStartPosition.Y.Scale,
				resizeStartPosition.Y.Offset + ((nextHeight - resizeStartSize.Y.Offset) / 2)
			)
			setWindowGeometry(UDim2.fromOffset(nextWidth, nextHeight), nextPosition)
		elseif dragging then
			local delta = input.Position - dragStart
			local nextPosition = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
			root.Position = nextPosition
			shadow.Position = UDim2.new(nextPosition.X.Scale, nextPosition.X.Offset + 6, nextPosition.Y.Scale, nextPosition.Y.Offset + 6)
			glow.Position = nextPosition
		end
	end)

	connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			if resizing then
				resizing = false
				tween(getScale(resizeHandle), { Scale = 1 }, 0.12)
			end
		end
	end)

	connect(UserInputService.InputBegan, function(input, processed)
		if not processed and input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightShift) then
			screenGui.Enabled = not screenGui.Enabled
		end
	end)

	window:_applyTheme()
	return window
end

return DarkUI
