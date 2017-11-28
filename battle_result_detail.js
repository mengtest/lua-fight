{
	// 我方
	our = {
		damage = 100,					// 战斗中造成的总伤害量
		heal = 200,						// 战斗中造成的总治疗量
		hp_percent = 0.5,				// 最后剩余血量比例
		dead_count = 0,					// 死亡数
		team = {						// 队伍存活的信息
			{
				id = 5,					// id
				current_hp = 300,		// 当前血量
				max_hp = 500,			// 最大血量
				current_anger = 3		// 当前怒气
			},
			{
				id = 6,
				current_hp = 300,
				max_hp = 500,
				current_anger = 3
			}
		}
	},
	peer = {
		damage = 100,
		heal = 200,
		hp_percent = 0,
		dead_count = 4,
		team = {}
	}
}