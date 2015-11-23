package main.lightdiver.skim.DAO;

import main.lightdiver.skim.exceptions.*;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Types;
import java.util.Properties;
import java.util.logging.Logger;
import oracle.jdbc.OracleTypes;

/**
 * Created by Serj on 05.11.2015.
 */
public class ConnectionPool {
    private final static Logger logger = Logger.getLogger(ConnectionPool.class.getName());
    private static String urlstr;
    private static String rdbms;

    private static String  DBDriver;
    private static String  DBTypeConn;
    private static String  DBBase;
    private static String  DBUser;
    private static String  DBPassword;
    private static String  DBHost;
    private static String  DBPort;


    public ConnectionPool(Properties props) throws InvalidParameter {
        DBBase = props.getProperty("DBBase");
        DBUser = props.getProperty("DBUser");
        DBPassword = props.getProperty("DBPassword");
        DBHost = props.getProperty("DBHost");
        DBPort = props.getProperty("DBPort");

        switch (props.getProperty("DBType").toLowerCase()) {
            case "oracle.thin":
                rdbms = "Oracle";
                DBDriver = "oracle.jdbc.driver.OracleDriver";
                DBTypeConn = "jdbc:oracle:thin";
                urlstr = DBTypeConn + ":@" + DBHost + ":" +
                        DBPort + ":" + DBBase;
                break;
            case "oracle.oci8":
                rdbms = "Oracle";
                DBDriver = "oracle.jdbc.driver.OracleDriver";
                DBTypeConn = "jdbc:oracle:oci8";
                urlstr = DBTypeConn + ":@" + DBBase;
                break;
            case "postgresql":
                rdbms = "Postgresql";
                DBDriver = "org.postgresql.Driver";
                DBTypeConn = "jdbc:postgresql";
                urlstr = DBTypeConn + "://" + DBHost + ":" +
                        DBPort + "/" + DBBase;
                break;
            default: throw new InvalidParameter("DBType");}
        }

    public static Connection OpenConnect() throws BaseNotConnect {
        try {
            Class.forName(DBDriver);
            Connection connection = DriverManager.getConnection(urlstr,DBUser,DBPassword);
            if (rdbms.equals("Postgresql")){
                connection.setAutoCommit(false);
            }
            return connection;
        } catch (SQLException e) {
            logger.info(e.getMessage());
            throw new BaseNotConnect();
        } catch (ClassNotFoundException e) {
            logger.info(e.getMessage());
            throw new BaseNotConnect();
        }

    }

    public static String getRdbms(){
        return rdbms;
    }

    public static int TypeCursor(){
        if (rdbms.equals("Oracle")){
            return OracleTypes.CURSOR;
        }
        else
        {
            return Types.OTHER;
        }
    }

}
