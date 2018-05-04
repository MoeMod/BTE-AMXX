
#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <orpheu>

#include "z4e_bits.inc"
#include "z4e_alarm.inc"
#include "z4e_team.inc"
#include "z4e_gameplay.inc"
#include "z4e_freeze.inc"
#include "z4e_building.inc"

#define PLUGIN "[Z4E] Map: ze_bb_purity"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

enum
{
	TS_AT_TOP,
	TS_AT_BOTTOM,
	TS_GOING_UP,
	TS_GOING_DOWN
}

enum MapStatus
{
	MS_NONE,
	MS_BUILD1_PREPARE,
	MS_BUILD1_BUILDING,
	MS_BUILD1_ENTER,
	MS_BUILD1_ATTACK,
	MS_BUILD1_RUN,
	MS_BUILD2_PREPARE,
	MS_BUILD2_BUILDING,
	MS_BUILD2_ENTER,
	MS_BUILD2_ATTACK,
	MS_BUILD2_RUN,
	MS_END,
	
} new MapStatus:g_iMapStatus;

new g_bitsMapRecord;

new OrpheuFunction:g_handleDoorGoDown;

#define TASK_MAP 23333

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Use, "func_button", "fw_UseButton")
	RegisterHam(Ham_Use, "func_door", "fw_UseDoor")
	RegisterHam(Ham_Touch, "trigger_hurt", "fw_Touch")
	
	g_handleDoorGoDown = OrpheuGetFunction("DoorGoDown", "CBaseDoor");
	OrpheuRegisterHook(g_handleDoorGoDown, "OnDoorGoDown");
	OrpheuRegisterHook(OrpheuGetFunction("DoorHitTop", "CBaseDoor"), "OnDoorHitTop");
	
	register_clcmd("goto", "CMD_Goto")
}

public OrpheuHookReturn:OnDoorGoDown(this)
{
	new szTargetName[32];
	pev(this, pev_targetname, szTargetName, 31);
	if(!strcmp(szTargetName, "zone1_exit") || !strcmp(szTargetName, "zone2_exit"))
		return OrpheuSupercede;
	if(!strcmp(szTargetName, "zone1_entrance") || !strcmp(szTargetName, "zone2_entrance"))
		return OrpheuSupercede;
	return OrpheuIgnored;
}

public CMD_Goto(id)
{
	set_pev(id, pev_origin, {-1281.0,-757.0, -200.0})
}

public plugin_precache()
{
	new szMap[32];
	get_mapname(szMap, 31)
	if(!equali(szMap, "ze_bb_purity")) // equali比较字符串不区分大小写
	{
		pause("a")
		return;
	}
}

public plugin_cfg()
{
	z4e_fw_gameplay_round_new();
}

public z4e_fw_team_set_post(id, iTeam)
{
	z4e_building_set_can_build(id, 0);
}

public z4e_fw_gameplay_round_new()
{
	remove_task(TASK_MAP);
	g_iMapStatus = MS_NONE;
	
	//z4e_alarm_push(_, "** 地图: 黑白印象 ** 地图: 小白白的男朋友 **", "难度：****", "", { 50,250,50 }, 2.0);
	
	new pEntity = -1
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_door"))))
	{
		ExecuteHamB(Ham_SetToggleState, pEntity, TS_AT_BOTTOM);
	}
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_button"))))
	{
		ExecuteHamB(Ham_Spawn, pEntity)
	}
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "func_rotating"))))
	{
		ExecuteHamB(Ham_Spawn, pEntity)
	}
	
	while(pev_valid((pEntity = fm_find_ent_by_tname(pEntity, "zone1_exit"))))
	{
		new bitsSpawnFlags = pev(pEntity, pev_spawnflags)
		set_pev(pEntity, pev_spawnflags, bitsSpawnFlags | SF_DOOR_NO_AUTO_RETURN)
		ExecuteHamB(Ham_SetToggleState, pEntity, TS_AT_TOP);
	}
	
	while(pev_valid((pEntity = fm_find_ent_by_tname(pEntity, "zone2_exit"))))
	{
		new bitsSpawnFlags = pev(pEntity, pev_spawnflags)
		set_pev(pEntity, pev_spawnflags, bitsSpawnFlags | SF_DOOR_NO_AUTO_RETURN)
		ExecuteHamB(Ham_SetToggleState, pEntity, TS_AT_TOP);
	}
	
	
	g_bitsMapRecord = 0;
	
	while((pEntity = fm_find_ent_by_tname(pEntity, "z4e_wall")) && pev_valid(pEntity))
	{
		z4e_building_set_entity(pEntity, 1);
	}
	
}

public fw_UseDoor(entity, caller, activator, use_type)
{
	if(!BitsGet(g_bitsMapRecord, 3) && pev(entity, pev_modelindex) == 215)
	{
		z4e_alarm_timertip(6, "#CSBTE_Z4E_ElevatorGoingUp");
		BitsSet(g_bitsMapRecord, 3);
		set_task(10.0, "Task_End", TASK_MAP);
	}
}

public OnDoorHitTop(this)
{
	if(pev(this, pev_modelindex) == 215)
	{
		Task_End();
	}
}

public fw_UseButton(entity, caller, activator, use_type)
{
	if(use_type == 2 && is_user_connected(caller))
	{
		if(!BitsGet(g_bitsMapRecord, 0) && pev(entity, pev_modelindex) == 14)
		{
			z4e_alarm_push(_, "** 机关【移动门】已激活 **", "", "", { 50,250,50 }, 2.0);
			BitsSet(g_bitsMapRecord, 0);
		}
		if(!BitsGet(g_bitsMapRecord, 1) && pev(entity, pev_modelindex) == 15)
		{
			z4e_alarm_push(_, "** 机关【大风车】已激活 **", "", "", { 50,250,50 }, 2.0);
			BitsSet(g_bitsMapRecord, 1);
		}
		if(!BitsGet(g_bitsMapRecord, 2) && pev(entity, pev_modelindex) == 123)
		{
			z4e_alarm_push(_, "** 机关【隐藏墙】已激活 **", "", "", { 50,250,50 }, 2.0);
			BitsSet(g_bitsMapRecord, 2);
		}
		if(!BitsGet(g_bitsMapRecord, 3) && pev(entity, pev_modelindex) == 130)
		{
			z4e_alarm_push(_, "** 机关【迷宫】已激活 **", "", "", { 50,250,50 }, 2.0);
			BitsSet(g_bitsMapRecord, 3);
		}
		
		if(pev(entity, pev_modelindex) == 104)
		{
			if(g_iMapStatus == MS_NONE)
			{
				z4e_alarm_timertip(10, "#CSBTE_Z4E_DoorClosing");
				set_task(10.0, "Task_BuildStart1", TASK_MAP);
				g_iMapStatus = MS_BUILD1_PREPARE;
			}
			else
			{
				return HAM_SUPERCEDE;
			}
		}
		
		if(pev(entity, pev_modelindex) == 214)
		{
			if(g_iMapStatus == MS_BUILD1_RUN)
			{
				z4e_alarm_timertip(10, "#CSBTE_Z4E_DoorClosing");
				set_task(10.0, "Task_BuildStart2", TASK_MAP);
				g_iMapStatus = MS_BUILD2_PREPARE;
			}
			else
			{
				return HAM_SUPERCEDE;
			}
		}
	}
	return HAM_IGNORED
}

public Task_BuildStart1(taskid)
{
	// 第一轮基建开始了
	new pEntity = -1;
	while(pev_valid((pEntity = fm_find_ent_by_tname(pEntity, "zone1_entrance"))))
	{
		ExecuteHamB(Ham_SetToggleState, pEntity, TS_AT_BOTTOM);
	}
	z4e_alarm_push(_, "大门很快开启，迅速建筑防御工事！", "", "", { 50,250,50 }, 2.0);
	z4e_alarm_push(_, "基地建设 ROUND 1", "", "", { 50,250,50 }, 2.0);
	z4e_alarm_timertip(60, "#CSBTE_Z4E_Building");
	
	for(new id=1;id<33;id++)
	{
		if(is_user_alive(id) && !z4e_team_get_user_zombie(id))
		{
			z4e_building_set_can_build(id, 1);
		}
		else
		{
			z4e_building_set_can_build(id, 0);
		}
	}
	
	g_iMapStatus = MS_BUILD1_BUILDING;
	set_task(60.0, "Task_BuildEnd1", TASK_MAP);
}

public Task_BuildEnd1(taskid)
{
	g_iMapStatus = MS_BUILD1_ENTER;
	
	//static const Float:vecMins[3] = {-1426.0,-943.0,-200.0};
	//static const Float:vecMaxs[3] = {940.0,-530.0,-150.0};
	static const Float:vecMins[3] = {1050.0,-943.0,-200.0};
	static const Float:vecMaxs[3] = {1450.0,139.0,-150.0};
	new Float:vecOrigin[3]
	for(new id=1;id<33;id++)
	{
		z4e_building_set_can_build(id, 0);
		
		if(is_user_alive(id))
		{
			if(!z4e_team_get_user_zombie(id))
			{
				do
				{
					RandomVector(vecMins, vecMaxs, vecOrigin);
				}
				while(!is_hull_vacant(vecOrigin, HULL_HUMAN));
				set_pev(id, pev_origin, vecOrigin);
			}
			else
			{
				z4e_freeze_set(id, 20.0, 1);
			}
		}
	}
	z4e_alarm_timertip(20, "#CSBTE_Z4E_BaseBuilder_Release");
	
	// 打开入口大门
	new pEntity = -1;
	while(pev_valid((pEntity = fm_find_ent_by_tname(pEntity, "zone1_entrance"))))
	{
		//ExecuteHamB(Ham_SetToggleState, pEntity, TS_AT_TOP);
		//ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0);
		OrpheuCall(g_handleDoorGoDown, pEntity);
	}
	
	set_task(20.0, "Task_BuildAttack1", TASK_MAP);
}

public Task_BuildAttack1(taskid)
{
	g_iMapStatus = MS_BUILD1_ATTACK;
	
	z4e_alarm_timertip(100, "#CSBTE_Z4E_DoorOpening");
	set_task(100.0, "Task_BuildRun1", TASK_MAP);
}

public Task_BuildRun1(taskid)
{
	g_iMapStatus = MS_BUILD1_RUN;
	
	// 打开出口大门
	new pEntity = -1;
	while(pev_valid((pEntity = fm_find_ent_by_tname(pEntity, "zone1_exit"))))
	{
		//ExecuteHamB(Ham_SetToggleState, pEntity, TS_AT_BOTTOM);
		//ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0);
		OrpheuCall(g_handleDoorGoDown, pEntity);
	}
	
	z4e_alarm_push(_, "出口已开启，迅速撤退！", "", "", { 50,250,50 }, 2.0);
	z4e_alarm_timertip(10, "#CSO_ZE_DEFENSE0");
	
	for(new id=1;id<33;id++)
	{
		if(is_user_alive(id) && z4e_team_get_user_zombie(id))
		{
			z4e_freeze_set(id, 10.0, 1);
		}
	}
}

//-----------------------------------------------------
public Task_BuildStart2(taskid)
{
	// 第二轮基建开始了
	new pEntity = -1;
	while(pev_valid((pEntity = fm_find_ent_by_tname(pEntity, "zone2_entrance"))))
	{
		ExecuteHamB(Ham_SetToggleState, pEntity, TS_AT_BOTTOM);
	}
	z4e_alarm_push(_, "基地建设 ROUND 2", "", "", { 50,250,50 }, 2.0);
	z4e_alarm_timertip(45, "#CSBTE_Z4E_Building");
	
	for(new id=1;id<33;id++)
	{
		if(is_user_alive(id) && !z4e_team_get_user_zombie(id))
		{
			z4e_building_set_can_build(id, 1);
		}
		else
		{
			z4e_building_set_can_build(id, 0);
		}
	}
	
	g_iMapStatus = MS_BUILD2_BUILDING;
	set_task(45.0, "Task_BuildEnd2", TASK_MAP);
}

public Task_BuildEnd2(taskid)
{
	g_iMapStatus = MS_BUILD2_ENTER;
	
	//static const Float:vecMins[3] = {-900.0,580.0,-200.0};
	//static const Float:vecMaxs[3] = {387.0,900.0,-150.0};
	static const Float:vecMins[3] = {-1450.0,345.0,-200.0};
	static const Float:vecMaxs[3] = {-1050.0,940.0,-150.0};
	new Float:vecOrigin[3]
	for(new id=1;id<33;id++)
	{
		z4e_building_set_can_build(id, 0);
		
		if(is_user_alive(id))
		{
			if(!z4e_team_get_user_zombie(id))
			{
				do
				{
					RandomVector(vecMins, vecMaxs, vecOrigin);
				}
				while(!is_hull_vacant(vecOrigin, HULL_HUMAN));
				set_pev(id, pev_origin, vecOrigin);
			}
			else
			{
				z4e_freeze_set(id, 20.0, 1);
			}
		}
	}
	
	// 打开入口大门
	new pEntity = -1;
	while(pev_valid((pEntity = fm_find_ent_by_tname(pEntity, "zone2_entrance"))))
	{
		//ExecuteHamB(Ham_SetToggleState, pEntity, TS_AT_TOP);
		//ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0);
		OrpheuCall(g_handleDoorGoDown, pEntity);
	}
	
	z4e_alarm_timertip(20, "#CSBTE_Z4E_BaseBuilder_Release");
	set_task(20.0, "Task_BuildAttack2", TASK_MAP);
}

public Task_BuildAttack2(taskid)
{
	g_iMapStatus = MS_BUILD2_ATTACK;
	
	z4e_alarm_timertip(120, "#CSBTE_Z4E_DoorOpening");
	set_task(120.0, "Task_BuildRun2", TASK_MAP);
}

public Task_BuildRun2(taskid)
{
	g_iMapStatus = MS_BUILD2_RUN;
	
	// 打开出口大门
	new pEntity = -1;
	while(pev_valid((pEntity = fm_find_ent_by_tname(pEntity, "zone2_exit"))))
	{
		//ExecuteHamB(Ham_SetToggleState, pEntity, TS_AT_BOTTOM);
		//ExecuteHamB(Ham_Use, pEntity, pEntity, pEntity, 0, 0.0);
		OrpheuCall(g_handleDoorGoDown, pEntity);
	}
	
	z4e_alarm_push(_, "出口已开启，迅速撤退！", "", "", { 50,250,50 }, 2.0);
	z4e_alarm_timertip(7, "#CSO_ZE_DEFENSE0");
	
	for(new id=1;id<33;id++)
	{
		if(is_user_alive(id) && z4e_team_get_user_zombie(id))
		{
			z4e_freeze_set(id, 7.0, 1);
		}
	}
}

public Task_End()
{
	g_iMapStatus = MS_END;
	client_print(0, print_chat, "Console: Round Ended")
	new Float:vecOrigin[3];
	for(new id=1;id<33;id++)
	{
		if(is_user_alive(id))
		{
			pev(id, pev_origin, vecOrigin);
			if(vecOrigin[2]<270.0)
				user_kill(id);
		}
	}
}

public fw_Touch(iEntity, iPtd)
{
	new szTargetName[32];
	pev(iEntity, pev_targetname, szTargetName, 31);
	if (strcmp(szTargetName, "end"))
		return HAM_IGNORED;
	
	if (g_iMapStatus != MS_END)
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED
}

stock RandomVector(const Float:vecMins[3], const Float:vecMaxs[3], Float:vecOut[3])
{
	for(new i=0;i<3;i++) vecOut[i] = random_float(vecMins[i], vecMaxs[i])
}

stock is_hull_vacant(Float:Origin[3], hull)
{
	engfunc(EngFunc_TraceHull, Origin, Origin, 0, hull, 0, 0)
	
	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true
	
	return false
}