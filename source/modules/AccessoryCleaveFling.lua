-- AccessoryCleaveFling.lua
-- Works by detecting a touched accessory handle and triggering a cleave + NPC fling.
-- Put this in a Script or use it through loadstring.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local canAttack = true
local cleaveRange = 18
local damage = 35
local flingPower = 60
local animationId = "rbxassetid://YOUR_ANIMATION_ID"

local accessoryHandle = nil

local function findAccessoryHandle()
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("Accessory") then
            local handle = descendant:FindFirstChild("Handle")
            if handle then
                return handle
            end
        end
    end
    return nil
end

local function getTargetNPC()
    local closestModel = nil
    local closestDistance = math.huge
    local forwardVector = rootPart.CFrame.LookVector

    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model ~= character then
            local npcHumanoid = model:FindFirstChildOfClass("Humanoid")
            local npcRoot = model:FindFirstChild("HumanoidRootPart")

            if npcHumanoid and npcRoot and npcHumanoid.Health > 0 then
                local offset = npcRoot.Position - rootPart.Position
                local distance = offset.Magnitude

                if distance <= cleaveRange then
                    local dot = forwardVector:Dot(offset.Unit)
                    if dot > 0.2 then
                        if distance < closestDistance then
                            closestModel = model
                            closestDistance = distance
                        end
                    end
                end
            end
        end
    end

    return closestModel
end

local function spawnCleaveEffect()
    local effect = Instance.new("Part")
    effect.Name = "CleaveFX"
    effect.Size = Vector3.new(1, 1, 1)
    effect.Material = Enum.Material.Neon
    effect.Color = Color3.fromRGB(255, 128, 0)
    effect.Anchored = true
    effect.CanCollide = false
    effect.Transparency = 0.2
    effect.CFrame = rootPart.CFrame * CFrame.new(0, -2, -2.5)
    effect.Parent = workspace

    local tween = TweenService:Create(effect, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(4, 4, 10),
        Transparency = 1,
    })
    tween:Play()
    tween.Completed:Connect(function()
        effect:Destroy()
    end)
end

local function flingTarget(targetModel)
    local targetHumanoid = targetModel:FindFirstChildOfClass("Humanoid")
    local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")

    if not targetHumanoid or not targetRoot or targetHumanoid.Health <= 0 then
        return
    end

    targetHumanoid:TakeDamage(damage)

    local direction = (targetRoot.Position - rootPart.Position)
    local flingVelocity = direction.Unit * flingPower + Vector3.new(0, 16, 0)

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(30000, 30000, 30000)
    bodyVelocity.Velocity = flingVelocity
    bodyVelocity.Parent = targetRoot

    task.delay(0.18, function()
        if bodyVelocity and bodyVelocity.Parent then
            bodyVelocity:Destroy()
        end
    end)
end

local function playCleaveAnimation()
    local anim = Instance.new("Animation")
    anim.AnimationId = animationId
    local track = humanoid:LoadAnimation(anim)

    if track then
        track:Play(0.1, 1, 1.3)
    end
end

local function doCleave()
    if not canAttack then
        return
    end

    canAttack = false

    local target = getTargetNPC()
    if target then
        flingTarget(target)
    end

    playCleaveAnimation()
    spawnCleaveEffect()

    task.delay(0.6, function()
        canAttack = true
    end)
end

local function setupAccessoryTrigger()
    accessoryHandle = findAccessoryHandle()
    if not accessoryHandle then
        return
    end

    accessoryHandle.Touched:Connect(function(hit)
        if not hit or not hit.Parent then
            return
        end

        local model = hit.Parent
        local npcHumanoid = model:FindFirstChildOfClass("Humanoid")

        if npcHumanoid and npcHumanoid.Health > 0 then
            doCleave()
        end
    end)
end

local function onCharacterAdded(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    setupAccessoryTrigger()
end

player.CharacterAdded:Connect(onCharacterAdded)
setupAccessoryTrigger()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.F then
        doCleave()
    end
end)

return {
    DoCleave = doCleave,
    SetAnimationId = function(id)
        animationId = id
    end,
    SetDamage = function(value)
        damage = value
    end,
    SetRange = function(value)
        cleaveRange = value
    end,
    SetFlingPower = function(value)
        flingPower = value
    end,
}
