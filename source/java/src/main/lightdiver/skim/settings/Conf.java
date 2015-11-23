package main.lightdiver.skim.settings;

import main.lightdiver.skim.exceptions.FileNotRead;

import javax.faces.context.FacesContext;
import javax.servlet.ServletContext;
import java.io.*;
import java.util.Date;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.LogManager;
import java.util.logging.Logger;

/**
 * Created by Serj on 05.11.2015.
 */
public class Conf {
    private final static Logger logger = Logger.getLogger(Conf.class.getName());
    private static Properties props = new Properties();

    //static String  curDir = new File("").getAbsolutePath();
    //private final static String fileName = /*System.getProperty("user.dir")*/curDir+ File.separator +"settings"+File.separator +"conf.ini";
    //private final InputStream confStream = getClass().getClassLoader().getResourceAsStream("/settings/conf.ini");
    ServletContext servletContext = (ServletContext) FacesContext.getCurrentInstance().getExternalContext().getContext();
    String fileNameConf = servletContext.getRealPath(File.separator + "WEB-INF" + File.separator + "settings"+File.separator + "conf.ini");
    String FileNameConfLog =  servletContext.getRealPath(File.separator + "WEB-INF" + File.separator + "settings"+File.separator + "logging.properties");


    public Conf() throws FileNotRead {
        //Settings for log
        try {
            LogManager.getLogManager().readConfiguration(
                    new FileInputStream(FileNameConfLog));
        } catch (IOException e) {
            e.printStackTrace();
            System.err.println("Could not setup logger configuration: " + e.toString());
        }

        logger.info(String.valueOf(new Date()) + ": Read settings application from " + fileNameConf);

        //Read settings app
        try {
            FileInputStream ins = new FileInputStream(fileNameConf);
            props.load(ins);
        } catch (FileNotFoundException e) {
            logger.log(Level.SEVERE, "Uvaga (FileNotFoundException) ", e);
            throw new FileNotRead(fileNameConf);
        }
        catch (IOException e) {
            logger.log(Level.SEVERE, "Uvaga! (IOException) ", e);
            throw new FileNotRead(fileNameConf);
        }
        catch (Throwable e){
            logger.log(Level.SEVERE, "Uvaga! (Throwable) " , e);
            throw new FileNotRead(fileNameConf);
        }

    }


    public Properties getProps(){
        return props;
    }
}
