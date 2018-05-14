// [BTE Event Command Function]
public message_StatusValue(msgid, msgdest, id)
{
	if (get_msg_arg_int(1) == 1 && get_msg_arg_int(2) >= 2 && get_pdata_int(id, m_iFOV) <= 40 && c_iSpecial[g_weapon[id][0]] == SPECIAL_SFSNIPER)
		emit_sound(id, CHAN_WEAPON, "weapons/sfsniper_insight1.wav", 1.0, 2.4, 0, 100);
}

public message_StatusIcon(msgid, msgdest, id)
{
	static szIcon[8];
	get_msg_arg_string(2, szIcon, 7);

	if (equal(szIcon, "buyzone") && get_msg_arg_int(1) && ((g_modruning == BTE_MOD_TD || g_modruning == BTE_MOD_DM) || (is_user_bot(id) && g_modruning != BTE_MOD_NONE)))
	{
		set_pdata_int(id, 235, get_pdata_int(id, 235) & ~SIGNAL_BUY);
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public message_TextMsg()
{
	static szText[256];
	get_msg_arg_string(2, szText, charsmax(szText));
	if (!IS_ZBMODE)
	{
		if (equal(szText, "#CTs_Win"))
		{
			UTIL_MVPBoard(2, 1, 0);
		}
		if (equal(szText, "#Terrorists_Win"))
		{
			UTIL_MVPBoard(1, 2, 0);
		}
		if (equal(szText, "#Bomb_Defused"))
		{
			UTIL_MVPBoard(2, 4, g_iDefuser);
		}
		if (equal(szText, "#Target_Bombed"))
		{
			UTIL_MVPBoard(1, 3, g_iPlanter);
		}
	}
}

/*public message_Damage(msgid, msgdest, id)
{
	new Float: origin[3];
	origin[0] = get_msg_arg_float(4);
	origin[1] = get_msg_arg_float(5);
	origin[2] = get_msg_arg_float(6);
	PRINT("damage origin: %f %f %f", origin[0], origin[1], origin[2])

	pev(id, pev_origin, origin);
	PRINT("origin: %f %f %f", origin[0], origin[1], origin[2])
}*/

/*
public message_DeathMsg()
{
	static iKiller, sWeapon[32],iAttackerWeapon
	new sWeaponChange[32],sSprites[32]
	iKiller = get_msg_arg_int(1)
	if (iKiller < 1 || iKiller >32) return PLUGIN_CONTINUE

	get_msg_arg_string(4, sWeapon, charsmax(sWeapon))

	if (sWeapon[0] == 'g' && sWeapon[1] == 'r' && sWeapon[2] == 'e' && sWeapon[3] == 'n')  // grenade
	{
		format(sWeapon, charsmax(sWeapon),"%s", c_sModel[g_lasthe[iKiller]])
		set_msg_arg_string(4, sWeapon)

		if (g_szKillWeapon[0])
			set_msg_arg_string(4, g_szKillWeapon);

		return PLUGIN_CONTINUE
	}

	if (sWeapon[0] == 'd' && sWeapon[1] == '_')
	{
		format(sWeaponChange,31,"%s",sWeapon[2])
		set_msg_arg_string(4, sWeaponChange)

		if (g_szKillWeapon[0])
			set_msg_arg_string(4, g_szKillWeapon);

		return PLUGIN_CONTINUE
	}

	iAttackerWeapon  = g_weapon[iKiller][0];

	if (c_iType[iAttackerWeapon] == WEAPONS_DOUBLE && g_double[iKiller][0])
		format(sSprites, charsmax(sSprites), "%s_2", c_sModel[iAttackerWeapon])
	else
		format(sSprites, charsmax(sSprites), "%s", c_sModel[iAttackerWeapon])

	set_msg_arg_string(4, sSprites)

	if (g_szKillWeapon[0])
		set_msg_arg_string(4, g_szKillWeapon);

	return PLUGIN_CONTINUE
}
*/

native BTE_DeathMsg(id, iVictim, iHeadShot, szWeapon[], iAssist);
native bte_zb4_get_day_status();
native bte_zb4_is_using_accshoot(id);

public message_DeathMsg(msgid, msgdest, id)
{
	new sWeapon[32],iAttackerWeapon
	new sWeaponChange[32],sSprites[32]
	
	new iKiller = get_msg_arg_int(1)
	new iVictim = get_msg_arg_int(2);
	new bIsHeadShot = get_msg_arg_int(3);
	get_msg_arg_string(4, sWeapon, charsmax(sWeapon))
	
	if (0 < get_pdata_int(iVictim, m_iTeam) < 3 && (0 < iKiller < 33))
	{
		static iInGame, iPlayer, iTeam;
		iInGame = iPlayer = 0;
		iTeam = get_pdata_int(iVictim, m_iTeam);
		
		for (new id=1; id<33; id++)
		{
			if (!is_user_connected(id) || !is_user_alive(id) || get_pdata_int(id, m_iTeam) != iTeam) continue;
			iInGame++;
			iPlayer = id;
		}
		if (iInGame == 1 && IsPlayer(iPlayer) && bte_get_user_zombie(iPlayer) != 1)
		{
			Native_Alarm(iPlayer, 28);
		}
		
		if (g_modruning == BTE_MOD_ZB1)
		{
			if (!CountZombies() && bte_get_user_zombie(iPlayer) != 1)
			{
				Native_Alarm(iKiller, 19);
			}
			else if (!CountHumans() && bte_get_user_zombie(iPlayer) == 1)
			{
				Native_Alarm(iKiller, 19);
			}
		}
		else
		{
			if (!CountPlayers(get_pdata_int(iVictim, m_iTeam)))
			{
				Native_Alarm(iKiller, 19);
			}
		}
	}
	
	if (g_isZomMod4 && (0 < iKiller < 33))
	{
		new bIsUsingSkill = bte_zb4_is_using_accshoot(iKiller);
		if (bte_zb4_get_day_status() != 1)
		{
			bIsHeadShot = bIsUsingSkill;
		}
		else
		{
			bIsHeadShot = 0;
		}
	}
	
	if (iVictim == g_iPlanting && pev_valid(g_iPlanting) && pev_valid(iKiller))
	{
		Native_Alarm(iKiller, 25);
	}
	else if (iVictim == g_iDefusing && pev_valid(g_iDefusing) && pev_valid(iKiller))
	{
		Native_Alarm(iKiller, 26);
	}
	else if (pev_valid(iVictim) && (0 < iKiller < 33))
	{
		if (get_pdata_bool(iVictim, 773))
			Native_Alarm(iKiller, 27);
	}
	
	if (pev_valid(iKiller) && is_user_connected(iKiller))
	{
		if (bte_get_user_zombie(iKiller) != 1)
			g_iRank[0][iKiller] ++;
		else
		{
			if (g_isZSE)
				g_iRank[2][iKiller]++;
		}
	}
	new iAssist = GetAssist(iKiller, iVictim);
	if (iKiller < 1 || iKiller >32)
	{
		
	}

	if (sWeapon[0] == 'g' && sWeapon[1] == 'r' && sWeapon[2] == 'e' && sWeapon[3] == 'n')  // grenade
	{
		format(sWeapon, charsmax(sWeapon),"%s", c_sModel[g_lasthe[iKiller]])
	}

	if (sWeapon[0] == 'd' && sWeapon[1] == '_')
	{
		format(sWeapon, 31, "%s",sWeapon[2])
	}

	iAttackerWeapon = g_weapon[iKiller][0];

	if (c_iType[iAttackerWeapon] == WEAPONS_DOUBLE && g_double[iKiller][0])
		format(sWeapon, charsmax(sWeapon), "%s_2", c_sModel[iAttackerWeapon])
	else
		format(sWeapon, charsmax(sWeapon), "%s", c_sModel[iAttackerWeapon])

	if(g_szKillWeapon[0])
		format(sWeapon, charsmax(sWeapon), "%s", g_szKillWeapon)
	
	set_msg_arg_int(3, get_msg_argtype(3), bIsHeadShot);
	set_msg_arg_string(4, sWeapon);
	
	message_begin(msgdest, msgid, _, id);
	write_byte(iKiller);
	write_byte(iVictim);
	write_byte(bIsHeadShot);
	write_string(sWeapon);
	write_byte(iAssist);
	message_end();
	
	BTE_DeathMsg(iKiller, iVictim, bIsHeadShot, sWeapon, iAssist);
	
	//client_print(0, print_chat, "%i %i %i %s %i", iKiller, iVictim, bIsHeadShot, sWeapon, iAssist);
	return PLUGIN_HANDLED;
}

native SendBuyTime(time)

public Event_HLTV()
{
	for(new i=1 ; i<33 ;i++)
	{
		if (!is_user_connected(i))
			continue;

		if (task_exists(i+TASK_BALROG1)==1) remove_task(i+TASK_BALROG1)
		if (task_exists(i+TASK_FIREBOMB)==1) remove_task(i+TASK_FIREBOMB)
		if (task_exists(i+TASK_HOLYBOMB)==1) remove_task(i+TASK_HOLYBOMB)
		if (task_exists(i+TASK_FLAMETHROWER)==1) remove_task(i+TASK_FLAMETHROWER)

		if (c_iSpecial[g_weapon[i][1]] == SPECIAL_M2)
		{
			g_iWeaponMode[i][1] = 0;
			g_iBlockSwitchDrop[i] = 0;
			MH_SendZB3Data(i, 15, 0);
		}
	}
	new Float:fBuyTime = get_cvar_float("mp_buytime") * 60.0;
	g_fBuyTime = get_gametime() + fBuyTime;
	SendBuyTime(floatround(fBuyTime));

	for (new i=1; i<33; i++) g_iRank[0][i] = g_iRank[1][i] = g_iRank[2][i] = 0;
	g_iPlanter = g_iDefuser = 0;
	g_flStartTime = get_gametime();

	g_freezetime = 1
	server_cmd("sv_maxvelocity 9999.0")

	MESSAGE_BEGIN(MSG_ALL, gmsgRoundStart);
	MESSAGE_END();
}
/*public Event_StatusIcon(id)
{
	g_buyzone[id] = read_data(1)
}*/
public LogEvent_Round_Start()
{
	g_freezetime = 0
	//client_print ( 0, print_chat , "您现在玩的游戏由BTE TEAM提供，交流地址 百度贴吧csoldjb吧" )

}

public Cmd_Buy(id)
{
	new sCmd[32];
	read_argv(1, sCmd, 31);
	Pub_Give_Idwpn(id, GetBTEWeaponID(sCmd), 1, 0)
}

public cmd_block(id)
{
	return PLUGIN_HANDLED
}
public cmd_buy_mywpn(id)
{
	if (g_modruning == BTE_MOD_GD || g_modruning == BTE_MOD_DR)
		return PLUGIN_HANDLED;

	if (!VIPCheck(id, TRUE))
		return PLUGIN_HANDLED;

	new sCmd[32];
	read_argv(1, sCmd, 31);

	if (!equal(sCmd, "10397"))
		return PLUGIN_HANDLED;
	read_argv(2, sCmd, 31);

	if (g_modruning == BTE_MOD_NONE || g_modruning == BTE_MOD_GHOST)
	{
		if (AlreadyHaveWeapon(id, sCmd))
		{
			ClientPrint(id, HUD_PRINTCENTER, "#Cstrike_Already_Own_Weapon");

			return PLUGIN_HANDLED;
		}
	}

	if (g_modruning == BTE_MOD_ZB1 && AlreadyHaveWeapon(id, sCmd))
		return PLUGIN_HANDLED;

	Pub_Buy_Named_Wpn(id, sCmd);
	return PLUGIN_HANDLED
}
/*public cmd_select_wpn(id)
{
	new sCmd[32];
	read_argv(1,sCmd,31);

	for(new i=1;i<g_wpn_count[0];i++)
	{
		if (equal(c_sModel[i],sCmd))
		{
			MH_SendData(id,2,c_iSlot[i],sCmd);
		}
	}

	return PLUGIN_HANDLED
}*/
public cmd_wpn_reload_data()
{
	new time = get_systime();
	Read_WeaponsINI(0)
	Util_Log("Reload Data: %ds", get_systime() - time)

}

public cmd_buyfullammo1(id)
{
	cmd_buy_ammo(id, 1, 0, TRUE)
	return PLUGIN_HANDLED
}
public cmd_buyfullammo2(id)
{
	cmd_buy_ammo(id, 2, 0, TRUE)
	return PLUGIN_HANDLED
}
public cmd_buyammo1(id)
{
	if (g_modruning==BTE_MOD_TD) return PLUGIN_HANDLED

	cmd_buy_ammo(id,1,0)
	return PLUGIN_HANDLED
}
public cmd_buyammo2(id)
{
	if (g_modruning==BTE_MOD_TD) return PLUGIN_HANDLED

	cmd_buy_ammo(id,2,0)
	return PLUGIN_HANDLED
}
stock Stock_Check_Buy()
{
	if (g_modruning == BTE_MOD_DR || g_modruning == BTE_MOD_ZE || g_modruning == BTE_MOD_Z4E || g_modruning == BTE_MOD_ZB1 || g_modruning == BTE_MOD_GD) return 0
	return 1
}

stock IsSpWpn(i)
{
	return (c_iSpecial[i] == SPECIAL_SFSNIPER || c_iSpecial[i] == SPECIAL_M200 || c_iSpecial[i] == SPECIAL_TKNIFE
		 || c_iSpecial[i] == SPECIAL_BOW || c_iSpecial[i] == SPECIAL_JANUS1 || c_iSpecial[i] == SPECIAL_M79 || c_iSpecial[i] == SPECIAL_CANNON
		 || c_iSpecial[i] == SPECIAL_FIRECRAKER || c_iSpecial[i] == SPECIAL_PETROLBOOMER || c_iSpecial[i] == SPECIAL_SPEARGUN || c_iSpecial[i] == SPECIAL_GAUSS)
}
stock cmd_buy_ammo(id, iSlot, iFree, bBuyFull = FALSE, bSetFull = FALSE)
{
	if (!VIPCheck(id, FALSE))
		return 0;

	// Check Mod Buy
	if (g_modruning == BTE_MOD_GHOST)
		iFree = 1;

	if (!Stock_Check_Buy() && !iFree) return 0
	static iEnt,iAmmoType,/*iAmmoType2,*/iAmmo,/*iAmmo2,*/iWpnID,iMoney,iNext,pActive
	//if (!g_buyzone[id] && get_pcvar_num(cvar_freebuyzone)) return 0
	if (!CheckBuyZone(id)) return 0
	if (get_pcvar_num(cvar_freebuy)) iFree=1

	if (g_fBuyTime < get_gametime() && (g_modruning == BTE_MOD_NONE || g_modruning == BTE_MOD_GHOST))
	{
		new str[4];
		format(str, 4, "%d", floatround(get_cvar_float("mp_buytime") * 60.0));
		ClientPrint(id, HUD_PRINTCENTER, "#Cant_buy", str);
		return 0;
	}

	iEnt = get_pdata_cbase(id,m_rgpPlayerItems + iSlot,5)
	if (iEnt < 1) return 0
	//iAmmoType2 = get_pdata_int(iEnt, m_iPrimaryAmmoType, 4)

	iNext = get_pdata_cbase(iEnt, m_pNext)
	pActive = get_pdata_cbase(id, m_pActiveItem, 5)
	iEnt = iNext>0?iNext:iEnt

	iWpnID = Get_Wpn_Data(iEnt,DEF_ID)
	iAmmoType = get_pdata_int(iEnt, m_iPrimaryAmmoType, 4)
	if (iNext>0 && pActive!=iEnt && c_iType[Get_Wpn_Data(pActive,DEF_ID)] == WEAPONS_DOUBLE || g_dchanging[id]) iAmmoType = get_pdata_int(pActive, m_iPrimaryAmmoType, 4)
	iAmmo = get_pdata_int(id, m_rgAmmo_player_Slot0 + iAmmoType)

	if (IsSpWpn(iWpnID))
	{
		new iClip = get_pdata_int(iEnt, m_iClip, 4);
		if (iClip >= c_iClip[iWpnID])
			return 0;

		iMoney = get_pdata_int(id, m_iAccount);

		new i = 0;
		while (iClip < c_iClip[iWpnID])
		{
			if (!iFree)
			{
				iMoney -= c_iAmmoCost[iWpnID];

				if (iMoney < 0)
					break;
			}

			iClip += c_iAmmo[iWpnID];
			i ++;

			if (!bBuyFull)
				break;
		}

		if (i)
		{
			if (!iFree) SetAccount(id, iMoney);//cs_set_user_money(id, iMoney, 1)
			Stock_EmitSound(id, sound_buyammo, CHAN_ITEM);

			set_pdata_int(iEnt, m_iClip, iClip > c_iClip[iWpnID] ? c_iClip[iWpnID] : iClip);
		}
		else
		{
			if (iClip >= c_iClip[iWpnID])
				return 0;

			ClientPrint(id, HUD_PRINTCENTER, "#Not_Enough_Money");
			BlinkAccount(id, 2);
		}

		return 0;
	}
	else
	{
		if (bSetFull || (c_iSpecial[iWpnID] != SPECIAL_BLOCKAR && c_iSpecial[iWpnID] != SPECIAL_BLOCKSMG))
		{
			new iCheck
			static iEnt2, iAmmoType2, iAmmo2
			// 修复子弹重复问题
			// 寻找武器是否存在
			iEnt2 = get_pdata_cbase(id,iSlot==2?m_rgpPlayerItems+1:m_rgpPlayerItems+2,5)

			// 修复DOUBLE子弹类型相同
			if (iEnt>0)
			{
				// 获得子弹类型
				iAmmoType2 = get_pdata_int(iEnt, m_iPrimaryAmmoType, 4)
				// 如果子弹类型相同,保存弹药
				if (iAmmoType == iAmmoType2 && pActive>0 && pActive == iEnt2)
				{
					iCheck = 1
					iAmmo2 = iAmmo
					set_pdata_int(id, m_rgAmmo_player_Slot0 + iAmmoType,iSlot==2?g_user_ammo[id][2]:g_user_ammo[id][1])
					iAmmo = (iSlot==2?g_user_ammo[id][2]:g_user_ammo[id][1])
				}
			}

			new iMaxAmmo = GetMaxAmmo(iWpnID, id);
			if (iAmmo >= iMaxAmmo)
				return 0;

			iMoney = get_pdata_int(id, m_iAccount);

			new i = 0, j = 0;
			while (iAmmo < iMaxAmmo)
			{
				if (!iFree)
				{
					iMoney -= c_iAmmoCost[iWpnID];

					if (iMoney < 0)
						break;
				}

				iAmmo += c_iAmmo[iWpnID];
				i ++;

				if (!bBuyFull)
					break;
			}

			if ((iAmmo >= iMaxAmmo && c_iType[iWpnID] == WEAPONS_SVDEX) || c_iSpecial[iWpnID] == SPECIAL_BLOCKAR  || c_iSpecial[iWpnID] == SPECIAL_BLOCKSMG)
			{
				new iExtraAmmo = GetExtraAmmo(iEnt);
				if (iExtraAmmo >= c_iExtraAmmo[iWpnID] && !i)
					return 0;

				while (iExtraAmmo < c_iExtraAmmo[iWpnID])
				{
					if (!iFree)
					{
						iMoney -= c_iExtraAmmoCost[iWpnID];

						if (iMoney < 0)
							break;
					}

					if(c_iSpecial[iWpnID] == SPECIAL_BLOCKSMG)
						iExtraAmmo = min(c_iExtraAmmo[iWpnID], iExtraAmmo + 9);
					else
						iExtraAmmo ++;
					
					j ++;

					if (!bBuyFull)
						break;
				}

				if (j)
					SetExtraAmmo(id, iEnt, iExtraAmmo);
			}

			if (i > 0|| j > 0)
			if (!iFree) SetAccount(id, iMoney);//cs_set_user_money(id, iMoney, 1)

			if (i)
			{
				if (g_dchanging[id] && c_iId[iWpnID + 1] != c_iId[iWpnID])
					for (new j = 0; j < i; j ++)
						GiveAmmo(id, c_iAmmo[iWpnID], WEAPON_AMMOTYPE[c_iId[iWpnID + 1]], iMaxAmmo);
				else
					for (new j = 0; j < i; j ++)
						GiveAmmo(id, c_iAmmo[iWpnID], WEAPON_AMMOTYPE[c_iId[iWpnID]], iMaxAmmo);

				Stock_EmitSound(id, sound_buyammo, CHAN_ITEM);

				// Also Update g_user_ammo
				g_user_ammo[id][iSlot] = get_pdata_int(id, m_rgAmmo_player_Slot0 + iAmmoType)
				set_pdata_int(id, m_rgAmmo_player_Slot0 + iAmmoType2 ,g_user_ammo[id][iSlot])
				// 还原弹药
				if (iCheck) set_pdata_int(id, m_rgAmmo_player_Slot0 + iAmmoType,iAmmo2)
			}
			else if (!j)
			{
				ClientPrint(id, HUD_PRINTCENTER, "#Not_Enough_Money");
				BlinkAccount(id, 5);
			}
		}
		else
		{
			if (c_iSpecial[iWpnID] == SPECIAL_BLOCKAR || c_iSpecial[iWpnID] == SPECIAL_BLOCKSMG)
			{
				if ((pev(iEnt, pev_iuser1) == STATUS_MODE1 || pev(iEnt, pev_iuser1) == STATUS_CHANGE2))
				{
					new iCheck
					static iEnt2, iAmmoType2, iAmmo2
					// 修复子弹重复问题
					// 寻找武器是否存在
					iEnt2 = get_pdata_cbase(id,iSlot==2?m_rgpPlayerItems+1:m_rgpPlayerItems+2,5)

					// 修复DOUBLE子弹类型相同
					if (iEnt>0)
					{
						// 获得子弹类型
						iAmmoType2 = get_pdata_int(iEnt, m_iPrimaryAmmoType, 4)
						// 如果子弹类型相同,保存弹药
						if (iAmmoType == iAmmoType2 && pActive>0 && pActive == iEnt2)
						{
							iCheck = 1
							iAmmo2 = iAmmo
							set_pdata_int(id, m_rgAmmo_player_Slot0 + iAmmoType,iSlot==2?g_user_ammo[id][2]:g_user_ammo[id][1])
							iAmmo = (iSlot==2?g_user_ammo[id][2]:g_user_ammo[id][1])
						}
					}

					new iMaxAmmo = GetMaxAmmo(iWpnID, id);
					if (iAmmo >= iMaxAmmo)
						return 0;

					iMoney = get_pdata_int(id, m_iAccount);

					new i = 0;
					while (iAmmo < iMaxAmmo)
					{
						
						if (!iFree)
						{
							iMoney -= c_iAmmoCost[iWpnID];

							if (iMoney < 0)
								break;
						}

						iAmmo += c_iAmmo[iWpnID];
						i ++;

						if (!bBuyFull)
							break;
					}

					if (i > 0)
					{
						if (!iFree)
							SetAccount(id, iMoney);
						if (g_dchanging[id] && c_iId[iWpnID + 1] != c_iId[iWpnID])
							for (new j = 0; j < i; j ++)
								GiveAmmo(id, c_iAmmo[iWpnID], WEAPON_AMMOTYPE[c_iId[iWpnID + 1]], iMaxAmmo);
						else
							for (new j = 0; j < i; j ++)
								GiveAmmo(id, c_iAmmo[iWpnID], WEAPON_AMMOTYPE[c_iId[iWpnID]], iMaxAmmo);

						Stock_EmitSound(id, sound_buyammo, CHAN_ITEM);

						// Also Update g_user_ammo
						g_user_ammo[id][iSlot] = get_pdata_int(id, m_rgAmmo_player_Slot0 + iAmmoType)
						set_pdata_int(id, m_rgAmmo_player_Slot0 + iAmmoType2 ,g_user_ammo[id][iSlot])
						// 还原弹药
						if (iCheck)
							set_pdata_int(id, m_rgAmmo_player_Slot0 + iAmmoType,iAmmo2)
					}
					else
					{
						ClientPrint(id, HUD_PRINTCENTER, "#Not_Enough_Money");
						BlinkAccount(id, 5);
					}
				}
				else
				{
					new iExtraAmmo = GetExtraAmmo(iEnt), j;
					if (iExtraAmmo >= c_iExtraAmmo[iWpnID])
						return 0;

					while (iExtraAmmo < c_iExtraAmmo[iWpnID])
					{
						if (!iFree)
						{
							iMoney -= c_iExtraAmmoCost[iWpnID];

							if (iMoney < 0)
								break;
						}

						iExtraAmmo ++;
						j ++;

						if (!bBuyFull)
							break;
					}

					if (j)
						SetExtraAmmo(id, iEnt, iExtraAmmo);
					else
					{
						ClientPrint(id, HUD_PRINTCENTER, "#Not_Enough_Money");
						BlinkAccount(id, 5);
					}
				}
			}
		}
	}
	return 0
}

public cmd_wpn_rebuy(id)
{
	if (!VIPCheck(id, TRUE))
		return PLUGIN_HANDLED;

	if (g_modruning == BTE_MOD_NONE || g_modruning == BTE_MOD_GHOST)
	{
		new bMsgSend = FALSE;

		for (new i=1; i<5; i++)
		{
			if (g_weapon[id][i] == g_save_guns[id][i] && get_pdata_cbase(id, m_rgpPlayerItems + i) > 0)
			{
				if (!bMsgSend)
				{
					ClientPrint(id, HUD_PRINTCENTER, "#Cstrike_Already_Own_Weapon");
					bMsgSend = TRUE;
				}
			}
			else
			{
				if (g_save_guns[id][i]) Pub_Give_Wpn_Check(id, g_save_guns[id][i]);
			}
		}
	}
	else
	{
		if (g_save_guns[id][1]) Pub_Give_Wpn_Check(id, g_save_guns[id][1]);
		if (g_save_guns[id][2]) Pub_Give_Wpn_Check(id, g_save_guns[id][2]);
		if (g_save_guns[id][3]) Pub_Give_Wpn_Check(id, g_save_guns[id][3]);
		if (g_save_guns[id][4]) Pub_Give_Wpn_Check(id, g_save_guns[id][4]);
	}


	return PLUGIN_HANDLED;
}

stock VIPCheck(id, bSendMsg)
{
	if (get_pdata_bool(id, m_bIsVIP))
	{
		if (bSendMsg)
			ClientPrint(id, HUD_PRINTCENTER, "#VIP_cant_buy");

		return 0;
	}

	return 1;
}

stock GetMaxAmmo(iWpnID, id)
{
	new iMaxAmmo = c_iMaxAmmo[iWpnID];

	if (!g_isZomMod5 && g_modruning==BTE_MOD_ZB1 && c_iMaxAmmo[iWpnID] < 200 && Pub_Ammo_Check(iWpnID))
		iMaxAmmo *= 2
	if (g_modruning==BTE_MOD_NPC && c_iMaxAmmo[iWpnID] > 1 && Pub_Ammo_Check(iWpnID))
		iMaxAmmo = 600
	if (bte_fun_get_have_mode_item(id, 4) && g_isZomMod3 && !g_isZomMod5 && g_modruning == BTE_MOD_ZB1 && Pub_Ammo_Check(iWpnID))
		iMaxAmmo = floatround(iMaxAmmo * 1.5)

	return iMaxAmmo;
}