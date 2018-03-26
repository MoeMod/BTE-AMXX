enum
{
	CANNONEX_STATUS_MODEA = 0,
	CANNONEX_STATUS_TRANSFORM,
	CANNONEX_STATUS_FIRE,
	CANNONEX_STATUS_MODEB,
	CANNONEX_STATUS_RELOAD,
	CANNONEX_STATUS_RELOAD2
}

public CCannonex_Precache()
{
	precache_model("models/p_cannonexb.mdl")
	precache_model("models/cannonexdragon.mdl")
	precache_model("models/w_cannonexb.mdl")
	//precache_model("models/p_cannonexdragonfx.mdl")
	precache_model("sprites/ef_cannonex.spr")
}

public CCannonex_Deploy(id, iEnt, iId, iBteWpn)
{
	
	if(pev(iEnt, pev_iuser2) == CANNONEX_STATUS_TRANSFORM)
	{
		set_pev(iEnt, pev_iuser2, CANNONEX_STATUS_MODEA)
	}
	
	if(pev(iEnt, pev_iuser2) != CANNONEX_STATUS_MODEA)
	{
		SendWeaponAnim(id, 3);
		set_pev(iEnt, pev_iuser2, CANNONEX_STATUS_MODEB)
	}
	else
	{
		SendWeaponAnim(id, 2);
	}
}

public CCannonex_Holster(id, iEnt, iId, iBteWpn)
{
	new pEntity = -1
	while ((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "cannonex_dragon")) && pev(pEntity, pev_owner) == id)
		set_pev(pEntity, pev_fuser1, get_gametime() + 0.05);
	set_pev(iEnt, pev_iuser1, 0);
}

public CCannonex_WeaponIdle(id, iEnt, iId, iBteWpn)
{
	if(get_pdata_float(iEnt, m_flTimeWeaponIdle) > 0.0) 
		return
		
	ExecuteHamB(Ham_Weapon_ResetEmptySound, iEnt);
	//OrpheuCall(OrpheuGetFunctionFromEntity(id, "GetAutoaimVector", "CBasePlayer"), id, AUTOAIM_10DEGREES)
	
	if(pev(iEnt, pev_iuser2) == CANNONEX_STATUS_MODEA)
		SendWeaponAnim(id, 0)
	else
		SendWeaponAnim(id, 1)
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 20.0)
	
	return
}

public CCannonex_PrimaryAttack(id, iEnt, iClip, iBteWpn)
{
	if (!iClip)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0] + 0.1);

		return;
	}

	set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	set_pev(iEnt, pev_iuser1, 1);
	
	CCannonex_FlameEffect(id, iEnt, iClip, iBteWpn)
	
	set_pdata_float(id, m_flNextAttack, random_float(0.05, 0.1));
}

public CCannonex_SecondaryAttack(id, iEnt, iClip, iBteWpn)
{
	if(pev(iEnt, pev_iuser2) != CANNONEX_STATUS_MODEA)
		return;
	
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 3, 0, FALSE, FALSE);
	UTIL_WeaponDelay(iEnt, 2.5, 2.47, 2.5+2.47);
	
	set_pev(iEnt, pev_iuser2, CANNONEX_STATUS_TRANSFORM)
}

public CCannonex_ItemPostFrame(id, iEnt, iClip, iBteWpn)
{
	if (pev(iEnt, pev_iuser1) == 1)
	{
		set_pev(iEnt, pev_iuser1, 0);
		iClip --;
		set_pdata_int(iEnt, m_iClip, iClip);
		
		CCannonex_FlameEffect(id, iEnt, iClip, iBteWpn);
		
		if(pev(iEnt, pev_iuser2) == CANNONEX_STATUS_FIRE)
		{
			set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0])
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 3.0999999)
		}
		else if(pev(iEnt, pev_iuser2) == CANNONEX_STATUS_MODEB)
		{
			UTIL_WeaponDelay(iEnt, 2.5, 2.5, 3.53);
			set_pev(iEnt, pev_iuser2, CANNONEX_STATUS_RELOAD);
		}
		else
		{
			UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0], 3.53);
		}
		
		KnifeAttack2(id, FALSE, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][0], IS_ZBMODE ? c_flDamageZB[iBteWpn][0] : c_flDamage[iBteWpn][0], _, HITGROUP_CHEST, FALSE, DMG_NEVERGIB | DMG_BULLET, TRUE);
		
		if (pev(id, pev_flags) & FL_ONGROUND)
		{
			if (!GetVelocity2D(id))
			{
				if (pev(id, pev_flags) & FL_DUCKING)
					KickBack(iEnt, 9.0, 2.1, 5.5, 15.0, 0.5, 1.25, 1);
				else
					KickBack(iEnt, 13.0, 3.2, 10.0, 15.0, 0.5, 1.5, 2);
			}
			else    
				KickBack(iEnt, 13.0, 2.25, 10.0, 12.0, 0.7, 1.45, 2);
		}
		else
		{
			KickBack(iEnt, 13.0, 5.0, 5.7, 15.0, 0.55, 1.85, 2);
		}
	}
	
	if(get_pdata_float(iEnt, m_flNextSecondaryAttack) <= 0.0)
	{
		if(pev(iEnt, pev_iuser2) == CANNONEX_STATUS_FIRE)
		{
			set_pev(iEnt, pev_iuser2, CANNONEX_STATUS_MODEB)
			
			new pEntity = -1
			while ((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "cannonex_dragon")) && pev(pEntity, pev_owner) == id)
			{
				CCannonex_FireAttack(id, iEnt, iClip, iBteWpn);
				set_pev(iEnt, pev_iuser2, CANNONEX_STATUS_FIRE)
				break;
			}
		}
		else if(pev(iEnt, pev_iuser2) == CANNONEX_STATUS_TRANSFORM)
		{
			
			if(pev(id, pev_button) & IN_ATTACK)
			{
				set_pev(iEnt, pev_iuser2, CANNONEX_STATUS_FIRE)
				CCannonexDragon_Create(id, iEnt, iClip, iBteWpn);
			}
			else
			{
				set_pev(iEnt, pev_iuser2, CANNONEX_STATUS_MODEB)
			}
			CCannonex_RadiusSurroundAttack(id, iEnt, iClip, iBteWpn);
			
			SendWeaponAnim(id, 1)
			
			set_pev(id, pev_weaponmodel2, "models/p_cannonexb.mdl")
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.067)
			
		}
		else if(pev(iEnt, pev_iuser2) == CANNONEX_STATUS_RELOAD)
		{
			set_pev(iEnt, pev_iuser2, CANNONEX_STATUS_RELOAD2)
			
			UTIL_WeaponDelay(iEnt, 2.47, 2.47, 2.5);
			
			SendWeaponAnim(id, 8)
		}
		else if(pev(iEnt, pev_iuser2) == CANNONEX_STATUS_RELOAD2)
		{
			set_pev(iEnt, pev_iuser2, CANNONEX_STATUS_MODEA)
			set_pev(id, pev_weaponmodel2, c_sModel_P[iBteWpn])
		}
		else if(!pev(iEnt, pev_iuser2) && pev(id, pev_button) & IN_ATTACK2)
		{
			set_pev(id, pev_button, pev(id, pev_button) & ~IN_ATTACK2)
			CCannonex_SecondaryAttack(id, iEnt, iClip, iBteWpn)
		}
		
	}
}

public CCannonex_FireAttack(id, iEnt, iClip, iBteWpn)
{
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 4, 0, FALSE, FALSE);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][1])
	
	KnifeAttack(id, FALSE, c_flDistance[iBteWpn][2], ((!IS_ZBMODE) ? c_flDamage[iBteWpn][2] : c_flDamageZB[iBteWpn][2]), _, HITGROUP_CHEST);
}

public CCannonex_RadiusSurroundAttack(id, iEnt, iClip, iBteWpn)
{
	new ptr = create_tr2()
	new Float:vecSrc[3], Float: vecEnd[3]
	GetGunPosition(id, vecSrc)
	
	new Float:flRange = c_flDistance[iBteWpn][1]
	
	static Float:vecForward[3]
	global_get(glb_v_forward, vecForward)
	xs_vec_mul_scalar(vecForward, flRange, vecForward)
	xs_vec_add(vecSrc, vecForward, vecEnd)

	engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, id, ptr)

	new Float:flFraction
	get_tr2(ptr, TR_flFraction, flFraction)
	
	if (flFraction >= 1.0)
	{
		engfunc(EngFunc_TraceHull, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, HULL_HEAD, id, ptr)
		
		if (flFraction < 1.0)
		{
			new pHit = get_tr2(ptr, TR_pHit)
			if(!pHit || ExecuteHamB(Ham_IsBSPModel, pHit))
			{
				FindHullIntersection(vecSrc, ptr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, id)
				get_tr2(ptr, TR_vecEndPos, vecEnd)
			}
		}
	}
	
	get_tr2(ptr, TR_flFraction, flFraction)
	if (flFraction >= 1.0)
	{
		
	}
	else
	{
		new pEntity = get_tr2(ptr, TR_pHit)
		if(pEntity < 0) pEntity = 0
		
		if(pEntity && ExecuteHamB(Ham_IsBSPModel, pEntity))
		{
			ClearMultiDamage()
			ExecuteHamB(Ham_TraceAttack, pEntity, id, ((!IS_ZBMODE) ? c_flDamage[iBteWpn][2] : c_flDamageZB[iBteWpn][2]), vecForward, ptr, DMG_NEVERGIB | DMG_BULLET)
			ApplyMultiDamage(id, id);
		}
	
		if(pEntity)
		{
			if(ExecuteHamB(Ham_Classify, pEntity) == CLASS_NONE || ExecuteHamB(Ham_Classify, pEntity) == CLASS_MACHINE)
			{
				new Float:vecTemp[3]
				xs_vec_sub(vecEnd, vecSrc, vecTemp)
				xs_vec_mul_scalar(vecTemp, 2.0, vecTemp)
				xs_vec_add(vecTemp, vecSrc, vecTemp)
				
				TEXTURETYPE_PlaySound(ptr, vecSrc, vecTemp, BULLET_PLAYER_CROWBAR);
				
			}
		}
	}
	free_tr2(ptr)
	
	// ¶ÔÍæ¼ÒÖ´ÐÐ·¶Î§ÉËº¦
	new Float:vecEndZ = vecEnd[2]
	new pEntity
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecSrc, flRange)) != 0)
	{
		if(pEntity == id)
			continue;
		if(ExecuteHamB(Ham_IsBSPModel, pEntity))
			continue;
			
		pev(pEntity, pev_origin, vecEnd)
		
		vecEnd[2] = vecSrc[2] + (vecEndZ - vecSrc[2]) * (get_distance_f(vecSrc, vecEnd) / flRange)
			
		engfunc(EngFunc_TraceLine, vecSrc, vecEnd, 0, id, ptr)
		get_tr2(ptr, TR_flFraction, flFraction)
		if (flFraction >= 1.0) 
		{
			engfunc(EngFunc_TraceHull, vecSrc, vecEnd, 0, HULL_HEAD, id, ptr)
			get_tr2(ptr, TR_flFraction, flFraction)
		}
		
		new pHit = get_tr2(ptr, TR_pHit)
		if(!pev_valid(pHit))
			continue;
		
		ClearMultiDamage()
		ExecuteHamB(Ham_TraceAttack, pEntity, id, ((!IS_ZBMODE) ? c_flDamage[iBteWpn][2] : c_flDamageZB[iBteWpn][2]), vecForward, ptr, DMG_NEVERGIB | DMG_BULLET)
		ApplyMultiDamage(id, id)
		
		free_tr2(ptr)
	}
	
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 5, 0, FALSE, FALSE);
}

public CCannonex_FlameEffect(id, iEnt, iClip, iBteWpn)
{
	if(pev(iEnt, pev_iuser2) == CANNONEX_STATUS_FIRE) // Dragon is Firing
	{
		engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 1, 0, FALSE, FALSE);
	}
	else if(pev(iEnt, pev_iuser2) == CANNONEX_STATUS_MODEB)  // Dragon Fire Ended
	{
		engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 2, 0, FALSE, FALSE);
	}
	else  // Dragon On Gun
	{
		engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 0, 0, FALSE, FALSE);
	}
}

public CCannonexDragon_Create(id, iEnt, iClip, iBteWpn)
{
	new pEntity = -1
	while ((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "cannonex_dragon")) && pev(pEntity, pev_owner) == id)
		engfunc(EngFunc_RemoveEntity, pEntity);
	
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(iEntity)) return -1
	
	set_pev(iEntity, pev_classname, "cannonex_dragon")
	set_pev(iEntity, pev_owner, id)
	
	engfunc(EngFunc_SetModel, iEntity, "models/cannonexdragon.mdl")
	
	set_pev(iEntity, pev_movetype, MOVETYPE_FLY)
	set_pev(iEntity, pev_solid, SOLID_NOT)
	set_pev(iEntity, pev_frame, 0.0)
	set_pev(iEntity, pev_framerate, 1.0)
	set_pev(iEntity, pev_animtime, get_gametime())
	
	set_pev(iEntity, pev_fuser1, get_gametime() + 6.0)
	set_pev(iEntity, pev_fuser2, get_gametime() + 2.0)
	set_pev(iEntity, pev_nextthink, get_gametime() + 0.067)
	
	BTE_SetThink(iEntity, "CCannonexDragon_ThinkDragonFX");
	
	set_pev(iEnt, pev_euser1, iEntity);
	return iEntity
}

public CCannonexDragon_ThinkDragonFX(iEntity)
{
	static iOwner; iOwner = pev(iEntity, pev_owner)
	
	static Float:flTimeRemove
	pev(iEntity, pev_fuser1, flTimeRemove)
	if(get_gametime() > flTimeRemove)
	{
		engfunc(EngFunc_RemoveEntity, iEntity)
		return;
	}
	
	static Float:vecOrigin[3]; pev(iOwner, pev_origin, vecOrigin)
	static Float:vecVelocity[3]; pev(iOwner, pev_velocity, vecVelocity)
	static Float:vecAngles[3]; pev(iOwner, pev_angles, vecAngles)
	vecOrigin[2] += 40.0
	vecAngles[0] = 0.0
	set_pev(iEntity, pev_origin, vecOrigin)
	set_pev(iEntity, pev_velocity, vecVelocity)
	set_pev(iEntity, pev_angles, vecAngles)
	
	static Float:flTimeResetAnim;
	pev(iEntity, pev_fuser2, flTimeResetAnim)
	if(get_gametime() > flTimeResetAnim)
	{
		set_pev(iEntity, pev_frame, 0.0)
		set_pev(iEntity, pev_fuser2, get_gametime() + 2.0)
	}
	
	set_pev(iEntity, pev_nextthink, get_gametime() + 0.067)
}