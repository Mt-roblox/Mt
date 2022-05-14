local funcs = {}
function funcs:_inherit(a,b)
	-- Includes properties and functions from object b to object a, used for inheritance, except it's not used at all

	for k,v in pairs(b) do
		if not a[k] then a[k] = v end
	end

	return a
end

function funcs:_getMouseButton1Pressed(pressedButtons)
	-- get left button pressed, used in many scripts, thats why it's here
	
	
	if not pressedButtons or #pressedButtons==0 then
		return false
	end
	--print(debug.traceback().."\n"..tostring(table.unpack(pressedButtons)))
	for i,button in ipairs(pressedButtons) do
		if button.UserInputType == Enum.UserInputType.MouseButton1 then return true end
	end
	return false
end

local OBJS = {}
function funcs:_storeObj(obj)
	local id = obj.OBJID
	if id ~= -1 then
		OBJS[id] = obj
	end
end
function funcs:_getObjFromId(id)
	return OBJS[id]
end
return funcs