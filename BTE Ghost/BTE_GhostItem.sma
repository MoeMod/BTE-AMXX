#include <amxmodx>
#include <amxmisc> 
#include <hamsandwich>
#include <fakemeta>
#include "cdll_dll.h"
#include "offset.inc"
#include "util.sma"

#define PLUGIN "BTE Ghost Item"
#define VERSION "1.0"
#define AUTHOR "NN"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("ghost_vest", "Item_Vest");
	
	gmsgArmorType = get_user_msgid("ArmorType");
	gmsgBlinkAcct = get_user_msgid("BlinkAcct");
	gmsgMoney = get_user_msgid("Money");
	gmsgTextMsg = get_user_msgid("TextMsg");
}

public Item_Vest(id)
{
	if (get_pdata_int(id, m_iTeam) != TEAM_TERRORIST)
		return PLUGIN_HANDLED;
	
	if (!CheckBuyTime(id))
		return PLUGIN_HANDLED;
	
	new Float:health, Float:armorvalue;
	pev(id, pev_health, health);
	pev(id, pev_armorvalue, armorvalue);
	
	new bAlreadyOwn = (health > 100.0 || armorvalue > 100.0);
	
	if (bAlreadyOwn)
	{
		ClientPrint(id, HUD_PRINTCENTER, "#Already_Have_Kevlar_Bought_Helmet");
		return PLUGIN_HANDLED;
	}
	
	if (!CheckAccount(id, 4000))
		return PLUGIN_HANDLED;
	
	AddAccount(id, -4000, TRUE);
	
	new bSendMsg = (get_pdata_int(id, m_iKevlar) != 2);
	
	set_pev(id, pev_health, health + 80.0); // 100 + 80
	set_pev(id, pev_max_health, health + 80.0);
	
	set_pdata_int(id, m_iKevlar, 2);
	set_pev(id, pev_armorvalue, armorvalue + 20.0); // 100 + 20
	
	if (bSendMsg)
		SendArmorType(id, 1);
	
	emit_sound(id, CHAN_ITEM, "items/ammopickup2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	return PLUGIN_HANDLED;
}

native BTE_Check_BuyTime(id, bSendMsg);

stock CheckBuyTime(id)
{
	return BTE_Check_BuyTime(id, TRUE);
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