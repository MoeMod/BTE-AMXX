#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >
#include "z4e_alarm.inc"
#include "z4e_team.inc"

#define PLUGIN_NAME	"[Z4E] Map: ze_deadspace_final"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"Xiaobaibai"

#define TASK_ESCAPE 2333

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	RegisterHam(Ham_Use, "func_button", "HamF_FuncButton_Use")
	RegisterHam(Ham_Use, "game_text", "HamF_GameText_Use")
	RegisterHam(Ham_Use, "func_train", "HamF_FuncTrain_Use")
	
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	register_clcmd("goto", "CMD_Goto")
}

public CMD_Goto(id)
{
	set_pev(id, pev_origin, {-1986.0, 500.0, -1686.0});
}

public plugin_precache()
{
	new szMap[19];
	get_mapname(szMap, 18)
	if(!equali(szMap, "ze_deadspace_final"))
	{
		pause("a")
		return;
	}
}

public Event_NewRound()
{
	remove_task(TASK_ESCAPE)
	set_task(2.0, "SpawnPrint", TASK_ESCAPE)
}

public SpawnPrint()
{
	z4e_alarm_insert(_, "** 提示：地图上有红色箭头路标~ **", "", "", { 250,250,250 }, 2.0);
	z4e_alarm_insert(_, "** 地图: 生化太空舱 ** 文本: 小白白 **", "难度：*****", "", { 250,250,250 }, 2.0);
}

public HamF_FuncButton_Use(this, caller, activator, use_type, Float:value)
{
	if(!pev_valid(this))
		return;
	if(pev(this, pev_modelindex) == 128)
	{
		z4e_alarm_timertip(50, "#CSBTE_Z4E_DeadSpace_SpacecraftPrepare");
	}
}

public HamF_GameText_Use(this, caller, activator, use_type, Float:value)
{
	if(!pev_valid(this))
		return;
	
	new szMessage[64];
	pev(this, pev_message, szMessage, 63);
	
	new szTargetName[31];
	pev(this, pev_targetname, szTargetName, 31);
	
	client_print(0, print_chat, "** Console : %s **", szMessage)
	
	if(equal(szTargetName, "men1a"))
	{
		z4e_alarm_insert(_, "** 四号飞船准备离开 **", "", "", { 250,250,250 }, 2.0);
	}
	else if(equal(szTargetName, "men2a"))
	{
		z4e_alarm_insert(_, "** 状态刷新中 **", "", "", { 250,250,250 }, 2.0);
	}
	else if(equal(szTargetName, "men2b"))
	{
		z4e_alarm_insert(_, "** 燃料装填中......[72%] **", "", "", { 250,250,250 }, 2.0);
	}
	else if(equal(szTargetName, "men2c"))
	{
		z4e_alarm_insert(_, "** 供氧系统......[已开启] **", "", "", { 250,250,250 }, 2.0);
	}
	else if(equal(szTargetName, "men3a"))
	{
		z4e_alarm_insert(_, "** 自动化操作......[已开启] **", "", "", { 250,250,250 }, 2.0);
	}
	else if(equal(szTargetName, "men3b"))
	{
		z4e_alarm_insert(_, "** 目的地：Planeta S-1kA **", "", "", { 250,250,250 }, 2.0);
	}
	else if(equal(szTargetName, "men4b"))
	{
		z4e_alarm_insert(_, "** 准备起飞 **", "", "", { 250,250,250 }, 2.0);
	}
	else if(equal(szTargetName, "men4a"))
	{
		z4e_alarm_insert(_, "** 封闭机舱 **", "", "", { 250,250,250 }, 2.0);
	}
	else if(equal(szTargetName, "men5b"))
	{
		z4e_alarm_insert(_, "** 开启大门 **", "", "", { 250,250,250 }, 2.0);
	}
	
}

public HamF_FuncTrain_Use(this, caller, activator, use_type, Float:value)
{
	if(!pev_valid(this))
		return;
	
	new szTargetName[31];
	pev(this, pev_targetname, szTargetName, 31);
	
	if(equal(szTargetName, "nave_cristal"))
	{
		z4e_alarm_timertip(12, "#CSBTE_Z4E_DeadSpace_SpacecraftRunning");
	}
}