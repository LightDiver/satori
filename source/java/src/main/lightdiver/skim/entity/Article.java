package main.lightdiver.skim.entity;

public class Article {
    private Integer articleId;
    private String title;
    private String content;
    private String lang;
    private Integer status;
    private Integer[] categoryIDList;


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
}