#define DMG_HE (1<<24)
public HamF_HostagePrecache(iEnt)
{
	return HAM_SUPERCEDE;
}

// ½«¸Ä±äfrag / death·Åµ½ÕâÀïÒÔ±ÜÃâ¶àÓàµÄÏûÏ¢·¢ËÍ
public HamF_Killed(victim, killer, gib)
{
	if (!g_zombie[victim])
		return;
/*
	if (get_pdata_int(victim, m_LastHitGroup) == 1)
	{
		set_pev(killer, pev_frags, float(pev(killer, pev_frags) + 2));
	}
	else
	{
		// ´ËÊ±²»ÐèÒª·¢ÏûÏ¢
		iBlockScoreInfoID = victim;
		set_pdata_int(victim, m_iDeaths, get_pdata_int(victim, m_iDeaths) - 1);
	}*/
	set_pev(killer, pev_frags, float(pev(killer, pev_frags) + 2));
}

public HamF_Killed_Post(victim, killer, gib)
{
	HumanKilledZombie(killer, victim, (get_pdata_int(victim, m_LastHitGroup) == 1))
	SetLight(victim, g_light)

#if 0
	MH_SendZB3Data(victim, 12, 0);
	message_begin(MSG_ONE, g_msgScreenFade, _, victim)
	write_short(0) // duration
	write_short(0) // hold time
	write_short(0x0000) // fade type
	write_byte(100) // red
	write_byte(100) // green
	write_byte(100) // blue
	write_byte(255) // alpha
	message_end()
#endif

	set_pdata_bool(victim, m_bNightVisionOn, false);
	Nvg(victim);
	
	/*new szLight[2]
	get_pcvar_string(Cvar_Light,szLight,2)
	SetLight(victim,szLight)*/
}

public HamF_Grenade_Think(iEntity)
{
	// Invalid entity
	if (!pev_valid(iEntity)) 
		return HAM_IGNORED;
	
	// Get damage time of grenade
	static iType; iType = pev(iEntity, PEV_NADE_TYPE)
	static Float:flDmgTime; pev(iEntity, pev_dmgtime, flDmgTime)

	if (get_gametime() > flDmgTime)
	{
		switch (pev(iEntity, PEV_NADE_TYPE))
		{
			case NADE_TYPE_ZOMBIEBOMB:
			{
				ZombieBombExplosion(iEntity, 0)
			}
			case NADE_TYPE_ZOMBIEBOMB2:
			{
				ZombieBombExplosion(iEntity, 1)
			}
			default: return HAM_IGNORED
		}
		return HAM_SUPERCEDE
	}
	
	if(iType == NADE_TYPE_ZOMBIEBOMB)
	{
		static Float:vecVelocity[3]; pev(iEntity, pev_velocity, vecVelocity)
		static Float:flFrame; pev(iEntity, pev_frame, flFrame)
		if(!flFrame)
			set_pev(iEntity, pev_animtime, get_gametime())
		if(vecVelocity[0] || vecVelocity[1] || vecVelocity[2])
			set_pev(iEntity, pev_framerate, 10.0)
		else
			set_pev(iEntity, pev_framerate, 0.0)
		set_pev(iEntity, pev_nextthink, get_gametime() + 0.05)
		return HAM_SUPERCEDE;
	}
	else if(iType == NADE_TYPE_ZOMBIEBOMB2)
	{
		if(pev(iEntity, pev_flags) & FL_ONGROUND)
		{
			new Float:vecOrigin[3]; pev(iEntity, pev_origin, vecOrigin)
			vecOrigin[2] += 1.0
			new Float:vecEnd[3]; 
			vecEnd[0] = vecOrigin[0]
			vecEnd[1] = vecOrigin[1]
			vecEnd[2] = vecOrigin[2] + 45.0
			new ptr = create_tr2()
			engfunc(EngFunc_TraceHull, vecOrigin, vecEnd, DONT_IGNORE_MONSTERS, HULL_HUMAN, 0, ptr)
			new pHit = get_tr2(ptr, TR_pHit)
			free_tr2(ptr)
			if(is_user_alive(pHit))
			{
				set_pev(iEntity, pev_dmgtime, get_gametime())
			}
		}
		static Float:vecVelocity[3]; pev(iEntity, pev_velocity, vecVelocity)
		static Float:flFrame; pev(iEntity, pev_frame, flFrame)
		if(!flFrame)
			set_pev(iEntity, pev_animtime, get_gametime())
		if(vecVelocity[0] || vecVelocity[1] || vecVelocity[2])
			set_pev(iEntity, pev_framerate, 10.0)
		else
			set_pev(iEntity, pev_framerate, 0.0)
		set_pev(iEntity, pev_nextthink, get_gametime() + 0.05)
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}

public HamF_Grenade_Touch(iEntity, pHit)
{
	// Invalid entity
	if (!pev_valid(iEntity)) 
		return HAM_IGNORED;
	
	// Get damage time of grenade
	static iType; iType = pev(iEntity, PEV_NADE_TYPE)
	
	if(iType == NADE_TYPE_ZOMBIEBOMB)
	{
		if(pHit <= 0)
			set_pev(iEntity, pev_sequence, random_num(4,6))
	}
		
	if(iType == NADE_TYPE_ZOMBIEBOMB2)
	{
		if(pHit <= 0)
			set_pev(iEntity, pev_sequence, random_num(4,6))
		
		if(is_user_alive(pHit))
		{
			set_pev(iEntity, pev_dmgtime, get_gametime() + 0.1)
		}
	}
		
	return HAM_IGNORED;
}

public HamF_ZombieDeploy(iEnt)
{
	static id
	id = get_pdata_cbase(iEnt, m_pPlayer, 4)
	if(!id || id>32 || !g_zombie[id]) return HAM_IGNORED

	SetZombieViewModel(id)

	return HAM_IGNORED
}

public bte_fw_precache_weapon_pre()
{
	SUPPLYBOX_ITEMS = ArrayCreate(64, 1)
	Load_SupplyBoxItems()
	new  iTotal = ArraySize(SUPPLYBOX_ITEMS)
	log_amx("%d %d",SUPPLYBOX_ITEMS,iTotal)
	for(new i=0;i<iTotal;i++)
	{
		new wpn[32]
		ArrayGetString(SUPPLYBOX_ITEMS, i, wpn, charsmax(wpn))
		bte_wpn_precache_named_weapon(wpn)
	}

	bte_wpn_precache_named_weapon("svdex")
	bte_wpn_precache_named_weapon("ddeagle")
	bte_wpn_precache_named_weapon("qbarrel")
	bte_wpn_precache_named_weapon("hegrenade")
}

public HamF_TouchSupplyBox(iPtr,iPtd)
{
	// Check is supplybox
	if(iPtd>32 || iPtd < 1) return HAM_IGNORED
	if(!pev_valid(iPtr)) return HAM_IGNORED
	if(g_zombie[iPtd]) return HAM_IGNORED
	if(pev(iPtr,pev_iuser3) != 998) return HAM_IGNORED
	static Float:vSpeed[3]
	pev(iPtr,pev_velocity,vSpeed)
	if(vSpeed[0] || vSpeed[1] || vSpeed[2]) return HAM_IGNORED
	if(fabs(g_next_picksupply[iPtd] - get_gametime()) < 1.0) return HAM_IGNORED
	g_next_picksupply[iPtd] = get_gametime()
	new name[32]
	get_user_name(iPtd,name,31)

	// Human
	static iRandom
	if(g_hero[iPtd])
	{
		iRandom = random_num(1,2)
		if(iRandom == 1) // nvg
		{
			bte_wpn_set_fullammo(iPtd)

			if (!get_pdata_bool(iPtd, m_bHasNightVision))
				Message_HudTextPro(iPtd, "#Hint_use_nightvision");

			set_pdata_bool(iPtd, m_bHasNightVision, true);

			ClientPrintEX(iPtd, HUD_PRINTCENTER, "#CSBTE_SupplyBox_Pickup_Item_All", 1, 0, name, "#CSBTE_SupplyBox_Nvg");
			ClientPrint(iPtd, HUD_PRINTCENTER, "#CSBTE_SupplyBox_Pickup_Item", "#CSBTE_SupplyBox_Nvg");

			if (!get_pdata_bool(iPtd, m_bNightVisionOn))
				client_cmd(iPtd,"nightvision");
		}
		else
		{
			bte_wpn_set_fullammo(iPtd)
			bte_wpn_give_grenade(iPtd)

			ClientPrintEX(iPtd, HUD_PRINTCENTER, "#CSBTE_SupplyBox_Pickup_Item_All", 1, 0, name, "#CSBTE_SupplyBox_Ammo");
			ClientPrint(iPtd, HUD_PRINTCENTER, "#CSBTE_SupplyBox_Pickup_Item", "#CSBTE_SupplyBox_Ammo");
		}
	}
	else
	{
		iRandom = random_num(1,10)
		if(iRandom <= 2) // nvg
		{
			bte_wpn_set_fullammo(iPtd)

			if (!get_pdata_bool(iPtd, m_bHasNightVision))
				Message_HudTextPro(iPtd, "Hint_use_nightvision");

			set_pdata_bool(iPtd, m_bHasNightVision, true);

			ClientPrintEX(iPtd, HUD_PRINTCENTER, "#CSBTE_SupplyBox_Pickup_Item_All", 1, 0, name, "#CSBTE_SupplyBox_Nvg");
			ClientPrint(iPtd, HUD_PRINTCENTER, "#CSBTE_SupplyBox_Pickup_Item", "#CSBTE_SupplyBox_Nvg");

			if (!get_pdata_bool(iPtd, m_bNightVisionOn))
				client_cmd(iPtd,"nightvision");
		}
		else if(iRandom <= 4)
		{
			bte_wpn_set_fullammo(iPtd)
			bte_wpn_give_grenade(iPtd)

			ClientPrintEX(iPtd, HUD_PRINTCENTER, "#CSBTE_SupplyBox_Pickup_Item_All", 1, 0, name, "#CSBTE_SupplyBox_Ammo");
			ClientPrint(iPtd, HUD_PRINTCENTER, "#CSBTE_SupplyBox_Pickup_Item", "#CSBTE_SupplyBox_Ammo");
		}
		else
		{
			bte_wpn_set_fullammo(iPtd)
			new wpn[32]
			new iItem = ArraySize(SUPPLYBOX_ITEMS) -1
			new ir = random_num(0, iItem)
			ArrayGetString(SUPPLYBOX_ITEMS, ir, wpn, charsmax(wpn))

			bte_wpn_give_named_wpn(iPtd, wpn, 0)

			new str1[32];
			strtoupper(wpn);
			format(str1, 32, "#CSBTE_%s", wpn);

			ClientPrintEX(iPtd, HUD_PRINTCENTER, "#CSBTE_SupplyBox_Pickup_Item_All", 1, 0, name, str1);
			ClientPrint(iPtd, HUD_PRINTCENTER, "#CSBTE_SupplyBox_Pickup_Item", str1);
		}
	}

	engfunc(EngFunc_RemoveEntity,iPtr)
	PlayEmitSound(iPtd, CHAN_WEAPON, SUPPLYBOX_SOUND_PICKUP)
	g_supplybox_count --
	return HAM_SUPERCEDE
}

public HamF_TouchWeaponBox(weapon, id)
{
	if (!is_user_connected(id)) return HAM_IGNORED
	if (g_zombie[id]) return HAM_SUPERCEDE
	return HAM_IGNORED
}

public HamF_TraceAttack(iVictim, iAttacker, Float:flDamage, Float:vecDirection[3], ptr, bitsDamageType)
{
	if (!g_bInfectionStart || g_bRoundTerminating)
		return HAM_IGNORED;
	if (!is_user_connected(iVictim) || !is_user_connected(iAttacker))
		return HAM_IGNORED;
	
	if (g_zombie[iVictim])
	{
		new iHitgroup = get_tr2(ptr, TR_iHitgroup);
		if(iHitgroup == HIT_HEAD)
		{
			new Float:flDefensePercent = 1.0;
			if(BitsGet(g_bitsDNA[iVictim], DNA_GENE_STRENGTHEN))
				flDefensePercent -= 0.2;
			if(BitsGet(g_bitsDNA[iVictim], DNA_ACCSHOOT_STRENGTHEN))
				flDefensePercent -= 0.2;
		}
	}
	return HAM_IGNORED;
}

public HamF_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if (!g_bInfectionStart || g_bRoundTerminating)
		return HAM_SUPERCEDE;
	if (!is_user_connected(victim) || !is_user_connected(attacker))
		return HAM_IGNORED;
	if (g_fNextRestoreHealth[victim] < get_gametime() + RESTORE_HEALTH_TIME)
		g_fNextRestoreHealth[victim] = get_gametime() + RESTORE_HEALTH_TIME;
	if (g_zombie[attacker] && inflictor > 32)
		return HAM_IGNORED;
	if (victim == attacker)
		return HAM_IGNORED;

	new Float:fDamage;
	fDamage = damage;

	if (g_zombie[victim])
	{
		g_restore_health[victim] = 0;

		new iMoraleLevel = g_human_morale[attacker] + g_human_morale[0] + g_iAdditionMorale[attacker] - 3;
		if (iMoraleLevel < 0)
			iMoraleLevel = 0;
		else if (iMoraleLevel > 16)
			iMoraleLevel = 16;

		new Float:fMoraleDamage = iMoraleLevel / 100.0 + 1.0;

		if(BitsGet(g_bitsGodMode, victim))
			fDamage = 0.0;
		
		if (get_user_weapon(attacker) != CSW_KNIFE || inflictor != attacker)
			fDamage *= fMoraleDamage;

		fDamage *= g_zombie_xdamage[victim][g_level[victim]-1];

		new Float:fHealth;
		pev(victim, pev_health, fHealth);

		new iLevel = g_level[victim];
		if (!g_zombie[attacker]) 
			UpdateEvolutionDamage(victim, fDamage);

		if (iLevel < g_level[victim])
			fDamage -= fHealth;
		
		new Float:flFraction = 1.0;
		if(BitsGet(g_bitsDNA[victim], DNA_CRISIS_RECOVERY) && get_user_health(victim) <= g_iZombieMaxHealth[victim] * 3 / 10)
			flFraction -= 0.4
		if(BitsGet(g_bitsDNA[victim], DNA_DEFENCE_STRENGTHEN))
			flFraction -= 0.05
		
		fDamage *= flFraction;
		
		//fDamage = fDamage < 1.0 ? 1.0 : fDamage;
	}

	if (damage_type & DMG_HE) return HAM_IGNORED
	if (g_zombie[attacker] && !g_zombie[victim])
	{
		ZombieInfectedHuman(attacker,  victim)
		CheckWinConditions();
		return HAM_SUPERCEDE;
	}
	else if (!g_zombie[attacker] && g_zombie[victim] && attacker!=victim)
	{
		new Float:ammor
		pev(victim,pev_armorvalue,ammor)
		if (ammor>0.0)
		{
			ammor -= fDamage * 0.1
			set_pev(victim,pev_armorvalue,ammor)
		}
		
		SetHamParamFloat(4, fDamage)

		return HAM_IGNORED
	}
	//else return HAM_SUPERCEDE
	return HAM_IGNORED
}

native BTE_Alarm(id, type)

public HamF_TakeDamage_Post(iVictim, inflictor, attacker, Float:flDamage, damage_type)
{
	if (!g_bInfectionStart || g_bRoundTerminating)
		return HAM_SUPERCEDE;
	if (!is_user_connected(iVictim) || !is_user_connected(attacker))
		return HAM_IGNORED;
	
	if(g_zombie[iVictim])
	{
		set_pev(iVictim, pev_punchangle, Float:{ 0.0, 0.0, 0.0 })
		
		if(g_iDamageRewarded[iVictim]<7)
		{
			g_flDamageToFrag[iVictim] += flDamage
			new iRewardCount = floatround(g_flDamageToFrag[iVictim] / 3000.0, floatround_floor)
			
			if (iRewardCount)
			{
				if(iRewardCount > 7-g_iDamageRewarded[iVictim])
					iRewardCount = 7-g_iDamageRewarded[iVictim]
				UpdateFrags(iVictim, 1)
				g_flDamageToFrag[iVictim] -= 3000.0 * iRewardCount
				g_iDamageRewarded[iVictim]+=iRewardCount
				BTE_Alarm(iVictim, 32);
			}
		}
		
		if(BitsGet(g_bitsDNA[iVictim], DNA_FREEZE_ON_HIT))
		{
			DNA_CheckSkillReset(iVictim)
		}
	}
	
	
	
	return HAM_IGNORED
}

native PlayerSpawn(id);

public HamF_Spawn_Player_Post(id)
{
	if (!is_user_alive(id) || !get_pdata_int(id,114)) return

	if (task_exists(id+TASK_SPAWN)) remove_task(id+TASK_SPAWN)
	SetRendering(id)
	StripWeapons(id)
	bte_wpn_give_named_wpn(id, "knife", 1)

	if(!g_zombie[id])
		bte_wpn_give_named_wpn(id, "usp", 1)

	PlayerRandomSpawn(id)
	if (g_zombie[id])
		set_pdata_int(id, 112, 2)

	if (!g_EnteredBuyMenu[id])
	{
		PlayerSpawn(id);
		g_EnteredBuyMenu[id] = 1;
	}

	if (!g_zombie[id])
		Make_Human(id);

	set_pev(id, pev_skin, 0);
}

public HamF_Spawn_Player(id)
{
	if(!g_zombie[id])
		set_pdata_int(id, 114, 2);

	return HAM_IGNORED;
}