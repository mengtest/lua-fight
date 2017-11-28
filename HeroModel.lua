local HeroModel = class("HeroModel")
local AttrManager = require("AttrManager")

local print_r = require "print_r"
function HeroModel:ctor(data, hero_controller)
	self._data = {
		-- cur_hp = 0,
		-- cur_anger = 0,
		-- attr = {},
		hero_id = 0,
		id = 0,
		level = 0,
		career = 0,
		partner_id = 0,
		pokeball_skill = 0,
		anger_skill = 0,
		special = {},
		normal_skill = 0
	}
	self._inited = false
	self._is_dead = false
	self._camp = 0
	-- self._hero_controller = hero_controller

	self:InitData(data)

	self._attr_manager = AttrManager.new(hero_controller, data.attr, data.cur_hp, data.cur_anger, data.level)
end

function HeroModel:InitData(data)
	-- inited here
	assert(data.hero_id, "invalid data no hero_id on init hero model data")
	table.walk(self._data, function(v, k)
		if data[k] then
			self._data[k] = data[k]
		else
			printWarn("key:%s not in data, hero hero_id:%d", tostring(k), data.hero_id)
		end
	end)

	self._inited = true
end

function HeroModel:GetId()
	return self._data.id
end

function HeroModel:GetCareer()
	return self._data.career
end

function HeroModel:Die()
	self._is_dead = true
end

function HeroModel:SetCamp(camp)
	self._camp = camp
end

function HeroModel:GetCamp()
	return self._camp
end

function HeroModel:IsDead()
	return self._is_dead
end

function HeroModel:GetLevel()
	return self._data.level
end

function HeroModel:GetConfigId()
	return self._data.hero_id
end

function HeroModel:GetPartnerConfigId()
	return self._data.partner_id
end

-- function HeroModel:CanTransform()
-- 	return self._data.can_transform > 0
-- end

function HeroModel:GetMaxHp()
	return self._attr_manager:GetMaxHp()
end

function HeroModel:GetCurrentHp()
	return self._attr_manager:GetCurrentHp()
end

function HeroModel:AddHp(add_hp)
	return self._attr_manager:AddHp(add_hp)
end

function HeroModel:SubHp(sub_hp)
	return self._attr_manager:SubHp(sub_hp)
end

function HeroModel:AddAnger(add_anger, bool)
	return self._attr_manager:AddAnger(add_anger, bool)
end

function HeroModel:SubAnger(sub_anger)
	return self._attr_manager:SubAnger(sub_anger)
end

function HeroModel:GetAnger()
	return self._attr_manager:GetAnger()
end

function HeroModel:CleanAnger()
	return self._attr_manager:CleanAnger()
end

function HeroModel:GetATK()
	return self._attr_manager:GetAtk()
end

function HeroModel:GetBlockRate()
	return self._attr_manager:GetBlockRate()
end

function HeroModel:GetDisBlockRate()
	return self._attr_manager:GetDisBlockRate()
end

function HeroModel:GetMissRate()
	return self._attr_manager:GetMissRate()
end

function HeroModel:GetHitRate()
	return self._attr_manager:GetHitRate()
end

function HeroModel:GetCritRate()
	return self._attr_manager:GetCritRate()
end

function HeroModel:GetDecCritRate()
	return self._attr_manager:GetDecCritRate()
end

function HeroModel:GetAttrTable()
	return self._attr_manager:GetAttrTable()
end

function HeroModel:GetPokeballSkill()
	return self._data.pokeball_skill
end

function HeroModel:Refresh()
	self._attr_manager:Refresh()
end

function HeroModel:AddAttr(attr_id, attr_value)
	self._attr_manager:AddAttr(attr_id, attr_value)
end

function HeroModel:SubAttr(attr_id, attr_value)
	self._attr_manager:SubAttr(attr_id, attr_value)
end

-- function HeroModel:GetTenacity()
-- 	return self._attr_manager:GetRangXingRate()
-- end

return HeroModel
