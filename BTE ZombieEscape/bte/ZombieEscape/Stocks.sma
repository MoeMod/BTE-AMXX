//[]
stock Stock_UpdateScore(id,iFrag,iNum)
{
	if (!is_user_connected(id)) return;
	if(iFrag)
	{
		set_pev(id, pev_frags, float(pev(id, pev_frags) + iNum))
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte(id) // id
		write_short(pev(id, pev_frags)) // frags
		write_short(get_user_deaths(id)) // deaths
		write_short(0) // class?
		write_short(get_user_team(id)) // team
		message_end()
	}
	else
	{
		new deaths = get_user_deaths(id) + iNum
		cs_set_user_deaths(id, deaths)
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte(id) // id
		write_short(pev(id, pev_frags)) // frags
		write_short(get_user_deaths(id)) // deaths
		write_short(0) // class?
		write_short(get_user_team(id)) // team
		message_end()
	}
}
stock Stock_InfectMsg(attacker, victim)
{
	message_begin(MSG_BROADCAST, g_msgDeathMsg)
	write_byte(attacker) // killer
	write_byte(victim) // victim
	write_byte(0) // headshot flag
	write_string("knife") // killer's weapon
	message_end()
	message_begin(MSG_BROADCAST, g_msgScoreAttrib)
	write_byte(victim) // id
	write_byte(0) // attrib
	message_end()
}
stock Stock_Check_End_Game() // Zombie Infection
{
	new iHuman
	for(new i = 1;i<33;i++)
	{
		if(is_user_connected(i) && is_user_alive(i))
		{
			if(!g_zombie[i]) iHuman++
		}
	}
	if(iHuman) return 0
	return 1
}
	
stock Stock_Str_Count(const str[], searchchar)
{
	new count, i, len = strlen(str)
	
	for (i = 0; i <= len; i++)
	{
		if(str[i] == searchchar)
			count++
	}
	
	return count;
}
stock Stock_Check_Hull(Float:origin[3], id)
{	
	static iTr
	new hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id,iTr)
	
	if (!get_tr2(iTr, TR_StartSolid) && !get_tr2(iTr, TR_AllSolid)/* && get_tr2(0, TR_InOpen)*/)
	{
		return true;
	}
	else
	{
		return false;
	}
}
stock Stock_PlaySound(id, const sound[])
{
	if (equal(sound[strlen(sound)-4], ".mp3"))
	{
		client_cmd(id,"mp3 stop")
		client_cmd(id, "mp3 play sound/%s", sound)
	}
	else
		client_cmd(id, "spk %s", sound)
}
stock Stock_Strip_Weapon(id)
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
	if (!pev_valid(ent)) return;
	
	dllfunc(DLLFunc_Spawn, ent)
	dllfunc(DLLFunc_Use, ent, id)
	if (pev_valid(ent)) engfunc(EngFunc_RemoveEntity, ent)
}
stock Stock_Off_FlashLight(id)
{
	// Restore batteries for the next use
	set_pdata_int(id, OFFSET_FLASHLIGHT_BATTERY, 100, OFFSET_LINUX)
	
	// Check if flashlight is on
	if (pev(id, pev_effects) & EF_DIMLIGHT)
	{
		// Turn it off
		set_pev(id, pev_impulse, IMPULSE_FLASHLIGHT)
	}
	else
	{
		// Clear any stored flashlight impulse (bugfix)
		set_pev(id, pev_impulse, 0)
	}
	
	// Update flashlight HUD
	message_begin(MSG_ONE, get_user_msgid("Flashlight"), _, id)
	write_byte(0) // toggle
	write_byte(100) // battery
	message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1034\\ f0\\ fs16 \n\\ par }
*/
