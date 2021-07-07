local SCRIPT_ENABLED = true

local LOCAL_PLAYER = game.Players.LocalPlayer
local MOUSE = LOCAL_PLAYER:GetMouse()
local RNG = Random.new()

local INPUT_SERVICE = game:GetService("UserInputService")
local RUN_SERVICE = game:GetService("RunService")
local TWEEN_SERVICE = game:GetService("TweenService")

local APPLICATION_GUI_PARENT = game:GetService("RunService"):IsStudio() and LOCAL_PLAYER.PlayerGui or game.CoreGui
local ALL_CONNECTIONS = {}

-- Application Theme (determines how the application gui will look, what font is used for text and what colors are used for things)
local THEME = {}
THEME.Element_Height = 19 -- The height of the containers of switch, buttons, sliders, etc.
THEME.Element_Left_Padding = 180
THEME.Element_Title_Left_Padding = 10
THEME.Element_Title_Text_Size = 13

THEME.Folder_Handle_Height = 17
THEME.Folder_Title_Left_Padding = 20
THEME.Folder_Collapse_Left_Padding = 10
THEME.Folder_Collapse_Button_Dimensions = Vector2.new(15, 15)

THEME.Switch_Off_Color = Color3.fromRGB(30, 30, 30)
THEME.Switch_On_Color = Color3.fromRGB(30, 120, 190)
THEME.Switch_Knob_Color = Color3.fromRGB(220, 220, 220)
THEME.Switch_Dimensions = Vector2.new(30, 13)

THEME.Button_Background_Color = Color3.fromRGB(30, 30, 30)
THEME.Button_Engaged_Color = Color3.fromRGB(30, 120, 190)
THEME.Button_Dimensions = Vector2.new(100, 15)
THEME.Button_Border_Rounding = 3

THEME.Input_Background_Color = Color3.fromRGB(30, 30, 30)
THEME.Input_Height = 15
THEME.Input_Border_Rounding = 3
THEME.Input_Text_Size = 12 

THEME.Output_Background_Color = Color3.fromRGB(30, 30, 30)
THEME.Output_Background_Border_Rounding = 3
THEME.Output_Background_Side_Padding = 10
THEME.Output_Background_Vertical_Padding = 6
THEME.Output_Background_Extra_Height = 2 -- Extra bit at the bottom of the background, doesn't affect top side
THEME.Output_Label_Height = 16
THEME.Output_Label_Left_Text_Padding = 4
THEME.Output_Font = Enum.Font.Code
THEME.Output_Text_Size = 14

THEME.Keybind_Height = 15
THEME.Keybind_Background_Color = Color3.fromRGB(30, 30, 30)
THEME.Keybind_Engaged_Color = Color3.fromRGB(30, 120, 190)
THEME.Keybind_Border_Rounding = 3
THEME.Keybind_Text_Size = 12

THEME.Font_Regular = Enum.Font.Gotham
THEME.Font_SemiBold = Enum.Font.GothamSemibold
THEME.Font_Bold = Enum.Font.GothamBold

THEME.Text_Color = Color3.fromRGB(255, 255, 255)

THEME.Window_Handle_Color = Color3.fromRGB(60, 60, 60)
THEME.Window_Background_Color = Color3.fromRGB(45, 45, 45)
THEME.Folder_Title_Color = Color3.fromRGB(100, 120, 220)

-- Misc. Functions
local function Lerp(start, finish, alpha)
	return start * (1 - alpha) + (finish * alpha)
end

local function StringToNumber(str, returnValueIfNotValid)
	local ret = returnValueIfNotValid ~= nil and returnValueIfNotValid or 0
	return typeof(tonumber(str)) == "number" and tonumber(str) or ret
end

local function RoundNumber(number, decimalPlaces)
	local multiplier = 10 ^ decimalPlaces

	return math.floor(number * multiplier + 0.5) / multiplier
end

-- Core Gui Elements
local function CreateGui()
	local gui = Instance.new("ScreenGui", APPLICATION_GUI_PARENT)
	gui.Name = ""
	gui.ResetOnSpawn = false

	return gui
end

local function CreatePadding(parent, height)
	local padding = Instance.new("Frame", parent)
	padding.Name = ""
	padding.Size = UDim2.new(1, 0, 0, height)
	padding.BackgroundTransparency = 1

	return padding
end

local function CreateFrame(parent, size, position, anchorPoint, color, borderRounding)
	if size           == nil then size           = UDim2.new(0, 0, 0, 0) end
	if position       == nil then position       = UDim2.new(0, 0, 0, 0) end
	if anchorPoint    == nil then anchorPoint    = Vector2.new(0, 0)     end
	if color          == nil then color          = Color3.new(1, 1, 1)   end
	if borderRounding == nil then borderRounding = 0                     end

	local frame = Instance.new("ImageLabel", parent)
	frame.Name = ""
	frame.Image = "rbxassetid://3570695787"
	frame.ImageColor3 = color
	frame.BackgroundTransparency = 1
	frame.Active = true

	frame.ScaleType = Enum.ScaleType.Slice
	frame.SliceCenter = Rect.new(Vector2.new(100, 100), Vector2.new(100, 100))
	frame.SliceScale = 0.01 * borderRounding

	if frame.SliceScale == 0 then frame.SliceScale = 0.001 end -- Prevent weird thing from happening

	frame.Size = size
	frame.Position = position
	frame.AnchorPoint = anchorPoint

	return frame
end

local function CreateScrollingFrame(parent, size, position, anchorPoint, elementPadding, bottomPadding)
	if size           == nil then size           = UDim2.new(0, 0, 0, 0) end
	if position       == nil then position       = UDim2.new(0, 0, 0, 0) end
	if anchorPoint    == nil then anchorPoint    = Vector2.new(0, 0)     end
	if elementPadding == nil then elementPadding = 0                     end
	if bottomPadding  == nil then bottomPadding  = 0                     end

	local container = Instance.new("ScrollingFrame", parent)
	container.Name = ""
	container.BorderSizePixel = 0
	container.BackgroundTransparency = 1
	container.ScrollingEnabled = true
	container.Size = size
	container.Position = position
	container.AnchorPoint = anchorPoint
	container.BottomImage = container.MidImage
	container.TopImage = container.MidImage
	container.ScrollBarThickness = 4

	container.CanvasSize = UDim2.new(0, 0, 0, elementPadding + bottomPadding) -- Just incase the padding is massive

	local list = Instance.new("UIListLayout", container)
	list.Name = ""
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, elementPadding)

	local function CalculateSize()
		container.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + bottomPadding)
	end

	local c1 = container.ChildAdded:Connect(function(c)
		CalculateSize()

		pcall(function()
			local c2 = c:GetPropertyChangedSignal("Size"):Connect(function()
				CalculateSize()
			end)

			table.insert(ALL_CONNECTIONS, c2)
		end)
	end)

	local c3 = container.ChildRemoved:Connect(function(c)
		CalculateSize()
	end)

	table.insert(ALL_CONNECTIONS, c1)
	table.insert(ALL_CONNECTIONS, c3)

	return container
end

local function CreateSwitch(parent, title, onByDefault)
	local container = Instance.new("Frame", parent)
	container.Name = ""
	container.Size = UDim2.new(1, 0, 0, THEME.Element_Height)
	container.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel", container)
	titleLabel.Name = ""
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -THEME.Element_Title_Left_Padding, 1, 0)
	titleLabel.Position = UDim2.new(1, 0, 0, 0)
	titleLabel.AnchorPoint = Vector2.new(1, 0)
	titleLabel.Font = THEME.Font_SemiBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = THEME.Text_Color
	titleLabel.TextSize = THEME.Element_Title_Text_Size
	titleLabel.Text = title

	local switchBackground = CreateFrame(
		container,
		UDim2.new(0, THEME.Switch_Dimensions.X, 0, THEME.Switch_Dimensions.Y),
		UDim2.new(0, THEME.Element_Left_Padding, 0.5, 0),
		Vector2.new(0, 0.5),
		THEME.Switch_Off_Color,
		math.floor(THEME.Switch_Dimensions.Y / 2) + 1
	)

	local knobWidth = THEME.Switch_Dimensions.Y - 2

	local knob = Instance.new("ImageLabel", switchBackground)
	knob.Name = ""
	knob.Image = "rbxassetid://3570695787"
	knob.BackgroundTransparency = 1
	knob.ImageColor3 = THEME.Switch_Knob_Color
	knob.Size = UDim2.new(0, knobWidth, 0, knobWidth)
	knob.Position = UDim2.new(0, 1, 0.5, 0)
	knob.AnchorPoint = Vector2.new(0, 0.5)

	local switchClickBox = Instance.new("TextButton", switchBackground)
	switchClickBox.Name = ""
	switchClickBox.BackgroundTransparency = 1
	switchClickBox.Size = UDim2.new(1, 0, 1, 0)
	switchClickBox.Text = ""

	-- Functionality
	local isOn = onByDefault
	local valueChanged = false

	local function UpdateSwitchAppearance()
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

		if isOn then
			local goal_1 = {}
			goal_1.AnchorPoint = Vector2.new(1, 0.5)
			goal_1.Position = UDim2.new(1, -1, 0.5, 0)

			local goal_2 = {}
			goal_2.ImageColor3 = THEME.Switch_On_Color

			local tween_1 = game:GetService("TweenService"):Create(knob, tweenInfo, goal_1) tween_1:Play()
			local tween_1 = game:GetService("TweenService"):Create(switchBackground, tweenInfo, goal_2) tween_1:Play()
		else
			local goal_1 = {}
			goal_1.AnchorPoint = Vector2.new(0, 0.5)
			goal_1.Position = UDim2.new(0, 1, 0.5, 0)

			local goal_2 = {}
			goal_2.ImageColor3 = THEME.Switch_Off_Color

			local tween_1 = game:GetService("TweenService"):Create(knob, tweenInfo, goal_1) tween_1:Play()
			local tween_1 = game:GetService("TweenService"):Create(switchBackground, tweenInfo, goal_2) tween_1:Play()
		end
	end

	local c1 = switchClickBox.MouseButton1Click:Connect(function()
		isOn = not isOn
		valueChanged = true

		UpdateSwitchAppearance()
	end)

	table.insert(ALL_CONNECTIONS, c1)

	UpdateSwitchAppearance()

	-- Switch class
	local switch = {}

	function switch.On()
		return isOn
	end

	function switch.ValueChanged()
		local r = valueChanged
		valueChanged = false

		return r
	end

	return switch
end

local function CreateButton(parent, title, buttonText)
	local container = Instance.new("Frame", parent)
	container.Name = ""
	container.Size = UDim2.new(1, 0, 0, THEME.Element_Height)
	container.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel", container)
	titleLabel.Name = ""
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -THEME.Element_Title_Left_Padding, 1, 0)
	titleLabel.Position = UDim2.new(1, 0, 0, 0)
	titleLabel.AnchorPoint = Vector2.new(1, 0)
	titleLabel.Font = THEME.Font_SemiBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = THEME.Text_Color
	titleLabel.TextSize = THEME.Element_Title_Text_Size
	titleLabel.Text = title

	local buttonFrame = CreateFrame(
		container,
		UDim2.new(0, THEME.Button_Dimensions.X, 0, THEME.Button_Dimensions.Y),
		UDim2.new(0, THEME.Element_Left_Padding, 0.5, 0),
		Vector2.new(0, 0.5),
		THEME.Button_Background_Color,
		THEME.Button_Border_Rounding
	)

	local clickBox = Instance.new("TextButton", buttonFrame)
	clickBox.Name = ""
	clickBox.BackgroundTransparency = 1
	clickBox.Font = THEME.Font_SemiBold
	clickBox.TextSize = 12
	clickBox.Size = UDim2.new(1, 0, 1, 0)
	clickBox.TextColor3 = THEME.Text_Color
	clickBox.Text = buttonText

	-- Functionality
	local pressCount = 0

	local c1 = clickBox.MouseButton1Click:Connect(function()
		pressCount = pressCount + 1

		buttonFrame.ImageColor3 = THEME.Button_Background_Color
		wait()
		buttonFrame.ImageColor3 = THEME.Button_Engaged_Color
	end)

	local c2 = clickBox.MouseEnter:Connect(function()
		buttonFrame.ImageColor3 = THEME.Button_Engaged_Color
	end)

	local c3 = clickBox.MouseLeave:Connect(function()
		buttonFrame.ImageColor3 = THEME.Button_Background_Color
	end)

	table.insert(ALL_CONNECTIONS, c1)
	table.insert(ALL_CONNECTIONS, c2)
	table.insert(ALL_CONNECTIONS, c3)

	-- Button class
	local button = {}

	function button.GetPressCount()
		local r = pressCount
		pressCount = 0

		return r
	end

	return button
end

local function CreateInput(parent, title, default)
	if default == nil then default = "Enter here" end

	local container = Instance.new("Frame", parent)
	container.Name = ""
	container.Size = UDim2.new(1, 0, 0, THEME.Element_Height)
	container.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel", container)
	titleLabel.Name = ""
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -THEME.Element_Title_Left_Padding, 1, 0)
	titleLabel.Position = UDim2.new(1, 0, 0, 0)
	titleLabel.AnchorPoint = Vector2.new(1, 0)
	titleLabel.Font = THEME.Font_SemiBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = THEME.Text_Color
	titleLabel.TextSize = THEME.Element_Title_Text_Size
	titleLabel.Text = title

	local backgroundWidth = parent.AbsoluteSize.X - THEME.Element_Left_Padding - 8

	local background = CreateFrame(
		container,
		UDim2.new(0, backgroundWidth, 0, THEME.Input_Height),
		UDim2.new(0, THEME.Element_Left_Padding, 0.5, 0),
		Vector2.new(0, 0.5),
		THEME.Input_Background_Color,
		THEME.Input_Border_Rounding
	)

	local inputTextBox = Instance.new("TextBox", background)
	inputTextBox.Name = ""
	inputTextBox.BackgroundTransparency = 1
	inputTextBox.Size = UDim2.new(1, -4, 0, THEME.Input_Text_Size)
	inputTextBox.Position = UDim2.new(1, 0, 0.5, 0)
	inputTextBox.AnchorPoint = Vector2.new(1, 0.5)
	inputTextBox.Font = THEME.Font_SemiBold
	inputTextBox.TextSize = THEME.Input_Text_Size
	inputTextBox.TextColor3 = THEME.Text_Color
	inputTextBox.TextXAlignment = Enum.TextXAlignment.Left
	inputTextBox.TextScaled = true
	inputTextBox.Text = default

	-- Functionality
	local textChanged = false
	local previousText = inputTextBox.Text

	local c1 = inputTextBox.FocusLost:Connect(function()
		if previousText ~= inputTextBox.Text then
			textChanged = true
		end

		previousText = inputTextBox.Text
	end)

	table.insert(ALL_CONNECTIONS, c1)

	-- Input class
	local input = {}

	function input.GetInputText()
		return inputTextBox.Text
	end

	function input.GetInputTextAsNumber()
		local n = tonumber(inputTextBox.Text)

		return n == nil and 0 or n
	end

	function input.InputChanged()
		local r = textChanged
		textChanged = false

		return r
	end

	return input
end

local function CreateKeybind(parent, title, defaultKeyCode)
	local container = Instance.new("Frame", parent)
	container.Name = ""
	container.Size = UDim2.new(1, 0, 0, THEME.Element_Height)
	container.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel", container)
	titleLabel.Name = ""
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -THEME.Element_Title_Left_Padding, 1, 0)
	titleLabel.Position = UDim2.new(1, 0, 0, 0)
	titleLabel.AnchorPoint = Vector2.new(1, 0)
	titleLabel.Font = THEME.Font_SemiBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = THEME.Text_Color
	titleLabel.TextSize = THEME.Element_Title_Text_Size
	titleLabel.Text = title

	local background = CreateFrame(
		container,
		nil,
		UDim2.new(0, THEME.Element_Left_Padding, 0.5, 0),
		Vector2.new(0, 0.5),
		THEME.Keybind_Background_Color,
		THEME.Keybind_Border_Rounding
	)

	local textButton = Instance.new("TextButton", background)
	textButton.Name = ""
	textButton.Size = UDim2.new(1, 0, 1, 0)
	textButton.BackgroundTransparency = 1
	textButton.Font = THEME.Font_SemiBold
	textButton.TextColor3 = THEME.Text_Color
	textButton.TextSize = THEME.Keybind_Text_Size

	-- Functionality
	local keyCodeName = string.sub(tostring(defaultKeyCode), 14, string.len(tostring(defaultKeyCode)))
	local engaged = false

	local function Update()
		local textWidth = game:GetService("TextService"):GetTextSize(keyCodeName, THEME.Keybind_Text_Size, THEME.Font_SemiBold, Vector2.new(math.huge, math.huge)).X
		background.Size = UDim2.new(0, textWidth + 12, 0, THEME.Keybind_Height)
		textButton.Text = keyCodeName
	end

	local c1 = textButton.MouseButton1Click:Connect(function()
		engaged = true
		background.ImageColor3 = THEME.Keybind_Engaged_Color
	end)

	local c2 = INPUT_SERVICE.InputBegan:Connect(function(key)
		if engaged then
			engaged = false
			background.ImageColor3 = THEME.Keybind_Background_Color

			keyCodeName = string.sub(tostring(key.KeyCode), 14, string.len(tostring(key.KeyCode)))

			if keyCodeName ~= "Unknown" then
				Update()
			end
		end
	end)

	table.insert(ALL_CONNECTIONS, c1)
	table.insert(ALL_CONNECTIONS, c2)

	Update()

	-- Keybind class
	local keybind = {}

	function keybind.GetKeyCode()
		return Enum.KeyCode[keyCodeName]
	end

	return keybind
end

local function CreateOutput(parent, labelCount)
	if labelCount == nil then labelCount = 1 end

	local backgroundHeight = THEME.Output_Label_Height * labelCount

	local container = Instance.new("Frame", parent)
	container.Name = ""
	container.Size = UDim2.new(1, 0, 0, backgroundHeight + THEME.Output_Background_Vertical_Padding)
	container.BackgroundTransparency = 1

	local background = CreateFrame(
		container,
		UDim2.new(1, -THEME.Output_Background_Side_Padding, 0, backgroundHeight + THEME.Output_Background_Extra_Height),
		UDim2.new(0.5, 0, 0.5, THEME.Output_Background_Extra_Height / 2),
		Vector2.new(0.5, 0.5),
		THEME.Output_Background_Color,
		THEME.Output_Background_Border_Rounding
	)

	local labels = {}

	for i = 1, labelCount do
		local label = Instance.new("TextBox", background)
		label.Name = ""
		label.Size = UDim2.new(1, -THEME.Output_Label_Left_Text_Padding, 0, THEME.Output_Label_Height)
		label.Position = UDim2.new(1, 0, 0, THEME.Output_Label_Height * (i - 1))
		label.AnchorPoint = Vector2.new(1, 0)
		label.BackgroundTransparency = 1
		label.Font = THEME.Output_Font
		label.TextSize = THEME.Output_Text_Size
		label.TextColor3 = THEME.Text_Color
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Selectable = true
		label.TextEditable = false
		label.ClearTextOnFocus = false
		label.Text = ""

		labels[i] = label
	end

	-- Output class
	local output = {}

	function output.EditLabel(index, text)
		if labels[index] then
			labels[index].Text = text
		end
	end

	function output.GetLabel(index)
		return labels[index]
	end

	return output
end

-- Complex Gui Features
local function CreateWindow(parent, title, size)
	local borderRounding = 3
	local background = CreateFrame(parent, UDim2.new(0, size[1], 0, size[2]), nil, nil, THEME.Window_Background_Color, borderRounding)

	-- Handle backgroud
	local handleBackgroundRounding = CreateFrame(
		background,
		UDim2.new(1, 0, 0, borderRounding * 2),
		nil,
		nil,
		THEME.Window_Handle_Color,
		borderRounding
	)

	local handleBackground = CreateFrame(
		background,
		UDim2.new(1, 0, 0, 20 - borderRounding),
		UDim2.new(0, 0, 0, borderRounding),
		nil,
		THEME.Window_Handle_Color,
		0
	)

	handleBackgroundRounding.ZIndex = 2
	handleBackground.ZIndex = 2

	-- Title also acts as the handle with the minimize and maximize buttons
	local titleLabel = Instance.new("TextLabel", background)
	titleLabel.Name = ""
	titleLabel.Size = UDim2.new(1, 0, 0, 20)
	titleLabel.Position = UDim2.new(0, 8, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = THEME.Font_SemiBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = THEME.Text_Color
	titleLabel.TextSize = 14
	titleLabel.ZIndex = 2
	titleLabel.Text = title

	local dragHandle = Instance.new("TextButton", background)
	dragHandle.Name = ""
	dragHandle.Size = UDim2.new(1, 0, 0, 20)
	dragHandle.BackgroundTransparency = 1
	dragHandle.Text = ""

	-- Buttons
	local closeButton = Instance.new("ImageButton", background)
	closeButton.Name = ""
	closeButton.Image = "rbxassetid://4389749368"
	closeButton.Size = UDim2.new(0, 12, 0, 12)
	closeButton.BackgroundTransparency = 1
	closeButton.AutoButtonColor = false
	closeButton.Position = UDim2.new(1, -18, 0, 4)
	closeButton.ZIndex = 2

	local miniButton = Instance.new("ImageButton", background)
	miniButton.Name = ""
	miniButton.Image = "rbxassetid://4530358017"
	miniButton.Size = UDim2.new(0, 12, 0, 12)
	miniButton.BackgroundTransparency = 1
	miniButton.AutoButtonColor = false
	miniButton.Position = UDim2.new(1, -37, 0, 4)
	miniButton.ZIndex = 2

	-- Functionality
	local active = true
	local minimised = false

	-- Close window event
	local c1 = closeButton.MouseButton1Click:Connect(function()
		active = false
	end)

	-- Minimize
	local c2 = miniButton.MouseButton1Click:Connect(function()
		minimised = not minimised

		if minimised then
			local textWidth = game:GetService("TextService"):GetTextSize(title, 14, THEME.Font_SemiBold, Vector2.new(math.huge, math.huge)).X
			background.Size = UDim2.new(0, textWidth + 60, 0, 20)

			handleBackground.Visible = false
			background.ImageColor3 = THEME.Window_Handle_Color

			for _, v in pairs(background:GetChildren()) do
				if v:IsA("ScrollingFrame") then
					v.Visible = false
				end
			end
		else
			background.Size = UDim2.new(0, size[1], 0, size[2])

			handleBackground.Visible = true
			background.ImageColor3 = THEME.Window_Background_Color

			for _, v in pairs(background:GetChildren()) do
				if v:IsA("ScrollingFrame") then
					v.Visible = true
				end
			end
		end
	end)

	-- Dragging
	local startDragPos = Vector2.new(0, 0)
	local dragging = false

	local c3 = dragHandle.MouseButton1Down:Connect(function()
		startDragPos = Vector2.new(MOUSE.X, MOUSE.Y)
		dragging = true

		local dragStartOffset = Vector2.new(MOUSE.X, MOUSE.Y) - dragHandle.AbsolutePosition

		repeat
			background.Position = UDim2.new(0, MOUSE.X - dragStartOffset.X, 0, MOUSE.Y - dragStartOffset.Y)

			RUN_SERVICE.RenderStepped:Wait()
		until dragging == false
	end)

	local c4 = dragHandle.MouseButton1Up:Connect(function()
		dragging = false
	end)

	local c5 = MOUSE.Button1Up:Connect(function()
		dragging = false
	end)

	table.insert(ALL_CONNECTIONS, c1)
	table.insert(ALL_CONNECTIONS, c2)
	table.insert(ALL_CONNECTIONS, c3)
	table.insert(ALL_CONNECTIONS, c4)
	table.insert(ALL_CONNECTIONS, c5)

	-- Window class
	local class = {}

	-- Methods
	function class.IsActive()
		return active
	end

	function class.GetBackground()
		return background
	end

	return class
end

local function CreateFolder(scrollingFrame, folderName, elementPadding)
	if folderName     == nil then folderName     = "Folder" end
	if elementPadding == nil then elementPadding = 0        end

	local frame = Instance.new("Frame", scrollingFrame)
	frame.Name = ""
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, THEME.Folder_Handle_Height)

	local container = Instance.new("Frame", frame)
	container.Name = ""
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 0, 0)
	container.Position = UDim2.new(0, 0, 0, THEME.Folder_Handle_Height)

	local titleLabel = Instance.new("TextLabel", frame)
	titleLabel.Name = ""
	titleLabel.Size = UDim2.new(1, -THEME.Folder_Title_Left_Padding, 0, THEME.Folder_Handle_Height)
	titleLabel.Position = UDim2.new(1, 0, 0, 0)
	titleLabel.AnchorPoint = Vector2.new(1, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = THEME.Font_Bold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	titleLabel.TextColor3 = THEME.Folder_Title_Color
	titleLabel.TextSize = 12
	titleLabel.Text = folderName

	local collapse = Instance.new("ImageButton", frame)
	collapse.Name = ""
	collapse.Image = "http://www.roblox.com/asset/?id=54479709"
	collapse.BackgroundTransparency = 1
	collapse.AnchorPoint = Vector2.new(0.5, 0.5)
	collapse.Size = UDim2.new(0, THEME.Folder_Collapse_Button_Dimensions.X, 0, THEME.Folder_Collapse_Button_Dimensions.Y)
	collapse.Position = UDim2.new(0, THEME.Folder_Collapse_Left_Padding, 0, THEME.Folder_Handle_Height / 2 + 3)

	local list = Instance.new("UIListLayout", container)
	list.Name = ""
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, elementPadding)

	-- Functionality
	local childrenHeight = 0
	local isCollapsed = false

	local function CalculateNewHeight()
		RUN_SERVICE.RenderStepped:Wait()
		childrenHeight = list.AbsoluteContentSize.Y

		frame.Size = UDim2.new(1, 0, 0, childrenHeight + THEME.Folder_Handle_Height)
		container.Size = UDim2.new(1, 0, 0, childrenHeight)
	end

	local c1 = container.ChildAdded:Connect(function(c)
		if isCollapsed == false then
			CalculateNewHeight()
		end
	end)

	local c2 = container.ChildRemoved:Connect(function(c)
		if isCollapsed == false then
			CalculateNewHeight()
		end
	end)

	-- Collapse
	local function Update()
		collapse.Rotation = isCollapsed and -180 or -90

		if isCollapsed then
			frame.Size = UDim2.new(1, 0, 0, THEME.Folder_Handle_Height)
		else
			frame.Size = UDim2.new(1, 0, 0, container.Size.Y.Offset + THEME.Folder_Handle_Height)
		end

		for _, v in pairs(container:GetDescendants()) do
			pcall(function()
				v.Visible = not isCollapsed
			end)
		end
	end

	local c3 = collapse.MouseButton1Click:Connect(function()
		isCollapsed = not isCollapsed

		Update()
	end)

	local c4 = container.DescendantAdded:Connect(function(c)
		if isCollapsed then
			pcall(function()
				c.Visible = not isCollapsed
			end)
		end
	end)

	table.insert(ALL_CONNECTIONS, c1)
	table.insert(ALL_CONNECTIONS, c2)
	table.insert(ALL_CONNECTIONS, c3)
	table.insert(ALL_CONNECTIONS, c4)

	Update()


	return container
end




-- Application Creation
local applicationGui = CreateGui()

local window = CreateWindow(applicationGui, "Essentials", { 380, 290 })
local elementsContainer = CreateScrollingFrame(window.GetBackground(), UDim2.new(1, 0, 1, -20), UDim2.new(0, 0, 0, 20), nil, 0, 6)

-- ESP
local folder_ESP = CreateFolder(elementsContainer, "ESP")
local switch_ESP_Enabled = CreateSwitch(folder_ESP, "ESP Enabled", false)
local switch_Freecam_Enabled = CreateSwitch(folder_ESP, "Freecam Enabled", false)
CreatePadding(folder_ESP, 2)
local input_Isolate_Player = CreateInput(folder_ESP, "Isolate Player", "")

-- Teleport
local folder_Teleport = CreateFolder(elementsContainer, "Teleport")
local button_Teleport_To_Camera = CreateButton(folder_Teleport, "Teleport To Camera", "Teleport")
CreatePadding(folder_Teleport, 4)
local button_Teleport_To_Player = CreateButton(folder_Teleport, "Teleport To Player", "Teleport")
local input_Teleport_To_Player_Target = CreateInput(folder_Teleport, "Player Name", "")
CreatePadding(folder_Teleport, 4)
local button_Teleport_Forward = CreateButton(folder_Teleport, "Teleport Forward", "Teleport")
local input_Teleport_Forward_Studs = CreateInput(folder_Teleport, "Teleport Forward Studs", 5)

-- ESP Settings
local folder_ESP_Settings = CreateFolder(elementsContainer, "ESP Settings")
local switch_Show_Tags = CreateSwitch(folder_ESP_Settings, "Show Tags", true)
local switch_Bold_Tags = CreateSwitch(folder_ESP_Settings, "Bold Tags", false)
local switch_Use_Display_Name = CreateSwitch(folder_ESP_Settings, "Use Display Name", false)
local switch_Label_Item_In_Hand = CreateSwitch(folder_ESP_Settings, "Label Item In Hand", false)
local switch_Show_Distance = CreateSwitch(folder_ESP_Settings, "Show Distance", false)
local input_ESP_Transparency = CreateInput(folder_ESP_Settings, "ESP Transparency", 0.9)
local input_Tag_Transparency = CreateInput(folder_ESP_Settings, "Tag Transparency", 0)

-- Freecam Settings
local folder_Freecam_Settings = CreateFolder(elementsContainer, "Freecam Settings")
local input_Freecam_Velocity = CreateInput(folder_Freecam_Settings, "Freecam Velocity", 100)
local input_Freecam_Sensitivity = CreateInput(folder_Freecam_Settings, "Freecam Sensitivity", 0.5)
local keybind_Freecam_Up = CreateKeybind(folder_Freecam_Settings, "Freecam Up", Enum.KeyCode.E)
local keybind_Freecam_Down = CreateKeybind(folder_Freecam_Settings, "Freecam Down", Enum.KeyCode.Q)

-- Aimbot
local folder_Aimbot = CreateFolder(elementsContainer, "Aimbot")
local switch_Aimbot_Enabled = CreateSwitch(folder_Aimbot, "Aimbot Enabled", false)
local switch_Aimbot_Team_Check = CreateSwitch(folder_Aimbot, "Team Check", false)
local switch_Aimbot_Wall_Check = CreateSwitch(folder_Aimbot, "Wall Check", false)
local switch_Show_Crosshair = CreateSwitch(folder_Aimbot, "Show Crosshair", false)
local keybind_Aimbot_Engage = CreateKeybind(folder_Aimbot, "Engage Aimbot", Enum.KeyCode.V)

-- Character
local folder_Character = CreateFolder(elementsContainer, "Character")
local switch_Noclip_Enabled = CreateSwitch(folder_Character, "Noclip Enabled", false)
local button_Sit = CreateButton(folder_Character, "Sit", "Sit")
CreatePadding(folder_Character, 2)
local input_Slope_Angle = CreateInput(folder_Character, "Slope Angle", 89)
local button_Set_Slope_Angle = CreateButton(folder_Character, "Set Slope Angle", "Set")
local switch_Force_Slope_Angle = CreateSwitch(folder_Character, "Force Slope Angle", false)

-- Misc
local folder_Misc = CreateFolder(elementsContainer, "Misc")
local button_Fix_Camera = CreateButton(folder_Misc, "Fix Camera", "Fix")
local button_Load_World_At_Camera = CreateButton(folder_Misc, "Load World At Camera", "Load")

-- Information
local folder_Information = CreateFolder(elementsContainer, "Information")
local output_ESP = CreateOutput(folder_Information, 2)
local output_Camera = CreateOutput(folder_Information, 3)
local output_Character = CreateOutput(folder_Information, 7)
local output_Server = CreateOutput(folder_Information, 2)


local espBoxFolder = Instance.new("Folder", applicationGui)
espBoxFolder.Name = ""

local espTagFolder = Instance.new("Folder", applicationGui)
espTagFolder.Name = ""


-- Cursor (used to show where the mouse incase the mouse icon is invisible)
local cursor = Instance.new("Frame", applicationGui)
cursor.Name = ""
cursor.BorderSizePixel = 0
cursor.Size = UDim2.new(0, 2, 0, 2)
cursor.AnchorPoint = Vector2.new(0.5, 0.5)
cursor.BackgroundColor3 = Color3.new(1, 1, 1)

-- Crosshair
local guiVerticalInset = game:GetService("GuiService"):GetGuiInset().Y

local crosshairFrame = Instance.new("Frame", applicationGui)
crosshairFrame.Name = ""
crosshairFrame.Size = UDim2.new(0, 15, 0, 15)
crosshairFrame.BackgroundTransparency = 1
crosshairFrame.Position = UDim2.new(0.5, 0, 0.5, -guiVerticalInset / 2)
crosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairFrame.Visible = false

local crosshairVertical = Instance.new("Frame", crosshairFrame)
crosshairVertical.Name = ""
crosshairVertical.Size = UDim2.new(0, 1, 1, 0)
crosshairVertical.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshairVertical.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairVertical.BorderSizePixel = 0
crosshairVertical.BackgroundColor3 = Color3.new(1, 1, 1)
crosshairVertical.Selectable = false

local crosshairHorizontal = Instance.new("Frame", crosshairFrame)
crosshairHorizontal.Name = ""
crosshairHorizontal.Size = UDim2.new(1, 0, 0, 1)
crosshairHorizontal.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshairHorizontal.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairHorizontal.BorderSizePixel = 0
crosshairHorizontal.BackgroundColor3 = Color3.new(1, 1, 1)
crosshairHorizontal.Selectable = false

-- Functions
local function MatchPlayerWithString(str)
	for _, v in pairs(game.Players:GetPlayers()) do
		if string.find(string.lower(v.Name), string.lower(str)) then
			return v
		end
	end
end

-- Some variables
local prevCameraType = workspace.CurrentCamera.CameraType -- The camera type before freecam is enabled
local aimbotTarget = nil
local lastTickCheckLoadedPlayers = tick()

local freecamPosition = Vector3.new(0, 0, 0)
local freecamRotation = Vector2.new(0, 0)

-- Freecam scroll
local inputChangedConnection = game:GetService("UserInputService").InputChanged:Connect(function(input, gameProcessed)
	if SCRIPT_ENABLED then
		if input.UserInputType == Enum.UserInputType.MouseWheel and not gameProcessed then
			if switch_Freecam_Enabled.On() then
				local ray = workspace.CurrentCamera:ScreenPointToRay(MOUSE.X, MOUSE.Y)
				local direction = ray.Direction

				freecamPosition = freecamPosition + (direction * input.Position.Z * 20)
			end
		end
	end
end)

table.insert(ALL_CONNECTIONS, inputChangedConnection)

-- ESP
local lastMissingESPCheckTick = tick()
local espList = {}

local function CreateESPForPlayer(plr)
	if switch_ESP_Enabled.On() == false then return end
	if espTagFolder:FindFirstChild(plr.Name) then return end
	
	if espList[plr.Name] then return end
	espList[plr.Name] = true
	
	local thread = coroutine.create(function()
		do
			local steps = 0
			
			repeat
				steps = steps + 1
				wait()
			until plr.Character or steps > 200
			
			if plr.Character == nil or steps > 200 then
				espList[plr.Name] = false
				return
			end
		end
		
		local character = plr.Character
		
		-- Keep track of connections
		local eventConnections = {}

		-- Tag
		local head = character:FindFirstChild("Head")
		local isActuallyHead = true

		if head == nil then
			head = character.PrimaryPart
			isActuallyHead = false
			
			if head == nil then
				espList[plr.Name] = false
				return
			end
		end

		local tag = Instance.new("TextLabel", espTagFolder)
		tag.Name = plr.Name
		tag.Font = Enum.Font.GothamSemibold
		tag.BackgroundTransparency = 1
		tag.AnchorPoint = Vector2.new(0.5, 1)
		tag.TextSize = 11

		local item = Instance.new("TextLabel", tag)
		item.Name = ""
		item.Text = ""
		item.TextSize = 10
		item.TextColor3 = Color3.new(0.4, 1, 0.4)
		item.Position = UDim2.new(0.5, 0, 0, -11)
		item.Font = Enum.Font.GothamSemibold
		item.AnchorPoint = Vector2.new(0.5, 0)
		item.TextStrokeTransparency = 0.9
		item.BackgroundTransparency = 1

		if LOCAL_PLAYER:IsFriendsWith(plr.UserId) then -- Label as friend
			local friend = Instance.new("TextLabel", tag)
			friend.Name = ""
			friend.Text = "FRIEND"
			friend.TextSize = 8
			friend.TextColor3 = Color3.new(0.4, 1, 0.4)
			friend.Position = UDim2.new(0.5, 0, 0, -10)
			friend.Font = Enum.Font.GothamSemibold
			friend.AnchorPoint = Vector2.new(0.5, 0)
			friend.TextStrokeTransparency = 0.9
			friend.BackgroundTransparency = 1

			item.Position = UDim2.new(0.5, 0, 0, -18)
		end

		-- Boxes
		local boxes = {}

		local function AddBox(part)
			local box = Instance.new("BoxHandleAdornment", espBoxFolder)
			box.Name = ""
			box.Adornee = part
			box.Size = part.Size
			box.Color = BrickColor.new(1, 1, 1)
			box.Transparency = input_ESP_Transparency.GetInputTextAsNumber()
			box.ZIndex = 10
			box.AlwaysOnTop = true
			
			local function CheckTransparency()
				if part.Name ~= "HumanoidRootPart" then
					if part.Transparency > 0.99 then -- 0.99 is the threshold (it's basically invisible)
						box.Color = BrickColor.new(1, 0, 0)
					else
						box.Color = BrickColor.new(1, 1, 1)
					end
				end
			end

			local c1 = part.AncestryChanged:Connect(function()
				if not box:IsDescendantOf(workspace) then
					box:Destroy()
				end
			end)
			
			local c2 = part:GetPropertyChangedSignal("Transparency"):Connect(function()
				CheckTransparency()
			end)
			
			local c3 = part:GetPropertyChangedSignal("Size"):Connect(function()
				box.Size = part.Size
			end)
			
			CheckTransparency()

			table.insert(boxes, box)
			table.insert(eventConnections, c1)
			table.insert(eventConnections, c2)
			table.insert(eventConnections, c3)
			table.insert(ALL_CONNECTIONS, c1)
			table.insert(ALL_CONNECTIONS, c2)
			table.insert(ALL_CONNECTIONS, c3)
		end

		local addedConnection = character.ChildAdded:Connect(function(c)
			if c:IsA("BasePart") and c.Name ~= "HumanoidRootPart" then
				AddBox(c)
			elseif c:IsA("Tool") then -- If player equips tool, then display that
				item.Text = "Holding: " .. c.Name
			end
		end)

		local removedConnection = character.ChildRemoved:Connect(function(c)
			if c:IsA("Tool") then
				item.Text = "" -- Assume no tools are being held

				for _, v in pairs(character:GetChildren()) do -- Check if a tool is held then change it
					if v:IsA("Tool") then
						item.Text = "Holding: " .. v.Name
					end
				end
			end
		end)
		
		for _, v in pairs(character:GetChildren()) do
			if v:IsA("BasePart") then
				AddBox(v)
			elseif v:IsA("Tool") then
				item.Text = "Holding: " .. v.Name

				for _, c in pairs(v:GetChildren()) do
					if v:IsA("BasePart") then
						AddBox(c)
					end
				end
			end
		end

		table.insert(eventConnections, addedConnection)
		table.insert(eventConnections, removedConnection)
		table.insert(ALL_CONNECTIONS, addedConnection)
		table.insert(ALL_CONNECTIONS, removedConnection)
		
		-- Loop
		local stopLoop = false
		local currentCharacter = character

		local function Process()
			if SCRIPT_ENABLED == false then
				stopLoop = true
				return
			end
				
			-- If tag is missing then stop
			if tag.Parent ~= espTagFolder then
				stopLoop = true
			end

			-- Different character so stop
			if character ~= currentCharacter then
				stopLoop = true
			end
			
			if head == nil then
				stopLoop = true
			elseif not head:IsDescendantOf(workspace) then
				stopLoop = true
			end
			
			-- Check if we can continue
			local tagPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.4, 0))

			do
				-- Tag is not visible because camera is not facing player
				if not onScreen then
					tag.Visible = false
					return
				end
				
				-- Isolate specific player
				local keyword = input_Isolate_Player.GetInputText()
				
				if keyword ~= "" then
					if switch_Use_Display_Name.On() then
						if not string.find(string.lower(plr.DisplayName), string.lower(keyword)) then
							tag.Visible = false
							return
						end
					else
						if not string.find(string.lower(plr.Name), string.lower(keyword)) then
							tag.Visible = false
							return
						end
					end
				end
			end
			
			-- Find player humanoid and character
			local humanoid = nil

			if character then
				humanoid = character:FindFirstChild("Humanoid")
			end
			
			-- Switch to head if possible
			if isActuallyHead == false then
				local h = character:FindFirstChild("Head")
				
				if h then
					head = h
					isActuallyHead = true
				end
			end

			-- Tag
			local tagText = ""

			if switch_Use_Display_Name.On() then
				tagText = "[" .. plr.DisplayName .. "]"
			else
				tagText = "[" .. plr.Name .. "]"
			end

			if switch_Bold_Tags.On() then
				tag.TextStrokeTransparency = input_Tag_Transparency.GetInputTextAsNumber()

				local color = tag.TextColor3
				local v = (color.R + color.G + color.B) / 3

				if v > 0.5 then
					tag.TextStrokeColor3 = Color3.new(0, 0, 0)  
				else
					tag.TextStrokeColor3 = Color3.new(1, 1, 1) 
				end
			else
				tag.TextStrokeTransparency = 0.9
				tag.TextStrokeColor3 = Color3.new(0, 0, 0)
			end
			
			if humanoid then
				local health = math.floor(humanoid.Health + 0.5)
				local maxHealth = math.floor(humanoid.MaxHealth + 0.5)
				
				tagText = tagText .. "[" .. health .. "/" .. maxHealth .. "]"
			end
			
			if character then
				local root = character:FindFirstChild("HumanoidRootPart")
				
				if switch_Show_Distance.On() and root then
					local distance = (workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude
					
					tagText = tagText .. "[" .. math.floor(distance + 0.5) .. " studs]"
				end
			end
			
			
			item.Visible = switch_Label_Item_In_Hand.On()
			
			tag.Text = tagText
			tag.TextColor3 = Color3.new(plr.TeamColor.r, plr.TeamColor.g, plr.TeamColor.b)
			tag.TextTransparency = input_Tag_Transparency.GetInputTextAsNumber()

			tag.Position = UDim2.new(0, tagPosition.X, 0, tagPosition.Y - guiVerticalInset)
			tag.Visible = switch_Show_Tags.On()
		end
		
		local function pcallProcess()
			local success, err = pcall(Process)
			
			if not success then
				stopLoop = true
			end
		end

		local uniqueId = game:GetService("HttpService"):GenerateGUID(false)
		RUN_SERVICE:BindToRenderStep(uniqueId, Enum.RenderPriority.Last.Value, pcallProcess)
		repeat RUN_SERVICE.RenderStepped:Wait() until stopLoop
		RUN_SERVICE:UnbindFromRenderStep(uniqueId)
		
		tag:Destroy()
		espList[plr.Name] = false
		
		-- Destroy connections
		for _, connection in pairs(eventConnections) do
			connection:Disconnect()
		end
		
		-- Destroy boxes
		for _, v in pairs(boxes) do
			if v ~= nil then
				v:Destroy()
			end
		end
	end)

	coroutine.resume(thread)
end

-- Add ESP for all players that exist
for _, v in pairs(game.Players:GetPlayers()) do
	if v ~= LOCAL_PLAYER then
		CreateESPForPlayer(v)

		local c = v.CharacterAdded:Connect(function()
			CreateESPForPlayer(v)
		end)

		table.insert(ALL_CONNECTIONS, c)
	end
end

-- Add ESP for all players that will join the game
local plrAdded = game.Players.PlayerAdded:Connect(function(plr)
	local c = plr.CharacterAdded:Connect(function()
		CreateESPForPlayer(plr)
	end)

	table.insert(ALL_CONNECTIONS, c)
end)

table.insert(ALL_CONNECTIONS, plrAdded)

-- Process is called every frame
local function Process(deltaTime)
	local success, err = pcall(function()
		local camera = workspace.CurrentCamera

		-- Find character and humanoid
		local character = LOCAL_PLAYER.Character
		local humanoid = nil

		if character then
			humanoid = character:FindFirstChild("Humanoid")
		end

		-- Cursor handling
		local winPos = window.GetBackground().AbsolutePosition
		local winSize = window.GetBackground().AbsoluteSize

		cursor.Position = UDim2.new(0, MOUSE.X, 0, MOUSE.Y)

		if MOUSE.X > winPos.X and MOUSE.X < winPos.X + winSize.X and MOUSE.Y > winPos.Y and MOUSE.Y < winPos.Y + winSize.Y then
			cursor.Visible = true
		else
			cursor.Visible = false
		end

		-- ESP
		if switch_ESP_Enabled.ValueChanged() then
			if switch_ESP_Enabled.On() then
				for _, v in pairs(game.Players:GetPlayers()) do
					if v ~= LOCAL_PLAYER then
						CreateESPForPlayer(v)
					end
				end
			else
				for _, v in pairs(espBoxFolder:GetChildren()) do
					v:Destroy()
				end

				for _, v in pairs(espTagFolder:GetChildren()) do
					v:Destroy()
				end
			end
		end

		if input_ESP_Transparency.InputChanged() then
			for _, v in pairs(espBoxFolder:GetChildren()) do
				if v:IsA("BoxHandleAdornment") then
					v.Transparency = input_ESP_Transparency.GetInputTextAsNumber()
				end
			end
		end
		
		-- Detect players without ESP (probably because of StreamingEnabled)
		if tick() - lastMissingESPCheckTick > 0.5 and switch_ESP_Enabled.On() then
			lastMissingESPCheckTick = tick()
			
			local missingPlayers = {}
			
			for _, v in pairs(game.Players:GetPlayers()) do
				if not espTagFolder:FindFirstChild(v.Name) and v ~= LOCAL_PLAYER then
					table.insert(missingPlayers, v)
				end
			end
			
			for i, v in pairs(missingPlayers) do
				CreateESPForPlayer(v)
				
				local x = espList[v.Name] and "true" or "false"
			end
		end
		
		-- Value should match the number of players not loaded in
		if switch_ESP_Enabled.On() then
			output_ESP.EditLabel(2, "Missing Tags: " .. #game.Players:GetPlayers() - #espTagFolder:GetChildren() - 1)
		else
			output_ESP.EditLabel(2, "Missing Tags: N/A")
		end
		
		-- Freecam
		if switch_Freecam_Enabled.ValueChanged() then
			if switch_Freecam_Enabled.On() then
				-- Disable movement of character while in freecam
				prevCameraType = camera.CameraType
				game:GetService("ContextActionService"):BindActionAtPriority("WASDUpDownKeys", function() return Enum.ContextActionResult.Sink end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, keybind_Freecam_Down.GetKeyCode(), keybind_Freecam_Up.GetKeyCode(), Enum.KeyCode.Space, Enum.KeyCode.LeftShift)

				local x, y = workspace.CurrentCamera.CFrame:ToOrientation()
				freecamPosition = workspace.CurrentCamera.CFrame.Position
				freecamRotation = Vector2.new(-y, -x)
			else
				-- Enable movement of character
				camera.CameraType = prevCameraType
				game:GetService("ContextActionService"):BindActionAtPriority("WASDUpDownKeys", function() return Enum.ContextActionResult.Pass end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, keybind_Freecam_Down.GetKeyCode(), keybind_Freecam_Up.GetKeyCode(), Enum.KeyCode.Space, Enum.KeyCode.LeftShift)
			end
		end

		if switch_Freecam_Enabled.On() then
			local freecamVelocity = Vector3.new(0, 0, 0)

			local w = INPUT_SERVICE:IsKeyDown(Enum.KeyCode.W)
			local a = INPUT_SERVICE:IsKeyDown(Enum.KeyCode.A)
			local s = INPUT_SERVICE:IsKeyDown(Enum.KeyCode.S)
			local d = INPUT_SERVICE:IsKeyDown(Enum.KeyCode.D)
			local up = INPUT_SERVICE:IsKeyDown(keybind_Freecam_Up.GetKeyCode())
			local down = INPUT_SERVICE:IsKeyDown(keybind_Freecam_Down.GetKeyCode())

			if w and s or (not w and not s) then
				freecamVelocity = Vector3.new(freecamVelocity.X, freecamVelocity.Y, 0)
			elseif w then
				freecamVelocity = Vector3.new(freecamVelocity.X, freecamVelocity.Y, -1)
			elseif s then
				freecamVelocity = Vector3.new(freecamVelocity.X, freecamVelocity.Y, 1)
			end

			if a and d or (not a and not d) then
				freecamVelocity = Vector3.new(0, freecamVelocity.Y, freecamVelocity.Z)
			elseif a then
				freecamVelocity = Vector3.new(-1, freecamVelocity.Y, freecamVelocity.Z)
			elseif d then
				freecamVelocity = Vector3.new(1, freecamVelocity.Y, freecamVelocity.Z)
			end

			if down and up or (not down and not up) then
				freecamVelocity = Vector3.new(freecamVelocity.X, 0, freecamVelocity.Z)
			elseif down then
				freecamVelocity = Vector3.new(freecamVelocity.X, -1, freecamVelocity.Z)
			elseif up then
				freecamVelocity = Vector3.new(freecamVelocity.X, 1, freecamVelocity.Z)
			end

			if INPUT_SERVICE:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				INPUT_SERVICE.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition

				local delta = INPUT_SERVICE:GetMouseDelta()
				local sens = INPUT_SERVICE.MouseDeltaSensitivity * input_Freecam_Sensitivity.GetInputTextAsNumber()

				local x = delta.X * (sens * sens)
				local y = delta.Y * (sens * sens)

				freecamRotation = freecamRotation + Vector2.new(math.rad(x), math.rad(y))
			else
				INPUT_SERVICE.MouseBehavior = Enum.MouseBehavior.Default
			end

			-- Update Camera
			local speedMultiplier = 1

			if INPUT_SERVICE:IsKeyDown(Enum.KeyCode.LeftShift) then
				speedMultiplier = speedMultiplier * 2
			end

			if INPUT_SERVICE:IsKeyDown(Enum.KeyCode.LeftControl) then
				speedMultiplier = speedMultiplier * 0.3
			end

			local move = freecamVelocity.Unit * input_Freecam_Velocity.GetInputTextAsNumber() * deltaTime * speedMultiplier
			if tostring(move.X) == "-nan(ind)" then move = Vector3.new(0, 0, 0) end

			local look = -(CFrame.new(0, 0, 0) *  CFrame.fromOrientation(-freecamRotation.Y, -freecamRotation.X, 0)).LookVector
			local up = (CFrame.new(0, 0, 0) *  CFrame.fromOrientation(-freecamRotation.Y, -freecamRotation.X, 0)).UpVector
			local right = (CFrame.new(0, 0, 0) *  CFrame.fromOrientation(-freecamRotation.Y, -freecamRotation.X, 0)).RightVector

			freecamPosition = freecamPosition + (move.Z * look) + (move.X * right) + (move.Y * up)

			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = CFrame.new(freecamPosition) * CFrame.fromOrientation(-freecamRotation.Y, -freecamRotation.X, 0)
		end

		-- Teleport
		if button_Teleport_To_Camera.GetPressCount() > 0 then
			character:SetPrimaryPartCFrame(CFrame.new(camera.CFrame.Position)) -- Removes rotation
		end
		
		if button_Teleport_To_Player.GetPressCount() > 0 then
			pcall(function()
				character:SetPrimaryPartCFrame(MatchPlayerWithString(input_Teleport_To_Player_Target.GetInputText()).Character:GetPrimaryPartCFrame())
			end)
		end
		
		if button_Teleport_Forward.GetPressCount() > 0 then
			pcall(function()
				local root = character:FindFirstChild("HumanoidRootPart")

				if root then
					character:SetPrimaryPartCFrame(character:GetPrimaryPartCFrame() * CFrame.new(0, 0, -input_Teleport_Forward_Studs.GetInputTextAsNumber()))
				end
			end)
		end
		
		-- Noclip
		if switch_Noclip_Enabled.On() then
			humanoid:ChangeState(11)
		end
		
		-- Sit
		if button_Sit.GetPressCount() > 0 then
			if humanoid then
				humanoid.Sit = true
			end
		end
		
		-- Fix Camera
		if button_Fix_Camera.GetPressCount() > 0 then
			camera.CameraType = Enum.CameraType.Custom
			
			if humanoid then
				camera.CameraSubject = humanoid
			end
		end
		
		-- Load World At Camera
		if button_Load_World_At_Camera.GetPressCount() > 0 then
			LOCAL_PLAYER:RequestStreamAroundAsync(camera.CFrame.Position)
		end
		
		-- Aimbot
		if INPUT_SERVICE:IsKeyDown(keybind_Aimbot_Engage.GetKeyCode()) and switch_Aimbot_Enabled.On() then
			if aimbotTarget == nil then
				-- Aimbot

				local target = nil
				local minDistance = math.huge
				local camDir = camera.CFrame.LookVector

				for _, v in pairs(game.Players:GetPlayers()) do
					if v.Character and v.Name ~= LOCAL_PLAYER.Name then
						local checked = true

						if not v.Character:FindFirstChild("Head") then
							checked = false
						end

						if v.Team == LOCAL_PLAYER.Team and switch_Aimbot_Team_Check.On() then
							checked = false
						end
						
						do -- Check if on screen
							local pos, onScreen = camera:WorldToScreenPoint(v.Character.Head.Position)
							
							if not onScreen then
								checked = false
							end
						end
						
						if switch_Aimbot_Wall_Check.On() then
							local me = character:GetPrimaryPartCFrame().Position
							local them = v.Character.Head.Position
							
							local rayDirection = (them - me).Unit * (me - them).Magnitude
							
							local raycastParams = RaycastParams.new()
							raycastParams.FilterDescendantsInstances = { v.Character, character }
							raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
							
							local raycastResult = workspace:Raycast(me, rayDirection, raycastParams)
							
							if raycastResult then
								local part = raycastResult.Instance
								
								if part then
									checked = false
								end
							end
						end

						if checked then
							local testTarget = v.Character.Head

							local targetDir = -(testTarget.Position - camera.CFrame.Position).Unit
							local d = camDir:Dot(targetDir)

							if d < minDistance then
								minDistance = d
								target = testTarget
							end
						end
					end
				end

				if target then
					aimbotTarget = target
					camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
				end
			else
				camera.CFrame = CFrame.new(camera.CFrame.Position, aimbotTarget.Position)
			end
		else
			aimbotTarget = nil
		end
		
		-- Crosshair
		if switch_Show_Crosshair.On() then
			crosshairFrame.Visible = true
		end
		
		-- Slope Angle
		if humanoid then
			if switch_Force_Slope_Angle.On() then
				humanoid.MaxSlopeAngle = input_Slope_Angle.GetInputTextAsNumber()
			end
			
			if button_Set_Slope_Angle.GetPressCount() > 0 then
				humanoid.MaxSlopeAngle = input_Slope_Angle.GetInputTextAsNumber()
			end
		end
		
		-- Information
		local camPosString = RoundNumber(camera.CFrame.Position.X, 2) .. ", " .. RoundNumber(camera.CFrame.Position.Y, 2) .. ", " .. RoundNumber(camera.CFrame.Position.Z, 2)
		local camRotString = nil
		
		do
			local x, y, z = camera.CFrame:ToOrientation()
			x = math.deg(x)
			y = math.deg(y)
			z = math.deg(z)
			
			camRotString = RoundNumber(x, 2) .. ", " .. RoundNumber(y, 2) .. ", " .. RoundNumber(z, 2)
		end
		
		local charPosString = "N/A"
		local charRotationString = "N/A"
		local charVelocityString = "N/A"

		if character then
			local root = character.PrimaryPart
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				local x, y, z = humanoidRootPart.Orientation.X, humanoidRootPart.Orientation.Y, humanoidRootPart.Orientation.Z
				charRotationString = RoundNumber(x, 2) .. ", " .. RoundNumber(y, 2) .. ", " .. RoundNumber(z, 2)
			end

			if root then
				if root:IsA("BasePart") then
					local x, y, z = root.Orientation.X, root.Orientation.Y, root.Orientation.Z

					charPosString = RoundNumber(root.Position.X, 2) .. ", " .. RoundNumber(root.Position.Y, 2) .. ", " .. RoundNumber(root.Position.Z, 2)
					charVelocityString = RoundNumber(root.Velocity.Magnitude, 2) .. " sps"
				end
			end
		end


		do -- Count how many players are not loaded in
			if tick() - lastTickCheckLoadedPlayers > 1 then -- Check only every second
				lastTickCheckLoadedPlayers = tick()

				local notLoadedCount = 0

				for _, v in pairs(game.Players:GetPlayers()) do
					local isLoaded = true

					if not v.Character then
						isLoaded = false
					elseif not v.Character:FindFirstChild("Head") then
						isLoaded = false
					end

					if isLoaded == false then
						notLoadedCount = notLoadedCount + 1
					end
				end

				output_ESP.EditLabel(1, "Players not loaded in: " .. notLoadedCount)
			end
		end

		output_Camera.EditLabel(1, "Camera Position: " .. camPosString)
		output_Camera.EditLabel(2, "Camera Position: " .. camRotString)
		output_Camera.EditLabel(3, "FOV: " .. camera.FieldOfView)
		
		output_Character.EditLabel(1, "Character Position: " .. charPosString)
		output_Character.EditLabel(2, "Character Rotation: " .. charRotationString)
		output_Character.EditLabel(3, "Character Velocity: " .. charVelocityString)
		output_Character.EditLabel(4, "Walk Speed: N/A")
		output_Character.EditLabel(5, "Jump Power: N/A")
		output_Character.EditLabel(6, "Health: N/A")

		output_Server.EditLabel(1, "Player Count: " .. #game.Players:GetPlayers() .. "/" .. game.Players.MaxPlayers)
		output_Server.EditLabel(2, "Job ID: " .. game.JobId)

		if humanoid then
			output_Character.EditLabel(4, "Walk Speed: " .. humanoid.WalkSpeed)
			output_Character.EditLabel(5, "Jump Power: " .. humanoid.JumpPower)
			output_Character.EditLabel(6, "Max Slope Angle: " .. humanoid.MaxSlopeAngle)
			output_Character.EditLabel(7, "Health: " .. RoundNumber(humanoid.Health, 3) .. "/" .. RoundNumber(humanoid.MaxHealth, 3))
		end
	end)
	
	if not success then
		--print("-------------------")
		--print(err)
	end
end

-- Bind process function to render step. Priority set to last so we can have control over everything (maybe)
local uniqueId = game:GetService("HttpService"):GenerateGUID(false)
RUN_SERVICE:BindToRenderStep(uniqueId, Enum.RenderPriority.Camera.Value, Process)

-- Wait until window is closed
repeat RUN_SERVICE.RenderStepped:Wait() until window.IsActive() == false

RUN_SERVICE:UnbindFromRenderStep(uniqueId) -- Unbind loop
applicationGui:Destroy() -- Destroy GUI
SCRIPT_ENABLED = false

for _, v in pairs(ALL_CONNECTIONS) do
	pcall(function()
		v:Disconnect()
	end)
end

if switch_Freecam_Enabled.On() then
	workspace.CurrentCamera.CameraType = prevCameraType
	game:GetService("ContextActionService"):BindActionAtPriority("WASDUpDownKeys", function() return Enum.ContextActionResult.Pass end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, keybind_Freecam_Down.GetKeyCode(), keybind_Freecam_Up.GetKeyCode(), Enum.KeyCode.Space, Enum.KeyCode.LeftShift)
end

-- script.Parent = nil -- Connections are destroyed if parent set to nil
