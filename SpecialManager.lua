local st_hero_special = require("st_hero_special")
local SkillTargetHelper = require("SkillTargetHelper")
local SkillCommand = require("SkillCommand")
local SpecialManager = class("SpecialManager")

function SpecialManager:ctor(hero, role_mgr)
	self._hero = hero
	self._role_mgr = role_mgr

	self._init = false
	self._specials = {}

	-- tmp data
	self._kill_add_anger_step = 0
end

function SpecialManager:Init(specials)
	if specials ~= nil then
		table.walk(specials, function(special_id)
			local data = st_hero_special[special_id]
			if data == nil then
				return
			end

			local special_type = data.special_type
			if not self._specials[special_type] then
				self._specials[special_type] = {}
			end

			-- SPECIALTYPE.REPLACE_SKILL_ALL 特殊处理 只用ID最大的
			if special_type ~= SPECIALTYPE.REPLACE_SKILL_ALL or #self._specials[special_type] == 0 then
				table.insert(self._specials[special_type], special_id)
			elseif special_type == SPECIALTYPE.REPLACE_SKILL_ALL and #self._specials[SPECIALTYPE.REPLACE_SKILL_ALL] > 0 and special_id > self._specials[SPECIALTYPE.REPLACE_SKILL_ALL][1] then
				self._specials[SPECIALTYPE.REPLACE_SKILL_ALL][1] = special_id
			end
		end)
	end
	self._init = true
end

function SpecialManager:TriggerBegin(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerBegin", special_type, ...)
	if special_type == SPECIALTYPE.REPLACE_SKILL_ALL then
		self:SelfReplaceSkill(special_data, result, param)

	elseif special_type == SPECIALTYPE.ADD_TARGET_BUFF_BEGIN then
		self:TargetAddBuff(special_data, result, param)

	elseif special_type == SPECIALTYPE.ADD_ATTR_DURINGFIGHT then
		self:SelfAddAttr(special_data, result, param)

	end
end

function SpecialManager:TriggerBeforeAct(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerBeforeAct", special_type, result, param)
end

-- NO USE
function SpecialManager:TriggerAttacking(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerAttacking", special_type, result, param)
	-- if special_type == SPECIALTYPE.MODIFY_SKILL_EFFECT_ALL then
	-- 	self:ModifySkillFactor(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.MODIFY_SKILL_STUNT_ALL then
	-- 	self:ModifySkillStunt(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.ADD_DMG_FIRSTATTACK then
	-- 	self:AddDmgFirstAttack(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.ADD_HIT_FIRSTATTACK then
	-- 	self:AddHitFirstAttack(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_ANGER_MORE_ADD_DMG_ATTACKING then
	-- 	self:TargetAngerMoreAddDmg(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_ANGER_LESS_ADD_DMG_ATTACKING then
	-- 	self:TargetAngerLessAddDmg(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_HP_MORE_ADD_DMG_ATTACKING then
	-- 	self:TargetHpMoreAddDmg(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_HP_LESS_ADD_DMG_ATTACKING then
	-- 	self:TargetHpLessAddDmg(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_HP_MORE_ADD_CRIT_ATTACKING then
	-- 	self:TargetHpMoreAddCrit(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.ADD_CRIT_OUR_ALIVE_ATTACKING then
	-- 	self:AddCritOurAlive(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_NOT_ACT_ADD_DMG_ATTACKING then
	-- 	self:TargetNotActAddDmg(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_HP_MORE_VAMPIRISM_LESS_ADDDMG_ATTACKING then
	-- 	self:TargetHpMoreVampism(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_HAS_BUFF_VAMPIRISM_AFTERACT then
	-- 	self:TargetHasBuffVampirism(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_HAS_BUFF_ADD_DMG_DURINGFIGHT then
	-- 	self:TargetHasBuffAddDmg(special_data, result, param)

	-- end
end

-- NO USE
function SpecialManager:TriggerAfterAttack(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerAfterAttack", special_type, result, param)
	-- if special_type == SPECIALTYPE.PROBABLY_DOUBLE_HIT_ATTACKING then
	-- 	self:ProbablyDoubleHit(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.VAMPIRISM_AFTERACT then
	-- 	self:VampirismAfterAct(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.DOUBLE_SKILL_AFTERRELEASEANGERSKILL then
	-- 	self:DoubleSkillAfterReleaseAngerSkill(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.ADD_BUFF_AFTERRELEASEANGERSKILL then
	-- 	self:AddBuffAfterReleaseAngerSkill(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.ADD_ATTR_AFTERRELEASEANGERSKILL then
	-- 	self:AddAttrAfterReleaseAngerSkill(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_LOSE_ANGER_ADD_DMG_AFTERRELEASEANGERSKILL then
	-- 	self:TargetLoseAngerAddDmg(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.VAMPIRISM_AFTERRELEASEANGERSKILL then
	-- 	self:VampirismAfterReleaseAngerSkill(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.PROBABLY_DOUBLE_HIT_AFTERNORMALSKILL then
	-- 	self:ProbablyDoubleHit(special_data, result, param)

	-- end
end

-- NO USE
function SpecialManager:TriggerHeal(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerHeal", special_type, result, param)
	-- if special_type == SPECIALTYPE.TARGET_HP_LOSE_ADDHEAL then
	-- 	self:TargetHpLoseAddHeal(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_FRONT_ROW_ADDHEAL then
	-- 	self:TargetFrontRowAddHeal(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.EXCESSIVE_HEAL_ADDSHIELD then
	-- 	self:ExcessiveHealAddShield(special_data, result, param)

	-- end
end

function SpecialManager:TriggerAfterAct(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerAfterAct", special_type, result, param)
	if special_type == SPECIALTYPE.ADD_BUFF_AFTERACT then
		self:AddBuffAfterAct(special_data, result, param)

	elseif special_type == SPECIALTYPE.ADD_ATTR_AFTERACT then
		self:AddAttrAfterAct(special_data, result, param)

	end
end

function SpecialManager:TriggerRoundOver(special_type, special_data, result, param)
	if special_type == SPECIALTYPE.RECOVER_DAMAGE_HP_ROUNDOVER then
		self:RecoverHPByATKRoundover(special_data, result, param)

	elseif special_type == SPECIALTYPE.ADD_DMG_DECDMG_ROUNDOVER then
		self:AddDmgRoundOver(special_data, result, param)

	elseif special_type == SPECIALTYPE.RECOVER_HP_BY_ATK_ROUNDOVER then
		self:RecoberHpByAtkRoundover(special_data, result, param)

	elseif special_type == SPECIALTYPE.ADD_BUFF_ROUNDOVER then
		self:AddBuffRoundover(special_data, result, param)

	elseif special_type == SPECIALTYPE.CLEAN_DEBUFF_ROUNDOVER then
		self:CleanDebuffRoundover(special_data, result, param)

	end
end

-- NO USE
function SpecialManager:TriggerUnderAttacking(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerUnderAttacking", special_type, result, param)
	-- if special_type == SPECIALTYPE.TARGET_ANGER_MORE_DEC_DMG_BEFOREUNDERATTACK then
	-- 	self:TargetAngerMoreDecDamage(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_HP_MORE_DEC_DMG_BEFOREUNDERATTACK then
	-- 	self:TargetHPMoreDecDamage(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_HP_LESS_DEC_DMG_BEFOREUNDERATTACK then
	-- 	self:TargetHPLessDecDamage(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_HAS_BUFF_DEC_DMG_BEFOREUNDERATTACK then
	-- 	self:TargetHasBuffDecDamage(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_SKILL_EFFECT_DEC_DMG_BEFOREUNDERATTACK then
	-- 	self:TargetSkillEffectDecDamage(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.DEC_DAMAGE_HP_LIMIT_UNDERATTACKING then
	-- 	self:DecDamageByHPLimit(special_data, result, param)

	-- end
end

-- NO USE
function SpecialManager:TriggerAfterBeAttacked(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerAfterBeAttacked", special_type, result, param)
	-- if special_type == SPECIALTYPE.ADD_ATTR_AFTERUNDERATTACK then
	-- 	self:AddAttrAfterUnderAttack(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_SKILL_EFFECT_ADD_ATTR_AFTERUNDERATTACK then
	-- 	self:TargetSkillEffectAddAttrAfterUnderAttck(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.REFLECTING_DMG_AFTERUNDERATTACK then
	-- 	self:ReflectingDmgAfterUnderAttack(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.TARGET_REDUCE_ATTR_AFTERUNDERATTACK then
	-- 	self:TargetReduceAttrAfterUnderAttack(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.BEAT_BACK_AFTERUNDERATTACK then
	-- 	self:BeatBackAfterUnderAttack(special_data, result, param)

	-- end
end

function SpecialManager:TriggerKillEnemy(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerKillEnemy", special_type, result, param)
	if special_type == SPECIALTYPE.ADD_ANGER_AFTERKILL then
		self:AddAngerAfterKill(special_data, result, param)

	elseif special_type == SPECIALTYPE.ADD_BUFF_AFTERKILL then
		self:AddBuffAfterKill(special_data, result, param)

	end
end

function SpecialManager:TriggerBeforeGetBuff(special_type, special_data, result, param)
	if result.can_add_buff == nil then
		result.can_add_buff = true
	end

	if special_type == SPECIALTYPE.IMMUNE_BUFF_DURINGFIGHT then
		self:ImmuneBuff(special_data, result, param)

	end
end

function SpecialManager:TriggerAfterGetBuff(special_type, special_data, result, param)
	if special_type == SPECIALTYPE.TARGET_COPY_BUFF then
		self:CopyBuffToCaster(special_data, result, param)

	end
end

function SpecialManager:TriggerRecoverAnger(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerRecoverAnger", special_type, result, param)
	if result.recover_anger == nil then
		result.recover_anger = ANGERTYPE.ADD_ANGER_PER_ROUND
	end

	if special_type == SPECIALTYPE.RECOVER_ONE_ANGER_DURINGFIGHT then
		self:RecoverOneAnger(special_data, result, param)
	end
end

-- NO USE
function SpecialManager:TriggerGetAttr(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerGetAttr", special_type, result, param)
	-- if special_type == SPECIALTYPE.ADD_DECDMG_SELFANGERMORE then
	-- 	self:AddDecDmgSelfAngerMore(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.ADD_DMG_SELFANGERMORE then
	-- 	self:AddDmgSelfAngerMore(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.ADD_DMG_SELFANGERLESS then
	-- 	self:AddDmgSelfAngerLess(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.ADD_DECDMG_SELFHPMORE then
	-- 	self:AddDecDmgSelfHPMore(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.ADD_DMG_SELFHPMORE then
	-- 	self:AddDmgSelfHPMore(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.ADD_DECDMG_SELFHPLESS then
	-- 	self:AddDecDmgSelfHPLess(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.ADD_DMG_SELFHPLESS then
	-- 	self:AddDmgSelfHPLess(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.ADD_ATTR_UNDERDEBUFF then
	-- 	self:AddAttrUnderDeBuff(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.ADD_ATTR_UNDERBLEEDING then
	-- 	self:AddAttrUnderBleeding(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.ADD_CRIT_BY_ANGER_ATTACKING then
	-- 	self:AddCritByAnger(special_data, result, param)

	-- end
end

function SpecialManager:TriggerLosingHP(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerLosingHP", special_type, result, param)
end

function SpecialManager:TriggerLostHP(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerLostHP", special_type, result, param)
end

function SpecialManager:TriggerAfterMiss(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerAfterMiss", special_type, result, param)
end

function SpecialManager:TriggerAfterBlock(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerAfterBlock", special_type, result, param)
	if special_type == SPECIALTYPE.ADD_BUFF_AFTERBLOCK then
		self:AddBuffAfterBlock(special_data, result, param)
	end
end

function SpecialManager:TriggerAfterCrit(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerAfterCrit", special_type, result, param)
end

function SpecialManager:TriggerAfterBeHeal(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerAfterBeHeal", special_type, result, param)
end

function SpecialManager:TriggerAfterDie(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerAfterDie", special_type, result, param)
	if special_type == SPECIALTYPE.TARGET_ADD_BUFF_BEKILLED then
		self:KillerAddBuff(special_data, result, param)
	end
end

function SpecialManager:TriggerAlive(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerAlive", special_type, result, param)
	-- if special_type == SPECIALTYPE.ADD_ARUA_BUFF_ALIVE then
	-- 	self:AddBuffAlive(special_data, result, param)

	-- elseif special_type == SPECIALTYPE.ADD_DMG_ALIVE then
	-- 	self:AddDmgAlive(special_data, result, param)
	-- end
end

function SpecialManager:TriggerAfterPartnerAttack(special_type, special_data, result, param)
	-- print("SpecialManager:TriggerAfterPartnerAttack", special_type, result, param)
	-- if special_type == SPECIALTYPE.EXTRA_NORMAL_SKILL_AFTERPARTNERACT then
	-- 	self:ExtraNormalSkillAfterPartnerAct(special_data, result, param)
	-- end
end

local SPECIAL_TRIGGER_OPPORTUNITY = {
	["SPECIAL_TRIGGER_BEGIN"] = SpecialManager.TriggerBegin,						-- 开场时
	["SPECIAL_TRIGGER_BEFORE_ACT"] = SpecialManager.TriggerBeforeAct,				-- 行动前
	-- ["SPECIAL_TRIGGER_ATTACKING"] = SpecialManager.TriggerAttacking,					-- 攻击时
	-- ["SPECIAL_TRIGGER_AFTER_ATTACK"] = SpecialManager.TriggerAfterAttack,			-- 攻击后
	-- ["SPECIAL_TRIGGER_HEAL"] = SpecialManager.TriggerHeal,							-- 治疗时
	["SPECIAL_TRIGGER_AFTER_ACT"] = SpecialManager.TriggerAfterAct,					-- 行动后
	["SPECIAL_TRIGGER_ROUNDOVER"] = SpecialManager.TriggerRoundOver,				-- 回合结束后
	["SPECIAL_TRIGGER_KILL_ENEMY"] = SpecialManager.TriggerKillEnemy,				-- 击杀目标后
	-- ["SPECIAL_TRIGGER_UNDER_ATTACKING"] = SpecialManager.TriggerUnderAttacking,		-- 受到攻击时
	-- ["SPECIAL_TRIGGER_AFTER_BE_ATTACKED"] = SpecialManager.TriggerAfterBeAttacked,	-- 受到攻击后
	["SPECIAL_TRIGGER_BEFORE_GET_BUFF"] = SpecialManager.TriggerBeforeGetBuff,			-- 获得BUFF前
	["SPECIAL_TRIGGER_AFTER_GET_BUFF"] = SpecialManager.TriggerAfterGetBuff,			-- 获得BUFF后
	["SPECIAL_TRIGGER_RECOVER_ANGER"] = SpecialManager.TriggerRecoverAnger,			-- 回复怒气时
	-- ["SPECIAL_TRIGGER_GET_ATTR"] = SpecialManager.TriggerGetAttr,					-- 获取属性时
	["SPECIAL_TRIGGER_LOSING_HP"] = SpecialManager.TriggerLosingHP,					-- 扣血时
	["SPECIAL_TRIGGER_LOST_HP"] = SpecialManager.TriggerLostHP,						-- 扣血后
	["SPECIAL_TRIGGER_AFTER_MISS"] = SpecialManager.TriggerAfterMiss,				-- 闪避后
	["SPECIAL_TRIGGER_AFTER_BLOCK"] = SpecialManager.TriggerAfterBlock,				-- 格挡后
	["SPECIAL_TRIGGER_AFTER_CRIT"] = SpecialManager.TriggerAfterCrit,				-- 暴击后
	["SPECIAL_TRIGGER_AFTER_BE_HEAL"] = SpecialManager.TriggerAfterBeHeal,			-- 受到治疗后
	["SPECIAL_TRIGGER_AFTER_DIE"] = SpecialManager.TriggerAfterDie,					-- 死亡后
	["SPECIAL_TRIGGER_ALIVE"] = SpecialManager.TriggerAlive,						-- 存活时
	["SPECIAL_TRIGGER_AFTER_PARTNER_ATTACK"] = SpecialManager.TriggerAfterPartnerAttack,	-- 队友攻击后
}

function SpecialManager:Trigger(opportunity, result, param)
	if not self._init then
		return
	end

	if SPECIAL_TRIGGER_OPPORTUNITY[opportunity] and type(SPECIAL_TRIGGER_OPPORTUNITY[opportunity]) == "function" then
		table.walk(self._specials, function(special_ids, special_type)
			table.walk(special_ids, function(special_id)
				local special_data = st_hero_special[special_id]
				if special_data == nil then
					return
				end

				SPECIAL_TRIGGER_OPPORTUNITY[opportunity](self, special_data.special_type, special_data, result, param)
			end)
		end)
	end
end

-- MARK trigger functions
-- ==================================================================

function SpecialManager:SelfReplaceSkill(special_data, result, param)
	if special_data.param1 <= 0 or special_data.param2 <= 0 then
		return
	end

	printDebug("Trigger REPLACE_SKILL_ALL special_id:%d, param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)

	local before_replace_skill = special_data.param1
	local after_replace_skill = special_data.param2
	self._hero:ReplaceSkill(before_replace_skill, after_replace_skill)
end

function SpecialManager:TargetAddBuff(special_data, result, param)
	if special_data.param1 <= 0 or special_data.param2 <= 0 then
		return
	end

	printDebug("Trigger ADD_TARGET_BUFF_BEGIN special_id:%d, param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)

	local target_helper = SkillTargetHelper.new(self._role_mgr:GetAllRole(), self._hero)
	local targets = target_helper:GetTargetByType(special_data.param1)
	table.walk(targets, function(role)
		if role:IsDead() == false then
			role:AddBuff(self._hero, special_data.param2)
		end
	end)
	return
end

function SpecialManager:SelfAddAttr(special_data, result, param)
	if special_data.param1 <= 0 or special_data.param2 <= 0 or self._hero:IsDead() then
		return
	end

	printDebug("Trigger ADD_ATTR_DURINGFIGHT special_id:%d, param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)
	self._hero:AddAttr(special_data.param1, special_data.param2)
end

function SpecialManager:ModifySkillFactor(special_data, result, param)
	-- print("Trigger Special ModifySkillFactor", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:ModifySkillStunt(special_data, result, param)
	-- print("Trigger Special ModifySkillStunt", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:AddDmgFirstAttack(special_data, result, param)
	-- print("Trigger Special AddDmgFirstAttack", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:AddHitFirstAttack(special_data, result, param)
	-- print("Trigger Special AddHitFirstAttack", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetAngerMoreAddDmg(special_data, result, param)
	-- print("Trigger Special TargetAngerMoreAddDmg", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetAngerLessAddDmg(special_data, result, param)
	-- print("Trigger Special TargetAngerLessAddDmg", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetHpMoreAddDmg(special_data, result, param)
	-- print("Trigger Special TargetHpMoreAddDmg", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetHpLessAddDmg(special_data, result, param)
	-- print("Trigger Special TargetHpLessAddDmg", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetHpMoreAddCrit(special_data, result, param)
	-- print("Trigger Special TargetHpMoreAddCrit", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:AddCritOurAlive(special_data, result, param)
	-- print("Trigger Special AddCritOurAlive", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetNotActAddDmg(special_data, result, param)
	-- print("Trigger Special TargetNotActAddDmg", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetHpMoreVampism(special_data, result, param)
	-- print("Trigger Special TargetHpMoreVampism", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetHasBuffVampirism(special_data, result, param)
	-- print("Trigger Special TargetHasBuffVampirism", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetHasBuffAddDmg(special_data, result, param)
	-- print("Trigger Special TargetHasBuffAddDmg", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:ProbablyDoubleHit(special_data, result, param)
	-- print("Trigger Special ProbablyDoubleHit", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:VampirismAfterAct(special_data, result, param)
	-- print("Trigger Special VampirismAfterAct", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:DoubleSkillAfterReleaseAngerSkill(special_data, result, param)
	-- print("Trigger Special DoubleSkillAfterReleaseAngerSkill", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:AddBuffAfterReleaseAngerSkill(special_data, result, param)
	-- print("Trigger Special AddBuffAfterReleaseAngerSkill", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:AddAttrAfterReleaseAngerSkill(special_data, result, param)
	-- print("Trigger Special AddAttrAfterReleaseAngerSkill", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetLoseAngerAddDmg(special_data, result, param)
	-- print("Trigger Special TargetLoseAngerAddDmg", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:VampirismAfterReleaseAngerSkill(special_data, result, param)
	-- print("Trigger Special VampirismAfterReleaseAngerSkill", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:ProbablyDoubleHit(special_data, result, param)
	-- print("Trigger Special ProbablyDoubleHit", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetHpLoseAddHeal(special_data, result, param)
	-- print("Trigger Special TargetHpLoseAddHeal", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetFrontRowAddHeal(special_data, result, param)
	-- print("Trigger Special TargetFrontRowAddHeal", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:ExcessiveHealAddShield(special_data, result, param)
	-- print("Trigger Special ExcessiveHealAddShield", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:RecoverHPByATKRoundover(special_data, result, param)
	if special_data.param1 <= 0 then
		return
	end

	local recover_hp = self._hero:GetATK() * special_data.param1 / 1000
	if recover_hp > 0 and self._hero:IsDead() == false then
		printDebug("Trigger RECOVER_DAMAGE_HP_ROUNDOVER special_id:%d, param1:%d, recover_hp:%d", special_data.config_id, special_data.param1, recover_hp)
		self._hero:AddHp(recover_hp, SKILL_OR_BUFF.SPECIAL, special_data.config_id, self._hero:GetId(), self._hero:GetCamp(), false)
	end
end

function SpecialManager:AddDmgRoundOver(special_data, result, param)
	if (special_data.param1 <= 0 and special_data.param2 <= 0) or self._hero:IsDead() then
		return
	end

	printDebug("Trigger ADD_DMG_DECDMG_ROUNDOVER special_id:%d, param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)

	if special_data.param1 > 0 then
		self._hero:AddAttr(HEROATTRTYPE.INC_DMG, special_data.param1)
	end
	if special_data.param2 > 0 then
		self._hero:AddAttr(HEROATTRTYPE.DEC_DMG, special_data.param2)
	end
end

function SpecialManager:RecoberHpByAtkRoundover(special_data, result, param)
	if self._hero:IsDead() then
		return
	end

	printDebug("Trigger RECOVER_HP_BY_ATK_ROUNDOVER special_id:%d, param1:%d", special_data.config_id, special_data.param1)

	if special_data.param1 > 0 then
		local atk = self._hero:GetATK()
		local add_hp = math.ceil(atk * special_data.param1 / 1000)
		self._hero:AddHp(add_hp, SKILL_OR_BUFF.SPECIAL, special_data.config_id, self._hero:GetId(), self._hero:GetCamp(), false)
	end
end

function SpecialManager:AddBuffRoundover(special_data, result, param)
	if special_data.param1 <= 0 or special_data.param2 <= 0 or self._hero:IsDead() then
		return
	end

	printDebug("Trigger ADD_BUFF_ROUNDOVER special_id:%d, param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)

	local target_helper = SkillTargetHelper.new(self._role_mgr:GetAllRole(), self._hero)
	local targets = target_helper:GetTargetByType(special_data.param1)
	table.walk(targets, function(role)
		if role:IsDead() == false then
			role:AddBuff(self._hero, special_data.param2)
		end
	end)
end

function SpecialManager:CleanDebuffRoundover(special_data, result, param)
	if special_data.param1 <= 0 or self._hero:IsDead() then
		return
	end

	printDebug("Trigger CLEAN_DEBUFF_ROUNDOVER special_id:%d, param1:%d", special_data.config_id, special_data.param1)

	local target_helper = SkillTargetHelper.new(self._role_mgr:GetAllRole(), self._hero)
	local targets = target_helper:GetTargetByType(special_data.param1)
	table.walk(targets, function(role)
		if role:IsDead() == false then
			role:Refine()
		end
	end)
end

function SpecialManager:AddBuffAfterAct(special_data, result, param)
	if special_data.param1 <= 0 or special_data.param2 <= 0 or self._hero:IsDead() then
		return
	end

	printDebug("Trigger ADD_BUFF_AFTERACT special_id:%d, param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)

	local target_helper = SkillTargetHelper.new(self._role_mgr:GetAllRole(), self._hero)
	local targets = target_helper:GetTargetByType(special_data.param1)
	table.walk(targets, function(role)
		if role:IsDead() == false then
			role:AddBuff(self._hero, special_data.param2)
		end
	end)

	if special_data.param3 and special_data.param3 > 0 then
		self._hero:AddBuff(self._hero, special_data.param3, true)
	end
end

function SpecialManager:AddAttrAfterAct(special_data, result, param)
	if special_data.param1 <= 0 or special_data.param2 <= 0 or self._hero:IsDead() then
		return
	end
	printDebug("Trigger ADD_ATTR_AFTERACT special_id:%d, param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)

	self._hero:AddAttr(special_data.param1, special_data.param2)
end

function SpecialManager:TargetAngerMoreDecDamage(special_data, result, param)
	-- print("Trigger Special TargetAngerMoreDecDamage", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetHPMoreDecDamage(special_data, result, param)
	-- print("Trigger Special TargetHPMoreDecDamage", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetHPLessDecDamage(special_data, result, param)
	-- print("Trigger Special TargetHPLessDecDamage", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetHasBuffDecDamage(special_data, result, param)
	-- print("Trigger Special TargetHasBuffDecDamage", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetSkillEffectDecDamage(special_data, result, param)
	-- print("Trigger Special TargetSkillEffectDecDamage", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:DecDamageByHPLimit(special_data, result, param)
	-- print("Trigger Special DecDamageByHPLimit", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:AddAttrAfterUnderAttack(special_data, result, param)
	-- print("Trigger Special AddAttrAfterUnderAttack", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetSkillEffectAddAttrAfterUnderAttck(special_data, result, param)
	-- print("Trigger Special TargetSkillEffectAddAttrAfterUnderAttck", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:ReflectingDmgAfterUnderAttack(special_data, result, param)
	-- print("Trigger Special ReflectingDmgAfterUnderAttack", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:TargetReduceAttrAfterUnderAttack(special_data, result, param)
	-- print("Trigger Special TargetReduceAttrAfterUnderAttack", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:BeatBackAfterUnderAttack(special_data, result, param)
	-- print("Trigger Special BeatBackAfterUnderAttack", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:AddAngerAfterKill(special_data, result, param)
	if special_data.param1 <= 0 or self._hero:IsDead() then
		return
	end

	local step = self._role_mgr:GetStep()
	if step <= self._kill_add_anger_step then
		return
	end

	self._kill_add_anger_step = step
	printDebug("Trigger ADD_ANGER_AFTERKILL special_id:%d, param1:%d", special_data.config_id, special_data.param1)

	self._hero:AddAnger(special_data.param1, true)
end

function SpecialManager:AddBuffAfterKill(special_data, result, param)
	if special_data.param1 <= 0 or special_data.param2 <= 0 or self._hero:IsDead() then
		return
	end

	printDebug("Trigger ADD_BUFF_AFTERKILL special_id:%d, param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)

	local target_helper = SkillTargetHelper.new(self._role_mgr:GetAllRole(), self._hero)
	local targets = target_helper:GetTargetByType(special_data.param1)
	table.walk(targets, function(role)
		if role:IsDead() == false then
			role:AddBuff(self._hero, special_data.param2)
		end
	end)
end

function SpecialManager:ImmuneBuff(special_data, result, param)
	printDebug("Trigger IMMUNE_BUFF_DURINGFIGHT special_id:%d", special_data.config_id)
	result.can_add_buff = false
end

function SpecialManager:CopyBuffToCaster(special_data, result, param)
	if result.ignore_copy_buff == true or result.caster == nil or result.caster:IsDead() or
		result.can_add_buff == false or result.buff_id == nil then
			return
	end

	printDebug("Trigger TARGET_COPY_BUFF special_id:%d", special_data.config_id)
	if result.buff_num and result.buff_num ~= 0 then
		result.caster:AddBuffByIdNum(result.caster, result.buff_id, result.buff_num, true)
	else
		result.caster:AddBuff(result.caster, result.buff_id, true)
	end

end

function SpecialManager:RecoverOneAnger(special_data, result, param)
	printDebug("Trigger RECOVER_ONE_ANGER_DURINGFIGHT special_id:%d", special_data.config_id)
	result.recover_anger = 1
end

function SpecialManager:AddDecDmgSelfAngerMore(special_data, result, param)
	if special_data.param1 == 0 or special_data.param2 == 0 or not result or self._hero:IsDead() then
		return
	end

	if self._hero:GetAnger() <= special_data.param1 then
		return
	end

	printDebug("Trigger Special AddDecDmgSelfAngerMore special_id:%d param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)
	if not result[HEROATTRTYPE.DEC_DMG] then
		result[HEROATTRTYPE.DEC_DMG] = special_data.param2
	else
		result[HEROATTRTYPE.DEC_DMG] = result[HEROATTRTYPE.DEC_DMG] + special_data.param2
	end
end

function SpecialManager:AddDmgSelfAngerMore(special_data, result, param)
	if special_data.param1 == 0 or special_data.param2 == 0 or not result or self._hero:IsDead() then
		return
	end

	if self._hero:GetAnger() <= special_data.param1 then
		return
	end

	printDebug("Trigger Special AddDmgSelfAngerMore special_id:%d param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)
	if not result[HEROATTRTYPE.INC_DMG] then
		result[HEROATTRTYPE.INC_DMG] = special_data.param2
	else
		result[HEROATTRTYPE.INC_DMG] = result[HEROATTRTYPE.INC_DMG] + special_data.param2
	end
end

function SpecialManager:AddDmgSelfAngerLess(special_data, result, param)
	if special_data.param1 == 0 or special_data.param2 == 0 or not result or self._hero:IsDead() then
		return
	end

	if self._hero:GetAnger() >= special_data.param1 then
		return
	end

	printDebug("Trigger Special AddDmgSelfAngerLess special_id:%d param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)
	if not result[HEROATTRTYPE.INC_DMG] then
		result[HEROATTRTYPE.INC_DMG] = special_data.param2
	else
		result[HEROATTRTYPE.INC_DMG] = result[HEROATTRTYPE.INC_DMG] + special_data.param2
	end
end

function SpecialManager:AddDecDmgSelfHPMore(special_data, result, param)
	if special_data.param1 == 0 or special_data.param2 == 0 or not result or self._hero:IsDead() then
		return
	end

	if self._hero:GetCurrentHpPercent() <= (special_data.param1 / 1000) then
		return
	end

	printDebug("Trigger Special AddDecDmgSelfHPMore special_id:%d param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)
	if not result[HEROATTRTYPE.DEC_DMG] then
		result[HEROATTRTYPE.DEC_DMG] = special_data.param2
	else
		result[HEROATTRTYPE.DEC_DMG] = result[HEROATTRTYPE.DEC_DMG] + special_data.param2
	end
end

function SpecialManager:AddDmgSelfHPMore(special_data, result, param)
	if special_data.param1 == 0 or special_data.param2 == 0 or not result or self._hero:IsDead() then
		return
	end

	if self._hero:GetCurrentHpPercent() <= (special_data.param1 / 1000) then
		return
	end

	printDebug("Trigger Special AddDmgSelfHPMore special_id:%d param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)
	if not result[HEROATTRTYPE.INC_DMG] then
		result[HEROATTRTYPE.INC_DMG] = special_data.param2
	else
		result[HEROATTRTYPE.INC_DMG] = result[HEROATTRTYPE.INC_DMG] + special_data.param2
	end
end

function SpecialManager:AddDecDmgSelfHPLess(special_data, result, param)
	if special_data.param1 == 0 or special_data.param2 == 0 or not result or self._hero:IsDead() then
		return
	end

	if self._hero:GetCurrentHpPercent() >= (special_data.param1 / 1000) then
		return
	end

	printDebug("Trigger Special AddDecDmgSelfHPLess special_id:%d param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)
	if not result[HEROATTRTYPE.DEC_DMG] then
		result[HEROATTRTYPE.DEC_DMG] = special_data.param2
	else
		result[HEROATTRTYPE.DEC_DMG] = result[HEROATTRTYPE.DEC_DMG] + special_data.param2
	end
end

function SpecialManager:AddDmgSelfHPLess(special_data, result, param)
	if special_data.param1 == 0 or special_data.param2 == 0 or not result or self._hero:IsDead() then
		return
	end

	if self._hero:GetCurrentHpPercent() >= (special_data.param1 / 1000) then
		return
	end

	printDebug("Trigger Special AddDmgSelfHPLess special_id:%d param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)
	if not result[HEROATTRTYPE.INC_DMG] then
		result[HEROATTRTYPE.INC_DMG] = special_data.param2
	else
		result[HEROATTRTYPE.INC_DMG] = result[HEROATTRTYPE.INC_DMG] + special_data.param2
	end
end

function SpecialManager:AddAttrUnderDeBuff(special_data, result, param)
	if special_data.param1 <= 0 or special_data.param2 == 0 or not result or self._hero:IsDead() then
		return
	end

	if not self._hero:HasDebuff() then
		return
	end

	if special_data.param1 < HEROATTRTYPE.ATK or special_data.param1 > HEROATTRTYPE.ANGER then
		return
	end

	printDebug("Trigger Special AddAttrUnderDeBuff special_id:%d param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)
	if not result[special_data.param1] then
		result[special_data.param1] = special_data.param2
	else
		result[special_data.param1] = result[special_data.param1] + special_data.param2
	end
end

function SpecialManager:AddAttrUnderBleeding(special_data, result, param)
	if special_data.param1 <= 0 or (special_data.param2 == 0 and special_data.param3 == 0) or not result or self._hero:IsDead() then
		return
	end

	local lost_hp_percent = 1 - self._hero:GetCurrentHpPercent()
	local rate = math.floor(1000*lost_hp_percent/special_data.param1)
	if rate < 1 then
		return
	end

	printDebug("Trigger Special AddAttrUnderBleeding special_id:%d param1:%d, param2:%d, param3:%d", special_data.config_id, special_data.param1, special_data.param2, special_data.param3)
	if not result[HEROATTRTYPE.INC_DMG] then
		result[HEROATTRTYPE.INC_DMG] = special_data.param2 * rate
	else
		result[HEROATTRTYPE.INC_DMG] = result[HEROATTRTYPE.INC_DMG] + special_data.param2 * rate
	end
	if not result[HEROATTRTYPE.DEC_DMG] then
		result[HEROATTRTYPE.DEC_DMG] = special_data.param3 * rate
	else
		result[HEROATTRTYPE.DEC_DMG] = result[HEROATTRTYPE.DEC_DMG] + special_data.param3 * rate
	end
end

function SpecialManager:AddCritByAnger(special_data, result, param)
	if (special_data.param1 == 0 and special_data.param2 == 0) or not result or self._hero:IsDead() then
		return
	end

	local anger = self._hero:GetAnger()
	if anger < 1 then
		return
	end

	printDebug("Trigger Special AddCritByAnger special_id:%d param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)
	if not result[HEROATTRTYPE.CRIT_DMG] then
		result[HEROATTRTYPE.CRIT_DMG] = special_data.param1 * anger
	else
		result[HEROATTRTYPE.CRIT_DMG] = result[HEROATTRTYPE.CRIT_DMG] + special_data.param1 * anger
	end
	if not result[HEROATTRTYPE.CRIT] then
		result[HEROATTRTYPE.CRIT] = special_data.param2 * anger
	else
		result[HEROATTRTYPE.CRIT] = result[HEROATTRTYPE.CRIT] + special_data.param2 * anger
	end
end

function SpecialManager:AddBuffAfterBlock(special_data, result, param)
	if special_data.param1 <= 0 or special_data.param2 <= 0 or self._hero:IsDead() then
		return
	end

	printDebug("Trigger ADD_BUFF_AFTERBLOCK special_id:%d param1:%d, param2:%d", special_data.config_id, special_data.param1, special_data.param2)

	local target_helper = SkillTargetHelper.new(self._role_mgr:GetAllRole(), self._hero)
	local targets = target_helper:GetTargetByType(special_data.param1)
	table.walk(targets, function(role)
		if role:IsDead() == false then
			role:AddBuff(self._hero, special_data.param2)
		end
	end)
end

function SpecialManager:KillerAddBuff(special_data, result, param)
	if param == nil or param.killer == nil or special_data.param1 <= 0 then
		return
	end

	if param.killer:IsDead() then
		return
	end

	printDebug("Trigger TARGET_ADD_BUFF_BEKILLED special_id:%d param1:%d", special_data.config_id, special_data.param1)
	param.killer:AddBuff(self._hero, special_data.param1, true)
end

function SpecialManager:AddBuffAlive(special_data, result, param)
	-- print("Trigger Special AddBuffAlive", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:AddDmgAlive(special_data, result, param)
	-- print("Trigger Special AddDmgAlive", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

function SpecialManager:ExtraNormalSkillAfterPartnerAct(special_data, result, param)
	-- print("Trigger Special ExtraNormalSkillAfterPartnerAct", special_data.config_id, special_data.special_type, special_data.param1, special_data.param2, special_data.param3)
end

-- MARK get special by type
-- ==================================================================

function SpecialManager:GetSpecialData(special_type)
	local result = false
	local param1 = 0
	local param2 = 0
	local param3 = 0
	if self._specials[special_type] and #self._specials[special_type]>0 then
		table.walk(self._specials[special_type], function(special_id)
			local data = st_hero_special[special_id]
			if not data then
				return
			end

			param1 = param1 + data.param1
			param2 = param2 + data.param2
			param3 = param3 + data.param3

			if result == false then
				result = true
			end
		end)
	end
	return result, param1, param2, param3
end

function SpecialManager:GetSpecialAddonIncDmg()
	local result = 0
	local anger = self._hero:GetAnger()
	local hp_percent = self._hero:GetCurrentHpPercent()
	if self._specials[SPECIALTYPE.ADD_DMG_SELFANGERMORE] and #self._specials[SPECIALTYPE.ADD_DMG_SELFANGERMORE]>0 then
		table.walk(self._specials[SPECIALTYPE.ADD_DMG_SELFANGERMORE], function(special_id)
			local data = st_hero_special[special_id]
			if data and anger > data.param1 then
				printDebug("Trigger ADD_DMG_SELFANGERMORE, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				result = result + data.param2
			end
		end)
	end

	if self._specials[SPECIALTYPE.ADD_DMG_SELFANGERLESS] and #self._specials[SPECIALTYPE.ADD_DMG_SELFANGERLESS]>0 then
		table.walk(self._specials[SPECIALTYPE.ADD_DMG_SELFANGERLESS], function(special_id)
			local data = st_hero_special[special_id]
			if data and anger < data.param1 then
				printDebug("Trigger ADD_DMG_SELFANGERLESS, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				result = result + data.param2
			end
		end)
	end

	if self._specials[SPECIALTYPE.ADD_DMG_SELFHPMORE] and #self._specials[SPECIALTYPE.ADD_DMG_SELFHPMORE]>0 then
		table.walk(self._specials[SPECIALTYPE.ADD_DMG_SELFHPMORE], function(special_id)
			local data = st_hero_special[special_id]
			if data and hp_percent > (data.param1 / 1000) then
				printDebug("Trigger ADD_DMG_SELFHPMORE, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				result = result + data.param2
			end
		end)
	end

	if self._specials[SPECIALTYPE.ADD_DMG_SELFHPLESS] and #self._specials[SPECIALTYPE.ADD_DMG_SELFHPLESS]>0 then
		table.walk(self._specials[SPECIALTYPE.ADD_DMG_SELFHPLESS], function(special_id)
			local data = st_hero_special[special_id]
			if data and hp_percent < (data.param1 / 1000) then
				printDebug("Trigger ADD_DMG_SELFHPLESS, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				result = result + data.param2
			end
		end)
	end

	if self._specials[SPECIALTYPE.ADD_ATTR_UNDERBLEEDING] and #self._specials[SPECIALTYPE.ADD_ATTR_UNDERBLEEDING]>0 then
		table.walk(self._specials[SPECIALTYPE.ADD_ATTR_UNDERBLEEDING], function(special_id)
			local data = st_hero_special[special_id]
			if data and (1-hp_percent) > (data.param1 / 1000) then
				local dmg = data.param2 * math.floor((1-hp_percent)*1000/data.param1)
				printDebug("Trigger ADD_ATTR_UNDERBLEEDING, special_id:%d, param1:%d, param2:%d, dmg:%d", data.config_id, data.param1, data.param2, dmg)
				result = result + dmg
			end
		end)
	end
	return result
end

function SpecialManager:GetSpecialAddonDecDmg()
	local result = 0
	local anger = self._hero:GetAnger()
	local hp_percent = self._hero:GetCurrentHpPercent()

	if self._specials[SPECIALTYPE.ADD_DECDMG_SELFANGERMORE] and #self._specials[SPECIALTYPE.ADD_DECDMG_SELFANGERMORE]>0 then
		table.walk(self._specials[SPECIALTYPE.ADD_DECDMG_SELFANGERMORE], function(special_id)
			local data = st_hero_special[special_id]
			if data and anger > data.param1 then
				printDebug("Trigger ADD_DECDMG_SELFANGERMORE, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				result = result + data.param2
			end
		end)
	end

	if self._specials[SPECIALTYPE.ADD_DECDMG_SELFHPMORE] and #self._specials[SPECIALTYPE.ADD_DECDMG_SELFHPMORE]>0 then
		table.walk(self._specials[SPECIALTYPE.ADD_DECDMG_SELFHPMORE], function(special_id)
			local data = st_hero_special[special_id]
			if data and hp_percent > (data.param1/1000) then
				printDebug("Trigger ADD_DECDMG_SELFHPMORE, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				result = result + data.param2
			end
		end)
	end

	if self._specials[SPECIALTYPE.ADD_DECDMG_SELFHPLESS] and #self._specials[SPECIALTYPE.ADD_DECDMG_SELFHPLESS]>0 then
		table.walk(self._specials[SPECIALTYPE.ADD_DECDMG_SELFHPLESS], function(special_id)
			local data = st_hero_special[special_id]
			if data and hp_percent < (data.param1 / 1000) then
				printDebug("Trigger ADD_DECDMG_SELFHPLESS, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				result = result + data.param2
			end
		end)
	end

	if self._specials[SPECIALTYPE.ADD_ATTR_UNDERBLEEDING] and #self._specials[SPECIALTYPE.ADD_ATTR_UNDERBLEEDING]>0 then
		table.walk(self._specials[SPECIALTYPE.ADD_ATTR_UNDERBLEEDING], function(special_id)
			local data = st_hero_special[special_id]
			if data and (1-hp_percent) > (data.param1 / 1000) then
				local dec_dmg = data.param3 * math.floor((1-hp_percent)*1000/data.param1)
				printDebug("Trigger ADD_ATTR_UNDERBLEEDING, special_id:%d, param1:%d, param2:%d, dec_dmg:%d", data.config_id, data.param1, data.param2, dec_dmg)
				result = result + dec_dmg
			end
		end)
	end

	return result
end

function SpecialManager:GetUnderDebuffAttr(attr_id)
	local result = 0
	local is_under_debuff = self._hero:HasDebuff()
	if is_under_debuff and self._specials[SPECIALTYPE.ADD_ATTR_UNDERDEBUFF] and #self._specials[SPECIALTYPE.ADD_ATTR_UNDERDEBUFF]>0 then
		table.walk(self._specials[SPECIALTYPE.ADD_ATTR_UNDERDEBUFF], function(special_id)
			local data = st_hero_special[special_id]
			if data and attr_id == data.param1 then
				printDebug("Trigger ADD_ATTR_UNDERDEBUFF, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				result = result + data.param2
			end
		end)
	end

	return result
end

function SpecialManager:CheckSkillSpecial(skill_cmd)
	if not skill_cmd then
		return
	end

	if self._specials[SPECIALTYPE.MODIFY_SKILL_EFFECT_ALL] and #self._specials[SPECIALTYPE.MODIFY_SKILL_EFFECT_ALL]>0 then
		local max_special_ids = {}
		table.walk(self._specials[SPECIALTYPE.MODIFY_SKILL_EFFECT_ALL], function(special_id)
			local data = st_hero_special[special_id]
			if data and (max_special_ids[data.param1] == nil or special_id > max_special_ids[data.param1].config_id) then
				max_special_ids[data.param1] = data
			end
		end)

		table.walk(max_special_ids, function(data, skill_type)
			if data and skill_cmd:GetSkillType() == data.param1 then
				printDebug("Trigger MODIFY_SKILL_EFFECT_ALL, special_id:%d, param1:%d, param2:%d, param3:%d", data.config_id, data.param1, data.param2, data.param3)
				skill_cmd._skill_damage_factor = skill_cmd._skill_damage_factor + data.param2
				skill_cmd._buff_rates[1] = skill_cmd._buff_rates[1] + data.param3
			end
		end)
	end

	if self._specials[SPECIALTYPE.MODIFY_SKILL_STUNT_ALL] and #self._specials[SPECIALTYPE.MODIFY_SKILL_STUNT_ALL]>0 then
		local max_special_ids = {}
		table.walk(self._specials[SPECIALTYPE.MODIFY_SKILL_STUNT_ALL], function(special_id)
			local data = st_hero_special[special_id]
			if data and (max_special_ids[data.param1] == nil or special_id > max_special_ids[data.param1].config_id) then
				max_special_ids[data.param1] = data
			end
		end)

		table.walk(max_special_ids, function(data, skill_type)
			if data and skill_cmd:GetSkillType() == data.param1 then
				printDebug("Trigger MODIFY_SKILL_STUNT_ALL, special_id:%d, param1:%d, param2:%d, param3:%d", data.config_id, data.param1, data.param2, data.param3)
				skill_cmd._param1 = skill_cmd._param1 + data.param2
				skill_cmd._param2 = skill_cmd._param2 + data.param3
			end
		end)
	end

	if self._specials[SPECIALTYPE.MODIFY_SKILL_BUFF_ALL] and #self._specials[SPECIALTYPE.MODIFY_SKILL_BUFF_ALL]>0 then
		local max_special_ids = {}
		table.walk(self._specials[SPECIALTYPE.MODIFY_SKILL_BUFF_ALL], function(special_id)
			local data = st_hero_special[special_id]
			if data and (max_special_ids[data.param1] == nil or special_id > max_special_ids[data.param1].config_id) then
				max_special_ids[data.param1] = data
			end
		end)

		table.walk(max_special_ids, function(data, skill_type)
			if data and skill_cmd:GetSkillType() == data.param1 then
				printDebug("Trigger MODIFY_SKILL_BUFF_ALL, special_id:%d, param1:%d, param2:%d, param3:%d", data.config_id, data.param1, data.param2, data.param3)
				if data.param2 > 0 then
					skill_cmd._buff_ids[1] = data.param2
				end
				if data.param3 > 0 then
					skill_cmd._buff_ids[2] = data.param3
				end
			end
		end)
	end
end

function SpecialManager:GetFirstActAttr(attr_table)
	if not attr_table then
		return
	end

	if self._specials[SPECIALTYPE.ADD_DMG_FIRSTATTACK] and #self._specials[SPECIALTYPE.ADD_DMG_FIRSTATTACK]>0 then
		table.walk(self._specials[SPECIALTYPE.ADD_DMG_FIRSTATTACK], function(special_id)
			local data = st_hero_special[special_id]
			if data then
				printDebug("Trigger ADD_DMG_FIRSTATTACK, special_id:%d, param1:%d, param2:%d, param3:%d", data.config_id, data.param1, data.param2, data.param3)
				attr_table.INC_DMG = attr_table.INC_DMG + data.param1
				attr_table.CRIT = attr_table.CRIT + data.param2
				attr_table.CRIT_DMG= attr_table.CRIT_DMG + data.param3
			end
		end)
	end

	if self._specials[SPECIALTYPE.ADD_HIT_FIRSTATTACK] and #self._specials[SPECIALTYPE.ADD_HIT_FIRSTATTACK]>0 then
		table.walk(self._specials[SPECIALTYPE.ADD_HIT_FIRSTATTACK], function(special_id)
			local data = st_hero_special[special_id]
			if data then
				printDebug("Trigger ADD_HIT_FIRSTATTACK, special_id:%d, param1:%d, param2:%d, param3:%d", data.config_id, data.param1, data.param2, data.param3)
				attr_table.INC_DMG = attr_table.INC_DMG + data.param1
				attr_table.CRIT = attr_table.CRIT + data.param2
				attr_table.HIT= attr_table.HIT + data.param3
			end
		end)
	end
end

function SpecialManager:GetAttrByTargetAnger(attr_table, target_anger)
	if not attr_table or not target_anger then
		return
	end

	if self._specials[SPECIALTYPE.TARGET_ANGER_MORE_ADD_DMG_ATTACKING] and #self._specials[SPECIALTYPE.TARGET_ANGER_MORE_ADD_DMG_ATTACKING]>0 then
		table.walk(self._specials[SPECIALTYPE.TARGET_ANGER_MORE_ADD_DMG_ATTACKING], function(special_id)
			local data = st_hero_special[special_id]
			if data and target_anger > data.param1 then
				printDebug("Trigger TARGET_ANGER_MORE_ADD_DMG_ATTACKING, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				attr_table.INC_DMG = attr_table.INC_DMG + data.param2
			end
		end)
	end

	if self._specials[SPECIALTYPE.TARGET_ANGER_LESS_ADD_DMG_ATTACKING] and #self._specials[SPECIALTYPE.TARGET_ANGER_LESS_ADD_DMG_ATTACKING]>0 then
		table.walk(self._specials[SPECIALTYPE.TARGET_ANGER_LESS_ADD_DMG_ATTACKING], function(special_id)
			local data = st_hero_special[special_id]
			if data and target_anger < data.param1 then
				printDebug("Trigger TARGET_ANGER_LESS_ADD_DMG_ATTACKING, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				attr_table.INC_DMG = attr_table.INC_DMG + data.param2
			end
		end)
	end
end

function SpecialManager:GetAttrByTargetHpPercent(attr_table, hp_percent)
	if not attr_table or not hp_percent then
		return
	end

	if self._specials[SPECIALTYPE.TARGET_HP_MORE_ADD_DMG_ATTACKING] and #self._specials[SPECIALTYPE.TARGET_HP_MORE_ADD_DMG_ATTACKING]>0 then
		table.walk(self._specials[SPECIALTYPE.TARGET_HP_MORE_ADD_DMG_ATTACKING], function(special_id)
			local data = st_hero_special[special_id]
			if data and hp_percent > (data.param1/1000) then
				printDebug("Trigger TARGET_HP_MORE_ADD_DMG_ATTACKING, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				attr_table.INC_DMG = attr_table.INC_DMG + data.param2
			end
		end)
	end

	if self._specials[SPECIALTYPE.TARGET_HP_LESS_ADD_DMG_ATTACKING] and #self._specials[SPECIALTYPE.TARGET_HP_LESS_ADD_DMG_ATTACKING]>0 then
		table.walk(self._specials[SPECIALTYPE.TARGET_HP_LESS_ADD_DMG_ATTACKING], function(special_id)
			local data = st_hero_special[special_id]
			if data and hp_percent < (data.param1/1000) then
				printDebug("Trigger TARGET_HP_LESS_ADD_DMG_ATTACKING, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				attr_table.INC_DMG = attr_table.INC_DMG + data.param2
			end
		end)
	end

	if self._specials[SPECIALTYPE.TARGET_HP_MORE_ADD_CRIT_ATTACKING] and #self._specials[SPECIALTYPE.TARGET_HP_MORE_ADD_CRIT_ATTACKING]>0 then
		table.walk(self._specials[SPECIALTYPE.TARGET_HP_MORE_ADD_CRIT_ATTACKING], function(special_id)
			local data = st_hero_special[special_id]
			if data and hp_percent > (data.param1/1000) then
				printDebug("Trigger TARGET_HP_MORE_ADD_CRIT_ATTACKING, special_id:%d, param1:%d, param2:%d, param3:%d", data.config_id, data.param1, data.param2, data.param3)
				attr_table.CRIT = attr_table.CRIT + data.param2
				attr_table.CRIT_DMG = attr_table.CRIT_DMG + data.param3
			end
		end)
	end
end

function SpecialManager:GetAliveCountAttr(attr_table, alive_count)
	if not attr_table or not alive_count then
		return
	end

	if self._specials[SPECIALTYPE.ADD_CRIT_OUR_ALIVE_ATTACKING] and #self._specials[SPECIALTYPE.ADD_CRIT_OUR_ALIVE_ATTACKING]>0 then
		table.walk(self._specials[SPECIALTYPE.ADD_CRIT_OUR_ALIVE_ATTACKING], function(special_id)
			local data = st_hero_special[special_id]
			if data and alive_count > 0 then
				printDebug("Trigger ADD_CRIT_OUR_ALIVE_ATTACKING, special_id:%d, param1:%d, param2:%d, alive_count:%d", data.config_id, data.param1, data.param2, alive_count)
				attr_table.CRIT = attr_table.CRIT + data.param1 * alive_count
				attr_table.CRIT_DMG = attr_table.CRIT_DMG + data.param2 * alive_count
			end
		end)
	end
end

function SpecialManager:GetTargetFirstActAttr(attr_table)
	if not attr_table then
		return
	end

	if self._specials[SPECIALTYPE.TARGET_NOT_ACT_ADD_DMG_ATTACKING] and #self._specials[SPECIALTYPE.TARGET_NOT_ACT_ADD_DMG_ATTACKING]>0 then
		table.walk(self._specials[SPECIALTYPE.TARGET_NOT_ACT_ADD_DMG_ATTACKING], function(special_id)
			local data = st_hero_special[special_id]
			if data then
				printDebug("Trigger ADD_CRIT_OUR_ALIVE_ATTACKING, special_id:%d, param1:%d", data.config_id, data.param1)
				attr_table.INC_DMG = attr_table.INC_DMG + data.param1
			end
		end)
	end
end

function SpecialManager:GetAttrByHpCompare(attr_table, attacker_hp, defender_hp)
	if not attr_table or not attacker_hp or not defender_hp then
		return
	end

	local vampirism_rate = 0
	if self._specials[SPECIALTYPE.TARGET_HP_MORE_VAMPIRISM_LESS_ADDDMG_ATTACKING] and #self._specials[SPECIALTYPE.TARGET_HP_MORE_VAMPIRISM_LESS_ADDDMG_ATTACKING]>0 then
		table.walk(self._specials[SPECIALTYPE.TARGET_HP_MORE_VAMPIRISM_LESS_ADDDMG_ATTACKING], function(special_id)
			local data = st_hero_special[special_id]
			if data then
				printDebug("Trigger TARGET_HP_MORE_VAMPIRISM_LESS_ADDDMG_ATTACKING, special_id:%d, param1:%d, param2:%d, attacker_hp:%d, defender:%d", data.config_id, data.param1, data.param2, attacker_hp, defender_hp)
				if attacker_hp >= defender_hp then
					vampirism_rate = data.param1
				else
					attr_table.INC_DMG = attr_table.INC_DMG + data.param2
				end
			end
		end)
	end
	return vampirism_rate
end

function SpecialManager:CheckEnemyBuff(attr_table, defender)
	if not attr_table or not defender then
		return
	end

	local vampirism_rate = 0

	if self._specials[SPECIALTYPE.TARGET_HAS_BUFF_VAMPIRISM_AFTERACT] and #self._specials[SPECIALTYPE.TARGET_HAS_BUFF_VAMPIRISM_AFTERACT]>0 then
		table.walk(self._specials[SPECIALTYPE.TARGET_HAS_BUFF_VAMPIRISM_AFTERACT], function(special_id)
			local data = st_hero_special[special_id]
			if data and defender:GetBuffCountByEffect(data.param1) > 0 then
				printDebug("Trigger TARGET_HAS_BUFF_VAMPIRISM_AFTERACT, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				vampirism_rate = data.param2
			end
		end)
	end

	if self._specials[SPECIALTYPE.TARGET_HAS_BUFF_ADD_DMG_DURINGFIGHT] and #self._specials[SPECIALTYPE.TARGET_HAS_BUFF_ADD_DMG_DURINGFIGHT]>0 then
		table.walk(self._specials[SPECIALTYPE.TARGET_HAS_BUFF_ADD_DMG_DURINGFIGHT], function(special_id)
			local data = st_hero_special[special_id]
			local buff_count = defender:GetBuffCountByEffect(data.param1)
			if data and buff_count > 0 then
				printDebug("Trigger TARGET_HAS_BUFF_ADD_DMG_DURINGFIGHT, special_id:%d, param1:%d, param2:%d, param3:%d", data.config_id, data.param1, data.param2, data.param3)
				attr_table.CRIT = attr_table.CRIT + buff_count * data.param2
				attr_table.INC_DMG = attr_table.INC_DMG + buff_count * data.param3
			end
		end)
	end

	return vampirism_rate
end

function SpecialManager:GetAttrByAttackerAnger(attr_table, attacker_anger)
	if not attr_table or not attacker_anger then
		return
	end

	if self._specials[SPECIALTYPE.TARGET_ANGER_MORE_DEC_DMG_BEFOREUNDERATTACK] and #self._specials[SPECIALTYPE.TARGET_ANGER_MORE_DEC_DMG_BEFOREUNDERATTACK]>0 then
		table.walk(self._specials[SPECIALTYPE.TARGET_ANGER_MORE_DEC_DMG_BEFOREUNDERATTACK], function(special_id)
			local data = st_hero_special[special_id]
			if data and attacker_anger > data.param1 then
				printDebug("Trigger TARGET_ANGER_MORE_DEC_DMG_BEFOREUNDERATTACK, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				attr_table.DEC_DMG = attr_table.DEC_DMG + data.param2
			end
		end)
	end
end

function SpecialManager:GetAttrByAttackerHpPercent(attr_table, hp_percent)
	if not attr_table or not hp_percent then
		return
	end

	if self._specials[SPECIALTYPE.TARGET_HP_MORE_DEC_DMG_BEFOREUNDERATTACK] and #self._specials[SPECIALTYPE.TARGET_HP_MORE_DEC_DMG_BEFOREUNDERATTACK]>0 then
		table.walk(self._specials[SPECIALTYPE.TARGET_HP_MORE_DEC_DMG_BEFOREUNDERATTACK], function(special_id)
			local data = st_hero_special[special_id]
			if data and hp_percent > (data.param1/1000) then
				printDebug("Trigger TARGET_HP_MORE_DEC_DMG_BEFOREUNDERATTACK, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				attr_table.DEC_DMG = attr_table.DEC_DMG + data.param2
			end
		end)
	end

	if self._specials[SPECIALTYPE.TARGET_HP_LESS_DEC_DMG_BEFOREUNDERATTACK] and #self._specials[SPECIALTYPE.TARGET_HP_LESS_DEC_DMG_BEFOREUNDERATTACK]>0 then
		table.walk(self._specials[SPECIALTYPE.TARGET_HP_LESS_DEC_DMG_BEFOREUNDERATTACK], function(special_id)
			local data = st_hero_special[special_id]
			if data and hp_percent < (data.param1/1000) then
				printDebug("Trigger TARGET_HP_LESS_DEC_DMG_BEFOREUNDERATTACK, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				attr_table.DEC_DMG = attr_table.DEC_DMG + data.param2
			end
		end)
	end
end

function SpecialManager:CheckAttackerBuff(attr_table, attacker)
	if not attr_table or not attacker then
		return
	end

	if self._specials[SPECIALTYPE.TARGET_HAS_BUFF_DEC_DMG_BEFOREUNDERATTACK] and #self._specials[SPECIALTYPE.TARGET_HAS_BUFF_DEC_DMG_BEFOREUNDERATTACK]>0 then
		table.walk(self._specials[SPECIALTYPE.TARGET_HAS_BUFF_DEC_DMG_BEFOREUNDERATTACK], function(special_id)
			local data = st_hero_special[special_id]
			if data and attacker:GetBuffCountByEffect(data.param1) > 0 then
				printDebug("Trigger TARGET_HAS_BUFF_DEC_DMG_BEFOREUNDERATTACK, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				attr_table.DEC_DMG = attr_table.DEC_DMG + data.param2
			end
		end)
	end
end

function SpecialManager:CheckAttackerSkillEffect(attr_table, effect_type)
	if not attr_table or not effect_type then
		return
	end

	if self._specials[SPECIALTYPE.TARGET_SKILL_EFFECT_DEC_DMG_BEFOREUNDERATTACK] and #self._specials[SPECIALTYPE.TARGET_SKILL_EFFECT_DEC_DMG_BEFOREUNDERATTACK]>0 then
		table.walk(self._specials[SPECIALTYPE.TARGET_SKILL_EFFECT_DEC_DMG_BEFOREUNDERATTACK], function(special_id)
			local data = st_hero_special[special_id]
			if data and ( data.param1 == effect_type or data.param2 == effect_type ) then
				printDebug("Trigger TARGET_SKILL_EFFECT_DEC_DMG_BEFOREUNDERATTACK, special_id:%d, param1:%d, param2:%d, param3:%d", data.config_id, data.param1, data.param2, data.param3)
				attr_table.DEC_DMG = attr_table.DEC_DMG + data.param3
			end
		end)
	end
end

function SpecialManager:GetMaxLoseHp(damage, max_hp)
	if not damage or not max_hp then
		return 0
	end

	local result = damage
	if self._specials[SPECIALTYPE.DEC_DAMAGE_HP_LIMIT_UNDERATTACKING] and #self._specials[SPECIALTYPE.DEC_DAMAGE_HP_LIMIT_UNDERATTACKING]>0 then
		table.walk(self._specials[SPECIALTYPE.DEC_DAMAGE_HP_LIMIT_UNDERATTACKING], function(special_id)
			local data = st_hero_special[special_id]
			if data then
				local max_damage = data.param1 * max_hp / 1000
				if result > max_damage then
					result = max_damage
					printDebug("Trigger DEC_DAMAGE_HP_LIMIT_UNDERATTACKING, special_id:%d, param1:%d, total_damage_limit:%d", data.config_id, data.param1, max_damage)
				end
			end
		end)
	end
	return result
end

function SpecialManager:CheckDoubleRelease()
	if self._specials[SPECIALTYPE.PROBABLY_DOUBLE_HIT_ATTACKING] and #self._specials[SPECIALTYPE.PROBABLY_DOUBLE_HIT_ATTACKING]>0 then
		for _, special_id in ipairs(self._specials[SPECIALTYPE.PROBABLY_DOUBLE_HIT_ATTACKING]) do
			local data = st_hero_special[special_id]
			if data and random(1000) <= data.param1 then
				printDebug("Trigger PROBABLY_DOUBLE_HIT_ATTACKING, special_id:%d, param1:%d", data.config_id, data.param1)
				return true
			end
		end
	end
	return false
end

function SpecialManager:GetRecoverHpByDamage(total_damage)
	if not total_damage then
		return 0
	end
	local result = 0
	if self._specials[SPECIALTYPE.VAMPIRISM_AFTERACT] and #self._specials[SPECIALTYPE.VAMPIRISM_AFTERACT]>0 then
		table.walk(self._specials[SPECIALTYPE.VAMPIRISM_AFTERACT], function(special_id)
			local data = st_hero_special[special_id]
			if data then
				local recover_hp = total_damage * data.param1 / 1000
				printDebug("Trigger VAMPIRISM_AFTERACT, special_id:%d, param1:%d, recover_hp:%d", data.config_id, data.param1, recover_hp)
				result = result + recover_hp
			end
		end)
	end
	return result
end

function SpecialManager:GetSkillAfterAngerSkill()
	if self._specials[SPECIALTYPE.DOUBLE_SKILL_AFTERRELEASEANGERSKILL] and #self._specials[SPECIALTYPE.DOUBLE_SKILL_AFTERRELEASEANGERSKILL]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.DOUBLE_SKILL_AFTERRELEASEANGERSKILL]) do
			local data = st_hero_special[special_id]
			if data then
				printDebug("Trigger DOUBLE_SKILL_AFTERRELEASEANGERSKILL, special_id:%d, param1:%d", data.config_id, data.param1)
				return data.param1
			end
		end
	end
	return 0
end

function SpecialManager:CheckTargetBuffAfterAngerSkill()
	if self._specials[SPECIALTYPE.ADD_BUFF_AFTERRELEASEANGERSKILL] and #self._specials[SPECIALTYPE.ADD_BUFF_AFTERRELEASEANGERSKILL]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.ADD_BUFF_AFTERRELEASEANGERSKILL]) do
			local data = st_hero_special[special_id]
			if data and data.param1 and data.param2 then
				printDebug("Trigger ADD_BUFF_AFTERRELEASEANGERSKILL, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				local target_helper = SkillTargetHelper.new(self._role_mgr:GetAllRole(), self._hero)
				local targets = target_helper:GetTargetByType(data.param1)
				table.walk(targets, function(role)
					if role:IsDead() == false then
						role:AddBuff(self._hero, data.param2)
					end
				end)
			end
		end
	end
end

function SpecialManager:CheckAttrAfterAngerSkill()
	if self._specials[SPECIALTYPE.ADD_ATTR_AFTERRELEASEANGERSKILL] and #self._specials[SPECIALTYPE.ADD_ATTR_AFTERRELEASEANGERSKILL]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.ADD_ATTR_AFTERRELEASEANGERSKILL]) do
			local data = st_hero_special[special_id]
			if data then
				printDebug("Trigger ADD_ATTR_AFTERRELEASEANGERSKILL, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				self._hero:AddAttr(data.param1, data.param2)
			end
		end
	end
end

function SpecialManager:VampirismAfterAngerSkill()
	if self._specials[SPECIALTYPE.VAMPIRISM_AFTERRELEASEANGERSKILL] and #self._specials[SPECIALTYPE.VAMPIRISM_AFTERRELEASEANGERSKILL]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.VAMPIRISM_AFTERRELEASEANGERSKILL]) do
			local data = st_hero_special[special_id]
			if data and data.param1 and data.param2 then
				printDebug("Trigger VAMPIRISM_AFTERRELEASEANGERSKILL, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				local target_helper = SkillTargetHelper.new(self._role_mgr:GetAllRole(), self._hero)
				local targets = target_helper:GetTargetByType(data.param1)
				local add_hp = 0
				table.walk(targets, function(role)
					if role:IsDead() == false then
						local vampireism_hp = role:GetMaxHp() * data.param2 / 1000
						if vampireism_hp > 0 then
							add_hp = add_hp + vampireism_hp
							role:SubHp(vampireism_hp, false, false, 0, 0, SKILL_OR_BUFF.SPECIAL, data.config_id, self._hero:GetId(), self._hero:GetCamp())
						end
					end
				end)

				if add_hp > 0 then
					self._hero:AddHp(add_hp, SKILL_OR_BUFF.SPECIAL, data.config_id, self._hero:GetId(), self._hero:GetCamp(), false)
				end
			end
		end
	end
end

function SpecialManager:CheckDoubleNormalSkill(release_num)
	if self._specials[SPECIALTYPE.PROBABLY_DOUBLE_HIT_AFTERNORMALSKILL] and #self._specials[SPECIALTYPE.PROBABLY_DOUBLE_HIT_AFTERNORMALSKILL]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.PROBABLY_DOUBLE_HIT_AFTERNORMALSKILL]) do
			local data = st_hero_special[special_id]
			if data and data.param1 then
				local rate = data.param1 - release_num * 50
				rate = rate < 0 and 0 or rate
				if random(1000) <= rate then
					printDebug("Trigger PROBABLY_DOUBLE_HIT_AFTERNORMALSKILL, special_id:%d, param1:%d, release_num:%d", data.config_id, data.param1, release_num)
					return true
				end
			end
		end
	end
	return false
end

function SpecialManager:AddAttrByStuntAnger(lose_anger)
	if self._specials[SPECIALTYPE.TARGET_LOSE_ANGER_ADD_DMG_AFTERRELEASEANGERSKILL] and #self._specials[SPECIALTYPE.TARGET_LOSE_ANGER_ADD_DMG_AFTERRELEASEANGERSKILL]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.TARGET_LOSE_ANGER_ADD_DMG_AFTERRELEASEANGERSKILL]) do
			local data = st_hero_special[special_id]
			if data and data.param1 then
				printDebug("Trigger TARGET_LOSE_ANGER_ADD_DMG_AFTERRELEASEANGERSKILL, special_id:%d, param1:%d, lose_anger:%d", data.config_id, data.param1, lose_anger)
				self._hero:AddAttr(HEROATTRTYPE.INC_DMG, lose_anger * data.param1)
			end
		end
	end
end

function SpecialManager:CheckHeal(attr_table, target_hp_percent, target_position)
	if self._specials[SPECIALTYPE.TARGET_HP_LOSE_ADDHEAL] and #self._specials[SPECIALTYPE.TARGET_HP_LOSE_ADDHEAL]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.TARGET_HP_LOSE_ADDHEAL]) do
			local data = st_hero_special[special_id]
			if data and data.param1 and data.param2 and target_hp_percent*1000 < data.param1 then
				printDebug("Trigger TARGET_HP_LOSE_ADDHEAL, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				attr_table.HEAL = attr_table.HEAL + data.param2
			end
		end
	end

	if self._specials[SPECIALTYPE.TARGET_FRONT_ROW_ADDHEAL] and #self._specials[SPECIALTYPE.TARGET_FRONT_ROW_ADDHEAL]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.TARGET_FRONT_ROW_ADDHEAL]) do
			local data = st_hero_special[special_id]
			if data and data.param1 and target_position>=1 and target_position<=3 then
				printDebug("Trigger TARGET_FRONT_ROW_ADDHEAL, special_id:%d, param1:%d", data.config_id, data.param1)
				attr_table.HEAL = attr_table.HEAL + data.param1
			end
		end
	end
end

function SpecialManager:CheckExcessiveHeal(defender, excessive_heal)
	if self._specials[SPECIALTYPE.EXCESSIVE_HEAL_ADDSHIELD] and #self._specials[SPECIALTYPE.EXCESSIVE_HEAL_ADDSHIELD]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.EXCESSIVE_HEAL_ADDSHIELD]) do
			local data = st_hero_special[special_id]
			if data and data.param1 and data.param2 then
				local shield = math.floor(excessive_heal * data.param1 / 1000)
				printDebug("Trigger EXCESSIVE_HEAL_ADDSHIELD, special_id:%d, param1:%d, param2:%d, shield:%d", data.config_id, data.param1, data.param2, shield)
				defender:AddBuffByIdNum(self._hero, data.param2, shield, 1)
			end
		end
	end
end

function SpecialManager:CheckAttrAfterHurt(attacker, effect_type)
	if self._specials[SPECIALTYPE.ADD_ATTR_AFTERUNDERATTACK] and #self._specials[SPECIALTYPE.ADD_ATTR_AFTERUNDERATTACK]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.ADD_ATTR_AFTERUNDERATTACK]) do
			local data = st_hero_special[special_id]
			if data and data.param1 and data.param2 then
				printDebug("Trigger ADD_ATTR_AFTERUNDERATTACK, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				if self._hero:IsDead() == false then
					self._hero:AddAttr(data.param1, data.param2)
				end
			end
		end
	end

	if self._specials[SPECIALTYPE.TARGET_SKILL_EFFECT_ADD_ATTR_AFTERUNDERATTACK] and #self._specials[SPECIALTYPE.TARGET_SKILL_EFFECT_ADD_ATTR_AFTERUNDERATTACK]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.TARGET_SKILL_EFFECT_ADD_ATTR_AFTERUNDERATTACK]) do
			local data = st_hero_special[special_id]
			if data and data.param1 and data.param2 and data.param3 and effect_type == data.param1 then
				printDebug("Trigger TARGET_SKILL_EFFECT_ADD_ATTR_AFTERUNDERATTACK, special_id:%d, param1:%d, param2:%d, param3:%d", data.config_id, data.param1, data.param2, data.param3)
				if self._hero:IsDead() == false then
					self._hero:AddAttr(data.param2, data.param3)
				end
			end
		end
	end

	if self._specials[SPECIALTYPE.TARGET_REDUCE_ATTR_AFTERUNDERATTACK] and #self._specials[SPECIALTYPE.TARGET_REDUCE_ATTR_AFTERUNDERATTACK]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.TARGET_REDUCE_ATTR_AFTERUNDERATTACK]) do
			local data = st_hero_special[special_id]
			if data and data.param1 and data.param2 then
				printDebug("Trigger TARGET_REDUCE_ATTR_AFTERUNDERATTACK, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				if attacker:IsDead() == false then
					attacker:SubAttr(data.param1, data.param2)
				end
			end
		end
	end

	if self._specials[SPECIALTYPE.ADD_ANGER_UNDER_ATTACK] and #self._specials[SPECIALTYPE.ADD_ANGER_UNDER_ATTACK]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.ADD_ANGER_UNDER_ATTACK]) do
			local data = st_hero_special[special_id]
			if data and data.param1 and random(1000) <= data.param1 then
				printDebug("Trigger ADD_ANGER_UNDER_ATTACK, special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)
				if self._hero:IsDead() == false then
					self._hero:AddAnger(data.param2, true)
				end
			end
		end
	end
end

function SpecialManager:CheckReflectDamage(attacker, damage)
	if self._specials[SPECIALTYPE.REFLECTING_DMG_AFTERUNDERATTACK] and #self._specials[SPECIALTYPE.REFLECTING_DMG_AFTERUNDERATTACK]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.REFLECTING_DMG_AFTERUNDERATTACK]) do
			local data = st_hero_special[special_id]
			if data and data.param1 and data.param2 and self._hero:IsDead() == false and random(1000) <= data.param1 and attacker:IsDead() == false then
				local reflect_damage = math.ceil(damage * data.param2 / 1000)
				printDebug("Trigger REFLECTING_DMG_AFTERUNDERATTACK, special_id:%d, param1:%d, param2:%d, reflect_damage:%d", data.config_id, data.param1, data.param2, reflect_damage)
				attacker:SubHp(reflect_damage, false, false, 0, 0, SKILL_OR_BUFF.SPECIAL, data.config_id, self._hero:GetId(), self._hero:GetCamp())
			end
		end
	end
end

function SpecialManager:CheckStrikeBack()
	if self._specials[SPECIALTYPE.BEAT_BACK_AFTERUNDERATTACK] and #self._specials[SPECIALTYPE.BEAT_BACK_AFTERUNDERATTACK]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.BEAT_BACK_AFTERUNDERATTACK]) do
			local data = st_hero_special[special_id]
			if data and data.param1 and random(1000) <= data.param1 then
				printDebug("Trigger BEAT_BACK_AFTERUNDERATTACK, special_id:%d, param1:%d", data.config_id, data.param1)
				return true
			end
		end
	end
	return false
end

function SpecialManager:CheckNormalSkillAfterPartnerAct()
	if self._specials[SPECIALTYPE.EXTRA_NORMAL_SKILL_AFTERPARTNERACT] and #self._specials[SPECIALTYPE.EXTRA_NORMAL_SKILL_AFTERPARTNERACT]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.EXTRA_NORMAL_SKILL_AFTERPARTNERACT]) do
			local data = st_hero_special[special_id]
			if data then
				self._role_mgr:RegisterNotify("EXTRA_NORMAL_SKILL_AFTERPARTNERACT", self._hero, function(role, param)
					local trigger = param[1]
					if not trigger or role:IsDead() or trigger:GetCamp() ~= role:GetCamp() or trigger:GetId() == role:GetId() then
						return
					end
					if random(1000) <= data.param1 then
						printDebug("Trigger EXTRA_NORMAL_SKILL_AFTERPARTNERACT, special_id:%d, param1:%d, param2:%d, hero_id:%d, hero_camp:%d", data.config_id, data.param1, data.param2, role:GetId(), role:GetCamp())
						local target_helper = SkillTargetHelper.new(self._role_mgr:GetAllRole(), role)
						local skill_cmd = SkillCommand.new(role, role:GetNormalSkillID())
						skill_cmd._main_targets = target_helper:GetTargetByType(data.param2)
						if #skill_cmd._main_targets > 0 then
							for i=1, skill_cmd:GetReleaseNum() do
								FIGHT_PACK_MANAGER:SkillReleasePack(role:GetId(), role:GetCamp(), skill_cmd, i, (i ~= 1))
								skill_cmd:DoSkill(i)
							end
						end
					end
				end)
			end
			return
		end
	end
end


function SpecialManager:TriggerArua()
	if self._specials[SPECIALTYPE.ADD_ARUA_BUFF_ALIVE] and #self._specials[SPECIALTYPE.ADD_ARUA_BUFF_ALIVE]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.ADD_ARUA_BUFF_ALIVE]) do
			local data = st_hero_special[special_id]
			if data and data.param1 and data.param2 then
				printDebug("Trigger ADD_ARUA_BUFF_ALIVE special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)

				local target_helper = SkillTargetHelper.new(self._role_mgr:GetAllRole(), self._hero)
				local targets = target_helper:GetTargetByType(data.param1)
				table.walk(targets, function(role)
					if role:IsDead() == false then
						role:AddBuff(self._hero, data.param2, true)
						if data.param3 and data.param3>0 then
							role:AddBuff(self._hero, data.param3, true)
						end
					end
				end)
			end
		end
	end
end

function SpecialManager:CleanAruaOnDie()
	if self._specials[SPECIALTYPE.ADD_ARUA_BUFF_ALIVE] and #self._specials[SPECIALTYPE.ADD_ARUA_BUFF_ALIVE]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.ADD_ARUA_BUFF_ALIVE]) do
			local data = st_hero_special[special_id]
			if data and data.param1 and data.param2 then
				printDebug("CleanAruaOnDie ADD_ARUA_BUFF_ALIVE special_id:%d, param1:%d, param2:%d", data.config_id, data.param1, data.param2)

				local target_helper = SkillTargetHelper.new(self._role_mgr:GetAllRole(), self._hero)
				local targets = target_helper:GetTargetByType(data.param1)
				table.walk(targets, function(role)
					if role:IsDead() == false then
						role:RemoveBuff(data.param2)
					end
				end)
			end
		end
	end
end

function SpecialManager:CheckImmuneLoseAnger()
	if self._specials[SPECIALTYPE.IMMUNE_LOSE_ANGER] and #self._specials[SPECIALTYPE.IMMUNE_LOSE_ANGER]>0 then
		for _,special_id in pairs(self._specials[SPECIALTYPE.IMMUNE_LOSE_ANGER]) do
			local data = st_hero_special[special_id]
			if data then
				printDebug("Trigger IMMUNE_LOSE_ANGER, special_id:%d, param1:%d", data.config_id)
				return true
			end
		end
	end
	return false
end

return SpecialManager
