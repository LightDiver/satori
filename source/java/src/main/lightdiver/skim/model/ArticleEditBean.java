package main.lightdiver.skim.model;

import main.lightdiver.skim.ManagerContent;
import main.lightdiver.skim.entity.Article;
import main.lightdiver.skim.exceptions.BaseNotConnect;

import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@ManagedBean
@ViewScoped
public class ArticleEditBean {
    String value = null;
    String language = "uk";
    String nameArticle;
    Integer idArticle;
    boolean rulesok = false;



    public String validNameArticleAjax(){
        final String PATTERN_NAME = "^[а-яА-ЯёЁa-zA-Z0-9 іІїЇєЄҐґ']{1,300}$";
        Pattern pattern;
        Matcher matcher;
        pattern = Pattern.compile(PATTERN_NAME);

        if (nameArticle.length() < 5) {
            FacesContext.getCurrentInstance().addMessage("add_article:namearticle",new FacesMessage(FacesMessage.SEVERITY_ERROR,"Name Article validation failed.",
                    "Name article must more 5 symbols " ));
            return "#";
        }

        matcher = pattern.matcher(nameArticle);
        if (!matcher.matches()){
            FacesContext.getCurrentInstance().addMessage("add_article:namearticle",
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Name article validation failed.", "Назва може складатись з букв та цифр, та не може перевищувати 300 символів"));
            return "#";
        }

        FacesContext.getCurrentInstance().addMessage("add_article:namearticle", new FacesMessage(FacesMessage.SEVERITY_INFO, "Ok.", "Ok "));
        return null;

    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        if (value != null) {
            int err = ManagerContent.editArticle(idArticle, nameArticle, value, "UA");
            System.out.println("setValue");

            if (err != 0) {
                FacesContext.getCurrentInstance().addMessage(null,
                        new FacesMessage(FacesMessage.SEVERITY_ERROR, "err="+err, "err="+err));
            }
        }
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

    public String getNameArticle() {
        return nameArticle;
    }

    public void setNameArticle(String nameArticle) {
        if (nameArticle != null){
            int err = ManagerContent.editArticle(idArticle, nameArticle, value, "UA");
            System.out.println("setNameArticle");
            if (err != 0) {
                FacesContext.getCurrentInstance().addMessage(null,
                        new FacesMessage(FacesMessage.SEVERITY_ERROR, "err="+err, "err="+err));
            }

        }
        this.nameArticle = nameArticle;
    }

    public Integer getIdArticle() {
        if (idArticle == null) {
            Article article = new Article();
            int err = ManagerContent.getMyActiveArticle(article);
            if ( err == 0) {
                idArticle = article.getArticleId();
                nameArticle = article.getTitle();
                value = article.getContent();

            }else
            {
                if (ManagerContent.createArticle(article, nameArticle, value, "UA") == 0)
                    idArticle = article.getArticleId();
                else {
                    FacesContext.getCurrentInstance().addMessage(null,
                            new FacesMessage(FacesMessage.SEVERITY_ERROR, "err=" + err, "err=" + err));
                }
            }
        }
        return idArticle;
    }

    public void setIdArticle(Integer idArticle) {
        this.idArticle = idArticle;
    }
}
