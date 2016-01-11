package main.lightdiver.skim.model;

import main.lightdiver.skim.ManagerContent;
import main.lightdiver.skim.entity.Article;
import main.lightdiver.skim.entity.Category;

import javax.annotation.PostConstruct;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ManagedProperty;
import javax.faces.bean.ViewScoped;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;
import java.util.ResourceBundle;

@ManagedBean
@ViewScoped
public class ArticleBean {
    private List<Category> categoryList;
    private List<SelectItem> categorySelectItemList;
    private Integer categoryID = -1;
    private List<Article> editorMyListEdit;
    private List<Article> editorReadyEdit;
    private List<Article> editorForeignEdit;
    private List<Article> previewArticle;
    private Article readArticle;
    private int currSelIDArticle;
    private String comment;

    @ManagedProperty("#{localizationBean}")
    private LocalizationBean localizationBean;

    @PostConstruct
    public void init(){
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        LocalizationBean localizationBean = (LocalizationBean) externalContext.getSessionMap().get("localizationBean");
        ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
        categoryList = new ArrayList<>();
        categoryList.add(new Category(1, msg.getString("cata.others")));
        categoryList.add(new Category(2, msg.getString("cata.skimread")));
        categoryList.add(new Category(3, msg.getString("cata.attentionmemory")));
        categoryList.add(new Category(4, msg.getString("cata.interestingmathematics")));
    }

    public String convStringCategory(Integer[] listIDCategory) {
        if (listIDCategory!= null && listIDCategory.length > 0){
            String stringSelectedCategory = "";
            for (int i = 0; i < listIDCategory.length; i++) {
                for(Category cat : categoryList){
                    if(listIDCategory[i] == cat.getCategoryId()){
                        stringSelectedCategory = stringSelectedCategory + cat.getCategoryName() + ",";
                        break;
                    }
                }
            }
            return stringSelectedCategory.substring(0, stringSelectedCategory.length() - 1);
        }
        return "";
    }

    public void loadArticle(){
        FacesContext facesContext = FacesContext.getCurrentInstance();
        String idA = facesContext.getExternalContext().getRequestParameterMap().get("id");
        int err;
        if (idA != null && idA.length() > 0) {
            if (readArticle == null) readArticle = new Article();
            err = ManagerContent.getArticle(idA, readArticle);
            if (err==0) readArticle.setCategoryNameList(convStringCategory(readArticle.getCategoryIDList()));
        } else {
            err = 1;
        }
    }

    public void loadEditorReadyEdit(){
        if (editorReadyEdit == null) editorReadyEdit = new ArrayList<>();
        ManagerContent.getEditorArticleList(3,null, editorReadyEdit);
    }
    public void loadEditorMyListEdit(){
        if (editorMyListEdit == null) editorMyListEdit = new ArrayList<>();
        ManagerContent.getEditorArticleList(2,1, editorMyListEdit);
    }
    public void loadEditorForeignEdit(){
        if (editorForeignEdit == null) editorForeignEdit = new ArrayList<>();
        ManagerContent.getEditorArticleList(2,2, editorForeignEdit);
    }

    public void loadPreviewArticle(){
       // System.out.println("start loadPreviewArticle");
        if (previewArticle == null) previewArticle = new ArrayList<>();
        if (ManagerContent.getPublicArticleList(categoryID==-1?null:categoryID, previewArticle)==0){
         for (Article art: previewArticle){
             art.setCategoryNameList(convStringCategory(art.getCategoryIDList()));
         }
        }
       // System.out.println("end loadPreviewArticle="+previewArticle.size());
    }

    public List<Category> getCategoryList() {
        return categoryList;
    }

    public void setCategoryList(List<Category> categoryList) {
        this.categoryList = categoryList;
    }

    public List<Article> getEditorMyListEdit() {
        if (editorMyListEdit == null) loadEditorMyListEdit();
        return editorMyListEdit;
    }

    public void setEditorMyListEdit(List<Article> editorMyListEdit) {
        this.editorMyListEdit = editorMyListEdit;
    }

    public List<Article> getEditorReadyEdit() {
        if (editorReadyEdit == null) loadEditorReadyEdit();
        return editorReadyEdit;
    }

    public void setEditorReadyEdit(List<Article> editorReadyEdit) {
        this.editorReadyEdit = editorReadyEdit;
    }

    public List<Article> getEditorForeignEdit() {
        if (editorForeignEdit == null) loadEditorForeignEdit();
        return editorForeignEdit;
    }

    public void setEditorForeignEdit(List<Article> editorForeignEdit) {
        this.editorForeignEdit = editorForeignEdit;
    }

    public List<Article> getPreviewArticle() {
        if (previewArticle == null) loadPreviewArticle();
        return previewArticle;
    }

    public String returnToReadyPublic(){
        System.out.println("returnToReadyPublic: currSelIDArticle="+currSelIDArticle + " commnet="+comment);
        ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());

        if (currSelIDArticle == 0 || comment == null || comment.length() == 0){
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, msg.getString("err.db.1013"), msg.getString("err.db.1013")));
            return "#";
        }

        int err;

        if ((err=ManagerContent.changeStatusArticleToReadyPublic(currSelIDArticle, comment)) !=0 ){
            String text;
            switch (err){
                case 1010:
                    text = msg.getString("err.db.1010");
                    break;
                case 1011:
                    text = msg.getString("err.db.1011");
                    break;
                case 1013:
                    text = msg.getString("err.db.1011");
                    break;
                default:
                    text = msg.getString("err.refused") + " err=" + err;
                    break;
            }
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, text, text));
            return "#";
        }else {
            for (Article art: previewArticle){
                if(art.getArticleId() == currSelIDArticle){
                    previewArticle.remove(art);
                    break;
                }

            }
            return null;
        }


    }

    public void setPreviewArticle(List<Article> previewArticle) {
        this.previewArticle = previewArticle;
    }

    public Article getReadArticle() {
        return readArticle;
    }

    public void setReadArticle(Article readArticle) {
        this.readArticle = readArticle;
    }

    public int getCurrSelIDArticle() {
        return currSelIDArticle;
    }

    public void setCurrSelIDArticle(int currSelIDArticle) {
        this.currSelIDArticle = currSelIDArticle;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public LocalizationBean getLocalizationBean() {
        return localizationBean;
    }

    public void setLocalizationBean(LocalizationBean localizationBean) {
        this.localizationBean = localizationBean;
    }

    public Integer getCategoryID() {
        return categoryID;
    }

    public void setCategoryID(Integer categoryID) {
        this.categoryID = categoryID;
    }

    public List<SelectItem> getCategorySelectItemList() {
        if (categorySelectItemList == null){
            categorySelectItemList = new ArrayList<>();
            for(Category cat: categoryList){
                categorySelectItemList.add(new SelectItem(cat.getCategoryId(), cat.getCategoryName()));
            }
        }
        return categorySelectItemList;
    }

    public void setCategorySelectItemList(List<SelectItem> categorySelectItemList) {
        this.categorySelectItemList = categorySelectItemList;
    }
}
