// ASS WE CAN
// pev_fuser1 = -> m_flTimeNextCharge
// pev_iuser1 = -> iMode
// pev_iuser4 = -> iClip2 ???

#define	WEAPON_MAXCLIP2			10
#define	WEAPON_GRENADE_CLASSNAME	"d_sgmissile"
#define	DMG_EXPLOSION			(1<<24)

// Pub_GiveNamedWeapon

public CSgmissile_Precache()
{
	precache_model("models/p_sgmissile_a.mdl")
	precache_model("models/p_sgmissile_b.mdl")
	precache_sound("weapons/sgmissile-1.wav")
	precache_sound("weapons/sgmissile-2.wav")
	precache_sound("weapons/sgmissile_exp.wav")
	precache_sound("weapons/sgmissile_reload.wav")
	precache_model("sprites/ef_sgmissile_line.spr")
	precache_model("sprites/ef_sgmissile.spr")
	g_iSpritesExpp[0] = precache_model("sprites/ef_sgmissile.spr")
	g_iSpritesExpp[1] = precache_model("sprites/ef_sgmissile_line.spr")
}

public CSgmissile_Deploy_Post(id, iEntity, iId, iBteWpn)
{
	ResetChargeTimer(iEntity)
	new m_iChange = pev(iEntity, pev_iuser1)
	if (m_iChange)
	{
		set_pev(id, pev_weaponmodel2, "models/p_sgmissile_b.mdl")
		SendWeaponAnim(id, 6)
	}
	else
	{
		set_pev(id, pev_weaponmodel2, "models/p_sgmissile_a.mdl")
		SendWeaponAnim(id, 2)
	}
}

public InitChargeState(iEntity)
{
	new id = get_pdata_cbase(iEntity, 41, 4)
	new iSpecialAmmo = GetExtraAmmo(iEntity)

	iSpecialAmmo = 0
	SetExtraAmmo(id, iEntity, iSpecialAmmo)

	new Float:m_flTimeNextCharge; pev(iEntity, pev_fuser1, m_flTimeNextCharge)
	m_flTimeNextCharge = -1.0
	set_pev(iEntity, pev_fuser1, get_gametime() + 2.0)
}

public ResetChargeTimer(iEntity)
{
	new id = get_pdata_cbase(iEntity, 41, 4)
	new iSpecialAmmo = GetExtraAmmo(iEntity)

	new Float:m_flTimeNextCharge; pev(iEntity, pev_fuser1, m_flTimeNextCharge)
	if (iSpecialAmmo != WEAPON_MAXCLIP2 && m_flTimeNextCharge <= 0.0)
	{
		set_pev(iEntity, pev_fuser1, get_gametime() + 2.0)
	}
}

public CSgmissile_ItemPostFrame(id, iEntity, iClip, iBteWpn)
{
	new iSpecialAmmo = GetExtraAmmo(iEntity)
	if (!iSpecialAmmo)
	{
		set_pev(iEntity, pev_iuser1, 0)
	}
	else
	{
		set_pev(iEntity, pev_iuser1, 1)
		set_pev(id, pev_weaponmodel2, "models/p_sgmissile_b.mdl")
	}
	if (iSpecialAmmo != WEAPON_MAXCLIP2)
	{
		client_print(id, print_chat, "充能啊")
		new Float:m_flTimeNextCharge; pev(iEntity, pev_fuser1, m_flTimeNextCharge)
		if (m_flTimeNextCharge >= 0.0 && m_flTimeNextCharge <= get_gametime())
		{
			iSpecialAmmo = iSpecialAmmo += (floatround((get_gametime() - m_flTimeNextCharge) / 2.0 + 1.0))
			SetExtraAmmo(id, iEntity, iSpecialAmmo)

			if (iSpecialAmmo >= WEAPON_MAXCLIP2)
			{
				iSpecialAmmo = WEAPON_MAXCLIP2
				SetExtraAmmo(id, iEntity, iSpecialAmmo)
			}

			engfunc(EngFunc_EmitSound, id, CHAN_ITEM, "weapons/sgmissile_reload.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			m_flTimeNextCharge = get_gametime() + 2.0

			if (iSpecialAmmo == WEAPON_MAXCLIP2)
			{
				m_flTimeNextCharge = -1.0
			}
			set_pev(iEntity, pev_fuser1, m_flTimeNextCharge)
			if (iSpecialAmmo == 1)
			{
				if (pev(id, pev_weaponanim) == 0)
				{
					set_pev(iEntity, pev_iuser1, 1)
					SendWeaponAnim(id, 11)
					set_pev(id, pev_weaponmodel2, "models/p_sgmissile_b.mdl")
					set_pdata_float(id, 83, 1.13, 5)
					set_pdata_float(iEntity, 46, 1.13, 4)
					set_pdata_float(iEntity, 47, 1.13, 4)
					set_pdata_float(iEntity, 48, 1.13, 4)
				}
			}
		}
	}
	else if ((pev(id, pev_button) & IN_ATTACK2) && get_pdata_float(id, 83, 5) <= 0.0 && get_pdata_float(iEntity, 47, 4) <= 0.0 && !get_pdata_int(iEntity, 54, 4))
	{
		CSgmissile_SecondaryAttack(id, iEntity, iClip, iBteWpn)
		set_pev(id, pev_button, pev(id, pev_button) & ~IN_ATTACK2)
	}
}

public CSgmissile_PrimaryAttack(id, iEntity, iClip, iBteWpn)
{
	new iSpecialAmmo = GetExtraAmmo(iEntity)

	ResetChargeTimer(iEntity)
	if (pev(id, pev_waterlevel) == 3)
	{
		ExecuteHam(Ham_Weapon_PlayEmptySound, iEntity)
		set_pdata_float(iEntity, 46, 0.15, 4)
		return
	}
	if (iClip <= 0)
	{
		/*if (iBpAmmo > 0)
		{
			ExecuteHamB(Ham_Weapon_Reload, iEntity)
		}
		else
		{
			ExecuteHam(Ham_Weapon_PlayEmptySound, iEntity)
			set_pdata_float(iEntity, 46, 0.2, 4)
		}*/
		ExecuteHam(Ham_Weapon_PlayEmptySound, iEntity)
		set_pdata_float(iEntity, 46, 0.2, 4)
		return
	}

	set_pdata_int(id, 239, 1000)
	set_pdata_int(id, 241, 512)

	iClip --
	set_pdata_int(iEntity, 51, iClip, 4)
	set_pev(id, pev_effects, (pev(id, pev_effects) | EF_MUZZLEFLASH))
    	OrpheuCall(OrpheuGetFunction("SetAnimation", "CBasePlayer"), id, PLAYER_ATTACK1)

	if (iSpecialAmmo > 0)
		SendWeaponAnim(id, random_num(0, 1) ? 7 : 8)
	else
		SendWeaponAnim(id, 3)

	new Float:vecVAngle[3], Float:vecPunchangle[3], Float:vecTemp[3]
	pev(id, pev_v_angle, vecVAngle)
	pev(id, pev_punchangle, vecPunchangle)
	xs_vec_add(vecVAngle, vecPunchangle, vecTemp)
	engfunc(EngFunc_MakeVectors, vecTemp)

	new Float:vecSrc[3]
	GetGunPosition(id, vecSrc)
	new Float:vecForward[3]
	global_get(glb_v_forward, vecForward)

	new Float:flDamage = (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1]
	FireBullets(id, c_cShots[iBteWpn], vecSrc, vecForward, Float:{0.04, 0.04, 0.0}, 3184.0, BULLET_PLAYER_BUCKSHOT, 0, floatround(flDamage), id)

	set_pdata_float(iEntity, 46, c_flAttackInterval[iBteWpn][0], 4)
	set_pdata_float(iEntity, 48, c_flAttackInterval[iBteWpn][0] + 0.7, 4)
	set_pdata_int(iEntity, 55, 0, 4)

	new Float:vecVelocity[3]
	pev(id, pev_velocity, vecVelocity)
	vecVelocity[2] = 0.0

	if (!(pev(id, pev_flags) & FL_ONGROUND))
		vecPunchangle[0] -= random_float(7.0, 10.0)
	else
		vecPunchangle[0] -= random_float(3.0, 4.0)
	set_pev(id, pev_punchangle, vecPunchangle)

	//PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, 0.0715, 0.0715, 0, 0, FALSE, TRUE)
}

public CSgmissile_Reload(id, iEntity, iClip, iBteWpn)
{
	new iAnim
	new iSpecialAmmo = GetExtraAmmo(iEntity)

	if (iSpecialAmmo > 0 && iSpecialAmmo <= WEAPON_MAXCLIP2)
		iAnim = 5
	else
		iAnim = 1

	if (DefaultReload(iEntity, c_iClip[iBteWpn], iAnim, c_flReload[iBteWpn][0]))
	{
		new Float:m_flTimeNextCharge; pev(iEntity, pev_fuser1, m_flTimeNextCharge)
		m_flTimeNextCharge = -1.0
		set_pev(iEntity, pev_fuser1, m_flTimeNextCharge)
		SetAnimation(id, PLAYER_RELOAD)
	}
}

public CSgmissile_SecondaryAttack(id, iEntity, iClip, iBteWpn)
{
	new m_iChange = pev(iEntity, pev_iuser1)

	if (!m_iChange)
	return

	new iSpecialAmmo = GetExtraAmmo(iEntity)
	iSpecialAmmo --
	SetExtraAmmo(id, iEntity, iSpecialAmmo)

	if (iSpecialAmmo <= 0)
	{
		set_pev(id, pev_weaponmodel2, "models/p_sgmissile_a.mdl")
	}

	set_pdata_int(id, 239, 1000)
	set_pdata_int(id, 241, 512)

	set_pev(id, pev_effects, (pev(id, pev_effects) | EF_MUZZLEFLASH))
    	OrpheuCall(OrpheuGetFunction("SetAnimation", "CBasePlayer"), id, PLAYER_ATTACK1)
	SendWeaponAnim(id, iSpecialAmmo ? 9 : 10)
	engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, "weapons/sgmissile-2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	new Float:m_flTimeNextCharge; pev(iEntity, pev_fuser1, m_flTimeNextCharge)
	m_flTimeNextCharge = -1.0
	set_pev(iEntity, pev_fuser1, m_flTimeNextCharge)

	new iSign = random_num(1,998)
	SGMissileBcsFire2(id, 0.0, iSign)
	for (new i = 1; i <= 4; i++)
	{
		SGMissileBcsFire2(id, i * 6.0, iSign)
		SGMissileBcsFire2(id, -i * 6.0, iSign)
	}

	if (iSpecialAmmo)
	{
		set_pdata_float(iEntity, 46, c_flAttackInterval[iBteWpn][0], 4)
		set_pdata_float(iEntity, 47, c_flAttackInterval[iBteWpn][0], 4)
		set_pdata_float(iEntity, 48, 0.87, 4)
	}
	else
	{
		set_pdata_float(iEntity, 46, c_flAttackInterval[iBteWpn][0] + c_flAttackInterval[iBteWpn][0], 4)
		set_pdata_float(iEntity, 47, c_flAttackInterval[iBteWpn][0] + c_flAttackInterval[iBteWpn][0], 4)
		set_pdata_float(iEntity, 48, c_flAttackInterval[iBteWpn][0] + c_flAttackInterval[iBteWpn][0], 4)
	}
}

public CSgmissile_WeaponIdle(id, iEntity, iId, iBteWpn)
{
	new iSpecialAmmo = GetExtraAmmo(iEntity)

	if (get_pdata_float(iEntity, 48) > 0.0)
	return HAM_SUPERCEDE

	set_pdata_float(iEntity, 48, 20.0, 4)
	ResetChargeTimer(iEntity)

	if (iSpecialAmmo > 0 && iSpecialAmmo <= WEAPON_MAXCLIP2)
	{
		SendWeaponAnim(id, 4)
	}
	else
	{
		SendWeaponAnim(id, 0)
	}
	return HAM_SUPERCEDE
}

public SGMissileBcsFire2(id, Float:fYaw, iSign)
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
	CreateSGMissileCannon2(id, vecSrc, vecDir, vecAngle2, 1000.0, 0.75, iSign)
}

// 实体拖尾没人写
public CreateSGMissileCannon2(id, Float:vecSrc[3], Float:vecDir[3], Float:vecAngles[3], Float:flSpeed, Float:flTimeRemove, iSign)
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if (pev_valid(iEntity))
	{
		set_pev(iEntity, pev_origin, vecSrc)
		engfunc(EngFunc_MakeVectors, vecAngles)
		set_pev(iEntity, pev_angles, vecAngles)
		set_pev(iEntity, pev_classname, WEAPON_GRENADE_CLASSNAME)
		set_pev(iEntity, pev_movetype, MOVETYPE_FLYMISSILE)
		set_pev(iEntity, pev_solid, SOLID_TRIGGER)
		engfunc(EngFunc_SetModel, iEntity, "sprites/ef_sgmissile_line.spr")
		engfunc(EngFunc_SetSize, iEntity, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0})
		set_pev(iEntity, pev_nextthink, get_gametime() + 0.01)

		set_pev(iEntity, pev_owner, id)
		set_pev(iEntity, pev_rendermode, kRenderTransAdd)
		set_pev(iEntity, pev_renderfx, kRenderFxNone)
		set_pev(iEntity, pev_renderamt, 90.0)
		set_pev(iEntity, pev_fuser1, get_gametime() + flTimeRemove)
		set_pev(iEntity, pev_framerate, random_float(1.0, 30.0))
		set_pev(iEntity, pev_frame, 0.0)

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

		// FAQ
		BTE_SetThink(iEntity, "CSgmissile_BCSThink")
		BTE_SetTouch(iEntity, "CSgmissile_BCSTouch")
	}
}

public CSgmissile_BCSThink(iEntity)
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

	// 时间到了删除实体
	if (flTimeRemove < get_gametime())
	{
		fFrame -= 1.5
		fFrame = floatmax(50.0, fFrame)
		set_pev(iEntity, pev_frame, fFrame)

		SUB_Remove(iEntity, 0.0)
	}
}

public CSgmissile_BCSTouch(iEntity, pOther)
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
						CSgmissile_Attack(iEntity, pOther)
						MissileExplode(iEntity)

						new i
						while ((i = engfunc(EngFunc_FindEntityByString, i, "classname", "d_balrog11")) && pev(i, pev_iuser3) == pev(iEntity, pev_iuser3))
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
		CSgmissile_Attack(iEntity, pOther)
		MissileExplode(iEntity)
		SUB_Remove(iEntity, 0.0)
	}
}

public CSgmissile_Attack(iEntity, pOther)
{
	new pOwner = pev(iEntity, pev_owner)
	new Float:vecOrigin2[3], Float:vecEnd[3], Float:vecDirection[3]
	pev(iEntity, pev_vuser3, vecDirection)
	pev(iEntity, pev_origin, vecOrigin2)
	new Float:flDamage = IS_ZBMODE ? 1600.0 : 40.0

	new ptr = create_tr2()
	xs_vec_mul_scalar(vecDirection, 42.0, vecDirection)
	xs_vec_add(vecOrigin2, vecDirection, vecEnd)
	engfunc(EngFunc_TraceLine, vecOrigin2, vecEnd, 0, iEntity, ptr)

	ClearMultiDamage()
	ExecuteHamB(Ham_TraceAttack, pOther, pOwner, flDamage, vecDirection, ptr, DMG_NEVERGIB | DMG_BULLET)
	ApplyMultiDamage(iEntity, pOwner)
	
	free_tr2(ptr)
}

public MissileExplode(iEntity)
{
	if (!pev_valid(iEntity))
	return

	new iOwner = pev(iEntity, pev_owner)
	new Float:vecOrigin[3]; pev(iEntity, pev_origin, vecOrigin)

	message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, vecOrigin[0] + 10.0)
	engfunc(EngFunc_WriteCoord, vecOrigin[1] + 10.0)
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + 10.0)
	write_short(g_iSpritesExpp[0])
	write_byte(8)
	write_byte(15)
	write_byte(TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOSOUND | TE_EXPLFLAG_NOPARTICLES)
	message_end()

	message_begin(MSG_BROADCAST ,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, vecOrigin[0] + 10.0)
	engfunc(EngFunc_WriteCoord, vecOrigin[1] + 10.0)
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + 10.0)
	write_short(g_iSpritesExpp[1])
	write_byte(4)
	write_byte(15)
	write_byte(TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOSOUND | TE_EXPLFLAG_NOPARTICLES)
	message_end()

	engfunc(EngFunc_EmitSound, iEntity, CHAN_WEAPON, "weapons/sgmissile_exp.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

	new i = -1
	while((i = engfunc(EngFunc_FindEntityInSphere, i, vecOrigin, 125.0)) > 0)
	{
		if (!pev_valid(i))
		continue

		if (ExecuteHamB(Ham_IsBSPModel, i))
		continue

		new Ptdclassname[32]
		pev(i, pev_classname, Ptdclassname, charsmax(Ptdclassname))
		new Float:iOrigin[3]
		pev(i, pev_origin, iOrigin)
		new Float:range = get_distance_f(vecOrigin, iOrigin)
		new Float:fMaxDistant = 125.0
		new Float:fDamage = 600.0
		new Float:fMaxDamage = floatmax(fDamage*((fMaxDistant-range)/fMaxDistant), 0.0)
		if (pev(i, pev_takedamage) == DAMAGE_NO)
		continue

		if (iOwner == i)
		continue

		if (is_user_alive(i) && pev_valid(i) == 2)
		{
			set_pdata_int(i, 75, 2, 5)
		}
		ExecuteHamB(Ham_TakeDamage, i, iEntity, iOwner, fMaxDamage, DMG_GENERIC)
	}
}



























