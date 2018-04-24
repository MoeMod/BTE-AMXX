public CJanus11_ItemPostFrame(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	if (get_pdata_float(iEnt,m_flNextPrimaryAttack) > 0.0)
	return

	new Float:fCurTime;
	global_get(glb_time, fCurTime);

	new iState = pev(iEnt, pev_iuser1);
	new Float:fNextReset; pev(iEnt, pev_fuser1, fNextReset);

	if (!iState)
	return;

	new iButton;
	iButton = pev(id,pev_button);
	if (iButton & IN_ATTACK2 && iState == JANUSMK5_CANUSE) // 按下右键切换充能模式
	{
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.0);
		set_pdata_float(iEnt, m_flNextSecondaryAttack, 2.0);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 2.0);
		SendWeaponAnim(id, 7);

		set_pev(iEnt,pev_iuser1,1);

		iState = JANUSMK5_USING;
		fNextReset = fCurTime + 8.0;
		MH_SpecialEvent(id, 50 + iState);
		set_pev(iEnt, pev_iuser1, iState);
		set_pev(iEnt, pev_fuser1, fNextReset);
		set_pev(iEnt, pev_iuser2, 0);

		SetCanReload(id, FALSE);
	}
	if (fCurTime > fNextReset && fNextReset)
	{
		if (iState == JANUSMK5_CANUSE)
		{
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.0, 4);
			
		}
		if (iState == JANUSMK5_USING) // 充能结束
		{
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.67, 4);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 1.67);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.67);
			SendWeaponAnim(id, 11);

			set_pev(iEnt, pev_iuser1,0);


			SetCanReload(id, TRUE);
		}

		iState = 0;
		fNextReset = 0.0;
		MH_SpecialEvent(id, 50 + iState);
		set_pev(iEnt, pev_iuser1, iState);
		set_pev(iEnt, pev_fuser1, fNextReset);
		return;
	}
}

public CJanus11_PrimaryAttack2(id, iEntity, iClip, iBteWpn)
{
	if (pev(id, pev_waterlevel) == 3)
	{
		ExecuteHam(Ham_Weapon_PlayEmptySound, iEntity)
		set_pdata_float(iEntity, 46, 0.15, 4)
		return
	}

	set_pdata_int(id, m_iWeaponVolume, LOUD_GUN_VOLUME);
	set_pdata_int(id, m_iWeaponFlash, BRIGHT_GUN_FLASH);

	set_pev(id, pev_effects, (pev(id, pev_effects) | EF_MUZZLEFLASH))
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1)

	new Float:vecVAngle[3], Float:vecPunchangle[3], Float:vecTemp[3]
	pev(id, pev_v_angle, vecVAngle)
	pev(id, pev_punchangle, vecPunchangle)
	xs_vec_add(vecVAngle, vecPunchangle, vecTemp)
	engfunc(EngFunc_MakeVectors, vecTemp)

	new Float:vecSrc[3], Float:vecForward[3]
	GetGunPosition(id, vecSrc)
	global_get(glb_v_forward, vecForward)
	FireBulletsEx(id, 8, vecSrc, vecForward, Float:{0.07, 0.07, 0.0}, iBteWpn)

	set_pdata_float(iEntity, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1])
	set_pdata_float(iEntity, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][1])
	set_pdata_float(iEntity, m_flTimeWeaponIdle, c_flShootAnimTime[iBteWpn][1])

	new Float:vecVelocity[3]
	pev(id, pev_velocity, vecVelocity)
	vecVelocity[2] = 0.0

	if (!(pev(id, pev_flags) & FL_ONGROUND))
		vecPunchangle[0] -= random_float(7.0, 10.0)
	else
		vecPunchangle[0] -= random_float(3.0, 5.0)
	set_pev(id, pev_punchangle, vecPunchangle)
	
	new iState = pev(iEntity, pev_iuser1);
	PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, 0.0, 0.0, 0, 0, !!iState, iState == JANUSMK5_USING);
}

public FireBulletsEx(id, cShots, Float:vecSrc[3], Float:vecForward[3], Float:vecSpread[3], iBteWpn)
{
	new tr = create_tr2()
	new Float:vecRight[3], Float:vecUp[3]
	global_get(glb_v_right, vecRight)
	global_get(glb_v_up, vecUp)

	new Float:vecVAngle[3], Float:vecPunchangle[3], Float:vecTemp[3]
	pev(id, pev_v_angle, vecVAngle)
	pev(id, pev_punchangle, vecPunchangle)
	xs_vec_add(vecVAngle, vecPunchangle, vecTemp)
	engfunc(EngFunc_MakeVectors, vecTemp)

	for (new iShot = 1; iShot <= cShots; iShot++)
	{
		new Float:x,Float:y, Float:z
		do
		{
			x = random_float(-0.5, 0.5) + random_float(-0.5, 0.5)
			y = random_float(-0.5, 0.5) + random_float(-0.5, 0.5)
			z = x * x + y * y
		}
		while (z > 1.0)

		new Float:vecDir[3], Float:vecRightOffset[3], Float:vecUpOffset[3]
		xs_vec_mul_scalar(vecRight, x * vecSpread[0], vecRightOffset)
		xs_vec_mul_scalar(vecUp, y * vecSpread[1], vecUpOffset)
		xs_vec_add(vecForward, vecRightOffset, vecDir)
		xs_vec_add(vecDir, vecUpOffset, vecDir)
		xs_vec_normalize(vecDir, vecDir)

		//static Float:vecDir[3]
		//vecDir[0] = vecForward[0] + x * vecSpread[0] * vecRight[0] + y * vecSpread[1] * vecUp[0]
		//vecDir[1] = vecForward[1] + x * vecSpread[0] * vecRight[1] + y * vecSpread[1] * vecUp[1]
		//vecDir[2] = vecForward[2] + x * vecSpread[0] * vecRight[2] + y * vecSpread[1] * vecUp[2]

	new Float:flDamage = 60.0
		FireBullets3(id, vecSrc, vecForward, 0.07, 8192.0, 7, BULLET_PLAYER_338MAG, floatround(flDamage), 1.0, id, false, random(233), vecDir)
	}
}
