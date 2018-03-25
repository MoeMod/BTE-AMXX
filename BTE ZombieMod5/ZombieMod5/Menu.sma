native MH_ZombieMenu(id,a[]);

public ShowZombieMenu(id)
{
	if(!g_zombie[id]) return

	g_iCanUseSkill[id] = 0;

	if (task_exists(id + TASK_SHOWINGMENU)) remove_task(id + TASK_SHOWINGMENU);
	set_task(5.0, "SetCanUseSkill", id + TASK_SHOWINGMENU);
	/*new menuwpn_title[64]
	format(menuwpn_title, 63, "%L",LANG_PLAYER,"BTE_ZB3_ZOMBIE_MENU_TITLE")
	new mHandleID = menu_create(menuwpn_title, "select_zombie")
	new class_name[32], class_id[32]*/

	new model_name[32]
	new message[512];

	for (new i = 0; i < class_count; i++)
	{
		/*ArrayGetString(zombie_name, i, class_name, charsmax(class_name))
		formatex(class_id, charsmax(class_name), "%i", i)
		menu_additem(mHandleID, class_name, class_id, 0)*/

		ArrayGetString(zombie_model, i, model_name, charsmax(model_name))
		/*PRINT("%s %d",model_name,strlen(model_name));*/

		format(message,511,"%s%s#",message,model_name);

	}
	MH_ZombieMenu(id,message);
	//menu_display(id, mHandleID, 0)
}
public SetCanUseSkill(iTask)
{
	g_iCanUseSkill[iTask - TASK_SHOWINGMENU] = 1;
}

public SelectZombie(id)
{
	if(g_iCanUseSkill[id])
		return PLUGIN_HANDLED;

	new sCmd[32];
	read_argv(1,sCmd,31);

	new i = str_to_num(sCmd);
	if(i < class_count)
	{
		g_zombieclass[id] = i;
		Make_Zombie(id, 0);
		ExecuteForward(g_fwUserInfected, g_fwDummyResult, id, 33);

		if (task_exists(id + TASK_SHOWINGMENU)) remove_task(id + TASK_SHOWINGMENU);
		g_iCanUseSkill[id] = 1;
	}

	return PLUGIN_HANDLED;
}
/*public select_zombie(id, menu, item)
{
	if (!g_zombie[id]) return PLUGIN_HANDLED

	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new idclass[32], name[32], access
	menu_item_getinfo(menu, item, access, idclass, 31, name, 31, access)

	// set class zombie
	g_zombieclass[id] = str_to_num(idclass)
	Make_Zombie(id,0)

	menu_destroy(menu)
	return PLUGIN_HANDLED
}*/
