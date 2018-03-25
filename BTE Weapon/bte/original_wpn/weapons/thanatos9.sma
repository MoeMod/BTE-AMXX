enum
{
	EV_THANATOS9_SLASH,
	EV_THANATOS9_STAB,
	EV_THANATOS9_SMOKE
	
}


public Thanatos9_ItemPostFrame(id, iEnt, iBteWpn)
{
	if(get_pdata_float(iEnt, m_flNextSecondaryAttack) <= 0.0)
	{
		if(pev(iEnt, pev_iuser1))
		{
			set_pev(iEnt, pev_iuser1, 0);
			set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_M4A1_SILENCED);
			set_pev(id, pev_weaponmodel2, "models/p_thanatos9b.mdl")
			set_pdata_string(id, m_szAnimExtention * 4, "m249", -1 , 20)
		}
	}
	if(get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0)
	{
		if(pev(iEnt, pev_iuser2))
		{
			if(pev(iEnt, pev_iuser3)>=18)
			{
				Thanatos9_ChargeEnd(id, iEnt, iBteWpn);
			}
			else
			{
				Thanatos9_ChargeAttack(id, iEnt, iBteWpn);
				UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][1], c_flAttackInterval[iBteWpn][1], c_flAttackInterval[iBteWpn][1] + 1.0);
				set_pev(iEnt, pev_iuser3, pev(iEnt, pev_iuser3)+1);
				set_pdata_int(iEnt, m_iWeaponState, 0)
			}
		}
	}
	return HAM_IGNORED;
}

public Thanatos9_Holster(id, iEnt, iBteWpn)
{
	set_pev(iEnt, pev_iuser1, 0);
	set_pev(iEnt, pev_iuser2, 0);
	set_pev(iEnt, pev_iuser3, 0);
	ClearThink(iEnt);
}

public Thanatos9_PrimaryAttack(id, iEnt, iBteWpn)
{
	if(!get_pdata_int(iEnt, m_iWeaponState))
	{
		SetKnifeDelay(iEnt, c_flDelay[iBteWpn][0], "Thanatos9_DelayedPrimaryAttack");
		OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
		SendWeaponAnim(id, random_num(7,8));
		UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0] + 1.0);
		PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, c_flDistance[iBteWpn][0], 0.0, 0, EV_THANATOS9_SLASH, FALSE, FALSE);
	}
	else
	{
		SendWeaponAnim(id, 2);
		UTIL_WeaponDelay(iEnt, 0.57, 0.57, 0.57 + 1.0);
		set_pev(iEnt, pev_iuser2, 1);
		set_pev(iEnt, pev_iuser3, 0);
	}
}

public Thanatos9_SecondaryAttack(id, iEnt, iBteWpn)
{
	if(!get_pdata_int(iEnt, m_iWeaponState))
	{
		set_pev(iEnt, pev_iuser1, 1);
		SendWeaponAnim(id, 9);
		UTIL_WeaponDelay(iEnt, 5.0, 5.0, 5.1);
		
	}
	else
	{
		set_pdata_int(iEnt, m_iWeaponState, 0);
		SendWeaponAnim(id, 10);
		UTIL_WeaponDelay(iEnt, 3.3, 3.3, 3.5);
		
	}
}

public Thanatos9_ChargeAttack(id, iEnt, iBteWpn)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	new Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1];

	SendWeaponAnim(id, 1);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	
	new iHitResult;
	if (!c_flAngle[iBteWpn][1])
		iHitResult = KnifeAttack(id, FALSE, c_flDistance[iBteWpn][1], flDamage, _);
	else
		iHitResult = KnifeAttack2(id, FALSE, c_flDistance[iBteWpn][1], c_flAngle[iBteWpn][1], flDamage, _);

	PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, c_flDistance[iBteWpn][1], 0.0, iHitResult, EV_THANATOS9_STAB, FALSE, FALSE);

	ClearThink(iEnt);
	
}

public Thanatos9_ChargeEnd(id, iEnt, iBteWpn)
{
	set_pev(iEnt, pev_iuser1, 0);
	set_pev(iEnt, pev_iuser2, 0);
	set_pev(iEnt, pev_iuser3, 0);
	set_pdata_int(iEnt, m_iWeaponState, 0);
	
	client_cmd(id, "mp3 stop; stopsound");
	SendWeaponAnim(id, 3);
	
	UTIL_WeaponDelay(iEnt, 5.0, 5.0, 5.1);
	
	set_pev(id, pev_weaponmodel2, "models/p_thanatos9a.mdl")
	set_pdata_string(id, m_szAnimExtention * 4, "skullaxe", -1 , 20)
	
	ClearThink(iEnt);
	SetKnifeDelay(iEnt, 0.5, "Thanatos9_ChargeEndAnim");
}

public Thanatos9_ChargeEndAnim(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	SendWeaponAnim(id, 10);
	ClearThink(iEnt);
	
}

public Thanatos9_DelayedPrimaryAttack(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	new Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][0] : c_flDamageZB[iBteWpn][0];

	new iHitResult;
	if (!c_flAngle[iBteWpn][0])
		iHitResult = KnifeAttack(id, FALSE, c_flDistance[iBteWpn][0], flDamage, _);
	else
		iHitResult = KnifeAttack2(id, FALSE, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][0], flDamage, _);
	if(iHitResult)
		PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, c_flDistance[iBteWpn][0], 0.0, iHitResult, EV_THANATOS9_SLASH, FALSE, FALSE);

	ClearThink(iEnt);

}
