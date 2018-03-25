// Made by Sh@de(Xiaobaibai)
// pev_euser1 = Gun<->GuillotineAmmo
// pev_euser2 = GuillotineAmmo->AttackingPlayer
// pev_fuser1 = GuillotineAmmo->TimeReturn

enum
{
	GUILLOTINE_START,
	GUILLOTINE_BACK,
}

public CGuillotine_Precache()
{
	precache_model("models/guillotine_projectile.mdl")
	precache_model("models/gibs_guilotine.mdl")
	precache_model("sprites/guillotine_lost.spr")
	precache_sound("weapons/guillotine_catch2.wav")
	precache_sound("weapons/janus9_wood1.wav")
	precache_sound("weapons/janus9_wood2.wav")
	precache_sound("weapons/janus9_metal1.wav")
	precache_sound("weapons/janus9_metal2.wav")
	precache_sound("weapons/janus9_stone1.wav")
	precache_sound("weapons/janus9_stone2.wav")
}

public CGuillotine_Deploy(id, iEnt, iId, iBteWpn)
{
	if(get_pdata_int(iEnt, m_iClip) > 0)
	{
		SendWeaponAnim(id, 3);
	}
	else
	{
		SendWeaponAnim(id, 4);
	}
	set_pev(iEnt, pev_euser1, 0);
}

public CGuillotine_GetWeaponModeIdle(id, iEnt)
{
	new pEntity = pev(iEnt, pev_euser1);
	if(pev_valid(pEntity))
	{
		if(pev(pEntity, pev_euser2))
			return 3;
		else
			return 2;
	}
	else
	{
		if(get_pdata_int(iEnt, m_iClip) > 0)
			return 0;
		else
			return 1;
	}
	return 0;
}

public CGuillotine_ItemPostFrame(id, iEnt, iId, iBteWpn)
{
	new pEntity = pev(iEnt, pev_euser1);
	if(pEntity && !pev_valid(pEntity) && get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0)
	{
		CGuillotine_Redraw(iEnt);
	}
}

public CGuillotine_PrimaryAttack(id, iEnt, iClip, iBteWpn)
{
	if (!iClip)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.2);

		return;
	}
	
	if(pev_valid(pev(iEnt, pev_euser1)))
	{
		return;
	}
	
	iClip--;
	set_pdata_int(iEnt, m_iClip, iClip);
	
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	
	SendWeaponAnim(id, 2);
	SendWeaponShootSound(id, FALSE, TRUE);
	set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.76);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.8);
	
	new pEntity = CGuillotineAmmo_Create();
	if (pEntity)
	{
		new Float:vecAngles[3], Float:vecPunchangle[3];
		new Float:vecSrc[3], Float:vecForward[3], Float:vecUp[3];
		new Float:vecVelocity[3]
		pev(id, pev_v_angle, vecAngles);
		pev(id, pev_punchangle, vecPunchangle);
		xs_vec_add(vecAngles, vecPunchangle, vecAngles);
		engfunc(EngFunc_MakeVectors, vecAngles);
		GetGunPosition(id, vecSrc);
		global_get(glb_v_forward, vecForward);
		global_get(glb_v_up, vecUp);
		xs_vec_mul_scalar(vecUp, 2.0, vecUp);
		xs_vec_sub(vecSrc, vecUp, vecSrc);
		set_pev(pEntity, pev_origin, vecSrc);
		set_pev(pEntity, pev_vuser1, vecForward)
		xs_vec_mul_scalar(vecForward, 1000.0, vecVelocity);
		engfunc(EngFunc_VecToAngles, vecForward, vecAngles);
		set_pev(pEntity, pev_angles, vecAngles);
		set_pev(pEntity, pev_velocity, vecVelocity);
		
		set_pev(pEntity, pev_owner, id);
		set_pev(pEntity, pev_euser1, iEnt);
		
	}
	set_pev(iEnt, pev_euser1, pEntity);
	
}

public CGuillotine_Catch(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer);
	
	new iClip = get_pdata_int(iEnt, m_iClip);
	iClip++;
	set_pdata_int(iEnt, m_iClip, iClip);
	
	SendWeaponAnim(id, 7);
	set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.0);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.03);
	
	set_pev(iEnt, pev_euser1, 0);
	
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	
	emit_sound(id, CHAN_ITEM, "weapons/guillotine_catch2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
}

public CGuillotine_Lost(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer);
	SendWeaponAnim(id, 8);
	set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.76);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.8);
}

public CGuillotine_Redraw(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer);
	
	set_pev(iEnt, pev_euser1, 0)
	
	SendWeaponAnim(id, 3);
	set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.0);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.03);
}

public CGuillotineAmmo_Create()
{
	new pEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	
	if (pEntity)
	{
		set_pev(pEntity, pev_classname, "d_guillotine");
		CGuillotineAmmo_Spawn(pEntity);
	}

	return pEntity;
}

public CGuillotineAmmo_Spawn(this)
{
	set_pev(this, pev_movetype, MOVETYPE_FLY);
	set_pev(this, pev_solid, SOLID_TRIGGER);
	set_pev(this, pev_gravity, 0.5);
	set_pev(this, pev_friction, 0.0);

	engfunc(EngFunc_SetModel, this, "models/guillotine_projectile.mdl");
	engfunc(EngFunc_SetSize, this, Float:{-1.44, -1.45, -1.3}, Float:{1.44, 1.45, 4.3});
	
	set_pev(this, pev_animtime, get_gametime())
	set_pev(this, pev_sequence, 0)
	set_pev(this, pev_framerate, 1.0)

	BTE_SetTouch(this, "CGuillotineAmmo_FireTouch");
	BTE_SetThink(this, "CGuillotineAmmo_ReturnThink");

	set_pev(this, pev_iuser1, GUILLOTINE_START);
	set_pev(this, pev_iuser2, 0);
	set_pev(this, pev_iuser3, 0);
	set_pev(this, pev_fuser1, get_gametime() + 0.73);
	set_pev(this, pev_nextthink, get_gametime());
}

public CGuillotineAmmo_MaterialSound(pEntity)
{
	new Float:vecOrigin[3], Float:vecSrc[3], Float:vecEnd[3], Float:vecDirection[3];
	pev(pEntity, pev_origin, vecOrigin);
	pev(pEntity, pev_vuser1, vecDirection);

	xs_vec_sub(vecOrigin, vecDirection, vecSrc);
	xs_vec_add(vecOrigin, vecDirection, vecEnd);

	switch (UTIL_TextureHit(UTIL_GetGlobalTrace(), vecSrc, vecEnd))
	{
		case 'W':	// wood
		engfunc(EngFunc_EmitAmbientSound, 0, vecOrigin, random_num(0, 1) ? "weapons/janus9_wood1.wav" : "weapons/janus9_wood2.wav", VOL_NORM, ATTN_NORM, 0, 96 + random_num(0, 15));

		case 'G', 'M', 'P':
		engfunc(EngFunc_EmitAmbientSound, 0, vecOrigin, random_num(0, 1) ? "weapons/janus9_metal1.wav" : "weapons/janus9_metal2.wav", VOL_NORM, ATTN_NORM, 0, 96 + random_num(0, 15));

		default:
		engfunc(EngFunc_EmitAmbientSound, 0, vecOrigin, random_num(0, 1) ? "weapons/janus9_stone1.wav" : "weapons/janus9_stone2.wav", VOL_NORM, ATTN_NORM, 0, 96 + random_num(0, 15));

	}
}

public CGuillotineAmmo_FireTouch(this, pOther)
{
	// Prevent bug when becoming zombie??
	new iEnt=pev(this, pev_euser1);
	new id = pev(this, pev_owner);
	if(!pev_valid(iEnt) || id != get_pdata_cbase(iEnt, m_pPlayer))
	{
		CGuillotineAmmo_Explode(this);
		return;
	}
	
	if(pOther == id)
		return;
	
	if(!is_user_alive(pOther))
	{
		CGuillotineAmmo_MaterialSound(this);
		if(pev(this, pev_iuser1) == GUILLOTINE_BACK)
		{
			CGuillotineAmmo_Explode(this);
			return;
		}
		else
		{
			BTE_SetTouch(this, "CGuillotineAmmo_FireTouch");
			BTE_SetThink(this, "CGuillotineAmmo_ReturnThink");
			set_pev(this, pev_nextthink, get_gametime());
			set_pev(this, pev_fuser1, get_gametime());
		}
	}
}

public CGuillotineAmmo_CheckDamage(this)
{
	new iEnt=pev(this, pev_euser1);
	new id = pev(this, pev_owner);
	new iBteWpn = WeaponIndex(iEnt);
	new bitsDamaged = pev(this, pev_iuser3);
	
	new Float:vecDirection[3], Float:vecOrigin[3], Float:vecVelocity[3];
	pev(this, pev_velocity, vecVelocity);
	pev(this, pev_origin, vecOrigin);
	xs_vec_normalize(vecVelocity, vecDirection)
	
	// TouchDamage
	new Float:vecEnd[3]
	xs_vec_mul_scalar(vecDirection, 39.37 * 0.5, vecDirection);
	xs_vec_add(vecOrigin, vecDirection, vecEnd);
	xs_vec_normalize(vecDirection, vecDirection)
	
	new ptr=create_tr2();
	engfunc(EngFunc_TraceLine, vecOrigin, vecEnd, 0, this, ptr);
	//engfunc(EngFunc_TraceHull, vecOrigin, vecEnd, DONT_IGNORE_MONSTERS, HULL_HEAD, this, ptr);
	//engfunc(EngFunc_TraceToss, this, this, ptr);
	//engfunc(EngFunc_TraceMonsterHull, this, vecOrigin, vecEnd, 0, this, ptr);
	
	new Float:vecEndPos[3];
	get_tr2(ptr, TR_vecEndPos, vecEndPos);
	new Float:flFraction
	get_tr2(ptr, TR_flFraction, flFraction);
	new iHitgroup = get_tr2(ptr, TR_iHitgroup);
	new pOther = get_tr2(ptr, TR_pHit);
	
	if(pev_valid(pOther) && pev(pOther, pev_takedamage))
	{
		if(pOther>32 || !(bitsDamaged & (1<<(pOther - 1))))
		{
			ClearMultiDamage();
			ExecuteHamB(Ham_TraceAttack, pOther, id, IS_ZBMODE ? c_flDamageZB[iBteWpn][0] : c_flDamage[iBteWpn][0], vecDirection, ptr, DMG_BULLET | DMG_NEVERGIB);
			ApplyMultiDamage(id, id);
		}
		
		if(pOther <= 32)
		{
			bitsDamaged |= (1<<(pOther - 1));
			set_pev(this, pev_iuser3, bitsDamaged);
		}
	}
	free_tr2(ptr);
	
	if(!is_user_alive(pOther))
	{
		return;
	}
	if (pev(this, pev_iuser1) == GUILLOTINE_START && IS_ZBMODE && iHitgroup == HIT_HEAD && !CheckTeammate(id, pOther) && pev(this, pev_iuser2) == 0)
	{
		set_pev(this, pev_euser2, pOther);
		BTE_SetTouch(this, "");
		BTE_SetThink(this, "CGuillotineAmmo_HeadCutThink");
		set_pev(this, pev_nextthink, get_gametime() + 0.001);
		set_pev(this, pev_dmgtime, get_gametime());
		
		set_pev(this, pev_animtime, get_gametime());
		set_pev(this, pev_framerate, 1.0);
		set_pev(this, pev_sequence, 1);
		
		new Float:vecOrigin2[3], Float:vecDelta[3]

		pev(pOther, pev_origin, vecOrigin2)
		xs_vec_sub(vecEndPos, vecOrigin2, vecDelta)
		set_pev(this, pev_vuser4, vecDelta);
		
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.1);
	}
}

public CGuillotineAmmo_HeadCutThink(this)
{
	// Prevent bug when becoming zombie??
	new iEnt=pev(this, pev_euser1);
	new id = pev(this, pev_owner);
	new iBteWpn = WeaponIndex(iEnt);
	if(!pev_valid(iEnt) || id != get_pdata_cbase(iEnt, m_pPlayer))
	{
		CGuillotineAmmo_Explode(this);
		return;
	}
	
	new Float:flDmgTime; pev(this, pev_dmgtime, flDmgTime);
	new iVictim = pev(this, pev_euser2);
	
	if(get_gametime() > flDmgTime)
	{
		new iDamagedTime = pev(this, pev_iuser2);
		
		if(iDamagedTime < 18 && is_user_alive(iVictim) && !CheckTeammate(id, iVictim))
		{
			set_pdata_int(iVictim, 75, HIT_HEAD);
			ExecuteHamB(Ham_TakeDamage, iVictim, this, id, IS_ZBMODE ? c_flDamageZB[iBteWpn][1] : c_flDamage[iBteWpn][1], DMG_BULLET);
			
			iDamagedTime++;
			set_pev(this, pev_iuser2, iDamagedTime);
			set_pev(this, pev_dmgtime, get_gametime() + 0.2);
		}
		else
		{
			BTE_SetTouch(this, "CGuillotineAmmo_FireTouch");
			BTE_SetThink(this, "CGuillotineAmmo_ReturnThink");
			set_pev(this, pev_nextthink, get_gametime());
			set_pev(this, pev_fuser1, get_gametime());
			
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.1);
			return;
		}
	}
	
	static Float:vecDelta[3], Float:vecHeadOrigin[3], Float:vecVelocity[3];
	pev(this, pev_vuser4, vecDelta);
	pev(iVictim, pev_origin, vecHeadOrigin);
	xs_vec_add(vecHeadOrigin, vecDelta, vecHeadOrigin)
	
	pev(iVictim, pev_velocity, vecVelocity);
	
	set_pev(this, pev_origin, vecHeadOrigin);
	set_pev(this, pev_velocity, vecVelocity);
	
	set_pev(this, pev_nextthink, get_gametime() + 0.001);
}

public CGuillotineAmmo_ReturnThink(this)
{
	new Float:flTimeReturn;
	pev(this, pev_fuser1, flTimeReturn);
	
	if(get_gametime()>flTimeReturn)
	{
		set_pev(this, pev_animtime, get_gametime());
		set_pev(this, pev_framerate, 1.0);
		set_pev(this, pev_sequence, 0);
		set_pev(this, pev_iuser1, GUILLOTINE_BACK);
		set_pev(this, pev_iuser3, 0);
		set_pev(this, pev_iuser4, 0);
		BTE_SetThink(this, "CGuillotineAmmo_FireThink");
		set_pev(this, pev_nextthink, get_gametime());
		return;
	}
	
	set_pev(this, pev_nextthink, get_gametime()+0.01);
	CGuillotineAmmo_CheckDamage(this);
	
}

public CGuillotineAmmo_FireThink(this)
{
	static id; id = pev(this, pev_owner)
	if(!is_user_alive(id))
	{
		CGuillotineAmmo_Explode(this);
		return;
	}
	static Float:vecOrigin[3], Float:vecOrigin2[3], Float:vecVelocity[3];
	pev(this, pev_origin, vecOrigin)
	pev(id, pev_origin, vecOrigin2)
	xs_vec_sub(vecOrigin2, vecOrigin, vecVelocity)
	if(xs_vec_len(vecVelocity) < 42.0)
	{
		CGuillotineAmmo_Catched(this)
		return;
	}
	
	xs_vec_normalize(vecVelocity, vecVelocity);
	xs_vec_mul_scalar(vecVelocity, 1000.0, vecVelocity);
	set_pev(this, pev_velocity, vecVelocity);
	
	
	set_pev(this, pev_nextthink, get_gametime()+0.01);
	CGuillotineAmmo_CheckDamage(this);
}

public CGuillotineAmmo_Catched(this)
{
	new id = pev(this, pev_owner)
	new iEnt = get_pdata_cbase(id, m_pActiveItem);
	if(iEnt != pev(this, pev_euser1))
	{
		CGuillotineAmmo_Explode(this);
	}
	else
	{
		SUB_Remove(this, 0.0);
		CGuillotine_Catch(iEnt);
	}
}

public CGuillotineAmmo_Explode(this)
{
	new id = pev(this, pev_owner)
	new iEnt = get_pdata_cbase(id, m_pActiveItem);
	SUB_Remove(this, 0.0);
	CGuillotine_Lost(iEnt);
	new Float:vecOrigin[3];
	pev(this, pev_origin, vecOrigin);
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, WEAPON_EVENT[CSW_KNIFE], 0.0, vecOrigin, {0.0, 0.0, 0.0}, 0.0 , 0.0, (1<<8), 0, FALSE, TRUE);
}