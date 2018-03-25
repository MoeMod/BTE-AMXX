public Janus9_Precache()
{
	precache_sound("weapons/janus9_wood1.wav")
	precache_sound("weapons/janus9_wood2.wav")
	precache_sound("weapons/janus9_metal1.wav")
	precache_sound("weapons/janus9_metal2.wav")
	precache_sound("weapons/janus9_stone1.wav")
	precache_sound("weapons/janus9_stone2.wav")
	precache_model("models/p_janus9_b.mdl")
}

public Janus9_PrimaryAttack(id, iEnt, iBteWpn)
{
	new iCharged = !!pev(iEnt, pev_iuser1)
	new iAnim = pev(iEnt, pev_iuser2)
	if(!iCharged) // No Charge
	{
		set_pev(iEnt, pev_iuser1, 1)
		SendWeaponAnim(id, iAnim ? 6:3);
		
	}
	else if(!get_pdata_int(iEnt, m_iWeaponState)) // Charged 1
	{
		set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_M4A1_SILENCED);
		SendWeaponAnim(id, iAnim ? 7:4);
		SetKnifeDelay(iEnt, 6.0, "Janus9_EndSignal");
	}
	else // Signal
	{
		
		SendWeaponAnim(id, iAnim ? 8:5);
	}
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][iCharged], c_flAttackInterval[iBteWpn][iCharged], c_flAttackInterval[iBteWpn][iCharged] + 0.5);
	
	new iHitResult, Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][iCharged] : c_flDamageZB[iBteWpn][iCharged];
	
	
	if (!c_flAngle[iBteWpn][iCharged])
		iHitResult = KnifeAttack(id, TRUE, c_flDistance[iBteWpn][iCharged], flDamage, _);
	else
		iHitResult = KnifeAttack2(id, TRUE, c_flDistance[iBteWpn][iCharged], c_flAngle[iBteWpn][iCharged], flDamage, _);
	
	
	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 2, 0);
		case RESULT_HIT_WORLD : Janus9_MaterialSound(id, iEnt, iBteWpn, c_flDistance[iBteWpn][iCharged]);
		default : SendKnifeSound(id, 1, iCharged);
	}
	
	
	set_pev(iEnt, pev_iuser2, !iAnim);
}

public Janus9_SecondaryAttack(id, iEnt, iBteWpn)
{
	if(!get_pdata_int(iEnt, m_iWeaponState))
		return;
	
	new iAnim = pev(iEnt, pev_iuser2)
	new iHitResult, Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][2] : c_flDamageZB[iBteWpn][2];
	
	UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][2], c_flAttackInterval[iBteWpn][2], c_flAttackInterval[iBteWpn][2] + 0.5);
	
	if (!c_flAngle[iBteWpn][2])
		iHitResult = KnifeAttack(id, TRUE, c_flDistance[iBteWpn][2], flDamage, _);
	else
		iHitResult = KnifeAttack2(id, TRUE, c_flDistance[iBteWpn][2], c_flAngle[iBteWpn][2], flDamage, _);
	
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK2);
	//SendKnifeSound(id, 4, iAnim);
	SendWeaponAnim(id, iAnim ? 12:11);
	
	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 5, iAnim);
		case RESULT_HIT_WORLD : Janus9_MaterialSound(id, iEnt, iBteWpn, c_flDistance[iBteWpn][2]);
		default : SendKnifeSound(id, 1, 1);
	}
	
	set_pev(iEnt, pev_iuser2, !iAnim);
	set_pdata_int(iEnt, m_iWeaponState, 0);
	set_pev(iEnt, pev_iuser1, 0);
	
	set_pev(id, pev_weaponmodel2, "models/p_janus9_b.mdl")
	SetKnifeDelay(iEnt, 1.5, "Janus9_ResetModel");
}

public Janus9_Holster(id, iEnt, iBteWpn)
{
	set_pdata_int(iEnt, m_iWeaponState, 0);
	set_pev(iEnt, pev_iuser1, 0);
	set_pev(iEnt, pev_iuser2, 0);
}

public Janus9_EndSignal(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	ClearThink(iEnt);
	SendWeaponAnim(id, 2);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.3);
	set_pdata_int(iEnt, m_iWeaponState, 0);
	set_pev(iEnt, pev_iuser1, 0);
}

public Janus9_ResetModel(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	ClearThink(iEnt);
	set_pev(id, pev_weaponmodel2, "models/p_janus9_a.mdl")
}

public Janus9_MaterialSound(id, iEnt, iBteWpn, Float:flDistance)
{
	new Float:vecSrc[3], Float:vecEnd[3], Float:v_angle[3], Float:vecForward[3];
	
	GetGunPosition(id, vecSrc);
	
	pev(id, pev_v_angle, v_angle);
	engfunc(EngFunc_MakeVectors, v_angle);
	
	global_get(glb_v_forward, vecForward);
	xs_vec_mul_scalar(vecForward, flDistance, vecForward);
	
	xs_vec_add(vecSrc, vecForward, vecEnd);

	switch (UTIL_TextureHit(UTIL_GetGlobalTrace(), vecSrc, vecEnd))
	{
		case 'W':	// wood
		engfunc(EngFunc_EmitAmbientSound, 0, vecSrc, random_num(0, 1) ? "weapons/janus9_wood1.wav" : "weapons/janus9_wood2.wav", VOL_NORM, ATTN_NORM, 0, 96 + random_num(0, 15));

		case 'G', 'M', 'P':
		engfunc(EngFunc_EmitAmbientSound, 0, vecSrc, random_num(0, 1) ? "weapons/janus9_metal1.wav" : "weapons/janus9_metal2.wav", VOL_NORM, ATTN_NORM, 0, 96 + random_num(0, 15));

		default:
		engfunc(EngFunc_EmitAmbientSound, 0, vecSrc, random_num(0, 1) ? "weapons/janus9_stone1.wav" : "weapons/janus9_stone2.wav", VOL_NORM, ATTN_NORM, 0, 96 + random_num(0, 15));

	}
}