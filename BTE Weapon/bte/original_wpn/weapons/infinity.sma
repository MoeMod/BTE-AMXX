public CInfinity_ItemPostFrame(id,iEnt,iClip,iBteWpn)
{
	if (!Stock_Can_Attack())
		return;

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

public CInfinity_PrimaryAttack_Post(id, iEnt, iClip, iBteWpn)
{
	new iWeaponState = get_pdata_int(iEnt, m_iWeaponState);

	if(iClip)
		iWeaponState ^=WPNSTATE_ELITE_LEFT
	
	set_pdata_int(iEnt, m_iWeaponState, iWeaponState);
}

public CInfinity_SecondaryAttack(id,iEnt,iClip,iBteWpn)
{
	new Float:vecVelocity[3]
	pev(id, pev_velocity, vecVelocity)
	vecVelocity[2] = 0.0
	
	new Float:flAccuracy = get_pdata_float(iEnt, m_flAccuracy)
		
	// 命中 射速 设定
	if (vector_length(vecVelocity) > 0) // 跑
		CInfinity_InfinityFire2(iEnt, (0.03) * (flAccuracy), c_flAttackInterval[iBteWpn][1], false);
	else if (!(pev(id, pev_flags) & FL_ONGROUND)) // 空
		CInfinity_InfinityFire2(iEnt, (0.07) * (flAccuracy), c_flAttackInterval[iBteWpn][1], false);
	else if (pev(id, pev_flags) & FL_DUCKING) // 蹲
		CInfinity_InfinityFire2(iEnt, (0.02) * (flAccuracy), c_flAttackInterval[iBteWpn][1], false);
	else // 地
		CInfinity_InfinityFire2(iEnt, (0.025) * (flAccuracy), c_flAttackInterval[iBteWpn][1], false);
		
}

public CInfinity_WeaponIdle_Post(this)
{
	new iWeaponState = get_pdata_int(this, m_iWeaponState);
	if(random_num(0,4))
		iWeaponState |= WPNSTATE_USP_SILENCED
	else
		iWeaponState &= ~WPNSTATE_USP_SILENCED
	set_pdata_int(this, m_iWeaponState, iWeaponState);
}

public CInfinity_InfinityFire2(this, Float:flSpread, Float:flCycleTime, bool:fUseAutoAim)
{
	new id = get_pdata_cbase(this, m_pPlayer)
	new iBteWpn = WeaponIndex(this);
	
	new iShotsFired = get_pdata_int(this, m_iShotsFired)
	iShotsFired++
	set_pdata_int(this, m_iShotsFired,  iShotsFired);
	
	new Float:flAccuracy = get_pdata_float(this, m_flAccuracy)
	
	// 命中计算公式
	if(iShotsFired == 1)
	{
		flAccuracy = 1.5
		
	}
	else
	{
		flAccuracy = ((iShotsFired * iShotsFired) / 220) + 0.6;
	}
	
	// 命中偏移最大
	if (flAccuracy> 2.0)
		flAccuracy = 2.0;
	else if (flAccuracy< 0.0)
		flAccuracy = 0.0;
	set_pdata_float(this, m_flAccuracy, flAccuracy)
	
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
	
	new iWeaponState = get_pdata_int(this, m_iWeaponState);

	if(iWeaponState & WPNSTATE_ELITE_LEFT)
	{
		new Float:vecSrcNew[3]
		xs_vec_mul_scalar(vecRight, 5.0, vecSrcNew)
		xs_vec_sub(vecSrc, vecSrcNew, vecSrcNew)
		FireBullets3(id, vecSrcNew, vecForward, flSpread, 4096.0, 0 + 1, BULLET_PLAYER_45ACP, floatround(flDamage), 0.8, id, true, get_pdata_int(id, random_seed), vecDir);
		PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, vecDir[0], vecDir[1], (iWeaponState & WPNSTATE_USP_SILENCED) ? 1:2, iClip, FALSE, TRUE);
		
		if(iWeaponState & WPNSTATE_USP_SILENCED)
			SendWeaponAnim(id, iClip > 1 ? 6:10)
		else
			SendWeaponAnim(id, iClip > 1 ? 7:10)
		
		iWeaponState &= ~WPNSTATE_ELITE_LEFT;
		SetAnimation(id, PLAYER_ATTACK1)
	}
	else
	{
		new Float:vecSrcNew[3]
		xs_vec_mul_scalar(vecRight, 5.0, vecSrcNew)
		xs_vec_sub(vecSrc, vecSrcNew, vecSrcNew)
		FireBullets3(id, vecSrcNew, vecForward, flSpread, 4096.0, 0 + 1, BULLET_PLAYER_45ACP, floatround(flDamage), 0.8, id, true, get_pdata_int(id, random_seed), vecDir);
		PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, vecDir[0], vecDir[1], (iWeaponState & WPNSTATE_USP_SILENCED) ? 1:2, iClip, TRUE, TRUE);
		
		if(iWeaponState & WPNSTATE_USP_SILENCED)
			SendWeaponAnim(id, iClip ? 8:11)
		else
			SendWeaponAnim(id, iClip ? 9:11)
		
		iWeaponState |= WPNSTATE_ELITE_LEFT;
		SetAnimation(id, PLAYER_ATTACK2)
	}
	
	set_pdata_int(this, m_iWeaponState, iWeaponState);
	
	set_pdata_float(this, m_flNextPrimaryAttack, flCycleTime);
	set_pdata_float(this, m_flNextSecondaryAttack, flCycleTime);
	set_pdata_float(this, m_flTimeWeaponIdle, 1.8);
	
	static Float:vecVelocity[3]
	pev(id, pev_velocity, vecVelocity)
	vecVelocity[2] = 0.0
	
	// 后坐力
	if (vector_length(vecVelocity) > 0) // 跑
		KickBack(this, 0.35, 0.4, 0.1, 0.15, 2.3, 3.3, 2);
	else if (!(pev(id, pev_flags) & FL_ONGROUND)) // 空
		KickBack(this, 1.0, 1.0, 0.8, 0.8, 5.0, 5.0, 5);
	else if (pev(id, pev_flags) & FL_DUCKING) // 蹲
		KickBack(this, 0.2 ,0.35, 0.07, 0.1, 2.0, 3.0, 1);
	else // 站
		KickBack(this, 0.3, 0.45, 0.1, 0.2, 1.3, 1.8, 2);
	
}