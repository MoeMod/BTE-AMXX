// Made by Moe Xiaobaibai
// DATA FROM CSO mp.dll

/* (pev_iuser1, this+648) : iAttackRecord
	
	0=left(PrimaryAttack) 
	1=right(SecondaryAttack)
	2=left2(PrimaryAttack) 
	3=right2(SecondaryAttack)
*/
/* (pev_iuser3, this+548) : iSkillRecord
	
*/
/* (pev_iuser4, this+636) : iPrimaryAttackRecord
	
*/
/* (pev_sequence, this+644) : iThinkType
	
*/
/* (pev_fuser1, this+652) : flNextTimeCanHolster
	
*/
/* (pev_weaponanim, this+624) : iLastAnim
	
*/
/* (pev_waterlevel, this+336) : iSecondaryAttackCount
	
*/

enum
{
	EV_DUALSWORD_STAB = 1,
	EV_DUALSWORD_STAB_END,
	EV_DUALSWORD_SKILL_START,
	EV_DUALSWORD_SKILL_ACT,
	EV_DUALSWORD_SKILL_END,
}

public DualSword_CanHolster(iEnt)
{
	new Float:flNextTimeCanHolster;
	pev(iEnt, pev_fuser1, flNextTimeCanHolster);
	return get_gametime() > flNextTimeCanHolster;
}

public DualSword_Deploy(id, iEnt, iId, iBteWpn)
{
	set_pev(iEnt, pev_iuser4, 1);
	set_pev(iEnt, pev_iuser1, 0);
	
	set_pev(iEnt, pev_sequence, 0);
	set_pev(iEnt, pev_fuser1, 0.0);
	
	set_pev(iEnt, pev_waterlevel, 0);
	
	new iSkillRecord = pev(iEnt, pev_iuser3);
	iSkillRecord %= 2;
	set_pev(iEnt, pev_iuser3, iSkillRecord);
	
	DualSword_DestroyEffect(id, iEnt, iBteWpn);
	
	UTIL_WeaponDelay(iEnt, 0.0, 0.0, 0.0);
	//BTE_SetThink(iEnt, "DualSword_Think");
}

public DualSword_Holster(id, iEnt, iBteWpn)
{
	//BTE_SetThink(iEnt, "");
	
	new iSkillRecord = pev(iEnt, pev_iuser3);
	iSkillRecord %= 2;
	set_pev(iEnt, pev_iuser3, iSkillRecord);
	
	DualSword_DestroyEffect(id, iEnt, iBteWpn);
	
	UTIL_WeaponDelay(iEnt, 0.0, 0.0, 0.0);
}

public DualSword_DestroyEffect(id, iEnt, iBteWpn)
{
	
}

public DualSword_WeaponIdle(id, iEnt, iBteWpn)
{
	if(get_pdata_float(iEnt, m_flTimeWeaponIdle) > 0.0) 
		return
		
	ExecuteHamB(Ham_Weapon_ResetEmptySound, iEnt);
	//OrpheuCall(OrpheuGetFunctionFromEntity(id, "GetAutoaimVector", "CBasePlayer"), id, AUTOAIM_10DEGREES)
		
	new iSkillRecord = pev(iEnt, pev_iuser3);
	iSkillRecord %= 2;
	set_pev(iEnt, pev_iuser3, iSkillRecord);
	
	set_pev(iEnt, pev_iuser4, 1);
	set_pev(iEnt, pev_iuser1, 0);
	
	if(pev(iEnt, pev_iuser1) % 2)
	{
		SendWeaponAnim(id, c_iIdleAnim[iBteWpn][1]);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 3.0);
	}
	else
	{
		SendWeaponAnim(id, c_iIdleAnim[iBteWpn][0]);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 4.0);
	}
	return
}

public DualSword_ItemPostFrame(id, iEnt, iBteWpn)
{
	//new iBteWpn = WeaponIndex(iEnt);
	//new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	
	new Float:flNextThink;
	pev(iEnt, pev_nextthink, flNextThink);
	if(get_gametime() < flNextThink)
		return;
	
	new iAttackRecord = pev(iEnt, pev_iuser1);  // 648
	new iThinkType = pev(iEnt, pev_sequence);  // 644
	switch(iThinkType)
	{
		case 1:
		{
			DualSword_DelaySecondaryAttack(iEnt);
		}
		case 2:
		{
			// TEMPENTITY HERE, AFTER SECONDARYATTACK
			new iSkillRecord = pev(iEnt, pev_iuser3); // 548
			if(iSkillRecord == 4)
			{
				PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, 0.0, 0.0, 2, EV_DUALSWORD_STAB_END, FALSE, FALSE);
				
				iThinkType = 7;
				set_pev(iEnt, pev_sequence, iThinkType);
				set_pev(iEnt, pev_nextthink, get_gametime() + (0.65 - 0.53));
			}
			else
			{
				PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, 0.0, 0.0, 1, EV_DUALSWORD_STAB_END, FALSE, FALSE);
				
				iThinkType = 3;
				set_pev(iEnt, pev_sequence, iThinkType);
				set_pev(iEnt, pev_nextthink, get_gametime() + 0.77);
			}
		}
		case 3:
		{
			SendWeaponAnim(id, 5);
			set_pev(iEnt, pev_weaponanim, 5);
			UTIL_WeaponDelay(iEnt, 0.0, 0.0, 2.0);
			
			// ADDED
			iThinkType = 0;
			set_pev(iEnt, pev_sequence, iThinkType);
		}
		case 4:
		{
			DualSword_DelayPrimaryAttack(iEnt);
		}
		case 5:
		{
			DualSword_ActPrimaryAttack(id, iEnt, iBteWpn, pev(iEnt, pev_iuser4));
			
			new iSkillRecord = pev(iEnt, pev_iuser3); // 548
			new iPrimaryAttackRecord = pev(iEnt, pev_iuser4);  // 636
			if(iPrimaryAttackRecord)
			{
				if(iSkillRecord == 4 || iAttackRecord != 3)
				{
					iAttackRecord = 0;
					set_pev(iEnt, pev_iuser1, iAttackRecord);
					set_pev(iEnt, pev_iuser1, iSkillRecord != 4);
					
					iPrimaryAttackRecord = (iPrimaryAttackRecord == 0);
					set_pev(iEnt, pev_iuser4, iPrimaryAttackRecord);
				}
				else
				{
					iAttackRecord = 4;
					set_pev(iEnt, pev_iuser1, iAttackRecord);
					
					iPrimaryAttackRecord = (iPrimaryAttackRecord == 0);
					set_pev(iEnt, pev_iuser4, iPrimaryAttackRecord);
				}
			} // else if(iSkillRecord == 4 || iAttackRecord != 4)
			else if(iSkillRecord == 4 || iAttackRecord != 4)
			{
				iAttackRecord = 0;
				set_pev(iEnt, pev_iuser1, iAttackRecord);
				
				iPrimaryAttackRecord = 1;
				set_pev(iEnt, pev_iuser4, iPrimaryAttackRecord);
			}
			else
			{
				iAttackRecord = 5;
				set_pev(iEnt, pev_iuser1, iAttackRecord);
				
				iPrimaryAttackRecord = 1;
				set_pev(iEnt, pev_iuser4, iPrimaryAttackRecord);
			}
		}
		case 6:
		{
			SendWeaponAnim(id, 10);
			set_pev(iEnt, pev_weaponanim, 10);
			UTIL_WeaponDelay(iEnt, 0.0, 0.0, 1.5);
			
			// ADDED
			iThinkType = 0;
			set_pev(iEnt, pev_sequence, iThinkType);
		}
		case 7:
		{
			SendWeaponAnim(id, 14);
			set_pev(iEnt, pev_weaponanim, 14);
			
			iThinkType = 8;
			set_pev(iEnt, pev_sequence, iThinkType);
			set_pev(iEnt, pev_nextthink, get_gametime() + 1.0);
		}
		case 8:
		{
			SendWeaponAnim(id, 15);
			set_pev(iEnt, pev_weaponanim, 15);
			
			iThinkType = 9;
			set_pev(iEnt, pev_sequence, iThinkType);
			set_pev(iEnt, pev_nextthink, get_gametime() + 10.0 + 1.49 + 0.59 + 1.4 - 1.0); // ???
		}
		case 9:
		{
			SendWeaponAnim(id, 6);
			set_pev(iEnt, pev_weaponanim, 6);
			
			set_pev(iEnt, pev_iuser3, 1);
			
			// NOT SURE
			UTIL_WeaponDelay(iEnt, 0.0, 0.0, 0.2);
			
			// ADDED
			iThinkType = 0;
			set_pev(iEnt, pev_sequence, iThinkType);
		}
	}
}

public DualSword_PrimaryAttack(id, iEnt, iBteWpn)
{
	//SetKnifeDelay(iEnt, c_flDelay[iBteWpn][0], "DualSword_DelayPrimaryAttack");
	//OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	//SendWeaponAnim(id, 7);
	//UTIL_WeaponDelay(iEnt, c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0], c_flAttackInterval[iBteWpn][0] + 1.0);
	
	new iSkillRecord = pev(iEnt, pev_iuser3);
	if(iSkillRecord == 1)
	{
		SendWeaponAnim(id, 12);
		set_pev(iEnt, pev_weaponanim, 12);
		set_pev(iEnt, pev_iuser3, 0);
		
		UTIL_WeaponDelay(iEnt, 99999.992, 99999.992, 99999.992);
		set_pev(iEnt, pev_sequence, 4);
		set_pev(iEnt, pev_nextthink, get_gametime() + 0.0); // 不确定
	}
	else if(iSkillRecord != 3 || pev(iEnt,pev_sequence) != 1)
	{
		DualSword_DelayPrimaryAttack(iEnt)
	}
	else
	{
		set_pev(iEnt, pev_sequence, 4);
		UTIL_WeaponDelay(iEnt, 99999.992, 99999.992, 99999.992);
	}
	
	
}

public DualSword_DelayPrimaryAttack(iEnt)
{
	//new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	
	new iPrimaryAttackRecord = pev(iEnt, pev_iuser4);
	if(iPrimaryAttackRecord == 0)
	{
		SendWeaponAnim(id, 9);
		set_pev(iEnt, pev_weaponanim, 9);
		SendKnifeSound(id, 1, 0);
	}
	else
	{
		SendWeaponAnim(id, 8);
		set_pev(iEnt, pev_weaponanim, 8);
		SendKnifeSound(id, 1, 0);
	}
	
	

	set_pev(iEnt, pev_iuser3, 2);
	set_pev(iEnt, pev_sequence, 5);
	
	UTIL_WeaponDelay(iEnt, 999999.992, 999999.992, 999999.992);
	set_pev(iEnt, pev_nextthink, get_gametime() + 0.25);
}

public DualSword_ActPrimaryAttack(id, iEnt, iBteWpn, iType)
{
	// 50伤害 130长度 90度 0.15时间
	// 770伤害 140长度 180度 0.65时间
	if(iType)
	{
		new Float:flDamage = 50.0 * (IS_ZBMODE ? 4.5:1.0);
		new iHitResult = KnifeAttack2(id, TRUE, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][0], flDamage, c_flKnockback[iBteWpn][0], -1, TRUE);
		switch (iHitResult)
		{
			case RESULT_HIT_PLAYER : SendKnifeSound(id, 2, 0);
			case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
		}
		
		UTIL_WeaponDelay(iEnt, 0.15, 0.15, 999999.992);
		set_pev(iEnt, pev_nextthink, get_gametime() + 0.42); // 0x3ED70A3E
		set_pev(iEnt, pev_fuser1, get_gametime() + 0.15);
	}
	else
	{
		new Float:flDamage = 770.0 * (IS_ZBMODE ? 4.5:1.0);
		new Float:vecEnd[3];
		new iHitResult = KnifeAttack2(id, TRUE, c_flDistance[iBteWpn][1], c_flAngle[iBteWpn][1], flDamage, c_flKnockback[iBteWpn][1], -1, TRUE, _, _, vecEnd);
		switch (iHitResult)
		{
			case RESULT_HIT_PLAYER : SendKnifeSound(id, 2, 0);
			case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
		}
		
		UTIL_WeaponDelay(iEnt, 0.65, 0.65, 999999.992);
		set_pev(iEnt, pev_nextthink, get_gametime() + 0.65); // 0x3F266666
		set_pev(iEnt, pev_fuser1, get_gametime() + 0.65);
	}
	
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);
	// Next think will end attack
	set_pev(iEnt, pev_sequence, 6);
	
	
}

public DualSword_SecondaryAttack(id, iEnt, iBteWpn)
{
	set_pev(iEnt, pev_waterlevel, 0);
	set_pev(iEnt, pev_iuser4, 1);
	if(pev(iEnt, pev_iuser3) == 0)
	{
		SendWeaponAnim(id, 13);
		set_pev(iEnt, pev_weaponanim, 13);
		
		set_pev(iEnt, pev_iuser3, 1);
		
		UTIL_WeaponDelay(iEnt, 99999.992, 99999.992, 99999.992);
		
		set_pev(iEnt,pev_sequence, 1);
		set_pev(iEnt, pev_nextthink, get_gametime() + 0.0); // 不确定
		return;
	}
	
	DualSword_DelaySecondaryAttack(iEnt)
	
	if(pev(iEnt, pev_iuser3) == 4)
	{
		set_pev(iEnt, pev_iuser1, 0);
		return;
	}
	
	if(pev(iEnt, pev_iuser1) == 5)
	{
		set_pev(iEnt, pev_iuser1, 6);
		return;
	}
	
	if(pev(iEnt, pev_iuser3) == 4 || pev(iEnt, pev_iuser1) != 1)
	{
		set_pev(iEnt, pev_iuser1, 0);
	}
	else
	{
		set_pev(iEnt, pev_iuser1, 2);
	}
}

public DualSword_DelaySecondaryAttack(iEnt)
{
	
	new iBteWpn = WeaponIndex(iEnt);
	new id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	
	new iSecondaryAttackCount = pev(iEnt, pev_waterlevel);
	
	set_pev(iEnt, pev_iuser3, 3);
	
	new v8 = iSecondaryAttackCount % 4;
	SendWeaponAnim(id, v8 + 1);
	set_pev(iEnt, pev_weaponanim, v8 + 1);
	
	iSecondaryAttackCount++;
	set_pev(iEnt, pev_waterlevel, iSecondaryAttackCount);
	
	// something deleted
	new Float:flDamage;
	switch(v8)
	{
		case 0: flDamage = 50.0;
		case 1: flDamage = 70.0;
		case 2: flDamage = 90.0;
		case 3: flDamage = 405.0;
	}
	flDamage *= (IS_ZBMODE ? 4.5:1.0);
	
	// 距离120.0 角度330.0
	new Float:vecEnd[3];
	new iHitResult = KnifeAttack2(id, TRUE, c_flDistance[iBteWpn][2], c_flAngle[iBteWpn][2], flDamage, c_flKnockback[iBteWpn][2], -1, TRUE, _, _, vecEnd);
	/*
	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER : SendKnifeSound(id, 5, 0);
		case RESULT_HIT_WORLD : SendKnifeSound(id, 3, 0);
	}*/
	
	// Sound
	PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, 0.0, 0.0, v8, EV_DUALSWORD_STAB, iHitResult == RESULT_HIT_PLAYER, iHitResult == RESULT_HIT_WORLD);
	
	// SVC_TEMPENTITY? 第二个v模型的特效在这里发送
	
	if(iSecondaryAttackCount < 4)
	{
		UTIL_WeaponDelay(iEnt, 0.0, 99999.992, 99999.992);
		set_pev(iEnt, pev_nextthink, get_gametime() + 0.15);
		set_pev(iEnt, pev_sequence, 1);
	}
	else
	{
		UTIL_WeaponDelay(iEnt, 0.65, 0.65, 99999.992);
		set_pev(iEnt, pev_fuser1, get_gametime() + 0.65);
		set_pev(iEnt, pev_nextthink, get_gametime() + 0.53);
		set_pev(iEnt, pev_sequence, 2);
		
		// (pev_iuser3, this+548) : iSkillRecord
		new iSkillRecord = pev(iEnt, pev_iuser3);
		if(iSkillRecord == 4)
		{
			set_pev(iEnt, pev_iuser1, 0);
			return;
		}
		
		if(pev(iEnt, pev_iuser1) == 6)
		{
			set_pev(iEnt, pev_iuser1, 7);
			DualSword_SpawnEffect(iEnt, id);
			return;
		}
		
		if(iSkillRecord == 4 || pev(iEnt, pev_iuser1) != 2)
		{
			set_pev(iEnt, pev_iuser1, 0);
		}
		else
		{
			set_pev(iEnt, pev_iuser1, 3);
		}
	}
}

public DualSword_SpawnEffect(iEnt, id)
{
	new pEffect = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	if(pev_valid(pEffect))
	{
		CDualSwordSpecialEffect_Spawn(pEffect, id);
	}
	
	//client_print(id, print_chat, "DualSword_SpawnEffect");
	
	set_pev(iEnt, pev_iuser3, 4);
	set_pev(iEnt, pev_iuser1, 0);
	UTIL_WeaponDelay(iEnt, 99999.992, 99999.992, 99999.992);
}

public CDualSwordSpecialEffect_Spawn(this, id)
{
	set_pev(this, pev_classname, "d_dualsword");
	set_pev(this, pev_owner, id);
	set_pev(this, pev_iuser1, 0); // this+93(iEffectType)
	set_pev(this, pev_fuser1, get_gametime() + 0.65); // this+97
	set_pev(this, pev_nextthink, get_gametime() + 0.017); // *(this+1)+260
	BTE_SetThink(this, "CDualSwordSpecialEffect_Think");
}

//CDualSwordSpecialEffect_EffectThink
public CDualSwordSpecialEffect_Think(this)
{
	if(!pev_valid(this))
		return;
	set_pev(this, pev_nextthink, get_gametime() + 0.017); // *(this+1)+260
	new id = pev(this, pev_owner);
	
	if(!is_user_alive(id) || bte_get_user_zombie(id) == 1)
	{
		SUB_Remove(this, 0.0);
		return;
	}
	
	new pWeapon = get_pdata_cbase(id, m_pActiveItem);
	new iBteWpn = WeaponIndex(pWeapon);
	if (c_iSpecial[iBteWpn] != SPECIAL_DUALSWORD)
	{
		SUB_Remove(this, 0.0);
		return;
	}
	
	new iEffectType = pev(this, pev_iuser1);
	new Float:flNextEffect; pev(this, pev_fuser1, flNextEffect);
	switch(iEffectType)
	{
		case 0:
		{
			if(get_gametime() > flNextEffect)
			{
				// TEMPENTITY HERE (90 15 10)
				// "weapons/dualsword_skill_start.wav"
				PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, 0.0, 0.0, 0, EV_DUALSWORD_SKILL_START, FALSE, FALSE);
				set_pev(this, pev_iuser1, 1); // this+93(iEffectType)
				set_pev(this, pev_fuser1, get_gametime() + 1.49); // this+97
			}
		}
		case 1:
		{
			if(get_gametime() > flNextEffect)
			{
				set_pev(this, pev_iuser1, 2); // this+93(iEffectType)
				set_pev(this, pev_fuser1, get_gametime() + 10.0); // this+97
			}
		}
		case 2:
		{
			CDualSwordSpecialEffect_Attack(this)
		}
		case 3:
		{
			if(get_gametime() > flNextEffect)
			{
				// TEMPENTITY HERE (90 -20 15 10)
				// "weapons/dualsword_skill_end.wav"
				PLAYBACK_EVENT_FULL(FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, 0.0, 0.0, 0, EV_DUALSWORD_SKILL_END, FALSE, FALSE);
				set_pev(this, pev_iuser1, 4); // this+93(iEffectType)
				set_pev(this, pev_fuser1, get_gametime() + 1.4); // this+97
			}
		}
		case 4:
		{
			if(get_gametime() > flNextEffect)
			{
				BTE_SetThink(this, "");
				SUB_Remove(this, 0.0);
			}
		}
	}
}

public CDualSwordSpecialEffect_Attack(this)
{
	new Float:flNextEffect; pev(this, pev_fuser1, flNextEffect);
	if(get_gametime() < flNextEffect)
	{
		new Float:flLastAttack1; pev(this, pev_fuser2, flLastAttack1);
		if(get_gametime() >= flLastAttack1 + 0.15)
		{
			CDualSwordSpecialEffect_Attack1(this);
			flLastAttack1 = get_gametime();
			set_pev(this, pev_fuser2, flLastAttack1);
		}
		new Float:flLastAttack2; pev(this, pev_fuser3, flLastAttack2);
		if(get_gametime() >= flLastAttack2 + 0.05)
		{
			CDualSwordSpecialEffect_Attack2(this);
			flLastAttack2 = get_gametime();
			set_pev(this, pev_fuser3, flLastAttack2);
		}
		new Float:flLastAttack3; pev(this, pev_fuser4, flLastAttack3);
		if(get_gametime() >= flLastAttack3 + 0.15)
		{
			CDualSwordSpecialEffect_Attack3(this);
			flLastAttack3 = get_gametime();
			set_pev(this, pev_fuser4, flLastAttack3);
		}
	}
	else
	{
		set_pev(this, pev_fuser1, get_gametime() + 0.59); // this+97
		set_pev(this, pev_iuser1, 3); // this+93(iEffectType)
	}
}

public CDualSwordSpecialEffect_Attack1(this)
{
	//new Float:flRange = 150.0;
	// 40.0 10.0
	// size 0.3*10.0
}

public CDualSwordSpecialEffect_Attack2(this)
{
	// 70.0 -20.0
	//new Float:flRange = 1200.0;
	// size 0.3*10.0
}

public CDualSwordSpecialEffect_Attack3(this)
{
	new id = pev(this, pev_owner);
	if(!is_user_alive(id) || bte_get_user_zombie(id) == 1)
	{
		SUB_Remove(this, 0.0);
		return;
	}
	new pWeapon = get_pdata_cbase(id, m_pActiveItem);
	new iBteWpn = WeaponIndex(pWeapon);
	if (c_iSpecial[iBteWpn] != SPECIAL_DUALSWORD)
	{
		SUB_Remove(this, 0.0);
		return;
	}
	
	//new Float:flRange = 200.0;
	new Float:flDamage = (!IS_ZBMODE) ? 380.0 : 120.0
	// 1230.0
	
	new ptr = create_tr2()
	new Float:vecSrc[3], Float: vecEnd[3]
	GetGunPosition(id, vecSrc)
	
	new Float:flRange = c_flDistance[iBteWpn][3]
	
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
	}
}