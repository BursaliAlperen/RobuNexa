--[[
    UI System for RobuNexa
    Provides the main interface for moveset selection and ability activation
    Dark theme with koyu gri (dark gray) that transitions to acik gri (light gray) on hover
]]

local UISystem = {}

-- UI Configuration
UISystem.Config = {
    Theme = "Dark",
    PrimaryColor = Color3.fromRGB(30, 30, 30),      -- Koyu gri (dark gray)
    SecondaryColor = Color3.fromRGB(50, 50, 50),   -- Koyu gri darker
    AccentColor = Color3.fromRGB(255, 215, 0),     -- Altın/yellow accent
    TextColor = Color3.fromRGB(255, 255, 255),     -- Beyaz (white)
    HoverColor = Color3.fromRGB(70, 70, 70),       -- Açık gri (light gray) hover
    ActiveColor = Color3.fromRGB(100, 100, 100),   -- Açık gri active
    TextSize = 14,
    ButtonPadding = 8,
    CornerRadius = 4,
}

-- Create the main UI screen gui
function UISystem.CreateMainUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RobuNexaUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 350, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    MainFrame.BackgroundColor3 = UISystem.Config.PrimaryColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, UISystem.Config.CornerRadius)
    corner.Parent = MainFrame
    
    -- Top bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundColor3 = UISystem.Config.SecondaryColor
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, UISystem.Config.CornerRadius)
    topCorner.Parent = TopBar
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "RobuNexa Movesets"
    Title.TextColor3 = UISystem.Config.TextColor
    Title.TextSize = UISystem.Config.TextSize
    Title.Parent = TopBar
    
    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Font = Enum.Font.Gotham
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = UISystem.Config.TextColor
    CloseBtn.TextSize = UISystem.Config.TextSize
    CloseBtn.Parent = TopBar
    
    -- Main content area
    local Content = Instance.new("ScrollingFrame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, -35)
    Content.Position = UDim2.new(0, 0, 0, 30)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 6
    Content.ScrollBarImageColor3 = UISystem.Config.AccentColor
    Content.Parent = MainFrame
    
    -- Example moveset buttons
    local Movesets = {"Aizen", "Gojo", "Sukuna"}
    local ButtonHeight = 50
    local Spacing = 10
    local TotalHeight = #Movesets * (ButtonHeight + Spacing) - Spacing
    
    Content.CanvasSize = UDim2.new(0, 0, 0, TotalHeight + 20)
    
    for i, moveset in ipairs(Movesets) do
        local Button = Instance.new("TextButton")
        Button.Name = moveset .. "Button"
        Button.Size = UDim2.new(1, -20, 0, ButtonHeight)
        Button.Position = UDim2.new(0, 10, 0, (i - 1) * (ButtonHeight + Spacing) + 10)
        Button.BackgroundColor3 = UISystem.Config.PrimaryColor
        Button.BorderSizePixel = 0
        Button.Font = Enum.Font.Gotham
        Button.Text = moveset .. " Moveset"
        Button.TextColor3 = UISystem.Config.TextColor
        Button.TextSize = UISystem.Config.TextSize
        Button.Parent = Content
        
        -- Corner
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, UISystem.Config.CornerRadius)
        btnCorner.Parent = Button
        
        -- Hover effect
        Button.MouseEnter:Connect(function()
            Button.BackgroundColor3 = UISystem.Config.HoverColor
        end)
        
        Button.MouseLeave:Connect(function()
            Button.BackgroundColor3 = UISystem.Config.PrimaryColor
        end)
        
        -- Click effect
        Button.MouseButton1Click:Connect(function()
            print("[UI] Selected: " .. moveset)
            -- Here we would load the moveset
        end)
    end
    
    -- Cooldown display area
    local CooldownFrame = Instance.new("Frame")
    CooldownFrame.Name = "CooldownFrame"
    CooldownFrame.Size = UDim2.new(1, 0, 0, 50)
    CooldownFrame.Position = UDim2.new(0, 0, 1, -50)
    CooldownFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    CooldownFrame.BackgroundTransparency = 0.2
    CooldownFrame.Parent = MainFrame
    
    local coCorner = Instance.new("UICorner")
    coCorner.CornerRadius = UDim.new(0, UISystem.Config.CornerRadius)
    coCorner.Parent = CooldownFrame
    
    -- Return the GUI
    return ScreenGui
end

-- Create a moveset button for a specific character
function UISystem.CreateMovesetButton(parent, characterName, position)
    local Button = Instance.new("TextButton")
    Button.Name = characterName .. "Button"
    Button.Size = UDim2.new(1, -20, 0, 40)
    Button.Position = position
    Button.BackgroundColor3 = UISystem.Config.PrimaryColor
    Button.BorderSizePixel = 0
    Button.Font = Enum.Font.Gotham
    Button.Text = characterName .. " Moveset"
    Button.TextColor3 = UISystem.Config.TextColor
    Button.TextSize = UISystem.Config.TextSize
    Button.Parent = parent
    
    -- Corner
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, UISystem.Config.CornerRadius)
    btnCorner.Parent = Button
    
    -- Hover effect
    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = UISystem.Config.HoverColor
    end)
    
    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = UISystem.Config.PrimaryColor
    end)
    
    -- Click effect
    Button.MouseButton1Click:Connect(function()
        print("[UI] " .. characterName .. " moveset activated")
        -- Trigger moveset loading
    end)
    
    return Button
end

-- Create cooldown indicator
function UISystem.CreateCooldownIndicator(parent, button, duration)
    local startTime = tick()
    local isOnCooldown = false
    
    button.MouseButton1Click:Connect(function()
        if isOnCooldown then
            return
        end
        
        isOnCooldown = true
        print("[UI] " .. button.Name .. " activated! Cooldown: " .. duration .. "s")
        
        -- Visual cooldown effect
        local elapsed = 0
        local cooldownConnection = game:GetService("RunService").RenderStepped:Connect(function()
            elapsed = elapsed + game:GetService("RunService").RenderStepped:Wait()
            local progress = math.min(elapsed / duration, 1)
            
            -- Update button appearance
            button.BackgroundTransparency = 1 - progress
            
            if progress >= 1 then
                isOnCooldown = false
                button.BackgroundTransparency = 0
                button.BackgroundColor3 = UISystem.Config.PrimaryColor
                cooldownConnection:Disconnect()
            end
        end)
    end)
    
    return button
end

-- Return the module
return UISystem