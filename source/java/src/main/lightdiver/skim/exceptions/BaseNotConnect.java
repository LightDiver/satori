package main.lightdiver.skim.exceptions;

import java.util.logging.Logger;

/**
 * Created by Serj on 06.11.2015.
 */
public class BaseNotConnect extends Throwable {
    private final static Logger logger = Logger.getLogger(BaseNotConnect.class.getName());
    public BaseNotConnect() {
        logger.severe(toString());
    }
    public String toString() {
        return "Connection Failed!";
    }
}

