package main.lightdiver.skim.exceptions;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Created by Serj on 09.11.2015.
 */
public class ErrorInBase extends Exception {
    private final static Logger logger = Logger.getLogger(ErrorInBase.class.getName());

    public ErrorInBase() {
        logger.log(Level.SEVERE, "Uvaga! (inside ErrorInBase) ");
    }

}