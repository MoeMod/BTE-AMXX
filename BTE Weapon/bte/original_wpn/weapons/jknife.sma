public WE_JKnife(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	static iButton, iHitResult, bStab;
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0 && get_pdata_float(iEnt, m_flNextSecondaryAttack) <= 0.0)
	{
		iButton = pev(id, pev_button);

		if (iButton & IN_ATTACK)
		{
			set_pdata_float(id, m_flNextAttack, c_flDelay[iBteWpn][0]);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][0]);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flAttackInterval[iBteWpn][0] + 3.0);

			set_pev(iEnt, pev_iuser1, 1);
			set_pev(iEnt, pev_iuser2, 0);

			OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

			new iAnim = g_anim[id] % 2;
			set_pev(iEnt, pev_iuser4, iAnim);
			
			g_anim[id] += 1;

			SendWeaponAnim(id, 6 + iAnim);
			SendKnifeSound(id, 1, iAnim);

		}
		if (iButton & IN_ATTACK2)
		{
			set_pdata_float(id, m_flNextAttack, c_flDelay[iBteWpn][1]);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1]);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][1]);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flAttackInterval[iBteWpn][1] + 2.0);

			set_pev(iEnt, pev_iuser1, 1);
			set_pev(iEnt, pev_iuser2, 1);

			g_anim[id] += 1;
			new iAnim = g_anim[id] % 2;
			set_pev(iEnt, pev_iuser4, iAnim);

			OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1)
		}

		iButton &= ~IN_ATTACK;
		iButton &= ~IN_ATTACK2;
		set_pev(id, pev_button, iButton);
	}
	if (get_pdata_float(id, m_flNextAttack) <= 0.0 && pev(iEnt, pev_iuser1))
	{
		bStab = pev(iEnt, pev_iuser2) ? TRUE : FALSE;
		if (!bStab)
		{
			iHitResult = KnifeAttack(id, FALSE, c_flDistance[iBteWpn][0], (!IS_ZBMODE) ? c_flDamage[iBteWpn][0] : c_flDamageZB[iBteWpn][0], _);

			switch (iHitResult)
			{
				case RESULT_HIT_PLAYER : SendKnifeSound(id, 2, pev(iEnt, pev_iuser4));
				case RESULT_HIT_WORLD : SendKnifeSound(id, 3, pev(iEnt, pev_iuser4));
			}
			if (iHitResult != RESULT_HIT_NONE)
			{
				set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0] / 1.4);
				set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][0] / 1.4);
			}

		}
		else
		{
			if (!c_flAngle[iBteWpn][0])
				iHitResult = KnifeAttack(id, TRUE, c_flDistance[iBteWpn][1], (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1], _);
			else
				iHitResult = KnifeAttack2(id, TRUE, c_flDistance[iBteWpn][1], c_flAngle[iBteWpn][1], (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1], _);

			switch (iHitResult)
			{
				case RESULT_HIT_PLAYER : SendKnifeSound(id, 5, pev(iEnt, pev_iuser4));
				case RESULT_HIT_WORLD : SendKnifeSound(id, 3, pev(iEnt, pev_iuser4));
				case RESULT_HIT_NONE : SendKnifeSound(id, 4, pev(iEnt, pev_iuser4));
			}
			if (iHitResult != RESULT_HIT_NONE)
			{
				new Float:f;
				pev(iEnt, pev_fuser1, f);
				if (f > get_gametime())
				{
					switch (g_anim[id]%3)
					{
						case 0: SendWeaponAnim(id, 4);
						case 1: SendWeaponAnim(id, 8);
						case 2: SendWeaponAnim(id, 9);
					}
				}
				else
					SendWeaponAnim(id, 4);

				set_pev(iEnt, pev_fuser1, get_gametime() + c_flAttackInterval[iBteWpn][1]);

				set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1]/1.4);
				set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][1]/1.4);
			}
			else
			{
				SendWeaponAnim(id, 5);
			}
		}

		set_pev(iEnt, pev_iuser1, 0);
	}
}