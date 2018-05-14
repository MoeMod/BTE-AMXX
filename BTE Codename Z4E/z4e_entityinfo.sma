#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#define PLUGIN "[Z4E] Entity Info"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define TASK_HUD 1413124

new g_pPointingTarget[33]
new gmsgStatusText

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_TraceLine, "fw_TraceLine", 1)
	
	register_clcmd("origin", "CMD_Origin")
	
	gmsgStatusText = get_user_msgid("StatusText")
	
	set_task(1.0, "Task_HUD", TASK_HUD, _, _, "b");
}

public CMD_Origin(id)
{
	static Float:vecStart[3]
	static Float:vecViewAngle[3]
	pev(id, pev_origin, vecStart)
	pev(id, pev_v_angle, vecViewAngle)
	client_print(id, print_chat, "坐标:%f %f %f 角度:%f %f %f", vecStart[0], vecStart[1], vecStart[2], vecViewAngle[0], vecViewAngle[1], vecViewAngle[2])
}

public Task_HUD(taskid)
{
	for(new id=1;id<get_maxplayers();id++)
	{
		if(!is_user_alive(id))
			return
		Update_Entity_Pointing(id)
	}
}

public fw_TraceLine( Float:v1[3], Float:v2[3], noMonsters, pentToSkip )
{
	new id = pentToSkip;
	if(!is_user_alive(id)) 
		return

	new iEntity = get_tr(TR_pHit)
	
	// 旧的目标失效
	if(!pev_valid(g_pPointingTarget[id]))
	{
		g_pPointingTarget[id] = 0;
		Update_Entity_Pointing(id)
	}
	
	// 更换了目标
	if(iEntity != g_pPointingTarget[id])
	{
		g_pPointingTarget[id] = iEntity
		Update_Entity_Pointing(id)
	}
	
	return;
}

Update_Entity_Pointing(id)
{
	if(!pev_valid(g_pPointingTarget[id]) || is_user_alive(g_pPointingTarget[id]))
	{
		message_begin(MSG_ONE_UNRELIABLE, gmsgStatusText, _, id)
		write_byte(0)
		write_string("^t")
		message_end()
		return PLUGIN_HANDLED;
	}
		
	static Float:flHealth; pev(g_pPointingTarget[id], pev_health, flHealth)
	static Float:szClassName[32]; pev(g_pPointingTarget[id], pev_classname, szClassName, 31)
	static Float:szTarget[32]; pev(g_pPointingTarget[id], pev_target, szTarget, 31)
	static Float:szTargetName[32]; pev(g_pPointingTarget[id], pev_targetname, szTargetName, 31)
	//if(flHealth > 0 && !equal(szClassName, "z4e_boss"))
	{
		static szMessage[64]
		//format(szMessage, charsmax(szMessage), "墙体耐久：%i", floatround(flHealth))
		format(szMessage, charsmax(szMessage), "CN:%s MI:%d T：%s TN：%s HP:%i", szClassName, pev(g_pPointingTarget[id], pev_modelindex), szTarget, szTargetName, floatround(flHealth))
		
		message_begin(MSG_ONE_UNRELIABLE, gmsgStatusText, _, id)
		write_byte(0)
		write_string(szMessage)
		message_end()
	}
	return PLUGIN_CONTINUE;
}