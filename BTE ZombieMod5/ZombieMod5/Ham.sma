#define DMG_HE (1<<24)

native bte_zb5_is_using_zbskill(id);

public HamF_HostagePrecache(iEnt)
{
	return HAM_SUPERCEDE;
}

public HamF_Weapon_Secondary_Post(iEnt)
{
	static id
	id = get_pdata_cbase(iEnt,m_pPlayer,4);
	g_attacking[id] = 0;

	return HAM_IGNORED
}

public HamF_Weapon_Secondary(iEnt)
{
	static id
	id = get_pdata_cbase(iEnt,m_pPlayer,4);
	g_attacking[id] = 1;

	return HAM_IGNORED
}

public HamF_Weapon_Primary(iEnt)
{
	static id
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	g_attacking[id] = 1;

	return HAM_IGNORED
}

public HamF_Weapon_Primary_Post(iEnt)
{
	static id
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	g_attacking[id] = 0;

	return HAM_IGNORED
}

// ½«¸Ä±äfrag / death·Åµ½ÕâÀïÒÔ±ÜÃâ¶àÓàµÄÏûÏ¢·¢ËÍ
public HamF_Killed(victim, killer, gib)
{
	if (!g_zombie[victim])
		return;

	/*if (get_pdata_int(victim, m_LastHitGroup) == 1)
	{*/
	set_pev(killer, pev_frags, float(pev(killer, pev_frags) + 1));
	//}
	/*else
	{
		// ´ËÊ±²»ÐèÒª·¢ÏûÏ¢
		iBlockScoreInfoID = victim;
		set_pdata_int(victim, m_iDeaths, get_pdata_int(victim, m_iDeaths) - 1);
	}*/
}

public HamF_Killed_Post(victim, killer, gib)
{
	HumanKilledZombie(killer, victim)
	SetLight(victim, g_light)

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

	/*new szLight[2]
	get_pcvar_string(Cvar_Light,szLight,2)
	SetLight(victim,szLight)*/
}
public HamF_ThinkGrenade(iEnt)
{
	static Float:dmgtime
	pev(iEnt, pev_dmgtime, dmgtime)

	if (dmgtime - get_gametime() > 0) return HAM_IGNORED

	switch (pev(iEnt, PEV_NADE_TYPE))
	{
		case NADE_TYPE_INFECTION:
		{
			ZombieBombExplosion(iEnt)
		}
		default: return HAM_IGNORED
	}
	return HAM_SUPERCEDE
}

public HamF_ZombieDeploy(iEnt)
{
	static id
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);

	if (!g_zombie[id])
		return HAM_IGNORED

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

public HamF_TouchSupplyBox(iPtr, iPtd)
{
	// Check is supplybox
	if(iPtd > 32 || iPtd < 1)
		return HAM_IGNORED

	if (!pev_valid(iPtr))
		return HAM_IGNORED
	if (g_zombie[iPtd])
		return HAM_IGNORED

	if (pev(iPtr,pev_iuser3) != 998)
		return HAM_IGNORED

	static Float:vSpeed[3]
	pev(iPtr, pev_velocity, vSpeed)

	if(vSpeed[0] || vSpeed[1] || vSpeed[2])
		return HAM_IGNORED

	if(fabs(g_next_picksupply[iPtd] - get_gametime()) < 1.0)
		return HAM_IGNORED

	g_next_picksupply[iPtd] = get_gametime()

	new name[32]
	get_user_name(iPtd,name,31)

	// Human
	static iRandom
	/*if (g_hero[iPtd])
	{
		iRandom = random_num(1,2)
		if(iRandom == 1) // nvg
		{
			bte_wpn_set_fullammo(iPtd)
			if(!g_havenvg[iPtd]) Message_HudTextPro(iPtd, "Hint_use_nightvision")
			g_havenvg[iPtd] = 1
			format(msg,127,"%L",LANG_PLAYER,"BTE_ZB3_NOTICE_NVG",name)
			SendMessage(iPtd,2,1,msg,print_center)
			format(msg,127,"%L",LANG_PLAYER,"BTE_ZB3_NOTICE_NVG","")
			client_print(iPtd,print_center,msg)
			if(!g_nvg[iPtd]) client_cmd(iPtd,"nightvision")
		}
		else
		{
			bte_wpn_set_fullammo(iPtd)
			bte_wpn_give_grenade(iPtd)
			format(msg,127,"%L",LANG_PLAYER,"BTE_ZB3_NOTICE_AMMO",name)
			SendMessage(iPtd,2,1,msg,print_center)
			format(msg,127,"%L",LANG_PLAYER,"BTE_ZB3_NOTICE_AMMO","")
			client_print(iPtd,print_center,msg)
			//bte_wpn_set_ammo(iPtd,1,floatround(bte_wpn_get_wpn_data(iPtd,0,1,BTE_WPNDATA_AMMO,0,0)*1.5))
			//bte_wpn_set_ammo(iPtd,2,floatround(bte_wpn_get_wpn_data(iPtd,0,2,BTE_WPNDATA_AMMO,0,0)*1.5))
			//ExecuteForward(g_fwSupplyPickupAmmo, g_fwDummyResult, iPtd)
		}
	}
	else*/
	{
		iRandom = random_num(1,10)
		/*if(iRandom <= 2) // nvg
		{
			bte_wpn_set_fullammo(iPtd)
			if(!g_havenvg[iPtd]) Message_HudTextPro(iPtd, "Hint_use_nightvision")
			g_havenvg[iPtd] = 1
			format(msg,127,"%L",LANG_PLAYER,"BTE_ZB3_NOTICE_NVG",name)
			SendMessage(iPtd,2,1,msg,print_center)
			format(msg,127,"%L",LANG_PLAYER,"BTE_ZB3_NOTICE_NVG","")
			client_print(iPtd,print_center,msg)
			if(!g_nvg[iPtd]) client_cmd(iPtd,"nightvision")
		}*/
		if (iRandom <= 6)
		{
			/*bte_wpn_set_fullammo(iPtd)
			bte_wpn_give_grenade(iPtd)
			format(msg,127,"%L",LANG_PLAYER,"BTE_ZB3_NOTICE_AMMO",name)
			SendMessage(iPtd,2,1,msg,print_center)
			format(msg,127,"%L",LANG_PLAYER,"BTE_ZB3_NOTICE_AMMO","")
			client_print(iPtd,print_center,msg)*/
			//bte_wpn_set_ammo(iPtd,1,floatround(bte_wpn_get_wpn_data(iPtd,0,1,BTE_WPNDATA_AMMO,0,0)*1.5))
			//bte_wpn_set_ammo(iPtd,2,floatround(bte_wpn_get_wpn_data(iPtd,0,2,BTE_WPNDATA_AMMO,0,0)*1.5))
			//ExecuteForward(g_fwSupplyPickupAmmo, g_fwDummyResult, iPtd)

			new Float:health, Float:max_health, Float:armorvalue, Float:max_armor;
			pev(iPtd, pev_health, health);
			pev(iPtd, pev_armorvalue, armorvalue);

			armorvalue = armorvalue < 0.0 ? 0.0 : armorvalue;
			armorvalue += 200.0;
			health += 500.0;

			max_health = g_hero[iPtd] ? 3000.0 : 1500.0;
			max_armor = g_hero[iPtd] ? 500.0 : 300.0;

			health = health > max_health ? max_health : health;
			armorvalue = armorvalue > max_armor ? max_armor : armorvalue;

			set_pev(iPtd, pev_health, health);
			set_pev(iPtd, pev_max_health, max_health);
			set_pev(iPtd, pev_armorvalue, armorvalue);

			ClientPrintEX(iPtd, HUD_PRINTCENTER, "#CSBTE_SupplyBox_Pickup_Item_All", 1, 0, name, "#CSBTE_SupplyBox_Armor")
			ClientPrint(iPtd, HUD_PRINTCENTER, "#CSBTE_SupplyBox_Pickup_Item", "#CSBTE_SupplyBox_Armor")

			/*format(msg, 127, "%s", "BTE_ZB3_NOTICE_GOT_ITEM", name, wpncn)
			SendMessage(iPtd,2,1,msg,print_center)
			format(msg, 127, "%s", "BTE_ZB3_NOTICE_GOT_ITEM", "", wpncn)
			client_print(iPtd,print_center,msg)*/
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

			/*new wpncn[32];
			strtoupper(wpn);
			format(wpncn, 32, "%L", LANG_PLAYER, wpn);

			format(msg,127,"%L",LANG_PLAYER,"BTE_ZB3_NOTICE_GOT_ITEM", name, wpncn)
			SendMessage(iPtd,2,1,msg,print_center)
			format(msg,127,"%L",LANG_PLAYER,"BTE_ZB3_NOTICE_GOT_ITEM", "", wpncn)
			client_print(iPtd,print_center,msg)*/
		}
	}
	engfunc(EngFunc_RemoveEntity,iPtr)
	PlayEmitSound(iPtd, CHAN_WEAPON, SUPPLYBOX_SOUND_PICKUP)
	g_supplybox_count --
	return HAM_SUPERCEDE
}

public HamF_TouchWeaponBox(weapon, id)
{
	if (!is_user_connected(id))
		return HAM_IGNORED

	if (g_zombie[id])
		return HAM_SUPERCEDE

	return HAM_IGNORED
}

public HamF_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if (!g_newround || g_endround)
		return HAM_SUPERCEDE;

	if (!is_user_connected(victim) || !is_user_connected(attacker))
		return HAM_IGNORED;

	if (g_fNextRestoreHealth[victim] < get_gametime() + RESTORE_HEALTH_TIME)
		g_fNextRestoreHealth[victim] = get_gametime() + RESTORE_HEALTH_TIME;

	if (victim == attacker)
		return HAM_IGNORED;

	// ½©Ê¬¹¥»÷ÈËÀà
	if (g_zombie[attacker] && !g_zombie[victim])
	{
		new Float:health, Float:armorvalue;
		pev(victim, pev_health, health);
		pev(victim, pev_armorvalue, armorvalue);

		if (!(damage_type & (1 << 24)))
		{
			damage = 300.0;

			if (bte_zb5_is_using_zbskill(attacker))
				damage = 500.0;
		}

		// Í³¼ÆÉËº¦
		g_flDamageCount[attacker] += damage * 2.5;

		if (armorvalue > 0)
		{
			// µ±ÓÐ·Àµ¯ÒÂÊ±
			damage *= 0.5;

			armorvalue -= damage * 0.333;
			health -= damage;
		}
		else
		{
			// ½©Ê¬µÄÉËº¦ÈÎºÎÇé¿ö¶¼ÊÇ 300
			health -= damage;
		}

		if (health <= 0.0)
		{
			// ËÀÁË qwq
			ZombieInfectedHuman(attacker,  victim);
			CheckWinCondition();

			return HAM_SUPERCEDE;
		}
		else
		{
			// °Ñ TakeDamage µÄÉËº¦¸Ä³É 0 ÎªÁË±ÜÃâÆæ¹ÖµÄÇé¿ö
			set_pev(victim, pev_health, health);
			set_pev(victim, pev_armorvalue, armorvalue);

			SetHamParamFloat(4, 0.0);

			return HAM_IGNORED;
		}

	}

	// ½©Ê¬¹¥»÷ÈËÀà
	if (g_zombie[victim] && !g_zombie[attacker])
	{
		new Float:flDamage;
		flDamage = damage;
		flDamage = flDamage * g_flHumanAttack / g_flZombieDefence;

		if (g_hero[victim])
			flDamage *= 1.5;

		// ´ò¶Ï»ØÑª
		g_restore_health[victim] = 0;

		// Í³¼ÆÉËº¦
		g_flDamageCount[attacker] += flDamage * 1.0;

		/*new Float: fMoraleDamage = str_to_float(XDAMAGE[g_human_morale[attacker] + g_human_morale[0]]);

		if (get_user_weapon(attacker) != CSW_KNIFE || inflictor != attacker)
			fDamage *= fMoraleDamage;*/

		flDamage *= g_zombie_xdamage[victim][g_level[victim]-1];

		new Float:ammor;
		pev(victim, pev_armorvalue, ammor);

		if (ammor > 0.0)
		{
			ammor -= flDamage * 0.2 * 0.9;
			flDamage *= 0.9;
			set_pev(victim, pev_armorvalue, ammor);
		}

		flDamage = flDamage < 1.0 ? 1.0 : flDamage;

		SetHamParamFloat(4, flDamage);
	}

	return HAM_IGNORED
}

public HamF_Spawn_Player_Post(id)
{
	if (!is_user_alive(id) || !get_pdata_int(id, m_iTeam))
		return;

	if (task_exists(id + TASK_SPAWN))
		remove_task(id + TASK_SPAWN)

	SetRendering(id);
	StripWeapons(id);
	bte_wpn_give_named_wpn(id, "knife", 1);

	if(!g_zombie[id])
		bte_wpn_give_named_wpn(id, "usp", 1);

	PlayerRandomSpawn(id)

	if (g_zombie[id])
	set_pdata_int(id, m_iKevlar, 2);

	if (!g_zombie[id])
		Make_Human(id);

	set_pev(id, pev_skin, 0);
}

public HamF_Spawn_Player(id)
{
	if (!g_zombie[id])
		set_pdata_int(id, m_iTeam, TEAM_CT);

	return HAM_IGNORED;
}