stock SendWeaponAnim(id, iAnim)
{
	if (!is_user_alive(id)) return;
	
	set_pev(id, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(iAnim)
	write_byte(pev(id, pev_body))
	message_end()
}

stock TextMsg(id, type, message[], str1[] = "", str2[] = "", str3[] = "", str4[] = "")
{
	new dest
	if (id) dest = MSG_ONE
	else dest = MSG_ALL
	
	message_begin(dest, g_msgTextMsg, {0,0,0}, id)
	write_byte(type)
	write_string(message)
	
	if (str1[0])
		write_string(str1)
	if (str2[0])
		write_string(str2)
	if (str3[0])
		write_string(str3)
	if (str4[0])
		write_string(str4)
		
	message_end()
}

stock PlayEmitSound(id, type, const sound[])
{
	emit_sound(id, type, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

stock PlaySound(id, const sound[])
{
	if (equal(sound[strlen(sound)-4], ".mp3"))
	{
		client_cmd(id,"mp3 stop")
		client_cmd(id, "mp3 play sound/%s", sound)
	}
	else
		client_cmd(id, "spk ^"%s^"", sound)
}

stock SetSkyColor(Float:x = 1.0)
{
	set_cvar_float("sv_skycolor_r", g_iSkyColor[0] * x);
	set_cvar_float("sv_skycolor_g", g_iSkyColor[1] * x);
	set_cvar_float("sv_skycolor_b", g_iSkyColor[2] * x);
}

stock SendDeathMsg(attacker, victim)
{
	message_begin(MSG_BROADCAST, g_msgDeathMsg)
	write_byte(attacker) 
	write_byte(victim) 
	write_byte(0) 
	write_string("knife")
	message_end()
}

stock FixDeadAttrib(id)
{
	message_begin(MSG_BROADCAST, g_msgScoreAttrib)
	write_byte(id) // id
	write_byte(0) // attrib
	message_end()
}

stock UpdateFrags(player, num, sendmsg = 0)
{
	if (!is_user_connected(player))
		return;
	
	set_pev(player, pev_frags, float(pev(player, pev_frags) + num))
	
	if (!sendmsg)
		return;
	
	message_begin(MSG_BROADCAST, g_msgScoreInfo)
	write_byte(player) // id
	write_short(pev(player, pev_frags)) // frags
	write_short(get_pdata_int(player, m_iDeaths)) // deaths
	write_short(0) // class?
	write_short(get_pdata_int(player, m_iTeam)) // team
	message_end()
}

stock StripWeapons(id)
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
	if (!pev_valid(ent)) return;
	
	dllfunc(DLLFunc_Spawn, ent)

	dllfunc(DLLFunc_Use, ent, id)
	if (pev_valid(ent)) engfunc(EngFunc_RemoveEntity, ent)
}

stock SetRendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)
	
	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
}

stock CountPlayer(iCountZombies = 0)
{
	new iNum;
	for(new i=1;i<33;i++)
	{
		if (is_user_alive(i))
		{
			if (iCountZombies && g_iZombie[i])
				iNum++;
			else if (!iCountZombies && !g_iZombie[i])
				iNum++;
		}
	}
	return iNum;
}

stock CheckRespawning()
{
	new iNum = 0;
	for(new i=1;i<33;i++)
	{
		if (g_iRespawning[i]) iNum++;
	}
	return iNum;
}

stock CreateFog()
{
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
	if (pev_valid(ent))
	{
		Set_Kvd(ent, "density", "0.001", "env_fog")
		Set_Kvd(ent, "rendercolor", "0 0 0", "env_fog")
	}
}

stock SetLight(id, light[], skipzombie = 0)
{
	if (!id)
	{
		if (!skipzombie)
		{
			message_begin(MSG_ALL, SVC_LIGHTSTYLE, _, id)
			write_byte(0)
			write_string(light)
			message_end()
		}
		else
		for(new id=0;id<32;id++)
		{
			if (!is_user_connected(id) || (g_iZombie[id] && skipzombie)) continue
		
			message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, id)
			write_byte(0)
			write_string(light)
			message_end()
		}
		return
	}
	
	message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, id)
	write_byte(0)
	write_string(light)
	message_end()

}

stock SetTeam(id, team)
{
	if (is_user_connected(id))
	{
		if (get_pdata_int(id, m_iTeam) == team) return
		
		if (task_exists(id+TASK_TEAM))
			remove_task(id+TASK_TEAM)
		
		set_task(0.1, "Task_UpdateTeam", id+TASK_TEAM)
		
		set_pdata_int(id, m_iTeam, team)
	}

}

public Task_UpdateTeam(taskid)
{
	new id = taskid - TASK_TEAM

	message_begin(/*MSG_BROADCAST*/MSG_ALL, g_msgTeamInfo)
	write_byte(id)
	write_string("TERRORIST")
	message_end()
	
}

