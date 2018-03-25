#include "bte/BTE_Delay_Knives.sma"
#include "bte/weapons/skullaxe.sma"
#include "bte/weapons/sfsword.sma"
#include "bte/weapons/knife.sma"
#include "bte/weapons/balrog9.sma"
#include "bte/weapons/hammer.sma"
#include "bte/weapons/katana.sma"
#include "bte/weapons/jknife.sma"
#include "bte/weapons/dragonsword.sma"
#include "bte/weapons/stormgiant.sma"
#include "bte/weapons/runeblade.sma"
#include "bte/weapons/thanatos9.sma"
#include "bte/weapons/janus9.sma"
#include "bte/weapons/crow9.sma"
#include "bte/weapons/dualsword.sma"

//#define KNIFE_ATTACK_AFTER_HOLSTER

public CKnife_PrimaryAttack(iEnt)
{
	static id, iBteWpn;
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	iBteWpn = g_weapon[id][0];

	if (bte_get_user_zombie(id) == 1)
		return HAM_IGNORED;

	if (c_iSpecial[iBteWpn] == SPECIAL_SKULLAXE)
		SkullAxe_PrimaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_DRAGONSWORD)
		DragonSword_PrimaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_SFSWORD)
		SfSword_PrimaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_STORMGIANT)
		StormGiant_PrimaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_RUNEBLADE)
		Runeblade_PrimaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_THANATOS9)
		Thanatos9_PrimaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUS9)
		Janus9_PrimaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_CROW9)
		Crow9_PrimaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_DUALSWORD)
		DualSword_PrimaryAttack(id, iEnt, iBteWpn);
	else
		Melee_PrimaryAttack(id, iEnt, iBteWpn);

	return HAM_SUPERCEDE;
}

public CKnife_Holster(iEnt)
{
	static id, iBteWpn;
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	iBteWpn = g_weapon[id][0];
	if (c_iSpecial[iBteWpn] == SPECIAL_STORMGIANT)
		StormGiant_Holster(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_RUNEBLADE)
		Runeblade_Holster(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_THANATOS9)
		Thanatos9_Holster(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUS9)
		Janus9_Holster(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_CROW9)
		Crow9_Holster(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_DUALSWORD)
		DualSword_Holster(id, iEnt, iBteWpn);
}

public CKnife_SecondaryAttack(iEnt)
{
	static id, iBteWpn;
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	iBteWpn = g_weapon[id][0];

	if (bte_get_user_zombie(id) == 1)
		return HAM_IGNORED;

	if (c_iSpecial[iBteWpn] == SPECIAL_SKULLAXE)
		SkullAxe_SecondaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_DRAGONSWORD)
		DragonSword_SecondaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_SFSWORD)
		SfSword_SecondaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_STORMGIANT)
		StormGiant_SecondaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_RUNEBLADE)
		Runeblade_SecondaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_THANATOS9)
		Thanatos9_SecondaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_JANUS9)
		Janus9_SecondaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_CROW9)
		Crow9_SecondaryAttack(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_DUALSWORD)
		DualSword_SecondaryAttack(id, iEnt, iBteWpn);
	else
		Melee_SecondaryAttack(id, iEnt, iBteWpn);
	return HAM_SUPERCEDE;
}

public CKnife_PostFrame(iEnt)
{
	static id, iBteWpn;
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	iBteWpn = g_weapon[id][0];

	if (c_iSpecial[iBteWpn] == SPECIAL_SFSWORD)
		return SfSword_PostFrame(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_RUNEBLADE)
		return Runeblade_ItemPostFrame(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_THANATOS9)
		return Thanatos9_ItemPostFrame(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_CROW9)
		return Crow9_ItemPostFrame(id, iEnt, iBteWpn);
	else if (c_iSpecial[iBteWpn] == SPECIAL_DUALSWORD)
		return DualSword_ItemPostFrame(id, iEnt, iBteWpn);
	return HAM_IGNORED;
}

public CKnife_WeaponIdle(iEnt)
{
	static id, iBteWpn;
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	iBteWpn = g_weapon[id][0];

	if (c_iSpecial[iBteWpn] == SPECIAL_DUALSWORD)
	{
		DualSword_WeaponIdle(id, iEnt, iBteWpn);
		return HAM_SUPERCEDE;
	}
}