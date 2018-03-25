// [BTE STOCK FUNCTION]

native UTIL_GetGlobalTrace();
native UTIL_GunshotDecalTrace(tr, decalnum);
native UTIL_DecalTrace(tr, decalnum);
native UTIL_TextureHit(tr, Float:vecSrc[3], Float:vecEnd[3]);
native FireBullets(id, cShots, Float:vecSrc[3], Float:vecDirShooting[3], Float:vecSpread[3], Float:flDistance, iBulletType, iTracerFreq = 4, iDamage = 0, pevAttacker = 0);
native SUB_Remove(pEntity, Float:intermission);
native Float:GetMultiDamageAmount();
native Float:Q_rsqrt(Float:f);

stock FireBullets3(this, Float:vecSrc[3], Float:vecDirShooting[3], Float:flSpread, Float:flDistance, iPenetration, iBulletType, iDamage, Float:flRangeModifier, iAttacker, bool:bPistol, shared_rand, Float:vecRet[3])
{
	g_bIgnoreHook = 1
	new iReturn = RageCall(handleFireBullets3, this, vecSrc, vecDirShooting, flSpread, flDistance, iPenetration, iBulletType, iDamage, flRangeModifier, iAttacker, bPistol, shared_rand, vecRet)
	g_bIgnoreHook = 0
	return iReturn
}

stock KickBack(this, Float:up_base, Float:lateral_base, Float:up_modifier, Float:lateral_modifier, Float:up_max, Float:lateral_max, direction_change)
{
	OrpheuCall(handleKickBack, this, up_base, lateral_base, up_modifier, lateral_modifier, up_max, lateral_max, direction_change);
}

stock DefaultReload(this, iClipSize, iAnim, Float:fDelay, body = 0)
{
	return OrpheuCall(handleDefaultReload, this, iClipSize, iAnim, fDelay);
}

stock SetAnimation(id, playerAnim)
{
	return OrpheuCall(handleSetAnimation, id, playerAnim);
}

stock GetAssist(iKiller, iVictim)
{
	if (!IsPlayer(iKiller) || !IsPlayer(iVictim)) return -1;
	new Float:fBiggestDamage = 0.0, iAssist = -1;
	for (new id=1; id<33; id++)
	{
		if (!is_user_connected(id)) continue;
		if (id == iKiller || id == iVictim) continue;
		if (g_fTotalDamage[iVictim][id] > fBiggestDamage)
		{
			iAssist = id;
			fBiggestDamage = g_fTotalDamage[iVictim][id];
		}
		if (g_fTotalDamage[iVictim][id] > 0.0 && IsPlayer(id) && is_user_connected(id) && pev_valid(id))
		{
			MESSAGE_BEGIN(MSG_ONE, gmsgAssist, _, id);
			WRITE_SHORT(iKiller);
			WRITE_SHORT(iVictim);
			MESSAGE_END();
			if(bte_get_user_zombie(iVictim) == 1)
				UpdateFrags(id, 1)
		}
	}
	for (new i=1; i<33; i++)
	{
		g_fTotalDamage[iVictim][i] = 0.0;
	}
	if (fBiggestDamage <= 0.0)
		return -1;
	g_iRank[1][iAssist] ++;
	return iAssist;
}

stock CountPlayers(iTeam = 0)
{
	new iNum;
	for (new id=1; id<33; id++)
	{
		if (!is_user_connected(id)) continue;
		if (!is_user_alive(id)) continue;
		if (iTeam && iTeam != get_pdata_int(id, m_iTeam)) continue;
		iNum++;
	}
	return iNum;
}

stock CountHumans()
{
	new iNum;
	for (new id=1; id<33; id++)
	{
		if (!is_user_connected(id)) continue;
		if (!is_user_alive(id)) continue;
		if (bte_get_user_zombie(id) == 1) continue;
		iNum++;
	}
	return iNum;
}

stock CountZombies()
{
	new iNum;
	for (new id=1; id<33; id++)
	{
		if (!is_user_connected(id)) continue;
		if (!is_user_alive(id)) continue;
		if (bte_get_user_zombie(id) != 1) continue;
		iNum++;
	}
	return iNum;
}
// stupid and slow code, DO NOT COPY
// Or you will be slower XD
stock UTIL_Rank(iData[3][5])
{
	new iMax[3];
	new iPlayer[3][5];
	new iTimesCount = 0;
	for (new abc=1; abc<33; abc++)
	{
		if (iTimesCount > 4) break;
		if (is_user_connected(abc))
		{
			iPlayer[0][iTimesCount] = iPlayer[1][iTimesCount] = iPlayer[2][iTimesCount] = abc;
			iTimesCount ++;
		}
	}
	for (new i=0; i<3; i++)
	{
		for (new id=1; id<33; id++)
		{
			if (g_iRank[i][id] > iMax[i] && is_user_connected(id))
			{
				iMax[i] = g_iRank[i][id];
				iPlayer[i][0] = id;
			}
		}
	}
	new iCurrent = 1;
	for (new j=0; j<3; j++)
	{
		iCurrent = 1;
		for (new def = iMax[j]; def >= 0; def--)
		{
			if (iCurrent > 4) break;
			for (new k=1; k<33; k++)
				if (g_iRank[j][k] == def && is_user_connected(k) && k != iPlayer[j][0])
				{
					iPlayer[j][iCurrent] = k;
					iCurrent++;
					if (iCurrent > 4) break;
				}
		}
	}
	copy(iData[0], 5, iPlayer[0]);
	copy(iData[1], 5, iPlayer[1]);
	copy(iData[2], 5, iPlayer[2]);
}

stock UTIL_MVPBoard(iWinningTeam, iType, iPlayer = 0)
{
	new iData[3][5];
	UTIL_Rank(iData);
	
	MESSAGE_BEGIN(MSG_ALL, gmsgMVP);
	WRITE_SHORT(1);
	WRITE_LONG(100 * g_iRank[0][iData[0][0]] + iData[0][0]);
	WRITE_LONG(100 * g_iRank[0][iData[0][1]] + iData[0][1]);
	WRITE_LONG(100 * g_iRank[0][iData[0][2]] + iData[0][2]);
	WRITE_LONG(100 * g_iRank[0][iData[0][3]] + iData[0][3]);
	WRITE_LONG(100 * g_iRank[0][iData[0][4]] + iData[0][4]);
	MESSAGE_END();
	
	MESSAGE_BEGIN(MSG_ALL, gmsgMVP);
	WRITE_SHORT(2);
	WRITE_LONG(100 * g_iRank[1][iData[1][0]] + iData[1][0]);
	WRITE_LONG(100 * g_iRank[1][iData[1][1]] + iData[1][1]);
	WRITE_LONG(100 * g_iRank[1][iData[1][2]] + iData[1][2]);
	WRITE_LONG(100 * g_iRank[1][iData[1][3]] + iData[1][3]);
	WRITE_LONG(100 * g_iRank[1][iData[1][4]] + iData[1][4]);
	MESSAGE_END();
	
	MESSAGE_BEGIN(MSG_ALL, gmsgMVP);
	WRITE_SHORT(3);
	WRITE_LONG(100 * g_iRank[2][iData[2][0]] + iData[2][0]);
	WRITE_LONG(100 * g_iRank[2][iData[2][1]] + iData[2][1]);
	WRITE_LONG(100 * g_iRank[2][iData[2][2]] + iData[2][2]);
	WRITE_LONG(100 * g_iRank[2][iData[2][3]] + iData[2][3]);
	WRITE_LONG(100 * g_iRank[2][iData[2][4]] + iData[2][4]);
	MESSAGE_END();
	
	MESSAGE_BEGIN(MSG_ALL, gmsgMVPBoard);
	WRITE_SHORT(iWinningTeam);
	WRITE_SHORT(iType);
	if (iType > 2)
		WRITE_SHORT(iPlayer);
	WRITE_BYTE(floatround(get_gametime() - g_flStartTime));
	MESSAGE_END();
}

stock Float:varf(_ent, _index)
{
	static Float:f;
	pev(_ent, _index, f);
	return f;
}

stock MakePlayerVectors(id)
{
	static Float:vecAngles[3], Float:vecPunchangle[3];
	pev(id, pev_v_angle, vecAngles);
	pev(id, pev_punchangle, vecPunchangle);

	// faster code instead of xs_vec_add
	vecAngles[0] += vecPunchangle[0];
	vecAngles[1] += vecPunchangle[1];
	vecAngles[2] += vecPunchangle[2];

	engfunc(EngFunc_MakeVectors, vecAngles);
}

stock ATTACKDOWN(id)
{
	return (pev(id, pev_button) & IN_ATTACK) ? 1 : 0;
}

stock SECATTACKDOWN(id)
{
	return (pev(id, pev_button) & IN_ATTACK2) ? 1 : 0;
}

stock GetWeaponClip(iEnt)
{
	if (c_iSpecial[Get_Wpn_Data(iEnt, DEF_ID)] == SPECIAL_GAUSS && IS_ZBMODE)
		return c_iClip[Get_Wpn_Data(iEnt, DEF_ID)];

	return get_pdata_int(iEnt, m_iClip, 4);
}

stock SetWeaponClip(iEnt, iAmount)
{
	if (c_iSpecial[Get_Wpn_Data(iEnt, DEF_ID)] == SPECIAL_GAUSS && IS_ZBMODE)
		return;

	set_pdata_int(iEnt, m_iClip, iAmount, 4);
}

stock AddWeaponClip(iEnt, iAmount)
{
	if (c_iSpecial[Get_Wpn_Data(iEnt, DEF_ID)] == SPECIAL_GAUSS && IS_ZBMODE)
		return;

	set_pdata_int(iEnt, m_iClip, GetWeaponClip(iEnt) + iAmount, 4);
}

stock Float:KnifeSettings(id, bStab, pEntity, tr, Float:flDamage)
{
	if (bte_hms_get_skillstat(id) & (1<<1))
	{
		set_tr2(tr, TR_iHitgroup, HITGROUP_HEAD);
		if(bStab)
		{
			if (CheckBack(id, pEntity))
				flDamage *= 3.0;
			else
				flDamage *= 2.0;
		}
	}
	else
	{
		if (CheckBack(id, pEntity) && bStab)
			flDamage *= 3.0;
	}

	return flDamage;
}

stock WeaponIndex(iEnt)
{
	if (pev_valid(iEnt) != 2)
		return 0;
	return Get_Wpn_Data(iEnt, DEF_ID);
}

stock UTIL_WeaponDelay(iEnt, Float:flNextPrimaryAttack, Float:flNextSecondaryAttack, Float:flTimeWeaponIdle)
{
	set_pdata_float(iEnt, m_flNextPrimaryAttack, flNextPrimaryAttack);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, flNextSecondaryAttack);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, flTimeWeaponIdle);
}

stock CheckTeammate(a, b)
{
	if (!a || !b) return FALSE;
	if (!IsPlayer(a) || !IsPlayer(b)) return FALSE;
	return (get_pdata_int(a, m_iTeam) == get_pdata_int(b, m_iTeam) && !get_pcvar_num(cvar_friendlyfire));
}

stock PLAYBACK_EVENT_FULL(flags, pevInvoker, eventindex, Float:flDelay, Float:vecOrigin[3], Float:vecAngles[3], Float:fParam1, Float:fParam2, iParam1, iParam2, bParam1, bParam2)
{
	engfunc(EngFunc_PlaybackEvent, flags, pevInvoker, eventindex, flDelay, vecOrigin, vecAngles, fParam1, fParam2, iParam1, iParam2, bParam1, bParam2);
}

stock MESSAGE_BEGIN(msg_dest, msg_type, const Float:pOrigin[3] = {0.0, 0.0, 0.0}, ed = 0)
{
	engfunc(EngFunc_MessageBegin, msg_dest, msg_type, pOrigin, ed);
}

stock MESSAGE_END()
{
	message_end();
}

stock WRITE_BYTE(iValue)
{
	write_byte(iValue);
}

stock WRITE_CHAR(iValue)
{
	write_char(iValue);
}

stock WRITE_SHORT(iValue)
{
	write_short(iValue);
}

stock WRITE_LONG(iValue)
{
	write_long(iValue);
}

stock WRITE_ENTITY(pEntity)
{
	write_entity(pEntity);
}

stock WRITE_ANGLE(Float:flValue)
{
	engfunc(EngFunc_WriteAngle, flValue);
}

stock WRITE_COORD(Float:flValue)
{
	engfunc(EngFunc_WriteCoord, flValue);
}

stock WRITE_STRING(const sz[])
{
	write_string(sz);
}

stock CREATE_NAMED_ENTITY(const classname[])
{
	return engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, classname));
}

stock SET_MODEL(ent, const model[])
{
	engfunc(EngFunc_SetModel, ent, model);
}

stock DispatchSpawn(pEntity)
{
	dllfunc(DLLFunc_Spawn, pEntity);
}

stock FNullEnt(index)
{
	return pev_valid(index) < 1;
}

stock Stock_Buff(id,damage,spr,scale)
{
	new vOri[3]
	if(id<33 && pev_valid(id))
	{
		get_user_origin(id,vOri,0)
		static health
		if(is_user_alive(id))
		{
			health = get_user_health(id)
			health -= damage
			if(health>0)
			{
				set_pev(id,pev_health,float(health))
				//Pub_Fake_Damage_Guns(id,id,0.00,FAKE_TYPE_TRACEBLEED|FAKE_TYPE_CHECKPHIT,9999.0)
			}
			else
			{
				set_pev(id,pev_health,float(1))
				//Pub_Fake_Damage_Guns(id,id,0.00,FAKE_TYPE_TRACEBLEED|FAKE_TYPE_CHECKPHIT,9999.0)
			}
			message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
			write_byte(TE_SPRITE)
			write_coord(vOri[0])
			write_coord(vOri[1])
			write_coord(vOri[2])
			write_short(spr)
			write_byte(scale)
			write_byte(255)
			message_end()
		}
	}
}
stock Stock_Set_Kvd(entity, const key[], const value[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	dllfunc(DLLFunc_KeyValue, entity, 0)
}

stock AirbursterAttack(id, bStab, Float:flRange, Float:fAngle, Float:flDamage, Float:flKnockBack = 0.0, iHitgroup = -1, bNoTraceCheck = FALSE)
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

	new iEnemy = get_tr2(tr, TR_pHit);
	
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

		if (!CheckAngle(id, pEntity, fAngle) && pEntity != iEnemy)
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
			if (IsPlayer(pEntity) || IsHostage(pEntity))
			{
				if (!bNoTraceCheck)
				{
					new iVictim = get_tr2(tr, TR_pHit);
					if (!pev_valid(iVictim))
						continue;
					if (!IsAlive(iVictim))
						continue;
					if (!CheckAngle(id, iVictim, fAngle) && iVictim != iEnemy)
						continue;
					if (!pev(iVictim, pev_takedamage))
						continue;
				}
				
				iHitResult = RESULT_HIT_PLAYER;

				if (IsPlayer(pEntity) || IsHostage(pEntity))
					if ((CheckBack(id, pEntity) && bStab && iHitgroup == -1) && !(bte_hms_get_skillstat(id) & (1<<1)))
						fCurDamage *= 3.0
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
					if (!CheckAngle(id, iVictim, fAngle) && iVictim != iEnemy)
						continue;
					if (!pev(iVictim, pev_takedamage))
						continue;
				}
				
				engfunc(EngFunc_MakeVectors, v_angle);
				global_get(glb_v_forward, vecForward);

				if (iHitgroup != -1)
					set_tr2(tr, TR_iHitgroup, iHitgroup);

				if (get_tr2(tr, TR_iHitgroup) == HITGROUP_HEAD)
				{
					set_tr2(tr, TR_iHitgroup, HITGROUP_CHEST);
				}
				
				ClearMultiDamage();
				ExecuteHamB(Ham_TraceAttack, pEntity, id, fCurDamage, vecForward, tr, DMG_NEVERGIB | DMG_CLUB);
				ApplyMultiDamage(id, id);

				FakeKnockBack(pEntity, vecSrc, vecEnd, flKnockBack);
			}
		}

		free_tr2(tr);

	}

	return iHitResult;
}

stock Stock_SetRendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
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


stock Stock_Send_WeaponID_Msg(id,iCswpn,iClip)
{
	if(is_user_connected(id))
	{
		message_begin(MSG_ONE_UNRELIABLE,g_msgCurWeapon,_,id)
		write_byte(1)
		write_byte(iCswpn)
		write_short(iClip)
		message_end()
	}
}
stock Stock_Send_Hide_Msg(id,iHide)
{
	message_begin(MSG_ONE_UNRELIABLE, g_msgHideWeapon, _, id)
	write_byte((iHide == 1)?(1<<6):0)
	message_end()
}
stock Stock_Can_Attack()
{
	if(g_freezetime) return 0
	return 1
}
stock Stock_Weapon_ShootSound(id)
{
	//emit_sound(id,CHAN_WEAPON,g_double[id][0]?c_sound2[g_weapon[id][0]]:c_sound1[g_weapon[id][0]],1.0, ATTN_NORM, 0, 94 + random_num(0, 15))
	new Float:vOrigin[3]; pev(id, pev_origin, vOrigin);
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, WEAPON_EVENT[CSW_KNIFE], 0.0, vOrigin, {0.0, 0.0, 0.0}, 0.0 , 0.0, (1<<1), c_iSlot[g_weapon[id][0]], false, false);
}
stock Stock_GetProbability(iMax) // 0-10
{
	if(iMax>=random_num(1,10)) return 1
	return 0
}
stock Stock_TE_Sprits(id, Float:origin[3], sprite, scale, brightness)
{
	message_begin(MSG_ONE, SVC_TEMPENTITY, _, id)
	write_byte(TE_SPRITE)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2]))
	write_short(sprite)
	write_byte(scale)
	write_byte(brightness)
	message_end()
}

stock Stock_TE_BEAMPOINTS(const Float:Source[ 3 ], const Float:Velocity[ 3 ])
{
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BEAMPOINTS)
	write_coord(floatround(Source[0]))
	write_coord(floatround(Source[1]))
	write_coord(floatround(Source[2]))
	write_coord(floatround(Velocity[0]))
	write_coord(floatround(Velocity[1]))
	write_coord(floatround(Velocity[2]))
	write_short(g_cache_trail)
	write_byte(0)
	write_byte(0)
	write_byte(10) //Life
	write_byte(20) //Width
	write_byte(0)
	write_byte(0) // r
	write_byte(0) // g
	write_byte(255) // b
	write_byte(255)
	write_byte(0)
	message_end()
}

stock Stock_Check_Back(iEnemy,id)
{
	new Float:anglea[3], Float:anglev[3]
	pev(iEnemy, pev_v_angle, anglea)
	pev(id, pev_v_angle, anglev)
	new Float:angle = anglea[1] - anglev[1]
	if(angle < -180.0) angle += 360.0
	if(angle <= 60.0 && angle >= -60.0) return 1
	return 0
}
stock Stock_Aim_At_Origin(id, Float:target[3], Float:angles[3])
{
	static Float:vec[3]
	pev(id,pev_origin,vec)
	vec[0] = target[0] - vec[0]
	vec[1] = target[1] - vec[1]
	vec[2] = target[2] - vec[2]
	engfunc(EngFunc_VecToAngles,vec,angles)
	angles[0] *= -1.0, angles[2] = 0.0
}
stock Stock_Ent_Move_To(ent, Float:target[3], speed)
{
	// set vel
	static Float:vec[3]
	Stock_Aim_At_Origin(ent,target,vec)
	engfunc(EngFunc_MakeVectors, vec)
	global_get(glb_v_forward, vec)
	vec[0] *= speed
	vec[1] *= speed
	vec[2] *= speed
	set_pev(ent, pev_velocity, vec)

	// turn to target
	new Float:angle[3]
	Stock_Aim_At_Origin(ent, target, angle)
	angle[0] = 0.0
	set_pev(ent, pev_angles, angle)
}
stock Stock_Get_Velocity_Angle(entity, Float:output[3])
{
	static Float:velocity[3]
	pev(entity, pev_velocity, velocity)
	vector_to_angle(velocity, output)
	if( output[0] > 90.0 ) output[0] = -(360.0 - output[0])
}
stock Float:Stock_BTE_CheckAngle(id,iTarget)
{
	new Float:vOricross[2],Float:fRad,Float:vId_ori[3],Float:vTar_ori[3],Float:vId_ang[3],Float:fLength,Float:vForward[3]

	Stock_Get_Origin(id, vId_ori)
	Stock_Get_Origin(iTarget, vTar_ori)

	pev(id,pev_angles,vId_ang)
	for(new i=0;i<2;i++)
	{
		vOricross[i] = vTar_ori[i] - vId_ori[i]
	}

	fLength = floatsqroot(vOricross[0]*vOricross[0] + vOricross[1]*vOricross[1])

	if(fLength<=0.0)
	{
		vOricross[0]=0.0
		vOricross[1]=0.0
	}
	else
	{
		vOricross[0]=vOricross[0]*(1.0/fLength)
		vOricross[1]=vOricross[1]*(1.0/fLength)
	}

	engfunc(EngFunc_MakeVectors,vId_ang)
	global_get(glb_v_forward,vForward)

	fRad = vOricross[0]*vForward[0]+vOricross[1]*vForward[1]

	return fRad   //->   RAD 90' = 0.5rad
}
stock Stock_Get_Origin(id, Float:origin[3])
{
	new Float:maxs[3],Float:mins[3]
	if(pev(id,pev_solid)==SOLID_BSP)
	{
		pev(id,pev_maxs,maxs)
		pev(id,pev_mins,mins)
		origin[0] = (maxs[0] - mins[0]) / 2 + mins[0]
		origin[1] = (maxs[1] - mins[1]) / 2 + mins[1]
		origin[2] = (maxs[2] - mins[2]) / 2 + mins[2]
	}
	else pev(id,pev_origin,origin)
}
stock Stock_is_aiming_wall(id, Float:flRange)
{
	new Float:vecStart[3], Float:vecTarget[3],Float:vecViewOfs[3]
	new trRes
	pev(id, pev_origin, vecStart)
	pev(id, pev_view_ofs, vecViewOfs)
	xs_vec_add(vecStart, vecViewOfs, vecStart)

	new Float:angle[3],Float:Forw[3]
	pev(id,pev_v_angle,angle)
	engfunc(EngFunc_MakeVectors,angle)
	global_get(glb_v_forward,Forw)
	xs_vec_mul_scalar(Forw,flRange,Forw)

	xs_vec_add(vecStart, Forw, vecTarget)
	engfunc(EngFunc_TraceLine, vecStart, vecTarget, 0, id, trRes)
	new Float:flFraction
	get_tr2(trRes, TR_flFraction, flFraction)

	new pHit = get_tr2(trRes, TR_pHit)
	if(pev_valid(pHit))
	{
		if(!is_user_alive(pHit))
		{
			return 1;
		}
	}
	else if(flFraction < 1.0)
	{
		return 1;
	}
	return 0;
}

stock Stock_TraceBlood(id, iScale)
{
	new Float:start[3], Float:view_ofs[3], Float:end[3]
	pev(id, pev_origin, start)
	pev(id, pev_view_ofs, view_ofs)
	xs_vec_add(start, view_ofs, start)

	pev(id, pev_v_angle, end)
	engfunc(EngFunc_MakeVectors, end)
	global_get(glb_v_forward, end)
	xs_vec_mul_scalar(end, 8120.0, end)
	xs_vec_add(start, end, end)
	new ptr = create_tr2();
	engfunc(EngFunc_TraceLine, start, end, DONT_IGNORE_MONSTERS, id, ptr)
	get_tr2(ptr, TR_vecEndPos, end)
	free_tr2(ptr)

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, end, 0);
	write_byte(TE_BLOODSPRITE)
	engfunc(EngFunc_WriteCoord,end[0])
	engfunc(EngFunc_WriteCoord,end[1])
	engfunc(EngFunc_WriteCoord,end[2])
	write_short(g_cache_bloodspray)
	write_short(g_cache_blood)
	write_byte(75)
	write_byte(iScale)
	message_end()
}

stock Stock_TraceBlood2(id, id2, iScale)
{
	new Float:v1[3],Float:v2[3]
	pev(id,pev_origin,v1)
	pev(id2,pev_origin,v2)

	new Float:end[3]
	new ptr = create_tr2();
	engfunc(EngFunc_TraceLine, v1, v2, 1, -1, ptr)
	get_tr2(ptr, TR_vecEndPos, end)

	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, end, 0);
	write_byte(TE_BLOODSPRITE)
	engfunc(EngFunc_WriteCoord,end[0])
	engfunc(EngFunc_WriteCoord,end[1])
	engfunc(EngFunc_WriteCoord,end[2])
	write_short(g_cache_bloodspray)
	write_short(g_cache_blood)
	write_byte(75)
	write_byte(iScale)
	message_end()
}

stock Stock_Get_Speed_Vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
}

stock Float:Stock_Adjust_Damage(Float:fPoint[3], ent, ignored)
{
	new Float:fOrigin[3],tr,Float:fFraction
	pev(ent, pev_origin, fOrigin)
	engfunc(EngFunc_TraceLine, fPoint, fOrigin, DONT_IGNORE_MONSTERS, ignored, tr)
	get_tr2(tr, TR_flFraction, fFraction)
	if ( fFraction == 1.0 || get_tr2( tr, TR_pHit ) == ent ) return 1.0
	return 0.6
}
stock Stock_Velocity_By_Aim(Float:vAngle[3],Float:fAngleOffset,Float:fMulti,Float:vVelocity[3])
{
	static Float:vForward[3],Float:vAngleTemp[3]
	xs_vec_copy(vAngle,vAngleTemp)
	vAngleTemp[0] += fAngleOffset
	angle_vector(vAngleTemp,ANGLEVECTOR_FORWARD,vForward)
	xs_vec_mul_scalar(vForward,fMulti, vVelocity)

		/*vVelocity[0] = floatcos(vAngle[1], degrees) * fMulti
		vVelocity[1] = floatsin(vAngle[1], degrees) * fMulti
		vVelocity[2] = floatcos(vAngle[0]+fAngleOffset, degrees) * fMulti
		return 1*/
}
stock Stock_Get_Postion(id,Float:forw,Float:right,Float:up,Float:vStart[])
{
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]

	pev(id, pev_origin, vOrigin)
	pev(id, pev_view_ofs,vUp)
	xs_vec_add(vOrigin,vUp,vOrigin)
	pev(id, pev_v_angle, vAngle)

	angle_vector(vAngle,ANGLEVECTOR_FORWARD,vForward)
	angle_vector(vAngle,ANGLEVECTOR_RIGHT,vRight)
	angle_vector(vAngle,ANGLEVECTOR_UP,vUp)

	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}
stock Stock_EmitSound(id,sSound[],iChan)
{
	emit_sound(id,iChan,sSound,1.0, ATTN_NORM, 0, PITCH_NORM)
}
stock Stock_Send_Anim(id,iAnim)
{
	if(!is_user_alive(id)) return;

	set_pev(id, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(iAnim)
	write_byte(pev(id, pev_body))
	message_end()
}
stock Stock_Get_Idwpn_FromSz(sModel[])
{
	strtolower(sModel)
	for(new i=1; i<MAX_WPN; i++)
	{
		if (equali(c_sModel[i], sModel))
		{
			return i;
		}
	}
	return 0;
}
stock Stock_Config_User_Bpammo(id, iCswpn, iAmmo = 0, iSet = 0)
{
	static iOffset
	switch(iCswpn)
	{
		case CSW_AWP: iOffset = OFFSET_AWM_AMMO;
		case CSW_SCOUT,CSW_AK47,CSW_G3SG1: iOffset = OFFSET_SCOUT_AMMO;
		case CSW_M249: iOffset = OFFSET_PARA_AMMO;
		case CSW_M4A1,CSW_FAMAS,CSW_AUG,CSW_SG550,CSW_GALI,CSW_SG552: iOffset = OFFSET_FAMAS_AMMO;
		case CSW_M3,CSW_XM1014: iOffset = OFFSET_M3_AMMO;
		case CSW_USP,CSW_UMP45,CSW_MAC10: iOffset = OFFSET_USP_AMMO;
		case CSW_FIVESEVEN,CSW_P90: iOffset = OFFSET_FIVESEVEN_AMMO;
		case CSW_DEAGLE: iOffset = OFFSET_DEAGLE_AMMO;
		case CSW_P228: iOffset = OFFSET_P228_AMMO;
		case CSW_GLOCK18,CSW_MP5NAVY,CSW_TMP,CSW_ELITE: iOffset = OFFSET_GLOCK_AMMO;
		case CSW_FLASHBANG: iOffset = OFFSET_FLASH_AMMO;
		case CSW_HEGRENADE: iOffset = OFFSET_HE_AMMO;
		case CSW_SMOKEGRENADE: iOffset = OFFSET_SMOKE_AMMO;
		case CSW_C4: iOffset = OFFSET_C4_AMMO;
		default: return 0;
	}
	if(iSet) set_pdata_int(id, iOffset, iAmmo, OFFSET_LINUX_WEAPONS)
	else return get_pdata_int(id, iOffset, OFFSET_LINUX_WEAPONS)
	return 0;
}
stock Stock_Kill_Item(id,iEnt)
{
	ExecuteHam(Ham_Weapon_RetireWeapon,iEnt)
	if(ExecuteHam(Ham_RemovePlayerItem,id,iEnt))
	{
		ExecuteHam(Ham_Item_Kill, iEnt)
	}
}
stock Stock_Strip_Slot(id, slot)
{
	new item = get_pdata_cbase(id, m_rgpPlayerItems + slot);

	while (item > 0)
	{
		set_pev(id, pev_weapons, pev(id, pev_weapons) &~ (1<<get_pdata_int(item, m_iId)))

		ExecuteHamB(Ham_Weapon_RetireWeapon, item);
		new new_item = get_pdata_cbase(item, m_pNext);

		if (ExecuteHamB(Ham_RemovePlayerItem, id, item))
			ExecuteHamB(Ham_Item_Kill, item);

		item = new_item;
	}

	set_pdata_cbase(id, m_rgpPlayerItems + slot, -1);

	/*new weapons[32], num
	get_user_weapons(id, weapons, num)
	for (new i = 0; i < num; i++)
	{
		static iSlot; iSlot = Stock_Get_Wpn_Slot(weapons[i])
		if (iSlot == iRemoveSlot)
		{
			set_pev(id,pev_weapons,(pev(id,pev_weapons)&~(1<<(weapons[i]))))
			new iEnt
			while((iEnt = engfunc(EngFunc_FindEntityByString,iEnt,"classname",WEAPON_NAME[weapons[i]])) && pev(iEnt,pev_owner) != id) {}
			if(iEnt)
			{
				ExecuteHamB(Ham_Weapon_RetireWeapon,iEnt)
				if(ExecuteHamB(Ham_RemovePlayerItem,id,iEnt))
				{
					ExecuteHamB(Ham_Item_Kill, iEnt)
				}
			}
		}
	}*/
}

stock RemoveGrenade(id)
{
	new item = get_pdata_cbase(id, m_rgpPlayerItems + 4);

	while (item > 0)
	{
		new new_item = get_pdata_cbase(item, m_pNext);

		if (get_pdata_int(item, m_iId) == CSW_HEGRENADE)
		{
			set_pev(id, pev_weapons, pev(id, pev_weapons) &~ 1<<CSW_HEGRENADE)

			ExecuteHamB(Ham_Weapon_RetireWeapon, item);

			if (ExecuteHamB(Ham_RemovePlayerItem, id, item))
				ExecuteHamB(Ham_Item_Kill, item);

			break;
		}

		item = new_item;
	}
}


stock Stock_Drop_Slot(id,iSlot)
{
	new weapons[32], num
	get_user_weapons(id, weapons, num)
	for (new i = 0; i < num; i++)
	{
		new slot = Stock_Get_Wpn_Slot(weapons[i]);

		if (iSlot == slot)
		{
			static wname[32]
			get_weaponname(weapons[i], wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}
stock Stock_Set_Vis(iEnt, iVis = 1)
{
	set_pev(iEnt, pev_effects, iVis == 1 ? pev(iEnt, pev_effects) & ~EF_NODRAW : pev(iEnt, pev_effects) | EF_NODRAW)
}
stock Stock_Give_Cswpn(id, iBteWpn=0, const item[], iDouble=0, iAmmo=0)
{
#if defined _DEBUG
	PRINT("%s", item)
#endif
	static iEnt
	iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item))
	set_pev(iEnt, pev_spawnflags, pev(iEnt, pev_spawnflags) | SF_NORESPAWN)
	Set_Wpn_Data(iEnt,DEF_SPAWN,1)
	dllfunc(DLLFunc_Spawn, iEnt)

	if(iDouble)
	{
		Set_Wpn_Data(iEnt,DEF_ISDOUBLE,1)
	}
	if(iAmmo)
	{
		Set_Wpn_Data(iEnt,DEF_AMMO,iAmmo)
	}

	if(c_iType[iBteWpn] == WEAPONS_SVDEX || c_iSpecial[iBteWpn] == SPECIAL_BLOCKAR || c_iSpecial[iBteWpn] == SPECIAL_BLOCKSMG || c_iSpecial[iBteWpn] == SPECIAL_AUGEX)
	{
		set_pdata_int(iEnt, 25, c_iExtraAmmo[iBteWpn]);
	}

	if (iEnt)
		set_pev(iEnt, pev_iuser2, 0);

	dllfunc(DLLFunc_Touch, iEnt, id)
	//set_pdata_int(iEnt,m_iDefaultAmmo,0,4)

	if(pev(iEnt,pev_owner)!=id) engfunc(EngFunc_RemoveEntity, iEnt)
	return iEnt
}
stock Stock_Get_Wpn_Slot(iWpn)
{
	if(PRIMARY_WEAPONS_BIT_SUM & (1<<iWpn))
	{
		return WPN_RIFLE
	}
	else if(SECONDARY_WEAPONS_BIT_SUM & (1<<iWpn))
	{
		return WPN_PISTOL
	}
	else if(iWpn==CSW_KNIFE)
	{
		return WPN_KNIFE
	}
	else if(iWpn == CSW_HEGRENADE)
	{
		return WPN_HE
	}
	else if(iWpn == CSW_C4)
	{
		return 5
	}
	return 6 //FLASHBANG SMOKEBANG
}
stock Stock_Reset_Wpn_Slot(id,iSlot)
{
	g_weapon[id][iSlot] = 0
	g_user_ammo[id][iSlot] = 0
	g_user_clip[id][iSlot] = 0
	if(iSlot <2)
	{
		g_double[id][iSlot] = 0
	}
}
stock Stock_Set_Wpn_Current(id,iSlot)
{
	g_weapon[id][0] = g_weapon[id][iSlot]
	g_user_ammo[id][0] = g_user_ammo[id][iSlot]
	g_user_clip[id][0] = g_user_clip[id][iSlot]
	if(iSlot <2)
	{
		g_double[id][0] = g_double[id][iSlot]
	}
}
stock Stock_Store_Wpn_Current(id,iSlot,iClip,iAmmo)
{
	g_weapon[id][iSlot] = g_weapon[id][0]
	g_user_ammo[id][iSlot] = iAmmo
	// Save for double
	if(c_iType[g_weapon[id][iSlot]] == WEAPONS_DOUBLE)
	{
		// Save clip
		g_user_clip[id][iSlot] = iClip
	}
	else g_user_clip[id][iSlot] = 0
	if(iSlot <2)
	{
		g_double[id][iSlot] = g_double[id][0]
	}
}
stock CheckMyWpn(szModel[])
{
	if (g_bEnableMyWpn == FALSE)
		return 1;

	for (new i = 0; i < MAX_WPN; i++)
	{
		if (equal(szModel, g_szMyWpn[i]))
			return 1;
	}

	return 0;
}
stock GetBTEWeaponID(szModel[])
{
	for (new i=0; i<MAX_WPN; i++)
	{
		if (equal(szModel, c_sModel[i]))
			return i;
	}

	return -1;
}
stock Float:Stock_Get_Body_Dmg(iBody)
{
	switch (iBody)
	{
		case HIT_GENERIC: return 0.75
		case 1: return 4.0 // 头
		case 2 : return 1.0 // 胸
		case 3 : return 1.25 // 腹
		case 4,5,6,7 : return 0.75 // 手 腿
		default :return 0.75
	}
	return 1.0
}
stock Stock_TraceBleed(iPlayer, Float:fDamage, Float:vecDir[3], iTr)
{
	//if (ExecuteHam(Ham_BloodColor, iPlayer) == DONT_BLEED)
		//return

	if (fDamage == 0)
		return

	new Float:vecTraceDir[3]
	new Float:fNoise
	new iCount, iBloodTr

	if (fDamage < 10)
	{
		fNoise = 0.1
		iCount = 1
	}
	else if (fDamage < 25)
	{
		fNoise = 0.2
		iCount = 2
	}
	else
	{
		fNoise = 0.3
		iCount = 4
	}

	for (new i = 0; i < iCount; i++)
	{
		xs_vec_mul_scalar(vecDir, -1.0, vecTraceDir)

		vecTraceDir[0] += random_float(-fNoise, fNoise)
		vecTraceDir[1] += random_float(-fNoise, fNoise)
		vecTraceDir[2] += random_float(-fNoise, fNoise)

		static Float:vecEndPos[3]
		get_tr2(iTr, TR_vecEndPos, vecEndPos)
		xs_vec_mul_scalar(vecTraceDir, -0.5, vecTraceDir)
		xs_vec_add(vecTraceDir, vecEndPos, vecTraceDir)
		engfunc(EngFunc_TraceLine, vecEndPos, vecTraceDir, IGNORE_MONSTERS, iPlayer, iBloodTr)

		static Float:flFraction
		get_tr2(iBloodTr, TR_flFraction, flFraction)

		if (flFraction != -1.0)
			Stock_BloodDecalTrace(iBloodTr/*, ExecuteHam(Ham_BloodColor, iPlayer)*/)
	}
}
stock Stock_BloodDecalTrace(iTrace/*, iBloodColor*/)
{
	switch (random_num(0, 5))
	{
		case 0:
		{
			Stock_DecalTrace(iTrace, engfunc(EngFunc_DecalIndex, "{blood1"))
		}
		case 1:
		{
			Stock_DecalTrace(iTrace, engfunc(EngFunc_DecalIndex, "{blood2"))
		}
		case 2:
		{
			Stock_DecalTrace(iTrace, engfunc(EngFunc_DecalIndex, "{blood3"))
		}
		case 3:
		{
			Stock_DecalTrace(iTrace, engfunc(EngFunc_DecalIndex, "{blood4"))
		}
		case 4:
		{
			Stock_DecalTrace(iTrace, engfunc(EngFunc_DecalIndex, "{blood5"))
		}
		case 5:
		{
			Stock_DecalTrace(iTrace, engfunc(EngFunc_DecalIndex, "{blood6"))
		}
	}
}
stock Stock_DecalTrace(iTrace, iDecalNumber)
{
	if (iDecalNumber < 0)
		return

	static Float:flFraction
	get_tr2(iTrace, TR_flFraction, flFraction)

	if (flFraction == 1.0)
		return

	new iHit = get_tr2(iTrace, TR_pHit)

	if (pev_valid(iHit))
	{
		if ((pev(iHit, pev_solid) != SOLID_BSP && pev(iHit, pev_movetype) != MOVETYPE_PUSHSTEP))
			return
	}
	else
		iHit = 0

	new iMessage = TE_DECAL
	if (iHit != 0)
	{
		if (iDecalNumber > 255)
		{
			iDecalNumber -= 256
			iMessage = TE_DECALHIGH
		}
	}
	else
	{
		iMessage = TE_WORLDDECAL
		if (iDecalNumber > 255)
		{
			iDecalNumber -= 256
			iMessage= TE_WORLDDECALHIGH
		}
	}

	static Float:vecEndPos[3]
	get_tr2(iTrace, TR_vecEndPos, vecEndPos)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(iMessage)
	engfunc(EngFunc_WriteCoord, vecEndPos[0])
	engfunc(EngFunc_WriteCoord, vecEndPos[1])
	engfunc(EngFunc_WriteCoord, vecEndPos[2])
	write_byte(iDecalNumber)
	if (iHit) write_short(iHit)
	message_end()

}
stock Stock_BloodEffect(Float:vecOri[3], scale)
{
	//if(!get_pcvar_num(cvar_friendlyfire)) return
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	engfunc(EngFunc_WriteCoord,vecOri[0])
	engfunc(EngFunc_WriteCoord,vecOri[1])
	engfunc(EngFunc_WriteCoord,vecOri[2])
	write_short(g_cache_bloodspray)
	write_short(g_cache_blood)
	write_byte(75)
	write_byte(scale)
	message_end()
}
stock Stock_Is_Direct(id,id2)
{
	new Float:v1[3],Float:v2[3]//,Float:v3[3]
	pev(id,pev_origin,v1)
	pev(id2,pev_origin,v2)
	//pev(id,pev_view_ofs,v3)
	//xs_vec_add(v1,v3,v1)
	//pev(id2,pev_view_ofs,v3)
	//xs_vec_add(v2,v3,v2)

	new Float:hit_origin[3]
	new tr

	engfunc(EngFunc_TraceLine, v1, v2, 1, -1, tr)

	get_tr2(tr, TR_vecEndPos, hit_origin)


	if (!vector_distance(hit_origin, v2)) return 1;

	return 0;

	/*new tr
	engfunc(EngFunc_TraceLine, v1, v2, DONT_IGNORE_MONSTERS, id, tr)
	PRINT("%d",get_tr2(tr, TR_flFraction ) != 1.0)
	//return (get_tr2(tr, TR_pHit ) == id2);
	return (get_tr2(tr, TR_flFraction ) != 1.0);*/
}
/*stock Stock_Not_Throuth_thing(id,id2)
{
	new Float:v1[3],Float:v2[3],Float:v3[3]
	pev(id,pev_origin,v1)
	pev(id2,pev_origin,v2)
	pev(id,pev_view_ofs,v3)
	xs_vec_add(v1,v3,v1)
	pev(id2,pev_view_ofs,v3)
	xs_vec_add(v2,v3,v2)

	new tr
	engfunc(EngFunc_TraceLine, v1, v2, DONT_IGNORE_MONSTERS, id, tr)
	new a = get_tr2(tr, TR_flFraction) == 1.0
	PRINT("%d",a)
	return a;
}*/
stock PunchAxis(id, Float:x, Float:y, Float:x_min = -100.0, Float:y_min = -100.0)
{
	new Float:vec[3];
	pev(id, pev_punchangle, vec);
	vec[0] += x;
	vec[1] += y;

	vec[0] = vec[0] < x_min ? x_min : vec[0];
	vec[0] = vec[0] > -x_min ? -x_min : vec[0];
	vec[1] = vec[1] < y_min ? y_min : vec[1];
	vec[1] = vec[1] > -y_min ? -y_min : vec[1];

	set_pev(id, pev_punchangle, vec);
}

stock Stock_GetSpeedVector(const Float:origin1[3], const Float:origin2[3], Float:speed, Float:new_velocity[3])
{
	xs_vec_sub(origin2, origin1, new_velocity)
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	xs_vec_mul_scalar(new_velocity, num, new_velocity)
}

stock Stock_Get_Aiming(id, Float:end[3])
{
	new Float:start[3], Float:view_ofs[3]
	pev(id, pev_origin, start)
	pev(id, pev_view_ofs, view_ofs)
	xs_vec_add(start, view_ofs, start)

	pev(id, pev_v_angle, end)
	engfunc(EngFunc_MakeVectors, end)
	global_get(glb_v_forward, end)
	xs_vec_mul_scalar(end, 8120.0, end)
	xs_vec_add(start, end, end)
	new ptr = create_tr2();
	engfunc(EngFunc_TraceLine, start, end, DONT_IGNORE_MONSTERS, id, ptr)
	get_tr2(ptr, TR_vecEndPos, end)
	free_tr2(ptr)
}

stock can_damage(id1, id2)
{
	if(id1 <= 0 || id1 >= 33 || id2 <= 0 || id2 >= 33)
		return 1;

	return (get_pdata_int(id1, m_iTeam) != get_pdata_int(id2, m_iTeam) || get_pcvar_num(cvar_friendlyfire));
}
stock is_user_zbot(id)
{
	if (!is_user_bot(id))
		return 0;

	new tracker[2], friends[2], ah[2];
	get_user_info(id,"tracker",tracker,1);
	get_user_info(id,"friends",friends,1);
	get_user_info(id,"_ah",ah,1);

	if (tracker[0] == '0' && friends[0] == '0' && ah[0] == '0')
		return 0; // PodBot / YaPB / SyPB

	return 1; // Zbot
}

stock bool:fm_is_in_viewcone(index, const Float:point[3]) {
	new Float:angles[3];
	pev(index, pev_angles, angles);
	engfunc(EngFunc_MakeVectors, angles);
	global_get(glb_v_forward, angles);
	angles[2] = 0.0;

	new Float:origin[3], Float:diff[3], Float:norm[3];
	pev(index, pev_origin, origin);
	xs_vec_sub(point, origin, diff);
	diff[2] = 0.0;
	xs_vec_normalize(diff, norm);

	new Float:dot, Float:fov;
	dot = xs_vec_dot(norm, angles);
	pev(index, pev_fov, fov);
	if (dot >= floatcos(fov * M_PI / 360))
		return true;

	return false;
}

stock PlayEmptySound(id)
{
	if (CSWPN_SEC & 1<<get_user_weapon(id))
		emit_sound(id, CHAN_AUTO, "weapons/dryfire_pistol.wav", 0.8, ATTN_NORM, 0, PITCH_NORM);
	else
		emit_sound(id, CHAN_AUTO, "weapons/dryfire_rifle.wav", 0.8, ATTN_NORM, 0, PITCH_NORM);
}
stock SendKnifeSound(id, iType, iAnim)
{
	new Float:vOrigin[3]; pev(id, pev_origin, vOrigin);
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, WEAPON_EVENT[CSW_KNIFE], 0.0, vOrigin, {0.0, 0.0, 0.0}, 0.0 , float(iAnim), (1<<2), iType, FALSE, FALSE);
}
stock SendWeaponShootSound(id, bType, bCrosschar, bType2 = FALSE)
{
	//emit_sound(id,CHAN_WEAPON,g_double[id][0]?c_sound2[g_weapon[id][0]]:c_sound1[g_weapon[id][0]],1.0, ATTN_NORM, 0, 94 + random_num(0, 15))
	new Float:vOrigin[3]; pev(id, pev_origin, vOrigin);
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, WEAPON_EVENT[CSW_KNIFE], 0.0, vOrigin, {0.0, 0.0, 0.0}, 0.0 , bType2 ? 1.0 : 0.0, (1<<1), c_iSlot[g_weapon[id][0]], bType, bCrosschar);
}
stock SendExplosion(pEntity, Float:vecOrigin[3], iType)
{
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, pEntity, m_usExplosion, 0.0, vecOrigin, {0.0, 0.0, 0.0}, 0.0 , 0.0, iType, 0, FALSE, FALSE);
}
stock SendTempEntity(pEntity, iType, iVictim, bRemoveTouchPlayer = TRUE)
{
	if (bRemoveTouchPlayer && IsPlayer(iVictim))
		return;

	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, pEntity, m_usTempEntity, 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0 , 0.0, iType, iVictim, FALSE, FALSE);
}
stock SendWeaponAnim(id, iAnim)
{
	if(!is_user_alive(id) || iAnim < 0) return;

	set_pev(id, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(iAnim)
	write_byte(pev(id, pev_body))
	message_end()
}

stock SendWeaponAnim2(id, iAnim)
{
	if (!is_user_alive(id) || iAnim < 0) return;
	if (pev(id, pev_weaponanim) == iAnim) return;

	set_pev(id, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(iAnim)
	write_byte(pev(id, pev_body))
	message_end()
}

stock CheckBack(iEnemy,id)
{
	new Float:anglea[3], Float:anglev[3]
	pev(iEnemy, pev_v_angle, anglea)
	pev(id, pev_v_angle, anglev)
	new Float:angle = anglea[1] - anglev[1]
	if(angle < -180.0) angle += 360.0
	if(angle <= 45.0 && angle >= -45.0) return 1
	return 0
}
stock GetGunPosition(id, Float:vecSrc[3])
{
	new Float:vecViewOfs[3];
	pev(id, pev_origin, vecSrc);
	pev(id, pev_view_ofs, vecViewOfs);
	xs_vec_add(vecSrc, vecViewOfs, vecSrc);
}
stock IsBSPModel(pEntity)
{
	return (pev(pEntity, pev_solid) == SOLID_BSP || pev(pEntity, pev_movetype) == MOVETYPE_PUSHSTEP);
}
stock IsPlayer(pEntity)
{
	if (pEntity <= 0)
		return FALSE;

	return ExecuteHam(Ham_Classify, pEntity) == CLASS_PLAYER;
}
stock IsHostage(pEntity)
{
	/*new classname[32];
	pev(pEntity, pev_classname, classname, charsmax(classname));
	return equal(classname, "hostage_entity");*/

	return ExecuteHam(Ham_Classify, pEntity) == CLASS_HUMAN_PASSIVE;
}
stock IsAlive(pEntity)
{
	if (pEntity < 1)
		return 0;

	return (pev(pEntity, pev_deadflag) == DEAD_NO && pev(pEntity, pev_health) > 0);
}
stock ClearMultiDamage()
{
	OrpheuCall(handleClearMultiDamage);
}
stock ApplyMultiDamage(inflictor, iAttacker)
{
	OrpheuCall(handleApplyMultiDamage, inflictor, iAttacker);
}
stock Float:DotProduct(Float:a[2], Float:b[2]) { return( a[0]*b[0] + a[1]*b[1]); }
/*stock FindHullIntersection(Float:vecStart[3], tr, Float:pflMins[3], Float:pfkMaxs[3], pEntity)
{
	new trTemp;
	new Float:flDistance = 1000000.0;
	float *pflMinMaxs[2] = { pflMins, pfkMaxs };

	new Float:vecHullEnd[3];
	get_tr2(tr, TR_vecEndPos, vecHullEnd);

	vecHullEnd = vecSrc + ((vecHullEnd - vecSrc) * 2);
	TRACE_LINE(vecSrc, vecHullEnd, dont_ignore_monsters, pEntity, &trTemp);

	if (trTemp.flFraction < 1)
	{
		tr = trTemp;
		return;
	}

	for (int i = 0; i < 2; i++)
	{
		for (int j = 0; j < 2; j++)
		{
			for (int k = 0; k < 2; k++)
			{
				Vector vecEnd;
				vecEnd.x = vecHullEnd.x + pflMinMaxs[i][0];
				vecEnd.y = vecHullEnd.y + pflMinMaxs[j][1];
				vecEnd[2] = vecHullEnd[2] + pflMinMaxs[k][2];

				TRACE_LINE(vecSrc, vecEnd, dont_ignore_monsters, pEntity, &trTemp);

				if (trTemp.flFraction < 1)
				{
					Float:flThisDistance = (trTemp.vecEndPos - vecSrc).Length();

					if (flThisDistance < flDistance)
					{
						tr = trTemp;
						flDistance = flThisDistance;
					}
				}
			}
		}
	}
}*/
			// 看起来错了
			/*new Float:vec2LOS[2], Float:vec2Forward[2], Float:angles[3];

			global_get(glb_v_forward, vecForward);
			vec2LOS[0] = vecForward[0];
			vec2LOS[1] = vecForward[1];

			pev(id, pev_angles, angles);
			engfunc(EngFunc_MakeVectors, angles);
			global_get(glb_v_forward, vecForward);

			vec2Forward[0] = vecForward[0];
			vec2Forward[1] = vecForward[1];

			new Float:flLen = floatsqroot(vec2LOS[0]*vec2LOS[0] + vec2LOS[1]*vec2LOS[1]);
			if (flLen == 0.0)
			{
				vec2LOS[0] = vec2LOS[1] = 0.0;
			}
			else
			{
				flLen = 1 / flLen;
				vec2LOS[0] *= flLen;
				vec2LOS[1] *= flLen;
			}

			PRINT("%f %f | %f %f", vec2LOS[0], vec2LOS[1], vec2Forward[0], vec2Forward[1])

			if (DotProduct(vec2LOS, vec2Forward) > 0.8)
				flDamage *= 3.0;

			PRINT("%f", DotProduct(vec2LOS, vec2Forward))*/


stock CheckAngle(iAttacker, iVictim, Float:fAngle)
{
	return (fAngle >= 360.0 || Stock_BTE_CheckAngle(iAttacker, iVictim) > floatcos(fAngle,degrees))
}

stock GetOrigin(pEntity, Float:vecOrigin[3])
{
	new Float:maxs[3], Float:mins[3];
	if (pev(pEntity, pev_solid) == SOLID_BSP)
	{
		pev(pEntity, pev_maxs, maxs);
		pev(pEntity, pev_mins, mins);
		vecOrigin[0] = (maxs[0] - mins[0]) / 2 + mins[0];
		vecOrigin[1] = (maxs[1] - mins[1]) / 2 + mins[1];
		vecOrigin[2] = (maxs[2] - mins[2]) / 2 + mins[2];
	}
	else pev (pEntity, pev_origin, vecOrigin);
}

stock KnifeAttack(id, bStab, Float:flRange, Float:flDamage, Float:flKnockBack=0.0, iHitgroup = -1, bitsDamageType = DMG_NEVERGIB | DMG_BULLET)
{
	new Float:vecSrc[3], Float:vecEnd[3], Float:v_angle[3], Float:vecForward[3], Float:vecTemp[3];
	new Float:vecSource[3];
	GetGunPosition(id, vecSrc);
	xs_vec_copy(vecSrc, vecSource);

	pev(id, pev_v_angle, v_angle);
	engfunc(EngFunc_MakeVectors, v_angle);

	global_get(glb_v_forward, vecForward);
	xs_vec_mul_scalar(vecForward, flRange, vecTemp);

	xs_vec_add(vecSrc, vecTemp, vecEnd);

	new tr = create_tr2();
	engfunc(EngFunc_TraceLine, vecSrc, vecEnd, dont_ignore_monsters, id, tr);

	new Float:flFraction;
	get_tr2(tr, TR_flFraction, flFraction);

	if (flFraction >= 1.0)
	{
		engfunc(EngFunc_TraceHull, vecSrc, vecEnd, dont_ignore_monsters, head_hull, id, tr);
	}

	get_tr2(tr, TR_flFraction, flFraction);

	new iHitResult = RESULT_HIT_NONE;
	new Float:flVol = 1.0;
	new bCanCross = TRUE;
	new pIgnoreEntity = id
	new Float:fCurDistance = 0.0;
	new Float:vecTempOrigin[3];
	new Float:flCurDamage = flDamage;
	
	while (bCanCross != FALSE)
	{
		flCurDamage = flDamage;
		if (flFraction < 1.0)
		{
			new pEntity = get_tr2(tr, TR_pHit);
			
			if (pEntity == id)
			{
				pIgnoreEntity = pEntity;
				GetOrigin(pEntity, vecTempOrigin);
				fCurDistance = get_distance_f(vecSource, vecTempOrigin);
				if (fCurDistance >= flRange)
				{
					bCanCross = FALSE;
					break;
				}
				get_tr2(tr, TR_vecEndPos, vecSrc);
				xs_vec_mul_scalar(vecForward, flRange - fCurDistance, vecTemp);
				xs_vec_add(vecSrc, vecTemp, vecEnd);
				engfunc(EngFunc_TraceLine, vecSrc, vecEnd, dont_ignore_monsters, pIgnoreEntity, tr);

				get_tr2(tr, TR_flFraction, flFraction);

				if (flFraction >= 1.0)
				{
					engfunc(EngFunc_TraceHull, vecSrc, vecEnd, dont_ignore_monsters, head_hull, pIgnoreEntity, tr);
				}

				get_tr2(tr, TR_flFraction, flFraction);
				continue;
			}

			if (!iHitResult) iHitResult = RESULT_HIT_WORLD;

			if (pev_valid(pEntity) && (IsPlayer(pEntity) || IsHostage(pEntity)))
			{
				if (iHitgroup == -1)
				flCurDamage = KnifeSettings(id, bStab, pEntity, tr, flDamage);

				iHitResult = RESULT_HIT_PLAYER;

				set_pdata_int(id, m_iWeaponVolume, KNIFE_BODYHIT_VOLUME);
			}

			if (pev_valid(pEntity))
			{
				engfunc(EngFunc_MakeVectors, v_angle);
				global_get(glb_v_forward, vecForward);

				if (iHitgroup != -1)
					set_tr2(tr, TR_iHitgroup, iHitgroup);
				/*
				if (bte_hms_get_skillstat(id) & (1<<1) && !bte_zb3_is_boomer_skilling(pEntity))
					set_tr2(tr, TR_iHitgroup, HITGROUP_HEAD);
				*/
				if (flDamage)
				{
					ClearMultiDamage();
					ExecuteHamB(Ham_TraceAttack, pEntity, id, flCurDamage, vecForward, tr, bitsDamageType);
					ApplyMultiDamage(id, id);
				}

				FakeKnockBack(pEntity, vecSrc, vecEnd, flKnockBack);
				if (!IsAlive(pEntity))
					flVol = 0.1;
			}
			else if (!pev_valid(pEntity) || !is_user_connected(pEntity))
			{
				bCanCross = FALSE;
				break;
			}
			pIgnoreEntity = pEntity;
			GetOrigin(pEntity, vecTempOrigin);
			fCurDistance = get_distance_f(vecSource, vecTempOrigin);
			if (fCurDistance >= flRange)
			{
				bCanCross = FALSE;
				break;
			}
			get_tr2(tr, TR_vecEndPos, vecSrc);
			xs_vec_mul_scalar(vecForward, flRange - fCurDistance, vecTemp);
			xs_vec_add(vecSrc, vecTemp, vecEnd);
			engfunc(EngFunc_TraceLine, vecSrc, vecEnd, dont_ignore_monsters, pIgnoreEntity, tr);

			get_tr2(tr, TR_flFraction, flFraction);

			if (flFraction >= 1.0)
			{
				engfunc(EngFunc_TraceHull, vecSrc, vecEnd, dont_ignore_monsters, head_hull, pIgnoreEntity, tr);
			}

			get_tr2(tr, TR_flFraction, flFraction);
			continue;
		}
		else if (flFraction >= 1.0)
		{
			engfunc(EngFunc_TraceHull, vecSrc, vecEnd, dont_ignore_monsters, head_hull, pIgnoreEntity, tr);
			get_tr2(tr, TR_flFraction, flFraction);
			if (flFraction >= 1.0)
			{
				bCanCross = FALSE;
				break;
			}
		}
	}
	set_pdata_int(id, m_iWeaponVolume, floatround(flVol * KNIFE_WALLHIT_VOLUME));
	free_tr2(tr);
	return iHitResult;
}

stock KnifeAttack2(id, bStab, Float:flRange, Float:fAngle, Float:flDamage, Float:flKnockBack=0.0, iHitgroup = -1, bNoTraceCheck = FALSE, bitsDamageType = DMG_NEVERGIB | DMG_BULLET, bDamageFallByDistance = FALSE, Float:vecReturnHitEnd[3] = {0.0,0.0,0.0})
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
	{
		iHitResult = RESULT_HIT_WORLD;
		get_tr2(tr, TR_vecEndPos, vecReturnHitEnd);
	}

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
		get_tr2(tr, TR_vecEndPos, vecReturnHitEnd);
		free_tr2(tr);

	}

	return iHitResult;
}

stock KnifeAttack5(id, bStab, Float:flRange, Float:fAngle, Float:flDamage, Float:flKnockBack=0.0, Float:flPower, iHitgroup = -1, bNoTraceCheck = FALSE, bitsDamageType = DMG_BULLET | DMG_NEVERGIB)
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
			if (iHitgroup != -1)
				set_tr2(tr, TR_iHitgroup, iHitgroup);

			if ((IsPlayer(pEntity) || IsHostage(pEntity) || pev(pEntity, pev_takedamage)))
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
					if (iHitgroup != -1)
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
					if (!CheckAngle(id, iVictim, fAngle) && fAngle != 360.0)
						continue;
					if (!pev(iVictim, pev_takedamage))
						continue;
				}
				engfunc(EngFunc_MakeVectors, v_angle);
				global_get(glb_v_forward, vecForward);

				ClearMultiDamage();
				ExecuteHamB(Ham_TraceAttack, pEntity, id, fCurDamage, vecForward, tr, bitsDamageType);
				ApplyMultiDamage(id, id);

				if (flPower >= 0.0)
					FakeKnockBack(pEntity, vecSrc, vecEnd, flKnockBack);
				new Float:vecVelocity[3];
				pev(id, pev_velocity, vecVelocity);
				vecVelocity[2] = flPower;
			}
		}

		free_tr2(tr);

	}

	return iHitResult;
}

stock RangeAttack(id, Float:flRange, Float:fAngle, Float:flDamage, Float:flKnockBack=0.0, bitsDamageType, bCheckTeam = TRUE, bDamageModifyByDistance = FALSE, iHitgroup = -1, Float:flMax = 0.0)
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

	bCheckTeam = (g_modruning == BTE_MOD_DM) ? FALSE : bCheckTeam;

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

		GetGunPosition(id, vecSrc);

		GetOrigin(pEntity, vecEnd);

		new Float:vecSrc2[3];
		pev(id, pev_origin, vecSrc2);
		FakeKnockBack(pEntity, vecSrc2, vecEnd, flKnockBack);

		new Float:vecEndZ2 = vecEnd[2];
		new Float:falloff = (get_distance_f(vecSrc, vecEnd) / flRange);

		vecEnd[2] = vecSrc[2] + (vecEndZ - vecSrc[2]) * falloff;
		if (flMax != 0.0)
		{
			if (vecEndZ2 >= vecEnd[2] - flMax && vecEndZ2 <= vecEnd[2] + flMax)
			{
				vecEnd[2] = vecEndZ2;
			}
		}

		xs_vec_sub(vecEnd, vecSrc, vecForward);
		xs_vec_normalize(vecForward, vecForward);
		xs_vec_mul_scalar(vecForward, flRange, vecForward);
		xs_vec_add(vecSrc, vecForward, vecEnd);

		engfunc(EngFunc_TraceLine, vecSrc, vecEnd, dont_ignore_monsters, id, tr);

		get_tr2(tr, TR_flFraction, flFraction);

		if (flFraction >= 1.0)
			engfunc(EngFunc_TraceHull, vecSrc, vecEnd, dont_ignore_monsters, head_hull, id, tr);

		if (IsPlayer(pEntity) || IsHostage(pEntity))
			iHitResult = RESULT_HIT_PLAYER;

		if (bCheckTeam && IsPlayer(pEntity) && pEntity != id)
			if(get_pdata_int(pEntity, m_iTeam) == get_pdata_int(id, m_iTeam) && !get_pcvar_num(cvar_friendlyfire))
				continue;

		engfunc(EngFunc_MakeVectors, v_angle);
		global_get(glb_v_forward, vecForward);

		if (iHitgroup != -1)
			set_tr2(tr, TR_iHitgroup, iHitgroup);

		if (bDamageModifyByDistance)
			flDamage *= (1.0 - falloff);

		ClearMultiDamage();
		ExecuteHamB(Ham_TraceAttack, pEntity, id, flDamage, vecForward, tr, bitsDamageType);
		ApplyMultiDamage(id, id);
	}

	free_tr2(tr);

	return iHitResult;
}


stock RadiusDamage(Float:vecSrc[3], pevInflictor, pevAttacker, Float:flDamage, Float:flRadius, Float:flKnockBack=0.0, bitsDamageType, bSkipAttacker, bCheckTeam, bDistanceCheck = TRUE)
{
	new pEntity = -1;
	new tr = create_tr2();
	new Float:flAdjustedDamage, Float:falloff;
	new iHitResult = RESULT_HIT_NONE;

	if (bDistanceCheck)
		falloff = flDamage / flRadius;
	else
		falloff = 0.0;

	new bInWater = (engfunc(EngFunc_PointContents, vecSrc) == CONTENTS_WATER);

	vecSrc[2] += 1.0;

	if (!pevAttacker)
		pevAttacker = pevInflictor;

	bCheckTeam = (g_modruning == BTE_MOD_DM) ? FALSE : bCheckTeam;

	while ((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecSrc, flRadius)) != 0)
	{
		if (pev(pEntity, pev_takedamage) == DAMAGE_NO)
			continue;

		if (bInWater && !pev(pEntity, pev_waterlevel))
			continue;

		if (!bInWater && pev(pEntity, pev_waterlevel) == 3)
			continue;

		if (bCheckTeam && IsPlayer(pEntity) && pEntity != pevAttacker)
			if(get_pdata_int(pEntity, m_iTeam) == get_pdata_int(pevAttacker, m_iTeam) && !get_pcvar_num(cvar_friendlyfire))
				continue;

		if (bSkipAttacker && pEntity == pevAttacker)
			continue;

		new Float:vecEnd[3];
		GetOrigin(pEntity, vecEnd);

#if 0
		new Float:vecDirection[3], Float:vecForward[3];
		xs_vec_sub(vecEnd, vecSrc, vecDirection);
		xs_vec_normalize(vecDirection, vecDirection);
		xs_vec_mul_scalar(vecDirection, 8196.0, vecForward);
		xs_vec_add(vecSrc, vecForward, vecEnd);
#endif

		engfunc(EngFunc_TraceLine, vecSrc, vecEnd, dont_ignore_monsters, 0, tr);

		new Float:flFraction;
		get_tr2(tr, TR_flFraction, flFraction);

		if (flFraction >= 1.0)
			engfunc(EngFunc_TraceHull, vecSrc, vecEnd, dont_ignore_monsters, head_hull, 0, tr);

		if (pev_valid(pEntity)/* && get_tr2(tr, TR_pHit) == pEntity*/)
		{
			GetOrigin(pEntity, vecEnd);
			xs_vec_sub(vecEnd, vecSrc, vecEnd);

			new Float:flDistance = xs_vec_len(vecEnd);
			if (flDistance < 1.0)
				flDistance = 0.0;

			flAdjustedDamage = flDistance * falloff;
			flAdjustedDamage = flDamage - flAdjustedDamage;

			if (get_tr2(tr, TR_pHit) != pEntity)
				flAdjustedDamage *= 0.3;

			if (flAdjustedDamage <= 0)
				continue;

			xs_vec_normalize(vecEnd, vecEnd);

			new Float:vecVelocity[3], Float:vecOldVelocity[3];
			xs_vec_mul_scalar(vecEnd, flKnockBack * ((flRadius - flDistance) / flRadius), vecVelocity);
			pev(pEntity, pev_velocity, vecOldVelocity);
			xs_vec_add(vecVelocity, vecOldVelocity, vecVelocity);

			if (IsPlayer(pEntity) && bte_get_user_zombie(pEntity) == 1)
				set_pev(pEntity, pev_velocity, vecVelocity);

			set_tr2(tr, TR_iHitgroup, HITGROUP_CHEST);

			ClearMultiDamage();
			ExecuteHamB(Ham_TraceAttack, pEntity, pevAttacker, flAdjustedDamage, vecEnd, tr, bitsDamageType);
			ApplyMultiDamage(pevInflictor, pevAttacker);

			iHitResult = RESULT_HIT_PLAYER;
		}
	}

	free_tr2(tr);

	return iHitResult;
}

stock SpearRadius(Float:vecSrc[3], pevInflictor, pevAttacker, Float:flDamage, Float:flRadius, Float:flKnockBack, bitsDamageType, bSkipAttacker, bCheckTeam, iHitgroup = -1, bDistanceCheck = TRUE)
{
	new pEntity = -1;
	new tr = create_tr2();
	new Float:flAdjustedDamage, Float:falloff;
	new iHitResult = RESULT_HIT_NONE;

	if (bDistanceCheck)
		falloff = flDamage / flRadius;
	else
		falloff = 0.0;

	new bInWater = (engfunc(EngFunc_PointContents, vecSrc) == CONTENTS_WATER);

	vecSrc[2] += 1.0;

	if (!pevAttacker)
		pevAttacker = pevInflictor;

	bCheckTeam = (g_modruning == BTE_MOD_DM) ? FALSE : bCheckTeam;

	while ((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecSrc, flRadius)) != 0)
	{
		if (pev(pEntity, pev_takedamage) == DAMAGE_NO)
			continue;

		if (bInWater && !pev(pEntity, pev_waterlevel))
			continue;

		if (!bInWater && pev(pEntity, pev_waterlevel) == 3)
			continue;

		if (bCheckTeam && IsPlayer(pEntity) && pEntity != pevAttacker)
			if(get_pdata_int(pEntity, m_iTeam) == get_pdata_int(pevAttacker, m_iTeam) && !get_pcvar_num(cvar_friendlyfire))
				continue;

		if (bSkipAttacker && pEntity == pevAttacker)
			continue;

		new Float:vecEnd[3];
		GetOrigin(pEntity, vecEnd);

		engfunc(EngFunc_TraceLine, vecSrc, vecEnd, dont_ignore_monsters, 0, tr);

		new Float:flFraction;
		get_tr2(tr, TR_flFraction, flFraction);

		if (flFraction >= 1.0)
			engfunc(EngFunc_TraceHull, vecSrc, vecEnd, dont_ignore_monsters, head_hull, 0, tr);

		if (pev_valid(pEntity))
		{
			GetOrigin(pEntity, vecEnd);
			new Float:flKnockBackModify = 1.0 - get_distance_f(vecSrc, vecEnd) / flRadius;
			
			if (pev(pEntity, pev_flags) & FL_DUCKING)
				flKnockBackModify *= 0.8;
				
			if (get_distance_f(vecSrc, vecEnd) < 40.0)
				flKnockBackModify *= 0.7;

			xs_vec_sub(vecEnd, vecSrc, vecEnd);

			new Float:flDistance = xs_vec_len(vecEnd);
			if (flDistance < 1.0)
				flDistance = 0.0;

			flAdjustedDamage = flDistance * falloff;
			flAdjustedDamage = flDamage - flAdjustedDamage;

			if (get_tr2(tr, TR_pHit) != pEntity)
				flAdjustedDamage *= 0.3;

			if (flAdjustedDamage <= 0)
				continue;

			xs_vec_normalize(vecEnd, vecEnd);

			new Float:vecVelocity[3], Float:vecOldVelocity[3];
			xs_vec_mul_scalar(vecEnd, flKnockBack * flKnockBackModify, vecVelocity);
			pev(pEntity, pev_velocity, vecOldVelocity);
			xs_vec_add(vecVelocity, vecOldVelocity, vecVelocity);

			if (IsPlayer(pEntity))
				set_pev(pEntity, pev_velocity, vecVelocity);

			if (iHitgroup == -1)
				set_tr2(tr, TR_iHitgroup, HITGROUP_CHEST);
			else
				set_tr2(tr, TR_iHitgroup, iHitgroup);

			ClearMultiDamage();
			ExecuteHamB(Ham_TraceAttack, pEntity, pevAttacker, flAdjustedDamage, vecEnd, tr, bitsDamageType);
			ApplyMultiDamage(pevInflictor, pevAttacker);

			iHitResult = RESULT_HIT_PLAYER;
		}
	}

	free_tr2(tr);

	return iHitResult;
}

stock EntityTouchDamage2(pevInflictor, pevAttacker, Float:flDamage, iHitgroup = -1, bitsDamageType = DMG_BULLET | DMG_NEVERGIB)
{
	new Float:vecOrigin[3], Float:vecVelocity[3], Float:vecDirection[3], Float:vecForward[3];
	pev(pevInflictor, pev_origin, vecOrigin);
	pev(pevInflictor, pev_velocity, vecVelocity);

	if (xs_vec_len(vecVelocity) <= 0.0)
		return FALSE;

	new Float:vecStart[3], Float:vecEnd[3];

	xs_vec_normalize(vecVelocity, vecDirection);
	xs_vec_mul_scalar(vecDirection, 100.0, vecForward);
	xs_vec_copy(vecOrigin, vecStart);
	xs_vec_add(vecOrigin, vecForward, vecEnd);

	new tr = create_tr2();

	engfunc(EngFunc_TraceLine, vecStart, vecEnd, dont_ignore_monsters, pevInflictor, tr);

	new pEntity = get_tr2(tr, TR_pHit);
	new bIsPlayer = IsPlayer(pEntity);
	
	if (iHitgroup > 0)
		set_tr2(tr, TR_iHitgroup, iHitgroup);

	if (IsAlive(pEntity))
	{
		ClearMultiDamage();
		ExecuteHamB(Ham_TraceAttack, pEntity, pevAttacker, flDamage, vecForward, tr, bitsDamageType);
		ApplyMultiDamage(pevInflictor, pevAttacker);
	}

	free_tr2(tr);

	return bIsPlayer;
}

stock EntityTouchDamage(pevInflictor, pevAttacker, Float:flDamage)
{
	new Float:vecOrigin[3], Float:vecVelocity[3], Float:vecDirection[3], Float:vecForward[3];
	pev(pevInflictor, pev_origin, vecOrigin);
	pev(pevInflictor, pev_velocity, vecVelocity);

	if (xs_vec_len(vecVelocity) <= 0.0)
		return FALSE;

	new Float:vecStart[3], Float:vecEnd[3];

	xs_vec_normalize(vecVelocity, vecDirection);
	xs_vec_mul_scalar(vecDirection, 100.0, vecForward);
	xs_vec_copy(vecOrigin, vecStart);
	xs_vec_add(vecOrigin, vecForward, vecEnd);

	new tr = create_tr2();

	engfunc(EngFunc_TraceLine, vecStart, vecEnd, dont_ignore_monsters, pevInflictor, tr);

	new pEntity = get_tr2(tr, TR_pHit);
	new bIsPlayer = IsPlayer(pEntity);

	if (IsAlive(pEntity))
	{
		ClearMultiDamage();
		ExecuteHamB(Ham_TraceAttack, pEntity, pevAttacker, flDamage, vecForward/*vecEnd*/, tr, DMG_BULLET | DMG_NEVERGIB);
		ApplyMultiDamage(pevInflictor, pevAttacker);
	}

	free_tr2(tr);

	return bIsPlayer;
}

stock EntityTouchGetHitGroup(pevInflictor)
{
	new Float:vecOrigin[3], Float:vecVelocity[3], Float:vecDirection[3], Float:vecForward[3];
	pev(pevInflictor, pev_origin, vecOrigin);
	pev(pevInflictor, pev_velocity, vecVelocity);

	if (xs_vec_len(vecVelocity) <= 0.0)
		return 0;

	new Float:vecStart[3], Float:vecEnd[3];

	xs_vec_copy(vecOrigin, vecStart);
	xs_vec_copy(vecOrigin, vecEnd);

	xs_vec_normalize(vecVelocity, vecDirection);
	xs_vec_mul_scalar(vecDirection, 100.0, vecForward);
	xs_vec_add(vecEnd, vecForward, vecEnd);
	xs_vec_mul_scalar(vecDirection, -10.0, vecForward);
	xs_vec_add(vecEnd, vecForward, vecEnd);

	new tr = create_tr2();

	engfunc(EngFunc_TraceLine, vecStart, vecEnd, dont_ignore_monsters, 0, tr);

	new pEntity = get_tr2(tr, TR_pHit);

	new iHitgroup = get_tr2(tr, TR_iHitgroup);
	free_tr2(tr);

	if (IsAlive(pEntity))
		return iHitgroup;

	return 0;
}


stock RemoveEntity(pEntity)
{
	/*set_pev(pEntity, pev_solid, SOLID_NOT);
	set_pev(pEntity, pev_movetype, MOVETYPE_NONE);
	set_pev(pEntity, pev_effects, EF_NODRAW);*/
	set_pev(pEntity, pev_flags, pev(pEntity, pev_flags) | FL_KILLME);
}

stock EntityTouchTraceTexture(pEntity)
{
	new Float:vecOrigin[3], Float:vecVelocity[3], Float:vecDirection[3], Float:vecForward[3];
	pev(pEntity, pev_origin, vecOrigin);
	pev(pEntity, pev_velocity, vecVelocity);

	new Float:vecStart[3], Float:vecEnd[3];

	xs_vec_normalize(vecVelocity, vecDirection);

	if (xs_vec_len(vecDirection) <= 0.0)
		return 0;

	xs_vec_mul_scalar(vecDirection, 8196.0, vecForward);
	xs_vec_copy(vecOrigin, vecStart);
	xs_vec_add(vecOrigin, vecForward, vecEnd);

	new tr = create_tr2();

	engfunc(EngFunc_TraceLine, vecStart, vecEnd, dont_ignore_monsters, pEntity, tr);

	new Float:flFraction;
	get_tr2(tr, TR_flFraction, flFraction);

	new iTtextureType;

	if (flFraction != 1.0)
	{
		new pTextureName[64];
		engfunc(EngFunc_TraceTexture, 0, vecStart, vecEnd, pTextureName, charsmax(pTextureName));
		iTtextureType = dllfunc(DLLFunc_PM_FindTextureType, pTextureName);
	}

	free_tr2(tr);

	return iTtextureType;
}

stock Float:GetVelocity2D(id)
{
	new Float:vecVelocity[3];
	pev(id, pev_velocity, vecVelocity);
	vecVelocity[2] = 0.0;
	return xs_vec_len(vecVelocity);
}

stock PlayAnimation(id, szAnim[])
{
	OrpheuCall(handleSetAnimation, id, PLAYER_RELOAD);
	set_pev(id, pev_frame, 0);
	set_pev(id, pev_sequence, LookupSequence(szAnim));
	OrpheuCall(handleResetSequenceInfo, id);
}

stock BreakupStringInt(value[], any:data[], max = 0)
{
	new count = CharCount(value, ',');

	new key[128];
	new i = 0;
	while (value[0] != 0 && strtok(value, key, charsmax(key), value, 1024, ','))
	{
		trim(key)
		trim(value)
		data[i] = str_to_num(key);
		i += 1;
	}

	if (!max)
		return;

	i = max - count - 1;
	while (i > count)
	{
		data[i] = data[count];
		i -= 1;
	}
}


stock BreakupStringFloat(value[], any:data[], max = 0)
{
	new count = CharCount(value, ',');

	new key[128];
	new i = 0;
	while (value[0] != 0 && strtok(value, key, charsmax(key), value, 1024, ','))
	{
		trim(key)
		trim(value)
		data[i] = str_to_float(key);
		i += 1;
	}

	if (!max)
		return;

	i = max - count - 1;
	while (i > count)
	{
		data[i] = data[count];
		i -= 1;
	}
}

stock CharCount(str[], search)
{
	new count, i, len = strlen(str);
	for (i = 0; i <= len; i++)
	{
		if(str[i] == search)
			count++;
	}
	return count;
}

stock GetEntityClass(const str[])
{
	if (equal(str, "ENTCLASS_NADE")) return ENTCLASS_NADE;
	if (equal(str, "ENTCLASS_NADE_BOUNCE")) return ENTCLASS_NADE_BOUNCE;
	if (equal(str, "ENTCLASS_BOLT")) return ENTCLASS_BOLT;
	if (equal(str, "ENTCLASS_PLASMA")) return ENTCLASS_PLASMA;
	if (equal(str, "ENTCLASS_SMOKE")) return ENTCLASS_SMOKE;
	if (equal(str, "ENTCLASS_KILLME")) return ENTCLASS_KILLME;
	if (equal(str, "ENTCLASS_BOW")) return ENTCLASS_BOW;
	if (equal(str, "ENTCLASS_DGUN")) return ENTCLASS_DGUN;
	if (equal(str, "ENTCLASS_SPEARGUN")) return ENTCLASS_SPEARGUN;
	if (equal(str, "ENTCLASS_PETROL")) return ENTCLASS_PETROL;

	return 0;
}

stock GetEntityMoveType(const str[])
{
	if (equal(str, "MOVETYPE_NONE")) return MOVETYPE_NONE;
	if (equal(str, "MOVETYPE_WALK")) return MOVETYPE_WALK;
	if (equal(str, "MOVETYPE_STEP")) return MOVETYPE_STEP;
	if (equal(str, "MOVETYPE_PUSH")) return MOVETYPE_PUSH;
	if (equal(str, "MOVETYPE_NOCLIP")) return MOVETYPE_NOCLIP;
	if (equal(str, "MOVETYPE_FLYMISSILE")) return MOVETYPE_FLYMISSILE;
	if (equal(str, "MOVETYPE_BOUNCE")) return MOVETYPE_BOUNCE;
	if (equal(str, "MOVETYPE_BOUNCEMISSILE")) return MOVETYPE_BOUNCEMISSILE;
	if (equal(str, "MOVETYPE_FOLLOW")) return MOVETYPE_FOLLOW;
	if (equal(str, "MOVETYPE_PUSHSTEP")) return MOVETYPE_PUSHSTEP;

	return 0;
}

stock GetBulletType(const str[])
{
	if (equal(str, "BULLET_NONE")) return BULLET_NONE;
	if (equal(str, "BULLET_PLAYER_9MM")) return BULLET_PLAYER_9MM;
	if (equal(str, "BULLET_PLAYER_MP5")) return BULLET_PLAYER_MP5;
	if (equal(str, "BULLET_PLAYER_357")) return BULLET_PLAYER_357;
	if (equal(str, "BULLET_PLAYER_BUCKSHOT")) return BULLET_PLAYER_BUCKSHOT;
	if (equal(str, "BULLET_PLAYER_CROWBAR")) return BULLET_PLAYER_CROWBAR;

	if (equal(str, "BULLET_MONSTER_9MM")) return BULLET_MONSTER_9MM;
	if (equal(str, "BULLET_MONSTER_MP5")) return BULLET_MONSTER_MP5;
	if (equal(str, "BULLET_MONSTER_12MM")) return BULLET_MONSTER_12MM;

	if (equal(str, "BULLET_PLAYER_45ACP")) return BULLET_PLAYER_45ACP;
	if (equal(str, "BULLET_PLAYER_338MAG")) return BULLET_PLAYER_338MAG;
	if (equal(str, "BULLET_PLAYER_762MM")) return BULLET_PLAYER_762MM;
	if (equal(str, "BULLET_PLAYER_556MM")) return BULLET_PLAYER_556MM;
	if (equal(str, "BULLET_PLAYER_50AE")) return BULLET_PLAYER_50AE;
	if (equal(str, "BULLET_PLAYER_57MM")) return BULLET_PLAYER_57MM;
	if (equal(str, "BULLET_PLAYER_357SIG")) return BULLET_PLAYER_357SIG;

	return 0;
}

stock GetWeaponID(const str[])
{
	if (equal(str, "P228")) return CSW_P228;
	if (equal(str, "SCOUT")) return CSW_SCOUT;
	if (equal(str, "HEGERNADE")) return CSW_HEGRENADE;
	if (equal(str, "XM1014")) return CSW_XM1014;
	if (equal(str, "C4")) return CSW_C4;
	if (equal(str, "MAC10")) return CSW_MAC10;
	if (equal(str, "AUG")) return CSW_AUG;
	if (equal(str, "SMOKEGRENADE")) return CSW_SMOKEGRENADE;
	if (equal(str, "ELITE")) return CSW_ELITE;
	if (equal(str, "FIVESEVEN")) return CSW_FIVESEVEN;
	if (equal(str, "UMP45")) return CSW_UMP45;
	if (equal(str, "SG550")) return CSW_SG550;
	if (equal(str, "GALIL")) return CSW_GALIL;
	if (equal(str, "FAMAS")) return CSW_FAMAS;
	if (equal(str, "USP")) return CSW_USP;
	if (equal(str, "GLOCK18")) return CSW_GLOCK18;
	if (equal(str, "AWP")) return CSW_AWP;
	if (equal(str, "MP5")) return CSW_MP5NAVY;
	if (equal(str, "M249")) return CSW_M249;
	if (equal(str, "M3")) return CSW_M3;
	if (equal(str, "M4A1")) return CSW_M4A1;
	if (equal(str, "TMP")) return CSW_TMP;
	if (equal(str, "G3SG1")) return CSW_G3SG1;
	if (equal(str, "FLASHBANG")) return CSW_FLASHBANG;
	if (equal(str, "DEAGLE")) return CSW_DEAGLE;
	if (equal(str, "SG552")) return CSW_SG552;
	if (equal(str, "AK47")) return CSW_AK47;
	if (equal(str, "KNIFE")) return CSW_KNIFE;
	if (equal(str, "P90")) return CSW_P90;

	return 0;
}

stock GetMenu(const str[])
{
	if (equal(str, "PISTOL")) return 0;
	if (equal(str, "SHOTGUN")) return 1;
	if (equal(str, "SMG")) return 2;
	if (equal(str, "RIFLE")) return 3;
	if (equal(str, "MG")) return 4;
	if (equal(str, "EQUIP")) return 5;
	if (equal(str, "KNIFE")) return 6;

	return 0;
}

stock EntityVelocityAngle(pEntity)
{
	static Float:vAngle[3];

	Stock_Get_Velocity_Angle(pEntity, vAngle);
	set_pev(pEntity, pev_angles, vAngle);
}

stock CreateEntity(id, iBteWpn, model[], Float:angle, Float:speed, Float:gravity, movetype, entclass)
{
	static Float:vecVAngle[3], Float:vecOrigin[3], Float:vecVelocity[3];

	pev(id, pev_v_angle, vecVAngle);
	Stock_Get_Postion(id, c_vecViewAttachment[iBteWpn][0], c_vecViewAttachment[iBteWpn][1], c_vecViewAttachment[iBteWpn][2], vecOrigin);

	if (angle == 0.0)
	{
		new Float:vecEnd[3]
		Stock_Get_Aiming(id, vecEnd);
		Stock_GetSpeedVector(vecOrigin, vecEnd, speed, vecVelocity);
	}
	else
	{
		Stock_Velocity_By_Aim(vecVAngle, angle, speed, vecVelocity);
	}

	vector_to_angle(vecVelocity, vecVAngle)
	if(vecVAngle[0] > 90.0) vecVAngle[0] = -(360.0 - vecVAngle[0]);

	new pEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));

	engfunc(EngFunc_SetModel, pEntity, model);

	new sKillEntName[32];
	format(sKillEntName, charsmax(sKillEntName), "d_%s", c_sModel[iBteWpn]);
	set_pev(pEntity, pev_classname, sKillEntName);

	set_pev(pEntity, pev_movetype, movetype);
	set_pev(pEntity, pev_angles, vecVAngle);
	set_pev(pEntity, pev_origin, vecOrigin);
	set_pev(pEntity, pev_gravity, gravity);
	set_pev(pEntity, pev_owner, id);
	set_pev(pEntity, pev_solid, SOLID_BBOX);
	set_pev(pEntity, pev_velocity, vecVelocity);

	Set_Ent_Data(pEntity, DEF_ENTCLASS, entclass);
	Set_Ent_Data(pEntity, DEF_ENTID, iBteWpn);

	return pEntity;
}

stock CreateEntity2(id, iBteWpn, iType = 0)
{
	static Float:vecVAngle[3], Float:vecOrigin[3], Float:vecVelocity[3];

	pev(id, pev_v_angle, vecVAngle);
	Stock_Get_Postion(id, c_vecViewAttachment[iBteWpn][0], c_vecViewAttachment[iBteWpn][1], c_vecViewAttachment[iBteWpn][2], vecOrigin);

	if (c_flEntityAngle[iBteWpn] == 0.0)
	{
		new Float:vecEnd[3]
		Stock_Get_Aiming(id, vecEnd);
		Stock_GetSpeedVector(vecOrigin, vecEnd, 2400.0, vecVelocity);
	}
	else
	{
		Stock_Velocity_By_Aim(vecVAngle, c_flEntityAngle[iBteWpn], c_flEntitySpeed[iBteWpn], vecVelocity);
	}

	vector_to_angle(vecVelocity, vecVAngle)
	if(vecVAngle[0] > 90.0) vecVAngle[0] = -(360.0 - vecVAngle[0]);

	new pEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));

	engfunc(EngFunc_SetModel, pEntity, c_sEntityModel[iBteWpn]);

	new sKillEntName[32];
	format(sKillEntName, charsmax(sKillEntName), "d_%s", c_sModel[iBteWpn]);
	set_pev(pEntity, pev_classname, sKillEntName);

	set_pev(pEntity, pev_movetype, c_iEntityMove[iBteWpn]);
	set_pev(pEntity, pev_angles, vecVAngle);
	set_pev(pEntity, pev_origin, vecOrigin);
	set_pev(pEntity, pev_gravity, c_flEntityGravity[iBteWpn]);
	set_pev(pEntity, pev_owner, id);
	set_pev(pEntity, pev_solid, SOLID_BBOX);
	set_pev(pEntity, pev_velocity, vecVelocity);

	Set_Ent_Data(pEntity, DEF_ENTCLASS, c_iEntityClass[iBteWpn]);
	Set_Ent_Data(pEntity, DEF_ENTID, iBteWpn);

	SetGreadeEntity(pEntity, iBteWpn, c_iEntityBeam[iBteWpn], iType);

	return pEntity;
}

stock SetGreadeEntity(pEntity, iBteWpn, iBeam = 0, iType = 0, Float:flDelay = 0.1)
{
	if (!IS_ZBMODE)
		set_pev(pEntity, pev_fuser3, c_flEntityDamage[iBteWpn][iType]);
	else
		set_pev(pEntity, pev_fuser3, c_flEntityDamageZB[iBteWpn][iType]);

	set_pev(pEntity, pev_fuser4, c_flEntityRange[iBteWpn][iType]);

	if (iBeam)
	{
		SetEntityDelayBeam(pEntity, iBeam, flDelay);
	}
}

stock SetEntityDelayBeam(pEntity, iBeam, Float:flDelay = 0.1)
{
	set_pev(pEntity, pev_nextthink, get_gametime() + flDelay);
	set_pdata_int(pEntity, 24, iBeam);
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

stock BlinkAccount(id, numBlinks)
{
	message_begin(MSG_ONE, gmsgBlinkAcct, _, id);
	write_byte(numBlinks);
	message_end();
}

stock AlreadyHaveWeapon(id, name[])
{
	return (
		equal(c_sModel[g_weapon[id][1]], name) && get_pdata_cbase(id, m_rgpPlayerItems + 1) > 0
	 || equal(c_sModel[g_weapon[id][2]], name) && get_pdata_cbase(id, m_rgpPlayerItems + 2) > 0
	 || equal(c_sModel[g_weapon[id][3]], name) && get_pdata_cbase(id, m_rgpPlayerItems + 3) > 0
	 || equal(c_sModel[g_weapon[id][4]], name) && IsPlayerHaveGrenade(id)
	 )
}

stock IsPlayerHaveGrenade(id)
{
	new item = get_pdata_cbase(id, m_rgpPlayerItems + 4);

	while (item > 0)
	{
		new new_item = get_pdata_cbase(item, m_pNext);

		if (get_pdata_int(item, m_iId) == CSW_HEGRENADE)
			return 1;

		item = new_item;
	}

	return 0;
}

stock EntityTouchDecal(pEntity)
{
	new Float:vecOrigin[3];
	pev(pEntity, pev_origin, vecOrigin);

	engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vecOrigin, 0);
	write_byte(TE_GUNSHOTDECAL);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(0);
	write_byte(DECAL_SHOT[random_num(0, 4)]);
	message_end();
}

stock GrenadeSmoke(pEntity)
{
	new Float:vecOrigin[3];
	pev(pEntity, pev_origin, vecOrigin);

	if (UTIL_PointContents(vecOrigin) != CONTENTS_WATER)
	{
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
		write_byte(TE_SMOKE);
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, vecOrigin[2] - 5.0);
		write_short(g_sModelIndexSmoke);
		write_byte(35 + random_num(0, 10));
		write_byte(5);
		message_end();
	}
	else
	{
		new Float:mins[3], Float:maxs[3];
		mins[0] = vecOrigin[0] - 64.0;
		mins[1] = vecOrigin[1] - 64.0;
		mins[2] = vecOrigin[2] - 64.0;
		maxs[0] = vecOrigin[0] + 64.0;
		maxs[1] = vecOrigin[1] + 64.0;
		maxs[2] = vecOrigin[2] + 64.0;

		UTIL_Bubbles(mins, maxs, 100);
	}

	RemoveEntity(pEntity);
}

stock UTIL_PointContents(Float:origin[3])
{
	return engfunc(EngFunc_PointContents, origin);
}

stock UTIL_Bubbles(Float:mins[3], Float:maxs[3], count)
{
	new Float:mid[3];
	mid[0] = (mins[0] + maxs[0]) * 0.5;
	mid[1] = (mins[1] + maxs[1]) * 0.5;
	mid[2] = (mins[2] + maxs[2]) * 0.5;

	new Float:flHeight = UTIL_WaterLevel(mid, mid[2], mid[2] + 1024.0);
	flHeight = flHeight - mins[2];

	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, mid, 0);
	write_byte(TE_BUBBLES);
	engfunc(EngFunc_WriteCoord, mins[0]);
	engfunc(EngFunc_WriteCoord, mins[1]);
	engfunc(EngFunc_WriteCoord, mins[2]);
	engfunc(EngFunc_WriteCoord, maxs[0]);
	engfunc(EngFunc_WriteCoord, maxs[1]);
	engfunc(EngFunc_WriteCoord, maxs[2]);
	engfunc(EngFunc_WriteCoord, flHeight);
	write_short(g_sModelIndexBubbles);
	write_byte(count);
	engfunc(EngFunc_WriteCoord, 8.0);
	message_end();
}

stock Float:UTIL_WaterLevel(Float:midUp[3], Float:minz, Float:maxz)
{
	midUp[2] = minz;

	if (UTIL_PointContents(midUp) != CONTENTS_WATER)
		return minz;

	midUp[2] = maxz;

	if (UTIL_PointContents(midUp) == CONTENTS_WATER)
		return maxz;

	new Float:diff = maxz - minz;

	while (diff > 1.0)
	{
		midUp[2] = minz + diff / 2.0;

		if (UTIL_PointContents(midUp) == CONTENTS_WATER)
			minz = midUp[2];
		else
			maxz = midUp[2];

		diff = maxz - minz;
	}

	return midUp[2];
}

stock UTIL_ScreenShake(id, amplitude = 8, duration = 6, frequency = 18)
{
	if (!amplitude)
		return;

	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id);
	write_short((1<<12) * amplitude);
	write_short((1<<12) * duration);
	write_short((1<<12) * frequency);
	message_end();
}

stock FakeKnockBack(pEntity, Float:vecSrc[3], Float:vecEnd[3], Float:flKnockBack, Float:flRange = 0.0)
{
	if (bte_get_user_zombie(pEntity) != 1)
		return;

	new flags = pev(pEntity, pev_flags);

	new Float:vecDirection[3];
	xs_vec_sub(vecEnd, vecSrc, vecDirection);

	new Float:flDistance = xs_vec_len(vecDirection);
	xs_vec_normalize(vecDirection, vecDirection);

	if (!flRange)
	{
		flRange = 1.0;
		flDistance = 0.0;
	}

	flKnockBack *= 10.0;

	new Float:vecVelocity[3], Float:vecOldVelocity[3];

	flKnockBack = flKnockBack * (flRange - flDistance) / flRange;
	if (flags & FL_DUCKING) flKnockBack *= 0.7;

	xs_vec_mul_scalar(vecDirection, flKnockBack, vecVelocity);
	vecVelocity[2] = 0.0;
	pev(pEntity, pev_velocity, vecOldVelocity);
	xs_vec_add(vecVelocity, vecOldVelocity, vecVelocity);

	set_pev(pEntity, pev_velocity, vecVelocity);
}

stock KnockBack(id, victim, iBteWpn, Float:vecVelocity[3], bUseType2 = FALSE, bIgnoreFraction = FALSE)
{
	new flags = pev(victim, pev_flags);
	new type = 0;

	// BANG->[not on ground, ducking, speed > 0, (other)]
	// Ground, Air, Fly, Duck

	if (!(flags & FL_ONGROUND))
	{
		if (xs_vec_len(vecVelocity) > 0.0)
			type = 2;
		else
			type = 1;
	}
	else if (flags & FL_DUCKING)
		type = 3;
	else 
		type = 0;
	
	if (bUseType2)
		type += 4;

	new Float:flKnockBack = c_flKnockback[iBteWpn][type];
	
	if(!bIgnoreFraction)
		flKnockBack *= g_knockback[victim];

	flKnockBack /= 2.0;
	
	new Float:vecOrigin[2][3], Float:vecDirection[3], Float:vecNewVelocity[3];
	pev(victim, pev_origin, vecOrigin[0]);
	pev(id, pev_origin, vecOrigin[1]);
	xs_vec_sub(vecOrigin[0], vecOrigin[1], vecDirection);
	xs_vec_normalize(vecDirection, vecDirection);
	vecDirection[2] = 0.0;

	xs_vec_mul_scalar(vecDirection, flKnockBack, vecNewVelocity);

	/*if (!(flags & FL_ONGROUND))
		vecVelocity[2] = 0.0;*/

	xs_vec_add(vecVelocity, vecNewVelocity, vecVelocity);
	set_pev(victim, pev_velocity, vecVelocity);
	
	
}
/*
stock KnifeAttack3(id, Float:flRange, Float:flDamage, iHitgroup)
{
	new Float:vecSrc[3], Float:vecEnd[3], Float:v_angle[3], Float:vecForward[3];
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

	if (flFraction >= 1.0)
	{
		engfunc(EngFunc_TraceHull, vecSrc, vecEnd, dont_ignore_monsters, head_hull, id, tr);
	}

	get_tr2(tr, TR_flFraction, flFraction);

	new pEntity;

	if (flFraction < 1.0)
	{
		pEntity = get_tr2(tr, TR_pHit);

		if (pev_valid(pEntity))
		{
			set_tr2(tr, TR_iHitgroup, iHitgroup);

			engfunc(EngFunc_MakeVectors, v_angle);
			global_get(glb_v_forward, vecForward);

			ClearMultiDamage();
			ExecuteHamB(Ham_TraceAttack, pEntity, id, flDamage, vecForward, tr, DMG_NEVERGIB | DMG_BULLET);
			ApplyMultiDamage(id, id);
		}
	}

	free_tr2(tr);

	return pEntity;
}*/

stock SendExtraAmmo(id, iEnt)
{
	MH_SendZB3Data(id, 5, GetExtraAmmo(iEnt));
}

stock SetExtraAmmo(id, iEnt, i, bSendMsg = TRUE)
{
	set_pdata_int(iEnt, 25, i);

	if (bSendMsg)
		MH_SendZB3Data(id, 5, i);
}

stock GetExtraAmmo(iEnt)
{
	if (!pev_valid(iEnt))
		return 0;

	return get_pdata_int(iEnt, 25);
}

stock ShowCustomCrosshair(id, bShow)
{
	MH_SendZB3Data(id, 16, bShow);
}

stock FireBullets3_Lite(Float:vecSrc[3], Float:vecDir[3], Float:flDistance, iPenetration, Float:flDamage, pevAttacker, Float: flKnockBack = 0.0)
{
	new Float:vecEnd[3], Float:vecEndPos[3], Float:vecForward[3];
	new tr = create_tr2();
	new Float:flFraction, Float:flCurrentDistance;

	xs_vec_mul_scalar(vecDir, flDistance, vecForward);
	xs_vec_add(vecSrc, vecForward, vecEnd);

	while (iPenetration != 0)
	{
		ClearMultiDamage();
		engfunc(EngFunc_TraceLine, vecSrc, vecEnd, dont_ignore_monsters, pevAttacker, tr);

		get_tr2(tr, TR_flFraction, flFraction);

		if (flFraction != 1.0)
		{
			new pEntity = get_tr2(tr, TR_pHit);

			if (pEntity < 0)
				return;

			iPenetration--;
			flCurrentDistance = flFraction * flDistance;

			get_tr2(tr, TR_vecEndPos, vecEndPos);

			xs_vec_mul_scalar(vecDir, 42.0, vecForward);
			xs_vec_add(vecEndPos, vecForward, vecSrc);

			flDistance = (flDistance - flCurrentDistance) * 0.75;

			xs_vec_mul_scalar(vecDir, flDistance, vecForward);
			xs_vec_add(vecSrc, vecForward, vecEnd);

			ExecuteHamB(Ham_TraceAttack, pEntity, pevAttacker, flDamage, vecDir, tr, DMG_BULLET | DMG_NEVERGIB);

			// 为了一些特别的情况
			if (flKnockBack)
				FakeKnockBack(pEntity, vecSrc, vecEnd, flKnockBack);
		}
		else
		{
			iPenetration = 0;
		}

		ApplyMultiDamage(pevAttacker, pevAttacker);
	}
}

stock SetFullAmmo(id, slot, Float:x = 1.0)
{
	new item = get_pdata_cbase(id, m_rgpPlayerItems + slot);

	while (item > 0)
	{
		set_pdata_int(id, m_rgAmmo[get_pdata_int(item, m_iPrimaryAmmoType)], floatround(c_iMaxAmmo[g_weapon[id][slot]] * x));
		g_user_ammo[id][slot] = floatround(c_iMaxAmmo[g_weapon[id][slot]] * x);

		item = get_pdata_cbase(item, m_pNext);
	}
}

stock SetFullClip(id, slot)
{
	new item = get_pdata_cbase(id, m_rgpPlayerItems + slot);

	while (item > 0)
	{
		set_pdata_int(item, m_iClip, c_iClip[g_weapon[id][slot]]);

		item = get_pdata_cbase(item, m_pNext);
	}
}

/*new iId = get_pdata_int(item, m_iId);
		new iOffset;

		switch (iId)
		{
			case CSW_AWP: iOffset = OFFSET_AWM_AMMO;
			case CSW_SCOUT, CSW_AK47,CSW_G3SG1: iOffset = OFFSET_SCOUT_AMMO;
			case CSW_M249: iOffset = OFFSET_PARA_AMMO;
			case CSW_M4A1, CSW_FAMAS,CSW_AUG,CSW_SG550,CSW_GALI,CSW_SG552: iOffset = OFFSET_FAMAS_AMMO;
			case CSW_M3, CSW_XM1014: iOffset = OFFSET_M3_AMMO;
			case CSW_USP, CSW_UMP45, CSW_MAC10: iOffset = OFFSET_USP_AMMO;
			case CSW_FIVESEVEN, CSW_P90: iOffset = OFFSET_FIVESEVEN_AMMO;
			case CSW_DEAGLE: iOffset = OFFSET_DEAGLE_AMMO;
			case CSW_P228: iOffset = OFFSET_P228_AMMO;
			case CSW_GLOCK18, CSW_MP5NAVY, CSW_TMP, CSW_ELITE: iOffset = OFFSET_GLOCK_AMMO;
		}

		set_pdata_int(id, iOffset, floatround(c_iMaxAmmo[g_weapon[id][slot]] * x));*/
stock GiveAmmo(id, iAmount, szName[], iMax)
{
	return ExecuteHam(Ham_GiveAmmo, id, iAmount, szName, iMax);
}

stock AddAccount(id, amount, bTrackChange)
{
	OrpheuCallSuper(handleAddAccount, id, amount, bTrackChange);

	/*new iAccount = get_pdata_int(id, m_iAccount);

	iAccount += amount;

	if (iAccount < 0)
		iAccount = 0;
	else if (iAccount > 16000)
		iAccount = 16000;

	set_pdata_int(id, m_iAccount, iAccount);

	message_begin(MSG_ONE, gmsgMoney, _, id);
	write_long(iAccount);
	write_byte(bTrackChange);
	message_end();*/
}

stock SetAccount(id, iAccount)
{
	new old = get_pdata_int(id, m_iAccount);
	new amount = iAccount - old;

	OrpheuCallSuper(handleAddAccount, id, amount, TRUE);
	//set_pdata_int(id, m_iAccount, iAccount);
}

public OrpheuHookReturn:OnAddAccount_Pre(id, amount, bTrackChange)
{
	new iAccount = get_pdata_int(id, m_iAccount);

	iAccount += amount;

	if (iAccount < 0)
		iAccount = 0;
	else if (iAccount > 16000)
		iAccount = 16000;

	set_pdata_int(id, m_iAccount, iAccount);

	msgMoney[id][m_flTimeSend] = get_gametime() + 0.05;
	msgMoney[id][m_bTrackChange] = bTrackChange;
	msgMoney[id][m_account] = iAccount;

	return OrpheuSupercede;
}

public OrpheuHookReturn:OnHandleBuyAliasCommands_Pre(id, pszCommand[])
{
	if (!strcmp(pszCommand, "vest") || !strcmp(pszCommand, "vesthelm") || !strcmp(pszCommand, "flash") || !strcmp(pszCommand, "sgren") || !strcmp(pszCommand, "nvgs") || !strcmp(pszCommand, "defuser"))
		return OrpheuIgnored;

	return OrpheuSupercede;
}

native BTE_DeathInfo_TakeDamage_Pre(victim, pevInflictor, pevAttacker, Float:flDamage, bitsDamageType)
native BTE_DeathInfo_TakeDamage_Post(victim, pevInflictor, pevAttacker, Float:flDamage, bitsDamageType)

stock RadiusDamage2(Float:vecSrc[3], pevInflictor, pevAttacker, iBteWpn)
{
	new pEntity = -1;
	new tr = create_tr2();

	new bInWater = (engfunc(EngFunc_PointContents, vecSrc) == CONTENTS_WATER);

	vecSrc[2] += 1.0;

	while ((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecSrc, c_flDistance[iBteWpn][0])) != 0)
	{
		if (pev(pEntity, pev_takedamage) == DAMAGE_NO)
			continue;

		if (bInWater && !pev(pEntity, pev_waterlevel))
			continue;

		if (!bInWater && pev(pEntity, pev_waterlevel) == 3)
			continue;

		if (!IsAlive(pEntity))
			continue;

		if (CheckTeammate(pEntity, pevAttacker))
			continue;

		new Float:vecEnd[3];
		GetOrigin(pEntity, vecEnd);

		engfunc(EngFunc_TraceLine, vecSrc, vecEnd, dont_ignore_monsters, 0, tr);

		new Float:flFraction;
		get_tr2(tr, TR_flFraction, flFraction);

		if (flFraction >= 1.0)
			engfunc(EngFunc_TraceHull, vecSrc, vecEnd, dont_ignore_monsters, head_hull, 0, tr);

		if (pEntity == get_tr2(tr, TR_pHit))
		{
			new Float:flDamage = (bte_get_user_zombie(pEntity) == 1) ? c_flDamageZB[iBteWpn][0] : c_flDamage[iBteWpn][0];

			if (IsPlayer(pEntity))
			{
				set_pdata_int(pEntity, m_LastHitGroup, HITGROUP_CHEST);
				OrpheuCall(handleSetAnimation, pEntity, PLAYER_FLINCH);
			}

			ExecuteHamB(Ham_TakeDamage, pEntity, pevInflictor, pevAttacker, 0.0, 0);

			BTE_DeathInfo_TakeDamage_Pre(pEntity, pevInflictor, pevAttacker, 0.0, 0);
			FakeTakeDamage(pEntity, pevAttacker, flDamage);
			BTE_DeathInfo_TakeDamage_Post(pEntity, pevInflictor, pevAttacker, 0.0, 0);

			if (IsPlayer(pEntity))
				set_pdata_float(pEntity, m_flVelocityModifier, c_flVelocityModifier[iBteWpn][0]);
		}
	}

	free_tr2(tr);
}

stock FakeTakeDamage(victim, attacker, Float:flDamage)
{
	new Float:health, Float:armorvalue;
	pev(victim, pev_health, health);
	pev(victim, pev_armorvalue, armorvalue);

	if (armorvalue > 0)
	{
		flDamage *= 0.5;
		armorvalue -= flDamage;
	}

	health -= flDamage;

	set_pev(victim, pev_health, health);
	set_pev(victim, pev_armorvalue, armorvalue);

	if (health <= 0.0)
		ExecuteHamB(Ham_Killed, victim, attacker, 1);
}

stock FindHullIntersection(Float:vecSrc[3], &ptr, Float:flMins[3], Float:fkMaxs[3], pEntity)
{
	new ptrTemp = create_tr2();
	new Float:flDistance = 1000000.0;

	new Float:flMinMaxs[2][3]
	for(new i;i<3;i++)
	{
		flMinMaxs[0][i] = flMins[i];
		flMinMaxs[1][i] = fkMaxs[i];
	}
	new Float:vecHullEnd[3]
	get_tr2(ptr, TR_vecEndPos, vecHullEnd)
	
	new Float:vecTemp[3]
	xs_vec_sub(vecHullEnd, vecSrc, vecTemp);
	xs_vec_mul_scalar(vecTemp, 2.0, vecTemp);
	xs_vec_add(vecSrc, vecTemp, vecHullEnd)
	
	engfunc(EngFunc_TraceLine, vecSrc, vecHullEnd, DONT_IGNORE_MONSTERS, pEntity, ptrTemp);
	
	new Float:flFraction
	get_tr2(ptrTemp, TR_flFraction, flFraction)
	
	if (flFraction < 1.0)
	{
		free_tr2(ptr)
		ptr = ptrTemp
		return ptr;
	}
	
	for(new i; i < 2; i++)
	{
		for(new j; j < 2; j++)
		{
			for(new k; k < 2; k++)
			{
				new Float:vecEnd[3];
				for(new l;l < 3;l++)
				{
					vecEnd[l] = vecHullEnd[l] + flMinMaxs[i][l];
					vecEnd[l] = vecHullEnd[l] + flMinMaxs[j][l];
					vecEnd[l] = vecHullEnd[l] + flMinMaxs[k][l];
				}
				
				engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, pEntity, ptrTemp)
				
				get_tr2(ptrTemp, TR_flFraction, flFraction)
				if (flFraction < 1.0)
				{
					new Float:vecEndPos[3]
					get_tr2(ptrTemp, TR_vecEndPos, vecEndPos)
					xs_vec_sub(vecEndPos, vecSrc, vecTemp);
					new Float:flThisDistance = xs_vec_len(vecTemp)
					if (flThisDistance < flDistance)
					{
						free_tr2(ptr)
						ptr = ptrTemp
						flDistance = flThisDistance;
						return ptr;
					}
				}
			}
		}
	}
	return ptr;
}

stock TEXTURETYPE_PlaySound(ptr, Float:vecSrc[3], Float:vecEnd[3], iBulletType)
{
	return OrpheuCall(handleTEXTURETYPE_PlaySound, ptr, vecSrc[0], vecSrc[1], vecSrc[2], vecEnd[0], vecEnd[1], vecEnd[2], iBulletType)
}

stock UpdateFrags(player, num)
{
	if (!is_user_connected(player)) return;

	set_pev(player, pev_frags, float(pev(player, pev_frags) + num))
	message_begin(MSG_BROADCAST, g_msgScoreInfo)
	write_byte(player) // id
	write_short(pev(player, pev_frags)) // frags
	write_short(get_user_deaths(player)) // deaths
	write_short(0) // class?
	write_short(get_user_team(player)) // team
	message_end()
}

stock is_wall_between_points(Float:start[3], Float:end[3], ignore_ent)
{
	new ptr = create_tr2()
	engfunc(EngFunc_TraceLine, start, end, IGNORE_MONSTERS, ignore_ent, ptr)
	new Float:fraction
	get_tr2(ptr, TR_flFraction, fraction)
	free_tr2(ptr)
	if(fraction == 1.0)
		return 0
	return 1
}