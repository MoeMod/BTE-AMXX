#include <amxmodx>
#include <fakemeta_util>
#include <hamsandwich>
#include <orpheu>

#include "z4e_team.inc"

#define PLUGIN "[Z4E] Zombie Knife"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

#define CSW_WEAPON CSW_KNIFE
#define weapon_classname "weapon_knife"

#define WEAPON_SLASH_DAMAGE1 68.0
#define WEAPON_SLASH_DAMAGE2 68.0
#define WEAPON_STAB_DAMAGE 200.0
#define WEAPON_SLASH_RADIUS 25.0
#define WEAPON_STAB_RADIUS 45.0
#define WEAPON_MAXSPEED 250.0

#define WEAPON_ANIMEXT "knife"

#define BitsGet(%1,%2) (%1 & (1 << (%2 & 31)))
#define BitsSet(%1,%2) %1 |= (1 << (%2 & 31))
#define BitsUnSet(%1,%2) %1 &= ~(1 << (%2 & 31))

new const WEAPON_MODELS[][] = 
{
    "models/v_knife_tank_zombi.mdl",
    ""
}

new const SOUND_SLASH[][] = { "zombi/zombi_swing_1.wav" , "zombi/zombi_swing_2.wav" }
new const SOUND_HITWALL[][] = { "zombi/zombi_wall_1.wav" , "zombi/zombi_wall_2.wav"  , "zombi/zombi_wall_3.wav"  }
new const SOUND_HITPLAYER[][] = { "zombi/zombi_attack_1.wav" , "zombi/zombi_attack_2.wav" }
new const SOUND_STAB[][] = { "zombi/zombi_attack_3.wav" }


enum
{
    ANIM_IDLE = 0,
    ANIM_NONE1,
    ANIM_NONE2,
    ANIM_DRAW,
    ANIM_STAB,
    ANIM_STAB_MISS,
    ANIM_SLASH1,
    ANIM_SLASH2
}


// 来自 player.h
enum
{
    PLAYER_IDLE,
    PLAYER_WALK,
    PLAYER_JUMP,
    PLAYER_SUPERJUMP,
    PLAYER_DIE,
    PLAYER_ATTACK1,
    PLAYER_ATTACK2,
    PLAYER_FLINCH,
    PLAYER_LARGE_FLINCH,
    PLAYER_RELOAD,
    PLAYER_HOLDBOMB
}

// FROM util.h
#define VEC_DUCK_HULL_MIN Float:{-16.0, -16.0, -18.0}
#define VEC_DUCK_HULL_MAX Float:{16.0, 16.0, 32.0}
#define VEC_DUCK_VIEW Float:{0.0, 0.0, 12.0}

// FROM weapons.h
enum
{
    BULLET_NONE = 0,
    BULLET_PLAYER_9MM,
    BULLET_PLAYER_MP5,
    BULLET_PLAYER_357,
    BULLET_PLAYER_BUCKSHOT,
    BULLET_PLAYER_CROWBAR,

    BULLET_MONSTER_9MM,
    BULLET_MONSTER_MP5,
    BULLET_MONSTER_12MM,

    BULLET_PLAYER_45ACP,
    BULLET_PLAYER_338MAG,
    BULLET_PLAYER_762MM,
    BULLET_PLAYER_556MM,
    BULLET_PLAYER_50AE,
    BULLET_PLAYER_57MM,
    BULLET_PLAYER_357SIG
}

// FROM cbase.h
#define CLASS_NONE 0
#define CLASS_MACHINE 1
#define CLASS_PLAYER 2
#define CLASS_HUMAN_PASSIVE 3
#define CLASS_HUMAN_MILITARY 4
#define CLASS_ALIEN_MILITARY 5
#define CLASS_ALIEN_PASSIVE 6
#define CLASS_ALIEN_MONSTER 7
#define CLASS_ALIEN_PREY 8
#define CLASS_ALIEN_PREDATOR 9
#define CLASS_INSECT 10
#define CLASS_PLAYER_ALLY 11
#define CLASS_PLAYER_BIOWEAPON 12
#define CLASS_ALIEN_BIOWEAPON 13
#define CLASS_VEHICLE 14
#define CLASS_BARNACLE 99

// FROM wpn_knife.cpp
#define KNIFE_BODYHIT_VOLUME 128
#define KNIFE_WALLHIT_VOLUME 512

// offset
#define PDATA_SAFE 2
#define OFFSET_LINUX_WEAPONS 4
#define OFFSET_LINUX 5

// CBaseEntity
stock m_iSwing = 32 // int
// CBaseMonster
stock m_flNextAttack = 83 // float
// CBasePlayer
stock m_iLastZoom = 109 // int
stock m_bResumeZoom = 440 // bool
stock m_iWeaponVolume = 239 // int
stock m_iWeaponFlash = 241 // int
stock m_iFOV = 363 // int
stock m_szAnimExtention = 492 // char [32]
stock m_bShieldDrawn = 2002 // bool
// CBasePlayerItem
stock m_pPlayer = 41 // CBasePlayer *
stock m_pNext = 42 // CBasePlayerItem *
stock m_iId = 43 // int
// CBasePlayerWeapon
stock m_flNextPrimaryAttack = 46 // float
stock m_flNextSecondaryAttack = 47 // float
stock m_flTimeWeaponIdle = 48 // float
stock m_iClip = 51 // int
stock m_fInReload = 54 // int
stock m_fMaxSpeed = 58 // float
stock m_bDelayFire = 236 // bool
stock m_flAccuracy = 62 // float
stock m_iShotsFired = 64 // int
stock m_flDecreaseShotsFired = 76 // float
// CKnife
stock m_trHit = 33 // TraceResult (available?)

public plugin_init() 
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)    
    
    RegisterHam(Ham_Item_Deploy, weapon_classname, "HamF_Item_Deploy")
	RegisterHam(Ham_Item_Deploy, weapon_classname, "HamF_Item_Deploy_Post", 1)
    RegisterHam(Ham_Weapon_PrimaryAttack, weapon_classname, "HamF_Weapon_PrimaryAttack")
    RegisterHam(Ham_Weapon_SecondaryAttack, weapon_classname, "HamF_Weapon_SecondaryAttack")
    RegisterHam(Ham_CS_Item_GetMaxSpeed, weapon_classname, "HamF_CS_Item_GetMaxSpeed")
    RegisterHam(Ham_Think, weapon_classname, "HamF_Knife_Think")
    
}

public plugin_precache()
{
    
    new i 
    engfunc(EngFunc_PrecacheModel, WEAPON_MODELS[0])
    for(i = 0; i < sizeof(SOUND_SLASH); i++) 
        engfunc(EngFunc_PrecacheSound, SOUND_SLASH[i]); 
    for(i = 0; i < sizeof(SOUND_HITWALL); i++) 
        engfunc(EngFunc_PrecacheSound, SOUND_HITWALL[i]); 
    for(i = 0; i < sizeof(SOUND_HITPLAYER); i++) 
        engfunc(EngFunc_PrecacheSound, SOUND_HITPLAYER[i]); 
    for(i = 0; i < sizeof(SOUND_STAB); i++) 
        engfunc(EngFunc_PrecacheSound, SOUND_STAB[i]); 
    
}

public Hook_Weapon(id)
{
    client_cmd(id, weapon_classname)
    return PLUGIN_HANDLED
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
    if(!is_user_alive(id) || !is_user_connected(id))
        return FMRES_IGNORED    
    if(get_user_weapon(id) == CSW_WEAPON && z4e_team_get_user_zombie(id))
        set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
    
    return FMRES_HANDLED
}

public HamF_Item_Deploy(this)
{
    if(!pev_valid(this))
        return HAM_IGNORED;
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    if(!z4e_team_get_user_zombie(id))
        return HAM_IGNORED
    // 初始值
    set_pdata_int(this, m_iSwing, 0, OFFSET_LINUX_WEAPONS)
    set_pdata_bool(id, m_bShieldDrawn, false)
    set_pdata_float(this, m_fMaxSpeed, 250.0, OFFSET_LINUX_WEAPONS)
    // VP模型 掏出时间（0.75） 掏出动作 第三人称动作
    OrpheuCall(OrpheuGetFunction("DefaultDeploy", "CBasePlayerWeapon"), this, WEAPON_MODELS[0], WEAPON_MODELS[1], ANIM_DRAW, WEAPON_ANIMEXT, 0)
    return HAM_SUPERCEDE;
}

public HamF_Item_Deploy_Post(this)
{
    if(!pev_valid(this))
        return HAM_IGNORED;
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    if(!z4e_team_get_user_zombie(id))
        return HAM_IGNORED
    
    set_pev(id, pev_viewmodel2, WEAPON_MODELS[0]);
	set_pev(id, pev_weaponmodel2, WEAPON_MODELS[1]);
    return HAM_SUPERCEDE;
}

public HamF_Weapon_PrimaryAttack(this)
{
    if(!pev_valid(this))
        return HAM_IGNORED
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    if(!z4e_team_get_user_zombie(id))
        return HAM_IGNORED
        
    Swing(this, true)
    
    return HAM_SUPERCEDE
}

public HamF_Weapon_SecondaryAttack(this)
{
    if(!pev_valid(this))
        return HAM_IGNORED
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    if(!z4e_team_get_user_zombie(id))
        return HAM_IGNORED
    
    Stab(this, true)
    set_pev(this, pev_nextthink, 0.35)
    return HAM_SUPERCEDE
}

stock GetGunPosition(id, Float:vecOut[3])
{
    new Float:vecOrigin[3]; pev(id, pev_origin, vecOrigin)
    new Float:vecViewOfs[3]; pev(id, pev_view_ofs, vecViewOfs)
    xs_vec_add(vecOrigin, vecViewOfs, vecOut)
}

public HamF_CS_Item_GetMaxSpeed(this)
{
    if(!pev_valid(this))
        return HAM_IGNORED
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    if(!z4e_team_get_user_zombie(id))
        return HAM_IGNORED
    SetHamReturnFloat(WEAPON_MAXSPEED)
    return HAM_HANDLED
}

public HamF_Knife_Think(this)
{
    if(!pev_valid(this))
        return HAM_IGNORED
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    if(!z4e_team_get_user_zombie(id))
        return HAM_IGNORED
    
    Smack(this)
    return HAM_SUPERCEDE
}

public Smack(this)
{
    //DecalGunshot(&m_trHit, BULLET_PLAYER_CROWBAR, false, m_pPlayer->pev, false);
    //其实这里什么也不需要写的说
}

public Swing(this, fFirst)
{
    new fDidHit = false;
    new ptr = create_tr2()
    new Float:vecSrc[3], Float: vecEnd[3]
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    GetGunPosition(id, vecSrc)
    
    static Float:vecForward[3]
    global_get(glb_v_forward, vecForward)
    xs_vec_mul_scalar(vecForward, WEAPON_SLASH_RADIUS, vecForward)
    xs_vec_add(vecSrc, vecForward, vecEnd)

    engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, id, ptr)

    new Float:flFraction
    get_tr2(ptr, TR_flFraction, flFraction)
    
    if (flFraction >= 1.0)
    {
        engfunc(EngFunc_TraceHull, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, HULL_HEAD, id, ptr)
        
        if (flFraction < 1.0)
        {
            new pHit = get_tr2(ptr, TR_pHit)
            if(!pHit || ExecuteHamB(Ham_IsBSPModel, pHit))
            {
                FindHullIntersection(vecSrc, ptr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, id)
                get_tr2(ptr, TR_vecEndPos, vecEnd)
            }
        }
    }
    
    get_tr2(ptr, TR_flFraction, flFraction)
    if (flFraction >= 1.0)
    {
        if(fFirst)
        {
            new iSwing = get_pdata_int(this, m_iSwing, OFFSET_LINUX_WEAPONS)
            switch((iSwing++) & 1) // % 2
            {
                case 0: UTIL_SendWeaponAnim(id, ANIM_SLASH1)
                case 1: UTIL_SendWeaponAnim(id, ANIM_SLASH2)
            }
            set_pdata_int(this, m_iSwing, iSwing, OFFSET_LINUX_WEAPONS)
            set_pdata_float(this, m_flNextPrimaryAttack, 0.35, OFFSET_LINUX_WEAPONS)
            set_pdata_float(this, m_flNextSecondaryAttack, 0.5, OFFSET_LINUX_WEAPONS)
            
            set_pdata_float(this, m_flTimeWeaponIdle, 2.0, OFFSET_LINUX_WEAPONS)
            // "weapons/knife_slash1.wav"
            engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, SOUND_SLASH[random_num(0, sizeof(SOUND_SLASH) - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
            OrpheuCall(OrpheuGetFunction("SetAnimation", "CBasePlayer"), id, PLAYER_ATTACK1)
        }
    }
    else
    {
        fDidHit = true;
        new iSwing = get_pdata_int(this, m_iSwing, OFFSET_LINUX_WEAPONS)
        switch((iSwing++) & 1) // % 2
        {
            case 0: UTIL_SendWeaponAnim(id, ANIM_SLASH1)
            case 1: UTIL_SendWeaponAnim(id, ANIM_SLASH2)
        }
        set_pdata_int(this, m_iSwing, iSwing, OFFSET_LINUX_WEAPONS)
        set_pdata_float(this, m_flNextPrimaryAttack, 0.4, OFFSET_LINUX_WEAPONS)
        set_pdata_float(this, m_flNextSecondaryAttack, 0.5, OFFSET_LINUX_WEAPONS)
        
        set_pdata_float(this, m_flTimeWeaponIdle, 2.0, OFFSET_LINUX_WEAPONS)
        
        new pEntity = get_tr2(ptr, TR_pHit)
        if(pEntity < 0) pEntity = 0
        //SetPlayerShieldAnim();
        OrpheuCall(OrpheuGetFunction("SetAnimation", "CBasePlayer"), id, PLAYER_ATTACK1)
        OrpheuCall(OrpheuGetFunction("ClearMultiDamage"))
        
        if(get_pdata_float(this, m_flNextPrimaryAttack, OFFSET_LINUX_WEAPONS) + (0.4) < 0)
            ExecuteHamB(Ham_TraceAttack, pEntity, id, WEAPON_SLASH_DAMAGE1, vecForward, ptr, DMG_NEVERGIB | DMG_BULLET)
        else
            ExecuteHamB(Ham_TraceAttack, pEntity, id, WEAPON_SLASH_DAMAGE2, vecForward, ptr, DMG_NEVERGIB | DMG_BULLET)
            
        OrpheuCall(OrpheuGetFunction("ApplyMultiDamage"), id, id)
        
        new Float:flVol = 1.0;
        new fHitWorld = true;
        
        if(pev_valid(pEntity))
        {
            if(ExecuteHamB(Ham_Classify, pEntity) != CLASS_NONE && ExecuteHamB(Ham_Classify, pEntity) != CLASS_MACHINE)
            {
                /*
                switch (random_num(0, 3))
                {
                    case 0: engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, "weapons/knife_hit1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
                    case 1: engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, "weapons/knife_hit2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
                    case 2: engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, "weapons/knife_hit3.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
                    case 3: engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, "weapons/knife_hit4.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
                }
                */
                // "weapons/knife_hit1.wav"
                engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, SOUND_HITPLAYER[random_num(0, sizeof(SOUND_HITPLAYER) - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
                set_pdata_int(id, m_iWeaponVolume, KNIFE_BODYHIT_VOLUME);
                
                if(!is_user_alive(pEntity))
                {
                    free_tr2(ptr)
                    return true;
                }
                flVol = 0.1;
                fHitWorld = false;
            }
        }
        
        if(fHitWorld)
        {
            new Float:vecTemp[3]
            xs_vec_sub(vecEnd, vecSrc, vecTemp)
            xs_vec_mul_scalar(vecTemp, 2.0, vecTemp)
            xs_vec_add(vecTemp, vecSrc, vecTemp)
            
            TEXTURETYPE_PlaySound(ptr, vecSrc, vecTemp, BULLET_PLAYER_CROWBAR);
            // "weapons/knife_hitwall1.wav"
            engfunc(EngFunc_EmitSound, id, CHAN_ITEM, SOUND_HITWALL[random_num(0, sizeof(SOUND_HITWALL) - 1)], VOL_NORM, ATTN_NORM, 0, 98 + random_num(0, 3))
            
        }
        
        // m_trHit = tr;
        set_pdata_int(id, m_iWeaponVolume, floatround(flVol * KNIFE_WALLHIT_VOLUME));
        // SetThink(&CKnife::Smack);
        set_pev(this, pev_nextthink, 0.2)
        // SetPlayerShieldAnim();
    }
    free_tr2(ptr)
    return fDidHit;
}

public Stab(this, fFirst)
{
    new fDidHit = false;
    new ptr = create_tr2()
    new Float:vecSrc[3], Float: vecEnd[3]
    new id = get_pdata_cbase(this, m_pPlayer, OFFSET_LINUX_WEAPONS)
    GetGunPosition(id, vecSrc)
    
    static Float:vecForward[3]
    global_get(glb_v_forward, vecForward)
    xs_vec_mul_scalar(vecForward, WEAPON_STAB_RADIUS, vecForward)
    xs_vec_add(vecSrc, vecForward, vecEnd)

    engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, id, ptr)

    new Float:flFraction
    get_tr2(ptr, TR_flFraction, flFraction)
    
    if (flFraction >= 1.0)
    {
        engfunc(EngFunc_TraceHull, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, HULL_HEAD, id, ptr)
        
        if (flFraction < 1.0)
        {
            new pHit = get_tr2(ptr, TR_pHit)
            if(!pHit || ExecuteHamB(Ham_IsBSPModel, pHit))
            {
                FindHullIntersection(vecSrc, ptr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, id)
                get_tr2(ptr, TR_vecEndPos, vecEnd)
            }
        }
    }
    
    get_tr2(ptr, TR_flFraction, flFraction)
    if (flFraction >= 1.0)
    {
        if(fFirst)
        {
            UTIL_SendWeaponAnim(id, ANIM_STAB_MISS)
            set_pdata_float(this, m_flNextPrimaryAttack, 1.1, OFFSET_LINUX_WEAPONS)
            set_pdata_float(this, m_flNextSecondaryAttack, 1.1, OFFSET_LINUX_WEAPONS)
            set_pdata_float(this, m_flTimeWeaponIdle, 1.3, OFFSET_LINUX_WEAPONS)
            
            // "weapons/knife_slash1.wav"
            engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, SOUND_SLASH[random_num(0, sizeof(SOUND_SLASH) - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
            OrpheuCall(OrpheuGetFunction("SetAnimation", "CBasePlayer"), id, PLAYER_ATTACK1)
        }
    }
    else
    {
        fDidHit = true;
        UTIL_SendWeaponAnim(id, ANIM_STAB)
        set_pdata_float(this, m_flNextPrimaryAttack, 1.1, OFFSET_LINUX_WEAPONS)
        set_pdata_float(this, m_flNextSecondaryAttack, 1.1, OFFSET_LINUX_WEAPONS)
        set_pdata_float(this, m_flTimeWeaponIdle, 2.3, OFFSET_LINUX_WEAPONS)
        
        new pEntity = get_tr2(ptr, TR_pHit)
        if(pEntity < 0) pEntity = 0
        //SetPlayerShieldAnim();
        OrpheuCall(OrpheuGetFunction("SetAnimation", "CBasePlayer"), id, PLAYER_ATTACK1)
        
        new Float:fDamage = WEAPON_STAB_DAMAGE
        if(pEntity && is_user_connected(pEntity))
        {
            // 背后伤害3倍？
            if(IsUserInTargetBack(id, pEntity))
                fDamage *= 3.0
        }
        
        new Float:vecVAngle[3], Float:vecPunchangle[3], Float:vecTemp[3];
        pev(id, pev_v_angle, vecVAngle)
        pev(id, pev_punchangle, vecPunchangle)
        xs_vec_add(vecVAngle, vecPunchangle, vecTemp);
        engfunc(EngFunc_MakeVectors, vecTemp);
        
        OrpheuCall(OrpheuGetFunction("ClearMultiDamage"))
        
        ExecuteHamB(Ham_TraceAttack, pEntity, id, fDamage, vecForward, ptr, DMG_NEVERGIB | DMG_BULLET)
        OrpheuCall(OrpheuGetFunction("ApplyMultiDamage"), id, id)
        
        new Float:flVol = 1.0;
        new fHitWorld = true;
        
        if(pev_valid(pEntity))
        {
            if(ExecuteHamB(Ham_Classify, pEntity) != CLASS_NONE && ExecuteHamB(Ham_Classify, pEntity) != CLASS_MACHINE)
            {
                // "weapons/knife_stab.wav"
                engfunc(EngFunc_EmitSound, id, CHAN_WEAPON, SOUND_STAB[random_num(0, sizeof(SOUND_STAB) - 1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
                set_pdata_int(id, m_iWeaponVolume, KNIFE_BODYHIT_VOLUME);
                
                if(!is_user_alive(pEntity))
                {
                    free_tr2(ptr)
                    return true;
                }
                flVol = 0.1;
                fHitWorld = false;
            }
        }
        
        if(fHitWorld)
        {
            new Float:vecTemp[3]
            xs_vec_sub(vecEnd, vecSrc, vecTemp)
            xs_vec_mul_scalar(vecTemp, 2.0, vecTemp)
            xs_vec_add(vecTemp, vecSrc, vecTemp)
            
            TEXTURETYPE_PlaySound(ptr, vecSrc, vecTemp, BULLET_PLAYER_CROWBAR);
            // "weapons/knife_hitwall1.wav"
            engfunc(EngFunc_EmitSound, id, CHAN_ITEM, SOUND_HITWALL[random_num(0, sizeof(SOUND_HITWALL) - 1)], VOL_NORM, ATTN_NORM, 0, 98 + random_num(0, 3))
            
        }
        
        // m_trHit = tr;
        set_pdata_int(id, m_iWeaponVolume, floatround(flVol * KNIFE_WALLHIT_VOLUME));
        
        // SetThink(&CKnife::Smack);
        set_pev(this, pev_nextthink, 0.2)
        // SetPlayerShieldAnim();
    }
    free_tr2(ptr)
    return fDidHit;
}

stock TEXTURETYPE_PlaySound(ptr, Float:vecSrc[3], Float:vecEnd[3], iBulletType)
{
    return OrpheuCall(OrpheuGetFunction("TEXTURETYPE_PlaySound"), ptr, vecSrc[0], vecSrc[1], vecSrc[2], vecEnd[0], vecEnd[1], vecEnd[2], iBulletType)
}

stock FindHullIntersection(Float:vecSrc[3], &ptr, Float:flMins[3], Float:fkMaxs[3], pEntity)
{
    new ptrTemp = create_tr2();
    new Float:flDistance = 1000000.0;

    new Float:flMinMaxs[2][3]
    for(new i;i<3;i++)
    {
        flMinMaxs[0][i] = flMins[i];
        flMinMaxs[1][i] = fkMaxs[i];
    }
    new Float:vecHullEnd[3]
    get_tr2(ptr, TR_vecEndPos, vecHullEnd)
    
    new Float:vecTemp[3]
    xs_vec_sub(vecHullEnd, vecSrc, vecTemp);
    xs_vec_mul_scalar(vecTemp, 2.0, vecTemp);
    xs_vec_add(vecSrc, vecTemp, vecHullEnd)
    
    engfunc(EngFunc_TraceLine, vecSrc, vecHullEnd, DONT_IGNORE_MONSTERS, pEntity, ptrTemp);
    
    new Float:flFraction
    get_tr2(ptrTemp, TR_flFraction, flFraction)
    
    if (flFraction < 1.0)
    {
        free_tr2(ptr)
        ptr = ptrTemp
        return ptr;
    }
    
    for(new i; i < 2; i++)
    {
        for(new j; j < 2; j++)
        {
            for(new k; k < 2; k++)
            {
                new Float:vecEnd[3];
                for(new l;l < 3;l++)
                {
                    vecEnd[l] = vecHullEnd[l] + flMinMaxs[i][l];
                    vecEnd[l] = vecHullEnd[l] + flMinMaxs[j][l];
                    vecEnd[l] = vecHullEnd[l] + flMinMaxs[k][l];
                }
                
                engfunc(EngFunc_TraceLine, vecSrc, vecEnd, DONT_IGNORE_MONSTERS, pEntity, ptrTemp)
                
                get_tr2(ptrTemp, TR_flFraction, flFraction)
                if (flFraction < 1.0)
                {
                    new Float:vecEndPos[3]
                    get_tr2(ptrTemp, TR_vecEndPos, vecEndPos)
                    xs_vec_sub(vecEndPos, vecSrc, vecTemp);
                    new Float:flThisDistance = xs_vec_len(vecTemp)
                    if (flThisDistance < flDistance)
                    {
                        free_tr2(ptr)
                        ptr = ptrTemp
                        flDistance = flThisDistance;
                        return ptr;
                    }
                }
            }
        }
    }
    return ptr;
}

stock UTIL_SendWeaponAnim(pPlayer, iAnim, iBody = -1)
{
    set_pev(pPlayer, pev_weaponanim, iAnim);
    if(iBody < 0)
        iBody = pev(pPlayer, pev_body)
    message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, pPlayer);
    write_byte(iAnim);
    write_byte(iBody);
    message_end();
}
/*
stock set_pdata_bool(ent, charbased_offset, bool:value, intbase_linuxdiff = 5) 
{ 
    set_pdata_char(ent, charbased_offset, _:value, intbase_linuxdiff) 
}

stock set_pdata_char(ent, charbased_offset, value, intbase_linuxdiff = 5) 
{ 
    value &= 0xFF 
    new int_offset_value = get_pdata_int(ent, charbased_offset >> 2, intbase_linuxdiff) 
    new bit_decal = (charbased_offset & 3) << 3
    int_offset_value &= ~(0xFF<<bit_decal) // clear byte 
    int_offset_value |= value<<bit_decal 
    set_pdata_int(ent, charbased_offset >> 2, int_offset_value, intbase_linuxdiff) 
    return 1 
}
*/
// 引用Nagist
// 是否在目标的后面 (来自 zp_extra_super_knife...) 
// 原形: is_user_in_target_back(id, target, angles_range = 120, distance_range = 200)
stock IsUserInTargetBack(iPlayer, iTarget, iAngleRange = 120, iDistanceRange = 200)
{
    new Float:vecOrigin[2][3]
    pev(iPlayer, pev_origin, vecOrigin[0])
    pev(iTarget, pev_origin, vecOrigin[1])
    
    new Float:vecAngles[2][3]
    pev(iTarget, pev_angles, vecAngles[0])
    
    new Float:vecVector[3]
    vecVector[0] = vecOrigin[0][0] - vecOrigin[1][0]
    vecVector[1] = vecOrigin[0][1] - vecOrigin[1][1]
    vecVector[2] = vecOrigin[0][2] - vecOrigin[1][2]
    vector_to_angle(vecVector, vecAngles[1])
    
    new Float:fAngle
    fAngle = (vecAngles[1][1] >= vecAngles[0][1]) ? vecAngles[1][1] - vecAngles[0][1] : vecAngles[0][1] - vecAngles[1][1]
    
    while (iAngleRange > 360)
        iAngleRange -= 360
    
    new Float:fTemp[2]
    fTemp[0] = 180.0 - (float(iAngleRange) / 2.0)
    fTemp[1] = 360.0 - fTemp[0] 
    
    if ((fAngle <= fTemp[0]) || (fAngle >= fTemp[1]))
        return 0
    
    new fDistance = floatround(get_distance_f(vecOrigin[0], vecOrigin[1]))
    if (fDistance > iDistanceRange)
        return 0
    
    return 1
}       