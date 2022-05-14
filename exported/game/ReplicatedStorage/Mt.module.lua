local mt = {}

-- Get every module in Mt
for i,child in ipairs(script:GetChildren()) do
	if child.ClassName == "ModuleScript" then
		mt[child.Name] = require(child)
	end
end

function _about()
	-- About Mt
	-- This is a test command that prints something about Mt
	
	print("Thanks for using Mt!")
end

mt["_about"] = _about

return mt