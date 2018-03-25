#include <amxmodx>
#include <BTE_API>
#include "cdll_dll.h"

new gmsgTextMsg;

public plugin_init()
{
	register_plugin("BTE Connection","BTE TEAM","1.0")

	gmsgTextMsg = get_user_msgid("TextMsg");
	
	register_message(gmsgTextMsg, "message_TextMsg");

}


public message_TextMsg(msg_id, msg_dest, entity_index)
{
	if (get_msg_arg_int(1) != HUD_PRINTNOTIFY)
		return;

	static string[22];
	get_msg_arg_string(2, string, charsmax(string));

	if (equal(string, "#Game_disconnected") || equal(string, "#Game_connected"))
	{
		set_msg_arg_int(1, get_msg_argtype(1), HUD_PRINTTALK);
	}
	
	if (equal(string, "#Game_join_terrorist") ||
		equal(string, "#Game_join_ct") ||
		equal(string, "#Game_join_terrorist_auto") ||
		equal(string, "#Game_join_ct_auto"))
	{
		if(bte_wpn_get_mod_running() != BTE_MOD_ZB1)
			set_msg_arg_int(1, get_msg_argtype(1), HUD_PRINTTALK);
	}
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
