public WE_Balrog9(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	static iButton, iCharging;

	if (get_pdata_float(iEnt,m_flNextPrimaryAttack) >= 0.0) return;
	if (!Stock_Can_Attack()) return;

	iButton = pev(id,pev_button);

	if (iButton & IN_ATTACK)
	{
		new iAnim = pev(iEnt, pev_iuser2) % 5;
		SendWeaponAnim(id, 2 + iAnim);
		SendKnifeSound(id, TYPE_SWING, iAnim);
		OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

		set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.23);

		iAnim += 1;
		set_pev(iEnt, pev_iuser2, iAnim);

		new iHitResult = KnifeAttack(id, FALSE, c_flDistance[iBteWpn][0], (!IS_ZBMODE) ? 15.0 : 90.0, c_flKnockback[iBteWpn][0]);

		switch (iHitResult)
		{
			case RESULT_HIT_PLAYER : SendKnifeSound(id, TYPE_SWING_PLAYER, random_num(0, 1));
			case RESULT_HIT_WORLD : SendKnifeSound(id, TYPE_WORLD, 0);
			case RESULT_HIT_NONE : set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.8);
		}

		if (iHitResult != RESULT_HIT_NONE)
		{
			set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);

			if (iAnim % 2)
				PunchAxis(id, 0.8, 0.8);
			else
				PunchAxis(id, -0.8, -0.8);
		}

		iButton &= ~IN_ATTACK;
		iButton &= ~IN_ATTACK2;
		set_pev(id, pev_button, iButton);
	}

	iCharging = pev(iEnt, pev_iuser1);
	new Float:fFinshTime; pev(iEnt, pev_fuser1, fFinshTime);

	if (iButton & IN_ATTACK2)
	{
		if (!iCharging)
		{
			iCharging = 1;
			fFinshTime = get_gametime() + 1.0;
			SendWeaponAnim(id, 7);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.74);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.74);
			set_pev(iEnt, pev_iuser1, iCharging);
			set_pev(iEnt, pev_fuser1, fFinshTime);
		}
		if (get_gametime() > fFinshTime && iCharging != 2)
		{
			iCharging = 2;
			SendWeaponAnim(id, 8);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.33);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.33);
			set_pev(iEnt, pev_iuser1, iCharging);
		}
		iButton &= ~IN_ATTACK;
		iButton &= ~IN_ATTACK2;
		set_pev(id, pev_button, iButton);
	}
	else
	{
		switch (iCharging)
		{
			case 1:
			{
				SendWeaponAnim(id, 11);
				SendKnifeSound(id, TYPE_SWING, 2);
				OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

				set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.63);
				set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.0);

				new iHitResult = KnifeAttack(id, FALSE, c_flDistance[iBteWpn][0], (!IS_ZBMODE) ? 25.0 : 150.0, c_flKnockback[iBteWpn][4]);

				switch (iHitResult)
				{
					case RESULT_HIT_PLAYER : SendKnifeSound(id, TYPE_SWING_PLAYER, random_num(0, 1));
					case RESULT_HIT_WORLD : SendKnifeSound(id, TYPE_WORLD, 0);
				}

			}
			case 2:
			{
				SendWeaponAnim(id, 12);
				SendKnifeSound(id, TYPE_STAB, 0);
				OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

				set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.63);
				set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.0);

				new Float:vecScr[3], Float:vecEnd[3], Float:v_angle[3], Float:vecForward[3];
				GetGunPosition(id, vecScr);

				pev(id, pev_v_angle, v_angle);
				engfunc(EngFunc_MakeVectors, v_angle);

				global_get(glb_v_forward, vecForward);
				xs_vec_mul_scalar(vecForward, 35.0, vecForward);

				xs_vec_add(vecScr, vecForward, vecEnd);

				RadiusDamage(vecEnd, id, id, (!IS_ZBMODE) ? 120.0 : 840.0, c_flDistance[iBteWpn][1], c_flKnockback[iBteWpn][2], DMG_EXPLOSION, TRUE, TRUE);

				engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, WEAPON_EVENT[CSW_KNIFE], 0.0, vecEnd, {0.0, 0.0, 0.0}, 0.0 , 0.0, (1<<3), 0, FALSE, FALSE);
			}
		}
		iCharging = 0;
		set_pev(iEnt, pev_iuser1, iCharging);
	}
}