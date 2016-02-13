package main.lightdiver.skim.DAO;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.SQLException;

public class DAO {
    public static int getNumericAsInt(CallableStatement cs, int parameterIndex) throws SQLException {
        final BigDecimal bigDecimal = cs.getBigDecimal(parameterIndex);
        if (bigDecimal == null) return 0;
        return bigDecimal.intValue();
    }

}
