public CJanus11_ItemPostFrame(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	if (get_pdata_float(iEnt,m_flNextPrimaryAttack) > 0.0)
		return;

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
		fNextReset = fCurTime + 11.0;
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