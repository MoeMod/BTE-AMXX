public CChainsaw_ItemPostFrame(id,iEnt,iClip,iBteWpn)
{
	if (!Stock_Can_Attack()) return;
	new iButton, iState;
	iButton = pev(id, pev_button);
	iState = pev(iEnt, pev_iuser1);
	
	static Float:vecOrigin[3];
	GetGunPosition(id, vecOrigin);

	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0)
	{
		if ((!iClip || !(iButton & IN_ATTACK) && !(iButton & IN_ATTACK2) && !(iButton & IN_RELOAD)) && iState == 1)
		{
			SendWeaponAnim(id, 5);

			set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.53);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.53);
			set_pev(iEnt, pev_iuser1, 2);
			return;
		}

		if (iButton & IN_ATTACK && !(iButton & IN_ATTACK2) && iClip)
		{
			switch (iState)
			{
				case 0:
				{
					set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.53);
					set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.53);
					set_pev(iEnt, pev_iuser1, 1);
					engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, c_flDistance[iBteWpn][0], 0.0, 0, 0, FALSE, FALSE);
					OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
					return;
				}
				case 1:
				{
					if (!iClip)
					{
						SendWeaponAnim(id, 5);
						set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.53);
						set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.53);
						set_pev(iEnt, pev_iuser1, 2);
						return;
					}

					set_pdata_int(iEnt, m_iClip, iClip - 1);

					new Float: flDamage = IS_ZBMODE ? c_flDamageZB[iBteWpn][0] : c_flDamage[iBteWpn][0];
					new iCallBack = KnifeAttack(id, FALSE, c_flDistance[iBteWpn][0], flDamage, _, -1, DMG_NEVERGIB | DMG_BULLET);

					engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, c_flDistance[iBteWpn][0], float(c_iShake[iBteWpn]), random_num(0, 1)?(random_num(0,1)):0, 0, iCallBack != RESULT_HIT_NONE, TRUE);

					OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

					set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
					set_pdata_float(iEnt, m_flTimeWeaponIdle, 5.0);
					
					static Float:vecVelocity[3]
					pev(id, pev_velocity, vecVelocity)
					vecVelocity[2] = 0.0
					
					if (vector_length(vecVelocity) > 0) // 跑
						KickBack(iEnt, 0.3, 0.3, 0.05, 0.02, 2.5, 1.5, 0);
					else if (!(pev(id, pev_flags) & FL_ONGROUND)) // 空
						KickBack(iEnt, 1.0, 0.4, 0.2, 0.15, 3.0, 2.0, 0);
					else if (pev(id, pev_flags) & FL_DUCKING) // 蹲
						KickBack(iEnt, 0.175 ,0.04, 0.03, 0.01, 1.5, 1.0, 0);
					else // 站
						KickBack(iEnt, 0.2, 0.2, 0.035, 0.015, 2.0, 1.25, 0);

					return;
				}
				case 2:
				{
					set_pev(iEnt, pev_iuser1, 0);
				}
			}
		}
	}

	if (get_pdata_float(iEnt, m_flNextSecondaryAttack) <= 0.0)
	{
		if (iButton & IN_ATTACK2)
		{
			new Float: flDamage = IS_ZBMODE ? c_flDamageZB[iBteWpn][1] : c_flDamage[iBteWpn][1];
			new iAnim = random_num(0, 1);
			new iPlayers;
			new iCallBack = ChainsawAttack(iPlayers, id, FALSE, c_flDistance[iBteWpn][1], c_flAngle[iBteWpn][1], flDamage, 3200.0);

			OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK2);

			engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, c_flDistance[iBteWpn][1], float(random_num(0, 1)), iAnim, 2, iCallBack == RESULT_HIT_PLAYER, iClip > 0);
			engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, iPlayers, 1, iAnim == 1, iClip > 0);

			set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1]);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][1]);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.5, 4);

			set_pev(iEnt, pev_iuser1, 0);
			set_pev(iEnt, pev_iuser3, iAnim);
		}
	}

	iButton &= ~IN_ATTACK;
	iButton &= ~IN_ATTACK2;

	set_pev(id, pev_button, iButton);
}

stock ChainsawAttack(&PlayerBits, id, bStab, Float:flRange, Float:fAngle, Float:flDamage, Float:flKnockBack, iHitgroup = -1, bNoTraceCheck = FALSE)
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

		if (!CheckAngle(id, pEntity, fAngle) && fAngle != 360.0)
			continue;

		static Float:fCurDamage;
		fCurDamage = flDamage;

		GetGunPosition(id, vecSrc);
		GetOrigin(pEntity, vecEnd);

		vecEnd[2] = vecSrc[2] + (vecEndZ - vecSrc[2]) * (get_distance_f(vecSrc, vecEnd) / flRange);

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
			if (IsPlayer(pEntity) || IsHostage(pEntity) || pev(pEntity, pev_takedamage))
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
					if (!CheckAngle(id, iVictim, fAngle))
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
				ClearMultiDamage();
				ExecuteHamB(Ham_TraceAttack, pEntity, id, fCurDamage, vecForward, tr, DMG_BULLET|DMG_NEVERGIB);
				ApplyMultiDamage(id, id);

				if(is_user_alive(pEntity) && bte_get_user_zombie(pEntity) == 1)
				{
					new Float:vecVelocity[3]
					pev(pEntity, pev_velocity, vecVelocity);
					
					new Float:vecDirection[3];
					xs_vec_sub(vecEnd, vecSrc, vecDirection);
					xs_vec_normalize(vecDirection, vecDirection);
					
					xs_vec_mul_scalar(vecDirection, flKnockBack, vecDirection);
					vecDirection[2] = 120.0;
					
					xs_vec_add(vecVelocity, vecDirection, vecVelocity);
					set_pev(pEntity, pev_velocity, vecVelocity);
					set_pdata_float(pEntity, m_flVelocityModifier, 0.6);
				}
				PlayerBits |= (1<<pEntity);
			}
		}

		free_tr2(tr);

	}

	return iHitResult;
}