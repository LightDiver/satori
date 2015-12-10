package main.lightdiver.skim.model;

import main.lightdiver.skim.LoadMenu;
import main.lightdiver.skim.Users;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.util.*;

/**
 * Created by Serj on 08.11.2015.
 */
@ManagedBean
@SessionScoped
public class SessionBean implements Serializable {
    private transient HashMap<String, Object> userInfo;
    protected String userName;
    protected transient String userPass;
    protected String hashPass = "abc";
    protected String userSession;
    protected String userKey;
    protected List<SelectItem> langs;
    protected boolean uLogin = false;
    protected boolean uAdmin = false;



    public boolean isuLogin() {
        return uLogin;
    }

    public void setuLogin(boolean uLogin) {
        this.uLogin = uLogin;
    }

    public boolean isuAdmin() {
        return uAdmin;
    }

    public String getUserName() throws Throwable {
        if (userName == null ){
            userName = "GUEST";
            login();
            userName = "";
        }
        return userName;
    }

    public String login() /*throws Throwable*/ {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
       // try {
            userInfo = Users.login(userName, hashPass);
            if (userInfo.get("err_id") == 0) {
                userSession = userInfo.get("session_id").toString();
                userKey = userInfo.get("key_id").toString();
                if (userName.equals("GUEST")){
                    uLogin = false;
                }
                else {
                    uLogin = true;
                    uAdmin = (Boolean)userInfo.get("is_admin");

                }

                externalContext.getSessionMap().put("userSession",userSession);
                externalContext.getSessionMap().put("userKey",userKey);
                return "#";
            } else {

                ResourceBundle msg = LocalizationBean.getTextDependLangList().get(externalContext.getSessionMap().get("electLocale"));
                FacesContext.getCurrentInstance().addMessage(null,
                        new FacesMessage(FacesMessage.SEVERITY_ERROR, msg.getString("err.refused"), msg.getString("err.login.invalid")));
                uLogin = false;
                //throw new Throwable();
                return "#";
            }
       /* }
        catch (Throwable e){
            e.printStackTrace();
            throw new Throwable();
        }*/
    }
    public String logout() {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        externalContext.invalidateSession();
        new Users().logout(userSession, userKey);
        uLogin = false;
        return "index";
    }

    public String getUserSession() {
        return userSession;
    }

    public String getUserKey() {
        return userKey;
    }


    public void setUserName(String userName) {
        this.userName = userName;
    }

    public void setUserSession(String userSession) {
        this.userSession = userSession;
    }

    public void setUserKey(String userKey) {
        this.userKey = userKey;
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

    public List<SelectItem> getLangs() {
        if (langs == null){
            langs = new ArrayList<SelectItem>();
            for (Map.Entry<String, String> me : LoadMenu.getLangs().entrySet() ) {
                langs.add(new SelectItem(me.getKey(), me.getValue()));
            }
        }
        return langs;
    }

    public void setLangs(List<SelectItem> langs) {
        this.langs = langs;
    }

}
