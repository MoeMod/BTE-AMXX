#include <amxmodx>
#include <amxmisc> 
#include <hamsandwich>
#include <fakemeta>
#include "cdll_dll.h"
#include "offset.inc"

#define PLUGIN "BTE Ghost Hostage Punishment"
#define VERSION "1.0"
#define AUTHOR "NN"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	RegisterHam(Ham_TakeDamage, "hostage_entity", "TakeDamage");
	RegisterHam(Ham_TakeDamage, "monster_scientist", "TakeDamage");
}

public TakeDamage(pevVictim, pevInflictor, pevAttacker, Float:flDamage, bitsDamageType)
{
	if (!is_user_connected(pevAttacker))
		return HAM_IGNORED;
	
	if (get_pdata_int(pevAttacker, m_iTeam) == TEAM_TERRORIST)
	{
		ExecuteHam(Ham_TakeDamage, pevAttacker, pevAttacker, pevAttacker, 20.0, bitsDamageType);
		
		return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}