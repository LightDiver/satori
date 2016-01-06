package main.lightdiver.skim.DAO;

import main.lightdiver.skim.entity.Article;
import main.lightdiver.skim.exceptions.BaseNotConnect;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;
import java.util.logging.Logger;

public class ArticleDAO {
    private final static Logger logger = Logger.getLogger(ArticleDAO.class.getName());


    public static int createArticle(String userSession, String userKey, String ipAddress, Article outArticle, String title, String shortContent, String content, String lang ) throws BaseNotConnect {
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        int res = -1;
        try {
            cs = con.prepareCall("{? = call pkg_article.create_new_article(?, ?, ?, ?, ?, ?, ?, ?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.registerOutParameter(5, Types.INTEGER);
            cs.setString(6, title);
            cs.setString(7, shortContent);
            cs.setString(8, content);
            cs.setString(9, lang);
            cs.execute();
            res = cs.getInt(1);
            if (res == 0){
                outArticle.setArticleId(cs.getInt(1));
            }
            cs.close();
            return res;
        } catch (SQLException e) {
            e.printStackTrace();
            logger.severe("" + e);
        }
        finally {
            ConnectionPool.putConn(con);
        }
        return res;
    }

    public static int editArticle(String userSession, String userKey, String ipAddress, Integer articleID, String title,String shortContent, String content, String lang, String categoryIDList ) throws BaseNotConnect {
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        int res = -1;
        try {
            cs = con.prepareCall("{? = call pkg_article.edit_article(?, ?, ?, ?, ?, ?, ?, ?,?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.setInt(5, articleID);
            cs.setString(6, title);
            cs.setString(7, shortContent);
            cs.setString(8, content);
            cs.setString(9, lang);
            cs.setString(10,categoryIDList);
            cs.execute();
            res = cs.getInt(1);
            cs.close();
            return res;
        } catch (SQLException e) {
            e.printStackTrace();
            logger.severe("" + e);
        }
        finally {
            ConnectionPool.putConn(con);
        }
        return res;
    }

    public static int getMyActiveArticle(String userSession, String userKey, String ipAddress, Article outArticle) throws BaseNotConnect {
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        int res = -1;
        try {
            cs = con.prepareCall("{? = call pkg_article.get_last_edit_active_article(?, ?, ?, ?, ?, ?, ?, ?, ?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.registerOutParameter(5, Types.INTEGER);
            cs.registerOutParameter(6, Types.VARCHAR);
            cs.registerOutParameter(7, Types.VARCHAR);
            cs.registerOutParameter(8, Types.VARCHAR);
            cs.registerOutParameter(9, Types.VARCHAR);
            cs.registerOutParameter(10, Types.VARCHAR);
            cs.execute();

            res = cs.getInt(1);
            if (res == 0){
                outArticle.setArticleId(cs.getInt(5)) ;
                outArticle.setTitle(cs.getString(6));
                outArticle.setShortContent(cs.getString(7));
                outArticle.setContent(cs.getString(8));
                outArticle.setLang(cs.getString(9));
                if (cs.getString(10) != null) {
                    String[] s = cs.getString(10).split(",");
                    Integer[] n_val = new Integer[s.length];
                    for (int i = 0; i < s.length; i++) {
                        n_val[i] = Integer.parseInt(s[i]);
                    }
                    outArticle.setCategoryIDList(n_val);
                }
            }
            cs.close();
            return res;
        } catch (SQLException e) {
            e.printStackTrace();
            logger.severe("" + e);
        }
        finally {
            ConnectionPool.putConn(con);
        }
        return res;
    }

    public static int getEditorArticle(Integer ArticleID, String userSession, String userKey, String ipAddress, Article outArticle) throws BaseNotConnect {
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        int res = -1;
        try {
            cs = con.prepareCall("{? = call pkg_article.get_edit_editor_article(?, ?, ?, ?, ?, ?, ?, ?, ?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.setInt(5, ArticleID);
            cs.registerOutParameter(6, Types.VARCHAR);
            cs.registerOutParameter(7, Types.VARCHAR);
            cs.registerOutParameter(8, Types.VARCHAR);
            cs.registerOutParameter(9, Types.VARCHAR);
            cs.registerOutParameter(10, Types.VARCHAR);
            cs.execute();

            res = cs.getInt(1);
            if (res == 0){
                outArticle.setArticleId(ArticleID);
                outArticle.setTitle(cs.getString(6));
                outArticle.setShortContent(cs.getString(7));
                outArticle.setContent(cs.getString(8));
                outArticle.setLang(cs.getString(9));
                if (cs.getString(10) != null) {
                    String[] s = cs.getString(10).split(",");
                    Integer[] n_val = new Integer[s.length];
                    for (int i = 0; i < s.length; i++) {
                        n_val[i] = Integer.parseInt(s[i]);
                    }
                    outArticle.setCategoryIDList(n_val);
                }
            }
            cs.close();
            return res;
        } catch (SQLException e) {
            e.printStackTrace();
            logger.severe("" + e);
        }
        finally {
            ConnectionPool.putConn(con);
        }
        return res;
    }

    public static int changeStatusArticle(String userSession, String userKey, String ipAddress, Integer articleID, Integer newStatusID) throws BaseNotConnect {
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        int res = -1;
        try {
            cs = con.prepareCall("{? = call pkg_article.change_status_article(?, ?, ?, ?, ?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.setInt(5,articleID);
            cs.setInt(6,newStatusID);
            cs.execute();

            res = cs.getInt(1);

            cs.close();
            return res;
        } catch (SQLException e) {
            e.printStackTrace();
            logger.severe("" + e);
        }
        finally {
            ConnectionPool.putConn(con);
        }
        return res;
    }
}
