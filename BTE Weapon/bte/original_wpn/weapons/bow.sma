public CBow_ItemPostFrame(id, iEnt, iClip, iBteWpn)
{
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) > 0.0)
		return;
	if (!iClip)
		return;

	static iButton;
	iButton = pev(id,pev_button);
	static Float:fCurTime;
	global_get(glb_time, fCurTime);

	static iCharging, Float:fFinshTime;
	iCharging = pev(iEnt, pev_iuser1);
	pev(iEnt, pev_fuser1, fFinshTime);

	if(iButton & IN_ATTACK && !(iButton & IN_ATTACK2))
	{
		CBow_PrimaryAttack(id, iEnt, iClip, iBteWpn)
		iButton &= ~IN_ATTACK;
		set_pev(id, pev_button, iButton);
		return;
	}
	else if(iButton & IN_ATTACK2)
	{
		if(!iCharging)
		{
			iCharging = 1;
			fFinshTime = fCurTime + 1.2;
			Stock_Send_Anim(id, 6);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flAttackInterval[iBteWpn][0]+0.15);
			set_pdata_float(iEnt,m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]+0.15);
			set_pev(iEnt, pev_iuser1, iCharging);
			set_pev(iEnt, pev_fuser1, fFinshTime);
			

			Pub_Set_MaxSpeed2(id, c_flMaxSpeed[iBteWpn][1]);
		}
		else if(fCurTime > fFinshTime && iCharging != 2)
		{
			iCharging = 2;
			Stock_Send_Anim(id, 7);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.43);
			set_pdata_float(iEnt,m_flNextPrimaryAttack, 0.2);
			set_pev(iEnt, pev_iuser1, iCharging);
		}
		iButton &= ~IN_ATTACK2;
		set_pev(id, pev_button, iButton);
	}
	else if(!(iButton & IN_RELOAD))
	{
		switch (iCharging)
		{			
			case 1:
			{
				Pub_Set_MaxSpeed2(id, c_flMaxSpeed[iBteWpn][0]);

				iClip--;
				set_pdata_int(iEnt, m_iClip, iClip);

				SendWeaponAnim(id, iClip ? 10 : 11);

				set_pdata_float(iEnt, m_flTimeWeaponIdle, iClip ? c_flAttackInterval[iBteWpn][2] : c_flAttackInterval[iBteWpn][1]);
				set_pdata_float(iEnt, m_flNextPrimaryAttack, iClip?1.36:0.7);
				
				engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, iClip?"weapons/bow_charge-2.wav":"weapons/bow_charge-1_empty.wav", 1.0, ATTN_NORM, 0, 94 + random_num(0, 15));
				
				OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

				new Float:fVelocity[3], Float:fOrigin[3], Float:fEnd[3], Float:fAngle[3];
				new iArrow = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));

				GetGunPosition(id, fOrigin);
				Stock_Get_Aiming(id, fEnd);
				Stock_GetSpeedVector(fOrigin, fEnd, 4000.0, fVelocity);
				set_pev(iArrow, pev_classname, "d_bow");
				engfunc(EngFunc_SetModel, iArrow, "models/arrow.mdl");
				set_pev(iArrow, pev_origin, fOrigin);
				set_pev(iArrow, pev_mins, {-0.1, -0.1, -0.1});
				set_pev(iArrow, pev_maxs, {0.1, 0.1, 0.1});
				set_pev(iArrow, pev_movetype, MOVETYPE_FLY);

				set_pev(iArrow, pev_solid, SOLID_BBOX);
				set_pev(iArrow, pev_owner, id);
				set_pev(iArrow, pev_gravity, 0.000001);
				set_pev(iArrow, pev_velocity,fVelocity);
				Stock_Get_Velocity_Angle(iArrow, fAngle);
				set_pev(iArrow, pev_angles, fAngle);
				Set_Ent_Data(iArrow,DEF_ENTID,iBteWpn);
				set_pev(iArrow, pev_iuser4, 9999);
				set_pev(iArrow, pev_vuser1, fVelocity);

				Set_Ent_Data(iArrow,DEF_ENTCLASS,ENTCLASS_BOW);
				set_pev(iArrow,pev_nextthink,get_gametime()+0.15);

				set_pev(iArrow, pev_iuser3, 0);
				set_pev(iArrow, pev_fuser2, g_modruning == BTE_MOD_ZB1?c_flDamageZB[iBteWpn][0]:c_flDamage[iBteWpn][0]);

				new Float:vPunchangle[3];
				pev(id, pev_punchangle, vPunchangle);
				vPunchangle[0] -= 3.0;
				set_pev(id, pev_punchangle, vPunchangle);

			}
			case 2:
			{
				Pub_Set_MaxSpeed2(id, c_flMaxSpeed[iBteWpn][0]);
				new Float:vecSrc[3], Float:vecDir[3];
				GetGunPosition(id, vecSrc);
				global_get(glb_v_forward, vecDir);
				FireBullets3_Lite(vecSrc, vecDir, 8192.0, c_iPenetration[iBteWpn][0], IS_ZBMODE ? c_flDamageZB[iBteWpn][1] : c_flDamage[iBteWpn][1], id, c_flKnockback[iBteWpn][1]);
				engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, 0.0, 0.0, iClip, 0, FALSE, FALSE);
				iClip--;
				set_pdata_int(iEnt, m_iClip, iClip);
				SendWeaponAnim(id, iClip?12:13);
				set_pdata_float(iEnt, m_flTimeWeaponIdle, iClip?c_flAttackInterval[iBteWpn][2]:c_flAttackInterval[iBteWpn][1]);
				set_pdata_float(iEnt, m_flNextPrimaryAttack, iClip?c_flAttackInterval[iBteWpn][2]:c_flAttackInterval[iBteWpn][1]);
				OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
				new Float:vPunchangle[3];
				pev(id, pev_punchangle, vPunchangle);
				vPunchangle[0] -= 5.0;
				set_pev(id, pev_punchangle, vPunchangle);
			}
		}
		iCharging = 0;
		set_pev(iEnt, pev_iuser1, iCharging);
	}
	iButton &= ~IN_ATTACK;
	iButton &= ~IN_ATTACK2;
	set_pev(id, pev_button, iButton);
}

public CBow_PrimaryAttack(id, iEnt, iClip, iBteWpn)
{
	new Float:vPunchangle[3];
	pev(id, pev_punchangle, vPunchangle);
	vPunchangle[0] -= 2.0;
	set_pev(id, pev_punchangle, vPunchangle);

	iClip--;
	set_pdata_int(iEnt, m_iClip, iClip);

	SendWeaponAnim(id, iClip?2:3);

	set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flAttackInterval[iBteWpn][0]+0.5);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][0]);
	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
	
	SendWeaponShootSound(id, false, true);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

	new Float:fVelocity[3], Float:fOrigin[3], Float:fAngle[3];
	velocity_by_aim(id, 3200, fVelocity);
	new iArrow = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	GetGunPosition(id, fOrigin);
	set_pev(iArrow, pev_classname, "d_bow");
	engfunc(EngFunc_SetModel, iArrow, "models/arrow.mdl");
	set_pev(iArrow, pev_origin, fOrigin);
	set_pev(iArrow, pev_mins, {-0.1, -0.1, -0.1});
	set_pev(iArrow, pev_maxs, {0.1, 0.1, 0.1});
	set_pev(iArrow, pev_movetype, MOVETYPE_FLY);
	set_pev(iArrow, pev_solid, SOLID_BBOX);
	set_pev(iArrow, pev_owner, id);
	set_pev(iArrow, pev_gravity,0.15);
	set_pev(iArrow, pev_velocity,fVelocity);
	Stock_Get_Velocity_Angle(iArrow, fAngle);
	set_pev(iArrow, pev_angles, fAngle);
	Set_Ent_Data(iArrow,DEF_ENTID,iBteWpn);
	set_pev(iArrow, pev_iuser4, 9999);
	set_pev(iArrow, pev_vuser1, fVelocity);

	Set_Ent_Data(iArrow,DEF_ENTCLASS,ENTCLASS_BOW);
	set_pev(iArrow,pev_nextthink,get_gametime()+0.15);


	set_pev(iArrow, pev_iuser3, 0);
	set_pev(iArrow, pev_fuser2, IS_ZBMODE ? c_flDamageZB[iBteWpn][0] : c_flDamage[iBteWpn][0]);

	

	set_pev(iEnt, pev_iuser1, 0);
	set_pev(iEnt, pev_fuser1, 0.0);
}
