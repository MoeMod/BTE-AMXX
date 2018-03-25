public CCrow7_Reload(id, iEnt, iBteWpn)
{
	if (DefaultReload(iEnt, c_iClip[iBteWpn], c_iReloadAnim[iBteWpn][0], c_flReload[iBteWpn][0], 0))
	{
		SetAnimation(id, PLAYER_RELOAD)
		
		if (get_pdata_int(id, m_iFOV) != 90)
		{
			set_pdata_int(id, m_iFOV, 90);
			set_pev(id, pev_fov, 90.0);

			ExecuteHam(Ham_Player_ResetMaxSpeed, id);
		}

		if (get_pdata_int(iEnt, m_iShotsFired) == 0 && c_flAccuracyDefault[iBteWpn])
			set_pdata_float(iEnt, m_flAccuracy, c_flAccuracyDefault[iBteWpn]);
		
		set_pdata_float(iEnt, m_flLastFire, get_gametime())
		set_pdata_int(iEnt, m_fInReload, 2)
		
		//SendWeaponAnim(id, ANIM_RELOAD_START)
		ClearThink(iEnt);
		BTE_SetThink(iEnt, "CCrow7_ReloadThink");
		set_pev(iEnt, pev_fuser1, get_gametime() + c_flReload[iBteWpn][2]);
		set_pev(iEnt, pev_nextthink, get_gametime());
	}
}

public CCrow7_ReloadThink(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	
	static Float:flNextCheck;
	pev(iEnt, pev_fuser1, flNextCheck);
	
	if(get_pdata_int(iEnt, m_fInReload) == 1)
	{
		if(get_gametime() > flNextCheck)
		{
			CCrow7_ChargeFail(iEnt);
		}
	}
	if(get_pdata_int(iEnt, m_fInReload) == 2)
	{
		if(get_gametime() > flNextCheck)
		{
			CCrow7_ChargeFail(iEnt);
		}
		else if(!(pev(id, pev_button) & IN_RELOAD))
		{
			set_pdata_int(iEnt, m_fInReload, 3);
		}
	}
	else if(get_pdata_int(iEnt, m_fInReload) == 3)
	{
		if(get_gametime() > flNextCheck)
		{
			CCrow7_ChargeStart(iEnt);
		}
		else if((pev(id, pev_button) & IN_RELOAD))
		{
			set_pdata_int(iEnt, m_fInReload, 1);
		}
	}
	else if(get_pdata_int(iEnt, m_fInReload) == 4)
	{
		if(get_gametime() > flNextCheck)
		{
			CCrow7_ChargeFail(iEnt);
		}
		else if((pev(id, pev_button) & IN_RELOAD))
		{
			CCrow7_ChargeReload(iEnt);
		}
	}
	
	set_pev(iEnt, pev_nextthink, get_gametime());
}

public CCrow7_Holster(id, iEnt, iBteWpn)
{
	ClearThink(iEnt);
}

public CCrow7_ChargeStart(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	
	
	if(get_pdata_int(iEnt, m_fInReload) > 1 && !(pev(id, pev_button) & IN_RELOAD))
	{
		set_pdata_int(iEnt, m_fInReload, 4);
	}
	else
	{
		set_pdata_int(iEnt, m_fInReload, 1);
	}
	//client_print(id, print_chat, "开始判定")
	set_pev(iEnt, pev_fuser1, get_gametime() + c_flReload[iBteWpn][3]);
}

public CCrow7_ChargeFail(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	
	ClearThink(iEnt);
	set_pdata_int(iEnt, m_fInReload, 1);
	//client_print(id, print_chat, "判定失败")
	SendWeaponAnim(id, c_iReloadAnim[iBteWpn][1]);
}

public CCrow7_ChargeReload(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	
	ClearThink(iEnt);
	//client_print(id, print_chat, "成功激活")
	set_pdata_int(iEnt, m_fInReload, 1);
	set_pdata_float(id, m_flNextAttack, c_flReload[iBteWpn][1] - c_flReload[iBteWpn][2] - c_flReload[iBteWpn][3])
	SendWeaponAnim(id, c_iReloadAnim[iBteWpn][2]);
}