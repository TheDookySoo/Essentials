local SCRIPT_ENABLED = true

local INPUT_SERVICE = game:GetService("UserInputService")
local RUN_SERVICE = game:GetService("RunService")
local TWEEN_SERVICE = game:GetService("TweenService")
local PLAYER_SERVICE = game:GetService("Players")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local STARTER_GUI = game:GetService("StarterGui")

local LOCAL_PLAYER = PLAYER_SERVICE.LocalPlayer
local MOUSE = LOCAL_PLAYER:GetMouse()
local RNG = Random.new()

local APPLICATION_GUI_PARENT = RUN_SERVICE:IsStudio() and LOCAL_PLAYER.PlayerGui or game.CoreGui
local ALL_CONNECTIONS = {}

local DEBUG_ERROR_COUNT = 0
local LAST_DEBUG_ERROR_COUNT = 0

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

THEME.InputAndButton_Button_Width = 60

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
	local gui = Instance.new("ScreenGui")
	
	pcall(function()
		syn.protect_gui(gui)
	end)
	
	gui.Parent = APPLICATION_GUI_PARENT
	gui.ResetOnSpawn = false

	return gui
end

local function CreatePadding(parent, height)
	local padding = Instance.new("Frame", parent)
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
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, elementPadding)

	local function CalculateSize()
		container.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + bottomPadding)
	end

	local c1 = container.ChildAdded:Connect(function(c)
		CalculateSize()

		local success, err = pcall(function()
			local c2 = c:GetPropertyChangedSignal("Size"):Connect(function()
				CalculateSize()
			end)

			table.insert(ALL_CONNECTIONS, c2)
		end)
		
		if not success then
			-- Debug
			DEBUG_ERROR_COUNT = DEBUG_ERROR_COUNT + 1
			DEBUG_LAST_ERROR_MESSAGE = debug.traceback() .. " - Message: " .. err
		end
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
	container.Size = UDim2.new(1, 0, 0, THEME.Element_Height)
	container.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel", container)
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
	knob.Image = "rbxassetid://3570695787"
	knob.BackgroundTransparency = 1
	knob.ImageColor3 = THEME.Switch_Knob_Color
	knob.Size = UDim2.new(0, knobWidth, 0, knobWidth)
	knob.Position = UDim2.new(0, 1, 0.5, 0)
	knob.AnchorPoint = Vector2.new(0, 0.5)

	local switchClickBox = Instance.new("TextButton", switchBackground)
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

			local tween_1 = TWEEN_SERVICE:Create(knob, tweenInfo, goal_1) tween_1:Play()
			local tween_1 = TWEEN_SERVICE:Create(switchBackground, tweenInfo, goal_2) tween_1:Play()
		else
			local goal_1 = {}
			goal_1.AnchorPoint = Vector2.new(0, 0.5)
			goal_1.Position = UDim2.new(0, 1, 0.5, 0)

			local goal_2 = {}
			goal_2.ImageColor3 = THEME.Switch_Off_Color

			local tween_1 = TWEEN_SERVICE:Create(knob, tweenInfo, goal_1) tween_1:Play()
			local tween_1 = TWEEN_SERVICE:Create(switchBackground, tweenInfo, goal_2) tween_1:Play()
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
	container.Size = UDim2.new(1, 0, 0, THEME.Element_Height)
	container.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel", container)
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
		task.wait(1/30)
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

local function CreateDualButtons(parent, title, leftButtonText, rightButtonText)
	local container = Instance.new("Frame", parent)
	container.Size = UDim2.new(1, 0, 0, THEME.Element_Height)
	container.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel", container)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -THEME.Element_Title_Left_Padding, 1, 0)
	titleLabel.Position = UDim2.new(1, 0, 0, 0)
	titleLabel.AnchorPoint = Vector2.new(1, 0)
	titleLabel.Font = THEME.Font_SemiBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = THEME.Text_Color
	titleLabel.TextSize = THEME.Element_Title_Text_Size
	titleLabel.Text = title

	local leftButtonFrame = CreateFrame(
		container,
		UDim2.new(0, THEME.Button_Dimensions.X / 2 - 2, 0, THEME.Button_Dimensions.Y),
		UDim2.new(0, THEME.Element_Left_Padding, 0.5, 0),
		Vector2.new(0, 0.5),
		THEME.Button_Background_Color,
		THEME.Button_Border_Rounding
	)

	local rightButtonFrame = CreateFrame(
		container,
		UDim2.new(0, THEME.Button_Dimensions.X / 2 - 2, 0, THEME.Button_Dimensions.Y),
		UDim2.new(0, THEME.Element_Left_Padding + (THEME.Button_Dimensions.X / 2) + 2, 0.5, 0),
		Vector2.new(0, 0.5),
		THEME.Button_Background_Color,
		THEME.Button_Border_Rounding
	)

	local leftClickBox = Instance.new("TextButton", leftButtonFrame)
	leftClickBox.BackgroundTransparency = 1
	leftClickBox.Font = THEME.Font_SemiBold
	leftClickBox.TextSize = 12
	leftClickBox.Size = UDim2.new(1, 0, 1, 0)
	leftClickBox.TextColor3 = THEME.Text_Color
	leftClickBox.Text = leftButtonText

	local rightClickBox = leftClickBox:Clone()
	rightClickBox.Parent = rightButtonFrame
	rightClickBox.Text = rightButtonText

	-- Functionality
	local leftPressCount = 0
	local rightPressCount = 0

	-- Left
	local c1 = leftClickBox.MouseButton1Click:Connect(function()
		leftPressCount = leftPressCount + 1

		leftButtonFrame.ImageColor3 = THEME.Button_Background_Color
		task.wait(1/30)
		leftButtonFrame.ImageColor3 = THEME.Button_Engaged_Color
	end)

	local c2 = leftClickBox.MouseEnter:Connect(function()
		leftButtonFrame.ImageColor3 = THEME.Button_Engaged_Color
	end)

	local c3 = leftClickBox.MouseLeave:Connect(function()
		leftButtonFrame.ImageColor3 = THEME.Button_Background_Color
	end)

	-- Right
	local c4 = rightClickBox.MouseButton1Click:Connect(function()
		rightPressCount = rightPressCount + 1

		rightButtonFrame.ImageColor3 = THEME.Button_Background_Color
		task.wait(1/30)
		rightButtonFrame.ImageColor3 = THEME.Button_Engaged_Color
	end)

	local c5 = rightClickBox.MouseEnter:Connect(function()
		rightButtonFrame.ImageColor3 = THEME.Button_Engaged_Color
	end)

	local c6 = rightClickBox.MouseLeave:Connect(function()
		rightButtonFrame.ImageColor3 = THEME.Button_Background_Color
	end)

	table.insert(ALL_CONNECTIONS, c1)
	table.insert(ALL_CONNECTIONS, c2)
	table.insert(ALL_CONNECTIONS, c3)
	table.insert(ALL_CONNECTIONS, c4)
	table.insert(ALL_CONNECTIONS, c5)
	table.insert(ALL_CONNECTIONS, c6)

	-- Button class
	local button = {}

	function button.GetLeftButtonPressCount()
		local r = leftPressCount
		leftPressCount = 0

		return r
	end

	function button.GetRightButtonPressCount()
		local r = rightPressCount
		rightPressCount = 0

		return r
	end

	return button
end

local function CreateInput(parent, title, default)
	if default == nil then default = "Enter here" end

	local container = Instance.new("Frame", parent)
	container.Size = UDim2.new(1, 0, 0, THEME.Element_Height)
	container.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel", container)
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

	function input.GetInputTextAsNumber(default)
		local d = default == nil and 0 or default
		
		local n = tonumber(inputTextBox.Text)

		return n == nil and d or n
	end

	function input.InputChanged()
		local r = textChanged
		textChanged = false

		return r
	end

	return input
end

local function CreateInputAndButton(parent, title, defaultInput, buttonText)
	if defaultInput == nil then defaultInput = "Enter here" end

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
		UDim2.new(0, backgroundWidth - THEME.InputAndButton_Button_Width - 4, 0, THEME.Input_Height),
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
	inputTextBox.Text = defaultInput

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

	-- Button

	local buttonFrame = CreateFrame(
		container,
		UDim2.new(0, THEME.InputAndButton_Button_Width, 0, THEME.Button_Dimensions.Y),
		UDim2.new(0, THEME.Element_Left_Padding + (backgroundWidth - THEME.InputAndButton_Button_Width), 0.5, 0),
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

	local pressCount = 0

	local c2 = clickBox.MouseButton1Click:Connect(function()
		pressCount = pressCount + 1

		buttonFrame.ImageColor3 = THEME.Button_Background_Color
		task.wait()
		buttonFrame.ImageColor3 = THEME.Button_Engaged_Color
	end)

	local c3 = clickBox.MouseEnter:Connect(function()
		buttonFrame.ImageColor3 = THEME.Button_Engaged_Color
	end)

	local c4 = clickBox.MouseLeave:Connect(function()
		buttonFrame.ImageColor3 = THEME.Button_Background_Color
	end)

	table.insert(ALL_CONNECTIONS, c1)
	table.insert(ALL_CONNECTIONS, c2)
	table.insert(ALL_CONNECTIONS, c3)

	-- Class

	local object = {}

	function object.GetPressCount()
		local r = pressCount
		pressCount = 0

		return r
	end

	function object.GetInputText()
		return inputTextBox.Text
	end

	function object.GetInputTextAsNumber()
		local n = tonumber(inputTextBox.Text)

		return n == nil and 0 or n
	end

	function object.InputChanged()
		local r = textChanged
		textChanged = false

		return r
	end

	return object
end

local function CreateKeybind(parent, title, defaultKeyCode)
	local container = Instance.new("Frame", parent)
	container.Size = UDim2.new(1, 0, 0, THEME.Element_Height)
	container.BackgroundTransparency = 1

	local titleLabel = Instance.new("TextLabel", container)
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
	
	function output.GetSingleLabelAbsoluteSize()
		if labels[1] then
			return labels[1].AbsoluteSize
		else
			return 0
		end
	end
	
	function output.GetLabelCount()
		return labelCount
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
	dragHandle.Size = UDim2.new(1, 0, 0, 20)
	dragHandle.BackgroundTransparency = 1
	dragHandle.Text = ""

	-- Buttons
	local closeButton = Instance.new("ImageButton", background)
	closeButton.Image = "rbxassetid://4389749368"
	closeButton.Size = UDim2.new(0, 12, 0, 12)
	closeButton.BackgroundTransparency = 1
	closeButton.AutoButtonColor = false
	closeButton.Position = UDim2.new(1, -18, 0, 4)
	closeButton.ZIndex = 2

	local miniButton = Instance.new("ImageButton", background)
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

local function CreateFolder(scrollingFrame, folderName, elementPadding, collapsedDefault)
	if folderName       == nil then folderName     = "Folder" end
	if elementPadding   == nil then elementPadding = 0        end
	if collapsedDefault == nil then collapsedDefault = false  end

	local frame = Instance.new("Frame", scrollingFrame)
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.new(1, 0, 0, THEME.Folder_Handle_Height)

	local container = Instance.new("Frame", frame)
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, 0, 0, 0)
	container.Position = UDim2.new(0, 0, 0, THEME.Folder_Handle_Height)

	local titleLabel = Instance.new("TextLabel", frame)
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
	collapse.Image = "http://www.roblox.com/asset/?id=54479709"
	collapse.BackgroundTransparency = 1
	collapse.AnchorPoint = Vector2.new(0.5, 0.5)
	collapse.Size = UDim2.new(0, THEME.Folder_Collapse_Button_Dimensions.X, 0, THEME.Folder_Collapse_Button_Dimensions.Y)
	collapse.Position = UDim2.new(0, THEME.Folder_Collapse_Left_Padding, 0, THEME.Folder_Handle_Height / 2 + 3)

	local list = Instance.new("UIListLayout", container)
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
			local success, err = pcall(function()
				if v:IsA("GuiObject") then
					v.Visible = not isCollapsed
				end
			end)
			
			if not success then
				-- Debug
				DEBUG_ERROR_COUNT = DEBUG_ERROR_COUNT + 1
				DEBUG_LAST_ERROR_MESSAGE = debug.traceback() .. " - Message: " .. err
			end
		end
	end

	local c3 = collapse.MouseButton1Click:Connect(function()
		isCollapsed = not isCollapsed

		Update()
	end)

	local c4 = container.DescendantAdded:Connect(function(c)
		if isCollapsed then
			local success, err = pcall(function()
				if c:IsA("GuiObject") then
					c.Visible = not isCollapsed
				end
			end)
			
			if not success then
				-- Debug
				DEBUG_ERROR_COUNT = DEBUG_ERROR_COUNT + 1
				DEBUG_LAST_ERROR_MESSAGE = debug.traceback() .. " - Message: " .. err
			end
		end
	end)

	table.insert(ALL_CONNECTIONS, c1)
	table.insert(ALL_CONNECTIONS, c2)
	table.insert(ALL_CONNECTIONS, c3)
	table.insert(ALL_CONNECTIONS, c4)
	
	task.spawn(function()
		RUN_SERVICE.RenderStepped:Wait()
		isCollapsed = collapsedDefault
		Update()
	end)

	return container
end


-- Application Creation
local applicationGui = CreateGui()

local window = CreateWindow(applicationGui, "Essentials", { 380, 290 })
local elementsContainer = CreateScrollingFrame(window.GetBackground(), UDim2.new(1, 0, 1, -20), UDim2.new(0, 0, 0, 20), nil, 0, 6)

-- ESP
local folder_ESP = CreateFolder(elementsContainer, "ESP", nil, false)
local switch_ESP_Enabled = CreateSwitch(folder_ESP, "ESP Enabled", false)
local switch_Freecam_Enabled = CreateSwitch(folder_ESP, "Freecam Enabled", false)
local input_Isolate_Player = CreateInput(folder_ESP, "Isolate Player", "")

-- ESP Settings
local folder_ESP_Settings = CreateFolder(elementsContainer, "ESP Settings", nil, true)
local switch_Show_Tags = CreateSwitch(folder_ESP_Settings, "Show Tags", true)
local switch_Bold_Tags = CreateSwitch(folder_ESP_Settings, "Bold Tags", false)
local switch_Use_Display_Name = CreateSwitch(folder_ESP_Settings, "Use Display Name", false)
local switch_Label_Item_In_Hand = CreateSwitch(folder_ESP_Settings, "Label Item In Hand", false)
local switch_Show_Distance = CreateSwitch(folder_ESP_Settings, "Show Distance", false)
local input_ESP_Transparency = CreateInput(folder_ESP_Settings, "ESP Transparency", 0.9)
local input_Tag_Transparency = CreateInput(folder_ESP_Settings, "Tag Transparency", 0)

-- Freecam Settings
local folder_Freecam_Settings = CreateFolder(elementsContainer, "Freecam Settings", nil, true)
local input_Freecam_Velocity = CreateInput(folder_Freecam_Settings, "Freecam Velocity", 100)
local input_Freecam_Sensitivity = CreateInput(folder_Freecam_Settings, "Freecam Sensitivity", 0.5)
local keybind_Freecam_Up = CreateKeybind(folder_Freecam_Settings, "Freecam Up", Enum.KeyCode.E)
local keybind_Freecam_Down = CreateKeybind(folder_Freecam_Settings, "Freecam Down", Enum.KeyCode.Q)

-- Teleport
local folder_Teleport = CreateFolder(elementsContainer, "Teleport", nil, false)
local button_Teleport_To_Camera = CreateButton(folder_Teleport, "Teleport To Camera", "Teleport")
local inputAndButton_Teleport_To_Player = CreateInputAndButton(folder_Teleport, "Player Name", "", "Teleport")
local inputAndButton_Teleport_Forward = CreateInputAndButton(folder_Teleport, "TP Forward Studs", "5", "Teleport")
CreatePadding(folder_Teleport, 4)
local switch_Teleport_Forward_Double_Tap = CreateSwitch(folder_Teleport, "TP Forward Double Tap", false)
local keybind_Teleport_Forward_Double_Tap = CreateKeybind(folder_Teleport, "Keybind", Enum.KeyCode.T)
local input_Teleport_Forward_Double_Tap_Time_Range = CreateInput(folder_Teleport, "Valid Time Range [s]", "0.2")
CreatePadding(folder_Teleport, 4)
local switch_KeybindClick_Teleport = CreateSwitch(folder_Teleport, "TP Keybind + Click TP")
local switch_KeybindClick_Ignore_Transparent_Parents = CreateSwitch(folder_Teleport, "Ignore Transparent Parts", true)
local keybind_KeybindClick_Teleport = CreateKeybind(folder_Teleport, "Keybind", Enum.KeyCode.LeftControl)

-- Aimbot
local folder_Aimbot = CreateFolder(elementsContainer, "Aimbot", nil, true)
local switch_Aimbot_Enabled = CreateSwitch(folder_Aimbot, "Aimbot Enabled", false)
local switch_Aimbot_Team_Check = CreateSwitch(folder_Aimbot, "Team Check", false)
local switch_Aimbot_Wall_Check = CreateSwitch(folder_Aimbot, "Wall Check", false)
local switch_Show_Crosshair = CreateSwitch(folder_Aimbot, "Show Crosshair", false)
local keybind_Aimbot_Engage = CreateKeybind(folder_Aimbot, "Engage Aimbot", Enum.KeyCode.V)

-- Character
local folder_Character = CreateFolder(elementsContainer, "Character", nil, true)
local switch_Noclip_Enabled = CreateSwitch(folder_Character, "Noclip Enabled", false)
local button_Sit = CreateButton(folder_Character, "Sit", "Sit")
local inputAndButton_Slope_Angle = CreateInputAndButton(folder_Character, "Slope Angle", 89, "Set")
local switch_Force_Slope_Angle = CreateSwitch(folder_Character, "Force Slope Angle", false)

-- Camera
local folder_Camera = CreateFolder(elementsContainer, "Camera", nil, false)
local inputAndButton_CameraMinZoomDistance = CreateInputAndButton(folder_Camera, "Min Zoom Distance", 0.5, "Set")
local inputAndButton_CameraMaxZoomDistance = CreateInputAndButton(folder_Camera, "Max Zoom Distance", 1024, "Set")
CreatePadding(folder_Camera, 4)
local button_Fix_Camera = CreateButton(folder_Camera, "Fix Camera", "Fix")
local button_Load_World_At_Camera = CreateButton(folder_Camera, "Load World At Camera", "Load")

-- Core Gui
local folder_CoreGui = CreateFolder(elementsContainer, "Core Gui", nil, false)
local dualButtons_ResetCharacter = CreateDualButtons(folder_CoreGui, "Reset Character", "Enable", "Disable")
local dualButtons_All = CreateDualButtons(folder_CoreGui, "All", "Enable", "Disable")

-- Information
local folder_Information = CreateFolder(elementsContainer, "Information", nil, false)
local output_ESP = CreateOutput(folder_Information, 2)
local output_Camera = CreateOutput(folder_Information, 5)
local output_Character = CreateOutput(folder_Information, 8)
local output_Server = CreateOutput(folder_Information, 2)

-- Debug
local folder_Debug = CreateFolder(elementsContainer, "Debug", nil, true)
local output_Debug = CreateOutput(folder_Debug, 10)

local espBoxFolder = Instance.new("Folder", applicationGui)
local espTagFolder = Instance.new("Folder", applicationGui)

-- Cursor (used to show where the mouse incase the mouse icon is invisible)
local cursor = Instance.new("Frame", applicationGui)
cursor.BorderSizePixel = 0
cursor.Size = UDim2.new(0, 2, 0, 2)
cursor.AnchorPoint = Vector2.new(0.5, 0.5)
cursor.BackgroundColor3 = Color3.new(1, 1, 1)

-- Crosshair
local guiVerticalInset = game:GetService("GuiService"):GetGuiInset().Y

local crosshairFrame = Instance.new("Frame", applicationGui)
crosshairFrame.Size = UDim2.new(0, 15, 0, 15)
crosshairFrame.BackgroundTransparency = 1
crosshairFrame.Position = UDim2.new(0.5, 0, 0.5, -guiVerticalInset / 2)
crosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairFrame.Visible = false

local crosshairVertical = Instance.new("Frame", crosshairFrame)
crosshairVertical.Size = UDim2.new(0, 1, 1, 0)
crosshairVertical.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshairVertical.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairVertical.BorderSizePixel = 0
crosshairVertical.BackgroundColor3 = Color3.new(1, 1, 1)
crosshairVertical.Selectable = false
crosshairVertical.ZIndex = 10

local crosshairHorizontal = crosshairVertical:Clone()
crosshairHorizontal.Parent = crosshairFrame
crosshairHorizontal.Size = UDim2.new(1, 0, 0, 1)

-- Functions
local function MatchPlayerWithString(str)
	for _, v in pairs(PLAYER_SERVICE:GetPlayers()) do
		if string.find(string.lower(v.Name), string.lower(str)) then
			return v
		end
	end
	
	for _, v in pairs(PLAYER_SERVICE:GetPlayers()) do
		if string.find(string.lower(v.DisplayName), string.lower(str)) then
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

local lastPrimaryPartPosition = Vector3.new(0, 0, 0)
local characterRealVelocityHistoryLength = 50
local characterRealVelocityHistory = table.create(characterRealVelocityHistoryLength, 0)

local teleportForwardKeybindLastPressed = 0

-- Freecam scroll
local inputChangedConnection = INPUT_SERVICE.InputChanged:Connect(function(input, gameProcessed)
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
	
	if espList[plr.Name] then return end -- Player is already tracked
	espList[plr.Name] = true -- Record player
	
	task.spawn(function()
		do
			local steps = 0
			
			repeat
				steps = steps + 1
				task.wait()
			until plr.Character or steps > 400
			
			if plr.Character == nil or steps > 400 then
				espList[plr.Name] = false
				return
			end
		end
		
		local character = plr.Character
		
		-- Keep track of connections
		local eventConnections = {}

		-- Tag
		local head
		local isActuallyHead = true
		
		local function FindHead()
			head = character:FindFirstChild("Head")
			
			if head == nil then
				head = character.PrimaryPart
				isActuallyHead = false

				if head == nil then
					head = character:FindFirstChildOfClass("BasePart")

					if head == nil then
						espList[plr.Name] = false
						return
					end
				end
			end
		end
		
		FindHead()
		
		local tag = Instance.new("TextLabel", espTagFolder)
		tag.Name = plr.Name
		tag.Font = Enum.Font.GothamSemibold
		tag.BackgroundTransparency = 1
		tag.AnchorPoint = Vector2.new(0.5, 1)
		tag.TextSize = 11

		local item = Instance.new("TextLabel", tag)
		item.Text = ""
		item.TextSize = 10
		item.TextColor3 = Color3.new(0.4, 1, 0.4)
		item.Position = UDim2.new(0.5, 0, 0, -11)
		item.Font = Enum.Font.GothamSemibold
		item.AnchorPoint = Vector2.new(0.5, 0)
		item.TextStrokeTransparency = 0.9
		item.BackgroundTransparency = 1
		item.Visible = false

		if LOCAL_PLAYER:IsFriendsWith(plr.UserId) then -- Label as friend
			local friend = Instance.new("TextLabel", tag)
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
			task.wait()
			
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
		local currentCharacter = character
		local uniqueId = game:GetService("HttpService"):GenerateGUID(false)
		
		local function StopProcessLoop()
			RUN_SERVICE:UnbindFromRenderStep(uniqueId)

			if tag ~= nil then
				tag:Destroy()
			end

			espList[plr.Name] = false

			-- Destroy connections
			for _, connection in pairs(eventConnections) do
				if connection ~= nil then
					connection:Disconnect()
				end
			end

			-- Destroy boxes
			for _, v in pairs(boxes) do
				if v ~= nil then
					v:Destroy()
				end
			end
		end
		
		-- Tag update stuff
		
		local function UpdateTag(root, humanoid)
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
				if switch_Show_Distance.On() and root then
					local distance = (workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude

					tagText = tagText .. "[" .. math.floor(distance + 0.5) .. " studs]"
				end
			end


			item.Visible = switch_Label_Item_In_Hand.On()

			if tag.Text ~= tagText then
				tag.Text = tagText
			end

			tag.TextColor3 = Color3.new(plr.TeamColor.r, plr.TeamColor.g, plr.TeamColor.b)
			tag.TextTransparency = input_Tag_Transparency.GetInputTextAsNumber()
		end

		local function Process()
			local processStartTime = tick()
			
			if not SCRIPT_ENABLED then
				StopProcessLoop()
			end
				
			-- If tag is missing then stop
			if tag.Parent ~= espTagFolder then
				StopProcessLoop()
			end

			-- Different character so stop
			if character ~= currentCharacter then
				StopProcessLoop()
			end
			
			-- Missing head
			if head == nil then
				FindHead()
				
				if head == nil then
					StopProcessLoop()
					return
				end
			elseif not head:IsDescendantOf(workspace) then -- Probably died or left
				StopProcessLoop()
				return
			end
			
			-- Check if we can continue
			local tagPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.4, 0))

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
			
			-- Find player humanoid and character
			local humanoid = nil
			
			if character then
				humanoid = character:FindFirstChild("Humanoid")
				
				if not humanoid then
					humanoid = character:FindFirstChildOfClass("Humanoid")
				end
			end
			
			-- Switch to head if possible
			if isActuallyHead == false then
				local h = character:FindFirstChild("Head")
				
				if h then
					head = h
					isActuallyHead = true
				end
			end
			
			-- Find root
			local root = character:FindFirstChild("HumanoidRootPart")

			if not root then
				root = character.PrimaryPart

				if not root then
					root = character:FindFirstChildOfClass("BasePart")
				end
			end

			-- Tag
			if switch_Show_Tags.On() then
				local tagText = UpdateTag(root, humanoid)
				
				tag.Position = UDim2.new(0, tagPosition.X, 0, tagPosition.Y - guiVerticalInset)
				tag.Visible = true
			else
				tag.Visible = false
			end
		end
		
		-- Wrapper
		local function pcallProcess()
			local success, err = pcall(Process)
			
			if not success then
				-- Debug
				DEBUG_ERROR_COUNT = DEBUG_ERROR_COUNT + 1
				DEBUG_LAST_ERROR_MESSAGE = debug.traceback() .. " - Message: " .. err
			end
		end

		RUN_SERVICE:BindToRenderStep(uniqueId, Enum.RenderPriority.Last.Value, pcallProcess)
	end)
end

-- Add ESP for all players that exist
for _, v in pairs(PLAYER_SERVICE:GetPlayers()) do
	if v ~= LOCAL_PLAYER then
		CreateESPForPlayer(v)

		local c = v.CharacterAdded:Connect(function()
			CreateESPForPlayer(v)
		end)

		table.insert(ALL_CONNECTIONS, c)
	end
end

-- Add ESP for all players that will join the game
local plrAdded = PLAYER_SERVICE.PlayerAdded:Connect(function(plr)
	local c = plr.CharacterAdded:Connect(function()
		CreateESPForPlayer(plr)
	end)

	table.insert(ALL_CONNECTIONS, c)
end)

table.insert(ALL_CONNECTIONS, plrAdded)

-- Process is called every frame

local function Process_ESP(deltaTime)
	local success, err = pcall(function()
		local camera = workspace.CurrentCamera
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
				for _, v in pairs(PLAYER_SERVICE:GetPlayers()) do
					if v ~= LOCAL_PLAYER then
						CreateESPForPlayer(v)
					end
				end
			else
				espBoxFolder:ClearAllChildren()
				espTagFolder:ClearAllChildren()
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
			
			for _, v in pairs(PLAYER_SERVICE:GetPlayers()) do
				if not espTagFolder:FindFirstChild(v.Name) and v ~= LOCAL_PLAYER then
					table.insert(missingPlayers, v)
				end
			end
			
			for i, v in pairs(missingPlayers) do
				CreateESPForPlayer(v)
			end
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
	end)
	
	if not success then
		-- Debug
		DEBUG_ERROR_COUNT = DEBUG_ERROR_COUNT + 1
		DEBUG_LAST_ERROR_MESSAGE = debug.traceback() .. " - Message: " .. err
	end
end

local function Process_Teleport(deltaTime)
	local success, err = pcall(function()
		local camera = workspace.CurrentCamera
		local character = LOCAL_PLAYER.Character
		
		if character == nil then
			return
		end
		
		-- Teleport
		if button_Teleport_To_Camera.GetPressCount() > 0 then
			character:SetPrimaryPartCFrame(CFrame.new(camera.CFrame.Position)) -- Removes rotation
		end

		if inputAndButton_Teleport_To_Player.GetPressCount() > 0 then
			local success, err = pcall(function()
				local target = MatchPlayerWithString(inputAndButton_Teleport_To_Player.GetInputText()).Character:GetPrimaryPartCFrame()
				character:SetPrimaryPartCFrame(target)
			end)

			if not success then
				-- Debug
				DEBUG_ERROR_COUNT = DEBUG_ERROR_COUNT + 1
				DEBUG_LAST_ERROR_MESSAGE = debug.traceback() .. " - Message: " .. err
			end
		end

		for i = 1, inputAndButton_Teleport_Forward.GetPressCount() do
			local success, err = pcall(function()
				local root = character:FindFirstChild("HumanoidRootPart")

				if not root then
					root = character.PrimaryPart

					if not root then
						root = character:FindFirstChildOfClass("BasePart")
					end
				end

				if root then
					root.CFrame = root.CFrame * CFrame.new(0, 0, -inputAndButton_Teleport_Forward.GetInputTextAsNumber())
				end
			end)

			if not success then
				-- Debug
				DEBUG_ERROR_COUNT = DEBUG_ERROR_COUNT + 1
				DEBUG_LAST_ERROR_MESSAGE = debug.traceback() .. " - Message: " .. err
			end
		end
	end)
	
	if not success then
		-- Debug
		DEBUG_ERROR_COUNT = DEBUG_ERROR_COUNT + 1
		DEBUG_LAST_ERROR_MESSAGE = debug.traceback() .. " - Message: " .. err
	end
end

local function Process_Aimbot(deltaTime)
	local success, err = pcall(function()
		local camera = workspace.CurrentCamera
		local character = LOCAL_PLAYER.Character
		
		-- Crosshair
		if switch_Show_Crosshair.On() then
			crosshairFrame.Visible = true
		else
			crosshairFrame.Visible = false
		end
		
		-- Aimbot
		if character == nil then
			return
		end
		
		if INPUT_SERVICE:IsKeyDown(keybind_Aimbot_Engage.GetKeyCode()) and switch_Aimbot_Enabled.On() then
			if aimbotTarget == nil then
				-- Aimbot

				local target = nil
				local minDistance = math.huge
				local camDir = camera.CFrame.LookVector

				for _, v in pairs(PLAYER_SERVICE:GetPlayers()) do
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
	end)

	if not success then
		-- Debug
		DEBUG_ERROR_COUNT = DEBUG_ERROR_COUNT + 1
		DEBUG_LAST_ERROR_MESSAGE = debug.traceback() .. " - Message: " .. err
	end
end

local function Process_Character(deltaTime)
	local success, err = pcall(function()
		local character = LOCAL_PLAYER.Character
		local humanoid = nil

		if character then
			humanoid = character:FindFirstChild("Humanoid")
			
			if humanoid then
				-- Slope Angle
				if humanoid then
					if switch_Force_Slope_Angle.On() then
						humanoid.MaxSlopeAngle = inputAndButton_Slope_Angle.GetInputTextAsNumber()
					end

					if inputAndButton_Slope_Angle.GetPressCount() > 0 then
						humanoid.MaxSlopeAngle = inputAndButton_Slope_Angle.GetInputTextAsNumber()
					end
				end
				
				-- Noclip
				if switch_Noclip_Enabled.On() then
					humanoid:ChangeState(11)
				end

				-- Sit
				if button_Sit.GetPressCount() > 0 then
					humanoid.Sit = true
				end
			end
		end
	end)

	if not success then
		-- Debug
		DEBUG_ERROR_COUNT = DEBUG_ERROR_COUNT + 1
		DEBUG_LAST_ERROR_MESSAGE = debug.traceback() .. " - Message: " .. err
	end
end

local function Process_Camera(deltaTime)
	local success, err = pcall(function()
		local camera = workspace.CurrentCamera

		-- Find character and humanoid
		local character = LOCAL_PLAYER.Character
		local humanoid = nil

		if character then
			humanoid = character:FindFirstChild("Humanoid")
		end
		
		-- Camera
		if inputAndButton_CameraMinZoomDistance.GetPressCount() > 0 then
			LOCAL_PLAYER.CameraMinZoomDistance = inputAndButton_CameraMinZoomDistance.GetInputTextAsNumber(0.5)
		end

		if inputAndButton_CameraMaxZoomDistance.GetPressCount() > 0 then
			LOCAL_PLAYER.CameraMaxZoomDistance = inputAndButton_CameraMaxZoomDistance.GetInputTextAsNumber(128)
		end

		if button_Fix_Camera.GetPressCount() > 0 then
			camera.CameraType = Enum.CameraType.Custom

			if humanoid then
				camera.CameraSubject = humanoid
			end
		end

		if button_Load_World_At_Camera.GetPressCount() > 0 then
			LOCAL_PLAYER:RequestStreamAroundAsync(camera.CFrame.Position)
		end
	end)

	if not success then
		-- Debug
		DEBUG_ERROR_COUNT = DEBUG_ERROR_COUNT + 1
		DEBUG_LAST_ERROR_MESSAGE = debug.traceback() .. " - Message: " .. err
	end
end

local function Process_CoreGui(deltaTime)
	local success, err = pcall(function()
		-- Core Gui
		if dualButtons_ResetCharacter.GetLeftButtonPressCount() > 0 then STARTER_GUI:SetCore("ResetButtonCallback", true) end
		if dualButtons_ResetCharacter.GetRightButtonPressCount() > 0 then STARTER_GUI:SetCore("ResetButtonCallback", false) end

		if dualButtons_All.GetLeftButtonPressCount() > 0 then STARTER_GUI:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end
		if dualButtons_All.GetRightButtonPressCount() > 0 then STARTER_GUI:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end
	end)

	if not success then
		-- Debug
		DEBUG_ERROR_COUNT = DEBUG_ERROR_COUNT + 1
		DEBUG_LAST_ERROR_MESSAGE = debug.traceback() .. " - Message: " .. err
	end
end

local function Process_Information(deltaTime)
	local success, err = pcall(function()
		local camera = workspace.CurrentCamera
		
		-- Value should match the number of players not loaded in
		local missingTagCount = #PLAYER_SERVICE:GetPlayers() - #espTagFolder:GetChildren() - 1

		if switch_ESP_Enabled.On() then
			output_ESP.EditLabel(2, "Missing Tags: " .. missingTagCount)
		else
			output_ESP.EditLabel(2, "Missing Tags: N/A")
		end
		
		-- Find character and humanoid
		local character = LOCAL_PLAYER.Character
		local humanoid = nil

		if character then
			humanoid = character:FindFirstChild("Humanoid")
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
		local charVelocityPropertyString = "N/A"
		local charVelocityRealString = "N/A"

		if character then
			local primary = character:FindFirstChild("HumanoidRootPart")

			if not primary then
				primary = character.PrimaryPart

				if not primary then
					primary = character:FindFirstChildOfClass("BasePart")
				end
			end

			if primary then
				if primary:IsA("BasePart") then
					local rx, ry, rz = primary.Orientation.X, primary.Orientation.Y, primary.Orientation.Z

					charPosString = RoundNumber(primary.Position.X, 2) .. ", " .. RoundNumber(primary.Position.Y, 2) .. ", " .. RoundNumber(primary.Position.Z, 2)
					charRotationString = RoundNumber(rx, 2) .. ", " .. RoundNumber(ry, 2) .. ", " .. RoundNumber(rz, 2)
					charVelocityPropertyString = RoundNumber(primary.Velocity.Magnitude, 2) .. " sps"

					-- Real
					local realVel = (primary.Position - lastPrimaryPartPosition) / deltaTime
					local average = 0

					local length = characterRealVelocityHistoryLength

					-- Push new value
					table.insert(characterRealVelocityHistory, 1, realVel.Magnitude)
					table.remove(characterRealVelocityHistory, #characterRealVelocityHistory)

					-- Find average
					for i = 1, length do
						average = average + characterRealVelocityHistory[i]
					end

					average = average / length

					lastPrimaryPartPosition = primary.Position

					-- String
					charVelocityRealString = RoundNumber(average, 2) .. " sps (now " .. RoundNumber(realVel.Magnitude, 2) .. ")"
				end
			end
		end

		do -- Count how many players are not loaded in
			if tick() - lastTickCheckLoadedPlayers > 1 then -- Check only every second
				lastTickCheckLoadedPlayers = tick()

				local notLoadedCount = 0

				for _, v in pairs(PLAYER_SERVICE:GetPlayers()) do
					local isLoaded = true

					if not v.Character then
						isLoaded = false
					elseif not v.Character:FindFirstChild("HumanoidRootPart") then
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
		output_Camera.EditLabel(2, "Camera Rotation: " .. camRotString)
		output_Camera.EditLabel(3, "FOV: " .. camera.FieldOfView)
		output_Camera.EditLabel(4, "Min Zoom Distance: " .. LOCAL_PLAYER.CameraMinZoomDistance)
		output_Camera.EditLabel(5, "Max Zoom Distance: " .. LOCAL_PLAYER.CameraMaxZoomDistance)

		output_Character.EditLabel(1, "Character Position: " .. charPosString)
		output_Character.EditLabel(2, "Character Rotation: " .. charRotationString)
		output_Character.EditLabel(3, "Character Velocity Property: " .. charVelocityPropertyString)
		output_Character.EditLabel(4, "Character Velocity Real: " .. charVelocityRealString)

		output_Server.EditLabel(1, "Player Count: " .. #PLAYER_SERVICE:GetPlayers() .. "/" .. PLAYER_SERVICE.MaxPlayers)
		output_Server.EditLabel(2, "Job ID: " .. game.JobId)

		if humanoid then
			output_Character.EditLabel(5, "Walk Speed: " .. humanoid.WalkSpeed)

			if humanoid.UseJumpPower then
				output_Character.EditLabel(6, "Jump Power: " .. humanoid.JumpPower)
			else
				output_Character.EditLabel(6, "Jump Height: " .. humanoid.JumpHeight)
			end

			output_Character.EditLabel(7, "Max Slope Angle: " .. humanoid.MaxSlopeAngle)
			output_Character.EditLabel(8, "Health: " .. RoundNumber(humanoid.Health, 3) .. "/" .. RoundNumber(humanoid.MaxHealth, 3))
		else
			output_Character.EditLabel(5, "Walk Speed: N/A")
			output_Character.EditLabel(6, "Jump Power: N/A")
			output_Character.EditLabel(7, "Max Slope Angle: N/A")
			output_Character.EditLabel(8, "Health: N/A")
		end

		-- Debug
		output_Debug.EditLabel(1, "Error Count: " .. DEBUG_ERROR_COUNT)

		if DEBUG_ERROR_COUNT ~= LAST_DEBUG_ERROR_COUNT then
			local msg = DEBUG_LAST_ERROR_MESSAGE

			if tostring(msg) == "nil" then
				DEBUG_LAST_ERROR_MESSAGE = "nil error message"
			end

			local labelCount = output_Debug.GetLabelCount()
			local glyphAdvance = 7
			local maxGlyphs = math.floor(output_Debug.GetSingleLabelAbsoluteSize().X / glyphAdvance)
			local remainingText = "Last Error: " .. tostring(msg)
			remainingText = remainingText:gsub("\n", "")

			for i = 4, labelCount do
				output_Debug.EditLabel(i, "")
			end

			for i = 4, labelCount do
				if string.len(remainingText) > maxGlyphs then
					local sub = string.sub(remainingText, 1, maxGlyphs)
					remainingText = string.sub(remainingText, maxGlyphs + 1, string.len(remainingText))

					output_Debug.EditLabel(i, sub)
				else
					output_Debug.EditLabel(i, remainingText)
					break
				end
			end
		end

		LAST_DEBUG_ERROR_COUNT = DEBUG_ERROR_COUNT
	end)

	if not success then
		-- Debug
		DEBUG_ERROR_COUNT = DEBUG_ERROR_COUNT + 1
		DEBUG_LAST_ERROR_MESSAGE = debug.traceback() .. " - Message: " .. err
	end
end

-- Mouse click

local mouseButton1DownConnection = MOUSE.Button1Down:Connect(function()
	if INPUT_SERVICE:IsKeyDown(keybind_KeybindClick_Teleport.GetKeyCode()) then
		if switch_KeybindClick_Teleport.On() then
			pcall(function()
				local character = LOCAL_PLAYER.Character

				if character then
					local depth = 0
					
					local params = RaycastParams.new()
					params.FilterType = Enum.RaycastFilterType.Blacklist
					params.FilterDescendantsInstances = { character }
					
					local function PerformRay(origin, direction)
						if depth > 100 then
							return
						end
						
						local result = workspace:Raycast(origin, direction.Unit * 15000, params)

						if result then
							if result.Instance.Transparency == 1 then
								if switch_KeybindClick_Ignore_Transparent_Parents.On() then
									PerformRay(result.Position + (direction.Unit * 0.001), direction)
									depth = depth + 1
									
									return
								end
							end
							
							--character:SetPrimaryPartCFrame(CFrame.new(result.Position + result.Normal * 4.5))
							character:SetPrimaryPartCFrame(CFrame.new(result.Position + Vector3.new(0, 4.5, 0)))
						else
							return
						end
					end
					
					local ray = workspace.CurrentCamera:ScreenPointToRay(MOUSE.X, MOUSE.Y)
					PerformRay(ray.Origin, ray.Direction)
				end
			end)
		end
	end
end)

-- Input began

local inputConnection = INPUT_SERVICE.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed == false then
		if input.KeyCode == keybind_Teleport_Forward_Double_Tap.GetKeyCode() then
			if switch_Teleport_Forward_Double_Tap.On() == false then
				return
			end
			
			if tick() - teleportForwardKeybindLastPressed < input_Teleport_Forward_Double_Tap_Time_Range.GetInputTextAsNumber(0.5) then
				local success, err = pcall(function()
					local character = LOCAL_PLAYER.Character
					
					if character == nil then
						return
					end
					
					local root = character:FindFirstChild("HumanoidRootPart")

					if not root then
						root = character.PrimaryPart

						if not root then
							root = character:FindFirstChildOfClass("BasePart")
						end
					end

					if root then
						root.CFrame = root.CFrame * CFrame.new(0, 0, -inputAndButton_Teleport_Forward.GetInputTextAsNumber())
					end
				end)
				
				if not success then
					-- Debug
					DEBUG_ERROR_COUNT = DEBUG_ERROR_COUNT + 1
					DEBUG_LAST_ERROR_MESSAGE = debug.traceback() .. " - Message: " .. err
				end
			end
			
			teleportForwardKeybindLastPressed = tick()
		end
	end
end)

table.insert(ALL_CONNECTIONS, mouseButton1DownConnection)
table.insert(ALL_CONNECTIONS, inputConnection)

-- Bind process function to render step. Priority set to last so we can have control over everything (maybe)
local uniqueId_ESP = game:GetService("HttpService"):GenerateGUID(false)
local uniqueId_Teleport = game:GetService("HttpService"):GenerateGUID(false)
local uniqueId_Aimbot = game:GetService("HttpService"):GenerateGUID(false)
local uniqueId_Character = game:GetService("HttpService"):GenerateGUID(false)
local uniqueId_Camera = game:GetService("HttpService"):GenerateGUID(false)
local uniqueId_CoreGui = game:GetService("HttpService"):GenerateGUID(false)
local uniqueId_Information = game:GetService("HttpService"):GenerateGUID(false)

RUN_SERVICE:BindToRenderStep(uniqueId_Camera, Enum.RenderPriority.Camera.Value, Process_Camera)
RUN_SERVICE:BindToRenderStep(uniqueId_ESP, Enum.RenderPriority.Camera.Value + 1, Process_ESP)
RUN_SERVICE:BindToRenderStep(uniqueId_Aimbot, Enum.RenderPriority.Camera.Value + 2, Process_Aimbot)
RUN_SERVICE:BindToRenderStep(uniqueId_Teleport, Enum.RenderPriority.Camera.Value + 3, Process_Teleport)
RUN_SERVICE:BindToRenderStep(uniqueId_Character, Enum.RenderPriority.Camera.Value + 4, Process_Character)
RUN_SERVICE:BindToRenderStep(uniqueId_CoreGui, Enum.RenderPriority.Camera.Value + 5, Process_CoreGui)
RUN_SERVICE:BindToRenderStep(uniqueId_Information, Enum.RenderPriority.Camera.Value + 6, Process_Information)

-- Wait until window is closed
repeat RUN_SERVICE.RenderStepped:Wait() until window.IsActive() == false

-- Unbind loops
RUN_SERVICE:UnbindFromRenderStep(uniqueId_ESP)
RUN_SERVICE:UnbindFromRenderStep(uniqueId_Teleport)
RUN_SERVICE:UnbindFromRenderStep(uniqueId_Aimbot)
RUN_SERVICE:UnbindFromRenderStep(uniqueId_Character)
RUN_SERVICE:UnbindFromRenderStep(uniqueId_Camera)
RUN_SERVICE:UnbindFromRenderStep(uniqueId_CoreGui)
RUN_SERVICE:UnbindFromRenderStep(uniqueId_Information)

-- Cleanup
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
