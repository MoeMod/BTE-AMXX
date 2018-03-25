public SkullAxe_Slash(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	new Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][0] : c_flDamageZB[iBteWpn][0];

	new iHitResult = KnifeAttack(id, FALSE, c_flDistance[iBteWpn][0], flDamage, c_flKnockback[iBteWpn][0]);

	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 2, 0);
		case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
		default:
			SendKnifeSound(id, 1, 0);
	}

	if (iHitResult != RESULT_HIT_NONE)
		SendWeaponAnim(id, 1);
	else
		SendWeaponAnim(id, 4);

	ClearThink(iEnt);
}

public SkullAxe_Stab(iEnt)
{
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	new iHitResult;
	new Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1];

	if (!c_flAngle[iBteWpn][1])
		iHitResult = KnifeAttack(id, TRUE, c_flDistance[iBteWpn][1], flDamage, c_flKnockback[iBteWpn][1]);
	else
		iHitResult = KnifeAttack2(id, TRUE, c_flDistance[iBteWpn][1], c_flAngle[iBteWpn][1], flDamage, c_flKnockback[iBteWpn][1], -1, TRUE);

	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 5, 0);
		case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
		default:
			SendKnifeSound(id, 4, 0);
	}

	ClearThink(iEnt);
}

public SkullAxe_PrimaryAttack(id, iEnt, iBteWpn)
{
	SetKnifeDelay(iEnt, c_flDelay[iBteWpn][0], "SkullAxe_Slash");
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	SendWeaponAnim(id, 7);
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0] + 1.0);
}

public SkullAxe_SecondaryAttack(id, iEnt, iBteWpn)
{
	SetKnifeDelay(iEnt, c_flDelay[iBteWpn][1], "SkullAxe_Stab");
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	SendWeaponAnim(id, 2);
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][1], c_flAttackInterval[iBteWpn][1], c_flAttackInterval[iBteWpn][1] + 1.0);
}