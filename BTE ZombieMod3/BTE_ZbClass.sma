#define CONFIG_FILE "bte_zombieclass.ini"
#define LANG_FILE "bte_zombie.bte"

#define PRINT(%1) client_print(1,print_chat,%1)

//#include <orpheu>

//new handleResetSequenceInfo, handleSetAnimation

new zombie_sound_heal[64], zombie_name[64], zombie_model[64], zombie_sex, zombie_modelindex, Float:zombie_gravity, Float:zombie_speed, Float:zombie_knockback, Float:zombie_xdamage[3],
zombie_sound_death1[64], zombie_sound_death2[64], zombie_sound_hurt1[64], zombie_sound_hurt2[64], zombie_sound_evolution[64]
new idclass

native bte_wpn_set_anim_offset(id,a,Float:b,c);

#define TASK_SKILL2 10086


PlayEmitSound(id, const sound[])
{
	emit_sound(id, CHAN_VOICE, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}
SetRendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) 
{
	new Float:RenderColor[3];
	RenderColor[0] = float(r);
	RenderColor[1] = float(g);
	RenderColor[2] = float(b);

	set_pev(entity, pev_renderfx, fx);
	set_pev(entity, pev_rendercolor, RenderColor);
	set_pev(entity, pev_rendermode, render);
	set_pev(entity, pev_renderamt, float(amount));

	return 1;
}
SetUserHealth(id, Float:health)
{	
	set_pev(id,pev_health,health)
}
SendAnim(id,iAnim)
{
	if(!is_user_alive(id)) return;
	
	set_pev(id, pev_weaponanim, iAnim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
	write_byte(iAnim)
	write_byte(pev(id, pev_body))
	message_end()
}
/*SendPlayAnim(id,playerAnim,framerate = 1.0)
{
	set_pdata_int(id,73,28)
	set_pev(id,pev_sequence,101)
	set_pev(id,pev_frame,0)
	set_pev(id,pev_animtime,get_gametime())
	set_pev(id,pev_framerate,framerate)

}*/
/*InitiateSequence ( const player, const sequence )
{
	if(!is_user_alive(player)) return
	static iDuck
	if(pev(player,pev_flags) & FL_DUCKING)
	{
		iDuck = 1
	}
	else iDuck = 0
	if(bte_get_user_zombie(player)) set_pev(player,pev_gaitsequence,iDuck?2:1)
	set_pev( player, pev_sequence, sequence );
	set_pev( player, pev_frame, 0 );
	set_pev( player, pev_framerate, 1.0); 

	OrpheuCall( handleResetSequenceInfo, player );
}*/

stock Float:CheckAngle(id,iTarget)
{
	new Float:vOricross[2],Float:fRad,Float:vId_ori[3],Float:vTar_ori[3],Float:vId_ang[3],Float:fLength,Float:vForward[3]
	
	pev(id,pev_origin,vId_ori)
	pev(iTarget,pev_origin,vTar_ori)
	
	pev(id,pev_angles,vId_ang)
	for(new i=0;i<2;i++)
	{
		vOricross[i] = vTar_ori[i] - vId_ori[i]
	}
	
	fLength = floatsqroot(vOricross[0]*vOricross[0] + vOricross[1]*vOricross[1])
	
	if(fLength<=0.0)
	{
		vOricross[0]=0.0
		vOricross[1]=0.0
	}
	else
	{
		vOricross[0]=vOricross[0]*(1.0/fLength)
		vOricross[1]=vOricross[1]*(1.0/fLength)
	}
	
	engfunc(EngFunc_MakeVectors,vId_ang)
	global_get(glb_v_forward,vForward)
	
	fRad = vOricross[0]*vForward[0]+vOricross[1]*vForward[1]
	
	return fRad   //->   RAD 90' = 0.5rad
}
