#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>

#include "z4e_team.inc"

#define PLUGIN "[Z4E] Zombie Sound"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

new const SOUND_ZOMBIE_DEATH[][] = { "zombi/zombi_death_1.wav", "zombi/zombi_death_2.wav" }
new const SOUND_ZOMBIE_PAIN[][] = { "zombi/zombi_hurt_01.wav", "zombi/zombi_hurt_02.wav" }
new const SOUND_ZOMBIE_RESPAWN[][] = { "vox/zombi_comeback.wav" }
new const SOUND_ZOMBIE_COMING[][] = { 
	"vox/zombi_coming_1.wav",
	"vox/zombi_coming_2.wav"
}

new Float:g_flLastSound

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_EmitSound, "fw_EmitSound")
}

public plugin_precache()
{
	new i
	
	for(i = 0; i < sizeof(SOUND_ZOMBIE_DEATH); i++) 
		engfunc(EngFunc_PrecacheSound, SOUND_ZOMBIE_DEATH[i]); 
	for(i = 0; i < sizeof(SOUND_ZOMBIE_PAIN); i++) 
		engfunc(EngFunc_PrecacheSound, SOUND_ZOMBIE_PAIN[i]); 
	for(i = 0; i < sizeof(SOUND_ZOMBIE_RESPAWN); i++) 
		engfunc(EngFunc_PrecacheSound, SOUND_ZOMBIE_RESPAWN[i]); 
	for(i = 0; i < sizeof(SOUND_ZOMBIE_COMING); i++) 
		engfunc(EngFunc_PrecacheSound, SOUND_ZOMBIE_COMING[i]); 
}

public z4e_fw_zombie_respawn_post(id)
{
	if(get_gametime() > g_flLastSound + 0.5)
	{
		PlaySound(0, SOUND_ZOMBIE_RESPAWN[random_num(0, sizeof(SOUND_ZOMBIE_RESPAWN) - 1)], 0)
		g_flLastSound = get_gametime()
	}
}

public z4e_fw_zombie_infect_post(id)
{
	if(get_gametime() > g_flLastSound + 0.5)
	{
		PlaySound(0, SOUND_ZOMBIE_COMING[random_num(0, sizeof(SOUND_ZOMBIE_RESPAWN) - 1)], 0)
		g_flLastSound = get_gametime()
	}
}

public z4e_fw_zombie_originate_post(id, iZombieCount)
{
	if(get_gametime() > g_flLastSound + 0.5)
	{
		PlaySound(0, SOUND_ZOMBIE_COMING[random_num(0, sizeof(SOUND_ZOMBIE_RESPAWN) - 1)], 0)
		g_flLastSound = get_gametime()
	}
}

public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
		return FMRES_SUPERCEDE;
	if(is_user_connected(id) && z4e_team_get_user_zombie(id))
	{
		// Zombie being hit
		if ((sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't') || (sample[7] == 'h' && sample[8] == 'e' && sample[9] == 'a' && sample[10] == 'd'))
		{
			emit_sound(id, channel, SOUND_ZOMBIE_PAIN[random_num(0, sizeof(SOUND_ZOMBIE_PAIN) - 1)], volume, attn, flags, pitch)
	
			return FMRES_SUPERCEDE;
		}
		
		// Zombie attacks with knife
		// Xiaobaiba: Since z4e_zombie_knife exists, no need for this.
		/*
		if (sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
		{
			if (sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') // slash
			{
				emit_sound(id, channel, cfg_szSoundSlash[random_num(0, sizeof(cfg_szSoundSlash) - 1)], volume, attn, flags, pitch)
				
				return FMRES_SUPERCEDE;
			}
			if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') // hit
			{
				if (sample[17] == 'w') // wall
				{
					emit_sound(id, channel, cfg_szSoundWall[random_num(0, sizeof(cfg_szSoundWall) - 1)], volume, attn, flags, pitch)
					
					return FMRES_SUPERCEDE;
				} else {
					emit_sound(id, channel, cfg_szSoundHit[random_num(0, sizeof(cfg_szSoundHit) - 1)], volume, attn, flags, pitch)
					
					return FMRES_SUPERCEDE;
				}
			}
			if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') // stab
			{
				emit_sound(id, channel, cfg_szSoundStab[random_num(0, sizeof(cfg_szSoundStab) - 1)], volume, attn, flags, pitch)
				return FMRES_SUPERCEDE;
			}
		}
		*/
				
		// Zombie dies
		if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
		{
			emit_sound(id, channel, SOUND_ZOMBIE_DEATH[random_num(0, sizeof(SOUND_ZOMBIE_DEATH) - 1)], volume, attn, flags, pitch)
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

stock PlaySound(index, const szSound[], stop_sounds_first = 0)
{
	if(equal(szSound, ""))
		return
	if (stop_sounds_first)
	{
		if (equal(szSound[strlen(szSound)-4], ".mp3"))
			client_cmd(index, "stopsound; mp3 play ^"sound/%s^"", szSound)
		else
			client_cmd(index, "mp3 stop; stopsound; spk ^"%s^"", szSound)
	}
	else
	{
		if (equal(szSound[strlen(szSound)-4], ".mp3"))
			client_cmd(index, "mp3 play ^"sound/%s^"", szSound)
		else
			client_cmd(index, "spk ^"%s^"", szSound)
	}
}