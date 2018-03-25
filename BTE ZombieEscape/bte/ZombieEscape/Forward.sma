//[]

public Forward_TraceLine_Post(Float:vecStart[3], vecEnd[3], iNoMonsters, iAttacker, iTr)
{
	if (!is_user_alive(iAttacker)) return FMRES_IGNORED;
	//if(!MH_IsMetaHookPlayer(iAttacker)) return FMRES_IGNORED;
	
	if(g_tr_time[iAttacker] < get_gametime())
	{
		g_tr_time[iAttacker] = get_gametime()
		
		static iEnt ; iEnt = get_tr2(iTr,TR_pHit)
		if(!pev_valid(iEnt)) return FMRES_IGNORED;
		static Name[32]
		pev(iEnt,pev_classname,Name,31)
		if(pev(iEnt,pev_spawnflags)&SF_BREAK_TRIGGER_ONLY) return FMRES_IGNORED;
		if(equal(Name,"func_breakable"))
		{
			new hp=pev(iEnt,pev_health)
			new sz[64]
			format(sz,63,"%L",LANG_PLAYER,"MSG_WALLHEALTH",hp)
			MH_DrawText(iAttacker,0,sz,0.01,0.7,255,180,30,2.0,22)
		}
		return FMRES_IGNORED;
	}
	return FMRES_IGNORED;
}
public Forward_ClientKill(id)
{
	if(!is_user_bot(id)) return FMRES_SUPERCEDE
	return FMRES_IGNORED
}
public Forward_AddToFullPack_Post(es, e, ent, host, hostflags, player, pSet)
{
	if(!get_orig_retval() || !is_user_alive(host) || !g_start)
	{
		return FMRES_IGNORED
	}
	if(player)
	{
		if(host != ent)
		{
			set_es(es, ES_Solid, SOLID_NOT)
			 	
			static Float:flDistance
			flDistance = entity_range(host, ent)
			if(flDistance < 70.0) 
			{
				set_es(es, ES_RenderMode, kRenderTransAlpha)
				set_es(es, ES_RenderAmt, floatround(flDistance)*3)
			}
		}
	}
	else
	{
		static owner ; owner = pev(ent, pev_aiment)
		if((0 < owner <33) && pev(ent,pev_euser3) && is_user_alive(owner))
		{    
			set_es(es, ES_Solid, SOLID_NOT)
			static Float:flDistance
			flDistance = entity_range(host, owner)
			if(flDistance < 70.0)
			{
				set_es(es, ES_RenderMode, kRenderTransAlpha)
				set_es(es, ES_RenderAmt, floatround(flDistance)*3)
			}
		}
	}
}
public Forward_Spawn(iEnt)
{
	if (!pev_valid(iEnt)) return FMRES_IGNORED;
	
	// Get classname
	new classname[32]
	pev(iEnt, pev_classname, classname, charsmax(classname))
	new size = sizeof (g_block_entity) 
	
	// Check whether it needs to be removed
	for (new i = 0; i < size; i++)
	{
		if (equal(classname, g_block_entity[i]))
		{
			engfunc(EngFunc_RemoveEntity, iEnt)
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}
public Forward_PlayerPreThink(id)
{
	if(!is_user_alive(id)) return FMRES_IGNORED
	if(g_freezetime) set_pev(id,pev_maxspeed,0.1)
	if(!g_zombie[id]) return FMRES_IGNORED
	
	set_pev(id,pev_maxspeed,280.0)
	return FMRES_IGNORED
}
public Forward_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
		return FMRES_SUPERCEDE;
	
	if (!is_user_connected(id) || !g_zombie[id])
		return FMRES_IGNORED;

	// Zombie being hit
	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't' ||
	sample[7] == 'h' && sample[8] == 'e' && sample[9] == 'a' && sample[10] == 'd')
	{
		emit_sound(id, channel, res_sound_zbhurt[random_num(0,1)], volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}
	
	// Zombie dies
	/*if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
	{
		if (g_level[id]==1) ArrayGetString(zombie_sound_death1, g_zombieclass[id], sound, charsmax(sound))
		else ArrayGetString(zombie_sound_death2, g_zombieclass[id], sound, charsmax(sound))
		emit_sound(id, channel, sound, volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}*/

	if (equal(sample,"weapons/knife_hitwall1.wav"))
	{
		emit_sound(id, channel, res_sound_zbhitwall[random_num(0,2)], volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}
		
	else if (equal(sample,"weapons/knife_hit1.wav") ||
	equal(sample,"weapons/knife_hit3.wav") ||
	equal(sample,"weapons/knife_hit2.wav") ||
	equal(sample,"weapons/knife_hit4.wav") ||
	equal(sample,"weapons/knife_stab.wav"))
	{
		emit_sound(id, channel, res_sound_zbhit[random_num(0,2)], volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}
	else if(equal(sample,"weapons/knife_slash1.wav") ||
	equal(sample,"weapons/knife_slash2.wav"))
	{
		emit_sound(id, channel, res_sound_zbswing[random_num(0,2)], volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}
	return FMRES_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1034\\ f0\\ fs16 \n\\ par }
*/
