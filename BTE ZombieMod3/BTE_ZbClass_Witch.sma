#define PLUGIN "BTE Witch Zombie"
#define VERSION "1.0"
#define AUTHOR "ltndkl"

#define CONFIG_NAME "[Witch Zombie]"

#include <amxmodx>
#include <fakemeta>
#include "BTE_API.inc"
#include "metahook.inc"
#include "BTE_ZbClass.sma"

new iClass;
new szName[33], 

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_logevent("LogEvent_RoundStart",2, "1=Round_Start");
	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0");
	register_clcmd("zbskill", "Cmd_UseSkill");
}

public plugin_precache()
{
	ReadConfigs();

	iClass = bte_zb3_register_zombieclass()
}

public bte_zb_infected(iVictim, iAttacker)
{
	if (iClass == bte_zb3_get_user_zombieclass(iVictim))
	
}

public LogEvent_RoundStart()
{

}

public ReadConfigs()
{
	new szConfigDir[256];
	new szFileDir[512];
	get_configsdir(szConfigDir, 255);
	format(szFileDir, "%s/%s", szConfigDir, CONFIG_FILE);

	if (!file_exists(szFileDir))
	{
		new szError[256];
		format(szError, "Cannot load customization file %s!", szFilePath);
	}
}