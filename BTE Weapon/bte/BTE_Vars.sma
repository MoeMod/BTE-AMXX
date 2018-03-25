// [BTE GLOBAL VARS]
// #################### Weapon Configs Value ######################
// === !Global ===
new g_szConfigDir[256]
new g_szMapName[64]
new g_szLogName[256],g_hLog=0,g_fwDummyResult
new g_szConfigFile[256]
new Float:g_fPlrMaxspeed[33]
new Float:g_fBuyTime;
// === Config Value ===
new Float:g_c_fWeaponLastTime,g_c_iStripDroppedHe
new g_c_iWeaponLimitBit=0
new g_c_bWeaponLimitCustom
new g_c_bUnlimitedBpAmmo=0
// === FIX ===
new g_isZomMod3

new g_bCanReload[33];

// === MyWpn ===
new g_bEnableMyWpn = TRUE;
new g_szMyWpn[MAX_WPN][64];

// === Base ===
new m_usFire[MAX_WPN][2];
new m_usExplosion, m_usTempEntity, m_usStormGiantEffect, m_usRunebladeEffect, m_usGaussFire, m_usGaussSpin;
// ===Special Weapon===

// #################### Player Global Value ######################
// === Base ===
new g_weapon[33][WPN_SLOT+1]
new g_user_clip[33][WPN_SLOT+1],g_user_ammo[33][WPN_SLOT+1]
new g_double[33][2]
//new g_buyzone[33]
new g_attacking[33]
new g_dchanging[33]
new Float:g_knockback[33], Float:g_vm[33];

enum msgMoney_e
{
	m_account,
	m_bTrackChange,
	Float: m_flTimeSend
}

new any:msgMoney[32][msgMoney_e];
// === Special ===
new g_hammer_changing[33],g_hammer_stat[33]
// === Other ===
new g_p_modelent[33]		//store player fake p_ model
new Float:g_flNextSetAnim[33],g_iAnimOffset[33],Float:g_fKeepFrame[33],Float:g_fFrameRate[33],g_iSequence[33];

// ##################### Other Global Vars ###############

new g_wpn_menu[8][128]
new g_wpn_menu_count[8]

// === Message & Cvars ===
new g_msgScreenShake,g_msgCurWeapon,g_msgHideWeapon,g_msgAmmoPickup,g_msgWeaponList,gmsgBlinkAcct, gmsgRoundStart, gmsgTextMsg, gmsgMoney,g_msgScoreInfo
new gmsgFade;
new cvar_botquota, cvar_friendlyfire,g_freezetime
new cvar_freebuy,cvar_freebuyzone;
// === Spr/Model Cache ===
new g_sModelIndexSmokeSmallPuff, g_sModelIndexBlockShell;
new g_sModelIndexLaserBeam;
new g_cache_destroyerExplosion;
new Float:g_flFramesBuffAKEXP, g_sModelIndexBuffAKEXP;
new g_cache_blood, g_cache_bloodspray, g_cache_trail
new g_cache_flameburn
new g_cache_holyburn
new g_sModelIndexSmokeBeam;
//new g_cache_trace
new g_cache_plasmabomb
// === Const Spr/Model/Sound
new sound_buyammo[] = "items/9mmclip1.wav"
//new sound_pickupgun[] = "items/gunpickup2.wav"
// === Other Value ===
//new g_HeBlock
new g_fwHamBotRegister
new g_fwPrecacheEvent,g_iBlockSetModel
//new g_guns_eventids_bitsum
// Block Resource
new g_sBlockResource[MAX_BLOCK][512]
new g_iBlockNums

// Fix Bug
new g_lasthe[33] // fix he damage
new g_modruning
//new g_modbuylimit[33][5]
//new g_attack[33]
new g_anim[33]

//Improve
new g_save_guns[33][5]
new g_fw_RegisterNamedWeapon

// ======= ORPHEU ========
new OrpheuFunction:handleResetSequenceInfo;
new OrpheuFunction:handleSetAnimation;
new OrpheuFunction:handleApplyMultiDamage;
new OrpheuFunction:handleClearMultiDamage;
new OrpheuFunction:handleKickBack;
new OrpheuFunction:handleAddAccount;
new OrpheuFunction:handleHandleBuyAliasCommands;
new OrpheuFunction:handleTEXTURETYPE_PlaySound;
new OrpheuFunction:handleSelectItem;
new OrpheuFunction:handleSelectLastItem;
//new OrpheuFunction:handleBuyItem;
//new OrpheuFunction:handleCanPlayerBuy;
new OrpheuFunction:handleDefaultReload;

// ======= RAGE ========
new RageFunc:handleFireBullets3, RageFunc:handleFireBullets
new g_bIgnoreHook


new g_sModelIndexFireball2,g_sModelIndexFireball3, g_sModelIndexSmoke, g_sModelIndexBubbles;

new Float:fMaxSpeed[33], Float:fNextMaxSpeedReset[33];

new Float:g_punchangle[33][3];

new g_grenade[33];

new DECAL_SCORCH[3]
new DECAL_SHOT[5]

new g_iWeaponMode[33][4];
new g_iBlockSwitchDrop[33];

new WEAPON_EVENT[32];

//new m_usFireELITE_LEFT, m_usFireELITE_RIGHT;

new g_iShotsFired[33];
new Float:g_flAccuracy[33];
new Float:g_flSpread[33];
new Float:g_flLastFire[33];

new c_sModel[MAX_WPN][32];
new c_sModel_V[MAX_WPN][64];
new c_sModel_P[MAX_WPN][64];
new c_sModel_W[MAX_WPN][64];
new c_iModel_W_Sub[MAX_WPN];

new c_sSound[MAX_WPN][64], c_iSprite[MAX_WPN]; // for hegrenade

new c_sDoubleMode[MAX_WPN][32];

new c_iId[MAX_WPN];
new c_iSlot[MAX_WPN];
new c_iMenu[MAX_WPN];
new c_iType[MAX_WPN];
new c_iSpecial[MAX_WPN];

new Float:c_flDamage[MAX_WPN][4];
new Float:c_flDamageZB[MAX_WPN][4];

new Float:c_flAttackInterval[MAX_WPN][4];

new c_iClip[MAX_WPN], c_iAmmo[MAX_WPN], c_iMaxAmmo[MAX_WPN], c_iAmmoCost[MAX_WPN];

new c_iBulletType[MAX_WPN];
new c_iPenetration[MAX_WPN][4];
new Float:c_flRangeModifier[MAX_WPN][4];
new Float:c_flDistance[MAX_WPN][4];
new Float:c_flDelay[MAX_WPN][4];
new Float:c_flAngle[MAX_WPN][4];
new Float:c_flRecoil[MAX_WPN];

new Float:c_flReload[MAX_WPN][4];
new Float:c_flDeploy[MAX_WPN];

new c_iReloadAnim[MAX_WPN][4];
new c_iDeployAnim[MAX_WPN][4];
new c_iIdleAnim[MAX_WPN][4];

new Float:c_flReloadAnimTime[MAX_WPN][4];
new Float:c_flDeployAnimTime[MAX_WPN][4];
new Float:c_flIdleAnimTime[MAX_WPN][4];
new Float:c_flShootAnimTime[MAX_WPN][2];

new c_iAccuracyCalculate[MAX_WPN];
new Float:c_flAccuracyDefault[MAX_WPN];
new Float:c_flAccuracy[MAX_WPN][4];
new Float:c_flAccuracyRange[MAX_WPN][2];
new Float:c_flSpread[MAX_WPN][5];
new Float:c_flSpreadUnZoom[MAX_WPN];
new Float:c_flSpreadRun[MAX_WPN];
new Float:c_flAccuracyMul[MAX_WPN][4];

new Float:c_flKickBack[4][MAX_WPN][7];

new Float:c_vecSpread[MAX_WPN][3];
new c_cShots[MAX_WPN];

new c_szAnimExtention[MAX_WPN][32];

new c_iZoom[MAX_WPN][2];
new Float:c_flMaxSpeed[MAX_WPN][4];

new c_iCost[MAX_WPN];
new c_bCanBuy[MAX_WPN];
new c_iTeam[MAX_WPN];
new c_iModeLimit[MAX_WPN];

new Float:c_flEjectBrass[MAX_WPN];

new Float:c_flKnockback[MAX_WPN][16];
new Float:c_flVelocityModifier[MAX_WPN][4];
new Float:c_flArmorRatio[MAX_WPN][4];

new c_iShake[MAX_WPN];

new c_iExtraAmmo[MAX_WPN];
new c_iExtraAmmoCost[MAX_WPN];

new Float:c_vecViewAttachment[MAX_WPN][3];
new Float:c_flEntitySpeed[MAX_WPN];
new Float:c_flEntityAngle[MAX_WPN];
new Float:c_flEntityGravity[MAX_WPN];
new Float:c_flEntityDamage[MAX_WPN][2];
new Float:c_flEntityDamageZB[MAX_WPN][2];
new Float:c_flEntityRange[MAX_WPN][2];
new c_iEntityMove[MAX_WPN];
new c_iEntityBeam[MAX_WPN];
new c_iEntityLightEffect[MAX_WPN];
new c_iEntityClass[MAX_WPN];
new c_sEntityModel[MAX_WPN][64];
new Float:c_flEntityKnockBack[MAX_WPN];

new Float:c_flDoubleChange[MAX_WPN][2];

new c_iBurstTimes[MAX_WPN], Float:c_flBurstSpeed[MAX_WPN], Float:c_flBurstSpread[MAX_WPN];

new Float:c_flPunchangle[MAX_WPN];

new Float:c_flElitesFireSrcOfs[MAX_WPN];

new g_isZomMod4, g_isZSE, g_isZomMod5

new g_szLimitWeapon[MAX_WPN][32];
new g_bDefaultWeaponLimited[6];

//new Float:g_flNextAutoReload[33];

new g_szKillWeapon[32];
new g_bSGDRILL_Attacking;
new g_pLastVictim;
new g_bHostOwnBuffAK47, g_bHostOwnBuffSG552, g_bHostOwnBuffM4A1, g_bHostOwnBuffAWP;

// Used for MVP Board
new g_iPlanting, g_iDefusing;
new gmsgAlarm, gmsgMVPBoard, gmsgMVP, gmsgAssist;
new g_iPlanter, g_iDefuser;
new g_iRank[3][33];
new Float:g_flStartTime = 0.0;
new Float:g_fOldHealth[512];
new Float:g_fTotalDamage[512][512];
new Float:g_fNextClear[512][512];