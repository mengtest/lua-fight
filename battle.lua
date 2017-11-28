package.path = package.path .. ';../../../../public/New_Fight/New_Fight/src/?.lua;'
package.path = package.path .. ';../lua/?.lua;'
package.path = package.path .. ';/opt/fate/bin/lua/?.lua'
package.path = package.path .. ';/data/fate/server/lua/?.lua'
package.path = package.path .. ';/data/duole/server/lua/?.lua'

require("BattleData")
require("functions")
local BattleLogic = require("BattleLogic")
local json = require "json"

function save_log( txt )
	if txt == nil or DEBUG < 3 then
		return
	end

	local s = txt
	local f = io.open( "lua.log", "a+" );
	f:write( s..'\n' )
	f:close()
end

function main( our, peer, mode, seed, attacker_power, defender_power, force_first )
	local c = BattleLogic.new()
	local peer1 = peer[1]
	c:LogSwitch("","a.txt")
	c:InitBattle(our.heros, our.player_extra_attr, peer1.heros, peer1.player_extra_attr, mode, seed, attacker_power, defender_power, force_first)

	function do_round()
		local result = FIGHTRESULT.PASS
		repeat
			result = c:Update()
		until result ~= FIGHTRESULT.PASS
		save_log(c:GetFightPackMgr():Dump())
		return result
	end

	local result = do_round()

	if result == FIGHTRESULT.WIN and #peer > 1 then
		for i = 2, #peer do
			assert( i <= #peer )
			assert( #(peer[i].heros) > 0 )
			c:InitNextBattle(peer[i].heros, peer[i].player_extra_attr, mode, force_first)
			result = do_round()
		end
	end

	return result, c:GetRound(), c:GetResultDetail()
end

function run_battle( our, peer, mode, seed, attacker_power, defender_power, force_first )
	local our_json = json.encode(our)
	local peers_json = json.encode(peer)
	save_log("our data:")
	save_log(our_json)
	save_log("peer data:")
	save_log(peers_json)
	save_log("mode:")
	save_log(mode)
	save_log("seed:")
	save_log(seed)
	save_log("force_first:")
	save_log(force_first)

	trace_func = function(msg)
		local msg = debug.traceback(msg, 3)
		save_log(msg)
	end

	local result = -1
	local round = 0
	local detail = {}
	run_func = function()
		result, round, detail = main(our, peer, mode, seed, attacker_power, defender_power, force_first)
	end

	local status, msg = xpcall( run_func, trace_func )
	if not status then
		-- ErrorLogCpp(msg)
		-- print(msg)
	end

	save_log("detail")
	save_log(json.encode(detail))
	return result, round, detail, our_json, peers_json
end
