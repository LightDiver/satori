package main.lightdiver.skim.model;

import main.lightdiver.skim.DAO.UsersDAO;
import main.lightdiver.skim.Users;
import main.lightdiver.skim.exceptions.ErrorInBase;

import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import java.io.Serializable;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by Serj on 24.11.2015.
 */
@ManagedBean
@ViewScoped
public class RegistrationNewUserBean implements Serializable{
    protected String userName;
    protected transient String userPass;
    protected transient String userPassRepeat;
    protected String hashPass = "abc";
    protected String userPIB;
    protected String userEMail;
    protected String sex;
    protected String userLang = "UA";

    public String registr() {
        String res = null;
        String check;
       /* if(0==0) try {
            throw new ErrorInBase();
        } catch (ErrorInBase errorInBase) {
            errorInBase.printStackTrace();
        }
        */
        //System.out.println("userName="+userName+" hashPass="+hashPass+" sex="+sex);
        if ( (check=validUserEMailAjax()) !=null){res=res+check;}
        if ( (check=validUserNameAjax())  !=null){res=res+check;}
        if ( (check=validSexAjax())  !=null){res=res+check;}
        if ( (check=validUserPIBAjax())  !=null){res=res+check;}
        if (res==null) {
            res = new Users().registr(userName, hashPass, userPIB, userEMail, sex, userLang);
        }
        if (res == null) {
        FacesContext.getCurrentInstance().addMessage(null,
                new FacesMessage(FacesMessage.SEVERITY_INFO, "OK", "New User Rigestered"));
            return "register_done";
        }
        else {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Refused", "Error Validation"));
            return "#";
        }
        //System.out.println("res = " + res);

    }
    public String validUserEMailAjax() {
        final String EMAIL_PATTERN = "^[_A-Za-z0-9-]+(\\." +
                "[_A-Za-z0-9-]+)*@[A-Za-z0-9]+(\\.[A-Za-z0-9]+)*" +
                "(\\.[A-Za-z]{2,})$";

        Pattern pattern;
        Matcher matcher;
        pattern = Pattern.compile(EMAIL_PATTERN);

        if (userEMail == "" || userEMail == null){
            FacesContext.getCurrentInstance().addMessage("r_useremail",
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "E-mail validation failed.", "E-mail empty"));
            return "#";
        }

        matcher = pattern.matcher(userEMail);
        //System.out.println("validUserEMailAjax: userEMail:" + userEMail+ " userName:" + this.userName);


        if(!matcher.matches()){
            FacesContext.getCurrentInstance().addMessage("r_useremail",
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "E-mail validation failed.", "Invalid E-mail format"));
            return "#";
        }
        else {
            FacesContext.getCurrentInstance().addMessage("r_useremail",
                    new FacesMessage(FacesMessage.SEVERITY_INFO, "Ok.", "Ok "));
            return null;
        }

    }


    public String validUserNameAjax(){
        //final String PATTERN_LOGIN = "^[\\w_]{3,25}$";
        final String PATTERN_LOGIN = "^[а-яА-ЯёЁa-zA-Z0-9_іІїЇєЄҐґ']{3,30}$";
        Pattern pattern;
        Matcher matcher;
        pattern = Pattern.compile(PATTERN_LOGIN);

        if (userName.length() < 3) {
            FacesContext.getCurrentInstance().addMessage("r_username",new FacesMessage(FacesMessage.SEVERITY_ERROR,"User Login validation failed.",
                    "User Login length must more 3 symbols "));
            return "#";
        }

        matcher = pattern.matcher(userName);
        if (!matcher.matches()){
            FacesContext.getCurrentInstance().addMessage("r_username",
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "User Login validation failed.", "Логін може складатись з букв, цифр та знаку _"));
            return "#";
        }

        if (UsersDAO.isUserExist(userName) == 1){
            FacesContext.getCurrentInstance().addMessage("r_username",new FacesMessage(FacesMessage.SEVERITY_ERROR,"User Login validation failed.",
                    "User Name occupations. Вибиріть інше"));
            return "#";
        }

        FacesContext.getCurrentInstance().addMessage("r_username", new FacesMessage(FacesMessage.SEVERITY_INFO, "Ok.", "Ok " ));
        return null;


    }
    public String validSexAjax(){
        //System.out.println(sex);
        if (sex == null || !( sex.equals("M") || sex.equals("W")) ) {
            FacesContext.getCurrentInstance().addMessage("r_sex",new FacesMessage(FacesMessage.SEVERITY_ERROR,"User Sex validation failed.",
                    "User Sex required "));
            return "#";
        }
        else{
            FacesContext.getCurrentInstance().addMessage("r_sex", new FacesMessage(FacesMessage.SEVERITY_INFO, "Ok.",
                    "Ok "));
            return null;
        }
    }
    public String validUserPIBAjax(){
        final String PATTERN_LOGIN = "^[а-яА-ЯёЁa-zA-Z0-9 іІїЇєЄҐґ']{1,55}$";
        Pattern pattern;
        Matcher matcher;
        pattern = Pattern.compile(PATTERN_LOGIN);

        if (userPIB.length() < 5) {
            FacesContext.getCurrentInstance().addMessage("r_userpib",new FacesMessage(FacesMessage.SEVERITY_ERROR,"User PIB validation failed.",
                    "User Name length must more 5 symbols " ));
            return "#";
        }

        matcher = pattern.matcher(userPIB);
        if (!matcher.matches()){
            FacesContext.getCurrentInstance().addMessage("r_userpib",
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "User Name validation failed.", "Ім'я може складатись з букв та цифр"));
            return "#";
        }

        FacesContext.getCurrentInstance().addMessage("r_userpib", new FacesMessage(FacesMessage.SEVERITY_INFO, "Ok.",
                    "Ok "));
        return null;

    }


    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserPass() {
        return userPass;
    }

    public void setUserPass(String userPass) {
        this.userPass = userPass;
    }

    public String getHashPass() {
        return hashPass;
    }

    public void setHashPass(String hashPass) {
        this.hashPass = hashPass;
    }

    public String getUserPIB() {
        return userPIB;
    }

    public void setUserPIB(String userPIB) {
        this.userPIB = userPIB;
    }

    public String getUserEMail() {
        return userEMail;
    }

    public void setUserEMail(String userEMail) {
        this.userEMail = userEMail;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }

    public String getUserLang() {
        return userLang;
    }

    public void setUserLang(String userLang) {
        this.userLang = userLang;
    }

    public String getUserPassRepeat() {
        return userPassRepeat;
    }

    public void setUserPassRepeat(String userPassRepeat) {
        this.userPassRepeat = userPassRepeat;
    }
}
