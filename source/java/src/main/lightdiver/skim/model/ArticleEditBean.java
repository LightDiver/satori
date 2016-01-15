package main.lightdiver.skim.model;

import main.lightdiver.skim.ManagerContent;
import main.lightdiver.skim.entity.Article;
import main.lightdiver.skim.entity.Category;
import main.lightdiver.skim.entity.Language;
import main.lightdiver.skim.entity.UploadedImage;
import main.lightdiver.skim.exceptions.BaseNotConnect;
import main.lightdiver.skim.exceptions.ErrorInBase;
import org.richfaces.event.FileUploadEvent;
import org.richfaces.model.UploadedFile;

import javax.annotation.PostConstruct;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ManagedProperty;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.io.OutputStream;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.ResourceBundle;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@ManagedBean
@ViewScoped
public class ArticleEditBean implements Serializable {
    private int err = 0;
    private boolean errCritical = false;

    private String shortValue = null;
    private Integer heightShortValue;
    private String value = null;
    private Language language;
    private String nameArticle;
    private Integer idArticle;
    private boolean rulesok = false;
    private List<Category> selectedCategory;

    private int typePage;

    private int currSelIDArticle;
    private String comment;
    private String showComment;

    private ArrayList<UploadedImage> files;
    private int uploadsAvailable = 10;

    private List<Article> myListIEdit;
    private List<Article> myListRedyToPublic;
    private List<Article> myListEditEditor;

    @ManagedProperty("#{sessionBean}")
    private SessionBean sessionBean;

    @ManagedProperty("#{localizationBean}")
    private LocalizationBean localizationBean;

    @ManagedProperty("#{articleBean}")
    private ArticleBean articleBean;

    @PostConstruct
    public void init(){
        FacesContext facesContext = FacesContext.getCurrentInstance();
        System.out.println("init ArticleEditBean " + " PhaseId=" + facesContext.getCurrentPhaseId());

        language = localizationBean.getLanguage();
        catchArticleID();

    }

    private void catchArticleID(){
        FacesContext facesContext = FacesContext.getCurrentInstance();
        System.out.println("catchArticleID " + " PhaseId=" + facesContext.getCurrentPhaseId());

        if (isWorkEditor()) typePage = 0; else typePage = 1;

        System.out.println("sessionBean="+sessionBean);
        System.out.println("typePage="+typePage + "uEditor="+sessionBean.uEditor+" uAdmin="+sessionBean.uAdmin);

        idArticle = null;
        Article article = new Article();
        err = -1;
        String text = "Невідома помилка";

        if (typePage == 0) {//Якщо працює редактор, то взяти с GET запиту id
            //FacesContext facesContext = FacesContext.getCurrentInstance();
            String idA = facesContext.getExternalContext().getRequestParameterMap().get("id");
            if (idA != null && idA.length() > 0) {
                err = ManagerContent.getEditorArticle(idA, article);
            } else {
                err = 1;
                errCritical = true;
            }
        }else {//користувач підгружає створену або створюэ "пустишку"
            System.out.println("idArticle="+idArticle);

            err = ManagerContent.getMyActiveArticle(article);
            System.out.println("ManagerContent.getMyActiveArticle(article)=" + err);
            if (err != 0) {
                nameArticle = "empty";
                if ((err=ManagerContent.createArticle(article, nameArticle, shortValue, value, language.getLangName().toUpperCase())) == 0) {
                    System.out.println("ManagerContent.createArticle=0");
                    idArticle = article.getArticleId();
                }
            }
        }
        if ( err == 0 && idArticle == null) {
            System.out.println("if ( err == 0) {");
            idArticle = article.getArticleId();
            nameArticle = article.getTitle();
            shortValue = article.getShortContent();
            value = article.getContent();
            language = localizationBean.getLanguageByISO(article.getLang().toLowerCase());
            selectedCategory = getCategoryObjList(article.getCategoryIDList());
            showComment = article.getComment();
        }
        if ( err !=0 ){
            ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
            switch (err){
                case -1:
                    text = msg.getString("err.unknown");
                    break;
                case 1:
                    text = msg.getString("err.idarticle");
                    break;
                case 1011:
                    text = msg.getString("err.db.1004");
                    break;
                default: break;
            }

            FacesContext.getCurrentInstance().addMessage(null,
                new FacesMessage(FacesMessage.SEVERITY_ERROR, "err=" + err + " " + text, null));
            System.out.println("else if ( err == 0) {");
        }
        System.out.println("END catchArticleID=" + idArticle);
    }

    public void backArticleForEdit(){
        System.out.println("backArticleForEdit");
        ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
        if (currSelIDArticle == 0) {
            FacesContext.getCurrentInstance().addMessage("MyArticleReadyToPublic",
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, null, msg.getString("err.idarticle")));
        }else{
            Article article = new Article();
            if ((err=ManagerContent.changeStatusArticleToEditUser(currSelIDArticle, null)) !=0 ){
                //System.out.println("err="+err);
                String text;
                switch (err){
                    case 1011:
                        text = msg.getString("err.db.1011");
                        break;
                    default:
                        text = msg.getString("err.refused") + " err=" + err;
                        break;
                }
                FacesContext.getCurrentInstance().addMessage("MyArticleReadyToPublic",
                        new FacesMessage(FacesMessage.SEVERITY_ERROR, text, text));
            }else {
                System.out.println(myListRedyToPublic.size());
                loadArticleForEdit();
                loadMyListIEdit();
                loadMyListRedyToPublic();
                System.out.println(myListRedyToPublic.size());
            }
        }

    }

    public void loadArticleForEdit(){
        System.out.println("loadArticleForEdit: currSelIDArticle="+currSelIDArticle);
        ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
        if (currSelIDArticle == 0) {
            FacesContext.getCurrentInstance().addMessage("MyArticleIEdit",
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, null, msg.getString("err.idarticle")));
        }else{
            Article article = new Article();
            if ((err=ManagerContent.getMyArticle(currSelIDArticle, article)) !=0 ){
                //System.out.println("err="+err);
                String text;
                switch (err){
                    case 1011:
                        text = msg.getString("err.db.1011");
                        break;
                    default:
                        text = msg.getString("err.refused") + " err=" + err;
                        break;
                }
                FacesContext.getCurrentInstance().addMessage("MyArticleIEdit",
                        new FacesMessage(FacesMessage.SEVERITY_ERROR, null, text));
            }else {
                idArticle = article.getArticleId();
                nameArticle = article.getTitle();
                shortValue = article.getShortContent();
                value = article.getContent();
                language = localizationBean.getLanguageByISO(article.getLang().toLowerCase());
                selectedCategory = getCategoryObjList(article.getCategoryIDList());
                showComment = article.getComment();
            }
        }

    }

    public void delMyArticle(){
        ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
        if ((err=ManagerContent.delMyArticle(idArticle)) !=0 ){
            //System.out.println("err="+err);
            String text;
            switch (err){
                case 1004:
                    text = msg.getString("err.db.1004");
                    break;
                default:
                    text = msg.getString("err.refused") + " err=" + err;
                    break;
            }
            FacesContext.getCurrentInstance().addMessage("MyArticleIEdit",
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, null, text));
        }else {
            catchArticleID();
            loadMyListIEdit();
        }
    }

    private void edit(boolean shortEdit){

        try {
            err = ManagerContent.editArticle(idArticle, nameArticle, shortValue, shortEdit?null:value, language.getLangName().toUpperCase(), shortEdit?null:getCategoryIDList());
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
            try {
                if (!FacesContext.getCurrentInstance().getExternalContext().isResponseCommitted())
                FacesContext.getCurrentInstance().getExternalContext().redirect("error.xhtml?error=baseNotConnect");
            } catch (IOException e) {
                e.printStackTrace();
            }
        } catch (ErrorInBase errorInBase) {
            try {
                if (!FacesContext.getCurrentInstance().getExternalContext().isResponseCommitted())
                FacesContext.getCurrentInstance().getExternalContext().redirect("error.xhtml?error=errorInBase");
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        if (err != 0) {
            String text;
            ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
            switch (err){
                case 1004:
                    text = msg.getString("err.db.1004");
                    break;
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
            FacesContext.getCurrentInstance().addMessage("add_article:categoryList", new FacesMessage(FacesMessage.SEVERITY_ERROR, null, msg.getString("err.manycategories")));
            return "#";
        }
        return null;
    }

    public String validNameArticleAjax(){
        final String PATTERN_NAME = "^[а-яА-ЯёЁa-zA-Z0-9 іІїЇєЄҐґ.!,?']{1,300}$";
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
            edit(true);
        }

        FacesContext.getCurrentInstance().addMessage("add_article:namearticle", new FacesMessage(FacesMessage.SEVERITY_INFO, null, "Ok "));
        return null;

    }

    public String saveToPublic(){
        //System.out.println("saveToPublic");
        ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());

        if (err != 0){
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "err= " + err, "err= " + err));
            return null;
        }
        if (validNameArticleAjax() != null || validCategoryAjax() != null ){
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, msg.getString("err.refused"), msg.getString("err.refused")));
            return null;
        }
        if (heightShortValue > (250 + (sessionBean.uEditor?10:0))){
            FacesContext.getCurrentInstance().addMessage("add_article:panel",
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, null, msg.getString("err.heightshortarticle")));
            return null;
        }

        if ((err=ManagerContent.changeStatusArticleToPublic(idArticle)) !=0 ){
            //System.out.println("saveToPublic ERR");
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
            return null;
        }else {
            System.out.println("saveToPublic OK");
            idArticle = null;
            return "article.xhtml";
        }

    }

    public String returnRevision(){
        System.out.println("returnRevision");
        ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());


        if (validNameArticleAjax() != null || validCategoryAjax() != null ){
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, msg.getString("err.refused"), msg.getString("err.refused")));
            return "#";
        }

        if ((err=ManagerContent.changeStatusArticleToEditUser(idArticle, comment)) !=0 ){
            String text;
            switch (err){
                case 1010:
                    text = msg.getString("err.db.1010");
                    break;
                case 1011:
                    text = msg.getString("err.db.1011");
                    break;
                case 1013:
                    text = msg.getString("err.db.1013");
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
            return "editorlistarticle.xhtml";
        }

    }

    public String saveToReadyPublic(){
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
        if (heightShortValue > (250 + (sessionBean.uEditor?10:0))){
            FacesContext.getCurrentInstance().addMessage("add_article:panel",
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, null, msg.getString("err.heightshortarticle")));
            return "#";
        }

        if ((err=ManagerContent.changeStatusArticleToReadyPublic(idArticle, null)) !=0 ){
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
            return null;
        }else {
                idArticle = null;
                return "okarticle.xhtml";
            }

    }

    public String iWillEdit(){
        //System.out.println("iWillEdit currSelIDArticle=" + currSelIDArticle);
        ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
        if (currSelIDArticle == 0) {
            FacesContext.getCurrentInstance().addMessage("formEditorReadyArticle",
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, null, msg.getString("err.idarticle")));
            return "#";
        }else{
            if ((err=ManagerContent.changeStatusArticleToEditEditor(currSelIDArticle)) !=0 ){
                //System.out.println("err="+err);
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
                FacesContext.getCurrentInstance().addMessage("formEditorReadyArticle",
                        new FacesMessage(FacesMessage.SEVERITY_ERROR, null, text));
                return "#";
            }else {
                //System.out.println("articleBean.ReadyEdit="+articleBean.getEditorReadyEdit().size());
                articleBean.loadEditorMyListEdit();
                articleBean.loadEditorReadyEdit();
                articleBean.loadEditorForeignEdit();
                //System.out.println("articleBean.ReadyEdit="+articleBean.getEditorReadyEdit().size());
            }
        }
        return null;
    }

    public String redoToReadyPublic(){
        //System.out.println("redoToReadyPublic currSelIDArticle=" + currSelIDArticle);
        ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
        if (currSelIDArticle == 0) {
            FacesContext.getCurrentInstance().addMessage("formEditorMyArticle",
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, null, msg.getString("err.idarticle")));
            return "#";
        }else{
            if ((err=ManagerContent.changeStatusArticleToReadyPublic(currSelIDArticle,null)) !=0 ){
                //System.out.println("err="+err);
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
                FacesContext.getCurrentInstance().addMessage("formEditorMyArticle",
                        new FacesMessage(FacesMessage.SEVERITY_ERROR, null, text));
                return "#";
            }else {
                //System.out.println("articleBean.ReadyEdit="+articleBean.getEditorReadyEdit().size());
                articleBean.loadEditorMyListEdit();
                articleBean.loadEditorReadyEdit();
                articleBean.loadEditorForeignEdit();
                //System.out.println("articleBean.ReadyEdit="+articleBean.getEditorReadyEdit().size());
            }
        }
        return null;
    }


    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        System.out.println("setValue");
        this.value = value;
        if (value != null) {
            edit(false);
        }
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
                for (Category cat : articleBean.getCategoryList()){
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

    public SessionBean getSessionBean() {
        return sessionBean;
    }

    public void setSessionBean(SessionBean sessionBean) {
        this.sessionBean = sessionBean;
    }

    public String getShortValue() {
        return shortValue;
    }

    public void setShortValue(String shortValue) {
        System.out.println("shortValue");
        if (!language.getLangISO().equals(localizationBean.getElectLocale())){
            ResourceBundle msg = localizationBean.getTextDependLangList().get(localizationBean.getElectLocale());
            FacesContext.getCurrentInstance().addMessage("add_article:sellang",
                    new FacesMessage(FacesMessage.SEVERITY_WARN, null, msg.getString("warn.articlelang")));

        }
        this.shortValue = shortValue;
        if (shortValue != null) {
            edit(true);
        }
    }

    public String getStringSelectedCategory() {
        if (selectedCategory!= null && selectedCategory.size() > 0){
            String stringSelectedCategory = "";
            for(Category cat : selectedCategory){
                stringSelectedCategory = stringSelectedCategory + cat.getCategoryName() + ",";
            }
            return stringSelectedCategory.substring(0, stringSelectedCategory.length() - 1);
        }
        return "";
    }

    public int getTypePage() {
        return typePage;
    }

    public void setTypePage(int typePage) {
        this.typePage = typePage;
    }

    public int getErr() {
        return err;
    }

    public void setErr(int err) {
        this.err = err;
    }

    public boolean isWorkEditor(){
        FacesContext facesContext = FacesContext.getCurrentInstance();
        HttpServletRequest request = (HttpServletRequest) facesContext.getExternalContext().getRequest();
        String uri=request.getRequestURI();

        System.out.println(uri);


        FacesContext.getCurrentInstance().getExternalContext().getRequestParameterMap();

        if (uri.equals("/view/editoreditarticle.xhtml") && sessionBean.uEditor){
            rulesok = true;
            return true;
        }
        else return false;

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

    public boolean isErrCritical() {
        return errCritical;
    }

    public void setErrCritical(boolean errCritical) {
        this.errCritical = errCritical;
    }

    public Integer getHeightShortValue() {
        return heightShortValue;
    }

    public void setHeightShortValue(Integer heightShortValue) {
        this.heightShortValue = heightShortValue;
    }

    public String getShowComment() {
        return showComment;
    }

    public void setShowComment(String showComment) {
        this.showComment = showComment;
    }

    public void loadMyListIEdit(){
        if (myListIEdit == null) myListIEdit = new ArrayList<>();
        ManagerContent.getMyArticleList(1, myListIEdit);
    }

    public List<Article> getMyListIEdit() {
        if (myListIEdit == null) loadMyListIEdit();
        return myListIEdit;
    }

    public void setMyListIEdit(List<Article> myListIEdit) {
        this.myListIEdit = myListIEdit;
    }

    public void loadMyListRedyToPublic(){
        if (myListRedyToPublic == null) myListRedyToPublic = new ArrayList<>();
        ManagerContent.getMyArticleList(3, myListRedyToPublic);
    }

    public List<Article> getMyListRedyToPublic() {
        if (myListRedyToPublic == null) loadMyListRedyToPublic();
        return myListRedyToPublic;
    }

    public void setMyListRedyToPublic(List<Article> myListRedyToPublic) {
        this.myListRedyToPublic = myListRedyToPublic;
    }

    public void loadMyListEditEditor(){
        if (myListEditEditor == null) myListEditEditor = new ArrayList<>();
        ManagerContent.getMyArticleList(2, myListEditEditor);
    }

    public List<Article> getMyListEditEditor() {
        if (myListEditEditor == null) loadMyListEditEditor();
        return myListEditEditor;
    }

    public void setMyListEditEditor(List<Article> myListEditEditor) {
        this.myListEditEditor = myListEditEditor;
    }


    public void paint(OutputStream stream, Object object) throws IOException {
        stream.write(getFiles().get((Integer) object).getData());
        stream.close();
    }

    public long getTimeStamp() {
        return System.currentTimeMillis();
    }

    public void listenerUpload(FileUploadEvent event) throws Exception {
        UploadedFile item = event.getUploadedFile();
        UploadedImage file = new UploadedImage();
        file.setLength(item.getData().length/1024);
        file.setName(item.getName());
        file.setData(item.getData());
        files.add(file);
        uploadsAvailable--;
    }

    public void searchFilesForArticle(){
        if (files == null) files = new ArrayList();
    }

    public ArrayList<UploadedImage> getFiles() {
        if (files==null) searchFilesForArticle();
        return files;
    }

    public void setFiles(ArrayList<UploadedImage> files) {
        this.files = files;
    }

    public int getUploadsAvailable() {
        return uploadsAvailable;
    }

    public void setUploadsAvailable(int uploadsAvailable) {
        this.uploadsAvailable = uploadsAvailable;
    }
}
