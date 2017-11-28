local Random = class("Random")
local json = require("json")
local math_randomseed = math.randomseed
local math_random = math.random

function Random:ctor(seed)
	seed = tonumber(seed)
	-- math_randomseed(seed)
	self._sequence = {}
	self.fe = seed
	self.seed = seed
	self.random_count = 0
end

function Random:Get(n)
	self.seed = self.seed + self.random_count * self.random_count + (self.random_count / 2) + n - 1
	return self.seed
end

function Random:nextInt(n)
	self.random_count = self.random_count + 1
	return math.ceil(self:Get(n))
end

function Random:random(n)
	local rn = self:nextInt(n)
	if rn < 0 then self.seed = self.fe end
	local result = math.abs(rn % n) + 1
	table.insert(self._sequence, result)
	return result
	-- local result = math_random(...)
	-- table.insert(self._sequence, result)
	-- return result
end

function Random:GetSequence()
	return json.encode(self._sequence)
end

return Random
