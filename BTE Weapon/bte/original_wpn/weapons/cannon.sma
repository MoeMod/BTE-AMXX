public CCannon_ItemPostFrame(id, iEnt, iClip, iBteWpn)
{
	if (!pev(iEnt, pev_iuser1))
		return;
	set_pev(iEnt, pev_iuser1, 0);
	iClip --;
	set_pdata_int(iEnt, m_iClip, iClip);
	
	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 3.53);

	KnifeAttack2(id, FALSE, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][0], IS_ZBMODE ? c_flDamageZB[iBteWpn][0] : c_flDamage[iBteWpn][0], _, HITGROUP_CHEST, FALSE, DMG_NEVERGIB | DMG_BULLET, TRUE);

	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 0, 0, FALSE, FALSE);
	
	if (pev(id, pev_flags) & FL_ONGROUND)
	{
		if (!GetVelocity2D(id))
		{
			if (pev(id, pev_flags) & FL_DUCKING)
				KickBack(iEnt, 9.0, 2.1, 1.25, 0.5, 15.0, 5.5, 1);
			else
				KickBack(iEnt, 13.0, 3.2, 1.5, 0.5, 15.0, 10.0, 2);
		}
		else    
			KickBack(iEnt, 13.0, 2.25, 1.45, 0.7, 12.0, 10.0, 1);
	}
	else
	{
		KickBack(iEnt, 13.0, 5.0, 1.85, 0.55, 15.0, 5.7, 2);
	}
}

public CCannon_Holster(id, iEnt, iId, iBteWpn)
{
	set_pev(iEnt, pev_iuser1, 0);
}

public CCannon_PrimaryAttack(id, iEnt, iClip, iBteWpn)
{
	if (!iClip)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0] + 0.1);

		return;
	}

	set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	set_pev(iEnt, pev_iuser1, 1);
	
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 0, 0, FALSE, FALSE);
	
	set_pdata_float(id, m_flNextAttack, random_float(0.05, 0.1));
}