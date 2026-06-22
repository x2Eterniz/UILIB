-- Vxizi Glass UI Library
-- Standalone Roblox Luau UI library.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui")

local Library = {}
Library.__index = Library
Library.Version = "3.0.0-glass-lime"

local Theme = {
	Backdrop = Color3.fromRGB(6, 8, 6),
	Panel = Color3.fromRGB(13, 14, 13),
	Rail = Color3.fromRGB(15, 16, 15),
	Card = Color3.fromRGB(17, 18, 17),
	CardHover = Color3.fromRGB(23, 24, 22),
	Row = Color3.fromRGB(17, 18, 17),
	Field = Color3.fromRGB(34, 35, 33),
	FieldHover = Color3.fromRGB(42, 43, 40),
	Stroke = Color3.fromRGB(58, 62, 55),
	SoftStroke = Color3.fromRGB(37, 40, 36),
	Text = Color3.fromRGB(242, 243, 237),
	Muted = Color3.fromRGB(157, 158, 151),
	MutedDark = Color3.fromRGB(105, 107, 101),
	Accent = Color3.fromRGB(199, 226, 61),
	AccentDark = Color3.fromRGB(139, 165, 40),
	Off = Color3.fromRGB(44, 46, 43),
	Shadow = Color3.fromRGB(0, 0, 0),
	White = Color3.fromRGB(255, 255, 255)
}

Library.Theme = Theme

local CHECK_MARK = utf8 and utf8.char(10003) or "v"

local function safe(fn, ...)
	local ok, result = pcall(fn, ...)
	if ok then
		return result
	end
	return nil
end

local function trim(text)
	return tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function make(className, props, children)
	local object = Instance.new(className)
	for key, value in pairs(props or {}) do
		object[key] = value
	end
	for _, child in ipairs(children or {}) do
		child.Parent = object
	end
	return object
end

local function corner(parent, radius)
	return make("UICorner", {
		CornerRadius = UDim.new(0, radius or 8),
		Parent = parent
	})
end

local function stroke(parent, color, thickness, transparency)
	return make("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent
	})
end

local function padding(parent, left, top, right, bottom)
	return make("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingRight = UDim.new(0, right or left or 0),
		PaddingBottom = UDim.new(0, bottom or top or 0),
		Parent = parent
	})
end

local function list(parent, direction, gap, align)
	return make("UIListLayout", {
		FillDirection = direction or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, gap or 0),
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Parent = parent
	})
end

local function tween(object, time, props, style, direction)
	local info = TweenInfo.new(
		time or 0.18,
		style or Enum.EasingStyle.Quart,
		direction or Enum.EasingDirection.Out
	)
	local tw = TweenService:Create(object, info, props)
	tw:Play()
	return tw
end

local function getScale(parent)
	local scale = parent:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = make("UIScale", { Scale = 1, Parent = parent })
	end
	return scale
end

local function pop(parent)
	local scale = getScale(parent)
	scale.Scale = 0.985
	tween(scale, 0.13, { Scale = 1 }, Enum.EasingStyle.Back)
end

local function resolveContentId(value)
	if value == nil then
		return nil
	end
	if type(value) == "number" then
		return "rbxassetid://" .. tostring(math.floor(value))
	end
	local text = trim(value)
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
	local assetId = string.match(text, "^assetid://(%d+)$") or string.match(text, "[%?&]id=(%d+)") or string.match(text, "^(%d+)$")
	if assetId then
		return "rbxassetid://" .. assetId
	end
	return text
end

local function setTextStyle(label, size, color, weight)
	label.FontFace = Font.new(
		"rbxasset://fonts/families/GothamSSm.json",
		weight or Enum.FontWeight.Medium,
		Enum.FontStyle.Normal
	)
	label.TextSize = size
	label.TextColor3 = color
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.BackgroundTransparency = 1
	label.RichText = false
end

local function bindHover(button, baseColor, hoverColor)
	button.MouseEnter:Connect(function()
		tween(button, 0.15, { BackgroundColor3 = hoverColor or Theme.CardHover })
	end)
	button.MouseLeave:Connect(function()
		tween(button, 0.15, { BackgroundColor3 = baseColor })
	end)
end

local function makeIcon(parent, name, color)
	local holder = make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(28, 28),
		Parent = parent
	})
	local c = color or Theme.Muted
	name = string.lower(tostring(name or "circle"))

	local function line(pos, size, rotation)
		local f = make("Frame", {
			BackgroundColor3 = c,
			BorderSizePixel = 0,
			Position = pos,
			Size = size,
			Rotation = rotation or 0,
			Parent = holder
		})
		corner(f, 2)
		return f
	end

	if name == "home" then
		line(UDim2.fromOffset(7, 14), UDim2.fromOffset(14, 10))
		line(UDim2.fromOffset(6, 12), UDim2.fromOffset(16, 3), -35)
		line(UDim2.fromOffset(12, 7), UDim2.fromOffset(16, 3), 35)
	elseif name == "settings" or name == "setting" then
		for i = 0, 5 do
			line(UDim2.fromOffset(13, 2), UDim2.fromOffset(2, 6), i * 60)
		end
		local dot = make("Frame", {
			BackgroundColor3 = Theme.Rail,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(9, 9),
			Size = UDim2.fromOffset(10, 10),
			Parent = holder
		})
		corner(dot, 8)
		stroke(dot, c, 2, 0)
	elseif name == "combat" then
		line(UDim2.fromOffset(8, 5), UDim2.fromOffset(3, 20), -45)
		line(UDim2.fromOffset(16, 5), UDim2.fromOffset(3, 20), 45)
	elseif name == "render" then
		local eye = make("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(5, 8),
			Size = UDim2.fromOffset(18, 12),
			Parent = holder
		})
		corner(eye, 10)
		stroke(eye, c, 2, 0)
		local dot = make("Frame", {
			BackgroundColor3 = c,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(11, 11),
			Size = UDim2.fromOffset(6, 6),
			Parent = holder
		})
		corner(dot, 6)
	elseif name == "movement" then
		line(UDim2.fromOffset(14, 5), UDim2.fromOffset(3, 18), 45)
		line(UDim2.fromOffset(8, 7), UDim2.fromOffset(10, 3), 45)
		line(UDim2.fromOffset(14, 18), UDim2.fromOffset(10, 3), 45)
	elseif name == "utility" then
		line(UDim2.fromOffset(7, 7), UDim2.fromOffset(14, 14))
		line(UDim2.fromOffset(11, 3), UDim2.fromOffset(6, 22))
	else
		local label = make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = string.sub(string.upper(tostring(name or "?")), 1, 1),
			TextColor3 = c,
			TextSize = 20,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
			Parent = holder
		})
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.TextYAlignment = Enum.TextYAlignment.Center
	end

	return holder
end

local function attachDrag(handle, target)
	local dragging = false
	local startInput
	local startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startInput = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startInput
			target.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local Module = {}
Module.__index = Module

local function refreshCanvas(scroller)
	local layout = scroller:FindFirstChildOfClass("UIListLayout")
	if layout then
		scroller.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 24)
	end
end

local function makeControlRow(section, height, title, description)
	local row = make("Frame", {
		BackgroundColor3 = Theme.Row,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height or 82),
		Parent = section.Body
	})

	local rowTitle = make("TextLabel", {
		Position = UDim2.fromOffset(28, 12),
		Size = UDim2.new(1, -260, 0, 34),
		Text = tostring(title or "Control"),
		Parent = row
	})
	setTextStyle(rowTitle, 23, Theme.Text, Enum.FontWeight.SemiBold)

	local rowDesc = make("TextLabel", {
		Position = UDim2.fromOffset(28, 44),
		Size = UDim2.new(1, -280, 0, 36),
		Text = tostring(description or ""),
		TextWrapped = true,
		Parent = row
	})
	setTextStyle(rowDesc, 18, Theme.Muted, Enum.FontWeight.Medium)

	local lineFrame = make("Frame", {
		BackgroundColor3 = Theme.SoftStroke,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
		Parent = row
	})

	return row, rowTitle, rowDesc, lineFrame
end

local function makeActionGlyph(parent, kind, color)
	local holder = make("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -28, 0.5, 0),
		Size = UDim2.fromOffset(32, 32),
		Parent = parent
	})

	color = color or Theme.Muted
	kind = kind or "play"
	if kind == "chevron" then
		local a = make("Frame", {
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(10, 8),
			Size = UDim2.fromOffset(4, 18),
			Rotation = -45,
			Parent = holder
		})
		local b = make("Frame", {
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(18, 8),
			Size = UDim2.fromOffset(4, 18),
			Rotation = 45,
			Parent = holder
		})
		corner(a, 2)
		corner(b, 2)
	else
		local tri = make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = ">",
			TextColor3 = color,
			TextSize = 28,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
			Parent = holder
		})
		tri.TextXAlignment = Enum.TextXAlignment.Center
		tri.TextYAlignment = Enum.TextYAlignment.Center
	end
	return holder
end

local function createPill(parent, width, text)
	local pill = make("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Field,
		BackgroundTransparency = 0.03,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -28, 0.5, 0),
		Size = UDim2.fromOffset(width or 190, 54),
		Text = "",
		Parent = parent
	})
	corner(pill, 16)
	stroke(pill, Theme.SoftStroke, 1, 0.18)
	bindHover(pill, Theme.Field, Theme.FieldHover)

	local label = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 0),
		Size = UDim2.new(1, -54, 1, 0),
		Text = text or "Select...",
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = pill
	})
	setTextStyle(label, 22, Theme.Muted, Enum.FontWeight.SemiBold)

	local arrow = make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -18, 0.5, -1),
		Size = UDim2.fromOffset(24, 24),
		Text = "v",
		TextColor3 = Theme.Muted,
		TextSize = 22,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
		Parent = pill
	})
	arrow.TextXAlignment = Enum.TextXAlignment.Center
	arrow.TextYAlignment = Enum.TextYAlignment.Center

	return pill, label, arrow
end

function Library:CreateWindow(config)
	config = config or {}
	if not PlayerGui then
		return setmetatable({}, Window)
	end

	local guiName = config.Name or "VxiziGlassUI"
	local old = PlayerGui:FindFirstChild(guiName)
	if old then
		old:Destroy()
	end

	local screenGui = make("ScreenGui", {
		Name = guiName,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = PlayerGui
	})

	local root = make("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Backdrop,
		BackgroundTransparency = config.Acrylic == false and 0.03 or 0.17,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = config.Position or UDim2.fromScale(0.5, 0.5),
		Size = config.Size or UDim2.fromOffset(1220, 760),
		Parent = screenGui
	})
	corner(root, 28)
	stroke(root, Theme.Stroke, 1, 0.18)
	getScale(root).Scale = 0.965
	tween(getScale(root), 0.35, { Scale = 1 }, Enum.EasingStyle.Back)

	local shadow = make("ImageLabel", {
		Name = "Shadow",
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217",
		ImageColor3 = Theme.Shadow,
		ImageTransparency = 0.45,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 58, 1, 58),
		ZIndex = 1,
		Parent = root
	})

	local rail = make("Frame", {
		Name = "Rail",
		BackgroundColor3 = Theme.Rail,
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.fromOffset(18, 22),
		Size = UDim2.new(0, 82, 1, -44),
		Parent = root
	})
	corner(rail, 22)
	stroke(rail, Theme.SoftStroke, 1, 0.16)
	attachDrag(rail, root)

	local tabList = make("Frame", {
		Name = "TabButtons",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.new(1, 0, 1, -120),
		Parent = rail
	})
	list(tabList, Enum.FillDirection.Vertical, 18, Enum.HorizontalAlignment.Center)

	local settingsButton = make("TextButton", {
		Name = "SettingsButton",
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Rail,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -24),
		Size = UDim2.fromOffset(58, 58),
		Text = "",
		Parent = rail
	})
	corner(settingsButton, 16)
	makeIcon(settingsButton, "settings", Theme.Muted)

	local content = make("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(128, 32),
		Size = UDim2.new(1, -158, 1, -64),
		Parent = root
	})

	local pages = make("Frame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = content
	})

	local resize = make("TextButton", {
		Name = "Resize",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -13, 1, -12),
		Size = UDim2.fromOffset(44, 44),
		Text = "///",
		TextColor3 = Theme.Accent,
		TextTransparency = 0.18,
		TextSize = 28,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
		Rotation = -45,
		Parent = root
	})

	local draggingResize = false
	local resizeStart
	local sizeStart
	resize.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingResize = true
			resizeStart = input.Position
			sizeStart = root.AbsoluteSize
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					draggingResize = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingResize and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - resizeStart
			local newX = math.clamp(sizeStart.X + delta.X, 720, 1500)
			local newY = math.clamp(sizeStart.Y + delta.Y, 480, 920)
			root.Size = UDim2.fromOffset(newX, newY)
		end
	end)

	local self = setmetatable({
		ScreenGui = screenGui,
		Root = root,
		Rail = rail,
		TabList = tabList,
		SettingsButton = settingsButton,
		Content = content,
		Pages = pages,
		Tabs = {},
		Sections = {},
		Controls = {},
		Flags = {},
		ActiveTab = nil,
		ConfigFolder = config.ConfigFolder or "Vxizi",
		Accent = Theme.Accent
	}, Window)

	settingsButton.MouseEnter:Connect(function()
		tween(settingsButton, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = Theme.CardHover })
	end)
	settingsButton.MouseLeave:Connect(function()
		tween(settingsButton, 0.15, { BackgroundTransparency = 1, BackgroundColor3 = Theme.Rail })
	end)
	settingsButton.MouseButton1Click:Connect(function()
		if self.SettingsTab then
			self:SelectTab(self.SettingsTab)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		local key = config.ToggleKey or Enum.KeyCode.RightControl
		if input.KeyCode == key then
			screenGui.Enabled = not screenGui.Enabled
		end
	end)

	return self
end

function Window:SelectTab(tab)
	for _, item in ipairs(self.Tabs) do
		local active = item == tab
		item.Page.Visible = active
		tween(item.Button, 0.18, {
			BackgroundTransparency = active and 0 or 1,
			BackgroundColor3 = active and Theme.Accent or Theme.Rail
		})
		if item.IconHolder then
			for _, child in ipairs(item.IconHolder:GetDescendants()) do
				if child:IsA("Frame") then
					child.BackgroundColor3 = active and Theme.Backdrop or Theme.Muted
				elseif child:IsA("TextLabel") then
					child.TextColor3 = active and Theme.Backdrop or Theme.Muted
				elseif child:IsA("UIStroke") then
					child.Color = active and Theme.Backdrop or Theme.Muted
				end
			end
		end
	end
	self.ActiveTab = tab
end

function Window:CreateTab(nameOrConfig, icon)
	local config = {}
	if type(nameOrConfig) == "table" then
		config = nameOrConfig
	else
		config.Name = tostring(nameOrConfig or "Tab")
		config.Icon = icon
	end
	local tabName = config.Name or config.Title or config.Text or "Tab"

	local page = make("ScrollingFrame", {
		Name = tabName,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,
		ScrollBarImageTransparency = 0.15,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = self.Pages
	})

	local grid = make("Frame", {
		Name = "Grid",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, -12, 0, 0),
		Parent = page
	})

	local columns = make("UIGridLayout", {
		CellPadding = UDim2.fromOffset(24, 0),
		CellSize = UDim2.new(0.5, -12, 0, 10),
		FillDirectionMaxCells = 2,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = grid
	})

	local colA = make("Frame", {
		Name = "Column1",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -12, 0, 0),
		Parent = grid
	})
	local colB = make("Frame", {
		Name = "Column2",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -12, 0, 0),
		Parent = grid
	})
	local listA = list(colA, Enum.FillDirection.Vertical, 28, Enum.HorizontalAlignment.Left)
	local listB = list(colB, Enum.FillDirection.Vertical, 28, Enum.HorizontalAlignment.Left)

	local function sync()
		colA.Size = UDim2.new(0.5, -12, 0, listA.AbsoluteContentSize.Y)
		colB.Size = UDim2.new(0.5, -12, 0, listB.AbsoluteContentSize.Y)
		local maxY = math.max(listA.AbsoluteContentSize.Y, listB.AbsoluteContentSize.Y)
		columns.CellSize = UDim2.new(0.5, -12, 0, maxY)
		grid.Size = UDim2.new(1, -12, 0, maxY)
		page.CanvasSize = UDim2.fromOffset(0, maxY + 24)
	end
	listA:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(sync)
	listB:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(sync)
	page:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync)

	local button = make("TextButton", {
		Name = tabName,
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Rail,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(58, 58),
		Text = "",
		Parent = self.TabList
	})
	corner(button, 16)
	local iconName = config.Icon or string.lower(tabName)
	local iconHolder = makeIcon(button, iconName, Theme.Muted)
	iconHolder.AnchorPoint = Vector2.new(0.5, 0.5)
	iconHolder.Position = UDim2.fromScale(0.5, 0.5)

	local tab = setmetatable({
		Window = self,
		Name = tabName,
		Button = button,
		IconHolder = iconHolder,
		Page = page,
		Grid = grid,
		Columns = { colA, colB },
		Lists = { listA, listB },
		NextColumn = 1,
		Sections = {}
	}, Tab)

	table.insert(self.Tabs, tab)

	button.MouseEnter:Connect(function()
		if self.ActiveTab ~= tab then
			tween(button, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = Theme.CardHover })
		end
	end)
	button.MouseLeave:Connect(function()
		if self.ActiveTab ~= tab then
			tween(button, 0.15, { BackgroundTransparency = 1, BackgroundColor3 = Theme.Rail })
		end
	end)
	button.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	if not self.ActiveTab then
		self:SelectTab(tab)
	end

	sync()
	return tab
end

Window.AddTab = Window.CreateTab

function Window:CreateSettingsTab()
	if self.SettingsTab then
		return self.SettingsTab
	end
	local tab = self:CreateTab({ Name = "Settings", Icon = "settings" })
	self.SettingsTab = tab
	return tab
end

function Window:Notify(config)
	config = type(config) == "table" and config or { Title = "Notification", Content = tostring(config or "") }
	local note = make("Frame", {
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -22, 1, -22),
		Size = UDim2.fromOffset(360, 94),
		Parent = self.Root
	})
	corner(note, 22)
	stroke(note, Theme.SoftStroke, 1, 0.08)
	local title = make("TextLabel", {
		Position = UDim2.fromOffset(18, 12),
		Size = UDim2.new(1, -36, 0, 28),
		Text = config.Title or "Notification",
		Parent = note
	})
	setTextStyle(title, 18, Theme.Text, Enum.FontWeight.Bold)
	local content = make("TextLabel", {
		Position = UDim2.fromOffset(18, 40),
		Size = UDim2.new(1, -36, 0, 42),
		Text = config.Content or config.Text or "",
		TextWrapped = true,
		Parent = note
	})
	setTextStyle(content, 15, Theme.Muted, Enum.FontWeight.Medium)
	getScale(note).Scale = 0.94
	tween(getScale(note), 0.22, { Scale = 1 }, Enum.EasingStyle.Back)
	task.delay(config.Duration or 3, function()
		if note and note.Parent then
			tween(note, 0.2, { BackgroundTransparency = 1 })
			task.wait(0.22)
			if note and note.Parent then
				note:Destroy()
			end
		end
	end)
	return note
end

function Window:Destroy()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
end

function Window:GetConfig()
	local data = {}
	for flag, control in pairs(self.Flags) do
		data[flag] = control.Value
	end
	return data
end

function Window:ApplyConfig(data)
	if type(data) ~= "table" then
		return
	end
	for flag, value in pairs(data) do
		local control = self.Flags[flag]
		if control and control.Set then
			control:Set(value, true)
		end
	end
end

function Window:SaveConfig(name)
	if not writefile or not makefolder then
		return false
	end
	name = trim(name or "default")
	safe(makefolder, self.ConfigFolder)
	local encoded = HttpService:JSONEncode(self:GetConfig())
	safe(writefile, self.ConfigFolder .. "/" .. name .. ".json", encoded)
	return true
end

function Window:LoadConfig(name)
	if not readfile or not isfile then
		return false
	end
	name = trim(name or "default")
	local path = self.ConfigFolder .. "/" .. name .. ".json"
	if not safe(isfile, path) then
		return false
	end
	local decoded = safe(function()
		return HttpService:JSONDecode(readfile(path))
	end)
	self:ApplyConfig(decoded)
	return decoded ~= nil
end

function Tab:AddSection(name, column)
	if type(name) == "table" then
		column = name.Column or column
		name = name.Name or name.Title or name.Text
	end
	column = column or self.NextColumn
	if column ~= 1 and column ~= 2 then
		column = self.NextColumn
	end
	self.NextColumn = column == 1 and 2 or 1

	local holder = make("Frame", {
		Name = tostring(name or "Section"),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 120),
		Parent = self.Columns[column]
	})

	local title = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(34, 0),
		Size = UDim2.new(1, -68, 0, 40),
		Text = string.upper(tostring(name or "Section")),
		Parent = holder
	})
	setTextStyle(title, 26, Theme.Muted, Enum.FontWeight.Medium)

	local body = make("Frame", {
		Name = "Body",
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.fromOffset(0, 42),
		Size = UDim2.new(1, 0, 0, 80),
		Parent = holder
	})
	corner(body, 30)
	stroke(body, Theme.SoftStroke, 1, 0.08)

	local bodyList = list(body, Enum.FillDirection.Vertical, 0, Enum.HorizontalAlignment.Left)
	bodyList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local height = bodyList.AbsoluteContentSize.Y
		body.Size = UDim2.new(1, 0, 0, height)
		holder.Size = UDim2.new(1, 0, 0, height + 42)
	end)

	local section = setmetatable({
		Tab = self,
		Window = self.Window,
		Holder = holder,
		Title = title,
		Body = body,
		Layout = bodyList,
		Controls = {}
	}, Section)

	table.insert(self.Sections, section)
	table.insert(self.Window.Sections, section)
	return section
end

Tab.CreateSection = Tab.AddSection
Tab.Section = Tab.AddSection

function Tab:CreateModule(config)
	config = type(config) == "table" and config or { Name = tostring(config or "Module") }
	local moduleName = config.Name or config.Title or config.Text or "Module"
	local section = self:AddSection(moduleName, config.Column)
	local module = setmetatable({
		Section = section,
		Window = self.Window,
		Name = moduleName,
		Expanded = true
	}, Module)
	if config.Default ~= nil then
		module.Toggle = section:AddToggle({
			Name = moduleName,
			Description = config.Description,
			Default = config.Default,
			Flag = config.Flag,
			Callback = config.Callback
		})
	end
	return module
end

Tab.AddModule = Tab.CreateModule

function Section:Register(control, flag)
	table.insert(self.Controls, control)
	if flag then
		self.Window.Flags[flag] = control
	end
	return control
end

function Section:AddButton(config)
	config = type(config) == "table" and config or { Name = tostring(config or "Button") }
	local controlName = config.Name or config.Title or config.Text or "Button"
	local row = make("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Row,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 82),
		Text = "",
		Parent = self.Body
	})
	local title = make("TextLabel", {
		Position = UDim2.fromOffset(28, 0),
		Size = UDim2.new(1, -120, 1, 0),
		Text = controlName,
		Parent = row
	})
	setTextStyle(title, 23, Theme.Text, Enum.FontWeight.SemiBold)
	makeActionGlyph(row, "play", Theme.Muted)
	bindHover(row, Theme.Row, Theme.CardHover)
	row.MouseButton1Click:Connect(function()
		pop(row)
		if config.Callback then
			task.spawn(config.Callback)
		end
	end)
	local control = { Instance = row, Value = nil }
	return self:Register(control, config.Flag)
end

Section.CreateButton = Section.AddButton

function Section:AddToggle(config)
	config = type(config) == "table" and config or { Name = tostring(config or "Toggle") }
	local value = config.Default == true
	local row = makeControlRow(self, 88, config.Name or config.Title or config.Text or "Toggle", config.Description or "")
	local button = make("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = value and Theme.Accent or Theme.Off,
		BackgroundTransparency = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -28, 0.5, 0),
		Size = UDim2.fromOffset(88, 42),
		Text = "",
		Parent = row
	})
	corner(button, 22)
	stroke(button, Theme.SoftStroke, 1, value and 1 or 0.1)
	local knob = make("Frame", {
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		Position = value and UDim2.fromOffset(50, 5) or UDim2.fromOffset(5, 5),
		Size = UDim2.fromOffset(32, 32),
		Parent = button
	})
	corner(knob, 18)

	local control = { Instance = row, Button = button, Knob = knob, Value = value }
	function control:Set(newValue, silent)
		self.Value = newValue == true
		tween(button, 0.18, { BackgroundColor3 = self.Value and Theme.Accent or Theme.Off })
		tween(knob, 0.2, { Position = self.Value and UDim2.fromOffset(50, 5) or UDim2.fromOffset(5, 5) }, Enum.EasingStyle.Back)
		if config.Callback and not silent then
			task.spawn(config.Callback, self.Value)
		end
	end
	button.MouseButton1Click:Connect(function()
		pop(button)
		control:Set(not control.Value)
	end)

	control:Set(value, true)
	return self:Register(control, config.Flag)
end

Section.CreateToggle = Section.AddToggle

function Section:AddCheckbox(config)
	config = type(config) == "table" and config or { Name = tostring(config or "Checkbox") }
	local value = config.Default == true
	local row = makeControlRow(self, 78, config.Name or config.Title or config.Text or "Checkbox", config.Description or "")
	local box = make("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = value and Theme.Accent or Theme.Field,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -38, 0.5, 0),
		Size = UDim2.fromOffset(34, 34),
		Text = value and CHECK_MARK or "",
		TextColor3 = Theme.Backdrop,
		TextSize = 24,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
		Parent = row
	})
	corner(box, 8)
	stroke(box, Theme.Stroke, 1, 0.02)

	local control = { Instance = row, Button = box, Value = value }
	function control:Set(newValue, silent)
		self.Value = newValue == true
		box.Text = self.Value and CHECK_MARK or ""
		tween(box, 0.15, { BackgroundColor3 = self.Value and Theme.Accent or Theme.Field })
		if config.Callback and not silent then
			task.spawn(config.Callback, self.Value)
		end
	end
	box.MouseButton1Click:Connect(function()
		pop(box)
		control:Set(not control.Value)
	end)

	control:Set(value, true)
	return self:Register(control, config.Flag)
end

Section.CreateCheckbox = Section.AddCheckbox

function Section:AddSlider(config)
	config = config or {}
	local min = tonumber(config.Min or config.Minimum or 0) or 0
	local max = tonumber(config.Max or config.Maximum or 100) or 100
	local decimals = tonumber(config.Decimals or config.Decimal or 0) or 0
	local value = tonumber(config.Default or config.Value or min) or min
	value = math.clamp(value, min, max)
	local suffix = tostring(config.Suffix or "")
	local row = makeControlRow(self, 118, config.Name or config.Title or config.Text or "Slider", config.Description or "")
	local valueBox = make("TextBox", {
		BackgroundColor3 = Theme.Field,
		BackgroundTransparency = 0.03,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -28, 0, 16),
		Size = UDim2.fromOffset(110, 42),
		ClearTextOnFocus = false,
		Text = "",
		TextColor3 = Theme.Text,
		TextSize = 20,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		Parent = row
	})
	valueBox.TextXAlignment = Enum.TextXAlignment.Center
	corner(valueBox, 14)
	stroke(valueBox, Theme.SoftStroke, 1, 0.12)

	local rail = make("Frame", {
		BackgroundColor3 = Theme.Field,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 28, 1, -32),
		Size = UDim2.new(1, -56, 0, 10),
		Parent = row
	})
	corner(rail, 6)
	local fill = make("Frame", {
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 1),
		Parent = rail
	})
	corner(fill, 6)
	local knob = make("Frame", {
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(28, 28),
		Parent = rail
	})
	corner(knob, 16)
	stroke(knob, Theme.Backdrop, 3, 0.05)

	local control = { Instance = row, Value = value }
	local dragging = false

	local function round(num)
		local mult = 10 ^ decimals
		return math.floor(num * mult + 0.5) / mult
	end

	function control:Set(newValue, silent)
		local num = tonumber(newValue) or min
		num = math.clamp(round(num), min, max)
		self.Value = num
		local pct = (num - min) / math.max(max - min, 1)
		tween(fill, 0.12, { Size = UDim2.fromScale(pct, 1) })
		tween(knob, 0.12, { Position = UDim2.fromScale(pct, 0.5) })
		valueBox.Text = tostring(num) .. suffix
		if config.Callback and not silent then
			task.spawn(config.Callback, num)
		end
	end

	local function setFromX(x)
		local pct = math.clamp((x - rail.AbsolutePosition.X) / math.max(rail.AbsoluteSize.X, 1), 0, 1)
		control:Set(min + (max - min) * pct)
	end

	rail.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromX(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	valueBox.FocusLost:Connect(function()
		local clean = tostring(valueBox.Text):gsub("[^%d%.-]", "")
		control:Set(tonumber(clean) or control.Value)
	end)

	control:Set(value, true)
	return self:Register(control, config.Flag)
end

Section.CreateSlider = Section.AddSlider

function Section:AddDropdown(config)
	config = config or {}
	local options = config.Options or config.Values or config.List or {}
	local selected = config.Default or config.Value or options[1]
	local row = makeControlRow(self, 88, config.Name or config.Title or config.Text or "Dropdown", config.Description or "")
	local pill, label, arrow = createPill(row, config.Width or 210, selected and tostring(selected) or "Select...")
	local optionHolder = make("Frame", {
		BackgroundColor3 = Theme.Field,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -28, 0, 72),
		Size = UDim2.fromOffset(config.Width or 210, 0),
		Visible = false,
		ZIndex = 4,
		Parent = row
	})
	corner(optionHolder, 16)
	stroke(optionHolder, Theme.SoftStroke, 1, 0.08)
	local optionLayout = list(optionHolder, Enum.FillDirection.Vertical, 0, Enum.HorizontalAlignment.Left)

	local control = { Instance = row, Value = selected, Options = options, Open = false }

	local function rebuild(filterText)
		for _, child in ipairs(optionHolder:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		local count = 0
		filterText = string.lower(trim(filterText or ""))
		for _, option in ipairs(options) do
			local text = tostring(option)
			if filterText == "" or string.find(string.lower(text), filterText, 1, true) then
				count += 1
				local item = make("TextButton", {
					AutoButtonColor = false,
					BackgroundColor3 = text == tostring(control.Value) and Theme.CardHover or Theme.Field,
					BackgroundTransparency = 0,
					Size = UDim2.new(1, 0, 0, 42),
					Text = "",
					ZIndex = 5,
					Parent = optionHolder
				})
				local accent = make("Frame", {
					BackgroundColor3 = Theme.Accent,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(0, 10),
					Size = UDim2.fromOffset(text == tostring(control.Value) and 4 or 0, 22),
					ZIndex = 6,
					Parent = item
				})
				corner(accent, 3)
				local itemLabel = make("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(16, 0),
					Size = UDim2.new(1, -24, 1, 0),
					Text = text,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 6,
					Parent = item
				})
				setTextStyle(itemLabel, 18, Theme.Text, Enum.FontWeight.SemiBold)
				bindHover(item, item.BackgroundColor3, Theme.CardHover)
				item.MouseButton1Click:Connect(function()
					control:Set(option)
					control:Close()
				end)
			end
		end
		return count
	end

	function control:OpenList()
		if self.Open then
			return
		end
		self.Open = true
		rebuild("")
		local h = math.min(#options * 42, config.MaxHeight or 210)
		row.Size = UDim2.new(1, 0, 0, 88 + h + 12)
		optionHolder.Visible = true
		optionHolder.Size = UDim2.fromOffset(config.Width or 210, 0)
		tween(optionHolder, 0.18, { Size = UDim2.fromOffset(config.Width or 210, h) })
		tween(arrow, 0.18, { Rotation = 180 })
	end

	function control:Close()
		if not self.Open then
			return
		end
		self.Open = false
		tween(optionHolder, 0.15, { Size = UDim2.fromOffset(config.Width or 210, 0) })
		tween(arrow, 0.15, { Rotation = 0 })
		task.delay(0.15, function()
			if not self.Open then
				optionHolder.Visible = false
				row.Size = UDim2.new(1, 0, 0, 88)
			end
		end)
	end

	function control:Set(newValue, silent)
		self.Value = newValue
		label.Text = newValue and tostring(newValue) or "Select..."
		if config.Callback and not silent then
			task.spawn(config.Callback, newValue)
		end
	end

	pill.MouseButton1Click:Connect(function()
		pop(pill)
		if control.Open then
			control:Close()
		else
			control:OpenList()
		end
	end)

	control:Set(selected, true)
	return self:Register(control, config.Flag)
end

Section.CreateDropdown = Section.AddDropdown

function Section:AddMultiDropdown(config)
	config = config or {}
	local selected = {}
	for _, v in ipairs(config.Default or config.Value or {}) do
		selected[tostring(v)] = true
	end
	local options = config.Options or config.Values or {}
	local display = {}
	for key, enabled in pairs(selected) do
		if enabled then
			table.insert(display, key)
		end
	end
	local dropdown = self:AddDropdown({
		Name = config.Name or config.Title or config.Text,
		Description = config.Description,
		Options = options,
		Default = #display > 0 and table.concat(display, ", ") or "Select...",
		Width = config.Width,
		MaxHeight = config.MaxHeight
	})
	dropdown.Selected = selected
	function dropdown:Set(newValue, silent)
		if type(newValue) == "table" then
			table.clear(self.Selected)
			for _, v in ipairs(newValue) do
				self.Selected[tostring(v)] = true
			end
		else
			local key = tostring(newValue)
			self.Selected[key] = not self.Selected[key]
		end
		local values = {}
		for key, enabled in pairs(self.Selected) do
			if enabled then
				table.insert(values, key)
			end
		end
		self.Value = values
		local pill = self.Instance:FindFirstChildWhichIsA("TextButton")
		if pill then
			local label = pill:FindFirstChildWhichIsA("TextLabel")
			if label then
				label.Text = #values > 0 and table.concat(values, ", ") or "Select..."
			end
		end
		if config.Callback and not silent then
			task.spawn(config.Callback, values)
		end
	end
	return self:Register(dropdown, config.Flag)
end

Section.CreateMultiDropdown = Section.AddMultiDropdown

function Section:AddTextBox(config)
	config = config or {}
	local row = makeControlRow(self, config.Multiline and 126 or 88, config.Name or config.Title or config.Text or "Input", config.Description or "")
	local box = make("TextBox", {
		BackgroundColor3 = Theme.Field,
		BackgroundTransparency = 0.03,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -28, 0.5, 0),
		Size = UDim2.fromOffset(config.Width or 230, config.Multiline and 78 or 52),
		ClearTextOnFocus = false,
		MultiLine = config.Multiline == true,
		PlaceholderText = config.Placeholder or "Type...",
		PlaceholderColor3 = Theme.MutedDark,
		Text = tostring(config.Default or config.Value or ""),
		TextColor3 = Theme.Text,
		TextSize = 19,
		TextWrapped = config.Multiline == true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = config.Multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		Parent = row
	})
	corner(box, 16)
	stroke(box, Theme.SoftStroke, 1, 0.08)
	padding(box, 14, config.Multiline and 10 or 0, 14, 0)
	local control = { Instance = row, Box = box, Value = box.Text }
	function control:Set(text, silent)
		self.Value = tostring(text or "")
		box.Text = self.Value
		if config.Callback and not silent then
			task.spawn(config.Callback, self.Value)
		end
	end
	box.FocusLost:Connect(function()
		control:Set(box.Text)
	end)
	return self:Register(control, config.Flag)
end

Section.CreateTextBox = Section.AddTextBox
Section.AddInput = Section.AddTextBox

function Section:AddLabel(text)
	local row = makeControlRow(self, 62, tostring(text or "Label"), "")
	local control = { Instance = row, Value = text }
	return self:Register(control)
end

Section.CreateLabel = Section.AddLabel

function Section:AddParagraph(config)
	config = type(config) == "table" and config or { Title = "Paragraph", Content = tostring(config or "") }
	local row = makeControlRow(self, 108, config.Title or config.Name or "Paragraph", config.Content or config.Text or "")
	local control = { Instance = row, Value = config.Content or config.Text or "" }
	return self:Register(control)
end

Section.CreateParagraph = Section.AddParagraph

function Section:AddDivider()
	local divider = make("Frame", {
		BackgroundColor3 = Theme.SoftStroke,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		Parent = self.Body
	})
	return self:Register({ Instance = divider, Value = nil })
end

function Section:AddKeybind(config)
	config = config or {}
	local value = config.Default or config.Key or Enum.KeyCode.RightControl
	local row = makeControlRow(self, 88, config.Name or config.Title or config.Text or "Keybind", config.Description or "")
	local pill, label = createPill(row, config.Width or 180, value.Name or tostring(value))
	local waiting = false
	local control = { Instance = row, Value = value }
	function control:Set(newKey, silent)
		self.Value = newKey
		label.Text = newKey and (newKey.Name or tostring(newKey)) or "None"
		if config.Callback and not silent then
			task.spawn(config.Callback, newKey)
		end
	end
	pill.MouseButton1Click:Connect(function()
		waiting = true
		label.Text = "..."
	end)
	UserInputService.InputBegan:Connect(function(input, processed)
		if waiting and not processed then
			waiting = false
			control:Set(input.KeyCode)
		elseif input.KeyCode == control.Value and config.Pressed then
			task.spawn(config.Pressed)
		end
	end)
	return self:Register(control, config.Flag)
end

Section.CreateKeybind = Section.AddKeybind

function Section:AddColorPicker(config)
	config = config or {}
	local colors = config.Colors or {
		Color3.fromRGB(199, 226, 61),
		Color3.fromRGB(96, 205, 255),
		Color3.fromRGB(255, 93, 106),
		Color3.fromRGB(178, 112, 255),
		Color3.fromRGB(255, 198, 41)
	}
	local value = config.Default or colors[1]
	local row = makeControlRow(self, 94, config.Name or config.Title or config.Text or "Color", config.Description or "")
	local holder = make("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -28, 0.5, 0),
		Size = UDim2.fromOffset(260, 42),
		Parent = row
	})
	list(holder, Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Right)
	local control = { Instance = row, Value = value }
	function control:Set(color, silent)
		self.Value = color
		if config.Callback and not silent then
			task.spawn(config.Callback, color)
		end
	end
	for _, color in ipairs(colors) do
		local swatch = make("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = color,
			Size = UDim2.fromOffset(38, 38),
			Text = "",
			Parent = holder
		})
		corner(swatch, 12)
		stroke(swatch, Theme.White, 1, 0.75)
		swatch.MouseButton1Click:Connect(function()
			pop(swatch)
			control:Set(color)
		end)
	end
	return self:Register(control, config.Flag)
end

Section.CreateColorPicker = Section.AddColorPicker

function Section:AddStatGrid(stats)
	local row = make("Frame", {
		BackgroundColor3 = Theme.Row,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 120),
		Parent = self.Body
	})
	padding(row, 22, 16, 22, 16)
	local grid = make("UIGridLayout", {
		CellPadding = UDim2.fromOffset(12, 12),
		CellSize = UDim2.new(0.5, -6, 0, 42),
		FillDirectionMaxCells = 2,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = row
	})
	for _, stat in ipairs(stats or {}) do
		local box = make("Frame", {
			BackgroundColor3 = Theme.Field,
			BackgroundTransparency = 0.12,
			BorderSizePixel = 0,
			Parent = row
		})
		corner(box, 12)
		local label = make("TextLabel", {
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -24, 1, 0),
			Text = tostring(stat.Name or stat[1] or "STAT") .. "  " .. tostring(stat.Value or stat[2] or ""),
			Parent = box
		})
		setTextStyle(label, 17, Theme.Text, Enum.FontWeight.SemiBold)
	end
	return self:Register({ Instance = row, Value = stats })
end

Section.CreateStatGrid = Section.AddStatGrid

function Section:AddThemeManager()
	self:AddColorPicker({
		Name = "Accent Color",
		Description = "Change active lime color.",
		Default = Theme.Accent,
		Callback = function(color)
			Theme.Accent = color
		end
	})
	self:AddKeybind({
		Name = "UI Key",
		Description = "Show or hide the interface.",
		Default = Enum.KeyCode.RightControl
	})
	return self
end

function Section:AddConfigManager()
	local current = "default"
	self:AddTextBox({
		Name = "Config Name",
		Default = current,
		Callback = function(text)
			current = trim(text)
		end
	})
	self:AddButton({
		Name = "Save Config",
		Callback = function()
			self.Window:SaveConfig(current)
		end
	})
	self:AddButton({
		Name = "Load Config",
		Callback = function()
			self.Window:LoadConfig(current)
		end
	})
	return self
end

function Module:CreateToggle(config)
	return self.Section:AddToggle(config)
end

function Module:CreateSlider(config)
	return self.Section:AddSlider(config)
end

function Module:CreateDropdown(config)
	return self.Section:AddDropdown(config)
end

function Module:CreateMultiDropdown(config)
	return self.Section:AddMultiDropdown(config)
end

function Module:CreateTextBox(config)
	return self.Section:AddTextBox(config)
end

function Module:CreateButton(config)
	return self.Section:AddButton(config)
end

Module.AddToggle = Module.CreateToggle
Module.AddSlider = Module.CreateSlider
Module.AddDropdown = Module.CreateDropdown
Module.AddMultiDropdown = Module.CreateMultiDropdown
Module.AddTextBox = Module.CreateTextBox
Module.AddButton = Module.CreateButton

function Library:MakeDemo()
	local window = self:CreateWindow({ Name = "VxiziGlassDemo" })
	local missions = window:CreateTab({ Name = "Missions", Icon = "home" })
	local sell = window:CreateTab({ Name = "Sell", Icon = "utility" })
	local misc = window:CreateTab({ Name = "Misc", Icon = "settings" })

	local missionSection = missions:AddSection("Missions", 1)
	missionSection:AddDropdown({
		Name = "Mission Class",
		Description = "Mission class.",
		Options = { "Story", "Daily", "Raid", "Legend" },
		Default = "Select..."
	})
	missionSection:AddButton({ Name = "Refresh Classes" })
	missionSection:AddDropdown({
		Name = "Preferred Region",
		Description = "Matchmaking server region.\nCurrent:",
		Options = { "Asia", "Europe", "US East", "US West" },
		Default = "Select..."
	})
	missionSection:AddButton({ Name = "Set Preferred Region" })
	missionSection:AddButton({ Name = "Request Mission" })

	local promo = missions:AddSection("Promotion", 1)
	promo:AddButton({ Name = "Request Promotion Task" })
	promo:AddToggle({
		Name = "Auto Promote",
		Description = "Auto-request promotion."
	})

	local sellSection = missions:AddSection("Sell Items", 2)
	sellSection:AddDropdown({
		Name = "Category",
		Description = "Category to sell.",
		Options = { "Items", "Potions", "Materials" },
		Default = "Select..."
	})
	sellSection:AddDropdown({
		Name = "Items",
		Description = "Pick items, or empty for all.",
		Options = { "Item 1", "Item 2", "Item 3" },
		Default = "Select..."
	})
	sellSection:AddDropdown({
		Name = "Don't Sell Rarity",
		Description = "Rarities to keep.",
		Options = { "Common", "Rare", "Epic", "Legendary", "Mythic" },
		Default = "5 selected"
	})
	sellSection:AddButton({ Name = "Refresh" })
	sellSection:AddToggle({
		Name = "Protect Quest Items",
		Description = "Keep quest items.",
		Default = true
	})
	sellSection:AddSlider({
		Name = "Sell Delay",
		Description = "Seconds between each sell (anti-spam).",
		Min = 0,
		Max = 2,
		Default = 0.1,
		Decimals = 1,
		Suffix = "s"
	})
	sellSection:AddToggle({
		Name = "Auto Sell",
		Description = "Sell now.",
		Default = true
	})

	local settings = window:CreateSettingsTab()
	local ui = settings:AddSection("UI Setting", 1)
	ui:AddThemeManager()
	local cfg = settings:AddSection("Configuration", 2)
	cfg:AddConfigManager()

	return window
end

return Library
