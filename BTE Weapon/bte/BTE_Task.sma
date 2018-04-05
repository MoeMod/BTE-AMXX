// [BTE Task Function]
enum _: TASK_LIST( += 2000)
{
	TASK_HAMMER_CHANGE = 1000,
	TASK_KNIFE_DELAY,
	TASK_BOT_WEAPON,
	TASK_BALROG1,
	TASK_FIREBOMB,
	TASK_HOLYBOMB,
	TASK_FLAMETHROWER,
}

public Task_Bot_Weapon(iTaskid)
{
	static id ; id = iTaskid - TASK_BOT_WEAPON;

	if (g_modruning == BTE_MOD_GD || g_modruning == BTE_MOD_TD2)
		return;

	new iWpn;

	new bitAvailableType = 0;

	for (new i = 0; i <= 7; i++)
	{
		if (g_wpn_menu_count[i] > 0)
			bitAvailableType |= (1 << i);
	}



	if (bitAvailableType & ((1 << 1) | (1 << 2) | (1 << 3) | (1 << 4) | (1 << 7)))
	{
		new wpn_type = 0;
		do
		{
			switch (random_num(0, 9))
			{
				case 0..3: wpn_type = 3; // rifle
				case 4..5: wpn_type = 2; // smg
				case 6..7: wpn_type = 4; // mg
				case 8: wpn_type = 1; // shotgun
				case 9: wpn_type = 7; // equip
			}

			if (bitAvailableType & (1 << wpn_type))
			{
				iWpn = g_wpn_menu[wpn_type][random_num(0, g_wpn_menu_count[wpn_type] - 1)];
				Pub_Give_Named_Wpn(id, c_sModel[iWpn]);
				break;
			}
			bitAvailableType &= ~(1 << wpn_type)
		}
		while(bitAvailableType);
	}
	
	// pistol
	iWpn = g_wpn_menu[0][random_num(0, g_wpn_menu_count[0] - 1)];
	Pub_Give_Named_Wpn(id, c_sModel[iWpn]);

	// knife
	iWpn = g_wpn_menu[6][random_num(0, g_wpn_menu_count[6] - 1)];
	Pub_Give_Named_Wpn(id, c_sModel[iWpn]);

	// grenade
	iWpn = g_wpn_menu[5][random_num(0, g_wpn_menu_count[5] - 1)];
	Pub_Give_Named_Wpn(id, c_sModel[iWpn]);
}
public Task_Reset(id)
{
	remove_task(id + TASK_HAMMER_CHANGE)
	remove_task(id + TASK_KNIFE_DELAY)
	g_hammer_changing[id] = 0
}

public Task_FlameThrower(iTask)
{
	new id = iTask - TASK_FLAMETHROWER;
	static damage = 5;
	if (bte_wpn_get_mod_running() == BTE_MOD_ZB1) damage = 30;
	Stock_Buff(id, damage, g_cache_flameburn, 5);
	if (!is_user_alive(id)) remove_task(iTask);
}
public Task_Balrog1(iTask)
{
	new id = iTask - TASK_BALROG1;
	static damage = 1;
	if (bte_wpn_get_mod_running() == BTE_MOD_ZB1) damage = 30;
	Stock_Buff(id, damage, g_cache_flameburn, 5);
	if (!is_user_alive(id)) remove_task(iTask);
}
public Task_Firebomb(iTask)
{
	new id = iTask - TASK_FIREBOMB;
	Stock_Buff(id, 40, g_cache_flameburn, 5);
	if (!is_user_alive(id)) remove_task(iTask);
}
public Task_Holybomb(iTask)
{
	new id = iTask - TASK_HOLYBOMB;
	Stock_Buff(id, 100, g_cache_holyburn, 5);
	if (!is_user_alive(id)) remove_task(iTask);
}