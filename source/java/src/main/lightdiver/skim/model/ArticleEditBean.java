package main.lightdiver.skim.model;

import main.lightdiver.skim.ManagerContent;
import main.lightdiver.skim.entity.Article;
import main.lightdiver.skim.entity.Category;
import main.lightdiver.skim.entity.Language;

import javax.annotation.PostConstruct;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ManagedProperty;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import java.util.ArrayList;
import java.util.List;
import java.util.ResourceBundle;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@ManagedBean
@ViewScoped
public class ArticleEditBean {
    private int err;

    private String shortValue = null;
    private String value = null;
    private Language language;
    private String nameArticle;
    private Integer idArticle;
    private boolean rulesok = false;
    private List<Category> selectedCategory;

    @ManagedProperty("#{localizationBean}")
    private LocalizationBean localizationBean;

    @ManagedProperty("#{articleBean}")
    private ArticleBean articleBean;

    @PostConstruct
    public void init(){
        language = localizationBean.getLanguage();
    }


    private void edit(){
        err = ManagerContent.editArticle(idArticle, nameArticle, shortValue, value, language.getLangName().toUpperCase(), getCategoryIDList());

        if (err != 0) {
            String text;
            ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
            switch (err){
                case 1006:
                    text = msg.getString("err.db.1006");
                    break;
                case 1007:
                    text = msg.getString("err.db.1007");
                    break;
                case 1008:
                    text = msg.getString("err.db.1008");
                    break;
                case 1011:
                    text = msg.getString("err.db.1011");
                    break;
                default:
                    text = "err=" +err;
                    break;
            }

            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, text, null));
        }

    }

    public String validCategoryAjax(){
        if (selectedCategory!= null && selectedCategory.size() > 3) {
            ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
            FacesContext.getCurrentInstance().addMessage("add_article:category", new FacesMessage(FacesMessage.SEVERITY_ERROR, null, msg.getString("err.manycategories")));
            return "#";
        }
        return null;
    }

    public String validNameArticleAjax(){
        final String PATTERN_NAME = "^[а-яА-ЯёЁa-zA-Z0-9 іІїЇєЄҐґ.']{1,300}$";
        Pattern pattern;
        Matcher matcher;
        pattern = Pattern.compile(PATTERN_NAME);
        ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());

        if (nameArticle.length() < 5) {
            FacesContext.getCurrentInstance().addMessage("add_article:namearticle",new FacesMessage(FacesMessage.SEVERITY_ERROR,null,msg.getString("err.minarticlename")));
            return "#";
        }

        matcher = pattern.matcher(nameArticle);
        if (!matcher.matches()){
            FacesContext.getCurrentInstance().addMessage("add_article:namearticle",
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, null, msg.getString("err.formatarticlename")));
            return "#";
        }

        if (nameArticle != null){
            edit();
        }

        FacesContext.getCurrentInstance().addMessage("add_article:namearticle", new FacesMessage(FacesMessage.SEVERITY_INFO, null, "Ok "));
        return null;

    }

    public String saveToPublic(){
        ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
        if (!rulesok) {
            FacesContext.getCurrentInstance().addMessage("add_article:rulesok",
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, null, msg.getString("err.rulesarticle")));
            return "#";
        }
        if (err != 0){
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "err= " + err, "err= " + err));
            return "#";
        }
        if (validNameArticleAjax() != null || validCategoryAjax() != null ){
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, msg.getString("err.refused"), msg.getString("err.refused")));
            return "#";
        }

        if ((err=ManagerContent.changeStatusArticleToReadyPublic(idArticle)) !=0 ){
            String text;
            switch (err){
                case 1010:
                    text = msg.getString("err.db.1010");
                    break;
                case 1011:
                    text = msg.getString("err.db.1011");
                    break;
                default:
                    text = msg.getString("err.refused") + " err=" + err;
                    break;
            }
                FacesContext.getCurrentInstance().addMessage(null,
                        new FacesMessage(FacesMessage.SEVERITY_ERROR, text, null));
            return "#";
        }else {
                idArticle = null;
                return "okarticle.xhtml";
            }

    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        System.out.println("setValue");
        if (value != null) {
            edit();
        }
        this.value = value;
    }

    public Language getLanguage() {
        return language;
    }

    public void setLanguage(Language language) {
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
        this.nameArticle = nameArticle;
    }

    public Integer getIdArticle() {
        if (idArticle == null || idArticle == 0) {
            Article article = new Article();
            err = ManagerContent.getMyActiveArticle(article);
            if ( err == 0) {
                idArticle = article.getArticleId();
                nameArticle = article.getTitle();
                shortValue = article.getShortContent();
                value = article.getContent();
                language = LocalizationBean.getLanguageByISO(article.getLang().toLowerCase());
                selectedCategory = getCategoryObjList(article.getCategoryIDList());

            }else
            {
                if (ManagerContent.createArticle(article, nameArticle, shortValue, value, language.getLangName().toUpperCase()) == 0)
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

    public LocalizationBean getLocalizationBean() {
        return localizationBean;
    }

    public void setLocalizationBean(LocalizationBean localizationBean) {
        this.localizationBean = localizationBean;
    }

    public List<Category> getSelectedCategory() {
        return selectedCategory;
    }

    public void setSelectedCategory(List<Category> selectedCategory) {
        this.selectedCategory = selectedCategory;
        validCategoryAjax();
    }

    private String getCategoryIDList(){
        String categoryIDList = "";
        if (selectedCategory!= null && selectedCategory.size() > 0){
            for(Category cat : selectedCategory){
                categoryIDList = categoryIDList + cat.getCategoryId() + ",";
            }
        }
        return categoryIDList;
    }

    private List<Category> getCategoryObjList(Integer[] n_id){
        List<Category> list = new ArrayList<>();
        if (n_id != null && n_id.length > 0){
            //ArticleBean articleBean = (ArticleBean)FacesContext.getCurrentInstance().getViewRoot().getViewMap().get("articleBean");
            for (int i = 0; i < n_id.length; i++) {
                for (Category cat : articleBean.getCategory()){
                   if (cat.getCategoryId() == n_id[i]){
                       list.add(cat);
                       break;
                   }
                }
            }

        }
        return list;
    }

    public ArticleBean getArticleBean() {
        return articleBean;
    }

    public void setArticleBean(ArticleBean articleBean) {
        this.articleBean = articleBean;
    }

    public String getShortValue() {
        return shortValue;
    }

    public void setShortValue(String shortValue) {
        System.out.println("shortValue");
        if (value != null) {
            edit();
        }
        if (!language.getLangISO().equals(localizationBean.getElectLocale())){
            ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
            FacesContext.getCurrentInstance().addMessage("add_article:sellang",
                    new FacesMessage(FacesMessage.SEVERITY_WARN, null, msg.getString("warn.articlelang")));

        }
        this.shortValue = shortValue;
    }
}
