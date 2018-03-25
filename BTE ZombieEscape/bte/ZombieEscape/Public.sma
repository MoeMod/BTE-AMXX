public Pub_Check_WinCondition()
{
	if(g_end_confirm) return;
	server_cmd("sv_noroundend 0")
	new iZBWin,iHMWin,sTga[64]
	
	if(g_end_zb_ontrain)
	{
		g_end_confirm = 1
		//TerminateRound( RoundEndType_TeamExtermination,TeamWinning_Terrorist );
		server_cmd("sv_restart 6")
		g_score_zb ++
		iZBWin = 1
	}
	if(g_end_hm_escape)
	{
		for(new i=1;i<33;i++)
		{
			if(is_user_alive(i) && !g_zombie[i] && !g_plr_touchtrain[i])
			{
				ExecuteHamB(Ham_Killed,i,i,0)
			}
		}
		g_end_confirm = 1
		//TerminateRound( RoundEndType_TeamExtermination, TeamWinning_Ct );
		g_score_hm ++
		iHMWin = 1
		Stock_PlaySound(0,res_music_end_s)
		server_cmd("sv_restart 6")
	}
	if(g_end_allinfected)
	{
		g_end_confirm = 1
		//TerminateRound( RoundEndType_TeamExtermination,TeamWinning_Terrorist );
		g_score_zb ++
		iZBWin =1
		Stock_PlaySound(0,res_music_end_f)
		server_cmd("sv_restart 6")
	}
	if(iHMWin)
	{
		copy(sTga,63,"mode\\ze\\escapesuccess")
	}
	if(iZBWin)
	{
		copy(sTga,63,"mode\\ze\\escapefail")
	}
	for(new i =1;i<33;i++)
	{
		if(MH_IsMetaHookPlayer(i))
		{
			MH_DrawTargaImage(i,sTga,1,1,255,255,255,0.5,0.3,0,11,5.0)
		}
	}
	if(g_special_button)
	{
		engfunc(EngFunc_RemoveEntity, g_special_button)
		g_special_button =0 
	}		
}
public Pub_Round_Trigger(id)
{
	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "trigger_once"))
	set_pev(iEnt, pev_classname, "wtf")
	DispatchKeyValue(iEnt, "target", g_trigger_start);
	DispatchKeyValue(iEnt, "delay", "0");
	set_pev(iEnt, pev_mins, Float:{-100.0, -100.0, -10.0})
	set_pev(iEnt, pev_maxs, Float:{100.0, 100.0, 10.0})
	new Float:ori[3]
	pev(id,pev_origin,ori)
	set_pev(iEnt,pev_origin,ori)
	DispatchSpawn(iEnt)
}
public Pub_Entity_Setting()
{
	/*static sName[32]
	for(new i=33;i<global_get(glb_maxEntities);i++)
	{
		if(pev_valid(i)) 
		{
			pev(i,pev_classname,sName,31)
			if(equal(sName,"func_button"))
			{
				DispatchKeyValue(i, "wait", "60");
				DispatchSpawn(i)
			}
			else if(equal(sName,"func_rotating"))
			{
				DispatchKeyValue(i, "renderamt", "200");
				DispatchSpawn(i)	
			}
			else if(equal(sName,"func_train"))
			{
				DispatchSpawn(i)				
			}
			else if(equal(sName,"func_wall_toggle"))
			{
				ExecuteHam(Ham_Use,i, 0, 0, 1, 0.0)
				DispatchSpawn(i)
			}
		}
	
	}*/
}
public Pub_Task_Ready()
{
	remove_task(TASK_READY)
	new mess[64]
	format(mess,63,"%L",LANG_PLAYER,"BTE_ZE_WAIT")
	client_print(0,print_center,mess)
	set_task(1.0,"Pub_Task_Ready",TASK_READY)
}
public Pub_Task_Zombie_Count()
{
	g_zombiecount --
	new mess[64]
	format(mess,63,"%L",LANG_PLAYER,"BTE_ZE_TIMEREMAINING",g_zombiecount)
	client_print(0,print_center,mess)
	
	new sSound[64]
	if(g_zombiecount<11)
	{
		format(sSound,63,"bte/ze/%d",g_zombiecount)
		Stock_PlaySound(0,sSound)
		if(g_zombiecount == 1)
		{
			g_count_start = 7
			set_task(1.0,"Pub_Task_Start",TASK_START)
			g_start = 1
		}			
	}
	if(!g_zombiecount) 
	{
		Pub_Zombie_Appear()
		Stock_PlaySound(0,res_music_start)
		remove_task(TASK_ZOMBIE_COUNT)
	}
}
public Pub_Task_Start()
{
	g_count_start --
	if(!g_count_start) return
	new mess[64]
	format(mess,63,"%L",LANG_PLAYER,"BTE_ZE_NOTICE_START")
	MH_DrawCountDown(0,mess,g_count_start)
}
public Pub_Zombie_Appear()
{
	new iInGame
	for(new i =1;i<33;i++)
	{
		if(is_user_connected(i) && is_user_alive(i)) iInGame++
	}
	
	// Get Total Zombie
	if(!iInGame)
	{
		return
	}
	new iZombieNum = iInGame / 10 + 1
	
	// Set Zombie
	new iRan,iCheck
	do
	{
		iCheck = 0
		while (!iCheck)
		{
			iRan = random_num(1, iInGame)
			if (is_user_alive(iRan) && !g_zombie[iRan] ) iCheck = 1
		}
		Pub_Make_Zombie_Origin(iRan)
		Pub_Make_Spawn_Zombie(iRan,1)
		//iZombieNum -- 
	} while (--iZombieNum)
	Pub_Make_Human()
	UpdateScoreBoard()
}
public Pub_Reset_Value()
{
	new reset[33]
	g_zombie = reset
	g_player_lastcount = reset
	g_plr_touchtrain = reset
	g_nvg = reset
	//for(new i=1;i<33;i++)
	//{
		//if(MH_IsMetaHookPlayer(i)) MH_ZombieModNV(i,3)
	//}
	new buttonreset[5]
	g_button = buttonreset
	g_start = 0
	g_end = 0
	g_end_zb_ontrain = 0
	g_end_confirm = 0
	g_end_hm_escape = 0
	g_end_allinfected = 0
	g_touch_train = 0
}
public Pub_Make_Spawn_Zombie(id,iStart)
{
	if(iStart)
	{
		new i
		new sp_index = random_num(0, g_spawn_zombie_total - 1)
		
		for (i = sp_index + 1;;i++)
		{
			if (i >= g_spawn_zombie_total) i = 0
			
			if (Stock_Check_Hull(g_spawn_zombie[i], id))
			{
				engfunc(EngFunc_SetOrigin, id, g_spawn_zombie[i])
				break;
			}
			if (i == sp_index) break;
		}
	}
}

native PlayerSpawn(id);
public Pub_Make_Human()
{
	for(new id= 1;id<33;id++)
	{
		if(is_user_alive(id)&&!g_zombie[id])
		{
			api_cs_set_player_team(id, 2, 1)
			bte_reset_user_model(id)
			set_pev(id,pev_gravity,1.0)
			PlayerSpawn(id);
		}
	}
}

public Pub_Make_Zombie(id)
{
	if (!is_user_alive(id)) return
	g_zombie[id] = 1

	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_BRIGHTLIGHT)
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_NODRAW)
	cs_set_user_zoom(id, CS_RESET_ZOOM, 1)
		
	set_pev(id, pev_armorvalue, 0.0)
	set_pev(id,pev_health,13000.0) // !
		
	Stock_Strip_Weapon(id)
	//cmd_nightvision(id)
	
	bte_wpn_give_named_wpn(id,"knife")
	//bte_wpn_set_playerwpn_model(id,0,"",0,0)
	set_pev(id, pev_weaponmodel2, 0);
	api_cs_set_player_team(id, 1, 1)

	// set model
	cs_set_user_model(id,"tank_zombi_host")
	set_pev(id,pev_gravity,0.8)
	set_pev(id,pev_model,res_model_zb)
	
	if (MH_IsMetaHookPlayer(id))
	{
		MH_PlayBink(id,"infection.bik",0.5,0.5,255,255,255,0,1,1,0)
	}
	

	Stock_Off_FlashLight(id)
	set_pdata_int(id, 491, g_zombie_index, 5);
	emit_sound(id, CHAN_VOICE, res_sound_infection[random_num(0,1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	UpdateScoreBoard()
	//turn_off_nvg(id)
	//if (get_pcvar_num(cvar_nvg_zombie_give)) cmd_nightvision(id)
}

public Pub_Make_Zombie_Origin(id)
{
	if (!is_user_alive(id)) return
	g_zombie[id] = 1

	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_BRIGHTLIGHT)
	set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_NODRAW)
	cs_set_user_zoom(id, CS_RESET_ZOOM, 1)
		
	set_pev(id, pev_armorvalue, 0.0)
	set_pev(id,pev_health,13000.0) // !
		
	Stock_Strip_Weapon(id)
	//cmd_nightvision(id)
	
	bte_wpn_give_named_wpn(id,"knife")
	//bte_wpn_set_playerwpn_model(id,0,"",0,0)
	set_pev(id, pev_weaponmodel2, 0);
	api_cs_set_player_team(id, 1, 1)

	// set model
	cs_set_user_model(id,"tank_zombi_origin")
	set_pev(id,pev_gravity,0.8)
	set_pev(id,pev_model,res_model_zb)
	
	if (MH_IsMetaHookPlayer(id))
	{
		MH_PlayBink(id,"origin.bik",0.5,0.5,255,255,255,0,1,1,0)
	}
	

	Stock_Off_FlashLight(id)
	set_pdata_int(id, 491, g_zombie_index2, 5);
	emit_sound(id, CHAN_VOICE, res_sound_infection[random_num(0,1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	UpdateScoreBoard()
	//turn_off_nvg(id)
	//if (get_pcvar_num(cvar_nvg_zombie_give)) cmd_nightvision(id)
}

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1034\\ f0\\ fs16 \n\\ par }
*/
