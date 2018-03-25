/*
func_breakable for bk_blackout.bsp
*/


#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <xs>

new Float:kick_damage[512];
new Float:kick_power_z[512];
new Float:kick_power[512];
new Float:kick_radius[512];

new mp_friendlyfire;

public plugin_init()
{
	RegisterHam(Ham_TakeDamage, "func_breakable", "TakeDamage");
	RegisterHam(Ham_TakeDamage, "func_breakable", "TakeDamage_Post", 1);

	mp_friendlyfire = get_cvar_pointer("mp_friendlyfire");
}

public plugin_precache()
{
	register_forward(FM_KeyValue, "KeyValue");
}

public KeyValue(pEntity, kvdid)
{
	new keyname[32], value[32];
	get_kvd(kvdid, KV_KeyName, keyname, 31);
	get_kvd(kvdid, KV_Value, value, 31);

	if (equal(keyname, "kick_damage"))
		kick_damage[pEntity] = str_to_float(value);
	else if (equal(keyname, "kick_power_z"))
		kick_power_z[pEntity] = str_to_float(value);
	else if (equal(keyname, "kick_power"))
		kick_power[pEntity] = str_to_float(value);
	else if (equal(keyname, "kick_radius"))
		kick_radius[pEntity] = str_to_float(value);
}

#define DMG_BULLET (1<<1)
#define DMG_EXPLOSION (1<<24)

new Float:origin[3];

public TakeDamage(pEntity, pevInflictor, pevAttacker, flDamage, bitsDamageType)
{
	//pev(pEntity, pev_origin, origin);
	GetOrigin(pEntity, origin);
}

public TakeDamage_Post(pEntity, pevInflictor, pevAttacker, flDamage, bitsDamageType)
{
	if (kick_radius[pEntity] <= 0.0 || kick_damage[pEntity] <= 0.0)
		return;

	new Float:health;
	pev(pEntity, pev_health, health);

	if (health > 0.0)
		return;

	new ff = get_pcvar_num(mp_friendlyfire);
	set_pcvar_num(mp_friendlyfire, 1);
	RadiusDamage(origin, pEntity, pevAttacker, kick_damage[pEntity], kick_radius[pEntity], kick_power[pEntity], kick_power_z[pEntity], DMG_BULLET, 1);
	set_pcvar_num(mp_friendlyfire, ff);
}

enum _:HITGROUP
{
	HITGROUP_GENERIC = 0,
	HITGROUP_HEAD,
	HITGROUP_CHEST,
	HITGROUP_STOMACH,
	HITGROUP_LEFTARM,
	HITGROUP_RIGHTARM,
	HITGROUP_LEFTLEG,
	HITGROUP_RIGHTLEG,
	HITGROUP_SHIELD
}

stock m_LastHitGroup = 75 // int

stock RadiusDamage(Float:vecSrc[3], id, pevAttacker, Float:flDamage, Float:flRadius, Float:flKnockBack, Float:flKnockBackZ, bitsDamageType, bDistanceCheck = 1)
{
	new pEntity = -1;
	new tr = create_tr2();
	new Float:flAdjustedDamage, Float:falloff;

	if (bDistanceCheck)
		falloff = flDamage / flRadius;
	else
		falloff = 0.0;

	new bInWater = (engfunc(EngFunc_PointContents, vecSrc) == CONTENTS_WATER);

	while ((pEntity = engfunc(EngFunc_FindEntityInSphere, pEntity, vecSrc, flRadius)) != 0)
	{
		if (id == pEntity)
			continue;

		if (pev(pEntity, pev_takedamage) == DAMAGE_NO)
			continue;

		if (bInWater && !pev(pEntity, pev_waterlevel))
			continue;

		if (!bInWater && pev(pEntity, pev_waterlevel) == 3)
			continue;

		new Float:vecEnd[3];
		GetOrigin(pEntity, vecEnd);

		engfunc(EngFunc_TraceLine, vecSrc, vecEnd, 0, 0, tr);

		new Float:flFraction;
		get_tr2(tr, TR_flFraction, flFraction);

		xs_vec_sub(vecEnd, vecSrc, vecEnd);

		new Float:flDistance = xs_vec_len(vecEnd);
		if (flDistance < 1.0)
			flDistance = 0.0;

		flAdjustedDamage = flDistance * falloff;
		flAdjustedDamage = flDamage - flAdjustedDamage;

		if (flFraction < 1.0)
			flAdjustedDamage *= 0.8;

		if (flAdjustedDamage <= 0)
			continue;

		new Float:velocity[3];

		if (IsPlayer(pEntity))
		{
			new Float:flAdjustedKickback[2];
			flAdjustedKickback[0] = bDistanceCheck ? (flKnockBack - (flDistance * (flKnockBack / flRadius))) : flKnockBack;
			flAdjustedKickback[1] = bDistanceCheck ? (flKnockBackZ - (flDistance * (flKnockBack / flRadius))) : flKnockBackZ;

			xs_vec_normalize(vecEnd, vecEnd);
			xs_vec_mul_scalar(vecEnd, flAdjustedKickback[0], velocity);
			velocity[2] = flKnockBackZ/*flAdjustedKickback[1]*/;

			set_pdata_int(pEntity, m_LastHitGroup, HITGROUP_CHEST)
		}

		if (IsPlayer(pEntity))
			ExecuteHamB(Ham_TakeDamage, pEntity, id, pevAttacker, flAdjustedDamage > 9000.0 ? 9000.0 : flAdjustedDamage, bitsDamageType);
		else
			ExecuteHamB(Ham_TakeDamage, pEntity, id, pevAttacker, flAdjustedDamage, bitsDamageType);

		if (IsPlayer(pEntity))
			set_pev(pEntity, pev_velocity, velocity);
	}

	free_tr2(tr);
}

stock GetOrigin(pEntity, Float:vecOrigin[3])
{
	new Float:maxs[3], Float:mins[3];
	if (pev(pEntity, pev_solid) == SOLID_BSP)
	{
		pev(pEntity, pev_maxs, maxs);
		pev(pEntity, pev_mins, mins);
		vecOrigin[0] = (maxs[0] - mins[0]) / 2 + mins[0];
		vecOrigin[1] = (maxs[1] - mins[1]) / 2 + mins[1];
		vecOrigin[2] = (maxs[2] - mins[2]) / 2 + mins[2];
	}
	else pev(pEntity, pev_origin, vecOrigin);
}

#define CLASS_PLAYER 2

stock IsPlayer(pEntity)
{
	if (pEntity <= 0)
		return 0;

	return ExecuteHam(Ham_Classify, pEntity) == CLASS_PLAYER;
}