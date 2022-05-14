local mtcore = {}

-- Get every object in MtCore
for i,child in ipairs(script:GetChildren()) do
	if child.ClassName == "ModuleScript" then
		mtcore[child.Name] = require(child)
	end
end

function mtcore:_inherit(a,b)
	-- Includes properties and functions from object b to object a, used for inheritance, except it's not used at all

	for k,v in pairs(b) do
		if not a[k] then a[k] = v end
	end

	return a
end

function mtcore:_getMouseButton1Pressed(pressedButtons)
	-- get left button pressed, used in many scripts, thats why it's here
	
	if not pressedButtons then return false end
	for i,button in ipairs(pressedButtons) do
		if button.UserInputType == Enum.UserInputType.MouseButton1 then return true end
	end
	return false
end

local OBJS = {}
function mtcore:_storeObj(obj)
	local id = obj.OBJID
	if not id == -1 then
		OBJS[id] = obj
	end
end
function mtcore:_getObjFromId(id)
	return OBJS[id]
end

return mtcore