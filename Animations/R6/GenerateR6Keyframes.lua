-- RobuNexa R6 KeyframeSequence generator
-- Run this in Roblox Studio's Command Bar or as a temporary Studio script.
-- It creates original, editable KeyframeSequence instances in ReplicatedStorage.
-- Review them on a classic R6 rig before publishing.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function pose(name, cf, children)
    local p = Instance.new("Pose")
    p.Name = name
    p.CFrame = cf or CFrame.new()
    p.Weight = 1
    for _, child in ipairs(children or {}) do
        child.Parent = p
    end
    return p
end

local function keyframe(time, rootPose)
    local k = Instance.new("Keyframe")
    k.Name = "Keyframe"
    k.Time = time
    rootPose.Parent = k
    return k
end

local function makeSequence(name, looped, priority, frames)
    local seq = Instance.new("KeyframeSequence")
    seq.Name = name
    seq.Loop = looped
    seq.Priority = priority
    for _, frame in ipairs(frames) do
        frame.Parent = seq
    end
    seq.Parent = ReplicatedStorage
    return seq
end

local function radians(deg)
    return math.rad(deg)
end

local function bodyPose(torso, rightArm, leftArm, rightLeg, leftLeg, root)
    return pose("HumanoidRootPart", CFrame.new(0, root or 0, 0), {
        pose("Torso", CFrame.Angles(radians(torso[1]), radians(torso[2]), radians(torso[3])), {
            pose("Right Arm", CFrame.Angles(radians(rightArm[1]), radians(rightArm[2]), radians(rightArm[3]))),
            pose("Left Arm", CFrame.Angles(radians(leftArm[1]), radians(leftArm[2]), radians(leftArm[3]))),
            pose("Right Leg", CFrame.Angles(radians(rightLeg[1]), radians(rightLeg[2]), radians(rightLeg[3]))),
            pose("Left Leg", CFrame.Angles(radians(leftLeg[1]), radians(leftLeg[2]), radians(leftLeg[3]))),
            pose("Head", CFrame.new()),
        }),
    })
end

-- Gentle breathing idle: 2-second seamless loop.
makeSequence("RobuNexa_R6_Idle", true, Enum.AnimationPriority.Idle, {
    keyframe(0, bodyPose({0,0,0}, {0,0,3}, {0,0,-3}, {0,0,0}, {0,0,0}, 0)),
    keyframe(1, bodyPose({-2,0,0}, {0,0,5}, {0,0,-5}, {0,0,0}, {0,0,0}, 0.04)),
    keyframe(2, bodyPose({0,0,0}, {0,0,3}, {0,0,-3}, {0,0,0}, {0,0,0}, 0)),
})

-- Friendly right-hand wave. Review/adjust the shoulder pose in Studio as needed.
makeSequence("RobuNexa_R6_Wave", false, Enum.AnimationPriority.Action, {
    keyframe(0, bodyPose({0,0,0}, {0,0,8}, {0,0,-4}, {0,0,0}, {0,0,0}, 0)),
    keyframe(0.25, bodyPose({0,0,0}, {0,0,8}, {0,0,-4}, {0,0,0}, {0,0,0}, 0)),
    keyframe(0.5, bodyPose({0,0,0}, {-15,0,135}, {0,0,-4}, {0,0,0}, {0,0,0}, 0)),
    keyframe(0.7, bodyPose({0,0,0}, {-15,0,105}, {0,0,-4}, {0,0,0}, {0,0,0}, 0)),
    keyframe(0.9, bodyPose({0,0,0}, {-15,0,135}, {0,0,-4}, {0,0,0}, {0,0,0}, 0)),
    keyframe(1.1, bodyPose({0,0,0}, {-15,0,105}, {0,0,-4}, {0,0,0}, {0,0,0}, 0)),
    keyframe(1.4, bodyPose({0,0,0}, {0,0,8}, {0,0,-4}, {0,0,0}, {0,0,0}, 0)),
})

-- Simple 1-second R6 walk cycle, authored as a starter pose set.
makeSequence("RobuNexa_R6_Walk", true, Enum.AnimationPriority.Movement, {
    keyframe(0, bodyPose({0,0,0}, {0,0,-25}, {0,0,25}, {30,0,0}, {-30,0,0}, 0)),
    keyframe(0.25, bodyPose({0,0,0}, {0,0,-12}, {0,0,12}, {15,0,0}, {-15,0,0}, 0.04)),
    keyframe(0.5, bodyPose({0,0,0}, {0,0,25}, {0,0,-25}, {-30,0,0}, {30,0,0}, 0)),
    keyframe(0.75, bodyPose({0,0,0}, {0,0,12}, {0,0,-12}, {-15,0,0}, {15,0,0}, 0.04)),
    keyframe(1, bodyPose({0,0,0}, {0,0,-25}, {0,0,25}, {30,0,0}, {-30,0,0}, 0)),
})

print("RobuNexa: created 3 R6 KeyframeSequences in ReplicatedStorage.")
print("To export: move each sequence under a rig's AnimSaves, inspect in Animation Editor, then Save to File as .rbxmx.")
