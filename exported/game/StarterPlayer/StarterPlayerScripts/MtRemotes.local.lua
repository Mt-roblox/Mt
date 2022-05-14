local remotes = game:GetService("ReplicatedStorage").Mt.Remotes
local plr = game:GetService("Players").LocalPlayer

remotes.ChangeCursor.Event:Connect(function(cursor: string)
	local mouse = plr:GetMouse()
	--print(mouse.Icon)
	mouse.Icon = cursor
end)