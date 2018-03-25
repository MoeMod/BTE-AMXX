#include <amxmodx>
#include <amxmisc>
native	bte_wpn_get_mod_running()
native	bte_wpn_get_weapon_limit()
native	MH_SendClientModRunning2(id,i)
native	MH_SendClientWeaponLimit(id,i)

enum _:BTE_MOD
{
	BTE_MOD_NONE=0,
	BTE_MOD_TD,
	BTE_MOD_ZE,
	BTE_MOD_NPC,
	BTE_MOD_ZB1,
	BTE_MOD_ZE,
	BTE_MOD_GD,
	BTE_MOD_DR,
	BTE_MOD_DM,
	BTE_MOD_GHOST,
	BTE_MOD_TD2
}

enum _:BTE_WEAPON_LIMIT
{
	WEAPON_LIMIT_NO=0,
	WEAPON_LIMIT_SNIPER,
	WEAPON_LIMIT_PISTOL,
	WEAPON_LIMIT_GRENADE,
	WEAPON_LIMIT_KNIFE
}


//new const MOD_NAME[][]={"NONE","TD","ZE","NPC","ZB1","GD","DR","","",""}
#define TASK_WAITTEXT	1451
#define TASK_SENDMODE	1551

new g_isZb2, g_isZb3, g_isZb4, g_isZb5, g_isZSE;

new gmsgGameMode;

public plugin_init()
{
	register_dictionary("bte_other.bte")
	register_plugin("BTE TIP", "1.0", "BTE TEAM");

	new config_dir[64], url_zb2[64], url_zb3[64], url_zb4[64], url_zb5[64], url_zse[64]
	get_configsdir(config_dir, charsmax(config_dir))
	format(url_zb2, charsmax(url_zb2), "%s/plugins-zb2.ini", config_dir)
	format(url_zb3, charsmax(url_zb3), "%s/plugins-zb3.ini", config_dir)
	format(url_zb4, charsmax(url_zb4), "%s/plugins-zb4.ini", config_dir)
	format(url_zb5, charsmax(url_zb5), "%s/plugins-zb5.ini", config_dir)
	format(url_zse, charsmax(url_zse), "%s/plugins-zse.ini", config_dir)

	if (file_exists(url_zb2)) g_isZb2 = 1
	else if(file_exists(url_zb3)) g_isZb3 = 1
	else if(file_exists(url_zb4)) g_isZb4 = 1
	else if(file_exists(url_zb5)) g_isZb5 = 1
	else if(file_exists(url_zse)) g_isZSE = 1

	server_cmd("mp_flashlight 1");

	gmsgGameMode = get_user_msgid("GameMode");
	register_message(gmsgGameMode, "message_msgGameMode");
}

public message_msgGameMode()
{
	new iMod, iWpnMod;
	iWpnMod = bte_wpn_get_weapon_limit();

	switch (bte_wpn_get_mod_running())
	{
		case BTE_MOD_NONE :		iMod = 1;
		case BTE_MOD_TD	:		iMod = 2;
		case BTE_MOD_DM	:		iMod = 14;
		case BTE_MOD_ZE : 		iMod = 10;
		case BTE_MOD_NPC :		iMod = 5;
		case BTE_MOD_ZB1 :
		{
			if (g_isZb2)		iMod = 13;
			else if(g_isZb3)	iMod = 11;
			else if(g_isZb4)	iMod = 12;
			else if(g_isZSE)	iMod = 15;
			else if(g_isZb5)	iMod = 16;
			else				iMod = 3;
		}
		case BTE_MOD_GD :		iMod = 8;
		case BTE_MOD_DR :		iMod = 9;
		case BTE_MOD_GHOST :	iMod = 7;
		default : iMod = 1;
	}

	set_msg_arg_int(1, get_msg_argtype(1), iMod * 10 + iWpnMod);
}
public client_putinserver(id)
{
	//iSendMod[id] = 0;
	if(GetPlayer()>=2 || bte_wpn_get_mod_running() == BTE_MOD_NPC)
	{
		for(new i=1;i<=32;i++)
		{
			if(task_exists(TASK_WAITTEXT + i))
				remove_task(TASK_WAITTEXT + i)
		}
	}
	else
	{
		if(bte_wpn_get_mod_running() != BTE_MOD_ZE && bte_wpn_get_mod_running() != BTE_MOD_NPC)
			set_task(1.0, "Task_WaitText", TASK_WAITTEXT + id, _, _, "b");
	}
	//set_task(1.0, "Task_SendMode", TASK_SENDMODE + id);
}
stock GetPlayer()
{
	new a = 0;
	for(new i=1;i<33;i++)
	{
		if(is_user_connected(i))	a += 1;
	}
	return a;
}

public Task_WaitText(iTask)
{
	new id = iTask - TASK_WAITTEXT
	client_print(id, print_center, "#CSBTE_Waiting");
}
