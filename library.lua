-- ObsidianUI Library for Roblox
-- Clean dark theme, tabs, sections, controls

local ObsidianUI = {}

-- Services
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Utility Functions
local function create(className, props)
    local obj = Instance.new(className)
    for k,v in pairs(props) do
        if k == "Parent" then
            obj.Parent = v
        else
            obj[k] = v
        end
    end
    return obj
end

-- Colors (Obsidian-like palette)
local Colors = {
    Background = Color3.fromRGB(30,30,40),
    Panel = Color3.fromRGB(40,40,50),
    Highlight = Color3.fromRGB(70,130,180), -- Steel Blue
    TextPrimary = Color3.fromRGB(220,220,230),
    TextSecondary = Color3.fromRGB(160,160,180),
    ToggleOn = Color3.fromRGB(70,130,180),
    ToggleOff = Color3.fromRGB(90,90,110),
    SliderTrack = Color3.fromRGB(60,60,80),
    SliderFill = Color3.fromRGB(70,130,180),
    DropdownBackground = Color3.fromRGB(40,40,50),
}

-- Main UI Container
function ObsidianUI:Init(title)
    -- Create ScreenGui
    local screenGui = create("ScreenGui", {
        Name = "ObsidianUI",
        Parent = PlayerGui,
        ResetOnSpawn = false,
    })

    -- Main Frame
    local mainFrame = create("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.5, -250, 0.5, -200),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
    })

    -- UI Corner for rounded edges
    create("UICorner", {Parent = mainFrame, CornerRadius = UDim.new(0, 8)})

    -- Title bar
    local titleBar = create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1,0,0,36),
        BackgroundColor3 = Colors.Panel,
    })
    create("UICorner", {Parent = titleBar, CornerRadius = UDim.new(0, 8)})

    local titleLabel = create("TextLabel", {
        Parent = titleBar,
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = title or "Obsidian UI",
        TextColor3 = Colors.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Padding = UDim.new(0, 12),
    })

    -- Tabs container
    local tabsFrame = create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1,0,0,36),
        Position = UDim2.new(0,0,0,36),
        BackgroundColor3 = Colors.Panel,
    })
    create("UICorner", {Parent = tabsFrame, CornerRadius = UDim.new(0, 8)})

    -- Container for tab buttons
    local tabsButtonsFrame = create("Frame", {
        Parent = tabsFrame,
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
    })

    -- Container for tab content
    local contentFrame = create("Frame", {
        Parent = mainFrame,
        Size = UDim2.new(1,0,1,-72),
        Position = UDim2.new(0,0,0,72),
        BackgroundColor3 = Colors.Panel,
        ClipsDescendants = true,
    })
    create("UICorner", {Parent = contentFrame, CornerRadius = UDim.new(0, 8)})

    -- Internal state
    local tabs = {}
    local selectedTab = nil

    -- Function to switch tabs
    local function selectTab(tabName)
        if selectedTab == tabName then return end
        selectedTab = tabName

        for name, data in pairs(tabs) do
            data.Button.BackgroundColor3 = (name == tabName) and Colors.Highlight or Colors.Panel
            data.Content.Visible = (name == tabName)
        end
    end

    -- API: Add Tab
    function self:AddTab(name)
        assert(type(name) == "string", "Tab name must be string")

        -- Create tab button
        local btn = create("TextButton", {
            Parent = tabsButtonsFrame,
            Text = name,
            BackgroundColor3 = Colors.Panel,
            TextColor3 = Colors.TextPrimary,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            AutoButtonColor = false,
            Size = UDim2.new(0, 100, 1, 0),
            LayoutOrder = #tabs + 1,
        })
        create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 6)})

        -- Create content frame for tab
        local tabContent = create("Frame", {
            Parent = contentFrame,
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Visible = false,
        })

        -- Layout inside content
        local layout = create("UIListLayout", {
            Parent = tabContent,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        tabs[name] = {
            Button = btn,
            Content = tabContent,
            Layout = layout,
            Sections = {},
        }

        -- Button click
        btn.MouseButton1Click:Connect(function()
            selectTab(name)
        end)

        -- If first tab, select it
        if #tabs == 0 then
            selectTab(name)
        end

        -- Return tab object for adding sections and controls
        local tabAPI = {}

        -- Add Section
        function tabAPI:AddSection(title)
            assert(type(title) == "string", "Section title must be string")

            local sectionFrame = create("Frame", {
                Parent = tabContent,
                Size = UDim2.new(1,0,0,0),
                BackgroundColor3 = Colors.Panel,
                LayoutOrder = #tabs[name].Sections + 1,
                AutomaticSize = Enum.AutomaticSize.Y,
            })
            create("UICorner", {Parent = sectionFrame, CornerRadius = UDim.new(0, 6)})

            local secTitle = create("TextLabel", {
                Parent = sectionFrame,
                Text = title,
                Size = UDim2.new(1, -12, 0, 24),
                Position = UDim2.new(0, 6, 0, 6),
                BackgroundTransparency = 1,
                TextColor3 = Colors.TextSecondary,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            local controlsFrame = create("Frame", {
                Parent = sectionFrame,
                Size = UDim2.new(1, -12, 0, 0),
                Position = UDim2.new(0, 6, 0, 36),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = 2,
            })

            local controlsLayout = create("UIListLayout", {
                Parent = controlsFrame,
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })

            local sectionAPI = {}

            -- Add Toggle
            function sectionAPI:AddToggle(opts)
                local toggleFrame = create("Frame", {
                    Parent = controlsFrame,
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    LayoutOrder = #controlsLayout:GetChildren() - 1,
                })

                local toggleLabel = create("TextLabel", {
                    Parent = toggleFrame,
                    Text = opts.text or "Toggle",
                    Size = UDim2.new(0.75, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.TextPrimary,
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local toggleBtn = create("TextButton", {
                    Parent = toggleFrame,
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -45, 0, 5),
                    BackgroundColor3 = opts.default and Colors.ToggleOn or Colors.ToggleOff,
                    AutoButtonColor = false,
                    Text = "",
                })
                create("UICorner", {Parent = toggleBtn, CornerRadius = UDim.new(0, 10)})

                local toggled = opts.default or false

                local function updateToggle(state)
                    toggled = state
                    toggleBtn.BackgroundColor3 = toggled and Colors.ToggleOn or Colors.ToggleOff
                    if opts.callback then
                        opts.callback(toggled)
                    end
                end

                toggleBtn.MouseButton1Click:Connect(function()
                    updateToggle(not toggled)
                end)

                -- Return control API
                return {
                    Set = updateToggle,
                    Get = function() return toggled end,
                }
            end

            -- Add Button
            function sectionAPI:AddButton(opts)
                local btn = create("TextButton", {
                    Parent = controlsFrame,
                    Text = opts.text or "Button",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Colors.Highlight,
                    TextColor3 = Colors.TextPrimary,
                    Font = Enum.Font.GothamBold,
                    TextSize = 16,
                    AutoButtonColor = true,
                    LayoutOrder = #controlsLayout:GetChildren() - 1,
                })
                create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 6)})

                if opts.callback then
                    btn.MouseButton1Click:Connect(opts.callback)
                end

                return btn
            end

            -- Add Slider (0 to max, with steps)
            function sectionAPI:AddSlider(opts)
                local sliderFrame = create("Frame", {
                    Parent = controlsFrame,
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundTransparency = 1,
                    LayoutOrder = #controlsLayout:GetChildren() - 1,
                })

                local label = create("TextLabel", {
                    Parent = sliderFrame,
                    Text = opts.text or "Slider",
                    Size = UDim2.new(0.5, 0, 0, 20),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.TextPrimary,
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local valueLabel = create("TextLabel", {
                    Parent = sliderFrame,
                    Text = tostring(opts.default or 0),
                    Size = UDim2.new(0.5, -10, 0, 20),
                    Position = UDim2.new(0.5, 10, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.TextSecondary,
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })

                local sliderBar = create("Frame", {
                    Parent = sliderFrame,
                    Size = UDim2.new(1, 0, 0, 10),
                    Position = UDim2.new(0, 0, 0, 30),
                    BackgroundColor3 = Colors.SliderTrack,
                })
                create("UICorner", {Parent = sliderBar, CornerRadius = UDim.new(0, 5)})

                local fillBar = create("Frame", {
                    Parent = sliderBar,
                    Size = UDim2.new(((opts.default or 0) - (opts.min or 0)) / ((opts.max or 100) - (opts.min or 0)), 0, 1, 0),
                    BackgroundColor3 = Colors.SliderFill,
                })
                create("UICorner", {Parent = fillBar, CornerRadius = UDim.new(0, 5)})

                local dragging = false
                local minValue = opts.min or 0
                local maxValue = opts.max or 100
                local step = opts.step or 1
                local value = opts.default or minValue

                local function updateValue(inputPosX)
                    local relativeX = math.clamp(inputPosX - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
                    local percent = relativeX / sliderBar.AbsoluteSize.X
                    local rawValue = minValue + (maxValue - minValue) * percent
                    local steppedValue = math.floor(rawValue / step + 0.5) * step
                    steppedValue = math.clamp(steppedValue, minValue, maxValue)
                    value = steppedValue
                    fillBar.Size = UDim2.new((value - minValue) / (maxValue - minValue), 0, 1, 0)
                    valueLabel.Text = tostring(value)
                    if opts.callback then
                        opts.callback(value)
                    end
                end

                sliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateValue(input.Position.X)
                    end
                end)
                sliderBar.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                sliderBar.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateValue(input.Position.X)
                    end
                end)

                return {
                    Get = function() return value end,
                    Set = function(v)
                        value = math.clamp(v, minValue, maxValue)
                        fillBar.Size = UDim2.new((value - minValue) / (maxValue - minValue), 0, 1, 0)
                        valueLabel.Text = tostring(value)
                        if opts.callback then
                            opts.callback(value)
                        end
                    end,
                }
            end

            -- Add Dropdown
            function sectionAPI:AddDropdown(opts)
                local dropdownFrame = create("Frame", {
                    Parent = controlsFrame,
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    LayoutOrder = #controlsLayout:GetChildren() - 1,
                })

                local label = create("TextLabel", {
                    Parent = dropdownFrame,
                    Text = opts.text or "Dropdown",
                    Size = UDim2.new(0.5, 0, 1, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.TextPrimary,
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local selectedValueLabel = create("TextLabel", {
                    Parent = dropdownFrame,
                    Text = opts.default or "Select",
                    Size = UDim2.new(0.5, -20, 1, 0),
                    Position = UDim2.new(0.5, 10, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Colors.TextSecondary,
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })

                local dropBtn = create("TextButton", {
                    Parent = dropdownFrame,
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundColor3 = Colors.Panel,
                    Text = "▼",
                    TextColor3 = Colors.TextSecondary,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    AutoButtonColor = true,
                })
                create("UICorner", {Parent = dropBtn, CornerRadius = UDim.new(0, 4)})

                -- Dropdown list container
                local listFrame = create("Frame", {
                    Parent = dropdownFrame,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 2),
                    BackgroundColor3 = Colors.DropdownBackground,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 10,
                })
                create("UICorner", {Parent = listFrame, CornerRadius = UDim.new(0, 6)})

                local listLayout = create("UIListLayout", {
                    Parent = listFrame,
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                local expanded = false
                local items = opts.items or {}

                local function closeDropdown()
                    expanded = false
                    listFrame.Visible = false
                    listFrame:TweenSize(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                end
                local function openDropdown()
                    expanded = true
                    listFrame.Visible = true
                    local height = #items * 28
                    listFrame:TweenSize(UDim2.new(1,0,0,height), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                end

                dropBtn.MouseButton1Click:Connect(function()
                    if expanded then
                        closeDropdown()
                    else
                        openDropdown()
                    end
                end)

                local selectedIndex = 1
                for i, v in ipairs(items) do
                    local itemBtn = create("TextButton", {
                        Parent = listFrame,
                        Text = v,
                        Size = UDim2.new(1, 0, 0, 28),
                        BackgroundColor3 = Colors.Panel,
                        TextColor3 = Colors.TextPrimary,
                        Font = Enum.Font.Gotham,
                        TextSize = 14,
                        AutoButtonColor = true,
                        LayoutOrder = i,
                    })
                    create("UICorner", {Parent = itemBtn, CornerRadius = UDim.new(0, 4)})

                    itemBtn.MouseButton1Click:Connect(function()
                        selectedValueLabel.Text = v
                        selectedIndex = i
                        if opts.callback then
                            opts.callback(v, i)
                        end
                        closeDropdown()
                    end)
                end

                return {
                    Get = function() return selectedValueLabel.Text, selectedIndex end,
                    Set = function(val)
                        for i,v in ipairs(items) do
                            if v == val then
                                selectedValueLabel.Text = val
                                selectedIndex = i
                                if opts.callback then
                                    opts.callback(val, i)
                                end
                                return
                            end
                        end
                    end,
                }
            end

            return sectionAPI
        end

        return tabAPI
    end

    -- Return main API
    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
    self.TabsFrame = tabsFrame
    self.ContentFrame = contentFrame

    return self
end

return ObsidianUI
