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

#define PLUGIN "BTE Human Skill"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define SOUND_SKILL_START "zombi/speedup.wav"

#define ATKUP_TIME	4.0
#define SUPPLY_CD	20.0
#define HEAL_TIME	5.0
#define HEAL_CD		30.0
#define HEAL_SPEED	360.0

#define TRUE 1
#define FALSE 0

#define PRINT(%1) client_print(1, print_chat, %1)

native bte_zb3_can_use_skill2()
native MetahookMsg(id, type, i2 = -1, i3 = -1)

#define HS_ATKUP 0
#define HS_SUPPLY 1
#define HS_HEAL 2

new g_can_use[33][3]
new g_using[33][3]
new Float:g_skill_time[33][3]
new Float:g_skill_cd_time[33][3]

new g_ham

new gmsgTextMsg, gmsgBlinkAcct;

new OrpheuFunction:handleAddAccount;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_concmd("hms_atkup", "check_atkup")
	register_concmd("hms_supply", "check_supply")
	register_concmd("hms_heal", "check_heal")

	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0");
	register_forward(FM_PlayerPostThink, "Forward_PlayerPostThink");

	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage");
	//RegisterHam(Ham_Touch, "player", "HamF_Touch_Post", TRUE);

	gmsgTextMsg = get_user_msgid("TextMsg");
	gmsgBlinkAcct = get_user_msgid("BlinkAcct");

	handleAddAccount = OrpheuGetFunction ( "AddAccount", "CBasePlayer" );
}

public plugin_precache()
{
	precache_sound(SOUND_SKILL_START);
}

new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame

public Forward_PlayerPostThink(id)
{
	new Float:time = get_gametime();

	if (g_using[id][HS_HEAL])
	{
		set_pdata_float(id, m_flVelocityModifier, 1.0);
		set_pev(id, pev_maxspeed, HEAL_SPEED);
	}

	if (g_using[id][HS_ATKUP] && time > g_skill_time[id][HS_ATKUP])
		g_using[id][HS_ATKUP] = FALSE;

	if (g_using[id][HS_HEAL] && time > g_skill_time[id][HS_HEAL])
	{
		g_using[id][HS_HEAL] = FALSE;

		ExecuteHam(Ham_Player_ResetMaxSpeed, id);
	}

	if (!g_can_use[id][HS_SUPPLY] && time > g_skill_cd_time[id][HS_SUPPLY])
		g_can_use[id][HS_SUPPLY] = TRUE;

	return FMRES_IGNORED;
}

public plugin_natives()
{
	register_native("bte_hms_get_skillstat", "Native_get_skillstat", 1)
}

public Native_get_skillstat(id)
{
	new iReturn
	if (g_using[id][HS_SUPPLY]) iReturn |= (1<<HS_SUPPLY)
	if (g_using[id][HS_ATKUP]) iReturn |= (1<<HS_ATKUP)
	if (g_using[id][HS_HEAL]) iReturn |= (1<<HS_HEAL)
	return iReturn
}

public bte_zb_infected(id, inf)
{
	ClearStat(id)
}

public Event_HLTV()
{
	for (new i = 1; i < 33 ; i++)
	{
		ClearStat(i)
	}
}

public ClearStat(id)
{
	for (new j = 0; j < 3; j++)
	{
		g_can_use[id][j] = TRUE;
		g_using[id][j] = FALSE;
	}
}

#define DMG_BULLET (1<<1)

public HamF_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if (!g_using[attacker][HS_ATKUP])
		return HAM_IGNORED;

	if (damage_type & DMG_BULLET)
		damage *= 3.0;
	else
		damage *= 1.5;

	SetHamParamFloat(4, damage);

	return HAM_IGNORED;
}

#if 0

new Float:flNextTouchCheck[33];

public HamF_Touch_Post(id, other)
{
	if (other <= 0 || other >= 32)
		return;

	if (bte_get_user_zombie(id) != 1 || bte_get_user_zombie(other) == 1)
		return;

	if (!g_using[other][HS_HEAL])
		return;

	if (get_gametime() < flNextTouchCheck[id])
		return;

	flNextTouchCheck[id] = get_gametime() + 0.5;

	new Float:origin[3][2], Float:dir[3], Float:velocity[3];

	pev(id, pev_origin, origin[0]);
	pev(other, pev_origin, origin[1]);

	xs_vec_sub(origin[0], origin[1], dir);
	xs_vec_normalize(dir, dir);
	xs_vec_mul_scalar(dir, 3000.0, dir);

	dir[2] = 100.0;

	pev(id, pev_velocity, velocity);
	xs_vec_add(velocity, dir, velocity);

	set_pev(id, pev_velocity, dir/*velocity*/);
}

#endif

public check_atkup(id)
{
	if (bte_get_user_zombie(id) == 1)
		return;

	if (!bte_zb3_can_use_skill2())
	{
		ClientPrint(id, HUD_PRINTCENTER, "#HumanSkillRoundStart");
		return;
	}

	if (!g_can_use[id][HS_ATKUP])
	{
		//ClientPrint(id, HUD_PRINTCENTER, "#AtkUpUsed");
		return;
	}

	MetahookMsg(id, 16);

	g_can_use[id][HS_ATKUP] = FALSE;
	g_using[id][HS_ATKUP] = TRUE;
	g_skill_time[id][HS_ATKUP] = get_gametime() + ATKUP_TIME;

	emit_sound(id, CHAN_ITEM, SOUND_SKILL_START, 1.0, ATTN_NORM, 0, PITCH_NORM);
}

public check_supply(id)
{
	if (bte_get_user_zombie(id) == 1)
		return;

	if (!bte_zb3_can_use_skill2())
	{
		ClientPrint(id, HUD_PRINTCENTER, "#HumanSkillRoundStart");
		return;
	}

	if (!g_can_use[id][HS_SUPPLY])
	{
		//ClientPrint(id, HUD_PRINTCENTER, "#SupplyCD");
		return;
	}

	if (!CheckAccount(id, 2000))
		return;

	MetahookMsg(id, 15);

	OrpheuCallSuper(handleAddAccount, id, -2000, TRUE);
	//AddAccount(id, -2000, TRUE);

	g_can_use[id][HS_SUPPLY] = FALSE;
	//g_using[id][HS_SUPPLY] = TRUE;
	g_skill_cd_time[id][HS_SUPPLY] = get_gametime() + SUPPLY_CD;

	bte_wpn_set_fullammo(id);

	emit_sound(id, CHAN_ITEM, SOUND_SKILL_START, 1.0, ATTN_NORM, 0, PITCH_NORM);
}

public check_heal(id)
{
	if (bte_get_user_zombie(id) == 1)
		return;

	if (!bte_zb3_can_use_skill2())
	{
		ClientPrint(id, HUD_PRINTCENTER, "#HumanSkillRoundStart");
		return
	}

	if (!g_can_use[id][HS_HEAL])
	{
		//ClientPrint(id, HUD_PRINTCENTER, "#HealUsed");
		return
	}

	MetahookMsg(id, 17);

	//g_can_use[id][HS_HEAL] = FALSE;
	g_using[id][HS_HEAL] = TRUE;
	g_skill_time[id][HS_HEAL] = get_gametime() + HEAL_TIME;
	//g_skill_cd_time[id][HS_HEAL] = get_gametime() + HEAL_CD;

	new Float:maxhealth, Float:health;
	pev(id, pev_max_health, maxhealth);
	pev(id, pev_health, health);

	health += maxhealth * 0.5;
	health = health > maxhealth ? maxhealth : health;

	set_pev(id, pev_health, health);

	emit_sound(id, CHAN_ITEM, SOUND_SKILL_START, 1.0, ATTN_NORM, 0, PITCH_NORM);
}

public client_putinserver(id)
{
	if (g_ham) return
	new classname[32]
	pev(id, pev_classname, classname,31)
	if (!equal(classname, "player") && is_user_zbot(id))
	{
		set_task(1.0, "RegHam",id)
	}
}

stock is_user_zbot(id)
{
	if (!is_user_bot(id))
		return 0;

	new tracker[2], friends[2], ah[2];
	get_user_info(id,"tracker",tracker,1);
	get_user_info(id,"friends",friends,1);
	get_user_info(id,"_ah",ah,1);

	if (tracker[0] == '0' && friends[0] == '0' && ah[0] == '0')
		return 0; // PodBot / YaPB / SyPB

	return 1; // Zbot
}

public RegHam(id)
{
	if (g_ham) return
	g_ham = 1

	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage")
	//RegisterHamFromEntity(Ham_Touch, id, "HamF_Touch_Post", TRUE);

}

stock PlaySound(id, const sound[])
{
	if (equal(sound[strlen(sound)-4], ".mp3"))
	{
		client_cmd(id,"mp3 stop")
		client_cmd(id, "mp3 play sound/%s", sound)
	}
	else
		client_cmd(id, "spk %s", sound)
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

stock BlinkAccount(id, numBlinks)
{
	message_begin(MSG_ONE, gmsgBlinkAcct, _, id);
	write_byte(numBlinks);
	message_end();
}

stock CheckAccount(id, cost)
{
	new iAccount = get_pdata_int(id, m_iAccount);

	if (iAccount >= cost)
		return TRUE;

	ClientPrint(id, HUD_PRINTCENTER, "#Not_Enough_Money");
	BlinkAccount(id, 2);

	return FALSE;
}