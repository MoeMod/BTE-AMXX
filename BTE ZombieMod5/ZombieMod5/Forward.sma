public Forward_StartFrame()
{
	if (g_flNextCalc > get_gametime()/* && */)
		return;

	g_flNextCalc = get_gametime() + 1.0;

	new Float:origin[33][3];
	new vaild[33];
	//new team[33];

	// 初始是 100%
	/*g_flHumanAttack = 100.0;
	g_flZombieDefence = 100.0;*/

	// 最低加成速度 1%
	//new Float:hm_add = 0.01;
	//new Float:zb_add = 0.02;

	new Float:max = 1.0;

	// 计算最大值 取有效玩家队伍和坐标坐标
	for (new id = 1; id <= 32; id++)
	{
		vaild[id] = FALSE;

		if (!is_user_connected(id))
			continue;

		// 每一个玩家增长 10%
		max += 0.1;

		if (!is_user_alive(id))
			continue;

		/*team[id] = get_pdata_int(id, m_iTeam);*/
		if (get_pdata_int(id, m_iTeam) != TEAM_CT)
			continue;

		vaild[id] = TRUE;
		pev(id, pev_origin, origin[id]);
	}

	// 计算坐标距离 得到攻击力加成增长速度
	new count = 0;
	for (new id = 1; id <= 32; id++)
	{
		if (!vaild[id])
			continue;

		for (new id2 = id + 1; id2 <= 32; id2 ++)
		{
			if (!vaild[id2])
				continue;

			/*if (team[id] == team[id2])
			{*/
			new Float:sub[3];
			xs_vec_sub(origin[id], origin[id2], sub);

			if (xs_vec_len(sub) < 400.0)
				count ++;
			//}
		}
	}

	switch (count)
	{
		case 2..4: g_flHMAdd = 0.02;
		case 5..8: g_flHMAdd = 0.03;
		case 9..12: g_flHMAdd = 0.04;
		case 13..99: g_flHMAdd = 0.06;
	}

	// 增加
	g_flHumanAttack += g_flHMAdd;
	g_flZombieDefence += g_flZBAdd;

	g_flHumanAttack = g_flHumanAttack > (max * 1.3) ? (max * 1.3) : g_flHumanAttack;
	g_flZombieDefence = g_flZombieDefence > max ? max : g_flZombieDefence;


	//PRINT("HMATK: %f ZBDEF: %f HMADD: %f ZBADD: %f", g_flHumanAttack, g_flZombieDefence, g_flHMAdd, g_flZBAdd);
}

public Forward_ClientKill(id)
{
	return FMRES_SUPERCEDE
}
public Forward_SetModel(entity, const model[])
{
	if (strlen(model) < 8) return FMRES_IGNORED
	static attacker
	attacker = pev(entity, pev_owner)
	if (g_zombie[attacker])
	{
		if (model[9] == 'h' && model[10] == 'e')
		{
			new Float:vecVelocity[3]
			vecVelocity[0] = random_float(-300.0, 300.0)
			vecVelocity[1] = random_float(-300.0, 300.0)
			vecVelocity[2] = random_float(-300.0, 300.0)
			set_pev(entity, pev_avelocity, vecVelocity)
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_INFECTION)
			engfunc(EngFunc_SetModel, entity, ZOMBIEBOMB_MODEL_W)
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}
public Forward_Spawn(entity)
{
	if (!pev_valid(entity)) return FMRES_IGNORED;
	new classname[32], objective[32], size = ArraySize(g_objective_ents)
	pev(entity, pev_classname, classname, charsmax(classname))
	for (new i = 0; i < size; i++)
	{
		ArrayGetString(g_objective_ents, i, objective, charsmax(objective))
		if (equal(classname, objective))
		{
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}
public Forward_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	// Block all those unneeeded hostage sounds
	if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
		return FMRES_SUPERCEDE;

	// Replace these next sounds for zombies only
	if (!is_user_connected(id) || !g_zombie[id])
		return FMRES_IGNORED;

	static sound[64]

	// Zombie being hit
	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't' ||
	sample[7] == 'h' && sample[8] == 'e' && sample[9] == 'a' && sample[10] == 'd')
	{
		if (g_level[id]==1) ArrayGetString(zombie_sound_hurt1, g_zombieclass[id], sound, charsmax(sound))
		else ArrayGetString(zombie_sound_hurt2, g_zombieclass[id], sound, charsmax(sound))
		emit_sound(id, channel, sound, volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}

	// Zombie dies
	if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
	{
		if (g_level[id]==1) ArrayGetString(zombie_sound_death1, g_zombieclass[id], sound, charsmax(sound))
		else ArrayGetString(zombie_sound_death2, g_zombieclass[id], sound, charsmax(sound))
		emit_sound(id, channel, sound, volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}
public Forward_PlayerPostThink(id)
{
	if(!g_zombie[id]) return FMRES_IGNORED;
	if(pev(id, pev_deadflag) != DEAD_NO) return FMRES_IGNORED;

	ZombieRestoreHealth(id);

	if (g_flMaxSpeed[id])
	set_pev(id, pev_maxspeed, g_flMaxSpeed[id]);

	return FMRES_IGNORED
}
/*public Forward_CmdStart(id, uc_handle, seed)
{
	if (!is_user_alive(id)) return FMRES_IGNORED
	if(g_zombie[id]) ZombieRestoreHealth(id)

	return FMRES_IGNORED
}*/

/*public bte_wpn_buy_wpn(id,iSlot)
{
    set_task(0.1, "Task_HideMoney", id+TASK_SPAWN)
}*/