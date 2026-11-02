--!strict
local AudioKit = {}
function AudioKit.Play(parent: Instance, soundId: string, volume: number?)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume or .5
	sound.RollOffMaxDistance = 80
	sound.Parent = parent
	sound:Play()
	sound.Ended:Connect(function() sound:Destroy() end)
	return sound
end
return AudioKit
