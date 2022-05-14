local MScreen = require(script.Parent.MScreen)
local MWidget = require(script.Parent.Parent.MtWidgets.MWidget)
local MWindowResizeRegion = require(script.Parent.Parent.MtWidgets.MWindowResizeRegion)
local MtEnum  = require(script.Parent.MtEnum)
local _getMouseButton1Pressed = require(script.Parent.MtCoreFunctions)._getMouseButton1Pressed
local _getObjFromId = require(script.Parent.MtCoreFunctions)._getObjFromId
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

function _dictKeys(t)
	local keyset={}
	local n=0

	for k,v in pairs(t) do
		n=n+1
		keyset[n]=k
	end

	return keyset
end
function _keyInTableExists(t,k)
	return table.find(_dictKeys(t),k) ~= nil
end

local MWindowManager = {
	Name = "windowmanager",
	ClassName = "MWindowManager",
	WindowBeingInteracted = false
}

MWindowManager.Init = function(self,plr,parent,_obj)
	local _obj = MScreen.Init(self,plr,parent,_obj)
	
	_obj.WindowMoved = Instance.new("BindableEvent")
	_obj.WindowResized = Instance.new("BindableEvent")
	_obj.WindowInteracted = Instance.new("BindableEvent")
	
	return _obj
end

MWindowManager.InitResize = function(self,window)
	window.ResizeRegions = {}
	window.ResizeRegions.LeftResizeRegion = MWindowResizeRegion:Init(0,0,MtEnum.Side.Left  ,0,1,5 ,0,window)
	window.ResizeRegions.RightResizeRegion= MWindowResizeRegion:Init(1,0,MtEnum.Side.Right ,0,1,-5,0,window)
	window.ResizeRegions.TopResizeRegion  = MWindowResizeRegion:Init(0,0,MtEnum.Side.Top   ,1,0,0 ,5,window)
	window.ResizeRegions.BottomResizeRegion=MWindowResizeRegion:Init(0,1,MtEnum.Side.Bottom,1,0,0,-5,window)

	for i,v in pairs(window.ResizeRegions) do
		v.Resizing.Event:Connect(function(size)
			window.NormalSize = size
			window.Resizing:Fire(size)
			window.Interacted:Fire()
			self.WindowResized:Fire(window.OBJID)
		end)
		
		v.ResizeBegan.Event:Connect(function()
			self:ToggleWindowBeingInteractedState()
			window.WindowInteractionState = MtEnum.WindowInteractionState.Resizing
		end)

		v.ResizeEnded.Event:Connect(function()
			self:ToggleWindowBeingInteractedState()
			window.WindowInteractionState = MtEnum.WindowInteractionState.None
		end)
	end
end

MWindowManager.ToggleWindowBeingInteractedState = function(self)
	self.WindowBeingInteracted = not self.WindowBeingInteracted
	--print(self.WindowBeingInteracted)
end

MWindowManager.InitWindowFunctionality = function(self,window)
	self:InitResize(window)
	
	window.Frame.InputBegan:Connect(function(input)
		if
			self.WindowBeingInteracted or
			window.WindowInteractionState ~= MtEnum.WindowInteractionState.None
		then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self:ToggleWindowBeingInteractedState()
			while _getMouseButton1Pressed(nil,uis:GetMouseButtonsPressed()) and self.WindowBeingInteracted do
				-- (why do i have to do this)
				task.wait()
			end
			window.Interacted:Fire()
			self:ToggleWindowBeingInteractedState()
		end
	end)
	
	window.Handle.Frame.InputBegan:Connect(function(input)
		if
			self.WindowBeingInteracted or
			window.WindowInteractionState ~= MtEnum.WindowInteractionState.None
		then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local clickLocation = uis:GetMouseLocation()
			local windowPosX = window.Frame.Position.X.Offset
			local windowPosY = window.Frame.Position.Y.Offset
			local xoff = clickLocation.X - windowPosX
			local yoff = clickLocation.Y - windowPosY
			
			self:ToggleWindowBeingInteractedState()
			
			window.WindowInteractionState = MtEnum.WindowInteractionState.Moving
			while _getMouseButton1Pressed(nil,uis:GetMouseButtonsPressed()) and self.WindowBeingInteracted do
				local location = uis:GetMouseLocation()

				window.Frame.Position = UDim2.fromOffset(
					location.X-xoff,
					location.Y-yoff
				)

				window.Moving:Fire(window.Frame.Position,location)
				self.WindowMoved:Fire(window.OBJID)
				window.Interacted:Fire()

				task.wait(0.025)
			end

			window.WindowInteractionState = MtEnum.WindowInteractionState.None
			self:ToggleWindowBeingInteractedState()
		end
	end)

	window.Moving.Event:Connect(function(pos)
		window.NormalPosition = pos
	end)

	window.CloseButton.MouseButton1Click:Connect(function()
		window.Interacted:Fire()
		window.Frame:TweenSize(
			UDim2.fromOffset(0,0),
			Enum.EasingDirection.In,
			Enum.EasingStyle.Back,
			0.2,
			true,
			function()
				window:SetHidden(true)
			end
		)
	end)

	window.MaxButton:SetAttribute("MaximizeState",true)
	window.MaxButton.MouseButton1Click:Connect(function()
		window.Interacted:Fire()
		if window.MaxButton:GetAttribute("MaximizeState") then
			window.Frame.Position = UDim2.fromOffset(0,0)
			window.Frame:TweenSize(
				UDim2.fromOffset(
					window.Screen:GetScreenWidth(),
					window.Screen:GetScreenHeight()
				),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Back,
				0.2,
				true
			)
			window.MaxButton.Image = "rbxassetid://9194909505"
		else
			window.Frame:TweenSizeAndPosition(
				window.NormalSize,
				window.NormalPosition,
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Back,
				0.2,
				true
			)
			window.MaxButton.Image = "rbxassetid://9194908204"
		end

		window.MaxButton:SetAttribute(
			"MaximizeState",
			not window.MaxButton:GetAttribute("MaximizeState")
		)
	end)

	window.NormalSize = window.Frame.Size
	window.NormalPosition = window.Frame.Position
	
	window.Interacted.Event:Connect(function()
		self.WindowInteracted:Fire(window.OBJID)
		local i = table.find(self.Widgets,window.OBJID)
		table.remove(self.Widgets,i)
		table.insert(self.Widgets,window.OBJID)
		self:RefreshFocus()
	end)
end

MWindowManager.RefreshFocus = function(self)
	for zi,window in ipairs(self:GetWidgets()) do
		local widget = window.Frame
		widget.ZIndex = zi
		
		for i,guiobj in ipairs(widget:GetDescendants()) do
			if guiobj:IsA("GuiObject") then
				guiobj.ZIndex = zi
			end
		end
		
		local handleC,buttonC = self:ZIndex2Color(zi)
		window.Handle.Frame.BackgroundColor3 = handleC
		window.Stroke.Color = handleC
		window.MaxButton.BackgroundColor3 = buttonC
	end
end

MWindowManager.ZIndex2Color = function(self,zi): Color3
	if zi == #self.Widgets then
		return Color3.fromRGB(0, 90, 235), Color3.fromRGB(95, 140, 240) -- active window handle and button colours
	else
		return Color3.fromRGB(125, 150, 225), Color3.fromRGB(80, 120, 230) -- inactive window handle and button colour
	end
end

MWindowManager.DarkenColor3 = function(self,color,amount): Color3
	return color * 0.5
end

MWindowManager.AddWidget = function(self,widget)
	MScreen.AddWidget(self,widget)
	self:InitWindowFunctionality(widget)
	self:RefreshFocus()
end

MWindowManager = MScreen:Init(nil,{},MWindowManager)

return MWindowManager