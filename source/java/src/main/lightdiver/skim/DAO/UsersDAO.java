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
public class UsersDAO {//а навіщо такий конструктор?
    private final static Logger logger = Logger.getLogger(UsersDAO.class.getName());
    private static Properties props = null;
    private static Connection con;

    public UsersDAO() throws BaseNotConnect, FileNotRead, InvalidParameter {
        if (props == null) {
            props = new Conf().getProps();
            ConnectionPool.initPool(props);
        }
    }

    public static HashMap<String, Object> login(String user_login, String pass, String terminal_ip, String terminal_client) throws ErrorInBase, BaseNotConnect {
        HashMap<String, Object> res = new HashMap<String, Object>();
        CallableStatement cs = null;
        try {
            con = ConnectionPool.takeConn();
            cs = con.prepareCall("{call pkg_users.login(?, ?, ?, ?, ?, ?, ?, ?, ?)}");


            cs.setString(1, user_login);
            cs.setString(2, pass);
            cs.setString(3, terminal_ip);
            cs.setString(4, terminal_client);
            cs.registerOutParameter(5, Types.NUMERIC);
            cs.registerOutParameter(6, Types.NUMERIC);
            cs.registerOutParameter(7, Types.VARCHAR);
            cs.registerOutParameter(8, Types.VARCHAR);
            cs.registerOutParameter(9, DAO.TypeCursor());
            cs.execute();
        res.put("err_id", DAO.getNumericAsInt(cs, 5));
        if (DAO.getNumericAsInt(cs, 5) != 0){
            res.put("err_text", "Some troubles(Виводити на мові користувача)");
            return res;
        }
        res.put("session_id", cs.getObject(6));
        res.put("key_id", cs.getObject(7));
        res.put("lang_id", cs.getObject(8).toString().equals("UA")?"uk":cs.getObject(8).toString().toLowerCase());


            res.put("is_admin",false);
            res.put("is_editor",false);
            ResultSet rset = (ResultSet)cs.getObject(9);
            while (rset.next ()){
                if(rset.getString(3).equals("ADMIN")){
                    res.put("is_admin",true);
                }
                if(rset.getString(3).equals("EDITOR")){
                    res.put("is_editor",true);
                }
            }

            cs.close();
            return res;
        } catch (SQLException e) {
            logger.log(Level.SEVERE,"Don't login, Critical dbase error", e);
            e.printStackTrace();
            throw new ErrorInBase();
        }
        finally {
            ConnectionPool.putConn(con);
        }

    }
    public void logout(String user_session, String user_key) throws ErrorInBase, BaseNotConnect {
        CallableStatement cs = null;
        try {
            con = ConnectionPool.takeConn();
            cs = con.prepareCall("{? = call pkg_users.logout(?, ?)}");
            cs.registerOutParameter(1, Types.NUMERIC);
            cs.setInt(2, Integer.parseInt(user_session));
            cs.setString(3, user_key);
            cs.execute();
            cs.close();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Don't logout", e);
            e.printStackTrace();
            throw new ErrorInBase();
        }
        finally {
            ConnectionPool.putConn(con);
        }
    }
    public String registr(String userSession, String userKey, String ipAddress, String userLogin, String userPass, String userName, String userEmail, String userSex, String userLang) {
        CallableStatement cs;
        String res = null;
     try {
         con = ConnectionPool.takeConn();
         cs = con.prepareCall("{? = call pkg_users.registr(?, ?, ?, ?, ?, ?, ?, ?, ?)}");
         cs.registerOutParameter(1, Types.NUMERIC);
         cs.setInt(2, Integer.parseInt(userSession));
         cs.setString(3, userKey);
         cs.setString(4, ipAddress);
         cs.setString(5, userLogin);
         cs.setString(6, userPass);
         cs.setString(7, userName);
         cs.setString(8, userEmail);
         cs.setString(9, userSex);
         cs.setString(10, userLang);
         cs.execute();
         if (DAO.getNumericAsInt(cs,1) != 0) {
             res = "Some troubles: "+ DAO.getNumericAsInt(cs, 1) + "-" + SystemInfoDAO.getDescError(DAO.getNumericAsInt(cs, 1), "UA");
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
        finally {
         ConnectionPool.putConn(con);
     }
        return res;
    }

    public static int isUserExist(String userLogin) throws BaseNotConnect {
        CallableStatement cs;
        try {
            int res;
            con = ConnectionPool.takeConn();
            cs = con.prepareCall("{? = call pkg_users.is_user_exist(?)}");
            cs.registerOutParameter(1, Types.NUMERIC);
            cs.setString(2, userLogin);
            cs.execute();
            res = DAO.getNumericAsInt(cs,1);
            cs.close();
            return res;
        } catch (SQLException e) {
            logger.severe("" + e);
            e.printStackTrace();
            return 1;//Тіпа завжди є
        }
        finally {
            ConnectionPool.putConn(con);
        }
    }
    public static List<UsersAction> getUsersAction(String userSession, String userKey, String ipAddress, Date startDate, Date endDate, Integer userId, Integer isSuccess) throws BaseNotConnect {
        List<UsersAction> usersActionList = new ArrayList<>();
        CallableStatement cs;
        try {
            con = ConnectionPool.takeConn();
            cs = con.prepareCall("{call pkg_users.list_users_action(?,?,?,?,?,?,?,?,?)}");

            cs.setInt(1, Integer.parseInt(userSession));
            cs.setString(2, userKey);
            cs.setString(3, ipAddress);
            cs.setDate(4,startDate);
            cs.setDate(5,endDate);
            if(userId==null) cs.setNull(6,Types.INTEGER); else cs.setInt(6,userId);
            //System.out.println("isSuccess="+isSuccess);
            if(isSuccess==null) cs.setNull(7,Types.INTEGER) ;else cs.setInt(7, isSuccess);
            cs.registerOutParameter(8, Types.NUMERIC);
            cs.registerOutParameter(9, DAO.TypeCursor());
            cs.execute();
            if (DAO.getNumericAsInt(cs,8) != 0){
                logger.severe("Refused execute getUsersAction (session= "+userSession+";key="+userKey+")" + "error code:"+DAO.getNumericAsInt(cs, 8));
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
        finally {
            ConnectionPool.putConn(con);
        }
        return usersActionList;
    }

    public List<UserEntity> getUsersList(String userSession, String userKey, String ipAddress) throws BaseNotConnect {
        List<UserEntity> usersList = new ArrayList<>();

        CallableStatement cs;
        try {
            con = ConnectionPool.takeConn();
            cs = con.prepareCall("{call pkg_users.list_users(?,?,?,?,?)}");

            cs.setInt(1, Integer.parseInt(userSession));
            cs.setString(2, userKey);
            cs.setString(3, ipAddress);
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.registerOutParameter(5, DAO.TypeCursor());
            cs.execute();
            if (DAO.getNumericAsInt(cs,4) != 0){
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
        finally {
            ConnectionPool.putConn(con);
        }
        return usersList;
    }

    public int checkUserSessActive(String userSession, String userKey, String ipAddress, int action) throws BaseNotConnect {
        int res = -1;
        CallableStatement cs;
        try {
            con = ConnectionPool.takeConn();
            cs = con.prepareCall("{? = call pkg_users.check_user_sess_active(?,?,?,?)}");
            cs.registerOutParameter(1, Types.NUMERIC);
            cs.setInt(2, Integer.parseInt(userSession));
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.setInt(5, action);
            cs.execute();
            res = DAO.getNumericAsInt(cs,1);
            cs.close();
        } catch (SQLException e) {
            e.printStackTrace();
            logger.severe("" + e);
        }
        finally {
            ConnectionPool.putConn(con);
        }
        return res;
    }

    public UserEntity getUserInfoBySess(String userSession, String userKey, String ipAddress) throws BaseNotConnect {
        UserEntity user = null;
        CallableStatement cs;
        try {
            con = ConnectionPool.takeConn();
            cs = con.prepareCall("{call pkg_users.user_info(?,?,?,?,?,?,?,?,?,?,?,?,?)}");
            cs.setInt(1, Integer.parseInt(userSession));
            cs.setString(2, userKey);
            cs.setString(3, ipAddress);
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.registerOutParameter(5,Types.NUMERIC);
            cs.registerOutParameter(6,Types.VARCHAR);
            cs.registerOutParameter(7,Types.VARCHAR);
            cs.registerOutParameter(8,Types.VARCHAR);
            cs.registerOutParameter(9,Types.VARCHAR);
            cs.registerOutParameter(10,Types.TIMESTAMP);
            cs.registerOutParameter(11,Types.VARCHAR);
            cs.registerOutParameter(12,Types.VARCHAR);
            cs.registerOutParameter(13, DAO.TypeCursor());

            cs.execute();

            if (DAO.getNumericAsInt(cs,4) == 0){
                user = new UserEntity();

                user.setUserId(DAO.getNumericAsInt(cs, 5));
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
                    //System.out.println(rset.getString(3) + ":" + rset.getString(2));
                    userR.put(rset.getString(3), rset.getString(2));
                }
                user.setUserRoles(userR);
            }
            else {
                logger.severe("Refused getUserInfoBySess error_id="+DAO.getNumericAsInt(cs, 4));
            }

            cs.close();

        } catch (SQLException e) {
            e.printStackTrace();
        }
        finally {
            ConnectionPool.putConn(con);
        }
        return user;
    }

}