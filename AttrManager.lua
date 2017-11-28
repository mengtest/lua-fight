local AttrManager = class("AttrManager")

function AttrManager:ctor(hero_controller, data, cur_hp, cur_anger, level)
	self._attr = {}
	self._current_hp = 0
	-- self._max_hp = 0
	self._current_anger = 0
	-- self._max_anger = 0
	-- self._attr_table = {}
	self._level = level
	self._hero_controller = hero_controller
	self:Init(cur_hp, cur_anger, data)
	self:InitAttrTable()
end

function AttrManager:Init(hp, anger, static_data)
	-- hp
	-- self._max_hp = math.ceil(static_data[HEROATTRTYPE.HP] * (1 + static_data[HEROATTRTYPE.HP_PERCENT]/1000))


	-- anger
	-- self._max_anger = ANGERTYPE.FULLANGER
	-- self._attr[HEROATTRTYPE.ANGER] = static_data[HEROATTRTYPE.ANGER]
	if anger > 0 then
		self._current_anger = anger
	else
		self._current_anger = static_data[HEROATTRTYPE.ANGER]
	end

	-- other
	self._attr[HEROATTRTYPE.HP] 					= static_data[HEROATTRTYPE.HP]
	self._attr[HEROATTRTYPE.ANGER] 					= static_data[HEROATTRTYPE.ANGER]
	self._attr[HEROATTRTYPE.ATK] 					= static_data[HEROATTRTYPE.ATK]
	self._attr[HEROATTRTYPE.DEF] 					= static_data[HEROATTRTYPE.DEF]
	self._attr[HEROATTRTYPE.ATK_PERCENT] 			= static_data[HEROATTRTYPE.ATK_PERCENT]
	self._attr[HEROATTRTYPE.DEF_PERCENT] 			= static_data[HEROATTRTYPE.DEF_PERCENT]
	self._attr[HEROATTRTYPE.HP_PERCENT] 			= static_data[HEROATTRTYPE.HP_PERCENT]
	self._attr[HEROATTRTYPE.CRIT] 					= static_data[HEROATTRTYPE.CRIT]
	self._attr[HEROATTRTYPE.DEC_CRIT] 				= static_data[HEROATTRTYPE.DEC_CRIT]
	self._attr[HEROATTRTYPE.HIT] 					= static_data[HEROATTRTYPE.HIT]
	self._attr[HEROATTRTYPE.MISS] 					= static_data[HEROATTRTYPE.MISS]
	self._attr[HEROATTRTYPE.CRIT_DMG] 				= static_data[HEROATTRTYPE.CRIT_DMG]
	self._attr[HEROATTRTYPE.DEC_CRIT_DMG] 			= static_data[HEROATTRTYPE.DEC_CRIT_DMG]
	self._attr[HEROATTRTYPE.INC_DMG] 				= static_data[HEROATTRTYPE.INC_DMG]
	self._attr[HEROATTRTYPE.DEC_DMG] 				= static_data[HEROATTRTYPE.DEC_DMG]
	self._attr[HEROATTRTYPE.INC_POISON] 			= static_data[HEROATTRTYPE.INC_POISON]
	self._attr[HEROATTRTYPE.DEC_POISON] 			= static_data[HEROATTRTYPE.DEC_POISON]
	self._attr[HEROATTRTYPE.INC_BURN] 				= static_data[HEROATTRTYPE.INC_BURN]
	self._attr[HEROATTRTYPE.DEC_BURN] 				= static_data[HEROATTRTYPE.DEC_BURN]
	self._attr[HEROATTRTYPE.HEAL] 					= static_data[HEROATTRTYPE.HEAL]
	self._attr[HEROATTRTYPE.BE_HEAL] 				= static_data[HEROATTRTYPE.BE_HEAL]
	self._attr[HEROATTRTYPE.BLOCK] 					= static_data[HEROATTRTYPE.BLOCK]
	self._attr[HEROATTRTYPE.DIS_BLOCK] 				= static_data[HEROATTRTYPE.DIS_BLOCK]
	self._attr[HEROATTRTYPE.PVP_INC_DMG] 			= static_data[HEROATTRTYPE.PVP_INC_DMG]
	self._attr[HEROATTRTYPE.PVP_DEC_DMG] 			= static_data[HEROATTRTYPE.PVP_DEC_DMG]
	self._attr[HEROATTRTYPE.BEAT_BACK] 				= static_data[HEROATTRTYPE.BEAT_BACK]
	self._attr[HEROATTRTYPE.REFLECT_RATE] 			= static_data[HEROATTRTYPE.REFLECT_RATE]
	self._attr[HEROATTRTYPE.REFLECT_DMG] 			= static_data[HEROATTRTYPE.REFLECT_DMG]
	self._attr[HEROATTRTYPE.HOLY_DMG] 				= static_data[HEROATTRTYPE.HOLY_DMG]
	self._attr[HEROATTRTYPE.HOLY_CRIT] 				= static_data[HEROATTRTYPE.HOLY_CRIT]
	self._attr[HEROATTRTYPE.SELF_HEAL] 				= static_data[HEROATTRTYPE.SELF_HEAL]
	self._attr[HEROATTRTYPE.FORCE_SELF_HEAL] 		= static_data[HEROATTRTYPE.FORCE_SELF_HEAL]
	self._attr[HEROATTRTYPE.VAMPIRISM] 				= static_data[HEROATTRTYPE.VAMPIRISM]
	self._attr[HEROATTRTYPE.VAMPIRISM_RESISTANCE] 	= static_data[HEROATTRTYPE.VAMPIRISM_RESISTANCE]

	local max_hp = self:GetMaxHp()
	if hp <= 0 or hp >= max_hp then
		self._current_hp = max_hp
	else
		self._current_hp = hp
	end

	-- if self._current_hp <= 0 then
	-- 	self._hero_controller:Die()
	-- end
end

function AttrManager:InitAttrTable()

end

function AttrManager:GetAttrTable()
	local attr_table = {
		ATK 						= self:GetAtk(),
		DEF 						= self:GetDef(),
		HP 							= self:GetCurrentHp(),
		MAX_HP						= self:GetMaxHp(),
		ATK_PERCENT					= self:GetAtkRate(),
		DEF_PERCENT					= self:GetDefRate(),
		HP_PERCENT					= self:GetHpRate(),
		CRIT						= self:GetCritRate(),
		DEC_CRIT					= self:GetDecCritRate(),
		HIT							= self:GetHitRate(),
		MISS						= self:GetMissRate(),
		CRIT_DMG 					= self:GetCritDamageRate(),
		DEC_CRIT_DMG 				= self:GetDecCritDamageRate(),
		INC_DMG 					= self:GetIncDamageRate(),
		DEC_DMG 					= self:GetDecDamageRate(),
		INC_POISON					= self:GetIncPoisonRate(),
		DEC_POISON					= self:GetDecPoisonRate(),
		INC_BURN					= self:GetIncBurnRate(),
		DEC_BURN					= self:GetIncBurnRate(),
		HEAL 						= self:GetHealRate(),
		BE_HEAL						= self:GetBeHealRate(),
		BLOCK 						= self:GetBlockRate(),
		DIS_BLOCK					= self:GetDisBlockRate(),
		PVP_INC_DMG					= self:GetPvpIncDamage(),
		PVP_DEC_DMG					= self:GetPvpDecDamage(),
		BEAT_BACK					= 0,
		REFLECT_RATE				= 0,
		REFLECT_DMG					= 0,
		HOLY_DMG					= 0,
		HOLY_CRIT					= 0,
		SELF_HEAL 					= 0,
		FORCE_SELF_HEAL 			= 0,
		VAMPIRISM 					= 0,
		VAMPIRISM_RESISTANCE		= 0,
		ANGER 						= self:GetAnger(),
		LEVEL 						= self._level
	}
	return attr_table
end

-- function AttrManager:GetHp()
-- 	return self._attr[HEROATTRTYPE.HP] + self:GetBuffAddAttr(HEROATTRTYPE.HP)
-- end

function AttrManager:GetHpRate()
	return self._attr[HEROATTRTYPE.HP_PERCENT] + self:GetBuffAddAttr(HEROATTRTYPE.HP_PERCENT)
end

function AttrManager:GetCurrentHp()
	local max_hp = self:GetMaxHp()
	local result = math.ceil(self._current_hp + self:GetBuffAddAttr(HEROATTRTYPE.HP))
	if result > max_hp then
		result = max_hp
		self._current_hp = max_hp
	end
	return result
end

function AttrManager:GetMaxHp()
	return math.floor(self._attr[HEROATTRTYPE.HP] * (1 + self:GetHpRate()/1000) + self:GetBuffAddAttr(HEROATTRTYPE.HP))
end

function AttrManager:SubHp(sub_hp)
	self._current_hp = self._current_hp - sub_hp
	if self._current_hp < 0 then
		self._current_hp = 0
	end
	return self._current_hp
end

function AttrManager:AddHp(num)
	self._current_hp = self._current_hp + num
	local max_hp = self:GetMaxHp()
	if self._current_hp > max_hp then
		self._current_hp = max_hp
	end
	return self._current_hp
end

function AttrManager:GetAnger()
	if self._current_anger < 0 then
		self._current_anger = 0
	end
	return self._current_anger
end

function AttrManager:SubAnger(sub_anger)
	self._current_anger = self._current_anger - sub_anger
	if self._current_anger < 0 then
		self._current_anger = 0
	end
	return self._current_anger
end

function AttrManager:AddAnger(num, force)
	if self._current_anger + num > ANGERTYPE.FULLANGER and not force then
		self._current_anger = ANGERTYPE.FULLANGER
	else
		self._current_anger = self._current_anger + num
		if self._current_anger > ANGERTYPE.MAXANGER then
			self._current_anger = ANGERTYPE.MAXANGER
		end
	end
end

function AttrManager:CleanAnger()
	self._current_anger = 0
end

function AttrManager:GetAtk()
	return math.ceil(self._attr[HEROATTRTYPE.ATK] * (1 + self:GetAtkRate()/1000) + self:GetBuffAddAttr(HEROATTRTYPE.ATK) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.ATK) or 0))
end

function AttrManager:GetAtkRate()
	return math.ceil(self._attr[HEROATTRTYPE.ATK_PERCENT] + self:GetBuffAddAttr(HEROATTRTYPE.ATK_PERCENT) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.ATK_PERCENT) or 0))
end

function AttrManager:GetDef()
	return math.ceil(self._attr[HEROATTRTYPE.DEF] * (1 + self:GetDefRate()/1000) + self:GetBuffAddAttr(HEROATTRTYPE.DEF) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.DEF) or 0))
end

function AttrManager:GetDefRate()
	return math.ceil(self._attr[HEROATTRTYPE.DEF_PERCENT] + self:GetBuffAddAttr(HEROATTRTYPE.DEF_PERCENT) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.DEF_PERCENT) or 0))
end

function AttrManager:GetCritRate()
	return math.ceil(self._attr[HEROATTRTYPE.CRIT] + self:GetBuffAddAttr(HEROATTRTYPE.CRIT) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.CRIT) or 0))
end

function AttrManager:GetDecCritRate()
	return math.ceil(self._attr[HEROATTRTYPE.DEC_CRIT] + self:GetBuffAddAttr(HEROATTRTYPE.DEC_CRIT) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.DEC_CRIT) or 0))
end

function AttrManager:GetHitRate()
	return math.ceil(self._attr[HEROATTRTYPE.HIT] + self:GetBuffAddAttr(HEROATTRTYPE.HIT) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.HIT) or 0))
end

function AttrManager:GetMissRate()
	return math.ceil(self._attr[HEROATTRTYPE.MISS] + self:GetBuffAddAttr(HEROATTRTYPE.MISS) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.MISS) or 0))
end

function AttrManager:GetCritDamageRate()
	return math.ceil(self._attr[HEROATTRTYPE.CRIT_DMG] + self:GetBuffAddAttr(HEROATTRTYPE.CRIT_DMG) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.CRIT_DMG) or 0))
end

function AttrManager:GetDecCritDamageRate()
	return math.ceil(self._attr[HEROATTRTYPE.DEC_CRIT_DMG] + self:GetBuffAddAttr(HEROATTRTYPE.DEC_CRIT_DMG) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.DEC_CRIT_DMG) or 0))
end

function AttrManager:GetIncDamageRate()
	local special_addon_inc_dmg = self._hero_controller:GetSpecialMgr():GetSpecialAddonIncDmg()
	return math.ceil(self._attr[HEROATTRTYPE.INC_DMG] + self:GetBuffAddAttr(HEROATTRTYPE.INC_DMG) + (special_addon_inc_dmg or 0) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.INC_DMG) or 0))
end

function AttrManager:GetDecDamageRate()
	local special_addon_dec_dmg = self._hero_controller:GetSpecialMgr():GetSpecialAddonDecDmg()
	return math.ceil(self._attr[HEROATTRTYPE.DEC_DMG] + self:GetBuffAddAttr(HEROATTRTYPE.DEC_DMG) + (special_addon_dec_dmg or 0) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.DEC_DMG) or 0) - (self._hero_controller._buff_manager:GetDecDmgByEffect() or 0))
end

function AttrManager:GetIncPoisonRate()
	return math.ceil(self._attr[HEROATTRTYPE.INC_POISON] + self:GetBuffAddAttr(HEROATTRTYPE.INC_POISON) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.INC_POISON) or 0))
end

function AttrManager:GetDecPoisonRate()
	return math.ceil(self._attr[HEROATTRTYPE.DEC_POISON] + self:GetBuffAddAttr(HEROATTRTYPE.DEC_POISON) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.DEC_POISON) or 0))
end

function AttrManager:GetIncBurnRate()
	return math.ceil(self._attr[HEROATTRTYPE.INC_BURN] + self:GetBuffAddAttr(HEROATTRTYPE.INC_BURN) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.INC_BURN) or 0))
end

function AttrManager:GetDecBurnRate()
	return math.ceil(self._attr[HEROATTRTYPE.DEC_BURN] + self:GetBuffAddAttr(HEROATTRTYPE.DEC_BURN) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.DEC_BURN) or 0))
end

function AttrManager:GetHealRate()
	return math.ceil(self._attr[HEROATTRTYPE.HEAL] + self:GetBuffAddAttr(HEROATTRTYPE.HEAL) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.HEAL) or 0))
end

function AttrManager:GetBeHealRate()
	return math.ceil(self._attr[HEROATTRTYPE.BE_HEAL] + self:GetBuffAddAttr(HEROATTRTYPE.BE_HEAL) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.BE_HEAL) or 0))
end

function AttrManager:GetBlockRate()
	return math.ceil(self._attr[HEROATTRTYPE.BLOCK] + self:GetBuffAddAttr(HEROATTRTYPE.BLOCK) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.BLOCK) or 0))
end

function AttrManager:GetDisBlockRate()
	return math.ceil(self._attr[HEROATTRTYPE.DIS_BLOCK] + self:GetBuffAddAttr(HEROATTRTYPE.DIS_BLOCK) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.DIS_BLOCK) or 0))
end

function AttrManager:GetPvpIncDamage()
	return math.ceil(self._attr[HEROATTRTYPE.PVP_INC_DMG] + self:GetBuffAddAttr(HEROATTRTYPE.PVP_INC_DMG) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.PVP_INC_DMG) or 0))
end

function AttrManager:GetPvpDecDamage()
	return math.ceil(self._attr[HEROATTRTYPE.PVP_DEC_DMG] + self:GetBuffAddAttr(HEROATTRTYPE.PVP_DEC_DMG) + (self._hero_controller:GetSpecialMgr():GetUnderDebuffAttr(HEROATTRTYPE.PVP_DEC_DMG) or 0))
end

function AttrManager:GetAttrById(attr_id)
	if attr_id < HEROATTRTYPE.ATK or attr_id > HEROATTRTYPE.ANGER then
		return -1
	end

	local attr_value = self._attr[attr_id]
	attr_value = attr_value + self:GetBuffAddAttr(attr_id)
	return attr_value
end

function AttrManager:AddAttr(attr_id, attr_value)
	if attr_id < HEROATTRTYPE.ATK or attr_id > HEROATTRTYPE.ANGER then
		return
	end

	self._attr[attr_id] = (self._attr[attr_id] or 0) + attr_value

	if attr_id == HEROATTRTYPE.HP then
		self._current_hp = self._current_hp + attr_value
	end

	if attr_id == HEROATTRTYPE.ANGER then
		self._current_anger = self._current_anger + attr_value
	end

end

function AttrManager:SubAttr(attr_id, attr_value)
	if attr_id < HEROATTRTYPE.ATK or attr_id > HEROATTRTYPE.ANGER then
		return
	end

	self._attr[attr_id] = (self._attr[attr_id] or 0) - attr_value

	if attr_id == HEROATTRTYPE.HP then
		self._current_hp = self._current_hp - attr_value
		if self._current_hp < 0 then
			self._current_hp = 0
		end
	end

	if attr_id == HEROATTRTYPE.ANGER then
		self._current_anger = self._current_anger - attr_value
		if self._current_anger < 0 then
			self._current_anger = 0
		end
	end

end

function AttrManager:GetBuffAddAttr(attr_id)
	return self._hero_controller._buff_manager:GetAddAttrValue(attr_id)
end
-- ==============================================================================================
-- ==============================================================================================
-- ==============================================================================================

-- function AttrManager:GetCureUp()

-- 	local num = self._attr[HEROATTRTYPE.CUREUP] * self._attr_rate[HEROATTRTYPE.CUREUP] / 100
-- 	if num < 0 then num = 0 end
-- 	if num > 10000 then num	= 10000 end
-- 	return num
-- end

-- function AttrManager:AddCureUp(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.CUREUP] = self._attr[HEROATTRTYPE.CUREUP] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.CUREUP] = self._attr_rate[HEROATTRTYPE.CUREUP] + num
-- 	end
-- end

-- function AttrManager:SubCureUp(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.CUREUP] = self._attr[HEROATTRTYPE.CUREUP] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.CUREUP] = self._attr_rate[HEROATTRTYPE.CUREUP] - num
-- 	end
-- end

-- function AttrManager:GetVioLevel()
-- 	local num = self._attr[HEROATTRTYPE.VIOLEVEL] * self._attr_rate[HEROATTRTYPE.VIOLEVEL] / 100
-- 	return num
-- end

-- function AttrManager:AddVioLevel(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.VIOLEVEL] = self._attr[HEROATTRTYPE.VIOLEVEL] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.VIOLEVEL] = self._attr_rate[HEROATTRTYPE.VIOLEVEL] + num
-- 	end
-- end

-- function AttrManager:SubVioLevel(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.VIOLEVEL] = self._attr[HEROATTRTYPE.VIOLEVEL] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.VIOLEVEL] = self._attr_rate[HEROATTRTYPE.VIOLEVEL] - num
-- 	end
-- end

-- function AttrManager:GetSSkillRate()
-- 	local num =	self._attr[HEROATTRTYPE.SUPERSKILL_RATE] * self._attr_rate[HEROATTRTYPE.SUPERSKILL_RATE] / 100
-- 	return num
-- end

-- function AttrManager:GetPVPHurtReduce()
-- 	local num =	self._attr[HEROATTRTYPE.PVP_HURTREDUCE] * self._attr_rate[HEROATTRTYPE.PVP_HURTREDUCE] / 100
-- 	if num < 0 then
-- 		return 0
-- 	elseif num > 10000 then
-- 		return 10000
-- 	end
-- 	return num
-- end

-- function AttrManager:ReSetHp()
-- 	self._attr[HEROATTRTYPE.HP] = self:GetBaseHp()
-- end

-- function AttrManager:AddPVPHurtReduce(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.PVP_HURTREDUCE] = self._attr[HEROATTRTYPE.PVP_HURTREDUCE] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.PVP_HURTREDUCE] = self._attr_rate[HEROATTRTYPE.PVP_HURTREDUCE] + num
-- 	end
-- end

-- function AttrManager:SubPVPHurtReduce(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.PVP_HURTREDUCE] = self._attr[HEROATTRTYPE.PVP_HURTREDUCE] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.PVP_HURTREDUCE] = self._attr_rate[HEROATTRTYPE.PVP_HURTREDUCE] - num
-- 	end
-- end


-- function AttrManager:GetPVPHurtAddon()
-- 	local num =	self._attr[HEROATTRTYPE.PVP_HURTADDON] * self._attr_rate[HEROATTRTYPE.PVP_HURTADDON] / 100
-- 	if num < 0 then
-- 		return 0
-- 	elseif num > 10000 then
-- 		return 10000
-- 	end
-- 	return num
-- end

-- function AttrManager:AddPVPHurtAddon(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.PVP_HURTADDON] = self._attr[HEROATTRTYPE.PVP_HURTADDON] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.PVP_HURTADDON] = self._attr_rate[HEROATTRTYPE.PVP_HURTADDON] + num
-- 	end
-- end

-- function AttrManager:SetWuLiAtk(num)
-- 	self._attr[HEROATTRTYPE.WULI_ATTACK] = num
-- end

-- function AttrManager:SetMoFaAtk(num)
-- 	self._attr[HEROATTRTYPE.MOFA_ATTACK] = num
-- end

-- function AttrManager:SubPVPHurtAddon(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.PVP_HURTADDON] = self._attr[HEROATTRTYPE.PVP_HURTADDON] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.PVP_HURTADDON] = self._attr_rate[HEROATTRTYPE.PVP_HURTADDON] - num
-- 	end
-- end

-- function AttrManager:GetRecove()
-- 	local num = self._attr[HEROATTRTYPE.RECOVERY] * self._attr_rate[HEROATTRTYPE.RECOVERY] / 100
-- 	return num
-- end

-- function AttrManager:SubSSkillRate(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.SUPERSKILL_RATE] = self._attr[HEROATTRTYPE.SUPERSKILL_RATE] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.SUPERSKILL_RATE] = self._attr_rate[HEROATTRTYPE.SUPERSKILL_RATE] - num
-- 	end
-- end

-- function AttrManager:AddSSkillRate(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.SUPERSKILL_RATE] = self._attr[HEROATTRTYPE.SUPERSKILL_RATE] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.SUPERSKILL_RATE] = self._attr_rate[HEROATTRTYPE.SUPERSKILL_RATE] + num
-- 	end
-- end

-- function AttrManager:SubRecove(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.RECOVERY] = self._attr[HEROATTRTYPE.RECOVERY] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.RECOVERY] = self._attr_rate[HEROATTRTYPE.RECOVERY] - num
-- 	end
-- end

-- function AttrManager:AddRecove(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.RECOVERY] = self._attr[HEROATTRTYPE.RECOVERY] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.RECOVERY] = self._attr_rate[HEROATTRTYPE.RECOVERY] - num
-- 	end
-- end

-- function AttrManager:GetHurtReduceRate()
-- 	local num = self._attr[HEROATTRTYPE.HURT_REDUCE_RATE] * self._attr_rate[HEROATTRTYPE.HURT_REDUCE_RATE] / 100
-- 	if num < 0 then
-- 		return 0
-- 	elseif num > 100 then
-- 		return 100
-- 	end
-- 	return num
-- end

-- function AttrManager:AddHurtReduceRate(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.HURT_REDUCE_RATE] = self._attr[HEROATTRTYPE.HURT_REDUCE_RATE] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.HURT_REDUCE_RATE] = self._attr_rate[HEROATTRTYPE.HURT_REDUCE_RATE] + num
-- 	end
-- end

-- function AttrManager:SubHurtReduceRate(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.HURT_REDUCE_RATE] = self._attr[HEROATTRTYPE.HURT_REDUCE_RATE] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.HURT_REDUCE_RATE] = self._attr_rate[HEROATTRTYPE.HURT_REDUCE_RATE] - num
-- 	end
-- end

-- function AttrManager:GetHurtAddonRate()
-- 	local num = self._attr[HEROATTRTYPE.HURT_ADDON_RATE] * self._attr_rate[HEROATTRTYPE.HURT_ADDON_RATE] / 100
-- 	if num < 0 then
-- 		return 0
-- 	elseif num > 10000 then
-- 		return 10000
-- 	end
-- 	return num
-- end

-- function AttrManager:AddHurtAddonRate(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.HURT_ADDON_RATE] = self._attr[HEROATTRTYPE.HURT_ADDON_RATE] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.HURT_ADDON_RATE] = self._attr_rate[HEROATTRTYPE.HURT_ADDON_RATE] + num
-- 	end
-- end

-- function AttrManager:SubHurtAddonRate(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.HURT_ADDON_RATE] = self._attr[HEROATTRTYPE.HURT_ADDON_RATE] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.HURT_ADDON_RATE] = self._attr_rate[HEROATTRTYPE.HURT_ADDON_RATE] - num
-- 	end
-- end

-- function AttrManager:GetRangXingRate()
-- 	-- local num = self._attr[HEROATTRTYPE.RANGXING_RATE] * self._attr_rate[HEROATTRTYPE.RANGXING_RATE] / 100
-- 	local num = self._attr[HEROATTRTYPE.RANGXING_RATE] * self._attr_rate[HEROATTRTYPE.RANGXING_RATE] / 100 + self._hero_controller._buff_manager:AddRengXing()
-- 	if num < 0 then
-- 		return 0
-- 	elseif num > 100 then
-- 		return 100
-- 	end
-- 	return num
-- end

-- function AttrManager:AddRangXingRate(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.RANGXING_RATE] = self._attr[HEROATTRTYPE.RANGXING_RATE] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.RANGXING_RATE] = self._attr_rate[HEROATTRTYPE.RANGXING_RATE] + num
-- 	end
-- end

-- function AttrManager:SubRangXingRate(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.RANGXING_RATE] = self._attr[HEROATTRTYPE.RANGXING_RATE] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.RANGXING_RATE] = self._attr_rate[HEROATTRTYPE.RANGXING_RATE] - num
-- 	end
-- end

-- function AttrManager:GetGeDangLevel()
-- 	local num = self._attr[HEROATTRTYPE.GEDANG_LEVEL] * self._attr_rate[HEROATTRTYPE.GEDANG_LEVEL] / 100
-- 	if num < 0 then
-- 		return 0
-- 	end
-- 	return num
-- end

-- function AttrManager:AddGeDangLevel(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.GEDANG_LEVEL] = self._attr[HEROATTRTYPE.GEDANG_LEVEL] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.GEDANG_LEVEL] = self._attr_rate[HEROATTRTYPE.GEDANG_LEVEL] + num
-- 	end
-- end

-- function AttrManager:SubGeDangLevel(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.GEDANG_LEVEL] = self._attr[HEROATTRTYPE.GEDANG_LEVEL] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.GEDANG_LEVEL] = self._attr_rate[HEROATTRTYPE.GEDANG_LEVEL] - num
-- 	end
-- end

-- function AttrManager:GetShangBiLevel()
-- 	-- local num = self._attr[HEROATTRTYPE.SHANGBI_LEVEL] * (self._attr_rate[HEROATTRTYPE.SHANGBI_LEVEL]) / 100
-- 	local num = self._attr[HEROATTRTYPE.SHANGBI_LEVEL] * (self._attr_rate[HEROATTRTYPE.SHANGBI_LEVEL] + self._hero_controller._buff_manager:GetHeart() + self._hero_controller._buff_manager:AddShangBiLevelRate()) / 100
-- 	if num < 0 then
-- 		return 0
-- 	end
-- 	return num
-- end

-- function AttrManager:AddShangBiLevel(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.SHANGBI_LEVEL] = self._attr[HEROATTRTYPE.SHANGBI_LEVEL] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.SHANGBI_LEVEL] = self._attr_rate[HEROATTRTYPE.SHANGBI_LEVEL] + num
-- 	end
-- end

-- function AttrManager:SubShangBiLevel(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.SHANGBI_LEVEL] = self._attr[HEROATTRTYPE.SHANGBI_LEVEL] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.SHANGBI_LEVEL] = self._attr_rate[HEROATTRTYPE.SHANGBI_LEVEL] - num
-- 	end
-- end

-- function AttrManager:GetMingZhongLevel()
-- 	-- local num = self._attr[HEROATTRTYPE.MINGZHONG_LEVEL] * (self._attr_rate[HEROATTRTYPE.MINGZHONG_LEVEL]) / 100
-- 	local num = self._attr[HEROATTRTYPE.MINGZHONG_LEVEL] * (self._attr_rate[HEROATTRTYPE.MINGZHONG_LEVEL] + self._hero_controller._buff_manager:GetHeart()) / 100
-- 	if num < 0 then
-- 		return 0
-- 	end
-- 	return num
-- end

-- function AttrManager:AddMingZhongLevel(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.MINGZHONG_LEVEL] = self._attr[HEROATTRTYPE.MINGZHONG_LEVEL] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.MINGZHONG_LEVEL] = self._attr_rate[HEROATTRTYPE.MINGZHONG_LEVEL] + num
-- 	end
-- end

-- function AttrManager:SubMingZhongLevel(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.MINGZHONG_LEVEL] = self._attr[HEROATTRTYPE.MINGZHONG_LEVEL] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.MINGZHONG_LEVEL] = self._attr_rate[HEROATTRTYPE.MINGZHONG_LEVEL] - num
-- 	end
-- end

-- function AttrManager:GetBaojiHurtAddonRate()
-- 	local num = self._attr[HEROATTRTYPE.BAOJIHURT_ADDON_RATE] * self._attr_rate[HEROATTRTYPE.BAOJIHURT_ADDON_RATE] / 100
-- 	return num
-- end

-- function AttrManager:AddBaojiHurtAddonRate(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.BAOJIHURT_ADDON_RATE] = self._attr[HEROATTRTYPE.BAOJIHURT_ADDON_RATE] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.BAOJIHURT_ADDON_RATE] = self._attr_rate[HEROATTRTYPE.BAOJIHURT_ADDON_RATE] + num
-- 	end
-- end

-- function AttrManager:SubBaojiHurtAddonRate(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.BAOJIHURT_ADDON_RATE] = self._attr[HEROATTRTYPE.BAOJIHURT_ADDON_RATE] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.BAOJIHURT_ADDON_RATE] = self._attr_rate[HEROATTRTYPE.BAOJIHURT_ADDON_RATE] - num
-- 	end
-- end

-- function AttrManager:GetBaoJiLevel()
-- 	-- local num = self._attr[HEROATTRTYPE.BAOJI_LEVEL] * (self._attr_rate[HEROATTRTYPE.BAOJI_LEVEL]) / 100
-- 	local num = self._attr[HEROATTRTYPE.BAOJI_LEVEL] * (self._attr_rate[HEROATTRTYPE.BAOJI_LEVEL] + self._hero_controller._buff_manager:GetHeart()) / 100
-- 	return num
-- end

-- function AttrManager:AddBaoJiLevel(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.BAOJI_LEVEL] = self._attr[HEROATTRTYPE.BAOJI_LEVEL] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.BAOJI_LEVEL] = self._attr_rate[HEROATTRTYPE.BAOJI_LEVEL] + num
-- 	end
-- end

-- function AttrManager:SubBaoJiLevel(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.BAOJI_LEVEL] = self._attr[HEROATTRTYPE.BAOJI_LEVEL] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.BAOJI_LEVEL] = self._attr_rate[HEROATTRTYPE.BAOJI_LEVEL] - num
-- 	end
-- end

-- function AttrManager:GetWuLiAtk()	 -------------物攻
-- 	-- local num = self._attr[HEROATTRTYPE.WULI_ATTACK] * (self._attr_rate[HEROATTRTYPE.WULI_ATTACK]) / 100
-- 	local num = self._attr[HEROATTRTYPE.WULI_ATTACK] * (self._attr_rate[HEROATTRTYPE.WULI_ATTACK] + self._hero_controller._buff_manager:GetAtkChange()) / 100
-- 	if num < 0 then
-- 		return 0
-- 	end
-- 	return num
-- end

-- function AttrManager:AddWuLiAtk(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.WULI_ATTACK] = self._attr[HEROATTRTYPE.WULI_ATTACK] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.WULI_ATTACK] = self._attr_rate[HEROATTRTYPE.WULI_ATTACK] + num
-- 	end
-- end

-- function AttrManager:SubWuLiAtk(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.WULI_ATTACK] = self._attr[HEROATTRTYPE.WULI_ATTACK] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.WULI_ATTACK] = self._attr_rate[HEROATTRTYPE.WULI_ATTACK] - num
-- 	end
-- end

-- function AttrManager:GetMoFaAtk()	---------------魔攻
-- 	-- local num = self._attr[HEROATTRTYPE.MOFA_ATTACK] * (self._attr_rate[HEROATTRTYPE.MOFA_ATTACK]) / 100
-- 	local num = self._attr[HEROATTRTYPE.MOFA_ATTACK] * (self._attr_rate[HEROATTRTYPE.MOFA_ATTACK] + self._hero_controller._buff_manager:GetAtkChange()) / 100
-- 	if num < 0 then
-- 		return 0
-- 	end
-- 	return num
-- end

-- function AttrManager:AddMoFaAtk(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.MOFA_ATTACK] = self._attr[HEROATTRTYPE.MOFA_ATTACK] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.MOFA_ATTACK] = self._attr_rate[HEROATTRTYPE.MOFA_ATTACK] + num
-- 	end
-- end

-- function AttrManager:SubMoFaAtk(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.MOFA_ATTACK] = self._attr[HEROATTRTYPE.MOFA_ATTACK] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.MOFA_ATTACK] = self._attr_rate[HEROATTRTYPE.MOFA_ATTACK] - num
-- 	end
-- end

-- function AttrManager:GetWuLiDef()
-- 	-- local num = self._attr[HEROATTRTYPE.WULI_DEFEND] * (self._attr_rate[HEROATTRTYPE.WULI_DEFEND]) / 100
-- 	local num = self._attr[HEROATTRTYPE.WULI_DEFEND] * (self._attr_rate[HEROATTRTYPE.WULI_DEFEND] + self._hero_controller._buff_manager:GetDefendChange()) / 100
-- 	if num < 0 then
-- 		return 0
-- 	end
-- 	return num
-- end

-- function AttrManager:AddWuLiDef(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.WULI_DEFEND] = self._attr[HEROATTRTYPE.WULI_DEFEND] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.WULI_DEFEND] = self._attr_rate[HEROATTRTYPE.WULI_DEFEND] + num
-- 	end
-- end

-- function AttrManager:SubWuLiDef(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.WULI_DEFEND] = self._attr[HEROATTRTYPE.WULI_DEFEND] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.WULI_DEFEND] = self._attr_rate[HEROATTRTYPE.WULI_DEFEND] - num
-- 	end
-- end

-- function AttrManager:GetMoFaDef()
-- 	-- local num = self._attr[HEROATTRTYPE.MOFA_DEFEND] * (self._attr_rate[HEROATTRTYPE.MOFA_DEFEND]) / 100
-- 	local num = self._attr[HEROATTRTYPE.MOFA_DEFEND] * (self._attr_rate[HEROATTRTYPE.MOFA_DEFEND] + self._hero_controller._buff_manager:GetDefendChange()) / 100
-- 	if num < 0 then
-- 		return 0
-- 	end
-- 	return num
-- end

-- function AttrManager:AddMoFaDef(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.MOFA_DEFEND] = self._attr[HEROATTRTYPE.MOFA_DEFEND] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.MOFA_DEFEND] = self._attr_rate[HEROATTRTYPE.MOFA_DEFEND] + num
-- 	end
-- end

-- function AttrManager:SubMoFaDef(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.MOFA_DEFEND] = self._attr[HEROATTRTYPE.MOFA_DEFEND] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.MOFA_DEFEND] = self._attr_rate[HEROATTRTYPE.MOFA_DEFEND] - num
-- 	end
-- end



-- function AttrManager:IsSecoundAction()
-- 	-- if self._hero_controller:IsMaster() then
-- 	-- 	return 0
-- 	-- end
-- 	-- return self._attr[HEROATTRTYPE.SECOND_ACTION]
-- 	return self._attr[HEROATTRTYPE.SECOND_ACTION] + self._hero_controller._buff_manager:IsSecoundAction()
-- end

-- function AttrManager:GetAjility()
-- 	-- local num = self._attr[HEROATTRTYPE.SPEED] * (self._attr_rate[HEROATTRTYPE.SPEED]) / 100
-- 	local num = self._attr[HEROATTRTYPE.SPEED] * (self._attr_rate[HEROATTRTYPE.SPEED] + self._hero_controller._buff_manager:GetSpeedChange()) / 100
-- 	return num
-- end

-- function AttrManager:GetSpeed()
-- 	-- local num = self._attr[HEROATTRTYPE.SPEED] * (self._attr_rate[HEROATTRTYPE.SPEED]) / 100
-- 	local num = self._attr[HEROATTRTYPE.SPEED] * (self._attr_rate[HEROATTRTYPE.SPEED] + self._hero_controller._buff_manager:GetSpeedChange()) / 100
-- 	return num
-- end

-- function AttrManager:AddAjility(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.SPEED] = self._attr[HEROATTRTYPE.SPEED] + num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.SPEED] = self._attr_rate[HEROATTRTYPE.SPEED] + num
-- 	end
-- end

-- function AttrManager:SubAjility(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.SPEED] = self._attr[HEROATTRTYPE.SPEED] - num
-- 	else
-- 		self._attr_rate[HEROATTRTYPE.SPEED] = self._attr_rate[HEROATTRTYPE.SPEED] - num
-- 	end
-- end

-- function AttrManager:AddBaseHp(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.BASEHP] = self._attr[HEROATTRTYPE.BASEHP] + num
-- 		self._attr[HEROATTRTYPE.HP] = self._attr[HEROATTRTYPE.HP] + num
-- 	else
-- 		local hp = self:GetBaseHp()
-- 		self._attr_rate[HEROATTRTYPE.BASEHP] = self._attr_rate[HEROATTRTYPE.BASEHP] + num
-- 		hp = self:GetBaseHp() - hp
-- 		self._attr[HEROATTRTYPE.HP] = self._attr[HEROATTRTYPE.HP] + hp
-- 	end
-- end

-- function AttrManager:SubBaseHp(num,bool)
-- 	if bool then
-- 		self._attr[HEROATTRTYPE.BASEHP] = self._attr[HEROATTRTYPE.BASEHP] - num
-- 		self._attr[HEROATTRTYPE.HP] = self._attr[HEROATTRTYPE.HP] - num
-- 		if self._attr[HEROATTRTYPE.HP] <= 0 then
-- 			self._attr[HEROATTRTYPE.HP] = 1
-- 		end
-- 	else
-- 		local hp = self:GetBaseHp()
-- 		self._attr_rate[HEROATTRTYPE.BASEHP] = self._attr_rate[HEROATTRTYPE.BASEHP] - num
-- 		hp = hp - self:GetBaseHp()
-- 		self._attr[HEROATTRTYPE.HP] = self._attr[HEROATTRTYPE.HP] - hp
-- 		if self._attr[HEROATTRTYPE.HP] < 0 then
-- 			self._attr[HEROATTRTYPE.HP] = 1
-- 		end
-- 	end
-- end



return AttrManager