#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <metahook>
#include <cstrike>
#include <orpheu>
#include <round_terminator>

#include "BTE_API.inc"

#define PLUGIN	"BTE GunDeath"
#define VERSION	"1.0"
#define AUTHOR	"BTE TEAM"

#define MAX_LEVEL 18
native BTE_MVPBoard(iWinningTeam, iType, iPlayer = 0);

new const SETTING_FILE[] = "bte_gundeath.ini"
new g_finalcheck[33]
// Player
new g_level[2][33], g_respawning[33], g_protection[33], g_kills[33], g_weapon[33][33], g_he[33]

// Server
new g_fwSpawn, round_time, g_newround, g_endround, g_tickets_ct, g_tickets_te

// Msg
new g_msgClCorpse, g_msgTextMsg, g_msgCrosshair,g_msgTeamInfo,g_msgStatusIcon

// Customization vars
new g_human_armor, Float:g_weapons_stay, g_round_time, g_tickets, Float:g_respawn_wait, Float:g_protection_time, Array:g_protection_color,
g_map_continue, Array:g_map_sequence,
Array:g_objective_ents

// Zbots
new g_fwHamBotRegister, cvar_botquota

enum
{
	SECTION_NONE = 0,
	SECTION_CONFIG_VALUE,
	SECTION_MAP_CONTINUE,
	SECTION_OBJECTIVE_ENTS
}
enum (+= 100)
{
	TASK_RESPAWN = 2000,
	TASK_PROTECTION,
	TASK_ROUND_TIME,
	TASK_CHANGE_MAP
}
#define ID_RESPAWN (taskid - TASK_RESPAWN)
#define ID_PROTECTION (taskid - TASK_PROTECTION)

const OFFSET_CSDEATHS = 444
const OFFSET_LINUX = 5

new WEAPON_LIMIT[18][2][16]
new WEAPON_LIST[][]=
{
	"m4a1","ak47",
	"sg550","g3sg1",
	"tar21","tar21",
	"aug","sg552",
	"an94","m16a4",
	"awp","svd",
	"scar","xm8",
	"famas","galil",
	"k1a","usas",
	"mp5","mp7a1",
	"m3","xm1014",
	"m249","qbb95",
	"scout","scout",
	"p90","p90",
	"deagle","elite",
	"tmp","mac10",
	"p228","fiveseven",
	"glock18","glock18",
	"glock18","hegrenade"
}
new WEAPON_LIMIT_RARE[][] = {"m1887","m134","m95","xm2010","stg44","m14ebr"}
new KILL_AIM[MAX_LEVEL] = {4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 2, 3, 3, 3, 3}
new g_msgScenario

new g_pGameRules, g_bNoRoundEnd

public bte_fw_precache_weapon_pre()
{
	new iCount = 0
	for(new i=0;i<18;i++)
	{
		for(new j=0;j<2;j++)
		{
			copy(WEAPON_LIMIT[i][j],15,WEAPON_LIST[iCount++])
			bte_wpn_precache_named_weapon(WEAPON_LIMIT[i][j])
		}
	}
	bte_wpn_precache_named_weapon("hegrenade")
	for(new i=0;i<sizeof(WEAPON_LIMIT_RARE);i++)
	{
		bte_wpn_precache_named_weapon(WEAPON_LIMIT_RARE[i])
	}
}
public update_player_scenario(id)
{
	if (g_level[1][id] == MAX_LEVEL)
	{
		message_begin(MSG_ONE, g_msgScenario, _, id)
		write_byte(0)//  Active
		write_string("d_awp")//  Sprite
		write_byte(150)//  Alpha
		write_short(0)//  FlashRate
		write_short(0)//  Unknown
		message_end()
		return
	}

	new sprname[32]
	format(sprname,31,"gd_remain%d",KILL_AIM[g_level[1][id]]-g_level[0][id])

	message_begin(MSG_ONE, g_msgScenario, _, id)
	write_byte(1)//  Active
	write_string(sprname)//  Sprite
	write_byte(255)//  Alpha
	write_short(0)//  FlashRate
	write_short(0)//  Unknown
	message_end()
}
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_logevent("logevent_round_start", 2, "1=Round_Start")
	register_logevent("logevent_round_end", 2, "1=Round_End")

	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1)
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon")
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
	
	g_fwHamBotRegister = register_forward(FM_PlayerPostThink, "fw_BotRegisterHam", 1)

	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_Touch, "fw_Touch")
	unregister_forward(FM_Spawn, g_fwSpawn)

	g_msgClCorpse = get_user_msgid("ClCorpse")
	g_msgTextMsg = get_user_msgid("TextMsg")
	g_msgCrosshair = get_user_msgid("Crosshair")
	g_msgScenario = get_user_msgid("Scenario")
	g_msgTeamInfo = get_user_msgid("TeamInfo")
	g_msgStatusIcon = get_user_msgid("StatusIcon")

	register_message(g_msgStatusIcon, "message_StatusIcon")
	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
	register_message(g_msgClCorpse, "message_msgClCorpse")
	register_message(g_msgTextMsg, "message_msgTextMsg")
	//register_message(g_msgTeamInfo, "message_msgTeamInfo")

	register_clcmd("drop", "cmd_block")
	register_clcmd("buy", "cmd_block")
	//register_clcmd("bte_wpn_menu", "cmd_block")

	cvar_botquota = get_cvar_pointer("bot_quota")
}

public fw_BotRegisterHam(id)
{
	if (!is_user_zbot(id) || get_pcvar_num(cvar_botquota) <= 0) 
		return
	unregister_forward(FM_PlayerPostThink, g_fwHamBotRegister, 1)
	
	RegisterHamFromEntity(Ham_Spawn, id, "fw_PlayerSpawn_Post", 1)
}

public plugin_precache()
{
	g_protection_color = ArrayCreate(32, 1)
	g_map_sequence = ArrayCreate(32, 1)
	g_objective_ents = ArrayCreate(32, 1)

	load_customization_from_files()

	new ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_map_parameters"))
	Set_Kvd(ent, "buying", "3", "info_map_parameters")
	dllfunc(DLLFunc_Spawn, ent)


	g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")
	OrpheuRegisterHook(OrpheuGetFunction("InstallGameRules"), "OnInstallGameRules", OrpheuHookPost)
}

public OrpheuHookReturn:OnInstallGameRules()
{
	g_pGameRules = OrpheuGetReturn();
	
	OrpheuRegisterHook(OrpheuGetFunctionFromObject(g_pGameRules, "CheckWinConditions", "CGameRules"), "OnCheckWinConditions")
}

public OrpheuHookReturn:OnCheckWinConditions(this)
{
	if (!g_bNoRoundEnd)
		return OrpheuIgnored
	return OrpheuSupercede
}

public plugin_cfg()
{
	g_bNoRoundEnd = 0 
}
public event_round_start()
{
	Update_Score()
	g_newround = 1
	g_endround = 0
	g_tickets_ct = 0
	g_tickets_te = 0
	g_bNoRoundEnd = 0 

	for (new id = 1; id <= get_maxplayers(); id++)
	{
		g_finalcheck[id] = 0
		if (!is_user_alive(id)) continue;

		reset_value(id)
		copy(g_weapon[id],15,WEAPON_LIMIT[0][2-get_user_team(id)])

		if(MH_IsMetaHookPlayer(id))
		{
			MH_SendClientModRunning(id,8)
		}
	}
}

new Float:g_flRoundStart;

public logevent_round_start()
{
	g_flRoundStart = get_gametime();

	g_tickets_ct = 0
	g_tickets_te = 0
	for(new i=1;i<33;i++)
	{
		if(is_user_alive(i)) g_bNoRoundEnd = 1
		reset_frags_deaths(i)
	}
	Update_Score()
	g_newround = 0

	round_time = g_round_time*60
	task_round_time()
	if (task_exists(TASK_ROUND_TIME)) remove_task(TASK_ROUND_TIME)
	set_task(1.0, "task_round_time", TASK_ROUND_TIME,  _, _, "b")
}
public logevent_round_end()
{
	Update_Score()
	for(new i=1;i<33;i++)
	{
		reset_value(i)
		update_frags_deaths(i, i, g_kills[i])
	}
}
public task_round_time()
{
	if (round_time <= 0)
	{
		set_end_round(0)
		remove_task(TASK_ROUND_TIME)
		return;
	}

	sendmsg_RoundTime(round_time)

	round_time --
}
public Player_Respawn(id)
{
	if(!is_user_alive(id) && is_user_connected(id)) ExecuteHamB(Ham_CS_RoundRespawn, id)
}
public message_msgTeamInfo()
{
	static id;
	id = read_data(1)
	if(!is_user_alive(id) && is_user_connected(id))
	{
		static sTeam[32];
		read_data(2,sTeam,31)
		if(equal(sTeam,"CT") || equal(sTeam,"TERRORIST"))
		{
			set_task(1.0,"Player_Respawn",id)
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}
public set_end_round(id)
{
	if (g_endround) return;
	g_endround = 1
	g_bNoRoundEnd = 0
	if (g_tickets_ct > g_tickets_te)
	{
		client_cmd(0,"spk dm/ctwin2.wav")
		client_print(0, print_center, "反恐小組獲得了勝利!")
		BTE_MVPBoard(2, 0, id);
		TerminateRound( RoundEndType_TeamExtermination, TeamWinning_Ct )
	}
	else if (g_tickets_ct < g_tickets_te)
	{
		client_cmd(0,"spk dm/trwin2.wav")
		client_print(0, print_center, "恐怖份子獲得了勝利!")
		BTE_MVPBoard(1, 0, id);
		TerminateRound( RoundEndType_TeamExtermination,TeamWinning_Terrorist );
	}
}
public change_map(taskid)
{
	if(!g_map_continue)
		return;
	new next_map[32]
	ArrayGetString(g_map_sequence, random_num(0, ArraySize(g_map_sequence) - 1), next_map, charsmax(next_map))
	server_cmd("changelevel %s", next_map)
}
public client_putinserver(id)
{
	reset_value(id)

	if (is_user_bot(id))
	{
		if (get_gametime() - g_flRoundStart > 20.0)
			set_task(2.0, "Check_Respawn", id + 9998);
	}

	//set_task(1.0,"Check_Respawn",id+9998)
}

public bte_player_model_change(id)
{
	if (get_gametime() - g_flRoundStart > 20.0)
	{
		set_task(1.0, "Check_Respawn", id + 9998);
	}

}

public Check_Respawn(idx)
{
	new id = idx-9998
	//client_print(0, print_chat, "!!%d" , is_user_connected(id))

	if(!is_user_connected(id)) return
	new team = get_user_team(id)
	//client_print(0, print_chat, "%d", team)



	if(!is_user_alive(id) && (team == 1|| team == 2 ))
	{
		ExecuteHamB(Ham_CS_RoundRespawn,id)
		return
	}
	//set_task(1.0,"Check_Respawn",idx)

}


public cmd_block(id)
{
	return PLUGIN_HANDLED
}
public Update_Score()
{
	for(new i=1;i<33;i++)
	{
		if(is_user_connected(i) && MH_IsMetaHookPlayer(i))
		{
			//MH_SendClientModRunning(i,8)
			//MH_DrawScoreBoard(i,g_tickets_te, g_tickets, g_tickets_ct, 0, 0 ,2)
		}
	}
}
////////////death and respawn////////////
public message_DeathMsg()
{
	new killer, victim, weapon[32],iRandom
	killer = get_msg_arg_int(1)
	victim =get_msg_arg_int(2)
	read_data(4, weapon, charsmax(weapon))
	if (containi(weapon, "grenade")!=-1 && killer!=victim)
	{
		set_task(0.5, "set_end_round", killer)
		for(new i = 1;i<33;i++)
		{
			if(is_user_alive(i) && MH_IsMetaHookPlayer(i))
			{
				new message[64],name[32]
				get_user_name(killer,name,31)
				format(message,63,"%L",LANG_PLAYER,"BTE_GUNDEATH_HEKILL",name)
				MH_DrawFontText(i,message,1,0.5,0.8,50,255,50,48,5.0,1.0,0,3)
			}
		}
		return
	}
	if(0<killer<33 && (cs_get_user_team(killer)!=cs_get_user_team(victim)))
	{
		if (g_level[1][killer] < MAX_LEVEL)
		{
			g_level[0][killer] += 1
			if (g_level[0][killer] == KILL_AIM[g_level[1][killer]])
			{
				g_level[1][killer] += 1
				if(g_level[1][killer]>18) g_level[1][killer] = 18
				g_level[0][killer] = 0
				copy(g_weapon[killer],15,WEAPON_LIMIT[g_level[1][killer]-1][random_num(0, 1)])
				iRandom = random_num(1,10)
				if(g_level[1][killer]>4 && g_level[1][killer]<11)
				{
					if(iRandom>9)
					{
						format(g_weapon[killer], 15, "%s", WEAPON_LIMIT_RARE[random_num(0,sizeof(WEAPON_LIMIT_RARE)-1)])
					}
				}

				//if (MH_IsMetaHookPlayer(killer))
				//{
				MH_PlayBink(killer,"weaponchange.bik",0.5,0.3,255,255,255,0,1,1,0)
				//}
				client_cmd(killer,"spk gdm/weaponchange.wav")
				set_task(0.2, "give_weapons", killer)
			}
		}
		else if (g_level[1][killer] == MAX_LEVEL)
		{
			if (g_level[0][killer] == 0 && !g_finalcheck[killer])
			{
				if (MH_IsMetaHookPlayer(killer)) MH_PlayBink(killer,"finalattack.bik",0.5,0.3,255,255,255,0,1,1,0)
				client_cmd(killer,"spk gdm/finalattack.wav")
				g_finalcheck[killer] = 1
			}
			if (!g_he[killer])
			{
				g_he[killer] = 1
				g_kills[killer] += 1
				set_task(0.2, "give_he", killer)
			}
		}
		update_player_scenario(killer)
		if (cs_get_user_team(killer) == CS_TEAM_CT && cs_get_user_team(victim) == CS_TEAM_T) g_tickets_ct += 1
		else if (cs_get_user_team(killer) == CS_TEAM_T && cs_get_user_team(victim) == CS_TEAM_CT) g_tickets_te += 1
		//if (g_tickets_ct >= g_tickets || g_tickets_te >= g_tickets) set_end_round(0)
	}

	g_respawning[victim] = 1
	reset_value_death(victim)
	if (task_exists(victim+TASK_RESPAWN)) remove_task(victim+TASK_RESPAWN)
	set_task(g_respawn_wait, "player_respawn", victim+TASK_RESPAWN)

	if (MH_IsMetaHookPlayer(victim)) MH_RespawnBar(victim, 1, g_respawn_wait)
	Update_Score()
	if (g_tickets_ct >= g_tickets || g_tickets_te >= g_tickets)
	{
		set_task(1.0,"set_end_round",2,_,_,"a",1)
	}
}
public player_respawn(taskid)
{
	new id = ID_RESPAWN

	if (!is_user_connected(id)) return;
	if (is_user_bot(id))
	{
		ExecuteHamB(Ham_CS_RoundRespawn, id)
		return;
	}

	g_respawning[id] = 0
	ExecuteHamB(Ham_CS_RoundRespawn, id)

	if (task_exists(taskid)) remove_task(taskid)
}
////////////Hamsandwitch////////////
public fw_Spawn(entity)
{
	if (!pev_valid(entity)) return FMRES_IGNORED;

	new classname[32], objective[32], size = ArraySize(g_objective_ents)
	pev(entity, pev_classname, classname, charsmax(classname))

	for (new i = 0; i < size; i++)
	{
		ArrayGetString(g_objective_ents, i, objective, charsmax(objective))

		if (equal(classname, objective))
		{
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE;
		}
	}

	return FMRES_IGNORED;
}
public give_knife(id)
{
	if(!is_user_bot(id)) bte_wpn_give_named_wpn(id,"knife",1)
}
public give_he(id)
{
	new name[32]
	get_user_name(id,name,31)
	client_print(0,print_center,"%L",LANG_PLAYER,"BTE_GUNDEATH_GOT_KILLGE",name)
	bte_wpn_give_named_wpn(id,"hegrenade",1)
}

public fw_PlayerSpawn_Post(id)
{
	if (!is_user_alive(id))
		return;

	Update_Score()
	update_player_scenario(id)

	set_task(0.2, "give_weapons", id)
	set_task(0.2, "give_knife", id)

	//set_task(0.1, "message_reset", id)
	set_protection(id)
	cs_set_user_armor(id, g_human_armor, CS_ARMOR_VESTHELM)
}

public fw_TouchWeapon(ent, id)
{
	//if (!is_user_connected(id))
		//return HAM_IGNORED;

	return HAM_SUPERCEDE;
}
public fw_ThinkGrenade(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return FMRES_IGNORED;

	// Get damage time of grenade
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)

	// Check if it's time to go off
	if (dmgtime > get_gametime())
		return HAM_IGNORED;

	static id
	id = pev(entity, pev_owner)
	g_he[id] = 0

	return HAM_IGNORED;
}
////////////Fakemeta////////////
public fw_SetModel(entity, const model[])
{
	if (!pev_valid(entity)) return FMRES_IGNORED

	if (strlen(model) < 8) return FMRES_IGNORED;

	new ent_classname[32]
	pev(entity, pev_classname, ent_classname, charsmax(ent_classname))
	if (equal(ent_classname, "weaponbox"))
	{
		set_pev(entity, pev_nextthink, get_gametime() + g_weapons_stay)
		return FMRES_IGNORED
	}
	return FMRES_IGNORED
}
public fw_Touch(ent, id)
{
	if (!pev_valid(ent) || !is_user_connected(id)) return FMRES_IGNORED;

	static class[32]; pev(ent, pev_classname, class, charsmax(class))
	if (equal(class, "func_buyzone")) return FMRES_SUPERCEDE;

	return FMRES_IGNORED;
}
////////////message////////////
public message_msgClCorpse()
{
	new victim = get_msg_arg_int(12)
	if (g_respawning[victim] || is_user_alive(victim)) return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE
}
public message_reset(id)
{
	message_begin(MSG_ONE, g_msgCrosshair, _, id)
	write_byte(0)
	message_end()
}
public message_msgTextMsg()
{
	if(get_msg_args() != 2) return PLUGIN_CONTINUE

	static textmsg[22]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))

	if(equal(textmsg, "#Game_Commencing") || equal(textmsg, "#Game_will_restart_in"))
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}
public message_StatusIcon(msgid, msgdest, id)
{
	static szIcon[8];
	get_msg_arg_string(2, szIcon, 7);

	if(equal(szIcon, "buyzone") && get_msg_arg_int(1))
	{
		set_pdata_int(id, 235, get_pdata_int(id, 235) & ~(1<<0));
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}
////////////function////////////
public give_weapons(id)
{
	if (!is_user_alive(id) || !cs_get_user_team(id))
		return;

	if (!g_weapon[id][0])
	{
		//client_print(0, print_chat, "id: %d %d", id, 2 - get_pdata_int(id, 114));
		copy(g_weapon[id], 15, WEAPON_LIMIT[0][2 - get_pdata_int(id, 114)])
	}

	bte_wpn_strip_weapon(id,1)
	bte_wpn_strip_weapon(id,2)
	//bte_wpn_give_named_wpn(id,"knife")

	if (g_level[1][id] == MAX_LEVEL)
	{
		bte_wpn_give_named_wpn(id,"glock18",1)
		if (g_he[id])
			bte_wpn_give_named_wpn(id,"hegrenade",1)
	}
	else
	{
		bte_wpn_give_named_wpn(id,g_weapon[id],1)
		//client_print(id,print_chat,"%s",g_weapon[id])
	}
}
set_protection(id)
{
	fm_set_user_godmode(id, 1)
	new color[3]
	color[0] = ArrayGetCell(g_protection_color, 0)
	color[1] = ArrayGetCell(g_protection_color, 1)
	color[2] = ArrayGetCell(g_protection_color, 2)
	fm_set_rendering(id, kRenderFxGlowShell, color[0], color[1], color[2], kRenderNormal, 10)
	if (task_exists(id+TASK_PROTECTION)) remove_task(id+TASK_PROTECTION)
	set_task(g_protection_time, "remove_protection", id+TASK_PROTECTION)
}
public remove_protection(taskid)
{
	new id = ID_PROTECTION

	if (!is_user_connected(id)) return;

	fm_set_user_godmode(id)
	fm_set_rendering(id)
}
sendmsg_RoundTime(seconds)
{
	message_begin(MSG_ALL, get_user_msgid("RoundTime"), _, 0)
	write_short(seconds)
	message_end()
}
reset_value(id)
{
	if (task_exists(id+TASK_RESPAWN)) remove_task(id+TASK_RESPAWN)
	if (task_exists(id+TASK_PROTECTION)) remove_task(id+TASK_PROTECTION)

	g_level[0][id] = 0
	g_level[1][id] = 1
	g_respawning[id] = 0
	g_protection[id] = 0
	g_he[id] = 0
	g_kills[id] = 0

	if (is_user_alive(id)) fm_set_rendering(id)
}

public client_disconnect(id)
{
	g_level[0][id] = 0
	g_level[1][id] = 1
	g_respawning[id] = 0
	g_protection[id] = 0
	g_he[id] = 0
	g_kills[id] = 0
}


reset_value_death(id)
{
	if (task_exists(id+TASK_RESPAWN)) remove_task(id+TASK_RESPAWN)
	if (task_exists(id+TASK_PROTECTION)) remove_task(id+TASK_PROTECTION)

	g_respawning[id] = 0
	g_protection[id] = 0
	update_player_scenario(id)

	if (is_user_alive(id)) fm_set_rendering(id)
}
////////////stock////////////
stock reset_frags_deaths(attacker)
{
	if (!is_user_connected(attacker)) return;

	set_pev(attacker, pev_frags, 0)
	message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
	write_byte(attacker)
	write_short(0)
	write_short(0)
	write_short(0)
	write_short(get_user_team(attacker))
	message_end()

	set_pdata_int(attacker, OFFSET_CSDEATHS, 0)
	message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
	write_byte(attacker) // id
	write_short(0) // frags
	write_short(0) // deaths
	write_short(0) // class?
	write_short(get_user_team(attacker)) // team
	message_end()
}
stock Set_Kvd(entity, const key[], const value[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	dllfunc(DLLFunc_KeyValue, entity, 0)
}

stock update_frags_deaths(attacker, victim, num, add=0)
{
	if (!is_user_connected(attacker)) return;
	if (!is_user_connected(victim)) return;

	new frags, deaths
	if (add)
	{
		frags = pev(attacker, pev_frags) + num
		deaths = get_user_deaths(victim) + num
	}
	else
	{
		frags = num
		deaths = num
	}
	set_pev(attacker, pev_frags, float(frags))
	message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
	write_byte(attacker)
	write_short(pev(attacker, pev_frags))
	write_short(get_user_deaths(attacker))
	write_short(0)
	write_short(get_user_team(attacker))
	message_end()

	set_pdata_int(victim, OFFSET_CSDEATHS, deaths)
	message_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
	write_byte(victim) // id
	write_short(pev(victim, pev_frags)) // frags
	write_short(deaths) // deaths
	write_short(0) // class?
	write_short(get_user_team(victim)) // team
	message_end()
}
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)

	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
}
stock fm_set_user_godmode(index, godmode = 0)
{
	set_pev(index, pev_takedamage, godmode == 1 ? DAMAGE_NO : DAMAGE_AIM)
	return 1;
}
stock fm_get_user_godmode(index)
{
	new Float:val;
	pev(index, pev_takedamage, val);

	return (val == DAMAGE_NO);
}
stock bool:fm_strip_user_gun(index, wid = 0, const wname[] = "")
{
	new ent_class[32];
	if (!wid && wname[0])
		copy(ent_class, sizeof ent_class - 1, wname);
	else {
		new weapon = wid, clip, ammo;
		if (!weapon && !(weapon = get_user_weapon(index, clip, ammo)))
			return false;

		get_weaponname(weapon, ent_class, sizeof ent_class - 1);
	}

	new ent_weap = fm_find_ent_by_owner(-1, ent_class, index);
	if (!ent_weap)
		return false;

	engclient_cmd(index, "drop", ent_class);

	new ent_box = pev(ent_weap, pev_owner);
	if (!ent_box || ent_box == index)
		return false;

	dllfunc(DLLFunc_Think, ent_box);

	return true;
}
stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0)
{
	new strtype[11] = "classname", ent = index;
	switch (jghgtype) {
		case 1: strtype = "target";
		case 2: strtype = "targetname";
	}

	while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}

	return ent;
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

load_customization_from_files()
{
	new path[64]
	format(path, charsmax(path), "addons/amxmodx/configs/%s", SETTING_FILE)

	if (!file_exists(path))
	{
		new error[100]
		formatex(error, charsmax(error), "Cannot load customization file %s!", path)
		set_fail_state(error)
		return;
	}

	new linedata[1024], key[64], value[960], section

	new file = fopen(path, "rt")

	while (file && !feof(file))
	{
		fgets(file, linedata, charsmax(linedata))

		replace(linedata, charsmax(linedata), "^n", "")

		if (!linedata[0] || linedata[0] == ';') continue;

		if (linedata[0] == '[')
		{
			section++
			continue;
		}

		strtok(linedata, key, charsmax(key), value, charsmax(value), '=')

		trim(key)
		trim(value)

		switch (section)
		{
			case SECTION_CONFIG_VALUE:
			{
				if (equal(key, "HUMAN_ARMOR"))
					g_human_armor = str_to_num(value)
				else if (equal(key, "WEAPONS_STAY"))
					g_weapons_stay = str_to_float(value)
				else if (equal(key, "ROUND_TIME"))
					g_round_time = str_to_num(value)
				else if (equal(key, "TICKETS"))
					g_tickets = str_to_num(value)
				else if (equal(key, "RESPAWN_WAIT"))
					g_respawn_wait = str_to_float(value)
				else if (equal(key, "PROTECTION_TIME"))
					g_protection_time = str_to_float(value)
				else if (equal(key, "PROTECTION_COLOR"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)
						ArrayPushCell(g_protection_color, str_to_num(key))
					}
				}
			}
			case SECTION_MAP_CONTINUE:
			{
				if (equal(key, "MAP_CONTINUE"))
					g_map_continue = str_to_num(value)
				if (equal(key, "MAP_SEQUENCE"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(g_map_sequence, key)
					}
				}
			}
			case SECTION_OBJECTIVE_ENTS:
			{
				if (equal(key, "CLASSNAMES"))
				{
					while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ','))
					{
						trim(key)
						trim(value)

						ArrayPushString(g_objective_ents, key)
					}
				}
			}
		}
	}
	if (file) fclose(file)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg936\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset134 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2052\\ f0\\ fs16 \n\\ par }
*/
