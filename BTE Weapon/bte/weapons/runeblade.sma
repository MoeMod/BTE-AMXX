public Runeblade_PrimaryAttack(id, iEnt, iBteWpn)
{
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0], 2.0);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	
	SendWeaponAnim(id, 1);
	
	SetKnifeDelay(iEnt, c_flDelay[iBteWpn][0], "Runeblade_DelayedPrimaryAttack");
}

public Runeblade_SecondaryAttack(id, iEnt, iBteWpn)
{
	new iCharged = pev(iEnt, pev_iuser1);
	if(iCharged == 0)
	{
		ClearThink(iEnt);
		SetKnifeDelay(iEnt, c_flDelay[iBteWpn][1], "Runeblade_CheckCharge");
		UTIL_WeaponDelay(iEnt, 0.4, 0.4, 2.0);
		SendWeaponAnim(id, 9);
	}
	else if(iCharged == 1)
	{
		Runeblade_ChargeFinish(id, iEnt, iBteWpn)
		set_pev(iEnt, pev_iuser1, 2);
	}
	else if(iCharged == 2)
	{
		return;
	}
}

public Runeblade_ItemPostFrame(id, iEnt, iBteWpn)
{
	new iCharged = pev(iEnt, pev_iuser1);
	new bitsCurbutton = pev(id, pev_button);
	if(iCharged == 0)
	{
		if(pev(id, pev_button) & IN_ATTACK2)
		{
			if(get_pdata_float(iEnt, m_flNextSecondaryAttack) <= 0.0)
				Runeblade_SecondaryAttack(id, iEnt, iBteWpn);
		}
	}
	else if(iCharged == 1)
	{
		if(!(bitsCurbutton & IN_ATTACK2))
		{
			Runeblade_ChargeFail(id, iEnt, iBteWpn);
			set_pev(iEnt, pev_iuser1, 0);
		}
		ExecuteHamB(Ham_Weapon_WeaponIdle, iEnt);
	}
	else if(iCharged == 2)
	{
		if(!(bitsCurbutton & IN_ATTACK2))
		{
			Runeblade_ChargeAttack(id, iEnt, iBteWpn);
			set_pev(iEnt, pev_iuser1, 0);
		}
		ExecuteHamB(Ham_Weapon_WeaponIdle, iEnt);
	}
	//bitsCurbutton &= ~IN_ATTACK2
	//set_pev(id, pev_button, bitsCurbutton);
	return HAM_IGNORED;
}

public Runeblade_Holster(id, iEnt, iBteWpn)
{
	set_pev(iEnt, pev_iuser1, 0);
	ClearThink(iEnt);
}

public Runeblade_GetWeaponModeIdle(id, iEnt, iBteWpn)
{
	return pev(iEnt, pev_iuser1);
}

public Runeblade_CheckCharge(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	
	ClearThink(iEnt);
	
	if(pev(id, pev_button) & IN_ATTACK2)
	{
		set_pev(iEnt, pev_iuser1, 1);
		UTIL_WeaponDelay(iEnt, 2.77 - c_flAttackInterval[iBteWpn][1], 2.77 - c_flAttackInterval[iBteWpn][1], 0.3);
		SendWeaponAnim(id, 3);
	}
	else
	{
		UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][1], c_flAttackInterval[iBteWpn][1], 2.7);
		OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK2);
		SetKnifeDelay(iEnt, c_flDelay[iBteWpn][1], "Runeblade_DelayedFailAttack");
	}
}

public Runeblade_ChargeFail(id, iEnt, iBteWpn)
{
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][1], c_flAttackInterval[iBteWpn][1], 2.7);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK2);
	
	SendWeaponAnim(id, 7);
	
	SetKnifeDelay(iEnt, c_flDelay[iBteWpn][1], "Runeblade_DelayedFailAttack");
}

public Runeblade_ChargeFinish(id, iEnt, iBteWpn)
{
	UTIL_WeaponDelay(iEnt, 0.0, 0.0, 0.4);
	SendWeaponAnim(id, 4);
	
}

public Runeblade_ChargeAttack(id, iEnt, iBteWpn)
{
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][2], c_flAttackInterval[iBteWpn][2], 2.0);
	SendWeaponAnim(id, 8);
	
	SetKnifeDelay(iEnt, c_flDelay[iBteWpn][1], "Runeblade_DelayedSpecialAttack");
}

public Runeblade_DelayedPrimaryAttack(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	new Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][0] : c_flDamageZB[iBteWpn][0];

	new iHitResult;
	
	iHitResult = RunebladeAttack(id, TRUE, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][0], flDamage, c_flKnockback[iBteWpn][0]);

	SendKnifeSound(id, 1, 0);
	
	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 2, 0);
		case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
	}
	
	PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, Float:{0.0, 0.0, 0.0}, Float:{0.0, 0.0, 0.0}, c_flDistance[iBteWpn][0], 0.0, iHitResult, 0, FALSE, FALSE);

	ClearThink(iEnt);
}

public Runeblade_DelayedFailAttack(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	new Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1];

	new iHitResult;
	iHitResult = RunebladeAttack(id, TRUE, c_flDistance[iBteWpn][1], c_flAngle[iBteWpn][1], flDamage, c_flKnockback[iBteWpn][1]);

	SendKnifeSound(id, 4, 0);
	
	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 2, 0);
		case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
	}
	
	PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, Float:{0.0, 0.0, 0.0}, Float:{0.0, 0.0, 0.0}, c_flDistance[iBteWpn][0], 0.0, iHitResult, 0, FALSE, FALSE);

	ClearThink(iEnt);
}

public Runeblade_DelayedSpecialAttack(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	new Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][2] : c_flDamageZB[iBteWpn][2];
	
	new iHitResult = RunebladeAttack(id, TRUE, c_flDistance[iBteWpn][2], c_flAngle[iBteWpn][2], flDamage, c_flKnockback[iBteWpn][2]);

	
	PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, Float:{0.0, 0.0, 0.0}, Float:{0.0, 0.0, 0.0}, c_flDistance[iBteWpn][0], 0.0, iHitResult, 0, TRUE, FALSE);

	ClearThink(iEnt);
}

stock RunebladeAttack(id, bStab, Float:flRange, Float:fAngle, Float:flDamage, Float:flKnockBack=0.0, iHitgroup = -1, bNoTraceCheck = FALSE, bitsDamageType = DMG_NEVERGIB | DMG_CLUB, bDamageFallByDistance = FALSE)
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

					PLAYBACK_EVENT_FULL(FEV_GLOBAL, pEntity, m_usRunebladeEffect, 0.0, g_vecZero, g_vecZero, 0.0, 0.0, 0, 0, FALSE, FALSE);
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