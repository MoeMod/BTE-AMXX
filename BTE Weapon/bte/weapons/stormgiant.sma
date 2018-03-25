public StormGiant_Holster(id, iEnt, iBteWpn)
{
	ClearThink(iEnt);
}

public StormGiant_CheckExtraAttack(iEnt)
{
	return pev(iEnt, pev_iuser1) != 0;
}

public StormGiant_ReDeploy(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	if (is_user_alive(id) && is_user_connected(id))
	{
		SendWeaponAnim(id, c_iDeployAnim[WeaponIndex(iEnt)][0]);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flDeployAnimTime[WeaponIndex(iEnt)][0]);
	}
	ClearThink(iEnt);
}

public StormGiant_Deploy(iEnt)
{
	StormGiant_CancelExtraAttack(iEnt);
	SetKnifeDelay(iEnt, 0.1, "StormGiant_DrawAttack");
}

public StormGiant_ExtraAttackThink(iEnt)
{
	static Float:fTimeCancel;
	pev(iEnt, pev_fuser1, fTimeCancel);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);

	if (get_gametime() > fTimeCancel)
	{
		if(pev(iEnt, pev_iuser1))
		{
			StormGiant_ExtraStab(iEnt);
			StormGiant_CancelExtraAttack(iEnt);
		}
		else
		{
			StormGiant_CancelExtraAttack(iEnt);
			StormGiant_ReDeploy(iEnt);
		}
		return;
	}

	if (pev(id, pev_button) & IN_ATTACK2 && CanPlayerAttack(id))
	{
		StormGiant_EnableExtraAttack(iEnt);
		return;
	}

	SetKnifeDelay(iEnt, 0.0, "StormGiant_ExtraAttackThink");
}

public StormGiant_DrawAttack(iEnt)
{
	StormGiant_DrawSlash(iEnt);
	StormGiant_CancelExtraAttack(iEnt);
	set_pev(iEnt, pev_fuser1, get_gametime() + 0.4);
	SetKnifeDelay(iEnt, 0.0, "StormGiant_ExtraAttackThink");
}

public StormGiant_CancelExtraAttack(iEnt)
{
	set_pev(iEnt, pev_iuser1, 0);
	ClearThink(iEnt);
}

public StormGiant_EnableExtraAttack(iEnt)
{
	set_pev(iEnt, pev_iuser1, 1);
}

public StormGiant_PrimaryAttack(id, iEnt, iBteWpn)
{
	SetKnifeDelay(iEnt, c_flDelay[iBteWpn][0], "StormGiant_Slash");
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0] + 2.0);
	SendWeaponAnim(id, 4);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
}

public StormGiant_SecondaryAttack(id, iEnt, iBteWpn)
{
	SetKnifeDelay(iEnt, c_flDelay[iBteWpn][1], "StormGiant_Stab");
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][1], c_flAttackInterval[iBteWpn][1], c_flAttackInterval[iBteWpn][1] + 1.0);
	SendWeaponAnim(id, 7);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
}

public StormGiant_DrawSlash(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4), iBteWpn = WeaponIndex(iEnt);
	new iResult;
	new Float:vecSrc[3];
	GetGunPosition(id, vecSrc);
	iResult = StormGiantAttack(id, TRUE, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][0], IS_ZBMODE ? c_flDamageZB[iBteWpn][0] : c_flDamage[iBteWpn][0], _);

	if (iResult != RESULT_HIT_NONE)
		SendWeaponAnim(id, 2);
	else
		SendWeaponAnim(id, 1);

	PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, vecSrc, g_vecZero, c_flDistance[iBteWpn][0], 0.0, iResult, 0, FALSE, FALSE);

	UTIL_WeaponDelay(iEnt, 0.05, 0.05, 1.15);

	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
}

public StormGiant_Slash(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4), iBteWpn = WeaponIndex(iEnt);
	new iResult;
	new Float:vecSrc[3];
	GetGunPosition(id, vecSrc);
	iResult = StormGiantAttack(id, TRUE, c_flDistance[iBteWpn][2], c_flAngle[iBteWpn][2], IS_ZBMODE ? c_flDamageZB[iBteWpn][2] : c_flDamage[iBteWpn][2], _, _, _, TRUE);

	if (iResult != RESULT_HIT_NONE)
		SendWeaponAnim(id, 5);
	else
		SendWeaponAnim(id, 6);

	PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, c_flDistance[iBteWpn][2], 0.0, iResult, 2, FALSE, FALSE);

	ClearThink(iEnt);
}

public StormGiant_ExtraStab(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4), iBteWpn = WeaponIndex(iEnt);
	new iResult;
	new Float:vecSrc[3];
	GetGunPosition(id, vecSrc);
	iResult = StormGiantAttack(id, TRUE, c_flDistance[iBteWpn][1], c_flAngle[iBteWpn][1], IS_ZBMODE ? c_flDamageZB[iBteWpn][1] : c_flDamage[iBteWpn][1], c_flKnockback[iBteWpn][4], _, _, TRUE);

	if (iResult != RESULT_HIT_NONE)
		SendWeaponAnim(id, 8);
	else
		SendWeaponAnim(id, 9);

	PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, c_flDistance[iBteWpn][1], 0.0, iResult, 1, FALSE, FALSE);

	ClearThink(iEnt);

	//UTIL_WeaponDelay(iEnt, 0.7, 0.7, 1.15);

	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK2);
}

public StormGiant_Stab(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4), iBteWpn = WeaponIndex(iEnt);
	new iResult;
	new Float:vecSrc[3];
	GetGunPosition(id, vecSrc);
	iResult = StormGiantAttack(id, TRUE, c_flDistance[iBteWpn][3], c_flAngle[iBteWpn][3], IS_ZBMODE ? c_flDamageZB[iBteWpn][3] : c_flDamage[iBteWpn][3], _, _, _, TRUE);

	if (iResult != RESULT_HIT_NONE)
		SendWeaponAnim(id, 8);
	else
		SendWeaponAnim(id, 9);

	PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, c_flDistance[iBteWpn][3], 0.0, iResult, 3, FALSE, FALSE);

	ClearThink(iEnt);
}

stock StormGiantAttack(id, bStab, Float:flRange, Float:fAngle, Float:flDamage, Float:flKnockBack=0.0, iHitgroup = -1, bNoTraceCheck = FALSE, bitsDamageType = DMG_NEVERGIB | DMG_CLUB, bDamageFallByDistance = FALSE)
{
	new Float:vecOrigin[3], Float:vecSrc[3], Float:vecEnd[3], Float:v_angle[3], Float:vecForward[3];
	pev(id, pev_origin, vecOrigin);

	new iHitResult = RESULT_HIT_NONE;

	GetGunPosition(id, vecSrc);

	pev(id, pev_v_angle, v_angle);
	engfunc(EngFunc_MakeVectors, v_angle);

	global_get(glb_v_forward, vecForward);
	xs_vec_mul_scalar(vecForward, flRange, vecForward);

	xs_vec_add(vecSrc, vecForward, vecEnd);

	new tr = create_tr2();
	engfunc(EngFunc_TraceLine, vecSrc, vecEnd, dont_ignore_monsters, id, tr);

	new Float:flFraction;
	get_tr2(tr, TR_flFraction, flFraction);

	if (flFraction < 1.0)
		iHitResult = RESULT_HIT_WORLD;

	new Float:vecEndZ = vecEnd[2];

	new pEntity = -1;
	while ((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, flRange)) != 0)
	{
		if (!pev_valid(pEntity))
			continue;

		if (id == pEntity)
			continue;

		if (!IsAlive(pEntity))
			continue;

		if (!CheckAngle(id, pEntity, fAngle))
			continue;

		static Float:fCurDamage;
		fCurDamage = flDamage;

		GetGunPosition(id, vecSrc);
		GetOrigin(pEntity, vecEnd);
		
		new Float:falloff = (get_distance_f(vecSrc, vecEnd) / flRange);

		vecEnd[2] = vecSrc[2] + (vecEndZ - vecSrc[2]) * falloff;

		xs_vec_sub(vecEnd, vecSrc, vecForward);
		xs_vec_normalize(vecForward, vecForward);
		xs_vec_mul_scalar(vecForward, flRange, vecForward);
		xs_vec_add(vecSrc, vecForward, vecEnd);

		engfunc(EngFunc_TraceLine, vecSrc, vecEnd, dont_ignore_monsters, id, tr);

		get_tr2(tr, TR_flFraction, flFraction);

		if (flFraction >= 1.0)
			engfunc(EngFunc_TraceHull, vecSrc, vecEnd, dont_ignore_monsters, head_hull, id, tr);

		get_tr2(tr, TR_flFraction, flFraction);

		if (flFraction < 1.0)
		{
			if ((IsPlayer(pEntity) || IsHostage(pEntity)))
			{
				if (!bNoTraceCheck)
				{
					new iVictim = get_tr2(tr, TR_pHit);
					if (!pev_valid(iVictim))
						continue;
					if (!IsAlive(iVictim))
						continue;
					if (!CheckAngle(id, iVictim, fAngle) && fAngle != 360.0)
						continue;
					if (!pev(iVictim, pev_takedamage))
						continue;
				}
				
				iHitResult = RESULT_HIT_PLAYER;

				if (IsPlayer(pEntity) || IsHostage(pEntity))
				{
					fCurDamage = KnifeSettings(id, bStab, pEntity, tr, flDamage);

					PLAYBACK_EVENT_FULL(FEV_GLOBAL, pEntity, m_usStormGiantEffect, 0.0, g_vecZero, g_vecZero, 0.0, 0.0, 0, 0, FALSE, FALSE);
				}
			}

			if (pev_valid(pEntity))
			{
				if (!bNoTraceCheck)
				{
					new iVictim = get_tr2(tr, TR_pHit);
					if (!pev_valid(iVictim))
						continue;
					if (!IsAlive(iVictim))
						continue;
					if (!CheckAngle(id, iVictim, fAngle) && fAngle != 360.0)
						continue;
					if (!pev(iVictim, pev_takedamage))
						continue;
				}
				engfunc(EngFunc_MakeVectors, v_angle);
				global_get(glb_v_forward, vecForward);

				if (iHitgroup != -1)
					set_tr2(tr, TR_iHitgroup, iHitgroup);
				/*
				if (bte_hms_get_skillstat(id) & (1<<1) && !bte_zb3_is_boomer_skilling(pEntity))
					set_tr2(tr, TR_iHitgroup, HITGROUP_HEAD);
				*/
				if (bDamageFallByDistance)
					fCurDamage *= (1.0-falloff);

				ClearMultiDamage();
				ExecuteHamB(Ham_TraceAttack, pEntity, id, fCurDamage, vecForward, tr, bitsDamageType);
				ApplyMultiDamage(id, id);

				FakeKnockBack(pEntity, vecSrc, vecEnd, flKnockBack);
			}
		}

		free_tr2(tr);

	}

	return iHitResult;
}