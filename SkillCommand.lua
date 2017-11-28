local st_skill = require("st_hero_skill")
local BattleCalculater = require("BattleCalculater")
local SkillController = require("SkillController")
local SkillCommand = class("SkillCommand")

function SkillCommand.GetSkillInfoByKey(skill_id, key)
	local data = st_skill[skill_id]
	if not data then
		return nil
	end

	return data[key]
end

function SkillCommand.GetSkillInfo(skill_id)
	local data = st_skill[skill_id]
	return data
end

function SkillCommand:ctor(caster, skill_id, skill_level)
	local data = st_skill[skill_id]
	assert(data, "unknow skill id" .. tostring(skill_id))
	self._caster = caster
	self._skill_id = skill_id
	self._skill = nil
	self._main_targets = {}
	self._buff_targets = {}
	self._buff_target_type = {}
	self._buff_ids = {}
	self._buff_rates = {}
	self._current_stage = 0
	self._total_damage = 0
	self._caster_heal = 0
	self._reflect_damage = 0
	self._stunt_reduce_targets = {}
	self._skill_level = skill_level

	self:InitStaticData(data)
end

function SkillCommand:InitStaticData(static_data)
	self._full_cd = static_data['cool_cd']
	self._main_target_type = static_data['main_target']
	self._skill_damage_factor = static_data["hurt_factor"]
	self._buff_ids[1] = static_data["buff_id1"]
	self._buff_target_type[1] = static_data["buff_target1"]
	self._buff_rates[1] = static_data["buff_dex1"]
	self._buff_ids[2] = static_data["buff_id2"]
	self._buff_target_type[2] = static_data["buff_target2"]
	self._buff_rates[2] = static_data["buff_dex2"]
	self._buff_ids[3] = static_data["buff_id3"]
	self._buff_target_type[3] = static_data["buff_target3"]
	self._buff_rates[3] = static_data["buff_dex3"]
	self._stunt_id1 = static_data["stunt_id1"]
	self._param1 = static_data["param1"]
	self._stunt_id2 = static_data["stunt_id2"]
	self._param2 = static_data["param2"]
	self._skill_class = static_data["skill_class"]
	self._skill_type = static_data["skill_type"]
	self._effect_type = static_data["effect_type"]
	self._release_num = static_data["release_num"]
	self._is_lock = static_data["is_lock"]
	self._condition_arg = static_data["condition_arg"]
end

function SkillCommand:DoSkill(current_stage)
	if self._caster:IsDead() then
		return
	end

	self._current_stage = current_stage

	for i = 1, #self._main_targets do
		if self._main_targets[i]:IsDead() == false then
			local defender = self._main_targets[i]

			-- attr_table
			local attacker_attr_table = self._caster:GetAttrTable()
			local defender_attr_table = defender:GetAttrTable()

			if  self._main_target_type > TARGET_TYPE.ENEMY_BEGIN and self._main_target_type < TARGET_TYPE.ENEMY_END and not defender:IsGod() then
				-- if self:Stunt(STUNTTYPE.DISPEL) ~= 0 then
				-- 	defender._buff_manager:Dispel()
				-- end
				-- if self:Stunt(STUNTTYPE.REFINE) ~= 0 then
				-- 	defender._buff_manager:Refine()
				-- end

				-- special start ===========================
				-- attacker
				if self._caster:IsFirstAct() then
					self._caster:GetSpecialMgr():GetFirstActAttr(attacker_attr_table)
				end
				if defender:IsFirstAct() then
					self._caster:GetSpecialMgr():GetTargetFirstActAttr(attacker_attr_table)
				end
				self._caster:GetSpecialMgr():GetAttrByTargetAnger(attacker_attr_table, defender:GetAnger())
				self._caster:GetSpecialMgr():GetAttrByTargetHpPercent(attacker_attr_table, defender:GetCurrentHpPercent())
				local alive_count = self._caster._role_manager:GetAliveCount(self._caster:GetCamp()) - 1
				if alive_count>0 then
					self._caster:GetSpecialMgr():GetAliveCountAttr(attacker_attr_table, alive_count)
				end
				local special_vampirism_rate = self._caster:GetSpecialMgr():GetAttrByHpCompare(attacker_attr_table, self._caster:GetCurrentHp(), defender:GetCurrentHp()) or 0
				special_vampirism_rate = special_vampirism_rate + (self._caster:GetSpecialMgr():CheckEnemyBuff(attacker_attr_table, defender) or 0)

				-- defender
				defender:GetSpecialMgr():GetAttrByAttackerAnger(defender_attr_table, self._caster:GetAnger())
				defender:GetSpecialMgr():GetAttrByAttackerHpPercent(defender_attr_table, self._caster:GetCurrentHpPercent())
				defender:GetSpecialMgr():CheckAttackerBuff(defender_attr_table, self._caster)
				defender:GetSpecialMgr():CheckAttackerSkillEffect(defender_attr_table, self._effect_type)
				-- special end ===========================

				-- 判断命中
				local hit_rate = max(attacker_attr_table.HIT - defender_attr_table.MISS, 0)
				hit_rate = hit_rate + self:Stunt(STUNTTYPE.ADDHIT) + self:Stunt(STUNTTYPE.ADDHITCRIT)
				if random(1000) <= hit_rate or defender:GetPetrified() or self:Stunt(STUNTTYPE.KILLALL) > 0 then
					-- 命中

					-- crit, block
					local crit_rate = max(attacker_attr_table.CRIT - defender_attr_table.DEC_CRIT, 0)
					local is_crit = false
					crit_rate = crit_rate + self:Stunt(STUNTTYPE.ADDCRIT) + self:Stunt(STUNTTYPE.ADDHITCRIT)
					if random(1000) <= crit_rate or self:Stunt(STUNTTYPE.KILLALL) > 0 then
						is_crit = true
					end

					local block_rate = max(defender_attr_table.BLOCK - attacker_attr_table.DIS_BLOCK, 0)
					local is_block = false
					if random(1000) <= block_rate and defender:GetPetrified() == false and self:Stunt(STUNTTYPE.KILLALL) <= 0 then
						is_block = true
					end

					if self._skill_damage_factor > 0 then

						local tmp_skill_damage_factor = self._skill_damage_factor
						local factor_enhance = self:Stunt(STUNTTYPE.ENHANCE_SKILL_PER_RELEASE)
						if factor_enhance > 0 then
							tmp_skill_damage_factor = tmp_skill_damage_factor + (self._skill_level - 1) * factor_enhance
							printDebug("stunt ENHANCE_SKILL_PER_RELEASE, count:%d, stunt_value:%d, after enhance skill factor:%d", self._skill_level - 1, factor_enhance, tmp_skill_damage_factor)
						end

						local damage = BattleCalculater.GetDamage(attacker_attr_table, defender_attr_table, is_crit, is_block, tmp_skill_damage_factor, 0)
						if self:Stunt(STUNTTYPE.KILLALL) > 0 then
							damage = 99999999
						end
						if damage > 0 then
							if self:Stunt(STUNTTYPE.KILLALL) <= 0 then
								-- stunt LASTHIT
								local last_hit_rate = self:Stunt(STUNTTYPE.LASTHIT)
								if last_hit_rate ~= 0 and self._current_stage == self._release_num then
									damage = damage * last_hit_rate
								end

								-- stunt HPLOWHURT
								local hp_low_factory = self:Stunt(STUNTTYPE.HPLOWHURT)
								if hp_low_factory > 0 then
									local hp_percent = defender:GetCurrentHpPercent()
									damage = damage * (1 + hp_low_factory * (1-hp_percent))
								end
								-- stunt OURHPLOWHURT
								local our_hp_low_factory = self:Stunt(STUNTTYPE.OURHPLOWHURT)
								if our_hp_low_factory > 0 then
									local hp_percent = self._caster:GetCurrentHpPercent()
									damage = damage * (1 + our_hp_low_factory * (1-hp_percent))
								end

								local double_damage_rate = self._caster:GetDoubleDamageBuffRate()
								if double_damage_rate > 0 and random(100) <= double_damage_rate then
									damage = damage * 2
								end

								local death_kill_rate = self._caster:GetDeathKillBuffRate()
								if death_kill_rate > 0 and random(100) <= death_kill_rate then
									damage = defender:GetCurrentHp()
								end

								-- stunt SUBSTRRIPHPRATE
								local stunt_hurt_rate = self:Stunt(STUNTTYPE.SUBSTRRIPHPRATE)
								if stunt_hurt_rate ~= 0 then
									damage = damage + math.ceil(defender:GetMaxHp() * stunt_hurt_rate / 100)
								end
							end

							-- special
							damage = (defender:GetSpecialMgr():GetMaxLoseHp(self._total_damage + damage, defender:GetMaxHp()) or 0) - self._total_damage
							if damage < 0 then
								damage = 0
							end

							-- stunt REDUCE
							local stunt_reduce = self:Stunt(STUNTTYPE.REDUCE)
							if stunt_reduce > 0 then
								if self._stunt_reduce_targets[defender:GetId()] ~= nil then
									damage = damage * stunt_reduce / 100
								else
									self._stunt_reduce_targets[defender:GetId()] = true;
								end
							end

							damage = math.ceil(damage)

							-- sub hp
							printDebug("caster_id:%d, caster_camp:%d, suffer_id:%d, suffer_camp:%d, damage:%d", self._caster:GetId(), self._caster:GetCamp(), defender:GetId(), defender:GetCamp(), damage)
							defender:SubHp(damage, is_crit, is_block, 0, 0, SKILL_OR_BUFF.SKILL, self._skill_id, self._caster:GetId(), self._caster:GetCamp())
							self._total_damage = self._total_damage + damage

							-- special
							if defender:IsDead() then
								self._caster:GetSpecialMgr():Trigger("SPECIAL_TRIGGER_KILL_ENEMY")
								local param = {}
								param.killer = self._caster
								defender:GetSpecialMgr():Trigger("SPECIAL_TRIGGER_AFTER_DIE", nil, param)
							end

							self._caster._role_manager:CampCombo(self._caster:GetCamp(), damage)

							-- caster heal
							self._caster_heal = self._caster_heal + defender:GetBuffHealByDamage(damage)

							-- boom damage
							if defender:IsDead() == false then
								defender:GetBoomDamage(self._caster:GetId(), self._caster:GetCamp())
							end

							-- reflect damage
							self._reflect_damage = self._reflect_damage + defender:GetReflectBuffDamage(damage) + damage * (special_vampirism_rate / 1000)

							-- special
							defender:GetSpecialMgr():CheckReflectDamage(self._caster, damage)

							-- miss heal buff
							if is_block == true and defender:IsDead() == false then
								local miss_heal_rate, buff_id = defender:GetMissHealBuffFactor()
								if miss_heal_rate > 0 and random(100) <= miss_heal_rate then
									local heal_hp = math.ceil(defender_attr_table.ATK * miss_heal_rate / 100)
									defender:AddHp(heal_hp, SKILL_OR_BUFF.BUFF, buff_id, defender:GetId(), defender:GetCamp(), false)
								end

								defender:GetSpecialMgr():Trigger("SPECIAL_TRIGGER_AFTER_BLOCK")
							end
						end
					end


					-- stunt anger
					if self._current_stage == self._release_num then
						local loss_anger = 0
						local loss_anger_rate = 0
						if self:Stunt(STUNTTYPE.LOSSANGER) ~= 0 then
							loss_anger = self:Stunt(STUNTTYPE.LOSSANGER)
							loss_anger_rate = 100

						elseif self:Stunt(STUNTTYPE.CLEAR_ANGER) ~= 0 then
							loss_anger = ANGERTYPE.MAXANGER
							loss_anger_rate = self:Stunt(STUNTTYPE.CLEAR_ANGER)

						elseif self:Stunt(STUNTTYPE.LOSSANGER_TWO) ~= 0 then
							loss_anger = 2
							loss_anger_rate = self:Stunt(STUNTTYPE.LOSSANGER_TWO)

						elseif self:Stunt(STUNTTYPE.LOSSANGER_ONE) ~= 0 then
							loss_anger = 1
							loss_anger_rate = self:Stunt(STUNTTYPE.LOSSANGER_ONE)
						end

						if loss_anger_rate > 0 and random(100) <= loss_anger_rate then
							if loss_anger > 0 then
								if defender:IsDead() == false then
									defender:SubAnger(loss_anger)
								end

								-- special
								if self._skill_type == SKILLTYPE.ANGER or self._skill_type == SKILLTYPE.POKEBALL then
									self._caster:GetSpecialMgr():AddAttrByStuntAnger(loss_anger)
								end

							elseif loss_anger < 0 and defender:IsDead() == false then
								defender:SubAnger(-loss_anger)
							end
						end

						-- special
						defender:GetSpecialMgr():CheckAttrAfterHurt(self._caster, self._effect_type)
						if defender:GetSpecialMgr():CheckStrikeBack() then
							local strike_back_skill = SkillCommand.new(defender, defender:GetNormalSkillID())
							table.insert(strike_back_skill._main_targets, self._caster)
							strike_back_skill:DoSkill(1)
						end
					end

					-- get anger buff
					defender:CheckGetAngerBuff()

					-- self._caster:CountHitTarget(defender)
				else
					-- 连击断
					self._caster._role_manager:ClearCampCombo(self._caster:GetCamp())

					-- 未命中
					FIGHT_PACK_MANAGER:AttackMiss(defender:GetId(), defender:GetCamp())

					-- miss heal buff
					local miss_heal_rate, buff_id = defender:GetMissHealBuffFactor()
					if miss_heal_rate > 0 and random(100) <= miss_heal_rate then
						local heal_hp = math.ceil(defender_attr_table.ATK * miss_heal_rate / 100)
						printDebug("caster_id:%d, caster_camp:%d, suffer_id:%d, suffer_camp:%d, heal:%d", self._caster:GetId(), self._caster:GetCamp(), defender:GetId(), defender:GetCamp(), heal_hp)
						defender:AddHp(heal_hp, SKILL_OR_BUFF.BUFF, buff_id, defender:GetId(), defender:GetCamp(), false)
					end
				end

			elseif self._main_target_type > TARGET_TYPE.FRIEND_BEGIN and self._main_target_type < TARGET_TYPE.FRIEND_END then
				-- 连击断
				self._caster._role_manager:ClearCampCombo(self._caster._role_manager:GetOpponentCamp(self._caster:GetCamp()))
				if self._skill_damage_factor > 0 then

					local tmp_skill_damage_factor = self._skill_damage_factor
					local factor_enhance = self:Stunt(STUNTTYPE.ENHANCE_SKILL_PER_RELEASE)
					if factor_enhance > 0 then
						tmp_skill_damage_factor = tmp_skill_damage_factor + (self._skill_level - 1) * factor_enhance
						printDebug("stunt ENHANCE_SKILL_PER_RELEASE, count:%d, stunt_value:%d, after enhance skill factor:%d", self._skill_level - 1, factor_enhance, tmp_skill_damage_factor)
					end

					-- special
					self._caster:GetSpecialMgr():CheckHeal(attacker_attr_table, defender:GetCurrentHpPercent(), defender:GetId())

					-- crit, block
					local crit_rate = max(attacker_attr_table.CRIT, 0)
					local is_crit = false
					crit_rate = crit_rate + self:Stunt(STUNTTYPE.ADDCRIT) + self:Stunt(STUNTTYPE.ADDHITCRIT)
					if random(1000) <= crit_rate then
						is_crit = true
					end

					local heal_value = BattleCalculater.GetHeal(attacker_attr_table, defender_attr_table, is_crit, tmp_skill_damage_factor, 0)
					if heal_value > 0 and defender:GetLockHeal() == false and defender:GetPetrified() == false then
						local lost_hp = defender:GetMaxHp() - defender:GetCurrentHp()
						defender:AddHp(heal_value, SKILL_OR_BUFF.SKILL, self._skill_id, self._caster:GetId(), self._caster:GetCamp(), is_crit)

						-- special
						if heal_value > lost_hp then
							self._caster:GetSpecialMgr():CheckExcessiveHeal(defender, heal_value - lost_hp)
						end
					end
				end

			else
				-- 对特定英雄释放
			end
		end
	end

	-- self:CheckSelfBuff()

	-- if self:Stunt(STUNTTYPE.GIVEANGER) ~= 0 then
	-- 	if ((self._caster:GetCurrentHp() / self._caster:GetBaseHp()) >= 0.35) and (self._caster:IsBoss() == false) then
	-- 		self._caster:AddAnger(ANGERTYPE.FULLANGER, true)
	-- 	elseif (((self._caster:GetCurrentHp() / self._caster:GetBaseHp()) >= 0.35) and (self._caster:IsBoss() == true) and (self._caster:GetBossHp() == 0) ) then
	-- 		self._caster:AddAnger(ANGERTYPE.FULLANGER, true)
	-- 	elseif (self._caster:IsBoss() == true) and (self._caster:GetBossHp() > 0) then
	-- 		self._caster:AddAnger(ANGERTYPE.FULLANGER, true)
	-- 	end
	-- end

	-- self._caster._buff_manager:RemoveBuff(self:Stunt(STUNTTYPE.SELFDISPEL))

	-- local sub_hp_stunt = self:Stunt(STUNTTYPE.SUBHP)
	-- if sub_hp_stunt ~= 0 then
	-- 	local num = self._caster:GetCurrentHp() * sub_hp_stunt / 100
	-- 	if num > 1 then
	-- 		self._caster:SubHp(num, false, false, 0, self._effect_type, 1, self:GetSkillId(), self._caster:GetId(), self._caster:GetCamp())
	-- 	end
	-- end

	-- skill_damage_extra, skill_damage_factor
	-- calc targets
	-- local skill_damage_factor = 0
	-- local skill_damage_extra = 0
end

function SkillCommand:CastFinish()
	-- check stunt
	self:CheckStuntAfterSkill()

	-- check buff
	for i=1, 3 do
		if self._buff_ids[i] and self._buff_target_type[i] and self._buff_targets[i]
				and self._buff_ids[i]>0 and self._buff_target_type[i] > 0 and #self._buff_targets[i] > 0 then
			self:CheckBuff(i)
		end
	end

	-- reflect damage
	if self._reflect_damage > 0 and self._caster:IsDead() == false then
		self._caster:SubHp(self._reflect_damage, false, false, 0, DAMAGE_EFFECT_TYPE.NORMAL, SKILL_OR_BUFF.BUFF, 0, 0, 0)
	end

	-- caster heal
	if self._caster_heal > 0 and self._caster:IsDead() == false then
		self._caster:AddHp(self._caster_heal)
	end


	-- stunt ENHANCE_SKILL_PER_RELEASE
	if self:Stunt(STUNTTYPE.ENHANCE_SKILL_PER_RELEASE) > 0 then
		self._caster:AddSkillLevel(self._skill_id, 1)
	end
end

function SkillCommand:CheckBuff(index)
	local buff_id = self._buff_ids[index]
	local buff_rate = self._buff_rates[index]
	for i = 1, #self._buff_targets[index] do
		if self._buff_targets[index][i]:IsDead() == false and random(100) <= buff_rate then
			local defender = self._buff_targets[index][i]
			if not defender:IsGod() then
				defender:AddBuff(self._caster, buff_id)
			end
		end
	end
end

function SkillCommand:CheckStuntAfterSkill()
	if self:Stunt(STUNTTYPE.SELFDISPEL) ~= 0 then
		self._caster:RemoveBuff(self:Stunt(STUNTTYPE.SELFDISPEL))
	end

	local back_anger = self:Stunt(STUNTTYPE.BACKANGER)
	if back_anger > 0 then
		self._caster:AddAnger(back_anger, true)
	elseif back_anger < 0 then
		self._caster:SubAnger(-back_anger)
	end

	-- stunt vampirism
	local vampirism_rate = self:Stunt(STUNTTYPE.VAMPIRISM)
	if vampirism_rate > 0 then
		local vampirism_value = max(self._total_damage * vampirism_rate / 100, 0)
		self._caster:AddHp(vampirism_value, SKILL_OR_BUFF.SKILL, self._skill_id, self._caster:GetId(), self._caster:GetCamp(), false)
	end
end

function SkillCommand:Stunt(type)
	if type == self._stunt_id1 then
		return self._param1
	end
	if type == self._stunt_id2 then
		return self._param2
	end
	return 0
end

function SkillCommand:GetCD()
	return self._full_cd
end

function SkillCommand:GetCaster()
	return self._caster
end

function SkillCommand:GetSkillId()
	return self._skill_id
end

function SkillCommand:SetTargets(targets)
	self._suffers = targets
end

function SkillCommand:GetTargets()
	return self._main_targets
end

function SkillCommand:SetMainTargets(targets)
	self._main_targets = targets
end

function SkillCommand:SetBuff1_Targets(targets)
	self._buff_targets[1] = targets
end

function SkillCommand:SetBuff2_Targets(targets)
	self._buff_targets[2] = targets
end

function SkillCommand:SetBuff3_Targets(targets)
	self._buff_targets[3] = targets
end

function SkillCommand:GetMainTargetType()
	return self._main_target_type
end

function SkillCommand:GETBuff1_Type()
	return self._buff_target_type[1]
end

function SkillCommand:GETBuff2_Type()
	return self._buff_target_type[2]
end

function SkillCommand:GETBuff3_Type()
	return self._buff_target_type[3]
end

function SkillCommand:GetReleaseNum()
	return self._release_num
end

function SkillCommand:GetCurrentStage()
	return self._current_stage
end

function SkillCommand:GetSkillType()
	return self._skill_type
end

function SkillCommand:IsLock()
	return self._is_lock
end

function SkillCommand:GetTargetNum()
	return #self._main_targets
end

return SkillCommand
