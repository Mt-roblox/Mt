local repstrg = game:GetService("ReplicatedStorage")
local MObject = require(repstrg.Mt.MtCore.MObject)
local uis = game:GetService("UserInputService")

local MWidget = {
	ClassName = "MWidget", -- See Mt.MtCore.MObject
	Name = "widget",       -- ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
}

MWidget.Init = function(self,parent,_obj)
	local _obj = MObject.Init(self,parent,_obj)

	_obj.Frame = Instance.new("Frame")
	_obj.Frame.Name = _obj.Name
	_obj.Frame.BorderSizePixel = 0
	_obj.Frame.BackgroundColor3 = Color3.new(1,1,1)
	_obj.Frame.Size = UDim2.fromScale(0.25,0.25)

	_obj.SizeConstraint = Instance.new("UISizeConstraint")
	_obj.SizeConstraint.Parent = _obj.Frame
	MWidget.SetSizeLimit(_obj,
		Vector2.new(10,10),
		Vector2.new(3000,3000)
	)

	return _obj
end

MWidget.SetSizeLimit = function(self,min,max)
	self.SizeConstraint.MinSize = min
	self.SizeConstraint.MaxSize = max
end

MWidget.SetMinimumSize = function(self,size)
	self:SetSizeLimit(size,self.SizeConstraint.MaxSize)
end

MWidget.SetMinimumWidth= function(self,width)
	self:SetMinimumSize(Vector2.new(
		width,
		self.SizeConstraint.MinimumSize.Y
		))
end

MWidget.SetMinimumHeight=function(self,height)
	self:SetMinimumSize(Vector2.new(
		self.SizeConstraint.MinimumSize.X,
		height
		))
end

MWidget.SetMaximumSize = function(self,size)
	self:SetSizeLimit(self.SizeConstraint.MinSize,size)
end

MWidget.SetMaximumWidth= function(self,width)
	self:SetMaximumSize(Vector2.new(
		width,
		self.SizeConstraint.MinimumSize.Y
		))
end

MWidget.SetMaxmimumHeight=function(self,height)
	self:SetMaximumSize(Vector2.new(
		self.SizeConstraint.MinimumSize.X,
		height
		))
end

MWidget.SetName = function(self,name)
	self.Frame.Name = name
	MObject.SetName(self,name)
end

MWidget.SetHidden = function(self,hidden)
	self.Frame.Visible = not hidden
end

MWidget._PointTouchingArea = function(self,point: Vector2,areaPos: UDim2,areaSize: UDim2)
	local px = point.X
	local py = point.Y
	local apx = areaPos.X.Offset
	local apy = areaPos.Y.Offset
	local asx = areaSize.X.Offset
	local asy = areaSize.X.Offset
	--print ("Verify Square Point("..px..","..py..")")
	--print ("              On   ("..apx..","..apy..","..asx..","..asy..")")
	return 
		(px >= apx-asx and px <= (apx + asx)) and
		(py >= apy-asy and py <= (apy + asy))
end

MWidget.IsPointInsideWidget = function(self,point:Vector2)
	self:_PointTouchingArea(point,self.Frame.Position,self.Frame.Size)
end

MWidget.IsBeingHovered = function(self)
	self:IsPointInsideWidget(uis:GetMouseLocation())
end

MWidget = MObject:Init({},MWidget,-1)

return MWidget