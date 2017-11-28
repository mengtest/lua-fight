local ActionManager = class("ActionManager")

function ActionManager:ctor()
	printDebug("ActionManager")
end

function ActionManager:Update()
	printDebug("ActionManager:Update()")
end

return ActionManager
