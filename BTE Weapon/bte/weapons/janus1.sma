public CJanus1_ItemPostFrame(id, iEnt, iClip, iBteWpn)
{
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) > 0.0)
		return;

	static iState, Float:fNextReset, Float:fCurTime;
	iState = pev(iEnt, pev_iuser1);
	pev(iEnt, pev_fuser1, fNextReset);
	fCurTime = get_gametime();

	if (iState == 1 && pev(id,pev_button) & IN_ATTACK2 && get_pdata_float(iEnt,m_flNextSecondaryAttack) <= 0.0)
	{
		CJanus1_SecondaryAttack(id, iEnt, iClip, iBteWpn)
		set_pev(id,pev_button, pev(id,pev_button) & ~IN_ATTACK2);
	}
	else if (fCurTime > fNextReset && fNextReset)
	{
		if (iState == 1) // 超过了可变形时间
		{
			set_pdata_float(iEnt, m_flTimeWeaponIdle, -0.1);
		}
		if (iState == 2) // 变形时间结束了
		{
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.7);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.7);
			SendWeaponAnim(id, 10);
			SetExtraAmmo(id, iEnt, 0);
		}

		iState = 0;
		fNextReset = 0.0;
		MH_SpecialEvent(id, 50 + iState);
		set_pev(iEnt, pev_iuser1, iState);
		set_pev(iEnt, pev_fuser1, fNextReset);
		return;
	}

	if (pev(id,pev_button) & IN_ATTACK)
	{
		CJanus1_PrimaryAttack(id, iEnt, iClip, iBteWpn);
	}
}

public CJanus1_Deploy(id, iEnt, iId, iBteWpn)
{
	new iType = pev(iEnt, pev_iuser1);
	MH_SpecialEvent(id, 50 + iType);
	SendExtraAmmo(id, iEnt);
}

public CJanus1_PrimaryAttack(id, iEnt, iClip, iBteWpn)
{
	new iState = pev(iEnt, pev_iuser1);
	if (iState != 2)
	{
		if (!iClip)
		{
			PlayEmptySound(id);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.5);
			return;
		}

		set_pdata_float(iEnt, m_flNextPrimaryAttack, iClip>1 ? 2.83 : 1.03);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, iClip>1 ? 2.83 : 1.03);

		if (iState == 1)
			SendWeaponAnim(id, iClip>1?4:13);
		else
			SendWeaponAnim(id, iClip>1?2:3);

		SendWeaponShootSound(id, iClip<=1, FALSE);

		set_pdata_int(iEnt, m_iClip, iClip - 1);
	}
	else
	{
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.3);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.03);

		SendWeaponAnim(id, 9);

		SendWeaponShootSound(id, TRUE, FALSE);
	}

	new pEntity = CreateEntity(id, iBteWpn, "models/s_grenade.mdl", c_flEntityAngle[iBteWpn], c_flEntitySpeed[iBteWpn], c_flEntityGravity[iBteWpn], MOVETYPE_BOUNCE, ENTCLASS_NADE);

	SetGreadeEntity(pEntity, iBteWpn, 1, (iState == 2))
}

public CJanus1_SecondaryAttack(id, iEnt, iClip, iBteWpn)
{
	new iState = pev(iEnt, pev_iuser1);
	
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.03);
	set_pdata_float(iEnt, m_flNextPrimaryAttack, 2.03);
	SendWeaponAnim(id, 5);
	SetExtraAmmo(id, iEnt, -1);

	iState = 2;
	MH_SpecialEvent(id, 50 + iState);
	set_pev(iEnt, pev_iuser1, iState);
	set_pev(iEnt, pev_iuser2, 0);
	set_pev(iEnt, pev_fuser1, get_gametime() + 8.0);
	set_pev(iEnt, pev_fuser2, get_gametime() + 2.03);
}