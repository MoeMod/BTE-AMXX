#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>

#include "z4e_alarm.inc"

#define PLUGIN "[Z4E] Stats Boss"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

new Float:g_flRoundDamage[33]

new const szRank[][] = { "1st.", "2nd.", "3rd.", "4th.", "5th.", "6th.", "7th." }

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_TakeDamage, "info_target", "fw_BossTakeDamage_Post", 1);
}

public z4e_fw_gameplay_round_new()
{
	arrayset(_:g_flRoundDamage, 0, 33)
}

public z4e_fw_alarm_show_pre(iType, szTitle[128], szSubTitle[128], szSound[128], iColor[3], Float:flAlarmTime)
{
	if(iType != Z4E_ALARMTYPE_IDLE)
		return Z4E_ALARM_IGNORED
		
	new pBoss[3];
	new iBossCount;
	new pEntity = 0;
	while(pev_valid((pEntity = engfunc(EngFunc_FindEntityByString, pEntity, "classname", "z4e_boss"))))
	{
		if(iBossCount>=3)
			break;
		if(pev(pEntity, pev_takedamage) != DAMAGE_YES)
			continue;
		new Float:flHealth;
		pev(pEntity, pev_health, flHealth)
		if(flHealth <= 0.0)
			continue;
		
		pBoss[iBossCount] = pEntity;
		
		iBossCount++;
	}
	
	if(!iBossCount)
		return Z4E_ALARM_IGNORED
	
	new Float:flTotalHealth = 0.0
	for(new i=0;i < iBossCount;i++)
	{
		new Float:flMaxHealth
		pev(pBoss[i], pev_max_health, flMaxHealth)
		flTotalHealth+=flMaxHealth;
	}
	
	new szBar[128], iLen
	for(new i=0;i < iBossCount;i++)
	{
		if(i)
			szBar[iLen++] = '|';
		
		new Float:flMaxHealth, Float:flHealth
		pev(pBoss[i], pev_max_health, flMaxHealth)
		pev(pBoss[i], pev_health, flHealth)
		
		for(new i = 0; i < floatround((((flHealth * 100.0 / flMaxHealth) / 2.0) * (flMaxHealth / flTotalHealth)), floatround_ceil); i++) 
			szBar[iLen++] = '=';
		for(new i = 0; i < floatround((((100.0 - flHealth * 100.0 / flMaxHealth) / 2.0) * (flMaxHealth / flTotalHealth))); i++) 
			szBar[iLen++] = '^t';
		
		
	}
	szBar[iLen++] = 0;
		
	iColor[0] = 250
	iColor[1] = 50
	iColor[2] = 0
	format(szTitle, 127, "[%s]", szBar)
	
	new Float:flRankDamage[33], iRankID[33], szName[32]
	PlayerRankFloat(g_flRoundDamage, flRankDamage, iRankID)
	
	for(new i; i < 3; i++)
	{
		if(flRankDamage[i] <= 0.0)
			break;
		get_user_name(iRankID[i], szName, 31)
		if(flRankDamage[i] < 1000.0)
			format(szSubTitle, 127, "%s^n%s^t%s^t^t( %i )", szSubTitle, szRank[i], szName, floatround(flRankDamage[i]))
		else
			format(szSubTitle, 127, "%s^n%s^t%s^t^t( %i.%iK )", szSubTitle, szRank[i], szName, floatround(flRankDamage[i] / 100.0) / 10, floatround(flRankDamage[i] / 100.0) % 10)
	}
	
	return Z4E_ALARM_IGNORED
}

public fw_BossTakeDamage_Post(this, iInflictor, iAttacker, Float:flDamage, bitsDamageType)
{
	if(!pev_valid(this))
		return;
	if(!is_user_connected(iAttacker)) 
		return;
		
	new szClassName[32]
	pev(this, pev_classname, szClassName, charsmax(szClassName))
	if(!equal(szClassName, "z4e_boss"))
		return;
	g_flRoundDamage[iAttacker] += flDamage
}

stock PlayerRank(const iSrc[33], iRank[33], iRankID[33])
{
	for(new i = 0; i <= 32; i++)
	{
		flRank[i] = flSrc[i]
		iRankID[i] = i
	}
	
	for(new j = 0; j <= 32; j++)
		for(new i = 0; i <= 32-1-j; i++)
			if(iRank[i]<iRank[i+1])
			{
				new t,u
				t=iRank[i];
				u=iRankID[i];
				iRank[i]=iRank[i+1];
				iRankID[i]=iRankID[i+1];
				iRank[i+1]=t;
				iRankID[i+1]=u;
			}
	return true
}

stock PlayerRankFloat(const Float:flSrc[33], Float:flRank[33], iRankID[33])
{
	for(new i = 0; i <= 32; i++)
	{
		flRank[i] = flSrc[i]
		iRankID[i] = i
	}
	
	for(new j = 0; j <= 32; j++)
		for(new i = 0; i <= 32-1-j; i++)
			if(flRank[i] < flRank[i+1])
			{
				new Float:t, u
				t=flRank[i];
				u=iRankID[i];
				flRank[i]=flRank[i+1];
				iRankID[i]=iRankID[i+1];
				flRank[i+1]=t;
				iRankID[i+1]=u;
			}
	return true
}