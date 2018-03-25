// [BTE API FUNCTION]
#include "BTE_API.inc"
#include <orpheu_stocks>
#include <orpheu_memory>



public plugin_natives()
{
	new config_dir[64], url_none[64], url_td[64], url_ze[64],url_npc[64],url_zb1[64],url_gd[64],url_dr[64],url_zb3[64],url_zb4[64],url_dm[64],url_ghost[64],url_td2[64],url_zb2[64],url_zse[64],url_zb5[64]
	get_configsdir(config_dir, charsmax(config_dir))
	format(url_none, charsmax(url_none), "%s/plugins-none.ini", config_dir)
	format(url_td, charsmax(url_td), "%s/plugins-td.ini", config_dir)
	format(url_dm, charsmax(url_td), "%s/plugins-dm.ini", config_dir)
	format(url_ze, charsmax(url_ze), "%s/plugins-ze.ini", config_dir)
	format(url_npc, charsmax(url_npc), "%s/plugins-npc.ini", config_dir)
	format(url_zb1, charsmax(url_zb1), "%s/plugins-zb1.ini", config_dir)
	format(url_gd, charsmax(url_gd), "%s/plugins-gd.ini", config_dir)
	format(url_dr, charsmax(url_dr), "%s/plugins-dr.ini", config_dir)
	format(url_zb3, charsmax(url_zb3), "%s/plugins-zb3.ini", config_dir)
	format(url_zb4, charsmax(url_zb4), "%s/plugins-zb4.ini", config_dir)
	format(url_ghost, charsmax(url_ghost), "%s/plugins-ghost.ini", config_dir)
	format(url_td2, charsmax(url_td2), "%s/plugins-td2.ini", config_dir)
	format(url_zb2, charsmax(url_zb2), "%s/plugins-zb2.ini", config_dir)
	format(url_zse, charsmax(url_zse), "%s/plugins-zse.ini", config_dir)
	format(url_zb5, charsmax(url_zb5), "%s/plugins-zb5.ini", config_dir)

	// get modruning
	if (file_exists(url_none)) g_modruning = BTE_MOD_NONE
	else if (file_exists(url_td)) g_modruning = BTE_MOD_TD
	else if (file_exists(url_dm)) g_modruning = BTE_MOD_DM
	else if (file_exists(url_ze)) g_modruning = BTE_MOD_ZE
	else if (file_exists(url_npc)) g_modruning = BTE_MOD_NPC
	else if (file_exists(url_zb1)) g_modruning = BTE_MOD_ZB1
	else if (file_exists(url_gd)) g_modruning = BTE_MOD_GD
	else if (file_exists(url_dr)) g_modruning = BTE_MOD_DR
	else if (file_exists(url_ghost)) g_modruning = BTE_MOD_GHOST
	else if (file_exists(url_td2)) g_modruning = BTE_MOD_TD2
	else if (file_exists(url_zb2))
	{
		g_modruning = BTE_MOD_ZB1
	}
	else if (file_exists(url_zb3))
	{
		g_isZomMod3 = 1
		g_modruning = BTE_MOD_ZB1;
	}
	else if (file_exists(url_zb4))
	{
		g_isZomMod4 = 1
		g_modruning = BTE_MOD_ZB1;
	}
	else if (file_exists(url_zse))
	{
		g_isZSE = 1;
		g_modruning = BTE_MOD_ZB1;
	}
	else if (file_exists(url_zb5))
	{
		g_isZomMod5 = TRUE;
		g_modruning = BTE_MOD_ZB1;
	}

	if(g_modruning == BTE_MOD_ZB1)
		JANUS7_CHARGE_SHOOTTIME = 110
		
	if (file_exists(url_dr))
	{
		register_native("BTE_DeathInfo_TakeDamage_Pre", "Native_None");
		register_native("BTE_DeathInfo_TakeDamage_Post", "Native_None");
	}

	/*if (g_modruning == BTE_MOD_NONE)
	{
		server_cmd("bte_wpn_free 0")
		server_cmd("bte_wpn_buyzone 1")
	}*/
	// reg native
	if (!g_isZomMod3 && !g_isZomMod5)
	{
		if (!g_isZomMod4 && !g_isZSE)
			register_native("bte_get_zombie_sex", "Native_NoValue",1)

		register_native("bte_hms_get_skillstat", "Native_NoValue",1)
		register_native("bte_zb3_is_boomer_skilling", "Native_NoValue",1)
		register_native("is_heavy_zombie", "Native_NoValue", 1);
	}

	if (!g_isZomMod4)
	{
		register_native("bte_zb4_is_stuned", "Native_NoValue",1)
		register_native("bte_zb4_get_dash", "Native_NoValue",1)
		register_native("bte_zb4_is_using_accshoot", "Native_None");
		register_native("bte_zb4_get_day_status", "Native_None");
	}

	if(g_modruning != BTE_MOD_ZB1 && g_modruning != BTE_MOD_ZE)
	{
		register_native("bte_get_user_zombie","Native_NoValue",1)
	}
	if(g_modruning != BTE_MOD_NPC)
	{
		register_native("bte_npc_is_npc","Native_NoValue",1)
	}

	//register_native("bte_wpn_get_wpn_data","Native_get_wpn_data",1)
	register_native("bte_wpn_get_is_admin","Native_get_is_admin",1)
	register_native("bte_wpn_give_named_wpn","Native_give_named_wpn",1)
	//register_native("bte_wpn_set_playerwpn_model","Native_set_playerwpn_model",1)
	//register_native("bte_wpn_get_playerwpn_model","Native_get_playerwpn_model",1)
	register_native("bte_wpn_get_wpn_name","Native_get_wpn_name",1)
	register_native("bte_wpn_deathinfo_weaponname","Native_DeathInfo_WeaponName",1)
	//register_native("bte_wpn_en_to_cn_name","Native_en_to_cn_name",1)
	//register_native("bte_wpn_menu_add_item","Native_menu_add_item",1)
	register_native("bte_wpn_get_mod_running","Native_get_mod_running",1)
	register_native("bte_wpn_get_weapon_limit","Native_get_weapon_limit",1)
	register_native("bte_wpn_precache_named_weapon","Native_precache_named_weapon",1)
	register_native("bte_wpn_strip_weapon","Native_strip_weapon",1)

	register_native("bte_wpn_set_maxspeed","Native_set_maxspeed",1)
	register_native("bte_wpn_set_maxspeed2","Native_set_maxspeed2",1)
	register_native("bte_wpn_set_fullammo","Native_set_fullammo",1)
	//register_native("bte_wpn_set_fullammo_ex","Native_set_fullammo_ex",1)
	register_native("bte_wpn_set_ammo","Native_set_ammo",1)
	register_native("bte_wpn_get_ammo","Native_get_ammo",1)
	//register_native("bte_wpn_play_seqence","Native_play_seqence",1)
	//register_native("bte_wpn_get_wpn_dmg","Native_get_wpn_dmg",1)
	register_native("bte_wpn_set_ammo_clip","Native_set_ammo_clip",1)
	register_native("bte_wpn_set_gerenade_ammo","Native_set_gerenade_ammo",1)
	register_native("bte_wpn_set_knockback","Native_set_knockback",1)
	register_native("bte_wpn_set_vm","Native_set_vm",1)
	register_native("bte_wpn_set_anim_offset","Native_set_anim_offset",1)
	register_native("bte_wpn_give_grenade","Native_give_grenade",1)

	register_native("bte_wpn_is_attacking","Native_is_attacking",1)
	register_native("bte_wpn_strip_slot","Native_strip_slot",1)

	register_native("bte_KnifeAttack", "native_KnifeAttack", 1);

	register_native("BTE_FireBullets3_Lite", "native_FireBullets3_Lite");
	register_native("BTE_Check_BuyTime", "native_Check_BuyTime", 1);
	register_native("BTE_Set_FullAmmo_EX", "native_Set_FullAmmo_EX", 1);

	register_native("BTE_HostOwnBuffAK47", "Native_HostOwnBuffAK47", 1);
	register_native("BTE_HostOwnBuffM4", "Native_HostOwnBuffM4", 1);
	register_native("BTE_HostOwnBuffSG552", "Native_HostOwnBuffSG552", 1);
	register_native("BTE_HostOwnBuffAWP", "Native_HostOwnBuffAWP", 1);

	register_native("BTE_Alarm", "Native_Alarm", 1);
	register_native("BTE_MVPBoard", "Native_MVPBoard", 1);
}

public Native_HostOwnBuffAWP()
{
	return g_bHostOwnBuffAWP;
}

public Native_HostOwnBuffSG552()
{
	return g_bHostOwnBuffSG552;
}

public Native_DeathInfo_WeaponName(sName[], sSave[33])
{
	param_convert(1);
	param_convert(2);
	new iBteWpn = GetBTEWeaponID(sName);
	if(iBteWpn <0 || iBteWpn>=MAX_WPN)
		return;
	if (c_iId[iBteWpn] == CSW_KNIFE)
	{
		format(sSave, 32, "%L", LANG_PLAYER, "DEATHINFO_KNIFE");
	}
	else if (c_iId[iBteWpn] == CSW_HEGRENADE)
	{
		format(sSave, 32, "%L", LANG_PLAYER, "DEATHINFO_GRENADE");
	}
	else
	{
		copy(sSave, 32, c_sModel[iBteWpn]);
		strtoupper(sSave);
		format(sSave, 32, "%L", LANG_PLAYER, sSave);
	}
}

public Native_Alarm(id, type)
{
	MESSAGE_BEGIN(id ? MSG_ONE : MSG_ALL, gmsgAlarm, _, id ? id : 0);
	WRITE_SHORT(type);
	MESSAGE_END();
}

public Native_MVPBoard(iWinTeam, iType, iPlayer)
{
	UTIL_MVPBoard(iWinTeam, iType, iPlayer);
}

public Native_HostOwnBuffM4()
{
	return g_bHostOwnBuffM4A1;
}

public Native_HostOwnBuffAK47()
{
	return g_bHostOwnBuffAK47;
}

public Native_None(const amx, const params)
{
	return 0;
}

public native_Set_FullAmmo_EX(id, slot, Float:x)
{
	SetFullAmmo(id, slot, x);
}

public native_Check_BuyTime(id, bSendMsg)
{
	if (g_fBuyTime < get_gametime())
	{
		if (bSendMsg)
		{
			new str[4];
			format(str, 4, "%d", floatround(get_cvar_float("mp_buytime") * 60.0));
			ClientPrint(id, HUD_PRINTCENTER, "#Cant_buy", str);
		}

		return FALSE;
	}

	return TRUE;
}

public native_FireBullets3_Lite(const plugin, const params)
{
	new Float:vecSrc[3], Float:vecDir[3], Float:flDistance, iPenetration, Float:flDamage, pevAttacker;

	get_array_f(1, vecSrc, 3);
	get_array_f(2, vecDir, 3);
	flDistance = get_param_f(3);
	iPenetration = get_param(4);
	flDamage = get_param_f(5);
	pevAttacker = get_param(6);

	FireBullets3_Lite(vecSrc, vecDir, flDistance, iPenetration, flDamage, pevAttacker);
}

/*public
{
	RageCall( handleFireBullets3,
}*/

public Native_set_vm(id, Float:vm)
{
	g_vm[id] = vm;
}

public native_KnifeAttack(id, bStab, Float:fRange, Float:flDamage)
{
	return KnifeAttack(id, bStab, fRange, flDamage, 0.0)
}

public Native_strip_slot(id,iSlot)
{
	Stock_Strip_Slot(id,iSlot);
}

public Native_is_attacking(id)
{
	return g_attacking[id];
}

public Native_get_weapon_limit()
{
	switch (g_c_iWeaponLimitBit)
	{
		case 0: return WEAPON_LIMIT_NO;
		case 1<<CSW_AWP | 1<<CSW_SCOUT | 1<<CSW_KNIFE: return WEAPON_LIMIT_SNIPER;
		case SECONDARY_WEAPONS_BIT_SUM | 1<<CSW_KNIFE: return WEAPON_LIMIT_PISTOL;
		case 1<<CSW_HEGRENADE | 1<<CSW_KNIFE: return WEAPON_LIMIT_GRENADE;
		case 1<<CSW_KNIFE: return WEAPON_LIMIT_KNIFE;
	}
	return WEAPON_LIMIT_NO;
}



public Native_give_grenade(id)
{
	if(!is_user_alive(id)) return;

	if(g_save_guns[id][4])
	{
		if(get_pdata_int(id, OFFSET_HE_AMMO, OFFSET_LINUX_WEAPONS)==0)
			Pub_Give_Idwpn(id,g_save_guns[id][4],1)
		else if(get_pdata_int(id, OFFSET_HE_AMMO, OFFSET_LINUX_WEAPONS)==1 && bte_fun_get_have_mode_item(id,4) && g_isZomMod3 && bte_get_user_zombie(id)!=1)
			set_pdata_int(id, OFFSET_HE_AMMO, 2, OFFSET_LINUX_WEAPONS)
	}
	else
	{
		if(get_pdata_int(id, OFFSET_HE_AMMO, OFFSET_LINUX_WEAPONS)==0)
			Pub_Give_Named_Wpn(id,"hegrenade")
		else if(get_pdata_int(id, OFFSET_HE_AMMO, OFFSET_LINUX_WEAPONS)==1 && bte_fun_get_have_mode_item(id,4) && g_isZomMod3 && bte_get_user_zombie(id)!=1)
			set_pdata_int(id, OFFSET_HE_AMMO, 2, OFFSET_LINUX_WEAPONS)
	}
}
public Native_set_maxspeed2(id,Float:fSpeed,Float:fTime)
{
	new Float:fCurTime;
	global_get(glb_time, fCurTime);

	fNextMaxSpeedReset[id] = fTime + fCurTime;
	fMaxSpeed[id] = fSpeed;

	set_pev(id, pev_maxspeed, fSpeed);
}
public Native_set_maxspeed(id,Float:fSpeed)
{
	Pub_Set_MaxSpeed2(id,fSpeed)
}
public Native_set_anim_offset(id,offset,Float:framerate,force)
{
	g_iAnimOffset[id] = offset;
	g_fFrameRate[id] = framerate;
	g_fKeepFrame[id] = -1.0;

	set_pev(id, pev_animtime, get_gametime());
	set_pev(id, pev_frame, 0);

	if(force) g_iSequence[id] = offset;
	else g_iSequence[id] = 0;
}

public Native_set_knockback(id,Float:knockback)
{
	g_knockback[id] = knockback;
}

/*public Native_play_seqence(id, iSequence, iFrame)
{
	OrpheuCall(handleResetSequenceInfo, id);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	set_pev(id, pev_sequence, iSequence);
	set_pev(id, pev_framerate, 1.0);
}*/

public Native_set_gerenade_ammo(id,type,ammo)
{
	static iOffset
	switch(type)
	{
		case 1: iOffset = OFFSET_HE_AMMO;
		case 2: iOffset = OFFSET_FLASH_AMMO;
		case 3: iOffset = OFFSET_SMOKE_AMMO;
		default: return 0;
	}
	set_pdata_int(id, iOffset, ammo, OFFSET_LINUX_WEAPONS)
	return 1;
}

public Native_set_ammo_clip(id,iSlot,clip)
{
	Stock_Config_User_Bpammo(id, c_iId[g_weapon[id][iSlot]], /*c_clip[g_weapon[id][iSlot]] * */clip, 1)
}



public Native_get_ammo(id,slot)
{
	// check if current weapon slot == slot
	static iSlot,iEnt,iAmmoType,iAmmo
	iSlot = c_iSlot[g_weapon[id][0]]
	if(iSlot == slot)
	{
		iEnt = get_pdata_cbase(id, m_rgpPlayerItems+slot,5)
		if(iEnt<1) return 0
		iAmmoType = get_pdata_int(iEnt, m_iPrimaryAmmoType, 4)
		iAmmo = get_pdata_int(id, m_rgAmmo_player_Slot0 + iAmmoType)
		return iAmmo
	}
	else
	{
		return g_user_ammo[id][slot]
	}
	return 0;
}
public Native_set_ammo(id,slot,ammo)
{
	// check if current weapon slot == slot
	static iSlot,iEnt,iAmmoType//,iAmmo
	iSlot = c_iSlot[g_weapon[id][0]]
	if(iSlot == slot)
	{
		iEnt = get_pdata_cbase(id, m_rgpPlayerItems+slot,5)
		if(iEnt<1) return
		iAmmoType = get_pdata_int(iEnt, m_iPrimaryAmmoType, 4)
		set_pdata_int(id, m_rgAmmo_player_Slot0 + iAmmoType,ammo,4)
	}
	else
	{
		g_user_ammo[id][slot] = ammo
	}
}
public Native_set_fullammo(id)
{
	/*while (cmd_buy_ammo(id,1,1)){}
	while (cmd_buy_ammo(id,2,1)){}*/
	cmd_buy_ammo(id, 1, TRUE, TRUE, TRUE)
	cmd_buy_ammo(id, 2, TRUE, TRUE, TRUE)
}

public Native_strip_weapon(id,iSlot)
{
	Stock_Strip_Slot(id,iSlot)
}
public Native_precache_named_weapon(sWeapon[])
{
	static i = MAX_WPN - 1;

	param_convert(1)
	copy(g_szMyWpn[i --], 15, sWeapon)
	return 1
}
public Native_get_mod_running()
{
	return g_modruning
}
public Native_NoValue(iNone)
{
	return 0
}
/*public Native_menu_add_item(hMenu,iSlot)
{
	new sTemp[32]
	if(g_mywpn_enable) // use mywpn
	{
		for(new i=0;i<g_mywpn_cachenum[iSlot];i++)
		{
			if(iSlot == 1)
			{
				Native_Local_en_to_cn_name(g_mywpn_r_cache[i],sTemp)
				menu_additem(hMenu, sTemp, g_mywpn_r_cache[i], 0)
			}
			else if(iSlot == 2)
			{
				Native_Local_en_to_cn_name(g_mywpn_p_cache[i],sTemp)
				menu_additem(hMenu, sTemp, g_mywpn_p_cache[i], 0)
			}
			else if(iSlot == 3)
			{
				Native_Local_en_to_cn_name(g_mywpn_k_cache[i],sTemp)
				menu_additem(hMenu, sTemp, g_mywpn_k_cache[i], 0)
			}
			else if(iSlot == 4)
			{
				Native_Local_en_to_cn_name(g_mywpn_h_cache[i],sTemp)
				menu_additem(hMenu, sTemp, g_mywpn_h_cache[i], 0)
			}
		}
	}
	else
	{
		for(new i=1;i<=g_wpn_count[iSlot];i++)
		{
			menu_additem(hMenu, c_name[g_wpn_count_match[iSlot][i]], c_sModel[g_wpn_count_match[iSlot][i]], 0)
		}
	}
}*/
/*public Native_Local_en_to_cn_name(sEn[],sCn[])
{
	for(new i=1;i<g_wpn_count[0];i++)
	{
		if(equal(c_sModel[i],sEn))
		{
			copy(sCn,charsmax(sCn),c_name[i])
		}
	}
}
public Native_en_to_cn_name(sEn[],sCn[])
{
	param_convert(1)
	param_convert(2)
	for(new i=1;i<g_wpn_count[0];i++)
	{
		if(equal(c_sModel[i],sEn))
		{
			copy(sCn,charsmax(sCn),c_name[i])
		}
	}
}*/
public Native_get_wpn_name(id,iCurrent,iType,sName[])
{
	param_convert(4)
	/*if(iType == BTE_WPNDATA_CN_NAME)
	{
		copy(sName,charsmax(sName),iCurrent?c_name[iCurrent]:c_name[g_weapon[id][0]])
	}
	else copy(sName,charsmax(sName),iCurrent?c_sModel[iCurrent]:c_sModel[g_weapon[id][0]])*/

	copy(sName,1024,iCurrent?c_sModel[iCurrent]:c_sModel[g_weapon[id][0]])
}
/*public Native_get_playerwpn_model(id)
{
	return g_p_modelent[id]
}*/
/*public Native_set_playerwpn_model(id,iVis,sModel[],iBody,iSeq)
{
	param_convert(3)
	if(iVis)
	{
		Stock_Set_Vis(g_p_modelent[id])
		engfunc(EngFunc_SetModel, g_p_modelent[id], sModel)
		set_pev(g_p_modelent[id],pev_body,iBody)
		//set_pev(g_p_modelent[id] ,pev_p_idwpn,iIdwpn)
		set_pev(g_p_modelent[id] ,pev_sequence,iSeq)
	}
	else Stock_Set_Vis(g_p_modelent[id],0)
}*/
public Native_give_named_wpn(id,sName[],iForceStripSlot)
{
	param_convert(2)

	//Pub_Give_Named_Wpn(id,sName,1,iForceStripSlot)
	Pub_Give_Idwpn(id, GetBTEWeaponID(sName), 1, iForceStripSlot)
}
public Native_get_is_admin(id)
{
	return (get_user_flags(id) & ADMIN_KICK)?1:0
}
/*public Float:Native_get_wpn_dmg(id)
{
	return (c_damage[g_weapon[id][0]]?c_damage[g_weapon[id][0]]:1.0)
}*/

/*public Float:Native_get_wpn_data(id,idwpn,iSlot,iSection,iSet,Float:fValue)
{
	if(idwpn)
	{
SEARCH_START:
		switch (iSection)
		{
			case BTE_WPNDATA_DAMAGE:
			{
				if(iSet)
				{
					c_damage[idwpn] = fValue
				}
				else return c_damage[idwpn]
			}
			case BTE_WPNDATA_SPEED:
			{
				if(iSet)
				{
					c_speed[idwpn] = fValue
				}
				else return c_speed[idwpn]
			}
			case BTE_WPNDATA_CLIP:
			{
				if(iSet)
				{
					c_clip[idwpn] = floatround(fValue)
				}
				else return float(c_clip[idwpn])
			}
			case BTE_WPNDATA_AMMO:
			{
				if(iSet)
				{
					c_maxammo[idwpn] = floatround(fValue)
				}
				else return float(c_maxammo[idwpn])
			}
			case BTE_WPNDATA_RECOIL:
			{
				if(iSet)
				{
					c_recoil[idwpn] = fValue
				}
				else return c_recoil[idwpn]
			}
			case BTE_WPNDATA_GRAVITY:
			{
				if(iSet)
				{
					c_gravity[idwpn] = floatround(fValue)
				}
				else return float(c_gravity[idwpn])
			}
			case BTE_WPNDATA_KNOCKBACK:
			{
				if(iSet)
				{
					c_knockback[idwpn] = fValue
				}
				else return c_knockback[idwpn]
			}
			case BTE_WPNDATA_COST:
			{
				if(iSet)
				{
					c_cost[idwpn] = floatround(fValue)
				}
				else return float(c_cost[idwpn])
			}
			case BTE_WPNDATA_BUY:
			{
				if(iSet)
				{
					c_bCanBuy[idwpn] = floatround(fValue)
				}
				else return float(c_damage[idwpn])
			}
			case BTE_WPNDATA_DMGZB:
			{
				if(iSet)
				{
					c_dmgzb[idwpn] = floatround(fValue)
				}
				else return c_dmgzb[idwpn]
			}
			default : return 0
		}
	}
	else
	{
		idwpn = g_weapon[id][iSlot]
		goto SEARCH_START
	}
}*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg936\\ deff0\\ deflang1033\\ deflangfe2052{\\ fonttbl{\\ f0\\ fnil\\ fcharset134 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2052\\ f0\\ fs16 \n\\ par }
*/
