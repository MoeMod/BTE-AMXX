// [BTE Public FUNCTION]

public OrpheuHookReturn:OnSelectItem_Pre(id, pstr[])
{
	if(!is_user_alive(id))
		return OrpheuIgnored;
	new iEnt = get_pdata_cbase(id, m_pActiveItem);
	new iBteWpn = g_weapon[id][0];
	if (c_iSpecial[iBteWpn] == SPECIAL_THANATOS9 && pev(iEnt, pev_iuser3))
	{
		return OrpheuSupercede;
	}
	if (c_iSpecial[iBteWpn] == SPECIAL_BLOODHUNTER && pev(iEnt, pev_iuser3))
	{
		return OrpheuSupercede;
	}
	if (c_iSpecial[iBteWpn] == SPECIAL_DUALSWORD && !DualSword_CanHolster(iEnt))
	{
		return OrpheuSupercede;
	}
	return OrpheuIgnored;
}

public OrpheuHookReturn:OnSelectLastItem_Pre(id)
{
	if(!is_user_alive(id))
		return OrpheuIgnored;
	new iEnt = get_pdata_cbase(id, m_pActiveItem);
	new iBteWpn = g_weapon[id][0];
	if (c_iSpecial[iBteWpn] == SPECIAL_THANATOS9 && pev(iEnt, pev_iuser3))
	{
		return OrpheuSupercede;
	}
	if (c_iSpecial[iBteWpn] == SPECIAL_BLOODHUNTER && pev(iEnt, pev_iuser3))
	{
		return OrpheuSupercede;
	}
	if (c_iSpecial[iBteWpn] == SPECIAL_DUALSWORD && !DualSword_CanHolster(iEnt))
	{
		return OrpheuSupercede;
	}
	return OrpheuIgnored;
}

public OnKickBack_Pre(iEnt, Float:up_base, Float:lateral_base, Float:up_modifier, Float:lateral_modifier, Float:up_max, Float:lateral_max, direction_change)
{
	static id, flags, Float:velocity, type, iBteWpn;
	id = get_pdata_cbase(iEnt, m_pPlayer);
	iBteWpn = g_weapon[id][0];

	if (!c_flKickBack[0][iBteWpn][0])
		return;

	flags = pev(id, pev_flags);
	velocity = GetVelocity2D(id);

	if (velocity > 0.0)
		type = 0;
	else if (!(flags & FL_ONGROUND))
		type = 1;
	else if (flags & FL_DUCKING)
		type = 2;
	else
		type = 3;

	for (new j=0; j<6; j++)
		OrpheuSetParam(j + 2, c_flKickBack[type][iBteWpn][j]);

	OrpheuSetParam(8, floatround(c_flKickBack[type][iBteWpn][6]));
}

public GetWeaponModeFireBullets3(id, iEnt, iBteWpn, iId, iWeaponState)
{
	static iButton;
	iButton = pev(id, pev_button);

	if (iWeaponState & WPNSTATE_M4A1_SILENCED) return 1;
	if (iWeaponState & WPNSTATE_USP_SILENCED) return 1;
	if (c_iSpecial[iBteWpn] == SPECIAL_INFINITY && (iButton & IN_ATTACK2)) return 1;
	//if (c_iSpecial[iBteWpn] == SPECIAL_BALROG3 && g_bl3_num[id] > 15) return 1;
	if (c_iSpecial[iBteWpn] == SPECIAL_JANUSMK5 && pev(iEnt, pev_iuser1) == JANUSMK5_USING) return 1;
	if (c_iSpecial[iBteWpn] == SPECIAL_JANUS11 && pev(iEnt, pev_iuser1) == JANUSMK5_USING) return 1;
	if (c_iSpecial[iBteWpn] == SPECIAL_BUFFM4A1) return get_pdata_int(id, m_iFOV) != 90;
	if (c_iSpecial[iBteWpn] == SPECIAL_BUFFAWP) return CBuffAWP_GetWeaponCharged(iEnt)
	return 0;
}

public OnFireBullets3_Pre( id, Float:source[3], Float:dirShooting[3], Float:spread, Float:distance, penetration, bulletType, damage, Float:rangerModifier, attacker, bool:isPistol, sharedRand )
{
	if(g_bIgnoreHook)
		return;
	if (id < 1 || id > 32)
		return;

	static iEnt, iId, iWeaponState, iBteWpn;
	iEnt = get_pdata_cbase(id, m_pActiveItem);
	iId = get_pdata_int(iEnt, m_iId);
	iWeaponState = get_pdata_int(iEnt, m_iWeaponState);
	iBteWpn = g_weapon[id][0] + g_double[id][0];

	if (c_flElitesFireSrcOfs[iBteWpn])
	{
		new Float:v_right[3];
		global_get(glb_v_right, v_right);

		new Float:ofs = 0.0;

		if (iId == CSW_ELITE)
		{
			if (iWeaponState & WPNSTATE_ELITE_LEFT) // remove elites defalut
				ofs = -5.0;
			else
				ofs = 5.0;
		}

		if (iWeaponState & WPNSTATE_ELITE_LEFT)
			ofs -= c_flElitesFireSrcOfs[iBteWpn];
		else
			ofs += c_flElitesFireSrcOfs[iBteWpn];

		xs_vec_mul_scalar(v_right, ofs, v_right);
		xs_vec_add(source, v_right, source);

		RageSetParam(2, source);
	}

	/*if (equal(c_sModel[iBteWpn], "dmp7a1"))
	{
		if (iWeaponState & WPNSTATE_ELITE_LEFT)
		{
			xs_vec_mul_scalar(v_right, -2.0, v_right);
			xs_vec_add(source, v_right, source);
		}
		else
		{
			xs_vec_mul_scalar(v_right, 2.0, v_right);
			xs_vec_add(source, v_right, source);
		}

		RageSetParam(2, source);
	}*/

	if (c_iSpecial[iBteWpn] == SPECIAL_M2 && g_iWeaponMode[id][1])
		spread *= 0.7;

	if (c_flBurstSpeed[iBteWpn] > 0 && !spread)
		spread = c_flBurstSpread[iBteWpn];

	if (g_flSpread[id] >= 0.0)
		spread = g_flSpread[id];

	RageSetParam(4, spread);

	new iType = GetWeaponModeFireBullets3(id, iEnt, iBteWpn, iId, iWeaponState);

	if (!IS_ZBMODE)
	{
		if (c_flDamage[iBteWpn][iType])
			RageSetParam(8, floatround(c_flDamage[iBteWpn][iType]));
	}
	else
	{
		if (c_flDamageZB[iBteWpn][iType])
			RageSetParam(8, floatround(c_flDamageZB[iBteWpn][iType]));
	}

	if (c_flRangeModifier[iBteWpn][iType])
	{
		rangerModifier = c_flRangeModifier[iBteWpn][iType];
		RageSetParam(9, rangerModifier);
	}

	if (c_iBulletType[iBteWpn])
	{
		bulletType = c_iBulletType[iBteWpn];
		RageSetParam(7, bulletType);
	}

	if (c_iPenetration[iBteWpn][iType])
	{
		penetration = c_iPenetration[iBteWpn][iType];
		RageSetParam(6, penetration);
	}

	if (c_flDistance[iBteWpn][iType])
	{
		distance = c_flDistance[iBteWpn][iType];
		RageSetParam(5, distance);
	}
#if defined _DEBUG
	PRINT("FrieBullets3: Damage: %d Spread: %f RangeModifier: %f BulletType: %d Penetration: %d", damage, spread, rangerModifier, bulletType, penetration);
#endif
}

public OnFireBullets_Pre( id, cShots, Float:vecSrc[3],  Float:vecDirShooting[3], Float:vecSpread[3], Float:flDistance, iBulletType, iTracerFreq, iDamage, pevAttacker)
{
	if(g_bIgnoreHook)
		return;
	if (id < 1 || id > 32)
		return;

	if (c_cShots[g_weapon[id][0]])
		cShots = c_cShots[g_weapon[id][0]];

	if (c_vecSpread[g_weapon[id][0]][0])
		vecSpread = c_vecSpread[g_weapon[id][0]];

	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_QBARREL)
	{
		new iEnt = get_pdata_cbase(id, m_pActiveItem);
		new iSpShoot = pev(iEnt, pev_iuser1);

		if (iSpShoot)
		{
			cShots = c_cShots[g_weapon[id][0]] ? c_cShots[g_weapon[id][0]] * iSpShoot : cShots * iSpShoot;

			vecSpread[0] *= 1.2;
			vecSpread[1] *= 1.2;
		}
	}

	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_SKULL11)
	{
		new iEnt = get_pdata_cbase(id, m_pActiveItem);
		if (get_pdata_int(iEnt, m_iWeaponState) & WPNSTATE_SKULL11_SLUG)
		{
			vecSpread[0] *= 0.15;
			vecSpread[1] *= 0.15;
		}
	}

	RageSetParam(2, cShots);
	RageSetParam(5, vecSpread);

#if defined _DEBUG
	PRINT("FrieBullets: cShots: %d Spread: %f", cShots, vecSpread[0]);
#endif
}

public OrpheuHookReturn:OnSetModel_Pre(iEnt, const szModel[])
{
	static iCswpn,iWpnEnt,iSlot,id,iLen
	iLen = strlen(szModel)
	if (iLen < 8) return OrpheuIgnored

	static classname[32];
	pev(iEnt, pev_classname, classname, charsmax(classname));
	if (equal(classname, "armoury_entity"))
	{
		new iItem = get_pdata_int(iEnt, m_iItem);

		if (iItem == ARMOURY_FLASHBANG || iItem == ARMOURY_KEVLAR || iItem == ARMOURY_ASSAULT || iItem == ARMOURY_SMOKEGRENADE)
			return OrpheuIgnored;

		//engfunc(EngFunc_SetModel, iEnt, "models/w_usp.mdl");
		OrpheuSetParam(2, "models/w_usp.mdl");
		return OrpheuOverride;
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
			return OrpheuSupercede
		}
	}*/

	if(szModel[7] == 'p' && szModel[8] == 'l' && szModel[8] == 'a' && szModel[8] == 'y') return OrpheuIgnored
	else if((szModel[7] == 'w' && szModel[8] == '_' && szModel[9] == 'h' && szModel[10] == 'e')) // grenade
	{
		id = pev(iEnt, pev_owner)
		g_lasthe[id] = g_weapon[id][4]
		//engfunc(EngFunc_SetModel, iEnt, c_sModel_W[g_weapon[id][4]])
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
		OrpheuSetParam(2, c_sModel_W[g_weapon[id][4]]);
		return OrpheuOverride;
	}
	else if(equal(szModel,"models/w_smokegrenade.mdl"))
	{
		//engfunc(EngFunc_SetModel, iEnt, "models/w_Grenade_1.mdl")
		set_pev(iEnt,pev_body,10)
		OrpheuSetParam(2, "models/w_Grenade_1.mdl");
		return OrpheuOverride;
	}
	else if(equal(szModel,"models/w_flashbang.mdl"))
	{
		//engfunc(EngFunc_SetModel, iEnt, "models/w_Grenade_1.mdl")
		set_pev(iEnt,pev_body,11)
		OrpheuSetParam(2, "models/w_Grenade_1.mdl");
		return OrpheuOverride;
	}
	//models/shield/p_shield_
	else if( iLen>26 && szModel[7] == 's' &&szModel[8] == 'h' &&szModel[9] == 'i' &&szModel[10] == 'e')
	{
		engfunc(EngFunc_RemoveEntity,iEnt)
		return OrpheuSupercede
	}
	//models/w_weaponbox.mdl
	else if(iLen>15 && szModel[7] == 'w' &&szModel[15] == 'b' &&szModel[16] == 'o' &&szModel[17] == 'x')
	{
		Set_Wpn_Data(iEnt,DEF_ISWEAPONBOX,1)
		return OrpheuIgnored
	}
	else if(iLen>11 && szModel[7] == 'w' &&szModel[8] == '_' &&szModel[9] == 'c' &&szModel[10] == '4')
	{
		return OrpheuIgnored
	}
	/*models/grenade.mdl
	else if(iLen>10 && szModel[7] == 'g' &&szModel[8] == 'r' &&szModel[9] == 'e' &&szModel[10] == 'n')
	{
		return OrpheuSupercede
	}*/
	//models/w_
	else if(szModel[7] != 'w' || szModel[8] != '_')
	{
		Util_Log("SetModel Skip: %s",szModel)
		return OrpheuIgnored
	}
	if(equal(szModel,"models/w_kevlar.mdl"))
	{
		return OrpheuIgnored;
	}
	/*if(get_pdata_int(iEnt,m_iDefaultAmmo,4))
	{
		return OrpheuSupercede
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
				if(CSWPN_NOTREMOVE & (1<<iCswpn)) return OrpheuIgnored

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
						//engfunc(EngFunc_SetModel, iEnt, "models/w_blockar2.mdl");
						OrpheuSetParam(2, "models/w_blockar2.mdl");
					}
					else
					{
						//engfunc(EngFunc_SetModel, iEnt, "models/w_blockar1.mdl");
						OrpheuSetParam(2, "models/w_blockar1.mdl");
					}
				}
				else if (c_iSpecial[g_weapon[id][iSlot]] == SPECIAL_BLOCKSMG)
				{
					if (pev(iWpnEnt, pev_iuser1))
					{
						//engfunc(EngFunc_SetModel, iEnt, "models/w_blockar2.mdl");
						OrpheuSetParam(2, "models/w_blocksmg2.mdl");
					}
					else
					{
						//engfunc(EngFunc_SetModel, iEnt, "models/w_blockar1.mdl");
						OrpheuSetParam(2, "models/w_blocksmg1.mdl");
					}
				}
				else
				{
					//engfunc(EngFunc_SetModel, iEnt, c_sModel_W[g_weapon[id][iSlot]])
					OrpheuSetParam(2, c_sModel_W[g_weapon[id][iSlot]]);
				}
				
				
				set_pev(iEnt, pev_body, c_iModel_W_Sub[g_weapon[id][iSlot]])
				Stock_Reset_Wpn_Slot(id,iSlot)

				if (g_modruning == BTE_MOD_TD || g_modruning == BTE_MOD_DM)
					g_c_fWeaponLastTime = 8.0

				if(g_c_fWeaponLastTime>0.1 && bte_get_user_zombie(id) != 1)
					set_pev(iEnt,pev_nextthink,get_gametime()+g_c_fWeaponLastTime)
				return OrpheuOverride
			}
		}
	}
	return OrpheuSupercede // May be occur a BUG?
}

public CheckZoom(id, iEnt, iBteWpn)
{
	if (get_pdata_float(iEnt, m_flNextSecondaryAttack) > 0.0)
		return;

	/*if (get_pdata_int(iEnt, m_fInSpecialReload)) // for M32
		return;*/

	if (!c_iZoom[iBteWpn][0])
		return;

	new iFov = get_pdata_int(id, m_iFOV);

	if (c_iZoom[iBteWpn][0] == c_iZoom[iBteWpn][1])
	{
		if (iFov != 90)
			iFov = 90;
		else
			iFov = c_iZoom[iBteWpn][1];
	}
	else
	{
		if (iFov == 90)
		{
			iFov = c_iZoom[iBteWpn][0];
		}
		else if (iFov == c_iZoom[iBteWpn][0])
		{
			iFov = c_iZoom[iBteWpn][1];
		}
		else
		{
			iFov = 90;
		}
			

		if (c_iSpecial[iBteWpn] != SPECIAL_SFSNIPER)
			emit_sound(id, CHAN_ITEM, "weapons/zoom.wav", 0.2, 0.4, 0, PITCH_NORM);
		else
			emit_sound(id, CHAN_ITEM, "weapons/sfsniper_zoom.wav", 0.2, 2.4, 0, 100);
	}

	set_pdata_int(id, m_iFOV, iFov);
	set_pev(id, pev_fov, float(iFov));

	ExecuteHam(Ham_Player_ResetMaxSpeed, id);

	set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.3);
	set_pdata_int(iEnt, m_fInSpecialReload, FALSE);

	set_pev(id, pev_button, pev(id, pev_button) & ~IN_ATTACK2);
}

public Pub_Shake(id)
{
	if (!c_iShake[g_weapon[id][0]]) return
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
	write_short((1<<12)*c_iShake[g_weapon[id][0]])
	write_short((1<<12)*1)
	write_short((1<<12)*c_iShake[g_weapon[id][0]])
	message_end()
}

public Pub_Buy_Named_Wpn(id, sName[])
{
	for (new i=1;i<=sizeof(c_sModel)-1;i++)
	{
		if (equal(sName, c_sModel[i]))
		{
			Pub_Give_Wpn_Check(id, i);
			return i;
		}
	}

	Util_Log("Failed buy weapon: %s",sName)

	return 0;
}



/*public OrpheuHookReturn:Orpheu_SetAnimation_Post ( const id, const Anim )
{
	if (Anim == 4) return OrpheuIgnored;
	if (bte_get_user_zombie(id) == 1)
	{
		if (get_user_weapon(id) != CSW_KNIFE) return OrpheuIgnored;
		if (g_iSequence[id])
		{
			new iFrame = pev(id, pev_frame);
			if (iFrame >= g_fKeepFrame[id])
			{
				g_iSequence[id] = 0;
				return OrpheuSupercede;
			}
			g_fKeepFrame[id] = iFrame
			set_pev(id, pev_sequence, g_iSequence[id]);
			set_pev(id, pev_framerate, 1.0);
			return OrpheuSupercede;
		}

		if (g_iOldAnim[id] == Anim && Anim != 1) return OrpheuIgnored;

		g_iOldAnim[id] = Anim;

		new iSequence;
		iSequence = Pub_Get_Seq(id);

		if (Anim == 2 || Anim == 3) iSequence = 83;

		if (iSequence != pev(id, pev_sequence))
		{
			set_pev(id, pev_frame, 0);
			set_pev(id, pev_animtime, get_gametime());
			set_pev(id, pev_sequence, iSequence);
		}



		static pAct;
		pAct = get_pdata_cbase(id, m_pActiveItem);

		//if (g_iSequence[id] || (get_pdata_float(pAct, m_flNextPrimaryAttack, 4) < 0.0 && get_pdata_float(pAct, m_flNextSecondaryAttack, 4) < 0.0 && Anim == 1 && get_user_weapon(id) == CSW_KNIFE))

		//set_pev(id, pev_framerate, 1.0);
		return OrpheuSupercede;
	}
	return OrpheuIgnored;
}
*/

public Pub_Grenade_Explode(iEnt,Float:fKnockBack)
{
	static iAttacker ,iIdwpn
	iAttacker = pev(iEnt, pev_owner)
	iIdwpn = Get_Ent_Data(iEnt,DEF_ENTID)

	static Float:vEntOrigin[3], Float:flDamage, Float:fRadius
	pev(iEnt, pev_fuser3, flDamage);
	pev(iEnt, pev_fuser4, fRadius);

	pev(iEnt, pev_origin, vEntOrigin)
	vEntOrigin[2] += 1.0

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_WORLDDECAL);
	write_coord_f(vEntOrigin[0]);
	write_coord_f(vEntOrigin[1]);
	write_coord_f(vEntOrigin[2]);
	write_byte(DECAL_SCORCH[random_num(0,1)]);
	message_end();

	vEntOrigin[2] -= 1.0;

	new iResult;
	iResult = RadiusDamage(vEntOrigin, iEnt, iAttacker, flDamage, fRadius, fKnockBack, DMG_EXPLOSION, FALSE, TRUE);

	if (c_iSpecial[iIdwpn] == SPECIAL_JANUS1 && iResult)
	{
		if (!is_user_alive(iAttacker)) return;

		new item = get_pdata_cbase(iAttacker, m_rgpPlayerItems + 2);
		if (item < 1) return;

		new iShootTime = pev(item, pev_iuser2);
		new iState = pev(item, pev_iuser1);

		iShootTime += 1;
		if (iShootTime >= 5 && iState != 2)
		{
			iState = 1;
			MH_SpecialEvent(iAttacker, 50 + iState);
			set_pev(item, pev_iuser1, iState);
			set_pev(item, pev_fuser1, get_gametime() + 11.0);

			//new iClip = get_pdata_int(item, m_iClip, 4);

			/*if (get_pdata_float(item, m_flTimeWeaponIdle) > iClip?2.83:1.03)
				set_pdata_float(item, m_flTimeWeaponIdle, -0.1);*/
		}

		if (iState != 2)
			set_pev(item, pev_iuser2, iShootTime);
	}

	if (c_iSpecial[iIdwpn] == SPECIAL_JANUS1)
		SendExplosion(iEnt, vEntOrigin, 1);
	else if (c_iSpecial[iIdwpn] == SPECIAL_FIRECRAKER) // TODO
		SendExplosion(iEnt, vEntOrigin, 2);
	else if (c_iType[iIdwpn] == WEAPONS_FG) // TODO
		SendExplosion(iEnt, vEntOrigin, 3);
	else if (c_iSpecial[iIdwpn] == SPECIAL_RPG)
		SendExplosion(iEnt, vEntOrigin, 5);
	else
		SendExplosion(iEnt, vEntOrigin, 0);


#if 0
	static Float:vColor[3][3]

	if (c_iSpecial[iIdwpn] == SPECIAL_FIRECRAKER)
	{
		vColor[0][0] = vColor[0][1]= 255.0
		vColor[0][2] = 0.0
		vColor[1][0] = vColor[1][1] = vColor[1][2] = 100.0
		vColor[2][0] = 50.0
		vColor[2][1] = 200.0
		vColor[2][2] = 50.0

		for (new i = 0;i<3;i++)
		{
			static Float:vOrigin[3]
			vOrigin[0] = vEntOrigin[0] + random_float(-100.0,100.0)
			vOrigin[1] = vEntOrigin[1] + random_float(-100.0,100.0)
			vOrigin[2] = vEntOrigin[2] + random_float(20.0,150.0)
			/*vOrigin[0] = vEntOrigin[0] + random_float(-50.0,50.0)
			vOrigin[1] = vEntOrigin[1] + random_float(-50.0,50.0)
			vOrigin[2] = vEntOrigin[2] + random_float(10.0,75.0)*/
			Stock_FireCracker_Effect(vOrigin,vColor[i])
		}
	}
	else
	{
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vEntOrigin, 0);
		write_byte(TE_EXPLOSION)
		engfunc(EngFunc_WriteCoord,vEntOrigin[0])
		engfunc(EngFunc_WriteCoord,vEntOrigin[1])
		engfunc(EngFunc_WriteCoord,vEntOrigin[2] + 20.0)
		write_short(g_sModelIndexFireball3)
		write_byte(25)
		write_byte(30)
		write_byte(TE_EXPLFLAG_NOSOUND)
		message_end()

		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vEntOrigin, 0);
		write_byte(TE_EXPLOSION)
		engfunc(EngFunc_WriteCoord,vEntOrigin[0] + random_float(-64.0,64.0))
		engfunc(EngFunc_WriteCoord,vEntOrigin[1] + random_float(-64.0,64.0))
		engfunc(EngFunc_WriteCoord,vEntOrigin[2] + random_float(30.0,35.0))
		write_short(g_sModelIndexFireball2)
		write_byte(30)
		write_byte(30)
		write_byte(c_iSpecial[iIdwpn] != SPECIAL_JANUS1 ? TE_EXPLFLAG_NONE : TE_EXPLFLAG_NOSOUND)
		message_end()

		if (c_iSpecial[iIdwpn] == SPECIAL_JANUS1)
			emit_sound(iEnt, CHAN_WEAPON, "weapons/janus1_exp.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);

		/*switch (random_num(0, 2))
		{
			case 0: emit_sound(iEnt, CHAN_WEAPON, "weapons/debris1.wav", 0.55, ATTN_NORM, 0, PITCH_NORM);
			case 1: emit_sound(iEnt, CHAN_WEAPON, "weapons/debris2.wav", 0.55, ATTN_NORM, 0, PITCH_NORM);
			case 2: emit_sound(iEnt, CHAN_WEAPON, "weapons/debris3.wav", 0.55, ATTN_NORM, 0, PITCH_NORM);
		}*/

	}
#endif
}


public Pub_Set_MaxSpeed(id,Float:fSpeed)
{
	if (bte_get_user_zombie(id) == 1) return;
	if (bte_get_user_zombie(id) == 2)
	{
		if (bte_get_user_sex(id) == SEX_MALE)
			g_fPlrMaxspeed[id] = 270.0;
		else
			g_fPlrMaxspeed[id] = 240.0;

		return;
	}
	// Set Gravity
	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_HAMMER)
	{
		if (g_hammer_stat[id])
		{
			g_fPlrMaxspeed[id] = c_flMaxSpeed[g_weapon[id][0]][0] - 100.0
		}
		else
		{
			g_fPlrMaxspeed[id] = c_flMaxSpeed[g_weapon[id][0]][0]
		}
		return
	}
	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_M2)
	{
		g_fPlrMaxspeed[id] = g_iWeaponMode[id][1]?0.1:c_flMaxSpeed[g_weapon[id][3]][0];
		return
	}
	g_fPlrMaxspeed[id] = fSpeed;

}
public Pub_Set_MaxSpeed2(id,Float:fSpeed)
{
	g_fPlrMaxspeed[id] = fSpeed;

	set_pev(id, pev_maxspeed, fSpeed);
	//ExecuteHamB(Ham_Item_PreFrame,id);
	return;
}

stock CheckBuyZone(id)
{
	if (is_user_bot(id))
		return TRUE;

	if (g_modruning != BTE_MOD_NONE && g_modruning != BTE_MOD_GHOST)
		return TRUE;

	if (!get_pcvar_num(cvar_freebuyzone))
		return TRUE;

	if (get_pdata_int(id, 235) & SIGNAL_BUY)
		return TRUE;

	return FALSE;
}

public Pub_Give_Wpn_Check(id, idwpn)
{
	if (bte_get_user_zombie(id)) return

	if (!is_user_alive(id) || !c_iId[idwpn] || !c_bCanBuy[idwpn]) return;

	static iMoney

	if (!(g_c_iWeaponLimitBit & 1<<c_iId[idwpn]) && g_c_iWeaponLimitBit)
		return

	if (c_iTeam[idwpn] != get_pdata_int(id, m_iTeam) && c_iTeam[idwpn] && g_modruning == BTE_MOD_NONE)
		return

	if (!CheckBuyZone(id))
		return

	if (g_fBuyTime < get_gametime() && (g_modruning == BTE_MOD_NONE || g_modruning == BTE_MOD_GHOST))
	{
		new str[4];
		format(str, 4, "%d", floatround(get_cvar_float("mp_buytime") * 60.0));
		ClientPrint(id, HUD_PRINTCENTER, "#Cant_buy", str);
		return
	}
	// Check Mod Buy
	if (c_iModeLimit[idwpn])
	{
		if (!(c_iModeLimit[idwpn] & (1<<g_modruning)))
			return
	}

	iMoney = cs_get_user_money(id) - c_iCost[idwpn]

	if (g_isZomMod5 && is_user_bot(id))
		iMoney = 16000;

	if (iMoney < 0 && !get_pcvar_num(cvar_freebuy))
	{
		ClientPrint(id, HUD_PRINTCENTER, "#Not_Enough_Money");
		BlinkAccount(id, 2);
		return
	}
	if (iMoney >= 0 && !get_pcvar_num(cvar_freebuy))
		SetAccount(id, iMoney);//cs_set_user_money(id,iMoney,1)

	Pub_Give_Idwpn(id, idwpn, 0)
}
public Pub_Ammo_Check(idwpn)
{
	return (c_iSpecial[idwpn] != SPECIAL_MUSKET && c_iSpecial[idwpn] != SPECIAL_CANNON && c_iSpecial[idwpn] != SPECIAL_M79 &&
		c_iSpecial[idwpn] != SPECIAL_FIRECRAKER && c_iSpecial[idwpn] != SPECIAL_CATAPULT && c_iSpecial[idwpn] != SPECIAL_BOW &&
		c_iSpecial[idwpn] != SPECIAL_DGUN && c_iSpecial[idwpn] != SPECIAL_JANUS1 && c_iSpecial[idwpn] != SPECIAL_SPEARGUN)
}


stock Pub_Give_Idwpn(id,idwpn,iType,iForceStripSlot = 0)
{
	if (idwpn < 0 || idwpn >= MAX_WPN || !c_iId[idwpn] || !c_sModel[idwpn][0]) 
		return;
	
	static iCswpn,iSlot

	if (!(g_c_iWeaponLimitBit & 1<<c_iId[idwpn]) && g_c_iWeaponLimitBit)
	{
		return
	}

	if (iType)
	{
		new iMoney = get_pdata_int(id, 115) /*cs_get_user_money(id)*/-c_iCost[idwpn]
		if (iMoney<0 && !get_pcvar_num(cvar_freebuy))
		{
			return
		}
	}

	if (!is_user_alive(id))
	{
		/*format(szMsg, charsmax(szMsg), "%L", LANG_PLAYER, "BTE_WPN_NOTICE_NOT_ALIVE")
		client_print(id,print_chat,szMsg)*/
		return;
	}
	if (bte_get_user_zombie(id) && !iType)
	{
		/*format(szMsg, charsmax(szMsg), "%L", LANG_PLAYER, "BTE_WPN_NOTICE_NOT_HUMAN")
		client_print(id,print_chat,szMsg)*/
		return;
	}

	if (c_iSlot[idwpn] == 4 && !bte_get_user_zombie(id))
		g_save_guns[id][c_iSlot[idwpn]] = idwpn

	g_save_guns[id][c_iSlot[idwpn]] = idwpn // save

	if (c_iSlot[idwpn] != 4)
	{
		if (c_iSlot[idwpn] < 3 && !iForceStripSlot)
			Stock_Drop_Slot(id,c_iSlot[idwpn])
		else
			Stock_Strip_Slot(id, c_iSlot[idwpn]) // Strip weapon
	}
	else if(c_iSlot[idwpn] != 5 && c_iSlot[idwpn] != 6)
	{
		RemoveGrenade(id);
	}

	iCswpn = c_iId[idwpn]
	iSlot = c_iSlot[idwpn]

	new maxammo = c_iMaxAmmo[idwpn]
	new check = Pub_Ammo_Check(idwpn);

	if (g_modruning == BTE_MOD_ZB1 && c_iMaxAmmo[idwpn] < 200 && check)
		maxammo *= 2
	if (g_modruning == BTE_MOD_NPC && c_iMaxAmmo[idwpn] > 1 && check)
		maxammo = 600

	if (/*bte_fun_get_have_mode_item(id,4) && */g_isZomMod3 && check)
		maxammo = floatround(maxammo * 1.5)

	if (g_modruning == BTE_MOD_ZB1 && c_iMaxAmmo[idwpn] < 200 && g_isZomMod5 && check)
		maxammo = floatround(maxammo / 2.0);

	// unlimited ammo for BOT
	if (g_modruning == BTE_MOD_ZB1 && g_isZomMod5 && check && is_user_bot(id))
		maxammo = 999;

	// Set Value
	g_weapon[id][iSlot] = idwpn
	g_user_ammo[id][iSlot] = maxammo

	// Update Pickup & Ammo HUD
	if (c_iSlot[idwpn] == WPN_KNIFE) 
	{
		Stock_Give_Cswpn(id, idwpn, WEAPON_NAME[CSW_KNIFE])
	}
	else if (c_iSlot[idwpn] == WPN_HE)
	{
		Stock_Give_Cswpn(id, idwpn, WEAPON_NAME[iCswpn])
		if ((bte_fun_get_have_mode_item(id,4) && g_isZomMod3 && bte_get_user_zombie(id)!=1) || g_isZomMod4) 
			set_pdata_int(id, OFFSET_HE_AMMO, 2, OFFSET_LINUX_WEAPONS)
	}
	else if (c_iSlot[idwpn] == 5 || c_iSlot[idwpn] == 6)
	{
		Stock_Give_Cswpn(id, idwpn, WEAPON_NAME[iCswpn])
	}
	else
	{
		Pub_Give_Reset(id,idwpn)

		if (g_modruning == BTE_MOD_NONE || g_modruning == BTE_MOD_NPC/* || g_modruning == BTE_MOD_GHOST*/) // None Mode
		{
			g_user_ammo[id][iSlot] = 0
			g_user_clip[id][iSlot] = c_iClip[idwpn]
			if (is_user_bot(id) || !Pub_Ammo_Check(idwpn))
			{
				g_user_ammo[id][iSlot] = maxammo
			}

			if (c_iType[idwpn] == WEAPONS_LAUNCHER)
			{
				if (c_iClip[idwpn]) g_user_clip[id][iSlot] = c_iClip[idwpn]
				Stock_Give_Cswpn(id, idwpn, WEAPON_NAME[iCswpn])
			}
			else
			{
				Stock_Give_Cswpn(id, idwpn, WEAPON_NAME[iCswpn])
				if (c_iType[idwpn] == WEAPONS_DOUBLE)
					Stock_Give_Cswpn(id, idwpn, WEAPON_NAME[c_iId[idwpn + 1]], 1)
			}
		}
		else
		{
			g_user_clip[id][iSlot] = c_iClip[idwpn]
			new iTimes
			if (c_iClip[idwpn])
			{
				iTimes = maxammo/c_iAmmo[idwpn]
			}
			else iTimes = maxammo/1
			if (c_iType[idwpn] == WEAPONS_LAUNCHER)
			{
				if (c_iClip[idwpn]) g_user_clip[id][iSlot] = c_iClip[idwpn]
				Stock_Give_Cswpn(id, idwpn, WEAPON_NAME[iCswpn])
			}
			else
			{
				Stock_Give_Cswpn(id, idwpn, WEAPON_NAME[iCswpn])
				if (c_iType[idwpn] == WEAPONS_DOUBLE)
					Stock_Give_Cswpn(id, idwpn, WEAPON_NAME[c_iId[idwpn + 1]],1)

			}

			if (g_modruning != BTE_MOD_GHOST)
			{
				for (new i = 0; i < iTimes ; i++)
				{
					message_begin(MSG_ONE_UNRELIABLE, g_msgAmmoPickup, _, id)
					write_byte(WEAPON_AMMOID[c_iId[idwpn]])
					write_byte(c_iAmmo[idwpn])
					message_end()
				}
			}

			g_user_ammo[id][iSlot] = maxammo

			if (g_modruning == BTE_MOD_ZB1 && c_iType[idwpn] != WEAPONS_LAUNCHER)
			{
				g_user_ammo[id][iSlot] = maxammo
			}
		}
	}
	// Give Special Ammo
	if (c_iSpecial[idwpn] == SPECIAL_MUSKET)
	{
		g_user_ammo[id][iSlot] = maxammo
	}

	// Reset Special Weapon Data

	if (c_iType[idwpn]==WEAPONS_DOUBLE)
		client_cmd(id,"weapon_%s",c_sModel[idwpn])

}

public Pub_Give_Default_Wpn(id,iType)
{
	if (g_modruning == BTE_MOD_GD && iType != 3) return;

	if (iType == 1 || iType == 4) return
	if (iType == 3)
	{
		if (g_bDefaultWeaponLimited[3])
		{
			g_weapon[id][3] = 1
			Stock_Give_Cswpn(id, _, WEAPON_NAME[CSW_KNIFE])
		}

		return
	}

	if (get_user_team(id) == 1)
	{
		if ((g_c_iWeaponLimitBit & (1 << CSW_GLOCK18) || !g_c_iWeaponLimitBit) && g_bDefaultWeaponLimited[2])
		{
			g_weapon[id][2] = 2
			g_user_ammo[id][2] = 40
			Stock_Give_Cswpn(id, _, WEAPON_NAME[CSW_GLOCK18])
		}
	}
	else
	{
		if ((g_c_iWeaponLimitBit & (1 << CSW_USP) || !g_c_iWeaponLimitBit) && g_bDefaultWeaponLimited[3])
		{
			g_weapon[id][2] = 3
			g_user_ammo[id][2] = 24
			Stock_Give_Cswpn(id, _, WEAPON_NAME[CSW_USP])
		}
	}
}

public Pub_Init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_dictionary("bte_wpn.bte")

	get_configsdir(g_szConfigDir, charsmax(g_szConfigDir))
	get_mapname(g_szMapName, charsmax(g_szMapName))
	formatex(g_szLogName, charsmax(g_szLogName),"%s/%s", g_szConfigDir,BTE_LOG_FILE)
	if (file_exists(g_szLogName))
	{
		delete_file(g_szLogName)
		Util_Log("Previous log has been deleted!")
		Util_Log("BTE Weapon Version:3.0 2014-6-7")
	}
}
public Pub_ShutDown()
{
	Util_Log("Server Shutdown!")
}

stock Pub_Give_Named_Wpn(id, sName[])
{
	for (new i=1;i<=sizeof(c_sModel)-1;i++)
	{
		if (equal(sName, c_sModel[i]))
		{
			Pub_Give_Wpn_Check(id, i);

			return i;
		}
	}
	Util_Log("FAILED Give %d : %s",id, sName)
	return 0
}


public Pub_Killed_Reset(id)
{

}
public Pub_DisConnectReset(id)
{
	Stock_Reset_Wpn_Slot(id,0)
	Stock_Reset_Wpn_Slot(id,1)
	Stock_Reset_Wpn_Slot(id,2)
	Stock_Reset_Wpn_Slot(id,3)
	Stock_Reset_Wpn_Slot(id,4)
}
public Pub_Give_Reset(id,idwpn)
{
	if (c_iSlot[idwpn] == 1)
	{
		g_double[id][c_iSlot[idwpn]] = 0
		g_iWeaponMode[id][1] = 0;
		g_iBlockSwitchDrop[id] = 0;
	}
	if (c_iSlot[idwpn] == 3)
	{
		g_hammer_stat[id] = 0;
	}
}
public Pub_Holster_Reset(id,iEnt)
{
	Task_Reset(id)
	g_dchanging[id] = 0

	if (iEnt > 1)
		set_pdata_float(iEnt, m_flFamasShoot, 0.0)

	if (c_iType[g_weapon[id][0]] == WEAPONS_M134)
		set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_M134_IDLE);

	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_BLOCKAR || c_iSpecial[g_weapon[id][0]] == SPECIAL_BLOCKSMG)
	{
		if (pev(iEnt, pev_iuser1) == STATUS_CHANGE1)
			set_pev(iEnt, pev_iuser1, STATUS_MODE2);
		else if (pev(iEnt, pev_iuser1) == STATUS_CHANGE2)
			set_pev(iEnt, pev_iuser1, STATUS_MODE1);
		set_pev(iEnt, pev_fuser1, 0.0);
		set_pev(iEnt, pev_fuser3, 0.0);
	}

	if (c_iSpecial[g_weapon[id][0]] == SPECIAL_GAUSS)
	{
		static Float:vecOrigin[3], Float:vecAngles[3];
		pev(id, pev_origin, vecOrigin);
		pev(id, pev_angles, vecAngles);
		PLAYBACK_EVENT_FULL( FEV_RELIABLE | FEV_GLOBAL, id, m_usGaussFire, 0.01, vecOrigin, vecAngles, 0.0, 0.0, 0, 0, 0, 1 );
		SendWeaponAnim(id, 7);

		set_pev(iEnt, pev_iuser1, 0);
		set_pdata_float(id, m_flNextAttack, 0.5);
	}

	/*if (g_dchanging[id] && iEnt)
	{
		static iSlot
		iSlot = ExecuteHam(Ham_Item_ItemSlot,iEnt)
		 g_double_save_clip[id]g_user_clip[iSlot][id]
		g_user_ammo[iSlot][id] = g_double_save_ammo[id]
		g_double_save_clip[id] = g_double_save_ammo[id] = 0
	}*/
	g_dchanging[id] = 0
}