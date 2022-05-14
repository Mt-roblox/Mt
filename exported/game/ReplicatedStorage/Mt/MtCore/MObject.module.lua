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

local _storeObj = require(script.Parent.MtCoreFunctions)._storeObj

local OBJIDS = 0

local MObject = {
	-- Properties (Read-only (use their functions))
	Name = "object", -- Object name (string)
	ClassName = "MObject", -- Object class name (string)
	OBJID = 0,
	Parent = {}, -- Object parent (MObject)
	Children = {}, -- Object's children (table (array))

	-- Options
	BlockEvents = false, -- Don't fire signals (boolean)

	-- Events (Read-only)
	Destroyed = Instance.new("BindableEvent"), -- Fires when the object is destroyed
}

-- Functions
MObject.Init = function(self,parent,_obj,_id)
	-- Creates object and returns it

	_obj = _obj or {}
	setmetatable(_obj, self)
	self.__index = self

	for k,v in pairs(self) do
		if not _keyInTableExists(_obj,k) then
			_obj[k] = v
		end
	end
	
	if _id then
		_obj.OBJID = _id
	else
		_obj.OBJID = OBJIDS
		OBJIDS += 1
	end

	parent = parent or {}
	MObject.SetParent(_obj,parent)
	
	_storeObj(nil,_obj)

	return _obj
end

MObject.FireEvent = function(self,event,...)
	-- Fires an event applying the BlockEvents filter
	
	if ... then
		if not self.BlockEvents then event:Fire(table.unpack(...)) end
	else
		if not self.BlockEvents then event:Fire() end
	end
end

MObject.Destroy = function(self)
	-- Fires the destroyed event and destroys the object and all its children

	self:FireEvent(self.Destroyed)

	self.Destroyed:Destroy()
	for i,child in ipairs(self.Children) do child:Destroy() end
	self = nil
end

MObject.Clone = function(self)
	-- Clones the object and returns it (i think)

	return self
end

MObject.SetName = function(self,name)
	self.Name = name
end

MObject.SetParent = function(self,parent)
	-- Sets parent for the object

	parent = parent or {}

	if self.Parent == {} then
		table.remove(self.Parent.Children,table.find(self.Parent.Children,self))
	end

	self.Parent = parent

	if parent == {} then
		table.insert(parent.Children,self)
	end

	return nil
end

MObject.FindFirstChild = function(self,child)
	-- Finds the inputted child in the object's children list and returns it

	for i,v in ipairs(self.Children) do
		if v.Name == child then
			return v
		end
	end

	return nil
end

MObject.PrintMembers = function(self)
	-- Prints all members of the metatable and their types

	print(self.Name.."'s members:")
	for k,v in pairs(self) do
		print(k..": "..typeof(v).." = "..v)
	end
end

return MObject