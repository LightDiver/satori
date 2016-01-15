package main.lightdiver.skim.entity;

import java.sql.Timestamp;

public class Article {
    private Integer articleId;
    private String title;
    private String shortContent;
    private String content;
    private String creator;
    private String editor;
    private String lang;
    private Integer status;
    private Timestamp createDate;
    private Timestamp editDate;
    private Timestamp publicDate;
    private Integer[] categoryIDList;
    private String categoryNameList;
    private String comment;


    public Integer getArticleId() {
        return articleId;
    }

    public void setArticleId(Integer articleId) {
        this.articleId = articleId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getLang() {
        return lang;
    }

    public void setLang(String lang) {
        this.lang = lang;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public Integer[] getCategoryIDList() {
        return categoryIDList;
    }

    public void setCategoryIDList(Integer[] categoryIDList) {
        this.categoryIDList = categoryIDList;
    }

    public String getShortContent() {
        return shortContent;
    }

    public void setShortContent(String shortContent) {
        this.shortContent = shortContent;
    }

    public String getCreator() {
        return creator;
    }

    public void setCreator(String creator) {
        this.creator = creator;
    }

    public String getEditor() {
        return editor;
    }

    public void setEditor(String editor) {
        this.editor = editor;
    }

    public Timestamp getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Timestamp createDate) {
        this.createDate = createDate;
    }

    public Timestamp getEditDate() {
        return editDate;
    }

    public void setEditDate(Timestamp editDate) {
        this.editDate = editDate;
    }

    public Timestamp getPublicDate() {
        return publicDate;
    }

    public void setPublicDate(Timestamp publicDate) {
        this.publicDate = publicDate;
    }

    public String getCategoryNameList() {
        return categoryNameList;
    }

    public void setCategoryNameList(String categoryNameList) {
        this.categoryNameList = categoryNameList;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }
}
