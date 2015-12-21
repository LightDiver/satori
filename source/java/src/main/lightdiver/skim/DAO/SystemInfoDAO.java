package main.lightdiver.skim.DAO;

import main.lightdiver.skim.exceptions.BaseNotConnect;

import java.sql.*;
import java.util.HashMap;
import java.util.logging.Logger;

/**
 * Created by Serj on 01.12.2015.
 */
public class SystemInfoDAO {
    private final static Logger logger = Logger.getLogger(SystemInfoDAO.class.getName());

    public static String getDescError(Integer error_id, String lang) throws BaseNotConnect {
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        try {
            cs = con.prepareCall("{? = call pkg_systeminfo.get_description_error(?, ?)}");

            cs.registerOutParameter(1, Types.VARCHAR);
            cs.setInt(2, error_id);
            cs.setString(3, lang);
            cs.execute();
            return cs.getString(1);
        } catch (SQLException e) {
            e.printStackTrace();
            logger.severe("Don't read description error from base: " + e);
            return "Don't read description error from base";
        }

    }

    public static HashMap<String, String> getLangs() throws BaseNotConnect {
        HashMap<String, String> langs = new HashMap<>();
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        try {
            cs = con.prepareCall("{? = call pkg_systeminfo.get_langs()}");

            cs.registerOutParameter(1, ConnectionPool.TypeCursor());
            cs.execute();

            ResultSet rset = (ResultSet)cs.getObject(1);
            while (rset.next ()){
                langs.put(rset.getString(1), rset.getString(2));
                //System.out.println(rset.getString(1) + "|" + rset.getString(2));
            }
            //System.out.println(langs.size());
        } catch (SQLException e) {
            e.printStackTrace();
            logger.severe("Don't read description error from base: " + e);
            return null;
        }
        return langs;
    }

}
