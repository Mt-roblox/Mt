local MObject = require(script.Parent.MObject)
local MWidget = require(script.Parent.Parent.MtWidgets.MWidget)
local _getObjFromId = require(script.Parent.MtCoreFunctions)._getObjFromId

local MScreen = {
	Name = "screen",
	ClassName = "MScreen",
	Widgets = {},
	ScrX=1,
	ScrY=1,
}

MScreen.Init = function(self,plr,parent,_obj)
	local _obj = MObject.Init(self,parent,_obj)

	_obj.Player = plr or game:GetService("Players").LocalPlayer

	_obj.ScreenGui = Instance.new("ScreenGui")
	_obj.ScreenGui.Name = _obj.Name
	_obj.ScreenGui.Parent = _obj.Player:FindFirstChild("PlayerGui")
	MScreen.SetOverrideTopbar(_obj,true)
	_obj.ScreenGui.ResetOnSpawn = false

	return _obj
end

MScreen.SetName = function(self,name)
	self.ScreenGui.Name = name
	MObject.SetName(self,name)
end

MScreen.AddWidget = function(self,widget)
	widget:SetParent(self)
	table.insert(self.Widgets,widget.OBJID)
	widget.Frame.Parent = self.ScreenGui
end

MScreen.RemoveWidget = function(self,widget)
	widget:SetParent()
	widget.Frame.Parent = nil
end

MScreen.GetWidgets = function(self)
	local widgets = {}

	for i,v in ipairs(self.Widgets) do
		table.insert(widgets,_getObjFromId(nil,v))
	end

	return widgets
end

MScreen.GetScreenSize = function(self)
	return self.ScreenGui.AbsoluteSize
end

MScreen.GetScreenWidth= function(self)
	return self:GetScreenSize().X
end

MScreen.GetScreenHeight=function(self)
	return self:GetScreenSize().Y
end

MScreen.SetOverrideTopbar = function(self,override)
	self.ScreenGui.IgnoreGuiInset = override
end

MScreen = MObject:Init({},MScreen,-1)

return MScreen