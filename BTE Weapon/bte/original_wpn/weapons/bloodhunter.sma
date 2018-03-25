// Made by Sh@de(Xiaobaibai)
// pev_iuser1 => iCharged[0,3]
// pev_iuser2 => iChargedFired[0,4]

new m_iBloodGrenadeExp

public CBloodhunter_Precache()
{
	m_iBloodGrenadeExp = precache_model("sprites/ef_bloodhunter3.spr")
	precache_model("models/w_bloodhunter_left.mdl")
}

public CBloodhunter_ItemPostFrame(id, iEnt, iClip, iBteWpn)
{
	if(pev(iEnt, pev_iuser3) && get_pdata_float(iEnt,m_flNextSecondaryAttack) <= 0.0)
	{
		CBloodhunter_ChargeAttack(iEnt);
	}
	else if (pev(id,pev_button) & IN_ATTACK2 && get_pdata_float(iEnt,m_flNextSecondaryAttack) <= 0.0)
	{
		CBloodhunter_SecondaryAttack(id, iEnt, iClip, iBteWpn)
		set_pev(id,pev_button, pev(id,pev_button) & ~IN_ATTACK2);
	}
	set_pev(id,pev_button, pev(id,pev_button) & ~IN_ATTACK2);
}

public CBloodhunter_Deploy_Post(id, iEnt, iId, iBteWpn)
{
	new iType = pev(iEnt, pev_iuser1);
	MH_SpecialEvent(id, 50 + iType);
	set_pev(iEnt, pev_iuser3, 0);
}

public CBloodhunter_PrimaryAttack_Post(id, iEnt, iClip, iBteWpn)
{
	new iType = pev(iEnt, pev_iuser1);
	new iChargedFired = pev(iEnt, pev_iuser2)
	if(iChargedFired>=4 && iType < 3)
	{
		iType++;
		iChargedFired = 0;
		set_pev(iEnt, pev_iuser1, iType);
		set_pev(iEnt, pev_iuser2, iChargedFired);
		MH_SpecialEvent(id, 50 + iType);
	}
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.0);
}

public CBloodhunter_SecondaryAttack(id, iEnt, iClip, iBteWpn)
{
	new iType = pev(iEnt, pev_iuser1);
	
	if(!iType)
		return;
	
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.0);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.3);
	set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.3);
	SendWeaponAnim(id, 7+iType);
	
	set_pev(iEnt, pev_iuser3, 1)
}

public CBloodhunter_ChargeAttack(iEnt)
{
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	new iType = pev(iEnt, pev_iuser1);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.0);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, 1.03);
	set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.03);
	SendWeaponAnim(id, 15);
	
	iType=0;
	set_pev(iEnt, pev_iuser1, iType);
	set_pev(iEnt, pev_iuser2, 0);
	MH_SpecialEvent(id, 50 + iType);
	set_pev(iEnt, pev_iuser3, iType);
	
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
	xs_vec_mul_scalar(vecForward, 1000.0, vecForward);
	xs_vec_mul_scalar(vecUp, 50.0, vecUp);
	new Float:vecVelocity[3]
	xs_vec_add(vecForward, vecUp, vecVelocity);
	
	new pEntity = CBloodGrenade_Create(id, vecSrc, vecVelocity, 0)
	if(pev_valid(pEntity))
	{
		set_pev(pEntity, pev_euser1, iEnt);
	}
}

public CBloodGrenade_Create(id, Float:vecOrigin[3], Float:vecVelocity[3], iType)
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(iEntity)) return -1
	
	set_pev(iEntity, pev_owner, id)
	set_pev(iEntity, pev_movetype, MOVETYPE_PUSHSTEP)
	set_pev(iEntity, pev_solid, SOLID_BBOX)
	set_pev(iEntity, pev_classname, "d_bloodhunter")
	
	engfunc(EngFunc_SetModel, iEntity, "models/w_bloodhunter_left.mdl")
	
	set_pev(iEntity, pev_sequence, 0)
	set_pev(iEntity, pev_framerate, 1.0)
	
	set_pev(iEntity, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(iEntity, pev_maxs, Float:{1.0, 1.0, 1.0})
	
	set_pev(iEntity, pev_iuser1, iType);
	
	set_pev(iEntity, pev_origin, vecOrigin);
	set_pev(iEntity, pev_velocity, vecVelocity);
	
	BTE_SetThink(iEntity, "CBloodGrenade_Detonate");
	BTE_SetTouch(iEntity, "CBloodGrenade_BounceTouch");
	
	set_pev(iEntity, pev_nextthink, get_gametime() + 1.0);
	return iEntity
}

public Float:CBloodGrenade_GetRadius(this)
{
	new iType = pev(this, pev_iuser1);
	if(IS_ZBMODE)
	{
		if(iType == 0)
			return 350.0
		else if(iType == 1)
			return 370.0
		else
			return 400.0
	}
	else
	{
		if(iType == 0)
			return 100.0
		else if(iType == 1)
			return 110.0
		else
			return 120.0
	}
	return 0.0
}

public Float:CBloodGrenade_GetKnockbackRatio(this)
{
	new iType = pev(this, pev_iuser1);
	if(IS_ZBMODE)
	{
		if(iType == 0)
			return 1.0
		else if(iType == 1)
			return 1.1
		else
			return 1.3
	}
	else
	{
		if(iType == 0)
			return 0.3
		else if(iType == 1)
			return 0.4
		else
			return 0.5
	}
	return 0.0
}

public CBloodGrenade_BounceTouch(this, pOther)
{
	if(bte_get_user_zombie(pOther))
	{
		BTE_SetTouch(this, "");
		BTE_SetThink(this, "CBloodGrenade_Detonate");
		set_pev(this, pev_nextthink, get_gametime() + 0.1)
	}
	else
	{
		
	}
}
// CBloodGrenade_DetonateBloodGrenade
public CBloodGrenade_Detonate(this)
{
	new Float:vecOrigin[3]; pev(this, pev_origin, vecOrigin)
	new iType = pev(this, pev_iuser1);
	new id = pev(this, pev_owner);
	new iEnt = pev(this, pev_euser1);
	new iBteWpn = WeaponIndex(iEnt);
	new Float:vecSrc[3]; GetGunPosition(id, vecSrc);
	
	new Float:flRadius = CBloodGrenade_GetRadius(this)
	new Float:flKnockbackRatio = CBloodGrenade_GetKnockbackRatio(this)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, vecOrigin[0])
	engfunc(EngFunc_WriteCoord, vecOrigin[1])
	engfunc(EngFunc_WriteCoord, vecOrigin[2] + 20.0)
	write_short(m_iBloodGrenadeExp)
	write_byte(floatround(flRadius / 3.0))
	write_byte(30)
	write_byte(0)
	message_end()
	
	//emit_sound(this, CHAN_ITEM, "weapons/zoom.wav", 0.20, 2.40, 0, 100)
	
	MH_SpecialEvent(id, 50 + 3);
	
	new pEntity = -1, Float:flAdjustedDamage
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, flRadius)) && pev_valid(pEntity))
	{
		if (pev(pEntity, pev_takedamage) == DAMAGE_NO)
			continue;
		
		
		static Float:vecEnd[3], Float:vecDelta[3]; 
		pev(pEntity, pev_origin, vecEnd);
		xs_vec_sub(vecEnd, vecOrigin, vecDelta);
		flAdjustedDamage = IS_ZBMODE ? c_flDamage[iBteWpn][iType] : c_flDamageZB[iBteWpn][iType];
		flAdjustedDamage *= 1.0 - (vector_length(vecDelta) / flRadius);
		
		if(pEntity == id)
			flAdjustedDamage *= 0.05
		
		if (flAdjustedDamage < 0.0)
			flAdjustedDamage = 0.0
		if(is_user_alive(pEntity))
		{
			set_pdata_int(pEntity, 75, HIT_CHEST)
		}
		ExecuteHamB(Ham_TakeDamage, pEntity, id, id, flAdjustedDamage, DMG_SLASH)
		
		if(is_user_alive(pEntity) && bte_get_user_zombie(pEntity))
		{
			// Data From CSO mp.dll
			new Float:vecVelocity[3]
			pev(pEntity, pev_velocity, vecVelocity)
			
			new Float:vecDirection[3]
			xs_vec_sub(vecEnd, vecSrc, vecDirection)
			vecDirection[2] = 0.0
			xs_vec_normalize(vecDirection, vecDirection)
			xs_vec_mul_scalar(vecDirection, 1000.0 * flKnockbackRatio, vecDirection)
			
			xs_vec_add(vecVelocity, vecDirection, vecVelocity)
			vecVelocity[2] = 200.0 * flKnockbackRatio
			set_pev(pEntity, pev_velocity, vecVelocity)
			
			set_pdata_float(pEntity, m_flVelocityModifier, 1.0);
		}
	}
	switch(random_num(0,2))
	{
		case 0: emit_sound(this, CHAN_ITEM, "weapons/debris1.wav", 0.8, 2.55, 0, 100)
		case 1: emit_sound(this, CHAN_ITEM, "weapons/debris2.wav", 0.8, 2.55, 0, 100)
		case 2: emit_sound(this, CHAN_ITEM, "weapons/debris3.wav", 0.8, 2.55, 0, 100)
	}
	
	set_pev(iEnt, pev_iuser1, 0);
	set_pev(iEnt, pev_iuser2, 0);
	MH_SpecialEvent(id, 50 + 0);
	set_pev(iEnt, pev_iuser3, 0);
	
	SUB_Remove(this, 0.0);
}