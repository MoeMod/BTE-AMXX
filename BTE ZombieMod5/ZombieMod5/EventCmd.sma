/*public Event_CurWeapon(id)
{
	if (!is_user_alive(id) || g_freezetime) return;

	if (g_zombie[id])
	{
		//new Float:maxspeed
		//maxspeed = ArrayGetCell(zombie_speed, g_zombieclass[id])
		set_pev(id, pev_maxspeed, g_maxspeed[id])
	}

	//Hide_Money(id)
}*/
public Message_ScoreInfo(msgid, msgdest, id)
{
	if (iBlockScoreInfoID == id)
	{
		iBlockScoreInfoID = -1;
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}


public Cmd_ChooseTeam(id)
{
	return PLUGIN_HANDLED
}
/*public Cmd_Drop(id)
{
	if(g_hero[id])
	{
		//client_print(id,print_center,"As an hero, You Cannot Drop Weapon!")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}*/
public Cmd_Redirect(id)
{
	client_cmd(id,"weapon_hegrenade")
	return PLUGIN_HANDLED
}
public cmd_nightvision(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(!g_zombie[id] && !g_havenvg[id]) return PLUGIN_HANDLED
	g_nvg[id] = 1 - g_nvg[id]
	if(g_nvg[id])
	{
		//remove_task(id+TASK_NVISION)
		//Task_Nvg(id+TASK_NVISION)
		Nvg(id);
		//set_task(1.0, "Task_Nvg", id+TASK_NVISION, _, _, "b")
	}
	else
	{
		//new szLight[2]
		//get_pcvar_string(Cvar_Light,szLight,2)
		//remove_task(id+TASK_NVISION)
		MH_SendZB3Data(id, 12, 0);
		SetLight(id,g_light)
		message_begin(MSG_ONE, g_msgScreenFade, _, id)
		write_short(0) // duration
		write_short(0) // hold time
		write_short(0x0000) // fade type
		write_byte(100) // red
		write_byte(100) // green
		write_byte(100) // blue
		write_byte(255) // alpha
		message_end()
	}
	PlaySound(id,g_nvg[id]?SND_NVG[1]:SND_NVG[0])
	return PLUGIN_HANDLED
}
public Event_DeathMsg()
{
	//new killer = read_data(1)
	//new victim = read_data(2)
	//new headshot = read_data(3)

	//if(g_zombie[victim]) MH_SendZB3Data(victim,7,1)
	//HumanKilledZombie(killer, victim, headshot)
}
public Message_ClCorpse()
{
	new victim = get_msg_arg_int(12)
	if (g_respawning[victim] || is_user_alive(victim)) return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}
public Message_TeamScore()
{
	static team[2]
	get_msg_arg_string(1, team, charsmax(team))
	switch (team[0])
	{
		case 'C': set_msg_arg_int(2, get_msg_argtype(2), g_score_human)
		case 'T': set_msg_arg_int(2, get_msg_argtype(2), g_score_zombie)
	}
}
public Message_SendAudio()
{
	static audio[17]
	get_msg_arg_string(2, audio, charsmax(audio))
	if(equal(audio[7], "terwin") || equal(audio[7], "ctwin") || equal(audio[7], "rounddraw")) return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}
public Message_TextMsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))
	if (equal(textmsg, "#Game_will_restart_in"))
	{
		g_score_human = 0
		g_score_zombie = 0
		g_startcount = 1
		LogEvent_RoundEnd()
	}
	else if (equal(textmsg, "#Game_Commencing"))
	{
		g_startcount = 1
		server_cmd("mp_autoteambalance 0")
	}
	else if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win"))
	{
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}
public Message_StatusIcon(msgid, msgdest, id)
{
	static szIcon[8];
	get_msg_arg_string(2, szIcon, 7);

	if(equal(szIcon, "buyzone") && get_msg_arg_int(1))
	{
		set_pdata_int(id, 235, get_pdata_int(id, 235) & ~(1<<0));
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

/*public Message_Location(msgid, msgdest, id)
{
	static szIcon[16];
	get_msg_arg_string(2, szIcon, 15);

PRINT("%s",szIcon)

	return PLUGIN_CONTINUE;
} */

native BTE_MVPBoard(iWinningTeam, iType, iPlayer = 0);

public LogEvent_RoundEnd()
{
	if (task_exists(TASK_FORCEWIN)) remove_task(TASK_FORCEWIN);

	g_endround = 1

	g_newround = 0

	new iTeamWin;

	if (g_startcount && g_count_down == -1)
	{
		new humans = Stock_GetPlayer(0)
		if (humans)
		{
			iTeamWin = TEAM_CT;
			g_score_human += 1
			PlaySound(0, SND_WIN_HUMAN)
			//MH_DrawTargaImage(0,"mode\\zb3\\humanwin",1,1,255,255,255,0.5,0.35,0,11,5.0)
			BTE_MVPBoard(2, 0);

			for(new i =1;i<33;i++)
				if(!g_zombie[i] && is_user_connected(i)) UpdateFrags(i, 2)
		}
		else
		{
			iTeamWin = TEAM_TERRORIST;
			g_score_zombie += 1
			PlaySound(0, SND_WIN_ZOMBIE)
			//MH_DrawTargaImage(0,"mode\\zb3\\zombiewin",1,1,255,255,255,0.5,0.35,0,11,5.0)
			BTE_MVPBoard(1, 0);

			for(new i =1;i<33;i++)
				if(g_zombie[i] && is_user_connected(i)) UpdateFrags(i, 1)
		}
	}

	for (new id = 1; id < 33; id++)
	{
		if (!is_user_connected(id))
			continue;

		new account = get_pdata_int(id, m_iAccount);
		if (get_pdata_int(id, m_iTeam) == iTeamWin)
			account -= 3000;
		else
			account -= 1500;

		// 1000 damage = $50
		set_pdata_int(id, m_iAccount, account + floatround(g_flDamageCount[id] * 0.05));
		//SetAccount(id, floatround(g_flDamageCount[id] * 0.05));
	}
}
public LogEvent_RoundStart()
{
	if(!g_bGameStarted || g_endround)
		return;
//	g_freezetime = 0
	if (g_rount_count)
	{
		new Float:round_time;
		round_time = get_cvar_float("mp_roundtime") * 60.0;

		if (task_exists(TASK_FORCEWIN))
			remove_task(TASK_FORCEWIN);

		set_task(round_time,"HumanWin",TASK_FORCEWIN);

		PlaySound(0, SND_ROUND_START);

		g_count_down = COUNT_DOWN_START;
		Task_CountDown()

		if (task_exists(TASK_MAKEZOMBIE))
			remove_task(TASK_MAKEZOMBIE)

		set_task(1.0, "Task_CountDown", TASK_MAKEZOMBIE, _, _, "b");

		new count = 0;

		for (new id = 1; id < 33; id++)
		{
			if (!is_user_connected(id))
				continue;

			count ++;
		}

		if (task_exists(TASK_ROUNDENDBGM))
			remove_task(TASK_ROUNDENDBGM)

		if (count >= 16)
		{
			set_task((4.3 * 60.0 - 43.0), "Task_RoundEngBgm", TASK_ROUNDENDBGM);
			server_cmd("mp_roundtime 4.3");
		}
		else
		{
			set_task((3.3 * 60.0 - 43.0), "Task_RoundEngBgm", TASK_ROUNDENDBGM);
			server_cmd("mp_roundtime 3.3");
		}

	}
}
public Event_HLTV()
{
	RemoveNamedEntity(SUPPLYBOX_CLASSNAME)

//	g_freezetime = 1
//	g_block_check = 0
	g_endround = 0
	g_newround = 0
	g_supplybox_count = 0
	g_levelmax_check = 0

	if (g_startcount) g_rount_count += 1

	//new szLight[2]
	//get_pcvar_string(Cvar_Light,szLight,2)


	if (g_startcount)
	{
		for (new id = 1; id < 33; id++)
		{
			if (!is_user_connected(id))
				continue

			g_human[id] = 0;

			set_pev(id,pev_gravity,1.0)
			RoundStartValue(id)
			SetLight(id, g_light)
			//MH_SendZB3Data(id,7,1)
			//MH_SendZB3Data(id, 8, 1)
			set_task(random_float(0.5,1.0), "Make_Human_Msg", id)
			g_zombie[id] = 0
			g_EnteredBuyMenu[id] = 1;
			//if(!is_user_bot(id)) client_cmd(id, "buy")

			//client_cmd(id,"mp3 stop")
		}
	}

	PlayerSpawn(0);


	//UpdateScoreBoard()

	//server_print("HLTV Round Start.")
}
