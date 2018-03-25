public Forward_ClientKill(id)
{
	return FMRES_SUPERCEDE
}
/*
public Forward_SetModel(entity, const model[])
{
	if (strlen(model) < 8) return FMRES_IGNORED
	static attacker
	attacker = pev(entity, pev_owner)
	if (g_zombie[attacker])
	{
		if (model[9] == 'h' && model[10] == 'e') 
		{
			new Float:vecVelocity[3]
			vecVelocity[0] = random_float(-300.0, 300.0)
			vecVelocity[1] = random_float(-300.0, 300.0)
			vecVelocity[2] = random_float(-300.0, 300.0)
			set_pev(entity, pev_avelocity, vecVelocity)
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_INFECTION)
			engfunc(EngFunc_SetModel, entity, ZOMBIEBOMB_MODEL_W)
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}
*/

public Forward_SetModel(iEntity, const szModel[])
{
	// We don't care
	if (strlen(szModel) < 8)
		return FMRES_IGNORED
		
	// Narrow down our matches a bit
	if (szModel[7] != 'w' || szModel[8] != '_')
		return FMRES_IGNORED
	
	// Get damage time of grenade
	new Float:flDmgTime
	pev(iEntity, pev_dmgtime, flDmgTime)
		
	new id = pev(iEntity, pev_owner)
	
	if (szModel[9] == 'h' && szModel[10] == 'e' && szModel[11] == 'g')
	{
		if (flDmgTime == 0.0 && g_zombie[id])
		{
			set_pev(iEntity, pev_effects, EF_NODRAW);
			set_pev(iEntity, pev_flags, pev(iEntity, pev_flags) | FL_KILLME);
			return FMRES_IGNORED
		}
		else if(g_zombie[id])
		{
			set_pev(iEntity, PEV_NADE_TYPE, NADE_TYPE_ZOMBIEBOMB)
			engfunc(EngFunc_SetModel, iEntity, ZOMBIEBOMB_MODEL_W)
			set_pev(iEntity, pev_sequence, random_num(1,3))
			set_pev(iEntity, pev_frame, 0.0)
			set_pev(iEntity, pev_framerate, 10.0)
			set_pev(iEntity, pev_animtime, get_gametime())
			set_pev(iEntity, pev_dmgtime, get_gametime() + 1.6)
			set_pev(iEntity, pev_nextthink, get_gametime() + 0.05)
			set_pev(iEntity, pev_mins, Float:{-1.0, -1.0, -1.0})
			set_pev(iEntity, pev_maxs, Float:{1.0, 1.0, 1.0})
			return FMRES_SUPERCEDE
		}
		else if(flDmgTime != 0.0)
		{
			set_pev(iEntity, PEV_NADE_TYPE, NADE_TYPE_HEGRENADE)
			return FMRES_IGNORED
		}
	}
	else if (szModel[9] == 'f' && szModel[10] == 'l' && szModel[11] == 'a')
	{
		if (flDmgTime == 0.0 && g_zombie[id])
		{
			set_pev(iEntity, pev_effects, EF_NODRAW);
			set_pev(iEntity, pev_flags, pev(iEntity, pev_flags) | FL_KILLME);
			return FMRES_IGNORED
		}
		else if(flDmgTime != 0.0)
		{
			set_pev(iEntity, PEV_NADE_TYPE, NADE_TYPE_FLASHBANG)
			return FMRES_IGNORED
		}
	}
	else if (szModel[9] == 's' && szModel[10] == 'm' && szModel[11] == 'o')
	{
		if (flDmgTime == 0.0 && g_zombie[id])
		{
			set_pev(iEntity, pev_effects, EF_NODRAW);
			set_pev(iEntity, pev_flags, pev(iEntity, pev_flags) | FL_KILLME);
			return FMRES_IGNORED
		}
		else if(g_zombie[id])
		{
			//BitsUnSet(g_bitsHasZombieBomb2, id)
			set_pev(iEntity, PEV_NADE_TYPE, NADE_TYPE_ZOMBIEBOMB2)
			set_pev(iEntity, pev_skin, 1)
			engfunc(EngFunc_SetModel, iEntity, ZOMBIEBOMB_MODEL_W)
			set_pev(iEntity, pev_sequence, random_num(1,3))
			set_pev(iEntity, pev_frame, 0.0)
			set_pev(iEntity, pev_framerate, 10.0)
			set_pev(iEntity, pev_animtime, get_gametime())
			set_pev(iEntity, pev_dmgtime, get_gametime() + 5.0)
			set_pev(iEntity, pev_nextthink, get_gametime() + 0.05)
			set_pev(iEntity, pev_mins, Float:{-1.0, -1.0, -1.0})
			set_pev(iEntity, pev_maxs, Float:{1.0, 1.0, 1.0})
			return FMRES_SUPERCEDE
		}
		else if(flDmgTime != 0.0)
		{
			set_pev(iEntity, PEV_NADE_TYPE, NADE_TYPE_SMOKEGRENADE)
			return FMRES_IGNORED
		}
	}
	return FMRES_IGNORED
}

public Forward_Spawn(entity)
{
	if (!pev_valid(entity)) return FMRES_IGNORED;
	new classname[32], objective[32], size = ArraySize(g_objective_ents)
	pev(entity, pev_classname, classname, charsmax(classname))
	for (new i = 0; i < size; i++)
	{
		ArrayGetString(g_objective_ents, i, objective, charsmax(objective))
		if (equal(classname, objective))
		{
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}
public Forward_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	// Block all those unneeeded hostage sounds
	if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
		return FMRES_SUPERCEDE;
	
	// Zombie Grenade Hit Ground
	if(sample[0] == 'w' && sample[1] == 'e' && sample[2] == 'a' && sample[3] == 'p' && sample[4] == 'o' && sample[5] == 'n' && sample[6] == 's')
	{
		if(sample[7] == 'g' && sample[8] == 'r' && sample[9] == 'e' && sample[10] == 'n' && sample[11] == 'a' && sample[12] == 'd' && sample[13] == 'e')
		{
			if(sample[14] == '_' && sample[15] == 'h' && sample[16] == 'i' && sample[17] == 't')
			{
				static iType; iType = pev(id, PEV_NADE_TYPE)
				if(iType == NADE_TYPE_ZOMBIEBOMB||iType == NADE_TYPE_ZOMBIEBOMB2)
				{
					emit_sound(id, channel, ZOMBIEBOM_SOUND_HIT[random_num(0, 1)] , volume, attn, flags, pitch)

					return FMRES_SUPERCEDE;
				}
			}
		}
	}
	
	// Replace these next sounds for zombies only
	if (!is_user_connected(id) || !g_zombie[id])
		return FMRES_IGNORED;
	
	static sound[64]
	
	// Zombie being hit
	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't' ||
	sample[7] == 'h' && sample[8] == 'e' && sample[9] == 'a' && sample[10] == 'd')
	{
		if (g_level[id]==1) ArrayGetString(zombie_sound_hurt1, g_zombieclass[id], sound, charsmax(sound))
		else ArrayGetString(zombie_sound_hurt2, g_zombieclass[id], sound, charsmax(sound))
		emit_sound(id, channel, sound, volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}
	
	// Zombie dies
	if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
	{
		if (g_level[id]==1) ArrayGetString(zombie_sound_death1, g_zombieclass[id], sound, charsmax(sound))
		else ArrayGetString(zombie_sound_death2, g_zombieclass[id], sound, charsmax(sound))
		emit_sound(id, channel, sound, volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}
public Forward_PlayerPostThink(id)
{
	if (!g_zombie[id] && is_user_alive(id))
	{
		g_iAdditionMorale[id] = 0;
		
		for(new i = 0; i < 33; i++)
		{
			if(!is_user_alive(i))
				continue
			if(g_zombie[i])
				continue
			if(i == id)
				continue
			if(fm_entity_range(i, id) > 230.0)
				continue
			g_iAdditionMorale[id]++
			if(g_iAdditionMorale[id] == 12) 
				break;
		}

		if (g_bCanReadyToBeZombies)
		{
			if (g_readyzombie[id])
			{
				if (pev(id, pev_button) & IN_USE)
				{
					new iInGame
					for(new i =1;i<33;i++)
					{
						if (is_user_connected(i) && is_user_alive(i))
							iInGame++;
					}
					if (!iInGame)
						return FMRES_IGNORED;
					new iZombieNum = iInGame / 10 + 1;
					new Float:fMaxHealth = 1000.0 * iInGame / iZombieNum;

					if(!g_zombieclass[id] || is_user_bot(id))
						g_zombieclass[id] = random(class_count);

					Make_Zombie2(id,fMaxHealth, 1);
					ExecuteForward(g_fwUserInfected, g_fwDummyResult, id, 33);
					SetRendering(id);

					set_pev(id, pev_button, pev(id, pev_button) & ~IN_USE);
					set_pev(id, pev_oldbuttons, pev(id, pev_oldbuttons) | IN_USE);

					g_readyzombie[id] = 0;

					new sound[64];

					ArrayGetString(sound_zombie_coming, random(ArraySize(sound_zombie_coming)), sound, charsmax(sound))
					PlaySound(0, sound)
				}
			}
		}
	}

	if(!g_zombie[id]) return FMRES_IGNORED;
	if(pev(id, pev_deadflag) != DEAD_NO) return FMRES_IGNORED;
	
	ZombieRestoreHealth(id);
	DNA_RageEnvyThink(id);
	
	if (g_flMaxSpeed[id])
	{
		set_pev(id, pev_maxspeed, g_flMaxSpeed[id]);
		//set_pev(id, pev_maxspeed, g_flMaxSpeed[id] * (1.0 + (float(get_user_health(id) % (g_iZombieMaxHealth[id] * 7 / 100)) * 0.025)));
	}
		

	return FMRES_IGNORED
}

/*public Forward_CmdStart(id, uc_handle, seed)
{			
	if (!is_user_alive(id)) return FMRES_IGNORED
	if(g_zombie[id]) ZombieRestoreHealth(id)
	
	return FMRES_IGNORED
}*/

/*public bte_wpn_buy_wpn(id,iSlot)
{
    set_task(0.1, "Task_HideMoney", id+TASK_SPAWN)
}*/