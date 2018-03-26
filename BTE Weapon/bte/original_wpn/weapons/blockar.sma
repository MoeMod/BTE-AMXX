public CBlockAR_CheckCurrentStatus(id, iEnt, iBteWpn)
{
	new Float:m_flTimeChange, Float:fCurTime, Float:m_flReloadCheck, Float:m_flTimeShootMissile, m_iExtraAmmo, m_iSwitchStatus;
	pev(iEnt, pev_fuser1, m_flTimeChange);
	pev(iEnt, pev_fuser2, m_flReloadCheck);
	pev(iEnt, pev_fuser3, m_flTimeShootMissile);
	global_get(glb_time, fCurTime);
	m_iExtraAmmo = GetExtraAmmo(iEnt);
	m_iSwitchStatus = pev(iEnt, pev_iuser1);
	if (m_flTimeChange != 0.0 && fCurTime > m_flTimeChange)
	{
		if (m_iSwitchStatus == STATUS_MODE1 || m_iSwitchStatus == STATUS_MODE2)
		{
			set_pev(id, pev_viewmodel2, "models/v_blockchange.mdl");
			SendWeaponAnim(id, 0);
			if (m_iSwitchStatus == STATUS_MODE2)
				m_iSwitchStatus = STATUS_CHANGE1;
			else
				m_iSwitchStatus = STATUS_CHANGE2;
			m_flTimeChange = fCurTime + 2.36;
		}
		else if (m_iSwitchStatus == STATUS_CHANGE2)
		{
			set_pev(id, pev_viewmodel2, "models/v_blockar2.mdl");
			set_pev(id, pev_weaponmodel2, "models/p_blockar2.mdl");
			set_pdata_string(id, m_szAnimExtention * 4, "m249", -1, 20);
			if (m_iExtraAmmo <= 0)
				SendWeaponAnim(id, 7);
			else
				SendWeaponAnim(id, 6);
			m_iSwitchStatus = STATUS_MODE2;
			m_flTimeChange = 0.0;
			SetCanReload(id, FALSE);
		}
		else if (m_iSwitchStatus == STATUS_CHANGE1)
		{
			set_pev(id, pev_viewmodel2, "models/v_blockar1.mdl");
			set_pev(id, pev_weaponmodel2, "models/p_blockar1.mdl");
			set_pdata_string(id, m_szAnimExtention * 4, c_szAnimExtention[iBteWpn], -1, 20);
			m_iSwitchStatus = STATUS_MODE1;
			m_flTimeChange = 0.0;
			SendWeaponAnim(id, 5);
			SetCanReload(id, TRUE);
		}

		set_pev(iEnt, pev_fuser1, m_flTimeChange);
		set_pev(iEnt, pev_iuser1, m_iSwitchStatus);

		return;
	}

	if (m_iSwitchStatus == STATUS_MODE2)
	{
		if (m_flReloadCheck > 0.0 && fCurTime > m_flReloadCheck && m_iExtraAmmo > 0)
		{
			SendWeaponAnim(id, 8);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.7);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 1.7);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.7);

			set_pev(iEnt, pev_fuser2, 0.0);
		}
	}

	if (m_flTimeShootMissile > 0.0 && get_gametime() >= m_flTimeShootMissile)
	{
		if (m_iSwitchStatus == STATUS_MODE2)
		{
			CBlockAR_ShootMissile(id, iEnt, iBteWpn);
		}
		set_pev(iEnt, pev_fuser3, 0.0);
	}

	CBlockAR_PostFrame(id, iEnt, iBteWpn, m_iSwitchStatus, m_flReloadCheck);

	return;
}

public CBlockARMissile_Spawn(pEntity)
{
	set_pev(pEntity, pev_movetype, MOVETYPE_FLY);
	set_pev(pEntity, pev_solid, SOLID_BBOX);
	SET_MODEL(pEntity, "models/block_missile.mdl");
	set_pev(pEntity, pev_nextthink, get_gametime()+0.1);
}

public CBlockARMissile_CreateMissile(const classname[], Float:vecSrc[3], Float:vecDirection[3], pevOwner)
{
	new pEntity = CREATE_NAMED_ENTITY("info_target");
	if (pEntity)
	{
		new Float:vecAngles[3];
		engfunc(EngFunc_VecToAngles, vecDirection, vecAngles);
		xs_vec_mul_scalar(vecDirection, 1400.0, vecDirection);

		set_pev(pEntity, pev_classname, classname);
		set_pev(pEntity, pev_origin, vecSrc);
		set_pev(pEntity, pev_angles, vecAngles);
		set_pev(pEntity, pev_owner, pevOwner);
		set_pev(pEntity, pev_velocity, vecDirection);

		DispatchSpawn(pEntity);

		CBlockARMissile_Spawn(pEntity);

		MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY, vecSrc);
		WRITE_BYTE(TE_SPRITE);
		WRITE_COORD(vecSrc[0]);
		WRITE_COORD(vecSrc[1]);
		WRITE_COORD(vecSrc[2]);
		WRITE_SHORT(g_sModelIndexSmokeSmallPuff);
		WRITE_BYTE(20);
		WRITE_BYTE(128);
		MESSAGE_END();

		MESSAGE_BEGIN(MSG_PVS, SVC_TEMPENTITY, vecSrc);
		WRITE_BYTE(TE_BREAKMODEL);
		WRITE_COORD(vecSrc[0]);
		WRITE_COORD(vecSrc[1]);
		WRITE_COORD(vecSrc[2]);
		WRITE_COORD(10.0);
		WRITE_COORD(10.0);
		WRITE_COORD(10.0);
		WRITE_COORD(0.0);
		WRITE_COORD(0.0);
		WRITE_COORD(0.0);
		WRITE_BYTE(10);
		WRITE_SHORT(g_sModelIndexBlockShell);
		WRITE_BYTE(10);
		WRITE_BYTE(30);
		WRITE_BYTE(0x40);
		MESSAGE_END();

		emit_sound(pevOwner, CHAN_WEAPON, "weapons/blockar2-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}

	return pEntity;
}

public CBlockAR_MissileFire(id, iEnt, iBteWpn, Float:flCycleTime)
{
	static Float:vecSrc[3], Float:vecViewAngles[3], Float:vecPunchangle[3], Float:vecForward[3];
	pev(id, pev_v_angle, vecViewAngles);
	pev(id, pev_punchangle, vecPunchangle);
	xs_vec_add(vecViewAngles, vecPunchangle, vecPunchangle);
	engfunc(EngFunc_MakeVectors, vecPunchangle);
	global_get(glb_v_forward, vecForward);
	GetGunPosition(id, vecSrc);

	vecSrc[0] += vecForward[0] * 35.0;
	vecSrc[1] += vecForward[1] * 35.0;
	vecSrc[2] += vecForward[2] * 35.0;

	static classname[32];
	format(classname, charsmax(classname), "d_%s", c_sModel[iBteWpn]);

	new pEntity = CBlockARMissile_CreateMissile(classname, vecSrc, vecForward, id);
	if (pEntity)
	{
		Set_Ent_Data(pEntity, DEF_ENTCLASS, ENTCLASS_BLOCKMISSILE);
		Set_Ent_Data(pEntity, DEF_ENTID, iBteWpn);
	}

	set_pdata_float(iEnt, m_flNextPrimaryAttack, flCycleTime);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, flCycleTime);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, flCycleTime);
	set_pev(iEnt, pev_fuser2, get_gametime() + 1.0);

	if (!(pev(id, pev_flags) & FL_ONGROUND))
	{
		KickBack(iEnt, 13.0, 3.0, 0.85, 0.25, 15.0, 5.6, 1);
	}
	else
	{
		if (!GetVelocity2D(id))
		{
			if (pev(id, pev_flags) & FL_DUCKING)
				KickBack(iEnt, 9.0, 2.1, 0.5, 0.2, 15.0, 5.0, 1);
			else
				KickBack(iEnt, 13.0, 3.2, 0.55, 0.2, 15.0, 10.0, 2);
		}
		else
			KickBack(iEnt, 13.0, 2.25, 0.8, 0.1, 15.0, 5.6, 1);
	}
}

public CBlockAR_ShootMissile(id, iEnt, iBteWpn)
{
	CBlockAR_MissileFire(id, iEnt, iBteWpn, 3.0);
	SendWeaponAnim(id, 3);
	SetExtraAmmo(id, iEnt, GetExtraAmmo(iEnt)-1);
	//set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.0);
	//set_pdata_float(iEnt, m_flNextSecondaryAttack, 1.0);
	//set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.0);
	//set_pev(iEnt, pev_fuser2, get_gametime()+1.0);
}

public CBlockAR_PostFrame(id, iEnt, iBteWpn, iStatus, Float:flReloadCheck)
{
	static m_iExtraAmmo, iButton;
	m_iExtraAmmo = GetExtraAmmo(iEnt);
	iButton = pev(id, pev_button);
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0 && (flReloadCheck <= 0.0 || flReloadCheck < get_gametime()))
	{
		if (iButton & IN_ATTACK)
		{
			if (iStatus == STATUS_MODE2)
			{
				if (m_iExtraAmmo > 0)
				{
					SendWeaponAnim(id, 2);
					set_pev(iEnt, pev_fuser3, get_gametime() + 0.96);
					set_pdata_float(iEnt, m_flNextPrimaryAttack, 3.0);
					set_pdata_float(iEnt, m_flNextSecondaryAttack, 3.0);
					set_pdata_float(iEnt, m_flTimeWeaponIdle, 3.0);
					iButton &= ~IN_ATTACK;
					set_pev(id, pev_button, iButton);
				}
				else
				{
					iButton &= ~IN_ATTACK;
					set_pev(id, pev_button, iButton);
				}
			}
		}
		else if (iButton & IN_ATTACK2)
		{
			if (iStatus == STATUS_MODE2)
			{
				if (m_iExtraAmmo > 0)
					SendWeaponAnim(id, 4);
				else
					SendWeaponAnim(id, 5);
			}
			else
			{
				SendWeaponAnim(id, 4);
				PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.53, g_vecZero, g_vecZero, 0.0, 0.0, 0, 0, TRUE, FALSE);
			}
			set_pev(iEnt, pev_fuser1, get_gametime() + 1.2);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 2.4 + 2.36);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 2.4 + 2.36);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.4 + 2.36);
			iButton &= ~IN_ATTACK2;
			set_pev(id, pev_button, iButton);
		}
	}
}