// [BTE Weapon Effect FUNCTION]

#include "bte/BTE_WpnEffect_Knife.sma"
#include "bte/weapons/cannonex.sma"
#include "bte/weapons/buffawp.sma"
#include "bte/weapons/speargun.sma"
#include "bte/weapons/guillotine.sma"
#include "bte/weapons/balrog7.sma"
#include "bte/weapons/thanatos7.sma"
#include "bte/weapons/thanatos5.sma"
#include "bte/weapons/bow.sma"
#include "bte/weapons/janus7.sma"
#include "bte/weapons/janusmk5.sma"
#include "bte/weapons/janus1.sma"
#include "bte/weapons/janus11.sma"
#include "bte/weapons/bloodhunter.sma"
#include "bte/weapons/chainsaw.sma"
#include "bte/weapons/infinity.sma"
#include "bte/weapons/cannon.sma"
#include "bte/weapons/blockar.sma"
#include "bte/weapons/blocksmg.sma"
#include "bte/weapons/crow7.sma"
#include "bte/weapons/crow1.sma"
#include "bte/weapons/sterlingbayonet.sma"
#include "bte/weapons/augex.sma"
#include "bte/weapons/desperado.sma"
#include "bte/weapons/gunkata.sma"
#include "bte/weapons/starchasersr.sma"

public WpnEffect(id,iEnt,iClip,iAmmo,iId)
{
	if (bte_get_user_zombie(id) == 1)
		return;

	if (g_bCanReload[id] == FALSE)
		set_pev(id, pev_button, pev(id, pev_button) & ~IN_RELOAD);

	static iBteWpn;
	iBteWpn = g_weapon[id][0] + g_double[id][0];

	if (c_iType[iBteWpn] == WEAPONS_M134)
	{
		WE_M134(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (c_iType[iBteWpn] == WEAPONS_SVDEX)
	{
		WE_Svdex_2(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_M249EP)
	{
		WE_M249EP(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_QBARREL)
	{
		WE_Qbarrel(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_M16A1)
	{
		WE_M16A1(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_SKULL8)
	{
		WE_Skull8(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_FIRECRAKER)
	{
		WE_Firecraker(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_SKULL1)
	{
		WE_Skull1(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_SFMG)
	{
		WE_SFMG(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_SFPISTOL)
	{
		WE_SfPistol2(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_INFINITY)
	{
		CInfinity_ItemPostFrame(id,iEnt,iClip,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_SPEARGUN)
	{
		CSpeargun_ItemPostFrame(id,iEnt,iClip,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_SKULL11)
	{
		WE_Skull11(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_RAILCANNON)
	{
		WE_RailCannon(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_CHAINSAW)
	{
		CChainsaw_ItemPostFrame(id,iEnt,iClip,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_GILBOAEX)
	{
		WE_GilboaEX(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_M1GARAND)
	{
		WE_M1Garand(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_RPG)
	{
		RPG7_SecondaryAttack(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_CANNON)
	{
		CCannon_ItemPostFrame(id, iEnt, iClip, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_CANNONEX)
	{
		CCannonex_ItemPostFrame(id, iEnt, iClip, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_SPSMG)
	{
		WE_Spsmg(id,iEnt,iClip,iAmmo,iId,iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_AIRBURSTER)
	{
		WE_Airburster(id, iEnt, iClip, iAmmo, iId, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BLOCKAR)
	{
		CBlockAR_CheckCurrentStatus(id, iEnt, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_SGDRILL)
	{
		WE_SGDrill(id, iEnt, iClip, iAmmo, iId, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BOW)
	{
		CBow_ItemPostFrame(id, iEnt, iClip, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_GAUSS)
	{
		CGauss_ItemPostFrame(id, iEnt, iClip, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_GUILLOTINE)
	{
		CGuillotine_ItemPostFrame(id, iEnt, iClip, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BALROG7)
	{
		CBalrog7_ItemPostFrame(id, iEnt, iClip, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_THANATOS7)
	{
		CThanatos7_ItemPostFrame(id, iEnt, iClip, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_THANATOS5)
	{
		CThanatos5_ItemPostFrame(id, iEnt, iClip, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BUFFAWP)
	{
		CBuffAWP_ItemPostFrame(id, iEnt, iClip, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUS7)
	{
		CJanus7_ItemPostFrame(id, iEnt, iClip, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUSMK5)
	{
		CJanusmk5_ItemPostFrame(id, iEnt, iClip, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUS1)
	{
		CJanus1_ItemPostFrame(id, iEnt, iClip, iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BLOODHUNTER)
	{
		CBloodhunter_ItemPostFrame(id, iEnt, iClip, iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_BLOCKSMG)
	{
		CBlockSMG_CheckCurrentStatus(id, iEnt, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_CROW1)
	{
		CCrow1_ItemPostFrame(id, iEnt, iClip, iBteWpn);
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_STERLINGBAYONET)
	{
		CSterlingbayonet_ItemPostFrame(id, iEnt, iClip, iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_AUGEX)
	{
		CAugEX_ItemPostFrame(id, iEnt, iClip, iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUS11)
	{
		CJanus11_ItemPostFrame(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}												  
	else if (c_iSpecial[iBteWpn] == SPECIAL_DESPERADO)
	{
		CDesperado_ItemPostFrame(id, iEnt, iClip, iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_GUNKATA)
	{
		CGunkata_ItemPostFrame(id, iEnt, iClip, iBteWpn)
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_STARCHASERSR)
	{
		CStarchaserSR_ItemPostFrame(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
	else if (iId == CSW_KNIFE)
	{
		if (c_iSpecial[iBteWpn] == SPECIAL_SFSWORD)
		{
			//WE_SfSword(id,iEnt,iClip,iAmmo,iId,iBteWpn)
			return;
		}
		else if (c_iSpecial[iBteWpn] == SPECIAL_SKULLAXE)
		{
			//WE_SkullAxe(id,iEnt,iClip,iAmmo,iId,iBteWpn)
			return;
		}
		else if (c_iSpecial[iBteWpn] == SPECIAL_BALROG9)
		{
			WE_Balrog9(id,iEnt,iClip,iAmmo,iId,iBteWpn)
		}
		else if (c_iSpecial[iBteWpn] == SPECIAL_KATANA)
		{
			WE_Katana(id,iEnt,iClip,iAmmo,iId,iBteWpn)
		}
		else if (c_iSpecial[iBteWpn] == SPECIAL_HAMMER)
		{
			//WE_Hammer(id,iEnt,iClip,iAmmo,iId,iBteWpn)
			return;
		}
		else if (c_iSpecial[iBteWpn] == SPECIAL_JKNIFE)
		{
			WE_JKnife(id,iEnt,iClip,iAmmo,iId,iBteWpn)
		}
		else if (c_iSpecial[iBteWpn] == SPECIAL_DRAGONSWORD)
		{
			//WE_DragonSword(id,iEnt,iClip,iAmmo,iId,iBteWpn)
			return;
		}
		else
		{
			//WE_Melee(id,iEnt,iClip,iAmmo,iId,iBteWpn)
			return;
		}
	}

	return;
}

public WpnEffect_Shotguns(id,iEnt,iClip,iAmmo,iId)
{
	static iBteWpn;
	iBteWpn = g_weapon[id][0] + g_double[id][0];

	if (c_iSpecial[iBteWpn] == SPECIAL_BALROG11)
	{
		WE_Balrog11(id,iEnt,iClip,iAmmo,iId,iBteWpn)
	}
}

public CBuffAK47Ammo_AnimationThink(iEnt)
{
	new Float:flFrame, Float:flFrameRate, Float:flFrameTime, Float:flMaxFrames;
	pev(iEnt, pev_frame, flFrame);
	pev(iEnt, pev_framerate, flFrameRate);
	pev(iEnt, pev_fuser1, flMaxFrames);
	global_get(glb_frametime, flFrameTime);
	flFrame += flFrameRate * flFrameTime;
	if (flFrame > flMaxFrames)
		flFrame = 0.0;
	set_pev(iEnt, pev_frame, flFrame);
	set_pev(iEnt, pev_nextthink, get_gametime()+0.01);
}

public CBuffAK47Ammo_AmmoTouch(iPtr, iPtd)
{
	if (!pev_valid(iPtr)) return;
	if (iPtd == iPtr) return;
	if (iPtd == pev(iPtr, pev_owner)) return;
	static Float:vecOrigin[3], iBteWpn;
	pev(iPtr, pev_origin, vecOrigin);
	iBteWpn = Get_Ent_Data(iPtr, DEF_ENTID);
	if (pev_valid(iPtd) && pev(iPtd, pev_takedamage))
	{
		EntityTouchDamage2(iPtr, pev(iPtr, pev_owner), (!IS_ZBMODE) ? c_flEntityDamage[iBteWpn][0] : c_flEntityDamageZB[iBteWpn][0], HITGROUP_CHEST, DMG_BULLET | DMG_NEVERGIB);
	}
	RadiusDamage(vecOrigin, iPtr, pev(iPtr, pev_owner), (!IS_ZBMODE) ? c_flEntityDamage[iBteWpn][1] : c_flEntityDamageZB[iBteWpn][1], c_flEntityRange[iBteWpn][0], c_flEntityKnockBack[iBteWpn], DMG_BULLET | DMG_NEVERGIB, TRUE, TRUE, FALSE);
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITE);
	engfunc(EngFunc_WriteCoord, vecOrigin[0]);
	engfunc(EngFunc_WriteCoord, vecOrigin[1]);
	engfunc(EngFunc_WriteCoord, vecOrigin[2]);
	write_short(g_sModelIndexBuffAKEXP);
	write_byte(5);
	write_byte(200);
	message_end();

	BTE_SetThink(iPtr, "");
	BTE_SetTouch(iPtr, "");

	RemoveEntity(iPtr);
}

public CBuffAK47_AmmoAttack(id, iEnt, iClip, iBteWpn)
{
	if (!iClip)
		return;
	static pEnt;
	static Float:vecVelocity[3], Float:vecOrigin[3];
	GetGunPosition(id, vecOrigin);
	velocity_by_aim(id, floatround(c_flEntitySpeed[iBteWpn]), vecVelocity);
	set_pdata_int(iEnt, m_iClip, iClip-1);
	pEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
	set_pev(pEnt, pev_classname, "d_buffak");
	engfunc(EngFunc_SetModel, pEnt, "sprites/muzzleflash19.spr");
	engfunc(EngFunc_SetSize, pEnt, {-4.0, -4.0, -4.0}, {4.0, 4.0, 4.0});
	set_pev(pEnt, pev_rendermode, kRenderTransAdd);
	set_pev(pEnt, pev_renderfx, kRenderFxNone);
	set_pev(pEnt, pev_renderamt, 180.0);
	set_pev(pEnt, pev_framerate, 10.0);
	set_pev(pEnt, pev_scale, 0.05);
	set_pev(pEnt, pev_origin, vecOrigin);
	set_pev(pEnt, pev_solid, SOLID_BBOX);
	set_pev(pEnt, pev_movetype, MOVETYPE_FLYMISSILE);
	set_pev(pEnt, pev_velocity, vecVelocity);
	set_pev(pEnt, pev_owner, id);
	set_pev(pEnt, pev_nextthink, get_gametime()+0.01);
	set_pev(pEnt, pev_fuser1, g_flFramesBuffAKEXP);

	Set_Ent_Data(pEnt, DEF_ENTID, iBteWpn);
	
	BTE_SetThink(pEnt, "CBuffAK47Ammo_AnimationThink");
	BTE_SetTouch(pEnt, "CBuffAK47Ammo_AmmoTouch");

	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 0, 0, TRUE, FALSE);
	
	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1]);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][1]);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flAttackInterval[iBteWpn][1] + 1.0);

	//PunchAxis(id, random_float(-10.0, 10.0), random_float(-8.0, 8.0), -8.0, -7.0);
	
	if (GetVelocity2D(id))
		KickBack(iEnt, 5.0, 3.0, 0.9, 0.5, 9.0, 9.0, 5);
	else
	{
		if (pev(id, pev_flags) & FL_ONGROUND)
		{
			if (pev(id, pev_flags) & FL_DUCKING)
				KickBack(iEnt, 3.0, 3.0, 0.65, 0.3, 7.25, 7.25, 8);
			else
				KickBack(iEnt, 4.5, 4.5, 0.75, 0.3, 8.0, 8.0, 6);
		}
		else
			KickBack(iEnt, 5.0, 3.0, 0.9, 0.5, 9.0, 9.0, 5);
	}
}

public CSGDrill_SecondaryAttack(id, iEnt, iBteWpn)
{
	g_bSGDRILL_Attacking = TRUE;
	KnifeAttack5(id, FALSE, c_flDistance[iBteWpn][1], c_flAngle[iBteWpn][0], IS_ZBMODE ? c_flDamageZB[iBteWpn][1] : c_flDamage[iBteWpn][1], c_flKnockback[iBteWpn][4], 180.0);
	g_bSGDRILL_Attacking = FALSE;
	set_pev(iEnt, pev_fuser1, 0.0);
}

public WE_SGDrill(id, iEnt, iClip, iAmmo, iId, iBteWpn)
{
	static iButton, Float:flNextAttack, Float:flNextResetModel;
	iButton = pev(id, pev_button);
	pev(iEnt, pev_fuser1, flNextAttack);
	pev(iEnt, pev_fuser2, flNextResetModel);
	
	if (flNextAttack && flNextAttack <= get_gametime())
	{
		CSGDrill_SecondaryAttack(id, iEnt, iBteWpn);
	}
	if (flNextResetModel && flNextResetModel <= get_gametime())
	{
		set_pev(id, pev_weaponmodel2, c_sModel_P[iBteWpn]);
		set_pev(iEnt, pev_fuser2, 0.0);
	}
	
	if (!Stock_Can_Attack())
		return;
	
	if (!(iButton & IN_ATTACK) && (iButton & IN_ATTACK2) && get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0 && !flNextAttack)
	{
		SendWeaponAnim(id, 2);
		
		set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1]);
		set_pev(iEnt, pev_fuser1, get_gametime() + c_flDelay[iBteWpn][0]);
		set_pev(iEnt, pev_fuser2, get_gametime() + 1.2);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.4);
		
		set_pev(id, pev_weaponmodel2, "models/p_sgdrill_slash.mdl");
		
		OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK2);
		
		engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, 0.0, 0.0, 0, 0, TRUE, FALSE);
	}
}

public WE_Airburster(id, iEnt, iClip, iAmmo, iId, iBteWpn)
{
	if (!Stock_Can_Attack()) return;
	if (!iClip) return;
	static iButton;
	iButton = pev(id, pev_button);
	if (((!(iButton & IN_ATTACK) && !(iButton & IN_ATTACK2)) || !iClip) && get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0 && pev(iEnt, pev_iuser2))
	{
		SendWeaponAnim(id, 2);
		set_pev(iEnt, pev_iuser2, 0);
	}
	
	if (iButton & IN_ATTACK && get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0)
	{
		iClip --;
		set_pdata_int(iEnt, m_iClip, iClip);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flAttackInterval[iBteWpn][0] + 1.0);
		set_pev(iEnt, pev_iuser2, 1);
		AirbursterAttack(id, FALSE, c_flDistance[iBteWpn][0], 20.0, IS_ZBMODE ? c_flDamageZB[iBteWpn][0] : c_flDamage[iBteWpn][0], _)
		engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 0, 0, FALSE, FALSE);
	}
	else if (iButton & IN_ATTACK2 && get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0)
	{
		iClip -= 10;
		if (iClip <= 0) iClip = 0;
		set_pdata_int(iEnt, m_iClip, iClip);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1]);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flAttackInterval[iBteWpn][1] + 1.0);
		AirbursterAttack(id, FALSE, c_flDistance[iBteWpn][1], c_flAngle[iBteWpn][0], IS_ZBMODE ? c_flDamageZB[iBteWpn][1] : c_flDamage[iBteWpn][1], c_flKnockback[iBteWpn][4]);
		set_pev(iEnt, pev_iuser2, 0);
		engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 0, 0, TRUE, FALSE);
	}
}

public WE_Spsmg(id,iEnt,iClip,iBpAmmo,iId,iBteWpn)
{
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) > 0.0)
		return;

	if (!iClip)
		return;
		
	if (!Stock_Can_Attack()) return;

	static iButton;
	iButton = pev(id, pev_button);

	if (iButton & IN_ATTACK2)
	{
		if (pev(id, pev_waterlevel) == 3)
		{
			PlayEmptySound(iEnt);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.2);
			set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.2);
		}


		if (iClip > 1)
		{
			new Float:vecSrc[3], Float:vecAngles[3], Float:vecPunchangle[3], Float:vecDir[3];

			GetGunPosition(id, vecSrc);

			pev(id, pev_v_angle, vecAngles);
			pev(id, pev_punchangle, vecPunchangle);
			xs_vec_add(vecAngles, vecPunchangle, vecAngles);

			engfunc(EngFunc_MakeVectors, vecAngles);
			global_get(glb_v_forward, vecDir);

			new Float:vecSpread[3];
			vecSpread[0] = vecSpread[1] = 0.067;
			vecSpread[2] = 0.0;

			engfunc(EngFunc_PlaybackEvent, 0, id, m_usFire[iBteWpn][0], 0.0, g_vecZero, g_vecZero, vecSpread[0], vecSpread[1], iClip, 0, TRUE, TRUE);
			
			FireBullets(id, iClip, vecSrc, vecDir, vecSpread, 3200.0, BULLET_PLAYER_BUCKSHOT, 0, floatround(IS_ZBMODE ? c_flDamageZB[iBteWpn][1] : c_flDamage[iBteWpn][1]));

			PunchAxis(id, -5.0, 1.0, -5.0, -1.0);
			
			set_pdata_int(iEnt, m_iClip, 0);

			set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1]);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.367);
		}
		else
		{
			ExecuteHamB(Ham_Weapon_PrimaryAttack, iEnt);
		}
	}
}

public RPG7_PrimaryAttack(id, iEnt, iClip, iBteWpn)
{
	if (pev(id, pev_waterlevel) == 3)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.2);

		return;
	}

	if (!iClip)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.6);

		return;
	}

	//set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH);
	//OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

	new iWeaponState = get_pdata_int(iEnt, m_iWeaponState);

	if (c_iShake[iBteWpn])
	{
		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id);
		write_short((1<<12) * c_iShake[g_weapon[id][0]]);
		write_short((1<<12)*1);
		write_short((1<<12) * c_iShake[g_weapon[id][0]]);
		message_end()
	}

	iClip --;
	set_pdata_int(iEnt, m_iClip, iClip);

	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flAttackInterval[iBteWpn][0]);

	//new movetype = (iWeaponState & WPNSTATE_RPG_AIMING) ? MOVETYPE_FLY : MOVETYPE_BOUNCE;
	//new movetype = MOVETYPE_FLY;
	//new Float:gravity = (iWeaponState & WPNSTATE_RPG_AIMING) ? -0.01 : -0.15;

	new movetype = MOVETYPE_BOUNCE;
	new Float:gravity = 0.19;
	new Float:angle = -3.0;
	new Float:velocity[3];

	pev(id, pev_velocity, velocity);

	if (xs_vec_len(velocity) > 140.0)
		angle = (iWeaponState & WPNSTATE_RPG_AIMING) ? -3.0 : -6.0;
	else
		angle = 0.0;

	new pEntity = CreateEntity(id, iBteWpn, "models/rpg7_rocket.mdl", angle, c_flEntitySpeed[iBteWpn], gravity, movetype, ENTCLASS_NADE);
	SetGreadeEntity(pEntity, iBteWpn, 7);

#if 1
	set_pev(pEntity, pev_nextthink, get_gametime() + 0.6);

	new Float:v_angle[3];
	pev(id, pev_v_angle, v_angle);
	set_pev(pEntity, pev_v_angle, v_angle);

	new Float:random;

	if (xs_vec_len(velocity) > 140.0)
		random = (iWeaponState & WPNSTATE_RPG_AIMING) ? -0.7 : -1.0;
	else
		random = (iWeaponState & WPNSTATE_RPG_AIMING) ? -0.3 : -0.5;

	set_pev(pEntity, pev_fuser1, random);
#endif

	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, pEntity, 0, (iWeaponState & WPNSTATE_RPG_AIMING), TRUE);

	//engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, pEntity, m_usBalrog11Cannon, 0.0, g_vecZero, g_vecZero, 0.0, 0.0, 0, 0, FALSE, FALSE);

	PunchAxis(id, c_flPunchangle[iBteWpn], 0.0, c_flPunchangle[iBteWpn]);

	set_pdata_int(iEnt, m_iWeaponState, iWeaponState & ~WPNSTATE_RPG_AIMING);
}

public RPG7_SecondaryAttack(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) >= 0.0)
		return;

	new iButton = pev(id, pev_button);

	if (!(iButton & IN_ATTACK2))
		return;

	new iWeaponState = get_pdata_int(iEnt, m_iWeaponState);

	/*if (iWeaponState & WPNSTATE_RPG_AIMING)
		set_pdata_string(id, m_szAnimExtention * 4, c_szAnimExtention[iBteWpn], -1, 20);
	else
		set_pdata_string(id, m_szAnimExtention * 4, "at4", -1, 20);*/

	set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.36);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.36);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.36);

	SendWeaponAnim(id, (iWeaponState & WPNSTATE_RPG_AIMING) ? (iClip ? 10 : 12) : (iClip ? 9 : 11));

	set_pdata_int(iEnt, m_iWeaponState, (iWeaponState & WPNSTATE_RPG_AIMING) ? 0 : WPNSTATE_RPG_AIMING);
}

public WE_M1Garand(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) >= 0.0)
		return;

	new iWeaponState = get_pdata_int(iEnt, m_iWeaponState);
	new iButton = pev(id, pev_button);

	if (!iClip)
		SetCanReload(id, TRUE);
	else
		SetCanReload(id, FALSE);

	if ((iWeaponState & WPNSTATE_M1GARAND_AIMING) && !iClip && iAmmo)
	{
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.23);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.23);

		SendWeaponAnim(id, 9);
		set_pdata_int(iEnt, m_iWeaponState, 0);

		return;
	}

	if (!(iButton & IN_ATTACK2))
		return;

	set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.23);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.23);

	SendWeaponAnim(id, (iWeaponState & WPNSTATE_M1GARAND_AIMING) ? (iClip ? 8 : 9) : (iClip ? 6 : 7));

	set_pdata_int(iEnt, m_iWeaponState, (iWeaponState & WPNSTATE_M1GARAND_AIMING) ? 0 : WPNSTATE_M1GARAND_AIMING);
}

public WE_GilboaEX(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	if (!Stock_Can_Attack())
		return;

	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) >= 0.0)
		return;

	new iButton = pev(id, pev_button);

	if (!(iButton & IN_ATTACK2))
		return;

	if (iClip <= 0)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.2);

		return;
	}

	if (iClip == 1)
	{
		ExecuteHamB(Ham_Weapon_PrimaryAttack, iEnt);

		return;
	}

	new flags = pev(id, pev_flags);
	new Float:velocity = GetVelocity2D(id);
	new Float:spread;

	new Float:flAccuracy = get_pdata_float(iEnt, m_flAccuracy);

	if (!(flags & FL_ONGROUND))
		spread = 0.04 + (0.3) * flAccuracy;
	else if (velocity > 140.0)
		spread = 0.04 + (0.07) * flAccuracy;
	else
		spread = (0.0375) * flAccuracy;

	new iShotsFired = get_pdata_int(iEnt, m_iShotsFired) + 2;

	set_pdata_bool(iEnt, m_bDelayFire, true);
	set_pdata_int(iEnt, m_iShotsFired, iShotsFired);
	flAccuracy = ((iShotsFired * iShotsFired * iShotsFired) / 300.0) + 0.35;

	if (flAccuracy > 1.25)
		flAccuracy = 1.25;

	set_pdata_float(iEnt, m_flAccuracy, flAccuracy);

	set_pdata_int(iEnt, m_iClip, iClip - 2);
	set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

	new Float:vecSrc[3], Float:v_angle[3], Float:punchangle[3], Float:v_forward[3], Float:v_right[3], Float:v_right2[3], Float:vecDir[3][2];

	pev(id, pev_v_angle, v_angle);
	pev(id, pev_v_angle, punchangle);
	xs_vec_add(v_angle, punchangle, v_forward);

	engfunc(EngFunc_MakeVectors, v_angle);
	global_get(glb_v_forward, v_forward);


	new Damage = floatround(IS_ZBMODE ? c_flDamageZB[iBteWpn][0] : c_flDamage[iBteWpn][0]);
	new shared_rand = get_pdata_int(id, 96);

	global_get(glb_v_right, v_right);
	xs_vec_mul_scalar(v_right, 1.0, v_right2);
	GetGunPosition(id, vecSrc);
	xs_vec_add(vecSrc, v_right, vecSrc);

	RageCall(handleFireBullets3, id, vecSrc, v_forward, spread, 8192.0, 2, BULLET_PLAYER_556MM, Damage, 0.98, id, FALSE, shared_rand, vecDir[0]); // random_seed = 96

	xs_vec_mul_scalar(v_right, -1.0, v_right2);
	GetGunPosition(id, vecSrc);
	xs_vec_add(vecSrc, v_right, vecSrc);

	RageCall(handleFireBullets3, id, vecSrc, v_forward, spread, 8192.0, 2, BULLET_PLAYER_556MM, Damage, 0.98, id, FALSE, shared_rand, vecDir[1]); // random_seed = 96

	// send spread shared_rand, let client do same calc
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, spread, float(shared_rand), floatround(punchangle[0] * 10000000), floatround(punchangle[1] * 10000000), FALSE, TRUE);

	/*m_pPlayer->m_iWeaponVolume = NORMAL_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = BRIGHT_GUN_FLASH;*/

	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1]);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][1]);

	set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.85);

	if (velocity > 0.0)
		OrpheuCall(handleKickBack, iEnt, 1.0, 0.45, 0.44, 0.08, 6.75, 6.0, 7);
	else if (!(flags & FL_ONGROUND))
		OrpheuCall(handleKickBack, iEnt, 1.2, 0.5, 0.33, 0.25, 8.5, 7.5, 6);
	else if (flags & FL_DUCKING)
		OrpheuCall(handleKickBack, iEnt, 0.6, 0.3, 0.3, 0.020, 6.25, 4.0, 7);
	else
		OrpheuCall(handleKickBack, iEnt, 0.65, 0.35, 0.4, 0.025, 6.5, 4.25, 7);

	/*
	// call it twice ._.|||||||||
	OrpheuCallSuper(handleKickBack, iEnt, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0);
	OrpheuCallSuper(handleKickBack, iEnt, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0);
	*/

	/*if (m_pPlayer->pev->velocity.Length2D() > 0)
		KickBack(1.0, 0.45, 0.28, 0.045, 3.75, 3.0, 7);
	else if (!FBitSet(m_pPlayer->pev->flags, FL_ONGROUND))
		KickBack(1.2, 0.5, 0.23, 0.15, 5.5, 3.5, 6);
	else if (FBitSet(m_pPlayer->pev->flags, FL_DUCKING))
		KickBack(0.6, 0.3, 0.2, 0.0125, 3.25, 2.0, 7);
	else
		KickBack(0.65, 0.35, 0.25, 0.015, 3.5, 2.25, 7);*/
}

public WE_RailCannon(id,iEnt,iClip,iBpAmmo,iId,iBteWpn)
{
	new iButton, iCharge;
	iButton = pev(id, pev_button);
	iCharge = pev(iEnt, pev_iuser1);

	if (iButton & IN_ATTACK2)
	{
		// attacked or charged
		if (get_pdata_float(iEnt, m_flNextPrimaryAttack) > 0.0)
			return;

		// at last 3 clip to charge
		if (iClip < 1 && !iCharge)
			return;

		if (!iClip || iCharge == 3) // stop charge or fully charged
			return;

		// start charge

		if (get_pdata_float(iEnt, m_flNextSecondaryAttack) < 0.0) // charge finish
		{
			iCharge += 1;
			iClip -= 1;
			set_pev(iEnt, pev_iuser1, iCharge);
			set_pdata_int(iEnt, m_iClip, iClip);
			SetExtraAmmo(id, iEnt, iCharge);

			set_pdata_float(id, m_flTimeWeaponIdle, 0.01);
			// 1    2    6         7     10        11   12
			// 0.4s 0.3s 0.25s (4) 0.3s  0.35s (3) 0.4s 0.45s
			switch (iCharge)
			{
				case 1 : set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.455);
				case 2 : set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.455);
				case 3 : set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.455);
			}

			if (iCharge == 1)
			{
				client_cmd(id, "spk weapons/railcanon_chage1_start.wav");
				client_cmd(id, "spk weapons/railcanon_chage1.wav");
				
			}
			else if (iCharge == 2)
			{
				client_cmd(id, "spk weapons/railcanon_chage2.wav");
				//client_cmd(id, "spk weapons/railcanon_chage3_loop.wav");
			}
			else if (iCharge == 3)
				client_cmd(id, "spk weapons/railcanon_chage3.wav");

			switch (iCharge)
			{
				case 1 : SendWeaponAnim2(id, 1);
				case 2 : SendWeaponAnim2(id, 2);
				case 3 : SendWeaponAnim2(id, 3);
			}

			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.5);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 60.0);
		}

		return;
	}

	if (!(iButton & IN_ATTACK2) && !(iButton & IN_RELOAD))
	{
		if (!iCharge)
			return;

		//client_cmd(id, "stopsound weapons/railcanon_chage3_loop.wav");
		// ATTACK!!!

		SetExtraAmmo(id, iEnt, 0);

		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.8);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.03);


		set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH);
		OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);


		new Float: vecSrc[3], Float: v_angle[3], Float: punchangle[3], Float: vecForward[3];

		GetGunPosition(id, vecSrc);

		pev(id, pev_v_angle, v_angle);
		pev(id, pev_punchangle, punchangle);
		xs_vec_add(v_angle, punchangle, v_angle);
		engfunc(EngFunc_MakeVectors, v_angle);

		global_get(glb_v_forward, vecForward);
		
		new Float:vecReturn[3]
		switch(iCharge)
		{
			case 1:RageCall(handleFireBullets, id, 7, vecSrc, vecForward, Float:{0.0715,0.0715,0.0}, 4128.0, 4, 0, IS_ZBMODE?32:20, id, vecReturn);
			case 2:RageCall(handleFireBullets, id, 8, vecSrc, vecForward, Float:{0.045,0.045,0.0}, 6096.0, 4, 0, IS_ZBMODE?48:20, id, vecReturn);
			case 3:RageCall(handleFireBullets, id, 8, vecSrc, vecForward, Float:{0.01,0.01,0.0}, 8192.0, 4, 0, IS_ZBMODE?75:16, id, vecReturn);
		}

		engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, float(iCharge), 0.0, 0, 0, TRUE, FALSE);

		if(pev(id, pev_flags) & FL_ONGROUND)
			punchangle[0] -= random_float(2.0,4.0);
		else
			punchangle[0] -= random_float(7.0,10.0);
		
		set_pev(id, pev_punchangle, punchangle);
		
		set_pev(iEnt, pev_iuser1, 0);
	}
}
public WE_M134(id,iEnt,iClip,iBpAmmo,iId,iBteWpn)
{
	static iButton
	iButton = pev(id,pev_button)
	if (!Stock_Can_Attack()) return

	new Float:flNextPrimaryAttack = get_pdata_float(iEnt, m_flNextPrimaryAttack);
	new iWeaponState = get_pdata_int(iEnt, m_iWeaponState);

	if (iButton & IN_ATTACK)
	{
		//静止
		if (!iClip && iWeaponState == WPNSTATE_M134_SPINNING) //没子弹的情况
		{
			SendWeaponAnim(id, M134_fire_after);

			set_pev(id, pev_maxspeed, c_flMaxSpeed[iBteWpn][0]);
			//Pub_Set_MaxSpeed(id, c_flMaxSpeed[iBteWpn][0]);

			set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.0);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.0);
			set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_M134_IDLE);

			set_pev(id, pev_button, (iButton & ~ IN_ATTACK))
		}
		if (iWeaponState == WPNSTATE_M134_IDLE)
		{
			if (flNextPrimaryAttack <= 0.0 && iClip)
			{
				SendWeaponAnim(id, M134_fire_ready);

				set_pev(id, pev_maxspeed, c_flMaxSpeed[iBteWpn][1]);
				//Pub_Set_MaxSpeed(id, c_flMaxSpeed[iBteWpn][1]);

				set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.0);
				set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.06);
				set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_M134_SPIN_UP);

				set_pev(id, pev_button, (iButton & ~ IN_ATTACK));
			}
		}
		if (iWeaponState == WPNSTATE_M134_SPIN_UP && flNextPrimaryAttack <= 0.0)
		{
			set_pev(id, pev_maxspeed, c_flMaxSpeed[iBteWpn][1]);

			set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_M134_SPINNING);
		}
		if (iWeaponState == WPNSTATE_M134_SPIN_DOWN && iClip)   // Nice 重新振作起来
		{
			SendWeaponAnim(id, M134_fire_change);

			set_pev(id, pev_maxspeed, c_flMaxSpeed[iBteWpn][1]);
			//Pub_Set_MaxSpeed(id, c_flMaxSpeed[iBteWpn][1]);

			set_pdata_float(iEnt, m_flNextPrimaryAttack,1.0);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.0); // 1.0秒后就可以射了
			set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_M134_SPIN_UP);

			set_pev(id,pev_button,(iButton & ~ IN_ATTACK))
		}
	}
	else if (!(iButton & IN_ATTACK2))
	{
		//情况1 在预热发射前放弃预热
		if (iWeaponState == WPNSTATE_M134_SPIN_UP)
		{
			SendWeaponAnim(id, M134_idle_change);

			set_pev(id, pev_maxspeed, c_flMaxSpeed[iBteWpn][0]);
			//Pub_Set_MaxSpeed(id, c_flMaxSpeed[iBteWpn][0])

			set_pdata_float(iEnt,m_flNextPrimaryAttack, 1.5) // 1.5秒内无法预热
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.5)
			set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_M134_IDLE);

			set_pev(id, pev_button, (iButton & ~ IN_ATTACK))
		}
		// 情况2 在发射的时候停止
		if (iWeaponState == WPNSTATE_M134_SPINNING)
		{
			SendWeaponAnim(id, M134_fire_after);

			set_pev(id, pev_maxspeed, c_flMaxSpeed[iBteWpn][0]);
			//Pub_Set_MaxSpeed(id, c_flMaxSpeed[iBteWpn][0])

			set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.0) // 给你1.0秒的时间重新启动
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.0)
			set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_M134_SPIN_DOWN);

			set_pev(id, pev_button, (iButton & ~ IN_ATTACK))
		}
		if (iWeaponState == WPNSTATE_M134_SPIN_DOWN && flNextPrimaryAttack <= 0.0)
		{
			set_pev(id, pev_maxspeed, c_flMaxSpeed[iBteWpn][0]);
			//Pub_Set_MaxSpeed(id, c_flMaxSpeed[iBteWpn][0])
			// 1.3秒已过 没机会了 只能重新启动
			set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_M134_IDLE);

			set_pev(id,pev_button,(iButton & ~ IN_ATTACK))
		}
	}
	else if (c_iSpecial[iBteWpn] == SPECIAL_M134EX)
	{
		if (iButton & IN_ATTACK2 && iClip)
		{
			if (iWeaponState == WPNSTATE_M134_IDLE)
			{
				if (flNextPrimaryAttack <= 0.0)
				{
					SendWeaponAnim(id, M134_fire_ready);

					set_pev(id, pev_maxspeed, c_flMaxSpeed[iBteWpn][1]);
					//Pub_Set_MaxSpeed(id, c_flMaxSpeed[iBteWpn][1]);

					set_pdata_float(iEnt, m_flTimeWeaponIdle, 60.0);
					set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.8) //预热是2.0秒
					set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_M134_SPIN_UP);

					set_pev(id, pev_button, (iButton & ~ IN_ATTACK2));
				}
			}


			if ((iWeaponState == WPNSTATE_M134_SPINNING || iWeaponState == WPNSTATE_M134_SPIN_UP) && flNextPrimaryAttack <= 0.0)
			{
				if (pev(id, pev_weaponanim) != 8)
				{
					SendWeaponAnim(id, 8);

					set_pdata_float(iEnt, m_flTimeWeaponIdle, 60.0);
				}

				set_pev(id, pev_maxspeed, c_flMaxSpeed[iBteWpn][1]);

				set_pdata_float(iEnt, m_flTimeWeaponIdle, 50.0, 4)
				set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_M134_SPIN_UP);

				set_pev(id, pev_button, (iButton & ~ IN_ATTACK2))
			}
		}
	}
}

public WE_M249EP(id,iEnt,iClip,iBpAmmo,iId,iBteWpn)
{
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) > 0.0)
		return;

	static iButton;
	iButton = pev(id, pev_button);

	if (iButton & IN_ATTACK2)
	{
		OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK2);

		set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1]);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flAttackInterval[iBteWpn][1] + 0.5);

		new iCallBack = KnifeAttack(id, TRUE, c_flDistance[iBteWpn][1], (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1], c_flKnockback[iBteWpn][4]);

		if (iCallBack != RESULT_HIT_NONE)
		{
			emit_sound(id, CHAN_ITEM, random_num(0,1) ? "weapons/m249ep_hit2.wav" : "weapons/m249ep_hit1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			SendWeaponAnim(id, WEAPON_TOTALANIM[c_iId[iBteWpn]]);
		}
		else
		{
			SendWeaponAnim(id, WEAPON_TOTALANIM[c_iId[iBteWpn]] + 1);
		}
	}
}

public WE_Qbarrel(id,iEnt,iClip,iBpAmmo,iId,iBteWpn)
{
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) > 0.0)
		return;

	if (!iClip)
		return;

	static iButton;
	iButton = pev(id, pev_button);

	if (iButton & IN_ATTACK2)
	{
		// PrimaryAttack -> FireBullets -> PLAYBACK_EVENT_FULL
		// reset iuser1 in PlaybackEvent

		set_pev(iEnt, pev_iuser1, iClip);

		ExecuteHam(Ham_Weapon_PrimaryAttack, iEnt);
		set_pdata_int(iEnt, m_iClip, 0);

		set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1]);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.367);

		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id);
		write_short((1<<12) * 3);
		write_short((1<<12) * 1);
		write_short((1<<12) * 3);
		message_end();

		PunchAxis(id, -8.0, 0.0);
	}
}

public WE_Plasma(id, iEnt, iClip, iBteWpn)
{
	if (!iClip)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.5);
		return;
	}

	PunchAxis(id, random_float(-2.35, 0.0), random_float(-2.35, 2.35));

	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.0);

	set_pdata_int(iEnt, m_iClip, iClip - 1);

	SendWeaponAnim(id, random_num(3, 5));
	SendWeaponShootSound(id, FALSE, TRUE);

	set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

	new pEntity = CreateEntity(id, iBteWpn, "sprites/plasmaball.spr", c_flEntityAngle[iBteWpn], c_flEntitySpeed[iBteWpn], c_flEntityGravity[iBteWpn], MOVETYPE_FLY, ENTCLASS_PLASMA);

	engfunc(EngFunc_SetSize, pEntity, {-0.0, -0.0, -0.0} , {0.0, 0.0, 0.0});
	//set_pev(pEntity, pev_animtime, get_gametime());
	//set_pev(pEntity, pev_framerate, 1.0);
	set_pev(pEntity, pev_frame, 0.0);
	set_pev(pEntity, pev_scale, 0.1)
	set_pev(pEntity, pev_rendermode, kRenderTransAdd);
	set_pev(pEntity, pev_renderamt, 254.0);
	set_pev(pEntity, pev_nextthink, get_gametime() + 0.05);
}

public WE_M16A1(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	if (get_pdata_float(iEnt, m_flNextSecondaryAttack) > 0.0)
		return;

	static iButton;
	iButton = pev(id, pev_button);

	if (iButton & IN_ATTACK2)
	{
		new iWeaponState = get_pdata_int(iEnt, m_iWeaponState);

		if (iWeaponState & WPNSTATE_M16A1_SEMIAUTO)
		{
			ClientPrint(id, HUD_PRINTCENTER, "#Switch_To_FullAuto");
			iWeaponState &= ~WPNSTATE_M16A1_SEMIAUTO;
		}
		else
		{
			ClientPrint(id, HUD_PRINTCENTER, "#Switch_To_SemiAuto");
			iWeaponState |= WPNSTATE_M16A1_SEMIAUTO;
		}

		set_pdata_int(iEnt, m_iWeaponState, iWeaponState);
		set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.3);
	}
}

public WE_Skull11(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	if (get_pdata_float(iEnt, m_flNextSecondaryAttack) > 0.0)
		return;

	static iButton;
	iButton = pev(id, pev_button);

	if (iButton & IN_ATTACK2)
	{
		new iWeaponState = get_pdata_int(iEnt, m_iWeaponState);

		if (iWeaponState & WPNSTATE_SKULL11_SLUG)
		{
			ClientPrint(id, HUD_PRINTCENTER, "#Switch_To_Buckshot");
			iWeaponState &= ~WPNSTATE_SKULL11_SLUG;
		}
		else
		{
			ClientPrint(id, HUD_PRINTCENTER, "#Switch_To_Slug");
			iWeaponState |= WPNSTATE_SKULL11_SLUG;
		}

		set_pdata_int(iEnt, m_iWeaponState, iWeaponState);
		set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.3);
	}
}

public WE_Skull8(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	if (get_pdata_float(id, m_flNextAttack) > 0.0)
		return;

	new attcking = pev(iEnt, pev_iuser1);
	new anim = pev(iEnt, pev_iuser2);

	if (attcking)
	{
		new iCallBack = KnifeAttack2(id, TRUE, c_flDistance[iBteWpn][1], c_flAngle[iBteWpn][1], (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1], c_flKnockback[iBteWpn][4]);

		if (iCallBack == RESULT_HIT_PLAYER)
			emit_sound(id, CHAN_ITEM, "weapons/skullaxe_hit.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
		else if (iCallBack == RESULT_HIT_WORLD)
			emit_sound(id, CHAN_ITEM, "weapons/skullaxe_wall.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);

		set_pdata_float(id, m_flNextAttack, 0.92);

		set_pev(iEnt, pev_iuser1, 0);
	}

	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) > 0.0)
		return;

	static iButton;
	iButton = pev(id, pev_button);

	if ((iButton & IN_ATTACK2) && !(iButton & IN_ATTACK))
	{
		SendWeaponAnim(id, WEAPON_TOTALANIM[c_iId[iBteWpn]] + anim);

		set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.76);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.76, 4);

		set_pdata_float(id, m_flNextAttack, 0.84);

		anim = 1 - anim;
		set_pev(iEnt, pev_iuser2, anim);
		set_pev(iEnt, pev_iuser1, 1);
	}
}

public WE_M32(id, iEnt, iClip, iBteWpn)
{
	if (!iClip)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.5);

		return;
	}

	SendWeaponShootSound(id, FALSE, FALSE);

	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id);
	write_short((1<<12) * c_iShake[g_weapon[id][0]]);
	write_short((1<<12)*1);
	write_short((1<<12) * c_iShake[g_weapon[id][0]]);
	message_end()

	SendWeaponAnim(id, 2);

	set_pdata_int(iEnt, m_fInSpecialReload, 0);

	set_pdata_int(iEnt, m_iClip, iClip - 1);
	set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

	new pEntity = CreateEntity(id, iBteWpn, "models/s_grenade.mdl", c_flEntityAngle[iBteWpn], c_flEntitySpeed[iBteWpn], c_flEntityGravity[iBteWpn], MOVETYPE_BOUNCE, ENTCLASS_NADE);

	SetGreadeEntity(pEntity, iBteWpn, 2);

	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flAttackInterval[iBteWpn][0] + 1.0);

	PunchAxis(id, c_flPunchangle[iBteWpn], 0.0, c_flPunchangle[iBteWpn]);
}

public WE_PetrolBoomer(id, iEnt, iClip, iBteWpn)
{
	if (!iClip)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.5);

		return;
	}

	set_pev(id, pev_weaponanim, 1);

	set_pdata_int(iEnt, m_iClip, iClip - 1);
	set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

	new pEntity = CreateEntity(id, iBteWpn, "models/petrol.mdl", c_flEntityAngle[iBteWpn], c_flEntitySpeed[iBteWpn], c_flEntityGravity[iBteWpn], MOVETYPE_BOUNCE, ENTCLASS_PETROL);

	SetGreadeEntity(pEntity, iBteWpn, 5);

	PunchAxis(id, c_flPunchangle[iBteWpn], 0.0, 0.8);

	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.0);

	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 0, 0, FALSE, FALSE);
}

public WE_Launcher(id, iEnt, iClip, iBteWpn)
{
	if (!iClip)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.5);

		return;
	}

	SendWeaponShootSound(id, FALSE, FALSE);

	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id);
	write_short((1<<12) * c_iShake[g_weapon[id][0]]);
	write_short((1<<12)*1);
	write_short((1<<12) * c_iShake[g_weapon[id][0]]);
	message_end()

	iClip --;
	SendWeaponAnim(id, iClip ? 1 : 2);

	set_pdata_int(iEnt, m_iClip, iClip);
	set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

	new movetype = (c_iType[iBteWpn] == WEAPONS_BAZOOKA) ? MOVETYPE_FLY : MOVETYPE_BOUNCE;
	new beam = (c_iSpecial[iBteWpn] == SPECIAL_FIRECRAKER) ? 3 : 2;

	new pEntity;

	if (c_iSpecial[iBteWpn] == SPECIAL_BAZOOKA)
		pEntity = CreateEntity(id, iBteWpn, "models/s_grenade_spark.mdl", c_flEntityAngle[iBteWpn], c_flEntitySpeed[iBteWpn], c_flEntityGravity[iBteWpn], movetype, ENTCLASS_NADE);
	else
		pEntity = CreateEntity(id, iBteWpn, "models/s_grenade.mdl", c_flEntityAngle[iBteWpn], c_flEntitySpeed[iBteWpn], c_flEntityGravity[iBteWpn], movetype, ENTCLASS_NADE);

	SetGreadeEntity(pEntity, iBteWpn, beam);

	if (c_iType[iBteWpn] == WEAPONS_BAZOOKA)
		set_pev(pEntity, pev_effects, EF_LIGHT);

	PunchAxis(id, c_flPunchangle[iBteWpn], 0.0, c_flPunchangle[iBteWpn]);

	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flAttackInterval[iBteWpn][0] + 1.0);

	/*

		if (c_iSpecial[iBteWpn] == SPECIAL_AT4CS)
		{
			for(new i=1 ;i <33;i++)
			{
				if (Pub_Get_Player_Zoom(id) && i!=id && is_user_alive(i) && Stock_BTE_CheckAngle(id,i)>floatcos(9.0,degrees) && Stock_Is_Direct(id,i))
				{
					Set_Ent_Data(iProjectile,DEF_ENTSTAT,i)
					set_pev(iProjectile,pev_nextthink,get_gametime()+0.1)
					break
				}
			}
		}
	}*/
}

public WE_Firecraker(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) > 0.0)
		return;

	static iButton;
	iButton = pev(id, pev_button);

	if (!(iButton & IN_ATTACK2) || (iButton & IN_ATTACK))
		return;

	if (!iClip)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.5);

		return;
	}

	SendWeaponShootSound(id, FALSE, FALSE);
	client_cmd(id, "spk weapons/firecracker-wick.wav");

	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id);
	write_short((1<<12) * c_iShake[g_weapon[id][0]]);
	write_short((1<<12)*1);
	write_short((1<<12) * c_iShake[g_weapon[id][0]]);
	message_end()

	iClip --;
	SendWeaponAnim(id, iClip ? 1 : 2);

	set_pdata_int(iEnt, m_iClip, iClip);
	set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

	new pEntity;
	pEntity = CreateEntity(id, iBteWpn, "models/s_grenade_spark.mdl", c_flEntityAngle[iBteWpn], c_flEntitySpeed[iBteWpn], c_flEntityGravity[iBteWpn], MOVETYPE_BOUNCE, ENTCLASS_NADE);

	SetGreadeEntity(pEntity, iBteWpn, 3);

	PunchAxis(id, c_flPunchangle[iBteWpn], 0.0);

	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flAttackInterval[iBteWpn][0] + 1.0);

	set_pdata_int(pEntity, 25, 1);
}

public WE_Skull1(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	if (!Stock_Can_Attack())
		return;

	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) > 0.0)
		return;

	static iButton;
	iButton = pev(id, pev_button);

	if ((iButton & IN_ATTACK2) && !(iButton & IN_ATTACK))
	{
		if (!iClip)
			return;

		set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_SKULL1_AUTO);
		ExecuteHamB(Ham_Weapon_PrimaryAttack, iEnt);

		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id);
		write_short((1<<12) * c_iShake[g_weapon[id][0]]);
		write_short((1<<12) * 1);
		write_short((1<<12) * c_iShake[g_weapon[id][0]]);
		message_end();

		return;
	}

	set_pdata_int(iEnt, m_iWeaponState, 0);
}

public WE_SFMG(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) > 0.0)
		return;

	static iButton;
	iButton = pev(id, pev_button);

	if ((iButton & IN_ATTACK2) && !(iButton & IN_ATTACK))
	{
		new iWeaponState = get_pdata_int(iEnt, m_iWeaponState);

		if (iWeaponState & WPNSTATE_SFMG_MODEB)
		{
			SendWeaponAnim(id, 13);
			iWeaponState &= ~WPNSTATE_SFMG_MODEB;
		}
		else
		{
			SendWeaponAnim(id, 6);
			iWeaponState |= WPNSTATE_SFMG_MODEB;
		}

		set_pdata_int(iEnt, m_iWeaponState, iWeaponState);

		set_pdata_float(iEnt, m_flNextPrimaryAttack, 2.6);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, 2.6);
	}
}

public CCrossbow_Primaryattack(id, iEnt, iClip, iBteWpn)
{
	if (!iClip)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.3);

		return;
	}

	SendWeaponAnim(id, 3);
	SendWeaponShootSound(id, FALSE, TRUE);

	iClip --;
	set_pdata_int(iEnt, m_iClip, iClip);

	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

	UTIL_ScreenShake(id, c_iShake[g_weapon[id][0]], 1, c_iShake[g_weapon[id][0]]);

	new pEntity = CreateEntity(id, iBteWpn, "models/cso_bolt.mdl", c_flEntityAngle[iBteWpn], c_flEntitySpeed[iBteWpn], c_flEntityGravity[iBteWpn], MOVETYPE_BOUNCE, ENTCLASS_BOLT);
	SetEntityDelayBeam(pEntity, 4, 0.15);

	PunchAxis(id, random_float(-c_flPunchangle[iBteWpn], c_flPunchangle[iBteWpn]), random_float(-c_flPunchangle[iBteWpn], c_flPunchangle[iBteWpn]));

	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flAttackInterval[iBteWpn][0] + 1.0);
}

public WE_FlameThrower(id, iEnt, iClip, iBteWpn)
{
	if (!iClip)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0] + 0.1);

		if (pev(id, pev_weaponanim) == 1)
		{
			SendWeaponAnim(id, 2);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flIdleAnimTime[iBteWpn][1]);
		}

		return;
	}

	if (pev(id, pev_weaponanim) != 1)
		SendWeaponAnim(id, 1);

	new Float:flNextSoundPlay, bPlaySound = FALSE;
	pev(iEnt, pev_fuser1, flNextSoundPlay);

	if (flNextSoundPlay < get_gametime())
	{
		//SendWeaponShootSound(id, FALSE, FALSE);
		bPlaySound = TRUE;
		set_pev(iEnt, pev_fuser1, get_gametime() + 0.95);
	}

	iClip --;
	set_pdata_int(iEnt, m_iClip, iClip);

	set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH);

	PunchAxis(id, random_float(-c_flPunchangle[iBteWpn], c_flPunchangle[iBteWpn]), random_float(-c_flPunchangle[iBteWpn], c_flPunchangle[iBteWpn]));

	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.1);

	KnifeAttack(id, FALSE, c_flDistance[iBteWpn][0], ((!IS_ZBMODE) ? c_flDamage[iBteWpn][0] : c_flDamageZB[iBteWpn][0]), _, HITGROUP_CHEST);

	new Float:vecOrigin[3], Float:vecAngles[3];
	pev(id, pev_origin, vecOrigin);
	pev(id, pev_v_angle, vecAngles);

	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, vecOrigin, vecAngles, 0.0, 0.0, 0, 0, bPlaySound, FALSE);
}

public WE_SfPistol2(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	if (!iClip)
	{
		if (pev(id, pev_weaponanim) == 1)
		{
			SendWeaponAnim(id, 2);

			set_pdata_float(iEnt, m_flTimeWeaponIdle, 0.54);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.54);

			engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, 0, 0, TRUE, TRUE);
		}
	}
}

public WE_SfPistol(id, iEnt, iClip, iBteWpn)
{
	if (!iClip)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0] + 0.1);

		return;
	}

	new iPlaySound = 0;

	if (pev(id, pev_weaponanim) != 1)
	{
		SendWeaponAnim(id, 1);

		iPlaySound = 2;
		set_pev(iEnt, pev_fuser1, get_gametime() + 0.15);
	}

	new Float:flNextSoundPlay;
	pev(iEnt, pev_fuser1, flNextSoundPlay);

	set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

	if (flNextSoundPlay < get_gametime())
	{
		iPlaySound = 1;
		set_pev(iEnt, pev_fuser1, get_gametime() + 4.0);
	}

	iClip --;
	set_pdata_int(iEnt, m_iClip, iClip);

	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flAttackInterval[iBteWpn][0] + 0.01);

	KnifeAttack(id, FALSE, c_flDistance[iBteWpn][0], ((!IS_ZBMODE) ? c_flDamage[iBteWpn][0] : c_flDamageZB[iBteWpn][0]), _, HITGROUP_CHEST);

	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, 0.0, 0.0, iPlaySound, 0, FALSE, FALSE);
}

public WE_Svdex_2(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) > 0.0)
		return;

	static iButton;
	iButton = pev(id, pev_button);

	if (iButton & IN_ATTACK2)
	{
		new iAnim = c_iIdleAnim[iBteWpn][1] + 3;
		if (c_iDeployAnim[iBteWpn][1]) iAnim ++;

		if (get_pdata_int(iEnt, m_iWeaponState) & WPNSTATE_SVDEX_GRENADE)
		{
			set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flDoubleChange[iBteWpn][1]);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flDoubleChange[iBteWpn][1]);
			set_pdata_int(iEnt, m_iWeaponState, 0);
			SendWeaponAnim(id, iAnim + 1);
			ShowCustomCrosshair(id, FALSE);
			SetCanReload(id, TRUE);
		}
		else
		{
			set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flDoubleChange[iBteWpn][0]);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flDoubleChange[iBteWpn][1]);
			set_pdata_int(iEnt, m_iWeaponState, WPNSTATE_SVDEX_GRENADE);
			SendWeaponAnim(id, iAnim);
			ShowCustomCrosshair(id, TRUE);
			SetCanReload(id, FALSE);
		}
	}
}

public WE_Svdex(id, iEnt, iClip, iBteWpn)
{
	iClip = GetExtraAmmo(iEnt);

	if (!iClip)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.5);

		return;
	}

	iClip --;
	SendWeaponAnim(id, iClip ? c_iIdleAnim[iBteWpn][1] + 1 : c_iIdleAnim[iBteWpn][1] + 2);

	SendWeaponShootSound(id, TRUE, FALSE, iClip == 0);

	SetExtraAmmo(id, iEnt, iClip);
	set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

	CreateEntity2(id, iBteWpn);

	PunchAxis(id, c_flPunchangle[iBteWpn], 0.0);

	set_pdata_float(iEnt, m_flNextPrimaryAttack, iClip ? c_flAttackInterval[iBteWpn][1] : 1.2);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, iClip ? c_flAttackInterval[iBteWpn][1] : 1.2);
}

/*
public WE_SpearGun(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	static iButton, pEntity;
	iButton = pev(id, pev_button);
	pEntity = pev(iEnt, pev_iuser1);

	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0 && iClip)
	{
		if (iButton & IN_ATTACK && !(iButton & IN_ATTACK2))
		{
			SendWeaponAnim(id, 1);
			SendWeaponShootSound(id, FALSE, TRUE);
			set_pdata_int(iEnt, m_iClip, iClip - 1);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
			set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.03);

			new pEntity = CSpearAmmo_Create();

			if (pEntity)
			{
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
				set_pev(pEntity, pev_vuser1, vecForward);
				xs_vec_mul_scalar(vecForward, 2000.0, vecForward);
				engfunc(EngFunc_VecToAngles, vecForward, vecAngles);
				set_pev(pEntity, pev_angles, vecAngles);
				set_pev(pEntity, pev_velocity, vecForward);
				set_pev(pEntity, pev_vuser2, vecForward);
				new Float:vecAngleVelocity[3];
				pev(pEntity, pev_avelocity, vecAngleVelocity);
				vecAngleVelocity[2] = 5.0;
				set_pev(pEntity, pev_avelocity, vecAngleVelocity);
				set_pev(pEntity, pev_fuser1, get_gametime()+4.0);
				set_pev(pEntity, pev_owner, id);
			}

			set_pev(iEnt, pev_iuser1, pEntity);

			if (pev(id, pev_flags) & FL_ONGROUND)
			{
				if (GetVelocity2D(id))
					KickBack(iEnt, 15.0, 10.0, 0.225, 0.05, 6.5, 2.5, 7);
				else
				{
					if (pev(id, pev_flags) & FL_DUCKING)
						KickBack(iEnt, 4.0, 3.0, 0.125, 0.02, 5.0, 1.35, 9);
					else
						KickBack(iEnt, 10.0, 7.0, 0.22, 0.38, 5.9, 1.9, 8);
				}
			}
			else
				KickBack(iEnt, 15.0, 10.0, 0.6, 0.35, 9.0, 6.0, 5);
		}
		else if (iButton & IN_ATTACK && (iButton & IN_ATTACK2) && get_pdata_float(iEnt, m_flNextPrimaryAttack) <= 0.0)
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.1);
	}

	if (iButton & IN_ATTACK2)
	{
		if (!pev_valid(pEntity))
			return;
#if 0
		new Float:vecOrigin[3], Float:flDamage;
		new aiment = pev(pEntity, pev_aiment);

		pev(aiment?aiment:pEntity, pev_origin, vecOrigin);
#endif
#if 0
		if (!IS_ZBMODE)
			flDamage = c_flEntityDamage[iBteWpn][0];
		else
			flDamage = c_flEntityDamageZB[iBteWpn][0];

		new iHitgroup = pev(pEntity, pev_iuser1);
		
		if (!iHitgroup)
			iHitgroup = -1;
		SpearRadius(vecOrigin, pEntity, id, flDamage, c_flEntityRange[iBteWpn][0], c_flEntityKnockBack[iBteWpn], DMG_CLUB | DMG_NEVERGIB, FALSE, TRUE, iHitgroup);

		RemoveEntity(pEntity);
#endif
		CSpearAmmo_Explode(pEntity, 0.0, 0);
	}

}
*/
public WE_Balrog11(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	static iButton;
	iButton = pev(id,pev_button);

	if (!(iButton & IN_ATTACK))
		set_pev(iEnt, pev_iuser1, 0);

	if (get_pdata_float(iEnt, m_flNextSecondaryAttack) > 0.0)
		return;

	if (!(iButton & IN_ATTACK2))
		return;

	iClip = GetExtraAmmo(iEnt);

	if (!iClip)
	{
		PlayEmptySound(id);
		set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.2);

		return;
	}

	iClip --;

	SetExtraAmmo(id, iEnt, iClip);
	set_pev(id, pev_effects, pev(id, pev_effects) | EF_MUZZLEFLASH);
	OrpheuCall(handleSetAnimation, id, PLAYER_ATTACK1);

	set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][1]);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, c_flAttackInterval[iBteWpn][1]);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flShootAnimTime[iBteWpn][1]);

	set_pdata_int(iEnt, m_fInSpecialReload, FALSE);

	PunchAxis(id, -6.5, 0.0, -10.5);

	RangeAttack(id, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][0], (!IS_ZBMODE) ? c_flDamage[iBteWpn][1] : c_flDamageZB[iBteWpn][1], c_flKnockback[iBteWpn][4], DMG_NEVERGIB | DMG_EXPLOSION, TRUE, FALSE, HITGROUP_CHEST, c_flAngle[iBteWpn][1]);

	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, m_usFire[iBteWpn][0], 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, c_flDistance[iBteWpn][0], c_flAngle[iBteWpn][0], 0, 0, FALSE, TRUE);
}
