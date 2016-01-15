package main.lightdiver.skim.DAO;

import main.lightdiver.skim.entity.Article;
import main.lightdiver.skim.entity.UsersAction;
import main.lightdiver.skim.exceptions.BaseNotConnect;
import main.lightdiver.skim.exceptions.ErrorInBase;

import java.sql.*;
import java.util.List;
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
                outArticle.setArticleId(cs.getInt(5));
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

    public static int editArticle(String userSession, String userKey, String ipAddress, Integer articleID, String title,String shortContent, String content, String lang, String categoryIDList ) throws BaseNotConnect, ErrorInBase {
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
            throw new ErrorInBase();
        }
        finally {
            ConnectionPool.putConn(con);
        }

    }

    public static int getMyActiveArticle(String userSession, String userKey, String ipAddress, Article outArticle) throws BaseNotConnect {
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        int res = -1;
        try {
            cs = con.prepareCall("{? = call pkg_article.get_last_edit_active_article(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.registerOutParameter(5, Types.INTEGER);
            cs.registerOutParameter(6, Types.VARCHAR);
            cs.registerOutParameter(7, Types.VARCHAR);
            cs.registerOutParameter(8, Types.CLOB);
            cs.registerOutParameter(9, Types.VARCHAR);
            cs.registerOutParameter(10, Types.VARCHAR);
            cs.registerOutParameter(11, Types.VARCHAR);
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
                outArticle.setComment(cs.getString(11));
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

    public static int getMyArticle(Integer ArticleID, String userSession, String userKey, String ipAddress, Article outArticle) throws BaseNotConnect {
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        int res = -1;
        try {
            cs = con.prepareCall("{? = call pkg_article.get_edit_my_article(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.setInt(5, ArticleID);
            cs.registerOutParameter(6, Types.VARCHAR);
            cs.registerOutParameter(7, Types.VARCHAR);
            cs.registerOutParameter(8, Types.CLOB);
            cs.registerOutParameter(9, Types.VARCHAR);
            cs.registerOutParameter(10, Types.VARCHAR);
            cs.registerOutParameter(11, Types.VARCHAR);
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
                outArticle.setComment(cs.getString(11));
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
            cs = con.prepareCall("{? = call pkg_article.get_edit_editor_article(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.setInt(5, ArticleID);
            cs.registerOutParameter(6, Types.VARCHAR);
            cs.registerOutParameter(7, Types.VARCHAR);
            cs.registerOutParameter(8, Types.CLOB);
            cs.registerOutParameter(9, Types.VARCHAR);
            cs.registerOutParameter(10, Types.VARCHAR);
            cs.registerOutParameter(11, Types.VARCHAR);
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
                outArticle.setComment(cs.getString(11));
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

    public static int changeStatusArticle(String userSession, String userKey, String ipAddress, Integer articleID, Integer newStatusID, String comment) throws BaseNotConnect {
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        int res = -1;
        try {
            cs = con.prepareCall("{? = call pkg_article.change_status_article(?, ?, ?, ?, ?, ?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.setInt(5,articleID);
            cs.setInt(6,newStatusID);
            cs.setString(7, comment);
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


    public static int getMyArticleList(String userSession, String userKey, String ipAddress, Integer statusID, List<Article> outListArticle) throws BaseNotConnect {
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        outListArticle.clear();
        int res = -1;
        try {
            cs = con.prepareCall("{? = call pkg_article.get_my_article_list(?, ?, ?, ?, ?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            if(statusID==null) cs.setNull(5,Types.INTEGER) ;else cs.setInt(5, statusID);
            cs.registerOutParameter(6, ConnectionPool.TypeCursor());

            cs.execute();

            res = cs.getInt(1);
            if (res == 0) {
                ResultSet rset = (ResultSet)cs.getObject(6);
                while (rset.next ()){
                    Article article = new Article();
                    article.setArticleId(rset.getInt(1));
                    article.setTitle(rset.getString(2));
                    article.setLang(rset.getString(3));
                    article.setCreateDate(rset.getTimestamp(4));
                    article.setPublicDate(rset.getTimestamp(5));
                    article.setEditDate(rset.getTimestamp(6));
                    //get Cat if need
                    article.setComment(rset.getString(8));


                    outListArticle.add(article);

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

    public static int getEditorArticleList(String userSession, String userKey, String ipAddress, Integer statusID, Integer iEditor, List<Article> outListArticle) throws BaseNotConnect {
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        outListArticle.clear();
        int res = -1;
        try {
            cs = con.prepareCall("{? = call pkg_article.get_editor_article_list(?, ?, ?, ?, ?,?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            if(statusID==null) cs.setNull(5,Types.INTEGER) ;else cs.setInt(5, statusID);
            if(iEditor==null) cs.setNull(6,Types.INTEGER) ;else cs.setInt(6, iEditor);
            cs.registerOutParameter(7, ConnectionPool.TypeCursor());

            cs.execute();

            res = cs.getInt(1);
            if (res == 0) {
                ResultSet rset = (ResultSet)cs.getObject(7);
                while (rset.next ()){
                    Article article = new Article();
                    article.setArticleId(rset.getInt(1));
                    article.setTitle(rset.getString(2));
                    article.setLang(rset.getString(3));
                    article.setCreator(rset.getString(4));
                    article.setEditor(rset.getString(5));
                    article.setCreateDate(rset.getTimestamp(6));
                    article.setPublicDate(rset.getTimestamp(7));
                    article.setEditDate(rset.getTimestamp(8));
                    article.setComment(rset.getString(9));
                    //get Cat

                    outListArticle.add(article);

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


    public static int getPublicArticleList(String userSession, String userKey, String ipAddress, Integer CategoryID, List<Article> outListArticle) throws BaseNotConnect {
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        outListArticle.clear();
        int res = -1;
        try {
            cs = con.prepareCall("{? = call pkg_article.get_article_list_public(?, ?, ?, ?, ?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            if(CategoryID==null) cs.setNull(5,Types.INTEGER) ;else cs.setInt(5, CategoryID);
            cs.registerOutParameter(6, ConnectionPool.TypeCursor());

            cs.execute();

            res = cs.getInt(1);
            if (res == 0) {
                ResultSet rset = (ResultSet)cs.getObject(6);
                while (rset.next ()){
                    Article article = new Article();
                    article.setArticleId(rset.getInt(1));
                    article.setTitle(rset.getString(2));
                    article.setShortContent(rset.getString(3));
                    article.setLang(rset.getString(4));
                    article.setCreator(rset.getString(5));
                    article.setEditor(rset.getString(6));
                    article.setCreateDate(rset.getTimestamp(7));
                    article.setPublicDate(rset.getTimestamp(8));
                    article.setEditDate(rset.getTimestamp(9));

                    if (rset.getString(10) != null) {
                        String[] s = rset.getString(10).split(",");
                        Integer[] n_val = new Integer[s.length];
                        for (int i = 0; i < s.length; i++) {
                            n_val[i] = Integer.parseInt(s[i]);
                        }
                        article.setCategoryIDList(n_val);
                    }

                    outListArticle.add(article);

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

    public static int getPublicArticleListNew5(String userSession, String userKey, String ipAddress, List<Article> outListArticle) throws BaseNotConnect {
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        outListArticle.clear();
        int res = -1;
        try {
            cs = con.prepareCall("{? = call pkg_article.get_article_list_public_new5(?, ?, ?, ?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.registerOutParameter(5, ConnectionPool.TypeCursor());

            cs.execute();

            res = cs.getInt(1);
            if (res == 0) {
                ResultSet rset = (ResultSet)cs.getObject(5);
                while (rset.next ()){
                    Article article = new Article();
                    article.setArticleId(rset.getInt(1));
                    article.setTitle(rset.getString(2));
                    article.setLang(rset.getString(3));
                    article.setPublicDate(rset.getTimestamp(4));
                    article.setCreator(rset.getString(5));

                    outListArticle.add(article);

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

    public static int getArticle(String userSession, String userKey, String ipAddress, Integer articleID, Article outArticle) throws BaseNotConnect {
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        int res = -1;
        try {
            cs = con.prepareCall("{? = call pkg_article.get_article(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.setInt(5, articleID);
            cs.registerOutParameter(6, Types.VARCHAR);
            cs.registerOutParameter(7, Types.VARCHAR);
            cs.registerOutParameter(8, Types.CLOB);
            cs.registerOutParameter(9, Types.VARCHAR);
            cs.registerOutParameter(10, Types.VARCHAR);
            cs.registerOutParameter(11, Types.TIMESTAMP);
            cs.registerOutParameter(12, Types.VARCHAR);
            cs.execute();

            res = cs.getInt(1);
            if (res == 0){
                outArticle.setArticleId(articleID) ;
                outArticle.setTitle(cs.getString(6));
                outArticle.setShortContent(cs.getString(7));
                outArticle.setContent(cs.getString(8));
                outArticle.setLang(cs.getString(9));
                outArticle.setCreator(cs.getString(10));
                outArticle.setPublicDate(cs.getTimestamp(11));

                if (cs.getString(12) != null) {
                    String[] s = cs.getString(12).split(",");
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


    public static int delMyArticle(String userSession, String userKey, String ipAddress, Integer articleID) throws BaseNotConnect {
        Connection con = ConnectionPool.takeConn();
        CallableStatement cs = null;
        int res = -1;
        try {
            cs = con.prepareCall("{? = call pkg_article.del_my_article(?, ?, ?, ?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, userSession);
            cs.setString(3, userKey);
            cs.setString(4, ipAddress);
            cs.setInt(5,articleID);

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
