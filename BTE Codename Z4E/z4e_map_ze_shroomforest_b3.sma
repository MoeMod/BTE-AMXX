#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include "z4e_alarm.inc"
#include "z4e_gameplay.inc"

#define PLUGIN "[Z4E] Map: ze_shroomforest_b3"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define TASK_MAP 10086

// 地道门 romper
// 两侧门 puerta


// 入口门 func_door 53
// 出口门 func_door 44

// 上面Found: multi_manager, firing (final
// 下面Found: multi_manager, firing (prefinal 高度-3131 
// 顶棚 func_breakable 58 高度-2650
// 门1判定范围 {-2940.0, 203.0, -16.0}  {-2358.0, 264.0, -128.0}
// 门2 3判定范围 {-2300.0, 3588.0, -289.0}  {-1024.0, 4100.0, 300.0}

// CBreakable
#define OFFSET_LINUX_BREAKABLE 4
stock m_Material = 36 // int (+4)
// FROM util.h
#define VEC_DUCK_HULL_MIN Float:{-16.0, -16.0, -18.0}
#define VEC_DUCK_HULL_MAX Float:{16.0, 16.0, 32.0}
#define VEC_DUCK_VIEW Float:{0.0, 0.0, 12.0}

enum 
{ 
	matGlass = 0, 
	matWood, 
	matMetal, 
	matFlesh, 
	matCinderBlock, 
	matCeilingTile, 
	matComputer, 
	matUnbreakableGlass, 
	matRocks, 
	matNone, 
	matLastMaterial 
}

enum MapStatus
{
	MS_DOOR1_CHECKING,
	MS_DOOR2_3_CHECKING,
	MS_DOOR4_CHECKING,
	MS_BOSS_READY,
	MS_BOSS_ATTACK,
	MS_BOSS_RUN,
	
} new MapStatus:g_iMapStatus;

new g_iBossID;

#define WALL_MODEL "models/z4e/wall1.mdl"
#define WALL_MODEL2 "models/z4e/wall2.mdl"

new g_pWall1, g_pWall2, g_pWall3

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Touch, "trigger_multiple", "HamF_TriggerMultiple_Touch")
	RegisterHam(Ham_Use, "multi_manager", "HamF_MultiManager_Use")
	RegisterHam(Ham_Touch, "func_breakable", "HamF_FuncBreakable_Touch")
	
	register_clcmd("goto", "CMD_Goto");
	register_clcmd("goto2", "CMD_Goto2");
	register_clcmd("goto3", "CMD_Goto3");
	
	g_pWall1 = CreateBox(Float:{-2560.0, 596.0, -120.0}, Float:{ 0.0, 90.0, 0.0});
	
	g_pWall2 = CreateBox2(Float:{-1050.0, 3756.0, -326.0}, Float:{ 0.0, 0.0, 0.0});
	g_pWall3 = CreateBox2(Float:{-1350.0, 3756.0, -326.0}, Float:{ 0.0, 0.0, 0.0});
}

public CreateBox(Float:vecOrigin[3], Float:vecAngles[3])
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_breakable"));
	set_pev(iEntity, pev_classname, "z4e_wall");
	
	engfunc(EngFunc_SetModel, iEntity, WALL_MODEL)
	set_pev(iEntity, pev_modelindex, engfunc(EngFunc_ModelIndex, WALL_MODEL))
	
	new Float:vecMins[3] = {-400.0, -16.0, 0.0}
	new Float:vecMaxs[3] = {400.0, 16.0, 512.0}
	engfunc(EngFunc_SetSize, iEntity, vecMins, vecMaxs)
	set_pev(iEntity, pev_angles, vecAngles)
	
	set_pev(iEntity, pev_movetype, MOVETYPE_NONE)
	set_pev(iEntity, pev_solid, SOLID_SLIDEBOX)
	
	engfunc(EngFunc_SetOrigin, iEntity, vecOrigin)
	set_pev(iEntity, pev_gravity, 0.0)
	set_pev(iEntity, pev_gamestate, 0.0)
	set_pdata_int(iEntity, m_Material, matRocks, OFFSET_LINUX_BREAKABLE)
	return iEntity;
}

public CreateBox2(Float:vecOrigin[3], Float:vecAngles[3])
{
	new iEntity = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_breakable"));
	set_pev(iEntity, pev_classname, "z4e_wall");
	
	engfunc(EngFunc_SetModel, iEntity, WALL_MODEL2)
	set_pev(iEntity, pev_modelindex, engfunc(EngFunc_ModelIndex, WALL_MODEL2))
	
	new Float:vecMins[3] = {-16.0, -256.0, 0.0}
	new Float:vecMaxs[3] = {16.0, 256.0, 512.0}
	engfunc(EngFunc_SetSize, iEntity, vecMins, vecMaxs)
	set_pev(iEntity, pev_angles, vecAngles)
	
	set_pev(iEntity, pev_movetype, MOVETYPE_NONE)
	set_pev(iEntity, pev_solid, SOLID_SLIDEBOX)
	
	engfunc(EngFunc_SetOrigin, iEntity, vecOrigin)
	set_pev(iEntity, pev_gravity, 0.0)
	set_pev(iEntity, pev_gamestate, 0.0)
	set_pdata_int(iEntity, m_Material, matWood, OFFSET_LINUX_BREAKABLE)
	return iEntity;
}

public CMD_Goto(id)
{
	set_pev(id, pev_origin, {1024.0,110.0, -106.0})
}

public CMD_Goto2(id)
{
	set_pev(id, pev_origin, {-2542.0,398.0, -106.0})
}

public CMD_Goto3(id)
{
	set_pev(id, pev_origin, {-1200.0,3735.0, -250.0})
}

public plugin_precache()
{
	new szMap[32];
	get_mapname(szMap, 31)
	if(!equali(szMap, "ze_shroomforest_b3")) // equali比较字符串不区分大小写
	{
		pause("a")
		return;
	}
	
	precache_model(WALL_MODEL);
	precache_model(WALL_MODEL2);
}

public plugin_cfg()
{
	z4e_fw_gameplay_round_new();
}

public z4e_fw_gameplay_round_new()
{
	remove_task(TASK_MAP);
	g_iMapStatus = MS_DOOR1_CHECKING;
	g_iBossID = 0;
	
	z4e_alarm_push(_, "** 地图: 幻菇森境 ** 插件：小白白 **", "难度：未定义", "", { 50,250,50 }, 2.0);
	/*
	new pEntity
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "target", "final"))))
	{
		new szClassname[32];
		pev(pEntity, pev_classname, szClassname, 31);
		client_print(0, print_chat, szClassname);
	}*/
	
	ResetWall(g_pWall1);
	ResetWall(g_pWall2);
	ResetWall(g_pWall3);
	set_pev(g_pWall1, pev_angles, { 0.0, 90.0, 0.0});
	
	new pEntity
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_breakable"))))
	{
		if(pev(pEntity, pev_modelindex) == 42 || pev(pEntity, pev_modelindex) == 43)
		{
			set_pev(pEntity, pev_spawnflags, pev(pEntity, pev_spawnflags) | SF_BREAK_TRIGGER_ONLY);
			set_pev(pEntity, pev_takedamage, DAMAGE_NO);
		}
	}
}

public HamF_FuncBreakable_Touch(this, id)
{
	if(!is_user_alive(id))
		return HAM_IGNORED
	
	if(pev(this, pev_modelindex) == 42 || pev(this, pev_modelindex) == 43)
	{
		set_pev(this, pev_takedamage, DAMAGE_YES)
		ExecuteHamB(Ham_TakeDamage, this, id, id, 5.0, DMG_BULLET)
		
		return HAM_SUPERCEDE
	}
	return HAM_IGNORED
}

ResetWall(pEntity)
{
	set_pev(pEntity, pev_deadflag, DEAD_NO);
	set_pev(pEntity, pev_effects, 0);
	set_pev(pEntity, pev_solid, SOLID_BBOX);
}

public z4e_fw_gameplay_timer()
{
	static Float:vecOrigin[3];
	if(g_iMapStatus == MS_DOOR1_CHECKING)
	{
		for(new i=1;i<33;i++)
		{
			if(!is_user_alive(i))
				continue;
			
			pev(i, pev_origin, vecOrigin);

			if(CheckPointIn(vecOrigin, Float:{-2940.0, 260.0, -128.0}, Float:{-2358.0, 563.0, -16.0}))
			{
				g_iMapStatus = MS_DOOR2_3_CHECKING;
				
				z4e_alarm_timertip(30, "砖墙爆破中…… ");
				set_task(30.0, "Task_Door1", TASK_MAP);
				
				break;
			}
		}
	}
	else if(g_iMapStatus == MS_DOOR2_3_CHECKING)
	{
		for(new i=1;i<33;i++)
		{
			if(!is_user_alive(i))
				continue;
			
			pev(i, pev_origin, vecOrigin);
			
			if(CheckPointIn(vecOrigin, Float:{-2300.0, 3588.0, -289.0}, Float:{-1024.0, 4100.0, 300.0}))
			{
				g_iMapStatus = MS_DOOR4_CHECKING;
				
				z4e_alarm_timertip(45, "木门开启中…… ");
				set_task(45.0, "Task_Door2_3", TASK_MAP);
				
				break;
			}
		}
	}
}

public Task_Door1()
{
	ExecuteHamB(Ham_Use, g_pWall1, 0, 0, 0, 0.0);
	z4e_alarm_insert(_, "砖墙已爆破！", "", "", { 250,250,50 }, 2.0);
}

public Task_Door2_3()
{
	ExecuteHamB(Ham_Use, g_pWall2, 0, 0, 0, 0.0);
	ExecuteHamB(Ham_Use, g_pWall3, 0, 0, 0, 0.0);
	z4e_alarm_insert(_, "木门已开启！", "", "", { 250,250,50 }, 2.0);
}

public HamF_TriggerMultiple_Touch(this, id)
{
	if(!pev_valid(this))
		return HAM_IGNORED
	
	new Float:flNextThink;
	pev(this, pev_nextthink, flNextThink);
	if(get_gametime() < flNextThink)
		return HAM_IGNORED;
	
	new szTarget[32];
	pev(this, pev_target, szTarget, 31);
	
	if(equal(szTarget, "final"))
	{
		z4e_alarm_timertip(15, "等待中…… ");
	}
	
	return HAM_IGNORED;
}

public HamF_MultiManager_Use(this, caller, activator, use_type)
{
	if(!pev_valid(this))
		return HAM_IGNORED
	new szTargetName[32];
	pev(this, pev_targetname, szTargetName, 31);
	
	if(equal(szTargetName, "final"))
	{
		//z4e_alarm_insert(_, "地下入口已开启！", "", "", { 250,250,50 }, 2.0);
		//g_iMapStatus = MS_BOSS_READY;
		
		new Float:vecOrigin[3]
		for(new i=1;i<33;i++)
		{
			if(!is_user_alive(i))
				continue;
			
			pev(i, pev_origin, vecOrigin);
			
			if(!CheckPointIn(vecOrigin, Float:{622.0, -660.0, -120.0}, Float:{1140.0, 150.0, 0.0}))
			{
				user_kill(i);
			}
		}
	}
	return HAM_IGNORED;
}

stock CheckPointIn(const Float:vecOrigin[3], const Float:vecMins[3], const Float:vecMaxs[3])
{
	if(vecOrigin[0] < vecMins[0] || vecOrigin[0] > vecMaxs[0])
		return 0;
	if(vecOrigin[1] < vecMins[1] || vecOrigin[1] > vecMaxs[1])
		return 0;
	if(vecOrigin[2] < vecMins[2] || vecOrigin[2] > vecMaxs[2])
		return 0;
	return 1;
}