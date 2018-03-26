public Melee_Slash(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	new iBteWpn = WeaponIndex(iEnt);
	new Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][0] : c_flDamageZB[iBteWpn][0];
	new iHitResult;

	if (!c_flAngle[iBteWpn][0])
		iHitResult = KnifeAttack(id, FALSE, c_flDistance[iBteWpn][0], flDamage, c_flKnockback[iBteWpn][0]);
	else
		iHitResult = KnifeAttack2(id, FALSE, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][0], flDamage, _);

	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 2, pev(iEnt, pev_iuser4));
		case RESULT_HIT_WORLD : SendKnifeSound(id, 3, pev(iEnt, pev_iuser4));
	}

	ClearThink(iEnt);
}

public Melee_Stab(iEnt)
{
	new iHitResult, iBteWpn = WeaponIndex(iEnt), id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	SendKnifeSound(id, 4, pev(iEnt, pev_iuser4));
	new Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1];

	if (!c_flAngle[iBteWpn][1])
		iHitResult = KnifeAttack(id, TRUE, c_flDistance[iBteWpn][1], flDamage, _);
	else
		iHitResult = KnifeAttack2(id, TRUE, c_flDistance[iBteWpn][1], c_flAngle[iBteWpn][1], flDamage, _);

	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 5, 0);
		case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
	}

	if (!c_flDelay[iBteWpn][1])
	{
		if (iHitResult != RESULT_HIT_NONE)
			SendWeaponAnim(id, 4);
		else
			SendWeaponAnim(id, 5);
	}

	ClearThink(iEnt);
}

public Melee_PrimaryAttack(id, iEnt, iBteWpn)
{
	SetKnifeDelay(iEnt, c_flDelay[iBteWpn][0], "Melee_Slash");
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0] + 3.0);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	g_anim[id] += 1;
	new iAnim = g_anim[id] % 2;
	set_pev(iEnt, pev_iuser4, iAnim);
	SendWeaponAnim(id, 6 + iAnim);
	SendKnifeSound(id, 1, iAnim);
}

public Melee_SecondaryAttack(id, iEnt, iBteWpn)
{
	SetKnifeDelay(iEnt, c_flDelay[iBteWpn][1], "Melee_Stab");
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][1], c_flAttackInterval[iBteWpn][1], c_flAttackInterval[iBteWpn][1] + 2.0);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	if (c_flDelay[iBteWpn][1])
		SendWeaponAnim(id, 6);
}