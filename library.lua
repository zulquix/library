local TDLib = {}
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

function TDLib:init(title)
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "TDLibUI"
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 550, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Text = title
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1

    local TabHolder = Instance.new("Frame", MainFrame)
    TabHolder.Name = "TabHolder"
    TabHolder.Size = UDim2.new(0, 150, 1, -30)
    TabHolder.Position = UDim2.new(0, 0, 0, 30)
    TabHolder.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    TabHolder.BorderSizePixel = 0

    local Content = Instance.new("Frame", MainFrame)
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -150, 1, -30)
    Content.Position = UDim2.new(0, 150, 0, 30)
    Content.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Content.BorderSizePixel = 0

    local UIList = Instance.new("UIListLayout", TabHolder)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 5)

    self.main = MainFrame
    self.tabs = {}
    self.currentTab = nil
    self.config = {}

    self:AddButton(TabHolder, "Unload", function()
        ScreenGui:Destroy()
    end)

    return self
end

function TDLib:AddTab(name)
    local TabButton = Instance.new("TextButton", self.main.TabHolder)
    TabButton.Size = UDim2.new(1, -10, 0, 40)
    TabButton.Text = name
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 14
    TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabButton.BorderSizePixel = 0

    local Frame = Instance.new("ScrollingFrame", self.main.Content)
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.CanvasSize = UDim2.new(0, 0, 5, 0)
    Frame.ScrollBarThickness = 5
    Frame.Visible = false
    Frame.BackgroundTransparency = 1
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

    local UIList = Instance.new("UIListLayout", Frame)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 10)

    TabButton.MouseButton1Click:Connect(function()
        if self.currentTab then self.currentTab.Visible = false end
        Frame.Visible = true
        self.currentTab = Frame
        TabButton.TextColor3 = Color3.fromRGB(255, 0, 255)
    end)

    self.tabs[name] = Frame
    if not self.currentTab then
        Frame.Visible = true
        self.currentTab = Frame
        TabButton.TextColor3 = Color3.fromRGB(255, 0, 255)
    end

    return Frame
end

function TDLib:AddToggle(parent, title, default, callback)
    local Button = Instance.new("TextButton", parent)
    Button.Size = UDim2.new(1, -20, 0, 30)
    Button.Text = title .. ": " .. tostring(default)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.BorderSizePixel = 0

    local state = default
    self.config[title] = state

    Button.MouseButton1Click:Connect(function()
        state = not state
        self.config[title] = state
        Button.Text = title .. ": " .. tostring(state)
        callback(state)
    end)
end

function TDLib:AddSlider(parent, title, min, max, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -20, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderSizePixel = 0

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Text = title .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.BackgroundTransparency = 1

    local Slider = Instance.new("TextButton", Frame)
    Slider.Size = UDim2.new(1, 0, 0, 10)
    Slider.Position = UDim2.new(0, 0, 0, 20)
    Slider.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
    Slider.BorderSizePixel = 0
    Slider.Text = ""

    local value = default
    self.config[title] = value

    Slider.MouseButton1Click:Connect(function()
        value = math.clamp(value + 1, min, max)
        self.config[title] = value
        Label.Text = title .. ": " .. value
        callback(value)
    end)

    return Frame
end

function TDLib:AddButton(parent, text, callback)
    local Button = Instance.new("TextButton", parent)
    Button.Size = UDim2.new(1, -20, 0, 30)
    Button.Text = text
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.BorderSizePixel = 0
    Button.MouseButton1Click:Connect(callback)
end

function TDLib:AddDropdown(parent, title, options, callback)
    local Button = Instance.new("TextButton", parent)
    Button.Size = UDim2.new(1, -20, 0, 30)
    Button.Text = title .. ": " .. options[1]
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.BorderSizePixel = 0

    local index = 1
    self.config[title] = options[index]

    Button.MouseButton1Click:Connect(function()
        index = index + 1
        if index > #options then index = 1 end
        self.config[title] = options[index]
        Button.Text = title .. ": " .. options[index]
        callback(options[index])
    end)
end

function TDLib:Notify(text, duration, type)
    local Holder = self.main:FindFirstChild("NotificationHolder") or Instance.new("Frame", self.main)
    Holder.Name = "NotificationHolder"
    Holder.Size = UDim2.new(0, 300, 0, 100)
    Holder.Position = UDim2.new(1, -310, 1, -110)
    Holder.BackgroundTransparency = 1

    local Note = Instance.new("TextLabel", Holder)
    Note.Size = UDim2.new(1, 0, 0, 30)
    Note.Text = text
    Note.TextColor3 = Color3.fromRGB(255, 255, 255)
    Note.Font = Enum.Font.GothamBold
    Note.TextSize = 14

    Note.BackgroundColor3 = ({
        success = Color3.fromRGB(0, 200, 0),
        error = Color3.fromRGB(200, 0, 0),
        warning = Color3.fromRGB(200, 200, 0),
        info = Color3.fromRGB(0, 170, 255)
    })[type or "info"]

    Debris:AddItem(Note, duration or 3)
end

function TDLib:SaveConfig(name)
    if writefile then
        writefile(name .. ".tdcfg", HttpService:JSONEncode(self.config))
    end
end

function TDLib:LoadConfig(name)
    if isfile and isfile(name .. ".tdcfg") then
        self.config = HttpService:JSONDecode(readfile(name .. ".tdcfg"))
    end
end

return TDLib
