public CCrow1_Reload(id, iEnt, iBteWpn)
{
	CCrow7_Reload(id, iEnt, iBteWpn);
}

public CCrow1_Holster(id, iEnt, iBteWpn)
{
	CCrow7_Holster(id, iEnt, iBteWpn);
}

public CCrow1_ItemPostFrame(id,iEnt,iClip,iBteWpn)
{
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) > 0.0)
		return;

	if(get_pdata_float(id, m_flNextAttack) <= 0.0 && !get_pdata_int(iEnt, m_fInReload))
	{
		if(pev(id, pev_button) & IN_ATTACK2 && !(pev(id, pev_button) & IN_ATTACK) && get_pdata_float(iEnt, m_flNextSecondaryAttack) <= 0.0)
		{
			ExecuteHamB(Ham_Weapon_SecondaryAttack, iEnt);
			set_pev(id, pev_button, pev(id, pev_button) & ~IN_ATTACK2);
		}
	}
}

public CCrow1_SecondaryAttack(id,iEnt,iClip,iBteWpn)
{
	static Float:vecVelocity[3]
	pev(id, pev_velocity, vecVelocity)
	vecVelocity[2] = 0.0
	
	g_flAccuracy[id] = get_pdata_float(iEnt, m_flAccuracy)
		
	// 命中 射速 设定
	if (!(pev(id, pev_flags) & FL_ONGROUND)) // 空
		CCrow1_Crow1Fire2(iEnt, (0.08) * (1.0 - g_flAccuracy[id]), c_flAttackInterval[iBteWpn][1], false);
	else if (vector_length(vecVelocity) > 0) // 跑
		CCrow1_Crow1Fire2(iEnt, (0.04) * (1.0 - g_flAccuracy[id]), c_flAttackInterval[iBteWpn][1], false);
	else if (pev(id, pev_flags) & FL_DUCKING) // 蹲
		CCrow1_Crow1Fire2(iEnt, (0.02) * (1.0 - g_flAccuracy[id]), c_flAttackInterval[iBteWpn][1], false);
	else // 地
		CCrow1_Crow1Fire2(iEnt, (0.03) * (1.0 - g_flAccuracy[id]), c_flAttackInterval[iBteWpn][1], false);
		
}

public CCrow1_Crow1Fire2(this, Float:flSpread, Float:flCycleTime, bool:fUseAutoAim)
{
	new id = get_pdata_cbase(this, m_pPlayer)
	new iBteWpn = WeaponIndex(this);
	
	g_iShotsFired[id] = get_pdata_int(this, m_iShotsFired);
	g_iShotsFired[id]++
	set_pdata_int(this, m_iShotsFired,  g_iShotsFired[id]);
	
	// 命中计算公式
	g_flAccuracy[id] = ((g_iShotsFired[id] * g_iShotsFired[id]) / 220) + 0.5;
	
	// 命中偏移最大
	if (g_flAccuracy[id]> 2.0)
		g_flAccuracy[id] = 2.0;
	else if (g_flAccuracy[id]< 0.9)
		g_flAccuracy[id] = 0.9;
	set_pdata_float(this, m_flAccuracy, g_flAccuracy[id])
	
	set_pdata_float(this, m_flLastFire, get_gametime())
	
	new iClip = get_pdata_int(this, m_iClip);
	if (iClip <= 0)
	{
		if (get_pdata_int(this, m_fFireOnEmpty))
		{
			ExecuteHamB(Ham_Weapon_PlayEmptySound, this);
			set_pdata_float(this, m_flNextSecondaryAttack, 0.2)
		}
		return;
	}
	
	iClip--;
	set_pdata_int(this, m_iClip, iClip);
	
	set_pev(id, pev_effects, (pev(id, pev_effects) | EF_MUZZLEFLASH));
	
	new Float:vecVAngle[3], Float:vecPunchangle[3], Float:vecTemp[3];
	pev(id, pev_v_angle, vecVAngle)
	pev(id, pev_punchangle, vecPunchangle)
	xs_vec_add(vecVAngle, vecPunchangle, vecTemp);
	engfunc(EngFunc_MakeVectors, vecTemp);
	
	set_pdata_int(id, m_iWeaponVolume, BIG_EXPLOSION_VOLUME);
	set_pdata_int(id, m_iWeaponFlash, BRIGHT_GUN_FLASH);
	
	new Float:vecSrc[3];
	new Float:vecDir[3];
	
	GetGunPosition(id, vecSrc)
	
	new Float:vecForward[3], Float:vecRight[3];
	global_get(glb_v_forward, vecForward);
	global_get(glb_v_right, vecRight);
	
	// 伤害和穿透和距离修正
	new Float:flDamage = IS_ZBMODE ? c_flDamageZB[iBteWpn][1] : c_flDamage[iBteWpn][1]
	

	FireBullets3(id, vecSrc, vecForward, flSpread, 4096.0, 0 + 1, BULLET_PLAYER_9MM, floatround(flDamage), 0.76, id, true, get_pdata_int(id, random_seed), vecDir);
	
	new iEvent = m_usFire[iBteWpn][0];
	if(!iEvent) iEvent = WEAPON_EVENT[c_iId[iBteWpn]];
	PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, iEvent, 0.0, g_vecZero, g_vecZero, vecDir[0], vecDir[1], floatround(vecPunchangle[0] * 100.0), floatround(vecPunchangle[1] * 100.0), iClip==0, FALSE);
	
	SetAnimation(id, PLAYER_ATTACK1)
	
	set_pdata_float(this, m_flNextPrimaryAttack, flCycleTime);
	set_pdata_float(this, m_flNextSecondaryAttack, flCycleTime);
	set_pdata_float(this, m_flTimeWeaponIdle, 1.8);
	
	// 后坐力
	if (GetVelocity2D(id) > 0.0) // 跑
		KickBack(this, 1.3, 0.45, 0.5, 0.045, 5.0, 2.75, 5);
	else if (!(pev(id, pev_flags) & FL_ONGROUND)) // 空
		KickBack(this, 1.4, 0.5, 0.45, 0.15, 6.0, 4.0, 4);
	else if (pev(id, pev_flags) & FL_DUCKING) // 蹲
		KickBack(this, 0.675, 0.3, 0.35, 0.0125, 4.0, 2.25, 5);
	else // 站
		KickBack(this, 0.725, 0.35, 0.4, 0.015, 4.25, 2.0, 5);
	
}