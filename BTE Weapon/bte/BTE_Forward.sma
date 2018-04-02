// [BTE Fakemeta FORWARD FUNCTION]

public Forward_PlayerPostThink(id)
{
	if (msgMoney[id][m_flTimeSend] < get_gametime() && msgMoney[id][m_flTimeSend])
	{
		msgMoney[id][m_flTimeSend] = 0.0;

		message_begin(MSG_ONE, gmsgMoney, _, id);
		write_long(msgMoney[id][m_account]);
		write_byte(msgMoney[id][m_bTrackChange]);
		message_end();

		//PRINT("%d", get_pdata_int(id, m_iAccount))
	}

	for (new i=1; i<33; i++)
	{
		if (g_fNextClear[id][i] <= get_gametime() && g_fTotalDamage[id][i])
		{
			g_fTotalDamage[id][i] = 0.0;
		}
	}

	if (pev(id, pev_deadflag) != DEAD_NO)
		return FMRES_IGNORED;


	if(g_freezetime)
		return FMRES_IGNORED;

	return FMRES_IGNORED
}

public Forward_FindEntityInSphere(iStartEnt,Float:vPos[3],Float:fRange)
{
	static id
	if(fRange == 350.0)
	{
		id = Get_Wpn_Data(iStartEnt,DEF_OWNER)

		if(id && pev(iStartEnt,pev_iuser2)!=1111) // ZombieBomb
		{
			if(g_c_iWeaponLimitBit == 1<<CSW_HEGRENADE | 1<<CSW_KNIFE && is_user_alive(id))
				Native_give_grenade(id);

			if(!c_iSprite[Get_Wpn_Data(iStartEnt,DEF_ID)])
			{
			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vPos, 0);
			write_byte(TE_EXPLOSION)
			engfunc(EngFunc_WriteCoord,vPos[0])
			engfunc(EngFunc_WriteCoord,vPos[1])
			engfunc(EngFunc_WriteCoord,vPos[2] + 20.0)
			write_short(g_sModelIndexFireball3)
			write_byte(25)
			write_byte(30)
			if(c_sSound[Get_Wpn_Data(iStartEnt,DEF_ID)][0])	write_byte(TE_EXPLFLAG_NOSOUND)
			else	write_byte(TE_EXPLFLAG_NONE)
			message_end()

			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vPos, 0);
			write_byte(TE_EXPLOSION)
			engfunc(EngFunc_WriteCoord,vPos[0] + random_float(-64.0,64.0))
			engfunc(EngFunc_WriteCoord,vPos[1] + random_float(-64.0,64.0))
			engfunc(EngFunc_WriteCoord,vPos[2] + random_float(30.0,35.0))
			write_short(g_sModelIndexFireball2)
			write_byte(30)
			write_byte(30)
			write_byte(TE_EXPLFLAG_NONE)
			message_end()
			}
			else
			{
			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vPos, 0);
			write_byte(TE_EXPLOSION)
			engfunc(EngFunc_WriteCoord,vPos[0])
			engfunc(EngFunc_WriteCoord,vPos[1])
			engfunc(EngFunc_WriteCoord,vPos[2] + 20.0)
			write_short(c_iSprite[Get_Wpn_Data(iStartEnt,DEF_ID)])
			write_byte(25)
			write_byte(30)
			if(c_sSound[Get_Wpn_Data(iStartEnt,DEF_ID)][0])	write_byte(TE_EXPLFLAG_NOSOUND)
			else	write_byte(TE_EXPLFLAG_NONE)
			message_end()
			}
		}
	}
	return FMRES_IGNORED
}
public Forward_UpdateClientData_Post(id,iWeapon,iCD)
{
	/*if(c_iType[g_weapon[id][0]] == WEAPONS_M134 && get_pdata_int(get_pdata_cbase(id, m_pActiveItem), m_iWeaponState) == WPNSTATE_M134_IDLE)
	{
		set_cd(iCD,CD_flNextAttack,get_gametime()+1.0)
	}
	else */if(c_iType[g_weapon[id][0]] == WEAPONS_LAUNCHER || c_iType[g_weapon[id][0]] == WEAPONS_BAZOOKA || c_iType[g_weapon[id][0]] == WEAPONS_FLAMETHROWER || c_iSpecial[g_weapon[id][0]] == SPECIAL_MUSKET
	 || c_iSpecial[g_weapon[id][0]] == SPECIAL_CROSSBOW || c_iSpecial[g_weapon[id][0]] == SPECIAL_CATAPULT || c_iSpecial[g_weapon[id][0]] == SPECIAL_CANNON || c_iType[g_weapon[id][0]] == WEAPONS_M32
	 || c_iSpecial[g_weapon[id][0]] == SPECIAL_CHAINSAW || c_iType[g_weapon[id][0]] == WEAPONS_FG || c_iSpecial[g_weapon[id][0]] == SPECIAL_COILGUN || c_iSpecial[g_weapon[id][0]] == SPECIAL_PLASMA
	 || c_iSpecial[g_weapon[id][0]] == SPECIAL_BOW || c_iSpecial[g_weapon[id][0]] == SPECIAL_DGUN/* || c_iSpecial[g_weapon[id][0]] == SPECIAL_SFSNIPER*/)
	{
		set_cd(iCD,CD_flNextAttack,get_gametime()+1.0)
		//set_cd(iCD, CD_iUser3, 0)
	}

	if (get_cd(iCD, CD_DeadFlag) != DEAD_NO)
		return

	/*new iWeaponType = get_cd(CD_Handle, CD_ID)

	if (!g_cvarRecoil[iWeaponType] || get_pcvar_float(g_cvarRecoil[iWeaponType]) == 1.0)
		return*/

	if (is_user_alive(id))
		set_cd(iCD, CD_iUser3, 0)
}
public Forward_PlaybackEvent(iFlags, id, iEvent, Float:fDelay, Float:vecOrigin[3], Float:vecAngle[3], Float:flParam1, Float:flParam2, iParam1, iParam2, bParam1, bParam2)
{
	if (!is_user_alive(id)) return FMRES_IGNORED

	if (m_usFire[g_weapon[id][0]][0] && WEAPON_EVENT[c_iId[g_weapon[id][0]]] == iEvent && c_iType[g_weapon[id][0]] != WEAPONS_DOUBLE)
		iEvent = m_usFire[g_weapon[id][0]][0];

	new iEnt;
	iEnt = get_pdata_cbase(id, m_pActiveItem);

	new iBteWpn = g_weapon[id][0];

	if (g_double[id][0])
		bParam1 = TRUE;

	if (c_iSpecial[iBteWpn] == SPECIAL_M16A1)
	{
		bParam1 = (get_pdata_int(iEnt, m_iWeaponState) & WPNSTATE_M16A1_SEMIAUTO);
		bParam2 = bParam1;
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_SFMG)
	{
		bParam2 = (get_pdata_int(iEnt, m_iWeaponState) & WPNSTATE_M16A1_SEMIAUTO);
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_M1GARAND)
	{
		bParam1 = (get_pdata_int(iEnt, m_iWeaponState) & WPNSTATE_M1GARAND_AIMING);
		bParam2 = (get_pdata_int(iEnt, m_iClip) <= 0);
	}

	if(c_iSpecial[iBteWpn] == SPECIAL_JANUSMK5 || c_iSpecial[iBteWpn] == SPECIAL_JANUS7 || c_iSpecial[iBteWpn] == SPECIAL_JANUS11)
	{
		bParam1 = !!pev(iEnt, pev_iuser1);//format(sound, charsmax(sound), "%s", "weapons/janusmk5-2.wav")
		bParam2 = pev(iEnt, pev_iuser1) == JANUSMK5_USING;
	}

	if (c_iSpecial[iBteWpn] == SPECIAL_DESTROYER)
	{
		new Float:vecOrigin[3], Float:vecAngles[3];
		new Float:vecForward[3], Float:vecRight[3], Float:vecUp[3];
		new Float:vecEnd[3];
		GetGunPosition(id, vecOrigin);
		pev(id, pev_v_angle, vecAngles);
		vecAngles[0] += iParam1 / 100.0;
		vecAngles[1] += iParam2 / 100.0;
		engfunc(EngFunc_AngleVectors, vecAngles, vecForward, vecRight, vecUp);
		for (new i=0; i<3; i++)
			vecEnd[i] = vecOrigin[i] + 8192.0 * (vecForward[i] + flParam1 * vecRight[i] + flParam2 * vecUp[i]);
		new tr = create_tr2();
		engfunc(EngFunc_TraceLine, vecOrigin, vecEnd, dont_ignore_monsters, id, tr);
		get_tr2(tr, TR_vecEndPos, vecEnd);
		new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
		if (iEntity)
		{
			engfunc(EngFunc_SetModel, iEntity, "models/w_usp.mdl");
			set_pev(iEntity, pev_rendermode, kRenderTransAdd);
			set_pev(iEntity, pev_renderamt, 0.0);
			set_pev(iEntity, pev_origin, vecEnd);
			set_pev(iEntity, pev_movetype, MOVETYPE_NOCLIP);
			set_pev(iEntity, pev_solid, SOLID_NOT);
			set_pev(iEntity, pev_nextthink, get_gametime()+0.6);
			set_pev(iEntity, pev_owner, id);
			Set_Ent_Data(iEntity, DEF_ENTCLASS, ENTCLASS_DESTROYER);
			Set_Ent_Data(iEntity, DEF_ENTID, iBteWpn);
		}
		free_tr2(tr);
	}

	if(c_iSpecial[g_weapon[id][0]] == SPECIAL_M2 && g_iWeaponMode[id][1])
		bParam2 = TRUE;

	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_SGDRILL)
		bParam1 = FALSE;

	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_BUFFM4A1)
		bParam1 = get_pdata_int(id, m_iFOV) != 90;
	
	
	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_THANATOS7 || c_iSpecial[g_weapon[id][0]] == SPECIAL_THANATOS5)
		bParam2 = !!get_pdata_int(iEnt, m_iWeaponState);
	
	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_BLOODHUNTER)
		bParam2 = (pev(iEnt, pev_iuser1) < 3 && pev(iEnt, pev_iuser2) == 4) ? TRUE:FALSE;
	
	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_INFINITY)
	{
		bParam1 = !!(get_pdata_int(iEnt, m_iWeaponState) & WPNSTATE_ELITE_LEFT);
		iParam2 = get_pdata_int(iEnt, m_iClip);
	}
	
	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_BLOCKSMG)
	{
		flParam2 = float(get_pdata_int(iEnt, m_iClip));
		bParam2 = !!(get_pdata_int(iEnt, m_iWeaponState) & WPNSTATE_ELITE_LEFT);
	}
	
	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_STERLINGBAYONET)
		bParam2 = !!get_pdata_int(iEnt, m_iWeaponState);
		

	if (c_iId[g_weapon[id][0]] == CSW_M3 || c_iId[g_weapon[id][0]] == CSW_XM1014)
	{
		new cShots = c_iId[g_weapon[id][0]] == CSW_M3 ? 9 : 6;

		if (c_cShots[g_weapon[id][0]])
			flParam2 = float(c_cShots[g_weapon[id][0]]);

		if (c_vecSpread[g_weapon[id][0]][0])
			flParam1 = c_vecSpread[g_weapon[id][0]][0] * 1000.0;

		if (c_iSpecial[g_weapon[id][0]] == SPECIAL_QBARREL)
		{
			new iSpShoot = pev(iEnt, pev_iuser1);

			if (iSpShoot)
			{
				flParam2 = float(c_cShots[g_weapon[id][0]] ? c_cShots[g_weapon[id][0]] * iSpShoot : cShots * iSpShoot);
				bParam2 = TRUE;

				flParam1 *= 1.2;

				set_pev(iEnt, pev_iuser1, 0);
			}
		}

		if (c_iSpecial[g_weapon[id][0]] == SPECIAL_SKULL11)
		{
			if (get_pdata_int(iEnt, m_iWeaponState) & WPNSTATE_SKULL11_SLUG)
				flParam1 *= 0.15;
		}
	}

	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_FIXSHOOT || (c_iSpecial[g_weapon[id][0]] == SPECIAL_SKULL3 && g_double[id][0]))
	{
		new item = get_pdata_cbase(id, m_pActiveItem);

		bParam1 = FALSE;
		bParam2 = FALSE;

		iParam2 = get_pdata_int(item, m_iClip);

		new Float:vecPunchangle[3];
		pev(id, pev_punchangle, vecPunchangle);

		iParam1 = floatround(vecPunchangle[1] * 100.0);

		if(get_pdata_int(item, m_iWeaponState) & WPNSTATE_ELITE_LEFT)
			iEvent = m_usFire[g_weapon[id][0]][0];
		else
			iEvent = m_usFire[g_weapon[id][0]][1];

		if(!g_double[id][0] && c_iSpecial[g_weapon[id][0]] == SPECIAL_SKULL3)
		{
			bParam1 = TRUE;
			iEvent = m_usFire[g_weapon[id][0]][0];
		}
	}

	if(c_iType[g_weapon[id][0]] == WEAPONS_SPSHOOT)
	{
		static pAct
		pAct = get_pdata_cbase(id, m_pActiveItem);
		if(pAct && get_pdata_int(pAct, m_iFamasShotsFired) >= 10)
		{
			engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, WEAPON_EVENT[CSW_FAMAS/*c_iId[g_weapon[id][0]]*/], c_flBurstSpeed[g_weapon[id][0]], vecOrigin, vecAngle, flParam1 , flParam2, iParam1, iParam2, bParam1, bParam2)
			return FMRES_SUPERCEDE
		}
	}

	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, iEvent, fDelay, vecOrigin, vecAngle, flParam1, flParam2, iParam1, iParam2, bParam1, bParam2)
	return FMRES_SUPERCEDE

}
public Forward_ClientCommand(id)
{
	new iDouble
	if(!is_user_alive(id)) return FMRES_IGNORED
	new sCmd[32]
	read_argv(0,sCmd,31)

	new a = 0
	do {
		if (equali(g_Aliases[a], sCmd) || equali(g_Aliases2[a], sCmd))
		{
			return PLUGIN_HANDLED
		}
	}  while(++a < MAXMENUPOS)

	if(equal(sCmd,"drop") || equal(sCmd,"lastinv"))
	{
		if(c_iSpecial[g_weapon[id][0]] == SPECIAL_M2 && g_iBlockSwitchDrop[id])
			return FMRES_SUPERCEDE
	}

	if(equal(sCmd,"weapon_",7))
	{
		if(c_iSpecial[g_weapon[id][0]] == SPECIAL_M2 && g_iBlockSwitchDrop[id])
			return FMRES_SUPERCEDE

		for(new i=1;i<=CSW_P90;i++)
		{
			if(equal(sCmd,WEAPON_NAME[i]))
			return FMRES_IGNORED
		}

		if(equal(sCmd[strlen(sCmd)-2], "_2")) iDouble = 1
		replace(sCmd,31,"weapon_","")
		replace(sCmd,31,"_2","")

		for(new i=1;i<=sizeof(c_sModel)-1;i++)
		{
			if(equal(sCmd,c_sModel[i]))
			{
				if(!iDouble) client_cmd(id,WEAPON_NAME[c_iId[i]])
				else client_cmd(id,WEAPON_NAME[c_iId[i + 1]])
				return FMRES_SUPERCEDE
			}
		}
	}
	return FMRES_IGNORED
}
public Forward_EmitSound(id,channel,sample[],Float:volume,Float:attenuation,flags,pitch)
{
	static iId
	if (!is_user_connected(id)) return FMRES_IGNORED
	iId = get_user_weapon(id)

	if (iId == CSW_XM1014)
	{
		if(equal(sample, "weapons/reload", 14))
			return FMRES_SUPERCEDE;
	}

	if (equal(sample, "weapons/knife_deploy1.wav") && ((g_weapon[id][3] == 1 && bte_get_user_sex(id) == 2) || g_weapon[id][3] != 1 || bte_get_user_zombie(id) == 1))
		return FMRES_SUPERCEDE;

	return FMRES_IGNORED;
}

public Forward_SetModel(iEnt, const szModel[])
{
	static iCswpn,iWpnEnt,iSlot,id,iLen
	iLen = strlen(szModel)
	if (iLen < 8) return FMRES_IGNORED

	new classname[32];
	pev(iEnt, pev_classname, classname, charsmax(classname));
	if (equal(classname, "armoury_entity"))
	{
		new iItem = get_pdata_int(iEnt, m_iItem);

		if (iItem == ARMOURY_FLASHBANG || iItem == ARMOURY_KEVLAR || iItem == ARMOURY_ASSAULT || iItem == ARMOURY_SMOKEGRENADE)
			return FMRES_IGNORED;

		engfunc(EngFunc_SetModel, iEnt, "models/w_usp.mdl");
		return FMRES_SUPERCEDE;
	}

	if (g_iBlockSetModel)
	{

	}
	// Fix Map Weapon Precache
	/*if (g_iBlockSetModel)
	{
		if(szModel[7] == 'w' && szModel[8] == '_')
		{
			engfunc(EngFunc_RemoveEntity, iEnt)
			return FMRES_SUPERCEDE
		}
	}*/

	if(szModel[7] == 'p' && szModel[8] == 'l' && szModel[8] == 'a' && szModel[8] == 'y') return FMRES_IGNORED
	else if((szModel[7] == 'w' && szModel[8] == '_' && szModel[9] == 'h' && szModel[10] == 'e')) // grenade
	{
		id = pev(iEnt, pev_owner)
		g_lasthe[id] = g_weapon[id][4]
		engfunc(EngFunc_SetModel, iEnt, c_sModel_W[g_weapon[id][4]])
		set_pev(iEnt,pev_body,c_iModel_W_Sub[g_weapon[id][4]])
		Set_Wpn_Data(iEnt,DEF_ID,g_weapon[id][4])
		Set_Wpn_Data(iEnt,DEF_OWNER,id)
		//set_pev(iEnt, pev_animtime, get_gametime());
		//set_pev(iEnt, pev_sequence, 3);
		//set_pev(iEnt, pev_framerate, 15);
		//PRINT("%d",pev(iEnt, pev_sequence))

		/*if(get_pdata_int(id, OFFSET_HE_AMMO, OFFSET_LINUX_WEAPONS)==0)
			Stock_Reset_Wpn_Slot(id,4)*/

		g_grenade[id] = 0;

		return FMRES_SUPERCEDE;
	}
	else if(equal(szModel,"models/w_smokegrenade.mdl"))
	{
		engfunc(EngFunc_SetModel, iEnt, "models/w_Grenade_1.mdl")
		set_pev(iEnt,pev_body,10)
		return FMRES_SUPERCEDE;
	}
	else if(equal(szModel,"models/w_flashbang.mdl"))
	{
		engfunc(EngFunc_SetModel, iEnt, "models/w_Grenade_1.mdl")
		set_pev(iEnt,pev_body,11)
		return FMRES_SUPERCEDE;
	}
	//models/shield/p_shield_
	else if( iLen>26 && szModel[7] == 's' &&szModel[8] == 'h' &&szModel[9] == 'i' &&szModel[10] == 'e')
	{
		engfunc(EngFunc_RemoveEntity,iEnt)
		return FMRES_SUPERCEDE
	}
	//models/w_weaponbox.mdl
	else if(iLen>15 && szModel[7] == 'w' &&szModel[15] == 'b' &&szModel[16] == 'o' &&szModel[17] == 'x')
	{
		Set_Wpn_Data(iEnt,DEF_ISWEAPONBOX,1)
		return FMRES_IGNORED
	}
	else if(iLen>11 && szModel[7] == 'w' &&szModel[8] == '_' &&szModel[9] == 'c' &&szModel[10] == '4')
	{
		return FMRES_IGNORED
	}
	/*models/grenade.mdl
	else if(iLen>10 && szModel[7] == 'g' &&szModel[8] == 'r' &&szModel[9] == 'e' &&szModel[10] == 'n')
	{
		return FMRES_SUPERCEDE
	}*/
	//models/w_
	else if(szModel[7] != 'w' || szModel[8] != '_')
	{
		Util_Log("SetModel Skip: %s",szModel)
		return FMRES_IGNORED
	}
	if(equal(szModel,"models/w_kevlar.mdl"))
	{
		return FMRES_IGNORED;
	}
	/*if(get_pdata_int(iEnt,m_iDefaultAmmo,4))
	{
		return FMRES_SUPERCEDE
	}*/
	if(Get_Wpn_Data(iEnt,DEF_ISWEAPONBOX)) // weaponbox entity
	{
		id = pev(iEnt, pev_owner)
		for(new i=0;i<6;i++)
		{
			iWpnEnt = get_pdata_cbase(iEnt,m_rgpWeaponBoxPlayerItems+i,4)
			if(iWpnEnt>0)
			{
				iCswpn = get_pdata_int(iWpnEnt,m_iId,4)
				if(CSWPN_NOTREMOVE & (1<<iCswpn)) return FMRES_IGNORED

				// Double Check!

				if(c_iType[g_weapon[id][iSlot]] == WEAPONS_DOUBLE)
				{
					static pNext
					pNext = get_pdata_cbase(id,m_rgpPlayerItems+1,5)
					if(pNext>1)
					{
						// Kill This Item
						static iWpn2
						iWpn2 = get_pdata_int(pNext, m_iId, 4);
						set_pev(id, pev_weapons, pev(id,pev_weapons) &~(1<<iWpn2))
						Stock_Kill_Item(id, pNext)
					}

					Set_Wpn_Data(iWpnEnt, DEF_ISDOUBLE, g_double[id][1]);
				}

				iSlot = ExecuteHam(Ham_Item_ItemSlot,iWpnEnt)
				Set_Wpn_Data(iWpnEnt,DEF_ID,g_weapon[id][iSlot])
				Set_Wpn_Data(iWpnEnt,DEF_SPAWN,1)
				Set_Wpn_Data(iWpnEnt,DEF_AMMO,g_user_ammo[id][iSlot])
				Set_Wpn_Data(iWpnEnt,DEF_ISDROPPED,1)
				if(c_iType[g_weapon[id][iSlot]] == WEAPONS_DOUBLE) Set_Wpn_Data(iWpnEnt,DEF_CLIP,g_user_clip[id][iSlot])
				if (c_iSpecial[g_weapon[id][iSlot]] == SPECIAL_BLOCKAR)
				{
					if (pev(iWpnEnt, pev_iuser1))
					{
						engfunc(EngFunc_SetModel, iEnt, "models/w_blockar2.mdl");
					}
					else
					{
						engfunc(EngFunc_SetModel, iEnt, "models/w_blockar1.mdl");
					}
				}
				else if (c_iSpecial[g_weapon[id][iSlot]] == SPECIAL_BLOCKSMG)
				{
					if (pev(iWpnEnt, pev_iuser1))
					{
						engfunc(EngFunc_SetModel, iEnt, "models/w_blocksmg2.mdl");
					}
					else
					{
						engfunc(EngFunc_SetModel, iEnt, "models/w_blocksmg1.mdl");
					}
				}
				else 
					engfunc(EngFunc_SetModel, iEnt, c_sModel_W[g_weapon[id][iSlot]])
				set_pev(iEnt, pev_body, c_iModel_W_Sub[g_weapon[id][iSlot]])
				Stock_Reset_Wpn_Slot(id,iSlot)

				if (g_modruning == BTE_MOD_TD || g_modruning == BTE_MOD_DM)
					g_c_fWeaponLastTime = 8.0

				if(g_c_fWeaponLastTime>0.1 && bte_get_user_zombie(id) != 1)
					set_pev(iEnt,pev_nextthink,get_gametime()+g_c_fWeaponLastTime)
				return FMRES_SUPERCEDE
			}
		}
	}
	return FMRES_SUPERCEDE // May be occur a BUG?
}

public Forward_PrecaceResource(sResource[])
{
	for (new i = 0; i < g_iBlockNums; i++)
	{
		if (equal(g_sBlockResource[i], sResource))
		{
			//Util_Log("BlockResource: %s", sResource)
			return FMRES_SUPERCEDE
		}
	}

	return FMRES_IGNORED
}
public Forward_PrecacheEvent(type, const name[])
{
	if(equal("events/ak47.sc", name))
	{
		WEAPON_EVENT[CSW_AK47] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/aug.sc", name))
	{
		WEAPON_EVENT[CSW_AUG] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/awp.sc", name))
	{
		WEAPON_EVENT[CSW_AWP] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/deagle.sc", name))
	{
		WEAPON_EVENT[CSW_DEAGLE] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/deagle.sc", name))
	{
		WEAPON_EVENT[CSW_DEAGLE] = get_orig_retval();
		return FMRES_HANDLED
	}

	/*if(equal("events/elite_left.sc", name))
	{
		m_usFireELITE_LEFT = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/elite_right.sc", name))
	{
		m_usFireELITE_RIGHT = get_orig_retval();
		return FMRES_HANDLED
	}*/

	if(equal("events/famas.sc", name))
	{
		WEAPON_EVENT[CSW_FAMAS] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/fiveseven.sc", name))
	{
		WEAPON_EVENT[CSW_FIVESEVEN] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/g3sg1.sc", name))
	{
		WEAPON_EVENT[CSW_G3SG1] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/galil.sc", name))
	{
		WEAPON_EVENT[CSW_GALIL] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/glock18.sc", name))
	{
		WEAPON_EVENT[CSW_GLOCK18] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/m3.sc", name))
	{
		WEAPON_EVENT[CSW_M3] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/m4a1.sc", name))
	{
		WEAPON_EVENT[CSW_M4A1] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/fiveseven.sc", name))
	{
		WEAPON_EVENT[CSW_FIVESEVEN] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/m249.sc", name))
	{
		WEAPON_EVENT[CSW_M249] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/mac10.sc", name))
	{
		WEAPON_EVENT[CSW_MAC10] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/mp5n.sc", name))
	{
		WEAPON_EVENT[CSW_MP5NAVY] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/p90.sc", name))
	{
		WEAPON_EVENT[CSW_P90] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/fiveseven.sc", name))
	{
		WEAPON_EVENT[CSW_FIVESEVEN] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/p228.sc", name))
	{
		WEAPON_EVENT[CSW_P228] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/scout.sc", name))
	{
		WEAPON_EVENT[CSW_SCOUT] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/sg550.sc", name))
	{
		WEAPON_EVENT[CSW_SG550] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/sg552.sc", name))
	{
		WEAPON_EVENT[CSW_SG552] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/tmp.sc", name))
	{
		WEAPON_EVENT[CSW_TMP] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/ump45.sc", name))
	{
		WEAPON_EVENT[CSW_UMP45] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/usp.sc", name))
	{
		WEAPON_EVENT[CSW_USP] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/xm1014.sc", name))
	{
		WEAPON_EVENT[CSW_XM1014] = get_orig_retval();
		return FMRES_HANDLED
	}

	if(equal("events/knife.sc", name))
	{
		WEAPON_EVENT[CSW_KNIFE] = get_orig_retval();
		return FMRES_HANDLED
	}

	return FMRES_IGNORED
}