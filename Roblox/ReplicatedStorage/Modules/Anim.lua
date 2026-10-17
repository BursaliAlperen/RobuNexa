--!strict
local TweenService = game:GetService("TweenService")
local Anim = {}
function Anim.Tween(instance: Instance, info: TweenInfo, props: {[string]: any})
	local tween = TweenService:Create(instance, info, props)
	tween:Play()
	return tween
end
function Anim.Button(button: GuiButton)
	local scale = button:FindFirstChild("Scale") :: UIScale?
	if not scale then
		scale = Instance.new("UIScale")
		scale.Name = "Scale"
		scale.Scale = 1
		scale.Parent = button
	end
	button.MouseEnter:Connect(function() Anim.Tween(scale, TweenInfo.new(.12, Enum.EasingStyle.Back), {Scale=1.04}) end)
	button.MouseLeave:Connect(function() Anim.Tween(scale, TweenInfo.new(.1), {Scale=1}) end)
	button.MouseButton1Down:Connect(function() Anim.Tween(scale, TweenInfo.new(.06), {Scale=.94}) end)
	button.MouseButton1Up:Connect(function() Anim.Tween(scale, TweenInfo.new(.12, Enum.EasingStyle.Back), {Scale=1.04}) end)
end
return Anim
