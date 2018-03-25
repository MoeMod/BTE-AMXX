//[]	
public HamF_TouchTrain(iPtr,iPtd)
{
	if(0<iPtd<33)
	{
		if(is_user_alive(iPtd))
		{
			g_plr_touchtrain[iPtd] = 1
			if(g_zombie[iPtd]) 
			{
				g_end = 1
				g_end_zb_ontrain = 1
				Pub_Check_WinCondition()
			}
			else
			{
				if(!g_touch_train && !g_end_zb_ontrain)
				{
					g_touch_train = 1
					//HamF_ButtonUse(998,1,1,1)
					new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "trigger_once"))
					set_pev(iEnt, pev_classname, "wtf")
					DispatchKeyValue(iEnt, "target", "mm_boat_use");
					DispatchKeyValue(iEnt, "delay", "0");
					set_pev(iEnt, pev_mins, Float:{-100.0, -100.0, -10.0})
					set_pev(iEnt, pev_maxs, Float:{100.0, 100.0, 10.0})
					new Float:ori[3]
					pev(iPtd,pev_origin,ori)
					set_pev(iEnt,pev_origin,ori)
					DispatchSpawn(iEnt)
					set_task(5.0,"Pub_Task_Hmescape")
				}
			}					
		}
	}
	return HAM_IGNORED
}
public Forward_KeyValue_Post(iEnt,iKvd)
{
	if(!pev_valid(iEnt)) return
	static name[63],kdata[32],kvalue[32]
	pev(iEnt,pev_classname,name,62)
	if(equal(name,"func_button"))
	{
		get_kvd(iKvd,KV_KeyName,kdata,31)
		if(equal(kdata,"target"))
		{
			get_kvd(iKvd,KV_Value,kvalue,31)
			for(new i=0;i<g_button_total;i++)
			{
				if(equal(kvalue,g_button_target[i]))
				{
					set_pev(iEnt,pev_euser4,i+1)
				}
			}
		}
	}	
	else if(equal(name,"func_train"))
	{
		g_ent_train = iEnt
	}
}
public HamF_ButtonUse(iEnt,iUser,iActivator,iType)
{
	new mess[128],iIndex
	iIndex = pev(iEnt,pev_euser4)

	if(iIndex)
	{
		iIndex--
		if(g_button[iIndex] ) return HAM_SUPERCEDE
		g_counter = g_button_time[iIndex]
		format(mess,63,"%L",LANG_PLAYER,g_button_msg[iIndex])
		g_button[iIndex] = 1
		MH_DrawCountDown(0,mess,g_counter)
	}
	return HAM_IGNORED
}
public Pub_Task_Hmescape()
{
	g_end_hm_escape = 1
	Pub_Check_WinCondition()
}		
public HamF_TouchWeapon(iPtr,iPtd)
{
	if (!is_user_connected(iPtd))
		return HAM_IGNORED;
	
	if (g_zombie[iPtd])
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}
public HamF_Item_Deploy_Post(iEnt)
{
	if(!pev_valid(iEnt)) return HAM_IGNORED
	
	new id = get_pdata_cbase(iEnt, 41, 4)
	// Check Model
	if(0 <id< 33 && g_zombie[id])
	{
		set_pev(id,pev_viewmodel2,res_model_zbhand)
		set_pev(id, pev_weaponmodel2, 0);
		//bte_wpn_set_playerwpn_model(id,0,"",0,0)
	}	
	return HAM_IGNORED
}
public HamF_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	// Fix bug player not connect
	if (!is_user_alive(victim))
		return HAM_IGNORED;
		
	if(!g_zombie[victim] && (attacker>32||attacker<1)) return HAM_SUPERCEDE;
	if(g_zombie[victim] && (attacker>32||attacker<1)) return HAM_IGNORED;
		
	// attacker is zombie
	if (g_zombie[attacker] && !g_zombie[victim])
	{
		Stock_InfectMsg(attacker, victim)
		Stock_UpdateScore(victim,0,1)
		Stock_UpdateScore(attacker,1,1)
		
		Pub_Make_Zombie(victim)
		
		Stock_PlaySound(0,res_sound_coming[random_num(0,1)])
		
		// Check WinCond
		if(Stock_Check_End_Game())
		{
			g_end_allinfected = 1
			Pub_Check_WinCondition()
		}
		/*}
		if(!iCheck)
		{
			g_end_allinfected = 1
			Pub_Check_WinCondition()
		}*/
		return HAM_SUPERCEDE;
	}
	if(!g_zombie[attacker] && !g_zombie[victim])
	{
		return HAM_SUPERCEDE
	}

	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1034\\ f0\\ fs16 \n\\ par }
*/
