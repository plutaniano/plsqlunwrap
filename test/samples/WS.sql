PROCEDURE ws (
    P                IN VARCHAR2 DEFAULT NULL,
    P_SEP            IN VARCHAR2 DEFAULT ':',
    P_TRACE          IN VARCHAR2 DEFAULT 'NO',
    P_DEBUG          IN VARCHAR2 DEFAULT 'NO',
    TZ               IN VARCHAR2 DEFAULT NULL,
    P_LANG           IN VARCHAR2 DEFAULT NULL,
    P_TERRITORY      IN VARCHAR2 DEFAULT NULL)
    






























IS
    L                        WWV_FLOW_GLOBAL.VC_ARR2;
    L_ARG_NAMES              WWV_FLOW_GLOBAL.VC_ARR2;
    L_ARG_VALUES             WWV_FLOW_GLOBAL.VC_ARR2;    
    L_TIME_ZONE              VARCHAR2(10);
    
    L_PAGE_FOUND             BOOLEAN := FALSE;
    L_SESSION                NUMBER := NULL;
    L_APP_ID                 NUMBER := NULL;
    L_ALIAS                  VARCHAR2(255);
    L_ALLOW_PUBLIC_ACCESS_YN VARCHAR2(1) := NULL;
    
    L_DATA_GRID_ALIAS        VARCHAR2(255);
    L_ROW_ID                 NUMBER;
    L_DATA_GRID_FOUND        BOOLEAN := FALSE;
    L_REDIRECT_PAGE_ID       NUMBER;
    LA_CLEAR_CACHE           WWV_FLOW_GLOBAL.VC_ARR2;
    
    L_ITEM_NAME              VARCHAR2(4000);
    L_ITEM_VALUE             VARCHAR2(4000);
    LA_ITEM_NAME             WWV_FLOW_GLOBAL.VC_ARR2;
    LA_ITEM_VALUE            WWV_FLOW_GLOBAL.VC_ARR2;
BEGIN
    
    L := WWV_FLOW_UTILITIES.STRING_TO_TABLE2(STR=>P,SEP=>NVL(P_SEP,':'));

    FOR I IN (L.COUNT + 1) .. 3 LOOP
       L(I) := NULL;
    END LOOP;
    
    
    IF TZ IS NOT NULL AND LENGTH(TZ) < 10 THEN
        L_TIME_ZONE := TZ;
    ELSE
    	  L_TIME_ZONE := NULL;
    END IF;

    
    L_APP_ID := L(1);
    L_ALIAS := UPPER(L(2));
    L_SESSION := L(3);
    L_REDIRECT_PAGE_ID := 900;
    
    
    L_ITEM_NAME := WWV_FLOW_UTILITIES.ARRAY_ELEMENT(L,4);
    L_ITEM_VALUE := WWV_FLOW_UTILITIES.ARRAY_ELEMENT(L,5);
    IF L_ITEM_NAME IS NOT NULL THEN
        LA_ITEM_NAME  := WWV_FLOW_UTILITIES.STRING_TO_TABLE2(STR=>UPPER(L_ITEM_NAME),SEP=>',');
        LA_ITEM_VALUE := WWV_FLOW_UTILITIES.STRING_TO_TABLE2(STR=>L_ITEM_VALUE,SEP=>',');
        
        
        FOR I IN LA_ITEM_VALUE.COUNT+1..LA_ITEM_NAME.COUNT LOOP
            LA_ITEM_VALUE(I) := NULL;
        END LOOP;
    END IF;
    
    
    L_ARG_NAMES(1) := 'WS_APP_ID';
    L_ARG_VALUES(1) := L(1);
    
    IF L_ALIAS = 'HOME' OR L_ALIAS IS NULL THEN
        FOR C1 IN (SELECT HOME_PAGE_ID
                   FROM WWV_FLOW_WS_APPLICATIONS
                   WHERE ID = L_APP_ID ) 
        LOOP
            L_ARG_NAMES(L_ARG_NAMES.COUNT+1) := 'P900_ID';
            L_ARG_VALUES(L_ARG_VALUES.COUNT+1) := C1.HOME_PAGE_ID;
            L_PAGE_FOUND := TRUE;
            EXIT;
        END LOOP;
    
    ELSIF INSTR(L_ALIAS,'DG_') > 0 THEN
        L_DATA_GRID_ALIAS := SUBSTR(L_ALIAS,4);
        FOR C1 IN (SELECT ID, WORKSHEET_ID
                   FROM WWV_FLOW_WS_WEBSHEET_ATTR
                   WHERE WS_APP_ID = L_APP_ID
                   AND WEBSHEET_ALIAS = L_DATA_GRID_ALIAS
                   AND WEBSHEET_TYPE = 'DATA')
        LOOP
            L_DATA_GRID_FOUND := TRUE;
            L_REDIRECT_PAGE_ID := 2;
            L_ARG_NAMES(L_ARG_NAMES.COUNT+1) := 'P2_ID';
            L_ARG_VALUES(L_ARG_VALUES.COUNT+1) := C1.WORKSHEET_ID;
            L_ARG_NAMES(L_ARG_NAMES.COUNT+1) := 'P2_WEBSHEET_ID';
            L_ARG_VALUES(L_ARG_VALUES.COUNT+1) := C1.ID;
            
            
            FOR I IN 1..LA_ITEM_NAME.COUNT
            LOOP
                IF UPPER(LA_ITEM_NAME(I)) = 'RPT_ID' THEN
                    L_ARG_NAMES(L_ARG_NAMES.COUNT+1) := 'RPT_ID';
                    L_ARG_VALUES(L_ARG_VALUES.COUNT+1) := WWV_FLOW_UTILITIES.ARRAY_ELEMENT(LA_ITEM_VALUE,I);
                    EXIT;
                END IF;
            END LOOP;

            
            FOR I IN 1..LA_ITEM_NAME.COUNT
            LOOP
                IF UPPER(LA_ITEM_NAME(I)) = 'ROW_ID' THEN
                    L_ROW_ID := LA_ITEM_VALUE(I);
                    
                    L_REDIRECT_PAGE_ID := 20;
                    LA_CLEAR_CACHE(1) := 20;
                    
                    L_ARG_NAMES(L_ARG_NAMES.COUNT+1) := 'P20_IR_ID';
                    L_ARG_VALUES(L_ARG_VALUES.COUNT+1) := C1.WORKSHEET_ID;
                    L_ARG_NAMES(L_ARG_NAMES.COUNT+1) := 'P20_DATA_GRID_ID';
                    L_ARG_VALUES(L_ARG_VALUES.COUNT+1) := C1.ID;
                    L_ARG_NAMES(L_ARG_NAMES.COUNT+1) := 'P20_ROW_ID';
                    L_ARG_VALUES(L_ARG_VALUES.COUNT+1) := L_ROW_ID;
                    L_ARG_NAMES(L_ARG_NAMES.COUNT+1) := 'CURRENT_WORKSHEET_ROW';
                    L_ARG_VALUES(L_ARG_VALUES.COUNT+1) := L_ROW_ID;
                    EXIT;
                END IF;
            END LOOP;
            
            
            IF L_REDIRECT_PAGE_ID = 20 THEN
                
                FOR I IN 1..LA_ITEM_NAME.COUNT
                LOOP
                    IF UPPER(LA_ITEM_NAME(I)) = 'LAST_PAGE_ID' THEN
                        L_ARG_NAMES(L_ARG_NAMES.COUNT+1) := 'P20_LAST_PAGE_ID';
                        L_ARG_VALUES(L_ARG_VALUES.COUNT+1) := WWV_FLOW_UTILITIES.ARRAY_ELEMENT(LA_ITEM_VALUE,I);
                        EXIT;
                    END IF;
                END LOOP;
                
                FOR I IN 1..LA_ITEM_NAME.COUNT
                LOOP
                    IF UPPER(LA_ITEM_NAME(I)) = 'LAST_SECTION_ID' THEN
                        L_ARG_NAMES(L_ARG_NAMES.COUNT+1) := 'P20_LAST_SECTION_ID';
                        L_ARG_VALUES(L_ARG_VALUES.COUNT+1) := WWV_FLOW_UTILITIES.ARRAY_ELEMENT(LA_ITEM_VALUE,I);
                        EXIT;
                    END IF;
                END LOOP;
            END IF;
            
            EXIT;
        END LOOP;
        
        
        IF NOT L_DATA_GRID_FOUND THEN
            FOR C1 IN (SELECT ID
                       FROM WWV_FLOW_WS_WEBPAGES
                       WHERE WS_APP_ID = L_APP_ID
                       AND PAGE_ALIAS = L_ALIAS )
            LOOP
                L_ARG_NAMES(L_ARG_NAMES.COUNT+1) := 'P900_ID';
                L_ARG_VALUES(L_ARG_VALUES.COUNT+1) := C1.ID;
                L_PAGE_FOUND := TRUE;
                EXIT;
            END LOOP;
        END IF;
    ELSE
        FOR C1 IN (SELECT ID
                   FROM WWV_FLOW_WS_WEBPAGES
                   WHERE WS_APP_ID = L_APP_ID
                   AND PAGE_ALIAS = L_ALIAS )
        LOOP
            L_ARG_NAMES(L_ARG_NAMES.COUNT+1) := 'P900_ID';
            L_ARG_VALUES(L_ARG_VALUES.COUNT+1) := C1.ID;
            L_PAGE_FOUND := TRUE;
        END LOOP;
    END IF;

    IF L_SESSION IS NULL THEN
        
        FOR C1 IN (SELECT ALLOW_PUBLIC_ACCESS_YN
                   FROM   WWV_FLOW_WS_APPLICATIONS
                   WHERE  ID = L_APP_ID)
        LOOP
           L_ALLOW_PUBLIC_ACCESS_YN := NVL(C1.ALLOW_PUBLIC_ACCESS_YN,'N');
        END LOOP;
    END IF;
    
    IF L_PAGE_FOUND OR L_DATA_GRID_FOUND THEN
        
        
        
        WWV_FLOW.SHOW (
           P_FLOW_ID      => 4900,
           P_FLOW_STEP_ID => L_REDIRECT_PAGE_ID,
           P_INSTANCE     => L_SESSION,
           P_CLEAR_CACHE  => LA_CLEAR_CACHE,
           P_ARG_NAMES    => L_ARG_NAMES,
           P_ARG_VALUES   => L_ARG_VALUES,
           P_DEBUG        => P_DEBUG,
           P_TRACE        => P_TRACE,
           P_TIME_ZONE    => L_TIME_ZONE,
           P_LANG         => P_LANG,
           P_TERRITORY    => P_TERRITORY
           );
    ELSE 
        
        WWV_FLOW.SHOW (
          P_FLOW_ID      => 4900,
          P_FLOW_STEP_ID => 999,
          P_INSTANCE     => L_SESSION,
          P_LANG         => P_LANG,
          P_TERRITORY    => P_TERRITORY
          );
    END IF;
EXCEPTION WHEN OTHERS THEN
     WWV_FLOW_SECURITY.G_SECURITY_GROUP_ID := NULL;
     
     RAISE_APPLICATION_ERROR (-20868,SQLERRM||CHR(10)||SYS.DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END WS;