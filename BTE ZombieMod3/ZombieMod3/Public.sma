native MH_SendZB3Data(id,iDataType,iData) // 内部API

public OrpheuHookReturn:OnInstallGameRules()
{
	g_pGameRules = OrpheuGetReturn();
	
	OrpheuRegisterHook(OrpheuGetFunctionFromObject(g_pGameRules, "CheckWinConditions", "CGameRules"), "OnCheckWinConditions")
	OrpheuRegisterHook(OrpheuGetFunctionFromObject(g_pGameRules, "FPlayerCanRespawn", "CGameRules"), "OnFPlayerCanRespawn")
}

public OrpheuHookReturn:OnCheckWinConditions(this)
{
	CheckWinConditions();
	
	return OrpheuSupercede;
}

public CheckWinConditions()
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
	if (g_bInfectionStart || g_bRoundTerminating)
		OrpheuSetReturn(false)
	else
		OrpheuSetReturn(true)
	return OrpheuSupercede
}

public OrpheuHookReturn:OnRadio_Pre(id, const msg_id[], const msg_verbose[], pitch, showIcon)
{
	if(!is_user_alive(id))
		return OrpheuIgnored
	if(!g_zombie[id])
		return OrpheuIgnored
	if(!strcmp(msg_id, "%!MRAD_FIREINHOLE"))
	{
		return OrpheuSupercede
	}
	return OrpheuIgnored
}

public HumanWin()
{
	TerminateRound( RoundEndType_TeamExtermination,TeamWinning_Ct );
}

public GiveZombieBomb(id)
{
	if(!g_zombie[id]) return
	bte_wpn_give_named_wpn(id,"hegrenade",0)
	fm_give_item(id,"weapon_smokegrenade")

	message_begin(MSG_ONE,g_msgWeaponList, {0,0,0}, id);
	write_string("weapon_zombibomb")
	write_byte(WEAPON_AMMOID[CSW_HEGRENADE])
	write_byte(1)
	write_byte(-1)
	write_byte(-1)
	write_byte(3)
	write_byte(CSWPN_POSITION[CSW_HEGRENADE])
	write_byte(CSW_HEGRENADE)
	write_byte(24)
	message_end()
	
	message_begin(MSG_ONE,g_msgWeaponList, {0,0,0}, id);
	write_string("weapon_zombibomb2")
	write_byte(WEAPON_AMMOID[CSW_SMOKEGRENADE])
	write_byte(1)
	write_byte(-1)
	write_byte(-1)
	write_byte(3)
	write_byte(CSWPN_POSITION[CSW_SMOKEGRENADE])
	write_byte(CSW_SMOKEGRENADE)
	write_byte(24)
	message_end()
}

public ZombieBombExplosion(ent, bGreen)
{
	//new iType = pev(ent, PEV_NADE_TYPE)
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

	originF[2] -= 20.0;

	new pevAttacker = pev(ent, pev_owner);

	for (new pEntity = 1; pEntity <= 32; pEntity ++)
	{
		if (!is_user_connected(pEntity))
			continue;
		if (!is_user_alive(pEntity))
			continue;
		ZombieBombKnockback(pEntity, originF, ent, pevAttacker, bGreen);
	}
	set_pev(ent, pev_effects, EF_NODRAW);
	set_pev(ent, pev_flags, pev(ent, pev_flags) | FL_KILLME);
}
/*
ZombieBomb_Explode(iEntity)
{
	static iType; iType = pev(iEntity, PEV_NADETYPE)
	static iAttacker; iAttacker = pev(iEntity, pev_owner)
	new Float:vecOrigin[3]
	pev(iEntity, pev_origin, vecOrigin)
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + 5.0)
	write_short(g_iZombieBombExplo)
	write_byte(30) // 35
	write_byte(120) // 186
	message_end()
	engfunc(EngFunc_EmitSound, iEntity, CHAN_BODY, SOUND_ZOMBIEBOMB[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	static Float:flPower;
	switch(iType)
	{
		case NADE_TYPE_ZOMBIEBOMB: flPower = 200.0
		case NADE_TYPE_ZOMBIEBOMB2: flPower = 75.0
	}
	for (new id = 1; id < 33; id ++)
	{
		if (!IsConnected(id))
			continue
		if (!IsAlive(id))
			continue
		new Float:vecVictimOrigin[3]
		pev(id, pev_origin, vecVictimOrigin)
		new Float:flDistance = get_distance_f(vecOrigin, vecVictimOrigin)
		if (flDistance > 150.0)
			continue
		new Float:vecOldVelocity[3], Float:vecNewVelocity[3]
		pev(id, pev_velocity, vecOldVelocity)
		
		GetVelocityFromOrigin(vecVictimOrigin, vecOrigin, BitsGet(g_bitsIsZombie, id) ? flPower : flPower * 2.0, vecNewVelocity)
		vecNewVelocity[2] = (pev(id, pev_flags) & FL_ONGROUND) && (iType == NADE_TYPE_ZOMBIEBOMB2) ? 450.0 : 200.0
		xs_vec_add(vecOldVelocity, vecNewVelocity, vecNewVelocity)
		set_pev(id, pev_velocity, vecNewVelocity)
		message_begin(MSG_ONE, get_user_msgid("ScreenShake"), _, id)
		write_short((1<<12) * 5)
		write_short((1<<12) * 2)
		write_short((1<<12) * 5)
		message_end()
		g_flLastDamageTime[id][iAttacker] = get_gametime()
	}
	set_pev(ent, pev_effects, EF_NODRAW);
	set_pev(ent, pev_flags, pev(ent, pev_flags) | FL_KILLME);
	
}
*/

public ZombieBombKnockback(pEntity, Float:vecSrc[3], pevInflictor, pevAttacker, bGreen)
{
	new Float:vecOrigin[3], Float:vecVelocity[3], Float:vecVelocityAdd[3];
	pev(pEntity, pev_origin, vecOrigin);
	pev(pEntity, pev_velocity, vecVelocity);
	new Float:xSub = vecOrigin[0] - vecSrc[0], Float:ySub = vecOrigin[1] - vecSrc[1], Float:zSub = vecOrigin[2] - vecSrc[2];
	new Float:fTemp = xSub * xSub + ySub * ySub + zSub * zSub;
	
	if (fTemp > 250.0 * 250.0)
		return;

	new Float:fLength = 1.0 / floatsqroot(fTemp);

	xSub *= fLength;
	ySub *= fLength;
	zSub *= fLength;

	new Float:flDamage = (250.0 - 1.0 / fLength) / 250.0;
	new Float:flMul = flDamage;

	if (flDamage < 0.0)
		flDamage = flMul = 0.0;

	ExecuteHamB(Ham_TakeDamage, pEntity, pevInflictor, pEntity == pevAttacker ? 0 : pevAttacker, 0.0, DMG_BLAST);
	new Float:flHealth, Float:flArmor;
	pev(pEntity, pev_health, flHealth);
	pev(pEntity, pev_armorvalue, flArmor);

	if (flArmor > 0.0)
	{
		flArmor -= 1.0;
		set_pev(pEntity, pev_armorvalue, flArmor);
	}
	else if (flHealth)
	{
		flHealth -= 1.0;
		set_pev(pEntity, pev_health, flHealth);
		if (flHealth <= 0.0)
		{
			ExecuteHamB(Ham_Killed, pEntity, 0);
		}
	}

	new Float:flScale = random_num(0, 10) / 10.0 + 1.5;
	flScale *= bGreen ? 500.0:350.0;

	if (flScale * flMul <= 420.0)	// 350 * 1.2
	{
		flScale = 420.0;
		flMul = 1.0;
	}

	vecVelocityAdd[0] = xSub * flScale * flMul;
	vecVelocityAdd[1] = ySub * flScale * flMul;
	vecVelocityAdd[2] = zSub * flScale * flMul;
	if (pev(pEntity, pev_flags) & FL_ONGROUND)
	{
		if (pev(pEntity, pev_flags) & FL_DUCKING)
		{
			vecVelocityAdd[0] *= 0.8;
			vecVelocityAdd[1] *= 0.8;
			vecVelocityAdd[2] *= 0.8;
		}
	}
	else
	{
		vecVelocityAdd[0] *= 0.9;
		vecVelocityAdd[1] *= 0.9;
		vecVelocityAdd[2] *= 0.9;
	}

	vecVelocity[0] += vecVelocityAdd[0];
	vecVelocity[1] += vecVelocityAdd[1];
	vecVelocity[2] += vecVelocityAdd[2];

	vecVelocity[2] *= bGreen ? flMul:(flMul * 0.75);

	set_pev(pEntity, pev_velocity, vecVelocity);

	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, pEntity);
	write_short((1<<12));
	write_short((1<<12)*2);
	write_short((1<<12)*6);
	message_end();
}

stock Make_Zombie(id,iSetHeath,bResetClass=0,iGiveWeapon = 1)
{
	if (!is_user_alive(id)) return

	//server_print("Make Zombie %d",id)

	/*StripSlot(id, 1)
	StripSlot(id, 2)*/
	g_hero[id] = 0;
	g_zombie[id] = 1;
	
	if(g_iNormalZombie[id] == -2 || is_user_bot(id))
	{
		g_zombieclass[id] = random_num(0, class_count-1);
		g_iCanUseSkill[id] = 1;
	}
	else if(g_iNormalZombie[id] == -1)
	{
		ShowZombieMenu(id, 1);
		if(bResetClass)
			g_zombieclass[id] = GetNormalZombie();
	}
	else
	{
		g_zombieclass[id] = g_iNormalZombie[id]
		g_iCanUseSkill[id] = 1;
	}
	
	//SetTeam(id, 1)
	//set_pdata_int(id, 114, 1);
	
	Activate_ZombieClass(id)

	if (iGiveWeapon || get_pdata_cbase(id, 370, 4) < 33)
	{
		StripWeapons(id)
		GiveZombieBomb(id)
		bte_wpn_give_named_wpn(id, "knife",0)
	}

	//ExecuteHamB(Ham_Item_Deploy, get_pdata_cbase(id, m_rgpPlayerItems[3], 4));
	engclient_cmd(id,"weapon_knife")

	//set_pdata_float(id, m_flNextAttack, 1.0);

	if(iSetHeath)
		UpdateHealthZombie(id,0)

	
	// nvg
	set_pdata_bool(id, m_bHasNightVision, true);
	set_pdata_bool(id, m_bNightVisionOn, true);
	Nvg(id)
	CheckEvolution(id)
	UpdateScoreBoard()
}

stock Activate_ZombieClass(id)
{
	new Float:gravity, Float:speed, Float:xdamage, Float:xdamage2, Float:flKnockBack, Float:flVM
	gravity = ArrayGetCell(zombie_gravity, g_zombieclass[id])
	speed = ArrayGetCell(zombie_speed, g_zombieclass[id])
	xdamage = ArrayGetCell(zombie_xdamage, g_zombieclass[id])
	xdamage2 = ArrayGetCell(zombie_xdamage2, g_zombieclass[id])
	flKnockBack = ArrayGetCell(zombie_knockback, g_zombieclass[id])
	flVM = 1.0
	//if(BitsGet(g_bitsDNA[id], DNA_KNOCKBACK_STRENGTHEN))
	//	flKnockBack *= 0.9
	if(BitsGet(g_bitsDNA[id], DNA_PAINSHOCK_STRENGTHEN))
		flVM *= 0.9
	if(BitsGet(g_bitsDNA[id], DNA_SPEED_STRENGTHEN))
		speed *= 1.15
	if(BitsGet(g_bitsDNA[id], DNA_GRAVITY_STRENGTHEN))
		gravity *= 0.86
	
	g_zombie_xdamage[id][0] = xdamage
	g_zombie_xdamage[id][1] = xdamage2
	g_zombie_xdamage[id][2] = xdamage2
	g_fNextRestoreHealth[id] = get_gametime() + RESTORE_HEALTH_TIME;
	bte_wpn_set_knockback(id, flKnockBack);
	bte_wpn_set_vm(id, flVM);
	
	g_flMaxSpeed[id] = speed;
	set_pev(id, pev_gravity, gravity);

	SetPlayerModel(id)
	SetZombieViewModel(id)
}

stock Make_Zombie2(id,Float:health, bResetClass=0)
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

	if(g_iNormalZombie[id] == -2 || is_user_bot(id))
	{
		g_zombieclass[id] = random_num(0, class_count-1);
		g_iCanUseSkill[id] = 1;
	}
	else if(g_iNormalZombie[id] == -1)
	{
		ShowZombieMenu(id, 1);
		if(bResetClass)
			g_zombieclass[id] = GetNormalZombie();
	}
	else
	{
		g_zombieclass[id] = g_iNormalZombie[id];
		g_iCanUseSkill[id] = 1;
	}

	Activate_ZombieClass(id)

	health += 1000.0;

	g_iZombieMaxHealth[id] = floatround(health)
	g_iZombieMaxArmor[id] = 500;

	DNA_OnBeingZombieOrigin(id);
	ActivateGodmode(id);
	
	set_pev(id, pev_max_health,health)
	set_pev(id, pev_health,health)
	set_pev(id,pev_armorvalue,health/10.0)


	GiveZombieBomb(id)
	Message_HudTextPro(id, "#ZombiSelected")

	bte_wpn_give_named_wpn(id,"knife",1)
	//bte_wpn_set_playerwpn_model(id,0,"",0,0)

	engclient_cmd(id,"weapon_knife")

	set_pdata_float(id, m_flNextAttack, 1.0);

	set_pdata_bool(id, m_bHasNightVision, true);
	set_pdata_bool(id, m_bNightVisionOn, true);
	Nvg(id)
	CheckEvolution(id)
	UpdateScoreBoard()

	if (MH_IsMetaHookPlayer(id))
	{
		MH_PlayBink(id,"origin.bik",0.5,0.5,255,255,255,0,1,1,0)
	}

	//server_print("Make Zombie finished.")
}

public Make_Hero(id)
{
	if (!is_user_alive(id)) return

	//server_print("Make Hero %d",id)

	g_zombie[id] = 0

	//SetTeam(id, 2)
	/*set_pev(id,pev_health,1000.0)
	set_pev(id,pev_max_health,1000.0)
	set_pev(id,pev_armorvalue,100.0)*/
	//set_pev(id, pev_gravity, HERO_GRAVITY)
	set_pdata_bool(id, m_bNightVisionOn, false);
	set_pdata_bool(id, m_bHasNightVision, false);

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


}

public Make_Human(id)
{
	//server_print("Make Human %d",id)

	g_zombie[id] = 0
	g_hero[id] = 0
	g_human[id] = 1
	//SetTeam(id, 2)
	set_pev(id, pev_health, 1000.0)
	set_pev(id, pev_max_health, 1000.0)
	set_pev(id, pev_armorvalue, 100.0)
	//PRINT("Set id:%d team:%d",id,get_pdata_int(id, 114));
	// fix some bugs

	set_pev(id, pev_gravity, 0.8);
	

	set_pdata_bool(id, m_bNightVisionOn, false);
	set_pdata_bool(id, m_bHasNightVision, false);

	g_human_morale[id] = 3
	RenderingHuman(id);
	
	//MH_OpenBuyMenu(id);

	MH_SendZB3Data(id, 10, 20);
	Make_Human_Msg(id);

	//server_print("Make Human finished.")
}

public Make_Human_Msg(id)
{
	if (!is_user_alive(id))
		return;
	if (g_human_morale[0])
		MH_SendZB3Data(id, 19, g_human_morale[0])
	MH_SendZB3Data(id, 1, g_human_morale[0] + g_human_morale[id])
}

public Task_CountDown_Waiting(taskid)
{
	if (!g_count_down)
	{
		remove_task(taskid);
		g_count_down = -1;

		g_bCanReadyToBeZombies = 0;

		new iInGame
		for(new i =1;i<33;i++)
		{
			if (is_user_connected(i) && is_user_alive(i))
				iInGame++;
		}
		if (!iInGame)
			return;
		new iZombieNum = iInGame / 10 + 1;
		new Float:fMaxHealth = 1000.0 * iInGame / iZombieNum;
		new sound[64];
		new bSoundPlayed = 0;

		for (new i=1; i<33; i++)
		{
			if (is_user_alive(i) && is_user_connected(i))
			{
				if (!g_zombie[i] && g_readyzombie[i])
				{
					if(!g_zombieclass[i] || is_user_bot(i))
						g_zombieclass[i] = random(class_count);

					Make_Zombie2(i, fMaxHealth, 1);
					ExecuteForward(g_fwUserInfected, g_fwDummyResult, i, 33);
					SetRendering(i);

					if (!bSoundPlayed)
					{
						ArrayGetString(sound_zombie_coming, random(ArraySize(sound_zombie_coming)), sound, charsmax(sound));
						PlaySound(0, sound);

						bSoundPlayed = 1;

						g_bCanEnd = 1;
					}
				}
			}
		}

		CheckWinConditions();
		return;
	}

	if (!g_bCanReadyToBeZombies)
		g_bCanReadyToBeZombies = 1;
	
	if(!g_bInfectionStart)
	{
		ExecuteForward(g_fwRoundStart, g_fwDummyResult);
		
		for (new id = 1; id <33; id++)
		{
			if (is_user_connected(id) && !g_zombie[id] && !g_hero[id] && !g_human[id])
			{
				Make_Human(id);
			}
		}
		
		if (task_exists(TASK_SUPPLYBOX))
			remove_task(TASK_SUPPLYBOX)
		set_task(SUPPLYBOX_TIME_FIRST, "Task_RespawnSupplyBox", TASK_SUPPLYBOX)
		g_bInfectionStart = 1;
	}

	new number[10];
	format(number, 9, "%d", g_count_down);

	ClientPrint(0, HUD_PRINTCENTER, "#CSO_InfectCandidateZombiesAllWait", number);

	g_count_down --;

	return;
}

public Task_CountDown_Chosen(taskid)
{
	new bInOne = 0;

	if (g_count_down == 8)
	{
		remove_task(taskid);
		set_task(1.0, "Task_CountDown_Waiting", taskid, _, _, "b");

		bInOne = 1;
	}
	else
		g_count_down --;

	new number[10];

	if (bInOne)
		format(number, 9, "1");
	else
		format(number, 9, "%d", g_count_down - 6);

	ClientPrint(0, HUD_PRINTCENTER, "#CSO_ZombiSelectCount", number);

	if (g_count_down < 17)
	{
		if (bInOne)
			PlaySound(0, SND_COUNT[0]);
		else
			PlaySound(0, SND_COUNT[g_count_down - 7]);
	}

	return;
}

native MetahookMsg(id, type, i2 = -1, i3 = -1)

public ChooseFirstZombies()
{
	new iInGame
	new iTime = 15;
	for(new i =1;i<33;i++)
	{
		if (is_user_connected(i) && is_user_alive(i))
			iInGame++;
	}
	if (!iInGame)
		return;
	new iZombieNum = iInGame / 10 + 1;
	switch(iInGame)
	{
		case 1..7 : iZombieNum = 1;
		case 8..10 : iZombieNum = random_num(1,2);
		case 11..17 : iZombieNum = 2;
		case 18..20 : iZombieNum = random_num(2,3);
		case 21..32 : iZombieNum = 3;
		default : iZombieNum = 1;
	}
	new iRan;

	do
	{
		iRan = GetRandomPlayer(2);
		if (!iRan)
			return;
		g_readyzombie[iRan] = 1;
		MetahookMsg(iRan, 47, iTime);
	} while (--iZombieNum);
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
public ZombieInfectedHuman(attacker, victim)
{
	// show Msg Death
	SendDeathMsg(attacker, victim)
	
	FixDeadAttrib(victim)

	UpdateFrags(attacker, 1)
	UpdateDeaths(victim, 1)

	UpdateEvolution(attacker, victim)
	g_evolution[victim] = 0.0
	g_level[victim] = 1
	//if(bte_fun_get_have_mode_item(victim,1)) g_iZombieMaxHealth[victim] = max(get_user_health(attacker), MIN_HEALTH_ZOMBIE_RANDOM);
	/*else */
	g_iZombieMaxHealth[victim] = max(floatround(get_user_health(attacker)*0.7), MIN_HEALTH_ZOMBIE_RANDOM);
	g_iZombieMaxArmor[victim] = floatround(get_user_armor(attacker)*0.7);
	/*g_iZombieMaxArmor[victim] = g_iZombieMaxHealth[victim] /14 / 50;
	g_iZombieMaxHealth[victim] /= 500;
	g_iZombieMaxHealth[victim] *= 500;*/
	g_iZombieMaxHealth[victim] += 1000;
	//g_iZombieMaxArmor[victim] *= 50;
	g_iZombieMaxArmor[victim] += 100;

	DNA_OnZombieInfectedHuman(attacker, victim)
	
	set_pdata_int(victim, 114, 1);

	remove_task(victim + TASK_UPDATETEAM)
	set_task(0.1, "Task_UpdateTeam", victim + TASK_UPDATETEAM)

	//SetTeam(victim, 1);

	if(!g_zombieclass[victim]||is_user_bot(victim)) 
		g_zombieclass[victim] = random(class_count)
	
	Make_Zombie(victim,1,1)
	g_level[victim] = 1
	SetRendering(victim)
	new sound[64], sex
	sex = bte_get_user_sex(victim)
	if (sex == 2) ArrayGetString(sound_female_death, random(ArraySize(sound_female_death)), sound, charsmax(sound))
	else ArrayGetString(sound_human_death, random(ArraySize(sound_human_death)), sound, charsmax(sound))
	PlayEmitSound(victim, CHAN_VOICE, sound)
	ExecuteForward(g_fwUserInfected, g_fwDummyResult, victim, attacker)
	ActivateGodmode(victim)
	
	//set_task(0.2, "Task_InfectedSound", victim+TASK_INFECTEDSOUND);
	InfectedSound()
	MH_SendZB3Data(attacker,3,_:g_evolution[attacker])

	if (MH_IsMetaHookPlayer(victim))
	{
		MH_PlayBink(victim,"infection.bik",0.5,0.5,255,255,255,0,1,1,0)
	}
}
public HumanKilledZombie(killer, victim, headshot)
{
	if (headshot && g_zombie[victim])
		g_bHeadshotKilled[victim] = 1;

	CheckWinConditions();

	if(!g_zombie[victim]) return

	if (!headshot)
	{
		//UpdateDeaths(victim, -1)

		if (task_exists(victim+TASK_ZOMBIE_RESPAWN)) remove_task(victim+TASK_ZOMBIE_RESPAWN)

		//respawn time
		g_respawn_count[victim] = 2
		
		set_task(1.0, "Task_ZombieRespawn2", victim+TASK_ZOMBIE_RESPAWN,"",0,"a",2)
		//g_iZombieMaxArmor[victim] *= 50;
		//g_iZombieMaxArmor[victim] -= 50;
		g_iZombieMaxArmor[victim] = 0;

	}
	else
	{
		remove_task(victim+TASK_ZOMBIE_RESPAWN_EF)
		ClientPrint(victim, HUD_PRINTCENTER, "#CSBTE_ZB3_CannotRespawn");
	}

	if(killer>0 && killer<33 && killer != victim) // IF NORMAL KILLED
	{
		UpdateHumanLevel(0)
		//UpdateScoreBoard()
	}
}
public ZombieRespawn(id)
{
	if (!g_bInfectionStart || g_bRoundTerminating || !is_user_connected(id)) return

	g_bHeadshotKilled[id] = 0
	if (is_user_connected(id))
	{
		ExecuteHamB(Ham_CS_RoundRespawn, id)
	}
	//Strip_Weapon(id)
	Make_Zombie(id,1);
	ExecuteForward(g_fwUserInfected, g_fwDummyResult, id, 0)

	new sound[64]
	ArrayGetString(sound_zombie_comeback, random(ArraySize(sound_zombie_comeback)), sound, charsmax(sound))
	//PlayEmitSound(id, CHAN_VOICE, sound)
	PlaySound(0, sound);

	Activate_ZombieClass(id);

	SetPlayerModel(id);

	//SetTeam(id, 1);
	return
}

public CheckRespawning()
{
	for(new i = 1;i<33;i++)
	{
		if(is_user_connected(i) && g_zombie[i] && !g_bHeadshotKilled[i]) return 1
	}
	return 0
}


stock UpdateHumanLevel(id,num=1)
{
	g_human_morale[0] += num
	g_human_morale[0] = min(g_human_morale[0],4)

	if(g_levelmax_check) return
	for(new i=1;i<33;i++)
	{
		if(is_user_connected(i) && is_user_alive(i) && !g_zombie[i])
		{
			MH_SendZB3Data(i,1,g_human_morale[0] + g_human_morale[i])
			/*new msg[32]
			format(msg,31,"%L",LANG_PLAYER,"BTE_ZB3_TEXT_MORALE",g_human_morale[0])
			MH_DrawFontText(i,msg,1,0.5,0.3,237,182,65,32,3.0,1.0,0,2)*/
			MH_SendZB3Data(i, 19, g_human_morale[0])
			RenderingHuman(i)
		}
	}
	//PlaySound(0, SND_LEVELUP)
	// SetRendering
	RenderingHuman(id)
	if(g_human_morale[0] == 4) g_levelmax_check = 1
}

public ActivateGodmode(id)
{
	BitsSet(g_bitsGodMode, id)
	fm_set_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 0)
	set_task(BitsGet(g_bitsDNA[id], DNA_GODMODE_STRENGTHEN) ? 1.3:1.0, "Task_ResetGod", id + TASK_GODMODE)
}

public Task_ResetGod(taskid)
{
	new id = taskid - TASK_GODMODE
	BitsUnSet(g_bitsGodMode, id)
	fm_set_rendering(id)
}