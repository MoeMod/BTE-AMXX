
native BTE_SetThink(iEnt, const function[]);
native BTE_SetTouch(iEnt, const function[]);
native BTE_SetUse(iEnt, const function[]);
native BTE_EButtonCreate(iEnt, bShow = 1, iTeamLimit = 0, bAutoRemove = 1);
native BTE_EButtonRemove(iEnt);
native OpenBuyMenu(id);

public HamF_InfoTarget_ObjectCaps(iEnt)
{
	if (!pev_valid(iEnt))
		return HAM_IGNORED;
	static classname[32];
	pev(iEnt, pev_classname, classname, charsmax(classname));
	if (!equal(classname, SUPPLYBOX_CLASSNAME))
		return HAM_IGNORED;
	SetHamReturnInteger(0x00000020);
	return HAM_SUPERCEDE;
}

public SupplyBoxEffect_FollowThink(iEnt)
{
	if (!pev_valid(pev(iEnt, pev_owner)))
	{
		engfunc(EngFunc_RemoveEntity, iEnt);
		return;
	}
	static Float:vecOrigin[3];
	pev(pev(iEnt, pev_owner), pev_origin, vecOrigin);
	vecOrigin[2] += 25.0;
	set_pev(iEnt, pev_origin, vecOrigin);
	set_pev(iEnt, pev_nextthink, get_gametime()+0.05);
}

public SupplyBox_EButtonThink(iEnt)
{
#if 0
	new pEntity = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"));
	engfunc(EngFunc_SetModel, pEntity, "sprites/e_button01.spr");
	engfunc(EngFunc_SetSize, pEntity, Float:{-16.0, -16.0, -16.0}, Float:{16.0, 16.0, 16.0});
	set_pev(pEntity, pev_owner, iEnt);
	set_pev(pEntity, pev_movetype, MOVETYPE_NONE);
	set_pev(pEntity, pev_solid, SOLID_NOT);
	set_pev(pEntity, pev_rendermode, kRenderTransAdd);
	set_pev(pEntity, pev_renderamt, 200.0);
	set_pev(pEntity, pev_scale, 0.12);
	set_pev(pEntity, pev_nextthink, get_gametime()+0.05);
	BTE_SetThink(pEntity, "SupplyBoxEffect_FollowThink");
#endif
	BTE_EButtonCreate(iEnt, 1, 1);
	BTE_SetThink(iEnt, "");
}

public CreateSupplyBox()
{
	if (g_supplybox_count>=SUPPLYBOX_MAX || !g_bInfectionStart || g_bRoundTerminating) return

	g_supplybox_count ++
	new iEnt = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,"info_target"))
	set_pev(iEnt,pev_classname,SUPPLYBOX_CLASSNAME)
	engfunc(EngFunc_SetModel,iEnt,SUPPLYBOX_MODEL)
	engfunc(EngFunc_SetSize,iEnt,Float:{-2.0,-2.0,-2.0},Float:{5.0,5.0,5.0})
	set_pev(iEnt,pev_solid, SOLID_TRIGGER)
	set_pev(iEnt,pev_movetype, MOVETYPE_TOSS)
	SupplyBoxRandomSpawn(iEnt)

	BTE_SetThink(iEnt, "SupplyBox_EButtonThink");
	set_pev(iEnt, pev_nextthink, get_gametime()+0.1);
}

public SupplyBoxRandomSpawn(id)
{
	static hull, sp_index, i
	hull = (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN

	if (!g_spawnCount_box) return
	sp_index = random_num(0, g_spawnCount_box - 1)
	for (i = sp_index + 1;; i++)
	{
		if (i >= g_spawnCount_box) i = 0
		if (CheckHull(g_spawns_box[i], hull))
		{
			engfunc(EngFunc_SetOrigin, id, g_spawns_box[i])
			break;
		}
		if (i == sp_index)
			break;
	}
}

public SupplyBox_Use(iEnt, iCaller)
{
	if (!pev_valid(iEnt))
		return;
	static classname[32];
	pev(iEnt, pev_classname, classname, charsmax(classname));
	if (!equal(classname, SUPPLYBOX_CLASSNAME))
		return;
	if (!is_user_connected(iCaller) || !is_user_alive(iCaller))
		return;
	if (iCaller < 1 || iCaller > 32)
		return;
	if (g_zombie[iCaller])
		return;

	if (!g_hero[iCaller])
		OpenBuyMenu(iCaller);

	bte_wpn_set_fullammo(iCaller);
	bte_wpn_give_grenade(iCaller);

	if (!get_pdata_bool(iCaller, m_bHasNightVision))
		Message_HudTextPro(iCaller, "#Hint_use_nightvision");

	set_pdata_bool(iCaller, m_bHasNightVision, true);

	if (!get_pdata_bool(iCaller, m_bNightVisionOn))
		client_cmd(iCaller,"nightvision");

	BTE_EButtonRemove(iEnt);
	engfunc(EngFunc_RemoveEntity, iEnt);

	PlayEmitSound(iCaller, CHAN_WEAPON, SUPPLYBOX_SOUND_PICKUP)

	return;
}