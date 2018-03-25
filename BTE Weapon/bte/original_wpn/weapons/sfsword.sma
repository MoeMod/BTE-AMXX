public SfSword_PostFrame(id, iEnt, iBteWpn)
{
	if (!pev(iEnt, pev_iuser4))
		return HAM_IGNORED;

	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) > 0.0)
		return HAM_SUPERCEDE;

	new off = pev(iEnt, pev_iuser1);
	new midslash = pev(iEnt, pev_iuser2);
	new stab = pev(iEnt, pev_iuser3);

	new iHitResult;

	if (off)
	{
		iHitResult = KnifeAttack(id, FALSE, c_flDistance[iBteWpn][1], (!IS_ZBMODE) ? 60.0 : 282.0, _);

		if (iHitResult != RESULT_HIT_NONE)
		{
			SendKnifeSound(id, 5, 0);

			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.7);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.7);
		}
		else
		{
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.24);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 1.24);
		}

		set_pev(iEnt, pev_iuser4, FALSE);

		OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	}
	else if (stab == 1)
	{
		iHitResult = KnifeAttack2(id, FALSE, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][1], (!IS_ZBMODE) ? 55.0 : 258.0, _);

		switch (iHitResult)
		{
			case RESULT_HIT_PLAYER : SendKnifeSound(id, 2, 0);
			case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
		}

		set_pdata_float(iEnt, m_flNextPrimaryAttack, (midslash == 2) ? 1.1 : 1.17);
		set_pdata_float(iEnt, m_flNextSecondaryAttack, (midslash == 2) ? 1.1 : 1.17);

		OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

		set_pev(iEnt, pev_iuser4, FALSE);
	}
	else
	{
		switch (stab)
		{
			case 2:
			{
				iHitResult = KnifeAttack2(id, FALSE, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][1], (!IS_ZBMODE) ? 33.0 : 155.0, _);

				switch (iHitResult)
				{
					case RESULT_HIT_PLAYER : SendKnifeSound(id, 2, 0);
					case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
				}

				set_pdata_float(iEnt, m_flNextPrimaryAttack,0.37);
				set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.37);

				set_pev(iEnt, pev_iuser3, 3);

				OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
			}
			case 3:
			{
				iHitResult = KnifeAttack2(id, FALSE, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][1], (!IS_ZBMODE) ? 55.0 : 258.0, _);

				switch (iHitResult)
				{
					case RESULT_HIT_PLAYER : SendKnifeSound(id, 2, 0);
					case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
				}

				set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.83);
				set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.83);

				set_pev(iEnt, pev_iuser3, 0);
				set_pev(iEnt, pev_iuser4, FALSE);

				OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
			}
		}
	}

	return HAM_SUPERCEDE;
}

public SfSword_PrimaryAttack(id, iEnt, iBteWpn)
{
	new off = pev(iEnt, pev_iuser1);
	new midslash = pev(iEnt, pev_iuser2);

	if (off)
	{
		SendWeaponAnim(id, Sfsword_off_slash1);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.26);
		set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.26);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.5);
	}
	else
	{
		if (!pev(iEnt, pev_iuser3))
		{
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.5);
			SendWeaponAnim(id, Sfsword_midslash1 + midslash);

			set_pdata_float(iEnt, m_flNextPrimaryAttack, (midslash == 1) ? 0.36 : 0.26);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, (midslash == 1) ? 0.36 : 0.26);

			midslash += 1;

			if (midslash == 3)
				midslash = 0;

			set_pev(iEnt, pev_iuser2, midslash);
			set_pev(iEnt, pev_iuser3, 1);
		}
		else
		{
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.5, 4);
			SendWeaponAnim(id, Sfsword_stab);

			set_pdata_float(iEnt, m_flNextPrimaryAttack,0.26);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.26);

			set_pev(iEnt, pev_iuser3, 2);
		}
	}

	set_pev(iEnt, pev_iuser4, TRUE);
}


public SfSword_SecondaryAttack(id, iEnt, iBteWpn)
{
	new off = pev(iEnt, pev_iuser1);

	off = 1 - off;
	set_pev(iEnt, pev_iuser1, off);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.5);
	set_pdata_float(iEnt, m_flNextPrimaryAttack,0.5);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.5);
	SendWeaponAnim(id, off ? Sfsword_off : Sfsword_on);

	set_pev(id, pev_weaponmodel2, off ? "models/p_sfsword_off.mdl" : "models/p_sfsword.mdl");
}