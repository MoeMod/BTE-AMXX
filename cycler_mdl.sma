/*

CSO have its own entity "cycler_mdl"
This plugins simulate its function
**You should change "cycler_mdl" to "info_target" in bsp first**

*/


#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>

new is_cycler_mdl[512];
new mdl0[512][32];
new mdl1[512][32];
new seq0[512][32];
new seq1[512][32];
new anitime[512][32];


new model[512][2];

public plugin_init()
{
	RegisterHam(Ham_Use, "info_target", "Use", 1);

	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0");
}

public plugin_precache()
{
	register_forward(FM_KeyValue, "KeyValue");

	RegisterHam(Ham_Spawn, "info_target", "Spawn", 1);
}

public Event_HLTV()
{
	for (new pEntity = 33; pEntity < 512; pEntity ++)
	{
		if (!is_cycler_mdl[pEntity])
			continue;

		engfunc(EngFunc_SetModel, pEntity, mdl0[pEntity]);

		set_pev(pEntity, pev_sequence, str_to_num(seq0[pEntity]));
		set_pev(pEntity, pev_frame, 0.0);
		set_pev(pEntity, pev_animtime, 0.0);
	}
}

public KeyValue(pEntity, kvdid)
{
	new keyname[32];
	get_kvd(kvdid, KV_KeyName, keyname, 31);

	if (equal(keyname, "_mdl0"))
	{
		is_cycler_mdl[pEntity] = 1;
		get_kvd(kvdid, KV_Value, mdl0[pEntity], 31);
	}

	if (equal(keyname, "_mdl1"))
	{
		is_cycler_mdl[pEntity] = 1;
		get_kvd(kvdid, KV_Value, mdl1[pEntity], 31);
	}

	if (equal(keyname, "_seq0"))
	{
		is_cycler_mdl[pEntity] = 1;
		get_kvd(kvdid, KV_Value, seq0[pEntity], 31);
	}

	if (equal(keyname, "_seq1"))
	{
		is_cycler_mdl[pEntity] = 1;
		get_kvd(kvdid, KV_Value, seq1[pEntity], 31);
	}

	if (equal(keyname, "anitime"))
	{
		is_cycler_mdl[pEntity] = 1;
		get_kvd(kvdid, KV_Value, anitime[pEntity], 31);
	}
}

public Spawn(pEntity)
{
	if (!is_cycler_mdl[pEntity])
		return;

	model[pEntity][0] = engfunc(EngFunc_PrecacheModel, mdl0[pEntity]);
	model[pEntity][1] = engfunc(EngFunc_PrecacheModel, mdl1[pEntity]);
	engfunc(EngFunc_SetModel, pEntity, mdl0[pEntity]);

	//server_print("Spawn %d %s", pEntity, mdl0[pEntity]);
	set_pev(pEntity, pev_sequence, str_to_num(seq0[pEntity]));
	set_pev(pEntity, pev_frame, 0.0);
	set_pev(pEntity, pev_animtime, 0.0);
}

public Use(pEntity, pActivator, pCaller, useType, value)
{
	if (!is_cycler_mdl[pEntity])
		return;

	//server_print("Use id: %d pActivator: %d pCaller: %d useType: %d value: %d", pEntity, pActivator, pCaller, useType, value);

	engfunc(EngFunc_SetModel, pEntity, mdl1[pEntity]);

	set_pev(pEntity, pev_sequence, str_to_num(seq1[pEntity]));
	set_pev(pEntity, pev_frame, 0.0);
	set_pev(pEntity, pev_framerate, 1.0);
	set_pev(pEntity, pev_animtime, str_to_float(anitime[pEntity]));
}
