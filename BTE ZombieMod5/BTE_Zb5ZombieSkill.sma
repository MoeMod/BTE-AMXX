#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <orpheu>
#include "bte_api.inc"
#include "metahook.inc"
#include "cdll_dll.h"
#include "offset.inc"

#define PLUGIN "BTE Zombie Skill"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define ATKUP_TIME	4.0
#define ATKUP_CD	30.0

#define TRUE	1
#define FALSE	0

native MetahookMsg(id, type, i2 = -1, i3 = -1);

new bCanUse[33], bUsing[33];
new Float: flEndTime[33], Float: flCoolDownTime[33];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd("z5_zbskill", "z5_zbskill");

	register_forward(FM_PlayerPostThink, "PlayerPostThink");
}

public plugin_natives()
{
	register_native("bte_zb5_is_using_zbskill", "is_using_zbskill", 1)
}

public is_using_zbskill(id)
{
	return bUsing[id];
}

public bte_zb_infected(id, inf)
{
	if (inf)
		bCanUse[id] = TRUE;
}

public PlayerPostThink(id)
{
	new Float:time = get_gametime();

	if (flEndTime[id] && time > flEndTime[id])
		bUsing[id] = FALSE;

	if (flCoolDownTime[id] && time > flCoolDownTime[id])
		bCanUse[id] = TRUE;
}

public z5_zbskill(id)
{
	if (bte_get_user_zombie(id) != 1)
		return;

	if (!bCanUse[id])
	{
		//ClientPrint(id, HUD_PRINTCENTER, "#");
		return;
	}

	MetahookMsg(id, 38, floatround(ATKUP_CD), 4);

	bCanUse[id] = FALSE;
	bUsing[id] = TRUE;
	flEndTime[id] = get_gametime() + ATKUP_TIME;
	flCoolDownTime[id] = get_gametime() + ATKUP_CD;
}