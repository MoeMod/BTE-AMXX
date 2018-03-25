public Crow9_PrimaryAttack(id, iEnt, iBteWpn)
{
	new iSwing = pev(iEnt, pev_iuser2)
	
	SendWeaponAnim(id, iSwing ? 2:1);
	
	set_pev(iEnt, pev_iuser2, iSwing);
	
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	
	new iHitResult, Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][0] : c_flDamageZB[iBteWpn][0];
	
	
	if (!c_flAngle[iBteWpn][0])
		iHitResult = KnifeAttack(id, TRUE, c_flDistance[iBteWpn][0], flDamage, _);
	else
		iHitResult = KnifeAttack2(id, TRUE, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][0], flDamage, _);
	
	
	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 2, iSwing);
		case RESULT_HIT_WORLD : SendKnifeSound(id, 3, iSwing);
		default : SendKnifeSound(id, 1, iSwing);
	}
	
	if(iHitResult == RESULT_HIT_WORLD)
	{
		if (iSwing)
			PunchAxis(id, 0.8, 0.8);
		else
			PunchAxis(id, -0.8, -0.8);
	}
	
	if(iHitResult)
		UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0] + 1.0);
	else
		UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][0] + 0.1, c_flAttackInterval[iBteWpn][0] + 0.1, c_flAttackInterval[iBteWpn][0] + 0.1 + 1.0);
	
	set_pev(iEnt, pev_iuser2, !iSwing);
}

public Crow9_SecondaryAttack(id, iEnt, iBteWpn)
{
	SendWeaponAnim(id, 4);
	
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK2);
	
	new iHitResult, Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1];
	
	
	if (!c_flAngle[iBteWpn][1])
		iHitResult = KnifeAttack(id, TRUE, c_flDistance[iBteWpn][1], flDamage, _);
	else
		iHitResult = KnifeAttack2(id, TRUE, c_flDistance[iBteWpn][1], c_flAngle[iBteWpn][1], flDamage, _);
	
	
	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 5, 0);
		case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
		default : SendKnifeSound(id, 4, 0);
	}
	
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][1], c_flAttackInterval[iBteWpn][1], c_flAttackInterval[iBteWpn][1] + 0.5);
	
	// Charge???
	set_pev(iEnt, pev_iuser1, 1);
	ClearThink(iEnt);
	SetKnifeDelay(iEnt, 0.8, "Crow9_ChargeStart");
}

public Crow9_ItemPostFrame(id, iEnt, iBteWpn)
{
	if(pev(iEnt, pev_iuser1) == 1)
	{
		// 刚开始时还是按住右键的，松开右键后才能开始判断。
		if(!(pev(id, pev_button) & IN_ATTACK2))
			set_pev(iEnt, pev_iuser1, 2);
	}
	else if(pev(iEnt, pev_iuser1) == 2)
	{
		// 这里开始判断有没有按右键，如果有的话就拒接充能
		if((pev(id, pev_button) & IN_ATTACK2))
			set_pev(iEnt, pev_iuser1, 0);
	}
	else if(pev(iEnt, pev_iuser1) == 3)
	{
		// 进入可以按键充能的时间
		if((pev(id, pev_button) & IN_ATTACK2))
			Crow9_ChargeAttack(iEnt);
	}
	return HAM_IGNORED
}

public Crow9_ChargeStart(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	
	ClearThink(iEnt);
	
	if(pev(iEnt, pev_iuser1) && !(pev(id, pev_button) & IN_ATTACK2))
	{
		// 玩家一开始就按住右键没有放开或者狂按右键的情况下拒绝充能
		set_pev(iEnt, pev_iuser1, 3);
		
	}
	SetKnifeDelay(iEnt, 0.2, "Crow9_ChargeFail");
}

public Crow9_ChargeFail(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	
	ClearThink(iEnt);
	set_pev(iEnt, pev_iuser1, 0);
	
	SendWeaponAnim(id, 6);
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][2], c_flAttackInterval[iBteWpn][2], c_flAttackInterval[iBteWpn][2] + 0.5);
}

public Crow9_ChargeAttack(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	
	ClearThink(iEnt);
	set_pev(iEnt, pev_iuser1, 0);
	
	SendWeaponAnim(id, 5);
	
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK2);
	
	new iHitResult, Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][2] : c_flDamageZB[iBteWpn][2];
	
	
	if (!c_flAngle[iBteWpn][2])
		iHitResult = KnifeAttack(id, TRUE, c_flDistance[iBteWpn][2], flDamage, c_flKnockback[iBteWpn][4]);
	else
		iHitResult = KnifeAttack2(id, TRUE, c_flDistance[iBteWpn][2], c_flAngle[iBteWpn][2], flDamage, c_flKnockback[iBteWpn][4]);
	
	
	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 5, 0);
		case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
		default : SendKnifeSound(id, 4, 0);
	}
	
	set_pev(id, pev_weaponmodel2, "models/p_crow9b.mdl");
	
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][2], c_flAttackInterval[iBteWpn][2], c_flAttackInterval[iBteWpn][2] + 0.5);
	
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, WEAPON_EVENT[CSW_KNIFE], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0 , 0.0, (1<<10), 1, FALSE, FALSE);
	
	SetKnifeDelay(iEnt, c_flAttackInterval[iBteWpn][2], "Crow9_ResetModel");
}

public Crow9_ResetModel(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	set_pev(id, pev_weaponmodel2, "models/p_crow9a.mdl");
	ClearThink(iEnt);
}

public Crow9_Holster(id, iEnt, iBteWpn)
{
	ClearThink(iEnt);
	set_pev(iEnt, pev_iuser1, 0);
	set_pev(iEnt, pev_iuser2, 0);
}