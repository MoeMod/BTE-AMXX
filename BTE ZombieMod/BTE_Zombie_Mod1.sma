#include <amxmodx>
#include <amxmisc>
#include <metahook>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <xs>
#include <round_terminator>

#include "BTE_ZM.inc"
#include "BTE_API.inc"
#include "offset.inc"

native GetLightStyle()

#define PLUGIN_NAME	"Zombie Mode 1"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"NoName"

#define is_zombie(%1)	g_team[%1]==ZOMBIE
#define is_human(%1)	g_team[%1]==HUMAN


#define PRINT(%1)	client_print(0,print_console,%1)

native BTE_MVPBoard(iWinningTeam, iType, iPlayer = 0);

//-----------------------------Var--------------------------------
new g_team[33],g_have_nvg[33],g_nvg[33],g_level[33];

new g_msgStatusIcon, g_msgTextMsg, g_msgScreenFade, g_msgDeathMsg, g_msgScoreAttrib, g_msgScoreInfo;
new g_fw_UserInfected, g_fw_DummyResult;
new g_count_down/*,g_round_check*/;
new g_round_status;
new g_hamczbots;

new g_light[2];

new g_zombie_index_host, g_zombie_index_origin;
new g_EnteredBuyMenu[33];
//new Float:g_roundstartime,Float:g_roundtime

//-----------------------------Init-------------------------------
public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_event("HLTV","Event_RoundStart","a","1=0","2=0");
	register_logevent("LogEvent_RoundStart",2,"1=Round_Start");
	register_logevent("LogEvent_RoundEnd",2,"1=Round_End");
	register_dictionary("bte_zombie.bte")
	
	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player");
	RegisterHam(Ham_Spawn, "player", "HamF_PlayerSpawn_Post", 1);
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage");
	RegisterHam(Ham_Touch, "weaponbox", "HamF_TouchWeaponBox");
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "HamF_ZombieDeploy",1);
	RegisterHam(Ham_Killed, "player", "HamF_Killed_Post",1)
	
	register_forward(FM_PlayerPostThink, "Forward_PlayerPostThink", 1);
	register_forward(FM_EmitSound, "Forward_EmitSound");
	register_forward(FM_ClientCommand, "Forward_ClientCommand")
	register_forward(FM_ClientKill, "Forward_ClientKill");
	
	g_msgDeathMsg = get_user_msgid("DeathMsg");
	g_msgScoreAttrib = get_user_msgid("ScoreAttrib");
	g_msgScoreInfo = get_user_msgid("ScoreInfo");
	g_msgScreenFade = get_user_msgid("ScreenFade");
	g_msgStatusIcon = get_user_msgid("StatusIcon");
	g_msgTextMsg = get_user_msgid("TextMsg");
	register_message(g_msgStatusIcon, "Message_StatusIcon");
	register_message(g_msgTextMsg, "Message_TextMsg");
	
	server_cmd("bte_wpn_buyzone 0");
	server_cmd("bte_wpn_free 1");
	
	g_light[0] = GetLightStyle();
	g_light[1] = 0;

	g_fw_UserInfected = CreateMultiForward("bte_zb_infected", ET_IGNORE, FP_CELL, FP_CELL);
}
public plugin_cfg()
{
	new cfgdir[32]
	get_configsdir(cfgdir, charsmax(cfgdir))
	
	server_cmd("exec %s/%s", cfgdir, "bte_zombiemod.cfg")
}
public client_disconnect(id)
{
	//PRINT("discount:%d",id)

	/*if(GetPlayer(ZOMBIE,1)<=0 && GetPlayer(ALL,1)>=2 && g_round_status==START)
	{
		client_print(0,print_chat,"%L",LANG_PLAYER,"BTE_ZB_LAST_ZOMBIE_AWAY")
		Make_First_Zombie()
		//TerminateRound( RoundEndType_TeamExtermination,TeamWinning_Ct )
	}*/
}
public plugin_precache()
{
	g_zombie_index_host = engfunc(EngFunc_PrecacheModel,MDL_ZOMBIE_HOST);
	g_zombie_index_origin = engfunc(EngFunc_PrecacheModel,MDL_ZOMBIE_ORIGIN);
	
	for(new i=0;i<2;i++)
	{
		precache_sound(SND_ZOMBIE_HURT[i]);
		precache_sound(SND_ZOMBIE_INFECTION_MALE[i]);
		precache_sound(SND_ZOMBIE_INFECTION_FEMALE[i]);
		precache_sound(SND_ZOMBIE_DEATH[i]);
		precache_sound(SND_ZOMBIE_COMING[i]);
	}
	
	precache_model(MDL_ZOMBIE_HAND);
}
public client_putinserver(id)
{
	/*if (is_user_bot(id) && !g_hamczbots && cvar_botquota)
	{
		set_task(0.1, "Task_Register_Bot", id)
	}*/
	set_task(random_float(0.5,1.0),"MakeHuman",id);

	g_EnteredBuyMenu[id] = 0;
	
	//if(GetPlayer(ALL)>=2) remove_task(TASK_WAITTEXT)
	
	if (is_user_zbot(id) && !g_hamczbots)
	{
		set_task(0.1, "Task_Register_Bots", id)
	}
}

public LogEvent_RoundEnd()
{
	if(task_exists(TASK_FORCEWIN)) remove_task(TASK_FORCEWIN);
	CheckWinRound();
}

public LogEvent_RoundStart()
{	
	//if(g_total_player[HUMAN]<=1) return;
	new Float:round_time;
	round_time = get_cvar_float("mp_roundtime") * 60.0;
	
	if (task_exists(TASK_ROUNDSTART)) remove_task(TASK_ROUNDSTART);
	//if (task_exists(TASK_WAITTEXT)) remove_task(TASK_WAITTEXT);
	
	
	g_count_down = COUNT_DOWN_START;
	if(GetPlayer(ALL,1)>=2)
	{
		SetBlockRound(1);
		g_round_status = COUNT;
		PlaySound(0, SND_ROUND_START);
		//PlaySound(0, SND_COUNT_START);
		Task_CountDown()
		set_task(1.0, "Task_CountDown", TASK_ROUNDSTART, _, _, "b");
		if(task_exists(TASK_FORCEWIN)) remove_task(TASK_FORCEWIN);
		set_task(round_time,"HumanWin",TASK_FORCEWIN);
	}	
	/*else
	{
		Task_WaitText();
		set_task(1.0, "Task_WaitText", TASK_WAITTEXT, _, _, "b");
	}*/
}

public Event_DeathMsg()
{
	//CheckWinRound();
}

native PlayerSpawn(id);

public Event_RoundStart()
{	
	g_round_status = FREEZE;
	server_cmd("sv_noroundend 0")

	//if(task_exists(TASK_FORCEWIN)) remove_task(TASK_FORCEWIN);
	for(new id=1;id<33;id++)
	{
		g_level[id] = 0;
		g_team[id] = HUMAN;
		if(is_user_connected(id))
		{
			SetLight(id, g_light);
			//g_round_check = 1;
			//set_task(random_float(0.5,1.0),"MakeHuman",id);
			//MakeHuman(id);
			
			//StripWeapon(id);
			
			//bte_wpn_give_named_wpn(id,"usp");
		}
	}

	PlayerSpawn(0);
}
//-----------------------------Ham--------------------------------
public HamF_Spawn_Player(id)
{
	set_pdata_int(id, m_iTeam, 2);
	
	return HAM_IGNORED;
}

public HamF_PlayerSpawn_Post(id)
{
	set_pdata_int(id, m_iKevlar, 2);
	
	if (g_team[id] == HUMAN)
		MakeHuman(id);
}

public HamF_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if (g_round_status!=START) return HAM_SUPERCEDE;
	if (attacker > 32 || victim > 32) return HAM_IGNORED;
	if (is_zombie(attacker) && inflictor > 32) return HAM_SUPERCEDE;
	if (victim == attacker) return HAM_IGNORED;
	if (!is_user_connected(victim) || !is_user_connected(attacker)) return HAM_IGNORED;
	if (damage_type & (1<<24)) return HAM_IGNORED;
	
	if (is_zombie(attacker) && is_human(victim))
	{
		ZombieInfectedHuman(attacker,  victim);
		return HAM_SUPERCEDE;
	}
	if (is_zombie(victim) && is_human(attacker))
	{
		damage *= ZOMBIE_XDAMAGE;
		SetHamParamFloat(4, damage);
		return HAM_IGNORED;
	}
	return HAM_IGNORED
}
public HamF_ZombieDeploy(iEnt)
{
	static id;
	id = get_pdata_cbase(iEnt, m_pPlayer, 4);
	if(is_zombie(id)) SetZombieViewModel(id);
	
	return HAM_IGNORED;
}
public HamF_TouchWeaponBox(weapon, id)
{
	if (!is_user_connected(id)) return HAM_IGNORED;
	if (is_zombie(id)) return HAM_SUPERCEDE;
	return HAM_IGNORED;
}
public HamF_Killed_Post(victim,killer,gib)
{
	MH_SendZB3Data(victim, 12, 0);
	HumanKilledZombie(killer, victim);
}
/*public HamF_Set_Player_Maxspeed_Post(id)
{
	if(!is_user_alive(id)) return HAM_IGNORED

	if(is_zombie(id)) set_pev(id,pev_maxspeed,ZOMBIE_MAXSPEED)
	return HAM_IGNORED
}*/
//-----------------------------Message----------------------------
public Message_StatusIcon(msgid, msgdest, id)
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
public Message_TextMsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))
	/*if (equal(textmsg, "#Game_will_restart_in"))
	{
		g_score_human = 0
		g_score_zombie = 0
		LogEvent_RoundEnd()
	}
	else */if (equal(textmsg, "#Game_Commencing"))
	{
		//g_startcount = 1
		server_cmd("mp_autoteambalance 0")
	}
	else if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win"))
	{
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

//-----------------------------Forward----------------------------
public Forward_PlayerPostThink(id)
{
	if (is_zombie(id))
		set_pev(id, pev_maxspeed, ZOMBIE_MAXSPEED);
}
public Forward_ClientCommand(id)
{
	static szCommand[24];
	read_argv(0, szCommand, charsmax(szCommand));
	
	if(!strcmp(szCommand, "nightvision"))
	{
		cmd_nightvision(id);
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED
}

public Forward_ClientKill(id)
{
	return FMRES_SUPERCEDE
}

public Forward_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if(strlen(sample) > 6)
		if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
			return FMRES_SUPERCEDE;
	
	if (!is_user_connected(id) || is_human(id))
		return FMRES_IGNORED;
	
	// Zombie being hit
	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't' ||
	sample[7] == 'h' && sample[8] == 'e' && sample[9] == 'a' && sample[10] == 'd')
	{
		emit_sound(id, channel, SND_ZOMBIE_HURT[random_num(0,1)], volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}
	
	// Zombie dies
	if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
	{
		emit_sound(id, channel, SND_ZOMBIE_DEATH[random_num(0,1)], volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}

	/*if (equal(sample,"weapons/knife_hitwall1.wav"))
	{
		emit_sound(id, channel, SND_ZOMBIE_HITWALL[random_num(0,2)], volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}
	
	else if (equal(sample,"weapons/knife_hit1.wav") ||
	equal(sample,"weapons/knife_hit3.wav") ||
	equal(sample,"weapons/knife_hit2.wav") ||
	equal(sample,"weapons/knife_hit4.wav") ||
	equal(sample,"weapons/knife_stab.wav"))
	{
		emit_sound(id, channel, SND_ZOMBIE_HIT[random_num(0,2)], volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}
	else if(equal(sample,"weapons/knife_slash1.wav") ||
	equal(sample,"weapons/knife_slash2.wav"))
	{
		emit_sound(id, channel, SND_ZOMBIE_SWING[random_num(0,2)], volume, attn, flags, pitch)
		return FMRES_SUPERCEDE;
	}*/
	return FMRES_IGNORED;
}

//-----------------------------Public-----------------------------
public HumanWin()
{
	if(task_exists(TASK_FORCEWIN)) remove_task(TASK_FORCEWIN);
	TerminateRound( RoundEndType_TeamExtermination,TeamWinning_Ct );
	BTE_MVPBoard(2, 0);
}
public CheckWinRound()
{
	if (GetPlayer(ALL,1)<=1) return;
	//if (!g_round_check) return;
	
	if (!GetPlayer(HUMAN,1))
	{
		server_cmd("sv_noroundend 1")
		PlaySound(0, SND_WIN[ZOMBIE]);
		//MH_DrawTargaImage(0,"mode\\zb3\\zombiewin",1,1,255,255,255,0.5,0.35,0,11,4.0);
		BTE_MVPBoard(1, 0);
	}
	else
	{
		server_cmd("sv_noroundend 1")
		PlaySound(0, SND_WIN[HUMAN]);
		//MH_DrawTargaImage(0,"mode\\zb3\\humanwin",1,1,255,255,255,0.5,0.35,0,11,4.0);
		BTE_MVPBoard(2, 0);
	}
	g_round_status = END;
}
public HumanKilledZombie(killer, victim)
{
	if(is_human(victim)) return;
	
	UpdateFrags(killer,2)
	UpdateDeaths(victim, 2)
	
	if(!GetPlayer(ZOMBIE, 1) && victim != killer)
		HumanWin()

}

public ZombieInfectedHuman(attacker, victim)
{
	static sex;
	new Float:health,Float:newhealth;
	
	SendInfectMsg(attacker, victim);
	
	UpdateFrags(attacker, 1);
	UpdateDeaths(victim, 1);
	
	pev(attacker,pev_health,health);
	newhealth = 500.0 * floatround(health / 500 / 2);
	if(newhealth<=ZOMBIE_MIN_HEALTH)
		MakeZombie(victim,ZOMBIE_MIN_HEALTH);
	else
		MakeZombie(victim,newhealth);
		
	MH_PlayBink(victim,"infection.bik",0.5,0.5,255,255,255,0,1,1,0);
	
	sex = bte_get_user_sex(victim);
	if(sex == SEX_MALE) emit_sound(victim, CHAN_VOICE, SND_ZOMBIE_INFECTION_MALE[random_num(0,1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	else emit_sound(victim, CHAN_VOICE, SND_ZOMBIE_INFECTION_FEMALE[random_num(0,1)], 1.0, ATTN_NORM, 0, PITCH_NORM)	
	
	set_task(0.2, "Task_InfectedSound", victim+TASK_INFECTEDSOUND);
	
	ExecuteForward(g_fw_UserInfected, g_fw_DummyResult, victim, attacker);

	if(!GetPlayer(HUMAN,1))
	{
		server_cmd("sv_noroundend 0");
		TerminateRound( RoundEndType_TeamExtermination,TeamWinning_Terrorist );
	}
}

public MakeHuman(id)
{
	if(!is_user_alive(id)) return;
	
	//SetTeam(id,_:CS_TEAM_CT);
	
	set_pev(id,pev_health, 1000.0);
	set_pev(id,pev_max_health, 1000.0);
	set_pev(id,pev_armorvalue, 100.0);
	set_pev(id,pev_gravity, 1.0);

	g_have_nvg[id] = 0;
	
	//g_have_nvg[id] = 1;
	//g_nvg[id] = 1;
	//cmd_nightvision(id);
	SetPlayerModel(id);
	
	StripWeapon(id);
	bte_wpn_give_named_wpn(id, "knife", 1);
	bte_wpn_give_named_wpn(id, "usp", 1);
	
	if (!g_EnteredBuyMenu[id])
		PlayerSpawn(id);
}

public MakeZombie(id,Float:health)
{
	if(!is_user_alive(id)) return;
	
	g_team[id] = ZOMBIE;
	SetTeam(id, _:CS_TEAM_T);
	
	set_pev(id, pev_health, health);
	set_pev(id, pev_max_health, health);
	set_pdata_int(id, m_iKevlar, 2);
	set_pev(id, pev_armorvalue, health * 0.1);
	set_pev(id, pev_gravity, 0.8);
	set_pev(id, pev_maxspeed, ZOMBIE_MAXSPEED);
	
	g_have_nvg[id] = 1;
	g_nvg[id] = 1;
	Nvg(id);
	
	StripWeapon(id);
	OffFlashLight(id);
	
	bte_wpn_give_named_wpn(id, "knife", 0);
	//bte_wpn_set_playerwpn_model(id,0,"",0,0);
	set_pev(id, pev_weaponmodel2, 0);
	
	SetZombieViewModel(id);
	SetPlayerModel(id);
	
	//bte_wpn_set_maxspeed(id,ZOMBIE_MAXSPEED);
}
public Make_First_Zombie()
{
	new iTotal, id
	iTotal = (GetPlayer(HUMAN,1)) / 10 + 1;
	if(!iTotal) iTotal = 1;
	new Float:fMaxHealth,iX;
	iX = (GetPlayer(HUMAN,1) - 4) / 2
	fMaxHealth = 1000.0 * iX + ZOMBIE_START_HEALTH;
	if(fMaxHealth < ZOMBIE_START_HEALTH) fMaxHealth = ZOMBIE_START_HEALTH;
	//client_print(0,print_console,"¹²Éú³É%d¸ö½©Ê¬",iTotal);
	while (iTotal)
	{
		id = random_num(1,GetPlayer(ALL));
		if(is_user_alive(id) && is_user_connected(id) && is_human(id))
		{
			g_level[id] = 1;
			MakeZombie(id, fMaxHealth);
			MH_PlayBink(id,"origin.bik",0.5,0.5,255,255,255,0,1,1,0)
			//client_print(0,print_console,"±ä³É½©Ê¬:%d",id);
			ExecuteForward(g_fw_UserInfected, g_fw_DummyResult, id, 0);			
			iTotal--;
		}
		if(GetPlayer(HUMAN)<=1) break;
	}
	PlaySound(0,SND_ZOMBIE_COMING[random_num(0,1)])
}

//-----------------------------Cmd--------------------------------
public cmd_nightvision(id)
{
	if(!is_user_alive(id) || !g_have_nvg[id]) return PLUGIN_HANDLED;
	g_nvg[id] = 1 - g_nvg[id];
	if(g_nvg[id])
	{		
		Nvg(id);
	}
	else
	{
		MH_SendZB3Data(id, 12, 0);
		SetLight(id, g_light);
		message_begin(MSG_ONE, g_msgScreenFade, _, id);
		write_short(0); // duration
		write_short(0); // hold time
		write_short(0x0000); // fade type
		write_byte(100); // red
		write_byte(100); // green
		write_byte(100); // blue
		write_byte(255); // alpha
		message_end();
	}
	PlaySound(id,g_nvg[id]?SND_NVG[1]:SND_NVG[0]);
	return PLUGIN_HANDLED;
}

//-----------------------------Task-------------------------------
public Task_SetLight(id)
{
	SetLight(id,"k")	
}
public Task_CountDown()
{
	new  sound_count[64]
	if (!g_count_down)
	{
		g_round_status=START;
		PlaySound(0, SND_BGM);
		Make_First_Zombie();
		remove_task(TASK_ROUNDSTART);
	}
	else
	{
		if (g_count_down<=10)
		{
			format(sound_count, charsmax(sound_count), "%s", SND_COUNT[g_count_down-1]);
			PlaySound(0, sound_count);
		}
		//format(message, charsmax(message), "%L", LANG_PLAYER, "BTE_ZB_TIMEREMAINING", g_count_down);
		new szSecond[3];
		num_to_str(g_count_down, szSecond, 2);
		message_begin(MSG_ALL, g_msgTextMsg);
		write_byte(4);
		write_string("#CSO_ZombiSelectCount");
		write_string(szSecond);
		message_end();
	}
	g_count_down -= 1;
}

/*public Task_WaitText()
{
	client_print(0, print_center, "%L", LANG_PLAYER, "BTE_WAITING");
}*/
public Task_InfectedSound(taskid)
{
	for(new id=1;id<33;id++)
	{
		if(is_user_alive(id)/* && is_human(id)*/) PlaySound(id,SND_ZOMBIE_COMING[random_num(0,1)]);
	}
	if (task_exists(taskid)) remove_task(taskid);
}

public Task_Register_Bots(id)
{
	if (g_hamczbots || !is_user_connected(id)) return;
			
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player");
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_PlayerSpawn_Post", 1);
	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage");
	RegisterHamFromEntity(Ham_Killed, id, "HamF_Killed_Post", 1);
	g_hamczbots = 1;
	//if (is_user_alive(id)) fw_PlayerSpawn_Post(id)
}
public Task_SetTeam(params[], taskid)
{
	new id = taskid - TASK_TEAM;
	new team = params[0];
	cs_set_user_team(id, team, 0);
	if (task_exists(id+TASK_TEAM)) remove_task(id+TASK_TEAM);
}
//-----------------------------Stock------------------------------
stock SetTeam(id, team)
{
	static params[1];
	params[0] = team;
	if (task_exists(id+TASK_TEAM)) remove_task(id+TASK_TEAM);
	set_task(0.1, "Task_SetTeam", id+TASK_TEAM, params, sizeof params);
	set_pdata_int(id, 114, team);
}
stock SetZombieViewModel(id)
{
	if(is_user_alive(id))
		set_pev(id, pev_viewmodel2, MDL_ZOMBIE_HAND);
}
stock Nvg(id)
{
	MH_SendZB3Data(id, 12, 1);
	SetLight(id,"1");
	message_begin(MSG_ONE, g_msgScreenFade, _, id);
	write_short((1<<12)*2); // duration
	write_short((1<<10)*10); // hold time
	write_short(0x0004); // fade type
	if(is_zombie(id))
	{
		write_byte(NVG_ZOMBIE_R); // red
		write_byte(NVG_ZOMBIE_G); // green
		write_byte(NVG_ZOMBIE_B); // blue
		write_byte(NVG_ZOMBIE_A); // alpha
	}
	else
	{
		write_byte(NVG_HUMAN_R); // red
		write_byte(NVG_HUMAN_G); // green
		write_byte(NVG_HUMAN_B); // blue
		write_byte(NVG_HUMAN_A); // alpha
	}
	message_end();
}

stock GetPlayer(team,alive=0)
{
	new a;
	for(new i=1;i<33;i++)
	{
		if((g_team[i]==team || team==ALL) && (is_user_alive(i) || !alive) && is_user_connected(i))	a += 1;
	}
	return a;
}
stock SetLight(id,light[])
{
	if(!is_user_connected(id)) return

	message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, id)
	write_byte(0)
	write_string(light)
	message_end()
}
stock PlaySound(id, const sound[])
{
	if (equal(sound[strlen(sound)-4], ".mp3"))
	{
		client_cmd(id,"mp3 stop")
		client_cmd(id,"mp3 play sound/%s", sound)
	}
	else
		client_cmd(id,"spk ^"sound/%s^"", sound)
}
stock StripWeapon(id)
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
	if (!pev_valid(ent)) return;
	
	dllfunc(DLLFunc_Spawn, ent)
	dllfunc(DLLFunc_Use, ent, id)
	if (pev_valid(ent)) engfunc(EngFunc_RemoveEntity, ent)
}
stock Set_Kvd(entity, const key[], const value[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	dllfunc(DLLFunc_KeyValue, entity, 0)
}
stock SendInfectMsg(attacker, victim)
{
	message_begin(MSG_BROADCAST, g_msgScoreAttrib)
	write_byte(attacker) // id
	write_byte(0) // attrib
	message_end()
	
	message_begin(MSG_BROADCAST, g_msgDeathMsg)
	write_byte(attacker) 
	write_byte(victim) 
	write_byte(0) 
	write_string("knife")
	message_end()
}
stock UpdateFrags(player, num)
{
	if (!is_user_connected(player)) return;
	
	set_pev(player, pev_frags, float(pev(player, pev_frags) + num))
	message_begin(MSG_BROADCAST, g_msgScoreInfo)
	write_byte(player) // id
	write_short(pev(player, pev_frags)) // frags
	write_short(get_user_deaths(player)) // deaths
	write_short(0) // class?
	write_short(get_user_team(player)) // team
	message_end()
}
stock UpdateDeaths(player, num)
{
	if (!is_user_connected(player)) return;
	
	new deaths = get_user_deaths(player) + num
	cs_set_user_deaths(player, deaths)
	message_begin(MSG_BROADCAST, g_msgScoreInfo)
	write_byte(player) // id
	write_short(pev(player, pev_frags)) // frags
	write_short(deaths) // deaths
	write_short(0) // class?
	write_short(get_user_team(player)) // team
	message_end()
}
stock OffFlashLight(id)
{
	// Restore batteries for the next use
	set_pdata_int(id, 244, 100, 5)
	
	// Check if flashlight is on
	if (pev(id, pev_effects) & EF_DIMLIGHT)
	{
		// Turn it off
		set_pev(id, pev_impulse, 100)
	}
	else
	{
		// Clear any stored flashlight impulse (bugfix)
		set_pev(id, pev_impulse, 0)
	}
	
	// Update flashlight HUD
	message_begin(MSG_ONE, get_user_msgid("Flashlight"), _, id)
	write_byte(0) // toggle
	write_byte(100) // battery
	message_end()
}

stock SetBlockRound(iBlock)
{
	server_cmd("sv_noroundend %d",iBlock)
}

stock SetPlayerModel(id)
{	
	if (!is_user_connected(id)) return;
	if (is_zombie(id))
	{
		//new model_view[64], model_index, idclass
		//idclass = g_zombieclass[id]
		if (g_level[id]==1)
		{
			bte_set_user_model(id, MDL_ORIGIN);
			bte_set_user_model_index(id, g_zombie_index_origin);
		}
		else
		{
			bte_set_user_model(id, MDL_HOST);
			bte_set_user_model_index(id, g_zombie_index_host);
			
		}
	}
	else
	{
		bte_reset_user_model(id)
	}
}
stock CheckHull(Float:origin[3], id)
{	
	static iTr
	new hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id,iTr)
	
	if (!get_tr2(iTr, TR_StartSolid) && !get_tr2(iTr, TR_AllSolid)/* && get_tr2(0, TR_InOpen)*/)
	{
		return true;
	}
	else
	{
		return false;
	}
	return false;
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

//-----------------------------Native-----------------------------
public plugin_natives()
{
	register_native("bte_get_user_zombie","native_is_zombie",1);
}

public native_is_zombie(id)
{
	if (id <= 0 || id >= 33)
		return 0;
	
	return is_zombie(id);
}