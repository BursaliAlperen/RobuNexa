-- UI System for RobuNexa - AAA Quality GUI with Cooldown Management
-- Implements LUA CODING ENGINE UI with enhanced visual effects and skill management

local UI = {}

-- Create main UI panel with enhanced styling
function UI.CreateMainPanel()
    local panel = Instance.new("Frame")
    panel.Name = "LuaCodingEngine_UI"
    panel.Size = UDim2.new(0, 350, 0, 450)
    panel.Position = UDim2.new(0.5, -175, 0.5, -225)
    panel.BackgroundTransparency = 0.2
    panel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    panel.BorderColor3 = Color3.fromRGB(100, 100, 255)
    panel.BorderSizePixel = 2
    panel.Parent = CoreGui
    
    -- Add blur effect
    local blur = Instance.new("BlurEffect")
    blur.Size = 10
    blur.Parent = panel
    
    return panel
end

-- Create enhanced skill button with visual effects
function UI.CreateSkillButton(name, icon, callback, cooldown, skillName)
    local button = Instance.new("TextButton")
    button.Name = name .. "_ToolButton"
    button.Size = UDim2.new(0, 90, 0, 40)
    button.Position = UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.Text = icon .. "\n" .. name
    button.Parent = CoreGui
    
    -- Add glow effect
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.2, 0, 1.2, 0)
    glow.Position = UDim2.new(-0.1, 0, -0.1, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://1362239204" -- Energy glow
    glow.ImageColor3 = Color3.fromRGB(100, 100, 255)
    glow.ImageTransparency = 0.5
    glow.ZIndex = -1
    glow.Parent = button
    
    -- Cooldown state
    local isCooldown = false
    local cooldownTime = cooldown or 1
    
    button.MouseButton1Click:Connect(function()
        if isCooldown then
            Util.Notify("Skill on cooldown! Wait " .. math.ceil(cooldownTime) .. "s")
            return
        end
        
        isCooldown = true
        callback(skillName)
        
        -- Enhanced cooldown indicator
        local cooldownLabel = Instance.new("TextLabel")
        cooldownLabel.Name = "CooldownLabel"
        cooldownLabel.Size = UDim2.new(1, 0, 1, 0)
        cooldownLabel.BackgroundTransparency = 0.5
        cooldownLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        cooldownLabel.Text = ""
        cooldownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        cooldownLabel.Font = Enum.Font.SourceSansBold
        cooldownLabel.TextSize = 12
        cooldownLabel.Visible = true
        cooldownLabel.Parent = button
        
        -- Fill cooldown bar
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(1, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        fill.BackgroundTransparency = 0
        fill.ZIndex = -1
        fill.Parent = cooldownLabel
        
        -- Animate cooldown fill
        local startTime = tick()
        local function updateCooldown()
            if not isCooldown then return end
            local elapsed = tick() - startTime
            local progress = 1 - (elapsed / cooldownTime)
            
            if progress <= 0 then
                fill.Size = UDim2.new(0, 0, 1, 0)
                isCooldown = false
                cooldownLabel.Visible = false
                fill:Destroy()
                cooldownLabel:Destroy()
                return
            end
            
            fill.Size = UDim2.new(progress, 0, 1, 0)
        end
        
        spawn(function()
            while isCooldown do
                updateCooldown()
                task.wait(0.1)
            end
        end)
    end)
    
    return button
end

-- Create enhanced UI with all Aizen skills
function UI.CreateAizenUI()
    local panel = UI.CreateMainPanel()
    
    -- Create title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Aizen - AAA Moveset"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 20
    titleLabel.Parent = panel
    
    -- Create skill buttons in grid layout
    local skills = {
        {"Aizen Cero", "⚡", 1.0, "Cero"},
        {"Aizen Shunpo", "🏃", 2.0, "Shunpo"},
        {"Aizen Illusion", "👻", 5.0, "Illusion"},
        {"Aizen Hierro", "🛡️", 10.0, "Hierro"},
        {"Aizen Cero Oscuro", "🔥", 15.0, "CeroOscuro"},
        {"Aizen Kyoka Suigetsu", "🌀", 30.0, "KyokaSuigetsu"},
        {"Aizen Ultimate", "💥", 60.0, "Ultimate"},
    }
    
    local buttonGrid = {}
    local spacing = 10
    local buttonSize = 90
    local rowHeight = 40
    
    for i, skill in ipairs(skills) do
        local row = math.floor((i - 1) / 2)
        local col = (i - 1) % 2
        
        local button = UI.CreateSkillButton(skill[1], skill[2], function(skillName) 
            -- This will be overridden by the actual callback
        end, skill[3], skill[4])
        
        button.Position = UDim2.new(
            0, col * (buttonSize + spacing) + spacing,
            0, row * (rowHeight + spacing) + 50
        )
        
        table.insert(buttonGrid, {button = button, skill = skill[4]})
    end
    
    -- Add status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 1, -40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Ready to fight!"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextSize = 14
    statusLabel.Parent = panel
    
    return panel
end

-- Update skill button with actual callback
function UI.UpdateSkillButton(button, skillName, callback)
    button.MouseButton1Click:Connect(function()
        -- Check if button is in cooldown
        local cooldownLabel = button:FindFirstChild("CooldownLabel")
        if cooldownLabel and cooldownLabel.Visible then
            Util.Notify("Skill on cooldown!")
            return
        end
        
        -- Execute callback
        callback(skillName)
    end)
end

return UI