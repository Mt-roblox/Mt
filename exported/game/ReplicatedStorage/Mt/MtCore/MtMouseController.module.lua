repeat task.wait() until game:IsLoaded()
local plr = game:GetService("Players").LocalPlayer
if not plr then error("Mt error: MtMouseController must be required by the client!") end
local mouse = plr:GetMouse()

local MtMouseController = {}

local cursor = ""


game:GetService("RunService").RenderStepped:Connect(function()
	mouse.Icon=cursor
end)

function MtMouseController:GetCursor(): string
	return cursor
end

function MtMouseController:ChangeCursor(icon: string)
	icon=icon or ""
	cursor=icon
end

function MtMouseController:ResetCursor()
	MtMouseController:ChangeCursor()
end

return MtMouseController