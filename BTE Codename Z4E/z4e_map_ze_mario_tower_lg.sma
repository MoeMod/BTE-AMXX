#include < amxmodx >
#include < cstrike >
#include < engine >
#include < fakemeta >
#include < hamsandwich >
#include < dhudmessage >
//#include < eG >
#include "z4e_alarm.inc"

#define PLUGIN_NAME	"[ZE]Map: ze_Mario_Tower_lg"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"EmeraldGhost"

#define TASK_ESCAPE 2333
new g_bButtonUsed

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	RegisterHam(Ham_Use, "func_button", "button_to_target")
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
}

public plugin_precache()
{
	new szMap[9];
	get_mapname(szMap, 8)
	if(!equali(szMap, "ze_mario"))
	{
		pause("a")
		return;
	}
}

public Event_NewRound()
{
	remove_task(TASK_ESCAPE)
	set_task(2.0, "SpawnPrint")
	g_bButtonUsed = 0;
}

public SpawnPrint()
{
		client_print(0, print_chat, "Console: ** ze_Mario_Tower_lg ** Plugin By EmeraldGhost **")
		//z4e_alarm_insert(_, "** 地图: 马里奥高塔 ** 文本: 鬼鬼 **", "难度：***", "", { 50,250,50 }, 2.0);
}

public button_to_target(ent, caller, activator, use_type, Float:value)
{
	new szTarget[33]
	
	entity_get_string(ent, EV_SZ_target, szTarget, 32)
	
	if(equal(szTarget,"mario_escape_final_001") && !g_bButtonUsed)
	{
		client_print(0, print_chat, "Console: ** The cloud is coming ** Defend here! **")
		
		//z4e_alarm_insert(_, "** 云马上就到 ** 守住这里! **", "", "", { 50,250,50 }, 2.0);
		z4e_alarm_timertip(22, "#CSBTE_Z4E_MarioTower_CloudRunning");
		
		set_task(22.0, "EscapePrint", TASK_ESCAPE)
		g_bButtonUsed = 1;
	}
}

public EscapePrint(taskid)
{
		client_print(0, print_chat, "Console: ** Pull down the flag to slay zombies **")
		
		//z4e_alarm_insert(_, "** 降下旗子来处死安全屋外的所有人 **", "", "", { 50,250,50 }, 2.0);
}