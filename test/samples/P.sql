PROCEDURE p ( N           IN VARCHAR2 DEFAULT NULL,
                                P_MIME_TYPE IN VARCHAR2 DEFAULT NULL,
                                P_INLINE    IN VARCHAR2 DEFAULT 'NO' ) AS





















BEGIN
     IF N IS NULL THEN
         SYS.HTP.P(WWV_FLOW_LANG.SYSTEM_MESSAGE('p.valid_page_err'));
         RETURN;
     END IF;
     
     WWV_FLOW_FILE_MGR.GET_FILE (
        P_ID => N,
        P_MIME_TYPE => P_MIME_TYPE,
        P_INLINE => P_INLINE);
END P;