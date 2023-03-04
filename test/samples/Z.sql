PROCEDURE z (


























    P_URL           VARCHAR2,
    P_CAT           VARCHAR2,
    P_ID            VARCHAR2    DEFAULT NULL,
    P_USER          VARCHAR2    DEFAULT NULL,
    P_COMPANY       VARCHAR2    DEFAULT NULL,
    P_WORKSPACE     VARCHAR2    DEFAULT NULL)
AS
    L_AUTHORIZED_URL        VARCHAR2(32767) := WWV_FLOW_SECURITY.AUTHORIZED_URL (
                                                   P_URL => P_URL );
    L_ID                    NUMBER;
    L_LOG                   WWV_FLOW_CLICKTHRU_LOG$%ROWTYPE;
    L_CURRENT_LOG_NUMBER    NUMBER := 0;
BEGIN
    IF L_AUTHORIZED_URL IS NOT NULL THEN    
        BEGIN
            L_ID                    := TO_NUMBER(P_ID);
            L_LOG.CLICKDATE         := SYSDATE;
            L_LOG.CATEGORY          := UPPER(NVL(P_CAT,SUBSTR(P_URL,1,255)));
            L_LOG.ID                := L_ID;
            L_LOG.FLOW_USER         := P_USER;
            L_LOG.IP                := SYS.OWA_UTIL.GET_CGI_ENV('REMOTE_ADDR');
            L_LOG.SECURITY_GROUP_ID := COALESCE (
                                           P_COMPANY,
                                           P_WORKSPACE );
        EXCEPTION WHEN VALUE_ERROR THEN NULL;
        END;

        IF L_LOG.SECURITY_GROUP_ID IS NOT NULL THEN
            L_CURRENT_LOG_NUMBER := WWV_FLOW_LOG.EVALUATE_CURRENT_LOG_NUMBER (
                                        P_LOG => 'CLICKTHRU' );

            IF L_CURRENT_LOG_NUMBER = 1 THEN
                INSERT INTO WWV_FLOW_CLICKTHRU_LOG$ VALUES L_LOG;
            ELSE
                INSERT INTO WWV_FLOW_CLICKTHRU_LOG2$ VALUES L_LOG;
            END IF;
            COMMIT;
        END IF;
    END IF;

    SYS.OWA_UTIL.REDIRECT_URL(L_AUTHORIZED_URL);
END Z;