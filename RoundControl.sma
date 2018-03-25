
    #include <amxmodx>
    #include <amxmisc>
    #include <orpheu_memory>
    #include <orpheu_stocks>
    #include <fakemeta>
    #include <engine>
    #include <round_terminator>


    /* PLUGIN INFORMATIONS */

        new const pluginName   [] = "Round Terminator";
        new const pluginVersion[] = "1.0.1";
        new const pluginAuthor [] = "Arkshine";


    /* CONSTANTS */

        enum /* Win Status */
        {
            WinStatus_Ct = 1,
            WinStatus_Terrorist,
            WinStatus_RoundDraw
        };

        enum /* Events */
        {
            Event_TargetBombed = 1,
            Event_VIPEscaped,
            Event_VIPAssassinated,
            Event_TerroristsEscaped,
            Event_CTsPreventEscape,
            Event_EscapingTerroNeutralized,
            Event_BombDefused,
            Event_CTsWin,
            Event_TerroristsWin,
            Event_RoundDraw,
            Event_AllHostagesRescued,
            Event_TargetSaved,
            Event_HostagesNotRescued,
            Event_TerroristsNotEscaped,
            Event_VIPNotEscaped
        };


    /* VARIABLES */

        new g_pGameRules;


    /* MACROS */

        #define set_mp_pdata(%1,%2)  ( OrpheuMemorySetAtAddress( g_pGameRules, %1, 1, %2 ) )
        #define get_mp_pdata(%1)     ( OrpheuMemoryGetAtAddress( g_pGameRules, %1 ) )


    public plugin_precache()
    {
        OrpheuRegisterHook( OrpheuGetFunction( "InstallGameRules" ), "OnInstallGameRules", OrpheuHookPost );
    }


    public OnInstallGameRules()
    {
        g_pGameRules = OrpheuGetReturn();
    }


    public plugin_init()
    {
        register_plugin( pluginName, pluginVersion, pluginAuthor );
        register_cvar( "round_terminator_version", pluginVersion, FCVAR_SERVER | FCVAR_SPONLY );

        register_concmd( "terminate_round", "ClientCommand_TerminateRound", ADMIN_RCON, "- Terminate a round immediately" );
    }


    public plugin_natives ()
    {
        register_library( "round_terminator")
        register_native( "TerminateRound", "Native_TerminateRound" );
    }


    public Native_TerminateRound ( const plugin, const params )
    {
        enum
        {
            RoundEndType = 1,
            TeamWinning,
            MapType
        }

        _TerminateRound( get_param( RoundEndType ), get_param( TeamWinning ), get_param( MapType ) );
        
        //client_print(0, print_chat, "called");
   }


    /**
     *  A player has used the command.
     *
     *  @param player       The player's index who has used the command.
     *  @param level        The access level needed to use the command.
     *  @param cid          The command index.
     */
    public ClientCommand_TerminateRound ( const player, const level, const cid )
    {
        if ( !cmd_access( player, level, cid, 1 ) )
        {
            return PLUGIN_HANDLED;
        }

        new argumentCount = read_argc();

        if ( argumentCount < 2 )
        {
            /*
                | No arguments passed, we show the command syntax so.
            */
            console_print( player, "^n- terminate_round <RoundEndType> [ <TeamWinning> <MapType> ]^n" );
            console_print( player, "^tRoundEndType : timer, team, objective, draw" );
            console_print( player, "^tTeamWinning  : terrorist, ct" );
            console_print( player, "^tMapType      : auto, bomb, escape, hostage,vip^n" );

            return PLUGIN_HANDLED;
        }

        new bool:needMoreArguments;
        new roundEndType;
        new teamWinning;
        new mapType;

        new argumentRoundEndType[ 12 ];
        read_argv( 1, argumentRoundEndType, charsmax( argumentRoundEndType ) );

        switch ( argumentRoundEndType[ 0 ] )
        {
            case 't', 'T' /* [t]imer/[t]eam */ :
            {
                switch ( argumentRoundEndType[ 1 ] )
                {
                    case 'i', 'I' /* t[i]mer */ : { roundEndType = RoundEndType_Timer; }
                    case 'e', 'E' /* t[e]am  */ : { roundEndType = RoundEndType_TeamExtermination; needMoreArguments = true; }
                }
            }
            case 'o', 'O' /* [o]bjective */ : { roundEndType = RoundEndType_Objective; needMoreArguments = true; }
            case 'd', 'D' /* [d]raw      */ : { roundEndType = RoundEndType_Draw; }
        }

        if ( needMoreArguments )
        {
            if ( argumentCount != 3 )
            {
                /*
                    | It needs a second param.
                */
                return PLUGIN_HANDLED;
            }

            new argumentTeamWinning [ 12 ];
            read_argv( 2, argumentTeamWinning , charsmax( argumentTeamWinning ) );

            switch ( argumentTeamWinning[ 0 ] )
            {
                case 't', 'T' /* [t]errorist */ : { teamWinning = TeamWinning_Terrorist; }
                case 'c', 'C' /* [c]t        */ : { teamWinning = TeamWinning_Ct; }
            }

            if ( argumentCount == 4 )
            {
                new argumentMapType[ 12 ];
                read_argv( 3, argumentMapType , charsmax( argumentMapType ) );

                switch ( argumentMapType[ 0 ] )
                {
                    case 'a', 'A' /* [a]uto    */ : { mapType = MapType_AutoDetect;      }
                    case 'b', 'B' /* [b]omb    */ : { mapType = MapType_Bomb;            }
                    case 'e', 'E' /* [e]scape  */ : { mapType = MapType_PrisonEscape;    }
                    case 'h', 'H' /* [h]ostage */ : { mapType = MapType_Hostage;         }
                    case 'v', 'V' /* [v]ip     */ : { mapType = MapType_VipAssasination; }
                }
            }
        }

        _TerminateRound( roundEndType, teamWinning, mapType );
        return PLUGIN_HANDLED;
    }


    /**
     *  The main function to terminate a round.
     *
     *  @param roundEndType     The round end type wanted.
     *  @param teamWinning      The choice of the team winning.
     *  @param mapType          The map type.
     *  @return                 true on success, false on failure.
     */
    bool:_TerminateRound ( const roundEndType, const teamWinning, const mapType )
    {
        switch ( roundEndType )
        {
            case RoundEndType_Timer :
            {
                /*
                    | Timer has ended and the main objectives have failed.
                    | Triggered from CHalfLifeMultiplay::Think().
                    |
                    | Default behaviour :
                    |
                    | Bomb map    : CT Win -> Target saved.
                    | Hostage map : T  Win -> Hostages not rescued.
                    | Escape map  : CT Win -> Terrorists not escaped.
                    | VIP map     : T  Win -> VIP not escaped.
                */

                set_mp_pdata( "m_iRoundWinStatus", 0   );
                set_mp_pdata( "m_iRoundTimeSecs" , 0   );
                set_mp_pdata( "m_fRoundCount"    , 0.0 );
            }
            case RoundEndType_TeamExtermination :
            {
                if ( !( TeamWinning_Terrorist <= teamWinning <= TeamWinning_Ct ) )
                {
                    return false;
                }

                /*
                    | A team has been exterminated.
                    | Triggered by default from CHalfLifeMultiplay::CheckWinConditions().
                    |
                    | No choice to redo the whole part for that since it involves normal vars
                    | created in the top of this function which count the number of terrorists
                    | and cts. It's something we can't altered. So we redo the exact CS code.
                    | I don't like much because there are some things harcoded like money, if
                    | a plugin wants to change that, it will leads to some problems.
                    | Oh well, whatever. :D
                */

                if ( teamWinning == TeamWinning_Ct )
                {
                    /*
                        | On bomb map, no need to terminate the round if the bomb has just blew.
                        | So, we ignore.
                        |
                        | Note about m_bIsC4. This offset seems to be an integer, it returns 256 when
                        | the "grenade" entity is a C4 bomb. In CS, it checks m_bIsC4 == 1, I guess there
                        | is a typo, though I did not checked more.
                    */

                    const m_bIsC4     = 96;  // "grenade" offset.
                    const m_bJustBlew = 108; // "grenade" offset.
                    const linuxDiff   = 4;

                    new grenade;

                    while ( ( grenade = find_ent_by_class( grenade, "grenade" ) ) )
                    {
                        if ( is_valid_ent( grenade ) && get_pdata_int( grenade, m_bIsC4, linuxDiff ) && get_pdata_int( grenade, m_bJustBlew, linuxDiff ) )
                        {
                            return false;
                        }
                    }
                }

                new accountOffsetName[ 22 ];
                new numTeamOffsetName[ 22 ];
                new roundEndmessage  [ 16 ];
                new sentenceName     [ 16 ];
                new winStatus;
                new event;
                new teamMoney = 3000;

                if ( get_mp_pdata( "m_bMapHasBombTarget" ) )
                {
                    teamMoney = 3250;
                }

                switch ( teamWinning )
                {
                    case TeamWinning_Terrorist :
                    {
                        accountOffsetName = "m_iAccountTerrorist";
                        numTeamOffsetName = "m_iNumTerroristWins";
                        sentenceName      = "%!MRAD_TERWIN";
                        roundEndmessage   = "#Terrorists_Win";
                        event             = Event_TerroristsWin;
                        winStatus         = WinStatus_Terrorist;
                    }
                    case TeamWinning_Ct :
                    {
                        accountOffsetName = "m_iAccountCT";
                        numTeamOffsetName = "m_iNumCTWins";
                        sentenceName      = "%!MRAD_CTWIN";
                        roundEndmessage   = "#CTs_Win";
                        event             = Event_CTsWin;
                        winStatus         = WinStatus_Ct;
                    }
                }

                //BroadcastAudio( .senderID = 0, .audioCode = sentenceName, .pitch = 100, .notifyAllPlugins = true );
                set_mp_pdata( accountOffsetName, get_mp_pdata( accountOffsetName ) + teamMoney );

                //client_print(0, print_chat, "m_iNumSpawnableTerrorist : %d  m_iNumSpawnableCT: %d", get_mp_pdata( "m_iNumSpawnableTerrorist" ),get_mp_pdata( "m_iNumSpawnableCT" ));
                
                new iNumSpawnableTerrorist, iNumSpawnableCT;
                
                for (new id = 1; id <= 32; id++)
                {
                    if (!is_user_connected(id))
                        continue;
                    
                    if (get_pdata_int(id, 114) == 2) // m_iTeam TEAM_CT
                    {
                        if (get_pdata_int(id, 205) != 3) // m_iMenu != Menu_ChooseAppearance
                            iNumSpawnableCT ++;
                    }
                    
                    if (get_pdata_int(id, 114) == 1) // TEAM_TERRORIST
                    {
                        if (get_pdata_int(id, 205) != 3) // m_iMenu != Menu_ChooseAppearance
                            iNumSpawnableTerrorist ++;
                    }
                }
                
                set_mp_pdata( "m_iNumSpawnableTerrorist" , iNumSpawnableTerrorist );
                set_mp_pdata( "m_iNumSpawnableCT" , iNumSpawnableCT );
                
                if ( iNumSpawnableTerrorist || iNumSpawnableCT/*get_mp_pdata( "m_iNumSpawnableTerrorist" ) && get_mp_pdata( "m_iNumSpawnableCT" )*/ )
                {
                    set_mp_pdata( numTeamOffsetName, get_mp_pdata( numTeamOffsetName ) + 1 );
                    UpdateTeamScores( .notifyAllPlugins = true );
                    
                   // client_print(0, print_chat, "%s : %d", numTeamOffsetName, get_mp_pdata( numTeamOffsetName ));
                }

                EndRoundMessage( roundEndmessage, event, .notifyAllPlugins = true );
                RoundTerminating( winStatus, .delay = 5.0 );
            }
            case RoundEndType_Objective :
            {
                /*
                    | An objective has been completed with success.
                    | Triggered by default from CHalfLifeMultiplay::CheckWinConditions().
                    |
                    | This works without problem on map with severals objectives.
                    | Using "auto" as param and the map type will be detected automatically.
                    | On maps with multiple objectives, you should not used "auto" since it will
                    | take the first type which comes.
                */

                static currentMapType;

                if ( mapType == MapType_AutoDetect || !( MapType_AutoDetect <= mapType <= MapType_PrisonEscape ) )
                {
                    if ( get_mp_pdata( "m_iMapHasVIPSafetyZone" ) == 1 )
                    {
                        currentMapType = MapType_VipAssasination;
                    }
                    else if ( get_mp_pdata( "m_bMapHasBombTarget" ) )
                    {
                        currentMapType = MapType_Bomb;
                    }
                    else if ( get_mp_pdata( "m_bMapHasRescueZone" ) )
                    {
                        currentMapType = MapType_Hostage;
                    }
                    else if ( get_mp_pdata( "m_bMapHasEscapeZone" ) )
                    {
                        currentMapType = MapType_PrisonEscape;
                    }
                }
                else
                {
                    currentMapType = mapType;
                }

                switch ( currentMapType )
                {
                    case MapType_VipAssasination :
                    {
                        const m_bEscaped = 209; // player's offset.
                        new playerVIP = get_mp_pdata( "m_pVIP" );

                        if ( playerVIP <= 0 )
                        {
                            return false;
                        }

                        switch ( teamWinning )
                        {
                            case TeamWinning_Terrorist : { set_pev( playerVIP, pev_deadflag, DEAD_DEAD ); }
                            case TeamWinning_Ct        : { set_pdata_int( playerVIP, m_bEscaped, true );  }
                        }
                    }
                    case MapType_Bomb :
                    {
                        switch ( teamWinning )
                        {
                            case TeamWinning_Terrorist : { set_mp_pdata( "m_bTargetBombed", true ); }
                            case TeamWinning_Ct        : { set_mp_pdata( "m_bBombDefused" , true ); }
                        }
                    }
                    case MapType_Hostage :
                    {
                        /*
                            | To count alive hostages, CS counts hostages which have the DAMAGE_YES value.
                            | Then there are 2 following checks : if there is still one alive hostage,
                            | and if m_iHostagesRescued >= ( hostagesCount * 0.5 ).
                            | So, to trigger, we make sure it finds no alive hostages and we store the hostage
                            | count in m_iHostagesRescued to make sure the second check is true.
                        */

                        if ( teamWinning == TeamWinning_Ct )
                        {
                            new hostage;
                            new hostageCount;

                            while ( ( hostage = find_ent_by_class( hostage, "hostage_entity" ) ) )
                            {
                                if ( pev_valid( hostage ) )
                                {
                                    hostageCount++;
                                    set_pev( hostage, pev_takedamage, DAMAGE_NO );
                                }
                            }

                            set_mp_pdata( "m_iHostagesRescued", hostageCount );
                        }
                    }
                    case MapType_PrisonEscape :
                    {
                        /*
                            | Like the team extermination, no choice to redo the whole part.
                            | The code is the same as CS.
                        */

                        new accountOffsetName[ 22 ];
                        new numTeamOffsetName[ 22 ];
                        new roundEndmessage  [ 34 ];
                        new sentenceName     [ 16 ];
                        new event;
                        new winStatus;
                        new teamMoney;

                        switch ( teamWinning )
                        {
                            case TeamWinning_Terrorist :
                            {
                                sentenceName      = "%!MRAD_TERWIN";
                                accountOffsetName = "m_iAccountTerrorist";
                                numTeamOffsetName = "m_iNumTerroristWins";
                                roundEndmessage   = "#Terrorists_Escaped";
                                event             = Event_TerroristsEscaped;
                                winStatus         = WinStatus_Terrorist;
                                teamMoney         = 3150;
                            }
                            case TeamWinning_Ct :
                            {
                                new numEscapers = get_mp_pdata( "m_iNumEscapers" );

                                if ( !numEscapers )
                                {
                                    return false;
                                }

                                new Float:escapeRatio = get_mp_pdata( "m_iHaveEscaped" ) / float( numEscapers );

                                sentenceName      = "%!MRAD_CTWIN";
                                accountOffsetName = "m_iAccountCT";
                                numTeamOffsetName = "m_iNumCTWins";
                                winStatus         = WinStatus_Ct;

                                if ( escapeRatio < get_mp_pdata( "m_flRequiredEscapeRatio" ) )
                                {
                                    roundEndmessage = "#CTs_PreventEscape";
                                    event           = Event_CTsPreventEscape;
                                    teamMoney       = 3500;
                                }
                                else
                                {
                                    roundEndmessage = "#Escaping_Terrorists_Neutralized";
                                    event           = Event_EscapingTerroNeutralized;
                                    teamMoney       = 3250;
                                }

                                teamMoney = floatround( ( 1 - escapeRatio ) * teamMoney );
                            }
                        }

                        //BroadcastAudio( .senderID = 0, .audioCode = sentenceName, .pitch = 100, .notifyAllPlugins = true );
                        set_mp_pdata( accountOffsetName, get_mp_pdata( accountOffsetName ) + teamMoney );

                        if ( get_mp_pdata( "m_iNumSpawnableTerrorist" ) && get_mp_pdata( "m_iNumSpawnableCT" ) )
                        {
                            set_mp_pdata( numTeamOffsetName, get_mp_pdata( numTeamOffsetName ) + 1 );
                            UpdateTeamScores( .notifyAllPlugins = true );
                        }

                        EndRoundMessage( roundEndmessage, event, .notifyAllPlugins = true );
                        RoundTerminating( winStatus, .delay = 5.0 );
                    }
                }

                /*
                    | The modifications neeeds to be rechecked right now.
                */
                CheckWinConditions( .notifyAllPlugins = true );
            }
            case RoundEndType_Draw :
            {
                /*
                    Both team have fallen in the same time.
                    It's a round draw.
                */

                //BroadcastAudio( .senderID = 0, .audioCode = "%!MRAD_ROUNDDRAW", .pitch = 100, .notifyAllPlugins = true );
                EndRoundMessage( "#Round_Draw", .event = Event_RoundDraw, .notifyAllPlugins = true );

                RoundTerminating( .winStatus = WinStatus_RoundDraw, .delay = 5.0 );
            }
        }

        return true;
    }


    /**
     *  Terminating a round.
     *
     *  @param winStatus             The team win status.
     *  @param delay                 The delay in seconds before the round restarts.
     */
    RoundTerminating( const winStatus, const Float:delay )
    {
        set_mp_pdata( "m_iRoundWinStatus"  , winStatus );
        set_mp_pdata( "m_fTeamCount"       , get_gametime() + delay );
        set_mp_pdata( "m_bRoundTerminating", true );
    }


    /**
     *  Play a sound for all players using SendAudio event.
     *
     *  @param senderID              The sender's index.
     *  @param audioCode             The sentence name to play.
     *  @param pitch                 The audio pitch.
     *  @param notifyAllPlugins      If it should notify all the plugins. (hookable)
     */
    BroadcastAudio ( const senderID, const audioCode[], const pitch, const bool:notifyAllPlugins = false )
    {
        static messageSendAudio;

        if ( messageSendAudio || ( messageSendAudio = get_user_msgid( "SendAudio" ) ) )
        {
            if ( notifyAllPlugins )
            {
                emessage_begin( MSG_BROADCAST, messageSendAudio );
                ewrite_byte( senderID );
                ewrite_string( audioCode );
                ewrite_short( pitch );
                emessage_end();
            }
            else
            {
                message_begin( MSG_BROADCAST, messageSendAudio );
                write_byte( senderID );
                write_string( audioCode );
                write_short( pitch );
                message_end();
            }
        }
    }


    /**
     *  CHalfLifeMultiply::UpdateTeamScores().
     *  Update the team scores. It sends TeamScore event.
     *
     *  @param notifyAllPlugins      If it should notify all the plugins. (hookable)
     */
    UpdateTeamScores ( const bool:notifyAllPlugins = false )
    {
        static OrpheuFunction:handleFuncUpdateTeamScores;

        if ( !handleFuncUpdateTeamScores )
        {
            handleFuncUpdateTeamScores = OrpheuGetFunction( "UpdateTeamScores", "CHalfLifeMultiplay" )
        }

        ( notifyAllPlugins ) ?

            OrpheuCallSuper( handleFuncUpdateTeamScores, g_pGameRules ) :
            OrpheuCall( handleFuncUpdateTeamScores, g_pGameRules );
    }


    /**
     *  CHalfLifeMultiply::CheckWinConditions().
     *  Check the win conditions and handle the round end.
     *
     *  @param notifyAllPlugins      If it should notify all the plugins. (hookable)
     */
    CheckWinConditions ( const bool:notifyAllPlugins = false )
    {
        static OrpheuFunction:handleFuncCheckWinConditions;

        if ( !handleFuncCheckWinConditions )
        {
            handleFuncCheckWinConditions = OrpheuGetFunction( "CheckWinConditions", "CHalfLifeMultiplay" )
        }

        ( notifyAllPlugins ) ?

            OrpheuCallSuper( handleFuncCheckWinConditions, g_pGameRules ) :
            OrpheuCall( handleFuncCheckWinConditions, g_pGameRules );
    }


    /**
     *  EndRoundMessage().
     *  Print a centered message on players with UTIL_ClientPrintAll()
     *  and log the event with UTIL_LogPrintf();
     *
     *  @param message               The message to send to players.
     *  @param event                 The event related to know if team is triggered.
     *  @param notifyAllPlugins      If it should notify all the plugins. (hookable)
     */
    EndRoundMessage ( const message[], const event, const bool:notifyAllPlugins = false )
    {
        static OrpheuFunction:handleFuncEndRoundMessage;

        if ( !handleFuncEndRoundMessage )
        {
            handleFuncEndRoundMessage = OrpheuGetFunction( "EndRoundMessage" );
        }

        ( notifyAllPlugins ) ?

            OrpheuCallSuper( handleFuncEndRoundMessage, message, event ) :
            OrpheuCall( handleFuncEndRoundMessage, message, event );
    }
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1034\\ f0\\ fs16 \n\\ par }
*/
