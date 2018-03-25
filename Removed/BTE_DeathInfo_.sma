#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include "BTE_API.inc"
#include <metahook>
#include <hamsandwich>
#define PLUGIN	"BTE Death Info"
#define VERSION	"1.0"
#define AUTHOR	"BTE TEAM"

const R=183
const G=207
const B=245
const Float:HUD_X=0.55
const Float:HUD_Y=0.55
const R2=242
const G2=148
const B2=148
const Float:HUD_X2=0.39
const Float:HUD_Y2=0.52
new fire[33][33][8], body[33][33][8]
new att_wpn[33][33]
new g_hamczbots

new Float:g_fOldHealth[33], Float:g_fHealth[33];
enum (+= 100)
{
	TASK_ATT = 6000,
	TASK_VIC
}
new cvar_dev

new bot_quota

new g_isZb2, g_isZb3, g_isZb4, g_isZSE;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_dictionary("bte_wpn.bte")
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_message(get_user_msgid("DeathMsg"),"get_wpname")
	//register_event("Damage", "Event_Damage", "b", "2!0", "3=0", "4!0")
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage")
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage_Post",1)
	cvar_dev = register_cvar("bte_dev_damage","0")

	bot_quota = get_cvar_pointer("bot_quota")

	new config_dir[64], url_zb2[64], url_zb3[64], url_zb4[64], url_zse[64]
	get_configsdir(config_dir, charsmax(config_dir))
	format(url_zb2, charsmax(url_zb2), "%s/plugins-zb2.ini", config_dir)
	format(url_zb3, charsmax(url_zb3), "%s/plugins-zb3.ini", config_dir)
	format(url_zb4, charsmax(url_zb4), "%s/plugins-zb4.ini", config_dir)
	format(url_zse, charsmax(url_zse), "%s/plugins-zse.ini", config_dir)

	if (file_exists(url_zb2)) g_isZb2 = 1
	else if(file_exists(url_zb3)) g_isZb3 = 1
	else if(file_exists(url_zb4)) g_isZb4 = 1
	else if(file_exists(url_zse)) g_isZSE = 1
}

public plugin_natives()
{
	register_native("BTE_DeathInfo_TakeDamage_Pre", "HamF_TakeDamage", 1);
	register_native("BTE_DeathInfo_TakeDamage_Post", "HamF_TakeDamage_Post", 1);
}


#if 0
public Event_Damage(id)
{
	static attacker,hitzone,weapon
	attacker = get_user_attacker(id,weapon,hitzone)
	/*bte_wpn_get_wpn_name(attacker,0,BTE_WPNDATA_CN_NAME,att_wpn[attacker])*/

	static damage; damage = read_data(2)
	if (!is_user_connected(id) || !is_user_connected(attacker) || attacker==id) return;
	hitzone = get_pdata_int(id, 75);
	fire[attacker][id][hitzone]+=damage
	body[attacker][id][hitzone]+=1
	if(get_pcvar_num(cvar_dev))
	{
		new msg[128],name1[32],name2[32],group[32]
		switch (hitzone)
		{
			case HIT_GENERIC: format(group,31,"%s","JJ部位");
			case HIT_HEAD: format(group,31,"%s","头部")
			case HIT_CHEST: format(group,31,"%s","胸部")
			case HIT_STOMACH: format(group,31,"%s","腹部")
			case HIT_LEFTARM: format(group,31,"%s","左臂")
			case HIT_RIGHTARM: format(group,31,"%s","右臂")
			case HIT_LEFTLEG: format(group,31,"%s","左腿")
			case HIT_RIGHTLEG: format(group,31,"%s","右腿")
		}
		get_user_name(attacker,name1,31)
		get_user_name(id,name2,31)
		format(msg,127,"%s给%s的%s造成伤害%d",name1,name2,group,damage)
		MH_DrawFontText(1,msg,1,0.5,0.5,R,G,B,14,3.0,1.0,0,5)
	}
}
#endif

public bte_zb_infected(victim,attacker)
{
	if(attacker >= 33) return;

	static para[2]
	para[0]=attacker
	para[1]=victim

	format(att_wpn[attacker],32,"-")
	//bte_wpn_get_wpn_name(victim,0,BTE_WPNDATA_CN_NAME,att_wpn[victim])

	if(attacker)
	{
		if (task_exists(attacker+TASK_ATT)) remove_task(attacker+TASK_ATT)
		if (task_exists(victim+TASK_VIC)) remove_task(victim+TASK_VIC)
		set_task(0.2,"Display_att",attacker+TASK_ATT,para,2)
		set_task(0.2,"Display_vic",victim+TASK_VIC,para,2)
		set_task(0.5,"clear",_,para,2)
	}
}

public HamF_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(victim) || !is_user_connected(attacker) || (bte_get_user_zombie(attacker) == 1 && !g_isZSE)) return

	pev(victim, pev_health, g_fOldHealth[victim]);

	new sWeapon[31];
	bte_wpn_get_wpn_name(attacker, 0, BTE_WPNDATA_CN_NAME, sWeapon);
	strtoupper(sWeapon);
	format(att_wpn[attacker], 32, "%L", LANG_PLAYER, sWeapon);

	if (bte_get_user_zombie(attacker) == 1 && g_isZSE)
		format(att_wpn[attacker], 32, "-");

}
public HamF_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(victim) || !is_user_connected(attacker) || (bte_get_user_zombie(attacker) == 1 && !g_isZSE)) return

	new msg[64],name1[32],name2[32],group[32],igroup,iamount
	//iamount = get_pdata_int(victim,334)
	pev(victim, pev_health, g_fHealth[victim]);

	iamount = floatround(g_fOldHealth[victim] - g_fHealth[victim]);
	if(!iamount) return

	if(0<victim<33 && 0<attacker<33)
	{
		//bte_wpn_get_wpn_name(attacker,0,BTE_WPNDATA_CN_NAME,att_wpn[attacker])

		igroup = get_pdata_int(victim,75)
		if(!igroup) igroup = HIT_CHEST
		fire[attacker][victim][igroup]+=iamount
		body[attacker][victim][igroup]+=1

		if(get_pcvar_num(cvar_dev))
		{
			switch (igroup)
			{
				case HIT_GENERIC: format(group,31,"%s","JJ部位");
				case HIT_HEAD: format(group,31,"%s","头部")
				case HIT_CHEST: format(group,31,"%s","胸部")
				case HIT_STOMACH: format(group,31,"%s","腹部")
				case HIT_LEFTARM: format(group,31,"%s","左臂")
				case HIT_RIGHTARM: format(group,31,"%s","右臂")
				case HIT_LEFTLEG: format(group,31,"%s","左腿")
				case HIT_RIGHTLEG: format(group,31,"%s","右腿")
			}
			get_user_name(attacker,name1,31)
			get_user_name(victim,name2,31)
			format(msg,63,"%s给%s的%s造成伤害%d",name1,name2,group,iamount)
			MH_DrawFontText(1,msg,1,0.5,0.5,R,G,B,14,3.0,1.0,0,5)
		}
	}
}
public client_putinserver(id)
{
	if (is_user_zbot(id) && !g_hamczbots && get_pcvar_num(bot_quota) > 0)
	{
		set_task(0.1, "Task_Register_Bot", id)
	}
}
public Task_Register_Bot(id)
{
	// Make sure it's a CZ bot and it's still connected
	if (g_hamczbots || !is_user_connected(id) || !is_user_zbot(id))
		return;

	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage")
	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage_Post",1)
	g_hamczbots = 1
}
public event_round_start()
{
	for (new id = 1; id <= get_maxplayers(); id++)
	{
		if (is_user_connected(id))
			reset_result(id, 0)
	}
}
public get_wpname(msgid,dest,id)
{
	static att,vic,para[2],sWeapon[32]
	att=get_msg_arg_int(1)
	vic=get_msg_arg_int(2)
	para[0]=att
	para[1]=vic
	get_msg_arg_string(4, sWeapon, charsmax(sWeapon));

	if (strlen(sWeapon) < 2)
		return;

	//bte_wpn_get_wpn_name(att,0,BTE_WPNDATA_CN_NAME,att_wpn[att])

	/*for (new i = 0; i < 30; i ++)
		sWeapon[i] = sWeapon[i + 2];*/

	if (sWeapon[strlen(sWeapon) - 2] == '_')
		sWeapon[strlen(sWeapon) - 2] = 0;

	strtoupper(sWeapon);

	format(att_wpn[att], 32, "%L", LANG_PLAYER, sWeapon);
	//MH_DrawFontText(att,att_wpn[att],0,HUD_X2,HUD_Y2,R2,G2,B2,14,3.0,1.0,0,1)

	if(vic!=att)
	{
		if (task_exists(att+TASK_ATT)) remove_task(att+TASK_ATT)
		if (task_exists(vic+TASK_VIC)) remove_task(vic+TASK_VIC)
		set_task(0.2,"Display_att",att+TASK_ATT,para,2)
		set_task(0.2,"Display_vic",vic+TASK_VIC,para,2)
		set_task(0.5,"clear",_,para,2)
	}
}
public Display_att(para[])
{
	new att=para[0]
	new vic=para[1]
	if(is_user_connected(att) && (1<=vic<=32))
	{
		new message[512],temp[64]
		new name[32],len
		get_user_name(vic,name,31)
		len=format(message,511,"%L",LANG_PLAYER,"VICTIM_DIED",name)
		new dis1[3],dis2[3]
		get_user_origin(att,dis1)
		get_user_origin(vic,dis2)
		new dist=get_distance(dis1,dis2)
		dist=dist/40                           //calculate distance (inch -> meter)
		format(temp,63,"%L",LANG_PLAYER,"DISTANCE",dist)
		len += format(message[len],511-len,"^n%s",temp )
		//damage all
		new total_damage
		for(new i=1;i<=7;i++)
		{
			total_damage+=fire[att][vic][i]
		}
		//Center Core
		format(temp,63,"%L",LANG_PLAYER,"HURT_TO_VICTIM",att_wpn[att],total_damage)
		len += format(message[len],511-len,"^n%s",temp )

		if(body[att][vic][1])
		{
			format(temp,63,"%L",LANG_PLAYER,"HEAD",fire[att][vic][1],body[att][vic][1])
			len += format(message[len],511-len,"^n%s",temp )
		}

		if(body[att][vic][2])
		{
			format(temp,63,"%L",LANG_PLAYER,"CHEST",fire[att][vic][2],body[att][vic][2])
			len += format(message[len],511-len,"^n%s",temp )
		}

		if(body[att][vic][3])
		{
			format(temp,63,"%L",LANG_PLAYER,"STOMACH",fire[att][vic][3],body[att][vic][3])
			len += format(message[len],511-len,"^n%s",temp )
		}

		if(body[att][vic][4] || body[att][vic][5])
		{
			format(temp,63,"%L",LANG_PLAYER,"ARM",fire[att][vic][4]+fire[att][vic][5],body[att][vic][4]+body[att][vic][5])
			len += format(message[len],511-len,"^n%s",temp )
		}

		if(body[att][vic][6] || body[att][vic][7])
		{
			format(temp,63,"%L",LANG_PLAYER,"LEG",fire[att][vic][6]+fire[att][vic][7],body[att][vic][6]+body[att][vic][7])
			len += format(message[len],511-len,"^n%s",temp )
		}

		if(MH_IsMetaHookPlayer(att))  MH_DrawFontText(att,message,0,HUD_X,HUD_Y,R,G,B,14,3.0,1.0,0,1)
	}
}
public Display_vic(para[])
{
		new att=para[0]
		new vic=para[1]
		if(is_user_connected(vic) && (1<=att<=32))
		{
			new message[512],temp[64]
			new name[32],len
			get_user_name(att,name,31)
			len=format(message,511,"%L",LANG_PLAYER,"ENEMY",name)
			new dis1[3],dis2[3]
			get_user_origin(att,dis1)
			get_user_origin(vic,dis2)
			new dist=get_distance(dis1,dis2)
			dist=dist/40//calculate distance (inch -> meter)
			format(temp,63,"%L",LANG_PLAYER,"DISTANCE",dist)
			len += format(message[len],511-len,"^n%s",temp )
			//damage all
			new total_damage, total_damage2
			for(new i=1;i<=7;i++)
			{
					total_damage+=fire[att][vic][i]
					total_damage2+=fire[vic][att][i]
			}
			//Center Core
			format(temp,63,"%L",LANG_PLAYER,"HURT_FROM_ATTACKER",att_wpn[att],total_damage)
			len += format(message[len],511-len,"^n%s",temp )

			if(total_damage2)
			{
			format(temp,63,"%L",LANG_PLAYER,"HURT_TO_VICTIM",att_wpn[vic],total_damage2)
			len += format(message[len],511-len,"^n^n%s",temp )
			}

			if(body[vic][att][1])
			{
			format(temp,63,"%L",LANG_PLAYER,"HEAD",fire[vic][att][1],body[vic][att][1])
			len += format(message[len],511-len,"^n%s",temp )
			}

			if(body[vic][att][2])
			{
			format(temp,63,"%L",LANG_PLAYER,"CHEST",fire[vic][att][2],body[vic][att][2])
			len += format(message[len],511-len,"^n%s",temp )
			}

			if(body[vic][att][3])
			{
			format(temp,63,"%L",LANG_PLAYER,"STOMACH",fire[vic][att][3],body[vic][att][3])
			len += format(message[len],511-len,"^n%s",temp )
			}

			if(body[vic][att][4] || body[vic][att][5])
			{
			format(temp,63,"%L",LANG_PLAYER,"ARM",fire[vic][att][4]+fire[vic][att][5],body[vic][att][4]+body[vic][att][5])
			len += format(message[len],511-len,"^n%s",temp )
			}

			if(body[vic][att][6] || body[vic][att][7])
			{
			format(temp,63,"%L",LANG_PLAYER,"LEG",fire[vic][att][6]+fire[vic][att][7],body[vic][att][6]+body[vic][att][7])
			len += format(message[len],511-len,"^n%s",temp )
			}

			new Float:hp,Float:ap
			pev(att,pev_health,hp)
			pev(att,pev_armorvalue,ap)

			format(temp,63,"^n%L",LANG_PLAYER,"HPAP",floatround(hp),floatround(ap))
			len += format(message[len],511-len,"^n%s",temp )

			if(MH_IsMetaHookPlayer(vic)) MH_DrawFontText(vic,message,0,HUD_X2,HUD_Y2,R2,G2,B2,14,3.0,1.0,0,1)
	}
}
public clear(para[])
{
	new att=para[0]
	new vic=para[1]
	reset_result(att, vic)
	reset_result(vic, 0)
}
public reset_result(id, target)
{
	if (!target)
	{
		for (new i = 1; i <= get_maxplayers(); i++)
		{
			for (new hi = 1; hi <= 7; hi++)
			{
				body[id][i][hi] = 0
				fire[id][i][hi] = 0
			}
		}
	}
	else
	{
		for (new hi = 1; hi <= 7; hi++)
		{
			body[id][target][hi] = 0
			fire[id][target][hi] = 0
		}
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

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg936\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset134 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang2052\\ f0\\ fs16 \n\\ par }
*/
