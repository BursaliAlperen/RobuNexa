-- Sukuna Moveset for RobuNexa / Hat Reanimation
-- Uses Roblox audio asset IDs; local MP3 files are not needed.
-- Controls: Z = Dismantle, X = Rush, C = Fuuga, V = Laugh.

local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")

local modules = {}

table.insert(modules, function()
    local m = {}
    m.ModuleType = "MOVESET"
    m.Name = "Sukuna"
    m.InternalName = "SUKUNA"
    m.Description = "Sukuna moveset\nZ - Dismantle\nX - Rush\nC - Fuuga\nV - Laugh"
    m.Assets = {}

    local figure
    local bound = false
    local actionNames = {
        "RobuNexa_Sukuna_Dismantle",
        "RobuNexa_Sukuna_Rush",
        "RobuNexa_Sukuna_Fuuga",
        "RobuNexa_Sukuna_Laugh",
    }

    local sounds = {
        Dismantle = "rbxassetid://81148579745420",
        Rush = "rbxassetid://140644642090775",
        Fuuga = "rbxassetid://81784387877244",
        Laugh = "rbxassetid://137836523944133",
    }

    local function playSound(name)
        if not figure or not figure.Parent then return end
        local root = figure:FindFirstChild("HumanoidRootPart") or figure:FindFirstChild("Torso")
        if not root then return end
        local sound = Instance.new("Sound")
        sound.Name = "Sukuna_" .. name
        sound.SoundId = sounds[name]
        sound.Volume = 1
        sound.RollOffMaxDistance = 80
        sound.Parent = root
        sound:Play()
        Debris:AddItem(sound, 12)
    end

    local function bindAction(actionName, soundName, keyCode, title, position)
        ContextActionService:BindAction(actionName, function(_, state)
            if state == Enum.UserInputState.Begin then
                playSound(soundName)
            end
            return Enum.ContextActionResult.Sink
        end, true, keyCode)
        ContextActionService:SetTitle(actionName, title)
        ContextActionService:SetPosition(actionName, position)
    end

    m.Config = function(parent)
    end

    m.Init = function(currentFigure)
        figure = currentFigure
        bindAction(actionNames[1], "Dismantle", Enum.KeyCode.Z, "Dismantle", UDim2.new(1, -180, 1, -230))
        bindAction(actionNames[2], "Rush", Enum.KeyCode.X, "Rush", UDim2.new(1, -120, 1, -230))
        bindAction(actionNames[3], "Fuuga", Enum.KeyCode.C, "Fuuga", UDim2.new(1, -180, 1, -170))
        bindAction(actionNames[4], "Laugh", Enum.KeyCode.V, "Laugh", UDim2.new(1, -120, 1, -170))
        bound = true
    end

    m.Update = function(dt, currentFigure)
        if currentFigure and currentFigure ~= figure then
            figure = currentFigure
        end
    end

    m.Destroy = function()
        if bound then
            for _, actionName in ipairs(actionNames) do
                ContextActionService:UnbindAction(actionName)
            end
            bound = false
        end
        figure = nil
    end

    return m
end)

return modules
