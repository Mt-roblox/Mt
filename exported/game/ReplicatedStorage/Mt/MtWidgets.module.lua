local mtwidgets = {}

-- Get every object in MtCore
for i,child in ipairs(script:GetChildren()) do
	if child.ClassName == "ModuleScript" then
		mtwidgets[child.Name] = require(child)
	end
end

return mtwidgets