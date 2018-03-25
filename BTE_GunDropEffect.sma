#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>

#include "bte_api.inc"
#include "metahook.inc"
#include "cdll_dll.h"

#define PLUGIN	"BTE GunDropEffect"
#define VERSION	"1.0"
#define AUTHOR	"BTE TEAM"

new gmsgTextMsg;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	RegisterHam(Ham_Touch, "weaponbox", "HamF_TouchWeapon")
	RegisterHam(Ham_Touch, "armoury_entity", "HamF_TouchWeapon")
	
	gmsgTextMsg = get_user_msgid("TextMsg");
}

public HamF_TouchWeapon(this, pOther)
{
	if(is_user_alive(pOther))
		ClientPrint(pOther, HUD_PRINTCENTER, "#CSO_Weapondrop_Effect_Notice");
}

stock ClientPrint(id, type, message[], str1[] = "", str2[] = "", str3[] = "", str4[] = "")
{
	new dest
	if (id) dest = MSG_ONE_UNRELIABLE
	else dest = MSG_ALL

	message_begin(dest, gmsgTextMsg, {0, 0, 0}, id)
	write_byte(type)
	write_string(message)

	if (str1[0])
		write_string(str1)
	if (str2[0])
		write_string(str2)
	if (str3[0])
		write_string(str3)
	if (str4[0])
		write_string(str4)

	message_end()
}