#include <amxmodx>
#include <amxmisc>

#define PLUGIN_NAME	"BTE VoteKick"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"BTE TEAM"

#define VOTETIME_LIMIT	20
#define VOTETIME_LAST	10
#define VOTETIME_COLDDOWN	90
#define KICK_PERCENT	0.5
new g_bIsVoting = false
new g_bIsMakingVoteRequest = false
new g_bRequesting = false
new g_iVotingID
new g_iVoterID
new g_iVoteTimeLimit = 0
new g_iLastVoteTime = 0
new g_iVoteChoice[2]
new Array:g_aKickedPlayer
public plugin_init()
{
	register_plugin(PLUGIN_NAME,PLUGIN_VERSION,PLUGIN_AUTHOR)
	register_clcmd("bte_votekick","Cmd_VoteKick"/*ADMIN_RCON,*/)
	g_aKickedPlayer = ArrayCreate(32, 1)
}
public client_connect(id)
{
	new szIP[30],szIN[30],szName[32]
	get_user_ip(id,szIP,29)
	get_user_name(id,szName,31)
	new iSize = ArraySize(g_aKickedPlayer)
	for (new i = 0; i < iSize; i++)
	{
		ArrayGetString(g_aKickedPlayer, i, szIN, charsmax(szIN))
		if (equal(szIP, szIN))
		{
			server_cmd("kick %s",szName)
			client_print(0,print_chat,"Kicked player %s try to connect, Refused",szName)
		}
	}
}
public Cmd_VoteKick(const id, const iLevel, const iCid)
{
	if (!CheckAdminAccess(id,iLevel,iCid)) return PLUGIN_HANDLED
	if (read_argc() == 2)
	{
		new szKickName[32]
		read_argv(1,szKickName,charsmax(szKickName))
		//Pub_KickNamedPlayer(szKickName) need to do
		return PLUGIN_HANDLED
	}
	if (g_iLastVoteTime > get_systime()) 
	{
		new iTime = g_iLastVoteTime - get_systime()
		client_print(id,print_chat, "Please wait %d seconds to vote",iTime)
		return PLUGIN_HANDLED
	}
	if (g_bIsVoting)
	{
		client_print(id,print_chat, "Another voting is doing, please wait")
		return PLUGIN_HANDLED
	}
	
	new iTotal = 0,hMenu
	for(new i=1;i<33;i++)
	{
		if (i == id) continue
		if (!is_user_connected(i)) continue
		//if (is_user_bot(i)) continue
		
		iTotal++
		new szPlayerID[3],szPlayerName[32]
		if (!hMenu) hMenu = menu_create("BTE VoteKick Menu - Select Player","Menu_VoteKick_Main")

		format(szPlayerID, 2, "%d", i)
		get_user_name(i,szPlayerName,charsmax(szPlayerName))
		
		menu_additem(hMenu,szPlayerName,szPlayerID)
	}
	if (!iTotal) return PLUGIN_HANDLED
	
	g_iVoterID = id
	
	/*g_bIsVoting = true
	g_bIsMakingVoteRequest = true
	g_bRequesting = false
	
	g_iVoteChoice[0] = g_iVoteChoice[1] = 0
	
	if (task_exists(1000)) remove_task(1000)
	g_iVoteTimeLimit = VOTETIME_LIMIT
	set_task(1.0, "Task_CheckTime", 1000, _, _, "b")*/
	
	menu_display(id, hMenu, 0)
	
	return PLUGIN_HANDLED
}

new g_szVotingReasons_List[][]={"","Using BUG or Cheat Programs","Sell Teammates","Bad Words","Others Reason"}

public Menu_VoteKick_Main(id,hMenu,iItem)
{
	if (g_iVoteTimeLimit<0) return menu_destroy(hMenu)
	if (iItem == MENU_EXIT) return menu_destroy(hMenu)

	new szCmd[32], szName[32], access
	menu_item_getinfo(hMenu, iItem, access, szCmd, 31, szName, 31, access)
	menu_destroy(hMenu)
	
	g_iVotingID = str_to_num(szCmd)
	new hMenu = menu_create("BTE VoteKick Menu - Select Reason", "Menu_VoteKick_Reason")
	
	for(new i=1; i<sizeof(g_szVotingReasons_List); i++)
	{
		new szReasonID[3]
		num_to_str(i,szReasonID,charsmax(szReasonID))
		menu_additem(hMenu,g_szVotingReasons_List[i],szReasonID)
	}
	menu_display(g_iVoterID, hMenu, 0)
	return PLUGIN_HANDLED
}
public Menu_VoteKick_Reason(id, hMenu, iItem)
{
	if (g_iVoteTimeLimit<0) return menu_destroy(hMenu)
	if (iItem == MENU_EXIT) return menu_destroy(hMenu)

	new szCmd[32], szName2[32], access
	menu_item_getinfo(hMenu, iItem, access, szCmd, 31, szName2, 31, access)
	menu_destroy(hMenu)
	
	new iReasonID = str_to_num(szCmd)
	
	new szMenuTitle[128],szName[2][32]
	get_user_name(g_iVoterID,szName[0],31)
	get_user_name(g_iVotingID,szName[1],31)
	format(szMenuTitle,127,"%s want to kick \r%s\y from the server.\nReason:\r%s",szName[0],szName[1],g_szVotingReasons_List[iReasonID])
	
	new hMenu = menu_create(szMenuTitle,"Menu_VoteKick_Show")
	menu_additem(hMenu,"YES, KICK Him", "0")
	menu_additem(hMenu,"NO, I LOVE Him", "1")
	
	for(new i=1;i<33;i++)
	{
		if (!is_user_connected(i)) continue
		if (is_user_bot(i)) continue
		if (i == g_iVotingID) continue
		if (i == g_iVoterID) continue
		
		menu_display(i, hMenu)
	}
	g_bIsMakingVoteRequest = false
	g_bRequesting = true
	g_iVoteTimeLimit = VOTETIME_LAST
	g_iLastVoteTime = get_systime() + VOTETIME_COLDDOWN
	
	g_bIsVoting = true
	g_iVoteChoice[0] = g_iVoteChoice[1] = 0
	g_iVoteChoice[0] ++
	
	client_print(g_iVoterID, print_chat, "Your vote started.")
	
	if (task_exists(1000)) remove_task(1000)
	set_task(1.0, "Task_CheckTime", 1000, _, _, "b")
	
	return PLUGIN_HANDLED
}
public Menu_VoteKick_Show(id,hMenu,iItem)
{
	if (g_iVoteTimeLimit<0) return menu_destroy(hMenu)
	if (iItem == MENU_EXIT) return menu_destroy(hMenu)
	
	new szCmd[32], szName[32], access
	menu_item_getinfo(hMenu, iItem, access, szCmd, 31, szName, 31, access)
	menu_destroy(hMenu)
	
	new iKickChoice = str_to_num(szCmd)
	g_iVoteChoice[iKickChoice] ++
	client_print(id,print_chat,"Choice Submitted. Please wait for the result.")
	return PLUGIN_HANDLED
}
public ProcessVote()
{
	g_bRequesting = false
	g_bIsVoting = false
	
	g_iVoteChoice[1]++ // The votekick player add his choice -- NO
	
	new Float:fPercent = floatdiv(float(g_iVoteChoice[0]),float(g_iVoteChoice[0]+g_iVoteChoice[1]))
	new szName[32]
	get_user_name(g_iVotingID,szName,charsmax(szName))
	if (fPercent > KICK_PERCENT)
	{
		KickOut()
		client_print(0, print_chat,"%.2f%% player agreed to kick %s from the server", fPercent*100, szName) // need to check the votekick player ?
		
	}
	else
	{
		client_print(0, print_chat,"Faild to kick %s from the server",szName) // need to check the votekick player ?
		server_print("Kick %s failed,Percent %f", szName, fPercent)
	}
}
public KickOut()
{
	if (!is_user_connected(g_iVotingID)) return
	// A:
	// client_cmd(g_iVotingID,"disconnect")
	// B:
	new szName[32],szIP[30]
	get_user_name(g_iVotingID,szName,charsmax(szName))
	get_user_ip(g_iVotingID,szIP,29)
	ArrayPushString(g_aKickedPlayer,szIP)
	server_cmd("kick %s",szName)
	// C:
	// Use Steam AuthID
}
public Task_CheckTime(iTaskid)
{
	if (g_bIsMakingVoteRequest)
	{
		g_iVoteTimeLimit --
		
		/*if (g_iVoteTimeLimit == 10)
		{
			if (g_bRequesting)
				client_print(g_iVoterID,print_chat, "Please finish kick in 10 seconds")
		}*/
		if (g_iVoteTimeLimit < 0)
		{
			/*if (g_bRequesting)
				client_print(g_iVoterID,print_chat, "Time reached. Vote closed")*/
			
			g_bIsVoting = false
			g_bRequesting = false
			
			g_iVoterID = 0
			if (task_exists(1000)) remove_task(1000)
		}
	}
	if (g_bRequesting)
	{
		g_iVoteTimeLimit --
		if (g_iVoteTimeLimit <0) ProcessVote()
	}
}
	
stock CheckAdminAccess(const id,const iLevel,const iCid)
{
	// Set everyone or only admin
	//if (!cmd_access( id, iLevel, iCid, 1 )) return 0
	return 1
}