#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>

enum _:
{
	USE_OFF,
	USE_ON,
	USE_SET,
	USE_TOGGLE
}

new is_func_wall_toggle[512];

public plugin_init()
{
	register_event("HLTV", "Event_HLTV", "a", "1=0", "2=0");
}

public plugin_precache()
{
	register_forward(FM_KeyValue, "KeyValue");
}

public KeyValue(pEntity, kvdid)
{
	if (!pev_valid(pEntity))
		return;

	new classname[32];
	pev(pEntity, pev_classname, classname, 32);

	if (!strcmp("func_wall_toggle", classname))
		is_func_wall_toggle[pEntity] = 1;
}

public Event_HLTV()
{
	for (new pEntity = 33; pEntity < 512; pEntity ++)
	{
		if (!is_func_wall_toggle[pEntity])
			continue;

		// Use(CBaseEntity *pActivator, CBaseEntity *pCaller, USE_TYPE useType, float value)
		ExecuteHamB(Ham_Use, pEntity, 0, 0, USE_OFF, 0);
	}
}
