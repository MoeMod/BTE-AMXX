/* 本插件由 AMXX-Studio 中文版自动生成*/
/* UTF-8 func by www.DT-Club.net */

#include <amxmodx>
#include "metahook.inc"
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <amxmisc>

#define PLUGIN_NAME	"BTE NONE MOD HELP"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"BTE TEAM"

#define BOMB_TARGET_TYPE1 "func_bomb_target" 
#define BOMB_TARGET_TYPE2 "info_bomb_target"

native	bte_wpn_get_mod_running()

//new iStart
//new iTRound,iCTRound

new vecBomb[2][3],g_EntitySum
public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	/*register_event("HLTV","R_ES","1=0","2=0")
	register_logevent("R_E",2,"1=Round_Start")
	register_logevent("R_E",2,"1=Round_End")
	register_event("DeathMsg","InitBoard","a")
	register_message(get_user_msgid("TeamScore"),"message_TeamScore")
	register_message(get_user_msgid("TextMsg"),"message_TextMsg")*/
	server_cmd("bte_wpn_free 0")
	server_cmd("bte_wpn_buyzone 1")
	//register_clcmd("sb","sb")
	//register_forward(FM_PlayerPreThink, "Forward_PlayerPreThink")
}
public plugin_cfg()
{
	new cfgdir[32], url_none[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	
	format(url_none, charsmax(url_none), "%s/plugins-none.ini", cfgdir)
	
	if (file_exists(url_none))
		server_cmd("exec %s/%s", cfgdir, "bte_originmod.cfg")
	else
		server_cmd("exec %s/%s", cfgdir, "bte_ghostmod.cfg")

	new entity = -1, Float:tmpOrigin[3]

	// BOMB_TARGET_TYPE1
	while ((entity = find_ent_by_class(entity, BOMB_TARGET_TYPE1)))
	{
		get_brush_entity_origin(entity, tmpOrigin)
		FVecIVec(tmpOrigin, vecBomb[g_EntitySum])

		g_EntitySum++
	}

	// BOMB_TARGET_TYPE2
	entity = -1
	while ((entity = find_ent_by_class(entity, BOMB_TARGET_TYPE2)))
	{
		entity_get_vector(entity,EV_VEC_origin,tmpOrigin)
		FVecIVec(tmpOrigin, vecBomb[g_EntitySum])

		g_EntitySum++
	}
}
public client_putinserver(id)
{
	set_task(3.0,"Check",id)
}

native MH_DrawFollowIcon(id, name[], pos_x, pos_y, pos_z, a, B, c, r, g, b)

public Check(id)
{
	if(MH_IsMetaHookPlayer(id)) 
	{
		//MH_SendClientModRunning(id,1)
		if(g_EntitySum)
		{
			MH_DrawFollowIcon(id,"bte_bombtargetA",vecBomb[0][0],vecBomb[0][1],vecBomb[0][2],1,1,1,200,200,200)
		}
		if(g_EntitySum>1)
		{
			MH_DrawFollowIcon(id,"bte_bombtargetB",vecBomb[1][0],vecBomb[1][1],vecBomb[1][2],1,1,2,200,200,200)
		}
	}
}
/*public R_ES()
{
	InitBoard()
}
public R_E()
{
	for(new id=1;id<=32;id++)
	{
		if(!MH_IsMetaHookPlayer(id)) continue
		MH_DrawScoreBoard(id,iTRound,iTRound+iCTRound+1,iCTRound,get_player(1),get_player(0),1)
	}
}
public message_TeamScore()
{
	new sTeamName[2]
	get_msg_arg_string(1, sTeamName, 1)
	
	switch (sTeamName[0])
	{
		case 'T': iTRound = get_msg_arg_int(2)
		case 'C': iCTRound = get_msg_arg_int(2)
	}
	InitBoard()	
}
public InitBoard()
{
	for(new id=1;id<=32;id++)
	{
		if(!MH_IsMetaHookPlayer(id)) continue
		MH_DrawScoreBoard(id,iTRound,iTRound+iCTRound+1,iCTRound,get_player(1),get_player(0),1)
	}
}
public get_player(iTeam)
{
	new num[3]
	for(new i=1;i<=32;i++)
	{
		if(!is_user_connected(i)||!is_user_alive(i)) continue
		num[cs_get_user_team(i)]++
	}
	return iTeam?num[CS_TEAM_T]:num[CS_TEAM_CT]
}
public message_TextMsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))
	if (equal(textmsg, "#Game_will_restart_in"))
	{
		iTRound=0
		iCTRound=0
	}
	else if (equal(textmsg, "#Game_Commencing"))
	{
		iStart = 1
	}
	
	return PLUGIN_CONTINUE;
}*/
	
		
		
		
		
