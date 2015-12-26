package main.lightdiver.skim;

import main.lightdiver.skim.DAO.ArticleDAO;
import main.lightdiver.skim.entity.Article;
import main.lightdiver.skim.exceptions.BaseNotConnect;

import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.servlet.http.HttpServletRequest;

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

    public static int editArticle(Integer articleID, String title, String content, String lang ){
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        int err = -1;
        try {
            err = ArticleDAO.editArticle((String)externalContext.getSessionMap().get("userSession"), (String)externalContext.getSessionMap().get("userKey"), getIP(), articleID, title, content, lang );
        } catch (BaseNotConnect baseNotConnect) {
            baseNotConnect.printStackTrace();
        }
        return err;
    }

    public static int createArticle(Article outArticle, String title, String content, String lang ) {
        ExternalContext externalContext = FacesContext.getCurrentInstance().getExternalContext();
        int err = -1;
        try {
            err = ArticleDAO.createArticle((String)externalContext.getSessionMap().get("userSession"), (String)externalContext.getSessionMap().get("userKey"), getIP(),  outArticle,  title,  content,  lang );
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
