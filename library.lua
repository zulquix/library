local TDLib = {}
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Theme configuration
local Themes = {
    Dark = {
        Primary = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(0, 200, 0),
        Error = Color3.fromRGB(200, 0, 0),
        Warning = Color3.fromRGB(200, 200, 0),
        Info = Color3.fromRGB(0, 170, 255),
        Shadow = Color3.fromRGB(0, 0, 0),
    },
    Light = {
        Primary = Color3.fromRGB(240, 240, 240),
        Secondary = Color3.fromRGB(220, 220, 220),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(0, 180, 0),
        Error = Color3.fromRGB(180, 0, 0),
        Warning = Color3.fromRGB(180, 180, 0),
        Info = Color3.fromRGB(0, 150, 255),
        Shadow = Color3.fromRGB(100, 100, 100),
    }
}

-- Animation configurations
local Animations = {
    HoverScale = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    ClickFade = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
    Slide = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Fade = TweenInfo.new(0.2, Enum.EasingStyle.Linear),
}

-- Utility functions
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
end

local function createShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Themes.Dark.Shadow
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
end

local function applyTween(instance, properties, tweenInfo)
    TweenService:Create(instance, tweenInfo or Animations.Fade, properties):Play()
end

-- Main library initialization
function TDLib:init(title, theme)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TDLibModernUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("CoreGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
    MainFrame.BackgroundColor3 = Themes[theme or "Dark"].Primary
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    createCorner(MainFrame)
    createShadow(MainFrame)

    -- Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Themes[theme or "Dark"].Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Text = title or "TDLib Modern UI"
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextColor3 = Themes[theme or "Dark"].Text
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    -- Window controls
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.TextSize = 14
    CloseButton.BackgroundColor3 = Themes[theme or "Dark"].Error
    CloseButton.TextColor3 = Themes[theme or "Dark"].Text
    CloseButton.Parent = TitleBar
    createCorner(CloseButton, 4)

    CloseButton.MouseButton1Click:Connect(function()
        applyTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, Animations.Slide)
        wait(0.3)
        ScreenGui:Destroy()
    end)

    -- Draggable functionality
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Tab holder
    local TabHolder = Instance.new("Frame")
    TabHolder.Name = "TabHolder"
    TabHolder.Size = UDim2.new(0, 150, 1, -40)
    TabHolder.Position = UDim2.new(0, 0, 0, 40)
    TabHolder.BackgroundColor3 = Themes[theme or "Dark"].Secondary
    TabHolder.BorderSizePixel = 0
    TabHolder.Parent = MainFrame

    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.Text
    TabList.Padding = 4
    TabList.Parent = TabHolder

    -- Content frame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Text = "ContentFrame"
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, -150, 1, -40))
    ContentFrame.Position = UDim2.new(0, 150, 0, 40)
    ContentFrame.BackgroundColor3 = Themes[theme or "Dark"].Primary
    ContentFrame.BorderSizePixel = 0
    local Content = UDim2.new(ContentFrame)
    ContentFrame.Parent = MainFrame

    -- Notification holder
    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "NotificationHolder"
    NotificationHolder.Size = UDim2.new(0, 0, 300, 0,  ContentHolder)
    NotificationHolder.Position = UDim2.new(1, -310, 1, -150)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Parent = ContentFrame

    -- Library state
    self.main = MainFrame
    self.tabs = {}
    self.currentTab = nil
    self.config = Content
    self.theme = Themes[theme or "Dark"]
    self.notificationHolder = NotificationHolder
    self.screenGui = ScreenGui

    -- Add default unload tab
    self:AddTab("Settings")
    self:AddButton(self.tabs["Settings"], "Unload UI", 30, function()
        applyTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, Animations.Slide)
        wait(0.3)
        ScreenGui:Destroy()
    end)

    return self
end

-- Add a tab with smooth transition
function TDLib:AddTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name
    TabButton.Size = UDim2.new(1, -10, 0, 35)
    TabButton.Position = UDim2.new(0, 5, 0, 0)
    TabButton.Text = name
    TabButton.Font = Enum.Font.SourceSansProBold
    TabButton.TextSize = 16
    TabButton.TextColor3 = self.theme.Text
    TabButton.BackgroundColor3 = self.theme.Secondary
    TabButton.Parent = self.main.TabHolder
    createCorner(TabButton, 4)

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Name = name
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
    TabFrame.ScrollBarThickness = 6
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.Parent = self.main.Content
    TabFrame.ScrollBarImageColor3 = self.theme.Accent

    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 8)
    TabList.Parent = TabFrame

    -- Tab button interactions
    TabButton.MouseEnter:Connect(function()
        applyTween(TabButton, {BackgroundColor3 = self.theme.Accent}, Animations.HoverScale)
    end)

    TabButton.MouseLeave:Connect(function()
        applyTween(TabButton, {BackgroundColor3 = self.theme.Secondary}, Animations.HoverScale)
    end)

    TabButton.MouseButton1Click:Connect(function()
        if self.currentTab then
            applyTween(self.currentTab, {BackgroundTransparency = 1}, Animations.Fade)
            self.currentTab.Visible = false
        end
        TabFrame.Visible = true
        applyTween(TabFrame, {BackgroundTransparency = 0}, Animations.Fade)
        self.currentTab = TabFrame
    end)

    self.tabs[name] = TabFrame
    if not self.currentTab then
        TabFrame.Visible = true
        self.currentTab = TabFrame
    end

    return TabFrame
end

-- Add toggle component
function TDLib:AddToggle(parent, title, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 40)
    ToggleFrame.Position = UDim2.new(0, 10, 0, 0)
    ToggleFrame.BackgroundColor3 = self.theme.Secondary
    ToggleFrame.Parent = parent
    createCorner(ToggleFrame, 6)

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Text = title
    ToggleLabel.Font = Enum.Font.SourceSansPro
    ToggleLabel.TextSize = 16
    ToggleLabel.TextColor3 = self.theme.Text
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame

    local ToggleSwitch = Instance.new("Frame")
    ToggleSwitch.Size = UDim2.new(0, 50, 0, 24)
    ToggleSwitch.Position = UDim2.new(0.85, -60, 0.5, -12)
    ToggleSwitch.BackgroundColor3 = self.theme.Primary
    ToggleSwitch.Parent = ToggleFrame
    createCorner(ToggleSwitch, 12)

    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Size = UDim2.new(0, 20, 0, 20)
    ToggleKnob.Position = UDim2.new(0, default and 30 or 4, 0, 2)
    ToggleKnob.BackgroundColor3 = default and self.theme.Accent or self.theme.Text
    ToggleKnob.Parent = ToggleSwitch
    createCorner(ToggleKnob, 10)

    local state = default
    self.config[title] = state

    ToggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            self.config[title] = state
            applyTween(ToggleKnob, {
                Position = UDim2.new(0, state and 30 or 4, 0, 2),
                BackgroundColor3 = state and self.theme.Accent or self.theme.Text
            }, Animations.Slide)
            ToggleLabel.Text = title .. ": " .. tostring(state)
            callback(state)
        end
    end)

    return ToggleFrame
end

-- Add slider component
function TDLib:AddSlider(parent, title, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -20, 0, 60)
    SliderFrame.Position = UDim2.new(0, 10, 0, 0)
    SliderFrame.BackgroundColor3 = self.theme.Secondary
    SliderFrame.Parent = parent
    createCorner(SliderFrame, 6)

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.Text = title .. ": " .. default
    SliderLabel.Font = Enum.Font.SourceSansPro
    SliderLabel.TextSize = 16
    SliderLabel.TextColor3 = self.theme.Text
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Parent = SliderFrame

    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, -20, 0, 8)
    SliderTrack.Position = UDim2.new(0, 10, 0, 40)
    SliderTrack.BackgroundColor3 = self.theme.Primary
    SliderTrack.Parent = SliderFrame
    createCorner(SliderTrack, 4)

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = self.theme.Accent
    SliderFill.Parent = SliderTrack
    createCorner(SliderFill, 4)

    local value = default
    self.config[title] = value

    local dragging
    SliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    SliderTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X
            local trackAbsPos = SliderTrack.AbsolutePosition.X
            local trackWidth = SliderTrack.AbsoluteSize.X
            local relative = math.clamp((mouseX - trackAbsPos) / trackWidth, 0, 1)
            value = math.floor(min + relative * (max - min))
            SliderFill.Size = UDim2.new(relative, 0, 1, 0)
            SliderLabel.Text = title .. ": " .. value
            self.config[title] = value
            callback(value)
        end
    end)

    return SliderFrame
end

-- Add button component
function TDLib:AddButton(parent, text, height, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, height or 40)
    Button.Position = UDim2.new(0, 10, 0, 0)
    Button.Text = text
    Button.Font = Enum.Font.SourceSansProBold
    Button.TextSize = 16
    Button.TextColor3 = self.theme.Text
    Button.BackgroundColor3 = self.theme.Accent
    Button.Parent = parent
    createCorner(Button, 6)

    Button.MouseEnter:Connect(function()
        applyTween(Button, {BackgroundColor3 = self.theme.Info}, Animations.HoverScale)
    end)

    Button.MouseLeave:Connect(function()
        applyTween(Button, {BackgroundColor3 = self.theme.Accent}, Animations.HoverScale)
    end)

    Button.MouseButton1Click:Connect(function()
        applyTween(Button, {BackgroundTransparency = 0.2}, Animations.ClickFade)
        wait(0.1)
        applyTween(Button, {BackgroundTransparency = 0}, Animations.ClickFade)
        callback()
    end)

    return Button
end

-- Add dropdown component
function TDLib:AddDropdown(parent, title, options, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, -20, 0, 40)
    DropdownFrame.Position = UDim2.new(0, 10, 0, 0)
    DropdownFrame.BackgroundColor3 = self.theme.Secondary
    DropdownFrame.Parent = parent
    createCorner(DropdownFrame, 6)

    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, 0, 1, 0)
    DropdownButton.Text = title .. ": " .. options[1]
    DropdownButton.Font = Enum.Font.SourceSansPro
    DropdownButton.TextSize = 16
    DropdownButton.TextColor3 = self.theme.Text
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Parent = DropdownFrame

    local DropdownList = Instance.new("Frame")
    DropdownList.Size = UDim2.new(1, 0, 0, 0)
    DropdownList.Position = UDim2.new(0, 0, 1, 0)
    DropdownList.BackgroundColor3 = self.theme.Secondary
    DropdownList.Visible = false
    DropdownList.Parent = DropdownFrame
    createCorner(DropdownList, 6)

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = DropdownList

    local index = 1
    self.config[title] = options[index]

    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 30)
        OptionButton.Text = option
        OptionButton.Font = Enum.Font.SourceSansPro
        OptionButton.TextSize = 16
        OptionButton.TextColor3 = self.theme.Text
        OptionButton.BackgroundColor3 = self.theme.Secondary
        OptionButton.Parent = DropdownList

        OptionButton.MouseButton1Click:Connect(function()
            index = i
            self.config[title] = option
            DropdownButton.Text = title .. ": " .. option
            DropdownList.Visible = false
            applyTween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, Animations.Slide)
            callback(option)
        end)
    end

    DropdownButton.MouseButton1Click:Connect(function()
        DropdownList.Visible = not DropdownList.Visible
        applyTween(DropdownList, {
            Size = UDim2.new(1, 0, 0, DropdownList.Visible and (#options * 30) or 0)
        }, Animations.Slide)
    end)

    return DropdownFrame
end

-- Add text input component
function TDLib:AddTextInput(parent, defaultText, callback)
    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, -20, 0, 40)
    InputFrame.Position = UDim2.new(0, 10, 0, 0)
    InputFrame.BackgroundColor3 = self.theme.Secondary
    InputFrame.Parent = parent
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -10, 0, 30)
    TextBox.Position = UDim2.new(0, 5, 0, -15)
    TextBox.Text = defaultText or ""
    TextBox.Font = Enum.Font.SourceSansPro
    TextBox.TextSize = 16
    TextBox.TextColor3 = self.theme.Text
    TextBox.BackgroundColor3 = self.theme.Primary
    TextBox.Parent = InputFrame
    createCorner(TextBox, 4)

    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            self.config[defaultText] = TextBox.Text
            callback(TextBox.Text)
        end
    end)

    return InputFrame
end

-- Notification system
function TDLib:Notify(text, duration, type)
    local Notification = Instance.new("TextLabel")
    Notification.Size = UDim2.new(1, 0, 0, 30)
    Notification.Text = text
    Notification.Font = Enum.Font.SourceSansProBold
    Notification.TextSize = 16
    Notification.TextColor3 = self.theme.Text
    Notification.BackgroundColor3 = self.theme[type or "Info"]
    Notification.Parent = self.BackgroundNotificationHolder
    createCorner(Notification, 6)

    applyTween(Notification, {Position = UDim2.new(0, 0, 0, 0)}, Animations.Slide)
    Debris:AddItem(Notification, duration or 3)
end

-- Theme switching
function TDLib:SetTheme(theme)
    self.theme = Themes[theme] or Themes.Dark
    self.main.BackgroundColor3 = self.theme.BackgroundColor3
    self.main.Content.BackgroundColor3 = self.theme.Background
    self.main.TabHolder.BackgroundColor3 = self.theme.Secondary

    for _, tab in pairs(self.tabs) do
        for _, child in ipairs(tab:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                child.TextColor3 = self.theme.Text
            elseif child:IsA("Frame") then
                child.BackgroundColor3 = self.theme.Secondary
            end
        end
    end
end

-- Save configuration
function TDLib:SaveConfig(name)
    if writefile then
        writefile(name .. ".tdconfig", HttpService:JSONEncode(self.config))
    end
end

-- Load configuration
function TDLib:LoadConfig(name)
    if inputfile and inputfile(name .. ".tdconfig") then
        self.config = HttpService:JSONDecode(readfile(name .. ".tdconfig"))
    end
end

-- Resizable window
function TDLib:MakeResizable()
    local ResizeHandle = Instance.new("Frame")
    ResizeHandle.Size = UDim2.new(0, 10, 0, 10)
    ResizeHandle.Position = UDim2.new(1, -10, 1, -10)
    ResizeHandle.BackgroundColor3 = self.theme.Accent
    ResizeHandle.Parent = self.main
    createCorner(ResizeHandle, 2)

    local resizing, resizeStart, startSize
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = self.main.Size
        end
    end)

    ResizeHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            self.main.Size = UDim2.new(
                0,
                math.max(300, startSize.X.Offset + delta.X),
                0,
                math.max(200, startSize.Y.Offset + delta.Y)
            )
        end
    end)
end

-- Minimize/maximize window
function TDLib:ToggleMinimize()
    local minimized = self.main.Size.Y.Offset == 40
    applyTween(self.main, {
        Size = UDim2.new(0, minimized and 600 or 300, 0, minimized and 450 or 40)
    }, Animations.Slide)
end

return TDLib
