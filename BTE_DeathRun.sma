#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <amxmisc>
#include <metahook>
#include <BTE_API>
#define PRINT(%1) client_print(1,print_chat,%1)
#define SPRINT(%1) server_print(%1)
#define BP_MAX	10
#define SP_MAX	10
#define SP2_MAX	20
#define SPAWNS_FILE "%s/bte/dr/dr_%s.bte"
#define TASK_SHOWSTARTBOX	1000
#define pev_group pev_euser2
#define pev_type  pev_iuser3
#pragma loadlib semiclip
new const snd_start[]="bte/dr/cm_start.wav"
new const snd_check[]="bte/dr/cm_check.wav"
new const snd_goal[]="bte/dr/cm_goal.wav"
new const snd_down[]="bte/dr/cm_down.wav"
enum TYPE(+=100)
{
	TYPE_START=100,
	TYPE_END,
	TYPE_BREAKPOINT,
	TYPE_BACKPOINT
}
new ISCREATE
new iLastEnt
new Float:g_Pos_Start[3],Float:g_Pos_End[3],Float:g_Bp[BP_MAX+1][3]
new g_Pos_Start_Ang,g_Pos_End_Ang
new g_BpIndex,g_BpAngle[BP_MAX+1],Float:g_Bk_Point[3],g_Bk_Angle
new g_BpGroup[BP_MAX+1]
new g_SpIndex,Float:g_SpSet[SP_MAX][3],g_SpNum[SP_MAX],Float:g_SpOrigin[SP_MAX][SP2_MAX][3]
new Float:g_CanBack[33]

new spr_dot
// Edit
new Float:g_Edit_Pos_Start[3],Float:g_Edit_Pos_End[3],Float:g_Edit_Bp[BP_MAX+1][3]
new g_Edit_Pos_Start_Ang,g_Edit_Pos_End_Ang
new g_Edit_BpIndex,g_Edit_BpAngle[BP_MAX+1],Float:g_Edit_Bk_Point[3],g_Edit_Bk_Angle
new g_Edit_SpIndex=0,g_Edit_SpNum[SP_MAX],Float:g_Edit_SpOrigin[SP_MAX][SP2_MAX][3]
new g_Edit_CurrentPos,g_Edit_GroupCurrent,g_Edit_Group[BP_MAX+1]
// Timer
new Float:g_StartTime[33]
new Float:g_UsedTime[33]={999.0,...}

// Hooked Set Origin
new Float:g_Hook_Origin[SP_MAX][3]
new Float:g_Record_Time[20] = {999.0,...}
public AddHookOrigin(id)
{
	new Float:vOrigin[3]
	pev(id,pev_origin,vOrigin)
	xs_vec_copy(vOrigin,g_Edit_SpOrigin[g_Edit_CurrentPos][g_Edit_SpNum[g_Edit_CurrentPos]])
	g_Edit_SpNum[g_Edit_CurrentPos] ++
	PRINT("%L",LANG_PLAYER,"BTE_DR_SPAWNPOINT_SAVED")
}
enum POINT_SECTION
{
	SECTION_ZERO = 0,
	SECTION_START,
	SECTION_END,
	SECTION_BREAKPOINT,
	SECTION_SPAWNPOINT,
	SECTION_BACKPOINT
}
public plugin_init()
{
	register_concmd("bte_dr","bte_kz")
	register_logevent("LogEvent_Round_Start",2, "1=Round_Start")
	register_dictionary("bte_other.bte")
	register_forward(FM_SetOrigin, "Forward_SetOrigin")
	register_logevent("LogEvent_Round_Start",2, "1=Round_Start")
	RegisterHam(Ham_Touch, "info_target", "HamF_InfoTarget_Touch")
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage")
	RegisterHam(Ham_Spawn, "player", "HamF_PlayerSpawn_Post", 1)
	RegisterHam(Ham_Killed, "player", "HamF_Killed", 1)
	register_forward(FM_ClientKill, "Forward_ClientKill")
}
public HamF_Killed(id, idattacker, shouldgib)
{
	if(0<id<33)
	{
		set_task(3.0,"Check_Respawn",id+9998)
	}
}
public Forward_ClientKill(id)
{
	return FMRES_SUPERCEDE
}
public HamF_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(0<victim<33 && attacker<33)
	{
		return HAM_SUPERCEDE
	}
	return HAM_SUPERCEDE
}
public LogEvent_Round_Start()
{
	server_cmd("sv_noroundend 1")
	Stock_PlaySound(0,"music/ze_start.mp3")
	for(new i =1;i<33;i++)
	{
		if(is_user_connected(i))
		{
			if(!task_exists(i+998)) set_task(240.0, "Task_PlayMp3", 998 + i, _, _, "b")
		}
	}
}	
stock Stock_PlaySound(id, const sound[])
{
	if (equal(sound[strlen(sound)-4], ".mp3"))
	{
		client_cmd(id,"mp3 stop")
		client_cmd(id, "mp3 play sound/%s", sound)
	}
	else
		client_cmd(id, "spk %s", sound)
}
public Strip_Weapon(id)
{
	if(is_user_alive(id))
	{
		fm_strip_user_gun(id)
		if(get_user_weapon(id)!=29) bte_wpn_give_named_wpn(id,"knife")
	}
}		
public HamF_PlayerSpawn_Post(id)
{
	if (!is_user_alive(id)) return
	set_task(0.2,"Strip_Weapon",id)
}
public client_putinserver(id)
{
	set_task(3.0,"SendMod",id)
	set_task(1.0,"Check_Respawn",id+9998)
}
public Check_Respawn(idx)
{
	
	new id = idx-9998
	if(!is_user_connected(id)) return
	new team = get_user_team(id)
	if(!is_user_alive(id) && (team == 1|| team == 2 ))
	{
		ExecuteHamB(Ham_CS_RoundRespawn,id)
		return
	}
	set_task(1.0,"Check_Respawn",idx)
}		
public client_connect(id)
{
	if(is_user_bot(id))
	{
		new name[32]
		get_user_name(id,name,31)
		server_cmd("kick %s",name)
	}
}
public SendMod(id)
{
	MH_SendClientModRunning(id,9)
}
public Task_PlayMp3(idx)
{
	new id=idx-998
	Stock_PlaySound(id,"music/ze_start.mp3")
}		
public plugin_precache()
{
	spr_dot = precache_model("sprites/dot.spr")
	new cfgdir[32], mapname[32], filepath[100], linedata[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), SPAWNS_FILE, cfgdir, mapname)
	if(file_exists(filepath))
	{
		LoadPoint()
		CreateEntity()
		SPRINT("===LOAD===")
		ISCREATE = 0
	}
	else 
	{
		SPRINT("===NEW===")
		ISCREATE = 1
	}
}
stock CheckVectorEqual(Float:v1[3],Float:v2[3])
{
	new Float:fDis = vector_distance(v1,v2)
	if(fDis < 20.0 ) return 1
	else return 0
}

public SpawnAtThisPosition(id,iPos)
{
	// Get Max Spawn Point
	new iMax = g_SpNum[iPos]
	static hull, sp_index, i
	// Get whether the player is crouching
	hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN	
	sp_index = random_num(0, iMax)
	for (i = sp_index + 1; /*no condition*/; i++)
	{
		if (i >= iMax) i = 0
		if (is_hull_vacant(g_SpOrigin[iPos][i], hull))
		{
			engfunc(EngFunc_SetOrigin, id, g_SpOrigin[iPos][i])
			break;
		}
		if (i == sp_index) break;
	}
}
stock is_hull_vacant(Float:origin[3], hull)
{
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0)
	
	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}
public Forward_SetOrigin(id,Float:vOrigin[3])
{
	// First Check All Hooked Origin
	if(!is_user_alive(id)) return FMRES_IGNORED
	
	if(ISCREATE) // BUILD MODE
	{
		for(new i = 0;i<=g_Edit_SpIndex;i++)
		{
			if(CheckVectorEqual(g_Hook_Origin[i],vOrigin)) 
			{
				g_Edit_CurrentPos = i
				SpawnAtThisPosition(id,i)
				return FMRES_IGNORED
			}
		}
		xs_vec_copy(vOrigin,g_Hook_Origin[g_Edit_SpIndex])	
		g_Edit_SpIndex ++
		g_Edit_CurrentPos = (g_Edit_SpIndex-1)
		return FMRES_IGNORED
	}
	else
	{
		for(new i=1;i<=g_SpIndex;i++)
		{
			if(CheckVectorEqual(g_SpSet[i],vOrigin))
			{
				SpawnAtThisPosition(id,i)
				return FMRES_SUPERCEDE
			}
		}
		return FMRES_IGNORED		
	}
}
new g_Touched_Entity[33][100]
new g_iLastTouch[33]
new Float:g_Touched_EntityTime[33][100]
new Float:g_TouchedTimeRecord[33][100]
new Float:g_Touched_LastTime[33]
public HamF_InfoTarget_Touch(iPtr,iPtd)
{
	static iType,iGroup
	new sMessage[128]
	iType = pev(iPtr,pev_type)
	iGroup = pev(iPtr,pev_group)
	if(iPtd>32 || iPtd<1) return HAM_IGNORED
	if(!is_user_alive(iPtd)) return HAM_IGNORED
	if(iType)
	{
		if(iType == TYPE_START)
		{
			if(g_Touched_Entity[iPtd][iPtr])
			{
			}
			else
			{
				format(sMessage,127,"%L",LANG_PLAYER,"BTE_DR_START")
				Stock_PlaySound(iPtd, snd_start)
				MH_DrawFontText(iPtd,sMessage,1,0.5,0.3,237,182,65,32,5.0,1.0,1,2)
				MH_SpecialEvent(iPtd,2)
				g_Touched_Entity[iPtd][iPtr] = 1
				g_Touched_EntityTime[iPtd][iPtr] = get_gametime()
				g_iLastTouch[iPtd] = iPtr
				g_Touched_LastTime[iPtd] = get_gametime()
				g_StartTime[iPtd] = get_gametime()
			}
		}
		else if(iType == TYPE_BREAKPOINT)
		{
			if(g_Touched_Entity[iPtd][iPtr])
			{
			}
			else
			{
				g_Touched_Entity[iPtd][iPtr] = 1
				new sTime[64],sMsg[128]
				if(!g_TouchedTimeRecord[iPtd][iGroup])
				{
					Stock_PlaySound(iPtd, snd_check)
					g_TouchedTimeRecord[iPtd][iGroup] = get_gametime() - g_Touched_LastTime[iPtd]
					MakeRecord(iGroup)
					new Float:fDelta2 = g_TouchedTimeRecord[iPtd][iGroup]  - g_Record_Time[iGroup];
					FormatTime(fDelta2,sTime)
					format(sMsg,127,"%L",LANG_PLAYER,"BTE_DR_COMP_RECORD",sTime)
					MH_DrawFontText(iPtd,sMsg,1,0.5,0.3,237,182,65,32,5.0,1.0,1,2)
				}
			}
		}
		else if(iType == TYPE_END)
		{
			if(g_Touched_Entity[iPtd][iPtr])
			{
			}
			else
			{
				format(sMessage,127,"%L",LANG_PLAYER,"BTE_DR_END")
				Stock_PlaySound(iPtd, snd_goal)
				MH_DrawFontText(iPtd,sMessage,1,0.5,0.3,237,182,65,32,5.0,1.0,1,2)
				MH_SpecialEvent(iPtd,3)
				g_Touched_Entity[iPtd][iPtr] = 1
				g_Touched_EntityTime[iPtd][iPtr] = get_gametime()
				g_iLastTouch[iPtd] = iPtr
				g_Touched_LastTime[iPtd] = get_gametime()
				if(g_UsedTime[iPtd]>get_gametime() - g_StartTime[iPtd])
				{
					g_UsedTime[iPtd] =  get_gametime() - g_StartTime[iPtd]
				}
				SendRank()
				bte_fun_process_data(iPtd,2)
			}
		}
		else if(iType == TYPE_BACKPOINT)
		{
			if(g_Touched_Entity[iPtd][iPtr])
			{
			}
			else
			{
				MH_SpecialEvent(iPtd,4)
				g_Touched_Entity[iPtd][iPtr] = 1
				g_Touched_EntityTime[iPtd][iPtr] = get_gametime()
				g_iLastTouch[iPtd] = iPtr
				g_Touched_LastTime[iPtd] = get_gametime()
				set_task(0.1,"Task_Back",iPtd)
			}
		}		
	}
	return HAM_IGNORED
}
public MakeRecord(iGroup)
{
	for(new i=1;i<33;i++)
	{
		if(g_TouchedTimeRecord[i][iGroup] && (g_TouchedTimeRecord[i][iGroup]<g_Record_Time[iGroup]))
		{
			g_Record_Time[iGroup] = g_TouchedTimeRecord[i][iGroup]
		}
	}
}
public Task_Back(id)
{
	// Back to origin
	Forward_SetOrigin(id,g_SpSet[1])
	set_task(0.1,"Task_Reset",id)
}

public Task_Reset(id)
{
	for(new i =0;i<100;i++)
	{
		g_Touched_Entity[id][i] = 0
		g_Touched_EntityTime[id][i] = 0
		for(new j=0;j<=g_BpGroup[g_BpIndex];j++)
		{
			g_TouchedTimeRecord[id][j] = 0
		}
	}
	g_Touched_LastTime[id] = 0
	g_iLastTouch[id] = 0		
}
public FormatTime(Float:fDelta,sTimeOut[])
{
	new iSeconds = floatround(fDelta,floatround_floor);
	new iMinutes = iSeconds / 60;
	iSeconds = iSeconds - 60*iMinutes
	new Float:fMilSec = (fDelta - floatround(fDelta,floatround_floor)) * 100;
	new MilSec = floatround(fMilSec)
	new sTemp[128]
	
	format(sTemp,charsmax(sTemp),"%02d:%02d:%02d",iMinutes,iSeconds,MilSec)
/*
	if(iMinutes == 0)
	{
		format(sTemp,charsmax(sTemp),"00:")
	}
	else if(iMinutes < 10)
	{
		format(sTemp,charsmax(sTemp),"0%d:",iMinutes)
	}
	else format(sTemp,charsmax(sTemp),"%d:",iMinutes)

	if(iSeconds == 0)
	{
		format(sTemp,charsmax(sTemp),"%s00:",sTemp)
	}
	else if(iSeconds < 10)
	{
		format(sTemp,charsmax(sTemp),"%s0%d:",sTemp,iSeconds)
	}
	else format(sTemp,charsmax(sTemp),"%s%d:",sTemp,iSeconds)
	
	if(MilSec == 0)
	{
		format(sTemp,charsmax(sTemp),"%s00",sTemp)
	}
	else if(MilSec < 10)
	{
		format(sTemp,charsmax(sTimeOut),"%s0%d",sTemp,MilSec)
	}
	else format(sTemp,charsmax(sTemp),"%s%d",sTemp,MilSec)*/
	copy(sTimeOut,charsmax(sTimeOut),sTemp)
}
public bte_kz(id)
{
	new title[64],item_name[10][256]
	if(ISCREATE) format(title, charsmax(title), "%L",LANG_PLAYER,"BTE_DR_MENU_TITLE_BUILD")
	else format(title, charsmax(title), "%L",LANG_PLAYER,"BTE_DR_MENU_TITLE_NOTBUILD")
	format(item_name[1], 255, "%L",LANG_PLAYER,"BTE_DR_MENU_CREATE_START",g_Edit_Pos_Start_Ang,floatround(g_Edit_Pos_Start[0]),floatround(g_Edit_Pos_Start[1]),floatround(g_Edit_Pos_Start[2]))
	format(item_name[2], 255, "%L",LANG_PLAYER,"BTE_DR_MENU_CREATE_END",g_Edit_Pos_End_Ang,floatround(g_Edit_Pos_End[0]),floatround(g_Edit_Pos_End[1]),floatround(g_Edit_Pos_End[2]))
	format(item_name[3], 255, "%L",LANG_PLAYER,"BTE_DR_MENU_CREATE_BREAKPOINT",g_Edit_BpIndex,g_Edit_GroupCurrent)
	format(item_name[4], 255, "%L",LANG_PLAYER,"BTE_DR_MENU_CREATE_SPAWNPOINT",g_Edit_CurrentPos,g_Edit_SpNum[g_Edit_CurrentPos])
	format(item_name[5], 255, "%L",LANG_PLAYER,"BTE_DR_MENU_CREATE_BACKPOINT",g_Edit_Bk_Angle,floatround(g_Edit_Bk_Point[0]),floatround(g_Edit_Bk_Point[1]),floatround(g_Edit_Bk_Point[2]))
	format(item_name[6], 255, "%L",LANG_PLAYER,"BTE_DR_MENU_ADD_BREAKPOINT")
	format(item_name[7], 255, "%L",LANG_PLAYER,"BTE_DR_MENU_SAVE")
	new iTime = floatround(g_CanBack[id] -get_gametime())
	format(item_name[8], 255, "%L",LANG_PLAYER,"BTE_DR_MENU_BACK_START",iTime>0?iTime:0)
	new mHandleID = menu_create(title, "menu_wpn_handler2")
	if(ISCREATE)
	{
		menu_additem(mHandleID, item_name[1], "1", 0)
		menu_additem(mHandleID, item_name[2], "2", 0)
		menu_additem(mHandleID, item_name[3], "3", 0)
		menu_additem(mHandleID, item_name[4], "4", 0)
		menu_additem(mHandleID, item_name[5], "5", 0)
		menu_additem(mHandleID, item_name[6], "6", 0)
		menu_additem(mHandleID, item_name[7], "7", 0)	
	}
	else menu_additem(mHandleID, item_name[8], "8", 0)	
	menu_display(id, mHandleID, 0)
}
SavePoint()
{
	new cfgdir[32], mapname[32], filepath[100], linedata[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), SPAWNS_FILE, cfgdir, mapname)
	
	if (file_exists(filepath)) delete_file(filepath)
	new g_file = fopen(filepath, "a")
	
	fprintf(g_file,";Generated By BTE_DeathRun Plugin^n")
	fprintf(g_file,"[START]^n")
	fprintf(g_file,"%d,%d,%d,%d^n",g_Edit_Pos_Start_Ang,floatround(g_Edit_Pos_Start[0]),floatround(g_Edit_Pos_Start[1]),floatround(g_Edit_Pos_Start[2]))
	fprintf(g_file,"[END]^n")
	fprintf(g_file,"%d,%d,%d,%d^n",g_Edit_Pos_End_Ang,floatround(g_Edit_Pos_End[0]),floatround(g_Edit_Pos_End[1]),floatround(g_Edit_Pos_End[2]))
	fprintf(g_file,"[BREAKPOINT]^n")
	for(new i=1;i<=g_Edit_BpIndex;i++)
	{
		formatex(linedata,63,"WALL_%d=%d,%d,%d,%d,%d^n",i,g_Edit_BpAngle[i],floatround(g_Edit_Bp[i][0]),floatround(g_Edit_Bp[i][1]),floatround(g_Edit_Bp[i][2]),g_Edit_Group[i])
		fprintf(g_file,linedata)	
	}
	fprintf(g_file,"[SPAWNPOINT]^n")
	for(new i=0;i<g_Edit_SpIndex;i++)
	{
		fprintf(g_file,"A^n")
		fprintf(g_file,"%d,%d,%d^n",floatround(g_Hook_Origin[i][0]),floatround(g_Hook_Origin[i][1]),floatround(g_Hook_Origin[i][2]))
		fprintf(g_file,"B^n")
		for(new j=0;j<g_Edit_SpNum[i];j++)
		{
			fprintf(g_file,"%d,%d,%d^n",floatround(g_Edit_SpOrigin[i][j][0]),floatround(g_Edit_SpOrigin[i][j][1]),floatround(g_Edit_SpOrigin[i][j][2]))
		}
	}
	fprintf(g_file,"[BACKPOINT]^n")
	fprintf(g_file,"%d,%d,%d,%d^n",g_Edit_Bk_Angle,floatround(g_Edit_Bk_Point[0]),floatround(g_Edit_Bk_Point[1]),floatround(g_Edit_Bk_Point[2]))
	fclose(g_file)
}
	
public menu_wpn_handler2(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new cmdbuy[32], name[32], access
	new title[64],item_name[32][32]
	menu_item_getinfo(menu, item, access, cmdbuy, 31, name, 31, access)
	menu_destroy(menu)
	if(equal(cmdbuy,"1"))
	{
		new Float:vOrigin[3],Float:vAngle[3]
		pev(id,pev_origin,vOrigin)
		pev(id,pev_angles,vAngle)
		new Float:fLength = 500.0
		new Float:mins[3] = { 0, 0, -100.0 }
		new Float:maxs[3] = {0, 0, 100.0 }
		xs_vec_copy(vOrigin,g_Edit_Pos_Start)
		g_Edit_Pos_Start_Ang = GetAngle(vAngle)
		if(g_Edit_Pos_Start_Ang == 90 || g_Edit_Pos_Start_Ang == -90)
		{
			mins[0] = -fLength
			maxs[0] = fLength
			mins[1] = -10.0
			maxs[1] = 10.0
		}
		else
		{
			mins[1] = -fLength
			maxs[1] = fLength
			mins[0] = -10.0
			maxs[0] = 10.0
		}
		CreateBox(vOrigin,mins,maxs)
	}
	if(equal(cmdbuy,"2"))
	{
		new Float:vOrigin[3],Float:vAngle[3]
		pev(id,pev_origin,vOrigin)
		pev(id,pev_angles,vAngle)
		new Float:fLength = 500.0
		new Float:mins[3] = { 0, 0, -100.0 }
		new Float:maxs[3] = {0, 0, 100.0 }
		xs_vec_copy(vOrigin,g_Edit_Pos_End)
		g_Edit_Pos_End_Ang = GetAngle(vAngle)
		if(g_Edit_Pos_End_Ang == 90 || g_Edit_Pos_End_Ang == -90)
		{
			mins[0] = -fLength
			maxs[0] = fLength
			mins[1] = -10.0
			maxs[1] = 10.0
		}
		else
		{
			mins[1] = -fLength
			maxs[1] = fLength
			mins[0] = -10.0
			maxs[0] = 10.0
		}
		CreateBox(vOrigin,mins,maxs)
	}
	if(equal(cmdbuy,"5"))
	{
		new Float:vOrigin[3],Float:vAngle[3]
		pev(id,pev_origin,vOrigin)
		pev(id,pev_angles,vAngle)
		new Float:fLength = 500.0
		new Float:mins[3] = { 0, 0, -100.0 }
		new Float:maxs[3] = {0, 0, 100.0 }
		xs_vec_copy(vOrigin,g_Edit_Bk_Point)
		g_Edit_Bk_Angle = GetAngle(vAngle)
		if(g_Edit_Bk_Angle == 90 || g_Edit_Bk_Angle == -90)
		{
			mins[0] = -fLength
			maxs[0] = fLength
			mins[1] = -10.0
			maxs[1] = 10.0
		}
		else
		{
			mins[1] = -fLength
			maxs[1] = fLength
			mins[0] = -10.0
			maxs[0] = 10.0
		}
		CreateBox(vOrigin,mins,maxs)
	}
	if(equal(cmdbuy,"3"))
	{
		g_Edit_BpIndex ++
		new Float:vOrigin[3],Float:vAngle[3]
		pev(id,pev_origin,vOrigin)
		pev(id,pev_angles,vAngle)
		new Float:fLength = 500.0
		new Float:mins[3] = { 0, 0, -100.0 }
		new Float:maxs[3] = {0, 0, 100.0 }
		xs_vec_copy(vOrigin,g_Edit_Bp[g_Edit_BpIndex])
		g_Edit_BpAngle[g_Edit_BpIndex] = GetAngle(vAngle)
		g_Edit_Group[g_Edit_BpIndex] = g_Edit_GroupCurrent
		if(g_Edit_BpAngle[g_Edit_BpIndex] == 90 || g_Edit_BpAngle[g_Edit_BpIndex] == -90)
		{
			mins[0] = -fLength
			maxs[0] = fLength
			mins[1] = -10.0
			maxs[1] = 10.0
		}
		else
		{
			mins[1] = -fLength
			maxs[1] = fLength
			mins[0] = -10.0
			maxs[0] = 10.0
		}
		CreateBox(vOrigin,mins,maxs)
	}
	if(equal(cmdbuy,"4"))
	{
		AddHookOrigin(id)
	}
	if(equal(cmdbuy,"7"))
	{
		SavePoint()
	}
	if(equal(cmdbuy,"6"))
	{
		g_Edit_GroupCurrent++
	}
	if(equal(cmdbuy,"8"))
	{
		new iTime = floatround(g_CanBack[id] -get_gametime())
		if(iTime>0)
		{
			client_print(id,print_chat,"%L",LANG_PLAYER,"BTE_DR_MSG_CANOT_GOBACK",iTime)
			return
		}
		g_CanBack[id] = get_gametime()+30
		set_task(0.1,"Task_Back",id)
	}
}
stock GetAngle(Float:v[3])
{
	new iAng = floatround(v[1])
	if(-120<iAng<-70)
	{
		iAng = -90
	}
	else if(-20<iAng<20)
	{
		iAng = 0
	}
	else if(iAng<-160)
	{
		iAng = -180
	}
	else if(70<iAng<120)
	{
		iAng = 90
	}
	else if(iAng>160)
	{
		iAng = 180
	}
	else iAng = -90
	return iAng
}		
stock fm_entity_set_origin(index, const Float:origin[3]) {
	new Float:mins[3], Float:maxs[3]
	pev(index, pev_mins, mins)
	pev(index, pev_maxs, maxs)
	engfunc(EngFunc_SetSize, index, mins, maxs)

	return engfunc(EngFunc_SetOrigin, index, origin)
}
public SendRank()
{
	static Float:fTime[33]
	static ID[33]
	//Copy Timer
	for(new i =1;i<33;i++) 
	{
		fTime[i] = g_UsedTime[i]
		ID[i] = i
	}
	// Make CurrentRank
	new Float:fTemp,fTemp2
	new  i,j,n=33;
	for(i=1;i<n-1;i++) 
	{
		for(j=i+1;j<n;j++)
		{
			if(fTime[i]> fTime[j])
			{
				fTemp=fTime[i];
				fTemp2 = ID[i]
				fTime[i]=fTime[j]; 
				ID[i] = ID[j]
				fTime[j]=fTemp; 
				ID[j]=fTemp2; 
			}
		}
	}
	// Send Rank
	new sSend[32]
	for(new i = 1;i<4;i++)
	{
		if(fTime[i]&& fTime[i]<800.0)
		{
			FormatTime(fTime[i],sSend)
			MH_SendDRRank(0,i,ID[i],sSend)
		}
		else 
		{
			MH_SendDRRank(0,i,0,"")
		}
	}
}
LoadPoint()
{
	new cfgdir[32], mapname[32], filepath[100], linedata[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), SPAWNS_FILE, cfgdir, mapname)
	
	if (file_exists(filepath))
	{
		new file = fopen(filepath,"rt")
		new iSection = 0
		
		while (file && !feof(file))
		{
			fgets(file, linedata, charsmax(linedata))
			replace(linedata, charsmax(linedata), "^n", "")
			new csdmdata[5][8]			
			if(!linedata[0] || linedata[0] == ';') continue;
			if (linedata[0] == '[')
			{
				iSection++
				continue;
			}
			switch (iSection)
			{
				case SECTION_START:
				{
					replace_all(linedata, charsmax(linedata), ",", " ")
					parse(linedata,csdmdata[0],7,csdmdata[1],7,csdmdata[2],7,csdmdata[3],7)
					g_Pos_Start_Ang = str_to_num(csdmdata[0])
					g_Pos_Start[0] = str_to_float(csdmdata[1])
					g_Pos_Start[1] = str_to_float(csdmdata[2])
					g_Pos_Start[2] = str_to_float(csdmdata[3])
				}
				case SECTION_END:
				{
					replace_all(linedata, charsmax(linedata), ",", " ")
					parse(linedata,csdmdata[0],7,csdmdata[1],7,csdmdata[2],7,csdmdata[3],7)
					g_Pos_End_Ang = str_to_num(csdmdata[0])
					g_Pos_End[0] = str_to_float(csdmdata[1])
					g_Pos_End[1] = str_to_float(csdmdata[2])
					g_Pos_End[2] = str_to_float(csdmdata[3])
				}
				case SECTION_BREAKPOINT:
				{
					new key[8],value[256]
					strtok(linedata, key, charsmax(key), value, charsmax(value), '=')
					replace_all(key, charsmax(key), "WALL_", "")
					g_BpIndex = str_to_num(key)
					
					replace_all(value, charsmax(value), ",", " ")
					parse(value,csdmdata[0],7,csdmdata[1],7,csdmdata[2],7,csdmdata[3],7,csdmdata[4],7)
					g_BpAngle[g_BpIndex] = str_to_num(csdmdata[0])
					g_Bp[g_BpIndex][0] = str_to_float(csdmdata[1])
					g_Bp[g_BpIndex][1] = str_to_float(csdmdata[2])
					g_Bp[g_BpIndex][2] = str_to_float(csdmdata[3])
					g_BpGroup[g_BpIndex] = str_to_num(csdmdata[4])
				}
				case SECTION_BACKPOINT:
				{
					replace_all(linedata, charsmax(linedata), ",", " ")
					parse(linedata,csdmdata[0],7,csdmdata[1],7,csdmdata[2],7,csdmdata[3],7)
					g_Bk_Angle = str_to_num(csdmdata[0])
					g_Bk_Point[0] = str_to_float(csdmdata[1])
					g_Bk_Point[1] = str_to_float(csdmdata[2])
					g_Bk_Point[2] = str_to_float(csdmdata[3])
				}
				case SECTION_SPAWNPOINT:
				{
					static iPart
					if(linedata[0]=='A') 
					{
						iPart = 1
						g_SpIndex++
						continue
					}
					else if(linedata[0]=='B')
					{
						iPart = 2
						continue
					}
					if(iPart == 1)
					{
						replace_all(linedata, charsmax(linedata), ",", " ")
						parse(linedata,csdmdata[0],7,csdmdata[1],7,csdmdata[2],7)
						g_SpSet[g_SpIndex][0] = str_to_float(csdmdata[0])
						g_SpSet[g_SpIndex][1] = str_to_float(csdmdata[1])
						g_SpSet[g_SpIndex][2] = str_to_float(csdmdata[2])
					}
					else if(iPart == 2)
					{
						replace_all(linedata, charsmax(linedata), ",", " ")
						parse(linedata,csdmdata[0],7,csdmdata[1],7,csdmdata[2],7)
						g_SpOrigin[g_SpIndex][g_SpNum[g_SpIndex]][0] = str_to_float(csdmdata[0])
						g_SpOrigin[g_SpIndex][g_SpNum[g_SpIndex]][1] = str_to_float(csdmdata[1])
						g_SpOrigin[g_SpIndex][g_SpNum[g_SpIndex]][2] = str_to_float(csdmdata[2])
						g_SpNum[g_SpIndex] ++
					}
				}
			}
		}
		if (file) fclose(file)
	}
}
CreateEntity()
{
	// Create START POINT
	CreateTypeEntity(TYPE_START,g_Pos_Start_Ang,g_Pos_Start)
	// Create END POINT
	CreateTypeEntity(TYPE_END,g_Pos_End_Ang,g_Pos_End)
	// Create BACK POINT
	CreateTypeEntity(TYPE_BACKPOINT,g_Bk_Angle,g_Bk_Point)
	// Create BREAKPOINT
	for(new i = 1;i<=g_BpIndex;i++)
	{
		CreateTypeEntity(TYPE_BREAKPOINT,g_BpAngle[i],g_Bp[i],g_BpGroup[i])
	}
}
stock CreateTypeEntity(iType,iAngle,Float:vOrigin[3],Group=0)
{
	new Float:fLength = (iType == TYPE_BREAKPOINT)?200.0:500.0
	new Float:mins[3] = { 0, 0, -100.0 }
	new Float:maxs[3] = {0, 0, 100.0 }
	if(iAngle == 90 || iAngle == -90)
	{
		mins[0] = -fLength
		maxs[0] = fLength
		mins[1] = -10.0
		maxs[1] = 10.0
	}
	else
	{
		mins[1] = -fLength
		maxs[1] = fLength
		mins[0] = -10.0
		maxs[0] = 10.0
	}
	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(iEnt, pev_classname, "bte_kz")		
	fm_entity_set_origin(iEnt,vOrigin)
	set_pev(iEnt, pev_movetype, MOVETYPE_FLY)
	set_pev(iEnt, pev_solid, SOLID_TRIGGER)
	set_pev(iEnt,pev_type,iType)
	set_pev(iEnt,pev_group,Group)
	engfunc(EngFunc_SetSize,iEnt, mins, maxs)
	return iEnt
	
}
public CreateBox(Float:pos[3],Float:mins[3],Float:maxs[3])
{
	mins[0] += pos[0]
	mins[1] += pos[1]
	mins[2] += pos[2]
	maxs[0] += pos[0]
	maxs[1] += pos[1]
	maxs[2] += pos[2]
	
	new color[3]
	color[0] = 255
	color[1] = 50
	color[2] = 50

	DrawLine(maxs[0], maxs[1], maxs[2], mins[0], maxs[1], maxs[2], color)
	DrawLine(maxs[0], maxs[1], maxs[2], maxs[0], mins[1], maxs[2], color)
	DrawLine(maxs[0], maxs[1], maxs[2], maxs[0], maxs[1], mins[2], color)
	DrawLine(mins[0], mins[1], mins[2], maxs[0], mins[1], mins[2], color)
	DrawLine(mins[0], mins[1], mins[2], mins[0], maxs[1], mins[2], color)
	DrawLine(mins[0], mins[1], mins[2], mins[0], mins[1], maxs[2], color)
	DrawLine(mins[0], maxs[1], maxs[2], mins[0], maxs[1], mins[2], color)
	DrawLine(mins[0], maxs[1], mins[2], maxs[0], maxs[1], mins[2], color)
	DrawLine(maxs[0], maxs[1], mins[2], maxs[0], mins[1], mins[2], color)
	DrawLine(maxs[0], mins[1], mins[2], maxs[0], mins[1], maxs[2], color)
	DrawLine(maxs[0], mins[1], maxs[2], mins[0], mins[1], maxs[2], color)
	DrawLine(mins[0], mins[1], maxs[2], mins[0], maxs[1], maxs[2], color)
}
public DrawLine(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2, color[3]) 
{
	new start[3]
	new stop[3]
		
	start[0] = floatround( x1 )
	start[1] = floatround( y1 )
	start[2] = floatround( z1 )
		
	stop[0] = floatround( x2 )
	stop[1] = floatround( y2 )
	stop[2] = floatround( z2 )
	
	FX_Line(start, stop, color, 200)
}
public FX_Line(start[3], stop[3], color[3], brightness) 
{
	message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, 1) 
	
	write_byte( TE_BEAMPOINTS ) 
	
	write_coord(start[0]) 
	write_coord(start[1])
	write_coord(start[2])
	
	write_coord(stop[0])
	write_coord(stop[1])
	write_coord(stop[2])
	
	write_short( spr_dot )
	
	write_byte( 1 )	// framestart 
	write_byte( 1 )	// framerate 
	write_byte( 200 )	// life in 0.1's 
	write_byte( 5 )	// width
	write_byte( 0 ) 	// noise 
	
	write_byte( color[0] )   // r, g, b 
	write_byte( color[1] )   // r, g, b 
	write_byte( color[2] )   // r, g, b 
	
	write_byte( brightness )  	// brightness 
	write_byte( 0 )   	// speed 
	
	message_end() 
}
stock bool:fm_strip_user_gun(index, wid = 0, const wname[] = "")
{
	new ent_class[32];
	if (!wid && wname[0])
		copy(ent_class, sizeof ent_class - 1, wname);
	else {
		new weapon = wid, clip, ammo;
		if (!weapon && !(weapon = get_user_weapon(index, clip, ammo)))
			return false;
		
		get_weaponname(weapon, ent_class, sizeof ent_class - 1);
	}
	
	new ent_weap = fm_find_ent_by_owner(-1, ent_class, index);
	if (!ent_weap)
		return false;
	
	engclient_cmd(index, "drop", ent_class);
	
	new ent_box = pev(ent_weap, pev_owner);
	if (!ent_box || ent_box == index)
		return false;
	
	dllfunc(DLLFunc_Think, ent_box);
	
	return true;
}
stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0)
{
	new strtype[11] = "classname", ent = index;
	switch (jghgtype) {
		case 1: strtype = "target";
		case 2: strtype = "targetname";
	}
	
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}
	
	return ent;
}