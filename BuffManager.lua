local Buff = require("Buff")
local BuffManager = class("BuffManager")

function BuffManager:ctor(hero)
	self._hero = hero
	self._buffs = {}
	self._buff_attrs = {}
end

function BuffManager:Update()
	printError("No Use BuffManager:Update")
	-- local i = 1
	-- while i <= #self._buffs do
	-- 	local buff = self._buffs[i]
	-- 	if buff and buff:GetBuffTime() >= 0 then
	-- 		buff:Update()
	-- 	end
	-- 	i = i + 1
	-- end
end

function BuffManager:ActionBeginUpdate()
	local i = 1
	while i <= #self._buffs do
		local buff = self._buffs[i]
		if buff and buff:GetBuffTime() > 0 then
			buff:UpdateOnSufferBeforeActor()
		end
		i = i + 1
	end
end

function BuffManager:ActionEndUpdate()
	printError("No Use BuffManager:ActionEndUpdate")
	-- local i = 1
	-- while i <= #self._buffs do
	-- 	local buff = self._buffs[i]
	-- 	if buff then
	-- 		if buff:GetBuffTime() > 0 then
	-- 			buff:ActionEndUpdate()
	-- 			i = i + 1
	-- 		else
	-- 			buff:Remove()
	-- 			table.remove(self._buffs, i)
	-- 		end
	-- 	end
	-- end
end

function BuffManager:CreateBuff(caster, buff_id, number, buff_level)
	local buff = Buff.new(caster, buff_id, number, buff_level)
	return buff
end

function BuffManager:AttachBuff(buff)
	local result = buff:AttachTo(self._hero)
	if result == true then
		table.insert(self._buffs, buff)
	end
	return result
end

function BuffManager:AddBuff(caster, buff_id, buff_level)
	local has_buff = false
	local buff = nil
	local i = 1
	while i <= #self._buffs do
		buff = self._buffs[i]
		if buff_id == buff:GetBuffId() then
			has_buff = true
			break
		end
		i = i + 1
	end
	if has_buff and buff then
		FIGHT_PACK_MANAGER:AddBuff(self._hero:GetId(), self._hero:GetCamp(), buff_id)
		buff:Refresh(caster)
	else
		buff = self:CreateBuff(caster, buff_id, 0, buff_level)
		if buff then
			local result = self:AttachBuff(buff)
			if result == true then
				printDebug("Add Buff, caster_id:%d, caster_camp:%d, suffer_id:%d, suffer_camp:%d, buff_id:%d, buff_time:%d", caster:GetId(), caster:GetCamp(), self._hero:GetId(), self._hero:GetCamp(), buff_id, buff:GetBuffTime())
				FIGHT_PACK_MANAGER:AddBuff(self._hero:GetId(), self._hero:GetCamp(), buff_id)
			end
			return buff
		end
	end
	return buff
end

function BuffManager:AddBuffByIdNum(caster, buff_id, number, buff_level)
	local has_buff = false
	local buff = nil
	local i = 1
	while i <= #self._buffs do
		buff = self._buffs[i]
		if buff_id == buff:GetBuffId() then
			has_buff = true
			break
		end
		i = i + 1
	end

	if has_buff and buff then
		buff._num = buff._num + number
		buff:Refresh(caster)
	else
		buff = self:CreateBuff(caster, buff_id, number, buff_level)
		if buff then
			local result = self:AttachBuff(buff)
			if result == true then
				printDebug("Add Buff By Id Num, caster_id:%d, caster_camp:%d, suffer_id:%d, suffer_camp:%d, buff_id:%d, buff_time:%d", caster:GetId(), caster:GetCamp(), self._hero:GetId(), self._hero:GetCamp(), buff_id, buff:GetBuffTime())
				FIGHT_PACK_MANAGER:AddBuff(self._hero:GetId(), self._hero:GetCamp(), buff_id)
			end
			return buff
		end
	end
	return buff
end

function BuffManager:RemoveBuff(buff_id)
	local i = 1
	while i <= #self._buffs do
		if self._buffs[i]:GetBuffId() == buff_id then
			self._buffs[i]:Remove()
			table.remove(self._buffs, i)
			printDebug("BuffManager:RemoveBuff() Remove Buff, suffer_id:%d, suffer_camp:%d, buff_id:%d", self._hero:GetId(), self._hero:GetCamp(), buff_id)
			FIGHT_PACK_MANAGER:RemoveBuff(self._hero:GetId(), self._hero:GetCamp(), buff_id)
			return true
		else
			i = i + 1
		end
	end
	return false
end

function BuffManager:RemoveAllBuffs()
	local buff = table.remove(self._buffs, 1)
	while buff do
		buff:Remove()
		buff = table.remove(self._buffs, 1)
	end
end

function BuffManager:AddBuffAttr(attr_table)
	table.walk(attr_table, function(attr_value, attr_id)
		if not self._buff_attrs[attr_id] then
			self._buff_attrs[attr_id] = 0
		end
		self._buff_attrs[attr_id] = self._buff_attrs[attr_id] + attr_value
	end)
end

function BuffManager:RemoveBuffAttr(attr_table)
	table.walk(attr_table, function(attr_value, attr_id)
		if not self._buff_attrs[attr_id] then
			return
		end
		self._buff_attrs[attr_id] = self._buff_attrs[attr_id] - attr_value
	end)
end

function BuffManager:GetAddAttrValue(attr_id)
	if self._buff_attrs[attr_id] and self._buff_attrs[attr_id] ~= 0 then
		return self._buff_attrs[attr_id]
	end
	return 0
end

function BuffManager:SubShield(hp)
	local sub_hp = hp
	local i = 1
	while i <= #self._buffs do
		local buff = self._buffs[i]
		local absorb_num, is_remove = buff:SubShield(sub_hp)
		sub_hp = sub_hp - absorb_num
		if sub_hp <= 0 then
			break
		end
		if is_remove then
			buff:Remove()
			table.remove(self._buffs, i)
		else
			i = i + 1
		end
	end

	sub_hp = math.ceil(sub_hp)
	if sub_hp < hp then
		local absorb_total = math.ceil(hp - sub_hp)
		FIGHT_PACK_MANAGER:AbsorbDamage(self._hero:GetId(), self._hero:GetCamp(), absorb_total)
	end
	return sub_hp
end

function BuffManager:GetDizz()
	for i = 1,#self._buffs do
		if self._buffs[i]:GetDizz() then
			return true
		end
	end
	return false
end

function BuffManager:GetSilence()
	for i = 1,#self._buffs do
		if self._buffs[i]:GetSilence() then
			return true
		end
	end
	return false
end

function BuffManager:HasSneerBuff()
	for i = 1,#self._buffs do
		if self._buffs[i]:HasSneerBuff() then
			return true
		end
	end
	return false
end

function BuffManager:HasLockAngerInc()
	for i = 1,#self._buffs do
		if self._buffs[i]:HasLockAngerInc() == true then
			return true
		end
	end
	return false
end

function BuffManager:HasLockAngerDec()
	for i = 1,#self._buffs do
		if self._buffs[i]:HasLockAngerDec() == true then
			return true
		end
	end
	return false
end

function BuffManager:IsGod()
	for i = 1,#self._buffs do
		if self._buffs[i]:IsGod() then
			return true
		end
	end
	return false
end

function BuffManager:Refine()
	local i = 1
	while i <= #self._buffs do
		if self._buffs[i]:CanClean() == true then
			printDebug("Refine: Remove Buff, suffer_id:%d, suffer_camp:%d, buff_id:%d", self._hero:GetId(), self._hero:GetCamp(), self._buffs[i]:GetBuffId())
			FIGHT_PACK_MANAGER:RemoveBuff(self._hero:GetId(), self._hero:GetCamp(), self._buffs[i]:GetBuffId())
			self._buffs[i]:Remove()
			table.remove(self._buffs, i)
		else
			i = i + 1
		end
	end
end

function BuffManager:Dispel()
	local i = 1
	while i <= #self._buffs do
		if self._buffs[i]:CanDispel() == true then
			printDebug("Dispel: Remove Buff, suffer_id:%d, suffer_camp:%d, buff_id:%d", self._hero:GetId(), self._hero:GetCamp(), self._buffs[i]:GetBuffId())
			FIGHT_PACK_MANAGER:RemoveBuff(self._hero:GetId(), self._hero:GetCamp(), self._buffs[i]:GetBuffId())
			self._buffs[i]:Remove()
			table.remove(self._buffs,i)
		else
			i = i + 1
		end
	end
end

function BuffManager:CheckGetAngerBuff()
	for i = 1,#self._buffs do
		self._buffs[i]:CheckGetAnger()
	end
end

function BuffManager:GetLockHeal()
	for i = 1,#self._buffs do
		if self._buffs[i]:GetLockHeal() == true then
			return true
		end
	end
	return false
end

function BuffManager:GetPetrified()
	for i = 1,#self._buffs do
		if self._buffs[i]:GetPetrified() == true then
			return true
		end
	end
	return false
end

function BuffManager:GetBuffHealByDamage(damage)
	local val = 0
	for i = 1,#self._buffs do
		local buff_val = self._buffs[i]:GetBuffHealByDamage(damage)
		if buff_val > 0 and buff_val > val then
			val = buff_val
		end
	end
	return val
end

function BuffManager:GetRebornHealFactor()
	for i = 1,#self._buffs do
		local buff_val = self._buffs[i]:GetRebornHealFactor()
		if buff_val > 0 then
			local buff_id = self._buffs[i]:GetBuffId()
			self._buffs[i]:Remove()
			table.remove(self._buffs, i)
			return buff_id, buff_val
		end
	end
	return 0, 0
end

function BuffManager:GetBoomDamage(id, camp)
	local i = 1
	local buff = nil
	for i = 1,#self._buffs do
		if self._buffs[i]:GetBoom() == true then
			buff = self._buffs[i]
			buff:RunBoom()
			if self._hero:IsDead() == false then
				buff:Remove()
			end
			break
		end
	end

	if buff then
		for i=1,#self._buffs do
			if self._buffs[i] == buff then
				table.remove(self._buffs, i)
				break
			end
		end
	end
end

function BuffManager:GetReflectBuffDamage(damage)
	local total_damage = 0
	for i = 1,#self._buffs do
		local reflect_damage = self._buffs[i]:GetReflectDamage(damage)
		if reflect_damage > 0 then
			total_damage = total_damage + reflect_damage
		end
	end
	return total_damage
end

function BuffManager:GetDoubleDamageBuffRate()
	local val = 0
	for i = 1,#self._buffs do
		local buff_val = self._buffs[i]:GetDoubleDamageRate()
		if buff_val > 0 and buff_val > val then
			val = buff_val
		end
	end
	return val
end

function BuffManager:GetDeathKillBuffRate()
	local val = 0
	for i = 1,#self._buffs do
		local buff_val = self._buffs[i]:GetDeathKillRate()
		if buff_val > 0 and buff_val > val then
			val = buff_val
		end
	end
	return val
end

function BuffManager:GetImmuneBuff()
	for i = 1,#self._buffs do
		if self._buffs[i]:GetImmuneBuff() == true then
			return true
		end
	end
	return false
end

function BuffManager:GetMissHealBuffFactor()
	local val = 0
	local buff_id = 0
	for i = 1,#self._buffs do
		local buff_val = self._buffs[i]:GetMissHealFactor()
		if buff_val > 0 and buff_val > val then
			val = buff_val
			buff_id = self._buffs[i]:GetBuffId()
		end
	end
	return val, buff_id
end

function BuffManager:HasBuff()
	local result = false
	for i = 1,#self._buffs do
		if self._buffs[i]:IsBuff() then
			result = true
			break
		end
	end
	return result
end

function BuffManager:HasDebuff()
	local result = false
	for i = 1,#self._buffs do
		if self._buffs[i]:IsDebuff() then
			result = true
			break
		end
	end
	return result
end

function BuffManager:GetBuffCountByEffect(effect)
	local result = 0
	for i = 1,#self._buffs do
		if self._buffs[i]:GetBuffEffect() == effect then
			result = result + self._buffs[i]:GetOverlay()
		end
	end
	return result
end

function BuffManager:GetDecDmgByEffect()
	local val = 0
	for i = 1,#self._buffs do
		local buff_val = self._buffs[i]:GetDecDmgByEffect()
		if buff_val > 0 then
			val = val + buff_val
		end
	end
	return val
end

-- ==========================================================================================
-- ==========================================================================================
-- ==========================================================================================

-- function BuffManager:GetAtkChange()
-- 	local x = 0
-- 	for i = 1,#self._buffs do
-- 		x = x + self._buffs[i]:GetAtkChange()
-- 	end
-- 	if x > 45 then return 45 end
-- 	if x < -45 then return -45 end
-- 	return x
-- end

-- function BuffManager:GetDefendChange()
-- 	local x = 0
-- 	for i = 1,#self._buffs do
-- 		x = x + self._buffs[i]:GetDefendChange()
-- 	end
-- 	if x > 100 then return 100 end
-- 	if x < -100 then return -100 end
-- 	return x
-- end

-- function BuffManager:GetSpeedChange()
-- 	local x = 0
-- 	for i = 1,#self._buffs do
-- 		x = x + self._buffs[i]:GetSpeedChange()
-- 	end
-- 	if x > 10000 then return 10000 end
-- 	if x < -75 then return -75 end
-- 	return x
-- end

-- function BuffManager:GetHeart()
-- 	local x = 0
-- 	for i = 1, #self._buffs do
-- 		x = x + self._buffs[i]:GetHeart()
-- 	end
-- 	return x
-- end

-- function BuffManager:SurviveLife()
-- 	local has_survivelife = false
-- 	local buff_id = 0
-- 	for i = 1,#self._buffs do
-- 		if self._buffs[i]:SurviveLife() then
-- 			has_survivelife = true
-- 			buff_id = self._buffs[i]:GetId()
-- 		end
-- 	end
-- 	if has_survivelife then
-- 		local sub_hp = self._hero:GetHp() * 0.9
-- 		if (self._hero:GetHp() - sub_hp) < 1 then
-- 			sub_hp = self._hero:GetHp() - 1
-- 		end
-- 		if sub_hp >= 1 then
-- 			self._hero:SubHp(sub_hp, false, false, 0, 0, SKILL_OR_BUFF.BUFF, buff_id, self._hero:GetId(), self._hero:GetCamp())
-- 		end
-- 	 end
-- end

-- function BuffManager:IsSecoundAction()
-- 	for i = 1,#self._buffs do
-- 		if self._buffs[i]:IsSecoundAction() then
-- 			return 1
-- 		end
-- 	end
-- 	return 0
-- end

-- function BuffManager:GetWeaken()
-- 	local x = 0
-- 	for i = 1,#self._buffs do
-- 		local y = self._buffs[i]:GetWeaken()
-- 		if x < y then
-- 			x = y
-- 		end
-- 	end
-- 	if x > 45 then return 45 end
-- 	return x
-- end

-- function BuffManager:RunBoomAttchHero(id,camp)
-- 	for i = 1,#self._buffs do
-- 		if self._buffs[i]:GetBoomAttchHero(id, camp) then
-- 			self._buffs[i]:RunBoom()
-- 		end
-- 	end
-- end

-- -- function BuffManager:GetSneerHero()
-- 	-- local peer_vec = self._hero.battle_logic:GetPeerVec(self._hero:GetCamp())
-- 	-- for i = 1,#peer_vec do
-- 	-- 	if peer_vec[i].aisystem.buffmanager:HasSneerBuff() then
-- 	-- 		return peer_vec[i]
-- 	-- 	end
-- 	-- end
-- 	-- return nil
-- -- end

-- function BuffManager:HasSneerBuff()
-- 	for i = 1,#self._buffs do
-- 		if self._buffs[i]:HasSneerBuff() then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

-- function BuffManager:GetSubHurt()
-- 	local sub_hurt = 0
-- 	for i = 1,#self._buffs do
-- 		 local num = self._buffs[i]:GetSubHurt()
-- 		 if num > sub_hurt then
-- 			 sub_hurt = num
-- 		 end
-- 	end
-- 	if sub_hurt < 0 then sub_hurt = 0 end
-- 	if sub_hurt > 100 then sub_hurt = 100 end
-- 	return sub_hurt
-- end

-- function BuffManager:HasChunGe()
-- 	for i = 1,#self._buffs do
-- 		local buff = self._buffs[i]:HasChunGe()
-- 		if buff ~= nil and buff.buff_time >= 0 then
-- 			return buff
-- 		end
-- 	end
-- 	return nil
-- end

-- function BuffManager:RemoveChunGe()
-- 	for i = 1,#self._buffs do
-- 		if self._buffs[i]:HasChunGe() then
-- 			--CJ TODO
-- 			-------------------------------------------
-- 			-- local fight_pack = {}
-- 			-- fight_pack.cmd = FIGHTCMD.REMOVEBUFF
-- 			-- fight_pack.id = self._hero:GetId()
-- 			-- fight_pack.camp = self._hero:GetCamp()
-- 			-- fight_pack.RemoveBuff = {}
-- 			-- fight_pack.RemoveBuff.buff_id = self._buffs[i]:GetId()
-- 			-- self._hero.battle_logic:SetFightData(fight_pack)
-- 			-- self._buffs[i].buff_time = -1
-- 			return
-- 		end
-- 	end
-- end

-- function BuffManager:HasSaberGift()
-- 	local num = 0
-- 	for i = 1,#self._buffs do
-- 		num = num + self._buffs[i]:HasSaberGift()
-- 	end
-- 	return num
-- end

-- function BuffManager:HasLancerGift(num)
-- 	for i = 1,#self._buffs do
-- 		self._buffs[i]:HasLancerGift(num)
-- 	end
-- end

-- function BuffManager:HasArcherGift()
-- 	local num = 0
-- 	for i = 1,#self._buffs do
-- 		num = num + self._buffs[i]:HasArcherGift()
-- 	end
-- 	return num
-- end

-- function BuffManager:HasBerserkerGift()
-- 	for i = 1,#self._buffs do
-- 		if self._buffs[i]:HasBerserkerGift() then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

-- function BuffManager:HasCasterGift()
-- 	local num = 0
-- 	for i = 1,#self._buffs do
-- 		num = num + self._buffs[i]:HasCasterGift()
-- 	end
-- 	return num
-- end

-- function BuffManager:RunGrowUp()
-- 	for i = 1,#self._buffs do
-- 		local num = self._buffs[i]:GetGrowUp()
-- 		if num > 0 then
-- 			local atk = self._hero:GetWuLiAtk() * num / 100
-- 			self._hero:AddWuLiAtk(atk,true)
-- 			atk = self._hero:GetMoFaAtk() * num / 100
-- 			self._hero:AddMoFaAtk(atk,true)
-- 			-----------------------------------------
-- 			local fight_pack = {}
-- 			fight_pack.cmd = FIGHTCMD.GROWUP
-- 			fight_pack.id = self._hero:GetId()
-- 			fight_pack.camp = self._hero:GetCamp()
-- 			fight_pack.GrowUp = {}
-- 			fight_pack.GrowUp.buff_id = self._buffs[i]:GetId()
-- 			self._hero.battle_logic:SetFightData(fight_pack)
-- 		end
-- 	end
-- end

-- function BuffManager:AddShangBiLevelRate()
-- 	local num = 0
-- 	for i = 1,#self._buffs do
-- 		num = num + self._buffs[i]:AddShangBiLevelRate()
-- 	end
-- 	return num
-- end

-- function BuffManager:RunSub50RateHp()
-- 	for i = 1,#self._buffs do
-- 		self._buffs[i]:RunSub50RateHp()
-- 	end
-- end

-- function BuffManager:RunSub50RateHpNormal()
-- 	for i = 1,#self._buffs do
-- 		self._buffs[i]:RunSub50RateHpNormal()
-- 	end
-- end

-- function BuffManager:HasJudderBuff()
--  local x = 0
--  local y = 0
--  local x_x = 0
--  local y_y = 0
-- 	for i = 1,#self._buffs do
-- 		x_x,y_y = self._buffs[i]:HasJudderBuff()
-- 		x = x + x_x
-- 		y = y + y_y
-- 	end
-- 	return x,y
-- end

-- function BuffManager:AddThiredHurt(num)
-- 	for i = 1,#self._buffs do
-- 		self._buffs[i]:AddThiredHurt(num)
-- 	end
-- end

-- function BuffManager:GetThiredHurt()
-- 	local num = 0
-- 	for i = 1,#self._buffs do
-- 		num = num + self._buffs[i]:GetThiredHurt()
-- 	end
-- 	return num
-- end

-- function BuffManager:ReSetThiredHurt()
-- 	for i = 1,#self._buffs do
-- 		self._buffs[i]:ReSetThiredHurt()
-- 	end
-- end

-- function BuffManager:AddRengXing()
-- 	local num = 0
-- 	for i = 1,#self._buffs do
-- 		num = num + self._buffs[i]:AddRengXing()
-- 	end
-- 	return num
-- end

-- function BuffManager:RiderBuff(hero)
-- 	local num = 0
-- 	for i = 1,#self._buffs do
-- 		num = num + self._buffs[i]:RiderBuff(hero)
-- 	end
-- 	return num
-- end

return BuffManager