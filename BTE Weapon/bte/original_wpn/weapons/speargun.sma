/*
public WE_SpearGun(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	if(!Stock_Can_Attack()) return;
	static iButton, pEntity;
	iButton = pev(id, pev_button);
	pEntity = pev(iEnt, pev_iuser1);

	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0 && iClip)
	{
		if (iButton & IN_ATTACK)
		{
			SendWeaponAnim(id, 1);
			SendWeaponShootSound(id, FALSE, TRUE);
			set_pdata_int(iEnt, m_iClip, iClip - 1);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.03);
			
			new pEntity = CreateEntity(id, iBteWpn, "models/spear.mdl", c_flEntityAngle[iBteWpn], c_flEntitySpeed[iBteWpn], 0.5, MOVETYPE_FLY, ENTCLASS_SPEARGUN);	
			engfunc(EngFunc_SetSize, pEntity, Float:{0.08, 0.08, 0.08}, Float:{0.08, 0.08, 0.08});

			set_pev(pEntity, pev_nextthink, get_gametime());

			set_pev(iEnt, pev_iuser1, pEntity);

			if (pev(id, pev_flags) & FL_ONGROUND)
			{
				if (GetVelocity2D(id))
					KickBack(iEnt, 15.0, 10.0, 0.225, 0.05, 6.5, 2.5, 7);
				else
				{
					if (pev(id, pev_flags) & FL_DUCKING)
						KickBack(iEnt, 4.0, 3.0, 0.125, 0.02, 5.0, 1.35, 9);
					else
						KickBack(iEnt, 10.0, 7.0, 0.22, 0.38, 5.9, 1.9, 8);
				}
			}
			else
				KickBack(iEnt, 15.0, 10.0, 0.6, 0.35, 9.0, 6.0, 5);

		}
	}

	if (iButton & IN_ATTACK2)
	{
		if (!pev_valid(pEntity))
			return;

		if (Get_Ent_Data(pEntity, DEF_ENTCLASS) != ENTCLASS_SPEARGUN || Get_Ent_Data(pEntity, DEF_ENTSTAT) == 0)
			return;

		new Float:vecOrigin[3], Float:flDamage;
		new aiment = pev(pEntity, pev_aiment);
		
		pev(aiment?aiment:pEntity, pev_origin, vecOrigin);

		if (!IS_ZBMODE)
			flDamage = c_flEntityDamage[iBteWpn][0];
		else
			flDamage = c_flEntityDamageZB[iBteWpn][0];

		new iHitgroup = pev(pEntity, pev_iuser1);
		
		if (!iHitgroup)
			iHitgroup = -1;

		SpearRadius(vecOrigin, pEntity, id, flDamage, c_flEntityRange[iBteWpn][0], c_flEntityKnockBack[iBteWpn], DMG_CLUB | DMG_NEVERGIB, FALSE, TRUE, iHitgroup);

		RemoveEntity(pEntity);

		engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, WEAPON_EVENT[CSW_KNIFE], 0.0, vecOrigin, {0.0, 0.0, 0.0}, 0.0 , 0.0, (1<<4), 0, FALSE, TRUE);
	}
}
*/

public CSpeargun_ItemPostFrame(id,iEnt,iClip,iBteWpn)
{
	static iButton, pEntity;
	iButton = pev(id, pev_button);
	pEntity = pev(iEnt, pev_iuser1);

	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0 && iClip)
	{
		if (iButton & IN_ATTACK && !(iButton & IN_ATTACK2))
		{
			SendWeaponAnim(id, 1);
			SendWeaponShootSound(id, FALSE, TRUE);
			set_pdata_int(iEnt, m_iClip, iClip - 1);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.03);

			new pEntity = CSpearAmmo_Create();

			if (pEntity)
			{
				new Float:vecAngles[3], Float:vecPunchangle[3];
				new Float:vecSrc[3], Float:vecForward[3], Float:vecUp[3];
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
				set_pev(pEntity, pev_vuser1, vecForward);
				xs_vec_mul_scalar(vecForward, 2000.0, vecForward);
				engfunc(EngFunc_VecToAngles, vecForward, vecAngles);
				set_pev(pEntity, pev_angles, vecAngles);
				set_pev(pEntity, pev_velocity, vecForward);
				set_pev(pEntity, pev_vuser2, vecForward);
				new Float:vecAngleVelocity[3];
				pev(pEntity, pev_avelocity, vecAngleVelocity);
				vecAngleVelocity[2] = 5.0;
				set_pev(pEntity, pev_avelocity, vecAngleVelocity);
				set_pev(pEntity, pev_fuser1, get_gametime()+4.0);
				set_pev(pEntity, pev_owner, id);
				set_pev(pEntity, pev_euser2, iEnt);
			}

			set_pev(iEnt, pev_iuser1, pEntity);

			if (pev(id, pev_flags) & FL_ONGROUND)
			{
				if (GetVelocity2D(id))
					KickBack(iEnt, 15.0, 10.0, 0.225, 0.05, 6.5, 2.5, 7);
				else
				{
					if (pev(id, pev_flags) & FL_DUCKING)
						KickBack(iEnt, 4.0, 3.0, 0.125, 0.02, 5.0, 1.35, 9);
					else
						KickBack(iEnt, 10.0, 7.0, 0.22, 0.38, 5.9, 1.9, 8);
				}
			}
			else
				KickBack(iEnt, 15.0, 10.0, 0.6, 0.35, 9.0, 6.0, 5);
		}
		else if (iButton & IN_ATTACK && (iButton & IN_ATTACK2) && get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0)
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.1);
	}

	if (iButton & IN_ATTACK2)
	{
		if (!pev_valid(pEntity))
			return;
/*
		new Float:vecOrigin[3], Float:flDamage;
		new aiment = pev(pEntity, pev_aiment);

		pev(aiment?aiment:pEntity, pev_origin, vecOrigin);

		if (!IS_ZBMODE)
			flDamage = c_flEntityDamage[iBteWpn][0];
		else
			flDamage = c_flEntityDamageZB[iBteWpn][0];

		new iHitgroup = pev(pEntity, pev_iuser1);
		
		if (!iHitgroup)
			iHitgroup = -1;
		SpearRadius(vecOrigin, pEntity, id, flDamage, c_flEntityRange[iBteWpn][0], c_flEntityKnockBack[iBteWpn], DMG_CLUB | DMG_NEVERGIB, FALSE, TRUE, iHitgroup);

		RemoveEntity(pEntity);
*/
		CSpearAmmo_Explode(pEntity, 0.1, 0);
	}

}

public CSpearAmmo_CheckExplode(pEntity)
{
	static pEntityLocking, Float:flMaxZVelocity, Float:flNextCheckExplode, Float:vecVelocity[3]/*, Float:vecOffset[3]*/;
	pev(pEntity, pev_fuser1, flNextCheckExplode);
	pev(pEntity, pev_vuser2, vecVelocity);
	
	pEntityLocking = pev(pEntity, pev_euser1);
	if (IS_ZBMODE)
		flMaxZVelocity = 50.0;
	else
		flMaxZVelocity = 0.0;
	if (get_gametime() <= flNextCheckExplode)
	{
		if (!(pev(pEntity, pev_effects) & EF_NODRAW))
		{
			set_pev(pEntity, pev_velocity, vecVelocity);
		}
		if (pev_valid(pEntityLocking))
		{
			if (IsAlive(pEntityLocking))
			{
				xs_vec_normalize(vecVelocity, vecVelocity);
				xs_vec_mul_scalar(vecVelocity, IS_ZBMODE ? 650.0 : 0.0, vecVelocity);
				if (flMaxZVelocity > vecVelocity[2])
					vecVelocity[2] = flMaxZVelocity;

				set_pev(pEntityLocking, pev_velocity, vecVelocity);
			}
			else
				CSpearAmmo_Explode(pEntity, 0.0, 0);
		}
	}
	else
		CSpearAmmo_Explode(pEntity, 0.0, 0);
}

public CSpearAmmo_PenetrateThink(pEntity)
{
	if (pev(pEntity, pev_iuser1))
	{
		new Float:vecVelocity[3], Float:vecOffset[3];
		pev(pEntity, pev_vuser2, vecVelocity);
		pev(pEntity, pev_vuser3, vecOffset);
		
		set_pev(pEntity, pev_origin, vecOffset);
		set_pev(pEntity, pev_velocity, vecVelocity);
		set_pev(pEntity, pev_solid, SOLID_BBOX);
		set_pev(pEntity, pev_movetype, MOVETYPE_FLY);
		set_pev(pEntity, pev_iuser1, 0);
	}
	BTE_SetThink(pEntity, "CSpearAmmo_FollowThink");
	set_pev(pEntity, pev_nextthink, get_gametime() + 0.032);
}

public CSpearAmmo_FollowThink(pEntity)
{
	new iEnt = pev(pEntity, pev_euser2)
	if(!pev_valid(iEnt))
	{
		SUB_Remove(pEntity, 0.0);
		return;
	}
	
	set_pev(pEntity, pev_nextthink, get_gametime() + 0.032);
	CSpearAmmo_CheckExplode(pEntity);
}

public CSpearAmmo_IgniteThink(pEntity)
{
	MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
	WRITE_BYTE(TE_BEAMFOLLOW);
	WRITE_SHORT(pEntity);
	WRITE_SHORT(g_sModelIndexSmokeBeam);
	WRITE_BYTE(4);
	WRITE_BYTE(4);
	WRITE_BYTE(50);
	WRITE_BYTE(185);
	WRITE_BYTE(200);
	WRITE_BYTE(200);
	MESSAGE_END();

	BTE_SetThink(pEntity, "CSpearAmmo_FollowThink");
	set_pev(pEntity, pev_nextthink, get_gametime() + 0.032);
	
	CSpearAmmo_CheckExplode(pEntity);
}

public CSpearAmmo_HitDamage(pEntity, pOther)
{
	new id = pev(pEntity, pev_owner)
	new iEnt = pev(pEntity, pev_euser2);
	new iBteWpn = WeaponIndex(iEnt);
	new Float:vecDirection[3]/*, tr = UTIL_GetGlobalTrace()*/;
	
	new Float:vecOrigin[3], Float:vecEnd[3];
	pev(pEntity, pev_vuser1, vecDirection);
	pev(pEntity, pev_vuser4, vecOrigin)

	new ptr=create_tr2();
	xs_vec_mul_scalar(vecDirection, 42.0, vecDirection)
	xs_vec_add(vecOrigin, vecDirection, vecEnd)
	engfunc(EngFunc_TraceLine, vecOrigin, vecEnd, 0, pEntity, ptr)
	
	new iHitgroup = pev(pEntity, pev_iuser3)
	set_tr2(ptr, TR_iHitgroup, iHitgroup)
	
	ClearMultiDamage();
	ExecuteHamB(Ham_TraceAttack, pOther, pev(pEntity, pev_owner), IS_ZBMODE ? c_flDamageZB[iBteWpn][0] : c_flDamage[iBteWpn][0], vecDirection, ptr, DMG_BULLET | DMG_NEVERGIB);
	ApplyMultiDamage(id, id);
	// !!!
	// Use in explode instead of ApplyMultiDamage!!
	set_pev(pEntity, pev_fuser2, GetMultiDamageAmount());
	set_pev(pEntity, pev_iuser4, iHitgroup);
	free_tr2(ptr);
}

public Float:CSpearAmmo_CalculateDamage(Float:vecSrc[3], Float:vecOrigin[3], Float:flDamageOffset, Float:flRadius, Float:vecResult[3])
{
	new Float:xSub = vecOrigin[0] - vecSrc[0], Float:ySub = vecOrigin[1] - vecSrc[1], Float:zSub = vecOrigin[2] - vecSrc[2];
	new Float:offset = xSub * xSub + ySub * ySub + zSub * zSub;
	if (flRadius * flRadius <= offset)
	{
		vecResult[0] = vecResult[1] = vecResult[2] = 0.0;
		return 0.0;
	}
	new Float:flRoot = Q_rsqrt(offset);
	new Float:flDamageModifier = (flRadius - 1.0 / flRoot) / flRadius;
	if (flDamageModifier < 0.0)
		flDamageModifier = 0.0;
	vecResult[0] = xSub * flRoot;
	vecResult[1] = ySub * flRoot;
	vecResult[2] = zSub * flRoot;

	return flDamageModifier * flDamageOffset;
}

public CSpearAmmo_Explode(pEntity, Float:flTimeRemove, bStartByThis)
{
	
	set_pev(pEntity, pev_iuser2, pev(pEntity, pev_iuser2)+1);
	if (pev(pEntity, pev_iuser2) <= 2)
	{
		new pLastEnemy = pev(pEntity, pev_euser1);
		new id = pev(pEntity, pev_owner);
		new iEnt = pev(pEntity, pev_euser2);
		new iBteWpn = WeaponIndex(iEnt);
		new Float:flDamageOffset = 1.0, Float:flHitDamage;
		new Float:vecOrigin[3];
		pev(pEntity, pev_fuser2, flHitDamage);

		if (bStartByThis || !pLastEnemy || IsBSPModel(pLastEnemy))
			pev(pEntity, pev_origin, vecOrigin);
		else
			pev(pLastEnemy, pev_origin, vecOrigin);

		engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, WEAPON_EVENT[CSW_KNIFE], 0.0, vecOrigin, {0.0, 0.0, 0.0}, 0.0 , 0.0, (1<<4), 0, FALSE, TRUE);

		if (pev_valid(pLastEnemy))
		{
			/*if (!IsPlayer(pLastEnemy) && !IsHostage(pLastEnemy))
				flDamageOffset = 1.28;
			else
				set_pev(pLastEnemy, m_LastHitGroup, pev(pEntity, pev_iuser4));
			ExecuteHamB(Ham_TakeDamage, pLastEnemy, pEntity, id, flHitDamage * flDamageOffset, DMG_BULLET);*/
			CSpearAmmo_HitDamage(pEntity, pLastEnemy);
		}

		new pOther = -1;
		new Float:flDamage;
		new Float:vecOrigin2[3];
		new Float:vecDir[3];
		new Float:vecVelocity[3];
		new Float:flMul;

		flDamageOffset = IS_ZBMODE ? c_flDamageZB[iBteWpn][1] : c_flDamage[iBteWpn][1];
		while ((pOther = engfunc(EngFunc_FindEntityInSphere, pOther, vecOrigin, 3.0 * 39.37)) != 0)
		{
			if (!pev_valid(pOther))
				continue;
			if (pOther != id && CheckTeammate(pOther, id))
				continue;

			pev(pOther, pev_origin, vecOrigin2);
			flDamage = CSpearAmmo_CalculateDamage(vecOrigin, vecOrigin2, flDamageOffset, 3.0 * 39.37, vecDir);

			flMul = flDamage / flDamageOffset;

			if (flDamage != 0.0)
			{
				if(pOther == pLastEnemy)
					set_pev(pLastEnemy, m_LastHitGroup, pev(pEntity, pev_iuser4));
				else
					set_pev(pLastEnemy, m_LastHitGroup, HIT_CHEST);
				//if (pOther == id)
					//flDamage *= 0.1;	// already in HamF_TakeDamage
				ExecuteHamB(Ham_TakeDamage, pOther, pEntity, id, flDamage, DMG_BULLET | DMG_NEVERGIB);
			
				if (IsPlayer(pOther) || IsHostage(pOther))
				{
					pev(pOther, pev_velocity, vecVelocity);
					// xs_vec_mul_scalar(vecDir, flMul, vecDir);
					// xs_vec_add(vecVelocity, vecDir, vecVelocity);
					// just few calculations so didn't use functions
					vecVelocity[0] += flMul * vecDir[0];
					vecVelocity[1] += flMul * vecDir[1];
					vecVelocity[2] += flMul * vecDir[2];

					if (vecVelocity[2] <= 199.0)
						vecVelocity[2] = 199.0;

					set_pev(pOther, pev_velocity, vecVelocity);
				}
			}
		}
	}

	if (flTimeRemove)
	{
		set_pev(pEntity, pev_effects, pev(pEntity, pev_effects) | EF_NODRAW);
		BTE_SetTouch(pEntity, "");
		SUB_Remove(pEntity, flTimeRemove);
	}
	else
		engfunc(EngFunc_RemoveEntity, pEntity);
}

public CSpearAmmo_MaterialSound(pEntity)
{
	new Float:vecOrigin[3], Float:vecSrc[3], Float:vecEnd[3], Float:vecDirection[3];
	pev(pEntity, pev_origin, vecOrigin);
	pev(pEntity, pev_vuser1, vecDirection);

	xs_vec_sub(vecOrigin, vecDirection, vecSrc);
	xs_vec_add(vecOrigin, vecDirection, vecEnd);

	switch (UTIL_TextureHit(UTIL_GetGlobalTrace(), vecSrc, vecEnd))
	{
		case 'W':	// wood
		engfunc(EngFunc_EmitAmbientSound, 0, vecOrigin, random_num(0, 1) ? "weapons/speargun_wood1.wav" : "weapons/speargun_wood2.wav", VOL_NORM, ATTN_NORM, 0, 96 + random_num(0, 15));

		case 'G', 'M', 'P':
		engfunc(EngFunc_EmitAmbientSound, 0, vecOrigin, random_num(0, 1) ? "weapons/speargun_metal1.wav" : "weapons/speargun_metal2.wav", VOL_NORM, ATTN_NORM, 0, 96 + random_num(0, 15));

		default:
		engfunc(EngFunc_EmitAmbientSound, 0, vecOrigin, random_num(0, 1) ? "weapons/speargun_stone1.wav" : "weapons/speargun_stone2.wav", VOL_NORM, ATTN_NORM, 0, 96 + random_num(0, 15));

	}
}

public CSpearAmmo_SpearTouch(pEntity, pOther)
{
	if (pev_valid(pev(pEntity, pev_euser1)))
		return;
	if (IsBSPModel(pOther) && pev(pOther, pev_rendermode))
	{
		CSpearAmmo_Explode(pEntity, 0.1, 0);
		return;
	}

	set_pev(pEntity, pev_euser1, pOther);
	//new tr = UTIL_GetGlobalTrace();
	new Float:vecOrigin[3];

	if (IsBSPModel(pOther))
	{
		CSpearAmmo_MaterialSound(pEntity);

		static Float:flNextCheckExplode;
		pev(pEntity, pev_origin, vecOrigin);

		pev(pEntity, pev_fuser1, flNextCheckExplode);
		if (get_gametime() + 0.8 <= flNextCheckExplode)
			flNextCheckExplode = get_gametime() + 0.8;
		set_pev(pEntity, pev_fuser1, flNextCheckExplode);
		set_pev(pEntity, pev_nextthink, flNextCheckExplode);
		BTE_SetTouch(pEntity, "");

		if (engfunc(EngFunc_PointContents, vecOrigin) != CONTENTS_WATER)
		{
			new Float:vecDirectionAdd[3], Float:vecDirectionAdd2[3], Float:vecOrigin2[3];
			pev(pEntity, pev_vuser1, vecDirectionAdd);
			xs_vec_mul_scalar(vecDirectionAdd, random_float(-7.0, -2.0), vecDirectionAdd2);
			xs_vec_add(vecOrigin, vecDirectionAdd2, vecOrigin2);

			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_GUNSHOTDECAL);
			engfunc(EngFunc_WriteCoord, vecOrigin[0]);
			engfunc(EngFunc_WriteCoord, vecOrigin[1]);
			engfunc(EngFunc_WriteCoord, vecOrigin[2]);
			write_short(0);
			write_byte(DECAL_SHOT[random_num(0,4)]);
			message_end();

			xs_vec_mul_scalar(vecDirectionAdd, -5.0, vecDirectionAdd2);
			xs_vec_add(vecOrigin, vecDirectionAdd, vecOrigin2);
			set_pev(pEntity, pev_origin, vecOrigin2);
			set_pev(pEntity, pev_velocity, g_vecZero);
			
			

			if (flNextCheckExplode - get_gametime() <= 0.0)
			{
				set_pev(pEntity, pev_effects, pev(pEntity, pev_effects) | EF_NODRAW);
				return;
			}
		}
		return;
	}

	if (!IsPlayer(pOther) && !IsHostage(pOther))
	{
		CSpearAmmo_HitDamage(pEntity, pOther);
		CSpearAmmo_Explode(pEntity, 0.0, 1);
		return;
	}

	vecOrigin[0] = vecOrigin[1] = vecOrigin[2] = 0.0;

	if (CheckTeammate(pev(pEntity, pev_owner), pOther))
	{
		new Float:vecDirection[3];
		pev(pEntity, pev_origin, vecOrigin);
		pev(pEntity, pev_vuser1, vecDirection);
		xs_vec_mul_scalar(vecDirection, 0.5 * 39.37, vecDirection);
		xs_vec_add(vecOrigin, vecDirection, vecOrigin);
		//set_pev(pEntity, pev_origin, vecOrigin);
		set_pev(pEntity, pev_vuser3, vecOrigin);
		set_pev(pEntity, pev_iuser1, 1);
		set_pev(pEntity, pev_solid, SOLID_NOT);
		set_pev(pEntity, pev_movetype, MOVETYPE_NOCLIP);
		set_pev(pEntity, pev_nextthink, get_gametime() + 0.05);
		set_pev(pEntity, pev_euser1, 0);
		BTE_SetThink(pEntity, "CSpearAmmo_PenetrateThink");
		return;
	}

	//CSpearAmmo_HitDamage(pEntity, pOther);

	if (IsAlive(pOther))
	{
		if (pev(pOther, pev_takedamage))
		{
			new Float:vecOrigin[3]
			new Float:vecDirection[3], Float:vecEnd[3];
			pev(pEntity, pev_origin, vecOrigin);
			pev(pEntity, pev_vuser1, vecDirection);
			
			set_pev(pEntity, pev_vuser4, vecOrigin)
			
			new ptr=create_tr2();
			xs_vec_mul_scalar(vecDirection, 42.0, vecDirection)
			xs_vec_add(vecOrigin, vecDirection, vecEnd)
			engfunc(EngFunc_TraceLine, vecOrigin, vecEnd, 0, pEntity, ptr)
			new iHitgroup = get_tr2(ptr, TR_iHitgroup)
			set_pev(pEntity, pev_iuser3, iHitgroup)
			free_tr2(ptr);
			
			set_pev(pEntity, pev_solid, SOLID_NOT);
			BTE_SetTouch(pEntity, "");

			new Float:vecNewVelocity[3], Float:flNextCheckExplode;

			set_pev(pEntity, pev_euser1, pOther);
			set_pev(pEntity, pev_fuser3, get_gametime() + (IS_ZBMODE ? 0.4 : 0.0));
			set_pev(pEntity, pev_effects, pev(pEntity, pev_effects) | EF_NODRAW);

			//vecNewVelocity[0] = vecNewVelocity[1] = vecOrigin[2];
			//vecNewVelocity[2] = 0.0;
			pev(pOther, pev_velocity, vecNewVelocity);

			set_pev(pEntity, pev_velocity, vecNewVelocity);

			pev(pEntity, pev_fuser1, flNextCheckExplode);
			if (get_gametime() + 0.8 <= flNextCheckExplode)
				flNextCheckExplode = get_gametime() + 0.8;

			set_pev(pEntity, pev_fuser1, flNextCheckExplode);
		}
	}
}

public CSpearAmmo_Spawn(pEntity)
{
	set_pev(pEntity, pev_movetype, MOVETYPE_FLY);
	set_pev(pEntity, pev_solid, SOLID_BBOX);
	set_pev(pEntity, pev_gravity, 0.5);
	set_pev(pEntity, pev_friction, 0.0);

	engfunc(EngFunc_SetModel, pEntity, "models/spear.mdl");
	engfunc(EngFunc_SetSize, pEntity, Float:{0.08, 0.08, 0.08}, Float:{0.08, 0.08, 0.08});

	BTE_SetTouch(pEntity, "CSpearAmmo_SpearTouch");
	BTE_SetThink(pEntity, "CSpearAmmo_IgniteThink");

	set_pev(pEntity, pev_nextthink, get_gametime());
}

public CSpearAmmo_Create()
{
	new pEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));

	if (pEntity)
	{
		set_pev(pEntity, pev_classname, "d_speargun");
		CSpearAmmo_Spawn(pEntity);
	}

	return pEntity;
}