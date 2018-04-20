// Made by MoeMod (aka Xiaobaibai | Sh@de.cc)
// data from CSO KR mp.dll 2018/4/19

// m_iClip -> (this+172)
// m_flTimeWeaponIdle -> (this+156)

// pev_iuser1 -> (this + 292) = iMode
// pev_waterlevel -> (this + 288) = pEntity
// pev_watertype -> (this + 296) = iStatus2
// pev_iuser3 -> (this + 308) = iAnim1
// pev_iuser4 -> (this + 312) = iAnim2

// pev_fuser1 -> (this + 320) = flNextSpecialAttack0
// pev_fuser2 -> (this + 324) = flNextSpecialAttack1
// pev_fuser3 -> (this + 328) = flNextSpecialAttack2

// pev_fuser4 -> (this + 332) = flNextSpecialAttack4
// pev_teleport_time -> (this + 336) = flNextSpecialAttack5
// pev_air_finished -> (this + 340) = flNextSpecialAttack6
// pev_pain_finished -> (this + 344) = flNextSpecialAttack7
// pev_dmg_take -> (this + 348) = flNextSpecialAttack8
// pev_dmg_save -> (this + 352) = flNextSpecialAttack9
// pev_dmgtime -> (this + 356) = flNextSpecialAttack10
// pev_speed -> (this + 360) = flNextSpecialAttack11

public CGunkata_Deploy(this) // bool sub_1026F9F0(this)
{
	set_pdata_float(this, m_flAccuracy, 1.1); // (this + 228) = 1.1
	set_pev(this, pev_iuser1, 0); // (this + 292) = 0
	set_pev(this, pev_fuser1, Float:0x7F7FFFFF); // 320
	set_pev(this, pev_teleport_time, Float:0x7F7FFFFF); // 336
	set_pev(this, pev_dmg_save, Float:0x7F7FFFFF); // 352
	set_pev(this, pev_speed, Float:0x7F7FFFFF); // 360
	
	/*new iDeployAnim = CGunkata_GetLRMode(this) ? 8:9
	// DefaultDeploy("models/v_gunkata.mdl", "models/p_gunkata.mdl", iDeployAnim, "dualpistols", v4 != 0, 0, 1.03)
	*/
	set_pdata_float(this, m_flNextPrimaryAttack, 0.2); // this+148
	set_pdata_float(this, m_flNextSecondaryAttack, 0.2); // this+152
	set_pdata_float(this,m_flTimeWeaponIdle, 1.03);
}

stock Float:CGunkata_GetDamage(iMode)
{
	if(iMode)
	{
		if(iMode == 1)
		{
			if(IS_ZBMODE)
			{
				return 87.0;
			}
			else
			{
				if(0/* && IS_ZBS*/)
					return 239.0;
				else
					return 22.0
			}
		}
		else if(iMode == 2)
		{
			if(IS_ZBMODE)
			{
				return 95.0;
			}
			else
			{
				if(0/* && IS_ZBS*/)
					return 265.0;
				else
					return 30.0
			}
		}
		else
		{
			return 0.0;
		}
	}
	else
	{
		if(IS_ZBMODE)
		{
			return 122.0;
		}
		else
		{
			if(0/* && IS_ZBS*/)
				return 240.0;
			else
				return 34.0
		}
	}
	return 0.0;
}

/*stock CGunkata_GetItemID(this) // sub_1026DF60
{
	return 395;
}*/

stock CGunkata_ItemPostFrame(id, this, iClip, iBteWpn)
{
	new iMode = pev(this, pev_iuser1); // (this + 292)
	//new id = get_pdata_cbase(this, m_pPlayer); // (this+112)
	//new iClip = get_pdata_int(this, m_iClip); // (this+172)
	switch(iMode)
	{
		case 1:
		{
			// sub_1026FA60((void *)(a1 + 320), (int *)gametime);
			set_pev(this, pev_fuser1, get_gametime());// pev_fuser1 -> (this + 320) = flNextSpecialAttack0
			set_pev(this, pev_fuser2, get_gametime());// pev_fuser2 -> (this + 324) = flNextSpecialAttack1
			set_pev(this, pev_fuser3, get_gametime());// pev_fuser3 -> (this + 328) = flNextSpecialAttack2
			set_pev(this, pev_fuser4, get_gametime());// pev_fuser4 -> (this + 332) = flNextSpecialAttack4
			set_pev(this, pev_teleport_time, get_gametime());// pev_teleport_time -> (this + 336) = flNextSpecialAttack5
			set_pev(this, pev_air_finished, get_gametime());// pev_air_finished -> (this + 340) = flNextSpecialAttack6
			set_pev(this, pev_pain_finished, get_gametime());// pev_pain_finished -> (this + 344) = flNextSpecialAttack7
			set_pev(this, pev_dmg_take, get_gametime());// pev_dmg_take -> (this + 348) = flNextSpecialAttack8
			set_pev(this, pev_dmg_save, get_gametime());// pev_dmg_save -> (this + 352) = flNextSpecialAttack9
			set_pev(this, pev_dmgtime, get_gametime());// pev_dmgtime -> (this + 356) = flNextSpecialAttack10
			set_pev(this, pev_speed, get_gametime());// pev_speed -> (this + 360) = flNextSpecialAttack11

			set_pev(this, pev_fuser4, get_gametime() + 0.2 * 1.0/*?*/);
			set_pev(this, pev_fuser2, get_gametime() + 0.2);
			
			// pEntity = sub_104BB1D0(id, "gunkata"); // 288
			iMode = 2;
			set_pev(this, pev_iuser1, iMode);
			
			set_pev(this, pev_iuser3, 13);
			set_pev(this, pev_iuser4, 11);
			//break;
		}
		case 2: // ”无影手“
		{
			if(iClip/*(this+172)*/ > 0)
			{
				if(pev(id, pev_button) & IN_ATTACK2) // (pPlayer + 396) & 0x800
				{
					new Float:flNextSpecialAttack1; pev(this, pev_fuser2, flNextSpecialAttack1);/*(this+324)*/
					if(get_gametime() >= flNextSpecialAttack1)
					{
						new iAnim1 = pev(this, pev_iuser3); // this+308, v16
						new iAnim2 = pev(this, pev_iuser4); // this+312
						new Float:v14 = 1.0; // 0x3F800000
						if ( iAnim1 == 10 || iAnim1 == 11 || iAnim1 == 4 )
						{
							v14 = 0.7; // 0x3F333333
						}
						else if(iAnim1 == 2)
						{
							v14 = 0.53; // 0x3F07AE14
						}
						// dword_108F7A0C(32,*(_DWORD *)(pPlayer + 540),*(_WORD *)(this + 286),0,pPlayer + 8,&qword_108F77EC,
						//	v14,0,iAnim1,0,1,1
						PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, v14,0.0,iAnim2,0,1,1); // show additional vmodel
						SendWeaponAnim(id, iAnim1);
						/*
						// CGunkata_sub_101710E0(&iAnim1, (int)&v45, iAnim1);
						if(iAnim1 == iAnim2) // ???
						{
							iAnim2 = iAnim1;
							set_pev(this, pev_iuser4, iAnim2);
							// CGunkata_sub_1026DA30(iAnim1, (int)v25, (int)v24, v23);
							// CGunkata_sub_1004B410((int)*v20, iAnim2);
						}
						*/
						iAnim1 = iAnim2;
						iAnim2+=1;
						if(iAnim2 == 14)
						{
							iAnim2 -= 4; // ???
						}
						set_pev(this, pev_iuser3, iAnim1);
						set_pev(this, pev_iuser4, iAnim2);
						flNextSpecialAttack1 = get_gametime() + 0.4;
						set_pev(this, pev_fuser2, flNextSpecialAttack1);
						//client_print(id, print_chat, "flNextSpecialAttack1, iAnim1=%d, iAnim2=%d", iAnim1, iAnim2);
					}
					
					new Float:flNextSpecialAttack2; pev(this, pev_fuser3, flNextSpecialAttack2);/*(this+328)*/
					if(get_gametime() >= flNextSpecialAttack2)
					{
						new iAnim1 = pev(this, pev_iuser3); // this+308, v18
						new iAnim2 = pev(this, pev_iuser4); // this+312
						new Float:v22; // v40
						if ( iAnim1 == 10 || iAnim1 == 11 || iAnim1 == 4 )
						{
							v22 = 0.7; // v12
						}
						else if(iAnim1 == 2)
						{
							v22 = 0.53; // v11
						}
						else
						{
							v22 = 1.0; // 0x3F800000
						}
						// dword_108F7A0C(32,*(_DWORD *)(pPlayer + 540),*(_WORD *)(this + 286),0,pPlayer + 8,&qword_108F77EC,
						//	v22,0,iAnim1,0,0,1);
						PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, v22,0.0,iAnim2,0,0,1); // show additional vmodel
						SendWeaponAnim(id, iAnim1);
						/*
						// CGunkata_sub_101710E0(&iAnim1, (int)&v45, iAnim1);
						if(iAnim1 == iAnim2) // ???
						{
							iAnim2 = iAnim1;
							set_pev(this, pev_iuser4, iAnim2);
							// CGunkata_sub_1026DA30(iAnim1, (int)v25, (int)v24, v23);
							// CGunkata_sub_1004B410((int)*v20, iAnim2);
						}
						*/
						iAnim1 = iAnim2;
						iAnim2+=1;
						if(iAnim2 == 14)
						{
							iAnim2 -= 4; // ???
						}
						
						set_pev(this, pev_iuser3, iAnim1);
						set_pev(this, pev_iuser4, iAnim2);
						flNextSpecialAttack2 = get_gametime() + v22;
						set_pev(this, pev_fuser3, flNextSpecialAttack2);
						//client_print(id, print_chat, "flNextSpecialAttack2, iAnim1=%d, iAnim2=%d", iAnim1, iAnim2);
					}
					new Float:flNextSpecialAttack0; pev(this, pev_fuser1, flNextSpecialAttack0);/*(this+320)*/
					if(get_gametime() >= flNextSpecialAttack0)
					{
						//v26 = id;
						// CGunkata_sub_10114650(id, 2.03, pEntity); // reload ?
						set_pev(id, pev_weaponmodel2, "models/p_gunkata2.mdl");
						// pPlayer->pev->?(296) = pEntity;
						// pPlayer->pev->?(304) = 0;
						//sub_104BB200(pPlayer);
						flNextSpecialAttack0 = get_gametime() + 2.03;
						set_pev(this, pev_fuser1, flNextSpecialAttack0);
						//client_print(id, print_chat, "flNextSpecialAttack0");
					}
					
					new Float:flNextSpecialAttack5; pev(this, pev_teleport_time, flNextSpecialAttack5);/*(this+336)*/
					if(get_gametime() >= flNextSpecialAttack5) // ?? effect
					{
						// dword_108F7A0C(32,*(_DWORD *)(pPlayer + 540),*(_WORD *)(this + 286),0,pPlayer + 8,&qword_108F77EC,
						//	0.87, 0,0,0,0,2);
						PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, 0.87, 0.0,0,0,0,2);
						flNextSpecialAttack5 = get_gametime() + 0.87;
						set_pev(this, pev_teleport_time, flNextSpecialAttack5);
					//	client_print(id, print_chat, "flNextSpecialAttack5");
					}
					
					new Float:flNextSpecialAttack4; pev(this, pev_fuser4, flNextSpecialAttack4);/*(this+332)*/
					if(get_gametime() >= flNextSpecialAttack4) // player model effect
					{
						new v26 = 0;
						if(pev(id, pev_flags) & FL_DUCKING)
							v26 = 6;
						new iStatus2 = pev(this, pev_iuser4) - 10;
						// dword_108F7A0C(32,*(_DWORD *)(pPlayer + 540),*(_WORD *)(this + 286),0,pPlayer + 8,&qword_108F77EC
						//	10.0, 2.0, 120, 500, v26+iStatus2, 4);
						PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, 10.0, 2.0, v26+iStatus2, 4, 0, 4);
						// CGunkata_sub_101710E0(this + 296, (int)&v45, *(this + 296));
						// sub_1004DFD0(this + 296, (unsigned int *)&v46);
						flNextSpecialAttack4 = get_gametime() + 0.2;
						set_pev(this, pev_fuser4, flNextSpecialAttack4);
						//client_print(id, print_chat, "flNextSpecialAttack4");
					}
					
					new Float:flNextSpecialAttack6; pev(this, pev_air_finished, flNextSpecialAttack6);/*(this+340)*/
					if(get_gametime() >= flNextSpecialAttack6)
					{
						CGunkata_RadiusAttack1(this);
						flNextSpecialAttack6 = get_gametime() + 0.082500003;
						set_pev(this, pev_air_finished, flNextSpecialAttack6);
					}
					
					new Float:flNextSpecialAttack7; pev(this, pev_pain_finished, flNextSpecialAttack7);/*(this+344)*/
					if(get_gametime() >= flNextSpecialAttack7)
					{
						//--*(_DWORD *)(this + 172);
						--iClip;
						set_pdata_int(this, m_iClip, iClip);
						flNextSpecialAttack7 = get_gametime() + 0.082500003;
						set_pev(this, pev_pain_finished, flNextSpecialAttack7);
						//client_print(id, print_chat, "flNextSpecialAttack7");
					}
					
					//break;
				}
				else // aka !(pev(id, pev_button) & IN_ATTACK2)
				{
					// dword_108F7A0C(32,*(_DWORD *)(pPlayer + 540),*(_WORD *)(this + 286),0,pPlayer + 8,&qword_108F77EC
					//	0 ,0, 0, 0, 0, 5);
					PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, 0.0 ,0.0, 0, 0, 0, 5);
					iMode = 4;
					set_pev(this, pev_iuser1, iMode); // *(_DWORD *)(this + 292) = 4;
					//client_print(id, print_chat, "release IN_ATTACK2");
					return HAM_IGNORED;
				}
			}
			else // iClip this+172 <=0
			{
				
				SendWeaponAnim(id, 15); //(*(void (__cdecl **)(signed int, _DWORD))(*(_DWORD *)a1 + 540))(15, 0);
				// v6 = sub_104BB1D0(id, "gunkata_end"); // lookup_sequence
				
				 //set_pev(id, ???(pPlayer->pev+304), 0); // (pPlayer->pev) + 304) = 0; 
				//*(_WORD *)(pPlayer + 2308) = v6;
				//*(float *)(pPlayer + 2304) = *(float *)gametime + 1.1;
				
				set_pev(id, pev_weaponmodel2, "models/p_gunkata.mdl");
				new Float:flNextSpecialAttack8 = get_gametime() + 0.63;
				set_pev(this, pev_dmg_take, flNextSpecialAttack8); /*(this+348)*/
				
				set_pev(this, pev_dmg_save, get_gametime() + 0.63); // this+352 = get_gametime() + 0.63
				set_pev(this, pev_dmgtime, get_gametime() + 1.1);// this+356 = get_gametime() + 1.1
				set_pev(this, pev_speed, get_gametime() + 1.1);// this+360 = get_gametime() + 1.1
				
				// dword_108F7A0C(32,*(_DWORD *)(pPlayer + 540),*(_WORD *)(this + 286),0,pPlayer + 8,&qword_108F77EC,
				//	0 ,0, 0, 0, 0, 5);
				PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, 0.0 ,0.0, 0, 0, 0, 5);
				iMode = 3;
				set_pev(this, pev_iuser1, iMode); // this+292
				//client_print(id, print_chat, "iClip<=0");
				return HAM_IGNORED;
			}
			//break;
		}
		case 3: // ”冲击波“
		{
			new Float:flNextSpecialAttack8; pev(this, pev_dmg_take, flNextSpecialAttack8);/*(this+348)*/
			if(get_gametime() >= flNextSpecialAttack8)
			{
				// dword_108F7A0C(32,*(_DWORD *)(pPlayer + 540),*(_WORD *)(this + 286),0,pPlayer + 8,&qword_108F77EC,
				//	1.0 ,0.22, 0, 0, 0, 3);
				PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, 1.0 ,0.22, 0, 0, 0, 3);
				flNextSpecialAttack8 = Float:0x7F7FFFFF; // infinity float
				set_pev(this, pev_dmg_take, flNextSpecialAttack8);
				//client_print(id, print_chat, "flNextSpecialAttack8");
			}
			
			new Float:flNextSpecialAttack9; pev(this, pev_dmg_save, flNextSpecialAttack9);/*(this+352)*/
			if(get_gametime() >= flNextSpecialAttack9)
			{
				CGunkata_RadiusAttack2(this); // RadiusAttack
				if ( !IS_ZBMODE ) //  !sub_10034A10()
				{
					flNextSpecialAttack9 = Float:0x7F7FFFFF; // infinity float
					set_pev(this, pev_dmg_save, flNextSpecialAttack9);
					//client_print(id, print_chat, "flNextSpecialAttack9");
				}
			}
			
			new Float:flNextSpecialAttack10; pev(this, pev_dmgtime, flNextSpecialAttack10);/*(this+356)*/
			if(get_gametime() >= flNextSpecialAttack10)
			{
				new maxclip = c_iClip[iBteWpn]; // v31
				
				new iAmmoType = m_rgAmmo_player_Slot0 + get_pdata_int(this, m_iPrimaryAmmoType, 4)
				new iBpAmmo = get_pdata_int(id, iAmmoType);
				
				new delta = maxclip - iClip;
				//if ( *(_DWORD *)(v34 + 4 * v32 + 1272) < v31 - v30 )
				if(iBpAmmo < maxclip - iClip)
				{
					delta = iBpAmmo;
				}
				
				iClip+=delta;
				set_pdata_int(this, m_iClip, iClip);
				iBpAmmo -= delta;
				set_pdata_int(id, iAmmoType, iBpAmmo);
				
				flNextSpecialAttack10 = Float:0x7F7FFFFF; // infinity float
				set_pev(this, pev_dmgtime, flNextSpecialAttack10);
				//client_print(id, print_chat, "flNextSpecialAttack10");
			}
			
			new Float:flNextSpecialAttack11; pev(this, pev_speed, flNextSpecialAttack11);/*(this+360)*/
			if(get_gametime() >= flNextSpecialAttack11)
			{
				iMode = 4;
				set_pev(this, pev_iuser1, iMode);
				//client_print(id, print_chat, "flNextSpecialAttack11");
				return HAM_IGNORED;
				
			}
			//break;
		}
		case 4:
		{
			set_pev(id, pev_weaponmodel2, "models/p_gunkata.mdl");
			// *(_DWORD *)(pPlayer + 2304) = -1.0;
			// *(_WORD *)(pPlayer + 2308) = -1;
			/*
			if ( (*(int (__stdcall **)(int, int))(pPlayer + 152))(a2, a3) )
			{
				*(_DWORD *)(pPlayer + 104) = 1;
				(*(void (__stdcall **)(_DWORD))(pPlayer + 448))(0);
				*(_DWORD *)(pPlayer->pev + 304) = 0;
				sub_104BB200(pPlayer);
			}
			*/
			
			SendWeaponAnim(id, !CGunkata_GetLRMode(this) ? 9:8);
			
			iMode = 0;
			set_pev(this, pev_iuser1, iMode); // this+292
			
			// this+228 = 1.1
			set_pdata_float(this, m_flNextPrimaryAttack, 0.2); // this+148
			set_pdata_float(this, m_flNextSecondaryAttack, 0.2); // this+152
			set_pdata_float(this, m_flTimeWeaponIdle, 1.03); // this+156
			//break;
			//client_print(id, print_chat, "case 4");
		}
	}
	
	
	// ADDED
	if (pev(id,pev_button) & IN_ATTACK2 && get_pdata_float(this,m_flNextSecondaryAttack) <= 0.0)
	{
		CGunkata_SecondaryAttack(this);
		set_pev(id,pev_button, pev(id,pev_button) & ~IN_ATTACK2);
		return HAM_IGNORED;
	}
	
	return HAM_IGNORED; // result = CBasePlayerWeapon::ItemPostFrame(this);
}

public CGunkata_Precache() // bool sub_1026F9F0(this)
{
	//v1 = this;
	precache_model("models/p_gunkata2.mdl");
	/*
	precache_model("models/ef_gunkata.mdl");
	precache_model("models/ef_gunkata_man.mdl");
	precache_model("models/ef_gunkata_woman.mdl");
	precache_model("models/ef_scorpion_hole.mdl");
	precache_sound("weapons/gunkata-1.wav");
	precache_sound("weapons/gunkata_idle.wav");
	precache_sound("weapons/gunkata_skill_01.wav");
	precache_sound("weapons/gunkata_skill_02.wav");
	precache_sound("weapons/gunkata_skill_03.wav");
	precache_sound("weapons/gunkata_skill_04.wav");
	precache_sound("weapons/gunkata_skill_05.wav");
	precache_sound("weapons/gunkata_skill_last_exp.wav");
	*/
	//m_iShell = precache_model("models/pshell.mdl");
	//*((_WORD *)v1 + 142) = precache_event(1, "events/gunkata.sc");
	//result = precache_event(1, "events/gunkata_effect.sc");
	//*((_WORD *)v1 + 143) = result;
	//return result;
	
	precache_sound("weapons/turbulent9_hit1.wav");
	precache_sound("weapons/turbulent9_hit2.wav");
}

public CGunkata_PrimaryAttack(id, this, iClip, iBteWpn)
{
	//new id = get_pdata_cbase(this, m_pPlayer); // (this+112)
	
	new Float:vecVelocity[3]
	pev(id, pev_velocity, vecVelocity)
	vecVelocity[2] = 0.0
	
	new Float:flAccuracy = get_pdata_float(this, m_flAccuracy); // this+228
	
	new Float:flSpread;
	
	// 命中 射速 设定
	
	if (vector_length(vecVelocity) > 0) // 跑
		flSpread = (1.0 - flAccuracy) * 0.12;
	else if (!(pev(id, pev_flags) & FL_ONGROUND)) // 空 0x200
		flSpread = (1.0 - flAccuracy) * 0.15;
	else if (pev(id, pev_flags) & FL_DUCKING) // 蹲
		flSpread = (1.0 - flAccuracy) * 0.1;
	else // 地
		flSpread = (1.0 - flAccuracy) * 0.11;
	
	CGunkata_GunkataFire(this, flSpread, c_flAttackInterval[iBteWpn][0], false);
}

public CGunkata_GunkataFire(this, flSpread, Float:flCycleTime, bool:fUseAutoAim)
{
	new id = get_pdata_cbase(this, m_pPlayer)
	new iBteWpn = WeaponIndex(this);
	
	new iClip = get_pdata_int(this, m_iClip);
	if (iClip <= 0)
	{
		// CGunkata_GetLRMode((_DWORD *)a1);
		if (get_pdata_int(this, m_fFireOnEmpty)) // this+136
		{
			ExecuteHamB(Ham_Weapon_PlayEmptySound, this);
			flCycleTime = 0.2;
		}
		set_pdata_float(this, m_flNextPrimaryAttack, flCycleTime); // this+148
		set_pdata_float(this, m_flNextSecondaryAttack, 0.2); // this+152
		set_pdata_float(this, m_flTimeWeaponIdle, 0.2); // this+156
		return;
	}
	
	//new v7 = id;
	new iShootAnim; // v8
	if(!CGunkata_GetLRMode(this))
	{
		iShootAnim = 4;
		SetAnimation(id, PLAYER_ATTACK1); // (*(void (__stdcall **)(signed int, int, int))(v7 + 448))(5, v26, v27);
		set_pdata_float(this, m_flTimeWeaponIdle, 0.7); // this+156
	}
	else
	{
		
		iShootAnim = 2;
		SetAnimation(id, PLAYER_ATTACK2); // (*(void (__stdcall **)(signed int, int, int))(v7 + 448))(5, v26, v27);
		set_pdata_float(this, m_flTimeWeaponIdle, 0.53); // this+156
	}
	
	new iShotsFired = get_pdata_int(this, m_iShotsFired)
	iShotsFired++
	set_pdata_int(this, m_iShotsFired,  iShotsFired);
	
	new Float:flLastFire = get_pdata_float(this, m_flLastFire); // this+232;
	if (flLastFire)
	{
		new Float:flAccuracy = get_pdata_float(this, m_flAccuracy)
		
		// 命中计算公式
		flAccuracy -= (0.3 - (get_gametime() - flLastFire)) * 0.2;
		
		// 命中偏移最大
		if (flAccuracy> 1.1)
			flAccuracy = 1.1;
		else if (flAccuracy< 0.4)
			flAccuracy = 0.4;
		set_pdata_float(this, m_flAccuracy, flAccuracy);
	}
	set_pdata_float(this, m_flLastFire, get_gametime());
	
	iClip--;
	set_pdata_int(this, m_iClip, iClip);
	
	//if ( !(((*(int (__thiscall **)(int))(*(_DWORD *)this + 600))(this) - *(_DWORD *)(this + 172)) % (signed int)ffloor(3.0)) )
	if(!((c_iClip[iBteWpn] - iClip) % 3))
    {
		//flCycleTime =  c_flAttackInterval[iBteWpn][1];
		flCycleTime = 0.31; // this+148
		set_pdata_float(id, m_flNextAttack, flCycleTime);
		set_pdata_float(this, m_flAccuracy, 1.1); //*(_DWORD *)(this + 228) = 1.1;
		++iShootAnim; //++v8;
		set_pdata_float(this, m_flTimeWeaponIdle, 0.53); // this+156  //v9 = sub_105E0FB0() + 0.52999997; *(float *)(this + 156) = v9;
		//client_print(id, print_chat, "!((c_iClip[iBteWpn] - iClip) % 3)");
    }
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
	new Float:flDamage = CGunkata_GetDamage(0);
	
	
	FireBullets3(id, vecSrc, vecForward, flSpread, 8192.0, 8 + 0, BULLET_PLAYER_45ACP, floatround(flDamage), 0.95, id, true, get_pdata_int(id, random_seed), vecDir);
	PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, vecDir[0], vecDir[1], floatround(vecPunchangle[0] * 100.0), floatround(vecPunchangle[1] * 100.0), iShootAnim, FALSE);
	SendWeaponAnim(id, iShootAnim);
	
	// 后坐力
	// *(float *)(*(_DWORD *)(*(_DWORD *)(v5 + 112) + 4) + 104) = *(float *)(*(_DWORD *)(*(_DWORD *)(v5 + 112) + 4) + 104) - *(float *)&dword_107CD53C;
	vecPunchangle[0] -= 0.33;
	set_pev(id, pev_punchangle, vecPunchangle);
	set_pdata_float(this, m_flNextPrimaryAttack, flCycleTime); // this+148
	set_pdata_float(this, m_flNextSecondaryAttack, 0.2); // this+152
}


public CGunkata_Reload(id, this, iClip, iBteWpn)
{
	if (get_pdata_float(this,m_flNextPrimaryAttack) <= 0.0 && get_pdata_float(this,m_flNextSecondaryAttack) <= 0.0)
	{
		/*new iAnim = 7;
		if(CGunkata_GetLRMode(this))
			iAnim = 6;*/
		// maxclip iAnim 1.73 
		if (DefaultReload(this, c_iClip[iBteWpn], c_iReloadAnim[iBteWpn][!CGunkata_GetLRMode(this)], c_flReload[iBteWpn][0]))
		{
			SetAnimation(id, PLAYER_RELOAD); // 9
			set_pdata_float(this, m_flTimeWeaponIdle, 2.03);
			set_pdata_float(this, m_flAccuracy, c_flAccuracyDefault[iBteWpn]); // 1.1
		}
	}
}

stock CGunkata_SecondaryAttack(this) // int __usercall sub_1026EED0@<eax>(int a1@<ecx>, double a2@<st0>)
{
	new iMode = pev(this, pev_iuser1); // this+292
	if(iMode != 1)
	{
		new iClip = get_pdata_int(this, m_iClip);
		if(iClip>0) // this+172
		{
			iMode = 1;
			set_pev(this, pev_iuser1, iMode);
			set_pdata_float(this, m_flNextPrimaryAttack, Float:0x7F7FFFFF); // this+148
			set_pdata_float(this, m_flNextSecondaryAttack, Float:0x7F7FFFFF); // this+152
			set_pdata_float(this, m_flTimeWeaponIdle, Float:0x7F7FFFFF); // this+156
		}
		else
		{
			ExecuteHamB(Ham_Weapon_PlayEmptySound, this); // (*(void (**)(void))(*(_DWORD *)this + 532))();
			// no ammo hints ?!
			/*if ( dword_108AB55C )
				(*(void (__stdcall **)(signed int, _DWORD, _DWORD))(*(_DWORD *)dword_108AB55C + 36))( 2,pPlayer,0);
			*/
			set_pdata_float(this, m_flNextPrimaryAttack, 0.2); // this+148
			set_pdata_float(this, m_flNextSecondaryAttack, 0.2); // this+152
			set_pdata_float(this, m_flTimeWeaponIdle, 0.2); // this+156
		}
	}
	
}

public CGunkata_WeaponIdle(id, this, iId, iBteWpn)
{
	if(get_pdata_float(this, m_flTimeWeaponIdle) > 0.0) 
		return HAM_SUPERCEDE;
		
	ExecuteHamB(Ham_Weapon_ResetEmptySound, this);
	//OrpheuCall(OrpheuGetFunctionFromEntity(id, "GetAutoaimVector", "CBasePlayer"), id, AUTOAIM_10DEGREES)
	
	/*if(CGunkata_GetLRMode(this))
		SendWeaponAnim(id, 0);
	else
		SendWeaponAnim(id, 1);*/
	SendWeaponAnim(id, c_iIdleAnim[iBteWpn][!CGunkata_GetLRMode(this)]);
	
	set_pdata_float(this, m_flTimeWeaponIdle, 6.03);
	
	return HAM_SUPERCEDE;
}

stock CGunkata_RadiusAttack1(this) // int __usercall sub_1026EED0@<eax>(int a1@<ecx>, double a2@<st0>)
{
	// radius = 220.0
	// angle = 110.0
	// hit sound : "weapons/turbulent9_hit1.wav", "weapons/turbulent9_hit2.wav"
	new id = get_pdata_cbase(this, m_pPlayer)
	new iBteWpn = WeaponIndex(this);
	
	new iHitResult = KnifeAttack(id, FALSE, c_flDistance[iBteWpn][1], c_flAngle[iBteWpn][0], CGunkata_GetDamage(1), c_flKnockback[iBteWpn][4]);
	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : 
		{
			if(random_num(0,1))
			{
				emit_sound(id, CHAN_VOICE, "weapons/turbulent9_hit1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			else
			{
				emit_sound(id, CHAN_VOICE, "weapons/turbulent9_hit2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
		}
	}
}

stock CGunkata_RadiusAttack2(this) // char __thiscall sub_1026F2C0(_DWORD *this)
{
	// radius = 220.0
	// KnockBack = 5000.0, 200.0
	
	new id = get_pdata_cbase(this, m_pPlayer)
	new iBteWpn = WeaponIndex(this);
	
	if(!is_user_alive(id) || bte_get_user_zombie(id) == 1)
	{
		SUB_Remove(this, 0.0);
		return;
	}
	if (c_iSpecial[iBteWpn] != SPECIAL_GUNKATA)
	{
		SUB_Remove(this, 0.0);
		return;
	}
	
	//new Float:flRange = 200.0;
	new Float:flDamage = CGunkata_GetDamage(2);
	// 1230.0
	
	new ptr = create_tr2()
	new Float:vecSrc[3], Float: vecEnd[3]
	GetGunPosition(id, vecSrc)
	
	new Float:flRange = c_flDistance[iBteWpn][2]
	
	static Float:vecForward[3]
	global_get(glb_v_forward, vecForward)
	xs_vec_mul_scalar(vecForward, flRange, vecForward)
	xs_vec_add(vecSrc, vecForward, vecEnd)

	engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, id, ptr)

	new Float:flFraction
	get_tr2(ptr, TR_flFraction, flFraction)
	
	if (flFraction >= 1.0)
	{
		engfunc(EngFunc_TraceHull, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, HULL_HEAD, id, ptr)
		
		if (flFraction < 1.0)
		{
			new pHit = get_tr2(ptr, TR_pHit)
			if(!pHit || ExecuteHamB(Ham_IsBSPModel, pHit))
			{
				FindHullIntersection(vecSrc, ptr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, id)
				get_tr2(ptr, TR_vecEndPos, vecEnd)
			}
		}
	}
	
	get_tr2(ptr, TR_flFraction, flFraction)
	if (flFraction >= 1.0)
	{
		
	}
	else
	{
		new pEntity = get_tr2(ptr, TR_pHit)
		if(pEntity < 0) pEntity = 0
		
		if(pEntity && ExecuteHamB(Ham_IsBSPModel, pEntity))
		{
			ClearMultiDamage()
			ExecuteHamB(Ham_TraceAttack, pEntity, id, flDamage, vecForward, ptr, DMG_NEVERGIB | DMG_BULLET)
			ApplyMultiDamage(id, id);
		}
	
		if(pEntity)
		{
			if(ExecuteHamB(Ham_Classify, pEntity) == CLASS_NONE || ExecuteHamB(Ham_Classify, pEntity) == CLASS_MACHINE)
			{
				new Float:vecTemp[3]
				xs_vec_sub(vecEnd, vecSrc, vecTemp)
				xs_vec_mul_scalar(vecTemp, 2.0, vecTemp)
				xs_vec_add(vecTemp, vecSrc, vecTemp)
				
				TEXTURETYPE_PlaySound(ptr, vecSrc, vecTemp, BULLET_PLAYER_CROWBAR);
				
			}
		}
	}
	free_tr2(ptr)
	
	// 对玩家执行范围伤害
	new Float:vecEndZ = vecEnd[2]
	new pEntity
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecSrc, flRange)) != 0)
	{
		if(pEntity == id)
			continue;
		if(ExecuteHamB(Ham_IsBSPModel, pEntity))
			continue;
			
		pev(pEntity, pev_origin, vecEnd)
		
		vecEnd[2] = vecSrc[2] + (vecEndZ - vecSrc[2]) * (get_distance_f(vecSrc, vecEnd) / flRange)
			
		engfunc(EngFunc_TraceLine, vecSrc, vecEnd, 0, id, ptr)
		get_tr2(ptr, TR_flFraction, flFraction)
		if (flFraction >= 1.0) 
		{
			engfunc(EngFunc_TraceHull, vecSrc, vecEnd, 0, HULL_HEAD, id, ptr)
			get_tr2(ptr, TR_flFraction, flFraction)
		}
		
		new pHit = get_tr2(ptr, TR_pHit)
		if(!pev_valid(pHit))
			continue;
		
		ClearMultiDamage()
		ExecuteHamB(Ham_TraceAttack, pEntity, id, flDamage, vecForward, ptr, DMG_NEVERGIB | DMG_BULLET)
		ApplyMultiDamage(id, id)
		
		free_tr2(ptr)
		
		if(is_user_alive(pEntity) && bte_get_user_zombie(pEntity) == 1)
		{
			new Float:vecVelocity[3]
			pev(pEntity, pev_velocity, vecVelocity);
			
			new Float:vecDirection[3];
			xs_vec_sub(vecEnd, vecSrc, vecDirection);
			xs_vec_normalize(vecDirection, vecDirection);
			
			xs_vec_mul_scalar(vecDirection, c_flKnockback[iBteWpn][5], vecDirection);
			vecDirection[2] = 200.0;
			
			xs_vec_add(vecVelocity, vecDirection, vecVelocity);
			set_pev(pEntity, pev_velocity, vecVelocity);
		}
	}
}

stock CGunkata_GetLRMode(this) // bool sub_1026F9F0(this)
{
	//new id = get_pdata_cbase(this, m_pPlayer)
	new iBteWpn = WeaponIndex(this);
	new iClip = get_pdata_int(this, m_iClip);
	return !(((c_iClip[iBteWpn] - iClip) / 3) % 2);
}

stock CGunkata_sub_101710E0(iAnim1, &a2, &iAnim2)
{
	iAnim1 = iAnim2;
	iAnim2 -= 4;
	a2 = iAnim2;
}