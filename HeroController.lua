local HeroModel = require("HeroModel")
local BuffManager = require("BuffManager")
local SkillCommand = require("SkillCommand")
local SkillController = require("SkillController")
local SkillTargetHelper = require("SkillTargetHelper")
local Buff = require("Buff")
local print_r = require("print_r")
local json = require("json")
local SpecialManager = require("SpecialManager")
local HeroController = class("HeroController")

local SKILL_INDEX = {
	NORMAL_SKILL = 1,
	ANGER_SKILL = 2,
	POKEBALL_SKILL = 3,
	SKILL_BEGIN = 4
}

function HeroController:ctor(role_manager, hero_data, camp)
	self._is_transform = false

	self._role_manager = role_manager

	self._special_manager = SpecialManager.new(self, role_manager)

	self._buff_manager = BuffManager.new(self)
	self._hero = HeroModel.new(hero_data, self)
	self._hero:SetCamp(camp)

	self._skills = {}
	self._hitskills = {}
	self._startskills = {}
	self._skill_cd = {}
	self._self_cast_buffs = {}
	self._first_act = true
	self._skill_level = {}

	self:InitSkills(hero_data)

	if self:GetCurrentHp() <= 0 then
		self:Die()
	end

	self._default_anger = self:GetAnger()
end

function HeroController:GetRoleMgr()
	return self._role_manager
end

function HeroController:InitSkills(data)
	local skill_id
	if data.normal_skill > 0 then
		skill_id = data.normal_skill
		self._skills[SKILL_INDEX.NORMAL_SKILL] = skill_id
		self._skill_cd[skill_id] = 0
		self._skill_level[skill_id] = 1
	end

	if data.anger_skill > 0 then
		skill_id = data.anger_skill
		self._skills[SKILL_INDEX.ANGER_SKILL] = skill_id
		self._skill_cd[skill_id] = 0
		self._skill_level[skill_id] = 1
	end

	if data.pokeball_skill > 0 then
		skill_id = data.pokeball_skill
		self._skills[SKILL_INDEX.POKEBALL_SKILL] = skill_id
		self._skill_cd[skill_id] = 0
		self._skill_level[skill_id] = 1
	end

	-- data.special
	self._special_manager:Init(data.special)

	-- 开场BUFF
	if data.begining_buffs then
		table.walk(data.begining_buffs, function(buff_id)
			self:AddBuff(self, buff_id)
		end)
	end

	-- table.walk(data.skills, function(skill_data)
	-- 	skill_id = skill_data.skill_id
	-- 	-- TODO start_skill onattack_skill
	-- 	if skill_id and skill_id > 0 then
	-- 		self._skill_cd[skill_id] = 0

	-- 		local skill_class = SkillCommand.GetSkillInfoByKey(skill_id, "skill_class") or ""
	-- 		if skill_class == "Normal" then
	-- 			table.insert(self._skills, SKILL_INDEX.SKILL_BEGIN, {skill_id=skill_id, skill_level=skill_data.skill_level})
	-- 		elseif skill_class == "Start" then
	-- 		elseif skill_class == "AURA" then
	-- 		elseif skill_class == "Last" then
	-- 		elseif skill_class == "OnAttack" then
	-- 		end
	-- 	end
	-- end)
end

function HeroController:OnEnter()
	-- call when enter the battle
	self._special_manager:Trigger("SPECIAL_TRIGGER_BEGIN")

	-- regisger partner act
	self._special_manager:CheckNormalSkillAfterPartnerAct()

	-- trigger arua
	self._special_manager:TriggerArua()

end

function HeroController:Update(data)

	if self:IsDead() then
		self:UpdateSelfCastBuff()
		return
	end

	self._special_manager:Trigger("SPECIAL_TRIGGER_BEFORE_ACT")

	self._buff_manager:ActionBeginUpdate()

	if self:IsDead() then
		self:UpdateSelfCastBuff()
		return
	end

	self:CheckSkillCD()
	self:Attack()
	self:UpdateSelfCastBuff()
	-- self._buff_manager:ActionEndUpdate()

	self._special_manager:Trigger("SPECIAL_TRIGGER_ROUNDOVER")
	-- self._special_manager:Trigger("SPECIAL_TRIGGER_AFTER_ACT")

	if self._first_act == true then
		self._first_act = false
	end
end

function HeroController:UpdateOnDie(data)
	printDebug("Update when hero is dead, id:%d, camp:%d", self:GetId(), self:GetCamp())
	self:UpdateSelfCastBuff()
end

function HeroController:SelfCastBuff(buff)
	if buff then
		table.insert(self._self_cast_buffs, buff)
	end
end

function HeroController:UpdateSelfCastBuff()
	if self._self_cast_buffs then
		local i = 1
		while i<=#self._self_cast_buffs do
			local buff = self._self_cast_buffs[i]
			local is_remove = buff:Update()
			if is_remove == true then
				table.remove(self._self_cast_buffs, i)
			else
				i = i + 1
			end
		end
	end
end

function HeroController:RemoveSelfCastBuff(remove_buff)
	if self._self_cast_buffs then
		for i=1,#self._self_cast_buffs do
			if self._self_cast_buffs[i] == remove_buff then
				table.remove(self._self_cast_buffs, i)
				break
			end
		end
	end
end

function HeroController:UnderAttack(attacker)
	-- TODO
end

function HeroController:CheckSkillCD()
	table.walk(self._skill_cd, function(v, k)
		if v > 0 then
			self._skill_cd[k] = self._skill_cd[k] - 1
		end
	end)
end

function HeroController:ResetCD()
	table.walk(self._skill_cd, function(v, k)
		if v > 0 then
			self._skill_cd[k] = 0
		end
	end)
end

function HeroController:Attack()
	-- TODO Refactor to fsm
	if self:GetDizz() or self:GetPetrified() then
		self:AddAnger(ANGERTYPE.ADD_ANGER_PER_ROUND, true)
		return
	end

	-- if self:GetAnger() >= ANGERTYPE.FULLANGER then
	-- 	self:Transform()
	-- end

	local skill_id = self:GetSkill()
	if skill_id then
		printDebug("Start Cast Skill, id:%d, camp:%d, skill_id:%d", self:GetId(), self:GetCamp(), skill_id)
		self:CastSkill(skill_id)
		printDebug("End Cast Skill, id:%d, camp:%d, skill_id:%d", self:GetId(), self:GetCamp(), skill_id)
	end

	--TODO check after attack
	-- self:CareerActor()
	self._special_manager:Trigger("SPECIAL_TRIGGER_AFTER_ACT")

	self._role_manager:TriggerNotify("EXTRA_NORMAL_SKILL_AFTERPARTNERACT", self)
end

function HeroController:CareerActor()
	self._role_manager:CareerActor(self._hero:GetId(), self._hero:GetCamp(), self._hero:GetCareer())
end

function HeroController:GetSkill()
	local skill_id

	if not self:GetSilence() and self:GetAnger() >= ANGERTYPE.FULLANGER then
		skill_id = self._skills[SKILL_INDEX.POKEBALL_SKILL]
		local partner_id = self._hero:GetPartnerConfigId()
		if skill_id and partner_id > 0 and self._role_manager:IsHeroAlive(partner_id, self:GetCamp()) and skill_id > 0 and self:GetCD(skill_id) == 0 then
			return skill_id
		end
		skill_id = self._skills[SKILL_INDEX.ANGER_SKILL]
		if skill_id and skill_id > 0 and self:GetCD(skill_id) == 0 then
			return skill_id
		end
	end

	skill_id = self._skills[SKILL_INDEX.NORMAL_SKILL]
	if skill_id and skill_id > 0 and self:GetCD(skill_id) == 0 then
		return skill_id
	end

	return nil
end

function HeroController:CheckSkillCondition(skill_id)
	local condition = SkillCommand.GetSkillInfoByKey(skill_id, "condition_arg")
	if condition == ConditionArg.NONE then
		return true

	elseif condition == ConditionArg.HP75 then
		if self:GetCurrentHp() / self:GetBaseHp() <= 0.75 then
			return true
		end

	elseif condition == ConditionArg.HP50 then
		if self:GetCurrentHp() / self:GetBaseHp() <= 0.5 then
			return true
		end

	elseif condition == ConditionArg.HP25 then
		if self:GetCurrentHp() / self:GetBaseHp() <= 0.25 then
			return true
		end

	elseif condition == ConditionArg.SERVANT1 then
		if #self._role_manager:GetRoles(self:GetCamp()) > 1 then
			return true
		end

	elseif condition == ConditionArg.ROUND3 then
		if self._role_manager:GetBattleController():GetRound() % 3 == 0 then
			return true
		end
	end
	return false
end

function HeroController:CastSkill(skill_id)
	local skill_level = self._skill_level[skill_id] or 1
	local skill_cmd = SkillCommand.new(self, skill_id, skill_level)
	local result = false
	if skill_cmd then
		self._special_manager:CheckSkillSpecial(skill_cmd)
		result = SkillController.DoSkillCommand(skill_cmd, self._role_manager, false, true)

		-- special
		local total_damage = skill_cmd._total_damage

		if skill_cmd:GetSkillType() == SKILLTYPE.ANGER or skill_cmd:GetSkillType() == SKILLTYPE.POKEBALL then
			local another_skill_id = self._special_manager:GetSkillAfterAngerSkill()
			if another_skill_id>0 then
				printDebug("Release Skill After Anger Skill:%d", another_skill_id)
				skill_cmd = SkillCommand.new(self, another_skill_id)
				SkillController.DoSkillCommand(skill_cmd, self._role_manager, true)
				total_damage = total_damage + skill_cmd._total_damage
			end

			self._special_manager:CheckTargetBuffAfterAngerSkill()
			self._special_manager:CheckAttrAfterAngerSkill()
			self._special_manager:VampirismAfterAngerSkill()
		else
			local extra_normal_skill_num = 0
			while self._special_manager:CheckDoubleNormalSkill(extra_normal_skill_num) do
				extra_normal_skill_num = extra_normal_skill_num + 1
				printDebug("Multi Release Normal Skill:%d", skill_id)
				skill_cmd = SkillCommand.new(self, skill_id)
				SkillController.DoSkillCommand(skill_cmd, self._role_manager, true)
				total_damage = total_damage + skill_cmd._total_damage
			end
		end

		if self._special_manager:CheckDoubleRelease() then
			printDebug("Double Release Skill:%d", skill_id)
			skill_cmd = SkillCommand.new(self, skill_id)
			SkillController.DoSkillCommand(skill_cmd, self._role_manager, true)
			total_damage = total_damage + skill_cmd._total_damage
		end

		local recover_hp = self._special_manager:GetRecoverHpByDamage(total_damage) or 0
		if recover_hp>0 then
			self:AddHp(recover_hp, SKILL_OR_BUFF.SPECIAL, 0, self:GetId(), self:GetCamp(), false)
		end
	end

	return result
end

function HeroController:AddSkillCD(skill_id, skill_cd)
	self._skill_cd[skill_id] = skill_cd
	printDebug("Add Skill CD skill_id:%d, skill_cd:%d", skill_id, skill_cd)
end

function HeroController:GetCD(skill_id)
	return self._skill_cd[skill_id]
end

function HeroController:CreateSkillCommand(skill_id, skill_level)
	local skill_cmd = SkillCommand.new(self, skill_id, skill_level)
	return skill_cmd
end

function HeroController:AddSkillLevel(skill_id, skill_level)
	if not self._skill_level[skill_id] then
		self._skill_level[skill_id] = 1
	end

	self._skill_level[skill_id] = self._skill_level[skill_id] + 1
	printDebug("Add Skill Level skill_id:%d, skill_level:%d", skill_id, skill_level)
end

function HeroController:CheckSSkillBuff(skill_cmd)
	if (skill_cmd and (skill_cmd:GetSkillType() == SKILLTYPE.BIG or skill_cmd:GetSkillType() == SKILLTYPE.SUPERBIG)) and (self.hero.battle_logic:GetFightType() ~= FIGHTTYPE.AUTO) then
		self._buff_manager:RunSub50RateHp()
	end
end

function HeroController:CheckNormalBuff(skill_cmd)
	if skill_cmd and (skill_cmd:GetSkillType() == SKILLTYPE.NORMAL) then
		self._buff_manager:RunSub50RateHpNormal()
	end
end

function HeroController:IsGod()
	return self._buff_manager:IsGod()
end

function HeroController:GetMaxHp()
	return self._hero:GetMaxHp()
end

function HeroController:GetCurrentHp()
	return self._hero:GetCurrentHp()
end

function HeroController:GetCurrentHpPercent()
	local percent = self._hero:GetCurrentHp() / self._hero:GetMaxHp()
	if percent > 1 then
		percent = 1
	elseif percent < 0 then
		percent = 0
	end
	return percent
end

function HeroController:AddHp(add_hp, skill_or_buff, skill_buff_id, caster_id, caster_camp, is_crit)
	if self._hero:IsDead() then
		return
	end

	add_hp = math.ceil(add_hp)
	local current_hp = self._hero:AddHp(add_hp)
	printDebug("Hero:%d, Camp:%d Add HP:%d, Current:%d", self:GetId(), self:GetCamp(), add_hp, current_hp)
	FIGHT_PACK_MANAGER:AddHp(self:GetId(), self:GetCamp(), add_hp, skill_or_buff, skill_buff_id, is_crit)

	self._role_manager:RecordHeal(self:GetCamp(), add_hp)
end

function HeroController:SubHp(sub_hp, is_crit, is_block, hit_count, effect_type, skill_or_buff, skill_buff_id, hero_id, hero_camp)
	local sub_hp_count = sub_hp
	sub_hp = math.ceil(sub_hp)

	-- if skill_or_buff ~= SKILL_OR_BUFF.BUFF then
	sub_hp = self._buff_manager:SubShield(sub_hp)
	-- end

	if  hero_id > 0 and hero_camp ~= self:GetCamp() then
		self._role_manager:RecordDamage(hero_camp, sub_hp_count)
	end

	if sub_hp < 0 then
		return
	end

	local current_hp = self._hero:SubHp(sub_hp)
	printDebug("Hero:%d, Camp:%d, Sub HP:%d, Current:%d, crit:%d, block:%d, skill_or_buff:%d, id:%d",self:GetId(), self:GetCamp(), sub_hp, current_hp, is_crit and 1 or 0, is_block and 1 or 0, skill_or_buff, skill_buff_id)
	FIGHT_PACK_MANAGER:SubHp(self:GetId(), self:GetCamp(), sub_hp, current_hp, is_crit, is_block, hit_count, effect_type, skill_or_buff, skill_buff_id)

	if (self._role_manager._mode >= FIGHTMODE.MODE3 and self._role_manager._mode <= FIGHTMODE.MODE5) and self:GetCamp() == CAMPTYPE.PEER then
		self._role_manager:SubSharedHP(sub_hp)
		return
	end

	if current_hp <= 0 then
		local buff_id, heal_factor = self._buff_manager:GetRebornHealFactor()
		if heal_factor > 0 then
			-- TODO new fight pack cmd

			local addhp = math.ceil(heal_factor * self:GetMaxHp() / 100)
			self:AddHp(addhp, SKILL_OR_BUFF.BUFF, buff_id, self:GetId(), self:GetCamp(), false)
		else
			self:Die()
		end
	end
end

function HeroController:AddAnger(add_anger, bool)
	if self._hero:IsDead() then
		return
	end

	if self._buff_manager:HasLockAngerInc() == true then
		return
	end
	self._hero:AddAnger(add_anger, bool)
	printDebug("Hero Add Anger:%d, Current:%d, id:%d, camp:%d", add_anger, self:GetAnger(), self:GetId(), self:GetCamp())
	FIGHT_PACK_MANAGER:AddAnger(self._hero:GetId(), self._hero:GetCamp(), add_anger, self._hero:GetAnger())

	if self._hero:GetAnger() >= ANGERTYPE.FULLANGER and self._hero:GetPokeballSkill()>0 then
		local partner_id = self:GetPartnerId()
		if partner_id and partner_id > 0 then
			printDebug("Hero PokeballSkill State, id1:%d, id2:%d, camp:%d, state:%d", self._hero:GetId(), partner_id, self._hero:GetCamp(), 1)
			FIGHT_PACK_MANAGER:PokeballSkillState(self._hero:GetId(), partner_id, self._hero:GetCamp(), 1)
		end
	end
end

function HeroController:SubAnger(sub_anger)
	if self._buff_manager:HasLockAngerDec() == true then
		return
	end

	if self._special_manager:CheckImmuneLoseAnger() == true then
		return
	end

	self._hero:SubAnger(sub_anger)
	printDebug("Hero Sub Anger:%d, Current:%d, id:%d, camp:%d", sub_anger, self:GetAnger(), self:GetId(), self:GetCamp())
	FIGHT_PACK_MANAGER:SubAnger(self._hero:GetId(), self._hero:GetCamp(), add_anger, self._hero:GetAnger())

	if self._hero:GetAnger() < ANGERTYPE.FULLANGER and self._hero:GetPokeballSkill()>0 then
		local partner_id = self:GetPartnerId()
		if partner_id and partner_id > 0 then
			printDebug("Hero PokeballSkill State, id1:%d, id2:%d, camp:%d, state:%d", self._hero:GetId(), partner_id, self._hero:GetCamp(), 0)
			FIGHT_PACK_MANAGER:PokeballSkillState(self._hero:GetId(), partner_id, self._hero:GetCamp(), 0)
		end
	end
end

function HeroController:SetAnger(anger, force)
	local now_anger = self._hero:GetAnger()
	if anger > now_anger then
		self:AddAnger(anger - now_anger, force)
	elseif anger < now_anger then
		self:SubAnger(now_anger - anger)
	end
end

function HeroController:Transform()
	if self._is_transform == false then
		printDebug("Hero Transform, id:%d, camp:%d", self:GetId(), self:GetCamp())
		FIGHT_PACK_MANAGER:Transform(self:GetId(), self:GetCamp(), true)
		self._is_transform = true
		self:SubAnger(self:GetAnger(), true)
	end
end

function HeroController:CleanAnger()
	if self._buff_manager:HasLockAnger() == true then
		return
	end
	local current_anger = self._hero:GetAnger()
	self._hero:CleanAnger()
	FIGHT_PACK_MANAGER:SubAnger(self._hero:GetId(), self._hero:GetCamp(), current_anger, 0)
end

function HeroController:GetAnger()
	return self._hero:GetAnger()
end

function HeroController:AddBuff(caster, buff_id, ignore_copy_buff, buff_level)
	if self._hero:IsDead() then
		return
	end

	if self._hero:GetId() == caster:GetId() and self._hero:GetCamp() == caster:GetCamp() then
		ignore_copy_buff = true
	end

	local result = {can_add_buff = true, caster = caster, buff_id = buff_id}
	if ignore_copy_buff == true then
		result.ignore_copy_buff = true
	else
		result.ignore_copy_buff = false
	end
	self._special_manager:Trigger("SPECIAL_TRIGGER_BEFORE_GET_BUFF", result)
	if result.can_add_buff == false then
		return
	end

	local buff = self._buff_manager:AddBuff(caster, buff_id, buff_level)
	caster:SelfCastBuff(buff)

	self._special_manager:Trigger("SPECIAL_TRIGGER_AFTER_GET_BUFF", result)

	return buff
end

function HeroController:AddBuffByIdNum(caster, buff_id, number, ignore_copy_buff, buff_level)
	if self._hero:IsDead() then
		return
	end

	local result = {can_add_buff = true, caster = caster, buff_id = buff_id, buff_num = number}
	if ignore_copy_buff == true then
		result.ignore_copy_buff = true
	else
		result.ignore_copy_buff = false
	end
	self._special_manager:Trigger("SPECIAL_TRIGGER_BEFORE_GET_BUFF", result)
	if result.can_add_buff == false then
		return
	end

	local buff = self._buff_manager:AddBuffByIdNum(caster, buff_id, number, buff_level)
	caster:SelfCastBuff(buff)

	self._special_manager:Trigger("SPECIAL_TRIGGER_AFTER_GET_BUFF", result)

	return buff
end

function HeroController:RemoveBuff(buff_id)
	return self._buff_manager:RemoveBuff(buff_id)
end

function HeroController:RemoveAllBuff()
	return self._buff_manager:RemoveAllBuffs()
end

function HeroController:GetSilence()
	return self._buff_manager:GetSilence()
end

function HeroController:HasSneerBuff()
	return self._buff_manager:HasSneerBuff()
end

function HeroController:GetSpeed()
	return self._hero:GetSpeed()
end

function HeroController:Die()
	self._buff_manager:RemoveAllBuffs()

	local partner_id = self:GetPartnerId()
	if partner_id and partner_id > 0 then
		printDebug("Hero Die, PokeballSkill State, id1:%d, id2:%d, camp:%d, state:%d", self._hero:GetId(), partner_id, self._hero:GetCamp(), 0)
		FIGHT_PACK_MANAGER:PokeballSkillState(self._hero:GetId(), partner_id, self._hero:GetCamp(), 0)
	end

	self._special_manager:CleanAruaOnDie()

	self._hero:Die()
	local id = self:GetId()
	local camp = self:GetCamp()
	self._role_manager:HeroDie(id, camp)
	FIGHT_PACK_MANAGER:HeroDie(id, camp)
end

function HeroController:IsDead()
	return self._hero:IsDead()
end

function HeroController:GetId()
	return self._hero:GetId()
end

function HeroController:GetCamp()
	return self._hero:GetCamp()
end

function HeroController:Refresh()
	self._first_act = true
	self:RemoveAllBuff()
	self:AddHp(self:GetMaxHp(), 0, 0, self:GetId(), self:GetCamp(), false)
	if self._default_anger > 0 then
		self:SetAnger(self._default_anger, true)
	end
end

-- function HeroController:GetAttr(attr_id)
-- 	return self._hero:GetAttr(attr_id)
-- end

-- function HeroController:GetPosition()
-- 	return self._hero:GetPosition()
-- end

function HeroController:GetConfigId()
	return self._hero:GetConfigId()
end

function HeroController:GetPartnerConfigId()
	return self._hero:GetPartnerConfigId()
end

function HeroController:GetPartnerId()
	local partner_hero_id = self._hero:GetPartnerConfigId()
	return self._role_manager:GetIDByHeroID(partner_hero_id, self._hero:GetCamp())
end

function HeroController:IsMaster()
	return false
end

function HeroController:IsBoss()
	return false
end

function HeroController:CountHitTarget(defender)
end

-- attribute
function HeroController:GetATK()
	return self._hero:GetATK()
end

function HeroController:GetBlockRate()
	return self._hero:GetBlockRate()
end

function HeroController:GetDisBlockRate()
	return self._hero:GetDisBlockRate()
end

function HeroController:GetMissRate()
	return self._hero:GetMissRate()
end

function HeroController:GetHitRate()
	return self._hero:GetHitRate()
end

function HeroController:GetCritRate()
	return self._hero:GetCritRate()
end

function HeroController:GetDecCritRate()
	return self._hero:GetDecCritRate()
end

function HeroController:GetLevel()
	return self._hero:GetLevel()
end

function HeroController:GetElementType()
	return 1
end

function HeroController:GetAttrTable()
	return self._hero:GetAttrTable()
end

function HeroController:GetDizz()
	return self._buff_manager:GetDizz()
end

function HeroController:CheckGetAngerBuff()
	self._buff_manager:CheckGetAngerBuff()
end

function HeroController:GetLockHeal()
	return self._buff_manager:GetLockHeal()
end

function HeroController:GetPetrified()
	return self._buff_manager:GetPetrified()
end

function HeroController:GetHealChangeGiveHpBuff()
	return self._buff_manager:GetHealChangeGiveHpBuff()
end

function HeroController:GetBuffHealByDamage(damage)
	return self._buff_manager:GetBuffHealByDamage(damage)
end

function HeroController:GetBoomDamage(id, camp)
	if self:IsDead() then
		return
	end

	return self._buff_manager:GetBoomDamage(id, camp)
end

function HeroController:GetReflectBuffDamage(damage)
	return self._buff_manager:GetReflectBuffDamage(damage)
end

function HeroController:GetDoubleDamageBuffRate()
	return self._buff_manager:GetDoubleDamageBuffRate()
end

function HeroController:GetDeathKillBuffRate()
	return self._buff_manager:GetDeathKillBuffRate()
end

function HeroController:GetImmuneBuff()
	return self._buff_manager:GetImmuneBuff()
end

function HeroController:GetMissHealBuffFactor()
	return self._buff_manager:GetMissHealBuffFactor()
end

function HeroController:HasBuff()
	return self._buff_manager:HasBuff()
end

function HeroController:HasDebuff()
	return self._buff_manager:HasDebuff()
end

-- special

function HeroController:GetSpecialMgr()
	return self._special_manager
end

function HeroController:ReplaceSkill(before_skill_id, after_skill_id)
	printDebug("Hero ReplaceSkill, hero_id:%d, hero_camp:%d, before_skill:%d, after_skill:%d", self:GetId(), self:GetCamp(), before_skill_id, after_skill_id)
	for index, skill_id in pairs(self._skills) do
		if skill_id == before_skill_id then
			self._skills[index] = after_skill_id
			self._skill_level[before_skill_id] = nil
			self._skill_level[after_skill_id] = 1
			self._skill_cd[after_skill_id] = 0
		end
	end
end

function HeroController:AddAttr(attr_id, attr_value)
	printDebug("Hero Add Attr hero_id:%d, hero_camp:%d, attr_id:%d, attr_value:%d", self:GetId(), self:GetCamp(), attr_id, attr_value)
	self._hero:AddAttr(attr_id, attr_value)
end

function HeroController:SubAttr(attr_id, attr_value)
	printDebug("Hero Sub Attr hero_id:%d, hero_camp:%d, attr_id:%d, attr_value:%d", self:GetId(), self:GetCamp(), attr_id, attr_value)
	self._hero:SubAttr(attr_id, attr_value)

	if attr_id == HEROATTRTYPE.HP then
		if self._hero:GetMaxHp() <= 0 then
			local buff_id, heal_factor = self._buff_manager:GetRebornHealFactor()
			if heal_factor > 0 then
				-- TODO new fight pack cmd

				local addhp = math.ceil(heal_factor * self:GetMaxHp() / 100)
				self:AddHp(addhp, SKILL_OR_BUFF.BUFF, buff_id, self:GetId(), self:GetCamp(), false)
			else
				self:Die()
			end
		end
	end
end

function HeroController:IsFirstAct()
	return self._first_act
end

function HeroController:GetBuffCountByEffect(effect)
	return self._buff_manager:GetBuffCountByEffect(effect)
end

function HeroController:GetNormalSkillID()
	return self._skills[SKILL_INDEX.NORMAL_SKILL]
end

function HeroController:Refine()
	self._buff_manager:Refine()
end

function HeroController:Dispel()
	self._buff_manager:Dispel()
end

-- function HeroController:CanTransform()
-- 	return self._hero:CanTransform()
-- end

return HeroController
