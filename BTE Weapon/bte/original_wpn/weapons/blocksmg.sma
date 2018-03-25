public CBlockSMG_Precache()
{
	precache_model("models/v_blocksmg1.mdl");
	precache_model("models/p_blocksmg1.mdl");
	precache_model("models/w_blocksmg1.mdl");
	precache_model("models/v_blocksmg2.mdl");
	precache_model("models/p_blocksmg2.mdl");
	precache_model("models/w_blocksmg2.mdl");
	precache_model("models/v_blockchange.mdl");
	g_sModelIndexBlockShell = precache_model("models/block_shell.mdl");
	precache_model("models/blockmg_missile.mdl");
	precache_sound("weapons/blocksmg2-1.wav");
}

public CBlockSMG_PrimaryAttack_Post(id, iEnt, iClip, iBteWpn)
{
	new iWeaponState = get_pdata_int(iEnt, m_iWeaponState);

	if(iClip)
		iWeaponState ^=WPNSTATE_ELITE_LEFT
	
	set_pdata_int(iEnt, m_iWeaponState, iWeaponState);
}

public CBlockSMG_CheckCurrentStatus(id, iEnt, iBteWpn)
{
	new Float:m_flTimeChange, Float:fCurTime, m_iExtraAmmo, m_iSwitchStatus;
	pev(iEnt, pev_fuser1, m_flTimeChange);

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
			set_pev(id, pev_viewmodel2, "models/v_blocksmg2.mdl");
			set_pev(id, pev_weaponmodel2, "models/p_blocksmg2.mdl");
			set_pdata_string(id, m_szAnimExtention * 4, "m249", -1, 20);
			
			SendWeaponAnim(id, 22 + pev(iEnt, pev_iuser2));
			
			m_iSwitchStatus = STATUS_MODE2;
			m_flTimeChange = 0.0;
			SetCanReload(id, FALSE);
		}
		else if (m_iSwitchStatus == STATUS_CHANGE1)
		{
			set_pev(id, pev_viewmodel2, "models/v_blocksmg1.mdl");
			set_pev(id, pev_weaponmodel2, "models/p_blocksmg1.mdl");
			set_pdata_string(id, m_szAnimExtention * 4, c_szAnimExtention[iBteWpn], -1, 20);
			m_iSwitchStatus = STATUS_MODE1;
			m_flTimeChange = 0.0;
			SendWeaponAnim(id, 9);
			SetCanReload(id, TRUE);
		}

		set_pev(iEnt, pev_fuser1, m_flTimeChange);
		set_pev(iEnt, pev_iuser1, m_iSwitchStatus);

		return;
	}

	CBlockSMG_PostFrame(id, iEnt, iBteWpn, m_iSwitchStatus);

	return;
}

public CBlockSMGRocket_Spawn(pEntity)
{
	set_pev(pEntity, pev_movetype, MOVETYPE_PUSHSTEP);
	set_pev(pEntity, pev_solid, SOLID_BBOX);
	SET_MODEL(pEntity, "models/blockmg_missile.mdl");
	set_pev(pEntity, pev_nextthink, get_gametime()+0.1);
	BTE_SetThink(pEntity, "CBlockSMGRocket_IgniteThink");
	BTE_SetTouch(pEntity, "CBlockSMGRocket_RocketTouch");
}

public CBlockSMGRocket_IgniteThink(this)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(this) // entity
	write_short(g_sModelIndexSmokeBeam) // sprite
	write_byte(5)  // life
	write_byte(1)  // width
	write_byte(0xE0) // r
	write_byte(0xE0);  // g
	write_byte(0xFF);  // b
	write_byte(0xFF); // brightnes
	message_end();
	
	//set_pev(pEntity, pev_nextthink, get_gametime()+0.1);
	set_pev(this, pev_nextthink, get_gametime()+5.0);
	BTE_SetThink(this, "CBlockSMGRocket_FollowThink");
}

public CBlockSMGRocket_FollowThink(this)
{
	SUB_Remove(this, 0.0);
}

public CBlockSMGRocket_RocketTouch(this, pOther)
{
	new iEnt=pev(this, pev_euser1);
	new id = pev(this, pev_owner);
	if(!pev_valid(iEnt) || id != get_pdata_cbase(iEnt, m_pPlayer))
	{
		engfunc(EngFunc_RemoveEntity, this);
		return;
	}
	
	new Float:vecOrigin[3], Float:vecVelocity[3]
	pev(this, pev_origin, vecOrigin)
	pev(this, pev_velocity, vecVelocity)
	
	if (!pOther)
	{
		MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
		WRITE_BYTE(TE_WORLDDECAL);
		WRITE_COORD(vecOrigin[0]);
		WRITE_COORD(vecOrigin[1]);
		WRITE_COORD(vecOrigin[2]);
		WRITE_BYTE(DECAL_SCORCH[random_num(0,1)]);
		MESSAGE_END();
	}
	
	new pEntity = -1, Float:flAdjustedDamage
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, (4.0 * 39.37))) && pev_valid(pEntity))
	{
		if (pev(pEntity, pev_takedamage) == DAMAGE_NO)
			continue;
		if (pEntity == id)
			continue;
		
		new Float:vecOrigin2[3]; pev(pEntity, pev_origin, vecOrigin2)
		new Float:vecDelta[3]; xs_vec_sub(vecOrigin2, vecOrigin, vecDelta)
		
		flAdjustedDamage = IS_ZBMODE ? 1600.0:80.0
		flAdjustedDamage *= 1.0 - (vector_length(vecDelta) / (4.0 * 39.37));
		
		if (flAdjustedDamage < 0.0)
			flAdjustedDamage = 0.0
		if(is_user_alive(pEntity))
			set_pdata_int(pEntity, 75, HIT_CHEST)
			
		ExecuteHamB(Ham_TakeDamage, pEntity, this, id, flAdjustedDamage, DMG_BULLET)
	}
	
	SendExplosion(this, vecOrigin, 0);
	SUB_Remove(this, 0.0);
}

public CBlockSMGRocket_CreateMissile(const classname[], Float:vecSrc[3], Float:vecDirection[3], pevOwner)
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

		CBlockSMGRocket_Spawn(pEntity);

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

		emit_sound(pevOwner, CHAN_WEAPON, "weapons/blocksmg2-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	}

	return pEntity;
}

public CBlockSMG_MissileFire(id, iEnt, iBteWpn, Float:flCycleTime)
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

	new pEntity = CBlockSMGRocket_CreateMissile(classname, vecSrc, vecForward, id);
	set_pev(pEntity, pev_euser1, iEnt);

	set_pdata_float(iEnt, m_flNextPrimaryAttack, flCycleTime);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, flCycleTime);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, flCycleTime);

	if (!(pev(id, pev_flags) & FL_ONGROUND))
	{
		KickBack(iEnt, 5.0, 3.2, 1.5, 0.5, 7.0, 5.7, 2);
	}
	else
	{
		if (!GetVelocity2D(id))
		{
			if (pev(id, pev_flags) & FL_DUCKING)
				KickBack(iEnt, 9.0, 2.1, 1.25, 0.5, 6.0, 5.5, 1);
			else
				KickBack(iEnt, 5.0, 3.2, 1.35, 0.5, 7.0, 10.0, 2);
		}
		else
			KickBack(iEnt, 5.0, 2.25, 1.45, 0.5, 7.0, 10.0, 1);
	}
}

public CBlockSMG_PostFrame(id, iEnt, iBteWpn, iStatus)
{
	static m_iExtraAmmo, iButton;
	m_iExtraAmmo = GetExtraAmmo(iEnt);
	iButton = pev(id, pev_button);
	
	if(iStatus == STATUS_MODE2 && get_pdata_int(iEnt, m_fInSpecialReload))
	{
		set_pdata_int(iEnt, m_fInSpecialReload, 0);
		SetExtraAmmo(id, iEnt, GetExtraAmmo(iEnt) - 9);
		set_pev(iEnt, pev_iuser2, 0);
	}
	
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0)
	{
		if(iStatus == STATUS_MODE2 && pev(iEnt, pev_iuser3) > 0)
		{
			set_pev(iEnt, pev_iuser3, pev(iEnt, pev_iuser3) - 1);
			CBlockSMG_MissileFire(id, iEnt, iBteWpn, 0.15);
			SendWeaponAnim(id, 7 + pev(iEnt, pev_iuser2));
			
			if(!pev(iEnt, pev_iuser3))
			{
				set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.03);
				set_pdata_float(iEnt, m_flNextSecondaryAttack, 1.03);
			}
			
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.0);
		}
		else if (iButton & IN_ATTACK)
		{
			if (iStatus == STATUS_MODE2)
			{
				if (pev(iEnt, pev_iuser2) < 3 && !pev(iEnt, pev_iuser3))
				{
					set_pev(iEnt, pev_iuser2, pev(iEnt, pev_iuser2) + 1);
					set_pev(iEnt, pev_iuser3, 3);
				}
				
				iButton &= ~IN_ATTACK;
				set_pev(id, pev_button, iButton);
				
			}
		}
		else if (iButton & IN_ATTACK2)
		{
			if (iStatus == STATUS_MODE2)
			{
				SendWeaponAnim(id, 18 + pev(iEnt, pev_iuser2));
			}
			else
			{
				SendWeaponAnim(id, 8);
				PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.53, g_vecZero, g_vecZero, 0.0, 0.0, 0, 0, TRUE, FALSE);
			}
			set_pev(iEnt, pev_fuser1, get_gametime() + 1.2);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 2.4 + 2.36);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 2.4 + 2.36);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.4 + 2.36);
			iButton &= ~IN_ATTACK2;
			set_pev(id, pev_button, iButton);
		}
		else if(iStatus == STATUS_MODE2 && pev(iEnt, pev_iuser2)>=3 && GetExtraAmmo(iEnt))
		{
			SendWeaponAnim(id, 13);
			
			set_pdata_int(iEnt, m_fInSpecialReload, 1);
			set_pdata_float(id, m_flNextAttack, 3.33);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 3.1);
		}
	}
}