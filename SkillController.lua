local SkillTargetHelper = require("SkillTargetHelper")
local SkillController = class("SkillController")

function SkillController.DoSkillCommand(skill_cmd, role_manager, ignore_anger, is_first_skill)
	local caster = skill_cmd:GetCaster()
	local skill_id = skill_cmd:GetSkillId()
	local skill_cd = skill_cmd:GetCD()

	local is_anger_skill = false
	if not ignore_anger and (skill_cmd:GetSkillType() == SKILLTYPE.ANGER or skill_cmd:GetSkillType() == SKILLTYPE.POKEBALL) then
		caster:SubAnger(ANGERTYPE.FULLANGER)
		is_anger_skill = true
	end

	local helper = SkillTargetHelper.new(role_manager:GetAllRole())
	helper:PrepareTarget(skill_cmd)

	if skill_cmd:GetTargetNum() <= 0 then
		return true
	end

	for i=1, skill_cmd:GetReleaseNum() do
		if caster:IsDead() then
			return true
		end

		if skill_cmd:IsLock() == LOCKTARGET.UNLOCK and i > 1 then
			helper:PrepareTarget(skill_cmd)
		end

		local partner_id = nil
		if skill_cmd:GetSkillType() == SKILLTYPE.POKEBALL then
			partner_id = caster:GetPartnerId()
		end

		if not is_first_skill then
			is_first_skill = false
		end
		FIGHT_PACK_MANAGER:SkillReleasePack(caster:GetId(), caster:GetCamp(), skill_cmd, i, (is_first_skill or (i~=1)), partner_id)
		skill_cmd:DoSkill(i)
	end
	skill_cmd:CastFinish()

	caster:AddSkillCD(skill_id, skill_cd)

	if not is_anger_skill and not ignore_anger then
		local result = {recover_anger = ANGERTYPE.ADD_ANGER_PER_ROUND}
		caster:GetSpecialMgr():Trigger("SPECIAL_TRIGGER_RECOVER_ANGER", result)
		caster:AddAnger(result.recover_anger, true)
	end

	return true

	-- skill:HasRelease()
	-- -- self:CheckSSkillBuff(skill)
	-- -- self:CheckNormalBuff(skill)
	-- skill:BuffSelfEffect(self)
	-- self._fight_pack_manager:SkillBegin(self:GetId(), self:GetCamp())
	-- for i = 1, skill:GetReleaseNum() do
	-- 	-- skill:CreateReleasePack(false,i)
	-- 	self._fight_pack_manager:SkillReleasePack(self:GetId(), self:GetCamp(), skill, false)
	-- 	skill:RunSkill(i)
	-- 	-- self.hitsencecount = self.hitsencecount + 1
	-- 	if skill:IsLock() == LOCKTARGET.UNLOCK then
	-- 		skill:HasRelease()
	-- 	end
	-- end
	-- skill:ClearHurtHero()
	-- -- skill:ReSetCD()
	-- skill:StartCD()
	-- skill:ClearLastHits()
	-- -- self:ReSetHitCount()
	-- if skill:GetSkillType() == SKILLTYPE.BIG or skill:GetSkillType() == SKILLTYPE.SUPERBIG then
	-- 	-- self.buffmanager:ReSetThiredHurt()
	-- 	-- if skill:HasTargetLife() then
	-- 	-- 	self.buffmanager:SurviveLife()
	-- 	-- end
	-- end
	-- skill:ClearCountHitTarget()
end

return SkillController
