stock Message_HudTextPro(id, message[])
{
	message_begin(MSG_ONE, get_user_msgid("HudTextPro"), {0,0,0} ,id)
	write_string(message)
	write_byte(1)
	message_end()
}

stock SendMessage(id,iType,iTeam,szMsg[],iPos)
{
	// type 1 -- ALL
	// type 2 -- ALL but yourself
	// team 1  -- HM
	// team 2 -- ZB
	// team 0 -- all

	for(new i = 1;i<33 ; i++)
	{
		if(!is_user_connected(i)) continue
		if(!iTeam)
		{
			if(iType == 2 && id!=i)
			{
				client_print(i,iPos,szMsg)
			}
			else if(iType == 1) client_print(0,iPos,szMsg)
		}
		else
		{
			if(iTeam == 1 && !g_zombie[i])
			{
				if(iType == 2 && id!=i)
				{
					client_print(i,iPos,szMsg)
				}
				else if(iType == 1) client_print(0,iPos,szMsg)
			}
			else if(iTeam == 2 && g_zombie[i])
			{
				if(iType == 2 && id!=i)
				{
					client_print(i,iPos,szMsg)
				}
				else if(iType == 1) client_print(0,iPos,szMsg)
			}
		}
	}
}
stock SetBlockRound(iBlock)
{
	server_cmd("sv_noroundend %d",iBlock)
}
stock UpdateScoreBoard()
{
	/*static iZB,iHM
	iZB = Stock_GetPlayer(1)
	iHM = Stock_GetPlayer(0)
	for(new id= 1;id<33;id++)
	{
		if(MH_IsMetaHookPlayer(id))
		{
			MH_DrawScoreBoard(id,g_score_zombie, g_score_zombie+g_score_human+1, g_score_human, iZB, iHM ,1)
		}
	}*/
}
stock Stock_GetPlayer(iZombie = 0)
{
	new iNum
	for(new i=1;i<33;i++)
	{
		if(is_user_alive(i))
		{
			if(iZombie && g_zombie[i]) iNum++
			else if(!iZombie && !g_zombie[i]) iNum++
		}
	}
	return iNum
}
stock CreateBombKnockBack(iVictim,Float:vAttacker[3],Float:fMulti,Float:fRadius)
{
	new Float:vVictim[3];
	pev(iVictim, pev_origin, vVictim);

	xs_vec_sub(vVictim, vAttacker, vVictim);

	xs_vec_mul_scalar(vVictim, fMulti * 0.7, vVictim);
	xs_vec_mul_scalar(vVictim, fRadius / xs_vec_len(vVictim), vVictim);

	set_pev(iVictim, pev_velocity, vVictim);
}
stock ScreenShake(id, amplitude = 8, duration = 6, frequency = 18)
{
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
	write_short((1<<12)*amplitude)
	write_short((1<<12)*duration)
	write_short((1<<12)*frequency)
	message_end()
}
stock Float:EstimateDamage(Float:fPoint[3], ent, ignored)
{
	new Float:fOrigin[3]
	new tr
	new Float:fFraction
	pev(ent, pev_origin, fOrigin)
	//UTIL_TraceLine ( vecSpot, vecSpot + Vector ( 0, 0, -40 ),  ignore_monsters, ENT(pev), & tr)
	engfunc(EngFunc_TraceLine, fPoint, fOrigin, DONT_IGNORE_MONSTERS, ignored, tr)
	get_tr2(tr, TR_flFraction, fFraction)
	if ( fFraction == 1.0 || get_tr2( tr, TR_pHit ) == ent )//no valid enity between the explode point & player
		return 1.0
	return 0.6//if has fraise, lessen blast hurt
}
stock GiveZombieBomb(id)
{
	if(!g_zombie[id]) return
	bte_wpn_give_named_wpn(id,"hegrenade",1)

	message_begin(MSG_ONE,g_msgWeaponList, {0,0,0}, id);
	write_string("weapon_zombibomb")
	write_byte(WEAPON_AMMOID[CSW_HEGRENADE])
	write_byte(1)
	write_byte(-1)
	write_byte(-1)
	write_byte(3)
	write_byte(CSWPN_POSITION[CSW_HEGRENADE])
	write_byte(CSW_HEGRENADE)
	write_byte(0)
	message_end()
}
stock Float:fabs(Float:a)
{
	if(a>0) return a
	return -a
}
stock Nvg(id)
{
	MH_SendZB3Data(id, 12, 1);
	SetLight(id,"1");
	message_begin(MSG_ONE, g_msgScreenFade, _, id);
	write_short((1<<12)*2); // duration
	write_short((1<<10)*10); // hold time
	write_short(0x0004); // fade type
	if(g_zombie[id])
	{
		write_byte(NVG_ZOMBIE_R); // red
		write_byte(NVG_ZOMBIE_G); // green
		write_byte(NVG_ZOMBIE_B); // blue
		write_byte(NVG_ZOMBIE_A); // alpha
	}
	else
	{
		write_byte(NVG_HUMAN_R); // red
		write_byte(NVG_HUMAN_G); // green
		write_byte(NVG_HUMAN_B); // blue
		write_byte(NVG_HUMAN_A); // alpha
	}
	message_end();
}
/*stock NvgToggle(id,iToggle)
{
	if(!iToggle)
	{
		g_nvg[id] = 0
		new szLight[2]
		get_pcvar_string(Cvar_Light,szLight,2)
		remove_task(id+TASK_NVISION)
		SetLight(id,szLight)
		message_begin(MSG_ONE, g_msgScreenFade, _, id)
		write_short(0) // duration
		write_short(0) // hold time
		write_short(0x0000) // fade type
		write_byte(255) // red
		write_byte(100) // green
		write_byte(100) // blue
		write_byte(140) // alpha
		message_end()
	}
	else
	{
		if(!g_zombie[id]) return
		remove_task(id+TASK_NVISION)
		Task_Nvg(id+TASK_NVISION)
		SetLight(id,"1")
		set_task(1.0, "Task_Nvg", id+TASK_NVISION, _, _, "b")
	}
}*/
stock CreateSupplyBox()
{
	if (g_supplybox_count>=SUPPLYBOX_MAX || !g_newround || g_endround) return

	g_supplybox_count ++

	new iEnt = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
	set_pev(iEnt,pev_classname,SUPPLYBOX_CLASSNAME)
	engfunc(EngFunc_SetModel,iEnt,SUPPLYBOX_MODEL)
	engfunc(EngFunc_SetSize,iEnt,Float:{-2.0,-2.0,-2.0},Float:{5.0,5.0,5.0})
	set_pev(iEnt,pev_solid,1)
	set_pev(iEnt,pev_movetype,6)
	set_pev(iEnt,pev_iuser3,998) // tag
	set_pev(iEnt,pev_iuser2,998) // tag
	SupplyBoxRandomSpawn(iEnt)
}
stock SetLight(id,light[])
{
	if(!is_user_connected(id)) return

	message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, id)
	write_byte(0)
	write_string(light)
	message_end()
}
stock SetTeam(id, team)
{
	static params[1]
	params[0] = team
	if (task_exists(id+TASK_TEAM)) remove_task(id+TASK_TEAM)
	set_task(0.1, "Task_SetTeam", id+TASK_TEAM, params, sizeof params)
}
stock GetRandomPlayer(iTeam)
{
	// Perpare all available players
	new iCount,iSlot[33]
	for(new i = 1;i<33;i++)
	{
		if(is_user_alive(i))
		{
			iSlot[iCount] = i
			iCount++
		}
	}
	if(iTeam == 1) // Zombie
	{
		new iCounter
		for(new j=random_num(0,iCount-1);iCounter<iCount;iCounter++)
		{
			if(g_zombie[iSlot[j]]) return iSlot[j]
			j++
			if(j == iCount) j = 0
		}
		//PRINT("随机失败")
		return 0
	}
	if(iTeam == 2) // Human
	{

		new iCounter
		for(new j=random_num(0,iCount-1);iCounter<iCount;iCounter++)
		{
			if(!g_zombie[iSlot[j]])
			{
				return iSlot[j]
			}
			j++
			if(j == iCount) j = 0
		}
		//PRINT("随机失败")
		return 0
	}
	return 0
}

stock EffectZombieRespawn(id)
{
	static Float:origin[3];
	pev(id,pev_origin,origin);

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(TE_EXPLOSION); // TE_EXPLOSION
	write_coord(floatround(origin[0])); // origin x
	write_coord(floatround(origin[1])); // origin y
	write_coord(floatround(origin[2])); // origin z
	write_short(cache_spr_zombie_respawn); // sprites
	write_byte(10); // scale in 0.1's
	write_byte(20); // framerate
	write_byte(14); // flags
	message_end(); // message end
}
/*stock ZombieRestoreHealth(id)
{
	if (!g_zombie[id] || !g_newround || g_endround) return;
	static Float:velocity[3]
	pev(id, pev_velocity, velocity)

	if (!velocity[0] && !velocity[1] && !velocity[2])
	{
		if (!g_restore_health[id]) g_restore_health[id] = get_systime()
	}
	else g_restore_health[id] = 0

	if (g_restore_health[id])
	{
		new rh_time = get_systime() - g_restore_health[id]
		if (rh_time == RESTORE_HEALTH_TIME+1 && get_user_health(id) < g_zombie_health_start[id])
		{
			new health_add
			if (g_level[id]==1) health_add = RESTORE_HEALTH_LV1
			else health_add = RESTORE_HEALTH_LV2
			new health_new = get_user_health(id)+health_add
			health_new = min(health_new, g_zombie_health_start[id])
			set_pev(id, pev_health,float(health_new))
			g_restore_health[id] += 1

			//EffectRestoreHealth(id)

			new sound_heal[64]
			ArrayGetString(zombie_sound_heal, g_zombieclass[id], sound_heal, charsmax(sound_heal))
			PlaySound(id, sound_heal)
			if(MH_IsMetaHookPlayer(id)) MH_DrawAdditiveImage(id,1,1,"zombirecovery",0.13,1.05,255,255,255,3,1.0,-1,-1)
		}
	}
}*/
stock ZombieRestoreHealth(id)
{
	new Float:fCurTime;
	global_get(glb_time, fCurTime);

	static Float:velocity[3]
	pev(id, pev_velocity, velocity)

	if (vector_length(velocity))
	{
		//if (g_fNextRestoreHealth[id] < fCurTime + RESTORE_HEALTH_TIME)
		g_fNextRestoreHealth[id] = fCurTime + RESTORE_HEALTH_TIME;
	}

	//client_print(id, print_chat, "%f %f", fCurTime, g_fNextRestoreHealth[id])

	if (g_fNextRestoreHealth[id] <= fCurTime)
	{
		new health = get_user_health(id);
		if(health >= g_zombie_health_start[id])
		{
			g_fNextRestoreHealth[id] = fCurTime + RESTORE_HEALTH_TIME;
			return;
		}

		health += 200;

		health = health >= g_zombie_health_start[id] ? g_zombie_health_start[id] : health;

		set_pev(id, pev_health, float(health))

		g_fNextRestoreHealth[id] = fCurTime + 1.0;

		new sound_heal[64]
		ArrayGetString(zombie_sound_heal, g_zombieclass[id], sound_heal, charsmax(sound_heal))
		PlaySound(id, sound_heal)
		//if(MH_IsMetaHookPlayer(id)) MH_DrawAdditiveImage(id,1,1,"zombirecovery",0.13,1.05,255,255,255,3,1.0,-1,-1)
		//MH_SendZB3Data(id, 18, 0);
	}
}

stock UpdateEvolution(id, add)
{
	if (!g_zombie[id])
		return

	g_evolution[id] += add;
	CheckEvolution(id);
}
stock CheckEvolution(attacker)
{
	new evolution_max = 3;

	if (g_evolution[attacker] >= evolution_max && g_level[attacker] != 2) // LEVEL UP!
	{
		g_level[attacker] += 1

		g_evolution[attacker] = 0;

		new sound_ev[64]
		ArrayGetString(zombie_sound_evolution, g_zombieclass[attacker], sound_ev, charsmax(sound_ev))
		PlayEmitSound(attacker, CHAN_VOICE, sound_ev)

		// Update
		g_zombie_health_start[attacker] = 3500;
		g_zombie_armor_start[attacker] = 1000;

		UpdateHealthZombie(attacker)
		SetPlayerModel(attacker)
		SetZombieViewModel(attacker)
	}
}

stock UpdateFrags(player, num)
{
	if (!is_user_connected(player)) return;

	set_pev(player, pev_frags, float(pev(player, pev_frags) + num))
	message_begin(MSG_BROADCAST, g_msgScoreInfo)
	write_byte(player) // id
	write_short(pev(player, pev_frags)) // frags
	write_short(get_user_deaths(player)) // deaths
	write_short(0) // class?
	write_short(get_user_team(player)) // team
	message_end()
}
stock UpdateDeaths(player, num)
{
	if (!is_user_connected(player)) return;

	new deaths = get_user_deaths(player) + num
	cs_set_user_deaths(player, deaths)
	message_begin(MSG_BROADCAST, g_msgScoreInfo)
	write_byte(player) // id
	write_short(pev(player, pev_frags)) // frags
	write_short(deaths) // deaths
	write_short(0) // class?
	write_short(get_user_team(player)) // team
	message_end()
}
stock FixDeadAttrib(id)
{
	message_begin(MSG_BROADCAST, g_msgScoreAttrib)
	write_byte(id) // id
	write_byte(0) // attrib
	message_end()
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
stock Connect_Reset(id)
{
	g_respawning[id] = 0
	g_zombie[id] = 0
	g_hero[id] = 0
	g_zombieclass[id] = 0
	g_EnteredBuyMenu[id] = 0;
	MH_DrawRetina(id,"",0,1,1,1,0.0)
	MH_DrawRetina(id,"",0,1,1,2,0.0)

	set_task(1.0,"Task_ChangeTeam",id)
}
public Task_ChangeTeam(id)
{
	SetTeam(id, 2)
}
stock Set_Kvd(entity, const key[], const value[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	dllfunc(DLLFunc_KeyValue, entity, 0)
}
stock PlayEmitSound(id, type, const sound[])
{
	emit_sound(id, type, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}
stock SetZombieViewModel(id)
{
	if (!is_user_alive(id)) return
	if (!g_zombie[id]) return
	static iEnt
	iEnt = get_pdata_cbase(id,m_pActiveItem)
	if(iEnt < 0) return
	new current_weapon = get_pdata_int(iEnt,m_iId,4)
	if (current_weapon)
	{
		new hand
		hand = ArrayGetCell(zombie_hosthand, g_zombieclass[id])
		if (current_weapon == CSW_HEGRENADE)
		{
			new v_model[64]
			if(g_level[id]==1 && hand) ArrayGetString(zombiebom_viewmodel2, g_zombieclass[id], v_model, charsmax(v_model))
			else ArrayGetString(zombiebom_viewmodel, g_zombieclass[id], v_model, charsmax(v_model))

			set_pev(id, pev_viewmodel2, v_model)
			set_pev(id, pev_weaponmodel2, ZOMBIEBOMB_MODEL_P)
			//bte_wpn_set_playerwpn_model(id,1,ZOMBIEBOMB_MODEL_P,0,0)
		}
		else
		{
			new v_model[64]

			if(g_level[id]==1 && hand) ArrayGetString(zombie_wpnmodel2, g_zombieclass[id], v_model, charsmax(v_model))
			else ArrayGetString(zombie_wpnmodel, g_zombieclass[id], v_model, charsmax(v_model))

			set_pev(id, pev_viewmodel2, v_model)
			set_pev(id, pev_weaponmodel2, 0)
			//bte_wpn_set_playerwpn_model(id,0,ZOMBIEBOMB_MODEL_P,0,0)
		}
	}
}
stock SetPlayerModel(id)
{
	if (!is_user_connected(id)) return;
	if (g_zombie[id])
	{
		new model_view[64], model_index, idclass
		idclass = g_zombieclass[id]
		if (g_level[id] == 1)
		{
			ArrayGetString(zombie_viewmodel_host, idclass, model_view, charsmax(model_view))
			model_index = ArrayGetCell(zombie_modelindex_host, idclass)
		}
		else
		{
			ArrayGetString(zombie_viewmodel_origin, idclass, model_view, charsmax(model_view))
			model_index = ArrayGetCell(zombie_modelindex_origin, idclass)
		}

		bte_set_user_model(id, model_view)
		bte_set_user_model_index(id, model_index)
	}
	else if (g_hero[id])
	{
		new sex = bte_get_user_sex(id)
		if(sex==1)
		{
			bte_set_user_model(id, HERO_MODEL_MALE)
			bte_set_user_model_index(id, HERO_MODEL_MALE_INDEX)

		}
		else
		{
			bte_set_user_model(id, HERO_MODEL_FEMALE)
			bte_set_user_model_index(id, HERO_MODEL_FEMALE_INDEX)
		}
	}
	else
	{
		bte_reset_user_model(id)
	}
}

stock UpdateHealthZombie(id)
{
	if (!g_zombie[id]) return

	set_pev(id, pev_max_health, float(g_zombie_health_start[id]))
	set_pev(id, pev_health, float(g_zombie_health_start[id]))
	set_pev(id, pev_armorvalue, float(g_zombie_armor_start[id]))

}

public StripSlot(id, slot)
{
	new item = get_pdata_cbase(id, m_rgpPlayerItems[slot])

	while (item > 0)
	{
		static classname[24]
		pev(item, pev_classname, classname, charsmax(classname))
		set_pev(item, pev_nextthink, get_gametime() + 0.1)
		engclient_cmd(id, "drop", classname)

		item = get_pdata_cbase(item, m_pNext)
	}

	set_pdata_cbase(id, m_rgpPlayerItems[slot], -1)
}

native bte_wpn_strip_slot(id,iSlot)

stock StripWeapons(id/*, iRemoveAll = 1*/)
{
	/*StripSlot(id, 1)
	StripSlot(id, 2)
	StripSlot(id, 4)*/
	/*new weapons[32], num
	get_user_weapons(id, weapons, num)
	for (new i = 0; i < num; i++)
	{
		if (weapons[i] != CSW_KNIFE && weapons[i] != CSW_HEGRENADE)
		{
			set_pev(id,pev_weapons,(pev(id,pev_weapons)&~(1<<(weapons[i]))))
			new iEnt
			while((iEnt = engfunc(EngFunc_FindEntityByString,iEnt,"classname",WEAPON_NAME[weapons[i]])) && pev(iEnt,pev_owner) != id) {}
			if(iEnt)
			{
				ExecuteHamB(Ham_Weapon_RetireWeapon,iEnt)
				if(ExecuteHamB(Ham_RemovePlayerItem,id,iEnt))
				{
					ExecuteHamB(Ham_Item_Kill, iEnt)
				}
			}
		}
	}*/

	/*static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
	if (!pev_valid(ent)) return;

	dllfunc(DLLFunc_Spawn, ent)*/

	set_pev(id, pev_button, pev(id, pev_button) & ~IN_ATTACK & ~IN_ATTACK2)

	//if(iRemoveAll)
	dllfunc(DLLFunc_Use, g_player_weaponstrip, id)
	/*else
	{
		StripSlot(id, 1)
		StripSlot(id, 2)
	}*/
	//if (pev_valid(ent)) engfunc(EngFunc_RemoveEntity, ent)
}

stock Strip_Weapon2(id)
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
	if (!pev_valid(ent)) return;

	dllfunc(DLLFunc_Spawn, ent)
	dllfunc(DLLFunc_Use, ent, id)
	if (pev_valid(ent)) engfunc(EngFunc_RemoveEntity, ent)
}

stock RemoveNamedEntity(const name[])
{
	new ent = -1
	while((ent = engfunc( EngFunc_FindEntityByString, ent, "classname", name)))
	{
		set_pev(ent, pev_effects, EF_NODRAW);
		set_pev(ent, pev_flags, pev(ent, pev_flags) | FL_KILLME);
	}
}
stock SendCenterText(id, message[])
{
	new dest
	if (id) dest = MSG_ONE
	else dest = MSG_ALL

	message_begin(dest, g_msgTextMsg, {0,0,0}, id)
	write_byte(4)
	write_string(message)
	message_end()
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
stock Str_Count(const str[], searchchar)
{
	new count, i, len = strlen(str)
	for (i = 0; i <= len; i++)
	{
		if(str[i] == searchchar)
			count++
	}
	return count
}
stock RoundStartValue(id)
{
	if (task_exists(id+TASK_SPAWN)) remove_task(id+TASK_SPAWN)
	if (task_exists(id+TASK_ZOMBIE_RESPAWN)) remove_task(id+TASK_ZOMBIE_RESPAWN)
	if (task_exists(id+TASK_ZOMBIE_RESPAWN_EF)) remove_task(id+TASK_ZOMBIE_RESPAWN_EF)
	if (task_exists(id+TASK_NVISION)) remove_task(id+TASK_NVISION)
	remove_task(id+TASK_NVISION)

	g_zombie_health_start[id] = 0

	g_level[id] = 0
	g_zombie[id] = 0
	g_hero[id] = 0
	g_evolution[id] = 0
	g_restore_health[id] = 0
	g_respawning[id] = 0
	g_nvg[id] = 0
	g_havenvg[id] = 0
	g_zombie_die[id] = 0

	g_flDamageCount[id] = 0;

	if (is_user_alive(id))
	{
		SetRendering(id)
		set_pev(id, pev_gravity, 1.0)
	}
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
stock CheckHull(Float:origin[3], hull)
{
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0)

	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true;

	return false;
}
stock GetPlayersNum()
{
	new iTotal = 0;
	for(new i=1;i<=32;i++)
		if(is_user_connected(i)) iTotal += 1;
	return iTotal;
}

stock PlayInfectedSound(victim)
{
	new sound[64], sex
	sex = bte_get_user_sex(victim);
	if (sex == 2)
		ArrayGetString(sound_female_death, random(ArraySize(sound_female_death)), sound, charsmax(sound));
	else
		ArrayGetString(sound_human_death, random(ArraySize(sound_human_death)), sound, charsmax(sound));

	PlayEmitSound(victim, CHAN_VOICE, sound);
}

stock SetAccount(id, amount)
{
	OrpheuCallSuper(handleAddAccount, id, amount, TRUE);
}

stock ClientPrint(id, type, message[], str1[] = "", str2[] = "", str3[] = "", str4[] = "")
{
	new dest
	if (id) dest = MSG_ONE_UNRELIABLE
	else dest = MSG_ALL

	message_begin(dest, g_msgTextMsg, {0, 0, 0}, id)
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

stock ClientPrintEX(id, type, message[], target, team, str1[] = "", str2[] = "", str3[] = "", str4[] = "")
{
	// target 0 -- ALL
	// target 1 -- ALL except yourself

	// team 0 -- all
	// team 1 -- HM
	// team 2 -- ZB

	for (new i = 1; i < 33; i++)
	{
		if (!is_user_connected(i))
			continue;

		if ((target == 1 && id != i) || target == 0)
		{
			if (team == 0 || (team == 2 && g_zombie[i]) || (team == 1 && !g_zombie[i]))
				ClientPrint(id, type, message, str1, str2, str3, str4)
		}
	}
}