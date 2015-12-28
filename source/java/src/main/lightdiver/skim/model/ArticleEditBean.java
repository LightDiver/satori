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
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@ManagedBean
@ViewScoped
public class ArticleEditBean {
    private int err;

    private String value = null;
    private Language language;
    private String nameArticle;
    private Integer idArticle;
    private boolean rulesok = false;
    private List<Category> selectedCategory;

    @ManagedProperty("#{localizationBean}")
    private LocalizationBean localizationBean;

    @PostConstruct
    public void init(){
        language = localizationBean.getLanguage();
    }

    public String validCategoryAjax(){
        System.out.print("validCategoryAjax:");
        if (selectedCategory == null){
            System.out.println("null");
        }
        else System.out.println(selectedCategory.size());

        if (selectedCategory!= null && selectedCategory.size() > 3) {
            FacesContext.getCurrentInstance().addMessage("add_article:category", new FacesMessage(FacesMessage.SEVERITY_ERROR, "Більше трьох категорій неприпустимо", "Більше трьох категорій неприпустимо"));
            return "#";
        }
        return null;
    }

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

        if (nameArticle != null){
            err = ManagerContent.editArticle(idArticle, nameArticle, value, language.getLangName().toUpperCase(), getCategoryIDList());
            System.out.println("validNameArticleAjax");
            if (err != 0) {
                FacesContext.getCurrentInstance().addMessage(null,
                        new FacesMessage(FacesMessage.SEVERITY_ERROR, "err="+err, "err="+err));
            }

        }

        FacesContext.getCurrentInstance().addMessage("add_article:namearticle", new FacesMessage(FacesMessage.SEVERITY_INFO, "Ok.", "Ok "));
        return null;

    }

    public String saveToPublic(){
        System.out.println("saveToPublic");
        if (!rulesok) {
            FacesContext.getCurrentInstance().addMessage("add_article:rulesok",
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Правила не приняті", "Правила не приняті"));
            return "#";
        }
        if (err != 0){
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Невідома помилка " + err, "Невідома помилка " + err));
            return "#";
        }


        if (ManagerContent.changeStatusArticleToReadyPublic(idArticle) !=0 ){
                FacesContext.getCurrentInstance().addMessage(null,
                        new FacesMessage(FacesMessage.SEVERITY_ERROR, "Невідома помилка", "Невідома помилка"));
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

            err = ManagerContent.editArticle(idArticle, nameArticle, value, language.getLangName().toUpperCase(), getCategoryIDList());


            if (err != 0) {
                FacesContext.getCurrentInstance().addMessage(null,
                        new FacesMessage(FacesMessage.SEVERITY_ERROR, "err="+err, "err="+err));

            }
        }
        if (!language.getLangISO().equals(localizationBean.getElectLocale())){
            FacesContext.getCurrentInstance().addMessage("add_article:sellang",
                    new FacesMessage(FacesMessage.SEVERITY_WARN, "Мова статті не співпадає з мовою Вашого профіля(ignore)", "Мова статті не співпадає з мовою Вашого профіля"));

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
                value = article.getContent();
                language = LocalizationBean.getLanguageByISO(article.getLang().toLowerCase());
                selectedCategory = getCategoryObjList(article.getCategoryIDList());

            }else
            {
                if (ManagerContent.createArticle(article, nameArticle, value, language.getLangName().toUpperCase()) == 0)
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
        System.out.println("setSelectedCategory");
        this.selectedCategory = selectedCategory;
    }

    private String getCategoryIDList(){
        String categoryIDList = "";
        if (selectedCategory!= null && selectedCategory.size() > 0){
            for(Category cat : selectedCategory){
                categoryIDList = categoryIDList + cat.getCategoryId() + ",";
            }
        }
        System.out.println("getCategoryIDList = " + categoryIDList);
        return categoryIDList;
    }

    private List<Category> getCategoryObjList(Integer[] n_id){
        List<Category> list = null;
        if (n_id != null && n_id.length > 0){
            ArticleBean articleBean = (ArticleBean)FacesContext.getCurrentInstance().getViewRoot().getViewMap().get("articleBean");
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
}
