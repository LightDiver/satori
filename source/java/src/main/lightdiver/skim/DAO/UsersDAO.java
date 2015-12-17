package main.lightdiver.skim.DAO;

import main.lightdiver.skim.entity.UserEntity;
import main.lightdiver.skim.entity.UsersAction;
import main.lightdiver.skim.exceptions.BaseNotConnect;
import main.lightdiver.skim.exceptions.ErrorInBase;
import main.lightdiver.skim.exceptions.FileNotRead;
import main.lightdiver.skim.exceptions.InvalidParameter;
import main.lightdiver.skim.settings.Conf;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Created by Serj on 05.11.2015.
 */
public class UsersDAO {
    private final static Logger logger = Logger.getLogger(UsersDAO.class.getName());
    private static Properties props = null;
    private static Connection con;
    private static ConnectionPool cp;

    public UsersDAO() throws BaseNotConnect, FileNotRead, InvalidParameter {
        if (props == null) {
            props = new Conf().getProps();
            this.cp = new ConnectionPool(props);
            this.con = cp.OpenConnect();
        }
    }

    public static HashMap<String, Object> login(String user_login, String pass, String terminal_ip, String terminal_client) throws ErrorInBase {
        HashMap<String, Object> res = new HashMap<String, Object>();
        CallableStatement cs = null;
        try {
            cs = con.prepareCall("{? = call pkg_users.login(?, ?, ?, ?, ?, ?, ?, ?)}");

        cs.registerOutParameter(1, Types.INTEGER);
        cs.setString(2, user_login);
        cs.setString(3, pass);
        cs.setString(4, terminal_ip);
        cs.setString(5, terminal_client);
        cs.registerOutParameter(6, Types.VARCHAR);
        cs.registerOutParameter(7, Types.VARCHAR);
        cs.registerOutParameter(8, Types.VARCHAR);
        cs.registerOutParameter(9, cp.TypeCursor());
        cs.execute();
        res.put("err_id", cs.getObject(1));
        if (cs.getInt(1) != 0){
            res.put("err_text", "Some troubles(Виводити на мові користувача)");
            return res;
        }
        res.put("session_id", cs.getObject(6));
        res.put("key_id", cs.getObject(7));
        res.put("lang_id", cs.getObject(8).toString().equals("UA")?"uk":cs.getObject(8).toString().toLowerCase());

        res.put("is_admin",false);
        ResultSet rset = (ResultSet)cs.getObject(9);
        while (rset.next ()){
            if(rset.getString(3).equals("ADMIN")){
                res.put("is_admin",true);
            }
        }
            cs.close();
            return res;
        } catch (SQLException e) {
            logger.log(Level.SEVERE,"Don't login, Critical dbase error", e);
            e.printStackTrace();
            throw new ErrorInBase();
        }

    }
    public void logout(String user_session, String user_key) throws ErrorInBase {
        CallableStatement cs = null;
        try {
            cs = con.prepareCall("{? = call pkg_users.logout(?, ?)}");
            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, user_session);
            cs.setString(3, user_key);
            cs.execute();
            cs.close();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Don't logout", e);
            e.printStackTrace();
            throw new ErrorInBase();
        }
    }
    public String registr(String userSession, String userKey, String ipAddress, String userLogin, String userPass, String userName, String userEmail, String userSex, String userLang) {
        CallableStatement cs;
        String res = null;
     try {
         cs = con.prepareCall("{? = call pkg_users.registr(?, ?, ?, ?, ?, ?, ?, ?, ?)}");
         cs.registerOutParameter(1, Types.INTEGER);
         cs.setString(2, userSession);
         cs.setString(3, userKey);
         cs.setString(4, ipAddress);
         cs.setString(5, userLogin);
         cs.setString(6, userPass);
         cs.setString(7, userName);
         cs.setString(8, userEmail);
         cs.setString(9, userSex);
         cs.setString(10, userLang);
         cs.execute();
         if (cs.getInt(1) != 0) {
             res = "Some troubles: "+ cs.getInt(1) + "-" + SystemInfoDAO.getDescError(cs.getInt(1), "UA");
         }
         cs.close();

     }catch (SQLException e) {
         logger.log(Level.SEVERE, "Don't register", e);
         e.printStackTrace();
         res = "SQLException";
     } catch (BaseNotConnect baseNotConnect) {
         baseNotConnect.printStackTrace();
         res = "baseNotConnect";
     }
        return res;
    }

    public static int isUserExist(String userLogin) {
        CallableStatement cs;
        try {
            int res;
            cs = con.prepareCall("{? = call pkg_users.is_user_exist(?)}");
            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userLogin);
            cs.execute();
            res = cs.getInt(1);
            cs.close();
            return res;
        } catch (SQLException e) {
            logger.severe("" + e);
            e.printStackTrace();
            return 1;//Тіпа завжди є
        }
    }
    public static List<UsersAction> getUsersAction(String userSession, String userKey, String ipAddress, Date startDate, Date endDate, Integer userId, Integer isSuccess){
        List<UsersAction> usersActionList = new ArrayList<>();
        CallableStatement cs;
        try {
            cs = con.prepareCall("{? = call pkg_users.list_users_action(?,?,?,?,?,?,?,?)}");
            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.setDate(5,startDate);
            cs.setDate(6,endDate);
            if(userId==null) cs.setNull(7,Types.INTEGER); else cs.setInt(7,userId);
            //System.out.println("isSuccess="+isSuccess);
            if(isSuccess==null) cs.setNull(8,Types.INTEGER) ;else cs.setInt(8, isSuccess);
            cs.registerOutParameter(9, cp.TypeCursor());
            cs.execute();
            if (cs.getInt(1) != 0){
                logger.severe("Refused execute getUsersAction (session= "+userSession+";key="+userKey+")");
            }
            ResultSet rset = (ResultSet)cs.getObject(9);
            while (rset.next ()){
                UsersAction usersAction = new UsersAction();
                usersAction.setUserId(rset.getInt(1));
                usersAction.setUserName(rset.getString(2));
                usersAction.setUserState(rset.getString(3));
                usersAction.setUserTerminalIP(rset.getString(4));
                usersAction.setUserTerminalClient(rset.getString(5));
                usersAction.setUserLastActionDate(rset.getTimestamp(6));
                usersAction.setUserLastActionName(rset.getString(7));
                usersAction.setUserRegistSessionDate(rset.getTimestamp(8));
                usersAction.setUserLastActionStatusName(rset.getString(9));

                usersActionList.add(usersAction);

            }
            cs.close();

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return usersActionList;
    }

    public List<UserEntity> getUsersList(String userSession, String userKey, String ipAddress){
        List<UserEntity> usersList = new ArrayList<>();

        CallableStatement cs;
        try {
            cs = con.prepareCall("{? = call pkg_users.list_users(?,?,?,?)}");
            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.registerOutParameter(5, cp.TypeCursor());
            cs.execute();
            if (cs.getInt(1) != 0){
                logger.severe("Refused execute getUsersList (session= "+userSession+";key="+userKey+")");
            }
            ResultSet rset = (ResultSet)cs.getObject(5);
            while (rset.next ()){
                UserEntity user = new UserEntity();
                user.setUserId(rset.getInt(1));
                user.setUserLogin(rset.getString(2));
                user.setUserName(rset.getString(3));
                user.setUserEMail(rset.getString(4));
                user.setUserState(rset.getString(5));
                user.setUserLang(rset.getString(6));
                user.setUserRegDate(rset.getTimestamp(7));
                usersList.add(user);

            }
            cs.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return usersList;
    }

    public int checkUserSessActive(String userSession, String userKey, String ipAddress, int action){
        int res = -1;
        CallableStatement cs;
        try {
            cs = con.prepareCall("{? = call pkg_users.active_session(?,?,?,?)}");
            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.setInt(5, action);
            cs.execute();
            res = cs.getInt(1);
            cs.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return res;
    }

    public UserEntity getUserInfoBySess(String userSession, String userKey, String ipAddress){
        UserEntity user = null;
        CallableStatement cs;
        try {
            cs = con.prepareCall("{? = call pkg_users.user_info(?,?,?,?,?,?,?,?,?,?,?,?)}");
            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.registerOutParameter(5,Types.INTEGER);
            cs.registerOutParameter(6,Types.VARCHAR);
            cs.registerOutParameter(7,Types.VARCHAR);
            cs.registerOutParameter(8,Types.VARCHAR);
            cs.registerOutParameter(9,Types.VARCHAR);
            cs.registerOutParameter(10,Types.TIMESTAMP);
            cs.registerOutParameter(11,Types.VARCHAR);
            cs.registerOutParameter(12,Types.VARCHAR);
            cs.registerOutParameter(13,cp.TypeCursor());

            cs.execute();

            if (cs.getInt(1) == 0){
                user = new UserEntity();

                user.setUserId(cs.getInt(5));
                user.setUserLogin(cs.getString(6));
                user.setUserName(cs.getString(7));
                user.setUserEMail(cs.getString(8));
                user.setUserState(cs.getString(9));
                user.setUserRegDate(cs.getTimestamp(10));
                user.setUserSex(cs.getString(11));
                user.setUserLang(cs.getString(12));


                HashMap<String, String> userR = new HashMap<>();
                ResultSet rset = (ResultSet)cs.getObject(13);
                while (rset.next ()){
                    userR.put(rset.getString(3), rset.getString(2));
                }
                user.setUserRoles(userR);
            }
            else {
                logger.severe("Refused getUserInfoBySess error_id="+cs.getInt(1));
            }

            cs.close();

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }

}