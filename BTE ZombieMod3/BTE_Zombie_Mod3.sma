#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta_util>
#include <hamsandwich>
#include <orpheu>
#include <orpheu_memory>
#include <xs>
#include <round_terminator>
#include "offset.inc"
#include "bte_api.inc"
#include "metahook.inc"
#include "cdll_dll.h"
#include "ZombieMod3/inc.inc"
#include "ZombieMod3/bits.inc"

#define PLUGIN "BTE Zombie Mod3"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#include "ZombieMod3/Vars.sma"

#include "ZombieMod3/DNA.sma"
#include "ZombieMod3/ZbClassBuff.sma"
#include "ZombieMod3/SupplyBox.sma"

#include "ZombieMod3/Task.sma"
#include "ZombieMod3/Util.sma"
#include "ZombieMod3/Public.sma"
#include "ZombieMod3/ReadFile.sma"
#include "ZombieMod3/Forward.sma"
#include "ZombieMod3/Ham.sma"
#include "ZombieMod3/EventCmd.sma"
#include "ZombieMod3/Natives.sma"
#include "ZombieMod3/Menu.sma"
#include "ZombieMod3/Stocks.sma"
// ==================================================================

//#define _DEBUG

#define PRINT(%1) client_print(1,print_chat,%1)

public sb(id)
{
	new sCmd[32]
	read_argv(1,sCmd,31)

	UpdateHumanLevel(id,str_to_num(sCmd))
}
public sb3(id)
{
	g_evolution[id] = 100.0
	CheckEvolution(id)
}
#if defined _DEBUG
public sb1(id)
{
	SetRendering(id)

	g_level[id] = 1;

	set_pdata_int(id, 114, 1);

	Make_Zombie(id,1)

	message_begin(MSG_ALL, g_msgTeamInfo)
	write_byte(id)
	write_string("TERRORIST")
	message_end()

	set_pev(id,pev_health,10.0)
	ShowZombieMenu(id)
}
public sb2(id)
{
	Make_Human(id)
	bte_reset_user_model(id)
}
#endif


new bot_quota

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_dictionary("bte_zombie.bte")
	/*register_concmd("test","test")
	register_concmd("morale","sb")
	register_concmd("evolution","sb3")*/

#if defined _DEBUG
	register_concmd("zombie","sb1")
	register_concmd("human","sb2")
	register_concmd("hero","Make_Hero")
#endif

	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0")
	register_logevent("LogEvent_RoundStart",2, "1=Round_Start")
	register_logevent("LogEvent_RoundEnd", 2, "1=Round_End")
	register_event("DeathMsg", "Event_DeathMsg", "a")
	//register_event("CurWeapon","Event_CurWeapon","be","1=1")
	register_clcmd("chooseteam","Cmd_ChooseTeam")
	register_clcmd("BTE_ZombieSkill1","Cmd_ZombieSkill1")
	register_clcmd("BTE_ZombieSkill2","Cmd_ZombieSkill2")
	register_clcmd("weapon_zombibomb","Cmd_Redirect")
	register_clcmd("weapon_zombibomb2","Cmd_Redirect2")
	register_clcmd("bte_zb3_select_zombie","SelectZombie")
	register_clcmd("bte_normal_zombie","NormalZombie")
	register_concmd("givezombiebomb", "CmdFunc_GiveZombieBomb");

	/*set_cvar_num("sv_skycolor_r",0);
	set_cvar_num("sv_skycolor_g",0);
	set_cvar_num("sv_skycolor_b",0);*/

	// HAM Forwards
	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player");
	RegisterHam(Ham_Spawn, "player", "HamF_Spawn_Player_Post",1)
	RegisterHam(Ham_Killed, "player", "HamF_Killed")
	RegisterHam(Ham_Killed, "player", "HamF_Killed_Post",1)
	RegisterHam(Ham_TraceAttack, "player", "HamF_TraceAttack")
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage")
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage_Post", 1)
	RegisterHam(Ham_Touch, "weaponbox", "HamF_TouchWeaponBox")
	RegisterHam(Ham_Think, "grenade", "HamF_Grenade_Think")
	RegisterHam(Ham_Touch, "grenade", "HamF_Grenade_Touch")
	RegisterHam(Ham_Item_Deploy, "weapon_hegrenade", "HamF_ZombieDeploy",1)
	RegisterHam(Ham_Item_Deploy, "weapon_smokegrenade", "HamF_ZombieDeploy",1)
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "HamF_ZombieDeploy",1)

	RegisterHam(Ham_ObjectCaps, "info_target", "HamF_InfoTarget_ObjectCaps");
	RegisterHam(Ham_Use, "info_target", "SupplyBox_Use");

	//RegisterHam(Ham_Touch, "info_target", "HamF_TouchSupplyBox")


	// FM Forwards
	g_fwHamBotRegister = register_forward(FM_PlayerPostThink, "fw_BotRegisterHam", 1)
	//register_forward(FM_PlayerPreThink, "Forward_PlayerPreThink")
	//register_forward(FM_CmdStart, "Forward_CmdStart")
	register_forward(FM_EmitSound, "Forward_EmitSound")
	register_forward(FM_SetModel, "Forward_SetModel")
	register_forward(FM_ClientKill, "Forward_ClientKill")
	register_forward(FM_PlayerPostThink, "Forward_PlayerPostThink", 1)
	//register_forward(FM_AddToFullPack, "Forward_AddToFullPack");
	unregister_forward(FM_Spawn, g_fwSpawn)
	
	// Orpheu Forwards
	OrpheuRegisterHook(OrpheuGetFunction("Radio", "CBasePlayer"), "OnRadio_Pre", OrpheuHookPre);

	// Message ID
	g_msgDeathMsg = get_user_msgid("DeathMsg")
	g_msgScoreAttrib = get_user_msgid("ScoreAttrib")
	g_msgStatusIcon = get_user_msgid("StatusIcon")
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	g_msgScenario = get_user_msgid("Scenario")
	//g_msgDamage = get_user_msgid("Damage")
	g_msgHostagePos = get_user_msgid("HostagePos")
	//g_msgHostageK = get_user_msgid("HostageK")
	g_msgFlashBat = get_user_msgid("FlashBat")
	g_msgNVGToggle = get_user_msgid("NVGToggle")
	//g_msgWeapPickup = get_user_msgid("WeapPickup")
	//g_msgAmmoPickup = get_user_msgid("AmmoPickup")
	g_msgTextMsg = get_user_msgid("TextMsg")
	g_msgSendAudio = get_user_msgid("SendAudio")
	g_msgTeamScore = get_user_msgid("TeamScore")
	g_msgScreenFade = get_user_msgid("ScreenFade");
	g_msgHudTextArgs = get_user_msgid("HudTextArgs")
	g_msgClCorpse = get_user_msgid("ClCorpse")
	//g_msgVGUIMenu = get_user_msgid("VGUIMenu")
	g_msgScreenShake = get_user_msgid("ScreenShake")
	//g_msgHideWeapon = get_user_msgid("HideWeapon")
	//g_msgCrosshair = get_user_msgid("Crosshair")
	g_msgWeaponList = get_user_msgid("WeaponList")
	g_msgTeamInfo = get_user_msgid("TeamInfo")
	//g_msgMoney = get_user_msgid("Money")

	// Message hook
	set_msg_block(g_msgFlashBat,BLOCK_SET)
	//set_msg_block(g_msgNVGToggle,BLOCK_SET)
	set_msg_block(g_msgScenario,BLOCK_SET)
	set_msg_block(g_msgHostagePos,BLOCK_SET)
	set_msg_block(g_msgHudTextArgs,BLOCK_SET)
	//set_msg_block(g_msgMoney,BLOCK_SET)

	register_message(g_msgTextMsg, "Message_TextMsg")
	register_message(g_msgSendAudio, "Message_SendAudio")
	register_message(g_msgTeamScore, "Message_TeamScore")
	register_message(g_msgClCorpse, "Message_ClCorpse")
	register_message(g_msgStatusIcon, "Message_StatusIcon")
	//register_message(g_msgScoreInfo, "Message_ScoreInfo")
	register_message(g_msgNVGToggle, "Message_NVGToggle");

	register_clcmd("nightvision", "cmd_nightvision")
	//Cvar_Light = register_cvar("bte_zb3_light", "g")
	Cvar_HolsterBomb = register_cvar("bte_zb3_holster_zombiebomb","1")

	bot_quota = get_cvar_pointer("bot_quota")
	g_fwUserInfected = CreateMultiForward("bte_zb_infected", ET_IGNORE, FP_CELL, FP_CELL)
	g_fwRoundStart = CreateMultiForward("bte_zb3_round_start", ET_IGNORE);
	g_fwResetSkill = CreateMultiForward("bte_zb3_reset_skill", ET_IGNORE, FP_CELL);
	

	Load_PlayerSpawns()
	Load_BoxSpawns()

	server_cmd("bte_wpn_buyzone 0");
	server_cmd("bte_wpn_free 1");
	server_cmd("sypb_gamemode 2");
	server_cmd("mp_autoteambalance 0");
	//set_cvar_num("sv_skycolor_r", 255)
	//set_cvar_num("sv_skycolor_g", 255)
	//set_cvar_num("sv_skycolor_b", 255)

	g_bCanEnd = 0;
	
	gmsgNormalZombieMenu = engfunc(EngFunc_RegUserMsg, "ZombieMenu", -1);
	gmsgHealthExtra = engfunc(EngFunc_RegUserMsg, "HealthExtra", 2);
}
public plugin_precache()
{
	//precache_model("models/test.mdl")

	g_objective_ents = ArrayCreate(32, 1)
	sound_human_death = ArrayCreate(64, 1)
	sound_female_death = ArrayCreate(64, 1)
	sound_zombie_coming = ArrayCreate(64, 1)
	sound_zombie_comeback = ArrayCreate(64, 1)
	sound_zombie_attack = ArrayCreate(64, 1)
	sound_zombie_hitwall = ArrayCreate(64, 1)
	sound_zombie_swing = ArrayCreate(64, 1)

	// class zombie
	zombie_name = ArrayCreate(64, 1)
	zombie_model = ArrayCreate(64,1)
	zombie_gravity = ArrayCreate(1, 1)
	zombie_speed = ArrayCreate(1, 1)
	zombie_knockback = ArrayCreate(1, 1)
	zombie_sound_death1 = ArrayCreate(64, 1)
	zombie_sound_death2 = ArrayCreate(64, 1)
	zombie_sound_hurt1 = ArrayCreate(64, 1)
	zombie_sound_hurt2 = ArrayCreate(64, 1)
	zombie_viewmodel_host = ArrayCreate(64, 1)
	zombie_viewmodel_origin = ArrayCreate(64, 1)
	zombie_modelindex_host = ArrayCreate(1, 1)
	zombie_modelindex_origin = ArrayCreate(1, 1)
	zombie_wpnmodel = ArrayCreate(64, 1)
	zombie_wpnmodel2 = ArrayCreate(64, 1)
	zombie_sound_heal = ArrayCreate(64, 1)
	zombie_sound_evolution = ArrayCreate(64, 1)
	zombiebom_viewmodel = ArrayCreate(64, 1)
	zombiebom_viewmodel2 = ArrayCreate(64, 1)
	zombie_sex = ArrayCreate(1, 1)
	zombie_modelindex = ArrayCreate(1, 1)
	zombie_xdamage = ArrayCreate(1, 1)
	zombie_xdamage2 = ArrayCreate(1, 1)
	zombie_hosthand = ArrayCreate(1, 1)

	Load_Config()
	Load_Config_Map()


	new i, buffer[100]

	// Model hero
	format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", HERO_MODEL_MALE, HERO_MODEL_MALE)
	HERO_MODEL_MALE_INDEX = engfunc(EngFunc_PrecacheModel, buffer)
	format(buffer, charsmax(buffer), "models/player/%s/%s.mdl", HERO_MODEL_FEMALE, HERO_MODEL_FEMALE)
	HERO_MODEL_FEMALE_INDEX = engfunc(EngFunc_PrecacheModel, buffer)

	// Custom sounds
	/*for (i = 0; i < ArraySize(sound_zombie_coming); i++)
	{
		ArrayGetString(sound_zombie_coming, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}*/
	for (i = 0; i < ArraySize(sound_zombie_comeback); i++)
	{
		ArrayGetString(sound_zombie_comeback, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_human_death); i++)
	{
		ArrayGetString(sound_human_death, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_female_death); i++)
	{
		ArrayGetString(sound_female_death, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_zombie_attack); i++)
	{
		ArrayGetString(sound_zombie_attack, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_zombie_hitwall); i++)
	{
		ArrayGetString(sound_zombie_hitwall, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}
	for (i = 0; i < ArraySize(sound_zombie_swing); i++)
	{
		ArrayGetString(sound_zombie_swing, i, buffer, charsmax(buffer))
		engfunc(EngFunc_PrecacheSound, buffer)
	}

	precache_sound(SUPPLYBOX_SOUND_PICKUP)
	precache_sound(ZOMBIEBOM_SOUND_EXP)
	//precache_sound("weapons/m79_shoot1.wav")
	engfunc(EngFunc_PrecacheModel, SUPPLYBOX_MODEL)

	//cache_spr_restore_health = precache_model("sprites/zb_restore_health.spr")
	cache_spr_zombie_respawn = precache_model("sprites/zb_respawn.spr")
	precache_model("sprites/e_button01.spr");
	cache_spr_zombiebomb_exp = engfunc(EngFunc_PrecacheModel, "sprites/zombiebomb_exp.spr")
	engfunc(EngFunc_PrecacheModel, ZOMBIEBOMB_MODEL_P)
	engfunc(EngFunc_PrecacheModel, ZOMBIEBOMB_MODEL_P_GREEN)
	engfunc(EngFunc_PrecacheModel, ZOMBIEBOMB_MODEL_W)
	//engfunc(EngFunc_PrecacheSound, "")
	ZbClassBuff_Precache();

	RegisterHam(Ham_Precache, "hostage_entity", "HamF_HostagePrecache");

	new ent
	/*ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "hostage_entity"))
	if (pev_valid(ent))
	{
		engfunc(EngFunc_SetOrigin, ent, Float:{8192.0,8192.0,8192.0})
		dllfunc(DLLFunc_Spawn, ent)
	}*/
	if (g_ambience_fog)
	{
		ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
		if (pev_valid(ent))
		{
			Set_Kvd(ent, "density", g_fog_density, "env_fog")
			Set_Kvd(ent, "rendercolor", g_fog_color, "env_fog")
		}
	}
	if (g_ambience_rain) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_rain"))
	if (g_ambience_snow) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_snow"))

	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_map_parameters"))
	Set_Kvd(ent, "buying", "3", "info_map_parameters")
	dllfunc(DLLFunc_Spawn, ent)


	g_fwSpawn = register_forward(FM_Spawn, "Forward_Spawn")

	get_mapname(g_mapname, charsmax(g_mapname));
	if (g_sky_enable)
	{
		//if(!(g_mapname[0] == 'z' && g_mapname[1] == 'm'))
		set_cvar_string("sv_skyname", g_skyname)
	}

	/*while (ent = engfunc(EngFunc_FindEntityByString, -1, "classname", "func_buyzone"))
engfunc(EngFunc_RemoveEntity, ent)*/

	OrpheuRegisterHook(OrpheuGetFunction("InstallGameRules"), "OnInstallGameRules", OrpheuHookPost)
}
public client_putinserver(id)
{
	Connect_Reset(id)
	
	set_task(0.1,"Task_SetLight",id);
	
}

public fw_BotRegisterHam(id)
{
	if (!is_user_zbot(id) || get_pcvar_num(bot_quota) <= 0) 
		return
	unregister_forward(FM_PlayerPostThink, g_fwHamBotRegister, 1)
	
	// Reg Ham Zbot
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player")
	RegisterHamFromEntity(Ham_Spawn, id, "HamF_Spawn_Player_Post", 1)
	RegisterHamFromEntity(Ham_TraceAttack, id, "HamF_TraceAttack")
	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage")
	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage_Post", 1)
	RegisterHamFromEntity(Ham_Killed, id, "HamF_Killed")
	RegisterHamFromEntity(Ham_Killed, id, "HamF_Killed_Post", 1)
	//if (is_user_alive(id)) fw_PlayerSpawn_Post(id)
}

public plugin_cfg()
{
	new cfgdir[32]
	get_configsdir(cfgdir, charsmax(cfgdir))

	server_cmd("exec %s/%s", cfgdir, CVAR_FILE)
	
	Event_HLTV();
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
