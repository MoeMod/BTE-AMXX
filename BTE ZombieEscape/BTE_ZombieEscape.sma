const OFFSET_MODELINDEX = 491
const OFFSET_PAINSHOCK = 108
const OFFSET_CSTEAMS = 114
const OFFSET_LINUX = 5
const IMPULSE_FLASHLIGHT = 100
const OFFSET_FLASHLIGHT_BATTERY = 244
const DMG_HEGRENADE = (1<<24)
const OFFSET_MODELINDEX = 491

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
//#include <bte_ze>
#include <xs>
#include <hamsandwich>
#include <BTE_API>
#include <metahook>
#include <engine>
#include <round_terminator>
new g_ent_train
#define PRINT(%1) client_print(1,print_chat,%1)
#include "bte/ZombieEscape/ValueDef.sma"
#include "bte/ZombieEscape/Vars.sma"
#include "bte/ZombieEscape/Public.sma"
#include "bte/ZombieEscape/Stocks.sma"
#include "bte/ZombieEscape/ReadFile.sma"
#include "bte/ZombieEscape/Forward.sma"
#include "bte/ZombieEscape/Ham.sma"



#pragma loadlib semiclip
new Float:v[3] = {2032.0,1680.0,126.0}
public test3(id)
{
	set_pev(id,pev_movetype,MOVETYPE_NOCLIP)
	
}
public test2(id)
{
	set_pev(id,pev_movetype,MOVETYPE_WALK)
}
public test4(id)
{
}
new g_admin_start
new g_iCheck

#define PLUGIN_NAME	"BTE Zombie Escape"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"BTE TEAM"

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0")
	register_logevent("LogEvent_Round_Start",2, "1=Round_Start")
	register_logevent("LogEvent_Round_End", 2, "1=Round_End")
	register_dictionary("bte_zombie.bte")
	
	register_forward(FM_EmitSound, "Forward_EmitSound")
	register_forward(FM_PlayerPreThink, "Forward_PlayerPreThink")
	register_forward(FM_AddToFullPack, "Forward_AddToFullPack_Post",1)
	register_forward(FM_TraceLine, "Forward_TraceLine_Post", 1)
	
	register_forward(FM_ClientKill, "Forward_ClientKill")
	
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage")
	//RegisterHam(Ham_TraceAttack, "player", "HamF_TraceAttack")
	RegisterHam(Ham_Touch, "weaponbox", "HamF_TouchWeapon")
	RegisterHam(Ham_Touch, "armoury_entity", "HamF_TouchWeapon")
	RegisterHam(Ham_Touch, "weapon_shield", "HamF_TouchWeapon")
	RegisterHam(Ham_Touch, "func_train", "HamF_TouchTrain")
	RegisterHam(Ham_Use, "func_button", "HamF_ButtonUse")
	
	
	RegisterHam(Ham_Item_Deploy,"weapon_knife", "HamF_Item_Deploy_Post",1)
	
	g_msgDeathMsg = get_user_msgid("DeathMsg")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_msgScoreAttrib = get_user_msgid("ScoreAttrib")
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	g_msgTextMsg = get_user_msgid("TextMsg")
	
	register_message(g_msgTextMsg, "Message_TextMsg")
	
	/*register_concmd("pos","cmd_p")
	register_concmd("test2","test2")
	register_concmd("test3","test3")*/
	register_concmd("bte_ze_start","cmd_start")
	cvar_botquota = get_cvar_pointer("bot_quota")
	
	register_clcmd("nightvision", "cmd_nightvision")
}
public cmd_start(id)
{
	if(!bte_wpn_get_is_admin(id)) return PLUGIN_HANDLED
	if(g_admin_start) return PLUGIN_HANDLED
	
	g_admin_start = 1
	g_iCheck = 1
}
new iCount
public cmd_p(id)
{
	iCount ++
	set_pev(id,pev_movetype,MOVETYPE_NOCLIP)
	new Float:v[3]
	pev(1,pev_origin,v)
	client_print(1,print_chat,"%d %f %f %f",iCount,v[0],v[1],v[2])
}
public client_disconnect(id)
{
	g_zombie[id] = 0
	UpdateScoreBoard()
}
public Event_HLTV()
{
	server_cmd("sv_noroundend 1")
	g_startcount = 1
	Pub_Entity_Setting()
	if(!g_admin_start)
	{
		remove_task(987)
		set_task(2.0,"Event_HLTV",987)
		server_cmd("sv_noroundend 1")
		client_print(0,print_center,"%L",LANG_PLAYER,"MSG_WAIT_FOR_START")
		g_iCheck = 0
		return
	}
	if(g_iCheck == 1)
	{
		server_cmd("sv_noroundend 0")
		set_cvar_num("sv_restart",1)
		
		g_iCheck = 0
	}
	
	remove_task(987)
	
	remove_task(TASK_ZOMBIE_COUNT)
	Pub_Reset_Value()
	set_task(0.1,"Pub_Make_Human")
	g_freezetime = 1
	g_newround = 1
	g_endround = 0
	client_cmd(0,"mp3 stop")
	MH_DrawCountDownReset(0)
	for(new i=1;i<33;i++)
	{
		if(is_user_connected(i))
		{	
			if(MH_IsMetaHookPlayer(i)) MH_SendClientModRunning(i,10)
				
			if(!is_user_bot(i))
			{
				remove_task(i+TASK_NVG)
				//close nvg
				message_begin(MSG_ONE, g_msgScreenFade, _, i)
				write_short(0) // duration
				write_short(0) // hold time
				write_short(0x0000) // fade type
				write_byte(255) // red
				write_byte(100) // green
				write_byte(100) // blue
				write_byte(140) // alpha
				message_end()
				Pub_Set_Light(i,"e")
			}					
		}
	}
	UpdateScoreBoard()	
}
public UpdateScoreBoard()
{
	new hm,zb
	for(new i =1;i<33;i++)
	{
		if(is_user_alive(i))
		{
			if(g_zombie[i]) zb++
			else hm++
		}
	}
	MH_DrawScoreBoard(0,g_score_hm, g_score_hm+g_score_zb+1, g_score_zb, zb, hm ,1)
}	
public LogEvent_Round_Start()
{
	if(!g_admin_start)
	{
		return
	}
	g_freezetime = 0
	g_zombiecount = 22
	g_newround = 0
	if(g_startcount)
	{
		//Pub_Entity_Setting()
		Pub_Round_Trigger(1)
		Stock_PlaySound(0,res_music_ready)
	
		remove_task(TASK_ZOMBIE_COUNT)
		remove_task(TASK_READY)
		set_task(1.0,"Pub_Task_Zombie_Count",TASK_ZOMBIE_COUNT,_, _, "b")
	}
	else 
	{
		remove_task(TASK_READY)
		set_task(1.0,"Pub_Task_Ready",TASK_READY)
	}
}
public LogEvent_Round_End()
{
	remove_task(TASK_ZOMBIE_COUNT)
	g_endround = 1	
}
public plugin_precache()
{
	g_zombie_index = precache_model(res_model_zb)
	g_zombie_index2 = precache_model(res_model_zb2)
	Pub_Load_Spawns()
	register_forward(FM_KeyValue, "Forward_KeyValue_Post")
	for(new i=0;i<2;i++)
	{
		precache_sound(res_sound_zbhurt[i])
		precache_sound(res_sound_infection[i])
	}
	for(new i=0;i<3;i++)
	{
		precache_sound(res_sound_zbhitwall[i])
		precache_sound(res_sound_zbhit[i])
		precache_sound(res_sound_zbswing[i])
	}

	precache_model(res_model_zbhand)
	g_fwSpawn = register_forward(FM_Spawn, "Forward_Spawn")
}
//
public client_putinserver(id)
{
	if (is_user_bot(id) && !g_hamczbots && cvar_botquota)
	{
		set_task(0.1, "Task_Register_Bot", id)
	}
}
public Task_Register_Bot(id)
{	
	// Make sure it's a CZ bot and it's still connected
	if (g_hamczbots || !is_user_connected(id) || !get_pcvar_num(cvar_botquota))
		return;
	
	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage")
	//RegisterHamFromEntity(Ham_TraceAttack, id, "HamF_TraceAttack")
	g_hamczbots = 1
}
//
public cmd_nightvision(id)
{
	if (!is_user_alive(id)) return PLUGIN_HANDLED;
	
	if(g_zombie[id])
	{
		g_nvg[id] = 1 - g_nvg[id]
		
		if(g_nvg[id]) 
		{
			remove_task(id+TASK_NVG)
			Task_Nvg(id+TASK_NVG)
			Pub_Set_Light(id,"1")
			set_task(1.0, "Task_Nvg", id+TASK_NVG, _, _, "b")
		}
		else 
		{
			remove_task(id+TASK_NVG)
			Pub_Set_Light(id,"e")
			message_begin(MSG_ONE, g_msgScreenFade, _, id)
			write_short(0) // duration
			write_short(0) // hold time
			write_short(0x0000) // fade type
			write_byte(255) // red
			write_byte(100) // green
			write_byte(100) // blue
			write_byte(140) // alpha
			message_end()
		}
		
		Stock_PlaySound(id, g_nvg[id]?res_sound_nvg[1]:res_sound_nvg[0])
	}
	else
	{
		g_nvg[id] = 1 - g_nvg[id]
		
		if(g_nvg[id]) 
		{
			remove_task(id+TASK_NVG)
			Task_Nvg(id+TASK_NVG)
			Pub_Set_Light(id,"1")
			set_task(1.0, "Task_Nvg", id+TASK_NVG, _, _, "b")
		}
		else 
		{
			remove_task(id+TASK_NVG)
			Pub_Set_Light(id,"f")
			message_begin(MSG_ONE, g_msgScreenFade, _, id)
			write_short(0) // duration
			write_short(0) // hold time
			write_short(0x0000) // fade type
			write_byte(0) // red
			write_byte(110) // green
			write_byte(0) // blue
			write_byte(120) // alpha
			message_end()
		}
		
		Stock_PlaySound(id, g_nvg[id]?res_sound_nvg[1]:res_sound_nvg[0])
	}
	
	return PLUGIN_HANDLED;
}
stock Pub_Set_Light(id,light[])
{
	if(!is_user_connected(id)) return
	new sz[3]
	message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, id)
	write_byte(0)
	write_string(light)
	message_end()
}
public Message_TextMsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))
	
	// Game restarting, reset scores and call round end to balance the teams
	if (equal(textmsg, "#Game_will_restart_in"))
	{
		LogEvent_Round_End()
		return PLUGIN_HANDLED;
	}
	if (equal(textmsg, "#Auto_Team_Balance_Next_Round"))
	{
		return PLUGIN_HANDLED;
	}
	/*else if (equal(textmsg, "#Game_Commencing"))
	{
		g_startcount = 1
	}*/
	// Block round end related messages
	else if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win"))
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}
public Task_Nvg(iTask)
{
	new id = iTask - TASK_NVG
	message_begin(MSG_ONE, g_msgScreenFade, _, id)
	write_short((1<<12)*2) // duration
	write_short((1<<10)*10) // hold time
	write_short(0x0000) // fade type
	if(g_zombie[id])
	{
		write_byte(100) // red
		write_byte(0) // green
		write_byte(0) // blue
		write_byte(120) // alpha
	}
	else
	{
		write_byte(0) // red
		write_byte(110) // green
		write_byte(0) // blue
		write_byte(120) // alpha
	}
	message_end()
}
public plugin_natives()
{
	register_native("bte_get_user_zombie","Native_get_user_zombie",1)
}
public Native_get_user_zombie(id)
{
	if(id<33 && id>0)
	return g_zombie[id]
	else
	return 0
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1034\\ f0\\ fs16 \n\\ par }
*/
