#include <amxmodx>
#include <amxmisc> 
#include <hamsandwich>
#include <fakemeta>
#include <xs>
#include "offset.inc"
#include "cdll_dll.h"
#include "BTE_GhostMode.inc"

#define PLUGIN "BTE Ghost Mode Bot Support"
#define VERSION "1.0"
#define AUTHOR "NN"

#define CHECK_INTERVAL 0.3

new Float:g_flNextCheck[33], g_iTarget[33];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_forward(FM_PlayerPostThink, "PlayerPostThink", 1);
	
	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0");
}

public PlayerPostThink(id)
{
	if (!is_user_bot(id))
		return FMRES_IGNORED;
	
	if (pev(id, pev_deadflag) != DEAD_NO)
		return FMRES_IGNORED;
	
	if (g_flNextCheck[id] > get_gametime())
		return FMRES_IGNORED;
	
	new iTeam = get_pdata_int(id, m_iTeam);
	
	if (iTeam == TEAM_TERRORIST)
		return FMRES_IGNORED;
	
	g_flNextCheck[id] > get_gametime() + CHECK_INTERVAL;
	
	new tr = create_tr2();
	PlayerTrace(id, tr);
	
	new pEntity = get_tr2(tr, TR_pHit);
	
	if (pEntity <= 32 && pEntity >= 1 && g_iTarget[id] != pEntity)
	{
		new iTeam2 = get_pdata_int(pEntity, m_iTeam);
		
		if (iTeam2 == TEAM_TERRORIST)
		{
			new Float:flFraction;
			get_tr2(tr, TR_flFraction, flFraction);
			
			new iApha = ghost_get_alpha(pEntity);
			
			if (iApha <= 5)
				SetCannotAttack(id);
			else if (iApha <= 10 && flFraction * 8196.0 >= 40.0)
				SetCannotAttack(id);
			else if (iApha <= 30 && flFraction * 8196.0 >= 300.0)
				SetCannotAttack(id);
			else
				g_iTarget[id] = pEntity;
				//g_flNextCheck[id] = get_gametime() + CHECK_INTERVAL + 0.5;
		}
	}
	else if (!pEntity)
	{
		if (g_iTarget[id])
		{
			SetCannotAttack(id);
			g_iTarget[id] = 0;
		}
	}
	
	free_tr2(tr);
	
	return FMRES_IGNORED;
}

public Event_HLTV()
{
	new null[33];
	g_iTarget = null;
}

stock SetCannotAttack(id)
{
	set_pdata_float(get_pdata_cbase(id, m_pActiveItem), m_flNextPrimaryAttack, CHECK_INTERVAL + 0.1);
	g_flNextCheck[id] = get_gametime() + CHECK_INTERVAL;
}

stock GetGunPosition(id, Float:vecScr[3])
{
	new Float:vecViewOfs[3];
	pev(id, pev_origin, vecScr);
	pev(id, pev_view_ofs, vecViewOfs);
	xs_vec_add(vecScr, vecViewOfs, vecScr);
}

stock PlayerTrace(id, tr)
{
	new Float:vecScr[3], Float:vecEnd[3], Float:v_angle[3], Float:vecForward[3];
	GetGunPosition(id, vecScr);

	pev(id, pev_v_angle, v_angle);
	engfunc(EngFunc_MakeVectors, v_angle);

	global_get(glb_v_forward, vecForward);
	xs_vec_mul_scalar(vecForward, 8196.0, vecForward);

	xs_vec_add(vecScr, vecForward, vecEnd);

	engfunc(EngFunc_TraceLine, vecScr, vecEnd, 0, id, tr);
}