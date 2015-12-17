package main.lightdiver.skim.model;

import main.lightdiver.skim.LoadMenu;
import main.lightdiver.skim.Users;
import main.lightdiver.skim.entity.UserEntity;

import javax.annotation.PostConstruct;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.component.UIViewRoot;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import javax.servlet.ServletRequest;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.Serializable;
import java.util.*;

/**
 * Created by Serj on 08.11.2015.
 */
@ManagedBean
@SessionScoped
public class SessionBean implements Serializable {
    private transient HashMap<String, Object> userInfo;

    public static final int CONST_expireCookie = 60*60*24*30;

    private static final int CONST_action_main = 7;
    private static final int CONST_action_about = 8;
    private static final int CONST_action_registr = 9;

    protected String currPage;
    protected boolean canVisitPage;
    protected String userName;
    protected transient String userPass;
    protected String hashPass = "abc";
    protected String userSession;
    protected String userKey;
    protected List<SelectItem> langs;
    protected boolean uLogin = false;
    protected boolean uAdmin = false;

    @PostConstruct
    public void init(){
        if (userName == null ){
            userSession = getCookie("userSession")==null?null:getCookie("userSession").getValue();
            if (userSession!=null) userKey = getCookie("userKey").getValue();
            if (userSession == null || userKey == null || Users.checkUserSessActive(userSession, userKey, 1) != 0) {
                userName = "GUEST";
                login();
                userName = "";
            }
            else{
                FacesContext.getCurrentInstance().getExternalContext().getSessionMap().put("userSession",userSession);
                FacesContext.getCurrentInstance().getExternalContext().getSessionMap().put("userKey",userKey);
                UserEntity user = Users.getUserInfoBySess(userSession, userKey);
                if (user.getUserLogin().equals("GUEST")){
                    uLogin = false;
                }else {
                    userName = user.getUserLogin();
                    uLogin = true;
                    uAdmin = user.getUserRoles().containsKey("ADMIN");

                }

                System.out.println("Restore user info " + userName);
            }

        }

    }

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
        return userName;
    }

    public String login() /*throws Throwable*/ {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        LocalizationBean localizationBean = (LocalizationBean) externalContext.getSessionMap().get("localizationBean");
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
                    String uLang = (String)userInfo.get("lang_id");
                    setCookie("userLang",uLang,CONST_expireCookie);
                    localizationBean.setElectLocale(uLang);
                }

                externalContext.getSessionMap().put("userSession",userSession);
                externalContext.getSessionMap().put("userKey",userKey);
                setCookie("userSession",userSession,CONST_expireCookie);
                setCookie("userKey",userKey,CONST_expireCookie);

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
            cookie.setPath(request.getContextPath());
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

    public String getCurrPage() {
        return currPage;
    }

    public void setCurrPage(String currPage) {
        this.currPage = currPage;
    }

    public boolean isCanVisitPage() {
        //canVisitPage = (Users.checkUserSessActive(userSession, userKey, 1) == 0);
        FacesContext facesContext = FacesContext.getCurrentInstance();
        HttpServletRequest request = (HttpServletRequest) facesContext.getExternalContext().getRequest();
        String uri=((HttpServletRequest)request).getRequestURI();
        String requestContext=((HttpServletRequest)request).getContextPath();
        UIViewRoot viewRoot = facesContext.getViewRoot();

        System.out.println("Страница " + uri + " requestContext=" + requestContext + " PhaseId=" + facesContext.getCurrentPhaseId()+ " viewRoot=" + viewRoot);

        switch (uri){
            case "/view/main.xhtml":
                canVisitPage = true;
                break;
            default:canVisitPage = false;
                    break;
        }

        return canVisitPage;
    }

    public void setCanVisitPage(boolean canVisitPage) {
        this.canVisitPage = canVisitPage;
    }
}
