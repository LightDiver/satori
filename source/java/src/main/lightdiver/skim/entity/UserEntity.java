package main.lightdiver.skim.entity;

import java.sql.Timestamp;
import java.util.HashMap;

/**
 * Created by Serj on 11.12.2015.
 */
public class UserEntity {
    Integer userId;
    String userLogin;
    String userName;
    String userEMail;
    String userState;
    String userLang;
    Timestamp userRegDate;
    String userSex;
    HashMap<String, String> userRoles;

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getUserLogin() {
        return userLogin;
    }

    public void setUserLogin(String userLogin) {
        this.userLogin = userLogin;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserEMail() {
        return userEMail;
    }

    public void setUserEMail(String userEMail) {
        this.userEMail = userEMail;
    }

    public String getUserState() {
        return userState;
    }

    public void setUserState(String userState) {
        this.userState = userState;
    }

    public String getUserLang() {
        return userLang;
    }

    public void setUserLang(String userLang) {
        this.userLang = userLang;
    }

    public Timestamp getUserRegDate() {
        return userRegDate;
    }

    public void setUserRegDate(Timestamp userRegDate) {
        this.userRegDate = userRegDate;
    }

    public String getUserSex() {
        return userSex;
    }

    public void setUserSex(String userSex) {
        this.userSex = userSex;
    }

    public HashMap<String, String> getUserRoles() {
        return userRoles;
    }

    public void setUserRoles(HashMap<String, String> userRoles) {
        this.userRoles = userRoles;
    }
}
