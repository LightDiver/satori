package main.lightdiver.skim.entity;

import java.util.Date;

/**
 * Created by Serj on 10.12.2015.
 */
public class UsersAction {
    Integer userId;
    String userName;
    String userState;
    String userTerminalIP;
    String userTerminalClient;
    Date userLastActionDate;
    String userLastActionName;
    Date userRegistSessionDate;
    String userLastActionStatusName;

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public void setUserState(String userState) {
        this.userState = userState;
    }

    public void setUserTerminalIP(String userTerminalIP) {
        this.userTerminalIP = userTerminalIP;
    }

    public void setUserTerminalClient(String userTerminalClient) {
        this.userTerminalClient = userTerminalClient;
    }

    public void setUserLastActionDate(Date userLastActionDate) {
        this.userLastActionDate = userLastActionDate;
    }

    public void setUserLastActionName(String userLastActionName) {
        this.userLastActionName = userLastActionName;
    }

    public void setUserRegistSessionDate(Date userRegistSessionDate) {
        this.userRegistSessionDate = userRegistSessionDate;
    }

    public void setUserLastActionStatusName(String userLastActionStatusName) {
        this.userLastActionStatusName = userLastActionStatusName;
    }

    public Integer getUserId() {
        return userId;
    }

    public String getUserName() {
        return userName;
    }

    public String getUserState() {
        return userState;
    }

    public String getUserTerminalIP() {
        return userTerminalIP;
    }

    public String getUserTerminalClient() {
        return userTerminalClient;
    }

    public Date getUserLastActionDate() {
        return userLastActionDate;
    }

    public String getUserLastActionName() {
        return userLastActionName;
    }

    public Date getUserRegistSessionDate() {
        return userRegistSessionDate;
    }

    public String getUserLastActionStatusName() {
        return userLastActionStatusName;
    }
}
