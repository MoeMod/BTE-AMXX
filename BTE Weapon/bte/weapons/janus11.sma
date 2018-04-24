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

	set_pdata_int(id, 239, 1000)
	set_pdata_int(id, 241, 512)

	set_pev(id, pev_effects, (pev(id, pev_effects) | EF_MUZZLEFLASH))
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1)

	//UTIL_PlayWeaponAnimation(id, ANIM_SHOOTC)
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 0, 0, FALSE, FALSE);

	new Float:vecVAngle[3], Float:vecPunchangle[3], Float:vecTemp[3]
	pev(id, pev_v_angle, vecVAngle)
	pev(id, pev_punchangle, vecPunchangle)
	xs_vec_add(vecVAngle, vecPunchangle, vecTemp)
	engfunc(EngFunc_MakeVectors, vecTemp)

	new Float:vecSrc[3], Float:vecForward[3]
	GetGunPosition(id, vecSrc)
	global_get(glb_v_forward, vecForward)
	FireBulletsEx(id, 8, vecSrc, vecForward, Float:{0.07, 0.07, 0.0})

	set_pdata_float(iEntity, 46, 0.43, 4)
	set_pdata_float(iEntity, 47, 0.43, 4)
	set_pdata_float(iEntity, 48, 1.9, 4)

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

public FireBulletsEx(id, cShots, Float:vecSrc[3], Float:vecForward[3], Float:vecSpread[3])
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

		/*new Float:vecDir[3], Float:vecRightOffset[3], Float:vecUpOffset[3]
		xs_vec_mul_scalar(vecRight, x * vecSpread[0], vecRightOffset)
		xs_vec_mul_scalar(vecUp, y * vecSpread[1], vecUpOffset)
		xs_vec_add(vecForward, vecRightOffset, vecDir)
		xs_vec_add(vecDir, vecUpOffset, vecDir)
		xs_vec_normalize(vecDir, vecDir)*/

		static Float:vecDir[3]
		vecDir[0] = vecForward[0] + x * vecSpread[0] * vecRight[0] + y * vecSpread[1] * vecUp[0]
		vecDir[1] = vecForward[1] + x * vecSpread[0] * vecRight[1] + y * vecSpread[1] * vecUp[1]
		vecDir[2] = vecForward[2] + x * vecSpread[0] * vecRight[2] + y * vecSpread[1] * vecUp[2]

		FireBullets3(id, vecSrc, vecForward, 0.07, 8192.0, 7, BULLET_PLAYER_338MAG, 80, 1.0, id, false, random(233), vecDir)
	}
}

// 以下内容BTE.dll实现。
/*
//下面全部来自Csoldjb_WeaponSystem.sma但是不知道为什么没有用呢
public TraceAttack(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
	
	static iBteWpn;

	if (c_iSpecial[iBteWpn] == SPECIAL_JANUS11 && pev(iEnt, pev_iuser1) == 1)
	{
		static Float:flEnd[3]
		get_tr2(ptr, TR_vecEndPos, flEnd)

		get_position(iAttacker, 20.0, 5.0, 5.0, StartOrigin2)
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMPOINTS)
		engfunc(EngFunc_WriteCoord, StartOrigin2[0])
		engfunc(EngFunc_WriteCoord, StartOrigin2[1])
		engfunc(EngFunc_WriteCoord, StartOrigin2[2] - 10.0)
		engfunc(EngFunc_WriteCoord, flEnd[0])
		engfunc(EngFunc_WriteCoord, flEnd[1])
		engfunc(EngFunc_WriteCoord, flEnd[2])
		write_short(g_iBeamSprite)
		write_byte(0) // start frame
		write_byte(0) // framerate
		write_byte(1) // life
		write_byte(5) // line width
		write_byte(0) // amplitude
		write_byte(255)
		write_byte(20)
		write_byte(50) // blue
		write_byte(255) // brightness
		write_byte(0) // speed
		message_end()
		return;
	}	
}


public fw_TraceAttack(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
	new Float:StartOrigin2[3]
	new g_iBeamSprite = precache_model("sprites/laserbeam.spr")
	
	if(!is_user_alive(iAttacker))
		return

	static iBteWpn;
	iBteWpn = g_weapon[iAttacker][0]

	if (c_iSpecial[iBteWpn] == SPECIAL_JANUS11 && pev(iEnt, pev_iuser1) == 1)
	{
	
	
		static Float:flEnd[3]
		get_tr2(ptr, TR_vecEndPos, flEnd)
		
	


		get_position(iAttacker, 20.0, 5.0, 5.0, StartOrigin2)
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMPOINTS)
		engfunc(EngFunc_WriteCoord, StartOrigin2[0])
		engfunc(EngFunc_WriteCoord, StartOrigin2[1])
		engfunc(EngFunc_WriteCoord, StartOrigin2[2] - 10.0)
		engfunc(EngFunc_WriteCoord, flEnd[0])
		engfunc(EngFunc_WriteCoord, flEnd[1])
		engfunc(EngFunc_WriteCoord, flEnd[2])
		write_short(g_iBeamSprite)
		write_byte(0) // start frame
		write_byte(0) // framerate
		write_byte(1) // life
		write_byte(8) // line width
		write_byte(0) // amplitude
		write_byte(220)
		write_byte(88)
		write_byte(0) // blue
		write_byte(255) // brightness
		write_byte(0) // speed
		message_end()
	}


}

stock get_position(id,Float:forw, Float:right, Float:up, Float:vStart[])
{
	static Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_view_ofs, vUp) //for player
	xs_vec_add(vOrigin, vUp, vOrigin)
	pev(id, pev_v_angle, vAngle) // if normal entity ,use pev_angles
	
	angle_vector(vAngle,ANGLEVECTOR_FORWARD, vForward) //or use EngFunc_AngleVectors
	angle_vector(vAngle,ANGLEVECTOR_RIGHT, vRight)
	angle_vector(vAngle,ANGLEVECTOR_UP, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}
*/