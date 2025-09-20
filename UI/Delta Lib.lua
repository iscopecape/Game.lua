-- DeltaLib UI Library - Improved with error handling and smaller UI
local DeltaLib = {}
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local Players = cloneref(game:GetService("Players"))
local Player = Players.LocalPlayer
local RunService = cloneref(game:GetService("RunService"))
local TextService = cloneref(game:GetService("TextService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

-- Helper functions for error handling
local function SafeCall(func, ...)
	if not func then return nil end
	local success, result = pcall(func, ...)
	if not success then
		warn("DeltaLib Error: " .. tostring(result))
		return nil
	end
	return result
end

local function SafeDestroy(instance)
	if instance and typeof(instance) == "Instance" then
		pcall(function()
			instance:Destroy()
		end)
	end
end

local function SafeConnect(signal, callback)
	if not signal then return nil end
	return pcall(function()
		return signal:Connect(callback)
	end)
end

-- Enhanced Color Scheme with better contrast and readability
local Colors = {
	Background = Color3.fromRGB(15, 15, 15), -- Darker background for better contrast
	LightBackground = Color3.fromRGB(25, 25, 25), -- Slightly lighter for sections
	DarkBackground = Color3.fromRGB(18, 18, 18), -- Input backgrounds
	Text = Color3.fromRGB(255, 255, 255), -- Pure white for better readability
	SubText = Color3.fromRGB(180, 180, 180), -- Lighter gray for better contrast
	NeonRed = Color3.fromRGB(255, 64, 64), -- Brighter red for better visibility
	Border = Color3.fromRGB(45, 45, 45), -- Lighter border for definition
	Success = Color3.fromRGB(64, 255, 64), -- Green for success states
	Warning = Color3.fromRGB(255, 196, 64), -- Orange for warnings
	Hover = Color3.fromRGB(35, 35, 35) -- Hover state color
}

-- Improved Draggable Function with Delta Movement and Error Handling
local function MakeDraggable(frame, dragArea)
	if not frame or not dragArea then return end

	local dragToggle = nil
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	local function updateInput(input)
		if not startPos then return end
		local delta = input.Position - dragStart
		pcall(function()
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end)
	end

	SafeConnect(dragArea.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragToggle = true
			dragStart = input.Position
			startPos = frame.Position

			-- Track when input ends
			SafeConnect(input.Changed, function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false
				end
			end)
		end
	end)

	SafeConnect(dragArea.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	SafeConnect(UserInputService.InputChanged, function(input)
		if input == dragInput and dragToggle then
			updateInput(input)
		end
	end)
end

-- Get Player Avatar with error handling
local function GetPlayerAvatar(userId, size)
	local success, result = pcall(function()
		size = size or "420x420"
		return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=" .. size:split("x")[1] .. "&height=" .. size:split("x")[2] .. "&format=png"
	end)

	if not success then
		warn("Failed to get avatar: " .. tostring(result))
		return "rbxassetid://7784647711" -- Default avatar fallback
	end

	return result
end

-- Create UI Elements
function DeltaLib:CreateWindow(title, size)
	local Window = {}
	size = size or UDim2.new(0, 400, 0, 300) -- Smaller default size

	-- Main GUI
	local DeltaLibGUI = Instance.new("ScreenGui")
	DeltaLibGUI.Name = "DeltaLibGUI"
	DeltaLibGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	DeltaLibGUI.ResetOnSpawn = false

	-- Try to parent to CoreGui if possible (for exploits)
	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(DeltaLibGUI)
			DeltaLibGUI.Parent = CoreGui
		elseif gethui then
			DeltaLibGUI.Parent = gethui()
		else
			DeltaLibGUI.Parent = CoreGui
		end
	end)

	if not DeltaLibGUI.Parent then
		pcall(function()
			DeltaLibGUI.Parent = Player:WaitForChild("PlayerGui")
		end)
	end

	-- Main Frame
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = size
	MainFrame.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
	MainFrame.BackgroundColor3 = Colors.Background
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = DeltaLibGUI

	-- Add rounded corners
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 4) -- Smaller corner radius
	UICorner.Parent = MainFrame

	-- Add shadow
	local Shadow = Instance.new("ImageLabel")
	Shadow.Name = "Shadow"
	Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow.BackgroundTransparency = 1
	Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	Shadow.Size = UDim2.new(1, 25, 1, 25) -- Smaller shadow
	Shadow.ZIndex = -1
	Shadow.Image = "rbxassetid://5554236805"
	Shadow.ImageColor3 = Colors.NeonRed
	Shadow.ImageTransparency = 0.6
	Shadow.ScaleType = Enum.ScaleType.Slice
	Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
	Shadow.Parent = MainFrame

	-- Title Bar
	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 25) -- Smaller title bar
	TitleBar.BackgroundColor3 = Colors.DarkBackground
	TitleBar.BorderSizePixel = 0
	TitleBar.Parent = MainFrame

	local TitleBarCorner = Instance.new("UICorner")
	TitleBarCorner.CornerRadius = UDim.new(0, 4) -- Smaller corner radius
	TitleBarCorner.Parent = TitleBar

	local TitleBarCover = Instance.new("Frame")
	TitleBarCover.Name = "TitleBarCover"
	TitleBarCover.Size = UDim2.new(1, 0, 0.5, 0)
	TitleBarCover.Position = UDim2.new(0, 0, 0.5, 0)
	TitleBarCover.BackgroundColor3 = Colors.DarkBackground
	TitleBarCover.BorderSizePixel = 0
	TitleBarCover.Parent = TitleBar

	-- User Avatar
	local AvatarContainer = Instance.new("Frame")
	AvatarContainer.Name = "AvatarContainer"
	AvatarContainer.Size = UDim2.new(0, 18, 0, 18) -- Smaller avatar
	AvatarContainer.Position = UDim2.new(0, 4, 0, 3)
	AvatarContainer.BackgroundColor3 = Colors.NeonRed
	AvatarContainer.BorderSizePixel = 0
	AvatarContainer.Parent = TitleBar

	local AvatarCorner = Instance.new("UICorner")
	AvatarCorner.CornerRadius = UDim.new(1, 0)
	AvatarCorner.Parent = AvatarContainer

	local AvatarImage = Instance.new("ImageLabel")
	AvatarImage.Name = "AvatarImage"
	AvatarImage.Size = UDim2.new(1, -2, 1, -2)
	AvatarImage.Position = UDim2.new(0, 1, 0, 1)
	AvatarImage.BackgroundTransparency = 1

	-- Use pcall for getting avatar
	pcall(function()
		AvatarImage.Image = GetPlayerAvatar(Player.UserId, "100x100")
	end)

	AvatarImage.Parent = AvatarContainer

	local AvatarImageCorner = Instance.new("UICorner")
	AvatarImageCorner.CornerRadius = UDim.new(1, 0)
	AvatarImageCorner.Parent = AvatarImage

	-- Username
	local UsernameLabel = Instance.new("TextLabel")
	UsernameLabel.Name = "UsernameLabel"
	UsernameLabel.Size = UDim2.new(0, 120, 1, 0)
	UsernameLabel.Position = UDim2.new(0, 26, 0, 0)
	UsernameLabel.BackgroundTransparency = 1
	UsernameLabel.Text = Player.Name
	UsernameLabel.TextColor3 = Colors.Text
	UsernameLabel.TextSize = 12 -- Smaller text size
	UsernameLabel.Font = Enum.Font.GothamSemibold
	UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
	UsernameLabel.Parent = TitleBar

	-- Title
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "TitleLabel"
	TitleLabel.Size = UDim2.new(1, -180, 1, 0)
	TitleLabel.Position = UDim2.new(0, 150, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = title or "Delta UI"
	TitleLabel.TextColor3 = Colors.NeonRed
	TitleLabel.TextSize = 12 -- Smaller text size
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
	TitleLabel.Parent = TitleBar

	-- Minimize Button
	local MinimizeButton = Instance.new("TextButton")
	MinimizeButton.Name = "MinimizeButton"
	MinimizeButton.Size = UDim2.new(0, 20, 0, 20) -- Smaller button
	MinimizeButton.Position = UDim2.new(1, -45, 0, 2) -- Position it to the left of the close button
	MinimizeButton.BackgroundTransparency = 1
	MinimizeButton.Text = "-" -- Minus symbol
	MinimizeButton.TextColor3 = Colors.Text
	MinimizeButton.TextSize = 14 -- Smaller text size
	MinimizeButton.Font = Enum.Font.GothamBold
	MinimizeButton.Parent = TitleBar

	SafeConnect(MinimizeButton.MouseEnter, function()
		MinimizeButton.TextColor3 = Colors.NeonRed
	end)

	SafeConnect(MinimizeButton.MouseLeave, function()
		MinimizeButton.TextColor3 = Colors.Text
	end)

	-- Close Button
	local CloseButton = Instance.new("TextButton")
	CloseButton.Name = "CloseButton"
	CloseButton.Size = UDim2.new(0, 20, 0, 20) -- Smaller button
	CloseButton.Position = UDim2.new(1, -22, 0, 2)
	CloseButton.BackgroundTransparency = 1
	CloseButton.Text = "X"
	CloseButton.TextColor3 = Colors.Text
	CloseButton.TextSize = 14 -- Smaller text size
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.Parent = TitleBar

	SafeConnect(CloseButton.MouseEnter, function()
		CloseButton.TextColor3 = Colors.NeonRed
	end)

	SafeConnect(CloseButton.MouseLeave, function()
		CloseButton.TextColor3 = Colors.Text
	end)

	SafeConnect(CloseButton.MouseButton1Click, function()
		SafeDestroy(DeltaLibGUI)
	end)

	-- Make window draggable with improved function
	MakeDraggable(MainFrame, TitleBar)

	-- Container for tabs with horizontal scrolling
	local TabContainer = Instance.new("Frame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(1, 0, 0, 25) -- Smaller tab container
	TabContainer.Position = UDim2.new(0, 0, 0, 25)
	TabContainer.BackgroundColor3 = Colors.LightBackground
	TabContainer.BorderSizePixel = 0
	TabContainer.Parent = MainFrame

	-- Left Scroll Button
	local LeftScrollButton = Instance.new("TextButton")
	LeftScrollButton.Name = "LeftScrollButton"
	LeftScrollButton.Size = UDim2.new(0, 20, 0, 25) -- Smaller button
	LeftScrollButton.Position = UDim2.new(0, 0, 0, 0)
	LeftScrollButton.BackgroundColor3 = Colors.DarkBackground
	LeftScrollButton.BorderSizePixel = 0
	LeftScrollButton.Text = "<"
	LeftScrollButton.TextColor3 = Colors.Text
	LeftScrollButton.TextSize = 14 -- Smaller text size
	LeftScrollButton.Font = Enum.Font.GothamBold
	LeftScrollButton.ZIndex = 3
	LeftScrollButton.Parent = TabContainer

	-- Right Scroll Button
	local RightScrollButton = Instance.new("TextButton")
	RightScrollButton.Name = "RightScrollButton"
	RightScrollButton.Size = UDim2.new(0, 20, 0, 25) -- Smaller button
	RightScrollButton.Position = UDim2.new(1, -20, 0, 0)
	RightScrollButton.BackgroundColor3 = Colors.DarkBackground
	RightScrollButton.BorderSizePixel = 0
	RightScrollButton.Text = ">"
	RightScrollButton.TextColor3 = Colors.Text
	RightScrollButton.TextSize = 14 -- Smaller text size
	RightScrollButton.Font = Enum.Font.GothamBold
	RightScrollButton.ZIndex = 3
	RightScrollButton.Parent = TabContainer

	-- Tab Scroll Frame
	local TabScrollFrame = Instance.new("ScrollingFrame")
	TabScrollFrame.Name = "TabScrollFrame"
	TabScrollFrame.Size = UDim2.new(1, -40, 1, 0) -- Leave space for scroll buttons
	TabScrollFrame.Position = UDim2.new(0, 20, 0, 0) -- Center between scroll buttons
	TabScrollFrame.BackgroundTransparency = 1
	TabScrollFrame.BorderSizePixel = 0
	TabScrollFrame.ScrollBarThickness = 0 -- Hide scrollbar
	TabScrollFrame.ScrollingDirection = Enum.ScrollingDirection.X
	TabScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
	TabScrollFrame.Parent = TabContainer

	-- Tab Buttons Container
	local TabButtons = Instance.new("Frame")
	TabButtons.Name = "TabButtons"
	TabButtons.Size = UDim2.new(1, 0, 1, 0)
	TabButtons.BackgroundTransparency = 1
	TabButtons.Parent = TabScrollFrame

	local TabButtonsLayout = Instance.new("UIListLayout")
	TabButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
	TabButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	TabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabButtonsLayout.Padding = UDim.new(0, 4) -- Smaller padding
	TabButtonsLayout.Parent = TabButtons

	-- Add padding to the first tab
	local TabButtonsPadding = Instance.new("UIPadding")
	TabButtonsPadding.PaddingLeft = UDim.new(0, 4) -- Smaller padding
	TabButtonsPadding.PaddingRight = UDim.new(0, 4) -- Smaller padding
	TabButtonsPadding.Parent = TabButtons

	-- Update tab scroll canvas size when tabs change
	SafeConnect(TabButtonsLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		pcall(function()
			TabScrollFrame.CanvasSize = UDim2.new(0, TabButtonsLayout.AbsoluteContentSize.X, 0, 0)
		end)
	end)

	-- Scroll buttons functionality
	local scrollAmount = 100 -- Smaller scroll amount
	local scrollDuration = 0.3 -- Duration of scroll animation

	-- Function to scroll with animation
	local function ScrollTabs(direction)
		pcall(function()
			local currentPos = TabScrollFrame.CanvasPosition.X
			local targetPos

			if direction == "left" then
				targetPos = math.max(currentPos - scrollAmount, 0)
			else
				local maxScroll = TabScrollFrame.CanvasSize.X.Offset - TabScrollFrame.AbsoluteSize.X
				targetPos = math.min(currentPos + scrollAmount, maxScroll)
			end

			-- Create a smooth scrolling animation
			local tweenInfo = TweenInfo.new(scrollDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			local tween = TweenService:Create(TabScrollFrame, tweenInfo, {CanvasPosition = Vector2.new(targetPos, 0)})
			tween:Play()
		end)
	end

	-- Button hover effects
	SafeConnect(LeftScrollButton.MouseEnter, function()
		TweenService:Create(LeftScrollButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.NeonRed}):Play()
	end)

	SafeConnect(LeftScrollButton.MouseLeave, function()
		TweenService:Create(LeftScrollButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.DarkBackground}):Play()
	end)

	SafeConnect(RightScrollButton.MouseEnter, function()
		TweenService:Create(RightScrollButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.NeonRed}):Play()
	end)

	SafeConnect(RightScrollButton.MouseLeave, function()
		TweenService:Create(RightScrollButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.DarkBackground}):Play()
	end)

	-- Connect scroll buttons
	SafeConnect(LeftScrollButton.MouseButton1Click, function()
		ScrollTabs("left")
	end)

	SafeConnect(RightScrollButton.MouseButton1Click, function()
		ScrollTabs("right")
	end)

	-- Add continuous scrolling when holding the button
	local isScrollingLeft = false
	local isScrollingRight = false

	SafeConnect(LeftScrollButton.MouseButton1Down, function()
		isScrollingLeft = true

		-- Initial scroll
		ScrollTabs("left")

		-- Continue scrolling while button is held
		spawn(function()
			local initialDelay = 0.5 -- Wait before starting continuous scroll
			wait(initialDelay)

			while isScrollingLeft do
				ScrollTabs("left")
				wait(0.2) -- Scroll interval
			end
		end)
	end)

	SafeConnect(LeftScrollButton.MouseButton1Up, function()
		isScrollingLeft = false
	end)

	SafeConnect(LeftScrollButton.MouseLeave, function()
		isScrollingLeft = false
	end)

	SafeConnect(RightScrollButton.MouseButton1Down, function()
		isScrollingRight = true

		-- Initial scroll
		ScrollTabs("right")

		-- Continue scrolling while button is held
		spawn(function()
			local initialDelay = 0.5 -- Wait before starting continuous scroll
			wait(initialDelay)

			while isScrollingRight do
				ScrollTabs("right")
				wait(0.2) -- Scroll interval
			end
		end)
	end)

	SafeConnect(RightScrollButton.MouseButton1Up, function()
		isScrollingRight = false
	end)

	SafeConnect(RightScrollButton.MouseLeave, function()
		isScrollingRight = false
	end)

	-- Content Container
	local ContentContainer = Instance.new("Frame")
	ContentContainer.Name = "ContentContainer"
	ContentContainer.Size = UDim2.new(1, 0, 1, -50) -- Smaller content container
	ContentContainer.Position = UDim2.new(0, 0, 0, 50)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = MainFrame

	-- Track minimized state
	local isMinimized = false
	local originalSize = size

	-- Minimize/Restore function
	SafeConnect(MinimizeButton.MouseButton1Click, function()
		isMinimized = not isMinimized

		if isMinimized then
			-- Save current size before minimizing if it's been resized
			originalSize = MainFrame.Size

			-- Minimize animation
			pcall(function()
				TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 25)
				}):Play()
			end)

			-- Hide content
			ContentContainer.Visible = false
			TabContainer.Visible = false

			-- Change minimize button to restore symbol
			MinimizeButton.Text = "+"
		else
			-- Restore animation
			pcall(function()
				TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = originalSize
				}):Play()
			end)

			-- Show content (with slight delay to match animation)
			task.delay(0.1, function()
				ContentContainer.Visible = true
				TabContainer.Visible = true
			end)

			-- Change restore button back to minimize symbol
			MinimizeButton.Text = "-"
		end
	end)

	-- Tab Management
	local Tabs = {}
	local SelectedTab = nil

	-- Create Tab Function
	function Window:CreateTab(tabName, iconId)
		local Tab = {}
		iconId = iconId or "rbxassetid://7733717447" -- Default icon

		-- Tab Button with enhanced styling
		local TabButton = Instance.new("TextButton")
		TabButton.Name = tabName.."Button"

		-- Calculate width including icon space
		local textWidth = 100 -- Default width with icon
		pcall(function()
			textWidth = TextService:GetTextSize(tabName, 13, Enum.Font.GothamSemibold, Vector2.new(math.huge, 20)).X + 40 -- Extra space for icon
		end)

		TabButton.Size = UDim2.new(0, textWidth, 1, -4)
		TabButton.Position = UDim2.new(0, 0, 0, 2)
		TabButton.BackgroundColor3 = Colors.DarkBackground
		TabButton.BorderSizePixel = 0
		TabButton.Text = ""
		TabButton.Parent = TabButtons

		local TabButtonCorner = Instance.new("UICorner")
		TabButtonCorner.CornerRadius = UDim.new(0, 6)
		TabButtonCorner.Parent = TabButton

		-- Added gradient background for tabs
		local TabGradient = Instance.new("UIGradient")
		TabGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Colors.DarkBackground),
			ColorSequenceKeypoint.new(1, Colors.LightBackground)
		}
		TabGradient.Rotation = 90
		TabGradient.Parent = TabButton

		-- Tab icon
		local TabIcon = Instance.new("ImageLabel")
		TabIcon.Name = "TabIcon"
		TabIcon.Size = UDim2.new(0, 16, 0, 16)
		TabIcon.Position = UDim2.new(0, 8, 0.5, -8)
		TabIcon.BackgroundTransparency = 1
		TabIcon.Image = iconId
		TabIcon.ImageColor3 = Colors.SubText
		TabIcon.Parent = TabButton

		-- Tab text label with better positioning
		local TabLabel = Instance.new("TextLabel")
		TabLabel.Name = "TabLabel"
		TabLabel.Size = UDim2.new(1, -32, 1, 0)
		TabLabel.Position = UDim2.new(0, 28, 0, 0)
		TabLabel.BackgroundTransparency = 1
		TabLabel.Text = tabName
		TabLabel.TextColor3 = Colors.SubText
		TabLabel.TextSize = 13
		TabLabel.Font = Enum.Font.GothamSemibold
		TabLabel.TextXAlignment = Enum.TextXAlignment.Left
		TabLabel.Parent = TabButton

		-- Tab Content
		local TabContent = Instance.new("ScrollingFrame")
		TabContent.Name = tabName.."Content"
		TabContent.Size = UDim2.new(1, -16, 1, -8) -- Smaller content area
		TabContent.Position = UDim2.new(0, 8, 0, 4)
		TabContent.BackgroundTransparency = 1
		TabContent.BorderSizePixel = 0
		TabContent.ScrollBarThickness = 2
		TabContent.ScrollBarImageColor3 = Colors.NeonRed
		TabContent.Visible = false
		TabContent.Parent = ContentContainer

		local TabContentLayout = Instance.new("UIListLayout")
		TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
		TabContentLayout.Padding = UDim.new(0, 8) -- Smaller padding
		TabContentLayout.Parent = TabContent

		local TabContentPadding = Instance.new("UIPadding")
		TabContentPadding.PaddingTop = UDim.new(0, 4) -- Smaller padding
		TabContentPadding.PaddingBottom = UDim.new(0, 4) -- Smaller padding
		TabContentPadding.Parent = TabContent

		-- Auto-size the scrolling frame content
		SafeConnect(TabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			pcall(function()
				TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContentLayout.AbsoluteContentSize.Y + 8)
			end)
		end)

		-- Enhanced tab selection with icon color changes
		SafeConnect(TabButton.MouseButton1Click, function()
			pcall(function()
				if SelectedTab then
					-- Deselect current tab
					SelectedTab.Button.BackgroundColor3 = Colors.DarkBackground
					SelectedTab.Icon.ImageColor3 = Colors.SubText
					SelectedTab.Label.TextColor3 = Colors.SubText
					SelectedTab.Content.Visible = false
				end

				-- Select new tab with enhanced styling
				TabButton.BackgroundColor3 = Colors.NeonRed
				TabIcon.ImageColor3 = Colors.Text
				TabLabel.TextColor3 = Colors.Text
				TabContent.Visible = true
				SelectedTab = {Button = TabButton, Content = TabContent, Icon = TabIcon, Label = TabLabel}

				-- Scroll to make the selected tab visible
				local buttonPosition = TabButton.AbsolutePosition.X - TabScrollFrame.AbsolutePosition.X
				local buttonEnd = buttonPosition + TabButton.AbsoluteSize.X
				local viewportWidth = TabScrollFrame.AbsoluteSize.X

				if buttonPosition < 0 then
					-- Button is to the left of the visible area
					local targetPos = TabScrollFrame.CanvasPosition.X + buttonPosition - 8
					TweenService:Create(TabScrollFrame, TweenInfo.new(0.3), {
						CanvasPosition = Vector2.new(math.max(targetPos, 0), 0)
					}):Play()
				elseif buttonEnd > viewportWidth then
					-- Button is to the right of the visible area
					local targetPos = TabScrollFrame.CanvasPosition.X + (buttonEnd - viewportWidth) + 8
					local maxScroll = TabScrollFrame.CanvasSize.X.Offset - viewportWidth
					TweenService:Create(TabScrollFrame, TweenInfo.new(0.3), {
						CanvasPosition = Vector2.new(math.min(targetPos, maxScroll), 0)
					}):Play()
				end
			end)
		end)

		-- Add to tabs table
		table.insert(Tabs, {Button = TabButton, Content = TabContent})

		-- If this is the first tab, select it
		if #Tabs == 1 then
			TabButton.BackgroundColor3 = Colors.NeonRed
			TabIcon.ImageColor3 = Colors.Text
			TabLabel.TextColor3 = Colors.Text
			TabContent.Visible = true
			SelectedTab = {Button = TabButton, Content = TabContent, Icon = TabIcon, Label = TabLabel}
		end

		-- Enhanced section creation with better typography
		function Tab:CreateSection(sectionName)
			local Section = {}

			-- Section Container with improved styling
			local SectionContainer = Instance.new("Frame")
			SectionContainer.Name = sectionName.."Section"
			SectionContainer.Size = UDim2.new(1, 0, 0, 35) -- Taller header
			SectionContainer.BackgroundColor3 = Colors.LightBackground
			SectionContainer.BorderSizePixel = 0
			SectionContainer.Parent = TabContent

			local SectionCorner = Instance.new("UICorner")
			SectionCorner.CornerRadius = UDim.new(0, 8)
			SectionCorner.Parent = SectionContainer

			-- Enhanced section border
			local SectionStroke = Instance.new("UIStroke")
			SectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			SectionStroke.Color = Colors.Border
			SectionStroke.Thickness = 1
			SectionStroke.Parent = SectionContainer

			-- Section header with better typography
			local SectionHeader = Instance.new("TextLabel")
			SectionHeader.Name = "SectionHeader"
			SectionHeader.Size = UDim2.new(1, -16, 0, 35)
			SectionHeader.Position = UDim2.new(0, 16, 0, 0)
			SectionHeader.BackgroundTransparency = 1
			SectionHeader.Text = sectionName
			SectionHeader.TextColor3 = Colors.Text
			SectionHeader.TextSize = 16
			SectionHeader.Font = Enum.Font.GothamBold
			SectionHeader.TextXAlignment = Enum.TextXAlignment.Left
			SectionHeader.Parent = SectionContainer

			-- Section divider line
			local SectionDivider = Instance.new("Frame")
			SectionDivider.Name = "SectionDivider"
			SectionDivider.Size = UDim2.new(1, -32, 0, 1)
			SectionDivider.Position = UDim2.new(0, 16, 1, -1)
			SectionDivider.BackgroundColor3 = Colors.NeonRed
			SectionDivider.BorderSizePixel = 0
			SectionDivider.Parent = SectionContainer

			-- Section Content with Scrolling
			local SectionScrollFrame = Instance.new("ScrollingFrame")
			SectionScrollFrame.Name = "SectionScrollFrame"
			SectionScrollFrame.Size = UDim2.new(1, -16, 0, 80) -- Initial height, will be adjusted
			SectionScrollFrame.Position = UDim2.new(0, 8, 0, 35) -- Position below the header
			SectionScrollFrame.BackgroundTransparency = 1
			SectionScrollFrame.BorderSizePixel = 0
			SectionScrollFrame.ScrollBarThickness = 2
			SectionScrollFrame.ScrollBarImageColor3 = Colors.NeonRed
			SectionScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
			SectionScrollFrame.Parent = SectionContainer

			local SectionContent = Instance.new("Frame")
			SectionContent.Name = "SectionContent"
			SectionContent.Size = UDim2.new(1, 0, 0, 0) -- Will be resized based on content
			SectionContent.BackgroundTransparency = 1
			SectionContent.Parent = SectionScrollFrame

			local SectionContentLayout = Instance.new("UIListLayout")
			SectionContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			SectionContentLayout.Padding = UDim.new(0, 6) -- Smaller padding
			SectionContentLayout.Parent = SectionContent

			-- Auto-size the section based on content with error handling
			SafeConnect(SectionContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				pcall(function()
					local contentHeight = SectionContentLayout.AbsoluteContentSize.Y
					SectionContent.Size = UDim2.new(1, 0, 0, contentHeight)

					-- Update the canvas size for scrolling
					SectionScrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)

					-- Adjust the section height (capped at 150 for scrolling)
					local newHeight = math.min(contentHeight, 150) -- Smaller max height
					SectionScrollFrame.Size = UDim2.new(1, -16, 0, newHeight)
					SectionContainer.Size = UDim2.new(1, 0, 0, newHeight + 35 + 1) -- +35 for header, +1 for divider
				end)
			end)

			-- Label Creation Function
			function Section:AddLabel(labelText)
				local LabelContainer = Instance.new("Frame")
				LabelContainer.Name = "LabelContainer"
				LabelContainer.Size = UDim2.new(1, 0, 0, 40) -- Increased height for better presence
				LabelContainer.BackgroundTransparency = 1
				LabelContainer.Parent = SectionContent

				-- Cool holographic background effect
				local LabelBackground = Instance.new("Frame")
				LabelBackground.Name = "LabelBackground"
				LabelBackground.Size = UDim2.new(1, 0, 1, 0)
				LabelBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
				LabelBackground.BorderSizePixel = 0
				LabelBackground.Parent = LabelContainer

				local LabelBackgroundCorner = Instance.new("UICorner")
				LabelBackgroundCorner.CornerRadius = UDim.new(0, 10)
				LabelBackgroundCorner.Parent = LabelBackground

				-- Animated neon border effect
				local LabelStroke = Instance.new("UIStroke")
				LabelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				LabelStroke.Color = Colors.NeonRed
				LabelStroke.Thickness = 2
				LabelStroke.Transparency = 0.3
				LabelStroke.Parent = LabelBackground

				-- Cool animated gradient effect
				local LabelGradient = Instance.new("UIGradient")
				LabelGradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 20, 25)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 25, 30)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 20, 25))
				}
				LabelGradient.Rotation = 0
				LabelGradient.Parent = LabelBackground

				-- Animate the gradient rotation for cool effect
				spawn(function()
					while LabelBackground.Parent do
						for i = 0, 360, 2 do
							if not LabelBackground.Parent then break end
							LabelGradient.Rotation = i
							wait(0.05)
						end
					end
				end)

				-- Enhanced label text with glow effect
				local Label = Instance.new("TextLabel")
				Label.Name = "Label"
				Label.Size = UDim2.new(1, -20, 1, 0)
				Label.Position = UDim2.new(0, 10, 0, 0)
				Label.BackgroundTransparency = 1
				Label.Text = labelText
				Label.TextColor3 = Color3.fromRGB(255, 255, 255)
				Label.TextSize = 16
				Label.Font = Enum.Font.GothamBold
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.TextYAlignment = Enum.TextYAlignment.Center
				Label.Parent = LabelBackground

				-- Add text stroke for glow effect
				local LabelTextStroke = Instance.new("UIStroke")
				LabelTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
				LabelTextStroke.Color = Colors.NeonRed
				LabelTextStroke.Thickness = 1
				LabelTextStroke.Transparency = 0.7
				LabelTextStroke.Parent = Label

				-- Cool hover effect
				local LabelClickArea = Instance.new("TextButton")
				LabelClickArea.Name = "LabelClickArea"
				LabelClickArea.Size = UDim2.new(1, 0, 1, 0)
				LabelClickArea.BackgroundTransparency = 1
				LabelClickArea.Text = ""
				LabelClickArea.Parent = LabelContainer

				SafeConnect(LabelClickArea.MouseEnter, function()
					TweenService:Create(LabelStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
					TweenService:Create(LabelBackground, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 25, 35)}):Play()
				end)

				SafeConnect(LabelClickArea.MouseLeave, function()
					TweenService:Create(LabelStroke, TweenInfo.new(0.3), {Transparency = 0.3}):Play()
					TweenService:Create(LabelBackground, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20, 20, 25)}):Play()
				end)

				local LabelFunctions = {}

				function LabelFunctions:SetText(newText)
					pcall(function()
						Label.Text = newText
					end)
				end

				return LabelFunctions
			end

			-- Button Creation Function
			function Section:AddButton(buttonText, callback)
				callback = callback or function() end

				local ButtonContainer = Instance.new("Frame")
				ButtonContainer.Name = "ButtonContainer"
				ButtonContainer.Size = UDim2.new(1, 0, 0, 35)
				ButtonContainer.BackgroundTransparency = 1
				ButtonContainer.Parent = SectionContent

				local Button = Instance.new("TextButton")
				Button.Name = "Button"
				Button.Size = UDim2.new(1, 0, 1, 0)
				Button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
				Button.BorderSizePixel = 0
				Button.Text = buttonText
				Button.TextColor3 = Colors.Text
				Button.TextSize = 14
				Button.Font = Enum.Font.GothamBold
				Button.Parent = ButtonContainer

				local ButtonCorner = Instance.new("UICorner")
				ButtonCorner.CornerRadius = UDim.new(0, 8)
				ButtonCorner.Parent = Button

				-- Enhanced button border
				local ButtonStroke = Instance.new("UIStroke")
				ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				ButtonStroke.Color = Color3.fromRGB(60, 60, 70)
				ButtonStroke.Thickness = 2
				ButtonStroke.Parent = Button

				-- Cool gradient background
				local ButtonGradient = Instance.new("UIGradient")
				ButtonGradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 35)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))
				}
				ButtonGradient.Rotation = 90
				ButtonGradient.Parent = Button

				-- Enhanced button effects
				SafeConnect(Button.MouseEnter, function()
					TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.NeonRed}):Play()
					TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 100, 120)}):Play()
					TweenService:Create(Button, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				end)

				SafeConnect(Button.MouseLeave, function()
					TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
					TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 60, 70)}):Play()
					TweenService:Create(Button, TweenInfo.new(0.2), {TextColor3 = Colors.Text}):Play()
				end)

				SafeConnect(Button.MouseButton1Click, function()
					-- Click animation
					TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(0.98, 0, 0.9, 0)}):Play()
					wait(0.1)
					TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 1, 0)}):Play()
					SafeCall(callback)
				end)

				local ButtonFunctions = {}

				function ButtonFunctions:SetText(newText)
					pcall(function()
						Button.Text = newText
					end)
				end

				return ButtonFunctions
			end

			-- Toggle Creation Function
			function Section:AddToggle(toggleText, default, callback)
				default = default or false
				callback = callback or function() end

				local ToggleContainer = Instance.new("Frame")
				ToggleContainer.Name = "ToggleContainer"
				ToggleContainer.Size = UDim2.new(1, 0, 0, 30)
				ToggleContainer.BackgroundTransparency = 1
				ToggleContainer.Parent = SectionContent

				local ToggleLabel = Instance.new("TextLabel")
				ToggleLabel.Name = "ToggleLabel"
				ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
				ToggleLabel.BackgroundTransparency = 1
				ToggleLabel.Text = toggleText
				ToggleLabel.TextColor3 = Colors.Text
				ToggleLabel.TextSize = 14
				ToggleLabel.Font = Enum.Font.GothamSemibold
				ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
				ToggleLabel.TextYAlignment = Enum.TextYAlignment.Center
				ToggleLabel.Parent = ToggleContainer

				-- Enhanced toggle button with better styling
				local ToggleButton = Instance.new("Frame")
				ToggleButton.Name = "ToggleButton"
				ToggleButton.Size = UDim2.new(0, 45, 0, 22)
				ToggleButton.Position = UDim2.new(1, -45, 0.5, -11)
				ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
				ToggleButton.BorderSizePixel = 0
				ToggleButton.Parent = ToggleContainer

				local ToggleButtonCorner = Instance.new("UICorner")
				ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
				ToggleButtonCorner.Parent = ToggleButton

				-- Enhanced toggle border
				local ToggleStroke = Instance.new("UIStroke")
				ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				ToggleStroke.Color = Color3.fromRGB(60, 60, 70)
				ToggleStroke.Thickness = 2
				ToggleStroke.Parent = ToggleButton

				-- Enhanced toggle circle with glow effect
				local ToggleCircle = Instance.new("Frame")
				ToggleCircle.Name = "ToggleCircle"
				ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
				ToggleCircle.Position = UDim2.new(0, 3, 0.5, -8)
				ToggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
				ToggleCircle.BorderSizePixel = 0
				ToggleCircle.Parent = ToggleButton

				local ToggleCircleCorner = Instance.new("UICorner")
				ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
				ToggleCircleCorner.Parent = ToggleCircle

				-- Circle glow effect
				local CircleStroke = Instance.new("UIStroke")
				CircleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				CircleStroke.Color = Color3.fromRGB(255, 255, 255)
				CircleStroke.Thickness = 1
				CircleStroke.Transparency = 0.8
				CircleStroke.Parent = ToggleCircle

				-- Make the entire container clickable
				local ToggleClickArea = Instance.new("TextButton")
				ToggleClickArea.Name = "ToggleClickArea"
				ToggleClickArea.Size = UDim2.new(1, 0, 1, 0)
				ToggleClickArea.BackgroundTransparency = 1
				ToggleClickArea.Text = ""
				ToggleClickArea.Parent = ToggleContainer

				-- Toggle State
				local Enabled = default

				-- Enhanced toggle animation
				local function UpdateToggle()
					pcall(function()
						if Enabled then
							TweenService:Create(ToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = Colors.NeonRed}):Play()
							TweenService:Create(ToggleStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(255, 100, 120)}):Play()
							TweenService:Create(ToggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 26, 0.5, -8)}):Play()
							TweenService:Create(ToggleCircle, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
							TweenService:Create(CircleStroke, TweenInfo.new(0.3), {Transparency = 0.3}):Play()
						else
							TweenService:Create(ToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
							TweenService:Create(ToggleStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(60, 60, 70)}):Play()
							TweenService:Create(ToggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 3, 0.5, -8)}):Play()
							TweenService:Create(ToggleCircle, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
							TweenService:Create(CircleStroke, TweenInfo.new(0.3), {Transparency = 0.8}):Play()
						end
					end)
				end

				-- Set initial state
				UpdateToggle()

				-- Toggle Logic with enhanced feedback
				SafeConnect(ToggleClickArea.MouseButton1Click, function()
					Enabled = not Enabled
					UpdateToggle()
					SafeCall(callback, Enabled)
				end)

				-- Hover effects
				SafeConnect(ToggleClickArea.MouseEnter, function()
					TweenService:Create(ToggleLabel, TweenInfo.new(0.2), {TextColor3 = Colors.NeonRed}):Play()
				end)

				SafeConnect(ToggleClickArea.MouseLeave, function()
					TweenService:Create(ToggleLabel, TweenInfo.new(0.2), {TextColor3 = Colors.Text}):Play()
				end)

				local ToggleFunctions = {}

				function ToggleFunctions:SetState(state)
					Enabled = state
					UpdateToggle()
					SafeCall(callback, Enabled)
				end

				function ToggleFunctions:GetState()
					return Enabled
				end

				return ToggleFunctions
			end

			-- Slider Creation Function - Improved for PC and Android with error handling
			function Section:AddSlider(sliderText, min, max, default, callback)
				min = min or 0
				max = max or 100
				default = default or min
				callback = callback or function() end

				local SliderContainer = Instance.new("Frame")
				SliderContainer.Name = "SliderContainer"
				SliderContainer.Size = UDim2.new(1, 0, 0, 36) -- Smaller slider
				SliderContainer.BackgroundTransparency = 1
				SliderContainer.Parent = SectionContent

				local SliderLabel = Instance.new("TextLabel")
				SliderLabel.Name = "SliderLabel"
				SliderLabel.Size = UDim2.new(1, 0, 0, 16) -- Smaller label
				SliderLabel.BackgroundTransparency = 1
				SliderLabel.Text = sliderText
				SliderLabel.TextColor3 = Colors.Text
				SliderLabel.TextSize = 12 -- Smaller text size
				SliderLabel.Font = Enum.Font.Gotham
				SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
				SliderLabel.Parent = SliderContainer

				local SliderValue = Instance.new("TextLabel")
				SliderValue.Name = "SliderValue"
				SliderValue.Size = UDim2.new(0, 25, 0, 16) -- Smaller value label
				SliderValue.Position = UDim2.new(1, -25, 0, 0)
				SliderValue.BackgroundTransparency = 1
				SliderValue.Text = tostring(default)
				SliderValue.TextColor3 = Colors.NeonRed
				SliderValue.TextSize = 12 -- Smaller text size
				SliderValue.Font = Enum.Font.GothamBold
				SliderValue.TextXAlignment = Enum.TextXAlignment.Right
				SliderValue.Parent = SliderContainer

				local SliderBackground = Instance.new("Frame")
				SliderBackground.Name = "SliderBackground"
				SliderBackground.Size = UDim2.new(1, 0, 0, 8) -- Smaller slider bar
				SliderBackground.Position = UDim2.new(0, 0, 0, 20)
				SliderBackground.BackgroundColor3 = Colors.DarkBackground
				SliderBackground.BorderSizePixel = 0
				SliderBackground.Parent = SliderContainer

				local SliderBackgroundCorner = Instance.new("UICorner")
				SliderBackgroundCorner.CornerRadius = UDim.new(1, 0)
				SliderBackgroundCorner.Parent = SliderBackground

				local SliderFill = Instance.new("Frame")
				SliderFill.Name = "SliderFill"
				SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
				SliderFill.BackgroundColor3 = Colors.NeonRed
				SliderFill.BorderSizePixel = 0
				SliderFill.Parent = SliderBackground

				local SliderFillCorner = Instance.new("UICorner")
				SliderFillCorner.CornerRadius = UDim.new(1, 0)
				SliderFillCorner.Parent = SliderFill

				local SliderButton = Instance.new("TextButton")
				SliderButton.Name = "SliderButton"
				SliderButton.Size = UDim2.new(1, 0, 1, 0)
				SliderButton.BackgroundTransparency = 1
				SliderButton.Text = ""
				SliderButton.Parent = SliderBackground

				-- Slider Logic with error handling
				local function UpdateSlider(value)
					pcall(function()
						value = math.clamp(value, min, max)
						value = math.floor(value + 0.5) -- Round to nearest integer

						SliderValue.Text = tostring(value)
						SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
						SafeCall(callback, value)
					end)
				end

				-- Set initial value
				UpdateSlider(default)

				-- Improved Slider Interaction for PC and Android with error handling
				local isDragging = false

				SafeConnect(SliderButton.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						isDragging = true

						-- Calculate value directly from initial press position
						pcall(function()
							local relativePos = input.Position.X - SliderBackground.AbsolutePosition.X
							local percent = math.clamp(relativePos / SliderBackground.AbsoluteSize.X, 0, 1)
							local value = min + (max - min) * percent

							UpdateSlider(value)
						end)
					end
				end)

				SafeConnect(UserInputService.InputEnded, function(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
						isDragging = false
					end
				end)

				SafeConnect(UserInputService.InputChanged, function(input)
					if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						-- Use delta movement for smoother control
						pcall(function()
							local relativePos = input.Position.X - SliderBackground.AbsolutePosition.X
							local percent = math.clamp(relativePos / SliderBackground.AbsoluteSize.X, 0, 1)
							local value = min + (max - min) * percent

							UpdateSlider(value)
						end)
					end
				end)

				local SliderFunctions = {}

				function SliderFunctions:SetValue(value)
					UpdateSlider(value)
				end

				function SliderFunctions:GetValue()
					return tonumber(SliderValue.Text)
				end

				return SliderFunctions
			end

			-- Enhanced dropdown with better styling and animations
			function Section:AddDropdown(dropdownText, options, default, callback)
				local DropdownFunctions = {}
				options = options or {}
				default = default or options[1] or ""
				callback = callback or function() end

				-- Main dropdown container with proper height calculation
				local DropdownContainer = Instance.new("Frame")
				DropdownContainer.Name = "DropdownContainer"
				DropdownContainer.Size = UDim2.new(1, 0, 0, 70) -- Fixed base height
				DropdownContainer.BackgroundTransparency = 1
				DropdownContainer.Parent = SectionContent

				-- Clear dropdown label with better typography
				local DropdownLabel = Instance.new("TextLabel")
				DropdownLabel.Name = "DropdownLabel"
				DropdownLabel.Size = UDim2.new(1, 0, 0, 25)
				DropdownLabel.BackgroundTransparency = 1
				DropdownLabel.Text = dropdownText
				DropdownLabel.TextColor3 = Colors.Text
				DropdownLabel.TextSize = 16
				DropdownLabel.Font = Enum.Font.GothamBold
				DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
				DropdownLabel.TextYAlignment = Enum.TextYAlignment.Center
				DropdownLabel.Parent = DropdownContainer

				-- Enhanced dropdown button with better visual feedback
				local DropdownButton = Instance.new("TextButton")
				DropdownButton.Name = "DropdownButton"
				DropdownButton.Size = UDim2.new(1, 0, 0, 40) -- Increased height for better visibility
				DropdownButton.Position = UDim2.new(0, 0, 0, 25)
				DropdownButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
				DropdownButton.BorderSizePixel = 0
				DropdownButton.Text = ""
				DropdownButton.Parent = DropdownContainer

				local DropdownButtonCorner = Instance.new("UICorner")
				DropdownButtonCorner.CornerRadius = UDim.new(0, 10)
				DropdownButtonCorner.Parent = DropdownButton

				-- Enhanced border with better contrast
				local DropdownButtonStroke = Instance.new("UIStroke")
				DropdownButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				DropdownButtonStroke.Color = Color3.fromRGB(70, 70, 80)
				DropdownButtonStroke.Thickness = 2
				DropdownButtonStroke.Parent = DropdownButton

				-- Enhanced selected value display
				local SelectedTextBox = Instance.new("TextLabel")
				SelectedTextBox.Name = "SelectedTextBox"
				SelectedTextBox.Size = UDim2.new(1, -60, 1, 0)
				SelectedTextBox.Position = UDim2.new(0, 20, 0, 0)
				SelectedTextBox.BackgroundTransparency = 1
				SelectedTextBox.Text = default
				SelectedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
				SelectedTextBox.TextSize = 16
				SelectedTextBox.Font = Enum.Font.GothamSemibold
				SelectedTextBox.TextXAlignment = Enum.TextXAlignment.Left
				SelectedTextBox.TextYAlignment = Enum.TextYAlignment.Center
				SelectedTextBox.Parent = DropdownButton

				-- Enhanced dropdown arrow with better positioning
				local DropdownArrow = Instance.new("TextLabel")
				DropdownArrow.Name = "DropdownArrow"
				DropdownArrow.Size = UDim2.new(0, 40, 1, 0)
				DropdownArrow.Position = UDim2.new(1, -40, 0, 0)
				DropdownArrow.BackgroundTransparency = 1
				DropdownArrow.Text = "▼"
				DropdownArrow.TextColor3 = Colors.NeonRed
				DropdownArrow.TextSize = 16
				DropdownArrow.Font = Enum.Font.GothamBold
				DropdownArrow.TextXAlignment = Enum.TextXAlignment.Center
				DropdownArrow.TextYAlignment = Enum.TextYAlignment.Center
				DropdownArrow.Parent = DropdownButton

				-- Enhanced dropdown list with proper height calculation
				local DropdownList = Instance.new("Frame")
				DropdownList.Name = "DropdownList"
				DropdownList.Size = UDim2.new(1, 0, 0, 0) -- Start with 0 height
				DropdownList.Position = UDim2.new(0, 0, 0, 70) -- Position below the button
				DropdownList.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
				DropdownList.BorderSizePixel = 0
				DropdownList.Visible = false
				DropdownList.ZIndex = 100
				DropdownList.Parent = DropdownContainer

				local DropdownListCorner = Instance.new("UICorner")
				DropdownListCorner.CornerRadius = UDim.new(0, 10)
				DropdownListCorner.Parent = DropdownList

				-- Enhanced dropdown list border
				local DropdownListStroke = Instance.new("UIStroke")
				DropdownListStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				DropdownListStroke.Color = Colors.NeonRed
				DropdownListStroke.Thickness = 2
				DropdownListStroke.Parent = DropdownList

				-- Enhanced scrolling frame
				local DropdownScrollFrame = Instance.new("ScrollingFrame")
				DropdownScrollFrame.Name = "DropdownScrollFrame"
				DropdownScrollFrame.Size = UDim2.new(1, -10, 1, -10)
				DropdownScrollFrame.Position = UDim2.new(0, 5, 0, 5)
				DropdownScrollFrame.BackgroundTransparency = 1
				DropdownScrollFrame.BorderSizePixel = 0
				DropdownScrollFrame.ScrollBarThickness = 8
				DropdownScrollFrame.ScrollBarImageColor3 = Colors.NeonRed
				DropdownScrollFrame.BottomImage = ""
				DropdownScrollFrame.TopImage = ""
				DropdownScrollFrame.ZIndex = 101
				DropdownScrollFrame.Parent = DropdownList

				local DropdownOptionsLayout = Instance.new("UIListLayout")
				DropdownOptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
				DropdownOptionsLayout.Padding = UDim.new(0, 3)
				DropdownOptionsLayout.Parent = DropdownScrollFrame

				local DropdownOptionsPadding = Instance.new("UIPadding")
				DropdownOptionsPadding.PaddingLeft = UDim.new(0, 10)
				DropdownOptionsPadding.PaddingRight = UDim.new(0, 10)
				DropdownOptionsPadding.PaddingTop = UDim.new(0, 8)
				DropdownOptionsPadding.PaddingBottom = UDim.new(0, 8)
				DropdownOptionsPadding.Parent = DropdownScrollFrame

				local isOpen = false
				local isAnimating = false
				local OptionButtons = {}

				-- Enhanced option button creation
				local function CreateOptionButton(option, index)
					local OptionButton = Instance.new("TextButton")
					OptionButton.Name = "OptionButton_" .. index
					OptionButton.Size = UDim2.new(1, 0, 0, 35) -- Increased height for better readability
					OptionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
					OptionButton.BorderSizePixel = 0
					OptionButton.Text = option
					OptionButton.TextColor3 = Color3.fromRGB(220, 220, 220)
					OptionButton.TextSize = 15
					OptionButton.Font = Enum.Font.GothamSemibold
					OptionButton.TextXAlignment = Enum.TextXAlignment.Left
					OptionButton.ZIndex = 102
					OptionButton.Parent = DropdownScrollFrame

					local OptionButtonCorner = Instance.new("UICorner")
					OptionButtonCorner.CornerRadius = UDim.new(0, 8)
					OptionButtonCorner.Parent = OptionButton

					local OptionButtonPadding = Instance.new("UIPadding")
					OptionButtonPadding.PaddingLeft = UDim.new(0, 15)
					OptionButtonPadding.Parent = OptionButton

					-- Enhanced hover effects with better visual feedback
					SafeConnect(OptionButton.MouseEnter, function()
						TweenService:Create(OptionButton, TweenInfo.new(0.2), {
							BackgroundColor3 = Colors.NeonRed
						}):Play()
						TweenService:Create(OptionButton, TweenInfo.new(0.2), {
							TextColor3 = Color3.fromRGB(255, 255, 255)
						}):Play()
					end)

					SafeConnect(OptionButton.MouseLeave, function()
						TweenService:Create(OptionButton, TweenInfo.new(0.2), {
							BackgroundColor3 = Color3.fromRGB(30, 30, 35)
						}):Play()
						TweenService:Create(OptionButton, TweenInfo.new(0.2), {
							TextColor3 = Color3.fromRGB(220, 220, 220)
						}):Play()
					end)

					SafeConnect(OptionButton.MouseButton1Click, function()
						SelectedTextBox.Text = option
						SafeCall(callback, option)
						ToggleDropdown()
					end)

					return OptionButton
				end

				-- Initialize options
				for i, option in ipairs(options) do
					local optionButton = CreateOptionButton(option, i)
					table.insert(OptionButtons, optionButton)
				end

				-- Enhanced toggle function with proper height calculation
				local function ToggleDropdown()
					if isAnimating then return end
					isAnimating = true
					isOpen = not isOpen

					-- Enhanced arrow animation
					TweenService:Create(DropdownArrow, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
						Rotation = isOpen and 180 or 0
					}):Play()

					-- Enhanced border color change
					TweenService:Create(DropdownButtonStroke, TweenInfo.new(0.3), {
						Color = isOpen and Colors.NeonRed or Color3.fromRGB(70, 70, 80)
					}):Play()

					if isOpen then
						DropdownList.Visible = true
						-- Calculate proper height based on number of options
						local optionsHeight = math.min(#options * 38 + 16, 200) -- Fixed height calculation
						
						-- Update container size to accommodate dropdown
						TweenService:Create(DropdownContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
							Size = UDim2.new(1, 0, 0, 70 + optionsHeight)
						}):Play()

						local listTween = TweenService:Create(
							DropdownList,
							TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{Size = UDim2.new(1, 0, 0, optionsHeight)}
						)

						listTween.Completed:Connect(function()
							isAnimating = false
							DropdownScrollFrame.CanvasSize = UDim2.new(0, 0, 0, DropdownOptionsLayout.AbsoluteContentSize.Y + 16)
						end)

						listTween:Play()
					else
						-- Reset container size
						TweenService:Create(DropdownContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
							Size = UDim2.new(1, 0, 0, 70)
						}):Play()

						local listTween = TweenService:Create(
							DropdownList,
							TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
							{Size = UDim2.new(1, 0, 0, 0)}
						)

						listTween.Completed:Connect(function()
							DropdownList.Visible = false
							isAnimating = false
						end)

						listTween:Play()
					end
				end

				SafeConnect(DropdownButton.MouseButton1Click, ToggleDropdown)

				-- Enhanced hover effects for main button
				SafeConnect(DropdownButton.MouseEnter, function()
					if not isOpen then
						TweenService:Create(DropdownButtonStroke, TweenInfo.new(0.2), {
							Color = Color3.fromRGB(100, 100, 110)
						}):Play()
						TweenService:Create(DropdownButton, TweenInfo.new(0.2), {
							BackgroundColor3 = Color3.fromRGB(30, 30, 35)
						}):Play()
					end
				end)

				SafeConnect(DropdownButton.MouseLeave, function()
					if not isOpen then
						TweenService:Create(DropdownButtonStroke, TweenInfo.new(0.2), {
							Color = Color3.fromRGB(70, 70, 80)
						}):Play()
						TweenService:Create(DropdownButton, TweenInfo.new(0.2), {
							BackgroundColor3 = Color3.fromRGB(25, 25, 30)
						}):Play()
					end
				end)

				function DropdownFunctions:SetValue(value)
					if table.find(options, value) then
						SelectedTextBox.Text = value
						callback(value)
					end
				end

				function DropdownFunctions:GetValue()
					return SelectedTextBox.Text
				end

				function DropdownFunctions:Refresh(newOptions, newDefault)
					options = newOptions or options
					default = newDefault or (options[1] or "")

					for _, button in ipairs(OptionButtons) do
						button:Destroy()
					end

					OptionButtons = {}

					for i, option in ipairs(options) do
						local optionButton = CreateOptionButton(option, i)
						table.insert(OptionButtons, optionButton)
					end

					DropdownScrollFrame.CanvasSize = UDim2.new(0, 0, 0, DropdownOptionsLayout.AbsoluteContentSize.Y + 16)
					SelectedTextBox.Text = default
				end

				return DropdownFunctions
			end

			-- Enhanced textbox without icons as requested
			function Section:AddTextBox(boxText, placeholder, default, callback)
				placeholder = placeholder or ""
				default = default or ""
				callback = callback or function() end

				local TextBoxContainer = Instance.new("Frame")
				TextBoxContainer.Name = "TextBoxContainer"
				TextBoxContainer.Size = UDim2.new(1, 0, 0, 50)
				TextBoxContainer.BackgroundTransparency = 1
				TextBoxContainer.Parent = SectionContent

				-- Clean textbox label
				local TextBoxLabel = Instance.new("TextLabel")
				TextBoxLabel.Name = "TextBoxLabel"
				TextBoxLabel.Size = UDim2.new(1, 0, 0, 25)
				TextBoxLabel.BackgroundTransparency = 1
				TextBoxLabel.Text = boxText
				TextBoxLabel.TextColor3 = Colors.Text
				TextBoxLabel.TextSize = 16
				TextBoxLabel.Font = Enum.Font.GothamSemibold
				TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
				TextBoxLabel.TextYAlignment = Enum.TextYAlignment.Center
				TextBoxLabel.Parent = TextBoxContainer

				-- Clean textbox without icon
				local TextBox = Instance.new("TextBox")
				TextBox.Name = "TextBox"
				TextBox.Size = UDim2.new(1, 0, 0, 25)
				TextBox.Position = UDim2.new(0, 0, 0, 25)
				TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
				TextBox.BorderSizePixel = 0
				TextBox.PlaceholderText = placeholder
				TextBox.Text = default
				TextBox.TextColor3 = Colors.Text
				TextBox.PlaceholderColor3 = Colors.SubText
				TextBox.TextSize = 14
				TextBox.Font = Enum.Font.Gotham
				TextBox.TextXAlignment = Enum.TextXAlignment.Left
				TextBox.ClearTextOnFocus = false
				TextBox.Parent = TextBoxContainer

				-- Simple padding without icon space
				local TextBoxPadding = Instance.new("UIPadding")
				TextBoxPadding.PaddingLeft = UDim.new(0, 12)
				TextBoxPadding.PaddingRight = UDim.new(0, 12)
				TextBoxPadding.Parent = TextBox

				local TextBoxCorner = Instance.new("UICorner")
				TextBoxCorner.CornerRadius = UDim.new(0, 8)
				TextBoxCorner.Parent = TextBox

				-- Clean textbox border
				local TextBoxStroke = Instance.new("UIStroke")
				TextBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				TextBoxStroke.Color = Color3.fromRGB(60, 60, 70)
				TextBoxStroke.Thickness = 2
				TextBoxStroke.Parent = TextBox

				-- Focus effects
				SafeConnect(TextBox.Focused, function()
					pcall(function()
						TweenService:Create(TextBoxStroke, TweenInfo.new(0.2), {
							Color = Colors.NeonRed
						}):Play()
					end)
				end)

				SafeConnect(TextBox.FocusLost, function(enterPressed)
					pcall(function()
						TweenService:Create(TextBoxStroke, TweenInfo.new(0.2), {
							Color = Color3.fromRGB(60, 60, 70)
						}):Play()
						SafeCall(callback, TextBox.Text, enterPressed)
					end)
				end)

				-- Hover effects
				SafeConnect(TextBox.MouseEnter, function()
					if not TextBox:IsFocused() then
						TweenService:Create(TextBoxStroke, TweenInfo.new(0.2), {
							Color = Color3.fromRGB(80, 80, 90)
						}):Play()
					end
				end)

				SafeConnect(TextBox.MouseLeave, function()
					if not TextBox:IsFocused() then
						TweenService:Create(TextBoxStroke, TweenInfo.new(0.2), {
							Color = Color3.fromRGB(60, 60, 70)
						}):Play()
					end
				end)

				local TextBoxFunctions = {}

				function TextBoxFunctions:SetText(text)
					pcall(function()
						TextBox.Text = text
						SafeCall(callback, text, false)
					end)
				end

				function TextBoxFunctions:GetText()
					return TextBox.Text
				end

				return TextBoxFunctions
			end

			return Section
		end

		return Tab
	end

	-- Add User Profile Section with error handling
	function Window:AddUserProfile(displayName)
		displayName = displayName or Player.DisplayName

		-- Update username label
		pcall(function()
			UsernameLabel.Text = displayName
		end)

		-- Create a function to update the avatar
		local function UpdateAvatar(userId)
			pcall(function()
				AvatarImage.Image = GetPlayerAvatar(userId or Player.UserId, "100x100")
			end)
		end

		return {
			SetDisplayName = function(name)
				pcall(function()
					UsernameLabel.Text = name
				end)
			end,
			UpdateAvatar = UpdateAvatar
		}
	end

	return Window
end

return DeltaLib
