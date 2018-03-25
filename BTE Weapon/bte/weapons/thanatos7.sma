public CThanatos7_Precache()
{
	precache_model("models/thanatos7_scythe.mdl");
	precache_sound("weapons/thanatos7_scytheshoot.wav");
}

public CThanatos7_ItemPostFrame(id, iEnt, iClip, iBteWpn)
{
	if(get_pdata_float(iEnt, m_flNextSecondaryAttack) <= 0.0)
	{
		if(pev(iEnt, pev_iuser1))
		{
			set_pev(iEnt, pev_iuser1, 0);
			set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_M4A1_SILENCED);
			SetExtraAmmo(id, iEnt, 1);
		}
		else if(pev(id, pev_button) & IN_ATTACK2)
		{
			set_pev(id, pev_button, pev(id, pev_button) & ~IN_ATTACK2)
			CThanatos7_SecondaryAttack(id, iEnt, iClip, iBteWpn)
		}
	}
}

public CThanatos7_Deploy(id, iEnt, iId, iBteWpn)
{
	SendExtraAmmo(id, iEnt);
	set_pev(iEnt, pev_iuser1, 0);
}

public CThanatos7_SecondaryAttack(id, iEnt, iClip, iBteWpn)
{
	if(!get_pdata_int(iEnt, m_iWeaponState))
	{
		set_pev(iEnt, pev_iuser1, 1);
		SendWeaponAnim(id, 10);
		UTIL_WeaponDelay(iEnt, 3.6, 3.6, 3.8);
	}
	else
	{
		SetExtraAmmo(id, iEnt, 0);
		set_pdata_int(iEnt, m_iWeaponState, 0);
		emit_sound(id, CHAN_WEAPON, "weapons/thanatos7_scytheshoot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		SendWeaponAnim(id, 9);
		UTIL_WeaponDelay(iEnt, 3.8, 3.8, 4.0);
		
		new pEntity = CThanatos7Scythe_Create(id)
		if(pev_valid(pEntity))
		{
			set_pev(pEntity, pev_owner, id)
			new Float:vecAngles[3], Float:vecPunchangle[3];
			new Float:vecSrc[3], Float:vecForward[3], Float:vecUp[3];
			pev(id, pev_v_angle, vecAngles);
			pev(id, pev_punchangle, vecPunchangle);
			xs_vec_add(vecAngles, vecPunchangle, vecAngles);
			engfunc(EngFunc_MakeVectors, vecAngles);
			GetGunPosition(id, vecSrc);
			global_get(glb_v_forward, vecForward);
			global_get(glb_v_up, vecUp);
			xs_vec_mul_scalar(vecUp, 2.0, vecUp);
			xs_vec_sub(vecSrc, vecUp, vecSrc);
			set_pev(pEntity, pev_origin, vecSrc);
			xs_vec_mul_scalar(vecForward, 1000.0, vecForward);
			engfunc(EngFunc_VecToAngles, vecForward, vecAngles);
			
			set_pev(pEntity, pev_angles, vecAngles);
			set_pev(pEntity, pev_velocity, vecForward);
			
			set_pev(pEntity, pev_euser1, iEnt);
		}
	}
}

public CThanatos7Scythe_Create(id)
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(iEntity)) return -1
	
	set_pev(iEntity, pev_movetype, MOVETYPE_FLY)
	set_pev(iEntity, pev_solid, SOLID_TRIGGER)
	set_pev(iEntity, pev_classname, "d_thanatos7")
	
	
	engfunc(EngFunc_SetModel, iEntity, "models/thanatos7_scythe.mdl")
	
	set_pev(iEntity, pev_sequence, 0)
	set_pev(iEntity, pev_framerate, 1.0)
	
	set_pev(iEntity, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(iEntity, pev_maxs, Float:{1.0, 1.0, 1.0})
	
	set_pev(iEntity, pev_iuser1, 0)
	
	BTE_SetThink(iEntity, "CThanatos7Scythe_ScytheThink");
	BTE_SetTouch(iEntity, "CThanatos7Scythe_ScytheTouch");
	
	set_pev(iEntity, pev_nextthink, get_gametime() + 0.4);
	return iEntity
}

public CThanatos7Scythe_ScytheThink(this)
{
	new iEnt=pev(this, pev_euser1);
	new id = pev(this, pev_owner);
	if(!pev_valid(iEnt) || id != get_pdata_cbase(iEnt, m_pPlayer))
	{
		engfunc(EngFunc_RemoveEntity, this);
		return;
	}
	
	if(pev(this, pev_solid) == SOLID_NOT)
	{
		new iShotsFired = pev(this, pev_iuser1)
		if(iShotsFired >= 20)
		{
			engfunc(EngFunc_RemoveEntity, this);
			return;
		}
		iShotsFired++;
		set_pev(this, pev_iuser1, iShotsFired)
		
	}
	
	new Float:vecOrigin[3]
	pev(this, pev_origin, vecOrigin)
	RadiusDamage(vecOrigin, this, id, IS_ZBMODE ? 520.0:65.0, 72.0, 0.0, DMG_BULLET, TRUE, TRUE, TRUE)
	
	set_pev(this, pev_nextthink, get_gametime() + 0.4);
}

public CThanatos7Scythe_ScytheTouch(this, pOther)
{
	new iEnt=pev(this, pev_euser1);
	new id = pev(this, pev_owner);
	if(!pev_valid(iEnt) || id != get_pdata_cbase(iEnt, m_pPlayer))
	{
		engfunc(EngFunc_RemoveEntity, this);
		return;
	}
	
	if(pOther == id)
		return;
	
	set_pev(this, pev_solid, SOLID_NOT)
	set_pev(this, pev_movetype, MOVETYPE_NONE)
	set_pev(this, pev_velocity, Float:{ 0.0, 0.0, 0.0})
	set_pev(this, pev_nextthink, get_gametime() + 0.4)
	
	if(is_user_alive(pOther))
		set_pdata_int(pOther, 75, HIT_CHEST)
	ExecuteHamB(Ham_TakeDamage, pOther, this, id, IS_ZBMODE ? 850.0:75.0, DMG_BULLET | DMG_SLASH)
	
}