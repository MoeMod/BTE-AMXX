public DrawonSword_Slash(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	new Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][0] : c_flDamageZB[iBteWpn][0];

	new iHitResult = KnifeAttack(id, FALSE, c_flDistance[iBteWpn][0], flDamage, _);

	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 2, pev(iEnt, pev_iuser4));
		case RESULT_HIT_WORLD : SendKnifeSound(id, 3, pev(iEnt, pev_iuser4));
	}

	ClearThink(iEnt);
}

public DrawonSword_Stab(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	new iHitResult, Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1];
	SendWeaponAnim(id, 5);
	SendKnifeSound(id, 4, pev(iEnt, pev_iuser4));
	if (!c_flAngle[iBteWpn][1])
		iHitResult = KnifeAttack(id, TRUE, c_flDistance[iBteWpn][1], flDamage, c_flKnockback[iBteWpn][2]);
	else
		iHitResult = KnifeAttack2(id, TRUE, c_flDistance[iBteWpn][1], c_flAngle[iBteWpn][1], flDamage, c_flKnockback[iBteWpn][2]);
	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 5, 0);
		case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
	}

	ClearThink(iEnt);
}

public DragonSword_PrimaryAttack(id,iEnt,iBteWpn)
{
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0] + 3.0);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	new iAnim = g_anim[id] % 2;
	set_pev(iEnt, pev_iuser4, iAnim);
	g_anim[id] += 1;
	SendWeaponAnim(id, 1 + iAnim);
	SendKnifeSound(id, 1, iAnim);
	if (!iAnim)
		SetKnifeDelay(iEnt, 0.6, "DrawonSword_Slash");
	else
		SetKnifeDelay(iEnt, c_flDelay[iBteWpn][0], "DrawonSword_Slash");
}

public DragonSword_SecondaryAttack(id, iEnt, iBteWpn)
{
	SetKnifeDelay(iEnt, c_flDelay[iBteWpn][1], "DrawonSword_Stab");
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][1], c_flAttackInterval[iBteWpn][1], c_flAttackInterval[iBteWpn][1] + 2.0);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	SendWeaponAnim(id, 4);
}