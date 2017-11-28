local EnvironmentManager = require("EnvironmentManager")
local RoleManager = require("RoleManager")
local ActionManager = require("ActionManager")
local FightPackManager = require("FightPackManager")
local Random = require("Random")
require("BattleData")

local BattleController = class("BattleController")

-- init data here
function BattleController:ctor()
	self._inited = false
	self._scene = 1
	self._round = 1
	self._step = 1
	self._mode = 0
	-- self._fight_pack_manager = FightPackManager.new(self)
	if not FIGHT_PACK_MANAGER then
		FIGHT_PACK_MANAGER = FightPackManager.new(self)
	end

	self._env_manager = EnvironmentManager.new(self)
	self._role_manager = RoleManager.new(self)
	self._action_manager = ActionManager.new(self)

	self._random = nil
end

function BattleController:RegistEnvEvent(event)
	self._env_manager:RegistEnvEvent(event)
end

-- old api
function BattleController:InitBattle(attacker_hero, player_extra_attr, sufferer_hero, sufferer_extra_attr, mode, seed, attacker_power, defender_power, force_first)
	self._random = Random.new(seed)
	RandomFunction = self._random
	FIGHT_PACK_MANAGER:ClearAllData()
	self._mode = mode
	self._role_manager:InitRole(attacker_hero, player_extra_attr, sufferer_hero, sufferer_extra_attr, mode, attacker_power, defender_power, force_first)
end

function BattleController:InitNextBattle(sufferer_hero, sufferer_extra_attr, mode, force_first)
	self._scene = self._scene + 1
	FIGHT_PACK_MANAGER:ClearAllData()
	self._role_manager:InitRoleNext(sufferer_hero, sufferer_extra_attr, mode, force_first)
end

function BattleController:Update()
	FIGHT_PACK_MANAGER:NewQueue()
	-- environment update
	self._env_manager:Update()

	printDebug("ROUND %d, STEP %d", self._round, self._step)

	local result = self._role_manager:Update(self._scene, self._step)
	self._step = self._step + 1

	if result == FIGHTRESULT.ROUND_OVER then
		self._round = self._round + 1
		-- check round over
		result = FIGHTRESULT.PASS
	end

	if self._round > 5 and (self._mode == FIGHTMODE.MODE2 or self._mode == FIGHTMODE.MODE4) then
		return FIGHTRESULT.WIN
	-- elseif self._mode >= FIGHTMODE.MODE3 and self._mode <= FIGHTMODE.MODE5 then
	-- 	if self:GetTotalHpPercent(CAMPTYPE.PEER) <= 0 then
	-- 		return FIGHTRESULT.WIN
	elseif self._round > 3 and self._mode == FIGHTMODE.MODE5 then
		return FIGHTRESULT.WIN
	-- elseif self._round > 5 and self._mode == FIGHTMODE.MODE4 then
	-- 	return FIGHTRESULT.WIN
	-- elseif self._round > 20 and self._mode == FIGHTMODE.MODE3 then
	-- 	return FIGHTRESULT.WIN
		-- end
	elseif self._round > 20 then
		if self._mode ~= FIGHTMODE.MODE6 and self._mode ~= FIGHTMODE.MODE3 then
			return FIGHTRESULT.TIMEOUT
		else
			return FIGHTMODE.WIN
		end
	end
	return result
end

function BattleController:ReleaseSSkill(data)
end

function BattleController:GetPeerStatNum()
end

function BattleController:GetOurEndHpAnger()
end

function BattleController:GetOurNum()
end

function BattleController:GetTotalHpPercent(camp)
	local detail = self._role_manager:GetResultDetail()
	if camp == CAMPTYPE.OUR then
		return detail.our.hp_percent
	else
		if self._mode >= FIGHTMODE.MODE3 and self._mode <= FIGHTMODE.MODE5 then
			return self._role_manager:GetSharedHPPercent()
		end
		return detail.peer.hp_percent
	end
end

function BattleController:SetVerify(scene, pos, camp, step)
end

function BattleController:GetReleaseSSkillVec()
end

function BattleController:GetFightDatas()
	return FIGHT_PACK_MANAGER:GetFightDatas()
end

function BattleController:GetRound()
	return self._round
end

function BattleController:ShowFightDataVec()
end

function BattleController:LogSwitch(path, filename)
	FIGHT_PACK_MANAGER:LogSwitch(path,filename)
end

function BattleController:GetAllLog()
end

function BattleController:GetFightPackMgr()
	return FIGHT_PACK_MANAGER
end

function BattleController:GetRandomSequence()
	return self._random:GetSequence()
end

function BattleController:GetResultDetail()
	-- return {our={damage=100,heal=200,hp_percent=0.5,dead_count=0,team={{id=5, current_hp=300, max_hp=500, current_anger=3}, {id=6, current_hp=300, max_hp=500, current_anger=3}}}, peer={damage=100,heal=200,hp_percent=0,dead_count=4,team={}}}
	return self._role_manager:GetResultDetail()
end

return BattleController
