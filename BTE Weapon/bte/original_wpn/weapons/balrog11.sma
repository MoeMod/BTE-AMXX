public CBalrog11_ItemPostFrame(id,iEnt,iClip,iBteWpn)
{
	static bitsCurButton;
	bitsCurButton = pev(id,pev_button);

	if (!(bitsCurButton & IN_ATTACK))
		set_pev(iEnt, pev_iuser1, 0);

	if ((bitsCurButton & IN_ATTACK2) && get_pdata_float(iEnt, m_flNextSecondaryAttack) <= 0.0)
	{
		CBalrog11_SecondaryAttack(id,iEnt,iClip,iBteWpn)
		return;
	}
}

public CBalrog11_SecondaryAttack(id,iEnt,iClip,iBteWpn)
{
	new iSpecialAmmo = GetExtraAmmo(iEnt);

	if (!iSpecialAmmo)
	{
		//PlayEmptySound(id);
		//set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.2);

		return;
	}

	iSpecialAmmo --;

	SetExtraAmmo(id, iEnt, iSpecialAmmo);
	
	set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1]);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][1]);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flShootAnimTime[iBteWpn][1]);

	set_pdata_int(iEnt, m_fInSpecialReload, FALSE);

	PunchAxis(id, -6.5, 0.0, -10.5);

	RangeAttack(id, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][0], (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1], c_flKnockback[iBteWpn][4], DMG_NEVERGIB | DMG_EXPLOSION, TRUE, FALSE, HITGROUP_CHEST, c_flAngle[iBteWpn][1]);

	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][0], 0, 0, FALSE, TRUE);
}