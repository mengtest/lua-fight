local SkillTargetHelper = class("SkillTargetHelper")

function SkillTargetHelper:ctor(roles, caster)
	self._roles = roles
	self._main_target_type = 0
	self._buff1_target_type = 0
	self._buff2_target_type = 0
	self._buff3_target_type = 0

	self._hero_id = 0
	local camp = CAMPTYPE.OUR
	if caster then
		self._hero_id = caster:GetId()
		camp = caster:GetCamp()
		self._caster = caster
	end
	-- if hero_id and hero_id > 0 then
	-- 	self._hero_id = hero_id
	-- end

	self._main_targets = {}
	self._buff1_targets = {}
	self._buff2_targets = {}
	self._buff3_targets = {}

	self._camp = 0
	self._op_camp = 0
	if camp and camp > 0 then
		self._camp = camp
		if camp == CAMPTYPE.OUR then
			self._op_camp = CAMPTYPE.PEER
		else
			self._op_camp = CAMPTYPE.OUR
		end
	end
end

function SkillTargetHelper:PrepareTarget(skill_cmd)
	self._main_target_type = skill_cmd:GetMainTargetType()
	self._buff1_target_type = skill_cmd:GETBuff1_Type()
	self._buff2_target_type = skill_cmd:GETBuff2_Type()
	self._buff3_target_type = skill_cmd:GETBuff3_Type()

	self._caster = skill_cmd:GetCaster()
	self._hero_id = self._caster:GetId()
	self._camp = self._caster:GetCamp()

	if self._camp == CAMPTYPE.OUR then
		self._op_camp = CAMPTYPE.PEER
	else
		self._op_camp = CAMPTYPE.OUR
	end

	self._main_targets = self:GetTargetByType(self._main_target_type)
	if #self._main_targets > 0 then
		skill_cmd:SetMainTargets(self._main_targets)
	end

	if self._buff1_target_type > 0 then
		if self._buff1_target_type ~= self._main_target_type then
			self._buff1_targets = self:GetTargetByType(self._buff1_target_type)
			if #self._buff1_targets > 0 then
				skill_cmd:SetBuff1_Targets(self._buff1_targets)
			end
		else
			self._buff1_targets = self._main_targets
			skill_cmd:SetBuff1_Targets(self._main_targets)
		end
	end

	if self._buff2_target_type > 0 then
		if self._buff2_target_type ~= self._main_target_type then
			self._buff2_targets = self:GetTargetByType(self._buff2_target_type)
			if #self._buff2_targets > 0 then
				skill_cmd:SetBuff2_Targets(self._buff2_targets)
			end
		else
			self._buff2_targets = self._main_targets
			skill_cmd:SetBuff2_Targets(self._main_targets)
		end
	end

	if self._buff3_target_type > 0 then
		if self._buff3_target_type ~= self._main_target_type then
			self._buff3_targets = self:GetTargetByType(self._buff3_target_type)
			if #self._buff3_targets > 0 then
				skill_cmd:SetBuff3_Targets(self._buff3_targets)
			end
		else
			self._buff3_targets = self._main_targets
			skill_cmd:SetBuff3_Targets(self._main_targets)
		end
	end

	printDebug("SkillTargetHelper:PrepareTarget main_target_type:%d, buff1_target_type:%d, buff2_target_type:%d, buff3_target_type:%d", self._main_target_type, self._buff1_target_type, self._buff2_target_type, self._buff3_target_type)
end

function SkillTargetHelper:GetTargetByType (target_type)
	local result = {}
	-- 敌方
	if target_type == TARGET_TYPE.ENEMY_FRONTROW_MULTI then
		result = self:GetCampFrontMulti(self._op_camp)

	elseif target_type == TARGET_TYPE.ENEMY_BACKROW_MULTI then
		result = self:GetCampBackMulti(self._op_camp)

	elseif target_type == TARGET_TYPE.ENEMY_COLUMN_MULTI then
		result = self:GetCampColumn(self._op_camp)

	elseif target_type == TARGET_TYPE.ENEMY_ALL_MULTI then
		result = self:GetCampAll(self._op_camp)

	elseif target_type == TARGET_TYPE.ENEMYR_ANDOMTHREE_MULTI then
		result = self:GetCampRandom(self._op_camp, 3)

	elseif target_type == TARGET_TYPE.ENEMY_FRONTNEIGHBOR_MULTI then
		result = self:GetCampFrontNeighbor(self._op_camp)

	elseif target_type == TARGET_TYPE.ENEMY_BACK_SINGLE then
		result = self:GetCampSnnerRole(self._op_camp)
		if not result or #result == 0 then
			result = self:GetCampBack(self._op_camp)
		end

	elseif target_type == TARGET_TYPE.ENEMY_FRONT_SINGLE then
		result = self:GetCampSnnerRole(self._op_camp)
		if not result or #result == 0 then
			result = self:GetCampFront(self._op_camp)
		end

	elseif target_type == TARGET_TYPE.ENEMY_RANDOM_BUFF_SINGLE then
		result = self:GetCampSnnerRole(self._op_camp)
		if not result or #result == 0 then
			result = self:GetBuffRandomN(self._op_camp, 1)
		end
	elseif target_type == TARGET_TYPE.ENEMY_RANDOM_BUFF_TWO then
		result = self:GetCampSnnerRole(self._op_camp)
		if not result or #result == 0 then
			result = self:GetBuffRandomN(self._op_camp, 2)
		end
	elseif target_type == TARGET_TYPE.ENEMY_HPPERCENTLOWEST_SINGLE then
		result = self:GetCampSnnerRole(self._op_camp)
		if not result or #result == 0 then
			result = self:GetCampHPLow(self._op_camp)
		end
	elseif target_type == TARGET_TYPE.ENEMY_HPPERCENTHIGHTEST_SINGLE then
		result = self:GetCampSnnerRole(self._op_camp)
		if not result or #result == 0 then
			result = self:GetCampHPHigh(self._op_camp)
		end
	elseif target_type == TARGET_TYPE.ENEMY_ANGERMOST_SINGLE then
		result = self:GetCampSnnerRole(self._op_camp)
		if not result or #result == 0 then
			result = self:GetCampAngerHigh(self._op_camp)
		end
	elseif target_type == TARGET_TYPE.ENEMY_ANGERLESS_SINGLE then
		result = self:GetCampSnnerRole(self._op_camp)
		if not result or #result == 0 then
			result = self:GetCampAngerLow(self._op_camp)
		end
	elseif target_type == TARGET_TYPE.ENEMY_ATK_HIGHEST_SINGLE then
		result = self:GetCampSnnerRole(self._op_camp)
		if not result or #result == 0 then
			result = self:GetCampATKHigh(self._op_camp)
		end
	elseif target_type == TARGET_TYPE.ENEMY_RANDOM_SINGLE then
		result = self:GetCampSnnerRole(self._op_camp)
		if not result or #result == 0 then
			result = self:GetCampRandom(self._op_camp, 1)
	end

	-- 我方
	elseif target_type == TARGET_TYPE.FRIEND_HPPERCENTLOWEST_SINGLE then
		result = self:GetCampHPLow(self._camp)

	elseif target_type == TARGET_TYPE.FRIEND_HPPERCENTHIGHTEST_SINGLE then
		result = self:GetCampHPHigh(self._camp)

	elseif target_type == TARGET_TYPE.FRIEND_CASTERSELF_SINGLE then
		result = self:GetSelf()

	elseif target_type == TARGET_TYPE.FRIEND_ANGERMOST_SINGLE then
		result = self:GetCampAngerHigh(self._camp)

	elseif target_type == TARGET_TYPE.FRIEND_ANGERLESS_SINGLE then
		result = self:GetCampAngerLow(self._camp)

	elseif target_type == TARGET_TYPE.FRIEND_RANDOMONE_SINGLE then
		result = self:GetCampRandom(self._camp, 1)

	elseif target_type == TARGET_TYPE.FRIEND_RANDOMTWO_SINGLE then
		result = self:GetCampRandom(self._camp, 2)

	elseif target_type == TARGET_TYPE.FRIEND_RANDOMTHREE_SINGLE then
		result = self:GetCampRandom(self._camp, 3)

	elseif target_type == TARGET_TYPE.FRIEND_FRONTROW_MULTI then
		result = self:GetCampFrontMulti(self._camp)

	elseif target_type == TARGET_TYPE.FRIEND_BACKROW_MULTI then
		result = self:GetCampBackMulti(self._camp)

	elseif target_type == TARGET_TYPE.FRIEND_ALL_MULTI then
		result = self:GetCampAll(self._camp)

	elseif target_type == TARGET_TYPE.FRIEND_RANDOM_DEBUFF_SINGLE then
		result = self:GetDebuffRandomN(self._camp, 1)

	elseif target_type == TARGET_TYPE.FRIEND_RANDOM_DEBUFF_TWO then
		result = self:GetDebuffRandomN(self._camp, 2)

	elseif target_type == TARGET_TYPE.FRIEND_ATK_HIGHEST_SINGLE then
		result = self:GetCampATKHigh(self._camp)

	elseif target_type == TARGET_TYPE.FRIEND_EXCEPT_SELF_MULTI then
		result = self:GetCampAll(self._camp, self._hero_id)

	-- target_type is hero id
	else
	end

	return result
end

function SkillTargetHelper:GetCampSnnerRole(camp)
	local roles = self._roles[camp]
	local result = {}

	if not roles then
		return result
	end

	for id, role in pairs(roles) do
		if role and role:IsDead() == false and role:HasSneerBuff() == true then
			table.insert(result, role)
			break
		end
	end
	return result
end

function SkillTargetHelper:GetCampFrontMulti(camp)
	local roles = self._roles[camp]
	if not roles then
		return {}
	end

	local result = {}
	for id=1, 3 do
		local main_peer = roles[id]
		if main_peer and main_peer:IsDead() == false then
			table.insert(result, main_peer)
		end
	end
	if #result <= 0 then
		for id=4, 6 do
			local main_peer = roles[id]
			if main_peer and main_peer:IsDead() == false then
				table.insert(result, main_peer)
			end
		end
	end

	return result
end

function SkillTargetHelper:GetCampBackMulti(camp)
	local roles = self._roles[camp]
	if not roles then
		return {}
	end

	local result = {}
	for id=4, 6 do
		local role = roles[id]
		if role and role:IsDead() == false then
			table.insert(result, role)
		end
	end
	if #result <= 0 then
		for id=1, 3 do
			local role = roles[id]
			if role and role:IsDead() == false then
				table.insert(result, role)
			end
		end
	end
	return result
end

function SkillTargetHelper:GetCampColumn(camp)
	local roles = self._roles[camp]
	if not roles then
		return {}
	end

	local front_single = self:GetCampFront(camp)

	local result = {}
	table.walk(front_single, function(front_role)
		if front_role and front_role:IsDead() == false then
			table.insert(result, front_role)
		else
			return
		end

		local id = front_role:GetId()
		if id <= 3 then
			local back_id = id + 3
			local role = roles[back_id]
			if role and role:IsDead() == false then
				table.insert(result, role)
			end
		end
	end)
	return result
end

function SkillTargetHelper:GetCampAll(camp, ignore_hero_id)
	local roles = self._roles[camp]
	if not roles then
		return {}
	end

	local result = {}
	table.walk(roles, function(role, id)
		if role and role:IsDead() == false and (ignore_hero_id == nil or (id ~= ignore_hero_id)) then
			table.insert(result, role)
		end
	end)
	return result
end

function SkillTargetHelper:GetCampFrontNeighbor(camp)
	local roles = self._roles[camp]
	if not roles then
		return {}
	end

	local front_single = self:GetCampFront(camp)
	local result = {}
	table.walk(front_single, function(front_role)
		if front_role and front_role:IsDead() == false then
			table.insert(result, front_role)
		else
			return
		end
		local id = front_role:GetId()
		local role
		local left = id - 1
		role = roles[left]
		if role and role:IsDead() == false then
			table.insert(result, role)
		end

		local right = id + 1
		role = roles[right]
		if role and role:IsDead() == false then
			table.insert(result, role)
		end

		if id <= 3 then
			local back = id + 3
			role = roles[back]
			if role and role:IsDead() == false then
				table.insert(result, role)
			end
		end
	end)
	return result
end

function SkillTargetHelper:GetCampFront(camp)
	local id = self._hero_id
	if id > 3 then
		id = id - 3
	end

	local roles = self._roles[camp]
	if not roles then
		return {}
	end

	local main_peer
	repeat
		main_peer = roles[id]
		if main_peer and main_peer:IsDead() == false then
			break
		end

		if id == 3 then
			main_peer = roles[id - 1]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id - 2]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id + 3]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id + 2]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id + 1]
			if main_peer and main_peer:IsDead() == false then
				break
			end

		elseif id == 2 then
			main_peer = roles[id - 1]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id + 1]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id + 3]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id + 4]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id + 2]
			if main_peer and main_peer:IsDead() == false then
				break
			end

		elseif id == 1 then
			main_peer = roles[id + 1]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id + 2]
			if main_peer and main_peer:IsDead() == false then
					break
			end
			main_peer = roles[id + 3]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id + 4]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id + 5]
			if main_peer and main_peer:IsDead() == false then
				break
			end
		end
	until true

	if main_peer and main_peer:IsDead() == false then
		return {main_peer}
	end

	return {}
end

function SkillTargetHelper:GetCampBack(camp)
	local id = self._hero_id
	if id <= 3 then
		id = id + 3
	end

	local roles = self._roles[camp]
	if not roles then
		return {}
	end

	local main_peer
	repeat
		main_peer = roles[id]
		if main_peer and main_peer:IsDead() == false then
			break
		end

		if id == 6 then
			main_peer = roles[id - 1]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id - 2]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id - 3]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id - 4]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id - 5]
			if main_peer and main_peer:IsDead() == false then
				break
			end

		elseif id == 5 then
			main_peer = roles[id + 1]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id - 1]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id - 3]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id - 2]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id - 4]
			if main_peer and main_peer:IsDead() == false then
				break
			end

		elseif id == 4 then
			main_peer = roles[id + 1]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id + 2]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id - 3]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id - 2]
			if main_peer and main_peer:IsDead() == false then
				break
			end
			main_peer = roles[id - 1]
			if main_peer and main_peer:IsDead() == false then
				break
			end
		end
	until true

	if main_peer and main_peer:IsDead() == false then
		return {main_peer}
	end

	return {}
end

function SkillTargetHelper:GetCampHPHigh(camp, skip_id)
	local roles = self._roles[camp]
	if not roles then
		return {}
	end

	local max_hp_percent = 0
	local result_role = nil
	table.walk(roles, function(role, role_id)
		if role:IsDead() then return end
		if skip_id and skip_id>0 and role_id==skip_id then return end

		if result_role == nil then
			result_role = role
			max_hp_percent = role:GetCurrentHp() / role:GetMaxHp()
		else
			local tmp_hp_percent = role:GetCurrentHp() / role:GetMaxHp()
			if tmp_hp_percent > max_hp_percent then
				result_role = role
				max_hp_percent = tmp_hp_percent
			end
		end
	end)

	if result_role and result_role:IsDead() == false then
		return {result_role}
	end
	return {}
end

function SkillTargetHelper:GetCampHPLow(camp, skip_id)
	local roles = self._roles[camp]
	if not roles then
		return {}
	end

	local result_role = nil
	local min_hp_percent = 0
	table.walk(roles, function(role, role_id)
		if role:IsDead() then return end
		if skip_id and skip_id>0 and role_id==skip_id then return end

		if result_role == nil then
			min_hp_percent = role:GetCurrentHp() / role:GetMaxHp()
			result_role = role
		else
			local tmp_hp_percent = role:GetCurrentHp() / role:GetMaxHp()
			if tmp_hp_percent < min_hp_percent then
				result_role = role
				min_hp_percent = tmp_hp_percent
			end
		end
	end)

	if result_role and result_role:IsDead() == false then
		return {result_role}
	end
	return {}
end

function SkillTargetHelper:GetCampAngerHigh(camp, skip_id)
	local roles = self._roles[camp]
	if not roles then
		return {}
	end

	-- local result_role = nil
	local max_anger = 0
	local result = {}
	table.walk(roles, function(role, role_id)
		if role:IsDead() then return end
		if skip_id and skip_id>0 and role_id==skip_id then return end

		-- if result_role == nil then
		if #result == 0 then
			max_anger = role:GetAnger()
			-- result_role = role
			table.insert(result, role)
		else
			local tmp_anger_percent = role:GetAnger()
			if tmp_anger_percent < max_anger then return end

			if tmp_anger_percent > max_anger then
				result = {}
				max_anger = tmp_anger_percent
			end
			table.insert(result, role)
		end
	end)

	-- if result_role and result_role:IsDead() == false then
		-- return {result_role}
	-- end
	return self:RandomN(camp, 1, result)
end

function SkillTargetHelper:GetCampAngerLow(camp, skip_id)
	local roles = self._roles[camp]
	if not roles then
		return {}
	end

	-- local result_role = nil
	local min_anger = 0
	local result = {}
	table.walk(roles, function(role, role_id)
		if role:IsDead() then return end
		if skip_id and skip_id>0 and role_id==skip_id then return end

		if #result == 0 then
			min_anger = role:GetAnger()
			-- result_role = role
		else
			local tmp_anger_percent = role:GetAnger()
			if tmp_anger_percent > min_anger then return end

			if tmp_anger_percent < min_anger then
				-- result_role = role
				min_anger = tmp_anger_percent
			end
			table.insert(result, role)
		end
	end)

	-- if result_role and result_role:IsDead() == false then
	-- 	return {result_role}
	-- end
	return self:RandomN(camp, 1, result)
end

function SkillTargetHelper:GetCampATKLow(camp, skip_id)
	local roles = self._roles[camp]
	if not roles then
		return {}
	end

	local result_role = nil
	local min_atk = 0
	table.walk(roles, function(role, role_id)
		if role:IsDead() then return end
		if skip_id and skip_id>0 and role_id==skip_id then return end

		if result_role == nil then
			min_atk = role:GetATK()
			result_role = role
		else
			local tmp_atk_role = role:GetATK()
			if tmp_atk_role < min_atk then
				result_role = role
				min_atk = tmp_atk_role
			end
		end
	end)

	if result_role and result_role:IsDead() == false then
		return {result_role}
	end
	return {}
end

function SkillTargetHelper:GetCampATKHigh(camp, skip_id)
	local roles = self._roles[camp]
	if not roles then
		return {}
	end

	local result_role = nil
	local max_atk = 0
	table.walk(roles, function(role, role_id)
		if role:IsDead() then return end
		if skip_id and skip_id>0 and role_id==skip_id then return end

		if result_role == nil then
			max_atk = role:GetATK()
			result_role = role
		else
			local tmp_atk = role:GetATK()
			if tmp_atk > max_atk then
				result_role = role
				max_atk = tmp_atk
			end
		end
	end)

	if result_role and result_role:IsDead() == false then
		return {result_role}
	end
	return {}
end

-- TODO
function SkillTargetHelper:GetBuffRandomN(camp, n)
	local buff_roles = {}
	local roles = self._roles[camp]
	if not roles then
		return {}
	end

	table.walk(roles, function(role, role_id)
		if role:IsDead() then return end
		if role:HasBuff() then
			buff_roles[role_id] = role
		end
	end)

	if #buff_roles>0 then
		return self:RandomN(camp, n, buff_roles)
	end

	return {}
end

function SkillTargetHelper:GetDebuffRandomN(camp, n)
	local debuff_roles = {}
	local roles = self._roles[camp]
	if not roles then
		return {}
	end

	table.walk(roles, function(role, role_id)
		if role:IsDead() then return end
		if role:HasDebuff() then
			debuff_roles[role_id] = role
		end
	end)

	if #debuff_roles>0 then
		return self:RandomN(camp, n, debuff_roles)
	end

	return {}
end

function SkillTargetHelper:GetCampRandom(camp, count)
	return self:RandomN(camp, count)
end

function SkillTargetHelper:GetSelf()
	return {self._caster}
end

function SkillTargetHelper:RandomN(camp, n, from_roles)
	local roles
	if from_roles and #from_roles > 0 then
		roles = from_roles
	else
		roles = self._roles[camp]
	end
	local result = {}

	local active_roles = {}
	table.walk(roles, function(role)
		if not role:IsDead() then
			table.insert(active_roles, role:GetId())
		end
	end)

	table.sort(active_roles, function(role1, role2)
		return role1 < role2
	end)

	local abandon = 0
	local random_index_set = {}
	local range_index = #active_roles
	if range_index > n then
		repeat
			local rd_index = random(range_index)
			if random_index_set[rd_index] ~= true then
				random_index_set[rd_index] = true
				abandon = abandon + 1
			end
		until(abandon == range_index - n)
	end

	table.walk(active_roles, function(role_id, index)
		if random_index_set[index] ~= true then
			table.insert(result, roles[role_id])
		end
	end)

	return result
end

-- function SkillTargetHelper:OutSelfCure()
-- end

-- function SkillTargetHelper:RandomOneHurt()
-- end

-- function SkillTargetHelper:SpeedMax(camp, skip_id)
-- 	local roles = self._roles[camp]
-- 	local min_speed_hero_id = 0
-- 	local min_speed = 0
-- 	table.walk(roles, function(role, role_id)
-- 		if role:IsDead() then return end
-- 		if skip_id>0 and role_id==skip_id then return end

-- 		if min_speed_hero_id == 0 then
-- 			min_speed_hero_id = role_id
-- 			min_speed = role:GetSpeed()
-- 		else
-- 			local tmp_speed = role:GetSpeed()
-- 			if tmp_speed < min_speed then
-- 				min_speed_hero_id = role_id
-- 				min_speed = tmp_speed
-- 			end
-- 		end
-- 	end)

-- 	if min_speed_hero_id > 0 then
-- 		return self._roles[min_speed_hero_id]
-- 	end
-- 	return nil
-- end

-- function SkillTargetHelper:AtsHight(camp, skip_id)
-- 	local roles = self._roles[camp]
-- 	local min_mfatk_hero_id = 0
-- 	local min_mfatk = 0
-- 	table.walk(roles, function(role, role_id)
-- 		if role:IsDead() then return end
-- 		if skip_id>0 and role_id==skip_id then return end

-- 		if min_mfatk_hero_id == 0 then
-- 			min_mfatk_hero_id = role_id
-- 			min_mfatk = role:GetMoFaAtk()
-- 		else
-- 			local tmp_mfatk = role:GetMoFaAtk()
-- 			if tmp_mfatk < min_mfatk then
-- 				min_mfatk_hero_id = role_id
-- 				min_mfatk = tmp_mfatk
-- 			end
-- 		end
-- 	end)

-- 	if min_mfatk_hero_id > 0 then
-- 		return self._roles[min_mfatk_hero_id]
-- 	end
-- 	return nil
-- end

-- function SkillTargetHelper:GunCol(main_target)
-- 	local id = main_target:GetId()
-- 	local camp = main_target:GetCamp()
-- 	local roles = self._roles[camp]
-- 	local result = {}

-- 	local func = function (index)
-- 		local role = roles[index]
-- 		if role and not role:IsDead() then
-- 			table.insert(result, role)
-- 		end
-- 	end

-- 	for i=1, 6 do
-- 		if math.floor((i-1)/3) == math.floor((id-1)/3) and i ~= id then
-- 			func(i)
-- 		end
-- 	end
-- 	return result
-- end

-- function SkillTargetHelper:GunRow(main_target)
-- 	local id = main_target:GetId()
-- 	local camp = main_target:GetCamp()
-- 	local roles = self._roles[camp]
-- 	local result = {}

-- 	local index = -1
-- 	if id <= 3 then
-- 		index = id + 3
-- 	else
-- 		index = id - 3
-- 	end

-- 	local role = roles[index]
-- 	if role and not role:IsDead() then
-- 		table.insert(result, role)
-- 	end

-- 	return result
-- end

-- function SkillTargetHelper:HPLOW()
-- end

-- function SkillTargetHelper:MAXHPHIGHT()
-- end

-- function SkillTargetHelper:None(main_target)
-- 	return {}
-- end

-- function SkillTargetHelper:RandomFive(main_target)
-- 	local camp = main_target:GetCamp()
-- 	local main_id = main_target:GetId()

-- 	local result = {}
-- 	table.walk(self._roles[camp], function(role)
-- 		if not role:IsDead() and role:GetId() ~= main_id then
-- 			table.insert(result, role)
-- 		end
-- 	end)

-- 	return result
-- end

-- function SkillTargetHelper:RandomFour(main_target)
-- 	return self:RandomN(main_target, 4)
-- end

-- function SkillTargetHelper:RandomOne(main_target)
-- 	return self:RandomN(main_target, 1)
-- end

-- function SkillTargetHelper:RandomTwo(main_target)
-- 	return self:RandomN(main_target, 2)
-- end

-- function SkillTargetHelper:RandomThree(main_target)
-- 	return self:RandomN(main_target, 3)
-- end

-- function SkillTargetHelper:Spotter(main_target)
-- 	local main_id = main_target:GetId()
-- 	local camp = main_target:GetCamp()
-- 	local roles = self._roles[camp]
-- 	local result = {}

-- 	table.walk({1, -1, 3, -3}, function(offset)
-- 		local new_id = main_id + offset
-- 		if new_id >=1 and new_id <=6 then
-- 			local role = roles[new_id]
-- 			if role and role:IsDead() then
-- 				table.insert(result, role)
-- 			end
-- 		end
-- 	end)

-- 	return result
-- end

return SkillTargetHelper
