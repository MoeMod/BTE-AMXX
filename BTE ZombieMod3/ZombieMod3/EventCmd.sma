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

public CmdFunc_GiveZombieBomb(id)
{
	GiveZombieBomb(id);
	return PLUGIN_HANDLED;
}
/*
public Message_ScoreInfo(msgid, msgdest, id)
{
	if (iBlockScoreInfoID == id)
	{
		iBlockScoreInfoID = -1;
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}*/
public Message_NVGToggle(msgid, msgdest, id)
{
	if (get_msg_arg_int(1))
		SetLight(id, "1");
	else
		SetLight(id, g_light);
}

public Cmd_ChooseTeam(id)
{
	ShowZombieMenu(id, 0);
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

public Cmd_ZombieSkill1(id)
{
	if(!is_user_alive(id)) 
		return PLUGIN_CONTINUE
	
	if(g_zombieclass[id] == g_iZbRevivalID && g_zombie[id]==1 && native_can_use_skill(id))
	{
		ClientPrint(id, HUD_PRINTCENTER, "#CSO_RevivalZombi_IsPassive");
		return PLUGIN_HANDLED
	}
	else if(g_zombieclass[id] == g_iZbTeleportID && g_zombie[id]==1 && native_can_use_skill(id))
	{
		Zb_Teleport_Skill(id)
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public Cmd_ZombieSkill2(id)
{
	if(!is_user_alive(id)) 
		return PLUGIN_CONTINUE
	
	else if ((g_zombieclass[id] == g_iZbRevivalID ||g_zombieclass[id] == g_iZbTeleportID) && g_zombie[id]==1 && native_can_use_skill(id))
	{
		Zb_Skill_HPBuff(id)
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public Cmd_Redirect(id)
{
	client_cmd(id,"weapon_hegrenade")
	return PLUGIN_HANDLED
}

public Cmd_Redirect2(id)
{
	client_cmd(id,"weapon_smokegrenade")
	return PLUGIN_HANDLED
}

public cmd_nightvision(id)
{
	if(!is_user_alive(id)) return PLUGIN_HANDLED
	if(!get_pdata_bool(id, m_bHasNightVision))
		return PLUGIN_HANDLED
	set_pdata_bool(id, m_bNightVisionOn, !get_pdata_bool(id, m_bNightVisionOn));
	Nvg(id);
	//PlaySound(id,g_nvg[id]?SND_NVG[1]:SND_NVG[0])
	emit_sound(id, CHAN_BODY, get_pdata_bool(id, m_bNightVisionOn) ? SND_NVG[1] : SND_NVG[0], 1.0, ATTN_NORM, 0, PITCH_NORM);
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
	if ((g_zombie[victim] && !g_bHeadshotKilled[victim]) || is_user_alive(victim)) return PLUGIN_HANDLED
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

	RemoveNamedEntity(SUPPLYBOX_CLASSNAME)

	g_bRoundTerminating = 1

	g_bInfectionStart = 0

	if (g_startcount && g_bCanEnd)
	{
		new humans = Stock_GetPlayer(0)
		if (humans)
		{
			g_score_human += 1
			PlaySound(0, SND_WIN_HUMAN)
			//MH_DrawTargaImage(0,"mode\\zb3\\humanwin",1,1,255,255,255,0.5,0.35,0,11,5.0)
			BTE_MVPBoard(2, 0);

			for(new i =1;i<33;i++)
				if(!g_zombie[i] && is_user_connected(i)) UpdateFrags(i, 7)
		}
		else
		{
			g_score_zombie += 1
			PlaySound(0, SND_WIN_ZOMBIE)
			//MH_DrawTargaImage(0,"mode\\zb3\\zombiewin",1,1,255,255,255,0.5,0.35,0,11,5.0)
			BTE_MVPBoard(1, 0);

			for(new i =1;i<33;i++)
				if(g_zombie[i] && is_user_connected(i)) UpdateFrags(i, 1)
		}

		g_bCanEnd = 0;
	}
}
public LogEvent_RoundStart()
{
	if(!g_bGameStarted || g_bRoundTerminating)
		return;
//	g_freezetime = 0
	if (g_rount_count)
	{
		new Float:round_time;
		round_time = get_cvar_float("mp_roundtime") * 60.0;

		if (task_exists(TASK_FORCEWIN)) remove_task(TASK_FORCEWIN);
		set_task(round_time,"HumanWin",TASK_FORCEWIN);

		PlaySound(0, SND_ROUND_START);
		//PlaySound(0, SND_COUNT_START);
		//g_count_down = COUNT_DOWN_START
		//Task_CountDown()
		//if (task_exists(TASK_MAKEZOMBIE)) remove_task(TASK_MAKEZOMBIE)
		//set_task(1.0, "Task_CountDown", TASK_MAKEZOMBIE, _, _, "b")

		PlaySound(0, SND_ROUND_START);
		ChooseFirstZombies();

		if (g_rount_count)
		{
			g_count_down = COUNT_DOWN_START;
			Task_CountDown_Chosen(TASK_MAKEZOMBIE);
			set_task(1.0, "Task_CountDown_Chosen", TASK_MAKEZOMBIE, _, _, "b");
		}
	}
}

native BTE_HostOwnBuffAK47();

public Event_HLTV()
{
	/*server_cmd("sv_skycolor_r 135")
	server_cmd("sv_skycolor_g 135")
	server_cmd("sv_skycolor_b 135")*/

//	g_freezetime = 1
//	g_block_check = 0
	g_bRoundTerminating = 0
	g_bInfectionStart = 0
	/*
	if(g_bGameStarted && (Stock_AliveCount() < 2))
	{
		g_bGameStarted = 0;
	}
	*/
	g_supplybox_count = 0
	g_human_morale[0] = 0
	g_levelmax_check = 0

	g_bCanEnd = 0;

	if (g_startcount) g_rount_count += 1

	//new szLight[2]
	//get_pcvar_string(Cvar_Light,szLight,2)
	if (g_startcount)
	{
		for (new id = 1; id < 33; id++)
		{
			if(!is_user_connected(id)) continue

			g_human[id] = 0;
			g_zombie[id] = 0;
			g_human_morale[id] = 0;
			g_readyzombie[id] = 0;

			g_EnteredBuyMenu[id] = 1;

			set_pev(id,pev_gravity,1.0)
			RoundStartValue(id)
			SetLight(id,g_light)
			RenderingHuman(id,1)

			set_task(random_float(0.2,0.5),"Make_Human_Msg",id)
		}
	}

	g_bCanReadyToBeZombies = 0;

	if (BTE_HostOwnBuffAK47())
		g_human_morale[0] = 2;
		//UpdateHumanLevel(0, 2);

	PlayerSpawn(0);

	if (task_exists(TASK_MAKEZOMBIE))
		remove_task(TASK_MAKEZOMBIE);

}
