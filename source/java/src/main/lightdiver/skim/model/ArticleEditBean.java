package main.lightdiver.skim.model;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ManagedBean
@ViewScoped
public class ArticleEditBean {
    String value = null;
    String language = "uk";
    boolean rulesok = false;

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public boolean isRulesok() {
        return rulesok;
    }

    public void setRulesok(boolean rulesok) {
        this.rulesok = rulesok;
    }
}
