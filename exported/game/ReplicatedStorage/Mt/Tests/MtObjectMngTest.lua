repstrg = game:GetService("ReplicatedStorage")

mt = require(repstrg.Mt)

obj1 = mt.MtWidgets.MWidget:Init()
obj1:SetName("obj1")

obj2 = mt.MtCore.MObject:Init()
obj2:SetName("obj2")
obj2:SetParent(obj1)

obj3 = mt.MtWidgets.MWindow:Init()
obj3:SetName("obj3")
obj3:SetParent(obj1)
obj3:PrintMembers()

print("1: "..obj1.Name)
print("2: "..obj2.Name)

print("children:")
for i,v in ipairs(obj1.Children) do
	print(v.Name)
end