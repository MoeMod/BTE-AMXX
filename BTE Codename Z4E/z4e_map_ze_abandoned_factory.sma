#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >

#include "z4e_alarm.inc"
#include "z4e_team.inc"
#include "z4e_bits.inc"

#define PLUGIN_NAME	"[Z4E] Map: ze_abandoned_factory"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"Xiaobaibai"

#define TASK_ESCAPE 2333

new g_bitsButtonUsed

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	RegisterHam(Ham_Use, "func_button", "HamF_FuncButton_Use")
	RegisterHam(Ham_Use, "multi_manager", "HamF_MultiManager_Use")
	RegisterHam(Ham_Use, "game_text", "HamF_GameText_Use")
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	
	register_clcmd("goto", "CMD_GOTO")
}

public plugin_precache()
{
	new szMap[32];
	get_mapname(szMap, 31)
	if(!equali(szMap, "ze_abandoned_factory"))
	{
		pause("a")
		return;
	}
}

public CMD_GOTO(id)
{
	set_pev(id, pev_origin, {136.729553,-2283.331054,-443.968750});
}

public Event_NewRound()
{
	remove_task(TASK_ESCAPE)
	set_task(2.0, "SpawnPrint", TASK_ESCAPE)
	
	g_bitsButtonUsed = 0;
}

public SpawnPrint()
{
	//z4e_alarm_insert(_, "** 提示：地图上的红色箭头会为你指路 **", "", "", { 250,250,250 }, 2.0);
	//z4e_alarm_insert(_, "** 地图: 废弃工厂 ** 文本: 小白白 **", "难度：***", "", { 250,250,250 }, 2.0);
}

public HamF_FuncButton_Use(this, caller, activator, use_type, Float:value)
{
	if(!pev_valid(this))
		return;
	if(pev(this, pev_modelindex) == 122 && !BitsGet(g_bitsButtonUsed, 1))
	{
		z4e_alarm_timertip(25, "#CSBTE_Z4E_AbandonedFactory_Decoding");
		BitsSet(g_bitsButtonUsed, 1);
	}
	
	if(pev(this, pev_modelindex) == 6 && !BitsGet(g_bitsButtonUsed, 2))
	{
		z4e_alarm_timertip(35, "#CSO_ZE_DEFENSE4");
		BitsSet(g_bitsButtonUsed, 2);
	}
}

public HamF_MultiManager_Use(this, caller, activator, use_type, Float:value)
{
	if(!pev_valid(this))
		return;
	
	new szMessage[64];
	pev(this, pev_message, szMessage, 63);
	
	new szTargetName[31];
	pev(this, pev_targetname, szTargetName, 31);
	
	if(equal(szTargetName, "multi1_prefinal"))
	{
		z4e_alarm_timertip(15, "爆破中…… ");
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
	
}