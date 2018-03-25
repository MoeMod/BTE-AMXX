public CThanatos5_Precache()
{
	precache_model("models/thanatos5_bulleta.mdl");
	//precache_model("models/thanatos5_bulletb.mdl");
	precache_sound("weapons/thanatos5_shootb2_1.wav");
	precache_model("sprites/thanatos5_explode.spr");
	precache_model("sprites/thanatos5_explode2.spr");
}

public CThanatos5_ItemPostFrame(id, iEnt, iClip, iBteWpn)
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
			CThanatos5_SecondaryAttack(id, iEnt, iClip, iBteWpn)
		}
	}
}

public CThanatos5_Deploy(id, iEnt, iId, iBteWpn)
{
	SendExtraAmmo(id, iEnt);
	set_pev(iEnt, pev_iuser1, 0);
}

public CThanatos5_SecondaryAttack(id, iEnt, iClip, iBteWpn)
{
	if(!get_pdata_int(iEnt, m_iWeaponState))
	{
		set_pev(iEnt, pev_iuser1, 1);
		SendWeaponAnim(id, 11);
		UTIL_WeaponDelay(iEnt, 5.14, 5.14, 5.2);
	}
	else
	{
		SetExtraAmmo(id, iEnt, 0);
		set_pdata_int(iEnt, m_iWeaponState, 0);
		emit_sound(id, CHAN_WEAPON, "weapons/thanatos5_shootb2_1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		SendWeaponAnim(id, 8);
		UTIL_WeaponDelay(iEnt, 2.0, 2.0, 2.1);
		
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
		xs_vec_mul_scalar(vecUp, 150.0, vecUp);
		new Float:vecVelocity[3]
		xs_vec_add(vecForward, vecUp, vecVelocity);
		
		new pEntity = CThanatos5Rocket_Create(id, vecSrc, vecVelocity, 0)
		if(pev_valid(pEntity))
		{
			set_pev(pEntity, pev_euser1, iEnt);
		}
	}
}

public CThanatos5Rocket_Create(id, Float:vecOrigin[3], Float:vecVelocity[3], iType)
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if(!pev_valid(iEntity)) return -1
	
	set_pev(iEntity, pev_owner, id)
	set_pev(iEntity, pev_movetype, MOVETYPE_PUSHSTEP)
	set_pev(iEntity, pev_solid, SOLID_BBOX)
	set_pev(iEntity, pev_classname, "d_thanatos5")
	
	engfunc(EngFunc_SetModel, iEntity, "models/thanatos5_bulleta.mdl")
	
	set_pev(iEntity, pev_sequence, 0)
	set_pev(iEntity, pev_framerate, 1.0)
	
	set_pev(iEntity, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(iEntity, pev_maxs, Float:{1.0, 1.0, 1.0})
	
	set_pev(iEntity, pev_iuser1, iType);
	
	set_pev(iEntity, pev_origin, vecOrigin);
	set_pev(iEntity, pev_velocity, vecVelocity);
	
	BTE_SetThink(iEntity, "CThanatos5Rocket_IgniteThink");
	BTE_SetTouch(iEntity, "CThanatos5Rocket_Touch");
	
	set_pev(iEntity, pev_nextthink, get_gametime() + 0.1);
	return iEntity
}

public CThanatos5Rocket_IgniteThink(this)
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
	
	BTE_SetThink(this, "CThanatos5Rocket_FollowThink");
	set_pev(this, pev_nextthink, get_gametime() + (iType ? 1.8 : 2.0));
}

public CThanatos5Rocket_FollowThink(this)
{
	new iEnt=pev(this, pev_euser1);
	new id = pev(this, pev_owner);
	if(!pev_valid(iEnt) || id != get_pdata_cbase(iEnt, m_pPlayer))
	{
		engfunc(EngFunc_RemoveEntity, this);
		return;
	}
	
	CThanatos5Rocket_Explode(this)
}

public CThanatos5Rocket_Touch(this, pOther)
{
	if(is_user_alive(pOther) && !pev(this, pev_iuser1))
		CThanatos5Rocket_Explode(this)
}

public CThanatos5Rocket_Explode(this)
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
		flDamage = IS_ZBMODE ? 500.0:13.0
	else
		flDamage = IS_ZBMODE ? 260.0:8.0
	
	new pEntity = -1
	while((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecOrigin, (iType ? 63.0 : 105.0))) && pev_valid(pEntity))
	{
		if (pev(pEntity, pev_takedamage) == DAMAGE_NO)
			continue;
		if (pEntity == id)
			continue;
		
		if(is_user_alive(pEntity))
			set_pdata_int(pEntity, 75, HIT_CHEST)
			
		ExecuteHamB(Ham_TakeDamage, pEntity, this, id, flDamage, DMG_BULLET)
	}
	
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, WEAPON_EVENT[CSW_KNIFE], 0.0, vecOrigin, {0.0, 0.0, 0.0}, 0.0 , 0.0, (1<<9), iType, FALSE, TRUE);
	
	if(iType < 2)
	{
		//【萌の白】一个变四个 四个变十六个（什么鬼？！）
		new pEntity = -1;
		new Float:flDispersion = iType ? 120.0 : 120.0
		vecVelocity[2] += iType ? 100.0 : 100.0
		//【萌の白】右上角一个
		vecVelocity[0] += flDispersion
		vecVelocity[1] += flDispersion
		pEntity = CThanatos5Rocket_Create(id, vecOrigin, vecVelocity, iType + 1)
		if(pev_valid(pEntity)) set_pev(pEntity, pev_euser1, iEnt)
		//【萌の白】左上角一个
		vecVelocity[0] -= flDispersion * 2
		pEntity = CThanatos5Rocket_Create(id, vecOrigin, vecVelocity, iType + 1)
		if(pev_valid(pEntity)) set_pev(pEntity, pev_euser1, iEnt)
		//【萌の白】左下角一个
		vecVelocity[1] -= flDispersion * 2
		pEntity = CThanatos5Rocket_Create(id, vecOrigin, vecVelocity, iType + 1)
		if(pev_valid(pEntity)) set_pev(pEntity, pev_euser1, iEnt)
		//【萌の白】右下角一个
		vecVelocity[0] += flDispersion * 2
		pEntity = CThanatos5Rocket_Create(id, vecOrigin, vecVelocity, iType + 1)
		if(pev_valid(pEntity)) set_pev(pEntity, pev_euser1, iEnt)
	}
	engfunc(EngFunc_RemoveEntity, this)
}