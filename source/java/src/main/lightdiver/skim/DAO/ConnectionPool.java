package main.lightdiver.skim.DAO;

import main.lightdiver.skim.exceptions.*;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Types;
import java.util.HashSet;
import java.util.Properties;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.logging.Logger;
import oracle.jdbc.OracleTypes;

/**
 * Created by Serj on 05.11.2015.
 */
public class ConnectionPool {
    private final static Logger logger = Logger.getLogger(ConnectionPool.class.getName());
    private static ConnectionPool connectionPool = null;

    private  String urlstr;
    private static String rdbms;

    private  String  DBDriver;
    private  String  DBTypeConn;
    private  String  DBBase;
    private  String  DBUser;
    private  String  DBPassword;
    private  String  DBHost;
    private  String  DBPort;

    private int maxOpenedConnectionsCount;

    private int openedConnectionsCount;
    private LinkedBlockingQueue<Connection> connections;
    private HashSet<Connection> openedConnections;



    public static ConnectionPool initPool(Properties props) throws InvalidParameter {
        //Якщо вже заініціалізовано то помилку?
        connectionPool = new ConnectionPool(props);
        return connectionPool;
    }

    public ConnectionPool() throws BaseNotConnect {
        if (urlstr == null){
            throw new BaseNotConnect();
        }
    }

    private ConnectionPool(Properties props) throws InvalidParameter {
        DBBase = props.getProperty("DBBase");
        DBUser = props.getProperty("DBUser");
        DBPassword = props.getProperty("DBPassword");
        DBHost = props.getProperty("DBHost");
        DBPort = props.getProperty("DBPort");

        maxOpenedConnectionsCount = Integer.parseInt(props.getProperty("maxConnect"));

        connections = new LinkedBlockingQueue<>(maxOpenedConnectionsCount);
        openedConnections = new HashSet<>();


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

    private Connection openConnect() throws BaseNotConnect {
        try {
            Class.forName(DBDriver);
            Connection connection = DriverManager.getConnection(urlstr, DBUser, DBPassword);
            if (rdbms.equals("Postgresql")){
                connection.setAutoCommit(false);
            }
            openedConnections.add(connection);
            openedConnectionsCount ++;
            return connection;
        } catch (SQLException e) {
            logger.info(e.getMessage());
            throw new BaseNotConnect();
        } catch (ClassNotFoundException e) {
            logger.info(e.getMessage());
            throw new BaseNotConnect();
        }

    }

    public synchronized static Connection takeConn() throws BaseNotConnect {
        if (connectionPool == null) return null;//можливо помилка?
        return connectionPool.take();
    }
    public synchronized static void putConn(Connection connection){
        if(connectionPool != null && connection != null) connectionPool.put(connection);
        //а якщо ні?
    }

    private Connection take() throws BaseNotConnect {
        Connection connection = null;
        if(connections.size() > 0 || openedConnectionsCount >= maxOpenedConnectionsCount)
            try {
                connection = connections.take();//якщо там пусто?
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        else
            connection = openConnect();
        return connection;
    }

    private void put(Connection connection){
        try {
            if(connection != null && !connection.isClosed()){
                connection.commit();
                connections.put(connection);//якщо більше ініціалзованого максимального?
            } else {
                if (openedConnections.remove(connection)) openedConnectionsCount --;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
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
