package main.lightdiver.skim.DAO;

import main.lightdiver.skim.exceptions.BaseNotConnect;
import main.lightdiver.skim.exceptions.ErrorInBase;
import main.lightdiver.skim.exceptions.FileNotRead;
import main.lightdiver.skim.exceptions.InvalidParameter;
import main.lightdiver.skim.settings.Conf;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;
import java.util.HashMap;
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

    public HashMap<String, Object> login(String user_login, String pass, String terminal_ip, String terminal_client) throws ErrorInBase {
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
        res.put("session_id", cs.getObject(6));
        res.put("key_id", cs.getObject(7));
        res.put("lang_id", cs.getObject(8));
        res.put("err_id", cs.getObject(1));
        if (cs.getInt(1) != 0){
            res.put("err_text", "Some troubles(Виводити на мові користувача)");
        }
        } catch (SQLException e) {
            logger.log(Level.SEVERE,"Don't login, Critical dbase error", e);
            e.printStackTrace();
            throw new ErrorInBase();
        }
        return res;
    }
    public void logout(String user_session, String user_key) throws ErrorInBase {
        CallableStatement cs = null;
        try {
            cs = con.prepareCall("{? = call pkg_users.logout(?, ?)}");
            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, user_session);
            cs.setString(3, user_key);
            cs.execute();
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

    public static int isUserExist(String userLogin){
        CallableStatement cs;
        try {
            cs = con.prepareCall("{? = call pkg_users.is_user_exist(?)}");
            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2,userLogin);
            cs.execute();
            return cs.getInt(1);
        } catch (SQLException e) {
            logger.severe("" + e);
            e.printStackTrace();
            return 1;//Тіпа завжди є
        }

    }


}