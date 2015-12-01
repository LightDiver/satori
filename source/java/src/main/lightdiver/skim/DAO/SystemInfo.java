package main.lightdiver.skim.DAO;

import main.lightdiver.skim.exceptions.BaseNotConnect;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;
import java.util.logging.Logger;

/**
 * Created by Serj on 01.12.2015.
 */
public class SystemInfo {
    private final static Logger logger = Logger.getLogger(SystemInfo.class.getName());

    public static String getDescError(Integer error_id, String lang) throws BaseNotConnect {
        Connection con = ConnectionPool.OpenConnect();
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
}
