public CJanus7_Precache()
{
	engfunc(EngFunc_PrecacheSound, "weapons/janus7-2.wav");
}

public CJanus7_ItemPostFrame(id, iEnt, iClip, iBteWpn)
{
	if (get_pdata_float(iEnt,m_flNextPrimaryAttack) > 0.0)
		return;

	new iState = pev(iEnt, pev_iuser1);
	new Float:fNextReset; pev(iEnt, pev_fuser1, fNextReset);

	if (!iState)
		return;

	if (iState == JANUSMK5_CANUSE && pev(id,pev_button) & IN_ATTACK2 && get_pdata_float(iEnt,m_flNextSecondaryAttack) <= 0.0)
	{
		CJanus7_SecondaryAttack(id, iEnt, iClip, iBteWpn)
		set_pev(id,pev_button, pev(id,pev_button) & ~IN_ATTACK2);
	}
	else if (get_gametime() > fNextReset && fNextReset)
	{
		if (iState == JANUSMK5_CANUSE)
		{
			CJanus7_SignalEnd(id, iEnt, iClip, iBteWpn)
		}
		else if (iState == JANUSMK5_USING)
		{
			CJanus7_ChargeEnd(id, iEnt, iClip, iBteWpn)
		}
		return;
	}
}

public CJanus7_Deploy(id, iEnt, iId, iBteWpn)
{
	new iType = pev(iEnt, pev_iuser1);
	MH_SpecialEvent(id, 50 + iType);
	SendExtraAmmo(id, iEnt);
}

public CJanus7_SecondaryAttack(id, iEnt, iClip, iBteWpn)
{
	
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.0);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, 2.0);
	set_pdata_float(iEnt, m_flNextPrimaryAttack, 2.0);
	SendWeaponAnim(id, 6);
	SetExtraAmmo(id, iEnt, -1);

	MH_SpecialEvent(id, 50 + JANUSMK5_USING);
	set_pev(iEnt, pev_iuser1, JANUSMK5_USING);
	set_pev(iEnt, pev_fuser1, get_gametime() + 11.0);
	set_pev(iEnt, pev_iuser2, 0);

	SetCanReload(id, FALSE);
}

public CJanus7_ChargeEnd(id, iEnt, iClip, iBteWpn)
{
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.67, 4);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, 1.67);
	set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.67);
	SendWeaponAnim(id, 11);
	SetExtraAmmo(id, iEnt, 0);
	

	SetCanReload(id, TRUE);
	
	MH_SpecialEvent(id, 50 + 0);
	set_pev(iEnt, pev_iuser1, 0);
	set_pev(iEnt, pev_fuser1, 0.0);
}

public CJanus7_SignalEnd(id, iEnt, iClip, iBteWpn)
{
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.0, 4);
	
	MH_SpecialEvent(id, 50 + 0);
	set_pev(iEnt, pev_iuser1, 0);
	set_pev(iEnt, pev_iuser2, 0);
	set_pev(iEnt, pev_fuser1, 0.0);
}

public CJanus7_PrimaryAttack(id, iEnt, iClip, iBteWpn)
{
	new iState = pev(iEnt, pev_iuser1);
	if(iState != JANUSMK5_USING)
		return HAM_IGNORED;
	
	CJanus7_LightingAttack(iEnt)
	return HAM_SUPERCEDE;
}

public CJanus7_LightingAttack(this)
{
	new id = get_pdata_cbase(this, m_pPlayer);
	new iBteWpn = g_weapon[id][0] + g_double[id][0];
	
	set_pev(id, pev_effects, (pev(id, pev_effects) | EF_MUZZLEFLASH));
	OrpheuCall(OrpheuGetFunction("SetAnimation", "CBasePlayer"), id, PLAYER_ATTACK1)
	
	SendWeaponAnim(id, random_num(9, 10))
	
	new Float:vecVAngle[3], Float:vecPunchangle[3], Float:vecTemp[3];
	pev(id, pev_v_angle, vecVAngle)
	pev(id, pev_punchangle, vecPunchangle)
	xs_vec_add(vecVAngle, vecPunchangle, vecTemp);
	engfunc(EngFunc_MakeVectors, vecTemp);
	
	new Float:vecSrc[3];
	
	GetGunPosition(id, vecSrc)
	
	// 寻找目标
	new iTarget = pev(this, pev_target)
	if(!CJanus7_IsTargetAvailable(id, iTarget, vecSrc))
	{
		while(pev_valid((iTarget = engfunc(EngFunc_FindEntityInSphere, iTarget, vecSrc, 400.0))))
		{
			if(CJanus7_IsTargetAvailable(id, iTarget, vecSrc))
				break;
		}
	}
	
	new Float:vecEnd[3]
	if(is_user_alive(iTarget))
	{
		pev(iTarget, pev_origin, vecEnd)
		
		set_pdata_int(iTarget, m_LastHitGroup, HIT_CHEST)
		new Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1];
		ExecuteHamB(Ham_TakeDamage, iTarget, 0, id, flDamage, DMG_BLAST)
	}
	else
	{
		new Float:vecForward[3];
		global_get(glb_v_forward, vecForward);
		xs_vec_mul_scalar(vecForward, 400.0, vecForward);
		xs_vec_add(vecSrc, vecForward, vecEnd)
	}
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMENTPOINT)
	write_short(id | 0x1000) 
	engfunc(EngFunc_WriteCoord, vecEnd[0])
	engfunc(EngFunc_WriteCoord, vecEnd[1])
	engfunc(EngFunc_WriteCoord, vecEnd[2])
	write_short(g_sModelIndexLaserBeam)
	write_byte(0) // framerate
	write_byte(0) // framerate
	write_byte(1) // life
	write_byte(30)  // width
	write_byte(15)   // noise
	write_byte(255)   // r, g, b
	write_byte(255)   // r, g, b
	write_byte(0)   // r, g, b
	write_byte(255)	// brightness
	write_byte(25)		// speed
	message_end()
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMENTPOINT)
	write_short(id | 0x1000) 
	engfunc(EngFunc_WriteCoord, vecEnd[0])
	engfunc(EngFunc_WriteCoord, vecEnd[1])
	engfunc(EngFunc_WriteCoord, vecEnd[2])
	write_short(g_sModelIndexLaserBeam)
	write_byte(0) // framerate
	write_byte(0) // framerate
	write_byte(1) // life
	write_byte(20)  // width
	write_byte(50)   // noise
	write_byte(250)   // r, g, b
	write_byte(200)   // r, g, b
	write_byte(0)   // r, g, b
	write_byte(255)	// brightness
	write_byte(25)		// speed
	message_end()
	
	set_pdata_int(id, m_iWeaponVolume, NORMAL_GUN_VOLUME);
	set_pdata_int(id, m_iWeaponFlash, BRIGHT_GUN_FLASH);
	
	set_pdata_float(this, m_flNextPrimaryAttack, 0.075)
	set_pdata_float(this, m_flNextSecondaryAttack, 0.075)
	set_pdata_float(this, m_flTimeWeaponIdle, 1.9)
	
	static Float:vecVelocity[3]
	pev(id, pev_velocity, vecVelocity)
	vecVelocity[2] = 0.0
	
	// 后坐力
	if (vector_length(vecVelocity) > 0) // 跑
		KickBack(this, 1.1, 0.3, 0.2, 0.06, 4.0, 2.5, 8);
	else if (!(pev(id, pev_flags) & FL_ONGROUND)) // 空
		KickBack(this, 1.5, 0.55, 0.3, 0.3, 6.0, 5.0, 5);
	else if (pev(id, pev_flags) & FL_DUCKING) // 蹲
		KickBack(this, 0.75, 0.1, 0.1, 0.018, 3.5, 1.2, 9);
	else // 站
		KickBack(this, 0.8, 0.2, 0.18, 0.02, 3.2, 2.25, 7);
	
	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, "weapons/janus7-2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM)
	
}

public CJanus7_IsTargetAvailable(id, iTarget, Float:vecSrc[3])
{
	if(is_user_alive(iTarget) && !CheckTeammate(id, iTarget))
	{
		new Float:vecEnd[3]; pev(iTarget, pev_origin, vecEnd)
		
		if(!is_wall_between_points(vecSrc, vecEnd, 0) && CheckAngle(id, iTarget, 45.0))
		{
			return 1;
		}
	}
	return 0;
}

// 以下内容是祖传代码，已被抛弃请无视它吧...
/*
public WE_Jauns7(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	new Float:flNextPrimaryAttack; pev(iEnt, pev_fuser2, flNextPrimaryAttack); // 用这个来替代原先的m_flNextPrimaryAttack

	new Float:fCurTime;
	global_get(glb_time, fCurTime);

	if (flNextPrimaryAttack > fCurTime)
		return;

	new iState = pev(iEnt, pev_iuser1);
	if (!iState)    return;

	new Float:fNextReset; pev(iEnt, pev_fuser1, fNextReset);


	if (fCurTime > fNextReset && fNextReset)
	{
		if (iState == JANUSMK5_CANUSE) // 超过了可变形时间
		{
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.0, 4);
			SendWeaponAnim(id, 0);
		}
		if (iState == JANUSMK5_USING) // 变形时间结束了
		{
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.7, 4);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 1.7);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.7);
			SendWeaponAnim(id, 11);

			SetCanReload(id, TRUE);
		}

		iState = 0;
		fNextReset = 0.0;
		flNextPrimaryAttack = 0.0;
		MH_SpecialEvent(id, 50 + iState); // 让外挂获知一些信息
		set_pev(iEnt, pev_iuser1, iState);
		set_pev(iEnt, pev_fuser1, fNextReset);
		set_pev(iEnt, pev_fuser2, flNextPrimaryAttack);
		return;
	}

	new iButton;
	iButton = pev(id,pev_button);
	if (iButton & IN_ATTACK2 && iState == JANUSMK5_CANUSE) // 开始变形
	{
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.03);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 9999.0); // 禁止原先的攻击
		SendWeaponAnim(id, 6);

		iState = JANUSMK5_USING;
		fNextReset = fCurTime + JANUS7_CHARGE_TIME;
		MH_SpecialEvent(id, 50 + iState); // 让外挂获知一些信息
		set_pev(iEnt, pev_iuser1, iState);
		set_pev(iEnt, pev_iuser2, 0); // 清除计数
		set_pev(iEnt, pev_fuser1, fNextReset);
		set_pev(iEnt, pev_fuser2, fCurTime + 2.03);
		set_pev(iEnt, pev_iuser4, 0);

		SetCanReload(id, FALSE);
	}

	if (iButton & IN_ATTACK && iState == JANUSMK5_USING)
	{
		new Float:vPunchangle[3];
		pev(id, pev_punchangle, vPunchangle);
		vPunchangle[0] += random_float(-1.0,1.0);
		vPunchangle[1] += random_float(-1.0,1.0);
		set_pev(id, pev_punchangle, vPunchangle);

		flNextPrimaryAttack = fCurTime + c_flAttackInterval[iBteWpn][0];
		set_pev(iEnt, pev_fuser2, flNextPrimaryAttack);

		SendWeaponAnim(id, random_num(9, 10));

		//engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, JANUS7_CHARGE_SHOOT_SOUND, 1.0, ATTN_NORM, 0, 94 + random_num(0, 15));
		SendWeaponShootSound(id, true, true);

		new Float:fOrigin[3];
		pev(id, pev_origin, fOrigin);
		new Float:fEnd[3];
		new iVic = pev(iEnt, pev_iuser4);
		Stock_Get_Origin(iVic, fEnd);

		if (get_distance_f(fOrigin, fEnd) > JANUS7_CHARGE_RANGE || !Janus7_Can_Attack(id, iVic))
		{
			iVic = 0;

			new Float:fDistance = 9999.0;
			new iVictim = -1;
			while ((iVictim = engfunc(EngFunc_FindEntityInSphere, iVictim, fOrigin, JANUS7_CHARGE_RANGE)) != 0)
			{
				if (!Janus7_Can_Attack(id, iVictim)) continue;

				new Float:fOrigin2[3];
				Stock_Get_Origin(iVictim, fOrigin2);

				if (!fm_is_in_viewcone(id, fOrigin2)) continue;

				new Float:fNewDistance;
				fNewDistance = get_distance_f(fOrigin, fOrigin2);
				if (fNewDistance < fDistance)
				{
					fDistance = fNewDistance;
					iVic = iVictim;
				}
			}
			set_pev(iEnt, pev_iuser4, iVic);
		}


		Stock_Get_Postion(id,28.0,4.5,-5.0,fOrigin);

		if (iVic)
		{
			ExecuteHamB(Ham_TakeDamage, iVic, id, id, g_modruning == BTE_MOD_ZB1 ? 45.6 : 27.0, DMG_EXPLOSION);

			Stock_Get_Origin(iVic, fEnd);
			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fOrigin, 0);
			write_byte(TE_SPRITE);
			engfunc(EngFunc_WriteCoord, fEnd[0]);
			engfunc(EngFunc_WriteCoord, fEnd[1]);
			engfunc(EngFunc_WriteCoord, fEnd[2]);
			write_short(g_cache_janus7_hit);
			write_byte(4);
			write_byte(255);
			message_end();

			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fOrigin, 0);
			write_byte(TE_BEAMPOINTS);
			engfunc(EngFunc_WriteCoord, fEnd[0]);
			engfunc(EngFunc_WriteCoord, fEnd[1]);
			engfunc(EngFunc_WriteCoord, fEnd[2]);
			engfunc(EngFunc_WriteCoord, fOrigin[0]);
			engfunc(EngFunc_WriteCoord, fOrigin[1]);
			engfunc(EngFunc_WriteCoord, fOrigin[2]);
			write_short(g_cache_lgtning);
			write_byte(0); // byte (starting frame)
			write_byte(10); // byte (frame rate in 0.1's)
			write_byte(2); // byte (life in 0.1's)
			write_byte(55); // byte (line width in 0.1's)
			write_byte(17); // byte (noise amplitude in 0.01's)
			write_byte(255); // byte,byte,byte (color)
			write_byte(174);
			write_byte(14);
			write_byte(255); // byte (brightness)
			write_byte(10); // byte (scroll speed in 0.1's)
			message_end();

			//Stock_Fake_KnockBack(id, iVic, JANUS7_CHARGE_KNOCKBACK);

			if (1 <= iVic <= 32)
			{
				new Float:vAttacker[3], Float:vVictim[3];

				pev(id,pev_origin,vAttacker);
				pev(iVic,pev_origin,vVictim);

				xs_vec_sub(vVictim, vAttacker, vVictim);
				new Float:fDistance;
				fDistance = xs_vec_len(vVictim);
				xs_vec_mul_scalar(vVictim, 1 / fDistance, vVictim);

				xs_vec_mul_scalar(vVictim, JANUS7_CHARGE_KNOCKBACK, vVictim);
				xs_vec_mul_scalar(vVictim, g_knockback[iVic], vVictim);

				set_pev(iVic,pev_velocity,vVictim)
			}

		}
		else
		{
			Stock_Get_Aiming(id, fEnd);

			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fOrigin, 0);
			write_byte(TE_BEAMPOINTS);
			engfunc(EngFunc_WriteCoord, fOrigin[0]);
			engfunc(EngFunc_WriteCoord, fOrigin[1]);
			engfunc(EngFunc_WriteCoord, fOrigin[2]);
			engfunc(EngFunc_WriteCoord, fEnd[0]);
			engfunc(EngFunc_WriteCoord, fEnd[1]);
			engfunc(EngFunc_WriteCoord, fEnd[2]);
			write_short(g_cache_lgtning);
			write_byte(0); // byte (starting frame)
			write_byte(10); // byte (frame rate in 0.1's)
			write_byte(2); // byte (life in 0.1's)
			write_byte(55); // byte (line width in 0.1's)
			write_byte(17); // byte (noise amplitude in 0.01's)
			write_byte(255); // byte,byte,byte (color)
			write_byte(174);
			write_byte(14);
			write_byte(255); // byte (brightness)
			write_byte(10); // byte (scroll speed in 0.1's)
			message_end();

		}
	}
}

stock Janus7_Can_Attack(id, iVictim)
{
	if(id == iVictim || !pev_valid(iVictim)) return 0;
	if(!pev(iVictim, pev_takedamage)) return 0;
	if(!is_user_alive(iVictim) && iVictim < 32) return 0;
	if(!Stock_Is_Direct(id, iVictim)) return 0;
	if(!pev(iVictim, pev_health)) return 0;
	if(!can_damage(id, iVictim)) return 0;
	return 1;
}*/