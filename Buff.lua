local st_buff = require("st_buff")
local BattleCalculater = require("BattleCalculater")
local Buff = class("Buff")

function Buff.GetBuffInfo(buff_id)
	local data = st_buff[buff_id]
	return data
end

function Buff.GetBuffInfoByKey(buff_id, key)
	local data = st_buff[buff_id]
	if data then
		return data[key]
	end
	return nil
end

function Buff:ctor(caster, buff_id, number, buff_level)
	local data = st_buff[buff_id]
	assert(data,  "unknow buff id:" .. tostring(buff_id))
	self._attached = false
	self._attach_role = nil
	self._buff_manager = nil

	self._num = 0
	if number > 0 then
		self._num = number
	end

	self._caster = caster
	self._buff_id = buff_id
	self._third_hurt = 0
	self._current_time = 0
	self._attr_table = {}
	self._new_buff = true

	if buff_level then
		self._buff_level = buff_level
	end

	self:InitData(data)
end

function Buff:InitData(data)
	self._buff_time = data["buff_time"]
	self._overlay = 1
	self._max_overlay = data['overlay']
	self._is_remove = false
	self._is_clean = false
	self._effect = data["effect"]
	self._effect_param_1 = data["effect_param_1"]
	self._effect_param_2 = data["effect_param_2"]

	if data["is_remove"] > 0 then
		self._is_remove = true
	end

	if data["is_clean"] > 0 then
		self._is_clean = true
	end
end

function Buff:AttachTo(role)
	local result = false
	if role then
		self._attach_role = role
		self._buff_manager = role._buff_manager
		self._attached = true
		self._current_time = self._buff_time

		-- TODO 检查同类BUFF

		result = self:CheckEffect()

		if self:IsAttrBuff() then
			self:AttachAttrBuff()
		end

		-- buff time = 0
		if self._current_time <= 0 then
			self:Remove()
			result = false
		end
	end
	return result
end

function Buff:CheckEffect()
	-- 计算伤害
	local result = false

	if self._attach_role:GetImmuneBuff() == true and self:CanClean() == true then
		return result
	end

	result = true

	if self._effect == BUFFTYPE.POISONING or self._effect == BUFFTYPE.BURNING or self._effect == BUFFTYPE.POISONING_CRIT or self._effect == BUFFTYPE.BURNING_CRIT then
		local damage_effect = DAMAGE_EFFECT_TYPE.NORMAL
		if self._effect == BUFFTYPE.POISONING then
			damage_effect = DAMAGE_EFFECT_TYPE.POISON
		elseif self._effect == BUFFTYPE.BURNING then
			damage_effect = DAMAGE_EFFECT_TYPE.BURN
		end

		self._num = BattleCalculater.GetBuffDamage(self._caster, self._attach_role, self._effect_param_1, damage_effect)
	-- end

	elseif self._effect == BUFFTYPE.RECOVERY then
		self._num = BattleCalculater.GetBuffHeal(self._caster, self._attach_role, self._effect_param_1)

	elseif self._effect == BUFFTYPE.BOOM then
		self._num = math.ceil(self._caster:GetATK() * self._effect_param_1 / 1000)

	elseif self._effect == BUFFTYPE.SHIELD then
		self._num = BattleCalculater.GetShield(self._caster, self._attach_role, self._effect_param_1)

	elseif self._effect == BUFFTYPE.GOD or self._effect == BUFFTYPE.CLEAN_DEBUFF then
		self._buff_manager:Refine()

	elseif self._effect == BUFFTYPE.DISPEL then
		self._buff_manager:Dispel()

	elseif self._effect == BUFFTYPE.INC_DAMAGE_BY_ATK then
		if self._overlay >= self._max_overlay then
			return
		end
		if not self._num then
			self._num = 0
		end

		self._num = self._num + math.ceil(self._caster:GetATK() * self._effect_param_1 / 1000)


	end

	return result
end

function Buff:IsAttached()
	return self._attached
end

function Buff:IsAttrBuff()
	if self._effect == BUFFTYPE.ATK_CHANGE
		or self._effect == BUFFTYPE.DEF_CHANGE
		or self._effect == BUFFTYPE.HP_CHANGE
		or self._effect == BUFFTYPE.DMG_CHANGE
		or self._effect == BUFFTYPE.CRIT_CHANGE
		or self._effect == BUFFTYPE.DEC_CRIT_CHANGE
		or self._effect == BUFFTYPE.HIT_CHANGE
		or self._effect == BUFFTYPE.MISS_CHANGE
		or self._effect == BUFFTYPE.CRIT_DMG_CHANGE
		or self._effect == BUFFTYPE.DEC_CRIT_DMG_CHANGE
		or self._effect == BUFFTYPE.BLOCK_CHANGE
		or self._effect == BUFFTYPE.DIS_BLOCK_CHANGE
		or self._effect == BUFFTYPE.STRONG
		or self._effect == BUFFTYPE.SMARTER
		or self._effect == BUFFTYPE.HEAL_CHANGE
		or self._effect == BUFFTYPE.BE_HEAL_CHANGE
		or self._effect == BUFFTYPE.ANGER_CHANGE
		or self._effect == BUFFTYPE.POISON_DMG_CHANGE
		or self._effect == BUFFTYPE.POISON_DEF_CHANGE
		or self._effect == BUFFTYPE.BURNING_DMG_CHANGE
		or self._effect == BUFFTYPE.BURNING_DEF_CHANGE

		or self._effect == BUFFTYPE.HEAL_CHANGE_GIVE_HP
		or self._effect == BUFFTYPE.INC_DAMAGE_BY_ATK
		or self._effect == BUFFTYPE.CRIT_AND_CRIT_DAMAGE_CHANGE
	then
		return true
	end
	return false
end

function Buff:AttachAttrBuff()
	if self._attr_table then
		self._buff_manager:RemoveBuffAttr(self._attr_table)
	end
	self._attr_table = {}

	if self._effect == BUFFTYPE.ATK_CHANGE then
		if not self._attr_table[HEROATTRTYPE.ATK_PERCENT] then
			self._attr_table[HEROATTRTYPE.ATK_PERCENT] = 0
		end
		self._attr_table[HEROATTRTYPE.ATK_PERCENT] = self._attr_table[HEROATTRTYPE.ATK_PERCENT] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.DEF_CHANGE then
		if not self._attr_table[HEROATTRTYPE.DEF_PERCENT] then
			self._attr_table[HEROATTRTYPE.DEF_PERCENT] = 0
		end
		self._attr_table[HEROATTRTYPE.DEF_PERCENT] = self._attr_table[HEROATTRTYPE.DEF_PERCENT] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.HP_CHANGE then
		if not self._attr_table[HEROATTRTYPE.HP_PERCENT] then
			self._attr_table[HEROATTRTYPE.HP_PERCENT] = 0
		end
		self._attr_table[HEROATTRTYPE.HP_PERCENT] = self._attr_table[HEROATTRTYPE.HP_PERCENT] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.DMG_CHANGE then
		if not self._attr_table[HEROATTRTYPE.INC_DMG] then
			self._attr_table[HEROATTRTYPE.INC_DMG] = 0
		end
		self._attr_table[HEROATTRTYPE.INC_DMG] = self._attr_table[HEROATTRTYPE.INC_DMG] + self._effect_param_1 * self._overlay
		if not self._attr_table[HEROATTRTYPE.DEC_DMG] then
			self._attr_table[HEROATTRTYPE.DEC_DMG] = 0
		end
		self._attr_table[HEROATTRTYPE.DEC_DMG] = self._attr_table[HEROATTRTYPE.DEC_DMG] + self._effect_param_2 * self._overlay

	elseif self._effect == BUFFTYPE.CRIT_CHANGE then
		if not self._attr_table[HEROATTRTYPE.CRIT] then
			self._attr_table[HEROATTRTYPE.CRIT] = 0
		end
		self._attr_table[HEROATTRTYPE.CRIT] = self._attr_table[HEROATTRTYPE.CRIT] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.DEC_CRIT_CHANGE then
		if not self._attr_table[HEROATTRTYPE.DEC_CRIT] then
			self._attr_table[HEROATTRTYPE.DEC_CRIT] = 0
		end
		self._attr_table[HEROATTRTYPE.DEC_CRIT] = self._attr_table[HEROATTRTYPE.DEC_CRIT] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.HIT_CHANGE then
		if not self._attr_table[HEROATTRTYPE.HIT] then
			self._attr_table[HEROATTRTYPE.HIT] = 0
		end
		self._attr_table[HEROATTRTYPE.HIT] = self._attr_table[HEROATTRTYPE.HIT] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.MISS_CHANGE then
		if not self._attr_table[HEROATTRTYPE.MISS] then
			self._attr_table[HEROATTRTYPE.MISS] = 0
		end
		self._attr_table[HEROATTRTYPE.MISS] = self._attr_table[HEROATTRTYPE.MISS] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.CRIT_DMG_CHANGE then
		if not self._attr_table[HEROATTRTYPE.CRIT_DMG] then
			self._attr_table[HEROATTRTYPE.CRIT_DMG] = 0
		end
		self._attr_table[HEROATTRTYPE.CRIT_DMG] = self._attr_table[HEROATTRTYPE.CRIT_DMG] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.DEC_CRIT_DMG_CHANGE then
		if not self._attr_table[HEROATTRTYPE.DEC_CRIT_DMG] then
			self._attr_table[HEROATTRTYPE.DEC_CRIT_DMG] = 0
		end
		self._attr_table[HEROATTRTYPE.DEC_CRIT_DMG] = self._attr_table[HEROATTRTYPE.DEC_CRIT_DMG] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.BLOCK_CHANGE then
		if not self._attr_table[HEROATTRTYPE.BLOCK] then
			self._attr_table[HEROATTRTYPE.BLOCK] = 0
		end
		self._attr_table[HEROATTRTYPE.BLOCK] = self._attr_table[HEROATTRTYPE.BLOCK] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.DIS_BLOCK_CHANGE then
		if not self._attr_table[HEROATTRTYPE.DIS_BLOCK] then
			self._attr_table[HEROATTRTYPE.DIS_BLOCK] = 0
		end
		self._attr_table[HEROATTRTYPE.DIS_BLOCK] = self._attr_table[HEROATTRTYPE.DIS_BLOCK] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.STRONG then
		if not self._attr_table[HEROATTRTYPE.DEC_CRIT] then
			self._attr_table[HEROATTRTYPE.DEC_CRIT] = 0
		end
		if not self._attr_table[HEROATTRTYPE.BLOCK] then
			self._attr_table[HEROATTRTYPE.BLOCK] = 0
		end
		if not self._attr_table[HEROATTRTYPE.DEC_DMG] then
			self._attr_table[HEROATTRTYPE.DEC_DMG] = 0
		end
		if not self._attr_table[HEROATTRTYPE.MISS] then
			self._attr_table[HEROATTRTYPE.MISS] = 0
		end

		self._attr_table[HEROATTRTYPE.DEC_CRIT] = self._attr_table[HEROATTRTYPE.DEC_CRIT] + self._effect_param_1 * self._overlay
		self._attr_table[HEROATTRTYPE.BLOCK] = self._attr_table[HEROATTRTYPE.BLOCK] + self._effect_param_1 * self._overlay
		self._attr_table[HEROATTRTYPE.DEC_DMG] = self._attr_table[HEROATTRTYPE.DEC_DMG] + self._effect_param_2 * self._overlay
		self._attr_table[HEROATTRTYPE.MISS] = self._attr_table[HEROATTRTYPE.MISS] + self._effect_param_2 * self._overlay

	elseif self._effect == BUFFTYPE.SMARTER then
		if not self._attr_table[HEROATTRTYPE.DEC_CRIT] then
			self._attr_table[HEROATTRTYPE.DEC_CRIT] = 0
		end
		if not self._attr_table[HEROATTRTYPE.DEC_CRIT_DMG] then
			self._attr_table[HEROATTRTYPE.DEC_CRIT_DMG] = 0
		end
		if not self._attr_table[HEROATTRTYPE.DEC_DMG] then
			self._attr_table[HEROATTRTYPE.DEC_DMG] = 0
		end
		if not self._attr_table[HEROATTRTYPE.MISS] then
			self._attr_table[HEROATTRTYPE.MISS] = 0
		end

		self._attr_table[HEROATTRTYPE.DEC_CRIT] = self._attr_table[HEROATTRTYPE.DEC_CRIT] + self._effect_param_1 * self._overlay
		self._attr_table[HEROATTRTYPE.DEC_DMG] = self._attr_table[HEROATTRTYPE.DEC_DMG] + self._effect_param_1 * self._overlay
		self._attr_table[HEROATTRTYPE.DEC_CRIT_DMG] = self._attr_table[HEROATTRTYPE.DEC_CRIT_DMG] + self._effect_param_2 * self._overlay
		self._attr_table[HEROATTRTYPE.MISS] = self._attr_table[HEROATTRTYPE.MISS] + self._effect_param_2 * self._overlay

	elseif self._effect == BUFFTYPE.HEAL_CHANGE then
		if not self._attr_table[HEROATTRTYPE.HEAL] then
			self._attr_table[HEROATTRTYPE.HEAL] = 0
		end
		self._attr_table[HEROATTRTYPE.HEAL] = self._attr_table[HEROATTRTYPE.HEAL] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.BE_HEAL_CHANGE or self._effect == BUFFTYPE.HEAL_CHANGE_GIVE_HP then
		if not self._attr_table[HEROATTRTYPE.BE_HEAL] then
			self._attr_table[HEROATTRTYPE.BE_HEAL] = 0
		end
		self._attr_table[HEROATTRTYPE.BE_HEAL] = self._attr_table[HEROATTRTYPE.BE_HEAL] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.ANGER_CHANGE then
		if self._effect_param_1 > 0 then
			self._attach_role:AddAnger(self._effect_param_1, true)
		elseif self._effect_param_1 < 0 then
			self._attach_role:SubAnger(-self._effect_param_1)
		end
		-- if not self._attr_table[HEROATTRTYPE.ANGER] then
		-- 	self._attr_table[HEROATTRTYPE.ANGER] = 0
		-- end
		-- self._attr_table[HEROATTRTYPE.ANGER] = self._attr_table[HEROATTRTYPE.ANGER] + self._effect_param_1

	elseif self._effect == BUFFTYPE.POISON_DMG_CHANGE then
		if not self._attr_table[HEROATTRTYPE.INC_POISON] then
			self._attr_table[HEROATTRTYPE.INC_POISON] = 0
		end
		self._attr_table[HEROATTRTYPE.INC_POISON] = self._attr_table[HEROATTRTYPE.INC_POISON] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.POISON_DEF_CHANGE then
		if not self._attr_table[HEROATTRTYPE.DEC_POISON] then
			self._attr_table[HEROATTRTYPE.DEC_POISON] = 0
		end
		self._attr_table[HEROATTRTYPE.DEC_POISON] = self._attr_table[HEROATTRTYPE.DEC_POISON] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.BURNING_DMG_CHANGE then
		if not self._attr_table[HEROATTRTYPE.INC_BURN] then
			self._attr_table[HEROATTRTYPE.INC_BURN] = 0
		end
		self._attr_table[HEROATTRTYPE.INC_BURN] = self._attr_table[HEROATTRTYPE.INC_BURN] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.BURNING_DEF_CHANGE then
		if not self._attr_table[HEROATTRTYPE.DEC_BURN] then
			self._attr_table[HEROATTRTYPE.DEC_BURN] = 0
		end
		self._attr_table[HEROATTRTYPE.DEC_BURN] = self._attr_table[HEROATTRTYPE.DEC_BURN] + self._effect_param_1 * self._overlay

	elseif self._effect == BUFFTYPE.INC_DAMAGE_BY_ATK then
		if not self._attr_table[HEROATTRTYPE.ATK] then
			self._attr_table[HEROATTRTYPE.ATK] = 0
		end
		self._attr_table[HEROATTRTYPE.ATK] = self._num

	elseif self._effect == BUFFTYPE.CRIT_AND_CRIT_DAMAGE_CHANGE then
		if not self._attr_table[HEROATTRTYPE.CRIT] then
			self._attr_table[HEROATTRTYPE.CRIT] = 0
		end
		if not self._attr_table[HEROATTRTYPE.CRIT_DMG] then
			self._attr_table[HEROATTRTYPE.CRIT_DMG] = 0
		end

		self._attr_table[HEROATTRTYPE.CRIT] = self._attr_table[HEROATTRTYPE.CRIT] + self._effect_param_1 * self._overlay
		self._attr_table[HEROATTRTYPE.CRIT_DMG] = self._attr_table[HEROATTRTYPE.CRIT_DMG] + self._effect_param_2 * self._overlay

	end

	if self._attr_table then
		self._buff_manager:AddBuffAttr(self._attr_table)
	end
end

function Buff:DetachAttrBuff()
	if self._attr_table then
		self._buff_manager:RemoveBuffAttr(self._attr_table)
		self._attr_table = nil
	end
end

function Buff:UpdateOnSufferBeforeActor()
	if not self._attached or self._current_time < 0 then
		return
	end

	if self._effect == BUFFTYPE.POISONING or self._effect == BUFFTYPE.BURNING or self._effect == BUFFTYPE.POISONING_CRIT or self._effect == BUFFTYPE.BURNING_CRIT then
		if self._attach_role:IsDead() == false and self._attach_role:IsGod() == false then
			-- crit
			local damage = self._num
			if self._effect == BUFFTYPE.POISONING_CRIT or self._effect == BUFFTYPE.BURNING_CRIT then
				local crit_rate = max(self._caster:GetCritRate(), 0)
				local is_crit = false
				if random(1000) <= crit_rate then
					is_crit = true
				end
				if is_crit == true then
					damage = math.ceil(damage * self._caster:GetCritDmgRate() / 1000)
				end
			end

			self._attach_role:SubHp(damage * self._overlay, is_crit, false, 0, DAMAGE_EFFECT_TYPE.NORMAL, SKILL_OR_BUFF.BUFF, self._buff_id, self._caster:GetId(), self._caster:GetCamp())
		end
	elseif self._effect == BUFFTYPE.RECOVER then
		if self._attach_role:IsDead() == false and defender:GetLockHeal() == false and defender:GetPetrified() == false then
			local heal = self._num
			local crit_rate = max(self._caster:GetCritRate(), 0)
			local is_crit = false
			if random(1000) <= crit_rate then
				is_crit = true
			end
			if is_crit == true then
				heal = math.ceil(heal * self._caster:GetCritDmgRate() / 1000)
			end
			self._attach_role:AddHp(heal * self._overlay, SKILL_OR_BUFF.BUFF, self._buff_id, self._caster:GetId(), self._caster:GetCamp(), is_crit)
		end
	end
end

function Buff:Update()
	if not self._attached or self._attach_role:IsDead() or self._current_time < 0 then
		return
	end

	return self:SubBuffTime()
end

-- function Buff:ActionBeginUpdate()
-- 	if not self._attached or self._current_time <= 0 then
-- 		return
-- 	end

-- 	if self._effect == BUFFTYPE.POISONING or self._effect == BUFFTYPE.BURNING or self._effect == BUFFTYPE.POISONING_CRIT or self._effect == BUFFTYPE.BURNING_CRIT then
-- 		if self._attach_role:IsDead() == false and self._attach_role:IsGod() == false then
-- 			-- crit
-- 			local damage = self._num
-- 			if self._effect == BUFFTYPE.POISONING_CRIT or self._effect == BUFFTYPE.BURNING_CRIT then
-- 				local crit_rate = max(self._caster:GetCritRate(), 0)
-- 				local is_crit = false
-- 				if random(1000) <= crit_rate then
-- 					is_crit = true
-- 				end
-- 				if is_crit == true then
-- 					damage = math.ceil(damage * self._caster:GetCritDmgRate() / 1000)
-- 				end
-- 			end

-- 			self._attach_role:SubHp(damage * self._overlay, is_crit, false, 0, DAMAGE_EFFECT_TYPE.NORMAL, SKILL_OR_BUFF.BUFF, self._buff_id, self._caster:GetId(), self._caster:GetCamp())
-- 		end
-- 	elseif self._effect == BUFFTYPE.RECOVER then
-- 		if self._attach_role:IsDead() == false and defender:GetLockHeal() == false and defender:GetPetrified() == false then
-- 			local heal = self._num
-- 			local crit_rate = max(self._caster:GetCritRate(), 0)
-- 			local is_crit = false
-- 			if random(1000) <= crit_rate then
-- 				is_crit = true
-- 			end
-- 			if is_crit == true then
-- 				heal = math.ceil(heal * self._caster:GetCritDmgRate() / 1000)
-- 			end
-- 			self._attach_role:AddHp(heal * self._overlay, SKILL_OR_BUFF.BUFF, self._buff_id, self._caster:GetId(), self._caster:GetCamp(), is_crit)
-- 		end
-- 	end
-- end
--
-- function Buff:ActionEndUpdate()
-- 	if not self._attached or self._current_time <= 0 then
-- 		return
-- 	end

-- 	self:SubBuffTime()
-- end

function Buff:SubBuffTime()
	if self._new_buff then
		self._new_buff = false
		return false
	end

	if self._current_time > 0 then
		self._current_time = self._current_time - 1
		printDebug("Buff Change, suffer_id:%d, suffer_camp:%d, buff_id:%d, buff_time:%d", self._attach_role:GetId(), self._attach_role:GetCamp(), self._buff_id, self._current_time)
		FIGHT_PACK_MANAGER:BuffChange(self._attach_role:GetId(), self._attach_role:GetCamp(), self._buff_id, self._current_time, self._overlay)
	end

	if self._current_time <= 0 then
		self:Remove()
		return true
	end

	return false
end

function Buff:Remove()
	self._current_time = -1

	printDebug("Buff:Remove() Remove Buff, suffer_id:%d, suffer_camp:%d, buff_id:%d", self._attach_role:GetId(), self._attach_role:GetCamp(), self._buff_id)
	FIGHT_PACK_MANAGER:RemoveBuff(self._attach_role:GetId(), self._attach_role:GetCamp(), self._buff_id)

	if self:IsAttrBuff() then
		self:DetachAttrBuff()
	end

	if self._num then
		self._num = 0
	end

	-- self._caster:RemoveSelfCastBuff(self)
end

function Buff:Refresh(caster)
	self:CheckEffect()
	if self._max_overlay > 1 and self._overlay < self._max_overlay then
		self._overlay = self._overlay + 1

		if self:IsAttrBuff() then
			self:AttachAttrBuff()
		end
	end
	self._current_time = self._buff_time

	self._caster = caster
	self._new_buff = true

	printDebug("Refresh Buff, caster_id:%d, caster_camp:%d, suffer_id:%d, suffer_camp:%d, buff_id:%d, buff_time:%d, overlay:%d", self._caster:GetId(), self._caster:GetCamp(), self._attach_role:GetId(), self._attach_role:GetCamp(), self._buff_id, self._current_time, self._overlay)
	FIGHT_PACK_MANAGER:BuffChange(self._caster:GetId(), self._caster:GetCamp(), self._buff_id, self._current_time, self._overlay)
end

function Buff:GetBuffTime()
	--if self._effect == BUFFTYPE.SHIELD and self._num > 0 then
	--	return 1
	--end
	 return self._current_time
end

function Buff:GetDizz()
	if self._effect == BUFFTYPE.DIZZ and self._current_time > 0 then
		return true
	end
	return false
end

function Buff:HasSneerBuff()
	if self._effect == BUFFTYPE.SNEER and self._current_time > 0 then
		return true
	end
	return false
end

function Buff:GetSilence()
	if self._effect == BUFFTYPE.SILENCE and self._current_time > 0 then
		return true
	end
	return false
end

function Buff:SubShield(hp)
	if self._current_time <= 0 or (self._effect ~= BUFFTYPE.SHIELD and self._effect ~= BUFFTYPE.EXCESSIVE_HEAL_SHIELD) then
		return 0, false
	end

	if self._num > hp then
		self._num = self._num - hp
		return hp, false
	elseif self._num <= hp and self._num > 0 then
		local num = self._num
		self._num = 0
		return num, true
	end

	return 0, false

end

function Buff:HasLockAngerInc()
	if self._effect == BUFFTYPE.LOCK_ANGER_INC and self._current_time > 0 then
		return true
	end
	return false
end

function Buff:HasLockAngerDec()
	if self._effect == BUFFTYPE.LOCK_ANGER_DEC and self._current_time > 0 then
		return true
	end
	return false
end

function Buff:CheckGetAnger()
	if self._effect == BUFFTYPE.GET_ANGER and self._current_time > 0 then
		if random(1000) <= self._effect_param_1 and not self._attach_role:IsDead() then
			self._attach_role:AddAnger(self._effect_param_2, true)
		end
	end
end

function Buff:IsGod()
	if self._effect == BUFFTYPE.GOD and self._current_time > 0 then
		return true
	end
	return false
end

function Buff:GetLockHeal()
	if self._effect == BUFFTYPE.LOCK_HEAL and self._current_time > 0 then
		return true
	end
	return false
end

function Buff:GetPetrified()
	if self._effect == BUFFTYPE.PETRIFIED and self._current_time > 0 then
		return true
	end
	return false
end

function Buff:GetBuffHealByDamage(damage)
	if self._effect == BUFFTYPE.HEAL_CHANGE_GIVE_HP and self._current_time > 0 then
		return math.ceil(self._effect_param_2 * damage / 1000)
	end
	return 0
end

function Buff:GetRebornHealFactor()
	if self._effect == BUFFTYPE.REBORN and self._current_time > 0 then
		return self._effect_param_1
	end
	return 0
end

function Buff:CanDispel()
	return self._is_remove
end

function Buff:CanClean()
	return self._is_clean
end

function Buff:GetBuffId()
	return self._buff_id
end

function Buff:GetBoomByIdCamp(id, camp)
	if self._effect == BUFFTYPE.BOOM and self._caster:GetId() == id and self._caster:GetCamp() == camp and self._current_time > 0 then
		return true
	end
	return false
end

function Buff:GetBoom()
	if self._effect == BUFFTYPE.BOOM and self._current_time > 0 then
		return true
	end
	return false
end

function Buff:RunBoom()
	self._attach_role:SubHp(self._num, false, false, 0, DAMAGE_EFFECT_TYPE.NORMAL, SKILL_OR_BUFF.BUFF, self._buff_id, self._caster:GetId(), self._caster:GetCamp())
end

function Buff:GetReflectDamage(damage)
	if self._effect == BUFFTYPE.REFLECT and self._current_time > 0 then
		return math.ceil(damage * self._effect_param_1 / 1000)
	end

	return 0
end

function Buff:GetDoubleDamageRate()
	if self._effect == BUFFTYPE.DOUBLE_DMG and self._current_time > 0 then
		return self._effect_param_1
	end
	return 0
end

function Buff:GetDeathKillRate()
	if self._effect == BUFFTYPE.DEATH_KILL and self._current_time > 0 then
		return self._effect_param_1
	end
	return 0
end

function Buff:GetImmuneBuff()
	if self._effect == BUFFTYPE.IMMUNE and self._current_time > 0 then
		return true
	end
	return false
end

function Buff:GetMissHealFactor()
	if self._effect == BUFFTYPE.MISS_HEAL and self._current_time > 0 then
		return self._effect_param_1
	end
	return 0
end

function Buff:IsBuff()
	return self._is_remove
end

function Buff:IsDebuff()
	return self._is_clean
end

function Buff:GetBuffEffect()
	return self._effect
end

function Buff:GetOverlay()
	return self._overlay
end

function Buff:GetDecDmgByEffect()
	if self._effect == BUFFTYPE.INC_DAMAGE_BY_EFFECT and self._current_time > 0 then
		return self._buff_manager:GetBuffCountByEffect(self._effect_param_1) * self._effect_param_2
	end

	return 0
end

-- ==========================================================================
-- ==========================================================================
-- ==========================================================================

-- function Buff:HasSneerBuff()
-- 	if self._effect == BUFFTYPE.SNEER and self._current_time > 0 then
-- 		return true
-- 	end
-- 	return false
-- end

-- function Buff:GetEffect()
-- 	return self._effect
-- end

-- function Buff:GetId()
-- 	return self._buff_id
-- end

-- -- function Buff:GetAtkChange()
-- -- 	if self._effect == BUFFTYPE.ATKCHANGE and self._current_time > 0 then
-- -- 		return self._effect_param_1
-- -- 	end
-- -- 	return 0
-- -- end

-- -- function Buff:GetDefendChange()
-- -- 	if self._effect == BUFFTYPE.DEFENDCHANGE and self._current_time > 0 then
-- -- 		return self._effect_param_1
-- -- 	end
-- -- 	return 0
-- -- end

-- -- function Buff:GetSpeedChange()
-- -- 	if self._effect == BUFFTYPE.SPEEDCHANGE and self._current_time > 0 then
-- -- 		return self._effect_param_1
-- -- 	end
-- -- 	return 0
-- -- end

-- function Buff:IsSecoundAction()
-- 	if self._effect == BUFFTYPE.SECORDACTION and self._current_time > 0 then
-- 		return true
-- 	end
-- 	return false
-- end



-- function Buff:GetLastHurt()

-- end

-- function Buff:GetOverLapLastHurt()

-- end

-- function Buff:GetHeart()
-- 	if self._effect == BUFFTYPE.HEART and self._current_time > 0 then
-- 		return self._effect_param_1
-- 	end
-- 	return 0
-- end

-- function Buff:GetRecover()

-- end

-- function Buff:GetWeaken()
-- 	if self._effect == BUFFTYPE.WEAKEN and self._current_time > 0 then
-- 		return self._effect_param_1
-- 	end
-- 	return 0
-- end

-- function Buff:SubBoutShield(hp)
-- 	if self._effect ~= BUFFTYPE.BOUTSHIELD or self._current_time <= 0 then
-- 		return 0
-- 	end
-- 	if self._num >= hp then
-- 		return hp
-- 	elseif self._num < hp and self._num > 0 then
-- 		return self._num
-- 	end
-- end

-- function Buff:ChunGeEffect()
-- 	if self._effect == BUFFTYPE.CHUNGE and self._current_time > 0 then
-- 		self._attach_role:AddHp(self._num, SKILL_OR_BUFF.BUFF, self._buff_id)
-- 	end
-- end

-- function Buff:GetSubHurt()
-- 	 if self._effect == BUFFTYPE.SUBHURT and self._current_time > 0 then
-- 		 return self._effect_param_1
-- 	 end
-- 	 return 0
-- end

-- function Buff:HasChunGe()
-- 	if self._effect == BUFFTYPE.CHUNGE and self._num >= 0 and self._current_time > 0 then
-- 		return self
-- 	end
-- 	return nil
-- end

-- function Buff:HasSaberGift()
-- 	if self._effect == BUFFTYPE.SABERGIFT and self._current_time > 0 then
-- 		return self._effect_param_1
-- 	end
-- 	return 0
-- end

-- function Buff:HasLancerGift(num)
-- 	if self._effect ~= BUFFTYPE.LANCERGIFT or self._current_time <= 0  then
-- 		return 0
-- 	end

-- 	local r = random(100)
-- 	if (self._effect_param_2 >= r) and ((num / self._attach_role:GetBaseHp()) > (self._effect_param_1 / 100)) then
-- 		local hp = self._attach_role:GetBaseHp() * self._effect_param_1 / 100
-- 		local x, juddge_num = self._attach_role._buff_manager:HasJudderBuff()
-- 		if self._attach_role:GetHp() / self._attach_role:GetBaseHp() < 0.4 then
-- 			hp = hp + hp * juddge_num / 100
-- 		end
-- 		self._attach_role:AddHp(hp, SKILL_OR_BUFF.BUFF, self._buff_id, self._caster:GetId(), self._caster:GetCamp())
-- 	end
-- end

-- function Buff:HasArcherGift()
-- 	if self._effect == BUFFTYPE.ARCHERGIFT and self._current_time > 0 then
-- 		return self._effect_param_1
-- 	end
-- 	return 0
-- end

-- function Buff:HasBerserkerGift()
-- 	if self._effect == BUFFTYPE.BERSERKERGIFT and self._current_time > 0 then
-- 		if self._attach_role:IsBoss() == false and (self._attach_role:GetHp() / self._attach_role:GetBaseHp()) < (self._effect_param_1 / 100) then
-- 			return true
-- 		-- elseif self._attach_role:IsBoss() == true and ((self._attach_role:GetHp() + self._attach_role:GetBaseHp() * self._attach_role:GetBossHp()) / (self._attach_role:GetBaseHp() * self._attach_role:GetHpStripStatic())) < (self._effect_param_1 / 100) then
-- 		-- 	return true
-- 		end
-- 	end
-- 	return false
-- end

-- function Buff:HasCasterGift()
-- 	if self._effect == BUFFTYPE.CASTERGIFT and self._effect_param_1 >= random(100) and self._current_time > 0 then
-- 		return self._effect_param_2
-- 	end
-- 	return 0
-- end

-- function Buff:GetGrowUp()
-- 	if self._effect == BUFFTYPE.GROWUP and self._current_time > 0 then
-- 		return self._effect_param_1
-- 	end
-- 	return 0
-- end

-- function Buff:AddShangBiLevelRate()
-- 	if self._effect == BUFFTYPE.SHANGBI and self._current_time > 0 then
-- 		return self._effect_param_1
-- 	end
-- 	return 0
-- end

-- function Buff:RunSub50RateHp()
-- 	if self._effect == BUFFTYPE.RELEASESSKILLSUBHP and self._current_time > 0 then
-- 		local num = self._attach_role:GetCurrentHp() * 0.5
-- 		if num < 1 then
-- 			return
-- 		end
-- 		self._attach_role:SubHp(num, false, false, 0, self._effect_type, SKILL_OR_BUFF.BUFF, self._buff_id, self._caster:GetId(), self._caster:GetCamp())
-- 	end
-- end

-- function Buff:RunSub50RateHpNormal()
-- 	if self._effect == BUFFTYPE.NORMALSKILLSUBHP and self._current_time > 0 then
-- 		local num = self._attach_role:GetCurrentHp() * 0.5
-- 		if num < 1 then
-- 			return
-- 		end
-- 		self._attach_role:SubHp(num, false, false, 0, self._effect_type, SKILL_OR_BUFF.BUFF, self._buff_id, self._caster:GetId(), self._caster:GetCamp())
-- 	end
-- end

-- function Buff:HasJudderBuff()
-- 	if self._effect == BUFFTYPE.JUDDERBUFF and self._current_time > 0 then
-- 		return self._effect_param_1, self._effect_param_2
-- 	end
-- 	return 0, 0
-- end

-- function Buff:GetAtkDefHpUp()
-- 	if self._effect == BUFFTYPE.ATKDEFHPUP and self._current_time > 0 then
-- 		return self._effect_param_1
-- 	end
-- 	return 0
-- end

-- function Buff:ReSetThiredHurt()
-- 	self._thired_hurt = 0
-- end

-- function Buff:AddRengXing()
-- 	if self._effect == BUFFTYPE.RENGXING and self._current_time > 0 then
-- 		return self._effect_param_1
-- 	end
-- 	return 0
-- end

-- function Buff:RiderBuff(role)
-- 	if self._effect == BUFFTYPE.RIDER and self._attach_role:GetSpeed() > role:GetSpeed() and self._current_time > 0 then
-- 		return self._effect_param_1
-- 	end
-- 	return 0
-- end

-- function Buff:SurviveLife()
-- 	if self._effect == BUFFTYPE.SURVIVELIFE and self._current_time > 0 then
-- 		return true
-- 	end
-- 	return false
-- end

return Buff
