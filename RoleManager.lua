-- local FormationManager = require("FormationManager")
local HeroController = require("HeroController")
local SkillController = require("SkillController")
local SkillTargetHelper = require("SkillTargetHelper")
local print_r = require("print_r")
local RoleManager = class("RoleManager")

function RoleManager.staticTest()
	printDebug("static function in RoleManager")
end

function RoleManager:ctor(battle_controller)
	self._battle_controller = battle_controller

	self._mode = 0
	self._force_first = 0
	-- new data construct
	self._roles = {}
	self._role_alive = {}
	self._current_camp_index = 0
	self._current_camp_index_table = {}
	self._current_camp_index_table[CAMPTYPE.OUR] = 1
	self._current_camp_index_table[CAMPTYPE.PEER] = 1
	self._fight_double_lsit = {}
	self._fight_double_lsit[CAMPTYPE.OUR] = {}
	self._fight_double_lsit[CAMPTYPE.PEER] = {}


	-- result detail
	self._result_detail = {}
	self._result_detail[CAMPTYPE.OUR] = {damage=0, heal=0, hp_percent=1, dead_count=0, team={}}
	self._result_detail[CAMPTYPE.PEER] = {damage=0, heal=0, hp_percent=1, dead_count=0, team={}}
	-- self._result_detail[CAMPTYPE.OUR] = {damage=0, heal=0, hp_percent=1, hp_max=0, hp_current=0, dead_count=0, team={}}
	-- self._result_detail[CAMPTYPE.PEER] = {damage=0, heal=0, hp_percent=1, hp_max=0, hp_current=0, dead_count=0, team={}}

	-- power
	self._power = {}
	self._power[CAMPTYPE.OUR] = 0
	self._power[CAMPTYPE.PEER] = 0

	-- combo data
	self._combo_data = {}
	self._combo_data[CAMPTYPE.OUR] = {combo = 0, total_damage = 0}
	self._combo_data[CAMPTYPE.PEER] = {combo = 0, total_damage = 0}

	-- mode3~mode5 total hp
	self._shared_total_hp = 0
	self._shared_current_hp = 0

	self._step = 0

	-- notify queue
	self._notify_queue = {}
end

function RoleManager:RoundOver()
	table.walk(self._fight_double_lsit, function (camp_list, camp)
		for k, v in ipairs(camp_list) do
			if v then
			-- if v and v.is_dead == false then
				self._current_camp_index_table[camp] = k
				break
			-- elseif v and v.is_dead == true then
			-- 	local role = self:GetRole(v.id, v.camp)
			-- 	if role then
			-- 		role:UpdateOnDie(data)
			-- 	end
			end
		end
	end)

	self._current_camp_index = self:GetFirstStepCamp();
end

function RoleManager:CheckRoundOver()
	local index_our = self._current_camp_index_table[CAMPTYPE.OUR]
	local index_peer = self._current_camp_index_table[CAMPTYPE.PEER]
	if index_our > #self._fight_double_lsit[CAMPTYPE.OUR] and index_peer > #self._fight_double_lsit[CAMPTYPE.PEER] then
		return true
	end
	return false
end

function RoleManager:Update(scene, step)
	self._step = step
	local data = self:GetFightNext()
	if data then
		local role = self:GetRole(data.id, data.camp)
		if role then
			role:Update(data)
		end

		printDebug("RoleManager:Update id:%d, camp:%d", data.id, data.camp)
	end

	self:UpdateResultDetail()

	if self._mode >= FIGHTMODE.MODE3 and self._mode <= FIGHTMODE.MODE5 and self:GetSharedHPPercent() <= 0 then
		self:CampAllDie(CAMPTYPE.PEER)
		return FIGHTRESULT.WIN
	end

	if self._role_alive[CAMPTYPE.OUR] <= 0 then
		return FIGHTRESULT.LOSE

	elseif self._role_alive[CAMPTYPE.PEER] <= 0 then
		return FIGHTRESULT.WIN

	elseif self:CheckRoundOver() then
		printDebug("====================================")
		printDebug(" Check Round Over, role alive:")
		print_r(self._role_alive, printDebug)
		printDebug("====================================")
		self:RoundOver()
		return FIGHTRESULT.ROUND_OVER
	end

	return FIGHTRESULT.PASS
end

function RoleManager:GetFightNext()
	local list = self._fight_double_lsit[self._current_camp_index]
	local result
	local index = self._current_camp_index_table[self._current_camp_index]
	local length = #list
	for i = index, length do
		result = list[i]
		if result and result.is_dead == false then
			self._current_camp_index_table[self._current_camp_index] = i + 1
			self._current_camp_index = self:GetOpponentCamp(self._current_camp_index)
			return result
		elseif result and result.is_dead == true then
			local role = self:GetRole(result.id, result.camp)
			if role then
				role:UpdateOnDie(data)
			end
		end
	end

	self._current_camp_index_table[self._current_camp_index] = length + 1
	self._current_camp_index = self:GetOpponentCamp(self._current_camp_index)

	if self._current_camp_index_table[self._current_camp_index] <= #self._fight_double_lsit[self._current_camp_index] then
		return self:GetFightNext()
	end

	return nil
end

function RoleManager:GetAllRole()
	return self._roles
end

function RoleManager:GetAllMaster()
	-- return self._masters
end

function RoleManager:GetRole(id, camp)
	if self._roles[camp] and self._roles[camp][id] then
		return self._roles[camp][id]
	end
	return nil
end

-- function RoleManager:InsertRing(data)
-- 	assert(data.id)
-- 	assert(data.camp)
-- 	local inserted = false
-- 	for i=self._fight_cur_index, self._fight_ring_length do
-- 		if data.speed > self._fight_ring[i].speed then
-- 			table.insert(self._fight_ring, i, data)
-- 			inserted = true
-- 			break
-- 		end
-- 	end
-- 	if not inserted then
-- 		table.insert(self._fight_ring, data)
-- 	end
-- 	self._fight_ring_length = self._fight_ring_length + 1
-- end

-- function RoleManager:InsertSSkill(id, camp, is_master)
	-- local data = {}
	-- data.speed = SPEED_MAX
	-- data.camp = camp
	-- data.id = id
	-- data.sskill = true
	-- data.is_master = is_master or false
	-- data.is_dead = false
	-- self:InsertRing(data)
-- end

function RoleManager:InsertRole(id, camp, hero_id)
	local data = {}
	data.id = id
	data.camp = camp
	data.hero_id = hero_id
	data.is_dead = false
	table.insert(self._fight_double_lsit[camp], data)
end

-- function RoleManager:RemoveRingRole(id, camp)
-- 	-- body
-- end

function RoleManager:GetFirstStepCamp()
	if self._force_first == 0 then
		if self._mode == 1 then
			if self._power[CAMPTYPE.OUR] >= self._power[CAMPTYPE.PEER] then
				return CAMPTYPE.OUR
			end
			return CAMPTYPE.PEER
		end
	elseif self._force_first == 2 then
		return CAMPTYPE.PEER
	end
	return CAMPTYPE.OUR
end

function RoleManager:InitDoubleList(is_first)
	self._role_alive = {}
	self._fight_double_lsit[CAMPTYPE.OUR] = {}
	self._fight_double_lsit[CAMPTYPE.PEER] = {}
	self._current_camp_index = self:GetFirstStepCamp()
	self._current_camp_index_table[CAMPTYPE.OUR] = 1
	self._current_camp_index_table[CAMPTYPE.PEER] = 1


	table.walk(self._roles, function(heros, camp)
		table.walk(heros, function(hero, id)
			if not hero:IsDead() then
				if not is_first then
					hero:Refresh()
				end

				if not self._role_alive[camp] then
					self._role_alive[camp] = 1
				else
					self._role_alive[camp] = self._role_alive[camp] +1
				end
				self:InsertRole(id, camp, hero:GetConfigId())
			end
		end)

		table.sort(self._fight_double_lsit[camp], function(p1, p2)
			if p1.id < p2.id then
				return true
			end
		end)
	end)
end

function RoleManager:RolesEnter()
	table.walk(self._roles, function(heros, camp)
		table.walk(heros, function(hero, id)
			if not hero:IsDead() then
				hero:OnEnter()
			end
		end)
	end)
end

function RoleManager:InitRole(attacker_hero, player_extra_attr, sufferer_hero, sufferer_extra_attr, mode, attacker_power, defender_power, force_first)
	self._mode = mode
	if force_first and force_first > 0 then
		self._force_first = force_first
	end
	-- new
	self._roles = {}

	table.walk(attacker_hero, function(hero)
		local hero_ctrller = HeroController.new(self, hero, CAMPTYPE.OUR)
		local camp = CAMPTYPE.OUR
		if not self._roles[camp] then
			self._roles[camp] = {}
		end
		self._roles[camp][hero.id] = hero_ctrller
	end)

	table.walk(sufferer_hero, function(hero)
		local hero_ctrller = HeroController.new(self, hero, CAMPTYPE.PEER)
		local camp = CAMPTYPE.PEER
		if not self._roles[camp] then
			self._roles[camp] = {}
		end
		self._roles[camp][hero.id] = hero_ctrller

		self._shared_total_hp = self._shared_total_hp + hero_ctrller:GetMaxHp()
		self._shared_current_hp = self._shared_current_hp + hero_ctrller:GetCurrentHp()
	end)

	if attacker_power and attacker_power > 0 then
		self._power[CAMPTYPE.OUR] = attacker_power
	end
	if defender_power and defender_power>0 then
		self._power[CAMPTYPE.PEER] = defender_power
	end

	self:InitDoubleList(true)
	self:RolesEnter()
	self:UpdateResultDetail()
end

function RoleManager:InitRoleNext(sufferer_hero, sufferer_extra_attr, mode, force_first)
	if force_first and force_first > 0 then
		self._force_first = force_first
	end

	if mode and mode > 0 then
		self._mode = mode
	end
	if self._roles[CAMPTYPE.PEER] then
		self._roles[CAMPTYPE.PEER] = {}
	end

	table.walk(sufferer_hero, function(hero)
		local hero_ctrller = HeroController.new(self, hero, CAMPTYPE.PEER)
		local camp = CAMPTYPE.PEER
		if not self._roles[camp] then
			self._roles[camp] = {}
		end
		self._roles[camp][hero.id] = hero_ctrller
	end)

	-- reset attacker todo
	self:InitDoubleList()
	self:RolesEnter()

	self._result_detail[CAMPTYPE.OUR] = {damage=0, heal=0, hp_percent=1, dead_count=0, team={}}
	self._result_detail[CAMPTYPE.PEER] = {damage=0, heal=0, hp_percent=1, dead_count=0, team={}}
	self:UpdateResultDetail()

	self._combo_data[CAMPTYPE.OUR] = {combo = 0, total_damage = 0}
	self._combo_data[CAMPTYPE.PEER] = {combo = 0, total_damage = 0}
end

function RoleManager:CareerActor(id, camp, career)
	-- TODO
	printDebug("Career Actor, %d, %d, %d", id, camp, career)
end

function RoleManager:GetCurrentRole()
	-- return self._attacker[1]
end

function RoleManager:GetOpponentCamp(camp_self)
	if camp_self == CAMPTYPE.OUR then
		return CAMPTYPE.PEER
	else
		return CAMPTYPE.OUR
	end
end

function RoleManager:GetRoles(camp)
	return self._roles[camp]
end

function RoleManager:GetOpponentRoles(camp_self)
	local camp = 0
	if camp_self == CAMPTYPE.OUR then
		camp = CAMPTYPE.PEER
	else
		camp = CAMPTYPE.OUR
	end
	return self:GetRoles(camp)
end

function RoleManager:GetSneerHero(camp)
	local roles = self._roles[camp]
	if not roles then
		return nil
	end

	for role_id, role_controller in pairs(roles) do
		if not role_controller:IsDead() and role_controller:GetSneer() then
			return role_controller
		end
	end
	return nil
end

function RoleManager:GetRoundOver()
	return false
end

function RoleManager:GetSceneOver()
	return false
end

function RoleManager:IsHeroAlive(hero_id, camp)
	for i=1, #self._fight_double_lsit[camp] do
		local hero_data = self._fight_double_lsit[camp][i]
		if hero_data.hero_id == hero_id and hero_data.is_dead == false then
			return true
		end
	end
	return false
end

function RoleManager:GetIDByHeroID(hero_id, camp)
	for i=1, #self._fight_double_lsit[camp] do
		local hero_data = self._fight_double_lsit[camp][i]
		if hero_data.hero_id == hero_id and hero_data.is_dead == false then
			return hero_data.id
		end
	end
	return nil
end

function RoleManager:HeroDie(id, camp)
	-- table.walk(self._fight_ring, function(hero_data, key)
	-- 	if hero_data.camp == camp and hero_data.id == id then
	-- 		printDebug("Hero Die, camp:%d, id:%d", camp, id)
	-- 		self._fight_ring[key].is_dead = true
	-- 		self._role_alive[camp] = self._role_alive[camp] - 1
	-- 	end
	-- end)

	local is_find = false
	for i=1, #self._fight_double_lsit[camp] do
		local hero_data = self._fight_double_lsit[camp][i]
		if hero_data.id == id then
			printDebug("Hero Die, camp:%d, id:%d", camp, id)
			hero_data.is_dead = true
			self._role_alive[camp] = self._role_alive[camp] - 1
			is_find = true
			break
		end
	end

	if is_find then
		self._result_detail[camp].dead_count = self._result_detail[camp].dead_count + 1
	end
end

function RoleManager:ClearCampCombo(camp)
	local is_cmd = self._combo_data[camp].combo > 0
	self._combo_data[camp].combo = 0
	self._combo_data[camp].total_damage = 0
	if is_cmd and camp == CAMPTYPE.OUR then
		printDebug("Clear Combo, camp:%d", camp)
		FIGHT_PACK_MANAGER:Combo(0, 0)
	end
end

function RoleManager:CampCombo(camp, current_damage)
	local opponent_camp = self:GetOpponentCamp(camp)
	self:ClearCampCombo(opponent_camp)

	self._combo_data[camp].combo = self._combo_data[camp].combo + 1
	self._combo_data[camp].total_damage = self._combo_data[camp].total_damage + current_damage

	if camp == CAMPTYPE.OUR then
		printDebug("Combo, camp:%d, combo:%d, total_damage:%d", camp, self._combo_data[camp].combo, self._combo_data[camp].total_damage)
		FIGHT_PACK_MANAGER:Combo(self._combo_data[camp].combo, self._combo_data[camp].total_damage)
	end
end

function RoleManager:RecordDamage(camp, damage)
	self._result_detail[camp].damage = self._result_detail[camp].damage + damage
end

function RoleManager:RecordHeal(camp, heal)
	self._result_detail[camp].heal = self._result_detail[camp].heal + heal
end

function RoleManager:GetCampDamage(camp)
	return self._result_detail[camp].damage
end

function RoleManager:GetCampHeal(camp)
	return self._result_detail[camp].heal
end

function RoleManager:UpdateResultDetail()
	table.walk(self._roles, function(heros, camp)
		local hp_max, hp_current = 0, 0
		self._result_detail[camp].team = {}
		table.walk(heros, function(hero, id)
			if not hero:IsDead() then
				table.insert(self._result_detail[camp].team, {id=id, current_hp=hero:GetCurrentHp(), max_hp=hero:GetMaxHp(), current_anger=hero:GetAnger()})
				hp_current = hp_current + hero:GetCurrentHp()
			end

			hp_max = hp_max + hero:GetMaxHp()
		end)

		if hp_max > 0 then
			self._result_detail[camp].hp_percent = tonumber(string.format("%.3f", (hp_current / hp_max)))
		else
			self._result_detail[camp].hp_percent = 0
		end
	end)

	if self._mode >= FIGHTMODE.MODE3 and self._mode <= FIGHTMODE.MODE5 then
		if self._shared_total_hp > 0 then
			self._result_detail[CAMPTYPE.PEER].hp_percent = tonumber(string.format("%.3f", (self._shared_current_hp / self._shared_total_hp)))
		else
			self._result_detail[CAMPTYPE.PEER].hp_percent = 0
		end
	end
end

function RoleManager:GetResultDetail()
	return {our = self._result_detail[CAMPTYPE.OUR], peer = self._result_detail[CAMPTYPE.PEER]}
end

function RoleManager:GetBattleController()
	return self._battle_controller
end

function RoleManager:SubSharedHP(damage)
	self._shared_current_hp = self._shared_current_hp - damage
	if self._shared_current_hp < 0 then
		self._shared_current_hp = 0
	end
end

function RoleManager:GetSharedHPPercent()
	return tonumber(string.format("%.3f", (self._shared_current_hp / self._shared_total_hp)))
end

function RoleManager:CampAllDie(camp)
	table.walk(self._roles[camp], function(hero)
		hero:Die()
	end)
end

function RoleManager:GetStep()
	return self._step
end

function RoleManager:GetAliveCount(camp)
	return self._role_alive[camp] or 0
end

function RoleManager:RegisterNotify(notify_str, role, fn)
	if not role then
		return
	end

	if not self._notify_queue[notify_str] then
		self._notify_queue[notify_str] = {}
	end

	local key = string.format("%d#%d", role:GetCamp(), role:GetId())
	if self._notify_queue[notify_str][key] then
		return
	end

	local data = {}
	data.role = role
	data.fn = fn
	self._notify_queue[notify_str][key] = data
end

function RoleManager:UnRegisterNotify(notify_str, role)
	if not role then
		return
	end

	if not self._notify_queue[notify_str] then
		return
	end

	local key = string.format("%d#%d", role:GetCamp(), role:GetId())
	if not self._notify_queue[notify_str][key] then
		return
	end
	self._notify_queue[notify_str][key] = nil
end

function RoleManager:TriggerNotify(notify_str, ...)
	if not notify_str or not self._notify_queue[notify_str] then
		return
	end

	local param = {...}
	table.walk(self._notify_queue[notify_str], function(data)
		local role = data.role
		local fn = data.fn
		if role and fn then
			fn(role, param)
		end
	end)
end

return RoleManager
