
#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>

#include "z4e_team.inc"

#define PLUGIN "[Z4E] Zombie: Leap"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

stock m_flVelocityModifier = 108;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	
	
}

public fw_PlayerPreThink(id)
{
	// Not alive
	if (!is_user_alive(id))
		return;
	
	if(!z4e_team_get_user_zombie(id))
		return;
	
	// Don't allow leap if player is frozen (e.g. freezetime)
	if (fm_get_user_maxspeed(id) == 1.0)
		return;
	
	if(get_pdata_float(id, m_flVelocityModifier) != 1.0)
		return;
	
	// Not doing a longjump (don't perform check for bots, they leap automatically)
	if (!is_user_bot(id) && !(pev(id, pev_button) & (IN_JUMP | IN_DUCK) == (IN_JUMP | IN_DUCK)))
		return;
	
	// Not on ground or not enough speed
	if (!(pev(id, pev_flags) & FL_ONGROUND) || fm_get_speed(id) < 140)
		return;
	
	ZombieLeap(id)
}

public ZombieLeap(id)
{
	static Float:velocity[3]
	
	// Make velocity vector
	velocity_by_aim(id, 350, velocity)
	// Set custom height
	velocity[2] = 300.0
	// Apply the new velocity
	set_pev(id, pev_velocity, velocity)
}