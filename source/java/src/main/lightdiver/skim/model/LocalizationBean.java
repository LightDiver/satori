package main.lightdiver.skim.model;

import main.lightdiver.skim.entity.Language;
import main.lightdiver.skim.LoadMenu;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import java.io.*;
import java.util.*;

@ManagedBean(eager = true)
@SessionScoped
public class LocalizationBean implements Serializable {

    private String locale = FacesContext.getCurrentInstance().getViewRoot().getLocale().toString();
    private String electLocale = locale;

    protected Language language;
    protected static List<Language> selectedLanguage;

    private static HashMap<String, ResourceBundle> textDependLangList;
    private LoadMenu loadMenu = new LoadMenu();

    @PostConstruct
    public void init() {
        if (selectedLanguage == null) {
            System.out.println("LangInit");
            selectedLanguage = new ArrayList<>();
            selectedLanguage.add(new Language("ua", "ua.png", "uk"));
            selectedLanguage.add(new Language("en", "en.png", "en"));
            selectedLanguage.add(new Language("ru", "ru.png", "ru"));
        }
        //Якщо є кука берем мову звідти
        locale = SessionBean.getCookie("userLang")==null?locale:SessionBean.getCookie("userLang").getValue();
        System.out.println("try cookie. locale="+locale);
        switch (locale) {
            case "uk":
                language = selectedLanguage.get(0);
                break;
            case "en":
                language = selectedLanguage.get(1);
                break;
            case "ru":
                language = selectedLanguage.get(2);
                break;
            default:
                language = selectedLanguage.get(0);
                break;
        }
        System.out.println("locale="+ locale +" langname="+language.getLangName());
        if (textDependLangList == null) {
            System.out.println("Load locale.text");
            textDependLangList = new HashMap<>();
            textDependLangList.put("uk", ResourceBundle.getBundle("locale.text", new Locale("uk")) );
            textDependLangList.put("en", ResourceBundle.getBundle("locale.text", new Locale("en")) );
            textDependLangList.put("ru", ResourceBundle.getBundle("locale.text", new Locale("ru")) );
        }
        setElectLocale(language.getLangISO());
    }


    public String getLocale() {
        return FacesContext.getCurrentInstance().getViewRoot().getLocale().toString();
    }


    public void setLocale(String locale) {
        this.locale = locale;
    }

    public String getElectLocale() {
        return electLocale;
    }

    public void setElectLocale(String electLocale) {
        this.electLocale = electLocale;
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        externalContext.getSessionMap().put("electLocale",electLocale);
        SessionBean.setCookie("userLang", electLocale, SessionBean.CONST_expireCookie);

        loadMenu.LoadMenuFooter();
    }

    public Language getLanguage() {
        return language;
    }

    public void setLanguage(Language language) {
        this.language = language;
    }

    public List<Language> getSelectedLanguage() {
        return selectedLanguage;
    }

    public void setSelectedLanguage(List<Language> selectedLanguage) {
        this.selectedLanguage = selectedLanguage;
    }


    public static HashMap<String, ResourceBundle> getTextDependLangList() {
        return textDependLangList;
    }

    public static void setTextDependLangList(HashMap<String, ResourceBundle> textDependLangList) {
        textDependLangList = textDependLangList;
    }

    public LoadMenu getLoadMenu() {
        return loadMenu;
    }

    public void setLoadMenu(LoadMenu loadMenu) {
        this.loadMenu = loadMenu;
    }
}
