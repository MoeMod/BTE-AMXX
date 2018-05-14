#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include "z4e_bits.inc"
#include "z4e_team.inc"

#define PLUGIN "[Z4E] Building"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai->Moe"

// Building (Thanks to BaseBuilder by Tirant)
#define BUILD_DELAY 0.75
#define BUILD_PUSHPULLRATE 4.0
#define BUILD_ROTATERATE 2.5
#define BUILD_MAXDIST 720.0
#define BUILD_MINDIST 30.0
#define BUILD_SETDIST 64.0

#define MovingEnt(%1)		 ( set_pev(%1, pev_iuser4, 1) )
#define UnmovingEnt(%1)	   ( set_pev(%1, pev_iuser4, 0) )
#define IsMovingEnt(%1)	   ( pev(%1, pev_iuser4) == 1)

#define SetEntMover(%1,%2)	  ( set_pev( %1, pev_iuser3, %2) )
#define UnsetEntMover(%1)	   ( set_pev( %1, pev_iuser3, 0) )
#define GetEntMover(%1)	   ( pev( %1, pev_iuser3) )

#define GHOST_MAXSPEED 300.0
#define GHOST_GRAVITY 0.3
#define GHOST_SPAWN_MINRADIUS 300.0
new const cfg_iColorEntSelect[3] = { 90, 90, 90 }
new const cfg_iColorEntMoving[3] = { 90, 190, 90 }
new const cfg_iColorEntChecking[3] = { 190, 190, 90 }
new const cfg_iColorEntStucked[3] = { 190, 90, 90 }
new const Float:cfg_flColorEntMoving[3] = { 90.0, 190.0, 90.0 }

#define HUD_ALARM_X -1.0
#define HUD_ALARM_Y 0.30

#define TASK_BUILDEND 198328
#define TASK_TIMER 998998

new g_bitsCanBuild
new g_bitsBuilding, g_pPointingTarget[33]
new Float:g_vecOffset[33][3]
new Float:g_flBuildDistance[33]
new Float:g_fBuildDelay[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink")
	register_forward(FM_TraceLine, "fw_TraceLine", 1)
	register_forward(FM_AddToFullPack, "fw_AddToFullPack_Post", 1)
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	//register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	
	RegisterHam(Ham_Touch, "func_wall", "fw_BuildWallTouch")
	
	// Build Entities
	//ResetEntity()
	
	g_bitsCanBuild = 0;
}

public plugin_precache()
{

}

public plugin_natives()
{
	register_native("z4e_building_set_can_build", "Native_SetPlayerCanBuild", 1)
	register_native("z4e_building_set_can_build", "Native_GetPlayerCanBuild", 1)
	register_native("z4e_building_set_entity", "Native_SetEntityBuilding", 1)
	register_native("z4e_building_set_entity", "Native_GetEntityBuilding", 1)
}

public Native_SetPlayerCanBuild(id, bSet)
{
	if(bSet)
		BitsSet(g_bitsCanBuild, id)
	else
		Reset_Player(id)
}

public Native_GetPlayerCanBuild(id)
{
	return !!BitsGet(g_bitsCanBuild, id)
}

public Native_SetEntityBuilding(pEntity, bSet)
{
	set_pev(pEntity, pev_iuser2, bSet ? 998:0);
	set_pev(pEntity, pev_iuser4, 0);
	set_pev(pEntity, pev_rendermode,kRenderNormal);
	engfunc(EngFunc_SetOrigin, pEntity, Float:{ 0.0, 0.0, 0.0 });
	for(new i=0;i<33;i++)
	{
		if(g_pPointingTarget[i] == pEntity)
			Build_End(i);
	}
}

public Native_GetEntityBuilding(pEntity)
{
	return pev(pEntity, pev_iuser2);
}

public Event_NewRound()
{
	//ResetEntity()
}

public Reset_Player(id)
{
	BitsUnSet(g_bitsCanBuild, id);
	
	Build_End(id)
}

public client_disconnect(id)
{
	Reset_Player(id)
}

public fw_CmdStart(id, uc_handle, seed)
{
	static bitsCurButton; bitsCurButton = get_uc(uc_handle, UC_Buttons)
	static bitsOldButton; bitsOldButton = pev(id, pev_oldbuttons)
	
	if(BitsGet(g_bitsBuilding, id))
	{
		if (bitsCurButton & IN_ATTACK)
		{
			g_flBuildDistance[id] += BUILD_PUSHPULLRATE;
			if (g_flBuildDistance[id] > BUILD_MAXDIST)
			{
				g_flBuildDistance[id] = BUILD_MAXDIST
			}
			bitsCurButton &= ~IN_ATTACK;
		}
		else if (bitsCurButton & IN_ATTACK2)
		{
			g_flBuildDistance[id] -= BUILD_PUSHPULLRATE;
			if (g_flBuildDistance[id] < BUILD_SETDIST)
			{
				g_flBuildDistance[id] = BUILD_SETDIST
			}
			bitsCurButton &= ~IN_ATTACK2;
		}
		set_uc(uc_handle, UC_Buttons, bitsCurButton)
	}
	
	if(bitsCurButton & ~bitsOldButton & IN_USE)
	{
		Build_Start(id)
	}
	else if(BitsGet(g_bitsBuilding, id) && !(bitsCurButton & IN_USE))
	{
		Build_End(id)
	}
}   

public fw_TraceLine( Float:v1[3], Float:v2[3], noMonsters, pentToSkip )
{
	new id = pentToSkip;
	if(!is_user_alive(id)) 
		return;
	
	if(!BitsGet(g_bitsCanBuild, id))
		return;
	if(BitsGet(g_bitsBuilding, id))
		return;

	new iEntity = get_tr(TR_pHit)
	
	// 旧的目标失效
	if(!pev_valid(g_pPointingTarget[id]))
	{
		g_pPointingTarget[id] = 0;
	}
	
	// 更换了目标
	if(iEntity != g_pPointingTarget[id])
	{
		if(FCanEntityBuilt(iEntity))
		{
			g_pPointingTarget[id] = iEntity;
		}
			
	}
	
	return;
}

FCanEntityBuilt(iEntity)
{
	if(!pev_valid(iEntity) || is_user_alive(iEntity) || IsMovingEnt(iEntity))
		return 0;
			
	if (!pev(iEntity, pev_iuser2))
		return 0;
	
	return 1;
}

public fw_PlayerPostThink(id)
{
	Build_Check_Moving(id)
}

public fw_AddToFullPack_Post(es_handle, e, iEntity, host, hostflags, player, pset)
{
	if(!is_user_connected(host))
		return
	
	if(iEntity == g_pPointingTarget[host])
	{
		if(BitsGet(g_bitsBuilding, host))
		{
			if(get_es(es_handle, ES_Solid) == SOLID_NOT)
			{
				set_es(es_handle, ES_RenderMode, kRenderTransColor)
				set_es(es_handle, ES_RenderAmt, 125)
				set_es(es_handle, ES_RenderFx, kRenderFxGlowShell)
				set_es(es_handle, ES_RenderColor, cfg_iColorEntMoving)
			}
			else if(get_es(es_handle, ES_Solid) == SOLID_BBOX)
			{
				set_es(es_handle, ES_RenderMode, kRenderTransColor)
				set_es(es_handle, ES_RenderAmt, 125)
				set_es(es_handle, ES_RenderFx, kRenderFxGlowShell)
				set_es(es_handle, ES_RenderColor, cfg_iColorEntChecking)
			}
			else if(get_es(es_handle, ES_Solid) == SOLID_SLIDEBOX)
			{
				set_es(es_handle, ES_RenderMode, kRenderTransColor)
				set_es(es_handle, ES_RenderAmt, 125)
				set_es(es_handle, ES_RenderFx, kRenderFxGlowShell)
				set_es(es_handle, ES_RenderColor, cfg_iColorEntStucked)
			}
		}
		else
		{
			set_es(es_handle, ES_RenderMode, kRenderTransColor)
			set_es(es_handle, ES_RenderAmt, 125)
			set_es(es_handle, ES_RenderFx, kRenderFxGlowShell)
			set_es(es_handle, ES_RenderColor,  cfg_iColorEntSelect)
		}
	}
}

Build_Check_Moving(id)
{
	if (!BitsGet(g_bitsCanBuild, id) || !is_user_alive(id))
	{
		Build_End(id)
		return PLUGIN_HANDLED
	}
	
	if(!BitsGet(g_bitsBuilding, id))
		return PLUGIN_HANDLED
	
	static Float:vecOrigin[3]; pev(g_pPointingTarget[id], pev_origin, vecOrigin)
	static Float:vecAngles[3]; pev(g_pPointingTarget[id], pev_angles, vecAngles)
	
	new iOrigin[3], iLook[3], Float:fOrigin[3], Float:fLook[3], Float:fLength
		
	get_user_origin(id, iOrigin, 1);
	IVecFVec(iOrigin, fOrigin);
	get_user_origin(id, iLook, 3);
	IVecFVec(iLook, fLook);
		
	fLength = get_distance_f(fLook, fOrigin);
	if (fLength == 0.0) fLength = 1.0;
	
	vecOrigin[0] = (fOrigin[0] + (fLook[0] - fOrigin[0]) * g_flBuildDistance[id] / fLength);
	vecOrigin[1] = (fOrigin[1] + (fLook[1] - fOrigin[1]) * g_flBuildDistance[id] / fLength);
	vecOrigin[2] = (fOrigin[2] + (fLook[2] - fOrigin[2]) * g_flBuildDistance[id] / fLength);
	vecOrigin[2] = float(floatround(vecOrigin[2], floatround_floor));
	xs_vec_add(vecOrigin, g_vecOffset[id], vecOrigin)
	
	if(pev(g_pPointingTarget[id], pev_solid) == SOLID_SLIDEBOX)
	{
		static Float:vecPos[3]; pev(g_pPointingTarget[id], pev_origin, vecPos)
		if(vector_distance(vecOrigin, vecPos) < 30.0)
		{
			return PLUGIN_CONTINUE
		}
		set_pev(g_pPointingTarget[id], pev_solid, SOLID_BBOX)
	}
	
	engfunc(EngFunc_SetOrigin, g_pPointingTarget[id], vecOrigin)
	set_pev(g_pPointingTarget[id], pev_angles, vecAngles)
	
	return PLUGIN_CONTINUE
}

Build_Start(id)
{
	if(!is_user_alive(id) || !BitsGet(g_bitsCanBuild, id))
		return PLUGIN_HANDLED;
	if(g_fBuildDelay[id] > get_gametime())
		return PLUGIN_HANDLED;
	else
		g_fBuildDelay[id] = get_gametime() + BUILD_DELAY
	
	static Float:vecStart[3], Float:vecViewOfs[3]
	pev(id, pev_origin, vecStart)
	pev(id, pev_view_ofs, vecViewOfs)
	xs_vec_add(vecStart, vecViewOfs, vecStart)

	static Float:vecViewAngle[3], Float:vecEnd[3]
	pev(id, pev_v_angle, vecViewAngle)
	engfunc(EngFunc_MakeVectors, vecViewAngle)
	global_get(glb_v_forward, vecEnd)
	xs_vec_mul_scalar(vecEnd, BUILD_MAXDIST, vecEnd)
	xs_vec_add(vecStart, vecEnd, vecEnd)

	new ptr = create_tr2()
	engfunc(EngFunc_TraceLine, vecStart, vecEnd, 0, id, ptr)
	
	static Float:vecEndPos[3], Float:flFraction
	get_tr2(ptr, TR_vecEndPos, vecEndPos)
	get_tr2(ptr, TR_flFraction, flFraction)
	if(flFraction >= 1.0) 
		engfunc(EngFunc_TraceHull, vecStart, vecEnd, 0, HULL_HEAD, id, ptr)
	new iEntity = get_tr2(ptr, TR_pHit)
	free_tr2(ptr)
	
		
	if(!pev_valid(iEntity) || is_user_alive(iEntity) || IsMovingEnt(iEntity))
		return PLUGIN_HANDLED;
	if (!pev(iEntity, pev_iuser2))
		return PLUGIN_HANDLED;
	
	new Float:vecOrigin[3]
	pev(iEntity, pev_origin, vecOrigin)
		
	xs_vec_sub(vecOrigin, vecEndPos, g_vecOffset[id])
	
	g_flBuildDistance[id] = get_distance_f(vecStart, vecEndPos)
	
	if (g_flBuildDistance[id] < BUILD_MINDIST)
		g_flBuildDistance[id] = BUILD_SETDIST;
	
	MovingEnt(iEntity);
	SetEntMover(iEntity, id);
	BitsSet(g_bitsBuilding, id)
	g_pPointingTarget[id] = iEntity
	
	set_pev(iEntity, pev_solid, SOLID_BBOX)
	set_pev(iEntity, pev_movetype, MOVETYPE_FLY)
	
	set_pev(iEntity,pev_rendermode, kRenderTransColor)
	set_pev(iEntity,pev_renderfx, kRenderFxGlowShell)
	set_pev(iEntity,pev_rendercolor, cfg_flColorEntMoving)
	set_pev(iEntity,pev_renderamt, 125.0)
	return PLUGIN_CONTINUE;
}

Build_End(id)
{
	if(!BitsGet(g_bitsBuilding, id))
		return PLUGIN_HANDLED
	
	new iEntity = g_pPointingTarget[id]
	
	new Float:vecAngles[3]
	pev(iEntity, pev_angles, vecAngles)
	dllfunc(DLLFunc_Spawn, iEntity)
	set_pev(iEntity, pev_angles, vecAngles)
	
	fm_set_rendering(iEntity)
	
	BitsUnSet(g_bitsBuilding, id);
	UnsetEntMover(iEntity);
	g_pPointingTarget[id] = 0;
	UnmovingEnt(iEntity);
	
	return PLUGIN_CONTINUE;
}

public fw_BuildWallTouch(iEntity, pHit)
{
	if(pev(iEntity, pev_solid) != SOLID_BBOX || !IsMovingEnt(iEntity))
		return
	set_pev(iEntity, pev_solid, SOLID_SLIDEBOX)
	set_pev(iEntity, pev_fuser1, get_gametime() + 0.3)
}
/*
ResetEntity()
{
	new iEntBarrier = fm_find_ent_by_tname( -1, "barrier" );
	fm_remove_entity(iEntBarrier);
	new pEntity = -1
	
	while((pEntity = fm_find_ent_by_class(pEntity, "func_wall")) && pev_valid(pEntity))
	{
		if(!pev(pEntity, pev_iuser2))
		{
			static Float:vecMins[3]; pev(pEntity, pev_mins, vecMins)
			static Float:vecMaxs[3]; pev(pEntity, pev_maxs, vecMaxs)
			set_pev(pEntity, pev_vuser3, vecMins)
			set_pev(pEntity, pev_vuser4, vecMaxs)
			static Float:flSquare[3]
			flSquare[0] = floatabs(vecMaxs[0] - vecMins[0]) * floatabs(vecMaxs[1] - vecMins[1])
			flSquare[1] = floatabs(vecMaxs[2] - vecMins[2]) * floatabs(vecMaxs[1] - vecMins[1])
			flSquare[2] = floatabs(vecMaxs[0] - vecMins[0]) * floatabs(vecMaxs[2] - vecMins[2])
			if(flSquare[0] > 100000.0 || flSquare[1] > 100000.0 || flSquare[2] > 100000.0)
			{
				continue;
			}
			//SetPenetrationToGhost(pEntity, true)
			set_pev(pEntity, pev_iuser2, 998);
			set_pev(pEntity, pev_rendermode,kRenderNormal)
			engfunc(EngFunc_SetOrigin, pEntity, Float:{ 0.0, 0.0, 0.0 });
			UnsetEntMover(pEntity);
		}
	}
	pEntity = -1
}
*/
/*
stock GetNewOrigin(const Float:vecAngles[3], const Float:B[3], Float:vecOut[3])
{
	// 转矩阵，表示新坐标系与旧坐标系的关系
	new Float:A[3][3];
	angle_vector(vecAngles, 1, A[0]);
	angle_vector(vecAngles, 2, A[1]);
	angle_vector(vecAngles, 3, A[2]);
	//AngleMatrix(vecAngles, A)
	
	// 解线性方程组AX=B
	
	// 先算A的逆矩阵A^(-1)
	new Float:A2[3][3];
	if(!MatrixInverse3(A, A2))
	{
		xs_vec_copy(B, vecOut)
		return;
	}
		
	// 然后算X=A^(-1) * B
	MatrixProductVector3(A2, B, vecOut);
}

// 欧拉角转矩阵
stock AngleMatrix(const Float:in[3], Float:out[3][3])
{
	new Float:cx, Float:sx, Float:cy, Float:sy, Float:cz, Float:sz;
	new Float:yx, Float:yy;

	cx = floatcos(in[0]);
	sx = floatsin(in[0]);
	cy = floatcos(in[1]);
	sy = floatsin(in[1]);
	cz = floatcos(in[2]);
	sz = floatsin(in[2]);

	yx = sy*cx;
	yy = sy*sx;
	
	out[0][0] =  cy*cz;
	out[0][1] = -cy*sz;
	out[0][2] =	 sy;

	out[1][0] =  yy*cz+cx*sz;
	out[1][1] = -yy*sz+cx*cz;
	out[1][2] = -sx;

	out[2][0] = -yx*cz+sx*sz;
	out[2][1] =  yx*sz+sx*cz;
	out[2][2] =  cx*cy;
}

// 三阶矩阵乘法
stock MatrixProduct3(const Float:in1[3][3], const Float:in2[3][3], Float:out[3][3])
{
	out[0][0] = in1[0][0]*in2[0][0] + in1[0][1]*in2[1][0] + in1[0][2]*in2[2][0];
	out[0][1] = in1[0][0]*in2[0][1] + in1[0][1]*in2[1][1] + in1[0][2]*in2[2][1];
	out[0][2] = in1[0][0]*in2[0][2] + in1[0][1]*in2[1][2] + in1[0][2]*in2[2][2];

	out[1][0] = in1[1][0]*in2[0][0] + in1[1][1]*in2[1][0] + in1[1][2]*in2[2][0];
	out[1][1] = in1[1][0]*in2[0][1] + in1[1][1]*in2[1][1] + in1[1][2]*in2[2][1];
	out[1][2] = in1[1][0]*in2[0][2] + in1[1][1]*in2[1][2] + in1[1][2]*in2[2][2];

	out[2][0] = in1[2][0]*in2[0][0] + in1[2][1]*in2[1][0] + in1[2][2]*in2[2][0];
	out[2][1] = in1[2][0]*in2[0][1] + in1[2][1]*in2[1][1] + in1[2][2]*in2[2][1];
	out[2][2] = in1[2][0]*in2[0][2] + in1[2][1]*in2[1][2] + in1[2][2]*in2[2][2];
}

// 向量乘三阶矩阵
stock MatrixProductVector3(const Float:in1[3][3], const Float:in2[3], Float:out[3])
{
	for(new i=0;i<3;i++)
		out[i] = in1[0][i] * in2[0] + in1[1][i] * in2[1] + in1[2][i] * in2[2];
}

// 算二阶行列式
stock Float:MatrixDet2(const Float:x[2][2])
{
	return x[0][0]*x[1][1] - x[0][1]*x[1][0];
}

// 算三阶行列式
stock Float:MatrixDet3(const Float:x[3][3])
{
	new Float:a = x[0][0] * ( x[1][1]*x[2][2] - x[1][2] * x[2][1])
	new Float:b = x[0][1] * ( x[1][2]*x[2][0] - x[1][0] * x[2][2])
	new Float:c = x[0][2] * ( x[2][1]*x[1][0] - x[1][1] * x[2][0])
	return a+b+c;
}

// 算三阶矩阵的代数余子式
stock Float:MatrixCofactor3(const Float:in[3][3], x, y)
{
	new Float:A[2][2];
	
	new m=-1
	for(new i=0;i<3;i++)
	{
		if(i==x)
		{
			continue;
		}
		else
		{
			m++;
		}
		
		new n=-1;
		for(new j=0;j<3;j++)
		{
			if(j==y)
			{
				continue;
			}
			else
			{
				n++;
			}
			
			A[m][n] = in[i][j];
		}
	}
	if((x+y) & 1)
		return -MatrixDet2(A);
	return MatrixDet2(A);
}

// 算三阶矩阵的逆矩阵
stock MatrixInverse3(const Float:in[3][3], Float:out[3][3])
{
	new Float:det = MatrixDet3(in);
	// 行列式为0的矩阵没有逆矩阵
	if(!det) return 0;
	
	// 算伴随矩阵后除以行列式
	for(new i=0;i<3;i++)
		for(new j=0;j<3;j++)
		{
			out[i][j] = MatrixCofactor3(in, i, j);
			out[i][j] /= det;
		}
			
		
	return 1;
}*/