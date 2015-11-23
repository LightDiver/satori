

import main.lightdiver.skim.Users;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.logging.LogManager;

/**
 * Created by Serj on 06.11.2015.
 */
public class TestUsers {
    private static HashMap<String, Object> userInfo;
    protected static String userName;
    protected static String userSession;
    protected static String userKey;

    public static void main(String[] args) {
        try {
            /*LogManager.getLogManager().readConfiguration(
                    TestUsers.class.getResourceAsStream("../logging.properties"));
                    */
            LogManager.getLogManager().readConfiguration(
                    new FileInputStream("settings/logging.properties"));
            System.out.println("settings/logging.properties is read...");
        } catch (IOException e) {
            System.err.println("Could not setup logger configuration: " + e.toString());
        }

        userName = "GUEST";
        userInfo = new Users().login("GUEST", "GUEST", "Term_ip", "Term_cl");
        userSession = userInfo.get("session_id").toString();
        userKey = userInfo.get("key_id").toString();

        System.out.println("userName="+userName+" userSession="+userSession+" userKey="+userKey);
    }
}
