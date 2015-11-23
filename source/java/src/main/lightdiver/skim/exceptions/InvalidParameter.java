package main.lightdiver.skim.exceptions;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Created by Serj on 06.11.2015.
 */
public class InvalidParameter  extends Exception {
    private final static Logger logger = Logger.getLogger(InvalidParameter.class.getName());
    private String parameterName;
    public InvalidParameter(String parameterName) {
        this.parameterName = parameterName;
        logger.log(Level.SEVERE, toString());
    }
    public String toString() {
        return "Invalid Parameter " + parameterName;
    }
}
