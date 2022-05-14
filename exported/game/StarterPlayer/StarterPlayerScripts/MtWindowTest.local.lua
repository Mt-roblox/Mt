local repstrg = game:GetService("ReplicatedStorage")
local plr = game:GetService("Players").LocalPlayer

--game:GetService("UserInputService").MouseIconEnabled = false

local MWindow = require(repstrg.Mt.MtWidgets.MWindow)
local MWindowManager = require(repstrg.Mt.MtCore.MWindowManager)

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false)

local screen = MWindowManager:Init()

function putStuffOnWindow(window,stuff:{GuiObject})
	for i,v in ipairs(stuff) do
		v.Parent = window.Content.Frame
	end
end

local window = MWindow:Init(screen)
window:SetName("MainWindow")
window:SetTitle("window")
window.Frame.Position = UDim2.fromOffset(0,0)
putStuffOnWindow(window,script.window:GetChildren())

local dialog = MWindow:Init(screen)
dialog:SetName("Dialog")
dialog:SetTitle("dialog")
putStuffOnWindow(dialog,script.dialog:GetChildren())

local page = MWindow:Init(screen)
page:SetName("Page")
page:SetTitle("page")
putStuffOnWindow(page,script.page:GetChildren())