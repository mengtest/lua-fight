local EnvironmentManager = class("EnvironmentManager")

function EnvironmentManager:ctor(battleController)
	self._battleController = battleController
	-- self._fightPackMgr = fightPackMgr
	-- printDebug("EnvironmentManager")
end

function EnvironmentManager:Update()
	-- printDebug("EnvironmentManager:Update")
end

function EnvironmentManager:RegistEnvEvent(event)
	-- TODO	
end

return EnvironmentManager
