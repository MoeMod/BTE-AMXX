#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <orpheu>
#include <orpheu_stocks>
#include <xs>

#include "inc.inc"
#include "offset.inc"
#include "animation.inc"
#include "BTE_Zb4_API.inc"

#define PLUGIN "BTE Zombie Animation"
#define VERSION "1.0"
#define AUTHOR "BTE TEAM"

#define FBitSet(%1, %2) ((%1) & (%2))

native bte_get_user_zombie(id)

new OrpheuFunction:handleSetAnimation, OrpheuFunction:handleResetSequenceInfo;
new g_iPlaying[33], g_szAnimation[32];

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	handleSetAnimation = OrpheuGetFunction( "SetAnimation", "CBasePlayer" )
	handleResetSequenceInfo = OrpheuGetFunction( "ResetSequenceInfo", "CBaseAnimating" );

	OrpheuRegisterHook( handleSetAnimation, "SetAnimation_Pre", OrpheuHookPre );
}

public plugin_natives()
{
	register_native("PlayAnimation", "native_PlayAnimation", 1);
	register_native("PlayAnimation2", "native_PlayAnimation2", 1);
	register_native("ResetSequence", "native_ResetSequence", 1);
}

public native_ResetSequence(id)
{
	g_iPlaying[id] = 0;
	OrpheuCall(handleSetAnimation, id, PLAYER_IDLE);
}

public native_PlayAnimation2(id, szAnim[])
{
	param_convert(2);

	OrpheuCall(handleSetAnimation, id, PLAYER_RELOAD);
	set_pev(id, pev_frame, 0);
	set_pev(id, pev_sequence, LookupSequence(id, szAnim));
	set_pev(id, pev_gaitsequence, LookupSequence(id, szAnim));
	ResetSequenceInfo(id);
}

public native_PlayAnimation(id, szAnim[])
{
	if (bte_zb4_is_stuned(id))
		return;

	param_convert(2);
	copy(g_szAnimation, 32, szAnim);

	g_iPlaying[id] = 1;

	set_pev(id, pev_frame, 0);
	ResetSequenceInfo(id);

	//client_print(0, print_chat, "native: %d Sequence Set : %s", id, szAnim);
}

public OrpheuHookReturn:SetAnimation_Pre ( const id, const playerAnim )
{
	if (bte_get_user_zombie(id) != 1 && !g_iPlaying[id])
		return OrpheuIgnored;

	if (get_user_weapon(id) != CSW_KNIFE)
		return OrpheuIgnored;

	if (playerAnim == PLAYER_DIE/* || playerAnim == PLAYER_FLINCH || playerAnim == PLAYER_LARGE_FLINCH*/)
		return OrpheuIgnored;

	new Activity = get_pdata_int(id, m_Activity);
	new IdealActivity = get_pdata_int(id, m_IdealActivity);

	new animDesired;
	new szAnim[64];

	new flags = pev(id, pev_flags);

	new Float:speed;
	new Float:velocity[3]; pev(id, pev_velocity, velocity); velocity[2] = 0.0;
	speed = xs_vec_len(velocity);

	new gaitanimDerired;
	new hopSeq = LookupActivity(id, ACT_HOP);
	new leapSeq = LookupActivity(id, ACT_LEAP);

	if (playerAnim == PLAYER_FLINCH)
	{
		IdealActivity = ACT_FLINCH;

		//ResetSequenceInfo(id);
	}

	if (playerAnim == PLAYER_LARGE_FLINCH)
	{
		IdealActivity = ACT_LARGE_FLINCH;

		//ResetSequenceInfo(id);
	}

	if (playerAnim == PLAYER_IDLE || playerAnim == PLAYER_WALK)
	{
		if (Activity != ACT_HOP && Activity != ACT_LEAP)
		{
			if (pev(id, pev_waterlevel) > 1)
			{
				if (speed < 10.0)
					IdealActivity = ACT_HOVER;
				else
					IdealActivity = ACT_SWIM;
			}
			else
				IdealActivity = ACT_WALK;
		}
		else if (FBitSet(flags, FL_ONGROUND))
			IdealActivity = ACT_WALK;
	}

	if (playerAnim == PLAYER_JUMP || playerAnim == PLAYER_SUPERJUMP)
	{
		if (Activity == ACT_SWIM || Activity == ACT_DIESIMPLE || Activity == ACT_HOVER)
			IdealActivity = Activity;
		else
			IdealActivity = ACT_HOP;

		gaitanimDerired = hopSeq;

		Activity = IdealActivity;

		//ResetSequenceInfo(id);
	}

	if (playerAnim == PLAYER_ATTACK1)
	{
		if (Activity == ACT_SWIM || Activity == ACT_DIESIMPLE || Activity == ACT_HOVER)
			IdealActivity = Activity;
		else
			IdealActivity = ACT_RANGE_ATTACK1;

		Activity = IdealActivity;

		set_pdata_float(id, m_flLastFired, get_gametime());
		//ResetSequenceInfo(id);
	}

	if (playerAnim == PLAYER_ATTACK2)
	{
		if (Activity == ACT_SWIM || Activity == ACT_DIESIMPLE || Activity == ACT_HOVER)
			IdealActivity = Activity;
		else
			IdealActivity = ACT_RANGE_ATTACK2;

		Activity = IdealActivity;

		set_pdata_float(id, m_flLastFired, get_gametime());
		//ResetSequenceInfo(id);
	}

	set_pdata_int(id, m_IdealActivity, IdealActivity);

	if (IdealActivity == ACT_WALK)
	{
		new fSequenceFinished = get_pdata_int(id, m_fSequenceFinished);
		if ((Activity != ACT_RANGE_ATTACK1 || fSequenceFinished) && (Activity != ACT_RANGE_ATTACK2 || fSequenceFinished) && (Activity != ACT_FLINCH || fSequenceFinished) && (Activity != ACT_LARGE_FLINCH || fSequenceFinished) && (Activity != ACT_RELOAD || fSequenceFinished))
		{
			if (FBitSet(flags, FL_DUCKING))
			{
				copy(szAnim, 64, "crouch_aim_");
				format(szAnim, 64, "%s%s", szAnim, "knife");

				if (speed)
					format(szAnim, 64, "%s%s", szAnim, "_crouchrun");
				else
					format(szAnim, 64, "%s%s", szAnim, "_crouch_idle");
			}
			else
			{
				copy(szAnim, 64, "ref_aim_");
				format(szAnim, 64, "%s%s", szAnim, "knife");

				if (speed >= 200.0)
					format(szAnim, 64, "%s%s", szAnim, "_run");
				else if (speed)
					format(szAnim, 64, "%s%s", szAnim, "_walk");
				else
					format(szAnim, 64, "%s%s", szAnim, "_idle1");
			}

			Activity = ACT_WALK;

			animDesired = LookupSequence(id, szAnim);
		}

	}

	if (IdealActivity == ACT_RANGE_ATTACK1 || IdealActivity == ACT_RANGE_ATTACK2)
	{
		set_pev(id, pev_frame, 0);

		if (FBitSet(flags, FL_DUCKING))
			copy(szAnim, 64, "crouch_");
		else
			copy(szAnim, 64, "ref_");


		if (IdealActivity == ACT_RANGE_ATTACK1)
			format(szAnim, 64, "%s%s", szAnim, "shoot_knife");
		else
			format(szAnim, 64, "%s%s", szAnim, "shoot2_knife");

		animDesired = LookupSequence(id, szAnim);
	}

	if (IdealActivity == ACT_FLINCH || IdealActivity == ACT_LARGE_FLINCH)
	{
		switch (get_pdata_int(id, m_LastHitGroup))
		{
			case HITGROUP_GENERIC:
			{
				if (random_num(0, 1))
					animDesired = LookupSequence(id, "gut_flinch");
				else
					animDesired = LookupSequence(id, "head_flinch");

			}
			case HITGROUP_HEAD: animDesired = LookupSequence(id, "head_flinch");
			case HITGROUP_CHEST: animDesired = LookupSequence(id, "head_flinch");
			default: animDesired = LookupSequence(id, "gut_flinch");
		}

		if (FBitSet(flags, FL_DUCKING))
		{
			if (speed)
				format(szAnim, 64, "%s%s", szAnim, "_crouchrun");
			else
				format(szAnim, 64, "%s%s", szAnim, "_crouch_idle");
		}

		Activity = IdealActivity;
	}

	if (IdealActivity == ACT_HOP) animDesired = LookupSequence(id, "ref_aim_knife_jump");
	if (IdealActivity == ACT_LEAP) animDesired = LookupSequence(id, "ref_aim_knife_jump");

	if (IdealActivity == ACT_SWIM) animDesired = LookupSequence(id, "swim");
	if (IdealActivity == ACT_HOVER) animDesired = LookupSequence(id, "treadwater");

	set_pdata_int(id, m_Activity, Activity);
	set_pdata_int(id, m_IdealActivity, IdealActivity);

	// !!! for ZB4
	if (bte_zb4_is_stuned(id))
		animDesired = LookupSequence(id, "stun");

	if (g_iPlaying[id])
	{
		if (get_pdata_int(id, m_fSequenceFinished))
			g_iPlaying[id] = 0;
		else
			animDesired = LookupSequence(id, g_szAnimation);
	}

	if (bte_zb4_get_dash(id) && bte_get_user_zombie(id) && !bte_zb4_is_stuned(id))
		animDesired = LookupSequence(id, "dash");

	if (animDesired != pev(id, pev_sequence) && animDesired > 0)
	{
		//client_print(0, print_chat, "%d Sequence Set : %s %d m_fSequenceFinished: %d", id, szAnim, animDesired, get_pdata_int(id, m_fSequenceFinished));
		set_pev(id, pev_frame, 0);
		set_pev(id, pev_sequence, animDesired);
		ResetSequenceInfo(id);
	}

	if (gaitanimDerired != hopSeq && gaitanimDerired != leapSeq && FBitSet(flags, FL_ONGROUND))
	{
		if (FBitSet(flags, FL_DUCKING))
		{
			if (speed)
				gaitanimDerired = LookupActivity(id, ACT_CROUCH);
			else
				gaitanimDerired = LookupActivity(id, ACT_CROUCHIDLE);
		}
		else if (speed > 200.0)
			gaitanimDerired = LookupActivity(id, ACT_RUN);
		else if (speed > 0)
			gaitanimDerired = LookupActivity(id, ACT_WALK);
		else
			gaitanimDerired = LookupActivity(id, ACT_IDLE);
	}

	/*if (Activity == ACT_FLINCH || Activity == ACT_LARGE_FLINCH)
	{
		if (FBitSet(flags, FL_DUCKING))
			gaitanimDerired = LookupActivity(id, ACT_CROUCHIDLE);
		else
			gaitanimDerired = LookupActivity(id, ACT_IDLE);
	}*/

	if (gaitanimDerired > 0)
		set_pev(id, pev_gaitsequence, gaitanimDerired);

	return OrpheuSupercede;
}

public HasShield(id)
{
	return get_pdata_int(id, m_bOwnsShield);
}

public ResetSequenceInfo(id)
{
	OrpheuCall(handleResetSequenceInfo, id);
}

public FBitSet(flBitVector, bit)
{
	return (flBitVector) & (bit)
}