local parentGui
if gethui then
    parentGui = gethui()
elseif syn and syn.protect_gui then
    parentGui = Instance.new("ScreenGui")
    syn.protect_gui(parentGui)
    parentGui.Parent = game.CoreGui
elseif game:GetService("CoreGui") then
    parentGui = game:GetService("CoreGui")
else
    parentGui = Players.LocalPlayer:WaitForChild("PlayerGui")
end
