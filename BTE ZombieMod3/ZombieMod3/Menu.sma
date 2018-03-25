//native MH_ZombieMenu(id,a[]);

public ShowZombieMenu(id, bSelect)
{
	if(bSelect)
	{
		if(!g_zombie[id]) return

		g_iCanUseSkill[id] = 0;
		
		if (task_exists(id + TASK_SHOWINGMENU)) remove_task(id + TASK_SHOWINGMENU);
		set_task(5.0, "SetCanUseSkill", id + TASK_SHOWINGMENU);
	}
	
	new model_name[32]
	//new message[512];
	
	new iCount = class_count;
	if(g_iZbRevivalID>=0) iCount--;
	if(g_iZbTeleportID>=0) iCount--;
	iCount++; // random
	
	engfunc(EngFunc_MessageBegin, MSG_ONE, gmsgNormalZombieMenu, {0.0, 0.0, 0.0}, id);
	write_byte(bSelect);
	write_byte(iCount);
	for (new i = 0; i < class_count; i++)
	{
		if(i==g_iZbRevivalID || i==g_iZbTeleportID)
			continue;
		ArrayGetString(zombie_model, i, model_name, charsmax(model_name))
		
		//format(message,511,"%s%s#",message,model_name);
		write_string(model_name);
		
	}
	//format(message,511,"%s%s#",message,"random");
	write_string("random");
	message_end();
	
	//MH_ZombieMenu(id,message);
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
	
	new iZombieClass = str_to_num(sCmd);
	if(class_count > 2)
	{
		for(new i=0;i<=iZombieClass;i++)
		{
			if(i==g_iZbRevivalID || i==g_iZbTeleportID)
				iZombieClass++;
		}
	}
	if(iZombieClass == class_count)
	{
		iZombieClass = random_num(0, class_count - 1)
	}
	
	if(iZombieClass < class_count)
	{
		g_zombieclass[id] = iZombieClass;
		Activate_ZombieClass(id)
		ExecuteForward(g_fwUserInfected, g_fwDummyResult, id, 33);
		
		if (task_exists(id + TASK_SHOWINGMENU)) remove_task(id + TASK_SHOWINGMENU);
		g_iCanUseSkill[id] = 1;
	}
	
	return PLUGIN_HANDLED;
}

public NormalZombie(id)
{
	new sCmd[32];
	read_argv(1,sCmd,31);
	
	new iZombieClass = -1;
	
	if(!strcmp(sCmd, "random"))
	{
		iZombieClass = -2;
	}
	else
	{
		new szModel[32]
		for(new i=0;i<class_count;i++)
		{
			ArrayGetString(zombie_model, i, szModel, charsmax(szModel));
			if(!strcmp(szModel, sCmd))
			{
				iZombieClass = i;
				break;
			}
		}
	}

	g_iNormalZombie[id] = iZombieClass;
}

public GetNormalZombie()
{
	new iZombieClass = 0;
	if(iZombieClass == g_iZbRevivalID) iZombieClass++;
	if(iZombieClass == g_iZbTeleportID) iZombieClass++;
	if(iZombieClass >= class_count)
		iZombieClass = 0;
	return iZombieClass;
}