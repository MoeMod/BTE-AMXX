stock CountPlayer(iTeam, bAlive = FALSE)
{
	new iPlayer;
	
	for (new id = 1; id <= 32; id++)
	{
		if (!is_user_connected(id))
			continue;
		
		if (!is_user_alive(id) && bAlive)
			continue;
		
		if (get_pdata_int(id, m_iTeam) == iTeam || !iTeam)
			iPlayer ++;
	}
	
	return iPlayer;
}

stock StripWeapons(id)
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
	if (!pev_valid(ent)) return;
	
	dllfunc(DLLFunc_Spawn, ent)

	dllfunc(DLLFunc_Use, ent, id)
	if (pev_valid(ent)) engfunc(EngFunc_RemoveEntity, ent)
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

stock SendWeaponAnim(id, iAnim)
{
	if (!is_user_alive(id)) return;
	
	set_pev(id, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(iAnim)
	write_byte(pev(id, pev_body))
	message_end()
}

stock ClientPrint(id, type, message[], str1[] = "", str2[] = "", str3[] = "", str4[] = "")
{
	new dest
	if (id) dest = MSG_ONE
	else dest = MSG_ALL
	
	message_begin(dest, gmsgTextMsg, {0, 0, 0}, id)
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
