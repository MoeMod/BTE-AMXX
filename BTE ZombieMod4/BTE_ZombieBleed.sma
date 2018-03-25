#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include "offset.inc"

#define PLUGIN "BTE Zombie Bleed Fix"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

new g_iKevlar[33];
new g_hamczbots, bot_quota;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	RegisterHam(Ham_TraceAttack, "player", "HamF_TraceAttack");
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage");
	RegisterHam(Ham_TraceAttack, "player", "HamF_TraceAttack_Post", 1);
	
	bot_quota = get_cvar_pointer("bot_quota");
}

public HamF_TraceAttack(iVictim, iAttacker, Float:flDamage, Float:vecDir[3], ptr, bitsDamageType)
{
	g_iKevlar[iVictim] = get_pdata_int(iVictim, m_iKevlar);
	set_pdata_int(iVictim, m_iKevlar, 0);
}

public HamF_TakeDamage(iVictim, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	set_pdata_int(iVictim, m_iKevlar, g_iKevlar[iVictim]);
}
public HamF_TraceAttack_Post(iVictim, iAttacker, Float:flDamage, Float:vecDir[3], ptr, bitsDamageType)
{
	set_pdata_int(iVictim, m_iKevlar, g_iKevlar[iVictim]);
}
public client_putinserver(id)
{
	if (!g_hamczbots && is_user_bot(id) && get_pcvar_num(bot_quota) > 0)
	{
		set_task(0.1, "RegisterHamBot", id)
	}
}

public RegisterHamBot(id)
{
	if (g_hamczbots || !is_user_connected(id))
		return;

	RegisterHamFromEntity(Ham_TraceAttack, id, "HamF_TraceAttack");
	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage");
	RegisterHamFromEntity(Ham_TraceAttack, id, "HamF_TraceAttack_Post", 1);

	g_hamczbots = 1;
}
