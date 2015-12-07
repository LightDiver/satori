package main.lightdiver.skim;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import java.io.Serializable;
import java.util.*;

@ManagedBean(eager = true)
@SessionScoped
public class LocalizationBean implements Serializable {

    private String locale = FacesContext.getCurrentInstance().getViewRoot().getLocale().toString();

    protected Language language;
    protected List<Language> selectedLanguage;

    @PostConstruct
    public void init() {
        System.out.println("LangInit");
        System.out.println("locale="+locale);
        selectedLanguage = new ArrayList<>();
        selectedLanguage.add(new Language("ua", "ua.png","uk"));
        selectedLanguage.add(new Language("en", "en.png","en"));
        selectedLanguage.add(new Language("ru", "ru.png","ru"));
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
        System.out.println(language.langName);
    }


    public String getLocale() {
        return locale;
    }


    public void setLocale(String locale) {
        this.locale = locale;
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


}