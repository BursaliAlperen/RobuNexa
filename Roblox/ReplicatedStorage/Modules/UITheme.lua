--!strict
-- Stage 2: responsive UI foundation helpers.
-- MainClient owns the actual screen construction; this module centralizes layout constants.
local Theme = {
\tOrange = Color3.fromRGB(245,130,30),
\tCream = Color3.fromRGB(250,220,160),
\tDark = Color3.fromRGB(45,45,50),
\tWhite = Color3.fromRGB(255,255,255),
\tMuted = Color3.fromRGB(120,112,105),
\tSuccess = Color3.fromRGB(80,205,115),
\tDanger = Color3.fromRGB(235,75,70),
\tFont = Enum.Font.GothamBold,
\tRadius = UDim.new(0,12),
\tMinTouch = 48,
\tLandscapeRatio = 16/9,
\tPortraitBreakpoint = 1.45,
}

function Theme.ApplyButton(button: GuiButton)
\tbutton.AutoButtonColor = false
\tbutton.Font = Theme.Font
\tbutton.TextColor3 = Theme.Dark
\tbutton.BackgroundColor3 = Theme.Cream
\tbutton.SizeConstraint = Enum.SizeConstraint.RelativeXY
\tbutton.Active = true
\tlocal c = button:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
\tc.CornerRadius = Theme.Radius
\tc.Parent = button
end

function Theme.IsPortrait(viewport: Vector2): boolean
\treturn viewport.X / math.max(viewport.Y, 1) < Theme.PortraitBreakpoint
end

return Theme