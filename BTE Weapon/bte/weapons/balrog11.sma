

public CBalrog11_Precache()
{
	precache_model("sprites/flame_puff01_blue.spr");
}

#define	WEAPON_FIRECLASSNAME		"d_balrog11"

public CBalrog11_ItemPostFrame(id,iEnt,iClip,iBteWpn)
{
	static bitsCurButton;
	bitsCurButton = pev(id,pev_button);

	if (!(bitsCurButton & IN_ATTACK))
		set_pev(iEnt, pev_iuser1, 0);

	if ((bitsCurButton & IN_ATTACK2) && get_pdata_float(iEnt, m_flNextSecondaryAttack) <= 0.0)
	{
		CBalrog11_SecondaryAttack(id, iEnt, iClip, iBteWpn)
		return;
	}
}

public CBalrog11_SecondaryAttack(id, iEnt, iClip, iBteWpn)
{
	//client_print(id, print_chat, "右键")
	new iSpecialAmmo = GetExtraAmmo(iEnt)
	if (!iSpecialAmmo)
	{
		set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1] + 0.1)
		set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][1])
		return
	}
	iSpecialAmmo --
	SetExtraAmmo(id, iEnt, iSpecialAmmo)

	set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH)
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1)

	set_pdata_int(iEnt, m_fInSpecialReload, FALSE)
	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1])
	set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][1])
	set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flShootAnimTime[iBteWpn][1])

	new iSign = random_num(1,998)
	Balrog11BcsFire(id, 0.0, iSign)
	for (new i = 1; i <= 2; i++)
	{
		Balrog11BcsFire(id, i * 6.0, iSign)
		Balrog11BcsFire(id, -i * 6.0, iSign)
	}
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][0], 0, 0, FALSE, TRUE);
}

public Balrog11BcsFire(id, Float:fYaw, iSign)
{
	new Float:vecVAngle[3], Float:vecPunchangle[3], Float:vecTemp[3]
	pev(id, pev_v_angle, vecVAngle)
	pev(id, pev_punchangle, vecPunchangle)
	xs_vec_add(vecVAngle, vecPunchangle, vecTemp)
	engfunc(EngFunc_MakeVectors, vecTemp)

	new Float:vecSrc[3], Float:vecForward[3], Float:vecRight[3], Float:vecUp[3]
	GetGunPosition(id, vecSrc)
	global_get(glb_v_forward, vecForward)
	global_get(glb_v_right, vecRight)
	global_get(glb_v_up, vecUp)

	vecSrc[0] += vecForward[0] * 25.0 - vecUp[0] * 2.0
	vecSrc[1] += vecForward[1] * 25.0 - vecUp[1] * 2.0
	vecSrc[2] += vecForward[2] * 25.0 - vecUp[2] * 2.0

	new Float:sinA = floatsin(fYaw, degrees)
	new Float:cosA = floatcos(fYaw, degrees)
	new Float:vecF2[3], Float:vecR2[3]
	xs_vec_mul_scalar(vecForward, cosA, vecF2)
	xs_vec_mul_scalar(vecRight, sinA, vecR2)
	new Float:vecDir[3]
	xs_vec_add(vecF2, vecR2, vecDir)

	new Float:vecAngle2[3]
	engfunc(EngFunc_VecToAngles, vecDir, vecAngle2)
	CreateSGMissileCannon(id, vecSrc, vecDir, vecAngle2, 1000.0, 0.75, iSign)
}

public CreateSGMissileCannon(id, Float:vecSrc[3], Float:vecDir[3], Float:vecAngles[3], Float:flSpeed, Float:flTimeRemove, iSign)
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if (pev_valid(iEntity))
	{
		set_pev(iEntity, pev_origin, vecSrc)
		engfunc(EngFunc_MakeVectors, vecAngles)
		set_pev(iEntity, pev_angles, vecAngles)
		set_pev(iEntity, pev_classname, WEAPON_FIRECLASSNAME)
		set_pev(iEntity, pev_movetype, MOVETYPE_FLYMISSILE)
		set_pev(iEntity, pev_solid, SOLID_TRIGGER)
		engfunc(EngFunc_SetModel, iEntity, "sprites/flame_puff01_blue.spr")
		engfunc(EngFunc_SetSize, iEntity, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0})
		set_pev(iEntity, pev_nextthink, get_gametime() + 0.01)

		set_pev(iEntity, pev_owner, id)
		set_pev(iEntity, pev_rendermode, kRenderTransAdd)
		set_pev(iEntity, pev_renderfx, kRenderFxNone)
		set_pev(iEntity, pev_renderamt, 100.0)
		set_pev(iEntity, pev_fuser1, get_gametime() + flTimeRemove)
		set_pev(iEntity, pev_frame, 0.0)
		set_pev(iEntity, pev_framerate, random_float(1.0, 30.0))

		new Float:vecVelocity[3]
		xs_vec_mul_scalar(vecDir, flSpeed, vecVelocity)

		set_pev(iEntity, pev_iuser2, 0)
		set_pev(iEntity, pev_iuser3, iSign)
		set_pev(iEntity, pev_vuser1, vecVelocity)	// m_vecVelocity
		set_pev(iEntity, pev_vuser2, vecSrc)		// m_vecOrigin
		set_pev(iEntity, pev_vuser3, vecDir)
		set_pev(iEntity, pev_velocity, vecVelocity)
		set_pev(iEntity, pev_speed, flSpeed)

		new Float:vecAvelocity[3], Float:vecAngles2[3]
		vecAvelocity[2] = random_float(5.0, 50.0)
		vecAngles2[2] = random_float(0.0, 180.0)

		if (random_num(0, 1))
			vecAvelocity[2] *= -1.0

		set_pev(iEntity, pev_avelocity, vecAvelocity)
		set_pev(iEntity, pev_angles, vecAngles2)
		set_pev(iEntity, pev_effects, pev(iEntity, pev_effects) | EF_NODRAW)

		BTE_SetThink(iEntity, "CBalrog11_BCSThink");
		BTE_SetTouch(iEntity, "CBalrog11_BCSTouch");
	}
}

public CBalrog11_BCSThink(iEntity)
{
		set_pev(iEntity, pev_nextthink, get_gametime() + 0.05)
		new Float:flTimeRemove; pev(iEntity, pev_fuser1, flTimeRemove)
		new Float:m_vecVelocity[3]; pev(iEntity, pev_vuser1, m_vecVelocity)
		new Float:m_vecOrigin[3]; pev(iEntity, pev_vuser2, m_vecOrigin)
		new Float:fFrame; pev(iEntity, pev_frame, fFrame)

		fFrame += 1.5
		fFrame = floatmin(21.0, fFrame)
		set_pev(iEntity, pev_frame, fFrame)

		m_vecOrigin[0] = m_vecOrigin[0] + m_vecVelocity[0] * 0.05
		m_vecOrigin[1] = m_vecOrigin[1] + m_vecVelocity[1] * 0.05
		m_vecOrigin[2] = m_vecOrigin[2] + m_vecVelocity[2] * 0.05

		set_pev(iEntity, pev_vuser2, m_vecOrigin)
		set_pev(iEntity, pev_origin, m_vecOrigin)

		if (flTimeRemove < get_gametime())
		{
			SUB_Remove(iEntity, 0.0)
		}
}

public CBalrog11_BCSTouch(iEntity, pOther)
{
	new id = pev(iEntity, pev_owner)
	if (pOther != id)
	{
			if (is_user_connected(pOther))
			{
				if (pev(pOther, pev_takedamage) != DAMAGE_NO)
				{
					if (!(pev(iEntity, pev_iuser2) & (1<<pOther)))
					{
						Attack(iEntity, pOther)
						new i
						while ((i = engfunc(EngFunc_FindEntityByString, i, "classname", WEAPON_FIRECLASSNAME)) && pev(i, pev_iuser3) == pev(iEntity, pev_iuser3))
						{
							if (pev_valid(i))
								set_pev(i, pev_iuser2, pev(i, pev_iuser2) | (1<<pOther))
						}
					}
				}
			}
	}
	if (IsBSPModel(pOther))
	{
		Attack(iEntity, pOther)
		SUB_Remove(iEntity, 0.0)
	}
}

public Attack(iEntity, pOther)
{
	new pOwner = pev(iEntity, pev_owner)
	new Float:vecOrigin2[3], Float:vecEnd[3], Float:vecDirection[3]
	pev(iEntity, pev_vuser3, vecDirection)
	pev(iEntity, pev_origin, vecOrigin2)
	new Float:flDamage = IS_ZBMODE ? 625.0 : 50.0

	new ptr = create_tr2()
	xs_vec_mul_scalar(vecDirection, 42.0, vecDirection)
	xs_vec_add(vecOrigin2, vecDirection, vecEnd)
	engfunc(EngFunc_TraceLine, vecOrigin2, vecEnd, 0, iEntity, ptr)

	set_tr2(ptr, TR_iHitgroup, HIT_CHEST)
	ClearMultiDamage()
	ExecuteHamB(Ham_TraceAttack, pOther, pOwner, flDamage, vecDirection, ptr, DMG_NEVERGIB | DMG_BULLET)
	ApplyMultiDamage(iEntity, pOwner)
	
	free_tr2(ptr)
}
