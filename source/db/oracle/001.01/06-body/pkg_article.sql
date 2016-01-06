CREATE OR REPLACE PACKAGE BODY pkg_article IS

  FUNCTION create_new_article(i_session_id      user_session.session_id%TYPE,
                              i_key_id          user_session.key_id%TYPE,
                              i_terminal_ip     user_session.terminal_ip%TYPE,
                              o_article_id      OUT article.article_id%TYPE,
                              i_article_title   article.article_title%TYPE,
                              i_article_short   article.article_short%TYPE,
                              i_article_content article.article_content%TYPE,
                              i_article_lang    article.article_lang%TYPE)
    RETURN error_desc.error_desc_id%TYPE AS
    /* Додавання статті
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
    */
    v_error_id error_desc.error_desc_id%TYPE;
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE := 14;
  
  BEGIN
    v_error_id := pkg_users.active_session(i_session_id,
                                           i_key_id,
                                           i_terminal_ip,
                                           c_perm_act,
                                           v_user_id);
    IF v_error_id <> 0 THEN
      RETURN v_error_id;
    END IF;
  
    o_article_id := article_id_seq.nextval;
  
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
  
    RETURN v_error_id;
  
  EXCEPTION
    WHEN pkg_users.insufficient_privileges THEN
      v_error_id := 1004;
      RETURN v_error_id;
  END create_new_article;

  FUNCTION edit_article(i_session_id       user_session.session_id%TYPE,
                        i_key_id           user_session.key_id%TYPE,
                        i_terminal_ip      user_session.terminal_ip%TYPE,
                        i_article_id       article.article_id%TYPE,
                        i_article_title    article.article_title%TYPE,
                        i_article_short    article.article_short%TYPE,
                        i_article_content  article.article_content%TYPE,
                        i_article_lang     article.article_lang%TYPE,
                        i_article_category VARCHAR2)
    RETURN error_desc.error_desc_id%TYPE AS
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
    v_error_id           error_desc.error_desc_id%TYPE := 0;
    v_user_id            user_session.user_id%TYPE;
    c_perm_act           action_type.action_type_id%TYPE := 20;
    v_article_status     article.article_status_id%TYPE;
    v_article_creator_id article.article_creator_id%TYPE;
    v_article_editor_id  article.article_editor_id%TYPE;
  BEGIN
    v_error_id := pkg_users.active_session(i_session_id,
                                           i_key_id,
                                           i_terminal_ip,
                                           c_perm_act,
                                           v_user_id);
  
    IF v_error_id <> 0 THEN
      RETURN v_error_id;
    END IF;
  
    BEGIN
    
      SELECT a.article_status_id, a.article_creator_id, a.article_editor_id
        INTO v_article_status, v_article_creator_id, v_article_editor_id
        FROM article a
       WHERE a.article_id = i_article_id;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN 1011;
    END;
  
    IF v_article_status NOT IN (1, 2) THEN
      v_error_id := 1008;
      RETURN v_error_id;
    END IF;
  
    IF v_article_status = 1 AND NOT (v_article_creator_id = v_user_id AND
        v_article_creator_id IS NOT NULL) THEN
      v_error_id := 1006;
      RETURN v_error_id;
    END IF;
  
    IF v_article_status = 2 AND NOT (v_article_editor_id = v_user_id AND
        v_article_editor_id IS NOT NULL) THEN
      v_error_id := 1007;
      RETURN v_error_id;
    END IF;
  
    IF i_article_content IS NULL AND i_article_short IS NULL THEN
      v_error_id := 1012;
      RETURN v_error_id;
    END IF;
  
    IF i_article_content IS NULL THEN
      UPDATE article a
         SET a.article_title = i_article_title,
             a.article_short = i_article_short,
             
             a.article_lang = i_article_lang
       WHERE a.article_id = i_article_id;
    
    ELSE
      UPDATE article a
         SET a.article_title   = i_article_title,
             a.article_short   = i_article_short,
             a.article_content = i_article_content,
             a.article_lang    = i_article_lang
       WHERE a.article_id = i_article_id;
    
      DELETE FROM category_article_link c
       WHERE c.article_id = i_article_id;
    
      IF i_article_category IS NOT NULL AND i_article_category <> ',' THEN
        FOR cur IN (SELECT regexp_substr(str, '[^,]+', 1, LEVEL) str
                      FROM (SELECT rtrim(i_article_category, ',') str
                              FROM dual) t
                    CONNECT BY instr(str, ',', 1, LEVEL - 1) > 0) LOOP
          INSERT INTO category_article_link
          VALUES
            (to_number(cur.str), i_article_id);
        END LOOP;
      END IF;
    
    END IF;
  
    RETURN v_error_id;
  
  EXCEPTION
    WHEN pkg_users.insufficient_privileges THEN
      v_error_id := 1004;
      RETURN v_error_id;
  END edit_article;

  FUNCTION user_is_editor(i_user_id users.user_id%TYPE) RETURN BOOLEAN AS
    v_cnt NUMBER(1);
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
  END user_is_editor;

  FUNCTION change_status_article(i_session_id         user_session.session_id%TYPE,
                                 i_key_id             user_session.key_id%TYPE,
                                 i_terminal_ip        user_session.terminal_ip%TYPE,
                                 i_article_id         article.article_id%TYPE,
                                 i_atricle_status_new article.article_status_id%TYPE)
    RETURN error_desc.error_desc_id%TYPE AS
    /* Зміна статусу статті
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
            1009 - Параметр _новий статус статті_ задано невірно
            1010 - Зміна статусу статті неможлива
            1011 - Пусто
         */
    v_error_id           error_desc.error_desc_id%TYPE := 0;
    v_user_id            user_session.user_id%TYPE;
    c_perm_act           action_type.action_type_id%TYPE;
    v_article_status     article.article_status_id%TYPE;
    v_article_creator_id article.article_creator_id%TYPE;
    v_article_editor_id  article.article_editor_id%TYPE;
    v_is_editor          BOOLEAN;
  BEGIN
    CASE i_atricle_status_new
      WHEN NULL THEN
        v_error_id := 1009;
        RETURN v_error_id;
      WHEN 1 THEN
        --Редагується автором
        c_perm_act := 15;
      WHEN 2 THEN
        --Редагується редактором
        c_perm_act := 16;
      WHEN 3 THEN
        --Готова до публікації 
        c_perm_act := 17;
      WHEN 4 THEN
        --Опубліковано
        c_perm_act := 18;
    END CASE;
  
    v_error_id := pkg_users.active_session(i_session_id,
                                           i_key_id,
                                           i_terminal_ip,
                                           c_perm_act,
                                           v_user_id);
    IF v_error_id <> 0 THEN
      RETURN v_error_id;
    END IF;
    v_is_editor := user_is_editor(v_user_id);
  
    BEGIN
    
      SELECT a.article_status_id, a.article_creator_id, a.article_editor_id
        INTO v_article_status, v_article_creator_id, v_article_editor_id
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
          UPDATE article a
             SET a.article_status_id = i_atricle_status_new
           WHERE a.article_id = i_article_id;
        ELSE
          RETURN 1010;
        END IF;
      WHEN 2 THEN
        --Редагується редактором
        IF v_article_status IN (2, 3) AND v_is_editor THEN
          UPDATE article a
             SET a.article_status_id = i_atricle_status_new,
                 a.article_editor_id = v_user_id
           WHERE a.article_id = i_article_id;
        ELSE
          RETURN 1010;
        END IF;
      WHEN 3 THEN
        --Готова до публікації 
        IF v_article_status = 1 AND v_user_id = v_article_creator_id THEN
          UPDATE article a
             SET a.article_status_id = i_atricle_status_new
           WHERE a.article_id = i_article_id;
        ELSE
          RETURN 1010;
        END IF;
      
      WHEN 4 THEN
        --Опубліковано
        IF v_article_status = 2 AND v_user_id = v_article_editor_id AND
           v_is_editor THEN
          UPDATE article a
             SET a.article_status_id   = i_atricle_status_new,
                 a.article_public_date = localtimestamp
           WHERE a.article_id = i_article_id;
        ELSE
          RETURN 1010;
        END IF;
      
    END CASE;
  
    RETURN v_error_id;
  
  EXCEPTION
  
    WHEN pkg_users.insufficient_privileges THEN
      v_error_id := 1004;
      RETURN v_error_id;
  END change_status_article;

  FUNCTION get_last_edit_active_article(i_session_id       user_session.session_id%TYPE,
                                        i_key_id           user_session.key_id%TYPE,
                                        i_terminal_ip      user_session.terminal_ip%TYPE,
                                        o_article_id       OUT article.article_id%TYPE,
                                        o_article_title    OUT article.article_title%TYPE,
                                        o_article_short    OUT article.article_short%TYPE,
                                        o_article_content  OUT article.article_content%TYPE,
                                        o_article_lang     OUT article.article_lang%TYPE,
                                        o_article_category OUT VARCHAR2)
    RETURN error_desc.error_desc_id%TYPE AS
    /* Повернути статтю яка в статусі Редагування автором
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
                 1011 - Пусто
    */
    v_error_id error_desc.error_desc_id%TYPE := 0;
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE := 19;
  BEGIN
    v_error_id := pkg_users.active_session(i_session_id,
                                           i_key_id,
                                           i_terminal_ip,
                                           c_perm_act,
                                           v_user_id);
  
    IF v_error_id <> 0 THEN
      RETURN v_error_id;
    END IF;
  
    SELECT a.article_id,
           a.article_title,
           a.article_short,
           a.article_content,
           a.article_lang
      INTO o_article_id,
           o_article_title,
           o_article_short,
           o_article_content,
           o_article_lang
      FROM article a
     WHERE a.article_creator_id = v_user_id
       AND a.article_status_id = 1
       AND rownum() < 2;
  
    SELECT listagg(c.category_id, ',') within GROUP(ORDER BY c.category_id)
      INTO o_article_category
      FROM category_article_link c
     WHERE c.article_id = o_article_id;
  
    RETURN v_error_id;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 1011;
    WHEN pkg_users.insufficient_privileges THEN
      v_error_id := 1004;
      RETURN v_error_id;
  END get_last_edit_active_article;

  FUNCTION get_edit_editor_article(i_session_id       user_session.session_id%TYPE,
                                   i_key_id           user_session.key_id%TYPE,
                                   i_terminal_ip      user_session.terminal_ip%TYPE,
                                   i_article_id       article.article_id%TYPE,
                                   o_article_title    OUT article.article_title%TYPE,
                                   o_article_short    OUT article.article_short%TYPE,
                                   o_article_content  OUT article.article_content%TYPE,
                                   o_article_lang     OUT article.article_lang%TYPE,
                                   o_article_category OUT VARCHAR2)
    RETURN error_desc.error_desc_id%TYPE AS
    /* Повернути статтю яка в статусі Редагування редактором за умови що редактором він і є
    Помилки:
                     1004 - Недостатньо повноважень
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
                 1011 - Пусто
    */
    v_error_id error_desc.error_desc_id%TYPE := 0;
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE := 21;
  
  BEGIN
    v_error_id := pkg_users.active_session(i_session_id,
                                           i_key_id,
                                           i_terminal_ip,
                                           c_perm_act,
                                           v_user_id);
  
    IF v_error_id <> 0 THEN
      RETURN v_error_id;
    END IF;
    IF NOT user_is_editor(v_user_id) THEN
      RETURN 1004;
    END IF;
  
    SELECT a.article_title,
           a.article_short,
           a.article_content,
           a.article_lang
      INTO o_article_title,
           o_article_short,
           o_article_content,
           o_article_lang
      FROM article a
     WHERE a.article_editor_id = v_user_id
       AND a.article_status_id = 2
       AND a.article_id = i_article_id;
  
    SELECT listagg(c.category_id, ',') within GROUP(ORDER BY c.category_id)
      INTO o_article_category
      FROM category_article_link c
     WHERE c.article_id = i_article_id;
  
    RETURN v_error_id;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 1011;
    WHEN pkg_users.insufficient_privileges THEN
      v_error_id := 1004;
      RETURN v_error_id;
  END get_edit_editor_article;

END pkg_article;
