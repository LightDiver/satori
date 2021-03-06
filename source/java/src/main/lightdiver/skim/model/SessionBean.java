package main.lightdiver.skim.model;

import main.lightdiver.skim.DAO.SystemInfoDAO;
import main.lightdiver.skim.LoadMenu;
import main.lightdiver.skim.Users;
import main.lightdiver.skim.entity.UserEntity;
import main.lightdiver.skim.exceptions.BaseNotConnect;
import main.lightdiver.skim.exceptions.ErrorInBase;
import main.lightdiver.skim.exceptions.FileNotRead;
import main.lightdiver.skim.exceptions.InvalidParameter;

import javax.annotation.PostConstruct;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ManagedProperty;
import javax.faces.bean.SessionScoped;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.Serializable;
import java.util.*;

/**
 * Created by Serj on 08.11.2015.
 */
@ManagedBean
@SessionScoped
public class SessionBean implements Serializable {
    private transient HashMap<String, Object> userInfo;
    @ManagedProperty("#{localizationBean}")
    private LocalizationBean localizationBean;

    public static final int CONST_EXPIRE_COOKIE = 60*60*24*30;
    private static final int VERS_MAJOR = 1;

    protected String userName;
    protected transient String userPass;
    protected String hashPass = "abc";
    protected String userSession;
    protected String userKey;
    protected List<SelectItem> langs;
    protected boolean uLogin = false;
    protected boolean uAdmin = false;
    protected boolean uEditor = false;

    @PostConstruct
    public void init() {
        String msgErr = null;

        userSession = getCookie("userSession")==null?null:getCookie("userSession").getValue();
        if (userSession!=null) userKey = getCookie("userKey").getValue();
        try {
            if (userSession == null || userKey == null || Users.checkUserSessActive(userSession, userKey, 1) != 0) {
                userName = "GUEST";
                    /*
                    if (login().equals("error.xhtml")){
                        try {
                            FacesContext.getCurrentInstance().getExternalContext().dispatch("/view/error.xhtml?error=");
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                    */
                login();
                userName = "";
            }
            else{
                FacesContext.getCurrentInstance().getExternalContext().getSessionMap().put("userSession",userSession);
                FacesContext.getCurrentInstance().getExternalContext().getSessionMap().put("userKey",userKey);
                UserEntity user = Users.getUserInfoBySess(userSession, userKey);
                if (user.getUserLogin().equals("GUEST")){
                    uLogin = false;
                    uAdmin = false;
                    uEditor = false;
                }else {
                    userName = user.getUserLogin();
                    uLogin = true;
                    uAdmin = user.getUserRoles().containsKey("ADMIN");
                    uEditor = user.getUserRoles().containsKey("EDITOR");
                }

            }
        } catch (FileNotRead fileNotRead) {
            msgErr = "?error=fileNotRead";
        } catch (InvalidParameter invalidParameter) {
            msgErr = "?error=invalidParameter";
        } catch (BaseNotConnect baseNotConnect) {
            msgErr = "?error=baseNotConnect";
        }
        try {
            if (SystemInfoDAO.checkVersion(VERS_MAJOR) ==0 ) {
                msgErr =  "?error=version";
                try {
                    FacesContext.getCurrentInstance().getExternalContext().redirect("/view/error.xhtml" + msgErr);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
        }
        /*
        if (msgErr != null) {
                try {
                    //FacesContext.getCurrentInstance().getExternalContext().dispatch("/view/error.xhtml" + msgErr);
                    FacesContext.getCurrentInstance().getExternalContext().redirect("/view/error.xhtml" + msgErr);

                } catch (IOException e) {
                    e.printStackTrace();
                }
        }
        */




    }

    public boolean isuLogin() {
        return uLogin;
    }

    public void setuLogin(boolean uLogin) {
        this.uLogin = uLogin;
    }

    public boolean isuEditor() {
        return uEditor;
    }

    public boolean isuAdmin() {
        return uAdmin;
    }

    public String getUserName() throws Throwable {
        return userName;
    }

    public String login() /*throws Throwable*/ {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        String msgErr = null;
        //LocalizationBean localizationBean = (LocalizationBean) externalContext.getSessionMap().get("localizationBean");
       // try {
        try {
            userInfo = Users.login(userName, hashPass);
        } catch (FileNotRead fileNotRead) {
            fileNotRead.printStackTrace();
            msgErr = "Не зміг прочитати налаштування";
        } catch (InvalidParameter invalidParameter) {
            invalidParameter.printStackTrace();
            msgErr = "Не зміг розпізнати параметри";
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
            msgErr = "Не зміг підключитись до БД";
        } catch (ErrorInBase errorInBase) {
            errorInBase.printStackTrace();
            msgErr = "Трапилась помилка при запиті у БД";
        }
        if (msgErr != null) {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, msgErr, "!"));

                return "error.xhtml";

        }
        if (userInfo.get("err_id") == 0) {
                userSession = userInfo.get("session_id").toString();
                userKey = userInfo.get("key_id").toString();
                if (userName.equals("GUEST")){
                    uLogin = false;
                    uAdmin =false;
                    uEditor = false;
                }
                else {
                    uLogin = true;
                    uAdmin = (Boolean)userInfo.get("is_admin");
                    uEditor = (Boolean)userInfo.get("is_editor");
                    String uLang = (String)userInfo.get("lang_id");
                    setCookie("userLang",uLang, CONST_EXPIRE_COOKIE);
                    localizationBean.setElectLocale(uLang);
                }

                externalContext.getSessionMap().put("userSession",userSession);
                externalContext.getSessionMap().put("userKey",userKey);
                setCookie("userSession",userSession, CONST_EXPIRE_COOKIE);
                setCookie("userKey",userKey, CONST_EXPIRE_COOKIE);

                return "#";
            } else {

                ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
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
        return "main";
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

    public static void setCookie(String name, String value, int expiry) {

        FacesContext facesContext = FacesContext.getCurrentInstance();

        HttpServletRequest request = (HttpServletRequest) facesContext.getExternalContext().getRequest();
        Cookie cookie = null;

        Cookie[] userCookies = request.getCookies();
        if (userCookies != null && userCookies.length > 0 ) {
            for (int i = 0; i < userCookies.length; i++) {
                if (userCookies[i].getName().equals(name)) {
                    cookie = userCookies[i];
                    break;
                }
            }
        }

        if (cookie != null) {
            cookie.setValue(value);
        } else {
            cookie = new Cookie(name, value);
            //cookie.setPath(request.getContextPath());
        }

        cookie.setMaxAge(expiry);

        HttpServletResponse response = (HttpServletResponse) facesContext.getExternalContext().getResponse();
        response.addCookie(cookie);
    }

    public static Cookie getCookie(String name) {

        FacesContext facesContext = FacesContext.getCurrentInstance();

        HttpServletRequest request = (HttpServletRequest) facesContext.getExternalContext().getRequest();
        Cookie cookie = null;

        Cookie[] userCookies = request.getCookies();
        if (userCookies != null && userCookies.length > 0 ) {
            for (int i = 0; i < userCookies.length; i++) {
                if (userCookies[i].getName().equals(name)) {
                    cookie = userCookies[i];
                    return cookie;
                }
            }
        }
        return null;
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


    public void canVisitPage() {
        //canVisitPage = (Users.checkUserSessActive(userSession, userKey, 1) == 0);
        int actionType = 0;
        int check;

        FacesContext facesContext = FacesContext.getCurrentInstance();
        HttpServletRequest request = (HttpServletRequest) facesContext.getExternalContext().getRequest();
        String uri=request.getRequestURI();

        //System.out.println("Страница " + uri + " PhaseId=" + facesContext.getCurrentPhaseId());
        //System.out.println(userName + ":" + userSession);

        switch (uri){
            case "/view/main.xhtml":
                actionType = 7;
                break;
            case "/view/about.xhtml":
                actionType = 8;
                break;
            case "/view/register.xhtml":
                actionType = 9;
                break;
            case "/view/news.xhtml":
                actionType = 11;
                break;
            case "/view/article.xhtml":
                actionType = 12;
                break;
            case "/view/interest.xhtml":
                actionType = 13;
                break;
            case "/view/editoreditarticle.xhtml":
                actionType = 22;
                break;
            default:actionType = 10;break;
        }

        if (actionType > 0){
            try {
                try {
                    if (userSession == null || userKey == null){//Можливо, якщо була зупинена БД перед тим як користувач прийде вперше
                        init();
                    }

                    if( (check=Users.checkUserSessActive(userSession, userKey, actionType)) != 0){
                        //Якщо була грохнута в базі сесія
                        if (check == 1002) {
                                    userName = null;
                                    userSession = null;
                                    FacesContext.getCurrentInstance().getExternalContext().redirect("error.xhtml?error=noLogin");
                        }
                        else {
                            FacesContext.getCurrentInstance().getExternalContext().redirect("access_denied.xhtml");
                        }
                    }
                } catch (FileNotRead fileNotRead) {
                    FacesContext.getCurrentInstance().getExternalContext().redirect("error.xhtml?error=fileNotRead");
                } catch (InvalidParameter invalidParameter) {
                    FacesContext.getCurrentInstance().getExternalContext().redirect("error.xhtml?error=invalidParameter");
                } catch (BaseNotConnect baseNotConnect) {
                    FacesContext.getCurrentInstance().getExternalContext().redirect("error.xhtml?error=baseNotConnect");
                }
            }
            catch (IOException e) {//try on redirect()
                e.printStackTrace();
            }
        }


    }

    public LocalizationBean getLocalizationBean() {
        return localizationBean;
    }

    public void setLocalizationBean(LocalizationBean localizationBean) {
        this.localizationBean = localizationBean;
    }
}
