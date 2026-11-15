-- RobuNexa / NAM - Aizen moveset (AAA Illusion + Cero + Fling)
-- Mutlaka Illüzyon odaklı, Aizen'in tüm yeteneklerini kapsar.
-- Kullanım: NAM loader'ına dahil edilir, m.Assets ile CDN'den yüklenir.

local modules = {}
local function AddModule(fn) table.insert(modules, fn) end

AddModule(function()
    local m = {}
    m.ModuleType = "MOVESET"
    m.Name = "Aizen"
    m.Description = "AAA Aizen moveset: Kyoka Suigetsu (Illusion), Cero, Cero Oscuro, Hierro Defense, Shunpo, Kyoka-Suigetsu Ultimate."
    
    -- CDN asset map (AnimLib .anim + .mp3)
    m.Assets = {
        "Aizen/AizenIdle.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/AizenIdle.anim",
        "Aizen/AizenWalk.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/AizenWalk.anim",
        "Aizen/AizenJump.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/AizenJump.anim",
        "Aizen/AizenFall.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/AizenFall.anim",
        "Aizen/Cero.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/Cero.anim",
        "Aizen/CeroOscuro.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/CeroOscuro.anim",
        "Aizen/Hierro.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/Hierro.anim",
        "Aizen/Shunpo.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/Shunpo.anim",
        "Aizen/KyokaSuigetsu.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/KyokaSuigetsu.anim",
        "Aizen/KyokaSuigetsuUltimate.anim@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/animations/Aizen/KyokaSuigetsuUltimate.anim",
        "sounds/aizen-cero.mp3@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/sounds/aizen-cero.mp3",
        "sounds/aizen-shunpo.mp3@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/sounds/aizen-shunpo.mp3",
        "sounds/aizen-illusion.mp3@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/sounds/aizen-illusion.mp3",
        "sounds/aizen-hierro.mp3@https://raw.githubusercontent.com/BursaliAlperen/RobuNexa/main/content/sounds/aizen-hierro.mp3",
        "source/fling_system.lua@source/fling_system.lua",
        "source/ui_system.lua@source/ui_system.lua",
        "source/passive_features.lua@source/passive_features.lua",
    }
    
    local animationFiles = {
        Idle   = "Aizen/AizenIdle.anim",
        Walk   = "Aizen/AizenWalk.anim",
        Jump   = "Aizen/AizenJump.anim",
        Fall   = "Aizen/AizenFall.anim",
        Cero   = "Aizen/Cero.anim",
        CeroOscuro = "Aizen/CeroOscuro.anim",
        Hierro = "Aizen/Hierro.anim",
        Shunpo = "Aizen/Shunpo.anim",
        KyokaSuigetsu = "Aizen/KyokaSuigetsu.anim",
        KyokaSuigetsuUltimate = "Aizen/KyokaSuigetsuUltimate.anim",
    }
    
    -- Import systems
    local FlingSystem = require(script.Parent.Parent.Parent.Source.FlingSystem)
    local UI = require(script.Parent.Parent.Parent.Source.UI)
    local PassiveFeatures = require(script.Parent.Parent.Parent.Source.PassiveFeatures)
    
    -- Initialize passive features
    PassiveFeatures.Initialize()
    
    -- Initialize UI
    UI.CreateAizenUI()
    
    -- Skill functions with passive features and real fling
    local function executeCero(target)
        -- Cero attack with passive cooldown reduction
        if FlingSystem.IsOnCooldown(target) then
            Util.Notify("Cooldown active! Wait " .. math.ceil(FlingSystem.GetRemainingCooldown(target)) .. "s (reduced by passive)")
        end
        
        -- Use real fling system
        FlingSystem.Fling(target, "Cero")
        Util.Notify("Cero executed!")
    end
    
    local function executeShunpo(target)
        -- Shunpo dash with passive cooldown reduction
        if FlingSystem.IsOnCooldown(target) then
            Util.Notify("Cooldown active! Wait " .. math.ceil(FlingSystem.GetRemainingCooldown(target)) .. "s (reduced by passive)")
        end
        
        FlingSystem.Fling(target, "Shunpo")
        Util.Notify("Shunpo executed!")
    end
    
    local function executeIllusion(target)
        -- Illusion with passive effects
        if FlingSystem.IsOnCooldown(target) then
            Util.Notify("Cooldown active! Wait " .. math.ceil(FlingSystem.GetRemainingCooldown(target)) .. "s (reduced by passive)")
        end
        
        local function createClone()
            local clone = target:Clone()
            clone.Parent = workspace
            clone:SetPrimaryPartCFrame(target:GetPrimaryPartCFrame())
            clone.Transparency = 0.5
            clone.Name = "AizenIllusion"
            
            -- Add passive visual effect
            PassiveFeatures.CreateSkillEffect("Illusion", clone)
            
            -- Remove after duration
            task.delay(5, function()
                if clone.Parent then
                    clone:Destroy()
                end
            end)
        end
        
        for i = 1, 3 do
            task.delay(i * 0.5, createClone)
        end
        
        FlingSystem.Fling(target, "Illusion")
        Util.Notify("Illusion created!")
    end
    
    local function executeHierro(target)
        -- Hierro defense with passive effects
        if FlingSystem.IsOnCooldown(target) then
            Util.Notify("Cooldown active! Wait " .. math.ceil(FlingSystem.GetRemainingCooldown(target)) .. "s (reduced by passive)")
        end
        
        -- TODO: Implement actual defense logic
        FlingSystem.Fling(target, "Hierro")
        Util.Notify("Hierro activated!")
    end
    
    local function executeCeroOscuro(target)
        -- Enhanced Cero attack with passive effects
        if FlingSystem.IsOnCooldown(target) then
            Util.Notify("Cooldown active! Wait " .. math.ceil(FlingSystem.GetRemainingCooldown(target)) .. "s (reduced by passive)")
        end
        
        FlingSystem.Fling(target, "CeroOscuro")
        Util.Notify("Cero Oscuro executed!")
    end
    
    local function executeKyokaSuigetsu(target)
        -- Kyoka Suigetsu ultimate with passive effects
        if FlingSystem.IsOnCooldown(target) then
            Util.Notify("Cooldown active! Wait " .. math.ceil(FlingSystem.GetRemainingCooldown(target)) .. "s (reduced by passive)")
        end
        
        -- TODO: Implement actual Kyoka Suigetsu logic
        FlingSystem.Fling(target, "KyokaSuigetsu")
        Util.Notify("Kyoka Suigetsu executed!")
    end
    
    local function executeUltimate(target)
        -- Ultimate skill with passive effects
        if FlingSystem.IsOnCooldown(target) then
            Util.Notify("Cooldown active! Wait " .. math.ceil(FlingSystem.GetRemainingCooldown(target)) .. "s (reduced by passive)")
        end
        
        -- TODO: Implement actual ultimate logic
        FlingSystem.Fling(target, "Ultimate")
        Util.Notify("Ultimate executed!")
    end
    
    -- Update UI buttons with actual callbacks
    local skillButtons = CoreGui:FindFirstChildrenWhichAreA("TextButton")
    for _, button in skillButtons do
        local skillName = button.Name
        if skillName == "Aizen_Cero_ToolButton" then
            button.MouseButton1Click:Connect(function()
                if FlingSystem.IsOnCooldown(target) then
                    Util.Notify("Cooldown active! Wait " .. math.ceil(FlingSystem.GetRemainingCooldown(target)) .. "s")
                    return
                end
                executeCero(target)
            end)
        elseif skillName == "Aizen_Shunpo_ToolButton" then
            button.MouseButton1Click:Connect(function()
                if FlingSystem.IsOnCooldown(target) then
                    Util.Notify("Cooldown active! Wait " .. math.ceil(FlingSystem.GetRemainingCooldown(target)) .. "s")
                    return
                end
                executeShunpo(target)
            end)
        elseif skillName == "Aizen_Illusion_ToolButton" then
            button.MouseButton1Click:Connect(function()
                if FlingSystem.IsOnCooldown(target) then
                    Util.Notify("Cooldown active! Wait " .. math.ceil(FlingSystem.GetRemainingCooldown(target)) .. "s")
                    return
                end
                executeIllusion(target)
            end)
        elseif skillName == "Aizen_Herro_ToolButton" then
            button.MouseButton1Click:Connect(function()
                if FlingSystem.IsOnCooldown(target) then
                    Util.Notify("Cooldown active! Wait " .. math.ceil(FlingSystem.GetRemainingCooldown(target)) .. "s")
                    return
                end
                executeHierro(target)
            end)
        elseif skillName == "Aizen_CeroOscuro_ToolButton" then
            button.MouseButton1Click:Connect(function()
                if FlingSystem.IsOnCooldown(target) then
                    Util.Notify("Cooldown active! Wait " .. math.ceil(FlingSystem.GetRemainingCooldown(target)) .. "s")
                    return
                end
                executeCeroOscuro(target)
            end)
        elseif skillName == "Aizen_KyokaSuigetsu_ToolButton" then
            button.MouseButton1Click:Connect(function()
                if FlingSystem.IsOnCooldown(target) then
                    Util.Notify("Cooldown active! Wait " .. math.ceil(FlingSystem.GetRemainingCooldown(target)) .. "s")
                    return
                end
                executeKyokaSuigetsu(target)
            end)
        elseif skillName == "Aizen_Ultimate_ToolButton" then
            button.MouseButton1Click:Connect(function()
                if FlingSystem.IsOnCooldown(target) then
                    Util.Notify("Cooldown active! Wait " .. math.ceil(FlingSystem.GetRemainingCooldown(target)) .. "s")
                    return
                end
                executeUltimate(target)
            end)
        end
    end
    
    return m
end)