CAMPTYPE = {
	OUR = 1,
	PEER = 2
}

CAREER_TYPE = {
	ELF = 1,
	FLYING = 2,
	BEAST = 3
}

SKILL_OR_BUFF = {
	SKILL = 1,
	BUFF = 2,
	SPECIAL = 3,
}

ELEMENT_DAMAGE_TYPE = {
	WATER = 1,
	FIRE = 2,
	WIND = 3,
	SOIL = 4
}

SKILL_UPGRADE_TYPE = {
	UPGRADE_FACTOR = 1,
	UPGRADE_EXTRA = 2,
	UPGRADE_AURA = 3,
	UPGRADE_BUFF = 4
}

FIGHTMODE = {
	MODE1 = 1, -- 普通
	MODE2 = 2, -- 5回合永远胜利
	MODE3 = 3, -- 敌方共享血条永远胜利模式
	MODE4 = 4, -- 敌方共享血条5回合永远胜利模式
	MODE5 = 5, -- 敌方共享血条3回合模式
	MODE6 = 6, -- 20回合永远胜利
}

-- ATTRTYPE = {
-- 	HP = 1,	-- 血量
-- 	WULI_ATTACK = 2, -- 物理伤害
-- 	MOFA_ATTACK = 3,	-- 魔法伤害
-- 	WULI_DEFEND = 4,	-- 物理防御
-- 	MOFA_DEFEND = 5,	-- 魔法防御
-- 	SPEED = 6, -- 敏捷
-- 	BAOJI_LEVEL = 7,	-- 暴击等级
-- 	BAOJIHURT_ADDON_RATE = 8,			 -- 暴击等级加成百分比%
-- 	MINGZHONG_LEVEL = 9,					-- 命中等级
-- 	SHANGBI_LEVEL = 10,						 -- 闪避等级
-- 	GEDANG_LEVEL = 11,				-- 格挡率=防御方格挡等级/防御方角色等级，该值的生效范围0-MAX
-- 	RANGXING_RATE = 12,						 -- % 百分比属性，可以降低控制性负面状态的命中率，该值的生效范围0-100
-- 	HURT_ADDON_RATE = 13,					-- %	伤害加成百分比
-- 	HURT_REDUCE_RATE = 14,				 -- %	伤害减少百分比
-- 	SECOND_ACTION = 15,			 -- 0或者非0。非0表示该单位会以减半敏捷二次行动。
-- 	RECOVERY = 16,						-- 假设恢复能力为X，战斗之后会恢复（X/该角色等级）%的生命值，最大不超过100%
-- 	ANGER = 17,								-- 初始怒气
-- 	PVP_HURTADDON = 18,			 -- PVP伤害加成
-- 	PVP_HURTREDUCE = 19,			-- PVP伤害减少
-- 	SUPERSKILL_RATE = 20,		 -- %
-- 	VIOLEVEL = 21,	-------------抗爆等级
-- 	CUREUP = 22, --攻击方治疗效果提升
-- 	------------------------------------------------------百分比增长
-- 	HP_AMEND = 101,
-- 	WULI_ATTACK_AMEND = 102, -- 物理伤害
-- 	MOFA_ATTACK_AMEND = 103,	-- 魔法伤害
-- 	WULI_DEFEND_AMEND = 104,	-- 物理防御
-- 	MOFA_DEFEND_AMEND = 105,	-- 魔法防御
-- 	SPEED_AMEND = 106, -- 敏捷
-- 	BAOJI_LEVEL_AMEND = 107,	-- 暴击等级
-- 	BAOJIHURT_ADDON_RATE_AMEND = 108,			 -- 暴击等级加成百分比%
-- 	MINGZHONG_LEVEL_AMEND = 109,					-- 命中等级
-- 	SHANGBI_LEVEL_AMEND = 110,						 -- 闪避等级
-- 	GEDANG_LEVEL_AMEND = 111,				-- 格挡率=防御方格挡等级/防御方角色等级，该值的生效范围0-MAX
-- 	RANGXING_RATE_AMEND = 112,						 -- % 百分比属性，可以降低控制性负面状态的命中率，该值的生效范围0-100
-- 	HURT_ADDON_RATE_AMEND = 113,					-- %	伤害加成百分比
-- 	HURT_REDUCE_RATE_AMEND = 114,				 -- %	伤害减少百分比
-- 	SECOND_ACTION_AMEND = 115,			 -- 0或者非0。非0表示该单位会以减半敏捷二次行动。
-- 	RECOVERY_AMEND = 116,						-- 假设恢复能力为X，战斗之后会恢复（X/该角色等级）%的生命值，最大不超过100%
-- 	ANGER_AMEND = 117,								-- 初始怒气
-- 	PVP_HURTADDON_AMEND = 118,			 -- PVP伤害加成
-- 	PVP_HURTREDUCE_AMEND = 119,			-- PVP伤害减少
-- 	SUPERSKILL_RATE_AMEND = 120,		 -- %
-- 	VIOLEVEL_AMEND = 121,	---------抗爆等级
-- 	CUREUP_AMEND = 122, ------------攻击方治疗效果提升百分比
-- }

HEROATTRTYPE =
{
	ATK 				= 1,
	DEF 				= 2,
	HP 					= 3,
	ATK_PERCENT 		= 4,
	DEF_PERCENT 		= 5,
	HP_PERCENT 			= 6,
	CRIT 				= 7,
	DEC_CRIT 			= 8,
	HIT 				= 9,
	MISS 				= 10,
	CRIT_DMG 			= 11,
	DEC_CRIT_DMG 		= 12,
	INC_DMG 			= 13,
	DEC_DMG 			= 14,
	INC_POISON 			= 15,
	DEC_POISON 			= 16,
	INC_BURN 			= 17,
	DEC_BURN 			= 18,
	HEAL 				= 19,
	BE_HEAL 			= 20,
	BLOCK 				= 21,
	DIS_BLOCK 			= 22,
	PVP_INC_DMG 		= 23,
	PVP_DEC_DMG 		= 24,
	BEAT_BACK 			= 25,
	REFLECT_RATE 		= 26,
	REFLECT_DMG 		= 27,
	HOLY_DMG 			= 28,
	HOLY_CRIT 			= 29,
	SELF_HEAL 			= 30,
	FORCE_SELF_HEAL 	= 31,
	VAMPIRISM 			= 32,
	VAMPIRISM_RESISTANCE = 33,
	ANGER 				= 34,
}

FIGHTRESULT = { -- 战斗结果
	PASS = 1,
	WIN = 2,
	LOSE = 3,
	TIMEOUT = 4,
	ROUND_OVER = 5,
}

TARGET_TYPE = {
	--------------------敌方

	ENEMY_BEGIN 					= 100,
	ENEMY_FRONTROW_MULTI 			= 101,		-- 敌方前排
	ENEMY_BACKROW_MULTI 			= 102,		-- 敌方后排
	ENEMY_COLUMN_MULTI 				= 103,		-- 敌方竖排
	ENEMY_ALL_MULTI					= 104,		-- 敌方全体
	ENEMYR_ANDOMTHREE_MULTI 		= 105,		-- 敌方随机3目标
	ENEMY_FRONTNEIGHBOR_MULTI 		= 106,		-- 敌方前排对位及其相邻目标
	ENEMY_BACK_SINGLE 				= 107,		-- 敌方后排对位
	ENEMY_FRONT_SINGLE 				= 108,		-- 敌方前排对位
	ENEMY_RANDOM_BUFF_SINGLE		= 109,		-- 敌方随机1个有BUFF的目标
	ENEMY_RANDOM_BUFF_TWO	 		= 110,		-- 敌方随机2个有BUFF的目标
	ENEMY_HPPERCENTLOWEST_SINGLE	= 111,		-- 敌方生命值百分比最低
	ENEMY_HPPERCENTHIGHTEST_SINGLE	= 112,		-- 敌方生命值百分比最高
	ENEMY_ANGERMOST_SINGLE			= 113,		-- 敌方怒气最多
	ENEMY_ANGERLESS_SINGLE			= 114,		-- 敌方怒气最少
	ENEMY_ATK_HIGHEST_SINGLE		= 115,		-- 敌方攻击最高
	ENEMY_RANDOM_SINGLE				= 116,		-- 敌方随机1目标

	ENEMY_END						= 199,

	--------------------我方

	FRIEND_BEGIN					= 200,
	FRIEND_HPPERCENTLOWEST_SINGLE	= 201,		-- 己方生命值百分比最低
	FRIEND_HPPERCENTHIGHTEST_SINGLE	= 202,		-- 己方生命值百分比最高
	FRIEND_CASTERSELF_SINGLE		= 203,		-- 自己
	FRIEND_ANGERMOST_SINGLE			= 204,		-- 己方怒气最多
	FRIEND_ANGERLESS_SINGLE			= 205,		-- 己方怒气最少
	FRIEND_RANDOMONE_SINGLE			= 206,		-- 己方随机1目标
	FRIEND_RANDOMTWO_SINGLE			= 207,		-- 己方随机2目标
	FRIEND_RANDOMTHREE_SINGLE		= 208,		-- 己方随机3目标
	FRIEND_FRONTROW_MULTI			= 209,		-- 己方前排
	FRIEND_BACKROW_MULTI			= 210,		-- 己方后排
	FRIEND_ALL_MULTI				= 211,		-- 己方全体
	FRIEND_RANDOM_DEBUFF_SINGLE		= 212,		-- 己方随机1个有DEBUFF的目标
	FRIEND_RANDOM_DEBUFF_TWO		= 213,		-- 己方随机2个有DEBUFF的目标
	FRIEND_ATK_HIGHEST_SINGLE		= 214,		-- 己方攻击最高
	FRIEND_EXCEPT_SELF_MULTI		= 215,		-- 除自己以外的所有友方

	FRIEND_END						= 299,

	OTHER_HERO_ID_BEGIN				= 300,		-- 大于300的为指定精灵ID
}

-- ORDERGOALTYPE = {
-- 	NONE = 100,	--无次目标
-- 	GUNROW = 101, --与主目标同行
-- 	GUNCOL = 102, -- 与主目标同列
-- 	RANDOMONE = 103, --随机一个目标
-- 	RANDOMTWO = 104,	-- 随机2个目标
-- 	RANDOMTHREE = 105, --随机3个目标
-- 	RANDOMFORE = 106, --随机4个目标
-- 	RANDOMFIVE = 107,	-- 随机5个目标
-- 	SPOTTER = 108,	--溅射
-- 	HPLOW = 109,	--当前生命百分值最低
-- 	MAXHPHIGHT = 110, --max hp 最高
-- }

function sleep(n)
	 if n > 0 then os.execute("ping -n " .. tonumber(n + 1) .. " localhost > NUL") end
end

function min(x,y)
	if x > y then
		return y
	end
	return x
end

function max(x,y)
	if x > y then
		return x
	end
	return y
end

FightLog = false

RandomFunction = false

function random(...)
	if RandomFunction then
		local n = RandomFunction:random(...)
		return n
	end
	return 0
end

FIGHT_PACK_MANAGER = false

FIGHTTYPE = {
	MANUL = 1, -------------手动
	AUTO = 2,	-------------自动
	VERIFY = 1, ---------------验证手动
	PVP = 3,	-----------------PVP模式
}

CLIENTTYPE = {
	CLIENT = 1,
	SERVER = 2,
}

ANGERTYPE = {
	ADD_ANGER_PER_ROUND = 2,
	FULLANGER 			= 4,
	MAXANGER			= 99,
}

SKILLTYPE = {
	NORMAL = 1,
	ANGER = 2,
	POKEBALL = 3,
}

DAMAGE_EFFECT_TYPE = {
	NORMAL 	= 1,
	HOLY 	= 2,
	POISON  = 3,
	BURN	= 4,
}

LOCKTARGET = {
	UNLOCK = 0, -- 每次发动技能都选择新目标
	LOCK = 1,	-- 每次发动都从已有的目标中选择
}

STUNTTYPE = {
	SKILLING = 0,	--发动时生效
	ADDHIT = 1, --增加命中率
	VAMPIRISM = 2, -- 吸血
	REDUCE = 3,	--削减，在一个技能周期内命中同一个目标的时候，伤害削减X%，不会再次削减。比如一个技能随机攻击20次，X为60，第13579次命中了同一个目标，第一次造成1000伤害，则3579次造成400,400,400,400点伤害
	HPLOWHURT = 4, -- 致命一击，敌方生命值百分比越低造成的伤害越高，空血时为200%
	BACKANGER = 5,--攻击者在释放该技能的时候额外回复X怒气（可以填负数，-1000到1000）
	LOSSANGER = 6,--受到攻击的人百分百额外损失X怒气（可以填负数，-1000到1000）
	SUBSTRRIPHPRATE = 7,--附加敌方单条血量X%的伤害
	-- CHANGEATKATS = 8,--使得自己的基础魔法攻击力和基础物理攻击力改变，数值为这两者之间高的那一个，比如基础物理攻击500，基础魔法攻击200，使用该技能之后两者都变500。
	-- GIVEANGER = 9, -- 攻击者生命值高于单条血量35%的时候（对于BOSS来说，只要血量大于1条都算高于35%，血量只剩1条的时候才比较这个35%），释放大招恢复满怒气。
	-- SUBGOALS = 10, --对次目标效果只有主目标的X%(在计算伤害和治疗技能的时候，对非主目标的效果只有X%，如果X=60，那么对次目标的所有效果乘以60%)
	-- DISPEL = 11,--驱散，消除X个目标所有可驱散的BUFF（敌方）
	-- REFINE = 12,--净化，消除X个目标所有可净化的DEBUFF（我方）
	-- SUBHP = 13, -- 释放技能时消耗单条血量的X%
	SELFDISPEL = 14,--自我驱散 X为BUFF ID
	-- CAREER = 15, -- 对职阶为X的目标造成双倍伤害
	OURHPLOWHURT = 16, --己方生命百分比最低的造成伤害越高
	-- CRITICAL = 17, -- 100%暴击

	-- TODO pet2
	LASTHIT = 18, -- 该技能在发动最后一次时的伤害系数变为原来的X倍
	ADDHITCRIT = 19, -- 额外增加X%命中率和暴击率
	LOSSANGER_ONE = 20, -- X%的概率使伤害目标怒气-1
	LOSSANGER_TWO = 21, -- X%的概率使伤害目标怒气-2
	CLEAR_ANGER = 22, -- X%的概率使伤害目标怒气清零
	ADDCRIT = 23, -- 额外增加X%暴击率
	KILLALL = 24, -- 秒杀
	ENHANCE_SKILL_PER_RELEASE = 25, -- 该技能每发动一次伤害系数增加X%
}

GROWTYPE = {
	NULLGROW = 0,	-- 无成长
	RDWGROW = 1,	-- 系数成长
	DAMAGEGROW = 2, -- 伤害成长
	HALOGROW = 3, -- 光环成长
}

BUFFTYPE = {
	ATK_CHANGE				= 1, -- 攻击力变为原先的X%
	DEF_CHANGE				= 2, -- 防御改变为原来的X%
	HP_CHANGE				= 3, -- 血量改变为原来的X%
	DMG_CHANGE				= 4, -- 伤害增加属性改变X%,伤害减免属性改变Y%
	CRIT_CHANGE 			= 5, -- 暴击率改变X%
	DEC_CRIT_CHANGE			= 6, -- 抗暴率改变X%
	HIT_CHANGE				= 7, -- 命中率改变X%
	MISS_CHANGE				= 8, -- 闪避率改变X%
	CRIT_DMG_CHANGE			= 9, -- 暴击伤害改变X%
	DEC_CRIT_DMG_CHANGE		= 10, -- 暴击免伤改变X%
	BLOCK_CHANGE 			= 11, -- 挡格率改变X%
	DIS_BLOCK_CHANGE 		= 12, -- 破挡率改变X%
	STRONG					= 13, -- 结实，抗暴率改变X%，格挡率改变X%，免伤改变Y%，闪避改变Y%
	SMARTER					= 14, -- 敏捷，抗暴率改变X%，免伤改变X%，闪避改变Y%，暴击免伤改变Y%
	HEAL_CHANGE 			= 15, -- 治疗率改变X%
	BE_HEAL_CHANGE 			= 16, -- 被治疗率改变X%
	ANGER_CHANGE			= 17, -- 怒气改变X

	LOCK_ANGER_DEC			= 18, -- 拥有这个BUFF的时候，怒气无法被降低
	GET_ANGER				= 19, -- 被攻击时有X%概率恢复Y点怒气
	LOCK_ANGER_INC			= 20, -- 【封怒】，拥有这个BUFF的时候，无法增加怒气，前端显示“封怒”特效。
	LOCK_HEAL				= 21, -- 【封疗】，无法被治疗。前端显示“封疗”字样。
	DIZZ					= 22, -- 【晕眩】，无法行动，无法格挡，无法闪避
	SILENCE 				= 23, -- 【沉默】，无法使用大招和超大招
	PETRIFIED				= 24, -- 【石化】，无法行动，无法被治疗，无法格挡，无法闪避。前端显示“石化”字样。
	HEAL_CHANGE_GIVE_HP		= 25, -- 【水波动】，拥有这个BUFF的时候，自身被治疗率改变X，受到伤害时攻击方恢复相当于伤害值Y%的生命
	POISONING				= 26, -- 中毒，根据中毒伤害公式计算X%+Y的伤害值，在BUFF上去的时候已计算好，每回合行动前受到伤害
	BURNING					= 27, -- 灼烧，根据灼烧伤害公式计算X%+Y的伤害值，在BUFF上去的时候已计算好，每回合行动前受到伤害
	SHIELD 					= 28, -- 护盾，根据治疗公式计算X%+Y的吸收量，吸收最终伤害值，同BUFFID不叠加，刷新为最高护盾值。
	POISON_DMG_CHANGE		= 29, -- 中毒增伤改变X%
	POISON_DEF_CHANGE		= 30, -- 中毒减伤改变X%
	BURNING_DMG_CHANGE		= 31, -- 灼烧增伤改变X%
	BURNING_DEF_CHANGE		= 32, -- 灼烧减伤改变X%
	RECOVERY 				= 33, -- 恢复，每回合根据治疗公式获得X%+Y治疗量
	GOD 					= 34, -- 无敌，该BUFF在的时候清除任何“可以被净化”BUFF，无视任何伤害技能，伤害技能效果和“可以
	REBORN					= 35, -- 春哥，在死亡前触发，如果受到的伤害小于最大生命值，可以强制生命值为1点，并且恢复X%+Y治疗量的生命值，移除该BUFF。
	BOOM 					= 36, -- 爆炸，爆炸的伤害量为X%+Y，在BUFF上去的时候已经计算好，除了无敌以外不能被减免，当有这个BUFF的人被BUFF的施法者使用普通攻击，大招或者超大招命中的时候，会对这个BUFF的人造成额外伤害，同时BUFF消失。
	SNEER 					= 37, -- 嘲讽，专注，命令。拥有这个BUFF的目标只能攻击指定目标，如果指定目标死亡，这个BUFF立刻消失。
	REFLECT 				= 38, -- 反弹，反弹伤害=攻击者造成伤害值的X%；此伤害为真实伤害，无视防御，且不能再次被反弹
	DOUBLE_DMG				= 39, -- 有X%概率造成双倍伤害，前端显示“双倍”字样。
	DEATH_KILL				= 40, -- 一击必杀，有X%的概率秒杀目标
	DISPEL					= 41, -- 驱散所有可驱散的BUFF
	CLEAN_DEBUF				= 42, -- 净化所有可净化的BUFF
	IMMUNE					= 43, -- 免疫，免疫所有可净化的BUFF
	MISS_HEAL				= 44, -- 拥有这个buff的时候，当自身闪避或者格挡的时候，治疗自己根据治疗公式计算X%+Y治疗量
	POISONING_CRIT			= 45, -- 中毒, 可暴击
	BURNING_CRIT			= 46, -- 灼烧, 可暴击
	STRIKE_NORMAL_BUFF		= 47, -- (战斗外已算好) 清扫火箭队普通攻击开场buff，每个己方单位的伤害增加+当前突破等级*100%，如：某精灵当前突破+8，则伤害增加+800%；前端显示突破提升字样，每只精灵头顶显示：伤害x当前突破等级字样
	STRIKE_ADVANCED_BUFF	= 48, -- (战斗外已算好) 清扫火箭队全力一击开场buff，伤害加成增加+当前突破等级*2.5*100%，如：某精灵当前突破+8，则伤害增加+2.5*800%=2000%；前端显示1、突破提升，伤害x当前突破等级字样2、全力一击，伤害x（当前突破等级*2.5）字样
	EXCESSIVE_HEAL_SHIELD	= 49, -- 护盾，吸收量=过量治疗的一定百分比，按特性表控制参数，吸收最终伤害值，同BUFFID不叠加，刷新为最高护盾值。身上有多个护盾的时候，按照先进先出的规则消耗护盾。
	INC_DAMAGE_BY_EFFECT	= 50, -- 记录当前身上特效ID为X的BUFF的总层数为n，受到伤害时的伤害增加n*Y。
	INC_DAMAGE_BY_ATK		= 51, -- 攻击力增加，施加buff时就已经算好，值为施加者攻击力的X%，此攻击力直接加在加成之后的攻击力上
	CRIT_AND_CRIT_DAMAGE_CHANGE = 52, -- 暴击率改变X；暴击伤害属性改变Y；减少则为负值
}

SPECIALTYPE = {
	-- 永久生效，战斗外也生效
	ADD_ATTR_ALL = 1,	-- 获得属性类型为X的属性Y，加在原有属性上
	MODIFY_SKILL_EFFECT_ALL = 2,	-- 当前宠物的X技能伤害系数+Y，buff1触发率+Z，直接加在原有值上（X=1,普通攻击，2，怒气技能，3，精灵球大招）
	REPLACE_SKILL_ALL= 3,	-- 如果拥有技能ID为X的技能，那么替换为技能ID为Y的技能
	MODIFY_SKILL_STUNT_ALL= 4,	-- 当前宠物的X技能特技1参数+Y，特技2参数+Z，直接加在原有值上（X=1,普通攻击，2，怒气技能，3，精灵球大招）
	MODIFY_SKILL_BUFF_ALL= 5,	-- 当前宠物的X技能buff_id1替换为Y，buff_id2替换为Z。（X=1,普通攻击，2，怒气技能，3，精灵球大招）

	-- 开场
	ADD_TARGET_BUFF_BEGIN = 101,	-- 战斗开始即为参数为X的目标施加一个ID为Y的BUFF

	-- 每回合结束时
	RECOVER_HP_BY_ATK_ROUNDOVER = 201, -- 每回合结束时回复相当于自身攻击力X%的血量
	ADD_DMG_DECDMG_ROUNDOVER = 202, -- 回合结束时，伤害提高X%，免伤提高Y%
	ADD_BUFF_ROUNDOVER = 203, -- 回合结束时，为参数为X的目标施加一个ID为Y的BUFF
	CLEAN_DEBUFF_ROUNDOVER = 204, -- 回合结束 清除DEBUFF

	-- 战斗中第一次攻击时
	ADD_DMG_FIRSTATTACK = 301, --	战斗中第一次攻击时，伤害增加X%，暴击率增加Y%，暴击伤害增加Z%
	ADD_HIT_FIRSTATTACK = 302, --	战斗中第一次攻击时，伤害增加X%，暴击率增加Y%，命中率增加Z%

	-- 攻击时
	TARGET_ANGER_MORE_ADD_DMG_ATTACKING = 401, --	对怒气大于X的目标造成的伤害提高Y%
	TARGET_ANGER_LESS_ADD_DMG_ATTACKING = 402, --	对怒气小于X的目标造成的伤害提高Y%
	TARGET_HP_MORE_ADD_DMG_ATTACKING = 403, --	对血量高于X%的目标造成的伤害提高Y%
	TARGET_HP_LESS_ADD_DMG_ATTACKING = 404, --	对血量低于X%的目标造成的伤害提高Y%
	TARGET_HP_MORE_ADD_CRIT_ATTACKING = 405, --	对血量高于X%的目标暴击率提高Y%，暴击伤害提高Z%
	ADD_CRIT_OUR_ALIVE_ATTACKING = 406, --	攻击时，场上每有一个队友存活，暴击率+X%，暴击伤害+Y%
	TARGET_NOT_ACT_ADD_DMG_ATTACKING = 407, --	攻击时，对本回合未行动过的对手伤害+X%
	ADD_CRIT_BY_ANGER_ATTACKING = 408, --	记录当前的怒气值，每有1点怒气，暴击伤害+X%，暴击率+Y%
	TARGET_HP_MORE_VAMPIRISM_LESS_ADDDMG_ATTACKING = 409, --	攻击对生命值高于自身的目标吸血X%，对低于自身的目标伤害增加Y%
	PROBABLY_DOUBLE_HIT_ATTACKING = 410, --	技能和普攻有X%的概率连续发动两次

	-- 行动之后（包括普攻、技能和额外行动）
	ADD_BUFF_AFTERACT = 501, --	行动之后，对目标参数为X的目标施加ID为Y的buff
	ADD_ATTR_AFTERACT = 502, --	行动之后，获得属性类型为X的属性Y，加在原有属性上
	-- 503, --	每次攻击后，敌方受ID为X、Y的BUFF影响的单位受到的来自于此buff的伤害（烧、毒）增加Z%，自身免伤加Z%，加法叠加
	-- 504, --	攻击了受到ID为X的buff影响的目标的队友，有Y%的概率再进行一次普攻（计入行动次数、怒气不变）
	VAMPIRISM_AFTERACT = 505, --	吸血，行动造成伤害之后，自身恢复相当于此次伤害值X%的生命值
	TARGET_HAS_BUFF_VAMPIRISM_AFTERACT = 506, --	攻击受特效ID为X的buff影响的敌人时吸血Y%
	-- TARGET_HAS_BUFF_ADD_BUFF_AFTERACT = 507, --	攻击受ID为X的buff影响的敌人后对它们施加ID为Z的buff

	-- 被攻击时（前）
	TARGET_ANGER_MORE_DEC_DMG_BEFOREUNDERATTACK = 601, --	怒气大于X的攻击者对自身造成的伤害减少Y%
	TARGET_HP_MORE_DEC_DMG_BEFOREUNDERATTACK = 602, --	血量高于X%的攻击者对自身造成的伤害减少Y%
	TARGET_HP_LESS_DEC_DMG_BEFOREUNDERATTACK = 603, --	血量低于X%的攻击者对自身造成的伤害减少Y%
	TARGET_HAS_BUFF_DEC_DMG_BEFOREUNDERATTACK = 604, --	受特效ID为X的BUFF影响下的攻击者对自身伤害减少Y%
	TARGET_SKILL_EFFECT_DEC_DMG_BEFOREUNDERATTACK = 605, --	效果类型为X、Y的技能对自己造成的伤害减少Z%

	-- 被攻击后（攻击行为结束后）
	ADD_ATTR_AFTERUNDERATTACK = 701, --	受到伤害后，属性类型为Y的属性增加Z（多段伤害算作1次）
	TARGET_SKILL_EFFECT_ADD_ATTR_AFTERUNDERATTACK = 702, --	受到效果类型为X的技能伤害后，属性类型为Y的属性增加Z
	-- 703, --	反弹1，每次被攻击后，有X%的概率对攻击者造成1次相当于Y%攻击力的反弹伤害（无反击动作）
	REFLECTING_DMG_AFTERUNDERATTACK = 704, --	反弹2，每次被攻击后，有X%的概率对攻击者造成相当于Y%伤害值的反弹伤害（无反击动作）
	TARGET_REDUCE_ATTR_AFTERUNDERATTACK = 705, --	对拥有该特性的精灵造成伤害的单位，属性类型为X的属性减少Y%，每回合对同一单位只生效1次，叠加
	BEAT_BACK_AFTERUNDERATTACK = 706, --	反击，被攻击后有X%的概率立即使用普通攻击对攻击者进行反击
	ADD_ANGER_UNDER_ATTACK = 707,	-- 受到伤害后，有X%概率回复Y点怒气（多段伤害只判定1次）

	-- 释放技能后（不包括普攻）
	DOUBLE_SKILL_AFTERRELEASEANGERSKILL = 801, --	释放技能后（类型2或3），立即再施放一次技能ID为X的技能
	ADD_BUFF_AFTERRELEASEANGERSKILL = 802, --	释放技能后（类型2或3），对目标参数为X的目标施加ID为Y的buff
	ADD_ATTR_AFTERRELEASEANGERSKILL = 803, --	释放技能后（类型2或3），获得属性类型为X的属性Y，加在原有属性上
	TARGET_LOSE_ANGER_ADD_DMG_AFTERRELEASEANGERSKILL = 804, --	释放技能后（类型2或3），敌方每成功减少1点怒气（因为此技能而减少），造成的伤害额外增加X%
	VAMPIRISM_AFTERRELEASEANGERSKILL = 805, --	释放技能后（类型2或3），吸取敌方对位单体X%生命上限的血量（敌方扣血我方回血）
	-- 806, --	释放技能后，随机使用一个ID为X、Y、Z的技能

	-- 击杀目标后
	ADD_ANGER_AFTERKILL = 901, --	击杀目标后，怒气增加X（每回合最多触发一次）
	ADD_BUFF_AFTERKILL = 902, --	击杀目标后，对参数为X的目标施加ID为Y的BUFF

	-- 持续整场战斗
	ADD_ATTR_DURINGFIGHT = 1001, --	获得属性类型为X的属性Y，加在原有属性上
	TARGET_HAS_BUFF_ADD_DMG_DURINGFIGHT = 1002, --	记录当前敌方身上特效ID为X的BUFF的总个数（叠加多层的按层数计算）为n，自身暴击率增加n*Y,伤害增加n*Z。
	IMMUNE_BUFF_DURINGFIGHT = 1003, --	[免疫特定buff]免疫特效ID为X、Y、Z的BUFF
	RECOVER_ONE_ANGER_DURINGFIGHT = 1004, --	拥有此特性的单位每回合只增加一点怒气（清扫火箭队用）
	IMMUNE_LOSE_ANGER = 1005, -- 怒气无法被降低

	-- 自身怒气
	ADD_DECDMG_SELFANGERMORE = 1101, --	当自身怒气大于X时，免伤提高Y%
	ADD_DMG_SELFANGERMORE = 1102, --	当自身怒气大于X时，伤害提高Y%
	ADD_DMG_SELFANGERLESS = 1103, --	当自身怒气小于X时，伤害提高Y%

	-- 自身血量
	ADD_DECDMG_SELFHPMORE = 1201, --	当自身血量高于X%时，免伤提高Y%
	ADD_DMG_SELFHPMORE = 1202, --	当自身血量高于X%时，伤害提高Y%
	ADD_DECDMG_SELFHPLESS = 1203, --	当自身血量低于X%时，免伤提高Y%
	ADD_DMG_SELFHPLESS = 1204, --	当自身血量低于X%时，伤害提高Y%(茂盛、猛火、激流)

	-- 普通攻击后
	PROBABLY_DOUBLE_HIT_AFTERNORMALSKILL = 1301, --	每次普通攻击结束后有X%概率再进行普通攻击（此概率逐级递减5%，如连续普攻了3次，下一次再连的概率=(X-5*2)%）

	-- 队友攻击后
	EXTRA_NORMAL_SKILL_AFTERPARTNERACT = 1401, --	队友攻击后有X%概率对队友的随机一名攻击目标追加一次普攻（在队友行动结束后立即行动）

	-- 格挡后
	ADD_BUFF_AFTERBLOCK = 1501, --	每次格挡后，给参数为X的目标施加ID为Y的BUFF

	-- 治疗时
	TARGET_HP_LOSE_ADDHEAL = 1601, --	治疗生命值低于X%的友方单位时，治疗率提高Y%
	TARGET_FRONT_ROW_ADDHEAL = 1602, --	治疗友方前排时，治疗率提高X%
	EXCESSIVE_HEAL_ADDSHIELD = 1603, --	治疗时，过量治疗的50%转化为护盾

	-- 处于DEBUFF（可净化的buff）影响下时
	ADD_ATTR_UNDERDEBUFF = 1701, --	[毅力]处于DEBUFF（可净化的buff）影响下时，获得属性类型为X的属性Y

	-- 扣血时
	ADD_ATTR_UNDERBLEEDING = 1801, --	血量每减少生命上限的X%，自身伤害增加Y%，免伤增加Z%

	-- 受到伤害时
	DEC_DAMAGE_HP_LIMIT_UNDERATTACKING = 1901, --	单次受到的最大伤害不超过自身生命上限的X%（这个单次是指一个单位的一次行动之内）

	-- 存活时
	ADD_ARUA_BUFF_ALIVE = 2001, --	存活时光环，为目标参数为X的目标提供ID为Y的BUFF，死亡即消失
	-- ADD_DMG_ALIVE = 2002, --	存活时光环，记录当前敌方身上特效ID为X的BUFF的层数为n，其在受到伤害时的伤害增加n*Y。

	-- 死亡时
	TARGET_ADD_BUFF_BEKILLED = 2101, --	杀死自己的敌人获得ID为X的buff

	-- 获得BUFF时
	TARGET_COPY_BUFF = 2201, -- [同步]被敌方施加BUFF时，对敌方施加此BUFF的精灵施加相同的BUFF

}

CanRelease = {
	CAN = 0, -- 能释放
	FORBIDDEN = 1, --被禁用
	DISSATISFY = 2, -- 不满足条件
}

ConditionArg = {
	NONE = 0 , ----------------无条件限制
	HP75 = 1,	------------HP 低于75
	HP50 = 2, -------------HP 低于50
	HP25 = 3,--------------HP 低于25
	SERVANT1 = 4,	---------我方英雄大于1
	ROUND3 = 5 ---------当前回合数为3的倍数
}

--FightData = {
--	cmd = 1,
--	id = 2,
--	camp = 3,
--  partner_id = 4,				// 如果是精灵球大招，会带副将的ID
--	ReleaseSkill ={	 -------------cmd = 1 释放技能 主动
--		skill_id = 1,--------------释放的技能ID
			--Target[1] = {	 ----------- 技能作用对象数组
					--id = 1		 ---------------对象ID
					--camp = 2			 ------------对象阵营
			--},
--	release_num = 3, ------------------释放的次数
--	},
-- SubHp = {						 -------------cmd = 2
--	sub_hp = 1,	 ------------扣血
--	is_crit = 2, ------------是否暴击
--	hit_count = 3 -------------连击
--	effect_type = 4 -----------技能效果
--},
-- AddHp = {	 --------------------cmd = 3
--	add_hp = 1,
--},
-- AddBuff = {	-----------------cmd = 4	添加BUFF 主动或被动
--	buff_id = 1,
--}
--
--RemoveBuff = {	---------------cmd = 5	移除BUFF
--	buff_id = 3,
--},
--BuffChange = {	----------------cmd = 6	BUFF计数次数改变
--	buff_id = 1,
--	buff_count = 2,
--	}
-- PerksSkill = { ----------------cmd = 7 被动技能
--	skill_id = 1,
--	}
-- SubAnger = { ------------------cmd = 8 减怒气
--	sub_anger = 1,
--	cur_anger = 2, -------------------减掉怒气后当前的怒气值
--	}
-- AddAnger = {	 ------------------cmd = 9 加怒气
--	add_anger = 1,
--	cur_anger = 2, ------------------加上怒气后当前的怒气量
--	}
-- ---------------------------------cmd = 10 死亡
-- ----------------------------------cmd = 11 属性改变
-- AttrChange = {
--	attr_type = 1,	------------------属性类型
--	attr_num = 2,	-------------------属性值
--	cur_num = 3,	--------------------属性类型是HP会有这个当前hp
--	}
--	-------------------------------cmd = 12 BUFFBEGIN
-- --------------------------------cmd = 13 SKILLBEGIN
--	-------------------------------cmd = 14 MISS
--	------------------------------cmd = 15 DEBUTHERO
		--BossHp = {	--------------------当一管血量消耗完的事件
			--boss_hp_strip = 1,		 ---------------- BOSS 血条
			--cur_hp = 2,					------------------ BOSS 当前血量
			--base_hp = 3,	------------------------- BOSS 基础HP
		--}
		-------------------------------cmd = 17 EXEUNT 退场
		-------------------------------cmd = 18 HITCOUNTBREAK 连击中断
		-------------------------------cmd = 19 行动停止
		--Step = {
			--num = 1，		----------------------行动停止计数
		--}
		-------------------------------cmd = 20 假的扣血
		-------------------------------cmd = 21 成长BUFF 成长OVER
		--GrowUp = {
		--	buff_id = 1, ------------------哪个BUFF
		--}
		--Absorb = {	--------------------cmd = 22 吸收
		--	num = 1, -----------------------吸收的具体指
		--
		------------------------------------cmd == 23 给我方全员加光环
		--Aura{
		--	aura_id = 1, --------------------光环的ID
		--}
		------------------------------------cmd == 24 是否可以释放大招或令咒
		--CanReleaseSSKill = {
		--	type = 1 --------------------------------- 是否可以释放大招 0 不能释放 1 可以释放
		--	id = 2 ------------------------------------英雄ID
		--	camp = 3 ---------------------------------- 英雄阵营
		--}
		--CareerDamage = {
		--}

	-- PokeballState = {	-----------------cmd = 27	精灵球大招状态
	--	id1 = 1,			// 位置1
	--	id2 = 2,			// 位置2
	--	camp = 3,			// 阵营
	--	state = 4,			// state是1 精灵球大招准备就绪， 0 未准备好
	--}

	-- Combo = {	-----------------cmd = 28	连击
	--	combo = 1,			// 连击数
	--	total_damage = 2,	// 总伤害
	--}
--}
FIGHTCMD = {
  RELEASESKILL = 1,
  SUBHP = 2,
  ADDHP = 3,
  ADDBUFF = 4,
  REMOVEBUFF = 5,
  BUFFCHANGE = 6,
  PERKSSKILL = 7,
  SUBANGER = 8,
  ADDANGER = 9,
  DEATH = 10,
  ATTRCHANGE = 11,
  BUFFBEGIN = 12,
  SKILLBEGIN = 13,
  MISS = 14,
  DEBUTHERO = 15,
  BOSSHP = 16,
  EXEUNT = 17,
  HITCOUNTBREAK = 18,
  STEP = 19,
  FAKESUBHP = 20,
  GROWUP = 21,
  ABSORB = 22,
  AURASKILL = 23,
  CANRELEASESSKILL = 24,
  CAREERDAMAGE = 25,

  TRANSFORM = 26,
  POKEBALLSKILLSTATE = 27,
  COMBO = 28,
}

