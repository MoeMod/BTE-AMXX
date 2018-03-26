native CGauss_Fire(iEnt, Float:vecSrc[3], Float:vecDir[3], Float:flDamage, bPrimary, bAccuracyShoot);
native UTIL_ScreenFade(pEntity, Float:color[3], Float:fadeTime, Float:holdTime, alpha, flags, msgid);

// pev->fuser1 = m_flStartCharge
// pev->fuser2 = m_flNextAmmoBurn
// pev->fuser3 = m_flAmmoStartCharge
// pev->fuser4 = m_flPlayerAftershock
// pev->iuser1 = m_fInAttack
// pev->iuser2 = m_fPrimaryFire

public CGauss_ItemPostFrame(id, iEnt, iClip, iBteWpn)
{
	new bLeft = ATTACKDOWN(id), bRight = SECATTACKDOWN(id);

	if (bRight)
	{
		//set_pev(id, pev_button, pev(id, pev_button) & ~IN_ATTACK2);
		if (get_pdata_float(iEnt, m_flNextSecondaryAttack) <= 0.0)
		{
			if (pev(id, pev_waterlevel) == 3)
			{
				if (pev(iEnt, pev_iuser1) != 0)
				{
					emit_sound(id, CHAN_WEAPON, "weapons/electro4.wav", 1.0, ATTN_NORM, 0, 80 + random_num(0,0x3f));
					SendWeaponAnim(id, c_iIdleAnim[iBteWpn][0]);
					set_pev(iEnt, pev_iuser1, 0);
				}
				else
				{
					PlayEmptySound(id);
				}

				set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.5);
				set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.5);

				return;
			}

			if (pev(iEnt, pev_iuser1) == 0)
			{
				if (iClip <= 0)
				{
					PlayEmptySound(id);
					set_pdata_float(id, m_flNextAttack, 0.5);
					return;
				}

				set_pev(iEnt, pev_iuser2, FALSE);

				AddWeaponClip(iEnt, -1);
				set_pev(iEnt, pev_fuser2, get_gametime());

				set_pdata_int(id, m_iWeaponVolume, 256);

				SendWeaponAnim(id, 3);	// spin up
				set_pev(iEnt, pev_iuser1, 1);
				set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.5);
				set_pev(iEnt, pev_fuser1, get_gametime());
				set_pev(iEnt, pev_fuser3, get_gametime() + c_flDoubleChange[iBteWpn][0]);

				PLAYBACK_EVENT_FULL( FEV_GLOBAL, id, m_usGaussSpin, 0.0, g_vecZero, g_vecZero, 0.0, 0.0, 110, 0, FALSE, FALSE);

			}
			else if (pev(iEnt, pev_iuser1) == 1)
			{
				if (get_pdata_float(iEnt, m_flTimeWeaponIdle) < 0.0)
				{
					SendWeaponAnim(id, 4);
					set_pev(iEnt, pev_iuser1, 2);
				}
			}
			else
			{
				if (get_gametime() >= varf(iEnt, pev_fuser2) && varf(iEnt, pev_fuser2) != 1000.0 )
				{
					AddWeaponClip(iEnt, -1);
					set_pev(iEnt, pev_fuser2, get_gametime() + 0.1);
				}

				if (GetWeaponClip(iEnt) <= 0)
				{
					CGauss_StartFire(id, iEnt, iBteWpn);
					set_pev(iEnt, pev_iuser1, 0);
					set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.0);
					set_pdata_float(id, m_flNextAttack, 1.0);
				}

				if (get_gametime() >= varf(iEnt, pev_fuser3))
				{
					set_pev(iEnt, pev_fuser2, 1000.0);
				}

				new pitch = floatround(( get_gametime() - varf(iEnt, pev_fuser1) ) * ( 150.0 / c_flDoubleChange[iBteWpn][0] ) + 100);
				if (pitch > 250)
					pitch = 250;

				PLAYBACK_EVENT_FULL( FEV_GLOBAL, id, m_usGaussSpin, 0.0, g_vecZero, g_vecZero, 0.0, 0.0, pitch, 0, TRUE, 0);

				set_pdata_int(id, m_iWeaponVolume, 256);

				if (varf(iEnt, pev_fuser1) < get_gametime() - 10.0)
				{
					emit_sound(id, CHAN_WEAPON, "weapons/electro4.wav", 1.0, ATTN_NORM, 0, 80 + random_num(0,0x3f));
					emit_sound(id, CHAN_ITEM, "weapons/electro6.wav", 1.0, ATTN_NORM, 0, 75 + random_num(0,0x3f));

					set_pev(iEnt, pev_iuser1, 0);
					set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.0);
					set_pdata_float(id, m_flNextAttack, 1.0);

					ExecuteHamB(Ham_TakeDamage, id, 0, 0, 50.0, DMG_SHOCK);
					UTIL_ScreenFade(id, Float:{255.0, 128.0, 0.0}, 2.0, 0.5, 128, 0/* FFADE_IN */, gmsgFade);
				
					PLAYBACK_EVENT_FULL( FEV_RELIABLE | FEV_GLOBAL, id, m_usGaussFire, 0.01, g_vecZero, g_vecZero, 0.0, 0.0, 0, 0, 0, 1 );
					SendWeaponAnim(id, c_iIdleAnim[iBteWpn][0]);

					return;
				}
			}
		}
	}
	else if (bLeft)
	{
		//set_pev(id, pev_button, pev(id, pev_button) & ~IN_ATTACK);
		if (get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0)
		{
			if (pev(id, pev_waterlevel) == 3)
			{
				PlayEmptySound(id);
				set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.15);
				set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.15);
				return;
			}

			if (iClip < 2)
			{
				PlayEmptySound(id);
				set_pdata_float(id, m_flNextAttack, 0.5);
				return;
			}

			set_pdata_int(id, m_iWeaponVolume, 450);
			set_pev(iEnt, pev_iuser2, TRUE);


			AddWeaponClip(iEnt, -2);

			CGauss_StartFire(id, iEnt, iBteWpn);

			set_pev(iEnt, pev_iuser1, 0);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.0);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.2);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.2);
			set_pdata_float(id, m_flNextAttack, 0.2);
		}
	}
}

public CGauss_WeaponIdle(id, iEnt, iBteWpn)
{
	if (ATTACKDOWN(id) || SECATTACKDOWN(id))
		return;

	if (varf(iEnt, pev_fuser4) && varf(iEnt, pev_fuser4) < get_gametime())
	{
		switch (random_num(0, 3))
		{
		case 0: emit_sound(id, CHAN_WEAPON, "weapons/electro4.wav", random_float(0.7, 0.8), ATTN_NORM, 0, PITCH_NORM);
		case 1: emit_sound(id, CHAN_WEAPON, "weapons/electro5.wav", random_float(0.7, 0.8), ATTN_NORM, 0, PITCH_NORM);
		case 2: emit_sound(id, CHAN_WEAPON, "weapons/electro6.wav", random_float(0.7, 0.8), ATTN_NORM, 0, PITCH_NORM);
		}
		set_pev(iEnt, pev_fuser4, 0.0);
	}

	if (get_pdata_float(iEnt, m_flTimeWeaponIdle) > 0.0)
		return;

	if (pev(iEnt, pev_iuser1) != 0)
	{
		CGauss_StartFire(id, iEnt, iBteWpn);
		set_pev(iEnt, pev_iuser1, 0);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.0);
	}
	else
	{
		new iIndex;
		new Float:flRand = random_float(0.0, 1.0);
		if (flRand <= 0.5)
		{
			iIndex = 0;
			set_pdata_float(iEnt, m_flTimeWeaponIdle, random_float(10.0, 15.0));
		}
		else if (flRand <= 0.75)
		{
			iIndex = 1;
			set_pdata_float(iEnt, m_flTimeWeaponIdle, random_float(10.0, 15.0));
		}
		else
		{
			iIndex = 2;
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 3.0);
		}

		SendWeaponAnim(id, c_iIdleAnim[iBteWpn][iIndex]);

		return;
		/*
			Valve code :

			return;
			SendWeaponAnim( iAnim );

			What the fuck?
		*/
	}
}

public CGauss_StartFire(id, iEnt, iBteWpn)
{
	static Float:flDamage, Float:flStartCharge, Float:vecSrc[3], Float:vecAiming[3], Float:vecVelocity[3];

	MakePlayerVectors(id);
	GetGunPosition(id, vecSrc);

	pev(iEnt, pev_fuser1, flStartCharge);
	pev(id, pev_velocity, vecVelocity);

	global_get(glb_v_forward, vecAiming);

	if (get_gametime() - flStartCharge > c_flDoubleChange[iBteWpn][0])
	{
		flDamage = 200.0;
	}
	else
	{
		flDamage = 200.0 * ((get_gametime() - flStartCharge) / c_flDoubleChange[iBteWpn][0]);
	}

	if (pev(iEnt, pev_iuser2))
		flDamage = 20.0;

	if (pev(iEnt, pev_iuser1) != 3)
	{
		if (!pev(iEnt, pev_iuser2))
		{
			vecVelocity[0] -= vecAiming[0] * flDamage * 5;
			vecVelocity[1] -= vecAiming[1] * flDamage * 5;
			vecVelocity[2] -= vecAiming[2] * flDamage * 5;

			set_pev(id, pev_velocity, vecVelocity);
		}

		OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	}

	set_pev(iEnt, pev_fuser4, get_gametime() + random_float(0.3, 0.8));

	static Float:vecOrigin[3], Float:vecAngles[3];
	pev(id, pev_origin, vecOrigin);
	pev(id, pev_angles, vecAngles);

	// The main firing event is sent unreliably so it won't be delayed.
	PLAYBACK_EVENT_FULL( FEV_GLOBAL, id, m_usGaussFire, 0.0, vecOrigin, vecAngles, flDamage, 0.0, 0, 0, pev(iEnt, pev_iuser2) ? 1 : 0, 0 );

	// This reliable event is used to stop the spinning sound
	// It's delayed by a fraction of second to make sure it is delayed by 1 frame on the client
	// It's sent reliably anyway, which could lead to other delays

	PLAYBACK_EVENT_FULL( FEV_GLOBAL, id, m_usGaussFire, 0.01, vecOrigin, vecAngles, 0.0, 0.0, 0, 0, 0, 1 );

	CGauss_Fire(iEnt, vecSrc, vecAiming, flDamage, pev(iEnt, pev_iuser2), bte_hms_get_skillstat(id) & (1<<1));
}