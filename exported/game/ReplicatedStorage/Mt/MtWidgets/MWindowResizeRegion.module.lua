local repstrg = game:GetService("ReplicatedStorage")
local changeCursor = repstrg.Mt.Remotes.ChangeCursor
local MObject  = require(repstrg.Mt.MtCore.MObject)
local MtEnum  = require(repstrg.Mt.MtCore.MtEnum)
local _getMouseButton1Pressed = require(repstrg.Mt.MtCore.MtCoreFunctions)._getMouseButton1Pressed
local MtMouseController = require(repstrg.Mt.MtCore.MtMouseController)
local plr = game:GetService("Players").LocalPlayer or nil

local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

local cursors = {
	[MtEnum.Side.Left]   = "rbxasset://textures/StudioUIEditor/icon_resize2.png",
	[MtEnum.Side.Top]    = "rbxasset://textures/StudioUIEditor/icon_resize4.png",
	[MtEnum.Side.Right]  = "rbxasset://textures/StudioUIEditor/icon_resize2.png",
	[MtEnum.Side.Bottom] = "rbxasset://textures/StudioUIEditor/icon_resize4.png",
}

--[[
local cursorsByResizeSide = {
	[MtEnum.ResizeSide.None]   = "",
	[{MtEnum.ResizeSide.Left,0}]   = "rbxasset://textures/StudioUIEditor/icon_resize2.png",
	[{MtEnum.ResizeSide.Right,0}]  = "rbxasset://textures/StudioUIEditor/icon_resize4.png",
	[{0,MtEnum.ResizeSide.Top}]    = "rbxasset://textures/StudioUIEditor/icon_resize2.png",
	[{0,MtEnum.ResizeSide.Bottom}] = "rbxasset://textures/StudioUIEditor/icon_resize4.png",

	[{MtEnum.ResizeSide.Left,MtEnum.ResizeSide.Top}]     = "rbxasset://textures/StudioUIEditor/icon_resize3.png",
	[{MtEnum.ResizeSide.Right,MtEnum.ResizeSide.Top}]    = "rbxasset://textures/StudioUIEditor/icon_resize1.png",
	[{MtEnum.ResizeSide.Right,MtEnum.ResizeSide.Bottom}] = "rbxasset://textures/StudioUIEditor/icon_resize3.png",
	[{MtEnum.ResizeSide.Left,MtEnum.ResizeSide.Bottom}]  = "rbxasset://textures/StudioUIEditor/icon_resize1.png",
}
--]]

local MWindowResizeRegion = {
	Name = "ResizeRegion",
	ClassName = "MWindowResizeRegion",
}

MWindowResizeRegion.Init = function(self,x,y,side,sx,sy,osx,osy,parent,_obj)
	if parent.ClassName ~= "MWindow" then
		error("Mt error: MWindowResizeRegions must be parented to an MWindow.")
	end
	
	local _obj = MObject.Init(self,parent,_obj)
	_obj.Resizing    = Instance.new("BindableEvent")
	_obj.ResizeEnded = Instance.new("BindableEvent")
	_obj.ResizeBegan = Instance.new("BindableEvent")

	if not _obj.Parent.Frame:FindFirstChild("resizeRegions") then
		_obj.ResizeRegionsFolder = Instance.new("Folder")
		_obj.ResizeRegionsFolder.Parent = _obj.Parent.Frame
		_obj.ResizeRegionsFolder.Name = "resizeRegions"
	else
		_obj.ResizeRegionsFolder = _obj.Parent.Frame.resizeRegions
	end

	if not _obj.ResizeRegionsFolder:FindFirstChild("Dragging") then
		_obj.DraggingValue = Instance.new("ObjectValue")
		_obj.DraggingValue.Parent = _obj.ResizeRegionsFolder
		_obj.DraggingValue.Name = "Dragging"
	else
		_obj.DraggingValue = _obj.ResizeRegionsFolder.Dragging
	end

	osx = osx or 0
	osy = osy or 0

	_obj.Region = Instance.new("Frame")
	_obj.Region.Parent = _obj.ResizeRegionsFolder
	_obj.Region.Name = side.._obj.Name
	_obj.Region.BackgroundTransparency = 1
	_obj.Region.BorderSizePixel = 0
	_obj.Region.BorderColor3 = Color3.new(0,1,0)
	_obj.Region.Position = UDim2.fromScale(x,y)
	_obj.Region.Size = UDim2.new(sx,osx,sy,osy)
	
	_obj.XRay = script.XRay:Clone()
	MWindowResizeRegion.SetXRayEnabled(_obj,false)
	_obj.XRay.Parent = _obj.Region

	_obj.Cursor = cursors[side]
	
	_obj.Region.MouseEnter:Connect(function()
		if MWindowResizeRegion.CanChangeCursor(_obj) then
			local mouse = plr:GetMouse()
			MtMouseController:ChangeCursor(_obj.Cursor)
		end
	end)

	_obj.Region.MouseLeave:Connect(function()
		if MWindowResizeRegion.CanChangeCursor(_obj) then
			local mouse = plr:GetMouse()
			MtMouseController:ResetCursor()
		end
	end)

	_obj.Region.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local clickLocation = uis:GetMouseLocation()
			local wx=_obj.Parent.Frame.Position.X.Offset
			local wy=_obj.Parent.Frame.Position.Y.Offset
			local wsx=_obj.Parent.Frame.Size.X.Offset
			local wsy=_obj.Parent.Frame.Size.Y.Offset
			local imx=clickLocation.X
			local imy=clickLocation.Y

			_obj.DraggingValue.Value = _obj.Region
			local sidex=MtEnum.ResizeSide.None
			local sidey=MtEnum.ResizeSide.None

			if _getMouseButton1Pressed(nil,uis:GetMouseButtonsPressed()) then
				if math.abs(imx-wx)<5 then sidex=MtEnum.ResizeSide.Left end
				if math.abs(imx-(wx+wsx))<5 then sidex=MtEnum.ResizeSide.Right end
				if math.abs(imy-wy)<5 then sidey=MtEnum.ResizeSide.Top end
				if math.abs(imy-(wy+wsy))<5 then sidey=MtEnum.ResizeSide.Bottom end
			end
			
			_obj.ResizeBegan:Fire()
			
			while _getMouseButton1Pressed(nil,uis:GetMouseButtonsPressed()) and _obj.Parent.Screen.WindowBeingInteracted do
				local location = uis:GetMouseLocation()
				local mx=location.X
				local my=location.Y
				local incx=mx-imx
				local incy=my-imy
				local nx,ny,nsx,nsy
				if sidex==MtEnum.ResizeSide.None then
					nx=wx
					nsx=wsx
				end
				if sidex==MtEnum.ResizeSide.Left then
					nx=wx+(incx)
					nsx=wsx-(incx)
				end
				if sidex==MtEnum.ResizeSide.Right then
					nx=wx
					nsx=wsx+(incx)
				end
				if sidey==MtEnum.ResizeSide.None then
					ny=wy
					nsy=wsy
				end
				if sidey==MtEnum.ResizeSide.Top then 
					ny=wy+(incy)
					nsy=wsy-(incy)
				end
				if sidey==MtEnum.ResizeSide.Bottom then
					ny=wy
					nsy=wsy+(incy)
				end
				
				_obj.Parent.Frame.Position = UDim2.fromOffset(nx,ny)
				_obj.Parent.Frame.Size = UDim2.fromOffset(nsx,nsy)

				_obj.Resizing:Fire(_obj.Parent.Frame.Size,_obj.Parent.Frame.Position,location)
				MtMouseController:ChangeCursor(MWindowResizeRegion.GetCursorFromResizeSide(sidex,sidey))

				task.wait(.025)
				--print(table.unpack(uis:GetMouseButtonsPressed()))
			end

			MtMouseController:ResetCursor()
			_obj.DraggingValue.Value = nil
			
			_obj.ResizeEnded:Fire()
		end
	end)
	
	--MWindowResizeRegion.SetXRayEnabled(_obj,true)

	return _obj
end

MWindowResizeRegion.CanChangeCursor = function(self): boolean
	return plr and not self.Parent.Screen.WindowBeingInteracted and self.Parent:GetZIndex() == #self.Parent.Screen.Widgets
end

MWindowResizeRegion.SetXRayEnabled = function(self,enabled:boolean)
	self.XRay.Enabled = enabled
end

MWindowResizeRegion.GetCursorFromResizeSide = function(x:number,y:number):string
	-- static function
	-- haha no x and y aren't coordinates they're MtEnum.ResizeSide enums.
	
	if x==0 and y==0 then return "" end -- none
	
	if x~=0 and y==0 then return "rbxasset://textures/StudioUIEditor/icon_resize2.png" end -- horizontal
	if y~=0 and x==0 then return "rbxasset://textures/StudioUIEditor/icon_resize4.png" end -- vertical
	
	if x==y then return "rbxasset://textures/StudioUIEditor/icon_resize3.png" end -- diagonal north-east
	if x~=y then return "rbxasset://textures/StudioUIEditor/icon_resize1.png" end -- diagonal north-west
end

MWindowResizeRegion = MObject:Init({},MWindowResizeRegion,-1)

return MWindowResizeRegion