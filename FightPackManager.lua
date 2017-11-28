local FightPackManager = class("FightPackManager")
local json = require("json")

function FightPackManager:ctor(battleController)
	printDebug("FightPackManager")
	self._currentFightData = {}
	self._allFightData = {}
end

function FightPackManager:NewQueue()
	-- print(json.encode(self._currentFightData))
	table.insertto(self._allFightData, self._currentFightData, #self._allFightData+1)
	self._currentFightData = {}
end

function FightPackManager:AddPack(pack)
	table.insert(self._currentFightData, pack)
end

function FightPackManager:BuffBegin(id, camp)
	-- local fight_pack = {}
	-- fight_pack.cmd = FIGHTCMD.BUFFBEGIN
	-- fight_pack.id = id
	-- fight_pack.camp = camp
	-- self:AddPack(fight_pack)
end

function FightPackManager:BuffChange(id, camp, buff_id, buff_time, buff_overlay)
	local fight_pack = {}
	fight_pack.cmd = FIGHTCMD.BUFFCHANGE
	fight_pack.id = id
	fight_pack.camp = camp
	fight_pack.BuffChange = {}
	fight_pack.BuffChange.buff_id = buff_id
	fight_pack.BuffChange.buff_count = buff_time
	fight_pack.BuffChange.buff_overlay = buff_overlay
	self:AddPack(fight_pack)
end

function FightPackManager:SkillBegin(id, camp)
	-- local fight_pack = {}
	-- fight_pack.cmd = FIGHTCMD.SKILLBEGIN
	-- fight_pack.id = id
	-- fight_pack.camp = camp
	-- self:AddPack(fight_pack)
end

function FightPackManager:SkillReleasePack(id, camp, skill_cmd, release_num, is_first_skill, partner_id)
	local fight_data = {}
	local targets = {}
	local ReleaseSkill = {}

	fight_data.id = id
	fight_data.camp = camp
	fight_data.cmd = FIGHTCMD.RELEASESKILL
	if is_first_skill == true then
		fight_data.is_first_skill = 1
	else
		fight_data.is_first_skill = 0
	end

	if partner_id and partner_id > 0 then
		fight_data.partner_id = partner_id
	end

	ReleaseSkill.skill_id = skill_cmd:GetSkillId()
	ReleaseSkill.release_num = release_num
	local tmp_targets = skill_cmd:GetTargets()
	for i = 1, #tmp_targets do
		if tmp_targets[i]:IsDead() == false then
			local target = {}
			target.id = tmp_targets[i]:GetId()
			target.camp = tmp_targets[i]:GetCamp()
			table.insert(targets, target)
		end
	end
	ReleaseSkill.Target = targets
	fight_data.ReleaseSkill = ReleaseSkill
	self:AddPack(fight_data)
end

function FightPackManager:RemoveBuff(id, camp, buff_id)
	local fight_pack = {}
	fight_pack.cmd = FIGHTCMD.REMOVEBUFF
	fight_pack.id = id
	fight_pack.camp = camp
	fight_pack.RemoveBuff = {}
	fight_pack.RemoveBuff.buff_id = buff_id
	self:AddPack(fight_pack)
end

function FightPackManager:AddHp(id, camp, add_hp, skill_or_buff, buff_id, is_crit)
	local fight_pack = {}
	fight_pack.cmd = FIGHTCMD.ADDHP
	fight_pack.id = id
	fight_pack.camp = camp
	fight_pack.AddHp = {}
	fight_pack.AddHp.add_hp = add_hp
	fight_pack.AddHp.id = buff_id
	fight_pack.AddHp.skill_or_buff = skill_or_buff
	fight_pack.AddHp.is_crit = is_crit
	self:AddPack(fight_pack)
end

function FightPackManager:SubHp(id, camp, sub_hp, current_hp, is_crit, is_block, hit_count, effect_type, skill_or_buff, buff_id)
	local fight_pack = {}
	fight_pack.cmd = FIGHTCMD.SUBHP
	fight_pack.id = id
	fight_pack.camp = camp
	fight_pack.SubHp = {}
	fight_pack.SubHp.sub_hp = sub_hp
	fight_pack.SubHp.is_crit = is_crit
	fight_pack.SubHp.hit_count = hit_count
	fight_pack.SubHp.effect_type = effect_type
	fight_pack.SubHp.skill_or_buff = skill_or_buff
	fight_pack.SubHp.id = buff_id
	fight_pack.SubHp.cur_hp = current_hp
	fight_pack.SubHp.is_gedang = is_block
	self:AddPack(fight_pack)
end

function FightPackManager:HeroDie(id, camp)
	local fight_pack = {}
	fight_pack.cmd = FIGHTCMD.DEATH
	fight_pack.id = id
	fight_pack.camp = camp
	self:AddPack(fight_pack)
end

function FightPackManager:AddAnger(id, camp, add_anger, after_anger)
	local fight_pack = {}
	fight_pack.cmd = FIGHTCMD.ADDANGER
	fight_pack.id = id
	fight_pack.camp = camp
	fight_pack.AddAnger = {}
	fight_pack.AddAnger.add_anger = add_anger
	fight_pack.AddAnger.cur_anger = after_anger
	self:AddPack(fight_pack)
end

function FightPackManager:SubAnger(id, camp, sub_anger, after_anger)
	local fight_pack = {}
	fight_pack.cmd = FIGHTCMD.SUBANGER
	fight_pack.id = id
	fight_pack.camp = camp
	fight_pack.SubAnger = {}
	fight_pack.SubAnger.sub_anger = sub_anger
	fight_pack.SubAnger.cur_anger = after_anger
	self:AddPack(fight_pack)
end

function FightPackManager:AttackMiss(id, camp)
	local fight_pack = {}
	fight_pack.cmd = FIGHTCMD.MISS
	fight_pack.id = id
	fight_pack.camp = camp
	self:AddPack(fight_pack)
end

function FightPackManager:AddBuff(id, camp, buff_id)
	local fight_pack = {}
	fight_pack.cmd = FIGHTCMD.ADDBUFF
	fight_pack.id = id
	fight_pack.camp = camp
	fight_pack.AddBuff = {}
	fight_pack.AddBuff.buff_id = buff_id
	self:AddPack(fight_pack)
end

function FightPackManager:AbsorbDamage(id, camp, absorb_num)
	local fight_pack = {}
	fight_pack.cmd = FIGHTCMD.ABSORB
	fight_pack.id = id
	fight_pack.camp = camp
	fight_pack.Absorb = {}
	fight_pack.Absorb.num = absorb_num
	self:AddPack(fight_pack)
end

function FightPackManager:Transform(id, camp, transform)
	local fight_pack = {}
	fight_pack.cmd = FIGHTCMD.TRANSFORM
	fight_pack.id = id
	fight_pack.camp = camp
	fight_pack.transform = transform
	self:AddPack(fight_pack)
end

function FightPackManager:PokeballSkillState(id_1, id_2, camp, state)
	local fight_pack = {}
	fight_pack.cmd = FIGHTCMD.POKEBALLSKILLSTATE
	fight_pack.id = id_1
	fight_pack.id_2 = id_2
	fight_pack.camp = camp
	fight_pack.state = state
	self:AddPack(fight_pack)
end

function FightPackManager:Combo(combo, total_damage)
	local fight_pack = {}
	fight_pack.cmd = FIGHTCMD.COMBO
	fight_pack.combo = combo
	fight_pack.total_damage = total_damage
	self:AddPack(fight_pack)
end

function FightPackManager:LogSwitch(path, filename)
	self.log_switch = true
	self.file_path = path
	self.file_name = filename
	if self.log_switch then
		self.file = io.open(self.file_path .. self.file_name,"w")
	end
	if self.file == nil then
		self.log_switch = false
	end
end

function FightPackManager:GetFightDatas()
	table.insertto(self._allFightData, self._currentFightData, #self._allFightData+1)
	self._currentFightData = {}
	return self._allFightData
end

function FightPackManager:ClearAllData()
	self._allFightData = {}
	self._currentFightData = {}
end

function FightPackManager:Dump()
	self:NewQueue()
	return json.encode(self._allFightData)
end

return FightPackManager
