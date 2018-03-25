public WE_Hammer(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	static iButton, iHitResult, iMode;
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0)
	{
		iButton = pev(id, pev_button);

		if (iButton & IN_ATTACK)
		{
			iMode = g_hammer_stat[id];

			set_pdata_float(id, m_flNextAttack, iMode?c_flDelay[iBteWpn][1]:c_flDelay[iBteWpn][0]);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, iMode?c_flAttackInterval[iBteWpn][1]:c_flAttackInterval[iBteWpn][0]);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, iMode?c_flAttackInterval[iBteWpn][1]:c_flAttackInterval[iBteWpn][0] + 0.1);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, iMode?c_flAttackInterval[iBteWpn][1]:c_flAttackInterval[iBteWpn][0] + 5.0);

			set_pev(iEnt, pev_iuser1, 1);

			OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

			SendWeaponAnim(id, 6);
			if (iMode)
				SendKnifeSound(id, TYPE_STAB, 0);

		}
		else if (iButton & IN_ATTACK2)
		{
			set_pdata_float(id, m_flNextAttack, c_flReload[iBteWpn][0]);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flReload[iBteWpn][0]);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flReload[iBteWpn][0]);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.53);

			SendWeaponAnim(id, 8);

			set_pev(iEnt, pev_iuser4, 1);
		}

		iButton &= ~IN_ATTACK;
		iButton &= ~IN_ATTACK2;
		set_pev(id, pev_button, iButton);
	}
	if (get_pdata_float(id, m_flNextAttack) <= 0.0 && pev(iEnt, pev_iuser1))
	{
		iMode = g_hammer_stat[id];

		if (!iMode)
		{
			iHitResult = KnifeAttack(id, false, c_flDistance[iBteWpn][0], (!IS_ZBMODE) ? c_flDamage[iBteWpn][0] : c_flDamageZB[iBteWpn][0], _);

			switch (iHitResult)
			{
				case RESULT_HIT_PLAYER : SendKnifeSound(id, TYPE_SWING_PLAYER, 0);
				case RESULT_HIT_WORLD : SendKnifeSound(id, TYPE_WORLD, 0);
			}

		}
		else
		{
			if (!c_flAngle[iBteWpn][0])
				iHitResult = KnifeAttack(id, true, c_flDistance[iBteWpn][1], (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1], c_flKnockback[iBteWpn][4]);
			else
				iHitResult = KnifeAttack2(id, true, c_flDistance[iBteWpn][1], c_flAngle[iBteWpn][1], (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1], c_flKnockback[iBteWpn][4]);

			switch (iHitResult)
			{
				case RESULT_HIT_PLAYER : SendKnifeSound(id, TYPE_STAB_PLAYER, 0);
				case RESULT_HIT_WORLD : SendKnifeSound(id, TYPE_WORLD, 0);
			}
		}

		set_pev(iEnt, pev_iuser1, 0);
	}

	if (get_pdata_float(id, m_flNextAttack) <= 0.0 && pev(iEnt, pev_iuser4))
	{
		iMode = g_hammer_stat[id];
		iMode = 1 - iMode;

		set_pev(iEnt, pev_iuser3, iMode);
		set_pev(iEnt, pev_iuser4, 0);

		g_hammer_stat[id] = iMode;

		Pub_Set_MaxSpeed(id, c_flMaxSpeed[iBteWpn][iMode]);

		if (iMode)
			set_pev(id, pev_viewmodel2, "models/v_hammer_2.mdl")
		else
			set_pev(id, pev_viewmodel2, "models/v_hammer.mdl")

	}
}