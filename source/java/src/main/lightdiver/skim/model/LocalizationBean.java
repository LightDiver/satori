package main.lightdiver.skim.model;

import main.lightdiver.skim.Language;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import java.io.*;
import java.util.*;

@ManagedBean(eager = true)
@SessionScoped
public class LocalizationBean implements Serializable {

    private String locale = FacesContext.getCurrentInstance().getViewRoot().getLocale().toString();
    private String electLocale = locale;

    protected Language language;
    protected List<Language> selectedLanguage;

    private static ResourceBundle textDependLang;

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
        System.out.println(language.getLangName());
        loadNewTextLang(locale);
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
        loadNewTextLang(electLocale);
        //System.out.println(textDependLang.getString("err.login.invalid"));
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

    private static void loadNewTextLang(String lang){
        textDependLang = ResourceBundle.getBundle("locale.text", new Locale(lang));
        //System.out.println(textDependLang.getString("err.login.invalid"));
        /*ServletContext servletContext = (ServletContext) FacesContext.getCurrentInstance().getExternalContext().getContext();
        String fileName = servletContext.getRealPath(File.separator + "WEB-INF" + File.separator + "classes" + File.separator + "locale"+File.separator + "textlang." + lang);
        textDependLang = new Properties();

        try {
            FileInputStream ins = new FileInputStream(fileName);
            textDependLang.load(ins);
            System.out.println("Load lang text ok: " + lang);
        } catch (FileNotFoundException e) {
            logger.log(Level.SEVERE, "Uvaga (FileNotFoundException) ", e);
            e.printStackTrace();
        } catch (IOException e) {
            logger.log(Level.SEVERE, "Uvaga! (IOException) ", e);
            e.printStackTrace();
        }
        catch (Throwable e){
            logger.log(Level.SEVERE, "Uvaga! (Throwable) " , e);
            e.printStackTrace();
        }
        */

    }

    public static ResourceBundle getTextDependLang() {
        return textDependLang;
    }

    public static void setTextDependLang(ResourceBundle textDependLang) {
        LocalizationBean.textDependLang = textDependLang;
    }
}
