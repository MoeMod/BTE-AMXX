#include <amxmodx>
#include <fakemeta>

#define PLUGIN "BTE Remove Objects"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

new g_msgStatusIcon;
new g_fwSpawn;

new szObjects[10][32] = {
"func_bomb_target", "info_bomb_target", "info_vip_start", "func_vip_safetyzone", "func_escapezone",
"hostage_entity", "monster_scientist", "func_hostage_rescue", "info_hostage_rescue", "item_longjump"
}


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_msgStatusIcon = get_user_msgid("StatusIcon");
	register_message(g_msgStatusIcon, "Message_StatusIcon");
	
	unregister_forward(FM_Spawn, g_fwSpawn);
}

public plugin_precache()
{
	g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")
}

public fw_Spawn(pEntity)
{
	if (!pev_valid(pEntity))
		return FMRES_IGNORED;
		
	new classname[32];
	
	pev(pEntity, pev_classname, classname, charsmax(classname));
	for (new i = 0; i < 10; i++)
	{
		if (equal(classname, szObjects[i]))
		{
			engfunc(EngFunc_RemoveEntity, pEntity);
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

public Message_StatusIcon(msgid, msgdest, id)
{
	static szIcon[8];
	get_msg_arg_string(2, szIcon, 7);
	
	if (equal(szIcon, "buyzone") && get_msg_arg_int(1))
	{
		set_pdata_int(id, 235, get_pdata_int(id, 235) & ~(1<<0));
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}
