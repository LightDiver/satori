package main.lightdiver.skim.DAO;

import oracle.jdbc.OracleTypes;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.Types;

public class DAO {
    public static int getNumericAsInt(CallableStatement cs, int parameterIndex) throws SQLException {
        final BigDecimal bigDecimal = cs.getBigDecimal(parameterIndex);
        if (bigDecimal == null) return 0;
        return bigDecimal.intValue();
    }

    public static int TypeCursor(){
        if (ConnectionPool.getRdbms().equals("Oracle")){
            return OracleTypes.CURSOR;
        }
        else
        {
            return Types.OTHER;
        }
    }

    public static int TypeCLOB(){
        if (ConnectionPool.getRdbms().equals("Oracle")){
            return Types.CLOB;
        }
        else
        {
            return Types.VARCHAR;
        }
    }

}
