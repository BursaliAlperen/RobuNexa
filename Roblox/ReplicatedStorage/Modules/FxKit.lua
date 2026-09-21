--!strict
local TweenService = game:GetService("TweenService")
local FxKit = {}
function FxKit.Punch(camera: Camera)
	local base = camera.FieldOfView
	local up = TweenService:Create(camera, TweenInfo.new(.06), {FieldOfView=base+5})
	up:Play()
	up.Completed:Connect(function() TweenService:Create(camera, TweenInfo.new(.12), {FieldOfView=base}):Play() end)
end
function FxKit.Popup(gui: ScreenGui, text: string, position: UDim2, color: Color3?)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency=1
	label.Text=text
	label.TextColor3=color or Color3.new(1,1,1)
	label.TextStrokeTransparency=.2
	label.Font=Enum.Font.GothamBlack
	label.TextScaled=true
	label.Size=UDim2.fromOffset(180,48)
	label.Position=position
	label.Parent=gui
	local tween=TweenService:Create(label,TweenInfo.new(.45,Enum.EasingStyle.Back),{Position=position+UDim2.fromOffset(0,-45),TextTransparency=1,TextStrokeTransparency=1})
	tween:Play(); tween.Completed:Connect(function() label:Destroy() end)
end
function FxKit.Burst(parent: Instance, color: Color3?)
	local p=Instance.new("ParticleEmitter")
	p.Rate=0; p.Lifetime=NumberRange.new(.25,.45); p.Speed=NumberRange.new(5,10); p.SpreadAngle=Vector2.new(360,360)
	p.Color=ColorSequence.new(color or Color3.new(1,1,1)); p.LightEmission=.6; p.Parent=parent
	p:Emit(8); task.delay(.6,function() if p then p:Destroy() end end)
end
return FxKit
