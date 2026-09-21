--!strict
local Theme = {
	Orange = Color3.fromRGB(245,130,30),
	Cream = Color3.fromRGB(250,220,160),
	Dark = Color3.fromRGB(45,45,50),
	White = Color3.fromRGB(255,255,255),
	Muted = Color3.fromRGB(120,112,105),
	Success = Color3.fromRGB(80,205,115),
	Danger = Color3.fromRGB(235,75,70),
	Font = Enum.Font.GothamBold,
	Radius = UDim.new(0,12),
	MinTouch = 48,
}
function Theme.ApplyButton(button: GuiButton)
	button.AutoButtonColor = false
	button.Font = Theme.Font
	button.TextColor3 = Theme.Dark
	button.BackgroundColor3 = Theme.Cream
	button.SizeConstraint = Enum.SizeConstraint.RelativeXY
	local c = button:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	c.CornerRadius = Theme.Radius
	c.Parent = button
end
return Theme
