local repstrg = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

local plr = game:GetService("Players").LocalPlayer or nil

local MWidget = require(repstrg.Mt.MtWidgets.MWidget)
local MtEnum  = require(repstrg.Mt.MtCore.MtEnum)
local MWindowResizeRegion = require(repstrg.Mt.MtWidgets.MWindowResizeRegion)

local _getMouseButton1Pressed = require(repstrg.Mt.MtCore)._getMouseButton1Pressed

local MWindow = {
	ClassName = "MWindow", -- See Mt.MtCore.MObject
	Name = "window",       -- ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^

	Title = "window", -- Window title (string) (Read-only (Use SetTitle())
	
	WindowInteractionState = MtEnum.WindowInteractionState.None -- Window interaction state (string (enum)) (Read-only)
}

MWindow.Init = function(self,screen,_obj)
	local _obj = MWidget.Init(self,screen,_obj)

	_obj.Interacted=Instance.new("BindableEvent")
	_obj.Resizing = Instance.new("BindableEvent")
	_obj.Moving   = Instance.new("BindableEvent")
	
	_obj.Screen = screen
	MWindow.InitGui(_obj)
	_obj.Screen:AddWidget(_obj)
	
	--MWindow.InitWindowFunctionality(_obj)
	
	return _obj
end

MWindow.SetPositionFromScale = function(self,x,y)
	local screenSize = self.Screen:GetScreenSize()
	self.Frame.Position = UDim2.fromOffset(
		x*screenSize.X,
		y*screenSize.Y
	)
end

MWindow.SetSizeFromScale = function(self,x,y)
	local screenSize = self.Screen:GetScreenSize()
	self.Frame.Size = UDim2.fromOffset(
		x*screenSize.X,
		y*screenSize.Y
	)
end

MWindow.InitGui = function(self)
	self:SetPositionFromScale(0.5,0.5)
	self:SetSizeFromScale(
		self.Frame.Size.X.Scale,
		self.Frame.Size.Y.Scale
	)

	local uicorner = Instance.new("UICorner")
	uicorner.Parent = self.Frame

	self.Stroke = Instance.new("UIStroke")
	self.Stroke.Parent = self.Frame
	self.Stroke.Color = script.handle.BackgroundColor3
	self.Stroke.Thickness = 2.75

	local handle = script.handle:Clone()
	self.Handle = MWidget:Init(self)
	self.Handle.SizeConstraint.Parent = handle
	self.Handle.Frame = handle
	
	self.TitleLabel = handle.title
	self.MaxButton = handle.buttons.maximize
	self.CloseButton = handle.buttons.close
	self.Layout = handle.UIListLayout
	self.Padding = handle.UIPadding
	handle.Parent = self.Frame
	
	self.Content = MWidget:Init(self)
	self.Content.Frame = script.content:Clone()
	self.Content.Frame.Parent = self.Frame
	rs.RenderStepped:Connect(function()
		self.Content.Frame.Size = UDim2.new(
			1,0,
			0,self.Frame.AbsoluteSize.Y-25
		)
	end)

	self:SetMinimumSize(Vector2.new(150,handle.Size.Y.Offset))
end

MWindow.InitResize = function(self)
	self.ResizeRegions = {}
	self.ResizeRegions.LeftResizeRegion = MWindowResizeRegion:Init(0,0,MtEnum.Side.Left  ,0,1,5 ,0,self)
	self.ResizeRegions.RightResizeRegion= MWindowResizeRegion:Init(1,0,MtEnum.Side.Right ,0,1,-5,0,self)
	self.ResizeRegions.TopResizeRegion  = MWindowResizeRegion:Init(0,0,MtEnum.Side.Top   ,1,0,0 ,5,self)
	self.ResizeRegions.BottomResizeRegion=MWindowResizeRegion:Init(0,1,MtEnum.Side.Bottom,1,0,0,-5,self)

	for i,v in pairs(self.ResizeRegions) do
		v.Resizing.Event:Connect(function(size)
			self.NormalSize = size
			self.WindowInteractionState = MtEnum.WindowInteractionState.Resizing
			self.Resizing:Fire(size)
		end)
		
		v.ResizeEnded.Event:Connect(function()
			self.WindowInteractionState = MtEnum.WindowInteractionState.None
		end)
	end
end

--[[
MWindow.IsAnyOtherWindowBeingInteracted = function(self)
	for i,v in ipairs(Windows) do
		if v ~= self then
			if v.WindowInteractionState ~= MtEnum.WindowInteractionState.None then
				return true
			end
		end
	end
	return false
end

MWindow.RefreshWindowZIndex = function()
	for i,v in ipairs(Windows) do
		v.Frame.ZIndex = i
		
		for di,dv in ipairs(v.Frame:GetDescendants()) do
			if dv:IsA("GuiObject") then
				dv.ZIndex = i
			end
		end
		
		if i == #Windows then	
			v.Frame.handle.BackgroundColor3 = Color3.fromRGB(0,120,180)
			v.Frame:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(0,120,180)
		else
			v.Frame.handle.BackgroundColor3 = Color3.fromRGB(105, 150, 255)
			v.Frame:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(105, 150, 255)
		end
	end
end
]]

MWindow.InitWindowFunctionality = function(self)
	self:InitResize()
	
	--[[
	self.Frame.InputBegan:Connect(function(input)
		if self:IsAnyOtherWindowBeingInteracted() then
			return
		end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			
			self:FireEvent(self.Interacted)
			
			local i = self.Frame.ZIndex
			table.move(Windows,i,i,#Windows+1)
			self:RefreshWindowZIndex()
			table.remove(Windows,#Windows)
		end
	end)
	--]]

	self.Handle.InputBegan:Connect(function(input)
		if
			self.Frame:FindFirstChild("resizeRegions").Dragging.Value or
			self:IsAnyOtherWindowBeingInteracted()
		then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			
			local clickLocation = uis:GetMouseLocation()
			local windowPosX = self.Frame.Position.X.Offset
			local windowPosY = self.Frame.Position.Y.Offset
			local xoff = clickLocation.X - windowPosX
			local yoff = clickLocation.Y - windowPosY

			while _getMouseButton1Pressed(nil,uis:GetMouseButtonsPressed()) do
				local location = uis:GetMouseLocation()

				self.Frame.Position = UDim2.fromOffset(
					location.X-xoff,
					location.Y-yoff
				)
				
				self.WindowInteractionState = MtEnum.WindowInteractionState.Moving

				self.Moving:Fire(self.Frame.Position,location)

				task.wait(0.025)
			end
			
			self.WindowInteractionState = MtEnum.WindowInteractionState.None
		end
	end)

	self.Moving.Event:Connect(function(pos)
		self.NormalPosition = pos
	end)

	self.CloseButton.MouseButton1Click:Connect(function()
		self.Frame:TweenSize(
			UDim2.fromOffset(0,0),
			Enum.EasingDirection.In,
			Enum.EasingStyle.Back,
			0.2,
			true,
			function()
				self:SetHidden(true)
			end
		)
	end)

	self.MaxButton:SetAttribute("MaximizeState",true)
	self.MaxButton.MouseButton1Click:Connect(function()
		if self.MaxButton:GetAttribute("MaximizeState") then
			self.Frame.Position = UDim2.fromOffset(0,0)
			self.Frame:TweenSize(
				UDim2.fromOffset(
					self.Screen:GetScreenWidth(),
					self.Screen:GetScreenHeight()
				),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Back,
				0.2,
				true
			)
			self.MaxButton.Image = "rbxassetid://9194909505"
		else
			self.Frame:TweenSizeAndPosition(
				self.NormalSize,
				self.NormalPosition,
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Back,
				0.2,
				true
			)
			self.MaxButton.Image = "rbxassetid://9194908204"
		end

		self.MaxButton:SetAttribute(
			"MaximizeState",
			not self.MaxButton:GetAttribute("MaximizeState")
		)
	end)

	self.NormalSize = self.Frame.Size
	self.NormalPosition = self.Frame.Position
end

MWindow.GetZIndex = function(self): number
	return table.find(self.Screen.Widgets,self.OBJID)
end

MWindow.SetTitle = function(self,title)
	self.Title = title
	self.TitleLabel.Text = self.Title
end

MWindow = MWidget:Init({},MWindow)

return MWindow