package main.lightdiver.skim;

/**
 * Created by Serj on 06.12.2015.
 */
public class Language {
    String langName;
    String langPict;

    public Language(){

    }
    public Language(String name, String pict){
        langName = name;
        langPict= pict;
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
}
