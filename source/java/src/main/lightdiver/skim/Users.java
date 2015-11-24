package main.lightdiver.skim;

import main.lightdiver.skim.DAO.UsersDAO;
import main.lightdiver.skim.exceptions.BaseNotConnect;
import main.lightdiver.skim.exceptions.ErrorInBase;
import main.lightdiver.skim.exceptions.FileNotRead;
import main.lightdiver.skim.exceptions.InvalidParameter;
import main.lightdiver.skim.model.SessionBean;


import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.servlet.http.HttpServletRequest;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

/**
 * Created by Serj on 06.11.2015.
 */
public class Users {
    private final static Logger logger = Logger.getLogger(Users.class.getName());
    private HttpServletRequest request = (HttpServletRequest) FacesContext.getCurrentInstance().getExternalContext().getRequest();


    public HashMap<String, Object> login(String user_login, String pass){
        HashMap<String, Object> res = null;
        try {
            String ipAddress = request.getHeader("X-FORWARDED-FOR");
            if ( ipAddress == null ) {
                ipAddress = request.getRemoteAddr();
            }

            RequestInfoToLog();//�������� ���� � ���

            res = new UsersDAO().login(user_login, pass, ipAddress, request.getHeader("user-agent"));
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
        } catch (InvalidParameter invalidParameter) {
            invalidParameter.printStackTrace();
        } catch (FileNotRead fileNotRead) {
            fileNotRead.printStackTrace();
        } catch (ErrorInBase errorInBase) {
            errorInBase.printStackTrace();
        }
        return res;
    }
    public static void logout(String user_session, String user_key){
        try {
            new UsersDAO().logout(user_session, user_key);
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
        } catch (FileNotRead fileNotRead) {
            fileNotRead.printStackTrace();
        } catch (InvalidParameter invalidParameter) {
            invalidParameter.printStackTrace();
        } catch (ErrorInBase errorInBase) {
            errorInBase.printStackTrace();
        }
    }

    public String registr(String userLogin, String userPass, String userName, String userEmail, String userSex, String userLang){
        String res = null;
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        try {
            String ipAddress = request.getHeader("X-FORWARDED-FOR");
            if ( ipAddress == null ) {
                ipAddress = request.getRemoteAddr();
            }

            RequestInfoToLog();//�������� ���� � ���
            logger.info("(String)externalContext.getSessionMap().get(\"userSession\") " + (String)externalContext.getSessionMap().get("userSession"));
            logger.info("(String)externalContext.getSessionMap().get(\"userKey\") " + (String)externalContext.getSessionMap().get("userKey"));

            res = new UsersDAO().registr((String)externalContext.getSessionMap().get("userSession"), (String)externalContext.getSessionMap().get("userKey"), ipAddress, userLogin, userPass, userName, userEmail, userSex, userLang);
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
            res = "baseNotConnect";
        } catch (InvalidParameter invalidParameter) {
            invalidParameter.printStackTrace();
            res = "InvalidParameter";
        } catch (FileNotRead fileNotRead) {
            fileNotRead.printStackTrace();
            res = "fileNotRead";
        } catch (ErrorInBase errorInBase) {
            errorInBase.printStackTrace();
            res = "errorInBase";
        }
        return res;
    }

    private void RequestInfoToLog(){
        logger.info("request.getAuthType() " + request.getAuthType());
        logger.info("request.getContextPath() " + request.getContextPath());
        logger.info("request.getMethod()  " + request.getMethod());
        logger.info("request.getPathInfo()  " + request.getPathInfo());
        logger.info("request.getPathTranslated() " + request.getPathTranslated());
        logger.info("request.getQueryString() " + request.getQueryString());
        logger.info("request.getRemoteUser() " + request.getRemoteUser());
        logger.info("request.getRequestedSessionId() " + request.getRequestedSessionId());
        logger.info("request.getRequestURI() " + request.getRequestURI());
        logger.info("request.getServletPath() " + request.getServletPath());
        logger.info("request.getCharacterEncoding() " + request.getCharacterEncoding());
        logger.info("request.getContentType() " + request.getContentType());
        logger.info("request.getLocalAddr() " + request.getLocalAddr());
        logger.info("request.getProtocol() " + request.getProtocol());
        logger.info("request.getRemoteAddr() " + request.getRemoteAddr());
        logger.info("request.getRemoteHost() " + request.getRemoteHost());
        logger.info("request.getServerName() " + request.getServerName());

        logger.info("request.getParameterMap(): " + request.getParameterMap());
        for (Map.Entry<String, String[]> pp : request.getParameterMap().entrySet()) {
            String s =  "getKey() = " + pp.getKey() + " getValue() = ";
            for (int i = 0; i < pp.getValue().length; i++) {
                s = s + pp.getValue()[i] + ";";
            }
            logger.info(s);
        }
        logger.info("getHeader: ");
        Enumeration<String> e = request.getHeaderNames();
        while (e.hasMoreElements()){
            String s = e.nextElement();
            logger.info("e.nextElement() = " + s + " Value = " + request.getHeader(s));
        }
    }



}
