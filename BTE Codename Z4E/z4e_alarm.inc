#if defined _z4e_alarm_included
  #endinput
#endif
#define _z4e_alarm_included

enum _:MAX_Z4E_ALARMTYPE
{
    Z4E_ALARMTYPE_NONE,
    Z4E_ALARMTYPE_IDLE,
    Z4E_ALARMTYPE_TIP,
    Z4E_ALARMTYPE_INFECT,
    Z4E_ALARMTYPE_KILL,
    Z4E_ALARMTYPE_SKILL,
}

enum
{
    Z4E_ALARM_IGNORED = 0,
    Z4E_ALARM_SUPERCEDE
};

native z4e_alarm_push(iAlarmType = Z4E_ALARMTYPE_NONE, const szTitle[], const szSubTitle[], const szSound[], const iColor[], Float:flAlarmTime)
native z4e_alarm_insert(iAlarmType = Z4E_ALARMTYPE_NONE, const szTitle[], const szSubTitle[], const szSound[], const iColor[], Float:flAlarmTime)
native z4e_alarm_timertip(iTime, const szText[])
native z4e_alarm_kill(iKiller, iVictim, iAlarmType = Z4E_ALARMTYPE_KILL)

forward z4e_fw_alarm_show_pre(iType, szTitle[128], szSubTitle[128], szSound[128], iColor[3], Float:flAlarmTime)
forward z4e_fw_alarm_show_post(iType, const szTitle[], const szSubTitle[], const szSound[], const iColor[], Float:flAlarmTime)