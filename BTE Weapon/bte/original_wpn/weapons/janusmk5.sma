public CJanusmk5_ItemPostFrame(id, iEnt, iClip, iBteWpn)
{
	if (get_pdata_float(iEnt,m_flNextPrimaryAttack) > 0.0)
		return;

	new iState = pev(iEnt, pev_iuser1);
	new Float:fNextReset; pev(iEnt, pev_fuser1, fNextReset);

	if (!iState)
		return;

	if (iState == JANUSMK5_CANUSE && pev(id,pev_button) & IN_ATTACK2 && get_pdata_float(iEnt,m_flNextSecondaryAttack) <= 0.0)
	{
		CJanusmk5_SecondaryAttack(id, iEnt, iClip, iBteWpn)
		set_pev(id,pev_button, pev(id,pev_button) & ~IN_ATTACK2);
	}
	else if (get_gametime() > fNextReset && fNextReset)
	{
		if (iState == JANUSMK5_CANUSE)
		{
			CJanusmk5_SignalEnd(id, iEnt, iClip, iBteWpn)
		}
		else if (iState == JANUSMK5_USING)
		{
			CJanusmk5_ChargeEnd(id, iEnt, iClip, iBteWpn)
		}
		return;
	}
}

public CJanusmk5_Deploy(id, iEnt, iId, iBteWpn)
{
	new iType = pev(iEnt, pev_iuser1);
	MH_SpecialEvent(id, 50 + iType);
	SendExtraAmmo(id, iEnt);
}

public CJanusmk5_PrimaryAttack(id, iEnt, iClip, iBteWpn)
{
	new iState = pev(iEnt, pev_iuser1);
	if(iState != JANUSMK5_USING)
		return HAM_IGNORED;
	
	if (pev(id, pev_waterlevel) == 3)
	{
		ExecuteHam(Ham_Weapon_PlayEmptySound, iEnt);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.15)
		return HAM_SUPERCEDE;
	}
	
	set_pdata_int(id, m_iWeaponVolume, LOUD_GUN_VOLUME);
	set_pdata_int(id, m_iWeaponFlash, BRIGHT_GUN_FLASH);
	
	set_pdata_int(iEnt, m_iShotsFired, get_pdata_int(iEnt, m_iShotsFired ) + 1);
	
	set_pev(id, pev_effects, (pev(id, pev_effects) | EF_MUZZLEFLASH));
	OrpheuCall(OrpheuGetFunction("SetAnimation", "CBasePlayer"), id, PLAYER_ATTACK1)
	
	new Float:vecVAngle[3], Float:vecPunchangle[3], Float:vecTemp[3];
	pev(id, pev_v_angle, vecVAngle)
	pev(id, pev_punchangle, vecPunchangle)
	xs_vec_add(vecVAngle, vecPunchangle, vecTemp);
	engfunc(EngFunc_MakeVectors, vecTemp);
	
	new Float:vecSrc[3];
	
	GetGunPosition(id, vecSrc)
	
	new Float:vecForward[3];
	global_get(glb_v_forward, vecForward);
	
	new Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1];
	FireBullets(id, 3, vecSrc, vecForward, Float:{0.0715,0.0715,0.0}, 8192.0, BULLET_PLAYER_BUCKSHOT, 0, floatround(flDamage / 3.0), id);
	
	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1])
	set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][1])
	set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flShootAnimTime[iBteWpn][1])
	
	// 后坐力
		
	if (pev(id, pev_flags) & FL_ONGROUND)
	{
		if (!GetVelocity2D(id))
		{
			if (pev(id, pev_flags) & FL_DUCKING)
				KickBack(iEnt, 0.45, 0.2, 0.12, 0.01, 3.0, 2.0, 7);
			else
				KickBack(iEnt, 0.595, 0.32, 0.215, 0.0105, 3.25, 2.0, 8);
		}
		else	
			KickBack(iEnt, 0.9, 0.435, 0.25, 0.04, 3.25, 3.0, 8);
	}
	else
	{
		KickBack(iEnt, 1.14, 0.475, 0.225, 0.145, 5.4, 3.5, 6);
	}
	
	PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, 0.0715, 0.0715, 0, 0, FALSE, TRUE);
	return HAM_SUPERCEDE;
}

public CJanusmk5_SecondaryAttack(id, iEnt, iClip, iBteWpn)
{
	
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.0);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, 2.0);
	set_pdata_float(iEnt, m_flNextPrimaryAttack, 2.0);
	SendWeaponAnim(id, 5);
	SetExtraAmmo(id, iEnt, -1);

	MH_SpecialEvent(id, 50 + JANUSMK5_USING);
	set_pev(iEnt, pev_iuser1, JANUSMK5_USING);
	set_pev(iEnt, pev_fuser1, get_gametime() + 11.0);
	set_pev(iEnt, pev_iuser2, 0);

	SetCanReload(id, FALSE);
}

public CJanusmk5_ChargeEnd(id, iEnt, iClip, iBteWpn)
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

public CJanusmk5_SignalEnd(id, iEnt, iClip, iBteWpn)
{
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.0, 4);
	
	MH_SpecialEvent(id, 50 + 0);
	set_pev(iEnt, pev_iuser1, 0);
	set_pev(iEnt, pev_iuser2, 0);
	set_pev(iEnt, pev_fuser1, 0.0);
}