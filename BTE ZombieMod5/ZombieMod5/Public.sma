new iInGame
new bHeroCheck;
new g_pGameRules;

public OrpheuHookReturn:OnInstallGameRules()
{
	g_pGameRules = OrpheuGetReturn();
	
	OrpheuRegisterHook(OrpheuGetFunctionFromObject(g_pGameRules, "CheckWinConditions", "CGameRules"), "OnCheckWinConditions")
	OrpheuRegisterHook(OrpheuGetFunctionFromObject(g_pGameRules, "FPlayerCanRespawn", "CGameRules"), "OnFPlayerCanRespawn")
}

public OrpheuHookReturn:OnCheckWinConditions(this)
{
	CheckWinCondition();
	
	return OrpheuSupercede;
}

public CheckWinCondition()
{
	if(!g_bGameStarted)
	{
		if(Stock_PlayerCount() >= 2)
		{
			g_bGameStarted = 1;
			//TerminateRound( RoundEndType_Draw,TeamWinning_None );
			server_cmd("sv_restart 1");
		}
	}
	else
	{
		if (Stock_GetPlayer(0) == 0)
		{
			TerminateRound( RoundEndType_TeamExtermination,TeamWinning_Terrorist )
		}
		else if (!CheckRespawning() && !Stock_GetPlayer(1))
		{
			TerminateRound( RoundEndType_TeamExtermination,TeamWinning_Ct )
		}
	}
}

public OrpheuHookReturn:OnFPlayerCanRespawn(this, id)
{
	if (g_newround || g_endround)
		OrpheuSetReturn(false)
	else
		OrpheuSetReturn(true)
	return OrpheuSupercede
}

public HumanWin()
{
	TerminateRound( RoundEndType_TeamExtermination,TeamWinning_Ct );
}

public ZombieBombExplosion(ent)
{
	if (!g_newround || g_endround) return
	static Float:originF[3]
	pev(ent, pev_origin, originF)

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord,originF[0])
	engfunc(EngFunc_WriteCoord,originF[1])
	engfunc(EngFunc_WriteCoord,originF[2])
	write_short(cache_spr_zombiebomb_exp)
	write_byte(40)
	write_byte(30)
	write_byte(14)
	message_end()

	engfunc(EngFunc_EmitSound, ent, CHAN_WEAPON, ZOMBIEBOM_SOUND_EXP, 1.0, ATTN_NORM, 0, PITCH_NORM)
	new victim = -1;
	new attacker = pev(ent, pev_owner);

	new Float:vecOrigin[3], Float:flDistance, Float:flMulti

	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, ZOMBIEBOM_RADIUS)) != 0)
	{
		if (!is_user_alive(victim)) continue
		ScreenShake(victim)
		pev(victim, pev_origin, vecOrigin)
		flDistance = get_distance_f(vecOrigin, originF)
		flMulti = ZOMBIEBOM_POWER - floatmul(ZOMBIEBOM_POWER, floatdiv(flDistance, ZOMBIEBOM_RADIUS))//get the damage value
		flMulti *= EstimateDamage(originF, victim, 0)
		if ( flMulti < 0 ) continue
		CreateBombKnockBack(victim, originF, flMulti, ZOMBIEBOM_POWER);

		ExecuteHamB(Ham_TakeDamage, victim, 0, attacker, (flMulti / ZOMBIEBOM_POWER) * 120.0, (1<<24));
	}
	set_pev(ent, pev_effects, EF_NODRAW);
	set_pev(ent, pev_flags, pev(ent, pev_flags) | FL_KILLME);
}

public Make_Zombie(id, iSetHeath)
{
	if (!is_user_alive(id))
		return

	StripWeapons(id);

	g_hero[id] = 0
	g_zombie[id] = 1

	new Float:gravity, Float:speed, Float:xdamage, Float:xdamage2, Float:fKb
	gravity = ArrayGetCell(zombie_gravity, g_zombieclass[id])
	speed = ArrayGetCell(zombie_speed, g_zombieclass[id])
	xdamage = ArrayGetCell(zombie_xdamage, g_zombieclass[id])
	xdamage2 = ArrayGetCell(zombie_xdamage2, g_zombieclass[id])
	fKb = ArrayGetCell(zombie_knockback, g_zombieclass[id])
	g_zombie_xdamage[id][0] = xdamage
	g_zombie_xdamage[id][1] = xdamage2
	g_zombie_xdamage[id][2] = xdamage2
	g_fNextRestoreHealth[id] = get_gametime() + RESTORE_HEALTH_TIME;
	bte_wpn_set_knockback(id, fKb);
	g_flMaxSpeed[id] = speed;
	set_pev(id, pev_gravity, gravity);

	bte_wpn_give_named_wpn(id, "knife", 0)
	GiveZombieBomb(id)
	//bte_wpn_set_playerwpn_model(id,0,"",0,0)

	set_pdata_float(id, m_flNextAttack, 1.0);

	if (get_pcvar_num(Cvar_HolsterBomb))
		client_cmd(id,"weapon_knife")

	if (iSetHeath)
		UpdateHealthZombie(id);

	SetPlayerModel(id)
	SetZombieViewModel(id)
	// nvg
	g_nvg[id] = 1
	Nvg(id)
	//CheckEvolution(id)
	UpdateScoreBoard()

	//ExecuteForward(g_fwUserInfected, g_fwDummyResult, id, 0)
}

public Make_Zombie2(id, Float:health)
{
	if (!is_user_alive(id)) return

	//server_print("Make Zombie %d",id)

	/*StripSlot(id, 1)
	StripSlot(id, 2)*/
	StripWeapons(id/*, 0*/)

	g_human[id] = 0
	g_hero[id] = 0
	g_zombie[id] = 1
	g_level[id] = 2

	//SetTeam(id, 1)

	set_pdata_int(id, 114, 1);

	remove_task(id + TASK_UPDATETEAM)
	set_task(0.1, "Task_UpdateTeam", id + TASK_UPDATETEAM)


	//PRINT("Set id:%d team:%d",id,get_pdata_int(id, 114));
	new Float:gravity, Float:speed, Float:xdamage, Float:xdamage2, Float:fKb
	gravity = ArrayGetCell(zombie_gravity, g_zombieclass[id])
	speed = ArrayGetCell(zombie_speed, g_zombieclass[id])
	xdamage = ArrayGetCell(zombie_xdamage, g_zombieclass[id])
	xdamage2 = ArrayGetCell(zombie_xdamage2, g_zombieclass[id])
	fKb = ArrayGetCell(zombie_knockback, g_zombieclass[id])
	g_zombie_xdamage[id][0] = xdamage
	g_zombie_xdamage[id][1] = xdamage2
	g_zombie_xdamage[id][2] = xdamage2
	g_fNextRestoreHealth[id] = get_gametime() + RESTORE_HEALTH_TIME;
	g_flMaxSpeed[id] = speed;
	set_pev(id, pev_gravity, gravity)
	bte_wpn_set_knockback(id, fKb);

	g_zombie_health_start[id] = floatround(health)
	g_zombie_armor_start[id] = 1000;

	set_pev(id, pev_max_health, health);
	set_pev(id, pev_health, health);
	set_pev(id, pev_armorvalue, 1000.0);


	GiveZombieBomb(id)
	//Message_HudTextPro(id, "ZombiSelected")

	bte_wpn_give_named_wpn(id,"knife",1)
	//bte_wpn_set_playerwpn_model(id,0,"",0,0)

	if (get_pcvar_num(Cvar_HolsterBomb))
		client_cmd(id,"weapon_knife")

	set_pdata_float(id, m_flNextAttack, 1.0);

	SetPlayerModel(id)
	SetZombieViewModel(id)
	g_nvg[id]=1
	Nvg(id)
	//CheckEvolution(id)
	UpdateScoreBoard()

	//MH_PlayBink(id,"origin.bik", 0.5, 0.5, 255, 255, 255, 0, 1, 1, 0);

	MetahookMsg(id, 40);

	//server_print("Make Zombie finished.")
}

public Make_Hero(id)
{
	if (!is_user_alive(id))
		return;

	g_hero[id] = 1;

	UTIL_TutorText(id, "#CSBTE_Totur_ZB5_Hero", 1 << 0, 3.0);

	set_pev(id, pev_health, 2500.0);
	set_pev(id, pev_max_health, 2500.0);
	set_pev(id, pev_armorvalue, 500.0);

#if 0
	//server_print("Make Hero %d",id)

	g_zombie[id] = 0

	//SetTeam(id, 2)
	/*set_pev(id,pev_health,1000.0)
	set_pev(id,pev_max_health,1000.0)
	set_pev(id,pev_armorvalue,100.0)*/
	//set_pev(id, pev_gravity, HERO_GRAVITY)
	g_nvg[id]=0
	g_havenvg[id] = 0

	new sex = bte_get_user_sex(id)

	new notdrop = 0

	if(sex==1)
	{
		bte_wpn_give_named_wpn(id,"svdex",notdrop)
		bte_wpn_give_named_wpn(id,"ddeagle",notdrop)
		MH_DrawTargaImage(id,"mode\\zb3\\hero",1,1,255,255,255,0.5,0.3,3,11,5.0)
	}
	else
	{
		bte_wpn_give_named_wpn(id,"qbarrel",notdrop)
		bte_wpn_give_named_wpn(id,"ddeagle",notdrop)
		MH_DrawTargaImage(id,"mode\\zb3\\heroine",1,1,255,255,255,0.5,0.3,3,11,5.0)
	}
	// !TODO TGA

	//
	message_begin(MSG_BROADCAST, g_msgScoreAttrib)
	write_byte(id) // id
	write_byte(1<<3) // attrib
	message_end()


	//server_print("Make Hero finished.")

	g_hero[id] = 1
	SetPlayerModel(id)
#endif

}

native PlayerSpawn(id);
public Make_Human(id)
{
	g_zombie[id] = 0
	g_hero[id] = 0
	g_human[id] = 1

	set_pev(id, pev_health, 1000.0)
	set_pev(id, pev_max_health, 1000.0)
	set_pev(id, pev_armorvalue, 100.0)

	// fix some bugs
	if (!g_newround)
	{
		/*if(bte_fun_get_have_mode_item(id,1)) set_pev(id, pev_gravity, 0.8);
		else set_pev(id, pev_gravity, 1.0);*/
		set_pev(id, pev_gravity, 0.8);
	}

	g_nvg[id] = 0
	g_havenvg[id] = 1

	//server_print("Make Human finished.")
	
	if (!g_EnteredBuyMenu[id])
		PlayerSpawn(id);
}

public Make_Human_Msg(id)
{
	if (!is_user_alive(id))
		return
}

public Make_First_Zombie()
{
	bHeroCheck = FALSE;

	// 初始是 100%
	g_flHumanAttack = 1.0;
	g_flZombieDefence = 1.0;
	g_flNextCalc = get_gametime() + 1.0;

	// 最低加成速度 1%
	g_flHMAdd = 0.01;
	g_flZBAdd = 0.01;

	PlaySound(0, SND_BGM)

	iInGame = 0

	for (new i = 1; i < 33; i++)
		if (is_user_connected(i) && is_user_alive(i)) iInGame++

	if (!iInGame)
	{
		//PRINT("NO INGAME PLAYERS!")
		return
	}

	new iZombieNum = floatround(iInGame * 0.25);

	/*// 母体 HPAP 5000~7500/1000
	new Float:fMaxHealth;
	fMaxHealth = 5000.0 + 2500.0 * float(iInGame) / 32.0;
	fMaxHealth = 100.0 * floatround(fMaxHealth / 100.0);*/

	new Float:fMaxHealth = 3500.0;

	//iZombieNum = 1;

	new iRan
	do
	{
		//iRan = 2;
		iRan = GetRandomPlayer(2);
		if (!iRan)
		{
			//PRINT("返回错误")
			return
		}
		// Set Info
		g_level[iRan] = 2

		if (!g_zombieclass[iRan] || is_user_bot(iRan))
			g_zombieclass[iRan] = random(class_count)

		PlayInfectedSound(iRan);

		Make_Zombie2(iRan, fMaxHealth);
		ExecuteForward(g_fwUserInfected, g_fwDummyResult, iRan, 33);
		SetRendering(iRan)
		ShowZombieMenu(iRan)

	} while (--iZombieNum)

	InfectedSound();

#if 0
	if(random_num(0, 9) > 6)
	{
		new szHeroMsg[128];

		new iZombieNum = 1;
		iZombieNum += random_num(0, iInGame / 10);
		iZombieNum += random_num(0, iInGame / 10 - 1);

		new iRan
		do
		{
			iRan = GetRandomPlayer(2)
			if(!iRan)
				return

			if(!g_hero[iRan]) Make_Hero(iRan)

		} while (--iZombieNum)


		new name[32]
		new iTotalHero = 0;
		new iSendMsg = 0;

		for (new id = 1; id <33; id++)
		{
			if (g_hero[id])
				iTotalHero += 1;
		}

		for (new id = 1; id <33; id++)
		{
			if (g_hero[id])
			{
				iTotalHero --
				get_user_name(id,name,31)
				format(szHeroMsg,127,"%s%s%s",szHeroMsg,name,iTotalHero?"，":"")
				iSendMsg = 1;
			}
		}
		format(szHeroMsg,127,"%L",LANG_PLAYER,"BTE_ZB3_HEROINFO",szHeroMsg)
		if(iSendMsg) client_print(0,print_center,szHeroMsg)
	}
#endif



	g_newround = 1

	// 如果有新加入玩家
	for (new id = 1; id <33; id++)
	{
		if (is_user_connected(id) && !g_zombie[id] && !g_hero[id] && !g_human[id])
			Make_Human(id)
	}

	if (task_exists(TASK_SUPPLYBOX))
		remove_task(TASK_SUPPLYBOX)

	set_task(SUPPLYBOX_TIME_FIRST, "Task_RespawnSupplyBox", TASK_SUPPLYBOX)

	if (task_exists(TASK_MAKEZOMBIE))
		remove_task(TASK_MAKEZOMBIE)
}

public PlayerRandomSpawn(id)
{
	static hull, sp_index, i
	hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN

	if (!g_spawnCount) return
	sp_index = random_num(0, g_spawnCount - 1)
	for (i = sp_index + 1;; i++)
	{
		if (i >= g_spawnCount) i = 0

		if (CheckHull(g_spawns[i][0], hull))
		{
			engfunc(EngFunc_SetOrigin, id, g_spawns[i][0])
			set_pev(id, pev_angles, g_spawns[i][1])
			set_pev(id, pev_v_angle, g_spawns[i][2])
			break
		}
		if (i == sp_index) break
	}
}

public SupplyBoxRandomSpawn(id)
{
	static hull, sp_index, i
	hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN

	if (!g_spawnCount_box) return
	sp_index = random_num(0, g_spawnCount_box - 1)
	for (i = sp_index + 1;; i++)
	{
		if (i >= g_spawnCount_box) i = 0
		if (CheckHull(g_spawns_box[i], hull))
		{
			engfunc(EngFunc_SetOrigin, id, g_spawns_box[i])
			break;
		}
		if (i == sp_index) break;
	}
}

public ZombieInfectedHuman(attacker, victim)
{
	g_flZombieDefence += 0.05;

	SetAccount(attacker, 500);

	// show Msg Death
	SendDeathMsg(attacker, victim)
	FixDeadAttrib(victim)

	UpdateFrags(attacker, 1)
	UpdateDeaths(victim, 1)

	UpdateEvolution(attacker, 2);

	g_evolution[victim] = 0;
	g_level[victim] = 1;

	// 次体 HPAP  2000~4000/500
	new MaxHealth = 2000;
	/*MaxHealth = 2000 + floatround(2000.0 * iInGame / 32.0);
	MaxHealth = 100 * floatround(MaxHealth / 100.0);*/

	g_zombie_health_start[victim] = MaxHealth;
	g_zombie_armor_start[victim] = 500;

	set_pdata_int(victim, m_iTeam, TEAM_TERRORIST);

	// 延迟发送更换队伍消息
	remove_task(victim + TASK_UPDATETEAM)
	set_task(0.1, "Task_UpdateTeam", victim + TASK_UPDATETEAM)

	if (!g_zombieclass[victim] || is_user_bot(victim))
		g_zombieclass[victim] = random(class_count);

	Make_Zombie(victim, 1);
	g_level[victim] = 1;

	//set_pdata_int(victim, 388, 2); // grenade ammo

	SetRendering(victim);
	PlayInfectedSound(victim);

	ExecuteForward(g_fwUserInfected, g_fwDummyResult, victim, attacker)
	ShowZombieMenu(victim)
	InfectedSound()
	//MH_SendZB3Data(attacker,3,g_evolution[attacker])

	//MH_PlayBink(victim,"infection.bik",0.5,0.5,255,255,255,0,1,1,0)
	MetahookMsg(victim, 41);

	CheckHero();
}

public HumanKilledZombie(killer, victim)
{
	if (!g_zombie[victim])
		return

	g_flZombieDefence += 0.05;

	// 游戏会 +300
	if (g_level[victim] == 2)
		SetAccount(killer, 200 - 300);
	else
		SetAccount(killer, 400 - 300);

	g_respawning[victim] = 1;

	if (task_exists(victim + TASK_ZOMBIE_RESPAWN))
		remove_task(victim + TASK_ZOMBIE_RESPAWN);

	// 僵尸复活等待时间：5~8秒
	new respawn_wait = random_num(5, 8);
	g_respawn_count[victim] = respawn_wait + 2;
	set_task(1.0, "Task_ZombieRespawn", victim + TASK_ZOMBIE_RESPAWN, "", 0, "a", respawn_wait + 2);

	if (task_exists(victim + TASK_ZOMBIE_RESPAWN_EF))
		remove_task(victim + TASK_ZOMBIE_RESPAWN_EF);

	set_task(0.5, "Task_ZombieRespawnEffect", victim + TASK_ZOMBIE_RESPAWN_EF);

	// 僵尸复活后不会减少生命值，但会失去部分防弹衣
	g_zombie_armor_start[victim] -= 500;
	g_zombie_armor_start[victim] = g_zombie_armor_start[victim] < 0 ? 0 : g_zombie_armor_start[victim];

}

public ZombieRespawn(id)
{
	if (!g_newround || g_endround || !is_user_connected(id)) return

	g_respawning[id] = 0
	if (is_user_connected(id))
		ExecuteHamB(Ham_CS_RoundRespawn, id)

	//Strip_Weapon(id)
	UpdateEvolution(id, 1);
	Make_Zombie(id, 1);
	ExecuteForward(g_fwUserInfected, g_fwDummyResult, id, 0)

	new sound[64]
	ArrayGetString(sound_zombie_comeback, random(ArraySize(sound_zombie_comeback)), sound, charsmax(sound))
	//PlayEmitSound(id, CHAN_VOICE, sound)
	PlaySound(0, sound);
	ExecuteForward(g_fwUserInfected, g_fwDummyResult, id, 0)

	new Float:gravity, Float:speed
	gravity = ArrayGetCell(zombie_gravity, g_zombieclass[id])
	speed = ArrayGetCell(zombie_speed, g_zombieclass[id])
	g_flMaxSpeed[id] = speed;
	set_pev(id, pev_gravity, gravity)

	SetPlayerModel(id);

	//SetTeam(id, 1);
	return
}

public CheckRespawning()
{
	for (new i = 1;i<33;i++)
	{
		if (is_user_connected(i) && g_zombie[i] && g_respawning[i]) return 1
	}
	return 0
}

public CheckHero()
{
	if (bHeroCheck)
		return;

	new human = 0;

	for (new id = 1; id < 33; id++)
	{
		if (!is_user_connected(id))
			continue;

		new team = get_pdata_int(id, m_iTeam);

		if (team == TEAM_UNASSIGNED || team == TEAM_SPECTATOR)
			continue;

		if (team == TEAM_CT)
			human ++;
	}

	if (human <= iInGame * 0.2)
	{
		for (new id = 1; id < 33; id++)
		{
			if (!g_zombie[id])
				Make_Hero(id);
		}

		bHeroCheck = TRUE;
	}
}