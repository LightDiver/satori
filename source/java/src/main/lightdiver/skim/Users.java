package main.lightdiver.skim;

import main.lightdiver.skim.DAO.UsersDAO;
import main.lightdiver.skim.entity.UserEntity;
import main.lightdiver.skim.entity.UsersAction;
import main.lightdiver.skim.exceptions.BaseNotConnect;
import main.lightdiver.skim.exceptions.ErrorInBase;
import main.lightdiver.skim.exceptions.FileNotRead;
import main.lightdiver.skim.exceptions.InvalidParameter;


import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.servlet.http.HttpServletRequest;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

/**
 * Created by Serj on 06.11.2015.
 */
public class Users {
    private final static Logger logger = Logger.getLogger(Users.class.getName());

    public static HashMap<String, Object> login(String user_login, String pass) throws FileNotRead, InvalidParameter, BaseNotConnect, ErrorInBase {
        HashMap<String, Object> res = null;
        HttpServletRequest request = (HttpServletRequest) FacesContext.getCurrentInstance().getExternalContext().getRequest();
        String ipAddress = getIP();

            //RequestInfoToLog();//�������� ���� � ���

            res = new UsersDAO().login(user_login, pass, ipAddress, request.getHeader("user-agent"));

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

    public static String registr(String userLogin, String userPass, String userName, String userEmail, String userSex, String userLang){
        String res = null;
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        try {
            String ipAddress = getIP();

            //RequestInfoToLog();//�������� ���� � ���
            logger.info("(String)externalContext.getSessionMap().get(\"userSession\") " + (String)externalContext.getSessionMap().get("userSession"));
            logger.info("(String)externalContext.getSessionMap().get(\"userKey\") " + (String)externalContext.getSessionMap().get("userKey"));

            res = new UsersDAO().registr((String)externalContext.getSessionMap().get("userSession"), (String)externalContext.getSessionMap().get("userKey"), ipAddress, userLogin, userPass, userName, userEmail, userSex, userLang);
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
            res = "BaseNotConnect";
        } catch (InvalidParameter invalidParameter) {
            invalidParameter.printStackTrace();
            res = "InvalidParameter";
        } catch (FileNotRead fileNotRead) {
            fileNotRead.printStackTrace();
            res = "FileNotRead";
        }
        return res;
    }

    public static List<UsersAction> getUsersAction(Date startDate, Date endDate, Integer userId, Integer isSuccess) throws FileNotRead, InvalidParameter, BaseNotConnect {
        //System.out.println("isSuccess="+isSuccess);
        List<UsersAction> usersActionList = null;
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        String ipAddress = getIP();
        usersActionList = new UsersDAO().getUsersAction((String)externalContext.getSessionMap().get("userSession"), (String)externalContext.getSessionMap().get("userKey"), ipAddress, new java.sql.Date(startDate.getTime()), new java.sql.Date(endDate.getTime()), userId, isSuccess);

        return usersActionList;
    }

    public static List<UserEntity> getUsersList(){
        List<UserEntity> usersList = null;
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        String ipAddress = getIP();
        try {
            usersList = new UsersDAO().getUsersList((String)externalContext.getSessionMap().get("userSession"), (String)externalContext.getSessionMap().get("userKey"), ipAddress);
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
        } catch (FileNotRead fileNotRead) {
            fileNotRead.printStackTrace();
        } catch (InvalidParameter invalidParameter) {
            invalidParameter.printStackTrace();
        }
        return usersList;
    }

    public static int checkUserSessActive(String userSession, String userKey, int action) throws FileNotRead, InvalidParameter, BaseNotConnect {
        String ipAddress = getIP();
        return new UsersDAO().checkUserSessActive(userSession, userKey, ipAddress, action);
    }

    public static UserEntity getUserInfoBySess(String userSession, String userKey){
        UserEntity user = null;
        String ipAddress = getIP();
        try {
            user = new UsersDAO().getUserInfoBySess(userSession, userKey, ipAddress);
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
            logger.severe("baseNotConnect");
        } catch (FileNotRead fileNotRead) {
            fileNotRead.printStackTrace();
            logger.severe("fileNotRead");
        } catch (InvalidParameter invalidParameter) {
            invalidParameter.printStackTrace();
            logger.severe("invalidParameter");
        }catch (Throwable e){
            logger.severe("Throwable." + e);
        }

        return user;
    }

    private static String getIP(){
        HttpServletRequest request = (HttpServletRequest) FacesContext.getCurrentInstance().getExternalContext().getRequest();
        String ipAddress = request.getHeader("X-FORWARDED-FOR");
        if ( ipAddress == null ) {
            ipAddress = request.getRemoteAddr();
        }
        return ipAddress;
    }

    private void RequestInfoToLog(){
        HttpServletRequest request = (HttpServletRequest) FacesContext.getCurrentInstance().getExternalContext().getRequest();
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
