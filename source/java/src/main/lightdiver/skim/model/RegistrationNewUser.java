package main.lightdiver.skim.model;

import main.lightdiver.skim.Users;

import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.bean.SessionScoped;
import javax.faces.component.UIComponent;
import javax.faces.component.UIInput;
import javax.faces.context.FacesContext;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by Serj on 24.11.2015.
 */
@ManagedBean
@SessionScoped
public class RegistrationNewUser {
    protected String userName;
    protected transient String userPass;
    protected transient String userPassRepeat;
    protected String hashPass = "abc";
    protected String userPIB;
    protected String userEMail;
    protected String sex;
    protected String userLang = "UA";

    public String registr(){
       /* if (sex.equals("Муж")){
            sex = "M";
        }
        else {
            sex = "W";
        }
        */
        String res = new Users().registr(userName, hashPass, userPIB, userEMail, sex, userLang);
        if (res == null) {
        FacesContext.getCurrentInstance().addMessage(null,
                new FacesMessage(FacesMessage.SEVERITY_INFO, "OK", "New User Rigestered"));}
        else {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Refused", res));
        }
        return "#";
    }
    public void validUserEMail(FacesContext context, UIComponent comp,
                                Object value) {
        final String EMAIL_PATTERN = "^[_A-Za-z0-9-]+(\\." +
                "[_A-Za-z0-9-]+)*@[A-Za-z0-9]+(\\.[A-Za-z0-9]+)*" +
                "(\\.[A-Za-z]{2,})$";

        Pattern pattern;
        Matcher matcher;
        pattern = Pattern.compile(EMAIL_PATTERN);
        String email = (String)value;
        matcher = pattern.matcher(email);


        if(!matcher.matches()){
            ((UIInput) comp).setValid(false);

            FacesMessage message = new FacesMessage("E-mail validation failed.",
                    "Invalid E-mail format");
            context.addMessage(comp.getClientId(context), message);
        }
    }
    public void validUserName(FacesContext context, UIComponent comp,
                               Object value) {
        String username = (String)value;
        if (username.length() < 5) {
            ((UIInput) comp).setValid(false);

            FacesMessage message = new FacesMessage("User Login validation failed.",
                    "User Name length must more 5 symbols");
            context.addMessage(comp.getClientId(context), message);
        }
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
