#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>
#include <dhudmessage>

#include "z4e_bits.inc"
#include "z4e_alarm.inc"

#define PLUGIN "[Z4E] Alarm"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

new const cfg_szTextAlarmTimer[] = "" 

enum _:MAX_ALARMTYPE
{
	ALARMTYPE_NONE,
	ALARMTYPE_IDLE,
	ALARMTYPE_TIP,
	ALARMTYPE_INFECT,
	ALARMTYPE_KILL,
}
new const cfg_iAlarmColor[MAX_ALARMTYPE][3] = {
	{ 255, 255, 255 },
	{ 255, 255, 255 },
	{ 200, 200, 50 },
	{ 255, 42, 42 },
	{ 42, 212, 255 }
}
new const cfg_szAlarmSubSound[MAX_ALARMTYPE][] = {
	"" , 
	"" , 
	"" , 
	"" , 
	""
}

enum STRUCT_ALARMINFO
{
	s_iAlarmType,
	s_iAlarmColor[4],
	Float:s_flAlarmTime,
	s_szAlarmSound[128],
	s_szAlarmTitle[128],
	s_szAlarmSubTitle[128],
}

enum _:TOTAL_FORWARDS
{
	FW_ALARM_SHOW_PRE = 0,
	FW_ALARM_SHOW_POST
}
new g_iForwards[TOTAL_FORWARDS]
new g_iForwardResult

#define TASK_ALARM 10086
#define TASK_TIMER 23333

new g_iHudAlarm
new g_bitsAlarm, any:g_sAlarmInfo[33][STRUCT_ALARMINFO]

new g_iTimerTip, g_szTimerTip[32]

#define HUD_ALARM_X -1.0
#define HUD_ALARM_Y 0.15

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	register_logevent("Event_RoundStart", 2, "1=Round_Start")
	
	g_iForwards[FW_ALARM_SHOW_PRE] = CreateMultiForward("z4e_fw_alarm_show_pre", ET_CONTINUE, FP_CELL, FP_ARRAY, FP_ARRAY, FP_ARRAY, FP_ARRAY, FP_FLOAT)
	g_iForwards[FW_ALARM_SHOW_POST] = CreateMultiForward("z4e_fw_alarm_show_post", ET_IGNORE, FP_CELL, FP_ARRAY, FP_ARRAY, FP_ARRAY, FP_ARRAY, FP_FLOAT)
	
	g_iHudAlarm = CreateHudSyncObj()
}

public plugin_natives()
{
	register_library("z4e_alarm")
	register_native("z4e_alarm_push", "Native_Push", 1)
	register_native("z4e_alarm_insert", "Native_Insert", 1)
	register_native("z4e_alarm_timertip", "Native_TimerTip", 1)
	register_native("z4e_alarm_kill", "Native_Kill", 1)
}

public Native_Push(iAlarmType, szTitle[], szSubTitle[], szSound[], iColor[], Float:flAlarmTime)
{
	param_convert(2)
	param_convert(3)
	param_convert(4)
	param_convert(5)
	return SendAlarm(iAlarmType, szTitle, szSubTitle, szSound, iColor, flAlarmTime, 0)
}

public Native_Insert(iAlarmType, szTitle[], szSubTitle[], szSound[], iColor[], Float:flAlarmTime)
{
	param_convert(2)
	param_convert(3)
	param_convert(4)
	param_convert(5)
	return SendAlarm(iAlarmType, szTitle, szSubTitle, szSound, iColor, flAlarmTime, 1)
}

public Native_TimerTip(iTime, szText[])
{
	param_convert(2)
	SendTimerTip(iTime, szText);
}

public Native_Kill(iKiller, iVictim, iAlarmType)
{
	
}

SendAlarm(iAlarmType, const szTitle[], const szSubTitle[], const szSound[], const iColor[], Float:flAlarmTime, bInsert = 0)
{
	if(!(~g_bitsAlarm))
		return false
	static iPos
	
	if(bInsert)
	{
		if(!BitsGet(g_bitsAlarm, 0))
			iPos = BitsGetFirst(g_bitsAlarm) - 1
		else if(BitsGet(g_bitsAlarm, 0) && BitsGet(g_bitsAlarm, 31))
			iPos = BitsGetFirst(g_bitsAlarm & g_bitsAlarm + 1) - 1
		else if(BitsGet(g_bitsAlarm, 0) && !BitsGet(g_bitsAlarm, 31))
			iPos = 31
	}
	else
	{
		if(BitsGet(g_bitsAlarm, 0))
			iPos = BitsGetFirst(~g_bitsAlarm)
		else if(!BitsGet(g_bitsAlarm, 0) && !BitsGet(g_bitsAlarm, 31))
			iPos = BitsGetFirst(~g_bitsAlarm & ~g_bitsAlarm + 1)
		else if(!BitsGet(g_bitsAlarm, 0) && BitsGet(g_bitsAlarm, 31))
			iPos = 0
	}
		
	g_sAlarmInfo[iPos][s_iAlarmType] = iAlarmType
	copy(g_sAlarmInfo[iPos][s_szAlarmTitle], 127, szTitle)
	copy(g_sAlarmInfo[iPos][s_szAlarmSubTitle], 127, szSubTitle)
	copy(g_sAlarmInfo[iPos][s_szAlarmSound], 127, szSound)
	copy(g_sAlarmInfo[iPos][s_iAlarmColor], 3, iColor)
	g_sAlarmInfo[iPos][s_flAlarmTime] = flAlarmTime
	BitsSet(g_bitsAlarm, iPos)
	if(!task_exists(TASK_ALARM))
		CheckAlarm()
	return true
}

SendTimerTip(iTime, const szText[])
{
	g_iTimerTip = iTime
	copy(g_szTimerTip, 31, szText)
	remove_task(TASK_TIMER)
	set_task(0.999999, "Task_Timer", TASK_TIMER, _, _, "b");
	
	remove_task(TASK_ALARM)
	CheckAlarm()
}

CheckAlarm()
{
	new iType, szTitle[128], szSubTitle[128], szSound[128], iColor[4], Float:flAlarmTime
	if(g_bitsAlarm)
	{
		static iPos
		if(BitsGet(g_bitsAlarm, 0) && BitsGet(g_bitsAlarm, 31))
			iPos = BitsGetFirst(g_bitsAlarm & (g_bitsAlarm + 1))
		else
			iPos = BitsGetFirst(g_bitsAlarm)
		
		iType = g_sAlarmInfo[iPos][s_iAlarmType]
		copy(szTitle, 127, g_sAlarmInfo[iPos][s_szAlarmTitle])
		copy(szSubTitle, 127, g_sAlarmInfo[iPos][s_szAlarmSubTitle])
		copy(szSound, 127, g_sAlarmInfo[iPos][s_szAlarmSound])
		copy(iColor, 3, g_sAlarmInfo[iPos][s_iAlarmColor])
		flAlarmTime = g_sAlarmInfo[iPos][s_flAlarmTime]
		BitsUnSet(g_bitsAlarm, iPos)
	}
	else
	{
		format(szSubTitle,127, "")
		if(g_iTimerTip)
		{
			iType = ALARMTYPE_TIP
			copy(iColor, 3, cfg_iAlarmColor[iType])
			format(szTitle,127, "%s [%i]", g_szTimerTip[0], g_iTimerTip)
		}
		else
		{
			iType = ALARMTYPE_IDLE
			copy(iColor, 3, cfg_iAlarmColor[iType])
			format(szTitle,127, cfg_szTextAlarmTimer)
		}
		flAlarmTime = 1.0
	}
	
	set_task(flAlarmTime, "Task_Alarm", TASK_ALARM);
	
	ExecuteForward(g_iForwards[FW_ALARM_SHOW_PRE], g_iForwardResult, iType, PrepareArray(szTitle, 127, 1), PrepareArray(szSubTitle, 127, 1), PrepareArray(szSound, 127, 1), PrepareArray(iColor, 3, 1), flAlarmTime)
	if(g_iForwardResult >= Z4E_ALARM_SUPERCEDE)
	{
		return;
	}
		
	if(szTitle[0])		
	{
		set_hudmessage(iColor[0], iColor[1], iColor[2], HUD_ALARM_X, HUD_ALARM_Y, 0, 1.0, flAlarmTime + 0.1, 0.1, 0.4,3)
		ShowSyncHudMsg(0, g_iHudAlarm, "^n [Thanatos Zone] ^n^n%s", szSubTitle)
		set_dhudmessage(iColor[0], iColor[1], iColor[2], HUD_ALARM_X, HUD_ALARM_Y + 0.05, 0, 1.2, flAlarmTime + 0.1, 0.1, 0.4, false)
		show_dhudmessage(0, szTitle)
	}
	
	
	if(iType < MAX_ALARMTYPE)
		PlaySound(0, cfg_szAlarmSubSound[iType])
	PlaySound(0, szSound)
	
	ExecuteForward(g_iForwards[FW_ALARM_SHOW_POST], g_iForwardResult, iType, PrepareArray(szTitle, 127, 0), PrepareArray(szSubTitle, 127, 0), PrepareArray(szSound, 127, 0), PrepareArray(iColor, 3, 0), flAlarmTime)

}

public Event_NewRound()
{
	remove_task(TASK_ALARM)
	remove_task(TASK_TIMER)
	g_iTimerTip = 0
	
	CheckAlarm()
}

public Event_RoundStart()
{
	remove_task(TASK_ALARM)
	set_task(0.05, "Task_Alarm", TASK_ALARM)
	remove_task(TASK_TIMER)
	set_task(1.0, "Task_Timer", TASK_TIMER, _, _, "b");
}

public Task_Alarm()
{
	CheckAlarm()
}

public Task_Timer()
{
	if(!g_iTimerTip)
	{
		g_szTimerTip[0] = 0
		return;
	}
	
	g_iTimerTip--;
}

stock PlaySound(index, const szSound[], stop_sounds_first = 0)
{
	if(equal(szSound, ""))
		return
	if (stop_sounds_first)
	{
		if (equal(szSound[strlen(szSound)-4], ".mp3"))
			client_cmd(index, "stopsound; mp3 play ^"sound/%s^"", szSound)
		else
			client_cmd(index, "mp3 stop; stopsound; spk ^"%s^"", szSound)
	}
	else
	{
		if (equal(szSound[strlen(szSound)-4], ".mp3"))
			client_cmd(index, "mp3 play ^"sound/%s^"", szSound)
		else
			client_cmd(index, "spk ^"%s^"", szSound)
	}
}