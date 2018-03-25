#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "TraceAttack Fix"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

new g_hamczbots;
new bot_quota;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	RegisterHam(Ham_TraceAttack, "player", "HamF_TraceAttack");
	
	bot_quota = get_cvar_pointer("bot_quota");
}

public HamF_TraceAttack(iVictim, iAttacker, Float:flDamage, Float:vecDir[3], ptr, bitsDamageType)
{
	/*
	code in mp
	
	if (CVAR_GET_FLOAT("mp_friendlyfire") == 0 && m_iTeam == pAttacker->m_iTeam)
		bShouldBleed = false;
	
	when pevAttacker is not CBasePlayer will crash
	
	*/
	
	/* lets fix it 0.0 */
	if (iAttacker > 32)
	{
		ExecuteHam(Ham_TraceAttack, iVictim, iVictim, flDamage, vecDir, ptr, bitsDamageType);
		
		return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

public client_putinserver(id)
{
	if (!g_hamczbots && is_user_bot(id) && get_pcvar_num(bot_quota) > 0)
	{
		if (!task_exists(id + 2647))
			set_task(0.1, "RegisterHamBot", id + 2647)
	}
}

public RegisterHamBot(taskid)
{
	new id = taskid - 2647;
	
	if (g_hamczbots || !is_user_connected(id))
		return;

	RegisterHamFromEntity(Ham_TraceAttack, id, "HamF_TraceAttack");

	g_hamczbots = 1;
}
