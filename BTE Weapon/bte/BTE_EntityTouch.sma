public TouchPlasmaBall(id, pEntity, iPtd, iBteWpn)
{
	new Float:vecOrigin[3], Float:vecOrigin2[3];
	pev(pEntity, pev_origin, vecOrigin);
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord,vecOrigin[0]);
	engfunc(EngFunc_WriteCoord,vecOrigin[1]);
	engfunc(EngFunc_WriteCoord,vecOrigin[2]);
	write_short(g_cache_plasmabomb)
	write_byte(5)
	write_byte(255)
	message_end()

	emit_sound(pEntity, CHAN_WEAPON, "weapons/plasmagun_exp.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	new Float:flDamageMax = !IS_ZBMODE ? c_flEntityDamage[iBteWpn][0] : c_flEntityDamageZB[iBteWpn][0];
	
	if (iPtd != id)
	{
		if (is_user_alive(iPtd))
			set_pdata_int(iPtd, 75, 2);
		
		if (!(pev(iPtd, pev_spawnflags) & SF_BREAK_TRIGGER_ONLY))
			ExecuteHamB(Ham_TakeDamage, iPtd, pEntity, id, flDamageMax, DMG_CLUB);
	}

	new iVictim = -1;
	while ((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, vecOrigin, c_flEntityRange[iBteWpn][0])) != 0)
	{
		if (pev(iVictim, pev_takedamage) == DAMAGE_NO)
			continue;
		
		if (iVictim == id || iVictim == iPtd)
			continue;
			
		if (pev(iVictim, pev_spawnflags) & SF_BREAK_TRIGGER_ONLY)
			continue;
		
		if (IsPlayer(iVictim))
			if(get_pdata_int(id, m_iTeam) == get_pdata_int(iVictim, m_iTeam) && !get_pcvar_num(cvar_friendlyfire))
				continue;
		
		GetOrigin(iVictim, vecOrigin2);
		
		new Float:fDistance = get_distance_f(vecOrigin, vecOrigin2);
		
		fDistance = fDistance - 30.0;
		fDistance = fDistance < 0.0 ? 0.0 : fDistance;
		
		new Float:flDamage = flDamageMax - flDamageMax * (fDistance / c_flEntityRange[iBteWpn][0]);
		
		if (flDamage < 1.0)
			flDamage = 1.0;
			
		if (is_user_alive(iVictim))
			set_pdata_int(iVictim, 75, 2);
			
		ExecuteHamB(Ham_TakeDamage, iVictim, pEntity, id, flDamage, DMG_CLUB);
	}
	
	RemoveEntity(pEntity);
}

public TouchFirecraker(pEntity)
{
	new sound[32];

	switch (random_num(0, 2))
	{
		case 0 : format(sound, charsmax(sound), "weapons/firecracker_bounce1.wav");
		case 1 : format(sound, charsmax(sound), "weapons/firecracker_bounce2.wav");
		case 2 : format(sound, charsmax(sound), "weapons/firecracker_bounce3.wav");
	}

	emit_sound(pEntity, CHAN_ITEM, sound, 1.0, ATTN_NORM, 0, PITCH_NORM);
}

public TouchBolt(id, pEntity, iVictim, iBteWpn)
{
	if (iVictim <= 0)
	{
		EntityTouchDecal(pEntity);
		RemoveEntity(pEntity);

		return;
	}

	EntityTouchDamage(pEntity, id, !IS_ZBMODE ? c_flEntityDamage[iBteWpn][0] : c_flEntityDamageZB[iBteWpn][0]);

	if (IsAlive(iVictim) || !iVictim)
		SendTempEntity(pEntity, 0, iVictim);

	RemoveEntity(pEntity);
}

public TouchPetrolBoom(id, pEntity, iVictim, iBteWpn)
{
	set_pev(pEntity, pev_model, 0);
	set_pev(pEntity, pev_movetype, MOVETYPE_NONE);		
	set_pev(pEntity, pev_solid, SOLID_NOT);
	set_pev(pEntity, pev_effects, pev(pEntity, pev_effects) | EF_NODRAW);

	new Float:vecOrigin[3];
	pev(pEntity, pev_origin, vecOrigin);

	SendExplosion(pEntity, vecOrigin, 4);

	set_pev(pEntity, pev_nextthink, get_gametime());

	new Float:flDamage;
	if (!IS_ZBMODE)
		flDamage = c_flEntityDamage[iBteWpn][0];
	else
		flDamage = c_flEntityDamageZB[iBteWpn][0];

	RadiusDamage(vecOrigin, pEntity, id, flDamage, c_flEntityRange[iBteWpn][0], 0.0, DMG_EXPLOSION, TRUE, TRUE);
}