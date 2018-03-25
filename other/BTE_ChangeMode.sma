#include <amxmodx>
#include <amxmisc>
#include "inc/BTE_API.inc"

new bte_mode[][16] = {"none", "td", "dm", "ze", "zb1" , "zb3", "zb4", "ghost", "zse", "gd"};

public plugin_init()
{
	register_plugin("BTE Choose Mode", "1.0", "NN");
	
	register_srvcmd("bte_change_mode", "cmd_change_mode");
}

public cmd_change_mode(id)
{
	new sCmd[32];
	read_argv(1, sCmd, 31);
	
	if (!sCmd[0])
	{
		server_print("usage: bte_change_mode < mode >");
		return PLUGIN_HANDLED;
	}
	
	change_mode(sCmd);
	
	return PLUGIN_HANDLED;
}

public change_mode(mode[])
{
	new config_dir[64], url_new[64], url_new2[64];
	get_configsdir(config_dir, charsmax(config_dir));
	
	format(url_new, charsmax(url_new), "%s/plugins-%s.ini", config_dir, mode);
	format(url_new2, charsmax(url_new2), "%s/disabled-%s.ini", config_dir, mode);
	
	if (file_exists(url_new))
	{
		server_print("Current mode already is %s", mode);
		return;
	}
	
	if (!file_exists(url_new2))
	{
		server_print("NOT exist %s", mode);
		return;
	}
	
	for (new i=0; i<sizeof(bte_mode); i++)
	{
		new url[64], url2[64];
		format(url, charsmax(url), "%s/plugins-%s.ini", config_dir, bte_mode[i]);
		format(url2, charsmax(url2), "%s/disabled-%s.ini", config_dir, bte_mode[i]);
		
		if (file_exists(url))
			rename(url, url2);
	}
	
	rename(url_new2, url_new);
	
	//server_print("Mode changed, please change map or restart server.");
	client_print(0, print_chat, "[Server] game mode changed to %s", mode);
}

public rename(old_name[], new_name[])
{
	new game[32] = "cstrike"
	new old_name_furl[200], new_name_furl[200]
	format(old_name_furl, 199, "%s/%s", game, old_name)
	format(new_name_furl, 199, "%s/%s", game, new_name)
	rename_file(old_name_furl, new_name_furl, 0);
}
