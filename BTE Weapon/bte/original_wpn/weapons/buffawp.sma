public CBuffAWP_GetWeaponCharged(this)
{
	new Float:flStartZoom;
	pev(this, pev_fuser1, flStartZoom)
	if(flStartZoom == 0.0)
		return 0;
	new iCharged = floatround((get_gametime() - flStartZoom) / 0.8);
	if (iCharged >= 3)
	{
		iCharged = 3;
	}
	return iCharged;
}

public CBuffAWP_SecondaryAttack(this)
{
	new id = get_pdata_cbase(this, m_pPlayer, 4);
	new iBteWpn = g_weapon[id][0] + g_double[id][0];
	
	switch(get_pdata_int(id, m_iFOV))
	{
		case 90:
		{
			set_pdata_int(id, m_iFOV, c_iZoom[iBteWpn][0])
			set_pev(id, pev_fov, c_iZoom[iBteWpn][0])
			CBuffAWP_StartCharge(this)
		}
		case 40:
		{
			set_pdata_int(id, m_iFOV, c_iZoom[iBteWpn][1])
			set_pev(id, pev_fov, c_iZoom[iBteWpn][1])
		}
		default:
		{
			set_pdata_int(id, m_iFOV, 90)
			set_pev(id, pev_fov, 90)
			CBuffAWP_ResetCharge(this)
		}
	}
	
	emit_sound(id, CHAN_ITEM, "weapons/zoom.wav", 0.20, 2.40, 0, 100)
	
	ExecuteHam(Ham_Player_ResetMaxSpeed, id);
	
	// ¿ª¾µÊ±¼ä
	set_pdata_float(this, m_flNextSecondaryAttack, 0.3, 4)
	return HAM_SUPERCEDE;
}

public CBuffAWP_ItemPostFrame(id, iEnt, iClip, iBteWpn)
{
	if(!pev(iEnt, pev_fuser1) && get_pdata_int(id, m_iFOV)<90)
		CBuffAWP_StartCharge(iEnt);
	if(get_pdata_int(id, m_iFOV)==90)
		CBuffAWP_ResetCharge(iEnt);
}

public CBuffAWP_PrimaryAttack_Post(this)
{
	CBuffAWP_ResetCharge(this)
}

public CBuffAWP_Holster_Post(this)
{
	CBuffAWP_ResetCharge(this)
}

public CBuffAWP_StartCharge(this)
{
	set_pev(this, pev_fuser1, get_gametime())
}

public CBuffAWP_ResetCharge(this)
{
	set_pev(this, pev_fuser1, 0.0)
}