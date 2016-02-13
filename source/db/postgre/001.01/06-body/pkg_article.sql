SET CLIENT_ENCODING TO 'WIN1251';

CREATE OR REPLACE FUNCTION pkg_article.create_new_article(
    IN i_session_id numeric,
    IN i_key_id character varying,
    IN i_terminal_ip character varying,
    IN i_article_title character varying,
    IN i_article_short character varying,
    IN i_article_content text,
    IN i_article_lang character varying,
    OUT o_error_id numeric,
    OUT o_article_id numeric)
  RETURNS record AS
$BODY$
    DECLARE
    /* Додавання статті
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
    */
  
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE = 14;
  
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
  
    o_article_id = nextval('article_id_seq');
  
    INSERT INTO article
      (article_id,
       article_title,
       article_content,
       article_short,
       article_status_id,
       article_create_date,
       article_creator_id,
       article_public_date,
       article_editor_id,
       article_lang)
    VALUES
      (o_article_id,
       i_article_title,
       i_article_short,
       i_article_content,
       1,
       localtimestamp,
       v_user_id,
       NULL,
       NULL,
       i_article_lang);
  
    RETURN;
  
  EXCEPTION
    WHEN SQLSTATE 'NPRIV' THEN
      o_error_id = 1004;
      RETURN;
  END;

$BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pkg_article.get_edit_my_article(
    IN i_session_id numeric,
    IN i_key_id character varying,
    IN i_terminal_ip character varying,
    IN i_article_id numeric,
    OUT o_error_id numeric,
    OUT o_article_title character varying,
    OUT o_article_short character varying,
    OUT o_article_content text,
    OUT o_article_lang character varying,
    OUT o_article_category character varying,
    OUT o_comment character varying)
  RETURNS record AS
$BODY$
    DECLARE
    /* Повернути статтю яка в статусі Редагування користувачем за умови що створювачем він і є
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
                 1011 - Пусто
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE = 20;
  
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
  
    SELECT a.article_title,
           a.article_short,
           a.article_content,
           a.article_lang,
           a.article_comment
      INTO strict o_article_title,
           o_article_short,
           o_article_content,
           o_article_lang,
           o_comment
      FROM article a
     WHERE a.article_creator_id = v_user_id
       AND a.article_status_id = 1
       AND a.article_id = i_article_id;
  
     SELECT string_agg(cast(c.category_id as varchar), ',')
		INTO o_article_category
                FROM category_article_link c
               WHERE c.article_id = i_article_id;
  
    RETURN;
  EXCEPTION
    WHEN no_data_found THEN
      o_error_id = 1011;
      RETURN;
    WHEN SQLSTATE 'NPRIV'  THEN
      o_error_id = 1004;
      RETURN;
  END;
  $BODY$
  LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION pkg_article.edit_article(
    i_session_id numeric,
    i_key_id character varying,
    i_terminal_ip character varying,
    i_article_id numeric,
    i_article_title character varying,
    i_article_short character varying,
    i_article_content text,
    i_article_lang character varying,
    i_article_category character varying)
  RETURNS numeric AS
$BODY$
    DECLARE
    /* Редагування статті
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
         1006 - Поточний статус(редагується автором) статті не дозволяє її редагувати
         1007 - Поточний статус(редагується редактором) статті не дозволяє її редагувати
         1008 - Поточний статус статті не дозволяє її редагувати
         1011 - Пусто
         1012 - Не задано ні заголовку ні тексту статті
    */
    v_error_id           error_desc.error_desc_id%TYPE = 0;
    v_user_id            user_session.user_id%TYPE;
    c_perm_act           action_type.action_type_id%TYPE = 20;
    v_article_status     article.article_status_id%TYPE;
    v_article_creator_id article.article_creator_id%TYPE;
    v_article_editor_id  article.article_editor_id%TYPE;
    cur record;
  BEGIN
    SELECT o.o_error_id, o.o_user_id FROM pkg_users.active_session(i_session_id,
                                           i_key_id,
                                           i_terminal_ip,
                                           c_perm_act
                                           ) o
    INTO v_error_id, v_user_id;
  
    IF v_error_id <> 0 THEN
      RETURN v_error_id;
    END IF;
  
    BEGIN
    
      SELECT  a.article_status_id, a.article_creator_id, a.article_editor_id
        INTO strict v_article_status, v_article_creator_id, v_article_editor_id
        FROM article a
       WHERE a.article_id = i_article_id;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN 1011;
    END;
  
    IF v_article_status NOT IN (1, 2) THEN
      v_error_id = 1008;
      RETURN v_error_id;
    END IF;
  
    IF v_article_status = 1 AND NOT (v_article_creator_id = v_user_id AND
        v_article_creator_id IS NOT NULL) THEN
      v_error_id = 1006;
      RETURN v_error_id;
    END IF;
  
    IF v_article_status = 2 AND NOT (v_article_editor_id = v_user_id AND
        v_article_editor_id IS NOT NULL) THEN
      v_error_id = 1007;
      RETURN v_error_id;
    END IF;
  
    IF i_article_content IS NULL AND i_article_short IS NULL THEN
      v_error_id = 1012;
      RETURN v_error_id;
    END IF;
  
    IF i_article_content IS NULL THEN
      UPDATE article
         SET article_title = i_article_title,
             article_short = i_article_short,
             
             article_lang      = i_article_lang,
             article_edit_date = CASE
                                     WHEN v_article_editor_id = v_user_id AND
                                          article_status_id = 2 THEN
                                      localtimestamp
                                     ELSE
                                      article_edit_date
                                   END
       WHERE article_id = i_article_id;
    
    ELSE
      UPDATE article
         SET article_title     = i_article_title,
             article_short     = i_article_short,
             article_content   = i_article_content,
             article_lang      = i_article_lang,
             article_edit_date = CASE
                                     WHEN v_article_editor_id = v_user_id AND
                                          article_status_id = 2 THEN
                                      localtimestamp
                                     ELSE
                                      article_edit_date
                                   END
       WHERE article_id = i_article_id;
    
      DELETE FROM category_article_link
       WHERE article_id = i_article_id;
    
      IF i_article_category IS NOT NULL AND i_article_category <> ',' AND i_article_category <> '' THEN
        FOR cur IN (select str from regexp_split_to_table(rtrim(i_article_category,','), ',') str) LOOP
          INSERT INTO category_article_link
          VALUES
            (cast(cur.str as integer), i_article_id);
        END LOOP;
      END IF;
    
    END IF;
  
    RETURN v_error_id;
  
  EXCEPTION
    WHEN SQLSTATE 'NPRIV'  THEN
      v_error_id = 1004;
      RETURN v_error_id;
  END;

$BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pkg_article.user_is_editor(i_user_id numeric)
  RETURNS boolean AS
$BODY$
    DECLARE
    v_cnt NUMERIC(1);
  BEGIN
    SELECT COUNT(1)
      INTO v_cnt
      FROM users_role ur
     WHERE ur.user_id = i_user_id
       AND ur.role_id = 4;
    IF v_cnt = 0 THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END ;
$BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pkg_article.change_status_article(
    i_session_id numeric,
    i_key_id character varying,
    i_terminal_ip character varying,
    i_article_id numeric,
    i_atricle_status_new numeric,
    i_comment character varying)
  RETURNS numeric AS
$BODY$
    DECLARE
    /* Зміна статусу статті
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
            1009 - Параметр _новий статус статті_ задано невірно
            1010 - Зміна статусу статті неможлива
            1011 - Пусто
            1013 - Не задана причина(більше 5ти символів) зміни статусу статті
         */
    v_error_id           error_desc.error_desc_id%TYPE = 0;
    v_user_id            user_session.user_id%TYPE;
    c_perm_act           action_type.action_type_id%TYPE;
    v_article_status     article.article_status_id%TYPE;
    v_article_creator_id article.article_creator_id%TYPE;
    v_article_editor_id  article.article_editor_id%TYPE;
    v_is_editor          BOOLEAN;
  BEGIN
    CASE i_atricle_status_new
      WHEN NULL THEN
        v_error_id = 1009;
        RETURN v_error_id;
      WHEN 1 THEN
        --Редагується автором
        c_perm_act = 15;
      WHEN 2 THEN
        --Редагується редактором
        c_perm_act = 16;
      WHEN 3 THEN
        --Готова до публікації
        c_perm_act = 17;
      WHEN 4 THEN
        --Опубліковано
        c_perm_act = 18;
    END CASE;
  
    SELECT o.o_error_id, o.o_user_id FROM pkg_users.active_session(i_session_id,
                                           i_key_id,
                                           i_terminal_ip,
                                           c_perm_act
                                           ) o
    INTO v_error_id, v_user_id;

    IF v_error_id <> 0 THEN
      RETURN v_error_id;
    END IF;
    v_is_editor = pkg_article.user_is_editor(v_user_id);
  
    BEGIN
    
      SELECT a.article_status_id, a.article_creator_id, a.article_editor_id
        INTO strict v_article_status, v_article_creator_id, v_article_editor_id
        FROM article a
       WHERE a.article_id = i_article_id;
    
    EXCEPTION
      WHEN no_data_found THEN
        RETURN 1011;
    END;
  
    CASE i_atricle_status_new
      WHEN 1 THEN
        --Редагується автором
        IF v_article_status = 3 AND v_user_id = v_article_creator_id THEN
          UPDATE article
             SET article_status_id = i_atricle_status_new
           WHERE article_id = i_article_id;
        ELSIF v_article_status = 2 AND v_user_id = v_article_editor_id THEN
          IF i_comment IS NULL OR length(i_comment) <= 5 THEN
            RETURN 1013;
          END IF;
          UPDATE article
             SET article_status_id = i_atricle_status_new,
                 article_comment   = i_comment
           WHERE article_id = i_article_id;
        ELSE
          RETURN 1010;
        END IF;
      WHEN 2 THEN
        --Редагується редактором
        IF v_article_status IN (2, 3) AND v_is_editor THEN
          UPDATE article
             SET article_status_id = i_atricle_status_new,
                 article_editor_id = v_user_id,
                 article_edit_date = localtimestamp
           WHERE article_id = i_article_id;
        ELSE
          RETURN 1010;
        END IF;
      WHEN 3 THEN
        --Готова до публікації
        IF v_article_status = 1 AND v_user_id = v_article_creator_id THEN
          UPDATE article
             SET article_status_id   = i_atricle_status_new,
                 article_create_date = localtimestamp
           WHERE article_id = i_article_id;
        ELSIF v_article_status = 2 AND v_user_id = v_article_editor_id THEN
          UPDATE article
             SET article_status_id = i_atricle_status_new
           WHERE article_id = i_article_id;
        ELSIF v_article_status = 4 AND v_is_editor THEN
          IF i_comment IS NULL OR length(i_comment) <= 5 THEN
            RETURN 1013;
          END IF;
          UPDATE article
             SET article_status_id = i_atricle_status_new,
                 article_comment   = i_comment
           WHERE article_id = i_article_id;
        
        ELSE
          RETURN 1010;
        END IF;
      
      WHEN 4 THEN
        --Опубліковано
        IF v_article_status = 2 AND v_user_id = v_article_editor_id AND
           v_is_editor THEN
          UPDATE article
             SET article_status_id   = i_atricle_status_new,
                 article_public_date = localtimestamp,
                 article_comment     = NULL
           WHERE article_id = i_article_id;
        ELSE
          RETURN 1010;
        END IF;
      
    END CASE;
  
    RETURN v_error_id;
  
  EXCEPTION
  
    WHEN SQLSTATE 'NPRIV'  THEN
      v_error_id = 1004;
      RETURN v_error_id;
  END;

$BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pkg_article.get_last_edit_active_article(
    IN i_session_id numeric,
    IN i_key_id character varying,
    IN i_terminal_ip character varying,
    OUT o_error_id numeric,
    OUT o_article_id numeric,
    OUT o_article_title character varying,
    OUT o_article_short character varying,
    OUT o_article_content text,
    OUT o_article_lang character varying,
    OUT o_article_category character varying,
    OUT o_comment character varying)
  RETURNS record AS
$BODY$
    DECLARE
    /* Повернути статтю яка в статусі Редагування автором
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
                 1011 - Пусто
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE = 19;
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
  
    SELECT a.article_id,
           a.article_title,
           a.article_short,
           a.article_content,
           a.article_lang,
           a.article_comment
      INTO strict o_article_id,
           o_article_title,
           o_article_short,
           o_article_content,
           o_article_lang,
           o_comment
      FROM article a
     WHERE a.article_creator_id = v_user_id
       AND a.article_status_id = 1
       limit 1;
  
     SELECT string_agg(cast(c.category_id as varchar), ',')
		INTO o_article_category
                FROM category_article_link c
               WHERE c.article_id = o_article_id;
  
    RETURN;
  EXCEPTION
    WHEN no_data_found THEN
      o_error_id = 1011;
      RETURN;
    WHEN SQLSTATE 'NPRIV' THEN
      o_error_id = 1004;
      RETURN;
  END;
$BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pkg_article.get_my_article_list(
    IN i_session_id numeric,
    IN i_key_id character varying,
    IN i_terminal_ip character varying,
    IN i_article_status_id numeric,
    OUT o_error_id numeric,
    OUT o_items refcursor)
  RETURNS record AS
$BODY$
    DECLARE
    /* Повернути мої статті яка в певному статусі
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE = 26;
  
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
             a.article_create_date,
             a.article_public_date,
             a.article_edit_date,
             (SELECT string_agg(cast(c.category_id as varchar), ',')
                FROM category_article_link c
               WHERE c.article_id = a.article_id) article_category,
             a.article_comment
        FROM article a
       WHERE (i_article_status_id IS NULL OR
             a.article_status_id = i_article_status_id)
         AND a.article_creator_id = v_user_id;
  
    RETURN;
  EXCEPTION
    WHEN  SQLSTATE 'NPRIV'  THEN
      o_error_id = 1004;
      RETURN;
  END;
  $BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pkg_article.get_article_list_public(
    IN i_session_id numeric,
    IN i_key_id character varying,
    IN i_terminal_ip character varying,
    IN i_article_cat_id numeric,
    IN i_lang_id character varying,
    OUT o_error_id numeric,
    OUT o_items refcursor)
  RETURNS record AS
$BODY$
    DECLARE
    /* Повернути статті що опубліковані
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE = 24;
  
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
             a.article_short,
             a.article_lang,
             uc.user_login,
             ue.user_login,
             a.article_create_date,
             a.article_public_date,
             a.article_edit_date,
             (SELECT string_agg(cast(c.category_id as varchar), ',')
                FROM category_article_link c
               WHERE c.article_id = a.article_id) article_category
        FROM article a
       INNER JOIN users uc
          ON uc.user_id = a.article_creator_id
        LEFT JOIN users ue
          ON ue.user_id = a.article_editor_id
       WHERE a.article_status_id = 4
         AND (i_article_cat_id IS NULL OR
             a.article_id IN
             (SELECT l.article_id
                 FROM category_article_link l
                WHERE i_article_cat_id = l.category_id) OR
             --Якщо 1.Інше і стаття не привязана до жодної категорії
             (i_article_cat_id = 1 AND
             0 = (SELECT COUNT(1)
                      FROM category_article_link l2
                     WHERE l2.article_id = a.article_id)))
            --Мова
         AND (i_lang_id IS NULL OR a.article_lang = i_lang_id);
  
    RETURN;
  EXCEPTION
    WHEN SQLSTATE 'NPRIV'  THEN
      o_error_id = 1004;
      RETURN;
  END ;
  $BODY$
  LANGUAGE plpgsql; 

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
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pkg_article.get_edit_editor_article(
    IN i_session_id numeric,
    IN i_key_id character varying,
    IN i_terminal_ip character varying,
    IN i_article_id numeric,
    OUT o_error_id numeric,
    OUT o_article_title character varying,
    OUT o_article_short character varying,
    OUT o_article_content text,
    OUT o_article_lang character varying,
    OUT o_article_category character varying,
    OUT o_comment character varying)
  RETURNS record AS
$BODY$
    DECLARE
    /* Повернути статтю яка в статусі Редагування редактором за умови що редактором він і є
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
                 1011 - Пусто
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE = 21;
  
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
    IF NOT pkg_article.user_is_editor(v_user_id) THEN
      o_error_id = 1004;
      RETURN;
    END IF;
  
    SELECT a.article_title,
           a.article_short,
           a.article_content,
           a.article_lang,
           a.article_comment
      INTO strict o_article_title,
           o_article_short,
           o_article_content,
           o_article_lang,
           o_comment
      FROM article a
     WHERE a.article_editor_id = v_user_id
       AND a.article_status_id = 2
       AND a.article_id = i_article_id;
  
     SELECT string_agg(cast(c.category_id as varchar), ',')
		INTO o_article_category
                FROM category_article_link c
               WHERE c.article_id = i_article_id;
  
    RETURN;
  EXCEPTION
    WHEN no_data_found THEN
      o_error_id = 1011;
      RETURN;
    WHEN SQLSTATE 'NPRIV' THEN
      o_error_id = 1004;
      RETURN;
  END;
  $BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pkg_article.get_editor_article_list(
    IN i_session_id numeric,
    IN i_key_id character varying,
    IN i_terminal_ip character varying,
    IN i_article_status_id numeric,
    IN i_my_working numeric,
    OUT o_error_id numeric,
    OUT o_items refcursor)
  RETURNS record AS
$BODY$
    DECLARE
    /* Повернути статті яка в певному статусі або всі якщо null
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE = 23;
  
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
    IF NOT pkg_article.user_is_editor(v_user_id) THEN
      o_error_id = 1004;
      RETURN;
    END IF;
  
    OPEN o_items FOR
      SELECT a.article_id,
             a.article_title,
             a.article_lang,
             uc.user_login,
             ue.user_login,
             a.article_create_date,
             a.article_public_date,
             a.article_edit_date,
            (SELECT string_agg(cast(c.category_id as varchar), ',')
                FROM category_article_link c
               WHERE c.article_id = a.article_id) article_category,
             a.article_comment
        FROM article a
       INNER JOIN users uc
          ON uc.user_id = a.article_creator_id
        LEFT JOIN users ue
          ON ue.user_id = a.article_editor_id
       WHERE (i_article_status_id IS NULL OR
             a.article_status_id = i_article_status_id)
         AND (i_my_working IS NULL OR
             (i_my_working = 1 AND a.article_editor_id = v_user_id) OR
             (i_my_working = 2 AND a.article_editor_id <> v_user_id));
  
    RETURN;
  EXCEPTION
    WHEN SQLSTATE 'NPRIV'  THEN
      o_error_id = 1004;
      RETURN;
  END;
  $BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pkg_article.get_article(
    IN i_session_id numeric,
    IN i_key_id character varying,
    IN i_terminal_ip character varying,
    IN i_article_id numeric,
    OUT o_error_id numeric,
    OUT o_article_title character varying,
    OUT o_article_short character varying,
    OUT o_article_content text,
    OUT o_article_lang character varying,
    OUT o_creator character varying,
    OUT o_public_date timestamp without time zone,
    OUT o_article_category character varying)
  RETURNS record AS
$BODY$
    DECLARE
    /* Повернути статтю яка в статусі Опублікована (або якщо власник чи редактор, то в любому статусі)
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
                 1011 - Пусто
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE = 25;
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
  
    SELECT a.article_title,
           a.article_short,
           a.article_content,
           a.article_lang,
           uc.user_login,
           a.article_public_date
      INTO strict  o_article_title,
           o_article_short,
           o_article_content,
           o_article_lang,
           o_creator,
           o_public_date
      FROM article a, users uc
     WHERE a.article_id = i_article_id
       AND (a.article_status_id = 4 OR a.article_creator_id = v_user_id OR
           a.article_editor_id = v_user_id)
       AND a.article_creator_id = uc.user_id;
  
     SELECT string_agg(cast(c.category_id as varchar), ',')
		INTO o_article_category
                FROM category_article_link c
               WHERE c.article_id = i_article_id;
  
    RETURN;
  EXCEPTION
    WHEN no_data_found THEN
      o_error_id = 1011;
      RETURN;
    WHEN SQLSTATE 'NPRIV'  THEN
      o_error_id = 1004;
      RETURN;
  END;
  $BODY$
  LANGUAGE plpgsql ;

CREATE OR REPLACE FUNCTION pkg_article.del_my_article(
    i_session_id numeric,
    i_key_id character varying,
    i_terminal_ip character varying,
    i_article_id numeric)
  RETURNS numeric AS
$BODY$
    DECLARE
    /* Видалити мою статтю в статусі Редагування користувачем
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
    */
    v_error_id error_desc.error_desc_id%TYPE = 0;
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE = 27;
  BEGIN
SELECT o.o_error_id, o.o_user_id FROM pkg_users.active_session(i_session_id,
                                           i_key_id,
                                           i_terminal_ip,
                                           c_perm_act
                                           ) o
    INTO v_error_id, v_user_id;
  
    IF v_error_id <> 0 THEN
      RETURN v_error_id;
    END IF;
  
    DELETE FROM article
     WHERE article_id = i_article_id
       AND article_status_id = 1
       AND article_creator_id = v_user_id;
  
    RETURN v_error_id;
  EXCEPTION
    WHEN SQLSTATE 'NPRIV'  THEN
      v_error_id = 1004;
      RETURN v_error_id;
  END;
  $BODY$
  LANGUAGE plpgsql; 