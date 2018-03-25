#include <amxmodx>
#include "cdll_dll.h"

public plugin_init()
{
	register_message(get_user_msgid("TextMsg"), "message_TextMsg");
}

public message_TextMsg()
{
	if (get_msg_arg_int(1) != HUD_PRINTRADIO)
		return PLUGIN_CONTINUE;
	
	new textmsg[32];
	get_msg_arg_string(3, textmsg, charsmax(textmsg));
	
	if (!equal(textmsg, "#Game_radio_location"))
		return PLUGIN_CONTINUE;
	
	get_msg_arg_string(5, textmsg, charsmax(textmsg));
	format(textmsg, charsmax(textmsg), "#%s", textmsg);
	set_msg_arg_string(5, textmsg);
	
	return PLUGIN_CONTINUE;
}
