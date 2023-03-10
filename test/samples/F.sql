PROCEDURE f (
    P                IN VARCHAR2 DEFAULT NULL,
    P_SEP            IN VARCHAR2 DEFAULT ':',
    P_TRACE          IN VARCHAR2 DEFAULT 'NO',
    C                IN VARCHAR2 DEFAULT NULL,
    PG_MIN_ROW       IN VARCHAR2 DEFAULT NULL,
    PG_MAX_ROWS      IN VARCHAR2 DEFAULT NULL,
    PG_ROWS_FETCHED  IN VARCHAR2 DEFAULT NULL,
    FSP_REGION_ID    IN VARCHAR2 DEFAULT NULL,
    SUCCESS_MSG      IN VARCHAR2 DEFAULT NULL,
    NOTIFICATION_MSG IN VARCHAR2 DEFAULT NULL,
    CS               IN VARCHAR2 DEFAULT NULL,
    S                IN VARCHAR2 DEFAULT 'N',
    TZ               IN VARCHAR2 DEFAULT NULL,
    P_LANG           IN VARCHAR2 DEFAULT NULL,
    P_TERRITORY      IN VARCHAR2 DEFAULT NULL,
    P_DIALOG_CS      IN VARCHAR2 DEFAULT NULL,
    X01              IN VARCHAR2 DEFAULT NULL )
AS




































































































    L_COMPANY_ID  NUMBER;
    L_P_ARGUMENTS WWV_FLOW_UTILITIES.T_P_ARGUMENTS;
    L_STATUS      NUMBER;
    L_LOCK_HANDLE VARCHAR2(40);
    L_CLEAR_CACHE WWV_FLOW_GLOBAL.VC_ARR2;
BEGIN
    
    
    
    BEGIN
       L_COMPANY_ID := C;
    EXCEPTION WHEN OTHERS THEN
       FOR C1 IN (SELECT PROVISIONING_COMPANY_ID FROM WWV_FLOW_COMPANIES WHERE SHORT_NAME = UPPER(C)) LOOP
          L_COMPANY_ID := C1.PROVISIONING_COMPANY_ID;
       END LOOP;
    END;
    
    
    
    L_P_ARGUMENTS := WWV_FLOW_UTILITIES.PARSE_P (
                         P_ARGUMENTS => P,
                         P_SEP       => P_SEP );

    IF L_P_ARGUMENTS.CLEAR_CACHE IS NOT NULL THEN
        L_CLEAR_CACHE := WWV_FLOW_UTILITIES.STRING_TO_TABLE2 (
                             STR => L_P_ARGUMENTS.CLEAR_CACHE,
                             SEP => ',' );
    END IF;

    
    WWV_FLOW.G_PRINT_SUCCESS_MESSAGE := SUCCESS_MSG;
    WWV_FLOW.G_NOTIFICATION          := NOTIFICATION_MSG;

    
    IF S = 'Y' AND L_P_ARGUMENTS.PAGE IS NOT NULL AND L_P_ARGUMENTS.SESSION_ID IS NOT NULL THEN
        L_LOCK_HANDLE := SUBSTR (
                             L_P_ARGUMENTS.APP||'.'||L_P_ARGUMENTS.PAGE||'.'||L_P_ARGUMENTS.SESSION_ID,
                             1,
                             40 );
        L_STATUS := SYS.DBMS_LOCK.REQUEST(
                        LOCKHANDLE        => L_LOCK_HANDLE,
                        LOCKMODE          => SYS.DBMS_LOCK.X_MODE,
                        TIMEOUT           => 60,
                        RELEASE_ON_COMMIT => FALSE );
    END IF;
    
    IF CS IS NOT NULL THEN
        
        WWV_FLOW_SECURITY.G_URL_CHECKSUM_SRC := L_P_ARGUMENTS.REQUEST||
                                                L_P_ARGUMENTS.CLEAR_CACHE;
        FOR I IN 1 .. L_P_ARGUMENTS.ARG_NAMES.COUNT LOOP
            WWV_FLOW_SECURITY.G_URL_CHECKSUM_SRC := WWV_FLOW_SECURITY.G_URL_CHECKSUM_SRC || L_P_ARGUMENTS.ARG_NAMES( I ) || L_P_ARGUMENTS.ARG_VALUES( I );
        END LOOP;
    END IF;

    WWV_FLOW.SHOW (
        P_FLOW_ID          => L_P_ARGUMENTS.APP,
        P_FLOW_STEP_ID     => L_P_ARGUMENTS.PAGE,
        P_INSTANCE         => L_P_ARGUMENTS.SESSION_ID,
        P_REQUEST          => L_P_ARGUMENTS.REQUEST,
        P_DEBUG            => L_P_ARGUMENTS.DEBUG,
        P_CLEAR_CACHE      => L_CLEAR_CACHE,
        P_ARG_NAMES        => L_P_ARGUMENTS.ARG_NAMES,
        P_ARG_VALUES       => L_P_ARGUMENTS.ARG_VALUES,
        P_PRINTER_FRIENDLY => L_P_ARGUMENTS.PRINTER_FRIENDLY,
        P_TRACE            => P_TRACE,
        P_COMPANY          => L_COMPANY_ID,
        P_TIME_ZONE        => TRIM(TZ),
        P_LANG             => P_LANG,
        P_TERRITORY        => P_TERRITORY,
        P_FSP_REGION_ID    => FSP_REGION_ID,
        P_PG_MIN_ROW       => PG_MIN_ROW,
        P_PG_MAX_ROWS      => PG_MAX_ROWS,
        P_PG_ROWS_FETCHED  => PG_ROWS_FETCHED,
        P_CS               => CS,
        P_DIALOG_CS        => P_DIALOG_CS,
        X01                => X01 );

     
     IF L_STATUS IS NOT NULL THEN
        L_STATUS := SYS.DBMS_LOCK.RELEASE(L_LOCK_HANDLE);
     END IF;

     WWV_FLOW_SECURITY.G_SECURITY_GROUP_ID := NULL;
EXCEPTION WHEN OTHERS THEN
     WWV_FLOW_SECURITY.G_SECURITY_GROUP_ID := NULL;
     L_STATUS := SYS.DBMS_LOCK.RELEASE(L_LOCK_HANDLE);
     RAISE_APPLICATION_ERROR (-20867, SQLERRM);
END;