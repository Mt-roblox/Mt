local repstrg = game:GetService("ReplicatedStorage")

local MWindow = require(repstrg.Mt.MtWidgets.MWindow)
local MScreen = require(repstrg.Mt.MtCore.MScreen)
local tbm = require(repstrg.Mt["3rd-party"].Icon)
local plr = game:GetService("Players").LocalPlayer

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false)

local screen = MScreen:Init()

local window = MWindow:Init(screen)
window:SetName("MainWindow")
window:SetTitle("window")