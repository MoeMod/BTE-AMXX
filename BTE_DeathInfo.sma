#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#include <metahook>
#include <hamsandwich>
#include <BTE_API>
#define PLUGIN	"BTE Death Info"
#define VERSION	"1.0"
#define AUTHOR	"BTE TEAM"

native bte_wpn_deathinfo_weaponname(sName[], sSave[33]);


const R=168
const G=211
const B=253
const Float:HUD_X=0.55
const Float:HUD_Y=0.65
const R2=239
const G2=155
const B2=155
const Float:HUD_X2=0.40
const Float:HUD_Y2=0.60
new fire[33][33][8], body[33][33][8]
new att_wpn[33][33]
new szAttackWeapon[33][33];
new g_hamczbots

enum DeathInfo_s
{
	iVictim,
	iAttacker,
	bCanSend,
	WeaponName[32]
}

new any:g_DeathInfo[33][33][DeathInfo_s];

new Float:g_fOldHealth[33], Float:g_fHealth[33];
enum (+= 100)
{
	TASK_ATT = 6000,
	TASK_VIC
}

new bot_quota

new gmsgDeathInfo;

new g_isZSE;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_dictionary("bte_wpn.bte")
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_message(get_user_msgid("DeathMsg"),"get_wpname")
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage")
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage_Post",1)

	bot_quota = get_cvar_pointer("bot_quota")

	new config_dir[64], url_zse[64]
	get_configsdir(config_dir, charsmax(config_dir))
	format(url_zse, charsmax(url_zse), "%s/plugins-zse.ini", config_dir)

	if(file_exists(url_zse)) g_isZSE = 1

	gmsgDeathInfo = engfunc(EngFunc_RegUserMsg, "DeathInfo", -1);
}

public plugin_natives()
{
	register_native("BTE_DeathMsg", "MsgFunc_DeathMsg", 1);
	register_native("BTE_DeathInfo_TakeDamage_Pre", "HamF_TakeDamage", 1);
	register_native("BTE_DeathInfo_TakeDamage_Post", "HamF_TakeDamage_Post", 1);
}

public MsgFunc_DeathMsg(id, iVictim, iHeadShot, szWeapon[], iAssist)
{
	param_convert(4);
	
	new att = id;
	new vic = iVictim;
	new para[2]
	para[0]=att;
	para[1]=vic;
	
	new sWeapon[32];
	copy(sWeapon, charsmax(sWeapon), szWeapon);

	if (strlen(sWeapon) < 2)
		return;

	if (sWeapon[strlen(sWeapon) - 2] == '_')
		sWeapon[strlen(sWeapon) - 2] = 0;

	//bte_wpn_deathinfo_weaponname(sWeapon, szAttackWeapon[att]);
	g_DeathInfo[para[0]][para[1]][bCanSend] = 1;
	g_DeathInfo[para[0]][para[1]][iVictim] = para[1];
	g_DeathInfo[para[0]][para[1]][iAttacker] = para[0];
	copy(g_DeathInfo[para[0]][para[1]][WeaponName], 31, sWeapon);
	
}

public bte_zb_infected(victim,attacker)
{
	if(attacker >= 33) return;

	static para[2]
	para[0]=attacker
	para[1]=victim

	format(att_wpn[attacker],32,"-")
	format(szAttackWeapon[attacker],32,"-")
	copy(g_DeathInfo[attacker][victim][WeaponName], 31, "-");

	if(attacker)
	{
		if (task_exists(attacker+TASK_ATT)) remove_task(attacker+TASK_ATT)
		if (task_exists(victim+TASK_VIC)) remove_task(victim+TASK_VIC)
		set_task(0.0,"Display_att",attacker+TASK_ATT,para,2)
		set_task(0.0,"Display_vic",victim+TASK_VIC,para,2)
		set_task(0.5,"clear",_,para,2)
	}
}
public HamF_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(victim) || !is_user_connected(attacker) || (bte_get_user_zombie(attacker) == 1 && !g_isZSE)) return

	pev(victim, pev_health, g_fOldHealth[victim]);

	new sWeapon[1024];
	bte_wpn_get_wpn_name(attacker, 0, BTE_WPNDATA_CN_NAME, sWeapon);
	//bte_wpn_deathinfo_weaponname(sWeapon, att_wpn[attacker]);
	copy(g_DeathInfo[attacker][victim][WeaponName], 31, sWeapon);

	if (bte_get_user_zombie(attacker) == 1 && g_isZSE)
	{
		format(att_wpn[attacker], 32, "-");
		format(szAttackWeapon[attacker],32,"-")
	}

}

native MetahookMsg(id, type, i2 = -1, i3 = -1)

public HamF_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(victim) || !is_user_connected(attacker) || (bte_get_user_zombie(attacker) == 1 && !g_isZSE)) return
	
	new igroup,iamount
	pev(victim, pev_health, g_fHealth[victim]);

	iamount = floatround(g_fOldHealth[victim] - g_fHealth[victim]);
	if(iamount <= 0) return

	if(0<victim<33 && 0<attacker<33)
	{
		
		
		if(bte_get_user_showdamage(attacker) && bte_wpn_get_mod_running() == BTE_MOD_ZB1)
		{
			MetahookMsg(attacker, 50, iamount/255, iamount%255);
		}
		
		igroup = get_pdata_int(victim,75)
		if(!igroup || igroup < 0 || igroup > 7) igroup = HIT_CHEST
		fire[attacker][victim][igroup]+=iamount
		body[attacker][victim][igroup]+=1
		new iParam[2];
		if (g_DeathInfo[attacker][victim][bCanSend])
		{
			iParam[0] = g_DeathInfo[attacker][victim][iAttacker];
			iParam[1] = g_DeathInfo[attacker][victim][iVictim];
			g_DeathInfo[attacker][victim][bCanSend] = 0;
			copy(att_wpn[attacker], 32, szAttackWeapon[attacker]);
			Display_att(iParam);
			Display_vic(iParam);
			clear(iParam);
			g_DeathInfo[attacker][victim][iVictim] = g_DeathInfo[attacker][victim][iAttacker] = 0;
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

	if (sWeapon[strlen(sWeapon) - 2] == '_')
		sWeapon[strlen(sWeapon) - 2] = 0;

	//bte_wpn_deathinfo_weaponname(sWeapon, att_wpn[att]);
	g_DeathInfo[para[0]][para[1]][bCanSend] = 1;
	g_DeathInfo[para[0]][para[1]][iVictim] = para[1];
	g_DeathInfo[para[0]][para[1]][iAttacker] = para[0];
	//copy(g_DeathInfo[para[0]][para[1]][WeaponName], 31, sWeapon);
}
/*
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
		dist=dist/40						   //calculate distance (inch -> meter)
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

		if(MH_IsMetaHookPlayer(att))
			MH_DrawFontText(att,message,0,HUD_X,HUD_Y,R,G,B,14,6.0,0.0,0,1)
	}
}
*/
public Display_att(para[])
{
	new att=para[0]
	new vic=para[1]
	if(is_user_connected(att) && (1<=vic<=32))
	{
		new dis1[3],dis2[3]
		get_user_origin(att,dis1)
		get_user_origin(vic,dis2)
		new dist=get_distance(dis1,dis2)
		dist=dist/40						   //calculate distance (inch -> meter)
		//damage all
		
		new total_damage
		for(new i=1;i<=7;i++)
		{
			total_damage+=fire[att][vic][i]
		}
		engfunc(EngFunc_MessageBegin, MSG_ONE, gmsgDeathInfo, {0.0, 0.0, 0.0}, att);
		write_byte(1);
		write_byte(vic);
		write_byte(dist);
		write_string(g_DeathInfo[att][vic][WeaponName]);
		write_short(total_damage);
		
		// HEAD
		write_short(fire[att][vic][1]);
		write_byte(body[att][vic][1]);
		// CHEST
		write_short(fire[att][vic][2]);
		write_byte(body[att][vic][2]);
		// STOMACH
		write_short(fire[att][vic][3]);
		write_byte(body[att][vic][3]);
		// ARM
		write_short(fire[att][vic][4] + fire[att][vic][5]);
		write_byte(body[att][vic][4] + body[att][vic][5]);
		// LEG
		write_short(fire[att][vic][6] + fire[att][vic][7]);
		write_byte(body[att][vic][6] + body[att][vic][7]);
		
		message_end();
	}
}
/*
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
		
		if(total_damage2)
		{
			format(temp,63,"%L",LANG_PLAYER,"HURT_TO_VICTIM_WHEN_DEATH",att_wpn[vic],total_damage2)
			len += format(message[len],511-len,"^n^n%s",temp )
		}
		else
		{
			format(temp,63,"%L",LANG_PLAYER,"HURT_TO_VICTIM_NOTHING")
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
		if (total_damage2)
		{
			format(temp,63,"^n%L",LANG_PLAYER,"HPAP",floatround(hp),floatround(ap))
			len += format(message[len],511-len,"^n%s",temp )
		}

		if(MH_IsMetaHookPlayer(vic))
			MH_DrawFontText(vic,message,0,HUD_X2,HUD_Y2,R2,G2,B2,14,6.0,0.0,0,2)
	}
}*/

public Display_vic(para[])
{
	new att=para[0]
	new vic=para[1]
	if(is_user_connected(vic) && (1<=att<=32))
	{
		new dis1[3],dis2[3]
		get_user_origin(att,dis1)
		get_user_origin(vic,dis2)
		new dist=get_distance(dis1,dis2)
		dist=dist/40//calculate distance (inch -> meter)
		
		new iTotalDamageFromAttacker, iTotalDamageTake
		for(new i=1;i<=7;i++)
		{
			iTotalDamageFromAttacker+=fire[att][vic][i]
			iTotalDamageTake+=fire[vic][att][i]
		}
		
		new Float:hp,Float:ap
		pev(att,pev_health,hp)
		pev(att,pev_armorvalue,ap)
		
		engfunc(EngFunc_MessageBegin, MSG_ONE, gmsgDeathInfo, {0.0, 0.0, 0.0}, vic);
		write_byte(2);
		write_byte(att);
		write_byte(dist);
		write_string(g_DeathInfo[att][vic][WeaponName]);
		write_short(iTotalDamageFromAttacker);
		
		// HEAD
		write_short(fire[att][vic][1]);
		write_byte(body[att][vic][1]);
		// CHEST
		write_short(fire[att][vic][2]);
		write_byte(body[att][vic][2]);
		// STOMACH
		write_short(fire[att][vic][3]);
		write_byte(body[att][vic][3]);
		// ARM
		write_short(fire[att][vic][4] + fire[att][vic][5]);
		write_byte(body[att][vic][4] + body[att][vic][5]);
		// LEG
		write_short(fire[att][vic][6] + fire[att][vic][7]);
		write_byte(body[att][vic][6] + body[att][vic][7]);
		
		// Damage 2
		write_short(iTotalDamageTake);
		// HEAD
		write_short(fire[vic][att][1]);
		write_byte(body[vic][att][1]);
		// CHEST
		write_short(fire[vic][att][2]);
		write_byte(body[vic][att][2]);
		// STOMACH
		write_short(fire[vic][att][3]);
		write_byte(body[vic][att][3]);
		// ARM
		write_short(fire[vic][att][4] + fire[vic][att][5]);
		write_byte(body[vic][att][4] + body[vic][att][6]);
		// LEG
		write_short(fire[vic][att][6] + fire[vic][att][7]);
		write_byte(body[vic][att][6] + body[vic][att][7]);
		
		write_short(floatround(hp));
		write_short(floatround(ap));
		message_end();

		//if(MH_IsMetaHookPlayer(vic))
		//	MH_DrawFontText(vic,message,0,HUD_X2,HUD_Y2,R2,G2,B2,14,6.0,0.0,0,2)
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

