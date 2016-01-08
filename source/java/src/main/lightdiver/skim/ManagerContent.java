package main.lightdiver.skim;

import main.lightdiver.skim.DAO.ArticleDAO;
import main.lightdiver.skim.entity.Article;
import main.lightdiver.skim.exceptions.BaseNotConnect;
import main.lightdiver.skim.exceptions.ErrorInBase;

import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.servlet.http.HttpServletRequest;
import java.util.List;

public class ManagerContent {

    public static int getMyActiveArticle(Article outArticle) {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();

        try {
            return ArticleDAO.getMyActiveArticle((String)externalContext.getSessionMap().get("userSession"), (String)externalContext.getSessionMap().get("userKey"), getIP(),outArticle);
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
            return -1;
        }

    }
    public static int getEditorArticle(String sArticleID, Article outArticle) {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        int ArticleID = Integer.parseInt(sArticleID);
        try {
            return ArticleDAO.getEditorArticle(ArticleID, (String) externalContext.getSessionMap().get("userSession"), (String) externalContext.getSessionMap().get("userKey"), getIP(), outArticle);
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
            return -1;
        }

    }

    public static int editArticle(Integer articleID, String title, String shortContent, String content, String lang, String categoryIDList ) throws BaseNotConnect, ErrorInBase {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        int err = -1;
        err = ArticleDAO.editArticle((String)externalContext.getSessionMap().get("userSession"), (String)externalContext.getSessionMap().get("userKey"), getIP(), articleID, title, shortContent, content, lang, categoryIDList );
        return err;
    }

    public static int createArticle(Article outArticle, String title,String shortContent, String content, String lang ) {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        int err = -1;
        try {
            err = ArticleDAO.createArticle((String)externalContext.getSessionMap().get("userSession"), (String)externalContext.getSessionMap().get("userKey"), getIP(),  outArticle,  title, shortContent,  content,  lang );
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
        }
        return err;
    }

    public static int changeStatusArticleToReadyPublic(Integer articleID) {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        int err = -1;
        try {
            err = ArticleDAO.changeStatusArticle((String) externalContext.getSessionMap().get("userSession"), (String) externalContext.getSessionMap().get("userKey"), getIP(), articleID, 3, null);
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
        }
        return err;
    }
    public static int changeStatusArticleToPublic(Integer articleID) {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        int err = -1;
        try {
            err = ArticleDAO.changeStatusArticle((String) externalContext.getSessionMap().get("userSession"), (String) externalContext.getSessionMap().get("userKey"), getIP(), articleID, 4, null);
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
        }
        return err;
    }

    public static int changeStatusArticleToEditUser(Integer articleID, String comment) {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        int err = -1;
        try {
            err = ArticleDAO.changeStatusArticle((String) externalContext.getSessionMap().get("userSession"), (String) externalContext.getSessionMap().get("userKey"), getIP(), articleID, 1, comment);
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
        }
        return err;
    }

    public static int changeStatusArticleToEditEditor(Integer articleID) {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        int err = -1;
        try {
            err = ArticleDAO.changeStatusArticle((String) externalContext.getSessionMap().get("userSession"), (String) externalContext.getSessionMap().get("userKey"), getIP(), articleID, 2, null);
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
        }
        return err;
    }


    public static int getEditorArticleList(Integer statusID,Integer iEditor, List<Article> outListArticle) {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        int err = -1;
        try {
            err = ArticleDAO.getEditorArticleList((String) externalContext.getSessionMap().get("userSession"), (String) externalContext.getSessionMap().get("userKey"), getIP(), statusID,iEditor, outListArticle);
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
        }
        return err;
    }

    public static int getPublicArticleList(List<Article> outListArticle) {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        int err = -1;
        try {
            err = ArticleDAO.getPublicArticleList((String) externalContext.getSessionMap().get("userSession"), (String) externalContext.getSessionMap().get("userKey"), getIP(), outListArticle);
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
        }
        return err;
    }

    public static int getArticle(String articleID, Article outArticle) {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        int err = -1;
        try {
            err = ArticleDAO.getArticle((String) externalContext.getSessionMap().get("userSession"), (String) externalContext.getSessionMap().get("userKey"), getIP(), Integer.parseInt(articleID), outArticle);
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
        }
        return err;
    }

    private static String getIP(){
        HttpServletRequest request = (HttpServletRequest) FacesContext.getCurrentInstance().getExternalContext().getRequest();
        String ipAddress = request.getHeader("X-FORWARDED-FOR");
        if ( ipAddress == null ) {
            ipAddress = request.getRemoteAddr();
        }
        return ipAddress;
    }


}
