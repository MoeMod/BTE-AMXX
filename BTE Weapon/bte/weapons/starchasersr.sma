
new g_cache_ssr_line;

public CStarchaserSR_ItemPostFrame(id,iEnt,iClip,iAmmo,iId,iBteWpn)
{
	new Float:fTimeSound;
	pev(iEnt, pev_fuser1, fTimeSound);
	new c_iCount[MAX_WPN][4];
	
	if (fTimeSound <= get_gametime())
	{
		client_cmd(id, "speak weapons/%s_idle.wav", c_sModel[iBteWpn]);
		set_pev(iEnt, pev_fuser1, get_gametime()+2.502);
	}
	
	if (!Stock_Can_Attack())
		return;
	
	if (get_pdata_float(iEnt, m_flNextPrimaryAttack) > 0.0)
		return;
	
	new iButton = pev(id, pev_button);
	if (iButton & IN_ATTACK)
	{
		if (!iClip)
		{
			PlayEmptySound(id);
			set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.2);
			return;
		}
		
		new Float:vVector[2][3];
		Stock_Get_Aiming(id, vVector[0]);
		Stock_Get_Postion(id, c_vecViewAttachment[iBteWpn][0], c_vecViewAttachment[iBteWpn][1], c_vecViewAttachment[iBteWpn][2], vVector[1]);
		
		new pEntity = CreateEntity3(id, iBteWpn, "sprites/ef_starchasersr_explosion.spr", vVector[0], vVector[0], 0.0, 0.01, MOVETYPE_NONE, ENTCLASS_FIRE);
		set_pev(pEntity, pev_rendermode, kRenderTransAdd);
		set_pev(pEntity, pev_renderamt, 150.0);
		set_pev(pEntity, pev_solid, SOLID_NOT);
		set_pev(pEntity, pev_scale, 1.0);
		set_pev(pEntity, pev_velocity, g_vecZero);
		set_pev(pEntity, pev_modelindex, engfunc(EngFunc_ModelIndex, "sprites/ef_starchasersr_explosion.spr"));
		set_pev(pEntity, pev_nextthink, get_gametime()+0.01);
		
		new Count = c_iCount[iBteWpn][0] ? c_iCount[iBteWpn][0] : 8;
		for (new i=0;i<Count;i++)
		{
			new Float:vVectorCopy[3];
			xs_vec_copy(vVector[0], vVectorCopy);
			vVectorCopy[0] *= random_float(-4.0, 4.0);
			vVectorCopy[1] *= random_float(-4.0, 4.0);
			vVectorCopy[2] *= random_float(-4.0, 4.0);
			
			new pEntity = CreateEntity3(id, iBteWpn, "sprites/ef_starchasersr_star.spr", vVector[0], vVectorCopy, c_flEntitySpeed[iBteWpn], 0.1, MOVETYPE_FLY, ENTCLASS_FIRE);
			set_pev(pEntity, pev_rendermode, kRenderTransAdd);
			set_pev(pEntity, pev_renderamt, 150.0);
			set_pev(pEntity, pev_solid, SOLID_TRIGGER);
			set_pev(pEntity, pev_scale, 0.1);
			set_pev(pEntity, pev_modelindex, engfunc(EngFunc_ModelIndex, "sprites/ef_starchasersr_star.spr"));
			set_pev(pEntity, pev_iuser1, 1);
			set_pev(pEntity, pev_nextthink, get_gametime()+0.01);
		}
		
		if (get_distance_f(vVector[0], vVector[1]) > 125.0)
		{
			new Float:v_angle[3], Float:vecForward[3];

			pev(id, pev_v_angle, v_angle);
			engfunc(EngFunc_MakeVectors, v_angle);
			global_get(glb_v_forward, v_angle);
			xs_vec_mul_scalar(v_angle, 25.0, vecForward);
			
			new iCount = floatround(get_distance_f(vVector[0], vVector[1]) / 25.0);
			new iCount2 = iCount;
			while (iCount)
			{
				new Float:fPrecent = float(iCount) / float(iCount2);
				xs_vec_add(vVector[1], vecForward, vVector[1]);
				
				message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
				write_byte(TE_EXPLOSION)
				engfunc(EngFunc_WriteCoord, vVector[1][0])
				engfunc(EngFunc_WriteCoord, vVector[1][1])
				engfunc(EngFunc_WriteCoord, vVector[1][2])
				write_short(g_cache_ssr_line)
				write_byte(1)
				write_byte(15 + floatround(15.0 * fPrecent))
				write_byte(TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOSOUND |TE_EXPLFLAG_NOPARTICLES)
				message_end()
				iCount--;
			}
		}
		
		ExecuteHamB(Ham_Weapon_PrimaryAttack, iEnt);
		set_pdata_float(iEnt, m_flNextPrimaryAttack, c_flAttackInterval[iBteWpn][0]);
		set_pdata_float(iEnt, m_flTimeWeaponIdle, c_flAttackInterval[iBteWpn][0] + 1.0);
		
		client_cmd(id, "speak items/equip_nvg.wav");
		set_pev(iEnt, pev_fuser1, get_gametime()+c_flAttackInterval[iBteWpn][0] + 1.0);
	}
}

public CStarchaserSR_Precache()
{
	precache_model("sprites/ef_starchasersr.spr");
	precache_model("sprites/ef_starchasersr_explosion.spr");
	precache_model("sprites/ef_starchasersr_star.spr");
	g_cache_ssr_line = precache_model("sprites/ef_starchasersr_line.spr");
}