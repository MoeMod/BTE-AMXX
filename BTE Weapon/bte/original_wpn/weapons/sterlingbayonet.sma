public CSterlingbayonet_ItemPostFrame(id, iEnt, iClip, iBteWpn)
{
	if(get_pdata_float(iEnt, m_flNextSecondaryAttack) <= 0.0)
	{
		if(pev(id, pev_button) & IN_ATTACK2)
		{
			set_pev(id, pev_button, pev(id, pev_button) & ~IN_ATTACK2)
			CSterlingbayonet_SecondaryAttack(id, iEnt, iClip, iBteWpn)
		}
	}
}

public CSterlingbayonet_SecondaryAttack(id, iEnt, iClip, iBteWpn)
{
	if(get_pdata_int(iEnt, m_iWeaponState))
	{
		UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][3], c_flAttackInterval[iBteWpn][3], c_flAttackInterval[iBteWpn][3] + 3.0);
		OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK2);
		
		SendWeaponAnim(id, random_num(7,8));
		
		SetKnifeDelay(iEnt, c_flDelay[iBteWpn][3], "CSterlingbayonet_Slash");
	}
	else
	{
		UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][2], c_flAttackInterval[iBteWpn][2], c_flAttackInterval[iBteWpn][2] + 3.0);
		OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK2);
		
		SendWeaponAnim(id, 4);
		
		SetKnifeDelay(iEnt, c_flDelay[iBteWpn][2], "CSterlingbayonet_Stab");
	}
}

public CSterlingbayonet_Slash(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	new Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][3] : c_flDamageZB[iBteWpn][3];

	new iHitResult = KnifeAttack(id, FALSE, c_flDistance[iBteWpn][3], flDamage, 0.0);

	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 2, 0);
		case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
		default:
			SendKnifeSound(id, 1, 0);
	}

	ClearThink(iEnt);
}

public CSterlingbayonet_Stab(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	new Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][2] : c_flDamageZB[iBteWpn][2];

	new iHitResult = KnifeAttack(id, FALSE, c_flDistance[iBteWpn][2], flDamage, 0.0);

	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 5, 0);
		case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
		default:
			SendKnifeSound(id, 4, 0);
	}
	
	if(iHitResult != RESULT_HIT_NONE)
	{
		SendWeaponAnim(id, 6);
		set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_M4A1_SILENCED);
	}
	else
	{
		SendWeaponAnim(id, 5);
	}

	ClearThink(iEnt);
}