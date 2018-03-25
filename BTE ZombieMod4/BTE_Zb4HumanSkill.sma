#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include "offset.inc"
#include "inc.inc"
#include "animation.inc"

#include "BTE_Zb4_API.inc"
#include "BTE_API.inc"

#define PLUGIN "BTE Zb4 Human Skill"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define _BOT_USE_SKILL

new g_iAccshoot[33], g_iSpeedUp[33], g_iKick[33];
new g_hamczbots, bot_quota;
new g_msgTextMsg;

#define TASK_REMOVE_SKILL	6413
#define TASK_REMOVE_KICK	6513

new g_fw_Kick, g_fw_DummyResult;
new Cache_Event;

#if defined _BOT_USE_SKILL
new iBotSkillRandom[33];
#endif


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_clcmd("z4_kick", "Kick");
	register_clcmd("z4_accshoot", "AccshootStart");
	register_clcmd("+dash", "DashStart");
	register_clcmd("-dash", "DashEnd");
	
	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0");
	
	RegisterHam(Ham_TraceAttack, "player", "HamF_TraceAttack");
	RegisterHam(Ham_TakeDamage, "player", "HamF_TakeDamage");
	
	register_forward(FM_PlayerPostThink, "Forward_PlayerPostThink", 1);
	register_forward(FM_ClientCommand, "Forward_ClientCommand");
	
	bot_quota = get_cvar_pointer("bot_quota");
	
	g_msgTextMsg = get_user_msgid("TextMsg");
	
	g_fw_Kick = CreateMultiForward("bte_zb4_kick", ET_IGNORE, FP_CELL, FP_CELL);
}

public plugin_precache()
{
	precache_model("models/v_foot.mdl");
	precache_sound("zombi/z4/all/kick.wav");
	precache_sound("zombi/z4/all/kick_metal1.wav");
	precache_sound("zombi/z4/all/kick_metal2.wav");
	precache_sound("zombi/z4/all/kick_wood1.wav");
	precache_sound("zombi/z4/all/kick_wood2.wav");
	precache_sound("zombi/z4/all/kick_stone1.wav");
	precache_sound("zombi/z4/all/kick_stone2.wav");
	
	Cache_Event = engfunc(EngFunc_PrecacheEvent, 1, "events/knife.sc");
}

public Event_HLTV()
{
	for(new id=1;id<=32;id++)
	{
		if(task_exists(id + TASK_REMOVE_KICK)) remove_task(id + TASK_REMOVE_KICK);
		iBotSkillRandom[id] = random_num(40, 70);
		g_iKick[id] = 0;
		bte_set_using_skill(id, 0);
	}
}

public Forward_ClientCommand(id)
{
	if (pev(id, pev_deadflag) != DEAD_NO)
		return FMRES_IGNORED;
	
	if (!g_iKick[id])
		return FMRES_IGNORED;
	
	new szCmd[32]
	read_argv(0, szCmd, 31);
	
	if (equal(szCmd, "drop") || equal(szCmd, "lastinv") || equal(szCmd,"weapon_", 7))
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}

public Forward_PlayerPostThink(id)
{
	if (pev(id, pev_deadflag) != DEAD_NO)
		return FMRES_IGNORED;
	
	if (bte_get_user_zombie(id))
		return FMRES_IGNORED;
	
	if (g_iSpeedUp[id])
		set_pev(id, pev_maxspeed, 350.0);
	
	return FMRES_IGNORED;
}

public Kick(id)
{
	if (bte_get_user_zombie(id))
		return PLUGIN_HANDLED;
	
	if (/*bte_get_user_power(id) < 10 || */g_iKick[id])
		return PLUGIN_HANDLED;
	
	if (get_pdata_int(id, m_iFOV) < 90 || pev(id, pev_flags) & FL_DUCKING)
	{
		TextMsg(id, HUD_PRINTCENTER, "#CSBTE_ZB4_Kick_Cannot_Use");
		
		return PLUGIN_HANDLED;
	}
	g_iKick[id] = 1;
	//bte_set_user_power(id, -10, 0.5);
	//bte_set_using_skill(id, 1);
	
	new iEnt = get_pdata_cbase(id, m_pActiveItem);
	set_pdata_float(id, m_flNextAttack, 1.0);
	set_pdata_float(iEnt, m_flNextPrimaryAttack, 1.0);
	set_pdata_float(iEnt, m_flNextSecondaryAttack, 1.0);
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.0);
	
	set_pdata_int(iEnt, m_fInReload, 0);
	set_pdata_int(iEnt, m_fInSpecialReload, 0);
	
	set_pev(id, pev_viewmodel2, "models/v_foot.mdl");
	set_pev(id, pev_weaponmodel, 0);
	
	SendWeaponAnim(id, 1);
	PlayAnimation(id, "zombiekick");
	
	KickAttack(id);
	
	set_task(1.0, "RemoveKick", id + TASK_REMOVE_KICK);
	
	return PLUGIN_HANDLED;
}

enum _:HIT_RESULT
{
	RESULT_HIT_NONE = 0,
	RESULT_HIT_PLAYER,
	RESULT_HIT_WORLD
}

stock GetGunPosition(id, Float:vecScr[3])
{
	new Float:vecViewOfs[3];
	pev(id, pev_origin, vecScr);
	pev(id, pev_view_ofs, vecViewOfs);
	xs_vec_add(vecScr, vecViewOfs, vecScr);
}

public KickAttack(id)
{
	new iHitResult = bte_KnifeAttack(id, false, 72.0, 100.0);
	
	new Float:vecStart[3], Float:vecEnd[3], Float:v_angle[3], Float:vecForward[3];
	
	GetGunPosition(id, vecStart);
	
	pev(id, pev_v_angle, v_angle);
	engfunc(EngFunc_MakeVectors, v_angle);
	
	global_get(glb_v_forward, vecForward);
	xs_vec_mul_scalar(vecForward, 600.0, vecForward);
	
	xs_vec_add(vecStart, vecForward, vecEnd);
	
	new tr = create_tr2();
	engfunc(EngFunc_TraceLine, vecStart, vecEnd, 0, id, tr);
	
	new Float:flFraction;
	get_tr2(tr, TR_flFraction, flFraction);
	
	switch (iHitResult)
	{
		case RESULT_HIT_PLAYER :
		{
			new pHit = get_tr2(tr, TR_pHit);
			if (is_user_connected(pHit))
				if (bte_get_user_zombie(pHit)/* && !bte_zb4_is_stuned(pHit)*/)
				{
					CreateKnockBack(id, pHit, 2000.0, 500.0);
					if(bte_zb4_is_stuned(pHit))
						bte_set_user_power(id, 30, 0.5);
					PlayAnimation(pHit, "hammer_flinch");
					ExecuteForward(g_fw_Kick, g_fw_DummyResult, pHit, id);
				}
			
			emit_sound(id, CHAN_ITEM, "zombi/z4/all/kick.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
		case RESULT_HIT_NONE : emit_sound(id, CHAN_ITEM, "zombi/z4/all/kick.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
		case RESULT_HIT_WORLD : 
		{
			new iTtextureType;
			
			if (flFraction != 1.0)
			{
				new pTextureName[64];
				engfunc(EngFunc_TraceTexture, 0, vecStart, vecEnd, pTextureName, charsmax(pTextureName));
				iTtextureType = dllfunc(DLLFunc_PM_FindTextureType, pTextureName);
			}
			
			free_tr2(tr);
			
			new szSound[32];
			
			if (iTtextureType == 'M' || iTtextureType == 'V' || iTtextureType == 'P')
			{
				switch (random_num(0,1))
				{
					case 0 : format(szSound, charsmax(szSound), "zombi/z4/all/kick_metal1.wav");
					case 1 : format(szSound, charsmax(szSound), "zombi/z4/all/kick_metal2.wav");
				}
			}		
			else if (iTtextureType == 'W')
			{
				switch (random_num(0,1))
				{
					case 0 : format(szSound, charsmax(szSound), "zombi/z4/all/kick_wood1.wav");
					case 1 : format(szSound, charsmax(szSound), "zombi/z4/all/kick_wood2.wav");
				}
			}
			else
			{
				switch (random_num(0,1))
				{
					case 0 : format(szSound, charsmax(szSound), "zombi/z4/all/kick_stone1.wav");
					case 1 : format(szSound, charsmax(szSound), "zombi/z4/all/kick_stone2.wav");
				}
			}
			
			emit_sound(id, CHAN_ITEM, szSound, 1.0, ATTN_NORM, 0, PITCH_NORM);
		}
	}
}

public RemoveKick(taskid)
{
	new id = taskid - TASK_REMOVE_KICK;
	
	if (bte_get_user_zombie(id))
		return;
	
	if (pev(id, pev_deadflag) != DEAD_NO)
		return;
	
	g_iKick[id] = 0;
	bte_set_using_skill(id, 0);
	
	ExecuteHamB(Ham_Item_Deploy, get_pdata_cbase(id, m_pActiveItem));
}

public DashStart(id)
{
	if (bte_get_user_zombie(id))
		return PLUGIN_CONTINUE;
	
	if (!is_user_alive(id))
		return PLUGIN_HANDLED;
	
	if (bte_get_user_power(id) < 5)
		return PLUGIN_HANDLED;
	
	if (!g_iSpeedUp[id])
		MH_ZB4SendData(id, 3);
	
	g_iSpeedUp[id] = 1;
	bte_zb4_set_dash(id, 1, 0.5, 5);
	
	return PLUGIN_HANDLED;
}

new Ham:Ham_Player_ResetMaxSpeed = Ham_Item_PreFrame

public DashEnd(id)
{
	if (bte_get_user_zombie(id))
		return PLUGIN_CONTINUE;
	
	if (!is_user_alive(id))
		return PLUGIN_HANDLED;
	
	if (g_iSpeedUp[id])
		MH_ZB4SendData(id, 4);
	
	g_iSpeedUp[id] = 0;
	bte_zb4_set_dash(id, 0, 0.0, 0);
	
	ExecuteHam(Ham_Player_ResetMaxSpeed, id);
	
	return PLUGIN_HANDLED;
}

public AccshootStart(id)
{
	if (bte_get_user_zombie(id))
		return PLUGIN_HANDLED;
	
	if (g_iAccshoot[id])
		return PLUGIN_HANDLED;
	
	new iPower = bte_get_user_power(id);
	if (iPower < 30)
		return PLUGIN_HANDLED;
	
	new Float:flSkillTime = iPower / 20.0;
	set_task(flSkillTime, "RemoveSkill", id + TASK_REMOVE_SKILL);
	// 这里用task似乎会有点计时不准
	
	new Float:flFlashTime = iPower / 20.0;
	bte_set_user_power(id, -100, flFlashTime);
	
	g_iAccshoot[id] = 1;
	bte_set_using_skill(id, 1);
	MH_ZB4SendData(id, 0);
	
	// fparam1 = 时间 iparam2 == 1 = z4_skull.spr
	engfunc(EngFunc_PlaybackEvent, FEV_GLOBAL, id, Cache_Event, 0.0, {0.0, 0.0, 0.0}, {0.0, 0.0, 0.0}, flSkillTime , 0.0, (1<<6), 1, false, false);
	
	return PLUGIN_HANDLED;
}

public RemoveSkill(taskid)
{
	new id = taskid - TASK_REMOVE_SKILL;
	
	g_iAccshoot[id] = 0;
	bte_set_using_skill(id, 0);
	MH_ZB4SendData(id, 1);
}

public HamF_TakeDamage(iVictim, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if (iAttacker > 32 || !iAttacker)
		return HAM_IGNORED;
	
	if (iInflictor == iAttacker && get_user_weapon(iAttacker) == CSW_KNIFE)
	{
		SetHamParamFloat(4, flDamage / 2.0); // 刀的攻击在 TraceAttack 里会被 * 4 这里 / 2 也就是两倍总伤害
		
		return HAM_IGNORED;
	}
	
	if (iInflictor > 32 && !bte_get_user_zombie(iAttacker) && g_iAccshoot[iAttacker])
	{
		new szClassname[16];
		pev(iInflictor, pev_classname, szClassname, charsmax(szClassname));
		if (equal(szClassname, "grenade"))
			return HAM_IGNORED;
		
		set_pdata_int(iVictim, m_LastHitGroup, 1);
		SetHamParamFloat(4, flDamage * 2.0);
		
		return HAM_IGNORED;
	}
	
#if 1
	if (!(bitsDamageType & (DMG_BULLET)) && g_iAccshoot[iAttacker]) // 这里还是在武器插件中整体换掉旧特殊功能武器的写法才好
	{
		set_pdata_int(iVictim, m_LastHitGroup, 1);
		SetHamParamFloat(4, flDamage * 4.0);
		
		return HAM_IGNORED;
	}
#endif
	
#if defined _BOT_USE_SKILL
	if (is_user_bot(iAttacker) && bte_get_user_power(iAttacker) > iBotSkillRandom[iAttacker] && !bte_get_user_zombie(iAttacker) && bte_zb4_get_day_status() != DAYSTATUS_NIGHT)
		AccshootStart(iAttacker);
#endif
	return HAM_IGNORED;
}

public HamF_TraceAttack(iVictim, iAttacker, Float:flDamage, Float:vecDir[3], ptr, bitsDamageType)
{
	if (bte_get_user_zombie(iAttacker))
		return HAM_IGNORED;
	
	// 跳过非原版武器攻击
	if (!(bitsDamageType & (DMG_BULLET)))
		return HAM_IGNORED;
	
	if (g_iAccshoot[iAttacker])
		set_tr2(ptr, TR_iHitgroup, 1);
	
	return HAM_IGNORED;
}

public client_putinserver(id)
{
	g_iAccshoot[id] = 0;
	g_iSpeedUp[id] = 0;
	
	if (!g_hamczbots && is_user_bot(id) && get_pcvar_num(bot_quota) > 0)
	{
		set_task(0.1, "RegisterHamBot", id)
	}
}

public bte_zb_infected(iVictim, iAttacker)
{
	DashEnd(iVictim);
}

public RegisterHamBot(id)
{
	if (g_hamczbots || !is_user_connected(id))
		return;

	RegisterHamFromEntity(Ham_TraceAttack, id, "HamF_TraceAttack");
	RegisterHamFromEntity(Ham_TakeDamage, id, "HamF_TakeDamage");

	g_hamczbots = 1;
}

public plugin_natives()
{
	register_native("bte_zb4_is_using_accshoot", "is_using_accshoot", 1);
}

public is_using_accshoot(id)
{
	return g_iAccshoot[id];
}

stock SendWeaponAnim(id, iAnim)
{
	if(!is_user_alive(id)) return;
	
	set_pev(id, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(iAnim)
	write_byte(pev(id, pev_body))
	message_end()
}

stock PlayEmitSound(id, type, const sound[])
{
	emit_sound(id, type, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

stock TextMsg(id, type, message[], str1[] = "", str2[] = "", str3[] = "", str4[] = "")
{
	new dest
	if (id) dest = MSG_ONE
	else dest = MSG_ALL
	
	message_begin(dest, g_msgTextMsg, {0,0,0}, id)
	write_byte(type)
	write_string(message)
	
	if(str1[0])
		write_string(str1)
	if(str2[0])
		write_string(str2)
	if(str3[0])
		write_string(str3)
	if(str4[0])
		write_string(str4)
		
	message_end()
}

stock CreateKnockBack(iAttacker, iVictim, Float:fMulti, Float:fZVelocity = 0.0)
{
	new Float:vVictim[3], Float:vAttacker[3];
	pev(iVictim, pev_origin, vVictim);
	pev(iAttacker, pev_origin, vAttacker);
	
	xs_vec_sub(vVictim, vAttacker, vVictim);
	xs_vec_normalize(vVictim, vVictim);
	xs_vec_mul_scalar(vVictim, fMulti, vVictim);
	
	new Float:vVelocity[3];
	pev(iVictim, pev_velocity, vVelocity);
	xs_vec_add(vVelocity, vVictim, vVelocity);
	
	if(fZVelocity)
		vVelocity[2] = fZVelocity;
	
	set_pev(iVictim, pev_velocity, vVelocity);
}

