package main.lightdiver.skim.model;

import main.lightdiver.skim.ManagerContent;
import main.lightdiver.skim.entity.Article;
import main.lightdiver.skim.entity.Category;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import java.util.ArrayList;
import java.util.List;
import java.util.ResourceBundle;

@ManagedBean
@ViewScoped
public class ArticleBean {
    private List<Category> category;
    private List<Article> editorMyListEdit;
    private List<Article> editorReadyEdit;
    private List<Article> editorForeignEdit;
    private List<Article> previewArticle;
    private Article readArticle;

    @PostConstruct
    public void init(){
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        LocalizationBean localizationBean = (LocalizationBean) externalContext.getSessionMap().get("localizationBean");
        ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
        category = new ArrayList<>();
        category.add(new Category(1,msg.getString("cata.others")));
        category.add(new Category(2,msg.getString("cata.skimread")));
        category.add(new Category(3,msg.getString("cata.attentionmemory")));
        category.add(new Category(4,msg.getString("cata.interestingmathematics")));
    }

    public void loadArticle(){
        FacesContext facesContext = FacesContext.getCurrentInstance();
        String idA = facesContext.getExternalContext().getRequestParameterMap().get("id");
        int err;
        if (idA != null && idA.length() > 0) {
            if (readArticle == null) readArticle = new Article();
            err = ManagerContent.getArticle(idA, readArticle);
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
        ManagerContent.getPublicArticleList(previewArticle);
       // System.out.println("end loadPreviewArticle="+previewArticle.size());
    }

    public List<Category> getCategory() {
        return category;
    }

    public void setCategory(List<Category> category) {
        this.category = category;
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

    public void setPreviewArticle(List<Article> previewArticle) {
        this.previewArticle = previewArticle;
    }

    public Article getReadArticle() {
        return readArticle;
    }

    public void setReadArticle(Article readArticle) {
        this.readArticle = readArticle;
    }
}
