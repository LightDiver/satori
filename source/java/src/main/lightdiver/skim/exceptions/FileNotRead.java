package main.lightdiver.skim.exceptions;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Created by Serj on 05.11.2015.
 */
public class FileNotRead extends Exception {
    private final static Logger logger = Logger.getLogger(FileNotRead.class.getName());

    public FileNotRead(String fileName) {
            logger.log(Level.SEVERE, "Uvaga! (inside FileNotRead) " + fileName);
    }

}
