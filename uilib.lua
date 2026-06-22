-- Vxizi UI Library
-- Standalone Roblox Lua UI library.
-- Usage:
-- local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/user/repo/main/uilib.lua"))()
-- local window = UI:CreateWindow({ Title = "Vxizi", Icon = "rbxassetid://0" })

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player and player:WaitForChild("PlayerGui")

local DarkUI = {}
DarkUI.__index = DarkUI
DarkUI.Version = "1.3.46"
DarkUI.DefaultLogo = "https://github.com/x2Eterniz/UILIB/blob/main/logo_512_transparent.png"
DarkUI.DefaultLogoFallback = "rbxassetid://84134406429567"
DarkUI.DefaultButtonIcon = "https://github.com/x2Eterniz/UILIB/blob/main/play.png"
DarkUI.ImageCache = {}
DarkUI.DefaultTabIcons = {
	Home = "https://github.com/x2Eterniz/UILIB/blob/main/home_54x54.png",
	Location = "https://github.com/x2Eterniz/UILIB/blob/main/location_icon_54x54_transparent%20%281%29.png",
	Player = "https://github.com/x2Eterniz/UILIB/blob/main/player_54x54.png",
	Setting = "https://github.com/x2Eterniz/UILIB/blob/main/setting_icon_54x54_transparent.png",
}

local function getFont(fontName, fallback)
	local ok, font = pcall(function()
		return Enum.Font[fontName]
	end)

	return ok and font or fallback
end

local function getFontFace(family, weight, style)
	local ok, fontFace = pcall(function()
		return Font.new(
			family,
			weight or Enum.FontWeight.Regular,
			style or Enum.FontStyle.Normal
		)
	end)

	return ok and fontFace or nil
end

local function resolveContentId(value)
	if value == nil then
		return nil
	end

	if type(value) == "number" then
		return "rbxassetid://" .. tostring(math.floor(value))
	end

	local text = tostring(value or "")
	text = string.gsub(text, "^%s+", "")
	text = string.gsub(text, "%s+$", "")
	if text == "" then
		return nil
	end

	local lowered = string.lower(text)
	if string.find(lowered, "rbxassetid://", 1, true)
		or string.find(lowered, "rbxthumb://", 1, true)
		or string.find(lowered, "asset://", 1, true)
		or string.find(lowered, "http://", 1, true)
		or string.find(lowered, "https://", 1, true)
		or string.find(lowered, "data:", 1, true) then
		return text
	end

	local assetIdProtocol = string.match(text, "^assetid://(%d+)$")
	if assetIdProtocol then
		return "rbxassetid://" .. assetIdProtocol
	end

	local queryId = string.match(text, "[%?&]id=(%d+)")
	if queryId then
		return "rbxassetid://" .. queryId
	end

	local numericId = string.match(text, "^(%d+)$")
	if numericId then
		return "rbxassetid://" .. numericId
	end

	return text
end

local function toRawGithubUrl(url)
	local owner, repo, branch, path = string.match(url, "^https://github%.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)$")
	if owner and repo and branch and path then
		return ("https://raw.githubusercontent.com/%s/%s/%s/%s"):format(owner, repo, branch, path)
	end

	return url
end

local function safeFileName(text)
	text = tostring(text or "image")
	text = string.gsub(text, "[^%w_%-%.]", "_")
	text = string.gsub(text, "_+", "_")
	return text
end

local function hashText(text)
	text = tostring(text or "")
	local hash = 0
	for index = 1, #text do
		hash = (hash * 31 + string.byte(text, index)) % 1000000007
	end

	return tostring(hash)
end

local function resolveImageContent(value, cacheName, fallback)
	local contentId = resolveContentId(value)
	if not contentId then
		return fallback
	end

	local lowered = string.lower(contentId)
	local isExternal = string.find(lowered, "http://", 1, true) == 1 or string.find(lowered, "https://", 1, true) == 1
	if not isExternal then
		return contentId
	end

	local rawUrl = toRawGithubUrl(contentId)
	if DarkUI.ImageCache[rawUrl] then
		return DarkUI.ImageCache[rawUrl]
	end

	if type(writefile) == "function" and type(getcustomasset) == "function" then
		local extension = string.match(string.lower(rawUrl), "%.([%w]+)$") or string.match(string.lower(rawUrl), "%.([%w]+)%?") or "png"
		if extension ~= "png" and extension ~= "jpg" and extension ~= "jpeg" and extension ~= "webp" then
			extension = "png"
		end

		local fileName = safeFileName(("vxizi_ui_%s_%s.%s"):format(cacheName or "image", hashText(rawUrl), extension))
		local ok, response = pcall(function()
			return game:HttpGet(rawUrl)
		end)

		if ok and type(response) == "string" and #response > 0 then
			local wrote = pcall(function()
				writefile(fileName, response)
			end)

			if wrote then
				local assetOk, asset = pcall(function()
					return getcustomasset(fileName)
				end)

				if assetOk and asset then
					DarkUI.ImageCache[rawUrl] = asset
					return asset
				end
			end
		end
	end

	if fallback == false then
		return nil
	end

	return fallback or contentId
end

local function getDefaultTabIcon(tabName)
	local lowered = string.lower(tostring(tabName or ""))

	if string.find(lowered, "setting", 1, true)
		or string.find(lowered, "config", 1, true)
		or string.find(lowered, "ui", 1, true) then
		return DarkUI.DefaultTabIcons.Setting
	end

	if string.find(lowered, "player", 1, true)
		or string.find(lowered, "profile", 1, true)
		or string.find(lowered, "user", 1, true)
		or string.find(lowered, "webhook", 1, true)
		or string.find(lowered, "discord", 1, true) then
		return DarkUI.DefaultTabIcons.Player
	end

	if string.find(lowered, "location", 1, true)
		or string.find(lowered, "teleport", 1, true)
		or string.find(lowered, "world", 1, true)
		or string.find(lowered, "map", 1, true)
		or string.find(lowered, "macro", 1, true)
		or string.find(lowered, "movement", 1, true) then
		return DarkUI.DefaultTabIcons.Location
	end

	if string.find(lowered, "home", 1, true)
		or string.find(lowered, "main", 1, true)
		or string.find(lowered, "auto", 1, true)
		or string.find(lowered, "farm", 1, true)
		or string.find(lowered, "lobby", 1, true) then
		return DarkUI.DefaultTabIcons.Home
	end

	return nil
end

DarkUI.Fonts = {
	Title = getFont("GothamMedium", getFont("GothamSemibold", getFont("GothamBold", Enum.Font.SourceSansBold))),
	Bold = getFont("GothamMedium", getFont("GothamSemibold", getFont("GothamBold", Enum.Font.SourceSansBold))),
	Body = getFont("Gotham", getFont("SourceSans", Enum.Font.SourceSans)),
}
DarkUI.FontFaces = {
	Body = getFontFace("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
	Bold = getFontFace("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
	WindowTitle = getFontFace("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		or getFontFace("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
}
DarkUI.TextScale = 1
DarkUI.TextStrokeColor = Color3.fromRGB(27, 30, 35)
DarkUI.TextStrokeTransparency = 1

DarkUI.ThemePresets = {
	Dark = {
		Background = Color3.fromRGB(8, 10, 8),
		Surface = Color3.fromRGB(14, 15, 14),
		Panel = Color3.fromRGB(18, 19, 18),
		PanelLight = Color3.fromRGB(27, 29, 25),
		Tab = Color3.fromRGB(18, 20, 18),
		TabActive = Color3.fromRGB(31, 36, 24),
		Stroke = Color3.fromRGB(52, 57, 48),
		Text = Color3.fromRGB(242, 244, 237),
		Muted = Color3.fromRGB(158, 160, 151),
		Accent = Color3.fromRGB(199, 226, 61),
		Element = Color3.fromRGB(20, 21, 19),
		ElementBorder = Color3.fromRGB(43, 47, 40),
		InElementBorder = Color3.fromRGB(70, 76, 62),
		Input = Color3.fromRGB(34, 35, 32),
		InputFocused = Color3.fromRGB(43, 45, 40),
		InputIndicator = Color3.fromRGB(199, 226, 61),
		SliderRail = Color3.fromRGB(42, 45, 39),
		DropdownHolder = Color3.fromRGB(18, 19, 18),
		DropdownOption = Color3.fromRGB(34, 35, 32),
		TitleBarLine = Color3.fromRGB(45, 50, 41),
		BackgroundTransparency = 0.18,
		SurfaceTransparency = 0.18,
		PanelTransparency = 0.14,
		PanelLightTransparency = 0.08,
		TabTransparency = 0.16,
		TabActiveTransparency = 0.08,
		ElementTransparency = 0.12,
		InputTransparency = 0.08,
		DropdownHolderTransparency = 0.08,
		DropdownOptionTransparency = 0.1,
		Success = Color3.fromRGB(199, 226, 61),
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

local function completeTheme(theme)
	local base = DarkUI.ThemePresets.Dark
	for key, value in pairs(base) do
		if theme[key] == nil then
			theme[key] = value
		end
	end

	theme.Element = theme.Element or theme.Panel
	theme.ElementBorder = theme.ElementBorder or theme.Stroke
	theme.InElementBorder = theme.InElementBorder or theme.Stroke
	theme.Input = theme.Input or theme.Panel
	theme.InputFocused = theme.InputFocused or theme.Surface
	theme.InputIndicator = theme.InputIndicator or theme.Muted
	theme.SliderRail = theme.SliderRail or theme.Element
	theme.DropdownHolder = theme.DropdownHolder or theme.Panel
	theme.DropdownOption = theme.DropdownOption or theme.Element
	theme.TitleBarLine = theme.TitleBarLine or theme.Stroke

	return theme
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
	local tweenInfo = TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
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

local function mixColor(fromColor, toColor, alpha)
	alpha = math.clamp(alpha or 0, 0, 1)
	return Color3.new(
		fromColor.R + (toColor.R - fromColor.R) * alpha,
		fromColor.G + (toColor.G - fromColor.G) * alpha,
		fromColor.B + (toColor.B - fromColor.B) * alpha
	)
end

local function accentGradient(accent)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, mixColor(accent, Color3.new(1, 1, 1), 0.28)),
		ColorSequenceKeypoint.new(0.48, accent),
		ColorSequenceKeypoint.new(1, mixColor(accent, Color3.new(0, 0, 0), 0.2)),
	})
end

local function flatTransparency(value)
	return NumberSequence.new(value)
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

	local label = make("TextLabel", {
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
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

	local fontFace = props.FontFace
	if not fontFace and self.FontFaces then
		fontFace = (props.Font == self.Fonts.Bold or props.Font == self.Fonts.Title) and self.FontFaces.Bold or self.FontFaces.Body
	end

	if fontFace then
		pcall(function()
			label.FontFace = fontFace
		end)
	end

	return label
end

function DarkUI:CreateWindow(config)
	config = config or {}

	local themeName = config.Theme or "Dark"
	local theme = completeTheme(copyTable(DarkUI.ThemePresets[themeName] or DarkUI.ThemePresets.Dark))
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
		BuiltInSettings = config.BuiltInSettings ~= false,
		BuiltInSettingsCreated = false,
		BuiltInSettingsTab = nil,
		BuiltInSettingsTabName = config.SettingsTabName or config.BuiltInSettingsTabName or "Setting",
		AutoSettingsTabName = nil,
		UserTabCount = 0,
		DragFPSCap = tonumber(config.DragFPSCap) or 60,
		UseDragSkeleton = config.UseDragSkeleton == true,
		FullVisibilityAnimation = config.FullVisibilityAnimation ~= false,
		DropdownsOutsideWindow = config.DropdownsOutsideWindow == true,
		Acrylic = config.Acrylic ~= false,
		Borderless = config.Borderless ~= false,
		Shadow = config.Shadow == true,
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
		instance.BackgroundColor3 = window.Theme[key] or window.Theme.Panel
		if window.Acrylic then
			local transparency = window.Theme[key .. "Transparency"]
			if transparency ~= nil then
				instance.BackgroundTransparency = transparency
			end
		end
		return instance
	end

	local function styledText(instance, key)
		instance:SetAttribute("DarkUIText", key)
		instance.TextColor3 = window.Theme[key] or window.Theme.Text

		if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
			if not instance:GetAttribute("DarkUITextScaled") then
				instance.TextSize = math.floor((instance.TextSize * window.TextScale) + 0.5)
				instance:SetAttribute("DarkUITextScaled", true)
			end

			if not instance:GetAttribute("DarkUIFontFaceApplied") and DarkUI.FontFaces then
				local fontFace = (instance.Font == DarkUI.Fonts.Bold or instance.Font == DarkUI.Fonts.Title) and DarkUI.FontFaces.Bold or DarkUI.FontFaces.Body
				if fontFace then
					pcall(function()
						instance.FontFace = fontFace
					end)
					instance:SetAttribute("DarkUIFontFaceApplied", true)
				end
			end

			instance.TextStrokeColor3 = DarkUI.TextStrokeColor
			instance.TextStrokeTransparency = 1
		end

		return instance
	end

	local function styledStroke(instance, key)
		instance:SetAttribute("DarkUIStroke", key)
		instance.Color = window.Theme[key] or window.Theme.Stroke
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
					BackgroundColor3 = window.Theme[hoverKey] or window.Theme.PanelLight,
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
					BackgroundColor3 = window.Theme[normalKey] or window.Theme.Panel,
				}, 0.12)
			end

			if hoverScale then
				tween(getScale(guiObject), {
					Scale = 1,
				}, 0.12)
			end
		end)
	end

	local showTitleBar = config.TitleBar == true or config.ShowTitleBar == true
	local iconOnlyTabs = config.IconOnlyTabs ~= false
	local headerHeight = showTitleBar and 44 or 0
	local tabHeight = config.TabHeight or (iconOnlyTabs and 56 or 42)
	local searchHeight = config.Search == true and 34 or 0
	local footerHeight = (config.Footer == true and not iconOnlyTabs) and 54 or 0
	local navWidth = config.NavWidth or config.TabWidth or (iconOnlyTabs and 82 or 168)
	local windowSize = config.Size or UDim2.fromOffset(660, 460)
	local collapsedSize = UDim2.fromOffset(windowSize.X.Offset, headerHeight)
	local windowPosition = config.Position or UDim2.fromScale(0.5, 0.5)
	local configuredLogo = config.Icon or config.Logo or config.HubIcon
	local windowIcon = resolveImageContent(configuredLogo or DarkUI.DefaultLogo, "logo", configuredLogo and nil or DarkUI.DefaultLogoFallback)
	local minWindowSize = config.MinSize or Vector2.new(520, 360)
	local resizable = config.Resizable ~= false
	local gripSize = math.max(30, tonumber(config.ResizeGripSize) or 44)

	local function glowSize(size)
		return UDim2.new(size.X.Scale, size.X.Offset + 12, size.Y.Scale, size.Y.Offset + 12)
	end

	local rootTransparency = window.Acrylic and (theme.BackgroundTransparency or 0.18) or 0
	local shadowVisibleTransparency = window.Shadow and (window.Acrylic and 0.82 or 0.64) or 1
	local glowVisibleTransparency = window.Borderless and 1 or (window.Acrylic and 0.995 or 0.975)
	local glowStrokeTransparency = window.Borderless and 1 or 0.66
	local rootStrokeTransparency = window.Borderless and 1 or 0.08

	local shadow = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = shadowVisibleTransparency,
		BorderSizePixel = 0,
		Position = UDim2.new(windowPosition.X.Scale, windowPosition.X.Offset + 5, windowPosition.Y.Scale, windowPosition.Y.Offset + 7),
		Size = windowSize,
		Parent = screenGui,
	}, {
		corner(18),
	})

	local glowStroke = stroke(theme.Accent, glowStrokeTransparency, 1)
	glowStroke.Name = "DarkUIGlowStroke"
	local glowStrokeGradient = make("UIGradient", {
		Name = "DarkUIWindowBorderGradient",
		Rotation = 45,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, theme.TitleBarLine),
			ColorSequenceKeypoint.new(0.5, theme.Accent),
			ColorSequenceKeypoint.new(1, theme.TitleBarLine),
		}),
		Parent = glowStroke,
	})
	local glow = make("Frame", {
		Name = "DarkUIGlow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = glowVisibleTransparency,
		BorderSizePixel = 0,
		Position = windowPosition,
		Size = glowSize(windowSize),
		Parent = screenGui,
	}, {
		corner(20),
		glowStroke,
	})

	local rootStroke = stroke(theme.Stroke, rootStrokeTransparency, 1)
	rootStroke.Name = "DarkUIRootStroke"
	make("UIGradient", {
		Name = "DarkUIWindowBorderGradient",
		Rotation = 45,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, theme.Stroke),
			ColorSequenceKeypoint.new(0.5, theme.Accent),
			ColorSequenceKeypoint.new(1, theme.Stroke),
		}),
		Parent = rootStroke,
	})

	local root = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Background,
		BackgroundTransparency = rootTransparency,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = windowPosition,
		Size = windowSize,
		Parent = screenGui,
	}, {
		corner(18),
		rootStroke,
	})
	root:SetAttribute("DarkUIBackground", "Background")
	rootStroke:SetAttribute("DarkUIStroke", "Stroke")

	local rootScale = make("UIScale", {
		Scale = 0.96,
		Parent = root,
	})

	tween(rootScale, { Scale = 1 }, 0.25)

	local header = styledBackground(make("Frame", {
		Name = "Header",
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, headerHeight),
		Visible = showTitleBar,
		ZIndex = 50,
		Parent = root,
	}, {
		corner(18),
	}), "Background")

	styledBackground(make("Frame", {
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -7),
		Size = UDim2.new(1, 0, 0, 7),
		ZIndex = 50,
		Parent = header,
	}), "Background")

	local titleBarLine = make("Frame", {
		Name = "DarkUITitleBarLine",
		BorderSizePixel = 0,
		BackgroundColor3 = theme.TitleBarLine,
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 51,
		Parent = header,
	})
	titleBarLine:SetAttribute("DarkUIBackground", "TitleBarLine")

	if showTitleBar and windowIcon then
		make("ImageLabel", {
			BackgroundTransparency = 1,
			Image = windowIcon,
			Position = UDim2.fromOffset(14, 12),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromOffset(20, 20),
			ZIndex = 52,
			Parent = header,
		})
	end

	local titleOffset = windowIcon and 40 or 15
	local title = styledText(DarkUI:Text({
		Font = DarkUI.Fonts.Title,
		FontFace = config.TitleFontFace or DarkUI.FontFaces.WindowTitle,
		Parent = header,
		Position = UDim2.fromOffset(titleOffset, 7),
		RichText = true,
		Size = UDim2.new(1, -142 - titleOffset, 0, 18),
		Text = config.Title or "Vxizi Hub",
		TextSize = 13,
	}), "Text")
	title.ZIndex = 52
	title.Visible = showTitleBar

	local subtitle = styledText(DarkUI:Text({
		Font = DarkUI.Fonts.Body,
		Parent = header,
		Position = UDim2.fromOffset(titleOffset, 24),
		Size = UDim2.new(1, -142 - titleOffset, 0, 14),
		Text = config.Subtitle or "clean dark interface",
		TextSize = 10,
	}), "Muted")
	subtitle.ZIndex = 52
	subtitle.Visible = showTitleBar

	local statusPill = styledBackground(make("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		BorderSizePixel = 0,
		Font = DarkUI.Fonts.Bold,
		Position = UDim2.new(1, -91, 0.5, 0),
		Size = UDim2.fromOffset(74, 24),
		Text = "WORKING",
		TextSize = 10,
		Visible = showTitleBar and config.Status == true,
		ZIndex = 52,
		Parent = header,
	}, {
		corner(6),
	}), "Panel")
	styledText(statusPill, "Accent")

	local minimizeButton = styledBackground(make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = DarkUI.Fonts.Bold,
		Position = UDim2.new(1, -47, 0.5, 0),
		Size = UDim2.fromOffset(24, 24),
		Text = "-",
		TextSize = 14,
		ZIndex = 52,
		Parent = header,
	}, {
		corner(6),
	}), "Background")
	styledText(minimizeButton, "Text")
	attachHover(minimizeButton, "Background", "Panel", 1.04)
	attachPress(minimizeButton, 0.88)

	local closeButton = styledBackground(make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = DarkUI.Fonts.Bold,
		Position = UDim2.new(1, -16, 0.5, 0),
		Size = UDim2.fromOffset(24, 24),
		Text = "x",
		TextSize = 13,
		ZIndex = 52,
		Parent = header,
	}, {
		corner(6),
	}), "Background")
	styledText(closeButton, "Text")
	attachHover(closeButton, "Background", "Panel", 1.04)
	attachPress(closeButton, 0.88)

	local body = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, headerHeight),
		Size = UDim2.new(1, 0, 1, -headerHeight),
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
		Position = iconOnlyTabs and UDim2.fromOffset(12, 12) or UDim2.new(),
		Size = iconOnlyTabs and UDim2.new(0, navWidth, 1, -footerHeight - 24) or UDim2.new(0, navWidth, 1, -footerHeight),
		Parent = body,
	}, {
		corner(iconOnlyTabs and 22 or 0),
	}), "Background")

	if not iconOnlyTabs then
		styledBackground(make("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, 1, 1, 0),
			Parent = navPanel,
		}), "TitleBarLine")
	end

	local railLogoHeight = 0
	if iconOnlyTabs and windowIcon then
		railLogoHeight = 76

		local logoFrame = styledBackground(make("Frame", {
			Name = "DarkUIRailLogo",
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(math.floor((navWidth - 58) / 2), 14),
			Size = UDim2.fromOffset(58, 58),
			Parent = navPanel,
		}, {
			corner(20),
			styledStroke(stroke(theme.Accent, 0.54, 1), "Accent"),
		}), "Panel")

		make("ImageLabel", {
			BackgroundTransparency = 1,
			Image = windowIcon,
			Position = UDim2.fromOffset(8, 8),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromOffset(42, 42),
			ZIndex = 2,
			Parent = logoFrame,
		})
	end

	local navBrandText = tostring(config.NavBrand or "")
	local hasNavBrand = (not iconOnlyTabs) and navBrandText ~= ""
	local navHeaderHeight = hasNavBrand and 48 or 0
	local navHeader = make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, navHeaderHeight),
		Parent = navPanel,
	})

	local navHeaderOffset = 12
	if hasNavBrand and windowIcon then
		make("ImageLabel", {
			BackgroundTransparency = 1,
			Image = windowIcon,
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
	local iconTabsStartY = railLogoHeight > 0 and railLogoHeight + 12 or 12
	local tabs = make("ScrollingFrame", {
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarImageColor3 = theme.Accent,
		ScrollBarImageTransparency = iconOnlyTabs and 1 or 0.42,
		ScrollBarThickness = iconOnlyTabs and 0 or 2,
		Position = UDim2.fromOffset(0, iconOnlyTabs and iconTabsStartY or navTabsStartY),
		Size = UDim2.new(1, 0, 1, -((iconOnlyTabs and (iconTabsStartY + 12) or navTabsStartY + 6))),
		Parent = navPanel,
	}, {
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, iconOnlyTabs and 10 or 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = iconOnlyTabs and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left,
		}),
		make("UIPadding", {
			PaddingLeft = UDim.new(0, iconOnlyTabs and 0 or 10),
			PaddingRight = UDim.new(0, iconOnlyTabs and 0 or 10),
			PaddingTop = UDim.new(0, iconOnlyTabs and 0 or 6),
			PaddingBottom = UDim.new(0, 4),
		}),
	})

	local activeRailGlowOuter = nil
	local activeRailGlowMid = nil
	local activeRailIndicator = nil
	local activeRailIndicatorX = 0
	if iconOnlyTabs then
		activeRailGlowOuter = styledBackground(make("Frame", {
			Name = "DarkUITabRailGlowOuter",
			BackgroundTransparency = 0.78,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(activeRailIndicatorX - 3, iconTabsStartY - 9),
			Size = UDim2.fromOffset(20, 48),
			Visible = false,
			ZIndex = 18,
			Parent = navPanel,
		}, {
			corner(999),
			make("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.22, 0.84),
					NumberSequenceKeypoint.new(0.5, 0.48),
					NumberSequenceKeypoint.new(0.78, 0.84),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),
		}), "Accent")

		activeRailGlowMid = styledBackground(make("Frame", {
			Name = "DarkUITabRailGlowMid",
			BackgroundTransparency = 0.55,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(activeRailIndicatorX - 1, iconTabsStartY - 5),
			Size = UDim2.fromOffset(14, 40),
			Visible = false,
			ZIndex = 19,
			Parent = navPanel,
		}, {
			corner(999),
			make("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.24, 0.66),
					NumberSequenceKeypoint.new(0.5, 0.16),
					NumberSequenceKeypoint.new(0.76, 0.66),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),
		}), "Accent")

		activeRailIndicator = styledBackground(make("Frame", {
			Name = "DarkUITabRailIndicator",
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(activeRailIndicatorX, iconTabsStartY),
			Size = UDim2.fromOffset(4, 30),
			Visible = false,
			ZIndex = 21,
			Parent = navPanel,
		}, {
			corner(999),
		}), "Accent")
	end

	local contentPanel = make("Frame", {
		BackgroundTransparency = 1,
		Position = iconOnlyTabs and UDim2.new(0, navWidth + 28, 0, 12) or UDim2.new(0, navWidth + 18, 0, 12),
		Size = iconOnlyTabs and UDim2.new(1, -navWidth - 40, 1, -footerHeight - 24) or UDim2.new(1, -navWidth - 30, 1, -footerHeight - 24),
		Parent = body,
	})

	local searchBox
	local searchClear
	if config.Search == true then
		local searchStroke = styledStroke(stroke(theme.Stroke, 0.35, 1), "Stroke")
		local searchBar = styledBackground(make("Frame", {
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 0, 34),
			Parent = contentPanel,
		}, {
			corner(5),
			searchStroke,
		}), "Panel")

		styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Bold,
			Parent = searchBar,
			Position = UDim2.fromOffset(13, 0),
			Size = UDim2.fromOffset(54, 34),
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
			TextSize = 13,
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
		}), "DropdownHolder")
		searchClear.BackgroundTransparency = 0.04
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

	local contentTopOffset = (config.Search == true) and (searchHeight + 6) or 0
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

	local function paintFooterIcon(parts, color, animated)
		for _, part in ipairs(parts or {}) do
			if part and part.Parent then
				if animated then
					tween(part, {
						BackgroundColor3 = color,
					}, 0.14)
				else
					part.BackgroundColor3 = color
				end
			end
		end
	end

	local function setFooterActive(role, animated)
		footerActiveRole = role or "Home"
		window.FooterRole = footerActiveRole

		for buttonRole, refs in pairs(footerButtons) do
			local active = buttonRole == footerActiveRole
			local targetBackground = window.Theme[active and "Panel" or "Surface"]
			local targetIconColor = window.Theme[active and "Accent" or "Text"]
			local targetTextColor = window.Theme[active and "Text" or "Muted"]
			local strokeObject = refs.Button:FindFirstChildOfClass("UIStroke")

			refs.Button:SetAttribute("DarkUIBackground", active and "Panel" or "Surface")
			refs.Label:SetAttribute("DarkUIText", active and "Text" or "Muted")
			refs.Button:SetAttribute("DarkUIFooterActive", active)

			if animated then
				tween(refs.Button, {
					BackgroundColor3 = targetBackground,
				}, 0.14)
				paintFooterIcon(refs.IconParts, targetIconColor, true)
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
				paintFooterIcon(refs.IconParts, targetIconColor, false)
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

			local footerIconHost = make("Frame", {
				Name = "DarkUIFooterIcon",
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, -8, 0, 4),
				Size = UDim2.fromOffset(16, 16),
				Parent = button,
			})

			local iconParts = {}
			local function iconPart(props, radius)
				props.BorderSizePixel = 0
				props.BackgroundColor3 = active and theme.Accent or theme.Text
				props.Parent = footerIconHost
				local part = make("Frame", props, radius and { corner(radius) } or nil)
				table.insert(iconParts, part)
				return part
			end

			if roleName == "Setting" then
				iconPart({
					Position = UDim2.fromOffset(6, 6),
					Size = UDim2.fromOffset(4, 4),
				}, 999)
				iconPart({ Position = UDim2.fromOffset(7, 1), Size = UDim2.fromOffset(2, 3) }, 1)
				iconPart({ Position = UDim2.fromOffset(7, 12), Size = UDim2.fromOffset(2, 3) }, 1)
				iconPart({ Position = UDim2.fromOffset(1, 7), Size = UDim2.fromOffset(3, 2) }, 1)
				iconPart({ Position = UDim2.fromOffset(12, 7), Size = UDim2.fromOffset(3, 2) }, 1)
				iconPart({ Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(2, 2) }, 1)
				iconPart({ Position = UDim2.fromOffset(11, 3), Size = UDim2.fromOffset(2, 2) }, 1)
				iconPart({ Position = UDim2.fromOffset(3, 11), Size = UDim2.fromOffset(2, 2) }, 1)
				iconPart({ Position = UDim2.fromOffset(11, 11), Size = UDim2.fromOffset(2, 2) }, 1)
			else
				iconPart({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromOffset(6, 6),
					Size = UDim2.fromOffset(7, 2),
					Rotation = -45,
				}, 999)
				iconPart({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromOffset(10, 6),
					Size = UDim2.fromOffset(7, 2),
					Rotation = 45,
				}, 999)
				iconPart({ Position = UDim2.fromOffset(3, 8), Size = UDim2.fromOffset(2, 6) }, 1)
				iconPart({ Position = UDim2.fromOffset(11, 8), Size = UDim2.fromOffset(2, 6) }, 1)
				iconPart({ Position = UDim2.fromOffset(3, 13), Size = UDim2.fromOffset(10, 2) }, 1)
				iconPart({ Position = UDim2.fromOffset(7, 10), Size = UDim2.fromOffset(2, 4) }, 1)
			end

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
				IconParts = iconParts,
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

	local uiVisible = true
	local floatingToggle
	local floatingToggleText
	local floatingLockText
	local floatingLocked = false

	local function setUiVisible(visible, animated)
		uiVisible = visible == true
		if window.FullVisibilityAnimation == false then
			animated = false
		end

		if floatingToggleText then
			floatingToggleText.Text = uiVisible and "Close" or "Open"
		end

		if uiVisible then
			root.Visible = true
			shadow.Visible = true
			glow.Visible = true
			if animated ~= false then
				rootScale.Scale = 0.94
				tween(rootScale, { Scale = 1 }, 0.18)
				tween(shadow, { BackgroundTransparency = shadowVisibleTransparency }, 0.18)
				tween(glow, { BackgroundTransparency = glowVisibleTransparency }, 0.18)
			end
		else
			if animated ~= false then
				tween(rootScale, { Scale = 0.94 }, 0.14)
				tween(shadow, { BackgroundTransparency = 1 }, 0.14)
				tween(glow, { BackgroundTransparency = 1 }, 0.14)
				task.delay(0.15, function()
					if not uiVisible and root.Parent then
						root.Visible = false
						shadow.Visible = false
						glow.Visible = false
					end
				end)
			else
				root.Visible = false
				shadow.Visible = false
				glow.Visible = false
			end
		end
	end

	if config.FloatingToggle ~= false then
		floatingToggle = styledBackground(make("Frame", {
			Name = "DarkUIFloatingToggle",
			BackgroundTransparency = 0.03,
			BorderSizePixel = 0,
			Position = config.FloatingPosition or UDim2.new(0, 20, 1, -68),
			Size = UDim2.fromOffset(118, 44),
			ZIndex = 240,
			Parent = screenGui,
		}, {
			corner(10),
			styledStroke(stroke(theme.Stroke, 0.16, 1), "Stroke"),
		}), "Surface")

		make("UIGradient", {
			Name = "DarkUIWindowBorderGradient",
			Rotation = 25,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, theme.Surface),
				ColorSequenceKeypoint.new(0.55, theme.Panel),
				ColorSequenceKeypoint.new(1, theme.Accent),
			}),
			Parent = floatingToggle,
		})

		local dragLayer = make("TextButton", {
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			ZIndex = 241,
			Parent = floatingToggle,
		})

		local openButton = styledBackground(make("TextButton", {
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(6, 6),
			Size = UDim2.new(1, -42, 1, -12),
			Text = uiVisible and "Close" or "Open",
			TextSize = 13,
			ZIndex = 242,
			Parent = floatingToggle,
		}, {
			corner(7),
		}), "Element")
		styledText(openButton, "Text")
		pcall(function()
			openButton.FontFace = DarkUI.FontFaces.Bold
		end)
		floatingToggleText = openButton

		local lockButton = styledBackground(make("TextButton", {
			AnchorPoint = Vector2.new(1, 0),
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -6, 0, 6),
			Size = UDim2.fromOffset(30, 32),
			Text = "L",
			TextSize = 13,
			ZIndex = 242,
			Parent = floatingToggle,
		}, {
			corner(7),
		}), "Background")
		styledText(lockButton, "Muted")
		pcall(function()
			lockButton.FontFace = DarkUI.FontFaces.Bold
		end)
		floatingLockText = lockButton

		attachHover(openButton, "Element", "PanelLight", 1.02)
		attachHover(lockButton, "Background", "PanelLight", 1.02)
		attachPress(openButton, 0.92)
		attachPress(lockButton, 0.9)

		connect(openButton.MouseButton1Click, function()
			setUiVisible(not uiVisible)
		end)

		connect(lockButton.MouseButton1Click, function()
			floatingLocked = not floatingLocked
			floatingLockText.Text = floatingLocked and "X" or "L"
			tween(lockButton, {
				BackgroundColor3 = floatingLocked and window.Theme.Accent or window.Theme.Background,
			}, 0.12)
			tween(lockButton, {
				TextColor3 = floatingLocked and window.Theme.Background or window.Theme.Muted,
			}, 0.12)
		end)

		local floatDragging = false
		local floatDragStart
		local floatStartPosition
		connect(dragLayer.InputBegan, function(input)
			if floatingLocked then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				floatDragging = true
				floatDragStart = input.Position
				floatStartPosition = floatingToggle.Position
			end
		end)
		connect(UserInputService.InputChanged, function(input)
			if floatDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - floatDragStart
				floatingToggle.Position = UDim2.new(
					floatStartPosition.X.Scale,
					floatStartPosition.X.Offset + delta.X,
					floatStartPosition.Y.Scale,
					floatStartPosition.Y.Offset + delta.Y
				)
			end
		end)
		connect(UserInputService.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				floatDragging = false
			end
		end)
	end

	window.Gui = screenGui
	window.Root = root
	window.Shadow = shadow
	window.Glow = glow
	window.FloatingToggle = floatingToggle
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
				descendant.BackgroundColor3 = self.Theme[backgroundKey] or self.Theme.Panel
				if self.Acrylic then
					local transparency = self.Theme[backgroundKey .. "Transparency"]
					if transparency ~= nil then
						descendant.BackgroundTransparency = transparency
					end
				end
			end

			if textKey and (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) then
				descendant.TextColor3 = self.Theme[textKey] or self.Theme.Text
				descendant.TextStrokeColor3 = DarkUI.TextStrokeColor
				descendant.TextStrokeTransparency = 1
				if descendant:IsA("TextBox") then
					descendant.PlaceholderColor3 = self.Theme.Muted
				end
			end

			if strokeKey and descendant:IsA("UIStroke") then
				descendant.Color = self.Theme[strokeKey] or self.Theme.Stroke
			end

			if descendant.Name == "DarkUIAccent" and descendant:IsA("Frame") and not backgroundKey then
				descendant.BackgroundColor3 = self.Theme.Accent
			elseif descendant.Name == "DarkUIAccentGradient" and descendant:IsA("UIGradient") then
				descendant.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, self.Theme.TitleBarLine),
					ColorSequenceKeypoint.new(0.5, self.Theme.Accent),
					ColorSequenceKeypoint.new(1, self.Theme.TitleBarLine),
				})
			elseif descendant.Name == "DarkUIWindowBorderGradient" and descendant:IsA("UIGradient") then
				descendant.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, self.Theme.Stroke),
					ColorSequenceKeypoint.new(0.5, self.Theme.Accent),
					ColorSequenceKeypoint.new(1, self.Theme.TitleBarLine),
				})
			elseif descendant.Name == "DarkUITabButtonGradient" and descendant:IsA("UIGradient") then
				descendant.Color = accentGradient(self.Theme.Accent)
			elseif descendant.Name == "DarkUITabActiveGlow" and descendant:IsA("Frame") then
				descendant.BackgroundColor3 = self.Theme.Text
			elseif descendant.Name == "DarkUIGlow" and descendant:IsA("Frame") then
				descendant.BackgroundColor3 = self.Theme.Accent
			elseif descendant.Name == "DarkUIGlowStroke" and descendant:IsA("UIStroke") then
				descendant.Color = self.Theme.Accent
				descendant.Transparency = self.Borderless and 1 or glowStrokeTransparency
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
			self.Theme = completeTheme(copyTable(DarkUI.ThemePresets[nameOrTheme]))
		elseif type(nameOrTheme) == "table" then
			for key, value in pairs(nameOrTheme) do
				self.Theme[key] = value
			end
			completeTheme(self.Theme)
		end

		self:_applyTheme()
	end

	function window:SetStatus(text, good)
		statusPill.Text = text or "READY"
		statusPill.Visible = true
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
			TextSize = 14,
		}), "Text")

		styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Body,
			Parent = note,
			Position = UDim2.fromOffset(15, 31),
			Size = UDim2.new(1, -30, 0, 34),
			Text = message or "",
			TextSize = 12,
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
		}), "DropdownHolder")
		dialog.BackgroundTransparency = 0.03
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
			TextSize = 16,
		}), "Text")
		confirmTitle.ZIndex = 102

		local confirmBody = styledText(DarkUI:Text({
			Font = DarkUI.Fonts.Body,
			Parent = dialog,
			Position = UDim2.fromOffset(18, 44),
			Size = UDim2.new(1, -36, 0, 52),
			Text = options.Text or options.Message or "Are you sure?",
			TextSize = 13,
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
		}), "Input")
		styledText(cancel, "Text")
		attachHover(cancel, "Input", "Panel", 1.03)
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
		}), "Input")
		styledText(confirm, "Accent")
		attachHover(confirm, "Input", "Panel", 1.03)
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

	local function paintTabIcon(tabButton, color, animated)
		for _, descendant in ipairs(tabButton:GetDescendants()) do
			if descendant.Name == "TabIconPart" and descendant:IsA("Frame") then
				if animated then
					tween(descendant, { BackgroundColor3 = color }, 0.14)
				else
					descendant.BackgroundColor3 = color
				end
			elseif descendant.Name == "TabIconImage" and descendant:IsA("ImageLabel") then
				if animated then
					tween(descendant, { ImageColor3 = color }, 0.14)
				else
					descendant.ImageColor3 = color
				end
			elseif descendant.Name == "TabIconStroke" and descendant:IsA("UIStroke") then
				if animated then
					tween(descendant, { Color = color }, 0.14)
				else
					descendant.Color = color
				end
			end
		end
	end

	local function createTabGlyph(parent, tabName, iconId)
		local host = make("Frame", {
			Name = "TabIconHost",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(28, 28),
			ZIndex = 4,
			Parent = parent,
		})

		if iconId then
			make("ImageLabel", {
				Name = "TabIconImage",
				BackgroundTransparency = 1,
				Image = iconId,
				ImageColor3 = window.Theme.Muted,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 5,
				Parent = host,
			})
			return host
		end

		local lowered = string.lower(tostring(tabName or ""))
		local kind = "misc"
		if string.find(lowered, "setting", 1, true) or string.find(lowered, "config", 1, true) then
			kind = "settings"
		elseif string.find(lowered, "webhook", 1, true) or string.find(lowered, "discord", 1, true) then
			kind = "webhook"
		elseif string.find(lowered, "macro", 1, true) then
			kind = "macro"
		elseif string.find(lowered, "auto", 1, true) or string.find(lowered, "farm", 1, true) or string.find(lowered, "main", 1, true) then
			kind = "home"
		elseif string.find(lowered, "input", 1, true) then
			kind = "input"
		end

		local function part(props, radius)
			props.Name = "TabIconPart"
			props.BorderSizePixel = 0
			props.BackgroundColor3 = window.Theme.Muted
			props.ZIndex = 5
			props.Parent = host
			return make("Frame", props, { corner(radius or 2) })
		end

		local function outline(props, radius)
			props.BackgroundTransparency = 1
			props.BorderSizePixel = 0
			props.ZIndex = 5
			props.Parent = host
			return make("Frame", props, {
				corner(radius or 6),
				make("UIStroke", {
					Name = "TabIconStroke",
					Color = window.Theme.Muted,
					Thickness = 2,
					Transparency = 0.12,
				}),
			})
		end

		if kind == "settings" then
			part({ Position = UDim2.fromOffset(12, 12), Size = UDim2.fromOffset(4, 4) }, 999)
			part({ Position = UDim2.fromOffset(13, 3), Size = UDim2.fromOffset(2, 6) }, 1)
			part({ Position = UDim2.fromOffset(13, 19), Size = UDim2.fromOffset(2, 6) }, 1)
			part({ Position = UDim2.fromOffset(3, 13), Size = UDim2.fromOffset(6, 2) }, 1)
			part({ Position = UDim2.fromOffset(19, 13), Size = UDim2.fromOffset(6, 2) }, 1)
			part({ Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(5, 2), Rotation = 45 }, 1)
			part({ Position = UDim2.fromOffset(17, 20), Size = UDim2.fromOffset(5, 2), Rotation = 45 }, 1)
			part({ Position = UDim2.fromOffset(18, 6), Size = UDim2.fromOffset(5, 2), Rotation = -45 }, 1)
			part({ Position = UDim2.fromOffset(6, 20), Size = UDim2.fromOffset(5, 2), Rotation = -45 }, 1)
		elseif kind == "webhook" then
			outline({ Position = UDim2.fromOffset(5, 6), Size = UDim2.fromOffset(18, 14) }, 5)
			part({ Position = UDim2.fromOffset(9, 19), Size = UDim2.fromOffset(8, 2), Rotation = -28 }, 1)
			part({ Position = UDim2.fromOffset(9, 11), Size = UDim2.fromOffset(10, 2) }, 1)
			part({ Position = UDim2.fromOffset(9, 15), Size = UDim2.fromOffset(7, 2) }, 1)
		elseif kind == "macro" then
			part({ Position = UDim2.fromOffset(7, 7), Size = UDim2.fromOffset(3, 14), Rotation = -45 }, 2)
			part({ Position = UDim2.fromOffset(7, 7), Size = UDim2.fromOffset(3, 14), Rotation = 45 }, 2)
			part({ Position = UDim2.fromOffset(17, 7), Size = UDim2.fromOffset(3, 14), Rotation = -45 }, 2)
			part({ Position = UDim2.fromOffset(17, 7), Size = UDim2.fromOffset(3, 14), Rotation = 45 }, 2)
		elseif kind == "input" then
			outline({ Position = UDim2.fromOffset(5, 6), Size = UDim2.fromOffset(18, 16) }, 4)
			part({ Position = UDim2.fromOffset(9, 11), Size = UDim2.fromOffset(10, 2) }, 1)
			part({ Position = UDim2.fromOffset(9, 16), Size = UDim2.fromOffset(7, 2) }, 1)
		elseif kind == "home" then
			part({ Position = UDim2.fromOffset(7, 13), Size = UDim2.fromOffset(14, 10) }, 2)
			part({ Position = UDim2.fromOffset(6, 10), Size = UDim2.fromOffset(12, 3), Rotation = -35 }, 2)
			part({ Position = UDim2.fromOffset(14, 10), Size = UDim2.fromOffset(12, 3), Rotation = 35 }, 2)
			part({ Position = UDim2.fromOffset(13, 17), Size = UDim2.fromOffset(3, 6) }, 1)
		else
			part({ Position = UDim2.fromOffset(6, 7), Size = UDim2.fromOffset(3, 15), Rotation = 45 }, 2)
			part({ Position = UDim2.fromOffset(19, 7), Size = UDim2.fromOffset(3, 15), Rotation = -45 }, 2)
			part({ Position = UDim2.fromOffset(7, 13), Size = UDim2.fromOffset(14, 3) }, 2)
		end

		return host
	end

	function window:SelectTab(name)
		for tabName, page in pairs(self.Pages) do
			local selected = tabName == name
			page.Visible = selected

			local tabButton = self.TabButtons[tabName]
			if tabButton then
				if iconOnlyTabs and activeRailIndicator and selected then
					local function syncRailIndicator(flash)
						if not activeRailIndicator.Parent or not tabButton.Parent or tabButton.AbsoluteSize.Y <= 0 then
							return
						end

						local targetY = (tabButton.AbsolutePosition.Y - navPanel.AbsolutePosition.Y) + math.floor((tabButton.AbsoluteSize.Y - 30) / 2)
						local function moveRailGlow(part, offsetX, offsetY, width, height, flashTransparency, restTransparency, duration)
							if not part then
								return
							end

							part.Visible = true
							part.BackgroundColor3 = self.Theme.Accent
							if flash then
								part.BackgroundTransparency = flashTransparency
							end
							tween(part, {
								Position = UDim2.fromOffset(activeRailIndicatorX + offsetX, targetY + offsetY),
								Size = UDim2.fromOffset(width, height),
								BackgroundTransparency = restTransparency,
							}, duration)
						end

						moveRailGlow(activeRailGlowOuter, -3, -9, 20, 48, 0.5, 0.78, 0.26)
						moveRailGlow(activeRailGlowMid, -1, -5, 14, 40, 0.3, 0.55, 0.2)

						activeRailIndicator.Visible = true
						activeRailIndicator.BackgroundColor3 = self.Theme.Accent
						tween(activeRailIndicator, {
							Position = UDim2.fromOffset(activeRailIndicatorX, targetY),
							Size = UDim2.fromOffset(4, 30),
							BackgroundTransparency = 0,
						}, 0.16)
					end

					syncRailIndicator(true)
					task.defer(function()
						syncRailIndicator(false)
					end)
					task.delay(0.03, function()
						syncRailIndicator(false)
					end)
				end

				tween(tabButton, {
					BackgroundColor3 = selected and (iconOnlyTabs and self.Theme.Accent or self.Theme.TabActive) or self.Theme.Background,
					BackgroundTransparency = iconOnlyTabs and (selected and 0 or 1) or (selected and (self.Acrylic and (self.Theme.TabActiveTransparency or 0.08) or 0) or (self.Acrylic and (self.Theme.BackgroundTransparency or 0.18) or 0)),
				}, 0.14)
				paintTabIcon(tabButton, selected and self.Theme.Text or self.Theme.Muted, true)

				local tabGradient = tabButton:FindFirstChild("DarkUITabButtonGradient")
				if tabGradient then
					tabGradient.Color = accentGradient(self.Theme.Accent)
					tabGradient.Transparency = flatTransparency(selected and iconOnlyTabs and 0 or 1)
				end

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
						BackgroundTransparency = selected and (iconOnlyTabs and 1 or 0) or 1,
					}, 0.14)
				end

				local tabStroke = tabButton:FindFirstChild("DarkUITabStroke")
				if tabStroke then
					tabStroke.Color = selected and (iconOnlyTabs and self.Theme.Text or self.Theme.Accent) or self.Theme.Stroke
					tween(tabStroke, {
						Transparency = selected and (iconOnlyTabs and 1 or 0.35) or 1,
					}, 0.14)
				end

				local accent = tabButton:FindFirstChild("DarkUIAccent")
				if accent then
					if selected then
						accent.Visible = true
					end
					tween(accent, {
						Size = selected and (iconOnlyTabs and UDim2.new(0, 4, 0, 28) or UDim2.new(0, 3, 1, -14)) or UDim2.new(0, iconOnlyTabs and 4 or 3, 0, 0),
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
		if self.BuiltInSettings and not tabConfig.Internal and isSettingsTabName(tabName) and type(self.CreateBuiltInSettingsTab) == "function" then
			return self:CreateBuiltInSettingsTab()
		end

		local defaultTabIcon = getDefaultTabIcon(tabName)
		local tabIcon = resolveImageContent(tabConfig.Icon or defaultTabIcon, "tab_" .. tabName, tabConfig.Icon and nil or false)

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
			LayoutOrder = tabConfig.LayoutOrder or (tabConfig.Internal and 10000 or (#self.TabOrder + 1)),
			Size = iconOnlyTabs and UDim2.fromOffset(54, 54) or UDim2.new(1, 0, 0, tabConfig.Height or tabHeight),
			Text = "",
			Parent = tabs,
		}, {
			corner(iconOnlyTabs and 15 or 7),
		}), "Background")
		if iconOnlyTabs then
			tabButton.BackgroundTransparency = 1
		end
		attachPress(tabButton, 0.97)

		local tabGradient = make("UIGradient", {
			Name = "DarkUITabButtonGradient",
			Color = accentGradient(self.Theme.Accent),
			Rotation = 35,
			Transparency = flatTransparency(1),
			Parent = tabButton,
		})

		local tabStroke = stroke(self.Theme.Text, 1, 1)
		tabStroke.Name = "DarkUITabStroke"
		tabStroke.Parent = tabButton

		local activeGlow = make("Frame", {
			Name = "DarkUITabActiveGlow",
			BackgroundColor3 = self.Theme.Text,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Parent = tabButton,
		}, {
			corner(iconOnlyTabs and 15 or 7),
			make("UIGradient", {
				Rotation = 35,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.72),
					NumberSequenceKeypoint.new(0.35, 0.9),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),
		})

		if iconOnlyTabs then
			createTabGlyph(tabButton, tabName, tabIcon)
		else
			local textOffset = tabIcon and 32 or 14
			if tabIcon then
				make("ImageLabel", {
					Name = "TabIconImage",
					BackgroundTransparency = 1,
					Image = tabIcon,
					ImageColor3 = window.Theme.Muted,
					Position = UDim2.fromOffset(10, 12),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromOffset(16, 16),
					Parent = tabButton,
				})
			end

			local titleLabel = styledText(DarkUI:Text({
				Font = DarkUI.Fonts.Bold,
				Parent = tabButton,
				Position = UDim2.fromOffset(textOffset, 7),
				Size = UDim2.new(1, -textOffset - 8, 0, 17),
				Text = tabName,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
			}), "Text")
			titleLabel.Name = "TabTitle"

			local descLabel = styledText(DarkUI:Text({
				Font = DarkUI.Fonts.Body,
				Parent = tabButton,
				Position = UDim2.fromOffset(textOffset, 23),
				Size = UDim2.new(1, -textOffset - 8, 0, 14),
				Text = tabDescription,
				TextSize = 9,
				TextXAlignment = Enum.TextXAlignment.Left,
			}), "Muted")
			descLabel.Name = "TabDesc"
			descLabel.TextTransparency = 0.42
		end

		if not iconOnlyTabs then
			make("Frame", {
				Name = "DarkUIAccent",
				AnchorPoint = Vector2.new(0, 0),
				BackgroundColor3 = self.Theme.Accent,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 6),
				Size = UDim2.new(0, 3, 0, 0),
				Visible = false,
				Parent = tabButton,
			}, {
				corner(999),
			})
		end

		connect(tabButton.MouseEnter, function()
			if window.SelectedTab ~= tabName then
				tween(tabButton, {
					BackgroundColor3 = window.Theme.Tab,
					BackgroundTransparency = iconOnlyTabs and 0.42 or (window.Acrylic and (window.Theme.TabTransparency or 0.16) or 0),
				}, 0.12)
				local hoverGradient = tabButton:FindFirstChild("DarkUITabButtonGradient")
				if hoverGradient and iconOnlyTabs then
					hoverGradient.Color = accentGradient(window.Theme.Accent)
					hoverGradient.Transparency = flatTransparency(0.76)
				end
				tween(getScale(tabButton), {
					Scale = iconOnlyTabs and 1.04 or 1.006,
				}, 0.12)
			end
		end)

		connect(tabButton.MouseLeave, function()
			if window.SelectedTab ~= tabName then
				tween(tabButton, {
					BackgroundColor3 = window.Theme.Background,
					BackgroundTransparency = iconOnlyTabs and 1 or (window.Acrylic and (window.Theme.BackgroundTransparency or 0.18) or 0),
				}, 0.12)
				local hoverGradient = tabButton:FindFirstChild("DarkUITabButtonGradient")
				if hoverGradient and iconOnlyTabs then
					hoverGradient.Transparency = flatTransparency(1)
				end
			end
			tween(getScale(tabButton), {
				Scale = 1,
			}, 0.12)
		end)

		local columnCount = tabConfig.Columns or config.Columns or 1
		local useTwoColumns = columnCount ~= 1
		local page = make("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			Parent = pagesHolder,
		}, {
			make("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, useTwoColumns and 10 or 0),
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
			Size = useTwoColumns and UDim2.new(0.5, -5, 1, 0) or UDim2.new(1, 0, 1, 0),
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
			Size = useTwoColumns and UDim2.new(0.5, -5, 1, 0) or UDim2.new(0, 0, 1, 0),
			Visible = useTwoColumns,
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

		local isInternalTab = tabConfig.Internal == true
		if not isInternalTab then
			self.UserTabCount += 1
		end

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
			Columns = useTwoColumns and { left, right } or { left },
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
			if options.Side == "Right" and self.Columns[2] then
				target = self.Columns[2]
			elseif options.Side == "Left" then
				target = self.Columns[1]
			else
				target = self.Columns[((self.SectionOrder - 1) % #self.Columns) + 1]
			end

			local section = styledBackground(make("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0,
				BackgroundTransparency = 0.08,
				LayoutOrder = self.SectionOrder,
				Size = UDim2.new(1, -2, 0, 0),
				Parent = target,
			}, {
				corner(18),
				stroke(window.Theme.Stroke, 1, 1),
				make("UIPadding", {
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingTop = UDim.new(0, 8),
				}),
				make("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 8),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			}), "Panel")

			local headerButton = make("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				LayoutOrder = 0,
				Size = UDim2.new(1, 0, 0, 34),
				Text = "",
				Parent = section,
			})

			styledText(DarkUI:Text({
				Font = DarkUI.Fonts.Bold,
				Parent = headerButton,
				Position = UDim2.fromOffset(2, 1),
				Size = UDim2.new(1, -26, 0, 24),
				Text = options.Title or "Section",
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			}), "Text")

			local isCollapsible = options.Collapsible ~= false
			local foldIcon = make("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -5, 0, 4),
				Rotation = options.DefaultOpen == false and -90 or 0,
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
				Position = UDim2.fromOffset(8, 11),
				Rotation = 45,
				Size = UDim2.fromOffset(10, 2),
				Parent = foldIcon,
			}, {
				corner(999),
			}), "Muted")
			local foldVertical = styledBackground(make("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(14, 11),
				Rotation = -45,
				Size = UDim2.fromOffset(10, 2),
				Parent = foldIcon,
			}, {
				corner(999),
			}), "Muted")

			make("Frame", {
				Name = "DarkUIAccent",
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = window.Theme.Accent,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 1, -1),
				Size = UDim2.new(1, 0, 0, 1),
				Parent = headerButton,
			}, {
				make("UIGradient", {
					Name = "DarkUIAccentGradient",
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, window.Theme.TitleBarLine),
						ColorSequenceKeypoint.new(0.5, window.Theme.Accent),
						ColorSequenceKeypoint.new(1, window.Theme.TitleBarLine),
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
					Rotation = self.Collapsed and -90 or 0,
				}, 0.18)
				tween(foldVertical, {
					BackgroundTransparency = 0,
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
					ClipsDescendants = true,
					LayoutOrder = sectionApi:NextOrder(),
					Size = UDim2.new(1, 0, 0, height),
					Parent = bodyFrame,
				}, {
					corner(13),
					styledStroke(stroke(window.Theme.ElementBorder, 0.16, 1), "ElementBorder"),
				}), "Element")

				row.BackgroundTransparency = window.Acrylic and (window.Theme.ElementTransparency or 0.12) or 0.03
				attachHover(row, "Element", "PanelLight")
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
				row:SetAttribute("DarkUIBackground", "Element")
				row.BackgroundColor3 = window.Theme.Element
				row.BackgroundTransparency = window.Acrylic and (window.Theme.ElementTransparency or 0.12) or 0.03

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(14, 8),
					Size = UDim2.new(1, -28, 0, 18),
					Text = options.Title or "Info",
					TextSize = 13,
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
				local requestedButtonIcon = options.ActionIcon or options.ButtonIcon or options.Icon
				local useDefaultButtonIcon = requestedButtonIcon == nil
				if requestedButtonIcon == false then
					useDefaultButtonIcon = false
					requestedButtonIcon = nil
				end

				local buttonIcon = resolveImageContent(useDefaultButtonIcon and DarkUI.DefaultButtonIcon or requestedButtonIcon, "button_" .. (options.Title or options.Text or "icon"), useDefaultButtonIcon and false or nil)
				local hasActionIcon = buttonIcon ~= nil
				local row = createRow(options, 44)

				local button = make("TextButton", {
					AutoButtonColor = false,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Font = DarkUI.Fonts.Bold,
					Size = UDim2.fromScale(1, 1),
					Text = "",
					Parent = row,
				}, {
					corner(13),
				})

				if buttonIcon then
					make("ImageLabel", {
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundTransparency = 1,
						Image = buttonIcon,
						Position = UDim2.new(1, -16, 0.5, 0),
						ScaleType = Enum.ScaleType.Fit,
						Size = UDim2.fromOffset(20, 20),
						Parent = button,
					})
				end

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = button,
					Position = UDim2.fromOffset(14, 0),
					Size = UDim2.new(1, hasActionIcon and -54 or -28, 1, 0),
					Text = options.Title or "Button",
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Left,
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
				local row = createRow(options, hasDescription and 64 or 48)

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(12, hasDescription and 8 or 0),
					Size = UDim2.new(1, -72, 0, hasDescription and 17 or 48),
					Text = options.Title or "Toggle",
					TextSize = 12,
				}), "Text")

				if hasDescription then
					styledText(DarkUI:Text({
						Font = DarkUI.Fonts.Body,
						Parent = row,
						Position = UDim2.fromOffset(12, 26),
						Size = UDim2.new(1, -80, 0, 32),
						Text = options.Description,
						TextSize = 10,
						TextWrapped = true,
						TextYAlignment = Enum.TextYAlignment.Top,
					}), "Muted")
				end

				local shellStroke = stroke(window.Theme.Stroke, 0.52, 1)
				local shell = styledBackground(make("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					AutoButtonColor = false,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = UDim2.fromOffset(44, 26),
					Text = "",
					Parent = row,
				}, {
					corner(999),
					shellStroke,
				}), "Element")

				local innerStroke = stroke(window.Theme.Stroke, 0.22, 1)
				local innerBox = make("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(245, 245, 247),
					BorderSizePixel = 0,
					Position = value and UDim2.fromScale(0.72, 0.5) or UDim2.fromScale(0.28, 0.5),
					Size = UDim2.fromOffset(18, 18),
					Parent = shell,
				}, {
					corner(999),
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
					Scale = 0,
					Parent = check,
				})

				local control
				local function render(animated)
					local onColor = window.Theme.Accent
					local shellProps = {
						BackgroundColor3 = value and window.Theme.Accent or window.Theme.Panel,
					}
					local shellStrokeProps = {
						Color = value and onColor or window.Theme.Stroke,
						Transparency = value and 0.16 or 0.52,
					}
					local innerProps = {
						BackgroundColor3 = Color3.fromRGB(245, 245, 247),
						Position = value and UDim2.fromScale(0.72, 0.5) or UDim2.fromScale(0.28, 0.5),
					}
					local innerStrokeProps = {
						Color = value and Color3.fromRGB(245, 245, 247) or Color3.fromRGB(54, 60, 76),
						Transparency = 1,
					}

					check.Visible = false

					if animated then
						tween(shell, shellProps, 0.14)
						tween(shellStroke, shellStrokeProps, 0.14)
						tween(innerBox, innerProps, 0.14)
						tween(innerStroke, innerStrokeProps, 0.14)
						tween(checkScale, { Scale = 0 }, 0.13)
						for _, child in ipairs(check:GetChildren()) do
							if child:IsA("Frame") then
								tween(child, {
									BackgroundTransparency = value and 0 or 1,
								}, 0.1)
							end
						end
					else
						shell.BackgroundColor3 = shellProps.BackgroundColor3
						shellStroke.Color = shellStrokeProps.Color
						shellStroke.Transparency = shellStrokeProps.Transparency
						innerBox.BackgroundColor3 = innerProps.BackgroundColor3
						innerBox.Position = innerProps.Position
						innerStroke.Color = innerStrokeProps.Color
						innerStroke.Transparency = innerStrokeProps.Transparency
						checkScale.Scale = 0
						check.Visible = false
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
				local row = createRow(options, 58)

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(12, 6),
					Size = UDim2.new(1, -24, 0, 18),
					Text = options.Title or "Slider",
					TextSize = 13,
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
				}), "Input")
				styledText(valueBox, "Accent")
				local valueBoxFocused = false
				local sanitizingSliderText = false

				local track = styledBackground(make("Frame", {
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(12, 42),
					Size = UDim2.new(1, -104, 0, 6),
					Parent = row,
				}, {
					corner(999),
				}), "SliderRail")

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

				connect(valueBox:GetPropertyChangedSignal("Text"), function()
					if sanitizingSliderText then
						return
					end

					local text = tostring(valueBox.Text or "")
					local cleaned = text:gsub("[^%d%.%-]", "")
					if cleaned:find("%-") and cleaned:find("%-") ~= 1 then
						cleaned = cleaned:gsub("%-", "")
					end

					local dotCount = 0
					cleaned = cleaned:gsub("%.", function()
						dotCount += 1
						return dotCount == 1 and "." or ""
					end)

					if cleaned ~= text then
						sanitizingSliderText = true
						valueBox.Text = cleaned
						sanitizingSliderText = false
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
				local discordCollapse = options.DiscordCollapse ~= false
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
				local useOutsideDropdown = window.DropdownsOutsideWindow == true

				styledText(DarkUI:Text({
					Font = DarkUI.Fonts.Bold,
					Parent = row,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(0.42, -12, 0, 44),
					Text = options.Title or "Dropdown",
					TextSize = 13,
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
				}), "Input")

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
					Rotation = discordCollapse and -90 or 0,
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
				attachHover(button, "Input", "PanelLight", 1.01)
				attachPress(button, 0.96)

				local list = styledBackground(make("ScrollingFrame", {
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ClipsDescendants = true,
					BorderSizePixel = 0,
					CanvasSize = UDim2.new(),
					Position = UDim2.fromOffset(12, 42),
					Size = UDim2.new(1, -24, 0, 0),
					ScrollBarImageColor3 = window.Theme.Accent,
					ScrollBarImageTransparency = 0.45,
					ScrollBarThickness = 2,
					Visible = false,
					ZIndex = useOutsideDropdown and 180 or 1,
					Parent = row,
				}, {
					corner(9),
					styledStroke(stroke(window.Theme.Stroke, 0.18, 1), "Stroke"),
					make("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						Padding = UDim.new(0, 3),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					make("UIPadding", {
						PaddingBottom = UDim.new(0, 5),
						PaddingLeft = UDim.new(0, 5),
						PaddingRight = UDim.new(0, 5),
						PaddingTop = UDim.new(0, 5),
					}),
				}), "DropdownHolder")
				list.BackgroundTransparency = 0.02
				if useOutsideDropdown then
					list.Parent = screenGui
				end

				local searchBox
				if searchable then
					searchBox = styledBackground(make("TextBox", {
						BorderSizePixel = 0,
						ClearTextOnFocus = false,
						Font = DarkUI.Fonts.Bold,
						LayoutOrder = 0,
						PlaceholderColor3 = window.Theme.Muted,
						PlaceholderText = "Search...",
						Size = UDim2.new(1, 0, 0, 28),
						Text = "",
						TextSize = 13,
						ZIndex = useOutsideDropdown and 181 or 1,
						Parent = list,
					}, {
						corner(7),
						styledStroke(stroke(window.Theme.Stroke, 0.28, 1), "Stroke"),
						make("UIPadding", {
							PaddingLeft = UDim.new(0, 8),
							PaddingRight = UDim.new(0, 8),
						}),
					}), "Input")
					searchBox.BackgroundTransparency = 0.04
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
						itemButton.BackgroundColor3 = active and window.Theme.TabActive or window.Theme.DropdownOption
						itemButton.BackgroundTransparency = active and 0.04 or 0.06
						if itemChecks[key] then
							itemChecks[key].Visible = active
						end
					end
				end

				local function setOpen(nextOpen)
					open = nextOpen == true
					local searchHeight = searchable and 33 or 0
					local fullHeight = searchHeight + (filteredCount * 35) + 10
					listHeight = open and math.min(fullHeight, options.MaxDropdownHeight or 392) or 0
					if open then
						list.Visible = true
					end
					if useOutsideDropdown then
						local pos = button.AbsolutePosition
						local size = button.AbsoluteSize
						list.Position = UDim2.fromOffset(pos.X, pos.Y + size.Y + 5)
						tween(row, {
							Size = UDim2.new(1, 0, 0, 44),
						}, 0.16)
						tween(list, {
							Size = UDim2.fromOffset(size.X, listHeight),
						}, 0.16)
					else
						tween(row, {
							Size = UDim2.new(1, 0, 0, 44 + listHeight),
						}, 0.16)
						tween(list, {
							Size = UDim2.new(1, -24, 0, listHeight),
						}, 0.16)
					end
					tween(arrow, {
						Rotation = open and 0 or (discordCollapse and -90 or 0),
					}, 0.16)
					if not open then
						task.delay(0.16, function()
							if list.Parent and not open then
								list.Visible = false
							end
						end)
					end
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
							Size = UDim2.new(1, 0, 0, 32),
							Text = "",
							TextSize = 10,
							Visible = matches,
							ZIndex = useOutsideDropdown and 181 or 1,
							Parent = list,
						}, {
							corner(5),
						}), "DropdownOption")
						itemButton.BackgroundTransparency = 0.06

						local itemLabel = styledText(DarkUI:Text({
							Font = DarkUI.Fonts.Bold,
							Parent = itemButton,
							Position = UDim2.fromOffset(12, 0),
							Size = UDim2.new(1, -20, 1, 0),
							Text = itemKey,
							TextSize = 13,
						}), "Text")
						itemLabel.ZIndex = useOutsideDropdown and 182 or 1

						local itemCheck = make("Frame", {
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundColor3 = window.Theme.Accent,
							BorderSizePixel = 0,
							Position = UDim2.new(0, -1, 0.5, 0),
							Size = UDim2.fromOffset(4, 14),
							Visible = false,
							ZIndex = useOutsideDropdown and 182 or 1,
							Parent = itemButton,
						}, {
							corner(2),
						})
						itemCheck.Name = "DarkUIAccent"

						itemButtons[itemKey] = itemButton
						itemChecks[itemKey] = itemCheck
						if matches then
							filteredCount += 1
						end
						attachHover(itemButton, "DropdownOption", "PanelLight", 1.01)
						attachPress(itemButton, 0.96)
						connect(itemButton.MouseLeave, function()
							local active = multi and selected[itemKey] == true or tostring(selected) == itemKey
							tween(itemButton, {
								BackgroundColor3 = active and window.Theme.TabActive or window.Theme.DropdownOption,
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
				setOpen(false)
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
					TextSize = 13,
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
				}), "Input")
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
					TextSize = 13,
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
				}), "Input")
				styledText(keyButton, "Text")
				attachHover(keyButton, "Input", "PanelLight", 1.02)
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
					TextSize = 13,
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

		if iconOnlyTabs then
			window:AttachTooltip(tabButton, tabName)
		end

		if not self.SelectedTab then
			self:SelectTab(tabName)
		end

		if self.BuiltInSettings and not isInternalTab and not self.BuiltInSettingsCreated and not isSettingsTabName(tabName) and type(self.CreateBuiltInSettingsTab) == "function" then
			self:CreateBuiltInSettingsTab()
		end

		if not isInternalTab and self.AutoSettingsTabName and self.SelectedTab == self.AutoSettingsTabName and self.UserTabCount == 1 then
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

	function window:CreateBuiltInSettingsTab()
		if self.BuiltInSettingsCreated and self.BuiltInSettingsTab then
			return self.BuiltInSettingsTab
		end

		self.BuiltInSettingsCreated = true

		local settingsName = self.BuiltInSettingsTabName or "Setting"
		local tab = self:CreateTab({
			Name = settingsName,
			Icon = DarkUI.DefaultTabIcons.Setting,
			Description = "UI settings and config",
			Columns = 1,
			Internal = true,
			LayoutOrder = 10000,
		})

		self.BuiltInSettingsTab = tab
		self.AutoSettingsTabName = settingsName
		self.FooterSettingsTab = settingsName

		local holder = tab.Columns[1]
		holder.ScrollBarThickness = 2

		local generalSection = tab:AddSection({
			Title = "General",
			Collapsible = false,
		})

		generalSection:AddDropdown({
			Title = "Language",
			Description = "Display language for the built-in interface.",
			Items = { "English", "Vietnamese" },
			Default = "English",
			Flag = "ui_language",
			Callback = function(value)
				self.Language = value
			end,
		})

		generalSection:AddDropdown({
			Title = "FPS Cap",
			Description = "Global frame rate cap for this client. Requires executor support.",
			Items = { "60 FPS", "120 FPS", "144 FPS", "240 FPS", "Uncapped" },
			Default = "60 FPS",
			Flag = "ui_fps_cap",
			Callback = function(value)
				local cap = tonumber(string.match(tostring(value), "%d+")) or 0
				if type(setfpscap) == "function" then
					setfpscap(cap)
				else
					self:Notify("FPS Cap", "setfpscap is not available in this executor.", "Warning")
				end
			end,
		})

		generalSection:AddToggle({
			Title = "3D Rendering",
			Description = "Disable 3D world rendering to save GPU. The UI remains visible.",
			Default = true,
			Flag = "ui_3d_rendering",
			Callback = function(value)
				pcall(function()
					RunService:Set3dRenderingEnabled(value)
				end)
			end,
		})

		local windowSection = tab:AddSection({
			Title = "Window",
			Collapsible = false,
		})

		windowSection:AddSlider({
			Title = "Drag FPS Cap",
			Min = 0,
			Max = 120,
			Default = self.DragFPSCap,
			Flag = "ui_drag_fps_cap",
			Callback = function(value)
				self.DragFPSCap = value
			end,
		})

		windowSection:AddToggle({
			Title = "Use Drag Skeleton",
			Description = "Use lightweight drag mode setting for scripts that hook into it.",
			Default = self.UseDragSkeleton,
			Flag = "ui_drag_skeleton",
			Callback = function(value)
				self.UseDragSkeleton = value
			end,
		})

		windowSection:AddToggle({
			Title = "Full UI Visibility Animation",
			Description = "Use scale and fade animation when hiding or showing the window.",
			Default = self.FullVisibilityAnimation,
			Flag = "ui_visibility_animation",
			Callback = function(value)
				self.FullVisibilityAnimation = value
			end,
		})

		local themeSection = tab:AddSection({
			Title = "Theme",
			Collapsible = false,
		})

		local themes = {}
		for name in pairs(DarkUI.ThemePresets) do
			table.insert(themes, name)
		end
		table.sort(themes)

		themeSection:AddDropdown({
			Title = "Theme Preset",
			Description = "Switch the whole UI theme.",
			Items = themes,
			Default = self.ThemeName,
			Flag = "ui_theme",
			Callback = function(value)
				self:SetTheme(value)
			end,
		})

		themeSection:AddColorPicker({
			Title = "Accent Color",
			Default = self.Theme.Accent,
			Flag = "ui_accent_color",
			Callback = function(color)
				self:SetAccentColor(color)
			end,
		})

		themeSection:AddToggle({
			Title = "Acrylic",
			Description = "Use softer transparent dark surfaces.",
			Default = self.Acrylic,
			Flag = "ui_acrylic",
			Callback = function(value)
				self.Acrylic = value
				self:_applyTheme()
			end,
		})

		themeSection:AddToggle({
			Title = "Borderless Theme",
			Description = "Hide most theme borders for a cleaner glass look.",
			Default = self.Borderless,
			Flag = "ui_borderless",
			Callback = function(value)
				self.Borderless = value
				self:_applyTheme()
			end,
		})

		local snapshotsSection = tab:AddSection({
			Title = "Snapshots",
			Collapsible = false,
		})

		local configName = snapshotsSection:AddTextBox({
			Title = "Config Name",
			Default = string.gsub(self.ConfigName, "%.json$", ""),
			Placeholder = "default",
		})

		snapshotsSection:AddButton({
			Title = "Save Snapshot",
			Callback = function()
				self:SaveConfig(configName:Get())
			end,
		})

		snapshotsSection:AddButton({
			Title = "Load Snapshot",
			Callback = function()
				self:LoadConfig(configName:Get())
			end,
		})

		snapshotsSection:AddButton({
			Title = "Delete Snapshot",
			Callback = function()
				self:Confirm({
					Title = "Delete Snapshot",
					Text = "Delete this config profile?",
					ConfirmText = "Delete",
					Callback = function()
						self:DeleteConfig(configName:Get())
					end,
				})
			end,
		})

		if false then

		local subNav = make("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 0,
			Size = UDim2.new(1, -2, 0, 48),
			Parent = holder,
		}, {
			make("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 30),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})

		local settingPages = {}
		local settingTabs = {}
		local settingTabOrder = 0
		local settingOrder = 0
		local activeSettingsPage = "General"

		local function text(parent, content, size, font, colorKey, props)
			props = props or {}
			props.Parent = parent
			props.Text = content
			props.TextSize = size
			props.Font = font or DarkUI.Fonts.Body
			local label = styledText(DarkUI:Text(props), colorKey or "Text")
			if props.Name then
				label.Name = props.Name
			end
			return label
		end

		local function createSettingsPage(name)
			local page = make("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Size = UDim2.new(1, -2, 0, 0),
				Visible = false,
				Parent = holder,
			}, {
				make("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 10),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			})

			settingPages[name] = page
			return page
		end

		local function setSettingsPage(name)
			activeSettingsPage = name
			for pageName, page in pairs(settingPages) do
				page.Visible = pageName == name
			end

			for pageName, button in pairs(settingTabs) do
				local selected = pageName == name
				local label = button:FindFirstChild("Label")
				local line = button:FindFirstChild("Line")
				if label then
					tween(label, {
						TextColor3 = selected and self.Theme.Accent or self.Theme.Muted,
					}, 0.12)
				end
				if line then
					line.Visible = true
					tween(line, {
						BackgroundTransparency = selected and 0 or 1,
						Size = selected and UDim2.new(1, 0, 0, 2) or UDim2.new(0, 0, 0, 2),
					}, 0.14)
				end
			end
		end

		local function createSettingsSubTab(name)
			settingTabOrder += 1
			local button = make("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = settingTabOrder,
				Size = UDim2.fromOffset(108, 42),
				Text = "",
				Parent = subNav,
			})

			local label = text(button, name, 18, DarkUI.Fonts.Bold, "Muted", {
				Name = "Label",
				Position = UDim2.fromOffset(0, 3),
				Size = UDim2.new(1, 0, 0, 26),
				TextXAlignment = Enum.TextXAlignment.Center,
			})

			local line = styledBackground(make("Frame", {
				Name = "Line",
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 1, -3),
				Size = UDim2.new(0, 0, 0, 2),
				Parent = button,
			}, {
				corner(999),
			}), "Accent")

			settingTabs[name] = button
			connect(button.MouseButton1Click, function()
				setSettingsPage(name)
			end)
			attachPress(button, 0.94)

			return button, label, line
		end

		local function createCategory(parent, title)
			settingOrder += 1
			return text(parent, string.upper(title), 12, DarkUI.Fonts.Bold, "Muted", {
				BackgroundTransparency = 1,
				LayoutOrder = settingOrder,
				Size = UDim2.new(1, -4, 0, 18),
				TextXAlignment = Enum.TextXAlignment.Left,
			})
		end

		local function createGroup(parent)
			settingOrder += 1
			local group = styledBackground(make("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = self.Acrylic and 0.18 or 0.05,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				LayoutOrder = settingOrder,
				Size = UDim2.new(1, -2, 0, 0),
				Parent = parent,
			}, {
				corner(22),
				styledStroke(stroke(self.Theme.Stroke, 0.42, 1), "Stroke"),
				make("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			}), "Surface")

			group:SetAttribute("DarkUIRowCount", 0)
			return group
		end

		local function createSettingRow(group, options)
			options = options or {}
			local rowCount = group:GetAttribute("DarkUIRowCount") or 0
			rowCount += 1
			group:SetAttribute("DarkUIRowCount", rowCount)

			local row = styledBackground(make("Frame", {
				BackgroundTransparency = 0.18,
				BorderSizePixel = 0,
				LayoutOrder = rowCount,
				Size = UDim2.new(1, 0, 0, options.Height or 72),
				Parent = group,
			}), "Surface")

			if rowCount > 1 then
				styledBackground(make("Frame", {
					BackgroundTransparency = 0.5,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(0, 0),
					Size = UDim2.new(1, 0, 0, 1),
					Parent = row,
				}), "Stroke")
			end

			text(row, options.Title or "Setting", 15, DarkUI.Fonts.Bold, "Text", {
				Position = UDim2.fromOffset(18, 11),
				Size = UDim2.new(1, -230, 0, 24),
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			if options.Description and options.Description ~= "" then
				text(row, options.Description, 13, DarkUI.Fonts.Body, "Muted", {
					Position = UDim2.fromOffset(18, 34),
					Size = UDim2.new(1, -230, 0, options.Height and options.Height - 38 or 34),
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
				})
			end

			return row
		end

		local function createCycleDropdown(group, options)
			local row = createSettingRow(group, options)
			local items = options.Items or {}
			local selectedIndex = 1
			for index, item in ipairs(items) do
				if tostring(item) == tostring(options.Default) then
					selectedIndex = index
					break
				end
			end

			local button = styledBackground(make("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				AutoButtonColor = false,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Position = UDim2.new(1, -18, 0.5, 0),
				Size = UDim2.fromOffset(options.Width or 172, 36),
				Text = "",
				Parent = row,
			}, {
				corner(999),
				styledStroke(stroke(self.Theme.InElementBorder, 0.28, 1), "InElementBorder"),
			}), "Input")

			local valueLabel = text(button, tostring(items[selectedIndex] or options.Default or ""), 14, DarkUI.Fonts.Bold, "Text", {
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -42, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			text(button, "v", 15, DarkUI.Fonts.Bold, "Muted", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -13, 0.5, -1),
				Size = UDim2.fromOffset(18, 18),
				TextXAlignment = Enum.TextXAlignment.Center,
			})

			local function applyValue(value, silent)
				valueLabel.Text = tostring(value)
				if options.Callback and not silent then
					options.Callback(value)
				end
			end

			connect(button.MouseButton1Click, function()
				if #items == 0 then
					return
				end

				selectedIndex = (selectedIndex % #items) + 1
				applyValue(items[selectedIndex])
			end)
			attachHover(button, "Input", "InputFocused", 1.02)
			attachPress(button, 0.96)
			applyValue(items[selectedIndex] or options.Default or "", true)

			return {
				Set = function(_, value, silent)
					for index, item in ipairs(items) do
						if tostring(item) == tostring(value) then
							selectedIndex = index
							break
						end
					end
					applyValue(value, silent)
				end,
				Get = function()
					return items[selectedIndex]
				end,
			}
		end

		local function createSwitch(group, options)
			local row = createSettingRow(group, options)
			local value = options.Default == true

			local switch = make("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				AutoButtonColor = false,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -20, 0.5, 0),
				Size = UDim2.fromOffset(54, 28),
				Text = "",
				Parent = row,
			}, {
				corner(999),
				styledStroke(stroke(self.Theme.Stroke, 0.32, 1), "Stroke"),
			})

			local knob = styledBackground(make("Frame", {
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(4, 4),
				Size = UDim2.fromOffset(20, 20),
				Parent = switch,
			}, {
				corner(999),
			}), "Text")

			local function render()
				switch.BackgroundColor3 = value and self.Theme.Accent or self.Theme.Panel
				switch.BackgroundTransparency = value and 0 or 0.08
				tween(knob, {
					Position = value and UDim2.fromOffset(30, 4) or UDim2.fromOffset(4, 4),
				}, 0.14)
			end

			local function setValue(nextValue, silent)
				value = nextValue == true
				render()
				if options.Callback and not silent then
					options.Callback(value)
				end
			end

			connect(switch.MouseButton1Click, function()
				setValue(not value)
			end)
			attachPress(switch, 0.96)
			registerRenderer(render)
			setValue(value, true)

			return {
				Set = function(_, nextValue, silent)
					setValue(nextValue, silent)
				end,
				Get = function()
					return value
				end,
			}
		end

		local function createSlider(group, options)
			local row = createSettingRow(group, {
				Title = options.Title,
				Description = options.Description,
				Height = options.Height or 86,
			})

			local min = tonumber(options.Min) or 0
			local max = tonumber(options.Max) or 100
			local value = math.clamp(tonumber(options.Default) or min, min, max)
			local suffix = options.Suffix or ""

			local valuePill = styledBackground(make("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(1, -18, 0, 14),
				Size = UDim2.fromOffset(78, 30),
				Parent = row,
			}, {
				corner(12),
				styledStroke(stroke(self.Theme.Stroke, 0.2, 1), "Stroke"),
			}), "Panel")

			local valueText = text(valuePill, "", 14, DarkUI.Fonts.Bold, "Text", {
				Size = UDim2.fromScale(1, 1),
				TextXAlignment = Enum.TextXAlignment.Center,
			})

			local rail = styledBackground(make("Frame", {
				AnchorPoint = Vector2.new(1, 1),
				BorderSizePixel = 0,
				Position = UDim2.new(1, -106, 1, -18),
				Size = UDim2.new(0, 230, 0, 6),
				Parent = row,
			}, {
				corner(999),
			}), "Panel")

			local fill = styledBackground(make("Frame", {
				BorderSizePixel = 0,
				Size = UDim2.new(0, 0, 1, 0),
				Parent = rail,
			}, {
				corner(999),
			}), "Accent")

			local knob = styledBackground(make("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.fromOffset(18, 18),
				Parent = rail,
			}, {
				corner(999),
				styledStroke(stroke(self.Theme.Text, 0.1, 1), "Text"),
			}), "Accent")

			local function formatValue(nextValue)
				if options.Decimals and options.Decimals > 0 then
					return string.format("%." .. tostring(options.Decimals) .. "f%s", nextValue, suffix)
				end
				return tostring(math.floor(nextValue + 0.5)) .. suffix
			end

			local function render()
				local alpha = max == min and 0 or (value - min) / (max - min)
				alpha = math.clamp(alpha, 0, 1)
				valueText.Text = formatValue(value)
				fill.Size = UDim2.new(alpha, 0, 1, 0)
				knob.Position = UDim2.new(alpha, 0, 0.5, 0)
			end

			local function setValue(nextValue, silent)
				value = math.clamp(tonumber(nextValue) or value, min, max)
				if not options.Decimals or options.Decimals <= 0 then
					value = math.floor(value + 0.5)
				end
				render()
				if options.Callback and not silent then
					options.Callback(value)
				end
			end

			local draggingSlider = false
			local function updateFromInput(input)
				local width = math.max(1, rail.AbsoluteSize.X)
				local alpha = math.clamp((input.Position.X - rail.AbsolutePosition.X) / width, 0, 1)
				setValue(min + ((max - min) * alpha))
			end

			connect(rail.InputBegan, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingSlider = true
					updateFromInput(input)
				end
			end)

			connect(UserInputService.InputChanged, function(input)
				if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateFromInput(input)
				end
			end)

			connect(UserInputService.InputEnded, function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingSlider = false
				end
			end)

			registerRenderer(render)
			setValue(value, true)

			return {
				Set = function(_, nextValue, silent)
					setValue(nextValue, silent)
				end,
				Get = function()
					return value
				end,
			}
		end

		local function createTextInput(group, options)
			local row = createSettingRow(group, options)
			local box = styledBackground(make("TextBox", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				ClearTextOnFocus = false,
				Font = DarkUI.Fonts.Bold,
				PlaceholderColor3 = self.Theme.Muted,
				PlaceholderText = options.Placeholder or "",
				Position = UDim2.new(1, -18, 0.5, 0),
				Size = UDim2.fromOffset(options.Width or 190, 36),
				Text = options.Default or "",
				TextColor3 = self.Theme.Text,
				TextSize = 14,
				Parent = row,
			}, {
				corner(12),
				styledStroke(stroke(self.Theme.Stroke, 0.28, 1), "Stroke"),
			}), "Panel")
			box:SetAttribute("DarkUIText", "Text")

			return box
		end

		local function createButtonRow(group, options)
			local row = createSettingRow(group, options)
			local button = styledBackground(make("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				AutoButtonColor = false,
				BorderSizePixel = 0,
				Font = DarkUI.Fonts.Bold,
				Position = UDim2.new(1, -18, 0.5, 0),
				Size = UDim2.fromOffset(options.Width or 150, 36),
				Text = options.ButtonText or "Run",
				TextColor3 = self.Theme.Text,
				TextSize = 14,
				Parent = row,
			}, {
				corner(12),
				styledStroke(stroke(self.Theme.Stroke, 0.25, 1), "Stroke"),
			}), options.Accent and "Accent" or "Panel")
			button:SetAttribute("DarkUIText", "Text")
			connect(button.MouseButton1Click, function()
				if options.Callback then
					options.Callback()
				end
			end)
			attachHover(button, options.Accent and "Accent" or "Panel", "PanelLight", 1.02)
			attachPress(button, 0.95)
			return button
		end

		createSettingsSubTab("General")
		createSettingsSubTab("Theme")
		createSettingsSubTab("Snapshots")

		local generalPage = createSettingsPage("General")
		local themePage = createSettingsPage("Theme")
		local snapshotsPage = createSettingsPage("Snapshots")
		registerRenderer(function()
			setSettingsPage(activeSettingsPage)
		end)

		createCategory(generalPage, "Localization")
		local localization = createGroup(generalPage)
		createCycleDropdown(localization, {
			Title = "Language",
			Description = "Display language for the built-in interface.",
			Items = { "English", "Vietnamese" },
			Default = "English",
			Callback = function(value)
				self.Language = value
			end,
		})

		createCategory(generalPage, "Performance")
		local performance = createGroup(generalPage)
		createCycleDropdown(performance, {
			Title = "FPS Cap",
			Description = "Global frame rate cap for this client. Requires executor support.",
			Items = { "60 FPS", "120 FPS", "144 FPS", "240 FPS", "Uncapped" },
			Default = "60 FPS",
			Callback = function(value)
				local cap = tonumber(string.match(tostring(value), "%d+")) or 0
				if type(setfpscap) == "function" then
					setfpscap(cap)
				else
					self:Notify("FPS Cap", "setfpscap is not available in this executor.", "Warning")
				end
			end,
		})
		createSwitch(performance, {
			Title = "3D Rendering",
			Description = "Disable 3D world rendering to save GPU. The UI remains visible.",
			Default = true,
			Callback = function(value)
				pcall(function()
					RunService:Set3dRenderingEnabled(value)
				end)
			end,
		})

		createCategory(generalPage, "Window")
		local windowGroup = createGroup(generalPage)
		createSlider(windowGroup, {
			Title = "Drag FPS Cap",
			Description = "0 = uncapped drag updates. Higher cap = smoother but more work.",
			Min = 0,
			Max = 120,
			Default = self.DragFPSCap,
			Suffix = "Hz",
			Callback = function(value)
				self.DragFPSCap = value
			end,
		})
		createSwitch(windowGroup, {
			Title = "Use Drag Skeleton",
			Description = "Use lightweight drag mode setting for scripts that hook into it.",
			Default = self.UseDragSkeleton,
			Callback = function(value)
				self.UseDragSkeleton = value
			end,
		})
		createSwitch(windowGroup, {
			Title = "Full UI Visibility Animation",
			Description = "Use scale and fade animation when hiding or showing the window.",
			Default = self.FullVisibilityAnimation,
			Callback = function(value)
				self.FullVisibilityAnimation = value
			end,
		})

		createCategory(themePage, "Appearance")
		local appearance = createGroup(themePage)
		local themes = {}
		for name in pairs(DarkUI.ThemePresets) do
			table.insert(themes, name)
		end
		table.sort(themes)
		createCycleDropdown(appearance, {
			Title = "Theme Preset",
			Description = "Switch the whole UI theme.",
			Items = themes,
			Default = self.ThemeName,
			Callback = function(value)
				self:SetTheme(value)
			end,
		})

		local accentRow = createSettingRow(appearance, {
			Title = "Accent Color",
			Description = "Pick the highlight color used by toggles, sliders and active tabs.",
			Height = 78,
		})
		local accentColors = {
			Color3.fromRGB(198, 232, 52),
			Color3.fromRGB(24, 179, 101),
			Color3.fromRGB(96, 205, 255),
			Color3.fromRGB(164, 94, 255),
			Color3.fromRGB(255, 93, 101),
			Color3.fromRGB(255, 203, 52),
		}
		for index, color in ipairs(accentColors) do
			local swatch = make("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				AutoButtonColor = false,
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -18 - ((#accentColors - index) * 34), 0.5, 0),
				Size = UDim2.fromOffset(24, 24),
				Text = "",
				Parent = accentRow,
			}, {
				corner(8),
				stroke(self.Theme.Text, 0.72, 1),
			})

			connect(swatch.MouseButton1Click, function()
				self:SetAccentColor(color)
			end)
			attachPress(swatch, 0.9)
		end

		createSwitch(appearance, {
			Title = "Acrylic",
			Description = "Use softer transparent dark surfaces.",
			Default = self.Acrylic,
			Callback = function(value)
				self.Acrylic = value
				self:_applyTheme()
			end,
		})
		createSwitch(appearance, {
			Title = "Borderless Theme",
			Description = "Hide most theme borders for a cleaner glass look.",
			Default = self.Borderless,
			Callback = function(value)
				self.Borderless = value
				self:_applyTheme()
			end,
		})

		createCategory(snapshotsPage, "Config")
		local configGroup = createGroup(snapshotsPage)
		local configNameBox = createTextInput(configGroup, {
			Title = "Config Name",
			Description = "Snapshot profile stored through executor file API.",
			Default = string.gsub(self.ConfigName, "%.json$", ""),
			Placeholder = "default",
		})
		createButtonRow(configGroup, {
			Title = "Save Snapshot",
			Description = "Save current control values, theme and accent color.",
			ButtonText = "Save",
			Accent = true,
			Callback = function()
				self:SaveConfig(configNameBox.Text)
			end,
		})
		createButtonRow(configGroup, {
			Title = "Load Snapshot",
			Description = "Load values from the selected snapshot profile.",
			ButtonText = "Load",
			Callback = function()
				self:LoadConfig(configNameBox.Text)
			end,
		})
		createButtonRow(configGroup, {
			Title = "Delete Snapshot",
			Description = "Delete the selected snapshot profile from disk.",
			ButtonText = "Delete",
			Callback = function()
				self:Confirm({
					Title = "Delete Snapshot",
					Text = "Delete this config profile?",
					ConfirmText = "Delete",
					Callback = function()
						self:DeleteConfig(configNameBox.Text)
					end,
				})
			end,
		})

		setSettingsPage("General")
		return tab
		end

		return tab
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
	local lastDragUpdate = 0

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

	local function beginWindowDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if resizing then
				return
			end
			dragging = true
			dragStart = input.Position
			startPosition = root.Position
		end
	end

	connect(header.InputBegan, beginWindowDrag)
	if not showTitleBar then
		connect(navPanel.InputBegan, beginWindowDrag)
	end

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

		if dragging or resizing then
			local dragCap = tonumber(window.DragFPSCap) or 0
			if dragCap > 0 then
				local now = os.clock()
				if now - lastDragUpdate < (1 / dragCap) then
					return
				end
				lastDragUpdate = now
			end
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
			setUiVisible(not uiVisible)
		end
	end)

	if window.BuiltInSettings and not window.BuiltInSettingsCreated and #window.TabOrder == 0 then
		window:CreateBuiltInSettingsTab()
	end

	window:_applyTheme()
	return window
end

return DarkUI
