// Made by Sh@de(Xiaobaibai) & TmNine!~
// pev_iuser1 => iMode
// pev_fuser1 = -> m_flNextRunEnd
// pev_fuser2 = -> m_flNextRunIdle
// pev_iuser2 = -> m_bJustRunStart

enum
{
	ANIM_IDLE_M = 0,
	ANIM_RUN_START_M,
	ANIM_RUN_IDLE_M,
	ANIM_RUN_END_M,
	ANIM_DRAW_M,
	ANIM_SHOOT_M,
	ANIM_RELOAD_M,
	ANIM_SWAB_M,	// 切换成金枪
	ANIM_IDLE_W,
	ANIM_RUN_START_W,
	ANIM_RUN_IDLE_W,
	ANIM_RUN_END_W,
	ANIM_DRAW_W,
	ANIM_SHOOT_W,
	ANIM_RELOAD_W,
	ANIM_SWAB_W	// 切换成蓝枪
}

public CDesperado_Deploy(id, iEntity, iId, iBteWpn)
{
	ResetRunIdle(iEntity)
	set_pdata_float(id, 83, 0.01, 5)
	set_pdata_float(iEntity, 48, 0.17, 4)
}

public CDesperado_Reload(id, iEnt, iClip, iBteWpn)
{
	if (get_pdata_float(iEnt,m_flNextPrimaryAttack) <= 0.0 && get_pdata_float(iEnt,m_flNextSecondaryAttack) <= 0.0)
	{
		new iType = pev(iEnt, pev_iuser1)
		if (DefaultReload(iEnt, c_iClip[iBteWpn], c_iReloadAnim[iBteWpn][iType], c_flReload[iBteWpn][0]))
		{
			ResetRunIdle(iEnt)
			SetAnimation(id, PLAYER_RELOAD)
			set_pdata_float(iEnt, m_flAccuracy, c_flAccuracyDefault[iBteWpn])
		}
	}
}

public CDesperado_WeaponIdle(id, iEntity, iId, iBteWpn)
{
	ExecuteHamB(Ham_Weapon_ResetEmptySound, iEntity)
	new iChangeMode = pev(iEntity, pev_iuser1)
	new m_bJustRunStart = pev(iEntity, pev_iuser2)
	new Float:m_flNextRunIdle	// fuser2
	new Float:m_flNextRunEnd	// fuser1

	pev(iEntity, pev_fuser1, m_flNextRunEnd)
	pev(iEntity, pev_fuser2, m_flNextRunIdle)

	if (get_pdata_float(iEntity, 48, 4) < 0.0)
	{
		if (pev(id, pev_button) & IN_FORWARD)
		{
			if (m_bJustRunStart)
			{
				SendWeaponAnim(id, iChangeMode ? ANIM_RUN_START_W : ANIM_RUN_START_M)
				m_bJustRunStart = 0
				set_pev(iEntity, pev_fuser2, get_gametime())
				set_pdata_float(iEntity, 48, 0.33, 4)
				set_pev(iEntity, pev_iuser2, m_bJustRunStart)
				return HAM_IGNORED
			}
			else if (m_flNextRunIdle <= get_gametime())
			{
				SendWeaponAnim(id, iChangeMode ? ANIM_RUN_IDLE_W : ANIM_RUN_IDLE_M)
				set_pev(iEntity, pev_fuser2, get_gametime() + 0.57)
			}
			set_pev(iEntity, pev_fuser1, get_gametime())
		}
		else
		{
			if (!m_bJustRunStart)
			{
				SendWeaponAnim(id, iChangeMode ? ANIM_RUN_END_W : ANIM_RUN_END_M)
				m_bJustRunStart = 1
				set_pev(iEntity, pev_fuser1, get_gametime())
				set_pdata_float(iEntity, 48, 0.3, 4)
				set_pev(iEntity, pev_iuser2, m_bJustRunStart)
				return HAM_IGNORED
			}
			else if (m_flNextRunEnd <= get_gametime())
			{
				SendWeaponAnim(id, iChangeMode ? ANIM_IDLE_W : ANIM_IDLE_M)
				set_pev(iEntity, pev_fuser1, get_gametime() + 3.0)
			}
			set_pev(iEntity, pev_fuser2, get_gametime())
		}
	}
	return
}

public CDesperado_SecondaryAttack(id, iEntity, iClip, iBteWpn)
{
	if (pev(id, pev_button) & IN_ATTACK)
	return

	new iType = pev(iEntity, pev_iuser1)
	if (iType != 1)
	{
		new iAmmoType = m_rgAmmo_player_Slot0 + get_pdata_int(iEntity, m_iPrimaryAmmoType, 4)
		new iBpAmmo = get_pdata_int(id, iAmmoType)
		new j = min(c_iClip[iBteWpn] - iClip, iBpAmmo)

		set_pdata_int(iEntity, m_iClip, iClip + j, OFFSET_LINUX_WEAPONS)
		set_pdata_int(id, iAmmoType,  iBpAmmo - j)
		set_pdata_int(iEntity, m_fInReload, 0, OFFSET_LINUX_WEAPONS)
		
		SendWeaponAnim(id, 7)
		set_pev(iEntity, pev_iuser1, 1)
		set_pev(id, pev_weaponmodel2, "models/p_desperado_w.mdl")
		set_pdata_float(iEntity, m_flNextPrimaryAttack, 0.17)
		set_pdata_float(iEntity, m_flNextSecondaryAttack, 0.17)
		set_pdata_float(iEntity, m_flTimeWeaponIdle, 0.17)
		ResetRunIdle(iEntity)
		return
	}
	
	new iShotsFired = get_pdata_int(iEntity, m_iShotsFired)
	iShotsFired++
	set_pdata_int(iEntity, m_iShotsFired,  iShotsFired);
	
	// 命中计算
	g_flLastFire[id] = get_pdata_float(iEntity, m_flLastFire)
	g_flAccuracy[id] = get_pdata_float(iEntity, m_flAccuracy)
	g_flAccuracy[id] -= (c_flAccuracy[iBteWpn][0] - (get_gametime() - g_flLastFire[id])) * c_flAccuracy[iBteWpn][1]

	if (g_flAccuracy[id]> c_flAccuracyRange[iBteWpn][0])
	{
		g_flAccuracy[id] = c_flAccuracyRange[iBteWpn][0]
	}
	else if (g_flAccuracy[id]< c_flAccuracyRange[iBteWpn][1])
	{
		g_flAccuracy[id] = c_flAccuracyRange[iBteWpn][1]
	}

	set_pdata_float(iEntity, m_flAccuracy, g_flAccuracy[id])
	set_pdata_float(iEntity, m_flLastFire, get_gametime())
	
	if (iClip <= 0)
	{
		if (get_pdata_int(iEntity, m_fFireOnEmpty))
		{
			//ExecuteHamB(Ham_Weapon_PlayEmptySound, this);
			//set_pdata_float(this, m_flNextSecondaryAttack, 0.2)
		}
		return
	}
	
	iClip--
	set_pdata_int(iEntity, m_iClip, iClip)
	
	new Float:vecVelocity[3]
	pev(id, pev_velocity, vecVelocity)
	vecVelocity[2] = 0.0
	
	if (!(pev(id, pev_flags) & FL_ONGROUND))
		g_flSpread[id] = c_flSpread[iBteWpn][0] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][0]
	else if (vector_length(vecVelocity) > 0.0)
		g_flSpread[id] = c_flSpread[iBteWpn][1] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][1]
	else if (pev(id, pev_flags) & FL_DUCKING)
		g_flSpread[id] = c_flSpread[iBteWpn][2] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][2]
	else
		g_flSpread[id] = c_flSpread[iBteWpn][3] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][3]

	set_pev(id, pev_effects, (pev(id, pev_effects) | EF_MUZZLEFLASH))

	new Float:vecVAngle[3], Float:vecPunchangle[3], Float:vecTemp[3]
	pev(id, pev_v_angle, vecVAngle)
	pev(id, pev_punchangle, vecPunchangle)
	xs_vec_add(vecVAngle, vecPunchangle, vecTemp)
	engfunc(EngFunc_MakeVectors, vecTemp)
	
	set_pdata_int(id, m_iWeaponVolume, BIG_EXPLOSION_VOLUME)
	set_pdata_int(id, m_iWeaponFlash, BRIGHT_GUN_FLASH)
	
	new Float:vecSrc[3]
	new Float:vecDir[3]
	GetGunPosition(id, vecSrc)
	new Float:vecForward[3], Float:vecRight[3]
	global_get(glb_v_forward, vecForward)
	global_get(glb_v_right, vecRight)
	
	// 伤害和穿透和距离修正
	new Float:flDamage = IS_ZBMODE ? c_flDamageZB[iBteWpn][0] : c_flDamage[iBteWpn][0]
	FireBullets3(id, vecSrc, vecForward, g_flSpread[id], c_flDistance[iBteWpn][0], c_iPenetration[iBteWpn][0], c_iBulletType[iBteWpn], floatround(flDamage), c_flRangeModifier[iBteWpn][0], id, true, get_pdata_int(id, random_seed), vecDir)
	PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, vecDir[0], vecDir[1], floatround(vecPunchangle[0] * 100.0), floatround(vecPunchangle[1] * 100.0), FALSE, iType)
	SetAnimation(id, PLAYER_ATTACK1)

	if (iClip <= 0)
	{
		set_pdata_float(iEntity, m_flNextPrimaryAttack, 0.0);
		set_pdata_float(iEntity, m_flNextSecondaryAttack, 0.6);
		set_pdata_float(iEntity, m_flTimeWeaponIdle, 0.6);
	}
	else
	{
		set_pdata_float(iEntity, m_flNextPrimaryAttack, 0.0)
		set_pdata_float(iEntity, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][0])
		set_pdata_float(iEntity, m_flTimeWeaponIdle, 0.6)
	}

	vecPunchangle[0]-=c_flPunchangle[iBteWpn]
	set_pev(id, pev_punchangle, vecPunchangle)
}

public CDesperado_PrimaryAttack(id, this, iClip, iBteWpn)
{
	if (pev(id, pev_button) & IN_ATTACK2)
	return

	new iType = pev(this, pev_iuser1)
	if (iType != 0)
	{
		// 子弹上膛设定
		new iAmmoType = m_rgAmmo_player_Slot0 + get_pdata_int(this, m_iPrimaryAmmoType, 4);
		new iBpAmmo = get_pdata_int(id, iAmmoType);
		new j = min(c_iClip[iBteWpn] - iClip, iBpAmmo);
		set_pdata_int(this, m_iClip, iClip + j, OFFSET_LINUX_WEAPONS)
		set_pdata_int(id, iAmmoType,  iBpAmmo - j)
		set_pdata_int(this, m_fInReload, 0, OFFSET_LINUX_WEAPONS)

		SendWeaponAnim(id, 15)
		set_pev(this, pev_iuser1, 0)
		set_pev(id, pev_weaponmodel2, "models/p_desperado_m.mdl");
		set_pdata_float(this, m_flNextPrimaryAttack, 0.17);
		set_pdata_float(this, m_flNextSecondaryAttack, 0.17);
		set_pdata_float(this, m_flTimeWeaponIdle, 0.17)
		ResetRunIdle(this)
		return
	}

	new iShotsFired = get_pdata_int(this, m_iShotsFired)
	iShotsFired++
	set_pdata_int(this, m_iShotsFired,  iShotsFired);
	
	// 命中计算
	g_flLastFire[id] = get_pdata_float(this, m_flLastFire);
	g_flAccuracy[id] = get_pdata_float(this, m_flAccuracy)
	g_flAccuracy[id] -= (c_flAccuracy[iBteWpn][0] - (get_gametime() - g_flLastFire[id])) * c_flAccuracy[iBteWpn][1];
	if (g_flAccuracy[id]> c_flAccuracyRange[iBteWpn][0])
		g_flAccuracy[id] = c_flAccuracyRange[iBteWpn][0];
	else if (g_flAccuracy[id]< c_flAccuracyRange[iBteWpn][1])
		g_flAccuracy[id] = c_flAccuracyRange[iBteWpn][1];
	set_pdata_float(this, m_flAccuracy, g_flAccuracy[id])
	set_pdata_float(this, m_flLastFire, get_gametime())
	
	if (iClip <= 0)
	{
		if (get_pdata_int(this, m_fFireOnEmpty))
		{
			//ExecuteHamB(Ham_Weapon_PlayEmptySound, this);
			//set_pdata_float(this, m_flNextPrimaryAttack, 0.2);
		}
		return;
	}
	
	iClip--;
	set_pdata_int(this, m_iClip, iClip);
	
	new Float:vecVelocity[3]
	pev(id, pev_velocity, vecVelocity)
	vecVelocity[2] = 0.0
	
	if (!(pev(id, pev_flags) & FL_ONGROUND))
		g_flSpread[id] = c_flSpread[iBteWpn][0] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][0];
	else if (vector_length(vecVelocity) > 0.0)
		g_flSpread[id] = c_flSpread[iBteWpn][1] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][1];
	else if (pev(id, pev_flags) & FL_DUCKING)
		g_flSpread[id] = c_flSpread[iBteWpn][2] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][2];
	else
		g_flSpread[id] = c_flSpread[iBteWpn][3] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][3];
	
	
	set_pev(id, pev_effects, (pev(id, pev_effects) | EF_MUZZLEFLASH));
	
	new Float:vecVAngle[3], Float:vecPunchangle[3], Float:vecTemp[3];
	pev(id, pev_v_angle, vecVAngle)
	pev(id, pev_punchangle, vecPunchangle)
	xs_vec_add(vecVAngle, vecPunchangle, vecTemp);
	engfunc(EngFunc_MakeVectors, vecTemp);
	
	set_pdata_int(id, m_iWeaponVolume, BIG_EXPLOSION_VOLUME);
	set_pdata_int(id, m_iWeaponFlash, BRIGHT_GUN_FLASH);
	
	new Float:vecSrc[3];
	new Float:vecDir[3];
	
	GetGunPosition(id, vecSrc)
	
	new Float:vecForward[3], Float:vecRight[3];
	global_get(glb_v_forward, vecForward);
	global_get(glb_v_right, vecRight);
	
	// 伤害和穿透和距离修正
	new Float:flDamage = IS_ZBMODE ? c_flDamageZB[iBteWpn][0] : c_flDamage[iBteWpn][0]
	

	FireBullets3(id, vecSrc, vecForward, g_flSpread[id], c_flDistance[iBteWpn][0], c_iPenetration[iBteWpn][0], c_iBulletType[iBteWpn], floatround(flDamage), c_flRangeModifier[iBteWpn][0], id, true, get_pdata_int(id, random_seed), vecDir);
	PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, vecDir[0], vecDir[1], floatround(vecPunchangle[0] * 100.0), floatround(vecPunchangle[1] * 100.0), FALSE, iType);
	
	SetAnimation(id, PLAYER_ATTACK1)
	
	if(iClip<=0)
	{
		set_pdata_float(this, m_flNextPrimaryAttack, 0.6);
		set_pdata_float(this, m_flNextSecondaryAttack, 0.0);
		set_pdata_float(this, m_flTimeWeaponIdle, 0.6);
	}
	else
	{
		set_pdata_float(this, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
		set_pdata_float(this, m_flNextSecondaryAttack, 0.0);
		set_pdata_float(this, m_flTimeWeaponIdle, 0.6);
	}
	
	vecPunchangle[0]-=c_flPunchangle[iBteWpn];
	set_pev(id, pev_punchangle, vecPunchangle);
}

public ResetRunIdle(iEntity)
{
	set_pev(iEntity, pev_iuser2, 1)
	set_pev(iEntity, pev_fuser1, get_gametime())
	set_pev(iEntity, pev_fuser2, get_gametime())
}
