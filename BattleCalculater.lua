local BattleCalculater = class("BattleCalculater")

function BattleCalculater:ctor()

end

--[[
attr_table = {
	ATK
	DEF
	HP
	MAX_HP
	ATK_PERCENT
	DEF_PERCENT
	HP_PERCENT
	CRIT
	DEC_CRIT
	HIT
	MISS
	CRIT_DMG
	DEC_CRIT_DMG
	INC_DMG
	DEC_DMG
	INC_POISON
	DEC_POISON
	INC_BURN
	DEC_BURN
	HEAL
	BE_HEAL
	BLOCK
	DIS_BLOCK
	PVP_INC_DMG
	PVP_DEC_DMG
	BEAT_BACK
	REFLECT_RATE
	REFLECT_DMG
	HOLY_DMG
	HOLY_CRIT
	SELF_HEAL
	FORCE_SELF_HEAL
	VAMPIRISM
	VAMPIRISM_RESISTANCE
	ANGER
	LEVEL
}
]]
function BattleCalculater._calc_damage(attacker_attr_table, defender_attr_table, is_crit, is_block, skill_damage_factor, skill_damage_extra)
	local damage = 0

	--TODO
	damage = attacker_attr_table.ATK - defender_attr_table.DEF

	if skill_damage_factor > 0 then
		damage = damage * skill_damage_factor / 100
	end

	-- 格挡50%?
	if is_block then
		damage = damage * 0.5
	end

	if is_crit then
		damage = damage * (1 + max(attacker_attr_table.CRIT_DMG - defender_attr_table.DEC_CRIT_DMG, 0) / 1000)
	end

	-- TODO
	-- 伤害类型加成

	-- final damage
	damage = damage * max(1 + (attacker_attr_table.INC_DMG - defender_attr_table.DEC_DMG) / 1000, 0.25)

	if damage < 1 then
		damage = 1
	end
	return math.ceil(damage)
end

function BattleCalculater._calc_buff_damage(attacker_attr_table, defender_attr_table, buff_damage_factor, damage_effect)
	local damage = 0

	--TODO
	damage = attacker_attr_table.ATK * buff_damage_factor / 100

	-- TODO
	-- 伤害类型加成

	-- final damage
	damage = damage * (1000 + attacker_attr_table.INC_DMG - defender_attr_table.DEC_DMG) / 1000

	if damage < 1 then
		damage = 1
	end
	return math.ceil(damage)
end

function BattleCalculater._calc_heal(attacker_attr_table, defender_attr_table, is_crit, skill_damage_factor, skill_damage_extra)
	local heal_value = (attacker_attr_table.ATK * skill_damage_factor /100 + skill_damage_extra) * (attacker_attr_table.HEAL + defender_attr_table.BE_HEAL)/1000
	if is_crit == true then
		heal_value = heal_value * (1 + attacker_attr_table.CRIT_DMG / 1000)
	end
	return math.ceil(heal_value)
end

function BattleCalculater._calc_buff_heal(attacker_attr_table, defender_attr_table, buff_damage_factor)
	local heal_value = attacker_attr_table.ATK * (buff_damage_factor/100) * (attacker_attr_table.HEAL + defender_attr_table.BE_HEAL)/1000
	return math.ceil(heal_value)
end

function BattleCalculater.GetDamage(attacker_attr_table, defender_attr_table, is_crit, is_block, skill_damage_factor, skill_damage_extra, damage_effect)
	-- local attacker_attr_table = attacker:GetAttrTable()
	-- local defender_attr_table = defender:GetAttrTable()

	return BattleCalculater._calc_damage(attacker_attr_table, defender_attr_table, is_crit, is_block, skill_damage_factor, skill_damage_extra)
	-- printDebug("caster_id:%d, caster_camp:%d, suffer_id:%d, suffer_camp:%d, damage:%d", attacker:GetId(), attacker:GetCamp(), defender:GetId(), defender:GetCamp(), damage)
	-- return damage
end

function BattleCalculater.GetBuffDamage(attacker, defender, buff_damage_factor, damage_effect)
	local attacker_attr_table = attacker:GetAttrTable()
	local defender_attr_table = defender:GetAttrTable()

	local damage = BattleCalculater._calc_buff_damage(attacker_attr_table, defender_attr_table, buff_damage_factor, damage_effect)
	printDebug("caster_id:%d, caster_camp:%d, suffer_id:%d, suffer_camp:%d, damage:%d", attacker:GetId(), attacker:GetCamp(), defender:GetId(), defender:GetCamp(), damage)

	return damage
end

function BattleCalculater.GetHeal(attacker_attr_table, defender_attr_table, is_crit, skill_damage_factor, skill_damage_extra)
	-- local attacker_attr_table = attacker:GetAttrTable()
	-- local defender_attr_table = defender:GetAttrTable()

	return BattleCalculater._calc_heal(attacker_attr_table, defender_attr_table, is_crit, skill_damage_factor, skill_damage_extra)
	-- printDebug("caster_id:%d, caster_camp:%d, suffer_id:%d, suffer_camp:%d, heal:%d", attacker:GetId(), attacker:GetCamp(), defender:GetId(), defender:GetCamp(), heal_value)
	-- return heal_value
end

function BattleCalculater.GetBuffHeal(attacker, defender, buff_damage_factor)
	local attacker_attr_table = attacker:GetAttrTable()
	local defender_attr_table = defender:GetAttrTable()

	local heal_value = BattleCalculater._calc_buff_heal(attacker_attr_table, defender_attr_table, buff_damage_factor)
	printDebug("caster_id:%d, caster_camp:%d, suffer_id:%d, suffer_camp:%d, heal:%d", attacker:GetId(), attacker:GetCamp(), defender:GetId(), defender:GetCamp(), heal_value)

	return heal_value
end

function BattleCalculater.GetShield(attacker, defender, buff_damage_factor)
	local attacker_attr_table = attacker:GetAttrTable()
	return math.ceil(attacker_attr_table.ATK * buff_damage_factor / 100)
end

return BattleCalculater
