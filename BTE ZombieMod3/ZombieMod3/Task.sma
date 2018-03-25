public Task_SetLight(id)
{
	/*new szLight[2]
	get_pcvar_string(Cvar_Light,szLight,2)*/
	SetLight(id,g_light)
}
public Task_InfectedSound(taskid)
{
	InfectedSound()
	if (task_exists(taskid)) remove_task(taskid);
}
InfectedSound()
{
	new sound[64]
	ArrayGetString(sound_zombie_coming, random(ArraySize(sound_zombie_coming)), sound, charsmax(sound))
	PlaySound(0, sound)
}

public Task_UpdateTeam(iTask)
{
	new id = iTask - TASK_UPDATETEAM

	message_begin(/*MSG_BROADCAST*/MSG_ALL, g_msgTeamInfo)
	write_byte(id)
	write_string("TERRORIST")
	message_end()

}

/*public Task_Nvg(taskid)
{
	new id = taskid - TASK_NVISION

	message_begin(MSG_ONE, g_msgScreenFade, _, id)
	write_short((1<<12)*2) // duration
	write_short((1<<10)*10) // hold time
	write_short(0x0004) // fade type
	if(g_zombie[id])
	{
		write_byte(100) // red
		write_byte(0) // green
		write_byte(0) // blue
		write_byte(120) // alpha
	}
	else
	{
		write_byte(0) // red
		write_byte(110) // green
		write_byte(0) // blue
		write_byte(120) // alpha
	}
	message_end()
}*/
public Task_RespawnSupplyBox(taskid)
{
	if (task_exists(TASK_SUPPLYBOX)) remove_task(TASK_SUPPLYBOX)
	set_task(SUPPLYBOX_TIME, "Task_RespawnSupplyBox", TASK_SUPPLYBOX)
	if (g_supplybox_count>=SUPPLYBOX_MAX || !g_bInfectionStart || g_bRoundTerminating)
	{
		return
	}
	new max = random_num(1,SUPPLYBOX_NUM)

	for (new i=1;i<=max;i++) CreateSupplyBox()

	// play sound
	PlaySound(0, SUPPLYBOX_SOUND_DROP)

	// show hudtext
	ClientPrint(0, HUD_PRINTCENTER, "#CSBTE_SupplyBox_Notice");

}
public Task_SetTeam(params[1], taskid)
{
	new id = ID_TEAM
	/*new team = params[0]
	cs_set_user_team(id, team, 0)*/
	if (task_exists(id+TASK_TEAM)) remove_task(id+TASK_TEAM)
}

public Task_ZombieRespawnEffect(taskid)
{
	new id = ID_ZOMBIE_RESPAWN_EF
	if (!g_bInfectionStart || g_bRoundTerminating || !is_user_connected(id) || is_user_alive(id)) return

	EffectZombieRespawn(id)
	if (task_exists(id+TASK_ZOMBIE_RESPAWN_EF)) remove_task(id+TASK_ZOMBIE_RESPAWN_EF)
	//set_task(2.0, "Task_ZombieRespawnEffect", id+TASK_ZOMBIE_RESPAWN_EF)
	return
}

public Task_ZombieRespawn(taskid)
{
	new id = ID_ZOMBIE_RESPAWN
	g_respawn_count[id]--

	if (g_respawn_count[id])
	{
		if (g_respawn_count[id] <= 8)
		{
			new sec[3];
			format(sec, charsmax(sec), "%d", g_respawn_count[id]);
			ClientPrint(id, HUD_PRINTCENTER, "#CSBTE_RespawnWait", sec);
		}
		return PLUGIN_HANDLED
	}

	ClientPrint(id, HUD_PRINTCENTER, "#CSBTE_Respawn");

	ZombieRespawn(id)

	if (task_exists(taskid))
		remove_task(taskid)

	return PLUGIN_CONTINUE
}

public Task_ZombieRespawn2(taskid)
{
	new id = ID_ZOMBIE_RESPAWN
	g_respawn_count[id]--

	if (g_respawn_count[id])
		return PLUGIN_HANDLED

	ClientPrint(id, HUD_PRINTCENTER, "#CSBTE_Respawn");
	ZombieRespawn(id)

	if (task_exists(taskid))
		remove_task(taskid)

	return PLUGIN_CONTINUE
}
