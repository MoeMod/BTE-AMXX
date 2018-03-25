public CAugEX_Precache()
{
	precache_model("models/s_grenade.mdl");
	precache_sound("weapons/augex_shoot3.wav");
}

public CAugEX_ItemPostFrame(id, iEnt, iClip, iBteWpn)
{
	if(get_pdata_float(iEnt, m_flNextSecondaryAttack) <= 0.0)
	{
		if(pev(id, pev_button) & IN_ATTACK2)
		{
			set_pev(id, pev_button, pev(id, pev_button) & ~IN_ATTACK2)
			CAugEX_SecondaryAttack(id, iEnt, iClip, iBteWpn)
		}
	}
}

public CAugEX_Deploy(id, iEnt, iId, iBteWpn)
{
	SendExtraAmmo(id, iEnt);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.0);
}

public CAugEX_SecondaryAttack(id, iEnt, iClip, iBteWpn)
{
	new iExtraAmmo = GetExtraAmmo(iEnt);
	if(!iExtraAmmo)
	{
		ExecuteHamB(Ham_Weapon_PlayEmptySound, iEnt);
		set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.2);
		return;
	}
		
	iExtraAmmo--
	SetExtraAmmo(id, iEnt, iExtraAmmo);
	
	emit_sound(id, CHAN_WEAPON, "weapons/augex_shoot3.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	SendWeaponAnim(id, iExtraAmmo ? 5:6);
	UTIL_WeaponDelay(iEnt, 3.5, 3.5, 3.6);
	
	new Float:vecAngles[3], Float:vecPunchangle[3];
	new Float:vecSrc[3], Float:vecForward[3], Float:vecUp[3];
	pev(id, pev_v_angle, vecAngles);
	pev(id, pev_punchangle, vecPunchangle);
	xs_vec_add(vecAngles, vecPunchangle, vecAngles);
	vecAngles[0] -= 30.0;
	engfunc(EngFunc_MakeVectors, vecAngles);
	GetGunPosition(id, vecSrc);
	global_get(glb_v_forward, vecForward);
	global_get(glb_v_up, vecUp);
	xs_vec_mul_scalar(vecUp, 2.0, vecUp);
	xs_vec_sub(vecSrc, vecUp, vecSrc);
	new Float:vecVelocity[3]
	xs_vec_mul_scalar(vecForward, 300.0, vecVelocity);
	//xs_vec_mul_scalar(vecUp, 30.0, vecUp);
	//xs_vec_add(vecForward, vecUp, vecVelocity);
	
	new pEntity = CAUGEXGrenade_Create(id, vecSrc, vecVelocity, 0)
	if(pev_valid(pEntity))
	{
		set_pev(pEntity, pev_euser1, iEnt);
	}
	
}

public CAUGEXGrenade_Create(id, Float:vecOrigin[3], Float:vecVelocity[3], iType)
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(iEntity)) return -1
	
	set_pev(iEntity, pev_owner, id)
	set_pev(iEntity, pev_movetype, MOVETYPE_PUSHSTEP)
	set_pev(iEntity, pev_solid, SOLID_TRIGGER)
	set_pev(iEntity, pev_classname, "d_augex")
	
	engfunc(EngFunc_SetModel, iEntity, "models/s_grenade.mdl")
	
	set_pev(iEntity, pev_sequence, 0)
	set_pev(iEntity, pev_framerate, 1.0)
	
	set_pev(iEntity, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(iEntity, pev_maxs, Float:{1.0, 1.0, 1.0})
	
	set_pev(iEntity, pev_iuser1, iType);
	
	set_pev(iEntity, pev_origin, vecOrigin);
	set_pev(iEntity, pev_velocity, vecVelocity);
	set_pev(iEntity, pev_gravity, 0.4);
	
	BTE_SetThink(iEntity, "CAUGEXGrenade_IgniteThink");
	BTE_SetTouch(iEntity, "");
	
	set_pev(iEntity, pev_nextthink, get_gametime() + 0.1);
	return iEntity
}

public CAUGEXGrenade_IgniteThink(this)
{
	new iEnt=pev(this, pev_euser1);
	new id = pev(this, pev_owner);
	if(!pev_valid(iEnt) || id != get_pdata_cbase(iEnt, m_pPlayer))
	{
		engfunc(EngFunc_RemoveEntity, this);
		return;
	}
	
	new iType = pev(this, pev_iuser1)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(this) // entity
	write_short(g_sModelIndexSmokeBeam) // sprite
	write_byte(5)  // life
	write_byte(1)  // width
	write_byte(224) // r
	write_byte(224);  // g
	write_byte(255);  // b
	write_byte(255); // brightnes
	message_end();
	
	set_pev(this, pev_solid, SOLID_BBOX);
	BTE_SetThink(this, "CAUGEXGrenade_FollowThink");
	BTE_SetTouch(this, "CAUGEXGrenade_Touch");
	set_pev(this, pev_nextthink, get_gametime() + (iType ? 5.0 : 0.4));
}

public CAUGEXGrenade_FollowThink(this)
{
	new iEnt=pev(this, pev_euser1);
	new id = pev(this, pev_owner);
	if(!pev_valid(iEnt) || id != get_pdata_cbase(iEnt, m_pPlayer))
	{
		engfunc(EngFunc_RemoveEntity, this);
		return;
	}
	
	CAUGEXGrenade_Explode(this, !pev(this, pev_iuser1))
}

public CAUGEXGrenade_Touch(this, pOther)
{
	CAUGEXGrenade_Explode(this, FALSE)
}

public CAUGEXGrenade_Explode(this, bShouldDivide)
{
	new iEnt=pev(this, pev_euser1);
	new id = pev(this, pev_owner);
	if(!pev_valid(iEnt) || id != get_pdata_cbase(iEnt, m_pPlayer))
	{
		engfunc(EngFunc_RemoveEntity, this);
		return;
	}
	
	new iType = pev(this, pev_iuser1)
	new Float:vecOrigin[3], Float:vecVelocity[3]
	pev(this, pev_origin, vecOrigin)
	pev(this, pev_velocity, vecVelocity)
	
	new Float:flDamage
	if(iType)
		flDamage = IS_ZBMODE ? 900.0:30.0
	else
		flDamage = IS_ZBMODE ? 900.0:30.0
	
	new flRadius = 3.0 * 36.37;
	new pEntity = -1, Float:flAdjustedDamage
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, flRadius)) && pev_valid(pEntity))
	{
		if (pev(pEntity, pev_takedamage) == DAMAGE_NO)
			continue;
		if (pEntity == id)
			continue;
		
		new Float:vecOrigin2[3]; pev(pEntity, pev_origin, vecOrigin2)
		new Float:vecDelta[3]; xs_vec_sub(vecOrigin2, vecOrigin, vecDelta)
		
		flAdjustedDamage = flDamage;
		flAdjustedDamage *= 1.0 - (vector_length(vecDelta) / flRadius);
		
		if(is_user_alive(pEntity))
			set_pdata_int(pEntity, 75, HIT_CHEST)
			
		ExecuteHamB(Ham_TakeDamage, pEntity, this, id, flAdjustedDamage, DMG_BULLET)
	}
	
	//engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, WEAPON_EVENT[CSW_KNIFE], 0.0, vecOrigin, {0.0, 0.0, 0.0}, 0.0 , 0.0, (1<<9), iType, FALSE, TRUE);
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, pEntity, m_usExplosion, 0.0, vecOrigin, {0.0, 0.0, 0.0}, 0.0 , 0.0, 0, 0, FALSE, FALSE);
	
	if(bShouldDivide)
	{
		new Float:vecAngles[3]
		engfunc(EngFunc_VecToAngles, vecVelocity, vecAngles)
		
		for(new i=-1;i<=1;i++)
		{
			new Float:vecNewVelocity[3];
			xs_vec_copy(vecAngles, vecNewVelocity);
			//vecNewVelocity[0] -= 30.0;
			vecNewVelocity[1] += float(i) *12.0;
			
			new Float:vecForward[3], Float:vecRight[3], Float:vecUp[3];
			engfunc(EngFunc_AngleVectors, vecNewVelocity, vecForward, vecRight, vecUp);
			
			xs_vec_mul_scalar(vecForward, 300.0, vecNewVelocity);
			new pEntity = CAUGEXGrenade_Create(id, vecOrigin, vecNewVelocity, iType + 1)
			if(pev_valid(pEntity)) set_pev(pEntity, pev_euser1, iEnt)
		}
		
	}
	engfunc(EngFunc_RemoveEntity, this)
}