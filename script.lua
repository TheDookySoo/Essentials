local SCRIPT_ENABLED = true

local LOCAL_PLAYER = game.Players.LocalPlayer
local MOUSE = LOCAL_PLAYER:GetMouse()

local INPUT_SERVICE = game:GetService("UserInputService")

local APPLICATION_GUI_PARENT = game:GetService("RunService"):IsStudio() and game.Players.LocalPlayer.PlayerGui or game.CoreGui
local APPLICATION_SIZE = UDim2.new(0, 380, 0, 274)
local APPLICATION_MINIMIZED = false

local ELEMENT_CONTAINER_EXTRA_PADDING = 0
local ELEMENT_CONTAINER_HEIGHT = 19
local ELEMENT_TITLE_PADDING = 10
local SLIDER_MAX_DECIMAL_PLACES = 2

local APPLICATION_THEME = {}
do
	APPLICATION_THEME.TextColor = Color3.fromRGB(255, 255, 255)
	APPLICATION_THEME.Padding_TextColor = Color3.fromRGB(100, 120, 190)

	APPLICATION_THEME.TextFont_Standard = Enum.Font.Gotham
	APPLICATION_THEME.TextFont_SemiBold = Enum.Font.GothamSemibold
	APPLICATION_THEME.TextFont_Bold = Enum.Font.GothamBold

	APPLICATION_THEME.Cursor_Color = Color3.new(1, 1, 1)

	APPLICATION_THEME.Color_Light = Color3.fromRGB(45, 45, 45)
	APPLICATION_THEME.Color_Medium = Color3.fromRGB(30, 30, 30)
	APPLICATION_THEME.Color_Dark = Color3.fromRGB(15, 15, 15)

	APPLICATION_THEME.Slider_Background_Color = Color3.fromRGB(60, 60, 60)
	APPLICATION_THEME.Slider_Bar_Color = Color3.fromRGB(190, 190, 190)

	APPLICATION_THEME.Keybind_Engaged_Color = Color3.fromRGB(110, 40, 40)
	APPLICATION_THEME.Keybind_NotEngaged_Color = Color3.fromRGB(30, 30, 30)

	APPLICATION_THEME.Button_Engaged_Color = Color3.fromRGB(110, 40, 40)
	APPLICATION_THEME.Button_NotEngaged_Color = Color3.fromRGB(30, 30, 30)

	APPLICATION_THEME.Input_Background_Color = Color3.fromRGB(30, 30, 30)

	APPLICATION_THEME.Switch_Background_Color = Color3.fromRGB(60, 60, 60)
	APPLICATION_THEME.Switch_Knob_Color = Color3.fromRGB(220, 220, 220)
	APPLICATION_THEME.Switch_Off_Color = Color3.fromRGB(30, 30, 30)
	APPLICATION_THEME.Switch_On_Color = Color3.fromRGB(30, 120, 190)
end

-- Functions
local function Lerp(start, finish, alpha)
	return start * (1 - alpha) + (finish * alpha)
end

-- Gui Functions
local function CreateGui(parent, name, resetOnSpawn, ignoreGuiInset)
	local gui = Instance.new("ScreenGui", parent)
	gui.Name = name

	gui.IgnoreGuiInset = ignoreGuiInset
	gui.ResetOnSpawn = resetOnSpawn

	return gui
end

local function AddPadding(parent, size, text)
	local paddingText = text ~= nil and text or ""

	local padding = Instance.new("TextButton", parent)
	padding.Name = "Padding"
	padding.BackgroundTransparency = 1
	padding.BorderSizePixel = 0
	padding.Size = UDim2.new(1, 0, 0, size)
	padding.Font = APPLICATION_THEME.TextFont_SemiBold
	padding.TextColor3 = APPLICATION_THEME.Padding_TextColor
	padding.TextSize = 12
	padding.TextXAlignment = Enum.TextXAlignment.Left
	padding.TextYAlignment = Enum.TextYAlignment.Bottom
	padding.Text = "  " .. paddingText

	return padding
end

local function CreateFrame(parent, name, borderRounding, size, position, anchorPoint, color)
	local frame_Position = position ~= nil and position or UDim2.new(0, 0, 0, 0)
	local frame_AnchorPoint = anchorPoint ~= nil and anchorPoint or Vector2.new(0, 0)

	local frame = Instance.new("ImageLabel", parent)
	frame.Name = name
	frame.Image = "rbxassetid://3570695787"
	frame.ImageColor3 = color == nil and APPLICATION_THEME.Color_Light or color
	frame.ScaleType = Enum.ScaleType.Slice
	frame.SliceCenter = Rect.new(Vector2.new(100, 100), Vector2.new(100, 100))
	frame.SliceScale = 0.01 * borderRounding
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Active = true

	frame.Size = size
	frame.Position = frame_Position
	frame.AnchorPoint = frame_AnchorPoint

	return frame
end

local function CreateDragHandle(parent, attachedGui, name, size, position, anchorPoint, text)
	local handle_Size = size ~= nil and size or UDim2.new(1, 0, 1, 0)
	local handle_Position = position ~= nil and position or UDim2.new(0, 0, 0, 0)
	local handle_AnchorPoint = anchorPoint ~= nil and anchorPoint or Vector2.new(0, 0)

	local handle = Instance.new("TextButton", parent)
	handle.Name = name
	handle.Size = handle_Size
	handle.Position = handle_Position
	handle.AnchorPoint = handle_AnchorPoint
	handle.BackgroundTransparency = 1
	handle.Text = "  " .. text
	handle.TextSize = 14
	handle.Font = APPLICATION_THEME.TextFont_SemiBold
	handle.TextXAlignment = Enum.TextXAlignment.Left
	handle.TextColor3 = APPLICATION_THEME.TextColor

	local border = Instance.new("Frame", handle)
	border.Name = "TitleBorder"
	border.Size = UDim2.new(1, 0, 0, 1)
	border.Position = UDim2.new(0.5, 0, 0, 20)
	border.AnchorPoint = Vector2.new(0.5, 0)
	border.BorderSizePixel = 0
	border.Active = false

	local titleBorder_Gradient = Instance.new("UIGradient", border)
	border.BackgroundColor3 = Color3.new(1, 1, 1)
	titleBorder_Gradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.05, 0.5),
		NumberSequenceKeypoint.new(0.95, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	}

	local closeButton = Instance.new("ImageButton", handle)
	closeButton.Name = "CloseButton"
	closeButton.Image = "rbxassetid://4389749368"
	closeButton.Size = UDim2.new(0, 12, 0, 12)
	closeButton.AnchorPoint = Vector2.new(0, 0.5)
	closeButton.BackgroundTransparency = 1
	closeButton.AutoButtonColor = false
	closeButton.Position = UDim2.new(1, -18, 0.5, 0)

	local miniButton = Instance.new("ImageButton", handle)
	miniButton.Name = "MinimizeButton"
	miniButton.Image = "rbxassetid://4530358017"
	miniButton.Size = UDim2.new(0, 12, 0, 12)
	miniButton.AnchorPoint = Vector2.new(0, 0.5)
	miniButton.BackgroundTransparency = 1
	miniButton.AutoButtonColor = false
	miniButton.Position = UDim2.new(1, -37, 0.5, 0)

	-- Enable Disable
	miniButton.MouseButton1Click:Connect(function()
		if APPLICATION_MINIMIZED then
			APPLICATION_MINIMIZED = false

			--parent.Visible = true
			--parent.Size = UDim2.new(0, APPLICATION_SIZE.X, 0, APPLICATION_SIZE.Y)
		else
			APPLICATION_MINIMIZED = true

			--parent.Visible = false
			--parent.Size = UDim2.new(0, APPLICATION_SIZE.X, 0, ELEMENT_CONTAINER_HEIGHT)

			-- localPlayer.CameraMinZoomDistance = before_CameraMinZoom
			-- localPlayer.CameraMaxZoomDistance = before_CameraMaxZoom
		end
	end)

	closeButton.MouseButton1Click:Connect(function()
		SCRIPT_ENABLED = false
		attachedGui:Destroy()
	end)



	local dragging = false

	handle.MouseButton1Down:Connect(function()
		dragging = true

		local dragStartOffset = Vector2.new(MOUSE.X, MOUSE.Y) - handle.AbsolutePosition

		repeat
			parent.Position = UDim2.new(0, MOUSE.X - dragStartOffset.X, 0, MOUSE.Y - dragStartOffset.Y)

			game:GetService("RunService").RenderStepped:Wait()
		until dragging == false
	end)

	handle.MouseButton1Up:Connect(function()
		dragging = false
	end)

	return handle
end

local function CreateScrollingFrame(parent, name, size, position, anchorPoint, padding)
	local container_Position = position ~= nil and position or UDim2.new(0, 0, 0, 0)
	local container_AnchorPoint = anchorPoint ~= nil and anchorPoint or Vector2.new(0, 0)

	local container = Instance.new("ScrollingFrame", parent)
	container.Name = name
	container.BorderSizePixel = 0
	container.BackgroundTransparency = 1
	container.ScrollingEnabled = true
	container.Size = size
	container.Position = container_Position
	container.AnchorPoint = container_AnchorPoint
	container.BottomImage = container.MidImage
	container.TopImage = container.MidImage
	container.ScrollBarThickness = 4

	local list = Instance.new("UIListLayout", container)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, padding)

	local scrolling = false
	local engaged = false

	container.CanvasSize = UDim2.new(0, 0, 0, ELEMENT_CONTAINER_EXTRA_PADDING)

	container.ChildAdded:Connect(function(c)
		pcall(function()
			wait()
			container.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + c.AbsoluteSize.Y + ELEMENT_CONTAINER_EXTRA_PADDING)
		end)
	end)

	container.ChildRemoved:Connect(function(c)
		pcall(function()
			wait()
			container.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y - c.AbsoluteSize.Y + ELEMENT_CONTAINER_EXTRA_PADDING)
		end)
	end)

	return container
end

-- Elements
local function CreateSlider(parent, name, titleText, min, max, defaultValue, inputSuffix)
	local suffix = inputSuffix ~= nil and inputSuffix or ""

	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, ELEMENT_CONTAINER_HEIGHT)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	-- Element
	local sliderBackground = CreateFrame(elementContainer, "SliderBackground", 3, UDim2.new(1, -180, 0, 7), UDim2.new(1, -10, 0.5, 0), Vector2.new(1, 0.5), APPLICATION_THEME.Slider_Background_Color)
	local sliderBar = CreateFrame(sliderBackground, "SliderBar", 3, UDim2.new(Lerp(0, 1, (defaultValue - min) / (max - min)), 0, 1, 0), UDim2.new(0, 0, 0, 0), Vector2.new(0, 0), APPLICATION_THEME.Slider_Bar_Color)

	local sliderClickBox = Instance.new("TextButton", sliderBackground)
	sliderClickBox.Name = "ClickBox"
	sliderClickBox.BackgroundTransparency = 1
	sliderClickBox.Text = ""
	sliderClickBox.Size = UDim2.new(1, 0, 1, 0)

	local valueTextLabel = Instance.new("TextLabel", sliderClickBox)
	valueTextLabel.Name = "ValueLabel"
	valueTextLabel.BackgroundTransparency = 1
	valueTextLabel.Size = UDim2.new(0, 1000, 0, 14)
	valueTextLabel.Font = APPLICATION_THEME.TextFont_SemiBold
	valueTextLabel.TextSize = 12
	valueTextLabel.TextColor3 = APPLICATION_THEME.TextColor
	valueTextLabel.TextTransparency = 1
	valueTextLabel.Text = ""

	-- Functionality
	local mouseDown = false
	local currentValue = defaultValue

	sliderClickBox.MouseButton1Down:Connect(function()
		mouseDown = true

		do
			local goal = {}
			goal.TextTransparency = 0

			local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

			local tween = game:GetService("TweenService"):Create(valueTextLabel, tweenInfo, goal)
			tween:Play()
		end

		repeat
			local dt = game:GetService("RunService").RenderStepped:Wait()

			local alpha = (MOUSE.X - sliderClickBox.AbsolutePosition.X) / sliderClickBox.AbsoluteSize.X
			alpha = math.clamp(alpha, 0, 1)

			sliderBar.Size = UDim2.new(Lerp(sliderBar.Size.X.Scale, alpha, 1 - (0.0000001 ^ dt)), 0, 1, 0)

			-- Label
			local realAlpha = sliderBar.AbsoluteSize.X / sliderBackground.AbsoluteSize.X
			local realValue = Lerp(min, max, sliderBar.AbsoluteSize.X / sliderBackground.AbsoluteSize.X)
			local realValueShortened = math.floor((realValue * (10 ^ SLIDER_MAX_DECIMAL_PLACES)) + 0.5) / (10 ^ SLIDER_MAX_DECIMAL_PLACES)

			currentValue = realValue
			valueTextLabel.Text = realValueShortened .. suffix

			valueTextLabel.AnchorPoint = Vector2.new(0.5, 0)
			valueTextLabel.Position = UDim2.new(realAlpha, 0, 1, 4)
			valueTextLabel.ZIndex = 100
		until mouseDown == false

		do
			local goal = {}
			goal.TextTransparency = 1

			local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

			local tween = game:GetService("TweenService"):Create(valueTextLabel, tweenInfo, goal)
			tween:Play()
		end
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			mouseDown = false
			wait(0.25)
			valueTextLabel.ZIndex = 1
		end
	end)

	-- Return
	local t = {}

	function t.GetValue()
		return currentValue
	end

	return t
end

local function CreateSwitch(parent, name, titleText, onByDefault)
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, ELEMENT_CONTAINER_HEIGHT)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	-- Element
	local backgroundColor = onByDefault and APPLICATION_THEME.Switch_On_Color or APPLICATION_THEME.Switch_Off_Color

	local switchBackground = CreateFrame(elementContainer, "SliderBackground", 7, UDim2.new(0, 30, 0, 13), UDim2.new(0, 170, 0.5, 0), Vector2.new(0, 0.5), backgroundColor)

	local knob = Instance.new("ImageLabel", switchBackground)
	knob.Name = "Knob"
	knob.Image = "rbxassetid://3570695787"
	knob.BackgroundTransparency = 1
	knob.ImageColor3 = APPLICATION_THEME.Switch_Knob_Color
	knob.Size = UDim2.new(0, 11, 0, 11)
	knob.Position = UDim2.new(0, 1, 0.5, 0)
	knob.AnchorPoint = Vector2.new(0, 0.5)

	local switchClickBox = Instance.new("TextButton", switchBackground)
	switchClickBox.Name = "ClickBox"
	switchClickBox.BackgroundTransparency = 1
	switchClickBox.Text = ""
	switchClickBox.Size = UDim2.new(1, 0, 1, 0)

	-- Functionality
	local switchUpdated = false
	local switchOn = not onByDefault

	local firstUpdate = false

	local function UpdateSwitch()
		switchOn = not switchOn

		switchUpdated = true

		if firstUpdate == false then
			firstUpdate = true
			switchUpdated = false
		end



		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

		if switchOn then
			local goal_1 = {}
			goal_1.AnchorPoint = Vector2.new(1, 0.5)
			goal_1.Position = UDim2.new(1, -1, 0.5, 0)

			local goal_2 = {}
			goal_2.ImageColor3 = APPLICATION_THEME.Switch_On_Color

			local tween_1 = game:GetService("TweenService"):Create(knob, tweenInfo, goal_1) tween_1:Play()
			local tween_1 = game:GetService("TweenService"):Create(switchBackground, tweenInfo, goal_2) tween_1:Play()
		else
			local goal_1 = {}
			goal_1.AnchorPoint = Vector2.new(0, 0.5)
			goal_1.Position = UDim2.new(0, 1, 0.5, 0)

			local goal_2 = {}
			goal_2.ImageColor3 = APPLICATION_THEME.Switch_Off_Color

			local tween_1 = game:GetService("TweenService"):Create(knob, tweenInfo, goal_1) tween_1:Play()
			local tween_1 = game:GetService("TweenService"):Create(switchBackground, tweenInfo, goal_2) tween_1:Play()
		end
	end

	switchClickBox.MouseButton1Click:Connect(function()
		UpdateSwitch()
	end)

	UpdateSwitch()

	-- Return
	local t = {}

	function t.ValueChanged()
		local r = switchUpdated
		switchUpdated = false

		return r
	end

	function t.GetValue()
		return switchOn
	end

	return t
end

local function CreateKeybind(parent, name, titleText, defaultKeyCode) -- Allows you to set keybinds
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, ELEMENT_CONTAINER_HEIGHT)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	local background = CreateFrame(elementContainer, "Background", 5, UDim2.new(0, 90, 0, 15), UDim2.new(0, 170, 0.5, 0), Vector2.new(0, 0.5))
	background.Name = "Background"
	background.ImageColor3 = APPLICATION_THEME.Keybind_NotEngaged_Color

	local clickBox = Instance.new("TextButton", background)
	clickBox.Name = "ClickBox"
	clickBox.BackgroundTransparency = 1
	clickBox.Font = APPLICATION_THEME.TextFont_SemiBold
	clickBox.TextSize = 12
	clickBox.Size = UDim2.new(1, 0, 1, 0)
	clickBox.TextColor3 = APPLICATION_THEME.TextColor
	clickBox.Text = string.sub(tostring(defaultKeyCode), 14, string.len(tostring(defaultKeyCode)))

	-- Functionality
	local engaged = false

	local function Update(keyName, isEngaged)
		local textWidth = game:GetService("TextService"):GetTextSize(keyName, 12, APPLICATION_THEME.TextFont_SemiBold, Vector2.new(math.huge, math.huge)).X
		background.Size = UDim2.new(0, textWidth + 14, 0, 15)

		if isEngaged then
			background.ImageColor3 = APPLICATION_THEME.Keybind_Engaged_Color
		else
			background.ImageColor3 = APPLICATION_THEME.Keybind_NotEngaged_Color
		end
	end

	Update(clickBox.Text, engaged)

	game:GetService("UserInputService").InputBegan:Connect(function(key)
		if engaged then
			local keyName = tostring(key.KeyCode)
			keyName = string.sub(keyName, 14, string.len(keyName))

			if keyName ~= "Unknown" then
				engaged = false
				clickBox.Text = keyName

				-- Tween
				Update(keyName, engaged)
			end
		end
	end)

	clickBox.MouseButton1Click:Connect(function()
		engaged = true

		-- Tween
		Update(clickBox.Text, engaged)
	end)

	-- Return
	local t = {}

	function t.GetKeyCode()
		return Enum.KeyCode[clickBox.Text]
	end

	return t
end

local function CreateButton(parent, name, titleText, buttonText) -- Allows you to set keybinds
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, ELEMENT_CONTAINER_HEIGHT)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	local button = CreateFrame(elementContainer, "ButtonBackground", 4, UDim2.new(0, 90, 0, 15), UDim2.new(0, 170, 0.5, 0), Vector2.new(0, 0.5))
	button.ImageColor3 = APPLICATION_THEME.Button_NotEngaged_Color

	local clickBox = Instance.new("TextButton", button)
	clickBox.Name = "ClickBox"
	clickBox.BackgroundTransparency = 1
	clickBox.Font = APPLICATION_THEME.TextFont_SemiBold
	clickBox.TextSize = 12
	clickBox.Size = UDim2.new(1, 0, 1, 0)
	clickBox.TextColor3 = APPLICATION_THEME.TextColor
	clickBox.Text = buttonText

	-- Functionality
	local pressed = false
	local mouseEnter = false

	clickBox.MouseEnter:Connect(function()
		button.ImageColor3 = APPLICATION_THEME.Button_Engaged_Color
		mouseEnter = true
	end)

	clickBox.MouseLeave:Connect(function()
		button.ImageColor3 = APPLICATION_THEME.Button_NotEngaged_Color
		mouseEnter = false
	end)

	clickBox.MouseButton1Click:Connect(function()
		pressed = true

		button.ImageColor3 = APPLICATION_THEME.Button_NotEngaged_Color
		wait()
		button.ImageColor3 = APPLICATION_THEME.Button_Engaged_Color
	end)

	-- Return
	local t = {}

	function t.ButtonPressed()
		local p = pressed
		pressed = false

		return p
	end

	function t.HoveringOver()
		return mouseEnter
	end

	return t
end

local function CreateInput(parent, name, titleText, default) -- Allows the user to provide input
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, ELEMENT_CONTAINER_HEIGHT)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	local background = CreateFrame(elementContainer, "ButtonBackground", 4, UDim2.new(1, -180, 0, 15), UDim2.new(0, 170, 0.5, 0), Vector2.new(0, 0.5))
	background.ImageColor3 = APPLICATION_THEME.Input_Background_Color

	local inputBox = Instance.new("TextBox", background)
	inputBox.Name = "InputBox"
	inputBox.BackgroundTransparency = 1
	inputBox.Font = APPLICATION_THEME.TextFont_SemiBold
	inputBox.TextSize = 12
	inputBox.Size = UDim2.new(1, -5, 1, 0)
	inputBox.TextXAlignment = Enum.TextXAlignment.Left
	inputBox.AnchorPoint = Vector2.new(1, 0)
	inputBox.Position = UDim2.new(1, 0, 0, 0)
	inputBox.TextColor3 = APPLICATION_THEME.TextColor
	inputBox.Text = default ~= nil and default or "Enter Here"

	-- Functionality
	local textChanged = false
	local previousText = inputBox.Text

	inputBox.FocusLost:Connect(function()
		if previousText ~= inputBox.Text then
			textChanged = true
		end

		previousText = inputBox.Text
	end)

	-- Return
	local t = {}

	function t.InputChanged()
		local v = textChanged
		textChanged = false

		return v
	end

	function t.GetText()
		return inputBox.Text
	end

	function t.GetNumber()
		return typeof(tonumber(inputBox.Text)) == "number" and tonumber(inputBox.Text) or 0
	end

	function t.SetText(t)
		inputBox.Text = t
	end

	return t
end

local function CreateColorPicker(parent, name, titleText)
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, 160)

	local elementTitle = Instance.new("TextLabel", elementContainer)
	elementTitle.Name = "Title"
	elementTitle.Size = UDim2.new(1, -ELEMENT_TITLE_PADDING, 1, 0)
	elementTitle.Position = UDim2.new(1, 0, 0, 0)
	elementTitle.AnchorPoint = Vector2.new(1, 0)
	elementTitle.BackgroundTransparency = 1
	elementTitle.TextColor3 = APPLICATION_THEME.TextColor
	elementTitle.TextXAlignment = Enum.TextXAlignment.Left
	elementTitle.Font = APPLICATION_THEME.TextFont_SemiBold
	elementTitle.TextSize = 13
	elementTitle.Text = titleText

	-- Gradient Map
	local backplate = Instance.new("Frame", elementContainer)
	backplate.Name = "Backplate"
	backplate.BorderSizePixel = 0
	backplate.BackgroundColor3 = Color3.new(0, 0, 0)
	backplate.Position = UDim2.new(0, 10, 0, 20)
	backplate.Size = UDim2.new(0, 100, 0, 100)

	local colorGradientBox = Instance.new("ImageLabel", backplate)
	colorGradientBox.Name = "ColorGradientBox"
	colorGradientBox.Image = "rbxassetid://1280017782"
	colorGradientBox.Size = UDim2.new(1, 0, 1, 0)
	colorGradientBox.Position = UDim2.new(0, 0, 0, 0)
	colorGradientBox.Rotation = 90
	colorGradientBox.BackgroundTransparency = 1

	local whiteGradientBox = Instance.new("ImageLabel", backplate)
	whiteGradientBox.Name = "WhiteGradientBox"
	whiteGradientBox.Image = "rbxassetid://1280017782"
	whiteGradientBox.ImageColor3 = Color3.new(1, 1, 1)
	whiteGradientBox.Size = UDim2.new(1, 0, 1, 0)
	whiteGradientBox.Position = UDim2.new(0, 0, 0, 0)
	whiteGradientBox.BackgroundTransparency = 1

	local blackGradientBox = Instance.new("ImageLabel", backplate)
	blackGradientBox.Name = "BlackGradientBox"
	blackGradientBox.Image = "rbxassetid://1280017782"
	blackGradientBox.ImageColor3 = Color3.new(0, 0, 0)
	blackGradientBox.Size = UDim2.new(1, 0, 1, 0)
	blackGradientBox.Position = UDim2.new(0, 0, 0, 0)
	blackGradientBox.Rotation = -90
	blackGradientBox.BackgroundTransparency = 1

	-- Color Map
	local backplate2 = Instance.new("Frame", elementContainer)
	backplate2.Name = "Backplate2"
	backplate2.BorderSizePixel = 0
	backplate2.BackgroundColor3 = Color3.new(0, 0, 0)
	backplate2.Position = UDim2.new(0, 115, 0, 20)
	backplate2.Size = UDim2.new(0, 100, 0, 100)

	local colorMap = Instance.new("ImageLabel", backplate2)
	colorMap.Name = "ColorMap"
	colorMap.Image = "rbxassetid://5425155739"
	colorMap.Size = UDim2.new(1, 0, 1, 0)
	colorMap.Position = UDim2.new(0, 0, 0, 0)
	colorMap.BackgroundTransparency = 1

	local desaturatedMap = Instance.new("ImageLabel", backplate2)
	desaturatedMap.Name = "DesaturatedMap"
	desaturatedMap.Image = "rbxassetid://5425157396"
	desaturatedMap.Size = UDim2.new(1, 0, 1, 0)
	desaturatedMap.Position = UDim2.new(0, 0, 0, 0)
	desaturatedMap.BackgroundTransparency = 1

	spawn(function()
		local t = 0
		local t2 = 0

		while true do
			local dt = game:GetService("RunService").RenderStepped:Wait()
			t = t + (dt / 2) if t > 1 then t = 0 end
			t2 = t2 + (dt * 2)

			colorGradientBox.ImageColor3 = Color3.fromHSV(t, 1, 1)

			desaturatedMap.ImageTransparency = math.sin(t2) / 2 + 0.5
		end
	end)
end

local function CreateOutput(parent, name, elementCount) -- Allows the script to show the user info
	local elementContainer = Instance.new("Frame", parent)
	elementContainer.Name = "ElementContainer"
	elementContainer.BackgroundTransparency = 1
	elementContainer.Size = UDim2.new(1, 0, 0, 18 * elementCount + 6)

	local background = CreateFrame(elementContainer, "ButtonBackground", 4, UDim2.new(1, -20, 0, 18 * elementCount), UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5))
	background.ImageColor3 = APPLICATION_THEME.Input_Background_Color

	local elements = {} -- Table which store the individual status text labels

	for i = 1, elementCount do
		local label = Instance.new("TextBox", background)
		label.Name = "InputBox"
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Code --APPLICATION_THEME.TextFont_SemiBold
		label.TextSize = 14
		label.Size = UDim2.new(1, -5, 0, 15)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.AnchorPoint = Vector2.new(1, 0)
		label.Position = UDim2.new(1, 0, 0, 18 * (i - 1) + 1)
		label.TextColor3 = APPLICATION_THEME.TextColor
		label.Text = ""

		table.insert(elements, label)
	end

	-- Return
	local t = {}

	function t.EditStatus(id, text)
		elements[id].Text = text
	end



	return t
end

-- Misc. Functions
local function MatchPlayerWithString(str)
	for _, v in pairs(game.Players:GetPlayers()) do
		if string.find(string.lower(v.Name), string.lower(str)) then
			return v
		end
	end
end

local function StringToNumber(str, returnValueIfNotValid)
	local ret = returnValueIfNotValid ~= nil and returnValueIfNotValid or 0
	return typeof(tonumber(str)) == "number" and tonumber(str) or ret
end

-- Math Functions
local function RoundNumber(number, decimals)
	local multiplier = 10 ^ decimals

	return math.floor(number * multiplier + 0.5) / multiplier
end





local DEFAULT_AIMBOT_KEY = Enum.KeyCode.LeftControl

-- Application Gui
local APP_GUI = CreateGui(APPLICATION_GUI_PARENT, "APPLICATION", false, false)

local mainFrame = CreateFrame(APP_GUI, "MainFrame", 3, APPLICATION_SIZE, UDim2.new(0, 0, 0, 0))
mainFrame.ClipsDescendants = true

local dragHandle = CreateDragHandle(mainFrame, APP_GUI, "DragHandle", UDim2.new(1, 0, 0, 20), nil, nil, "Essentials")

local elements_Container = CreateScrollingFrame(mainFrame, "ElementsContainer", UDim2.new(1, 0, 1, -22), UDim2.new(0, 0, 0, 22), nil, 0)

local cursor = Instance.new("Frame", APP_GUI)
cursor.BorderSizePixel = 0
cursor.Size = UDim2.new(0, 2, 0, 2)
cursor.AnchorPoint = Vector2.new(0.5, 0.5)
cursor.BackgroundColor3 = Color3.new(1, 1, 1)


-- ESP
AddPadding(elements_Container, 17, "ESP")
local switch_ESP_Enabled = CreateSwitch(elements_Container, "Switch_ESP_Enabled", "ESP Enabled", false)
local switch_Freecam_Enabled = CreateSwitch(elements_Container, "Switch_Freecam_Enabled", "Freecam Enabled", false)

AddPadding(elements_Container, 4)
local switch_UseDisplayName = CreateSwitch(elements_Container, "Switch_UseDisplayName", "Use Display Name", false)
local switch_LabelItemInHand = CreateSwitch(elements_Container, "Switch_LabelItemInHand", "Label Item In Hand", false)
local switch_ShowDistance = CreateSwitch(elements_Container, "Switch_ShowDistance_Enabled", "Show Distance", false)
local switch_BoldTags = CreateSwitch(elements_Container, "Switch_BoldTags", "Bold Tags", false)

-- Teleport
AddPadding(elements_Container, 17, "Teleport")
local button_TeleportToCamera = CreateButton(elements_Container, "Button_TeleportToCamera", "Teleport To Camera", "Teleport")
local button_TeleportThrough = CreateButton(elements_Container, "Button_TeleportThrough", "Teleport Through", "Teleport")

AddPadding(elements_Container, 4)
local button_TeleportToPlayer = CreateButton(elements_Container, "Button_TeleportToPlayer", "Teleport To", "Teleport")
local input_TeleportToPlayer = CreateInput(elements_Container, "Input_TeleportToPlayer", "Player Name")

-- Aimbot
AddPadding(elements_Container, 17, "Aimbot")
local switch_Aimbot_Enabled = CreateSwitch(elements_Container, "Switch_Aimbot_Enabled", "Aimbot Enabled", false)
local switch_Aimbot_TeamCheck_Enabled = CreateSwitch(elements_Container, "Switch_AimbotTeamCheck_Enabled", "Team Check Enabled", false)

-- Misc
AddPadding(elements_Container, 17, "Misc")

local switch_Noclip = CreateSwitch(elements_Container, "Switch_Noclip", "Noclip Enabled", false)
local button_FixCamera = CreateButton(elements_Container, "Button_FixCamera", "Fix Camera", "Fix")
local button_LoadWorldAtCamera = CreateButton(elements_Container, "Button_LoadWorldAtCamera", "Load World At Camera", "Load")

-- Keybinds
AddPadding(elements_Container, 17, "Keybinds")
local keybind_Aimbot = CreateKeybind(elements_Container, "Keybind_Aimbot", "Engage Aimbot", DEFAULT_AIMBOT_KEY)
local keybind_FreecamUp = CreateKeybind(elements_Container, "Keybind_FreecamUp", "Freecam Up", Enum.KeyCode.E)
local keybind_FreecamDown = CreateKeybind(elements_Container, "Keybind_FreecamDown", "Freecam Down", Enum.KeyCode.Q)

-- Settings
AddPadding(elements_Container, 17, "Settings")
local input_FreecamSpeed = CreateInput(elements_Container, "Input_FreecamSpeed", "Freecam Speed", 100)
local input_FreecamSensitivity = CreateInput(elements_Container, "Input_FreecamSensitivity", "Freecam Sensitivity", 0.5)
local input_TeleportThroughLength = CreateInput(elements_Container, "Input_TeleportThroughLength", "Teleport Through Length", 5)
local input_ESP_Transparency = CreateInput(elements_Container, "Input_ESP_Transparency", "ESP Transparency", 0.8)

-- Information
AddPadding(elements_Container, 17, "Information")
local output_Camera = CreateOutput(elements_Container, "Output", 1)
local output_Character = CreateOutput(elements_Container, "Output", 3)
local output_Misc = CreateOutput(elements_Container, "Output", 3)

local uniqueId = tostring(game:GetService("HttpService"):GenerateGUID(false))

local function AddESPToPlayer(plr)
	local function AddBox(c)
		local box = Instance.new("BoxHandleAdornment", APP_GUI)
		box.Name = "Box"
		box.Adornee = c
		box.Size = c.Size
		box.Color = BrickColor.new(1, 1, 1)
		box.Transparency = input_ESP_Transparency.GetNumber()
		box.ZIndex = 10
		box.AlwaysOnTop = true
		
		c.AncestryChanged:Connect(function()
			if not box:IsAncestorOf(workspace) then
				box:Destroy()
			end
		end)
	end

	local stop = false
	
	if switch_ESP_Enabled.GetValue() == true then
		local thread = coroutine.create(function()
			if plr.Character and plr ~= LOCAL_PLAYER then -- Ensure the player's character exists and that this player is not us
				-- Wait until humanoid exists, otherwise just stop the loop after too many checks
				local step = 0
				local maxChecks = 500
				repeat step = step + 1 wait() until plr.Character:FindFirstChild("Humanoid") or step > maxChecks or not SCRIPT_ENABLED

				if step <= maxChecks then
					-- Remove duplicate tags
					for _, v in pairs(APP_GUI:GetChildren()) do
						if v.Name == "Tag_" .. plr.Name then
							v:Destroy()
						end
					end
					
					local tag = Instance.new("TextLabel", APP_GUI)
					tag.Name = "Tag_" .. plr.Name
					tag.TextSize = 11
					tag.TextColor3 = Color3.new(1, 1, 1)
					tag.Font = Enum.Font.GothamSemibold
					tag.AnchorPoint = Vector2.new(0.5, 1)
					tag.TextStrokeTransparency = 0.9
					tag.BackgroundTransparency = 1

					local item = Instance.new("TextLabel", tag)
					item.Name = "Item"
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
						friend.Name = "Friend"
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
					
					local childAddedConnection = plr.Character.ChildAdded:Connect(function(c)
						if SCRIPT_ENABLED then
							if c:IsA("Tool") then -- If player equips tool, then display that
								item.Text = "Holding: " .. c.Name
							end
							
							if c:IsA("BasePart") and c.Name ~= "HumanoidRootPart" then
								AddBox(c)
							end
						end
					end)

					local childRemovedConnection = plr.Character.ChildRemoved:Connect(function(c) -- If player unequips tool, then change that
						if SCRIPT_ENABLED then
							if c:IsA("Tool") then
								item.Text = "" -- Assume no tools are being held
								
								for _, v in pairs(plr.Character:GetChildren()) do -- Check if a tool is held then change it
									if v:IsA("Tool") then
										item.Text = "Holding: " .. v.Name
									end
								end
							end
						end
					end)
					
					-- Add a box for every part, excluding the HumanoidRootPart
					for _, c in pairs(plr.Character:GetChildren()) do
						if c:IsA("BasePart") and c.Name ~= "HumanoidRootPart" then
							AddBox(c)
						end

						if c:IsA("Tool") then -- Check if a tool is held
							item.Text = "Holding: " .. c.Name
						end
					end
					
					local currentCharacter = plr.Character
					local renderSteppedConnection = nil
					
					local function Disconnect()
						pcall(function() childAddedConnection:Disconnect() end)
						pcall(function() childRemovedConnection:Disconnect() end)
						pcall(function() renderSteppedConnection:Disconnect() end)
						
						pcall(function() tag:Destroy() end)
					end
					
					renderSteppedConnection = game:GetService("RunService").RenderStepped:Connect(function()
						if SCRIPT_ENABLED then
							if plr == nil or currentCharacter ~= plr.Character or tag.Parent ~= APP_GUI then
								Disconnect()
							end
							
							local head = plr.Character:FindFirstChild("Head")
							
							-- Tag
							local tagText = ""
							
							if switch_UseDisplayName.GetValue() == true then
								tagText = "[" .. plr.DisplayName .. "]"
							else
								tagText = "[" .. plr.Name .. "]"
							end
							
							if switch_BoldTags.GetValue() == true then
								tag.TextStrokeTransparency = 0
							else
								tag.TextStrokeTransparency = 0.9
							end

							tag.TextColor3 = Color3.new(plr.TeamColor.r, plr.TeamColor.g, plr.TeamColor.b)

							item.Visible = switch_LabelItemInHand.GetValue()

							if plr.Character:FindFirstChild("Humanoid") then
								tagText = tagText .. "[" .. math.floor(plr.Character.Humanoid.Health + 0.5) .. "/" .. math.floor(plr.Character.Humanoid.MaxHealth + 0.5) .. "]"

								if switch_ShowDistance.GetValue() == true then
									tagText = tagText .. "[" .. math.floor((workspace.CurrentCamera.CFrame.Position - plr.Character.HumanoidRootPart.Position).Magnitude + 0.5) .. " studs]"
								end
							end
							
							tag.Text = tagText
							
							-- Position
							if head ~= nil then
								local pos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(head.Position)
								local offset = 1500 / (head.Position - workspace.CurrentCamera.CFrame.Position).Magnitude

								if onScreen then
									tag.Visible = true
									tag.Position = UDim2.new(0, pos.X, 0, pos.Y - offset)
								else
									tag.Visible = false
								end
							else
								tag.Visible = false
							end
						else
							Disconnect()
						end
					end)
				end
			end
		end)
		
		coroutine.resume(thread)
	end
end

-- ESP when player is given new character
for _, plr in pairs(game.Players:GetPlayers()) do
	plr.CharacterAdded:Connect(function(char)
		AddESPToPlayer(plr)
	end)
end

game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		AddESPToPlayer(plr)
	end)
end)

local function RemoveESPs()
	for _, plr in pairs(game.Players:GetPlayers()) do
		if plr.Character then
			for _, c in pairs(plr.Character:GetDescendants()) do
				if c.Name == uniqueId then
					c:Destroy()
				end
			end

			for _, c in pairs(APP_GUI:GetChildren()) do
				if c:IsA("BoxHandleAdornment") or string.find(c.Name, "Tag") then
					c:Destroy()
				end
			end
		end
	end
end


local freecamVelocity = Vector3.new(0, 0, 0)
local freecamRotation = Vector2.new(0, 0)
local freecamPosition = Vector3.new(0, 0, 0)

local previousCamType = workspace.CurrentCamera.CameraType
local lastTick = tick()

local aimbotTarget = nil


local function InputChanged(input, gameProcessed)
	if SCRIPT_ENABLED then
		if input.UserInputType == Enum.UserInputType.MouseWheel and not gameProcessed then
			if switch_Freecam_Enabled.GetValue() == true then
				local ray = workspace.CurrentCamera:ScreenPointToRay(MOUSE.X, MOUSE.Y)
				local direction = ray.Direction
				
				freecamPosition = freecamPosition + (direction * input.Position.Z * 20)
			end
		end
	end
end

local inputChangedConnection = game:GetService("UserInputService").InputChanged:Connect(InputChanged)

while SCRIPT_ENABLED do
	local dt = tick() - lastTick
	local cam = workspace.CurrentCamera

	--mainFrame.BackgroundTransparency = input_GuiTransparency.GetNumber()

	cursor.Position = UDim2.new(0, MOUSE.X, 0, MOUSE.Y)
	if MOUSE.X > mainFrame.AbsolutePosition.X and MOUSE.X < mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X and MOUSE.Y > mainFrame.AbsolutePosition.Y and MOUSE.Y < mainFrame.AbsolutePosition.Y + mainFrame.AbsoluteSize.Y then
		cursor.Visible = true
	else
		cursor.Visible = false
	end
	
	-- Load world
	if button_LoadWorldAtCamera.ButtonPressed() then
		local thread = coroutine.create(function()
			LOCAL_PLAYER:RequestStreamAroundAsync(cam.CFrame.Position)
		end)
		
		coroutine.resume(thread)
	end

	-- Noclip
	if switch_Noclip.GetValue() == true then
		if LOCAL_PLAYER.Character then
			pcall(function()
				LOCAL_PLAYER.Character.Humanoid:ChangeState(11)
			end)
		end
	end

	if switch_ESP_Enabled.ValueChanged() then
		if switch_ESP_Enabled.GetValue() == true then
			for _, plr in pairs(game.Players:GetPlayers()) do
				AddESPToPlayer(plr)
			end
		else
			RemoveESPs()
		end
	end

	if switch_Freecam_Enabled.ValueChanged() then
		if switch_Freecam_Enabled.GetValue() == true then
			game:GetService("ContextActionService"):BindActionAtPriority("WASDUpDownKeys", function() return Enum.ContextActionResult.Sink end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, keybind_FreecamDown.GetKeyCode(), keybind_FreecamUp.GetKeyCode(), Enum.KeyCode.Space, Enum.KeyCode.LeftShift)
			previousCamType = cam.CameraType

			local x, y = workspace.CurrentCamera.CFrame:ToOrientation()
			freecamPosition = workspace.CurrentCamera.CFrame.Position
			freecamRotation = Vector2.new(-y, -x)
		else
			game:GetService("ContextActionService"):BindActionAtPriority("WASDUpDownKeys", function() return Enum.ContextActionResult.Pass end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, keybind_FreecamDown.GetKeyCode(), keybind_FreecamUp.GetKeyCode(), Enum.KeyCode.Space, Enum.KeyCode.LeftShift)
			cam.CameraType = previousCamType

			--[[
			local stuff = APP_GUI:GetChildren()
			
			for i = 1, #stuff do
				if stuff[i]:IsA("BoxHandleAdornment") then
					stuff[i]:Destroy()
				end
			end
			]]
		end
	end

	if button_TeleportToPlayer.ButtonPressed() then
		pcall(function()
			LOCAL_PLAYER.Character:SetPrimaryPartCFrame(MatchPlayerWithString(input_TeleportToPlayer.GetText()).Character:GetPrimaryPartCFrame())
		end)
	end

	if button_TeleportToCamera.ButtonPressed() then
		if LOCAL_PLAYER.Character then
			local look = -(CFrame.new(0, 0, 0) *  CFrame.fromOrientation(-freecamRotation.Y, -freecamRotation.X, 0)).LookVector
			local up = (CFrame.new(0, 0, 0) *  CFrame.fromOrientation(-freecamRotation.Y, -freecamRotation.X, 0)).UpVector
			local right = (CFrame.new(0, 0, 0) *  CFrame.fromOrientation(-freecamRotation.Y, -freecamRotation.X, 0)).RightVector
			cam.CFrame = CFrame.new(freecamPosition) * CFrame.fromOrientation(-freecamRotation.Y, -freecamRotation.X, 0)
			
			LOCAL_PLAYER.Character:SetPrimaryPartCFrame(CFrame.new(workspace.CurrentCamera.CFrame.Position))
		end
	end

	if button_TeleportThrough.ButtonPressed() then
		if LOCAL_PLAYER.Character then
			local root = LOCAL_PLAYER.Character:FindFirstChild("HumanoidRootPart")

			if root then
				LOCAL_PLAYER.Character:SetPrimaryPartCFrame(LOCAL_PLAYER.Character:GetPrimaryPartCFrame() * CFrame.new(0, 0, -input_TeleportThroughLength.GetNumber()))
			end
		end
	end

	pcall(function()
		if switch_Freecam_Enabled.GetValue() == true and game.Players.LocalPlayer.Character.Humanoid.Health > 0 then
			do
				spawn(function()
					local w = INPUT_SERVICE:IsKeyDown(Enum.KeyCode.W)
					local a = INPUT_SERVICE:IsKeyDown(Enum.KeyCode.A)
					local s = INPUT_SERVICE:IsKeyDown(Enum.KeyCode.S)
					local d = INPUT_SERVICE:IsKeyDown(Enum.KeyCode.D)
					local down = INPUT_SERVICE:IsKeyDown(keybind_FreecamDown.GetKeyCode())
					local up = INPUT_SERVICE:IsKeyDown(keybind_FreecamUp.GetKeyCode())

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
						local sens = INPUT_SERVICE.MouseDeltaSensitivity * input_FreecamSensitivity.GetNumber()

						local x = delta.X * (sens * sens)
						local y = delta.Y * (sens * sens)

						freecamRotation = freecamRotation + Vector2.new(math.rad(x), math.rad(y))
					else
						INPUT_SERVICE.MouseBehavior = Enum.MouseBehavior.Default
					end
				end)
			end

			-- Update Camera
			local speedMultiplier = 1

			if INPUT_SERVICE:IsKeyDown(Enum.KeyCode.LeftShift) then
				speedMultiplier = speedMultiplier * 2
			end

			if INPUT_SERVICE:IsKeyDown(Enum.KeyCode.LeftControl) then
				speedMultiplier = speedMultiplier * 0.3
			end

			local move = freecamVelocity.Unit * input_FreecamSpeed.GetNumber() * dt * speedMultiplier
			if tostring(move.X) == "-nan(ind)" then move = Vector3.new(0, 0, 0) end

			cam.CameraType = Enum.CameraType.Scriptable

			local look = -(CFrame.new(0, 0, 0) *  CFrame.fromOrientation(-freecamRotation.Y, -freecamRotation.X, 0)).LookVector
			local up = (CFrame.new(0, 0, 0) *  CFrame.fromOrientation(-freecamRotation.Y, -freecamRotation.X, 0)).UpVector
			local right = (CFrame.new(0, 0, 0) *  CFrame.fromOrientation(-freecamRotation.Y, -freecamRotation.X, 0)).RightVector

			freecamPosition = freecamPosition + (move.Z * look) + (move.X * right) + (move.Y * up)
			cam.CFrame = CFrame.new(freecamPosition) * CFrame.fromOrientation(-freecamRotation.Y, -freecamRotation.X, 0)
		elseif previousCamType and switch_Freecam_Enabled.ValueChanged() then
			freecamVelocity = Vector3.new(0, 0, 0)

			cam.CameraType = previousCamType
			previousCamType = cam.CameraType
		else
			previousCamType = cam.CameraType
		end

		if button_FixCamera.ButtonPressed() then
			pcall(function()
				cam.CameraType = Enum.CameraType.Custom
				workspace.CurrentCamera.CameraSubject = LOCAL_PLAYER.Character.Humanoid
			end)
		end

		if game:GetService("UserInputService"):IsKeyDown(keybind_Aimbot.GetKeyCode()) and switch_Aimbot_Enabled.GetValue() then
			if aimbotTarget == nil then
				-- Aimbot

				local target = nil
				local minDistance = math.huge
				local camDir = workspace.CurrentCamera.CFrame.LookVector

				for _, v in pairs(game.Players:GetPlayers()) do
					if v.Character and v.Name ~= LOCAL_PLAYER.Name then
						local checked = true

						if not v.Character:FindFirstChild("Head") then
							checked = false
						end

						if v.Team == LOCAL_PLAYER.Team and switch_Aimbot_TeamCheck_Enabled.GetValue() then
							checked = false
						end

						if checked then
							local testTarget = v.Character.Head

							local targetDir = -(testTarget.Position - cam.CFrame.Position).Unit
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
					workspace.CurrentCamera.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
				end
			else
				workspace.CurrentCamera.CFrame = CFrame.new(cam.CFrame.Position, aimbotTarget.Position)
			end
		else
			aimbotTarget = nil
		end
	end)
	
	-- Update ESP transparency
	if input_ESP_Transparency.InputChanged() then
		for _, v in pairs(APP_GUI:GetChildren()) do
			if v:IsA("BoxHandleAdornment") and v.Name == "Box" then
				v.Transparency = input_ESP_Transparency.GetNumber()
			end
		end
	end

	-- Update Outputs
	local camPosString = RoundNumber(cam.CFrame.Position.X, 2) .. ", " .. RoundNumber(cam.CFrame.Position.Y, 2) .. ", " .. RoundNumber(cam.CFrame.Position.Z, 2)
	local charPosString = "N/A"
	local charRotationString = "N/A"
	local charVelocityString = "N/A"

	if LOCAL_PLAYER.Character then
		local root = LOCAL_PLAYER.Character.PrimaryPart
		local humanoidRootPart = LOCAL_PLAYER.Character:FindFirstChild("HumanoidRootPart")
		
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
	
	
	output_Camera.EditStatus(1, "Camera Position: " .. camPosString)
	
	output_Character.EditStatus(1, "Character Position: " .. charPosString)
	output_Character.EditStatus(2, "Character Rotation: " .. charRotationString)
	output_Character.EditStatus(3, "Character Velocity: " .. charVelocityString)
	
	output_Misc.EditStatus(1, "Health: N/A")
	output_Misc.EditStatus(2, "Player Count: " .. #game.Players:GetPlayers() .. "/" .. game.Players.MaxPlayers)

	output_Misc.EditStatus(3, "Job ID: " .. game.JobId)

	pcall(function()
		output_Misc.EditStatus(1, "Health: " .. math.floor(LOCAL_PLAYER.Character.Humanoid.Health + 0.5) .. "/" .. math.floor(LOCAL_PLAYER.Character.Humanoid.MaxHealth + 0.5))
	end)


	lastTick = tick()
	game:GetService("RunService").RenderStepped:Wait()
end

RemoveESPs()

if switch_Freecam_Enabled.GetValue() == true then
	workspace.CurrentCamera.CameraType = previousCamType
	game:GetService("ContextActionService"):BindActionAtPriority("WASDUpDownKeys", function() return Enum.ContextActionResult.Pass end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, keybind_FreecamDown.GetKeyCode(), keybind_FreecamUp.GetKeyCode(), Enum.KeyCode.Space, Enum.KeyCode.LeftShift)
end

inputChangedConnection:Disconnect()
