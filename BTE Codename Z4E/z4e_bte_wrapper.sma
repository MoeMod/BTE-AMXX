#include <amxmodx>

#include "z4e_team.inc"

new g_fw_UserInfected, g_fw_DummyResult;

public plugin_init()
{
	g_fw_UserInfected = CreateMultiForward("bte_zb_infected", ET_IGNORE, FP_CELL, FP_CELL);
}

public plugin_natives()
{
	register_native("bte_get_user_zombie","native_is_zombie",1);
}

public native_is_zombie(id)
{
	return z4e_team_get_user_zombie(id);
}