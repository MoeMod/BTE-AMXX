// [BTE Hamsandwich FORWARD FUNCTION]
#define ITEM_FLAG_SELECTONEMPTY	   1
#define ITEM_FLAG_NOAUTORELOAD		2
#define ITEM_FLAG_NOAUTOSWITCHEMPTY   4
#define ITEM_FLAG_LIMITINWORLD		8
#define ITEM_FLAG_EXHAUSTIBLE		16

#include "bte/weapons/gauss.sma"

public HamF_BloodColor(id)
{
	g_pLastVictim = id;
	return HAM_IGNORED;
}

public HamF_Item_CanDrop(iEnt)
{
	static id;
	id = get_pdata_cbase(iEnt, m_pPlayer);

	if (bte_get_user_zombie(id) == 2)
	{
		SetHamReturnInteger(0);
		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}

public HamF_Item_GetMaxSpeed(iEnt)
{
	static id, iBteWpn;
	id = get_pdata_cbase(iEnt, m_pPlayer);
	iBteWpn = Get_Wpn_Data(iEnt, DEF_ID);

	if (bte_get_user_zombie(id) == 2)
	{
		if (bte_get_user_sex(id) == SEX_MALE)
			SetHamReturnFloat(270.0);
		else
			SetHamReturnFloat(240.0);

		return HAM_SUPERCEDE;
	}

	if (iBteWpn)
	{
		if (get_pdata_int(id, m_iFOV) != 90)
			SetHamReturnFloat(c_flMaxSpeed[iBteWpn][1]);
		else
			SetHamReturnFloat(c_flMaxSpeed[iBteWpn][0]);

		if (c_iSpecial[iBteWpn] == SPECIAL_HAMMER && get_pdata_int(iEnt, m_iWeaponState) & WPNSTATE_HAMMER_STAB)
			SetHamReturnFloat(c_flMaxSpeed[iBteWpn][1]);
		else
			SetHamReturnFloat(c_flMaxSpeed[iBteWpn][0]);

		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}


public HamF_ArmouryEntity_Spawn_Post(iEnt)
{
	new iItem = get_pdata_int(iEnt, m_iItem);
	new iBteWpn;

	switch (iItem)
	{
		case ARMOURY_MP5NAVY: iBteWpn = GetBTEWeaponID("mp5");
		case ARMOURY_TMP: iBteWpn = GetBTEWeaponID("tmp");
		case ARMOURY_P90: iBteWpn = GetBTEWeaponID("p90");
		case ARMOURY_MAC10: iBteWpn = GetBTEWeaponID("mp5");
		case ARMOURY_AK47: iBteWpn = GetBTEWeaponID("ak47");
		case ARMOURY_SG552: iBteWpn = GetBTEWeaponID("sg552");
		case ARMOURY_M4A1: iBteWpn = GetBTEWeaponID("m4a1");
		case ARMOURY_AUG: iBteWpn = GetBTEWeaponID("aug");
		case ARMOURY_SCOUT: iBteWpn = GetBTEWeaponID("scout");
		case ARMOURY_G3SG1: iBteWpn = GetBTEWeaponID("g3sg1");
		case ARMOURY_AWP: iBteWpn = GetBTEWeaponID("awp");
		case ARMOURY_M3: iBteWpn = GetBTEWeaponID("m3");
		case ARMOURY_XM1014: iBteWpn = GetBTEWeaponID("xm1014");
		case ARMOURY_M249: iBteWpn = GetBTEWeaponID("m249");
		case ARMOURY_FLASHBANG:
		{
			engfunc(EngFunc_SetModel, iEnt, "models/w_Grenade_1.mdl");
			set_pev(iEnt, pev_body, 11);

			return HAM_IGNORED;
		}
		case ARMOURY_HEGRENADE: iBteWpn = GetBTEWeaponID("hegrenade");
		case ARMOURY_KEVLAR: return HAM_IGNORED;
		case ARMOURY_ASSAULT: return HAM_IGNORED;
		case ARMOURY_SMOKEGRENADE:
		{
			engfunc(EngFunc_SetModel, iEnt, "models/w_Grenade_1.mdl");
			set_pev(iEnt, pev_body, 10);

			return HAM_IGNORED;
		}
		default: return HAM_IGNORED;
	}

	if (!iBteWpn)
	{
		RemoveEntity(iEnt);
		return HAM_IGNORED;
	}

	engfunc(EngFunc_SetModel, iEnt, c_sModel_W[iBteWpn]);
	set_pev(iEnt, pev_body, c_iModel_W_Sub[iBteWpn]);
	set_pdata_int(iEnt, 25, iBteWpn);

	return HAM_IGNORED;
}

public HamF_ArmouryEntity_Touch(iEnt, id)
{
	if (id < 1 || id > 32)
		return HAM_IGNORED;

	if (get_pdata_bool(id, m_bIsVIP))
		return HAM_SUPERCEDE;

	new iCount = get_pdata_int(iEnt, m_iCount);
	new iItem = get_pdata_int(iEnt, m_iItem);
	new iBteWpn = get_pdata_int(iEnt, 25);

	if (!iBteWpn)
		return HAM_IGNORED;

	if (iCount <= 0)
		return HAM_SUPERCEDE;

	if (get_pdata_cbase(id, m_rgpPlayerItems + c_iSlot[iBteWpn]) >= 1)
		return HAM_SUPERCEDE;

	set_pdata_int(iEnt, m_iCount, iCount - 1);

	Pub_Give_Idwpn(id, iBteWpn, 0, 0);

	switch (iItem)
	{
		case ARMOURY_MP5NAVY: Stock_Config_User_Bpammo(id, CSW_MP5NAVY, 60, TRUE);
		case ARMOURY_TMP: Stock_Config_User_Bpammo(id, CSW_TMP, 60, TRUE);
		case ARMOURY_P90: Stock_Config_User_Bpammo(id, CSW_P90, 50, TRUE);
		case ARMOURY_MAC10: Stock_Config_User_Bpammo(id, CSW_MAC10, 60, TRUE);
		case ARMOURY_AK47: Stock_Config_User_Bpammo(id, CSW_AK47, 60, TRUE);
		case ARMOURY_SG552: Stock_Config_User_Bpammo(id, CSW_SG552, 60, TRUE);
		case ARMOURY_M4A1: Stock_Config_User_Bpammo(id, CSW_M4A1, 60, TRUE);
		case ARMOURY_AUG: Stock_Config_User_Bpammo(id, CSW_AUG, 60, TRUE);
		case ARMOURY_SCOUT: Stock_Config_User_Bpammo(id, CSW_SCOUT, 30, TRUE);
		case ARMOURY_G3SG1: Stock_Config_User_Bpammo(id, CSW_G3SG1, 30, TRUE);
		case ARMOURY_AWP: Stock_Config_User_Bpammo(id, CSW_AWP, 20, TRUE);
		case ARMOURY_M3: Stock_Config_User_Bpammo(id, CSW_M3, 24, TRUE);
		case ARMOURY_XM1014: Stock_Config_User_Bpammo(id, CSW_XM1014, 24, TRUE);
		case ARMOURY_M249: Stock_Config_User_Bpammo(id, CSW_M249, 60, TRUE);
	}

	set_pev(iEnt, pev_effects, pev(iEnt, pev_effects) | EF_NODRAW);

	return HAM_SUPERCEDE;
}

public HamF_InfoTarget_Think(iEnt)
{
	if (!pev_valid(iEnt)) return;
	if (pev(iEnt, pev_flags) & FL_KILLME) return;

	static iEntClass, iBteWpn;
	iEntClass = Get_Ent_Data(iEnt, DEF_ENTCLASS)
	iBteWpn = Get_Ent_Data(iEnt, DEF_ENTID)

	new iShowBeam = get_pdata_int(iEnt, 24);
	if (iShowBeam)
	{
		set_pdata_int(iEnt, 24, 0);

		switch (iShowBeam)
		{
			case 1 :
			{
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_BEAMFOLLOW);
				write_short(iEnt);
				write_short(g_cache_trail);
				write_byte(30);
				write_byte(5);
				write_byte(224);
				write_byte(224);
				write_byte(255);
				write_byte(220);
				message_end();
			}
			case 2 :
			{
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_BEAMFOLLOW);
				write_short(iEnt);
				write_short(g_cache_trail);
				write_byte(7);
				write_byte(6);
				write_byte(224);
				write_byte(224);
				write_byte(255);
				write_byte(220);
				message_end();
			}
			case 3 :
			{
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_BEAMFOLLOW);
				write_short(iEnt);
				write_short(g_cache_trail);
				write_byte(30);
				write_byte(4);
				write_byte(255);
				write_byte(110);
				write_byte(110);
				write_byte(220)
				message_end();

				if (get_pdata_int(iEnt, 25))
				{
					set_pev(iEnt, pev_nextthink, get_gametime() + 1.9);
				}

				return;
			}
			case 4 :
			{
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_BEAMFOLLOW);
				write_short(iEnt);
				write_short(g_cache_trail);
				write_byte(1);
				write_byte(1);
				write_byte(224);
				write_byte(224);
				write_byte(255);
				write_byte(220);
				message_end();
			}
			case 5 :
			{
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_BEAMFOLLOW);
				write_short(iEnt);
				write_short(g_cache_trail);
				write_byte(5);
				write_byte(4);
				write_byte(224);
				write_byte(224);
				write_byte(255);
				write_byte(220);
				message_end();

				set_pev(iEnt, pev_nextthink, get_gametime() + 9999.0);

				return;
			}
			case 6 :
			{
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_BEAMFOLLOW);
				write_short(iEnt);
				write_short(g_cache_trail);
				write_byte(5);
				write_byte(1);
				write_byte(224);
				write_byte(224);
				write_byte(255);
				write_byte(220);
				message_end();
			}
			case 7 :
			{
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_BEAMFOLLOW);
				write_short(iEnt);
				write_short(g_cache_trail);
				write_byte(8);
				write_byte(3);
				write_byte(224);
				write_byte(224);
				write_byte(255);
				write_byte(220);
				message_end();
			}
		}

		if (iEntClass == ENTCLASS_NADE_BOUNCE)
		{
			set_pev(iEnt, pev_nextthink , get_gametime() + 1.4);

			return;
		}

	}

	if (iEntClass == ENTCLASS_BLOCKMISSILE)
	{
		if (pev_valid(iEnt))
		{
			set_pev(iEnt, pev_nextthink, get_gametime()+0.1);
		}
	}

	if (iEntClass == ENTCLASS_BOW)
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW);
		write_short(iEnt);
		write_short(g_cache_trail);
		write_byte(5);
		write_byte(1);
		write_byte(244);
		write_byte(244);
		write_byte(244);
		write_byte(100);
		message_end();
		set_pev(iEnt,pev_nextthink,get_gametime()+10.0)
	}

	if (iEntClass == ENTCLASS_FADEIN)
	{
		static Float:fRenderMount
		pev(iEnt, pev_renderamt, fRenderMount)
		fRenderMount -= 3.5
		
		if (fRenderMount<=0.0)
		{
			set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME);
			return
		}
		set_pev(iEnt,pev_renderamt,fRenderMount)
		set_pev(iEnt,pev_nextthink,get_gametime()+0.01)
	}
	
	if (iEntClass == ENTCLASS_DESTROYER)
	{
		new Float:vecOrigin[3];
		pev(iEnt, pev_origin, vecOrigin);
		new flScale;
		if (IS_ZBMODE)
			flScale = 7;
		else
			flScale = 4;
		engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecOrigin, 0);
		write_byte(TE_EXPLOSION);
		engfunc(EngFunc_WriteCoord, vecOrigin[0]);
		engfunc(EngFunc_WriteCoord, vecOrigin[1]);
		engfunc(EngFunc_WriteCoord, vecOrigin[2]);
		write_short(g_cache_destroyerExplosion);
		write_byte(flScale);
		write_byte(20);
		write_byte(TE_EXPLFLAG_NOSOUND);
		message_end();
		
		emit_sound(iEnt, CHAN_ITEM, "weapons/destroyer_exp.wav", 0.5, ATTN_NORM, 0, PITCH_NORM);
		
		new iBteWpn = Get_Ent_Data(iEnt, DEF_ENTID);
		
		RadiusDamage(vecOrigin, iEnt, pev(iEnt, pev_owner), IS_ZBMODE ? c_flEntityDamageZB[iBteWpn][0] : c_flEntityDamage[iBteWpn][0], IS_ZBMODE ? 4.0 * 39.37 : 39.37, c_flEntityKnockBack[iBteWpn], DMG_EXPLOSION, TRUE, TRUE, FALSE);
		
		RemoveEntity(iEnt);
	}

	if (iEntClass == ENTCLASS_KILLME)
	{
		set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME);
		return
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_FIRECRAKER)
	{
		Pub_Grenade_Explode(iEnt, c_flEntityKnockBack[iBteWpn]);
		set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME);
		return
	}

#if 1
	else if (c_iSpecial[iBteWpn] == SPECIAL_RPG)
	{
		new Float:angles[3];
		pev(iEnt, pev_v_angle, angles);

		new Float:ofs = 1.0;
		pev(iEnt, pev_fuser1, ofs);

		angles[0] += random_float(-ofs, ofs);
		angles[1] += random_float(-ofs, ofs);

		new Float:vforward[3];
		engfunc(EngFunc_MakeVectors, angles);
		global_get(glb_v_forward, vforward);

		new Float:velocity[3];
		xs_vec_mul_scalar(vforward, c_flEntitySpeed[iBteWpn], velocity);

		set_pev(iEnt, pev_velocity, velocity);
		set_pev(iEnt, pev_v_angle, angles);

		set_pev(iEnt, pev_nextthink , get_gametime() + 0.01);

		return;
	}
#endif

	else if (iEntClass == ENTCLASS_NADE_BOUNCE)
	{
		Pub_Grenade_Explode(iEnt, c_flEntityKnockBack[iBteWpn])

		set_pev(iEnt, pev_movetype, MOVETYPE_NONE);
		set_pev(iEnt, pev_model, 0);
		set_pev(iEnt, pev_solid, SOLID_NOT);
		set_pev(iEnt, pev_takedamage, DAMAGE_NO);
		set_pev(iEnt, pev_nextthink, get_gametime() + 0.55);
		Set_Ent_Data(iEnt, DEF_ENTCLASS, ENTCLASS_SMOKE);

		//set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME);;
		return
	}
	else if (iEntClass == ENTCLASS_PETROL)
	{
		new Float:vecOrigin[3];
		pev(iEnt, pev_origin, vecOrigin);

		new pevAttacker = pev(iEnt, pev_owner);

		new Float:flDamage;
		if (!IS_ZBMODE)
			flDamage = c_flEntityDamage[iBteWpn][1];
		else
			flDamage = c_flEntityDamageZB[iBteWpn][1];

		RadiusDamage(vecOrigin, iEnt, pevAttacker, flDamage, c_flEntityRange[iBteWpn][0], 0.0, DMG_EXPLOSION, TRUE, TRUE, FALSE);

		set_pev(iEnt, pev_nextthink, get_gametime() + 0.5);

		new iCheck = pev(iEnt, pev_iuser1);
		set_pev(iEnt, pev_iuser1, iCheck + 1);

		if (iCheck == 12)
			set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME);
	}

	else if (iEntClass == ENTCLASS_SMOKE)
	{
		GrenadeSmoke(iEnt);
	}
	else if (iEntClass == ENTCLASS_BOLT/* || iEntClass == ENTCLASS_DGUN*/)
	{
		EntityVelocityAngle(iEnt);

		set_pev(iEnt,pev_nextthink,get_gametime()+0.03)
	}
	else if (iEntClass == ENTCLASS_DGUN)
	{
		static Float:vAngle[3]
		Stock_Get_Velocity_Angle(iEnt,vAngle)
		set_pev(iEnt,pev_angles,vAngle)
		set_pev(iEnt,pev_nextthink,get_gametime()+0.03)
	}
	else if (iEntClass == ENTCLASS_PLASMA)
	{
		new Float:vecAngle[3];
		pev(iEnt, pev_angles, vecAngle);
		vecAngle[2] += 3.0;
		vecAngle[2] = vecAngle[2] >= 360.0 ? 0.0 : vecAngle[2];
		set_pev(iEnt, pev_angles, vecAngle);

		new Float:fFrame;
		pev(iEnt, pev_frame, fFrame);
		fFrame += 0.1;
		fFrame = fFrame > 1.0 ? 0.0 : fFrame;
		set_pev(iEnt, pev_frame, fFrame);

		set_pev(iEnt, pev_nextthink, get_gametime() + 0.01);
	}

	/*else if (iEntClass == ENTCLASS_TKNIFE)
	{
		new i = pev(iEnt, pev_iuser1);
		if (!i)
		{
			static Float:vAngle[3];
			Stock_Get_Velocity_Angle(iEnt,vAngle);
			set_pev(iEnt,pev_angles,vAngle);
			set_pev(iEnt,pev_nextthink,get_gametime()+0.03);
		}
		else
		{
			set_pev(iEnt, pev_rendermode, kRenderTransAlpha)
			set_pev(iEnt, pev_renderamt, 255.0)

			Set_Ent_Data(iEnt,DEF_ENTCLASS,ENTCLASS_FADEIN);
			set_pev(iEnt,pev_nextthink,get_gametime()+0.01);
		}
	}*/
	/*else if (iEntClass == ENTCLASS_NADE)
	{
		if (Get_Ent_Data(iEnt,DEF_ENTSTAT) && c_iSpecial[iBteWpn] == SPECIAL_AT4CS) // AT4CS
		{
			static iTarget
			iTarget = Get_Ent_Data(iEnt,DEF_ENTSTAT)
			if (iTarget && is_user_alive(iTarget))
			{
				static Float:vOri[3]
				pev(iTarget,pev_origin,vOri)
				Stock_Ent_Move_To(iEnt, vOri, floatround(c_flEntitySpeed[Get_Ent_Data(iEnt,DEF_ENTID)]))
				set_pev(iEnt,pev_nextthink,get_gametime()+0.1)
			}
			else Set_Ent_Data(iEnt,DEF_ENTSTAT,0)
		}
	}*/
	else if (iEntClass == ENTCLASS_BOW)
	{
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW)
		write_short(iEnt)
		write_short(g_cache_trail)
		write_byte(5)
		write_byte(1)
		write_byte(244)
		write_byte(244)
		write_byte(244)
		write_byte(100)
		message_end()
		set_pev(iEnt,pev_nextthink,get_gametime()+10.0)
	}
	else if (iEntClass == ENTCLASS_SPEARGUN)
	{
		switch (Get_Ent_Data(iEnt, DEF_ENTSTAT))
		{
			case 0:
			{
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
				write_byte(TE_BEAMFOLLOW);
				write_short(iEnt);
				write_short(g_cache_trail);
				write_byte(5);
				write_byte(1);
				write_byte(155);
				write_byte(255);
				write_byte(218);
				write_byte(100);
				message_end();
				set_pev(iEnt, pev_nextthink, get_gametime() + 0.9/*c_flAttackInterval[iBteWpn][0] - 0.1*/);

				Set_Ent_Data(iEnt, DEF_ENTSTAT, 1);
			}
			case 1:
			{
				new Float:vecOrigin[3];
				new id = pev(iEnt, pev_owner);
				new aiment = pev(iEnt, pev_aiment);

				pev(aiment?aiment:iEnt, pev_origin, vecOrigin);

				new Float:flDamage;
				if (!IS_ZBMODE)
					flDamage = c_flEntityDamage[iBteWpn][0];
				else
					flDamage = c_flEntityDamageZB[iBteWpn][0];

				SpearRadius(vecOrigin, iEnt, id, flDamage, c_flEntityRange[iBteWpn][0], c_flEntityKnockBack[iBteWpn], DMG_CLUB | DMG_NEVERGIB, FALSE, TRUE, pev(iEnt, pev_iuser1) ? pev(iEnt, pev_iuser1) : -1);
				RemoveEntity(iEnt);

				engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, WEAPON_EVENT[CSW_KNIFE], 0.0, vecOrigin, {0.0, 0.0, 0.0}, 0.0 , 0.0, (1<<4), 0, FALSE, TRUE);

			}
		}
	}

	return
}

public HamF_Think_Grenade(iEnt)
{
	if (!pev_valid(iEnt))
		return HAM_IGNORED;

	new iBteWpn = Get_Wpn_Data(iEnt, DEF_ID);

	if (c_iSpecial[iBteWpn] == SPECIAL_FFF)
	{
		set_pev(iEnt, pev_dmgtime, get_gametime() + 999.0);

		if (!pev(iEnt, pev_iuser1))
			return HAM_IGNORED;


		new Float:vecOrigin[3];
		pev(iEnt, pev_origin, vecOrigin);

		new pevAttacker = pev(iEnt, pev_owner);

		copy(g_szKillWeapon, 31, "fff");
		//RadiusDamage(vecOrigin, iEnt, pevAttacker, flDamage, c_flDistance[iBteWpn][0], 0.0, DMG_EXPLOSION, FALSE, FALSE, FALSE);
		RadiusDamage2(vecOrigin, iEnt, pevAttacker, iBteWpn);
		g_szKillWeapon[0] = 0;

		set_pev(iEnt, pev_nextthink, get_gametime() + 0.25);

		new iCheck = pev(iEnt, pev_iuser1);
		set_pev(iEnt, pev_iuser1, iCheck + 1);

		if (iCheck == 60)
			set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME);

		return HAM_IGNORED;
	}

	static Float:dmgtime;
	pev(iEnt, pev_dmgtime, dmgtime)

	if (dmgtime > get_gametime())
		return HAM_IGNORED;

	iBteWpn = Get_Wpn_Data(iEnt,DEF_ID);

	if (c_sSound[iBteWpn][0] && !Get_Wpn_Data(iEnt, DEF_ENTSTAT))
	{
		engfunc(EngFunc_EmitSound, iEnt, CHAN_WEAPON, c_sSound[iBteWpn], 1.0, ATTN_NORM, 0, PITCH_NORM);
		Set_Wpn_Data(iEnt, DEF_ENTSTAT, 1);
	}

	return HAM_IGNORED;
}

public HamF_Touch_Grenade(iEnt,iTouched)
{
	static iOwner
	iOwner = pev(iEnt,pev_owner)
	if (iOwner == iTouched) return

	if (c_iSpecial[Get_Wpn_Data(iEnt, DEF_ID)] == SPECIAL_HOLYBOMB)
	{
		set_pev(iEnt, pev_dmgtime, 0.1)
	}

	if (c_iSpecial[Get_Wpn_Data(iEnt, DEF_ID)] == SPECIAL_FFF/* && (pev(iEnt, pev_flags) & FL_ONGROUND)*/)
	{
		set_pev(iEnt, pev_dmgtime, get_gametime() + 999.0);
		set_pev(iEnt, pev_movetype, MOVETYPE_NONE);
		set_pev(iEnt, pev_solid, SOLID_NOT);
		set_pev(iEnt, pev_iuser1, 1);
		set_pev(iEnt, pev_nextthink, get_gametime() + 0.01);

		set_pev(iEnt, pev_rendermode, kRenderTransAlpha);
		set_pev(iEnt, pev_renderamt, 0.0);

		engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, iEnt, m_usExplosion, 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0 , 0.0, 6, 0, FALSE, FALSE);

	}

	return
}

#include "bte/BTE_EntityTouch.sma"

public HamF_InfoTarget_Touch(iPtr,iPtd)
{
	if (!pev_valid(iPtr)) return HAM_IGNORED;

	static iClass ,iOwner, iBteWpn
	iClass = Get_Ent_Data(iPtr,DEF_ENTCLASS)
	iBteWpn = Get_Ent_Data(iPtr,DEF_ENTID)
	iOwner = pev(iPtr,pev_owner)

	new Float:vecOrigin[3];
	pev(iPtr, pev_origin, vecOrigin);

	if (engfunc(EngFunc_PointContents, vecOrigin) == CONTENTS_SKY)
	{
		RemoveEntity(iPtr);
		return HAM_IGNORED
	}

	if (iClass == ENTCLASS_BLOCKMISSILE)
	{
		SendExplosion(iPtr, vecOrigin, 0);
		if (!iPtd)
		{
			MESSAGE_BEGIN(MSG_BROADCAST, SVC_TEMPENTITY);
			WRITE_BYTE(TE_WORLDDECAL);
			WRITE_COORD(vecOrigin[0]);
			WRITE_COORD(vecOrigin[1]);
			WRITE_COORD(vecOrigin[2]);
			WRITE_BYTE(DECAL_SCORCH[random_num(0,1)]);
			MESSAGE_END();
		}

		if (pev_valid(iPtd) && pev(iPtd, pev_takedamage) && !CheckTeammate(iOwner, iPtd))
		{
			ExecuteHamB(Ham_TakeDamage, iPtd, iPtr, iOwner, IS_ZBMODE ? c_flEntityDamageZB[iBteWpn][0] : c_flEntityDamage[iBteWpn][0], DMG_BULLET | DMG_NEVERGIB);
			if (IsPlayer(iPtd))
				set_pdata_int(iPtd, 75, HITGROUP_CHEST);
		}

		RadiusDamage(vecOrigin, iPtr, iOwner, IS_ZBMODE ? c_flEntityDamageZB[iBteWpn][1] : c_flEntityDamage[iBteWpn][1], c_flEntityRange[iBteWpn][0], c_flEntityKnockBack[iBteWpn], DMG_BULLET | DMG_NEVERGIB, FALSE, TRUE);

		if (pev_valid(iPtr))
			RemoveEntity(iPtr);

		return HAM_IGNORED;
	}

	if (iClass == ENTCLASS_BOW)
	{
		set_pev(iPtr, pev_solid, SOLID_NOT);

		new Float:vOrigin[3], Float:vecEntity[3];
		pev(iPtr,pev_origin,vOrigin);

		if (pev_valid(iPtd))
			pev(iPtd, pev_origin, vecEntity);
		
		new iOwner = pev(iPtr, pev_owner);

		if (iPtd == iOwner)
			return HAM_IGNORED;
			

		if (!iPtd)
		{
			engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vOrigin, 0);
			write_byte(TE_GUNSHOTDECAL);
			engfunc(EngFunc_WriteCoord,vOrigin[0]);
			engfunc(EngFunc_WriteCoord,vOrigin[1]);
			engfunc(EngFunc_WriteCoord,vOrigin[2]);
			write_short(0);
			write_byte(DECAL_SHOT[random_num(0,4)]);
			message_end();

			engfunc(EngFunc_EmitSound, iPtr, CHAN_AUTO, "weapons/xbow_hit1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			set_pev(iPtr, pev_animtime, get_gametime())
			set_pev(iPtr, pev_framerate, 1.0)
			set_pev(iPtr, pev_sequence, 0)
				
			Set_Ent_Data(iPtr, DEF_ENTCLASS, ENTCLASS_FADEIN);
			set_pev(iPtr, pev_nextthink, get_gametime()+3.5);
			set_pev(iPtr, pev_rendermode, kRenderTransAlpha);
			set_pev(iPtr, pev_renderamt, 255.0);
			set_pev(iPtr, pev_movetype, MOVETYPE_NONE);

			return HAM_IGNORED;
		}
		else
			set_pev(iPtr, pev_flags, pev(iPtr, pev_flags) | FL_KILLME);

		new Float:fDamage;
		pev(iPtr, pev_fuser2, fDamage);
		
		new trRes,Float:vecStart[3],Float:Forw[3],Float:vecEnd[3],Float:angle[3],Float:direction[3];		
		static Float:flFraction, Float:vecEndPos[3];
		pev(iPtr, pev_origin, vecStart);
			
		Stock_Get_Velocity_Angle(iPtr, angle);
		engfunc(EngFunc_MakeVectors, angle);
		global_get(glb_v_forward,direction);
		xs_vec_mul_scalar(direction,20.0,Forw);
		xs_vec_add(vecStart, Forw, vecEnd);
		xs_vec_mul_scalar(direction,-5.0,Forw);
		xs_vec_add(vecStart, Forw, vecStart);
		
		engfunc(EngFunc_TraceLine, vecStart, vecEnd, 0, iOwner, trRes);
		get_tr2(trRes, TR_flFraction, flFraction);
		get_tr2(trRes, TR_vecEndPos, vecEndPos);
		
		Set_Ent_Data(iPtr, DEF_ENTCLASS, ENTCLASS_FADEIN);
		set_pev(iPtr, pev_nextthink, get_gametime()+6.0);
		set_pev(iPtr, pev_rendermode, kRenderTransAlpha);
		set_pev(iPtr, pev_renderamt, 255.0);
		
		//UTIL_BubbleTrail(vecStart, vecEndPos, floatround((8196.0 * flFraction) / 64.0));

		if (pev_valid(iPtd) == 2) 
		{
			pev(iPtr, pev_velocity, direction);
			xs_vec_normalize(direction, direction);

			new tr = UTIL_GetGlobalTrace();

			ClearMultiDamage();
			ExecuteHamB(Ham_TraceAttack, iPtd, iOwner, fDamage, direction, tr, DMG_BULLET | DMG_NEVERGIB);
			ApplyMultiDamage(iOwner, iOwner);

			if (IsPlayer(iPtd))
			{
				if (pev(iPtr, pev_iuser3))
					FakeKnockBack(iPtd, vOrigin, vecEntity, c_flKnockback[iBteWpn][1]);
				else
					FakeKnockBack(iPtd, vOrigin, vecEntity, c_flKnockback[iBteWpn][0]);

				set_pev(iPtr, pev_renderamt, 0.0);
			}

			engfunc(EngFunc_EmitSound, iPtr, CHAN_AUTO, "weapons/xbow_hitbod1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
		}

		//set_pev(iPtr, pev_flags, pev(iPtr, pev_flags) | FL_KILLME);
		if (pev(iPtr, pev_iuser4) <= 0)
		{
			set_pev(iPtr, pev_flags, pev(iPtr, pev_flags) | FL_KILLME);
			return HAM_IGNORED;
		}

		set_pev(iPtr, pev_movetype, MOVETYPE_NONE);
		return HAM_IGNORED;
	}

	if (iClass  == ENTCLASS_NADE)
	{
		if (c_iSpecial[iBteWpn] == SPECIAL_FIRECRAKER && get_pdata_int(iPtr, 25))
		{
			TouchFirecraker(iPtr);

			return HAM_IGNORED;
		}

		Pub_Grenade_Explode(iPtr, c_flEntityKnockBack[iBteWpn]);

		set_pev(iPtr, pev_movetype, MOVETYPE_NONE);
		set_pev(iPtr, pev_model, 0);
		set_pev(iPtr, pev_solid, SOLID_NOT);
		set_pev(iPtr, pev_takedamage, DAMAGE_NO);
		set_pev(iPtr, pev_effects, pev(iPtr, pev_effects) | EF_NODRAW);

		if (c_iSpecial[iBteWpn] != SPECIAL_FIRECRAKER)
		{
			set_pev(iPtr, pev_nextthink, get_gametime() + 0.55);
			Set_Ent_Data(iPtr, DEF_ENTCLASS, ENTCLASS_SMOKE);
		}
		else
		{
			RemoveEntity(iPtr);
		}

		return HAM_IGNORED
	}
	else if (iClass == ENTCLASS_NADE_BOUNCE)
	{
		new Float:vecVelocity[3];
		pev(iPtr,pev_velocity,vecVelocity);
		/*if (pev(iPtr,pev_flags) & FL_ONGROUND)
		{*/
		xs_vec_mul_scalar(vecVelocity,0.25,vecVelocity);
		vecVelocity[2] *= 0.5;
		//}
		set_pev(iPtr,pev_velocity,vecVelocity);
	}
	else if (iClass == ENTCLASS_PETROL)
	{
		TouchPetrolBoom(iOwner, iPtr, iPtd, iBteWpn);
	}
	else if (iClass == ENTCLASS_PLASMA)
	{
		if (iPtd == iOwner) return HAM_IGNORED;

		TouchPlasmaBall(iOwner, iPtr, iPtd, iBteWpn);
	}

	else if (iClass == ENTCLASS_BOLT)
	{
		if (iPtd == iOwner) return HAM_IGNORED;

		TouchBolt(iOwner, iPtr, iPtd, iBteWpn);
	}

	else if (iClass == ENTCLASS_DGUN)
	{
		new iOwner = pev(iPtr, pev_owner);
		new iPenetration = pev(iPtr, pev_iuser2);
		if (iPtd == iOwner) return HAM_IGNORED;

		new Float:fCurrentDamage, Float:fDamageModify;
		pev(iPtr, pev_fuser1, fDamageModify);

		new Float:vecAngle[3], Float:vecOrigin[3], Float:vecVelocity[3];
		pev(iPtr, pev_velocity, vecVelocity);
		pev(iPtr, pev_angles, vecAngle);
		pev(iPtr, pev_origin, vecOrigin);
		if (!iPtd)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_GUNSHOTDECAL);
			engfunc(EngFunc_WriteCoord, vecOrigin[0]);
			engfunc(EngFunc_WriteCoord, vecOrigin[1]);
			engfunc(EngFunc_WriteCoord, vecOrigin[2]);
			write_short(0);
			write_byte(DECAL_SHOT[random_num(0,4)]);
			message_end();

			fDamageModify *= 0.3;
		}

		if (iPtd == pev(iPtr, pev_iuser1) || iPenetration == 0)
		{
			RemoveEntity(iPtr);
			return HAM_IGNORED;
		}

		fCurrentDamage = fDamageModify * 107.0;

		EntityTouchDamage(iPtr, iOwner, fCurrentDamage);
		RemoveEntity(iPtr);

#if 0
		new Float:vecDirection[3], Float:vecForward[3], Float:vecStart[3], Float:vecEnd[3];

		xs_vec_normalize(vecVelocity, vecDirection);
		xs_vec_mul_scalar(vecDirection, 40.0, vecForward);
		xs_vec_add(vecOrigin, vecForward, vecStart);
		xs_vec_mul_scalar(vecDirection, 400.0, vecForward);
		xs_vec_add(vecOrigin, vecForward, vecEnd);

		new tr = create_tr2();

		engfunc(EngFunc_TraceLine, vecStart, vecEnd, dont_ignore_monsters, iPtr, tr);

		new Float:flFraction;
		get_tr2(tr, TR_flFraction, flFraction);
		PRINT("%f", flFraction)
#else
		new Float:vecDirection[3], Float:vecForward[3];

		xs_vec_normalize(vecVelocity, vecDirection);
		xs_vec_mul_scalar(vecDirection, 40.0, vecForward);
		xs_vec_add(vecOrigin, vecForward, vecOrigin);

		if (engfunc(EngFunc_PointContents, vecOrigin) == CONTENTS_SOLID)
			return HAM_IGNORED

		if (xs_vec_len(vecVelocity) < 100.0)
			return HAM_IGNORED
#endif

		//return HAM_IGNORED

		new iArrow = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
		set_pev(iArrow, pev_classname, "d_drillgun");
		engfunc(EngFunc_SetModel, iArrow, "models/drillgun_nail.mdl");
		engfunc(EngFunc_SetSize, iArrow, {-0.1, -0.1, -0.1}, {0.1, 0.1, 0.1});

		set_pev(iArrow, pev_origin, vecOrigin);
		set_pev(iArrow, pev_movetype, MOVETYPE_PUSHSTEP);

		set_pev(iArrow, pev_solid, SOLID_BBOX);
		set_pev(iArrow, pev_owner, iOwner);
		set_pev(iArrow, pev_gravity, DGUN_GRAVITY);
		set_pev(iArrow, pev_velocity, vecVelocity);
		set_pev(iArrow, pev_angles, vecAngle);
		Set_Ent_Data(iArrow, DEF_ENTID, iBteWpn);
		Set_Ent_Data(iArrow, DEF_ENTCLASS, ENTCLASS_DGUN);
		set_pev(iArrow, pev_nextthink, get_gametime()+0.02);

		set_pev(iArrow, pev_iuser1, iPtd);
		set_pev(iArrow, pev_iuser2, iPenetration - 1);

		set_pev(iArrow, pev_fuser1, fDamageModify * 0.9);

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW);
		write_short(iArrow);
		write_short(g_cache_trail);
		write_byte(1);
		write_byte(1);
		write_byte(244);
		write_byte(244);
		write_byte(244);
		write_byte(100);
		message_end();

		return HAM_IGNORED;
	}
	else if (iClass == ENTCLASS_TKNIFE)
	{
		if (!iPtd)
		{
			new Float:vOrigin[3];
			pev(iPtr,pev_origin,vOrigin);

			engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vOrigin, 0);
			write_byte(TE_GUNSHOTDECAL);
			engfunc(EngFunc_WriteCoord,vOrigin[0]);
			engfunc(EngFunc_WriteCoord,vOrigin[1]);
			engfunc(EngFunc_WriteCoord,vOrigin[2]);
			write_short(0);
			write_byte(DECAL_SHOT[random_num(0,4)]);
			message_end();

			new iTtextureType = EntityTouchTraceTexture(iPtr);

			new sound[32];
			if (iTtextureType == 'M' || iTtextureType == 'V' || iTtextureType == 'P')
			{
				switch (random_num(0,2))
				{
					case 0 : format(sound, charsmax(sound), "weapons/tknife_metal1.wav");
					case 1 : format(sound, charsmax(sound), "weapons/tknife_metal2.wav");
					case 2 : format(sound, charsmax(sound), "weapons/tknife_metal3.wav");
				}
			}
			else if (iTtextureType == 'W')
			{
				switch (random_num(0,1))
				{
					case 0 : format(sound, charsmax(sound), "weapons/tknife_wood1.wav");
					case 1 : format(sound, charsmax(sound), "weapons/tknife_wood2.wav");
				}
			}
			else
			{
				switch (random_num(0,1))
				{
					case 0 : format(sound, charsmax(sound), "weapons/tknife_stone1.wav");
					case 1 : format(sound, charsmax(sound), "weapons/tknife_stone2.wav");
				}
			}
			engfunc(EngFunc_EmitSound, iPtr, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}

		if (Get_Ent_Data(iPtd,DEF_ENTCLASS) == ENTCLASS_TKNIFE)
			return HAM_IGNORED;

		if (pev(iPtr, pev_iuser1))
			return HAM_IGNORED;

		new Float:origin[3];
		pev(iPtr, pev_origin, origin);

		if (engfunc(EngFunc_PointContents, origin) == CONTENTS_SKY)
		{
			set_pev(iPtr, pev_flags, pev(iPtr, pev_flags) | FL_KILLME);
			return HAM_IGNORED;
		}

		new iOwner  = pev(iPtr, pev_owner);

		if (iPtd == iOwner) return HAM_IGNORED;

		if (EntityTouchDamage(iPtr, iOwner, c_flDamage[iBteWpn][0]))
		{
			engfunc(EngFunc_EmitSound, iPtr, CHAN_ITEM, "weapons/axe_hit1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
		else
		{
			new sound[32];
			switch (random_num(0,2))
			{
				case 0 : format(sound, charsmax(sound), "weapons/tknife_metal1.wav");
				case 1 : format(sound, charsmax(sound), "weapons/tknife_metal2.wav");
				case 2 : format(sound, charsmax(sound), "weapons/tknife_metal3.wav");
			}
			engfunc(EngFunc_EmitSound, iPtr, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}

		RemoveEntity(iPtr); // 如果要考虑恢复以前的效果 那么 @BTE.DLL @temp entity

		return HAM_IGNORED;
	}
	else if (iClass == ENTCLASS_BOW)
	{
#if 0
		set_pev(iPtr, pev_solid, SOLID_NOT);

		new Float:vOrigin[3];
		pev(iPtr,pev_origin,vOrigin);

		if (engfunc(EngFunc_PointContents, vOrigin) == CONTENTS_SKY)
		{
			set_pev(iPtr, pev_flags, pev(iPtr, pev_flags) | FL_KILLME);
			return HAM_IGNORED;
		}

		new iOwner = pev(iPtr, pev_owner);

		if (iPtd == iOwner)
			return HAM_IGNORED;

		if (!iPtd)
		{
			engfunc(EngFunc_MessageBegin, MSG_BROADCAST, SVC_TEMPENTITY, vOrigin, 0);
			write_byte(TE_GUNSHOTDECAL);
			engfunc(EngFunc_WriteCoord,vOrigin[0]);
			engfunc(EngFunc_WriteCoord,vOrigin[1]);
			engfunc(EngFunc_WriteCoord,vOrigin[2]);
			write_short(0);
			write_byte(DECAL_SHOT[random_num(0,4)]);
			message_end();

			engfunc(EngFunc_EmitSound, iPtr, CHAN_AUTO, "weapons/xbow_hit1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			//set_pev(iPtr, pev_flags, pev(iPtr, pev_flags) | FL_KILLME);
			Set_Ent_Data(iPtr, DEF_ENTCLASS, ENTCLASS_FADEIN);
			set_pev(iPtr, pev_nextthink, get_gametime()+6.0);
			set_pev(iPtr, pev_rendermode, kRenderTransAlpha);
			set_pev(iPtr, pev_renderamt, 255.0);
			set_pev(iPtr, pev_movetype, MOVETYPE_NONE);

			return HAM_IGNORED;
		}

		new Float:fDamage;
		pev(iPtr, pev_fuser2, fDamage);
		fDamage *= 80.0;

		new trRes,Float:vecStart[3],Float:Forw[3],Float:vecEnd[3],Float:angle[3],Float:direction[3];
		pev(iPtr, pev_origin, vecStart);

		Stock_Get_Velocity_Angle(iPtr, angle);
		engfunc(EngFunc_MakeVectors, angle);
		global_get(glb_v_forward,direction);
		xs_vec_mul_scalar(direction,20.0,Forw);
		xs_vec_add(vecStart, Forw, vecEnd);
		xs_vec_mul_scalar(direction,-5.0,Forw);
		xs_vec_add(vecStart, Forw, vecStart);

		engfunc(EngFunc_TraceLine, vecStart, vecEnd, 0, iOwner, trRes);

		Set_Ent_Data(iPtr, DEF_ENTCLASS, ENTCLASS_FADEIN);
		set_pev(iPtr, pev_nextthink, get_gametime()+6.0);
		set_pev(iPtr, pev_rendermode, kRenderTransAlpha);
		set_pev(iPtr, pev_renderamt, 255.0);

		new iBody = get_tr2(trRes,TR_iHitgroup);
		iBody = bte_hms_get_skillstat(iOwner) & (1<<1)?1:iBody;

		if (0 < iPtd && iPtd < 33)
		{
			fDamage *= Stock_Get_Body_Dmg(bte_zb3_is_boomer_skilling(iPtd)?0:iBody);

			if (can_damage(iOwner, iPtd)) Stock_BloodEffect(vOrigin, iBody==1?12:7);

			set_pdata_int(iPtd, 75, bte_zb3_is_boomer_skilling(iPtd)?0:iBody);

			ExecuteHamB(Ham_TakeDamage,iPtd,iPtr,iOwner,fDamage,DMG_CLUB);

			new iCharged;
			iCharged = pev(iPtr, pev_iuser3);

			if (iCharged)
				Stock_Fake_KnockBack(iOwner,iPtd,c_knockback[g_weapon[iOwner][0]]);
			//set_pev(iPtr, pev_aiment, iPtd);
			set_pev(iPtr, pev_renderamt, 0.0);
			engfunc(EngFunc_EmitSound, iPtr, CHAN_AUTO, "weapons/xbow_hitbod1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);

			new Float:fCurTime;
			global_get(glb_time, fCurTime);

			/*if (c_stop_speed[g_weapon[iOwner][0]] && (bte_get_user_zombie(iPtd) == 1))
			{
				g_stop_next[iPtd] = fCurTime + iCharged?0.8:0.4 * g_knockback[iOwner]<1.0?g_knockback[iOwner]:1.0;
				g_stop_speed[iPtd] = c_stop_speed[g_weapon[iOwner][0]];
				set_pev(iPtd, pev_maxspeed, g_stop_speed[iPtd]);
			}*/


		}
		if (iPtd > 32)
		{
			if (!(pev(iPtd, pev_spawnflags) & SF_BREAK_TRIGGER_ONLY))
				ExecuteHamB(Ham_TakeDamage,iPtd,iPtr,iOwner,fDamage,DMG_CLUB);
		}

		//set_pev(iPtr, pev_flags, pev(iPtr, pev_flags) | FL_KILLME);

		set_pev(iPtr, pev_movetype, MOVETYPE_NONE);
#endif

	}
	else if (iClass == ENTCLASS_SPEARGUN)
	{
		/*new Float:vecOrigin[3];
		pev(iPtr, pev_origin, vecOrigin);

		if (engfunc(EngFunc_PointContents, vecOrigin) == CONTENTS_SKY)
		{
			RemoveEntity(iPtr);
			return HAM_IGNORED
		}*/

		/*set_pev(iPtr, pev_nextthink, get_gametime() + 1.0);

		PRINT("!%d", iPtr)*/

		//SendTempEntity(iPtr, 1, iPtd, FALSE);

		if (!iPtd)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_GUNSHOTDECAL);
			engfunc(EngFunc_WriteCoord, vecOrigin[0]);
			engfunc(EngFunc_WriteCoord, vecOrigin[1]);
			engfunc(EngFunc_WriteCoord, vecOrigin[2]);
			write_short(0);
			write_byte(DECAL_SHOT[random_num(0,4)]);
			message_end();

			new iTtextureType = EntityTouchTraceTexture(iPtr);

			new sound[32];
			if (iTtextureType == 'M' || iTtextureType == 'V' || iTtextureType == 'P')
			{
				switch (random_num(0,1))
				{
					case 0 : format(sound, charsmax(sound), "weapons/speargun_metal1.wav");
					case 1 : format(sound, charsmax(sound), "weapons/speargun_metal2.wav");
				}
			}
			else if (iTtextureType == 'W')
			{
				switch (random_num(0,1))
				{
					case 0 : format(sound, charsmax(sound), "weapons/speargun_wood1.wav");
					case 1 : format(sound, charsmax(sound), "weapons/speargun_wood2.wav");
				}
			}
			else
			{
				switch (random_num(0,1))
				{
					case 0 : format(sound, charsmax(sound), "weapons/speargun_stone1.wav");
					case 1 : format(sound, charsmax(sound), "weapons/speargun_stone2.wav");
				}
			}

			engfunc(EngFunc_EmitSound, iPtr, CHAN_ITEM, sound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
		else if (IsPlayer(iPtd))
		{
			if (bte_get_user_zombie(iPtd) == 1)
			{
				new Float:vecVelocity[3];
				pev(iPtd, pev_velocity, vecVelocity);

				new Float:vecDirection[3], Float:vecForward[3];
				pev(iPtr, pev_velocity, vecDirection);
				xs_vec_normalize(vecDirection, vecDirection);
				xs_vec_mul_scalar(vecDirection, c_flKnockback[iBteWpn][0], vecForward);

				if (pev(iPtd, pev_flags) & FL_DUCKING)
					xs_vec_mul_scalar(vecDirection, 0.5/*c_flKnockback[iBteWpn][1]*/, vecForward);

				vecForward[2] = 0.0;
				xs_vec_add(vecVelocity, vecForward, vecVelocity);

				set_pev(iPtd, pev_velocity, vecVelocity);
			}

			//EntityTouchDamage(iPtr, iOwner, (!IS_ZBMODE) ? c_flDamage[iBteWpn][0] : c_flDamageZB[iBteWpn][0]);

			set_pev(iPtr, pev_iuser1, EntityTouchGetHitGroup(iPtr));
			set_pev(iPtr, pev_iuser2, iPtd);
			set_pev(iPtr, pev_velocity, g_vecZero);
			set_pev(iPtr, pev_aiment, iPtd);

			set_pev(iPtr, pev_movetype, MOVETYPE_NONE);
			set_pev(iPtr, pev_solid, SOLID_NOT);
			//set_pev(iPtr, pev_effects, EF_NODRAW);


			new Float:vecOrigin[3], Float:vecOrigin2[3];
			pev(iPtr, pev_origin, vecOrigin);
			pev(iPtd, pev_origin, vecOrigin2);
			xs_vec_sub(vecOrigin, vecOrigin2, vecOrigin);
			set_pev(iPtr, pev_vuser2, vecOrigin);

			//set_pev(iPtr, pev_movetype, MOVETYPE_FOLLOW); // 似乎不好


			return HAM_IGNORED;
		}
		set_pev(iPtr, pev_solid, SOLID_NOT);
		set_pev(iPtr, pev_movetype, MOVETYPE_NONE);

		return HAM_IGNORED;
	}

	return HAM_IGNORED
}

/*public HamF_InfoTarget_Touch_Post(iPtr,iPtd)
{
	static iClass ,iOwner
	iClass = Get_Ent_Data(iPtr,DEF_ENTCLASS)
	iOwner = pev(iPtr, pev_owner)
	if (iClass == ENTCLASS_SPEARGUN)
	{
		if (iPtd == iOwner) return HAM_IGNORED;

		set_pev(iPtr, pev_velocity, {0.0, 0.0, 0.0});
		//set_pev(iPtr, pev_origin, vecOrigin);

	}
	return HAM_IGNORED;
}*/

public HamF_Killed(id, idattacker, shouldgib)
{
	//set_pev(id, pev_weaponmodel, 0)
	//set_pev(id, pev_maxspeed, 250.0)

	//if (c_seq[g_weapon[id][0]] && bte_get_user_zombie(id) != 1) InitiateSequence(id,0);

	g_iWeaponMode[id][1] = 0;

	Pub_Killed_Reset(id)
	//Pub_Holster_Reset(id, 0)
	//if (is_user_bot(id)) Stock_ResetBotMoney(id)
	if (pev_valid(g_p_modelent[id]))
	{
		Stock_Set_Vis(g_p_modelent[id],0)
	}
	if (g_c_iStripDroppedHe)
	{
		new sz[64]
		for(new i=1;i<4;i++)
		{
			if (i==1) copy(sz,63,"weapon_hegrenade")
			else if (i==2) copy(sz,63,"weapon_smokegrenade")
			else copy(sz,63,"weapon_flashbang")
			new wEnt
			while((wEnt = engfunc(EngFunc_FindEntityByString,wEnt,"classname",sz)) && pev(wEnt,pev_owner) != id) {}
			if (wEnt)
			{
				ExecuteHamB(Ham_Weapon_RetireWeapon,wEnt)
				if (!ExecuteHamB(Ham_RemovePlayerItem,id,wEnt))  continue
				ExecuteHamB(Ham_Item_Kill, wEnt)
			}
		}
	}
	return HAM_IGNORED;
}

stock GetWeaponModeIdle(id, iEnt, iBteWpn)
{
	static iClip, iWeaponState;
	iClip = get_pdata_int(iEnt, m_iClip);
	iWeaponState = get_pdata_int(iEnt, m_iWeaponState);

	if (c_iSpecial[iBteWpn] == SPECIAL_INFINITY) return (iClip <= 1);
	if (iWeaponState & WPNSTATE_M4A1_SILENCED) return 1;
	if (iWeaponState & WPNSTATE_USP_SILENCED) return 1;
	if (c_iSpecial[iBteWpn] == SPECIAL_JANUSMK5 || c_iSpecial[iBteWpn] == SPECIAL_JANUS7 || c_iSpecial[iBteWpn] == SPECIAL_JANUS1 || c_iSpecial[iBteWpn] == SPECIAL_JANUS11) return pev(iEnt, pev_iuser1);
	if (c_iSpecial[iBteWpn] == SPECIAL_FIXSHOOT || (c_iSpecial[iBteWpn] == SPECIAL_SKULL3 && g_double[id][0])) return (iClip == 1);
	if (c_iSpecial[iBteWpn] == SPECIAL_CHAINSAW) return (iClip == 0);
	if (c_iSpecial[iBteWpn] == SPECIAL_SFSWORD) return pev(iEnt, pev_iuser1);
	if (c_iSpecial[iBteWpn] == SPECIAL_BALROG9) return pev(iEnt, pev_iuser1);
	if (c_iSpecial[iBteWpn] == SPECIAL_DGUN) return (iClip == 0);
	if (c_iSpecial[iBteWpn] == SPECIAL_BOW) return pev(iEnt, pev_iuser1) >= 1 ? (pev(iEnt, pev_iuser1) == 2 ? 3 : 2) : (iClip ? 0: 1);
	if (c_iSpecial[iBteWpn] == SPECIAL_M2) return iClip ? (g_iWeaponMode[id][1] ? 1 : 0) : (g_iWeaponMode[id][1] ? 3 : 2);
	if (c_iSpecial[iBteWpn] == SPECIAL_PETROLBOOMER || c_iSpecial[iBteWpn] == SPECIAL_SPEARGUN) return (iClip == 0) ? 1 : (pev(id, pev_weaponanim) == 1 ? 2 : 0);
	if (c_iSpecial[iBteWpn] == SPECIAL_MAUSERC96) return iClip?0:1;
	if (c_iSpecial[iBteWpn] == SPECIAL_BLOCKAR)
	{
		if (pev(iEnt, pev_iuser1) == STATUS_MODE2)
			return GetExtraAmmo(iEnt) > 0 ? 1 : 2;
		return 0;
	}
	if (c_iSpecial[iBteWpn] == SPECIAL_GUILLOTINE)
		return CGuillotine_GetWeaponModeIdle(id, iEnt);
	if (c_iSpecial[iBteWpn] == SPECIAL_RUNEBLADE)
		return Runeblade_GetWeaponModeIdle(id, iEnt, iBteWpn);

	return 0;
}

public WeaponIdleSpecial(id, iEnt, iBteWpn)
{
	/*if (c_iSpecial[iBteWpn] == SPECIAL_BALROG3)
	{
		if (get_gametime()-g_bl3_timer[id] > c_flAttackInterval[iBteWpn][0] + 0.15)
		{
			if (g_bl3_num[id] > 15)
				g_bl3_num[id] = 0
		}
	}*/
	
	if (c_iSpecial[iBteWpn] == SPECIAL_SGDRILL)
		set_pev(iEnt, pev_fuser1, 0.0);
}
public HamF_Weapon_WeaponIdle(iEnt)
{
	static id, iId, iBteWpn;
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	iId = get_pdata_int(iEnt, m_iId, 4)
	iBteWpn = g_weapon[id][0];

	if (c_iType[iBteWpn] == WEAPONS_SHOTGUN_RELOAD)
	{
		HamF_Weapon_WeaponIdle_Shotgun(iEnt);

		return HAM_SUPERCEDE;
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_GAUSS)
	{
		CGauss_WeaponIdle(id, iEnt, iBteWpn);
		return HAM_SUPERCEDE;
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_CANNONEX)
	{
		CCannonex_WeaponIdle(id, iEnt, iId, iBteWpn);
		return HAM_SUPERCEDE;
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_DESPERADO)
	{
		CDesperado_WeaponIdle(id, iEnt, iId, iBteWpn);
		return HAM_SUPERCEDE;
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_GUNKATA)
	{
		CGunkata_WeaponIdle(id, iEnt, iId, iBteWpn);
		return HAM_SUPERCEDE;
	}

	WeaponIdleSpecial(id, iEnt, iBteWpn);

	new Float:flTimeWeaponIdle = get_pdata_float(iEnt, m_flTimeWeaponIdle, 4);

	if (flTimeWeaponIdle > 0.0)
		return HAM_IGNORED;

	new iType;

	iType = GetWeaponModeIdle(id, iEnt, iBteWpn);

	if (c_iSpecial[iBteWpn] == SPECIAL_ZG)
	{
		if (pev(id, pev_weaponanim) == c_iIdleAnim[iBteWpn][1])
			SendWeaponAnim(id, c_iIdleAnim[iBteWpn][0]);
		else
			SendWeaponAnim(id, c_iIdleAnim[iBteWpn][random_num(0,3) == 3]);

		set_pdata_float(iEnt, m_flTimeWeaponIdle, 7.0);
		return HAM_IGNORED;
	}

	if (c_iType[iBteWpn] == WEAPONS_FLAMETHROWER)
	{
		if (pev(id, pev_weaponanim) == 1)
		{
			SendWeaponAnim(id, 2);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flIdleAnimTime[iBteWpn][1]);
		}
		else
		{
			SendWeaponAnim(id, 0);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flIdleAnimTime[iBteWpn][0]);
		}

		return HAM_IGNORED;
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_SFPISTOL)
	{
		if (pev(id, pev_weaponanim) == 1)
		{
			SendWeaponAnim(id, 2);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.54);

			engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 0, 0, TRUE, TRUE);

			return HAM_IGNORED;
		}

		SendWeaponAnim(id, 0);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flIdleAnimTime[iBteWpn][0]);

		return HAM_IGNORED;
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_M1GARAND)
	{
		new iClip = get_pdata_int(iEnt, m_iClip);
		new iWeaponState = get_pdata_int(iEnt, m_iWeaponState);

		SendWeaponAnim(id, (iWeaponState & WPNSTATE_M1GARAND_AIMING) ? (iClip ? 2 : 3) : (iClip ? 0 : 1));
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 60.0);

		return HAM_IGNORED;
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_RPG)
	{
		new iClip = get_pdata_int(iEnt, m_iClip);
		new iWeaponState = get_pdata_int(iEnt, m_iWeaponState);

		SendWeaponAnim(id, (iWeaponState & WPNSTATE_M1GARAND_AIMING) ? (iClip ? 1 : 3) : (iClip ? 0 : 2));
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 60.0);

		return HAM_IGNORED;
	}
	
	if(c_iSpecial[iBteWpn] == SPECIAL_BLOCKSMG)
	{
		new iClip = get_pdata_int(iEnt, m_iClip);
		if (pev(iEnt, pev_iuser1) == STATUS_MODE2)
		{
			SendWeaponAnim(id, (random_num(0,1) * 4) + pev(iEnt, pev_iuser2));
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 6.0);
		}
		else
		{
			SendWeaponAnim(id, iClip <=1 ? 1:0)
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.0);
		}
		
		return 0;
	}
	
	if(c_iSpecial[iBteWpn] == SPECIAL_INFINITY)
	{
		CInfinity_WeaponIdle_Post(iEnt)
	}

	if (c_iIdleAnim[iBteWpn][iType] == -1)
		return HAM_IGNORED;

	SendWeaponAnim(id, c_iIdleAnim[iBteWpn][iType]);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flIdleAnimTime[iBteWpn][iType]);

#if defined _DEBUG
	PRINT("WeaponIdle: %d %d %d", id, iType, c_iIdleAnim[iBteWpn][iType])
#endif

	return HAM_IGNORED;
}

public Float:TakeDamageSpecialWeapons(id, iVictim, iInflictor, bitsDamageType, iBteWpn)
{
	if (bitsDamageType & DMG_EXPLOSION && !Get_Ent_Data(iInflictor,DEF_ENTCLASS) && iInflictor > 32) //He Damage
	{
		if (can_damage(id, iVictim))
		{
			if (c_iSpecial[iBteWpn] == SPECIAL_FIREBOMB)
			{
				if (task_exists(iVictim+TASK_FIREBOMB))
				{
					remove_task(iVictim+TASK_FIREBOMB)
					set_task(1.00,"Task_Firebomb",iVictim+TASK_FIREBOMB,"",0,"a",8)
				}
				else
				{
					set_task(1.00,"Task_Firebomb",iVictim+TASK_FIREBOMB,"",0,"a",8)
				}
			}
			if (c_iSpecial[iBteWpn] == SPECIAL_HOLYBOMB)
			{
				if (task_exists(iVictim+TASK_HOLYBOMB))
				{
					remove_task(iVictim+TASK_HOLYBOMB)
					set_task(1.00,"Task_Holybomb",iVictim+TASK_HOLYBOMB,"",0,"a",8)
				}
				else
				{
					set_task(1.00,"Task_Holybomb",iVictim+TASK_HOLYBOMB,"",0,"a",8)
				}
			}
		}
		return 1.0;
	}

	/*if (c_iSpecial[iBteWpn] == SPECIAL_BALROG5)
		return (WE_Balrog5(id, iVictim));*/

	/*if (c_iSpecial[iBteWpn] == SPECIAL_BALROG3 && g_bl3_num[id]>15)
	{
		static Float:head_origin[3], Float:angles[3]

		engfunc(EngFunc_GetBonePosition, iVictim, PLAYERBONE_HEAD, head_origin, angles)

		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, head_origin, 0);
		write_byte(TE_SPRITE)
		engfunc(EngFunc_WriteCoord,head_origin[0]);
		engfunc(EngFunc_WriteCoord,head_origin[1]);
		engfunc(EngFunc_WriteCoord,head_origin[2] + 20.0);
		write_short(g_cache_barlog5exp)
		write_byte(5)
		write_byte(255)
		message_end()
	}*/

	 if (c_iSpecial[iBteWpn] == SPECIAL_JANUS11 && !CheckTeammate(id, iVictim))
	{
		if (!is_user_alive(id)) return 1.0;

		new Float:fCurTime;
		global_get(glb_time, fCurTime);

		new iEnt;
		iEnt = get_pdata_cbase(id, m_pActiveItem);
		if (!pev_valid(iEnt)) return 1.0;
		new iShootTime = pev(iEnt, pev_iuser2);
		new iState = pev(iEnt, pev_iuser1);
		new Float:fNextReset;

		iShootTime += 1;
#if defined _DEBUG
		if (iShootTime >= 1 && iState != JANUSMK5_USING)
#else
		if (iShootTime >= 15 && iState != JANUSMK5_USING)
#endif
		{
			iState = JANUSMK5_CANUSE;
			fNextReset = fCurTime + 8.0;
			MH_SpecialEvent(id, 50 + iState);
			set_pev(iEnt, pev_iuser1, iState);
			set_pev(iEnt, pev_fuser1, fNextReset);
			SendWeaponAnim(id, 16)
		}
		if (iState != JANUSMK5_USING)
			set_pev(iEnt, pev_iuser2, iShootTime);
	}										   
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUSMK5 && !CheckTeammate(id, iVictim))
	{
		if (!is_user_alive(id)) return 1.0;

		new Float:fCurTime;
		global_get(glb_time, fCurTime);

		new iEnt;
		iEnt = get_pdata_cbase(id, m_pActiveItem);
		if (!pev_valid(iEnt)) return 1.0;
		new iShootTime = pev(iEnt, pev_iuser2);
		new iState = pev(iEnt, pev_iuser1);
		new Float:fNextReset;

		iShootTime += 1;
#if defined _DEBUG
		if (iShootTime >= 1 && iState != JANUSMK5_USING)
#else
		if (iShootTime >= 57 && iState != JANUSMK5_USING)
#endif
		{
			iState = JANUSMK5_CANUSE;
			fNextReset = fCurTime + 8.0;
			MH_SpecialEvent(id, 50 + iState);
			set_pev(iEnt, pev_iuser1, iState);
			set_pev(iEnt, pev_fuser1, fNextReset);
		}
		if (iState != JANUSMK5_USING)
			set_pev(iEnt, pev_iuser2, iShootTime);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUS7 && !CheckTeammate(id, iVictim))
	{
		if (!is_user_alive(id)) return 1.0;

		new Float:fCurTime;
		global_get(glb_time, fCurTime);

		new iEnt;
		iEnt = get_pdata_cbase(id, m_pActiveItem);
		if (!pev_valid(iEnt)) return 1.0;
		new iShootTime = pev(iEnt, pev_iuser2);
		new iState = pev(iEnt, pev_iuser1);
		new Float:fNextReset;

		iShootTime += 1;
#if defined _DEBUG
		if (iShootTime >= 1 && iState != JANUSMK5_USING)
#else
		if (iShootTime >= JANUS7_CHARGE_SHOOTTIME && iState != JANUSMK5_USING)
#endif
		{
			iState = JANUSMK5_CANUSE;
			fNextReset = fCurTime + JANUS7_CHARGE_TIME_CANUSE;
			MH_SpecialEvent(id, 50 + iState);
			set_pev(iEnt, pev_iuser1, iState);
			set_pev(iEnt, pev_fuser1, fNextReset);
		}
		if (iState != JANUSMK5_USING)
			set_pev(iEnt, pev_iuser2, iShootTime);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BLOODHUNTER && !CheckTeammate(id, iVictim))
	{
		new iEnt = get_pdata_cbase(id, m_pActiveItem);
		new iShootTime = pev(iEnt, pev_iuser2);
		iShootTime++;
		set_pev(iEnt, pev_iuser2, iShootTime);
	}

	return 1.0;
}

//new Float:g_flVelocityModifier[33];
new Float:g_vecVelocity[33][3];

public HamF_TakeDamage(iVictim, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if ((bte_get_user_zombie(iAttacker)==1) && iInflictor > 32)
		return HAM_SUPERCEDE;

	if (!is_user_connected(iAttacker))
		return HAM_IGNORED;

	if (0 < iVictim < 33)
	{
		pev(iVictim, pev_health, g_fOldHealth[iVictim]);
	}
		
	if (bitsDamageType & DMG_ALWAYSGIB)
		bitsDamageType &= ~DMG_ALWAYSGIB;
		
	SetHamParamInteger(5, bitsDamageType);

	if (g_modruning == BTE_MOD_ZB1)
	{
		if (bte_get_user_zombie(iAttacker) != 1 && bte_get_user_zombie(iVictim) != 1 && iVictim == iAttacker)
			flDamage /= 5.0;
	}

	if (is_user_connected(iVictim))
	{
		//g_flVelocityModifier[iVictim] = get_pdata_float(iVictim, m_flVelocityModifier);
		pev(iVictim, pev_velocity, g_vecVelocity[iVictim]);
	}

	static iBteWpn;
	iBteWpn = g_weapon[iAttacker][0] + g_double[iAttacker][0];
	static iId;
	iId	= get_user_weapon(iAttacker)
	
	/*PRINT("TakeDamage(hegrenade): victim %d Health:%d Armor:%d", iVictim, get_user_health(iVictim), get_user_armor(iVictim))
	if(is_user_connected(iVictim) && c_flArmorRatio[iBteWpn][0] && iId && ARMOR_RATIO[iId]!=1.0)
	{
		static OrpheuFunction:handleTakeDamage;
		if(!handleTakeDamage) handleTakeDamage = OrpheuGetFunctionFromEntity(iVictim, "TakeDamage", "CBasePlayer");
		static pfnTakedamage;
		if(!pfnTakedamage) pfnTakedamage = OrpheuGetFunctionAddress(handleTakeDamage);
		static szMemoryDataName[16];
		format(szMemoryDataName, 15, "pflRatio[%i]", iId);
		OrpheuMemorySetAtAddress(pfnTakedamage, szMemoryDataName, 1, c_flArmorRatio[iBteWpn][0])
	}*/

	if (bitsDamageType & DMG_EXPLOSION && !Get_Ent_Data(iInflictor, DEF_ENTCLASS) && iInflictor > 32) // hegrenade
	{
		iBteWpn = Get_Wpn_Data(iInflictor, DEF_ID);

		if (c_flDamage[iBteWpn][0])
		{
			if (!IS_ZBMODE)
				flDamage *= c_flDamage[iBteWpn][0] / 100.0;
			else
				flDamage *= c_flDamageZB[iBteWpn][0] / 100.0;

#if defined _DEBUG
			PRINT("TakeDamage(hegrenade): victim %d flDamage: %f c_flDamage: %f", iVictim, flDamage, (!IS_ZBMODE) ? c_flDamage[iBteWpn][0] : c_flDamageZB[iBteWpn][0])
#endif

			SetHamParamFloat(4, flDamage);
		}

		if (c_iSpecial[iBteWpn] == SPECIAL_HOLYBOMB) // only hurt zombie
		{
			if (iVictim > 32)
				return HAM_SUPERCEDE;
			if (bte_get_user_zombie(iVictim) != 1)
				return HAM_SUPERCEDE;
		}
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_JANUS11)
	{

		// Multiplay damage only for Shoot mode B
		new iEnt;
		if (pev(iEnt, pev_iuser1) == 1)
		{	

			// multi x8
			flDamage *= 10;
			SetHamParamFloat(4, flDamage);
		}	

	}
	if (iInflictor == iAttacker)
	{
		if ((iId == CSW_M3 || iId == CSW_XM1014) && !g_bSGDRILL_Attacking)
		{
			if (!IS_ZBMODE)
				flDamage *= c_flDamage[iBteWpn][0];
			else
				flDamage *= c_flDamageZB[iBteWpn][0];

			SetHamParamFloat(4, flDamage);
		}
	}

#if defined _DEBUG
	PRINT("TakeDamage: victim %d XDamage %f", iVictim, TakeDamageSpecialWeapons(iAttacker, iVictim, iInflictor, bitsDamageType, iBteWpn));
#else
	flDamage *= TakeDamageSpecialWeapons(iAttacker, iVictim, iInflictor, bitsDamageType, iBteWpn);
#endif

	SetHamParamFloat(4, flDamage);
	return HAM_IGNORED
}

public HamF_TakeDamage_Breakable(iVictim, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if (bitsDamageType & DMG_EXPLOSION && !Get_Ent_Data(iInflictor, DEF_ENTCLASS) && iInflictor > 32) // hegrenade
	{
		if (pev(iVictim, pev_solid) != SOLID_BSP) // !! SOLID_BSP no damage
			return HAM_IGNORED;

		new iBteWpn = Get_Wpn_Data(iInflictor, DEF_ID);

		if (c_iSpecial[iBteWpn] == SPECIAL_HOLYBOMB) // only hurt zombie
			return HAM_SUPERCEDE;

		new Float: origin[2][3];
		GetOrigin(iVictim, origin[0]);
		GetOrigin(iVictim, origin[1]);

		xs_vec_sub(origin[0], origin[1], origin[0])

		flDamage = 100.0 - 100.0 * xs_vec_len(origin[0]) / 350.0;

		if (c_flDamage[iBteWpn][0])
		{
			if (!IS_ZBMODE)
				flDamage *= c_flDamage[iBteWpn][0] / 100.0;
			else
				flDamage *= c_flDamageZB[iBteWpn][0] / 100.0;

#if defined _DEBUG
			PRINT("TakeDamage(breakable)(hegrenade): victim %d flDamage: %f c_flDamage: %f", iVictim, flDamage, (!IS_ZBMODE) ? c_flDamage[iBteWpn][0] : c_flDamageZB[iBteWpn][0])
#endif
			SetHamParamFloat(4, flDamage);
		}
	}

	return HAM_IGNORED;
}

public HamF_TakeDamage_Post(iVictim, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if (!is_user_connected(iAttacker))
		return HAM_IGNORED;

	if (iVictim > 0 && iVictim < 33)
	{
		new Float:flHealth;
		pev(iVictim, pev_health, flHealth);
		
		g_fTotalDamage[iVictim][iAttacker] += g_fOldHealth[iVictim] - flHealth;
		
		g_fNextClear[iVictim][iAttacker] = get_gametime()+10.0;
	}

	if (CheckTeammate(iVictim, iAttacker))
		return HAM_IGNORED;

	new iBteWpn = g_weapon[iAttacker][0] + g_double[iAttacker][0];
	new iEnt = get_pdata_cbase(iAttacker, m_pActiveItem);
	
	//static iId;
	//iId	= get_user_weapon(iAttacker)
	
	/*PRINT("TakeDamage(hegrenade): victim %d Health:%d Armor:%d", iVictim, get_user_health(iVictim), get_user_armor(iVictim))
	if(is_user_connected(iVictim) && c_flArmorRatio[iBteWpn][0] && iId && ARMOR_RATIO[iId]!=1.0)
	{
		static OrpheuFunction:handleTakeDamage;
		if(!handleTakeDamage) handleTakeDamage = OrpheuGetFunctionFromEntity(iVictim, "TakeDamage", "CBasePlayer");
		static pfnTakedamage;
		if(!pfnTakedamage) pfnTakedamage = OrpheuGetFunctionAddress(handleTakeDamage);
		static szMemoryDataName[16];
		format(szMemoryDataName, 15, "pflRatio[%i]", iId);
		OrpheuMemorySetAtAddress(pfnTakedamage, szMemoryDataName, 1, ARMOR_RATIO[iId])
	}*/

	if (iInflictor > 32)
	{
		if (Get_Ent_Data(iInflictor, DEF_ENTCLASS))
			iBteWpn = Get_Ent_Data(iInflictor, DEF_ENTID);
	}

	if ((pev_valid(iVictim) && pev(iVictim, pev_takedamage)) && IsPlayer(iAttacker))
		if (c_iSpecial[iBteWpn] == SPECIAL_BUFFM4A1 || c_iSpecial[iBteWpn] == SPECIAL_BUFFAK47 || c_iSpecial[iBteWpn] == SPECIAL_BUFFSG552 || c_iSpecial[iBteWpn] == SPECIAL_BUFFAWP || c_iSpecial[iBteWpn] == SPECIAL_BLOODHUNTER|| c_iSpecial[iBteWpn] == SPECIAL_DESPERADO|| c_iSpecial[iBteWpn] == SPECIAL_GUNKATA)
			PLAYBACK_EVENT_FULL(FEV_HOSTONLY, iAttacker, WEAPON_EVENT[CSW_KNIFE], 0.0, g_vecZero, g_vecZero, 0.0, 0.0, (1<<7), 0, FALSE, FALSE);

	if (c_flVelocityModifier[iBteWpn][GetWeaponModeKnockback(iAttacker, iBteWpn)])
		set_pdata_float(iVictim, m_flVelocityModifier, c_flVelocityModifier[iBteWpn][GetWeaponModeKnockback(iAttacker, iBteWpn)]);

	if (g_modruning == BTE_MOD_ZB1)
	{
		new Float:flVelocityModifier = get_pdata_float(iVictim, m_flVelocityModifier);

		if (g_vm[iVictim])
		{
			flVelocityModifier /= g_vm[iVictim];
			if (flVelocityModifier > 1.0) flVelocityModifier = 1.0;
			set_pdata_float(iVictim, m_flVelocityModifier, flVelocityModifier);
		}
		/*if (g_flVelocityModifier[iVictim] < flVelocityModifier)
			flVelocityModifier = g_flVelocityModifier[iVictim];

		set_pdata_float(iVictim, m_flVelocityModifier, flVelocityModifier);*/

		if (bitsDamageType & DMG_BULLET)
		{
			//new iType = GetWeaponModeTakeDamage(iAttacker, iBteWpn);

			if (c_flKnockback[iBteWpn][0])
			{
				
				if (c_iSpecial[iBteWpn] == SPECIAL_DESPERADO && pev(iEnt, pev_iuser1) == 1)
				{
					KnockBack(iAttacker, iVictim, iBteWpn, g_vecVelocity[iVictim], GetWeaponModeKnockback(iAttacker, iBteWpn), TRUE);
					new Float:vecVelocity[3];
					pev(iVictim, pev_velocity, vecVelocity);
					vecVelocity[2] = 200.0;
					set_pev(iVictim, pev_velocity, vecVelocity);
					
				}
				else
				{
					KnockBack(iAttacker, iVictim, iBteWpn, g_vecVelocity[iVictim], GetWeaponModeKnockback(iAttacker, iBteWpn));
				}
				
				
				/*
				new flags = pev(iVictim, pev_flags);
				new Float:fKnockBack = c_flKnockback[iBteWpn][iType] / flVelocityModifier * 5.0 * g_knockback[iVictim];
				if (flags & FL_DUCKING) fKnockBack *= 0.7;
				if (!(flags & FL_ONGROUND)) fKnockBack *= c_flKnockback[iBteWpn][iType + 1];

				new Float:vecOrigin[2][3], Float:vecDirection[3], Float:vecVelocity[3];
				pev(iVictim, pev_origin, vecOrigin[0]);
				pev(iAttacker, pev_origin, vecOrigin[1]);
				xs_vec_sub(vecOrigin[0], vecOrigin[1], vecDirection);
				//vecDirection[2] = 0.0;
				xs_vec_normalize(vecDirection, vecDirection);
				xs_vec_mul_scalar(vecDirection, fKnockBack, vecVelocity);

				vecVelocity[2] = 0.0;

				if (!(flags & FL_ONGROUND))
					g_vecVelocity[iVictim][0] = g_vecVelocity[iVictim][1] = 0.0;

				xs_vec_add(g_vecVelocity[iVictim], vecVelocity, vecVelocity);
				set_pev(iVictim, pev_velocity, vecVelocity);
				*/
			}
		}
	}

	return HAM_IGNORED;
}

public GetWeaponModeTakeDamage(id, iBteWpn)
{
	if (!is_user_alive(id))
		return 0;

	if (c_iSpecial[iBteWpn] == SPECIAL_QBARREL)
	{
		new iEnt = get_pdata_cbase(id, m_pActiveItem);
		new iSpShoot = pev(iEnt, pev_iuser1);

		if (iSpShoot)
			return 2;
	}

	return 0;
}

public GetWeaponModeKnockback(id, iBteWpn)
{
	if (!is_user_alive(id))
		return 0;
	new iEnt = get_pdata_cbase(id, m_pActiveItem);
	if (c_iSpecial[iBteWpn] == SPECIAL_INFINITY || c_iSpecial[iBteWpn] == SPECIAL_SKULL1)
	{
		return !!(pev(id, pev_button) & IN_ATTACK2)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BUFFM4A1)
	{
		return get_pdata_int(id, m_iFOV) != 90
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BOW)
	{
		return pev(iEnt, pev_iuser1) == 2
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BOW)
	{
		return pev(iEnt, pev_iuser1) == 2
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_RAILCANNON)
	{
		return pev(iEnt, pev_iuser1)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_QBARREL)
	{
		return !!pev(iEnt, pev_iuser1)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_DESPERADO)
	{
		return !!pev(iEnt, pev_iuser1)
	}

	return 0;
}

public HamF_Weapon_PrimaryAttack(iEnt)
{
	static id, iClip, Float:iFov, iBteWpn;
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	iClip = get_pdata_int(iEnt, m_iClip, 4);
	pev(id, pev_fov, iFov);

	iBteWpn = g_weapon[id][0] + g_double[id][0];

	if (c_iSpecial[iBteWpn] == SPECIAL_GAUSS)
		return HAM_SUPERCEDE;

	g_attacking[id] = iClip ? 1 : 0;

	g_flSpread[id] = -0.000001;

	g_flAccuracy[id] = get_pdata_float(iEnt, m_flAccuracy);
	g_iShotsFired[id] = get_pdata_int(iEnt, m_iShotsFired);
	g_flLastFire[id] = get_pdata_float(iEnt, m_flLastFire);

	switch (c_iAccuracyCalculate[iBteWpn])
	{
		case 1 :
		{
			// Primaryattack
			new flags = pev(id, pev_flags);
			new Float:velocity = GetVelocity2D(id);

			if (!(flags & FL_ONGROUND))
				g_flSpread[id] = c_flSpread[iBteWpn][0] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][0];
			else if (velocity > c_flSpreadRun[iBteWpn])
				g_flSpread[id] = c_flSpread[iBteWpn][1] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][1];
			else
				g_flSpread[id] = c_flSpread[iBteWpn][2] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][2];

#if defined _DEBUG
			PRINT("Primaryattack: Accuracy: %f", g_flAccuracy[id]);
			//PRINT("Primaryattack: Accuracy: %f (c_flSpread + flAccuracy * c_flAccuracyMul)", g_flAccuracy[id]);
#endif
			// Fire
			g_iShotsFired[id] += 1;
			g_flAccuracy[id] = ((g_iShotsFired[id] * g_iShotsFired[id] * g_iShotsFired[id]) / c_flAccuracy[iBteWpn][0]) + c_flAccuracy[iBteWpn][1];

			if (g_flAccuracy[id] < c_flAccuracyRange[iBteWpn][0])
				g_flAccuracy[id] = c_flAccuracyRange[iBteWpn][0];
			else if (g_flAccuracy[id] > c_flAccuracyRange[iBteWpn][1])
				g_flAccuracy[id] = c_flAccuracyRange[iBteWpn][1];

		}
		case 2..3 :
		{
			// Primaryattack
			new flags = pev(id, pev_flags);
			new Float:velocity = GetVelocity2D(id);

			if (!(flags & FL_ONGROUND))
				g_flSpread[id] = c_flSpread[iBteWpn][0] + (1.0 - g_flAccuracy[id]) * c_flAccuracyMul[iBteWpn][0];
			else if (velocity > 0.0)
				g_flSpread[id] = c_flSpread[iBteWpn][1] + (1.0 - g_flAccuracy[id]) * c_flAccuracyMul[iBteWpn][1];
			else if (flags & FL_DUCKING)
				g_flSpread[id] = c_flSpread[iBteWpn][2] + (1.0 - g_flAccuracy[id]) * c_flAccuracyMul[iBteWpn][2];
			else
				g_flSpread[id] = c_flSpread[iBteWpn][3] + (1.0 - g_flAccuracy[id]) * c_flAccuracyMul[iBteWpn][3];

#if defined _DEBUG
			PRINT("Primaryattack: Accuracy: %f", g_flAccuracy[id]);
			//PRINT("Primaryattack: Accuracy: %f (c_flSpread + (1 - flAccuracy) * c_flAccuracyMul)", g_flAccuracy[id]);
#endif

			// Fire
			if (iFov == 90.0)
				g_flSpread[id] += c_flSpreadUnZoom[iBteWpn];

			if (g_flLastFire[id])
			{
				if (c_iAccuracyCalculate[iBteWpn] == 2)
					g_flAccuracy[id] = (get_gametime() - g_flLastFire[id]) * c_flAccuracy[iBteWpn][0] + c_flAccuracy[iBteWpn][1];
				else
					g_flAccuracy[id] = (c_flAccuracy[iBteWpn][0] - (get_gametime() - g_flLastFire[id])) * c_flAccuracy[iBteWpn][1];

				if (g_flAccuracy[id] < c_flAccuracyRange[iBteWpn][0])
					g_flAccuracy[id] = c_flAccuracyRange[iBteWpn][0];
				else if (g_flAccuracy[id] > c_flAccuracyRange[iBteWpn][1])
					g_flAccuracy[id] = c_flAccuracyRange[iBteWpn][1];
			}
		}
		case 4:
		{
			// Primaryattack
			new flags = pev(id, pev_flags);
			new Float:velocity = GetVelocity2D(id);

			if (!(flags & FL_ONGROUND)) // awp default 0.85 0.25 0.1 0.0 0.001
				g_flSpread[id] = c_flSpread[iBteWpn][0];
			else if (velocity > c_flSpreadRun[iBteWpn])
				g_flSpread[id] = c_flSpread[iBteWpn][1];
			else if (velocity > 10.0)
				g_flSpread[id] = c_flSpread[iBteWpn][2];
			else if (flags & FL_DUCKING)
				g_flSpread[id] = c_flSpread[iBteWpn][3];
			else
				g_flSpread[id] = c_flSpread[iBteWpn][4];

			// Fire
			if (iFov == 90.0) // awp default 0.08
				g_flSpread[id] += c_flSpreadUnZoom[iBteWpn];
		}
		case 5:	// only for buffsg552
		{
			if (iFov == 90.0)
			{
				new flags = pev(id, pev_flags);
				new Float:velocity = GetVelocity2D(id);

				if (!(flags & FL_ONGROUND))
					g_flSpread[id] = 0.035 + g_flAccuracy[id] * 0.45;
				else if (velocity > 140.0)
					g_flSpread[id] = 0.035 + g_flAccuracy[id] * 0.01;
				else
					g_flSpread[id] = g_flAccuracy[id] * 0.02;

				// Fire
				g_iShotsFired[id] += 1;
				g_flAccuracy[id] = ((g_iShotsFired[id] * g_iShotsFired[id] * g_iShotsFired[id]) / 210.0) + 0.3;

				if (g_flAccuracy[id] > 1.0)
					g_flAccuracy[id] = 1.0;
			}
			else
			{
				new flags = pev(id, pev_flags);
				new Float:velocity = GetVelocity2D(id);

				if (!(flags & FL_ONGROUND))
					g_flSpread[id] = (1.0 - g_flAccuracy[id]) * 0.09;
				else if (velocity > 0.0)
					g_flSpread[id] = 0.03;
				else if (flags & FL_DUCKING)
					g_flSpread[id] = (1.0 - g_flAccuracy[id]) * 0.01;
				else
					g_flSpread[id] = (1.0 - g_flAccuracy[id]) * 0.02;

				g_flAccuracy[id] = (get_gametime() - g_flLastFire[id]) * 0.5 + 1.0;

				if (g_flAccuracy[id] > 1.0)
					g_flAccuracy[id] = 1.0;
			}
		}
		case 6 : // for infinity
		{
			// Primaryattack
			new flags = pev(id, pev_flags);
			new Float:velocity = GetVelocity2D(id);

			if (!(flags & FL_ONGROUND))
				g_flSpread[id] = c_flSpread[iBteWpn][0] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][0];
			else if (velocity > 0.0)
				g_flSpread[id] = c_flSpread[iBteWpn][1] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][1];
			else if (flags & FL_DUCKING)
				g_flSpread[id] = c_flSpread[iBteWpn][2] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][2];
			else
				g_flSpread[id] = c_flSpread[iBteWpn][3] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][3];

			// Fire
			g_iShotsFired[id] += 1;
			g_flAccuracy[id] = ((g_iShotsFired[id] * g_iShotsFired[id]) / c_flAccuracy[iBteWpn][0]) + c_flAccuracy[iBteWpn][1];

			if (g_flAccuracy[id] < c_flAccuracyRange[iBteWpn][0])
				g_flAccuracy[id] = c_flAccuracyRange[iBteWpn][0];
			else if (g_flAccuracy[id] > c_flAccuracyRange[iBteWpn][1])
				g_flAccuracy[id] = c_flAccuracyRange[iBteWpn][1];
		}
		case 7 : 
		{
			// Primaryattack
			new flags = pev(id, pev_flags);
			new Float:velocity = GetVelocity2D(id);

			if (!(flags & FL_ONGROUND))
				g_flSpread[id] = c_flSpread[iBteWpn][0] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][0];
			else if (velocity > c_flSpreadRun[iBteWpn])
				g_flSpread[id] = c_flSpread[iBteWpn][1] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][1];
			else
				g_flSpread[id] = c_flSpread[iBteWpn][2] + g_flAccuracy[id] * c_flAccuracyMul[iBteWpn][2];

			// Fire
			g_iShotsFired[id] += 1;
			g_flAccuracy[id] = ((g_iShotsFired[id] * g_iShotsFired[id]) / c_flAccuracy[iBteWpn][0]) + c_flAccuracy[iBteWpn][1];

			if (g_flAccuracy[id] < c_flAccuracyRange[iBteWpn][0])
				g_flAccuracy[id] = c_flAccuracyRange[iBteWpn][0];
			else if (g_flAccuracy[id] > c_flAccuracyRange[iBteWpn][1])
				g_flAccuracy[id] = c_flAccuracyRange[iBteWpn][1];
		}
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_SPSMG)
	{
		
	}

	pev(id, pev_punchangle, g_punchangle[id]);

	return PrimaryAttackSpecialWeapon(id, iEnt, iClip, iBteWpn);
}

public PrimaryAttackSpecialWeapon(id, iEnt, iClip, iBteWpn)
{
	if (c_iType[iBteWpn] == WEAPONS_M134 && iClip)
	{
		if (pev(id, pev_weaponanim) != 4)
		{
			SendWeaponAnim(id, 4);

			set_pdata_float(iEnt, m_flTimeWeaponIdle, 60.0);
		}
		return HAM_IGNORED;
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BALROG11 && iClip)
	{
		if (GetExtraAmmo(iEnt) < c_iExtraAmmo[iBteWpn])
		{
			new iShotsFired = pev(iEnt, pev_iuser1);
			iShotsFired ++;

			if (iShotsFired >= 4)
			{
				iShotsFired = 0;
				SetExtraAmmo(id, iEnt, GetExtraAmmo(iEnt) + 1);

				emit_sound(iEnt, CHAN_WEAPON, "weapons/balrog9_charge_finish1.wav", 1.0, ATTN_NORM, 0, 93 + random_num(0, 0xf));
			}

			set_pev(iEnt, pev_iuser1, iShotsFired);
		}

		return HAM_IGNORED
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_M16A1)
	{
		if (!(get_pdata_int(iEnt, m_iWeaponState) & WPNSTATE_M16A1_SEMIAUTO))
			return HAM_IGNORED;

		if (get_pdata_int(iEnt, m_iShotsFired) > 0)
		{
			set_pdata_float(iEnt, m_flDecreaseShotsFired, 0.0);

			return HAM_SUPERCEDE;
		}
	}
	else if (c_iType[iBteWpn] == WEAPONS_SINGLE)
	{
		if (get_pdata_int(iEnt, m_iShotsFired) > 0)
		{
			set_pdata_float(iEnt, m_flDecreaseShotsFired, 0.0);

			return HAM_SUPERCEDE;
		}
	}
	else if (c_iType[iBteWpn] == WEAPONS_BAZOOKA || c_iSpecial[iBteWpn] == SPECIAL_M79 || c_iSpecial[iBteWpn] == SPECIAL_FIRECRAKER)
	{
		WE_Launcher(id, iEnt, iClip, iBteWpn);

		return HAM_SUPERCEDE;
	}
	else if (c_iType[iBteWpn] == WEAPONS_M32)
	{
		WE_M32(id, iEnt, iClip, iBteWpn);

		return HAM_SUPERCEDE;
	}
	else if (c_iType[iBteWpn] == WEAPONS_FLAMETHROWER)
	{
		WE_FlameThrower(id, iEnt, iClip, iBteWpn);

		return HAM_SUPERCEDE;
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_PLASMA)
	{
		WE_Plasma(id, iEnt, iClip, iBteWpn);

		return HAM_SUPERCEDE;
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_CROSSBOW)
	{
		CCrossbow_Primaryattack(id, iEnt, iClip, iBteWpn);

		return HAM_SUPERCEDE;
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_PETROLBOOMER)
	{
		WE_PetrolBoomer(id, iEnt, iClip, iBteWpn);

		return HAM_SUPERCEDE;
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_SFPISTOL)
	{
		WE_SfPistol(id, iEnt, iClip, iBteWpn);

		return HAM_SUPERCEDE;
	}
	else if (c_iType[iBteWpn] == WEAPONS_SVDEX)
	{
		if (!(get_pdata_int(iEnt, m_iWeaponState) & WPNSTATE_SVDEX_GRENADE))
			return HAM_IGNORED;

		WE_Svdex(id, iEnt, iClip, iBteWpn);

		return HAM_SUPERCEDE;
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_CANNON)
	{
		CCannon_PrimaryAttack(id, iEnt, iClip, iBteWpn);

		return HAM_SUPERCEDE;
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_CANNONEX)
	{
		CCannonex_PrimaryAttack(id, iEnt, iClip, iBteWpn);

		return HAM_SUPERCEDE;
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_RPG)
	{
		RPG7_PrimaryAttack(id, iEnt, iClip, iBteWpn);

		return HAM_SUPERCEDE;
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BUFFAK47)
	{
		if (get_pdata_int(id, m_iFOV) != 90)
		{
			CBuffAK47_AmmoAttack(id, iEnt, iClip, iBteWpn);

			return HAM_SUPERCEDE;
		}
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_GUILLOTINE)
	{
		CGuillotine_PrimaryAttack(id, iEnt, iClip, iBteWpn);
		return HAM_SUPERCEDE;
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUSMK5)
	{
		return CJanusmk5_PrimaryAttack(id, iEnt, iClip, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUS7)
	{
		return CJanus7_PrimaryAttack(id, iEnt, iClip, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_DESPERADO)
	{
		CDesperado_PrimaryAttack(id, iEnt, iClip, iBteWpn);
		return HAM_SUPERCEDE;
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_GUNKATA)
	{
		CGunkata_PrimaryAttack(id, iEnt, iClip, iBteWpn);
		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED
}

public HamF_Weapon_PrimaryAttack_Post(iEnt)
{
	static id, iId, iClip, iWeaponState, Float:flNextAttack, Float:flTimeWeaponIdle, iBteWpn;
	id = get_pdata_cbase(iEnt,m_pPlayer);
	iId = get_pdata_int(iEnt, m_iId);
	iClip = get_pdata_int(iEnt, m_iClip);
	iWeaponState = get_pdata_int(iEnt, m_iWeaponState);

	iBteWpn = g_weapon[id][0] + g_double[id][0];

	if (c_iAccuracyCalculate[iBteWpn])
		set_pdata_float(iEnt, m_flAccuracy, g_flAccuracy[id]);

	if (iId == CSW_SG550 || iId == CSW_G3SG1)
	{
		set_pdata_int(iEnt, m_iShotsFired, get_pdata_int(iEnt, m_iShotsFired) + 1);
	}

	if (c_flRecoil[iBteWpn])
	{
		new Float:punchangle[3];
		pev(id, pev_punchangle, punchangle);
		xs_vec_sub(punchangle, g_punchangle[id], punchangle);
		//xs_vec_normalize(punchangle, punchangle); // cause BUG
		xs_vec_mul_scalar(punchangle, c_flRecoil[iBteWpn], punchangle);
		xs_vec_add(g_punchangle[id], punchangle, g_punchangle[id]);
		set_pev(id, pev_punchangle, g_punchangle[id]);
	}

	if (g_attacking[id]) // If Attacking
	{
		if (bte_get_user_zombie(id) == 1 && iId == CSW_HEGRENADE && !g_grenade[id])
		{
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.36, 4);
			g_grenade[id] = 1;
		}

		if (c_iType[iBteWpn] == WEAPONS_SHOTGUN_RELOAD)
			set_pdata_int(iEnt, m_fInSpecialReload, FALSE);

		if (c_flEjectBrass[iBteWpn] < 0.0)
			set_pdata_float(id, m_flEjectBrass, 0.0);
		else if (c_flEjectBrass[iBteWpn] > 0.0)
			set_pdata_float(id, m_flEjectBrass, get_gametime() + c_flEjectBrass[iBteWpn]);

		/*if ((iId == CSW_M3 || iId == CSW_XM1014) && !iClip)
			set_pdata_float(iEnt, m_flTimeWeaponIdle, iId == CSW_XM1014 ? 0.75 : 0.875);*/

		if (c_iType[g_weapon[id][0]] == WEAPONS_SPSHOOT && iClip)
		{
			set_pdata_int(iEnt, m_iFamasShotsFired, 10);
			set_pdata_float(iEnt, m_flFamasShoot, get_gametime() + c_flBurstSpeed[g_weapon[id][0]]);
		}

		if ((c_iSpecial[iBteWpn] == SPECIAL_FIXSHOOT || (c_iSpecial[iBteWpn] == SPECIAL_SKULL3 && g_double[id][0])))
		{
			if (!(iClip & 1))
				set_pdata_int(iEnt, m_iWeaponState, 0);
			else
				set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_ELITE_LEFT);

			if (iWeaponState & WPNSTATE_ELITE_LEFT)
			{
				OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK2);
				set_pdata_int(iEnt, m_iWeaponState, 0);
			}
			else
			{
				OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
				set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_ELITE_LEFT);
			}

			if (!iClip)
				set_pdata_float(iEnt, m_flTimeWeaponIdle, 60.0);
		}

		if (c_iType[iBteWpn] == WEAPONS_PISTOL)
		{
			set_pdata_int(iEnt, m_iShotsFired, 0);
		}

		/*fRecoil = (g_double[id][0] == 0?c_recoil[g_weapon[id][0]]:c_d_recoil[g_weapon[id][0]])
		if (c_iSpecial[g_weapon[id][0]] == SPECIAL_SPAS12EX)
		{
			fRecoil *= c_d_recoil[g_weapon[id][0]]
		}
		if (c_iSpecial[g_weapon[id][0]] == SPECIAL_M2 && g_iWeaponMode[id][1])
			fRecoil = 0.1;*/

		new iType = GetWeaponModePrimaryAttack(id, iEnt, iWeaponState, iBteWpn);

		flNextAttack = c_flAttackInterval[iBteWpn][iType];
		flTimeWeaponIdle = c_flShootAnimTime[iBteWpn][iType];

		if (flNextAttack)
		{
			if (!(iWeaponState & (WPNSTATE_FAMAS_BURST_MODE | WPNSTATE_GLOCK18_BURST_MODE)))
				set_pdata_float(iEnt, m_flNextPrimaryAttack, flNextAttack);
		}

		if (flTimeWeaponIdle)
			set_pdata_float(iEnt, m_flTimeWeaponIdle, flTimeWeaponIdle);

		PrimaryAttackPostSpecialWeapon(id, iEnt, iId, iClip, iBteWpn);
	}

	g_attacking[id] = 0

	return HAM_IGNORED;
}
public GetWeaponModePrimaryAttack(id, iEnt, iWeaponState, iBteWpn)
{
	if (get_pdata_int(id, m_iFOV) < 90) return 1;

	if (iWeaponState & WPNSTATE_M4A1_SILENCED) return 1;
	if (iWeaponState & WPNSTATE_USP_SILENCED) return 1;

	if (c_iSpecial[iBteWpn] == SPECIAL_SKULL11 && iWeaponState & WPNSTATE_SKULL11_SLUG) return 1;
	if (c_iSpecial[iBteWpn] == SPECIAL_M1GARAND && iWeaponState & WPNSTATE_M1GARAND_AIMING) return 1;

	//if (c_iSpecial[iBteWpn] == SPECIAL_SPAS12EX && g_spas12_stat[id]) return 1;

	if (c_iSpecial[iBteWpn] == SPECIAL_JANUSMK5 && pev(iEnt, pev_iuser1) == JANUSMK5_USING) return 1;
	if (c_iSpecial[iBteWpn] == SPECIAL_JANUS7 && pev(iEnt, pev_iuser1) == JANUSMK5_USING) return 1;
	if (c_iSpecial[iBteWpn] == SPECIAL_JANUS11 && pev(iEnt, pev_iuser1) == JANUSMK5_USING) return 1;																							 
	if (c_iSpecial[iBteWpn] == SPECIAL_M2 && g_iWeaponMode[id][1]) return 1;

	//if (g_bl3_num[id] > 15) return 1;

	return 0;
}

public PrimaryAttackPostSpecialWeapon(id, iEnt, iId, iClip, iBteWpn)
{
	if (c_iSpecial[iBteWpn] == SPECIAL_JANUS11 && pev(iEnt, pev_iuser1) == JANUSMK5_USING)
	{
		iClip += 1;
		set_pdata_int(iEnt, m_iClip, iClip);

		//LaserBeam(id , 2 , 0 , 40 , 200)

	}																				   
	if (c_iSpecial[iBteWpn] == SPECIAL_BALROG3)
	{
		//WE_Balrog3(id,iEnt,iId)
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_BALROG7)
	{
		CBalrog7_PrimaryAttack_Post(id, iEnt, iId, iClip, iBteWpn)
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_M1GARAND)
	{
		if (!iClip)
			set_pdata_float(iEnt, m_flNextPrimaryAttack, (get_pdata_int(iEnt, m_iWeaponState) & WPNSTATE_M1GARAND_AIMING) ? 0.8 : 0.43);
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_BUFFAWP)
	{
		CBuffAWP_PrimaryAttack_Post(iEnt)
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_BLOODHUNTER)
	{
		CBloodhunter_PrimaryAttack_Post(id, iEnt, iClip, iBteWpn)
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_INFINITY)
	{
		CInfinity_PrimaryAttack_Post(id, iEnt, iClip, iBteWpn)
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_BLOCKSMG)
	{
		CBlockSMG_PrimaryAttack_Post(id, iEnt, iClip, iBteWpn)
	}
}

public HamF_Item_PostFrame(iEnt)
{
	static id,iBpAmmo,iClip,/*iSlot,*/iAmmoType,iInReload,Float:fNextAttack,iMaxClip,iTemp,iId,iButton, iBteWpn //,iInSpecialReload
	id = get_pdata_cbase(iEnt, m_pPlayer, 4)

	iBteWpn = g_weapon[id][0] + g_double[id][0];

	iId = get_pdata_int(iEnt,m_iId,4)
	//iSlot = ExecuteHam(Ham_Item_ItemSlot,iEnt)
	iClip = get_pdata_int(iEnt, m_iClip, 4)
	iAmmoType = m_rgAmmo_player_Slot0 + get_pdata_int(iEnt, m_iPrimaryAmmoType, 4)
	iBpAmmo = get_pdata_int(id, iAmmoType, 5)
	iInReload = get_pdata_int(iEnt, m_fInReload, 4)
	fNextAttack = get_pdata_float(id, m_flNextAttack, 5)
	iButton = pev(id,pev_button);
	iMaxClip = c_iClip[iBteWpn];

	if (!CanPlayerAttack(id))
	{
		if (iButton & IN_ATTACK)
			iButton &= ~IN_ATTACK;
		if (iButton & IN_ATTACK2)
			iButton &= ~IN_ATTACK2;
		set_pev(id, pev_button, iButton);
	}

	if (iClip == iMaxClip || !iBpAmmo)
	{
		if ((c_iSpecial[iBteWpn] != SPECIAL_CHAINSAW) && (c_iSpecial[iBteWpn] != SPECIAL_RAILCANNON || !pev(iEnt, pev_iuser1)) && (c_iSpecial[iBteWpn] != SPECIAL_BOW))
		{
			if (iButton & IN_RELOAD)
				iButton &= ~IN_RELOAD;
			set_pev(id, pev_button, iButton);
		}
	}


	if (c_iType[g_weapon[id][0]] == WEAPONS_SPSHOOT)
	{
		if (get_pdata_int(iEnt, m_iFamasShotsFired) >= 9 + c_iBurstTimes[g_weapon[id][0]])
		{
			set_pdata_int(iEnt, m_iFamasShotsFired, 10);
			set_pdata_float(iEnt, m_flFamasShoot, 0.0);
		}
	}

	if (CSWPN_SHOTGUNS & (1<<iId) && c_iType[g_weapon[id][0]] != WEAPONS_SHOTGUN)
	{
		WpnEffect_Shotguns(id,iEnt,iClip,iBpAmmo,iId);

	}

	if (iInReload && fNextAttack <= 0.0)
	{
		iTemp = min(iMaxClip - iClip, iBpAmmo)
		set_pdata_int(iEnt, m_iClip, iClip + iTemp, 4)
		set_pdata_int(id, iAmmoType, iBpAmmo - iTemp, 5)
		set_pdata_int(iEnt, m_fInReload, 0, 4)
		set_pdata_int(iEnt, m_fInSpecialReload, 0, 4)

		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.01); // Fix bug
		set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.01);
	}
	if (fNextAttack < 0.0 && g_dchanging[id])
	{
		g_dchanging[id] = 0
		g_double[id][0] = 1 - g_double[id][0];

		iBteWpn = g_weapon[id][0] + g_double[id][0];

		set_pdata_int(iEnt, m_iClip, c_iClip[iBteWpn]);
	}


	if (iButton & IN_ATTACK2 && c_iSpecial[iBteWpn] != SPECIAL_BUFFAWP)
		CheckZoom(id, iEnt, iBteWpn);

	// !! Weapon Effect
	WpnEffect(id, iEnt, iClip, iBpAmmo, iId);

	return HAM_IGNORED;
}

stock CanReload(iEnt, iBteWpn)
{
	new bCanReload = (c_iType[iBteWpn] != WEAPONS_LAUNCHER && c_iSpecial[iBteWpn] != SPECIAL_SFSNIPER && c_iSpecial[iBteWpn] != SPECIAL_M200);

	if (c_iSpecial[iBteWpn] == SPECIAL_JANUSMK5 || c_iSpecial[iBteWpn] == SPECIAL_JANUS7  || c_iSpecial[iBteWpn] == SPECIAL_JANUS11)
	{
		new iState = pev(iEnt, pev_iuser1);
		bCanReload = (iState != JANUSMK5_USING);
	}

	if (c_iType[iBteWpn] == WEAPONS_SVDEX)
		bCanReload = !(get_pdata_int(iEnt, m_iWeaponState) & WPNSTATE_SVDEX_GRENADE);

	return bCanReload;
}

stock SetCanReload(id, bCanReload)
{
	g_bCanReload[id] = bCanReload;
	/*new iWeaponState = get_pdata_int(iEnt, m_iWeaponState);

	if (!bCanReload)
		iWeaponState |= WPNSTATE_SHIELD_DRAWN;
	else
		iWeaponState &= ~WPNSTATE_SHIELD_DRAWN;

	set_pdata_int(iEnt, m_iWeaponState, iWeaponState);*/
}

public HamF_Weapon_Reload_Shotgun(iEnt)
{
	static id, iId, iClip, iMaxClip, fInSpecialReload, iBpAmmo, iBteWpn;
	id = get_pdata_cbase(iEnt, m_pPlayer);
	iId = get_pdata_int(iEnt, m_iId);
	iClip = get_pdata_int(iEnt, m_iClip);
	iBpAmmo = get_pdata_int(id, m_rgAmmo[get_pdata_int(iEnt, m_iPrimaryAmmoType)]);
	fInSpecialReload = get_pdata_int(iEnt, m_fInSpecialReload);

	iBteWpn = g_weapon[id][0];
	iMaxClip = c_iClip[iBteWpn];

	//new iState = pev(iEnt, pev_iuser1);								
	if (c_iSpecial[iBteWpn] == SPECIAL_RAILCANNON)
	{
		new iCharge = pev(iEnt, pev_iuser1);
		if(iCharge)
			return HAM_SUPERCEDE;
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_CROW7)
	{
		CCrow7_Reload(id, iEnt, iBteWpn);
		return HAM_SUPERCEDE;
	}
	
	if (!g_bCanReload[id] || iClip == c_iClip[iBteWpn])
	{
		set_pdata_int(iEnt, m_fInReload, FALSE);
		set_pdata_int(iEnt, m_fInSpecialReload, FALSE);
		set_pdata_float(iEnt, m_flNextReload, 0.01);	// Fix bug
		return HAM_SUPERCEDE;
	}

	set_pdata_int(id, m_iFOV, 90);
	set_pev(id, pev_fov, 90.0);

	if (c_iType[iBteWpn] == WEAPONS_SHOTGUN)
	{
		if (!iBpAmmo || iMaxClip == iClip)
			return HAM_SUPERCEDE;

		new Float:flReload, Float:flTimeWeaponIdle;
		flReload = c_flReload[iBteWpn][0];
		flTimeWeaponIdle = c_flReloadAnimTime[iBteWpn][0];

		if (!flTimeWeaponIdle)
			flTimeWeaponIdle = flReload + 0.5;

		OrpheuCall(handleSetAnimation, id, PLAYER_RELOAD);
																		  
		SendWeaponAnim(id, c_iReloadAnim[iBteWpn][0]);

		set_pdata_float(id, m_flNextAttack, flReload);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, flTimeWeaponIdle);
		set_pdata_int(iEnt, m_fInReload, 1);
		set_pdata_int(iEnt, m_fInSpecialReload, 0);

		return HAM_SUPERCEDE;
	}

	ShotgunReload(iEnt, iId, iMaxClip, iClip, iBpAmmo, id, iBteWpn, fInSpecialReload);

	return HAM_SUPERCEDE;
}

public HamF_Weapon_WeaponIdle_Shotgun(iEnt)
{
	static id, iId, iClip, iMaxClip, fInSpecialReload, iBpAmmo, Float:flTimeWeaponIdle, iBteWpn;
	id = get_pdata_cbase(iEnt, m_pPlayer);
	iId = get_pdata_int(iEnt, m_iId);
	iBteWpn = g_weapon[id][0];
	flTimeWeaponIdle = get_pdata_float(iEnt, m_flTimeWeaponIdle);

	new iState = pev(iEnt, pev_iuser1);								
	if (c_iType[iBteWpn] == WEAPONS_SHOTGUN)
	{
		if (flTimeWeaponIdle > 0.0)
			return HAM_SUPERCEDE;

		set_pdata_float(iEnt, m_flTimeWeaponIdle, 60.0);
		if (c_iSpecial[iBteWpn] == SPECIAL_JANUS11)
		{	
			SendWeaponAnim(id, c_iIdleAnim[iBteWpn][iState]);
		}
		else
		{
			SendWeaponAnim(id, SHOTGUN_idle);
		}
		
		return HAM_SUPERCEDE;
	}

	if (flTimeWeaponIdle <= 0.0)
	{
		iClip = get_pdata_int(iEnt, m_iClip);
		fInSpecialReload = get_pdata_int(iEnt, m_fInSpecialReload);
		iBpAmmo = get_pdata_int(id, m_rgAmmo[get_pdata_int(iEnt, m_iPrimaryAmmoType)]);
		iMaxClip = c_iClip[iBteWpn];

		if (iClip == 0 && fInSpecialReload == 0 && iBpAmmo)
		{
			ShotgunReload(iEnt, iId, iMaxClip, iClip, iBpAmmo, id, iBteWpn, fInSpecialReload);
		}
		else if (fInSpecialReload != 0)
		{
			if (iClip != iMaxClip && iBpAmmo)
			{
				ShotgunReload(iEnt, iId, iMaxClip, iClip, iBpAmmo, id, iBteWpn, fInSpecialReload);
			}
			else  // after reload
			{
				if (c_iSpecial[iBteWpn] == SPECIAL_JANUS11)
				{
					SendWeaponAnim(id, c_iReloadAnim[iBteWpn][iState] + 1);
				}
				else
				{
					SendWeaponAnim(id, c_iReloadAnim[iBteWpn][1]);
				}

				set_pdata_int(iEnt, m_fInSpecialReload, 0);
				set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flReloadAnimTime[iBteWpn][1]);

				if (c_flReload[iBteWpn][1])
				{
					set_pdata_float(id, m_flNextAttack, c_flReload[iBteWpn][1]);
					set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flReload[iBteWpn][1]);
					set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flReload[iBteWpn][1]);
				}
			}
		}
		else
		{
			if (c_iSpecial[iBteWpn] == SPECIAL_JANUS11)
			{	
				SendWeaponAnim(id, c_iIdleAnim[iBteWpn][iState]);
			}
			else		
			{
				SendWeaponAnim(id, SHOTGUN_idle);
			}			
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 60.0);
		}
	}

	return HAM_SUPERCEDE;
}

public ShotgunReload(iEnt, iId, iMaxClip, iClip, iBpAmmo, id, iBteWpn, fInSpecialReload)
{
	if (iBpAmmo <= 0 || iClip == iMaxClip)
		return;

	if (get_pdata_int(iEnt, m_flNextPrimaryAttack, 4) > 0.0)
		return;

	new iState = pev(iEnt, pev_iuser1);							 
	if (!fInSpecialReload)
	{
		OrpheuCall(handleSetAnimation, id, PLAYER_RELOAD);
				
		if (c_iSpecial[iBteWpn] == SPECIAL_JANUS11) // start reload
		{
			SendWeaponAnim(id, c_iReloadAnim[iBteWpn][iState] + 2);
		}
		else														  
			SendWeaponAnim(id, c_iReloadAnim[iBteWpn][2]);

		set_pdata_int(iEnt, m_fInSpecialReload, 1);
		set_pdata_float(id, m_flNextAttack, c_flReload[iBteWpn][2]);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flReloadAnimTime[iBteWpn][2]);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flReload[iBteWpn][2]);
		set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flReload[iBteWpn][2]);
	}
	else if (fInSpecialReload == 1)
	{
		if (get_pdata_float(iEnt, m_flTimeWeaponIdle) > 0.0)
			return;

		set_pdata_int(iEnt, m_fInSpecialReload, 2);
		if (c_iSpecial[iBteWpn] == SPECIAL_JANUS11) // insert
		{
			SendWeaponAnim(id, c_iReloadAnim[iBteWpn][iState]);
		}
		else															  
			SendWeaponAnim(id, c_iReloadAnim[iBteWpn][0]);

		set_pdata_float(iEnt, m_flNextReload, c_flReload[iBteWpn][0]);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flReloadAnimTime[iBteWpn][0]);
	}
	else
	{
		set_pdata_int(iEnt, m_iClip, iClip + 1);
		set_pdata_int(id, m_rgAmmo[get_pdata_int(iEnt, m_iPrimaryAmmoType)], iBpAmmo - 1);
		set_pdata_int(iEnt, m_fInSpecialReload, 1);
		set_pdata_int(id, ammo_buckshot, get_pdata_int(id, ammo_buckshot) - 1);
	}
}

public ReloadSpecialWeapon(id, iEnt, iBteWpn)
{
	/*if (g_bl1_mode[id] == 1)
	{
		g_bl1_mode[id] = 0
	}*/

	if (c_iSpecial[iBteWpn] == SPECIAL_BALROG11)
		set_pev(iEnt, pev_iuser1, 0);

	if (c_iSpecial[iBteWpn] == SPECIAL_AIRBURSTER)
		set_pev(iEnt, pev_iuser2, 0);

	if (c_iSpecial[iBteWpn] == SPECIAL_SFPISTOL)
	{
		engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 0, 0, TRUE, FALSE);
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_INFINITY)
	{
		set_pev(iEnt, pev_iuser3, pev(iEnt, pev_iuser3) + 1);
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_BLOCKSMG)
	{
		set_pdata_int(iEnt, m_iWeaponState, (get_pdata_int(iEnt, m_iWeaponState) & ~WPNSTATE_ELITE_LEFT));
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_SGDRILL)
		set_pev(iEnt, pev_fuser1, 0.0);
}

public GetWeaponModeReload(id, iId, iEnt, iBteWpn)
{
	static iWeaponState, iClip;
	iWeaponState = get_pdata_int(iEnt, m_iWeaponState);
	iClip = get_pdata_int(iEnt, m_iClip)

	if (iWeaponState & WPNSTATE_M4A1_SILENCED) return 1;
	if (iWeaponState & WPNSTATE_USP_SILENCED) return 1;
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUSMK5 || c_iSpecial[g_weapon[id][0]] == SPECIAL_JANUS7 || c_iSpecial[iBteWpn] == SPECIAL_JANUS11) return pev(iEnt, pev_iuser1);
	else if (c_iSpecial[iBteWpn] == SPECIAL_M2) return g_iWeaponMode[id][1];
	else if (c_iSpecial[iBteWpn] == SPECIAL_SKULL3 && iId == c_iId[g_weapon[id][0] + 1]) return 1;
	//else if (g_bl1_mode[id] == 1) return 1;
	else if (c_iSpecial[iBteWpn] == SPECIAL_MAUSERC96) return iClip ? 0 :1;
	else if (c_iSpecial[iBteWpn] == SPECIAL_BLOODHUNTER) return pev(iEnt, pev_iuser1);
	else if (c_iSpecial[iBteWpn] == SPECIAL_DESPERADO) return pev(iEnt, pev_iuser1);

	return 0;
}

public HamF_Weapon_Reload_Post(iEnt)
{
	static id, iBteWpn;
	id = get_pdata_cbase(iEnt, m_pPlayer);
	iBteWpn = g_weapon[id][0] + g_double[id][0];

	if (get_pdata_int(iEnt, m_iShotsFired) == 0 && c_flAccuracyDefault[iBteWpn])
		set_pdata_float(iEnt, m_flAccuracy, c_flAccuracyDefault[iBteWpn]);
}

public HamF_Weapon_Reload(iEnt)
{
	static id, iAmmoType, iAmmo, iClip, iInReload, Float:flReload, Float:flTimeWeaponIdle, iId, iBteWpn
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	iAmmoType = get_pdata_int(iEnt, m_iPrimaryAmmoType, 4);
	iAmmo = get_pdata_int(id, m_rgAmmo_player_Slot0 + iAmmoType);
	iInReload = get_pdata_int(iEnt, m_fInReload, 4);
	iClip = get_pdata_int(iEnt, m_iClip,4);
	iId = get_pdata_int(iEnt, m_iId);

	iBteWpn = g_weapon[id][0] + g_double[id][0];

	if (c_iType[iBteWpn] == WEAPONS_SHOTGUN_RELOAD)
	{
		HamF_Weapon_Reload_Shotgun(iEnt);

		return HAM_SUPERCEDE;
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_CROW7)
	{
		CCrow7_Reload(id, iEnt, iBteWpn);
		return HAM_SUPERCEDE;
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_CROW1)
	{
		CCrow1_Reload(id, iEnt, iBteWpn);
		return HAM_SUPERCEDE;
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_DESPERADO)
	{
		CDesperado_Reload(id, iEnt, iClip, iBteWpn);
		return HAM_SUPERCEDE;
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_GUNKATA)
	{
		CGunkata_Reload(id, iEnt, iClip, iBteWpn);
		return HAM_SUPERCEDE;
	}

	if (iAmmo <= 0)
		return HAM_IGNORED;

	if (!g_bCanReload[id] || iClip == c_iClip[iBteWpn])
	{
		set_pdata_int(iEnt, m_fInReload, FALSE);
		set_pdata_float(iEnt, m_flNextReload, 0.01);	// Fix bug
		return HAM_SUPERCEDE;
	}

	if (!iInReload)
	{
		OrpheuCall(handleSetAnimation, id, PLAYER_RELOAD);

		if (get_pdata_int(id, m_iFOV) != 90 && c_iSpecial[iBteWpn] != SPECIAL_BUFFAK47 && c_iSpecial[iBteWpn] != SPECIAL_BUFFM4A1)
		{
			set_pdata_int(id, m_iFOV, 90);
			set_pev(id, pev_fov, 90.0);

			ExecuteHam(Ham_Player_ResetMaxSpeed, id);
		}

		new iType = 0;
		iType = GetWeaponModeReload(id, iId, iEnt, iBteWpn);

		flReload = c_flReload[iBteWpn][iType] ? c_flReload[iBteWpn][iType] : WEAPON_DELAY[c_iId[iBteWpn]];

		flTimeWeaponIdle = c_flReloadAnimTime[iBteWpn][iType] ? c_flReloadAnimTime[iBteWpn][iType] : flReload + 0.5;

		set_pdata_float(id, m_flNextAttack, flReload);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, flTimeWeaponIdle);
		set_pdata_int(iEnt, m_fInReload, 1);

		new iAnim = c_iReloadAnim[iBteWpn][iType];
		if (iAnim == -1)
		{
			if (iType == 1 && (iId == CSW_USP || iId == CSW_M4A1))
				iAnim = (WEAPON_TOTALANIM[c_iId[iBteWpn]]/2)-3;
			else
				iAnim = RELOAD_ANIM[c_iId[iBteWpn]];
		}

		SendWeaponAnim(id, iAnim);

		ReloadSpecialWeapon(id, iEnt, iBteWpn);

		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}
public HamF_Item_Holster_Post(iEnt)
{
	static id ; id = get_pdata_cbase(iEnt, m_pPlayer, 4)

	if (!is_user_alive(id))
		return HAM_IGNORED

	static iId ; iId = get_pdata_int(iEnt, m_iId, 4)
	static iSlot ; iSlot = ExecuteHam(Ham_Item_ItemSlot,iEnt)
	static iClip ; iClip = get_pdata_int(iEnt, m_iClip,4)
	static iBpAmmo;

	static iBteWpn; iBteWpn = g_weapon[id][0] + g_double[id][0];
	
	if (c_iSpecial[iBteWpn] == SPECIAL_CANNONEX)
	{
		set_pev(iEnt, pev_fuser1, 0.0);
		CCannonex_Holster(id, iEnt, iId, iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BUFFAWP)
	{
		CBuffAWP_Holster_Post(iEnt)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_CANNON)
	{
		CCannon_Holster(id, iEnt, iId, iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_CROW7)
	{
		CCrow7_Holster(id, iEnt, iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_CROW1)
	{
		CCrow1_Holster(id, iEnt, iBteWpn)
	}
	
	if (iId == CSW_KNIFE)
		CKnife_Holster(iEnt);

	if (id && iSlot < 5)
	{
		Pub_Holster_Reset(id, iEnt)

		iBpAmmo = 0;
		if (iSlot != 4)
			iBpAmmo = Stock_Config_User_Bpammo(id,iId,0,0)

		Stock_Store_Wpn_Current(id, iSlot, iClip, iBpAmmo)
		Stock_Reset_Wpn_Slot(id, 0)
	}
	return HAM_IGNORED
}


#if 0
public HamF_Set_Player_Maxspeed_Post(id)
{
	if (!is_user_alive(id)) return HAM_IGNORED
	if (g_freezetime)
	{
		set_pev(id,pev_maxspeed,0.1)
		return HAM_IGNORED
	}
	/*if (!g_fPlrMaxspeed[id])
	{
		g_fPlrMaxspeed[id] = 250.0;
	}

	new Float:fCurTime;
	global_get(glb_time, fCurTime);

	if (fNextMaxSpeedReset[id] > fCurTime)
	{
		set_pev(id, pev_maxspeed, fMaxSpeed[id]);
	}
	else
	{
		if (g_stop_next[id] > fCurTime && g_stop_speed[id])
			set_pev(id, pev_maxspeed, g_stop_speed[id]);
		else
			set_pev(id,pev_maxspeed,g_fPlrMaxspeed[id]);
	}*/

	return HAM_IGNORED;
}
#endif

public HamF_AddPlayerItem(id, iEnt)
{
	static iId; iId = get_pdata_int(iEnt, m_iId, 4)
	static iSlot; iSlot = ExecuteHam(Ham_Item_ItemSlot,iEnt)
	static iDouble; iDouble = Get_Wpn_Data(iEnt,DEF_ISDOUBLE)

	if (g_modruning == BTE_MOD_ZB1)
	{
		if (iId == CSW_C4/* || iId == CSW_FLASHBANG || iId == CSW_SMOKEGRENADE*/) return HAM_SUPERCEDE
	}

	if (!(CSWPN_NOTREMOVE & (1<<iId)))
	{
		if (Get_Wpn_Data(iEnt, DEF_ID))
			g_weapon[id][iSlot] = Get_Wpn_Data(iEnt, DEF_ID);

		Set_Wpn_Data(iEnt, DEF_ID, g_weapon[id][iSlot]);

		static iBteWpn;
		iBteWpn = g_weapon[id][iSlot];

		// Set Ammo
		if (Get_Wpn_Data(iEnt,DEF_ISDROPPED))
			g_user_ammo[id][iSlot] = Get_Wpn_Data(iEnt, DEF_AMMO);

		// Update Clip if needed
		if (Get_Wpn_Data(iEnt,DEF_CLIP))
			g_user_clip[id][iSlot] = Get_Wpn_Data(iEnt, DEF_CLIP);

		// If Pickup a double weapon
		if (c_iType[iBteWpn] == WEAPONS_DOUBLE && Get_Wpn_Data(iEnt, DEF_ISDROPPED))
		{
			/*ExecuteHam(Ham_AddPlayerItem, id, iEnt);

			new iEnt2, iDouble;
			iDouble = Get_Wpn_Data(iEnt, DEF_ISDOUBLE);

			if (iId == c_iId[iBteWpn + 1])
			{
				iEnt2 = iEnt;
				iEnt = Stock_Give_Cswpn(id, iBteWpn, WEAPON_NAME[c_iId[iBteWpn]]);
			}
			else
			{
				iEnt2 = Stock_Give_Cswpn(id, iBteWpn, WEAPON_NAME[c_iId[iBteWpn + 1]], 1);
			}

			g_double[id][0] = g_double[id][1] = iDouble;
			g_dchanging[id] = 0;

			set_pdata_float(id, m_flNextAttack, 0.0);

			if (g_double[id][0])
				ExecuteHamB(Ham_Item_Deploy, iEnt2);
			else
				ExecuteHamB(Ham_Item_Deploy, iEnt);*/

			new iDouble;
			iDouble = Get_Wpn_Data(iEnt, DEF_ISDOUBLE);

			Stock_Give_Cswpn(id, iBteWpn, WEAPON_NAME[c_iId[iBteWpn]])
			Stock_Give_Cswpn(id, iBteWpn, WEAPON_NAME[c_iId[iBteWpn + 1]], 1);

			g_double[id][0] = g_double[id][1] = iDouble;

			client_cmd(id, "%s", WEAPON_NAME[c_iId[iBteWpn + iDouble]]);

			return HAM_SUPERCEDE;
		}

		static sTxt[32]
		if (iDouble)
		{
			format(sTxt,31,"weapon_%s_2", c_sModel[iBteWpn])
			message_begin(MSG_ONE,g_msgWeaponList, {0,0,0}, id);
			write_string(sTxt)
			write_byte(WEAPON_AMMOID[c_iId[iBteWpn + 1]])
			write_byte(c_iMaxAmmo[g_weapon[id][iSlot]])
			write_byte(-1)
			write_byte(-1)
			write_byte(c_iSlot[iBteWpn] - 1)
			write_byte(CSWPN_POSITION[c_iId[iBteWpn + 1]])
			write_byte(c_iId[iBteWpn + 1])
			write_byte(0)
			message_end()
		}
		else
		{
			format(sTxt,31,"weapon_%s", c_sModel[iBteWpn])
			message_begin(MSG_ONE,g_msgWeaponList, {0,0,0}, id);
			write_string(sTxt)
			write_byte(WEAPON_AMMOID[iId])
			write_byte(c_iMaxAmmo[iBteWpn])
			write_byte(-1)
			write_byte(-1)
			write_byte(c_iSlot[iBteWpn]-1)
			write_byte(CSWPN_POSITION[iId])
			write_byte(iId)
			write_byte(0)
			message_end()
		}

		if (c_iSpecial[g_weapon[id][iSlot]] == SPECIAL_M2)
		{
			set_pev(iEnt, pev_iuser4, 0);
			set_pev(iEnt, pev_fuser1, 0.0);
			g_iWeaponMode[id][1] = 0;
		}

	}
	return HAM_IGNORED;
}
public HamF_Spawn_Player_Post(id)
{
	if (!is_user_alive(id)) return HAM_IGNORED

	//if (is_user_bot(id)) Stock_ResetBotMoney(id)

	if (g_modruning != BTE_MOD_ZB1)
	{
		for(new i=1;i<5;i++)
		{
			if (get_pdata_cbase(id, m_rgpPlayerItems+i, 5) < 1)
			{
				/*if (g_modruning != BTE_MOD_TD) */
				Stock_Reset_Wpn_Slot(id,i)
				if (bte_get_user_zombie(id) != 1)
					Pub_Give_Default_Wpn(id, i)
			}
		}
	}

	if (is_user_bot(id) && g_modruning != BTE_MOD_GD) // Give Bot Weapon
	{
		// Primary
		remove_task(id+TASK_BOT_WEAPON)
		//cs_set_user_money(id,0)
		Pub_Give_Default_Wpn(id, 2)
		Pub_Give_Default_Wpn(id, 3)
		set_task(random_float(0.01,0.5),"Task_Bot_Weapon",id+TASK_BOT_WEAPON)
	}

	if (g_modruning == BTE_MOD_GHOST)
	{
		SetFullAmmo(id, 1);
		SetFullAmmo(id, 2);

		SetFullClip(id, 1);
		SetFullClip(id, 2);
	}

	return HAM_IGNORED
}

public HamF_Spawn_Weapon(iEnt)
{
	if (!Get_Wpn_Data(iEnt, DEF_SPAWN))
	{
		//g_iBlockSetModel = TRUE;
		set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME);

		return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}

public HamF_Item_Deploy(iEnt)
{
	/*
	static id;
	id = get_pdata_cbase(iEnt, m_pPlayer, 4)

	//g_flNextAutoReload[id] = 0.0;

	if (!is_user_alive(id))
		return HAM_SUPERCEDE;
	*/
	return HAM_IGNORED;

}
stock GetWeaponModeDeploy(iEnt, iBteWpn)
{
	static iClip, iWeaponState, Float:flBlockarNextReload;
	iClip = get_pdata_int(iEnt, m_iClip);
	iWeaponState = get_pdata_int(iEnt, m_iWeaponState);

	if (iWeaponState & WPNSTATE_M4A1_SILENCED) return 1;
	if (iWeaponState & WPNSTATE_USP_SILENCED) return 1;
	else if (c_iSpecial[iBteWpn] == SPECIAL_CHAINSAW) return iClip?0:1;
	else if (c_iSpecial[iBteWpn] == SPECIAL_CATAPULT) return iClip?0:1;
	else if (c_iSpecial[iBteWpn] == SPECIAL_BOW) return iClip?0:1;
	else if (c_iSpecial[iBteWpn] == SPECIAL_DGUN) return iClip?0:1;
	else if (c_iSpecial[iBteWpn] == SPECIAL_M2) return iClip?0:1;
	else if (c_iSpecial[iBteWpn] == SPECIAL_SPEARGUN) return iClip?0:1;
	else if (c_iSpecial[iBteWpn] == SPECIAL_PETROLBOOMER) return iClip?0:1;
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUSMK5 || c_iSpecial[iBteWpn] == SPECIAL_JANUS7 || c_iSpecial[iBteWpn] == SPECIAL_JANUS1 || c_iSpecial[iBteWpn] == SPECIAL_JANUS11) return pev(iEnt, pev_iuser1);
	else if (c_iSpecial[iBteWpn] == SPECIAL_MAUSERC96) return iClip?0:1;
	else if (c_iSpecial[iBteWpn] == SPECIAL_BLOCKAR)
	{
		pev(iEnt, pev_fuser2, flBlockarNextReload);

		if (pev(iEnt, pev_iuser1) == STATUS_MODE1)
			return 0;
		if (pev(iEnt, pev_iuser1) == STATUS_MODE2)
		{
			if (GetExtraAmmo(iEnt) <= 0 || flBlockarNextReload > 0.0)
				return 2;
			return 1;
		}
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BLOODHUNTER) return pev(iEnt, pev_iuser1);
	else if (c_iSpecial[iBteWpn] == SPECIAL_DESPERADO) return pev(iEnt, pev_iuser1);
	else if (c_iSpecial[iBteWpn] == SPECIAL_DUALSWORD) return pev(iEnt, pev_iuser3);
	else if (c_iSpecial[iBteWpn] == SPECIAL_GUNKATA) return !CGunkata_GetLRMode(iEnt);
	return 0;
}

public DeploySpecialWeapon(id, iEnt, iId, iBteWpn)
{
	if (c_iSpecial[iBteWpn] == SPECIAL_STORMGIANT)
		StormGiant_Deploy(iEnt);

	if (c_iSpecial[iBteWpn] == SPECIAL_GAUSS)
		set_pev(iEnt, pev_fuser4, 0.0);

	if (c_iSpecial[iBteWpn] == SPECIAL_BLOCKAR || c_iSpecial[iBteWpn] == SPECIAL_BLOCKSMG)
	{
		if (pev(iEnt, pev_iuser1) == STATUS_MODE2)
			SetCanReload(id, FALSE);
		else
			SetCanReload(id, TRUE);

		SendExtraAmmo(id, iEnt);
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_AIRBURSTER)
		set_pev(iEnt, pev_iuser2, 0);
	
	if (c_iSpecial[iBteWpn] == SPECIAL_CANNON || c_iSpecial[iBteWpn] == SPECIAL_SGDRILL)
		set_pev(iEnt, pev_fuser1, 0.0);
	
	if (c_iSpecial[iBteWpn] == SPECIAL_CANNONEX)
	{
		set_pev(iEnt, pev_fuser1, 0.0);
		CCannonex_Deploy(id, iEnt, iId, iBteWpn)
	}
		
	if (c_iSpecial[iBteWpn] == SPECIAL_SGDRILL)
		set_pev(iEnt, pev_fuser2, 0.0);
	
	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_RAILCANNON)
	{
		set_pev(iEnt, pev_iuser1, 0);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.0);
		set_pdata_int(iEnt, m_iWeaponState, 0);
		SetExtraAmmo(id, iEnt, 0);
	}

	if (c_iType[g_weapon[id][0]] == WEAPONS_FLAMETHROWER)
	{
		set_pev(iEnt, pev_fuser1, 0.0);
	}

	if (c_iType[g_weapon[id][0]] == WEAPONS_SVDEX)
	{
		SendExtraAmmo(id, iEnt);

		if (get_pdata_int(iEnt, m_iWeaponState) & WPNSTATE_SVDEX_GRENADE)
			ShowCustomCrosshair(id, TRUE);

	}

	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_TKNIFE)
	{
		//Stock_Send_Anim(id,2);
		set_pdata_float(iEnt,m_flNextPrimaryAttack, 9999.0);
		set_pev(iEnt, pev_fuser1, c_flDeploy[g_weapon[id][0]] + get_gametime());
		set_pev(iEnt, pev_fuser2, c_flDeploy[g_weapon[id][0]] + get_gametime());
		set_pev(iEnt, pev_fuser3, c_flDeploy[g_weapon[id][0]] + get_gametime());
	}
	if (c_iSlot[g_weapon[id][0]] == 3)
	{
		set_pev(iEnt, pev_iuser1, 0);
		set_pev(iEnt, pev_iuser2, 0);

		if (c_iSlot[g_weapon[id][0]] != SPECIAL_HAMMER)
			set_pev(iEnt, pev_iuser3, 0);

		set_pev(iEnt, pev_iuser4, 0);
	}
	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_CHAINSAW)
	{
		set_pev(iEnt, pev_iuser1, 0);
		set_pev(iEnt, pev_iuser2, 0);
		set_pev(iEnt, pev_iuser3, 0);
	}
	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_SKULL8)
	{
		set_pev(iEnt, pev_iuser1, 0);
		set_pev(iEnt, pev_iuser2, 0);
	}

	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_BOW || c_iSpecial[g_weapon[id][0]] == SPECIAL_BALROG9)
	{
		set_pev(iEnt, pev_iuser1, 0);
		set_pev(iEnt, pev_fuser1, 0.0);
	}

	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_BALROG9)
	{
		//Stock_Send_Anim(id, 1);
		set_pdata_float(iEnt, m_flNextSecondaryAttack, 9999.0);
	}

	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_DGUN)
	{
		set_pev(iEnt, pev_iuser1, 0);
		set_pev(iEnt, pev_fuser1, c_flDeploy[g_weapon[id][0]]);
		set_pdata_float(iEnt,m_flNextPrimaryAttack, 9999.0);
	}

	if (c_iSpecial[g_weapon[id][0]] != SPECIAL_M2 && g_iWeaponMode[id][1])
	{
		MH_SendZB3Data(id, 15, 0);
	}

	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_BALROG11)
	{
		SendExtraAmmo(id, iEnt);
		set_pev(iEnt, pev_iuser1, 0);
	}

	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_HAMMER)
	{
		if (g_hammer_stat[id])
		{
			set_pev(id, pev_viewmodel2, "models/v_hammer_2.mdl")
			Pub_Set_MaxSpeed(id, c_flMaxSpeed[g_weapon[id][0]][1]);
		}
		else
		{
			set_pev(id, pev_viewmodel2, "models/v_hammer.mdl")
		}
	}

	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_JANUS7)
	{
		new iType = pev(iEnt, pev_iuser1);
		MH_SpecialEvent(id, 50 + iType);
	}
	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_JANUS11)
	{
		new iType = pev(iEnt, pev_iuser1);
		MH_SpecialEvent(id, 50 + iType);
	}										 

	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_SKULL3)
	{
		set_pev(id, pev_weaponmodel2, "models/p_skull3dual.mdl");
		set_pdata_string(id, m_szAnimExtention * 4, "dualpistols", -1, 20);

		if (iId == c_iId[g_weapon[id][0] + 1])
			SendWeaponAnim(id, g_dchanging[id] ? 10 : 9)
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_M1GARAND)
	{
		SendWeaponAnim(id, get_pdata_int(iEnt, m_iClip) ? 4 : 5);
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_RPG)
	{
		SendWeaponAnim(id, get_pdata_int(iEnt, m_iClip) ? 7 : 8);
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_GUILLOTINE)
	{
		CGuillotine_Deploy(id, iEnt, iId, iBteWpn);
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_THANATOS7)
	{
		CThanatos7_Deploy(id, iEnt, iId, iBteWpn);
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_THANATOS5)
	{
		CThanatos5_Deploy(id, iEnt, iId, iBteWpn);
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_JANUSMK5)
	{
		CJanusmk5_Deploy(id, iEnt, iId, iBteWpn);
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_JANUS1)
	{
		CJanus1_Deploy(id, iEnt, iId, iBteWpn);
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_JANUS7)
	{
		CJanus7_Deploy(id, iEnt, iId, iBteWpn);
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_BLOODHUNTER)
	{
		CBloodhunter_Deploy_Post(id, iEnt, iId, iBteWpn);
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_AUGEX)
	{
		CAugEX_Deploy(id, iEnt, iId, iBteWpn);
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_DESPERADO)
	{
		CDesperado_Deploy(id, iEnt, iId, iBteWpn)
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_DUALSWORD)
	{
		DualSword_Deploy(id, iEnt, iId, iBteWpn)
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_GUNKATA)
	{
		CGunkata_Deploy(iEnt);
	}
}

public DeploySpecialWeaponPre(id, iEnt, iId, iBteWpn)
{
	if (c_iType[iBteWpn] == WEAPONS_SVDEX)
	{
		if (!c_iDeployAnim[iBteWpn][1])
			set_pdata_int(iEnt, m_iWeaponState, 0);
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_M1GARAND || c_iSpecial[iBteWpn] == SPECIAL_RPG)
	{
		set_pdata_int(iEnt, m_iWeaponState, 0);
	}
}

public HamF_Item_Deploy_Post(iEnt)
{
	static id, iId, iSlot, iClip, Float:fDeployTime, iBteWpn;
	id = get_pdata_cbase(iEnt, m_pPlayer, 4)

	iId =  get_pdata_int(iEnt, m_iId, 4)
	iSlot = ExecuteHam(Ham_Item_ItemSlot, iEnt)
	iClip = get_pdata_int(iEnt, m_iClip, 4)

	set_pdata_float(id, m_flEjectBrass, 0.0);

	if (CSWPN_NOTREMOVE & (1<<iId)) return HAM_IGNORED;

	Stock_Set_Wpn_Current(id, iSlot);

	iBteWpn = g_weapon[id][0] + g_double[id][0];

	DeploySpecialWeaponPre(id, iEnt, iId, iBteWpn);
	SetCanReload(id, CanReload(iEnt, iBteWpn));

	if (iId == CSW_KNIFE)
		SendKnifeSound(id, TYPE_DRAW, 0);

	if (iSlot != 3 && iSlot != 4)
	{
		Stock_Config_User_Bpammo(id, iId, g_user_ammo[id][0], 1)

		if (g_user_clip[id][0] || c_iType[iBteWpn] == WEAPONS_LAUNCHER)
		{
			set_pdata_int(iEnt, m_iClip, g_user_clip[id][0])
			g_user_clip[id][0] = 0
		}
	}

	new iType = GetWeaponModeDeploy(iEnt, g_weapon[id][0]);

	SendWeaponAnim(id, c_iDeployAnim[g_weapon[id][0]][iType]);

	if ((c_iSpecial[iBteWpn] == SPECIAL_FIXSHOOT || (c_iSpecial[iBteWpn] == SPECIAL_SKULL3 && g_double[id][0])))
	{
		if (!(iClip & 1))
			set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_ELITE_LEFT);
		else
			set_pdata_int(iEnt, m_iWeaponState, 0);
	}

	if (c_iType[g_weapon[id][0]] == WEAPONS_DOUBLE)
	{
		if (iId == c_iId[g_weapon[id][0]] || iId == c_iId[g_weapon[id][0] + 1])
		{
#if defined _DEBUG
			PRINT("m_iID: %d A: %d B: %d D: %d", iId, c_iId[g_weapon[id][0]], c_iId[g_weapon[id][0] + 1], g_double[id][0])
#endif
			if (!g_double[id][0] && iId == c_iId[g_weapon[id][0] + 1]) // A->B
			{
				if (c_iSpecial[iBteWpn] != SPECIAL_SKULL3)
					SendWeaponAnim(id, WEAPON_TOTALANIM[iId])

				g_dchanging[id] = 1;

				set_pdata_float(id, m_flNextAttack, c_flDoubleChange[iBteWpn][1]);
				set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flDoubleChange[iBteWpn][1]);
				set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flDoubleChange[iBteWpn][1]);

				iBteWpn = g_weapon[id][0] + 1;
			}
			else if (g_double[id][0] && iId == c_iId[g_weapon[id][0]]) // B->A
			{
				SendWeaponAnim(id, WEAPON_TOTALANIM[iId])

				g_dchanging[id] = 1;

				set_pdata_float(id, m_flNextAttack, c_flDoubleChange[iBteWpn][0]);
				set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flDoubleChange[iBteWpn][0]);
				set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flDoubleChange[iBteWpn][0]);

				iBteWpn = g_weapon[id][0];
			}
		}
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_BLOCKAR)
	{
		if (pev(iEnt, pev_iuser1))
		{
			set_pev(id, pev_viewmodel2, "models/v_blockar2.mdl");
			set_pev(id, pev_weaponmodel2, "models/p_blockar2.mdl");
		}
		else
		{
			set_pev(id, pev_viewmodel2, "models/v_blockar1.mdl");
			set_pev(id, pev_weaponmodel2, "models/p_blockar1.mdl");
		}
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BLOCKSMG)
	{
		if (pev(iEnt, pev_iuser1))
		{
			set_pev(id, pev_viewmodel2, "models/v_blocksmg2.mdl");
			set_pev(id, pev_weaponmodel2, "models/p_blocksmg2.mdl");
			SendWeaponAnim(id, 14+pev(iEnt, pev_iuser2));
		}
		else
		{
			set_pev(id, pev_viewmodel2, "models/v_blocksmg1.mdl");
			set_pev(id, pev_weaponmodel2, "models/p_blocksmg1.mdl");
		}
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_THANATOS9)
	{
		if(!get_pdata_int(iEnt, m_iWeaponState))
		{
			set_pev(id, pev_viewmodel2, c_sModel_V[iBteWpn]);
			set_pev(id, pev_weaponmodel2, "models/p_thanatos9a.mdl");
		}
		else
		{
			set_pev(id, pev_viewmodel2, c_sModel_V[iBteWpn]);
			set_pev(id, pev_weaponmodel2, "models/p_thanatos9b.mdl");
		}
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUS9)
	{
		set_pev(id, pev_viewmodel2, c_sModel_V[iBteWpn]);
		set_pev(id, pev_weaponmodel2, "models/p_janus9_a.mdl");
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_CROW9)
	{
		set_pev(id, pev_viewmodel2, c_sModel_V[iBteWpn]);
		set_pev(id, pev_weaponmodel2, "models/p_crow9a.mdl");
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_DESPERADO)
	{
		if (pev(iEnt, pev_iuser1))
		{
			set_pev(id, pev_viewmodel2, c_sModel_V[iBteWpn]);
			set_pev(id, pev_weaponmodel2, "models/p_desperado_w.mdl");
		}
		else
		{
			set_pev(id, pev_viewmodel2, c_sModel_V[iBteWpn]);
			set_pev(id, pev_weaponmodel2, "models/p_desperado_m.mdl");
		}
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_DUALSWORD)
	{
		if (pev(iEnt, pev_iuser1) % 2)
		{
			set_pev(id, pev_viewmodel2, c_sModel_V[iBteWpn]);
			set_pev(id, pev_weaponmodel2, "models/p_dualsword_a.mdl");
		}
		else
		{
			set_pev(id, pev_viewmodel2, c_sModel_V[iBteWpn]);
			set_pev(id, pev_weaponmodel2, "models/p_dualsword_b.mdl");
		}
	}
	else 
	{
		set_pev(id, pev_viewmodel2, c_sModel_V[iBteWpn]);
		set_pev(id, pev_weaponmodel2, c_sModel_P[g_weapon[id][0]]);
	}


	//Pub_Set_MaxSpeed(id, c_flMaxSpeed[iBteWpn][iType]);

	if (c_iSpecial[iBteWpn] == SPECIAL_BLOCKAR || c_iSpecial[iBteWpn] == SPECIAL_BLOCKSMG)
		set_pdata_string(id, m_szAnimExtention * 4, pev(iEnt, pev_iuser1) == 3 ? "m249" : c_szAnimExtention[iBteWpn], -1, 20);
	else if (c_szAnimExtention[iBteWpn][0])
		set_pdata_string(id, m_szAnimExtention * 4, c_szAnimExtention[iBteWpn], -1, 20);


	if (c_flAccuracyDefault[iBteWpn])
		set_pdata_float(iEnt, m_flAccuracy, c_flAccuracyDefault[iBteWpn]);




#if 0
	//ResetMaxSpeed(id, iBteWpn);

	if (g_dchanging[id])
		Pub_Set_MaxSpeed(id,g_double[id][0]?c_gravity[g_weapon[id][0]]:c_d_gravity[g_weapon[id][0]])
	else
		Pub_Set_MaxSpeed(id,g_double[id][0]?c_d_gravity[g_weapon[id][0]]:c_gravity[g_weapon[id][0]])
#endif

	// Set Deploy Time if needed
	fDeployTime = c_flDeploy[iBteWpn];

	if (fDeployTime > 0.0)
	{
		set_pdata_float(id, m_flNextAttack, fDeployTime);
		set_pdata_float(iEnt,m_flTimeWeaponIdle, fDeployTime + 0.5);
	}

	if (((1<<c_iId[g_weapon[id][0]]) & CSWPN_FIRSTZOOM || (1<<c_iId[g_weapon[id][0]]) & CSWPN_SNIPER) && c_iZoom[iBteWpn][0] == 0)
		set_pdata_float(iEnt, m_flNextSecondaryAttack, 9999.0);


	set_pdata_int(iEnt, m_fInSpecialReload, 0, 4);

	DeploySpecialWeapon(id, iEnt, iId, iBteWpn);

/*#if defined ENABLE_SKULLAXE_BUG
	if (c_iSpecial[g_weapon[id][3]] == SPECIAL_SKULLAXE || c_iSpecial[g_weapon[id][3]] == SPECIAL_DRAGONSWORD)
		set_pdata_float(id, m_flNextAttack, 0.1, 5)
#endif*/

	if (c_iSpecial[g_weapon[id][3]] == SPECIAL_DRAGONSWORD)
		g_anim[id] = 0

	return HAM_SUPERCEDE;
}
/*public HamF_TraceAttack(iVictim, iAttacker, Float:fDamage, Float:vDir[3], iTr, iDamageType)
{
	if (iVictim == iAttacker) return HAM_IGNORED
	if (!is_user_connected(iAttacker) || !is_user_connected(iVictim)) return HAM_IGNORED
	if (get_pdata_int(iVictim, m_iTeam) == get_pdata_int(iAttacker, m_iTeam) && !get_pcvar_num(cvar_friendlyfire)) return HAM_IGNORED
	if (get_user_weapon(iAttacker) == CSW_KNIFE) return HAM_IGNORED

	if (g_freezetime) return HAM_SUPERCEDE
	if (!(iDamageType & DMG_BULLET)) return HAM_IGNORED

	static Float:vVelocity[3], Float:fKnockBack, flags

	pev(iVictim, pev_velocity, vVelocity);
	flags = pev(iAttacker, pev_flags);

	fKnockBack = g_double[iAttacker][0]?c_d_knockback[g_weapon[iAttacker][0]]:c_knockback[g_weapon[iAttacker][0]]

	if (!fKnockBack)
		return HAM_IGNORED

	xs_vec_mul_scalar(vDir, fKnockBack, vDir)
	xs_vec_mul_scalar(vDir, g_knockback[iVictim], vDir);

	vDir[2] = xs_vec_len(vDir) * c_knockbackh[g_weapon[iAttacker][0]];

	if (flags & ~FL_ONGROUND)
	{
		xs_vec_mul_scalar(vDir, 1.5, vDir);
		vDir[2] *= 0.4;
	}

	xs_vec_add(vVelocity, vDir, vDir)
	set_pev(iVictim, pev_velocity, vDir)

	return HAM_IGNORED
}*/

public HamF_Weapon_SecondaryAttack(iEnt)
{
	static id, iBteWpn, iClip;
	id = get_pdata_cbase(iEnt, m_pPlayer, 4)

	iBteWpn = g_weapon[id][0] + g_double[id][0];
	iClip = get_pdata_int(iEnt, m_iClip, 4);

	if (c_iSpecial[iBteWpn] == SPECIAL_GAUSS)
		return HAM_SUPERCEDE;

	if (c_iSpecial[iBteWpn] == SPECIAL_BUFFAWP)
	{
		return CBuffAWP_SecondaryAttack(iEnt);
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_INFINITY)
	{
		CInfinity_SecondaryAttack(id,iEnt,iClip,iBteWpn);
		return HAM_SUPERCEDE;
	}
	
	if (c_iSpecial[iBteWpn] == SPECIAL_CROW1)
	{
		CCrow1_SecondaryAttack(id,iEnt,iClip,iBteWpn);
		return HAM_SUPERCEDE;
	}
	
	if (c_iType[iBteWpn] == WEAPONS_BLOCK_RIGHT)
	{
		set_pdata_float(iEnt, m_flNextSecondaryAttack, 1.0);

		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}