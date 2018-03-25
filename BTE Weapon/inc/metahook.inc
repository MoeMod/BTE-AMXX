// MetaHook Include
// Version 1.0
// Author: Martin
// Editor: Csoldjb (Thanks to Martin!!!)

#if defined _metahook_included
	#endinput
#endif
#define _metahook_included

#if AMXX_VERSION_NUM >= 175
 #pragma reqlib metahook
 #if !defined AMXMODX_NOAUTOLOAD
  #pragma loadlib metahook
 #endif
#else
 #pragma library metahook
#endif

// 给玩家显示一张TGA (不需要缓存 收到消息后 MetaHook会自动加载)
// 参数依次为
// 玩家id szTga-TGA名字(如果要显示test.tga 直接填 test即可)  iFunc-无用参数
// iCenter-是否居中显示  rgb为颜色值 xy为屏幕坐标(0.0-1.0)
// iMode = 图片消息显示模式 [0 - 正常显示 // 1 - 淡入 // 2 - 淡出 // 3 - 淡入淡出] iChan-频道 fTime-显示时间
native MH_DrawTargaImage(id,szTga[],iFunc,iCenter,r,g,b,Float:x,Float:y,iMode,iChan,Float:fTime) //
native MH_BuyMenu(id,iType,iPage,iHaveNextPage,sz[])
native MH_SendData(id,iType,iData,szData[])

// 给玩家画一个倒计时
// sz为提示 time为时间
native MH_DrawCountDown(id,sz[],itime)

// 关闭倒计时（time为0也会自动关闭倒计时）
native MH_DrawCountDownReset(id)

// 提供一个复活进度条
native MH_RespawnBar(id,i,Float:time)

native MH_IsMetaHookPlayer(iIndex) // 判断玩家是否使用MetaHook

// 提供一个文本显示（华康圆体W9字体）
// iSale 字体大小 fLastTime 字体持续时间 fFadeTime 字体淡入淡出时间 iFillBg是否绘制背景 iChan频道
native MH_DrawFontText(id,text[],icenter,Float:x,Float:y,r,g,b,iSale,Float:fLastTime,Float:fFadeTime,iFillBg,iChannel)

// 播放BIK文件
native MH_PlayBink(id,sBink[],Float:x,Float:y,iR,iG,iB,iLoop,iPlay,iCenter,iFullScreen)


native MH_DrawExtraAmmo(iIndex,iType)  // 内部API
native MH_Quest(id,i1,i2,i3)  // 内部API
native MH_WeaponSkin(id,i1,sz[],i2)  // 内部API
native MH_SendDRRank(id,iRank,id2,s[])  // 内部API
native MH_ChangeTattoo(id,sTattoo[],iType)  // 内部API(改变纹身/手臂用)
native MH_SendClientModRunning(iIndex,iModRunning)  // 内部API
native MH_SpecialEvent(iIndex , iSpecialEvent)  // 内部API
// 显示给玩家一张图片 (SPR)
//
// iIndex = 玩家索引
// iCheck = 是否读取hud.txt中的SPR(1为hud中的SPR)，反之是SPR文件
// iCenter = 是否图片居中
// szSprite = 图片文件名
// x = 横向坐标 (0.5 为屏幕中心位置)
// y = 纵向坐标 (0.5 为屏幕中心位置)
// r = 图片消息的红色值
// g = 图片消息的绿色值
// b = 图片消息的蓝色值
// iMode = 图片消息显示模式 [0 - 禁用 // 1 - 淡入 // 2 - 淡出 // 3 - 淡入淡出]
// flTime = 图片消息的显示时间
// iChanne = 图片消息的通道值 (小于 0 或者大于 63 为随机)
// iLength = 图片显示的长度(为方便只支持hud中的SPR，长度请通过坐标计算，适合用过做动态血条等)
//
native MH_DrawImage(iIndex, iCheck = 1, iCenter = 1, const szSprite[], Float:x = 0.5, Float:y = 0.5, r = 255, g = 255, b = 255, iMode = 0, Float:flDisplayTime = 1.0, iChanne = 0, iLength)

// 显示给玩家一张 Additive 模式图片 (SPR)
//
// iIndex = 玩家索引
// iCheck = 是否读取hud.txt中的SPR(1为hud中的SPR)，反之是SPR文件
// iCenter = 是否图片居中
// szSprite = 图片文件名
// x = 横向坐标 (0.5 为屏幕中心位置)
// y = 纵向坐标 (0.5 为屏幕中心位置)
// r = 图片消息的红色值
// g = 图片消息的绿色值
// b = 图片消息的蓝色值
// iMode = 图片消息显示模式 [0 - 禁用 // 1 - 淡入 // 2 - 淡出 // 3 - 淡入淡出]
// flTime = 图片消息的显示时间
// iChanne = 图片消息的通道值 (小于 0 或者大于 63 为随机)
//
native MH_DrawAdditiveImage(iIndex, iCheck = 1, iCenter = 1, const szSprite[], Float:x = 0.5, Float:y = 0.5, r = 255, g = 255, b = 255, iMode = 0, Float:flDisplayTime = 1.0, iChanne = 0, iLength)

// 显示给玩家一张 Holes 模式图片 (SPR)
//
// iIndex = 玩家索引
// iCheck = 是否读取hud.txt中的SPR(1为hud中的SPR)，反之是SPR文件
// iCenter = 是否图片居中
// szSprite = 图片文件名
// x = 横向坐标 (0.5 为屏幕中心位置)
// y = 纵向坐标 (0.5 为屏幕中心位置)
// r = 图片消息的红色值
// g = 图片消息的绿色值
// b = 图片消息的蓝色值
// iMode = 图片消息显示模式 [0 - 禁用 // 1 - 淡入 // 2 - 淡出 // 3 - 淡入淡出]
// flTime = 图片消息的显示时间
// iChanne = 图片消息的通道值 (小于 0 或者大于 63 为随机)
// iLength = 图片显示的长度(为方便只支持hud中的SPR，长度请通过坐标计算，适合用过做动态血条等)
//
native MH_DrawHolesImage(iIndex, iCheck = 1, iCenter = 1, const szSprite[], Float:x = 0.5, Float:y = 0.5, r = 255, g = 255, b = 255, iMode = 0, Float:flDisplayTime = 1.0, iChanne = 0, iLength)

// 显示给玩家一段文字
//
// iIndex = 玩家索引
// iCenter = 是否文字居中
// szText = 需要显示的文字
// x = 横向坐标 (0.5 为屏幕中心位置)
// y = 纵向坐标 (0.5 为屏幕中心位置)
// r = 文字消息的红色值
// g = 文字消息的绿色值
// b = 文字消息的蓝色值
// flTime = 文字消息的显示时间
// iChanne = 文字消息的通道值 (小于 0 或者大于 63 为随机)
// iLength = 图片显示的长度(为方便只支持hud中的SPR，长度请通过坐标计算，适合用过做动态血条等)
//
native MH_DrawText(iIndex, iCenter = 1, const szText[], Float:x = 0.5, Float:y = 0.5, r = 255, g = 255, b = 255, Float:flDisplayTime = 1.0, iChanne = 0)

// 设置玩家视角模型的身体部位
//
// iIndex = 玩家索引
// iBody = 身体部位 (-1 不做任何改变)
//
native MH_SetViewEntityBody(iIndex, iBody = -1)

// 设置玩家视角模型的渲染属性
// 渲染属性参数请参照 "amxconst.inc".
//
// iIndex = 玩家索引
// iMode = 渲染模式 (-1 不做任何改变)
// iEffect = 渲染特效
// iColorR = 渲染红色值
// iColorG = 渲染绿色值
// iColorB = 渲染蓝色值
// iAmout = 渲染值
//
native MH_SetViewEntityRender(iIndex, iMode = -1, iEffect, iColorR, iColorG, iColorB, iAmout)

// 给玩家提供一个记分牌
// 
// iIndex = 玩家索引
// szScoreBoardName = 记分牌SPR
// iTopLeftNum = 记分牌左上数字 (SHORT支持大于10000)
// iTopCenterNum = 记分牌中间数字 (BYTE 最大255)
// iTopRightNum = 记分牌右上数字 (SHORT)
// iDownLeftNum = 记分牌左下数字 (SHORT)
// iDownRightNum = 记分牌右下数字 (SHORT)
// iMode = 可用于记录模式 (SHORT)
// 当iDownLeftNum 等于 -1 时，可关闭下方的数字显示，比如用于团队个人模式等
// 当iMode = -1 时可以关闭记分牌 :D 记分牌初始化时iMode默认为 -1(1为生化 竞技样式 2 为大灾变样式 3 为 团队个人样式)
//
native MH_DrawScoreBoard(iIndex,iTopLeftNum, iTopCenterNum, iTopRightNum, iDownLeftNum, iDownRightNum ,iMode)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
