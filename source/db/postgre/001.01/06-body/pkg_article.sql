SET CLIENT_ENCODING TO 'WIN1251';

CREATE OR REPLACE FUNCTION pkg_article.get_article_list_public_new5(
    IN i_session_id numeric,
    IN i_key_id character varying,
    IN i_terminal_ip character varying,
    OUT o_error_id numeric,
    OUT o_items refcursor)
  RETURNS record AS
$BODY$
    DECLARE
    /* Повернути статті що опубліковані (Останных 5 опублікованих)
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE := 24;
  
  BEGIN
    
    SELECT o.o_error_id, o.o_user_id FROM pkg_users.active_session(i_session_id,
                                           i_key_id,
                                           i_terminal_ip,
                                           c_perm_act
                                           ) o
    INTO o_error_id, v_user_id;
  
    IF o_error_id <> 0 THEN
      RETURN;
    END IF;
  
    OPEN o_items FOR
      SELECT a.article_id,
                     a.article_title,
                     a.article_lang,
                     a.article_public_date,
                     u.user_login
                FROM article a, users u
               WHERE a.article_status_id = 4
                 AND a.article_creator_id = u.user_id
               ORDER BY a.article_public_date DESC limit  5;
  
    RETURN;
  EXCEPTION
    WHEN SQLSTATE 'NPRIV' THEN
      o_error_id = 1004;
      RETURN;
  END;
$BODY$
  LANGUAGE plpgsql
