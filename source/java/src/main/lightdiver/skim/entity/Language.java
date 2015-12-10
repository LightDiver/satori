package main.lightdiver.skim.entity;


/**
 * Created by Serj on 06.12.2015.
 */
public class Language {
    String langName;
    String langISO;
    String langPict;

    public Language(){

    }
    public Language(String name, String pict, String iso){
        langName = name;
        langPict= pict;
        langISO = iso;
    }

    public String getLangName() {
        return langName;
    }

    public void setLangName(String langName) {
        this.langName = langName;
    }

    public String getLangPict() {
        return langPict;
    }

    public void setLangPict(String langPict) {
        this.langPict = langPict;
    }

    public String getLangISO() {
        return langISO;
    }

    public void setLangISO(String langISO) {
        this.langISO = langISO;
    }
}
