PROCEDURE apex (
    P_SESSION IN NUMBER DEFAULT NULL)
AS
    C_LANDING_PAGE_OVERRIDE CONSTANT WWV_FLOW_PLATFORM_PREFS.VALUE%TYPE := WWV_FLOW_PLATFORM.GET_PREFERENCE('LANDING_PAGE_OVERRIDE');
    L_USER                  VARCHAR2(4000);
    L_SESSION               NUMBER;
BEGIN
    IF WWV_FLOW_CGI.GET_HTTP_REFERER LIKE '%p_done_url%'
       AND WWV_FLOW_CGI.GET_HTTP_ACCEPT LIKE 'image%'
    THEN
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        WWV_FLOW_DEBUG.WARN('image request for apex procedure from SSO logout - exiting');
        WWV_FLOW_DEBUG.FLUSH_CACHE;
        SYS.HTP.P('Unsupported image request for APEX procedure from SSO logout');
        RETURN;
    END IF;

    IF C_LANDING_PAGE_OVERRIDE IS NOT NULL THEN
        SYS.OWA_UTIL.REDIRECT_URL(C_LANDING_PAGE_OVERRIDE);
    ELSE
        WWV_FLOW_SECURITY.SESSION_COOKIE_INFO_INTERNAL(
            P_USER    => L_USER,
            P_SESSION => L_SESSION,
            P_SGID    => WWV_FLOW_SECURITY.G_SECURITY_GROUP_ID);

        IF L_SESSION IS NOT NULL THEN
            IF WWV_FLOW_ISC.VC THEN
                
                
                IF P_SESSION IS NOT NULL OR WWV_FLOW_ISC.DEPLOYMENT_ENVIRONMENT THEN
                    L_SESSION := P_SESSION;
                END IF;
                WWV_FLOW.SHOW(P_INSTANCE=>L_SESSION,P_FLOW_STEP_ID=>'1000',P_FLOW_ID=>'4500');
                RETURN;
            ELSE
                
                WWV_FLOW.SHOW(P_INSTANCE=>P_SESSION,P_FLOW_STEP_ID=>'3',P_FLOW_ID=>'4050');
            END IF;
        ELSE
            
            WWV_FLOW_SECURITY.G_SECURITY_GROUP_ID := NULL;
            WWV_FLOW.SHOW(P_INSTANCE=>P_SESSION,P_FLOW_STEP_ID=>'1000',P_FLOW_ID=>'4500');
        END IF;
    END IF;
EXCEPTION WHEN OTHERS THEN
    WWV_FLOW_SECURITY.G_SECURITY_GROUP_ID := NULL;
END APEX;