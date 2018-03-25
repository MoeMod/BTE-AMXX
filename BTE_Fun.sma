#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>

public plugin_natives()
{
	register_native("bte_fun_get_have_mode_item","native_get_have_mode_item",1)
	register_native("bte_fun_process_data", "native_no");
}

public native_no(const amx, const params)
{
	return 0;
}

public native_get_have_mode_item(id,iItem)
{
	return (is_user_bot(id)) ? (random_num(0, 1)) : 1;
}