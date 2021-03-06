CREATE OR REPLACE PACKAGE BODY pkg_article IS

  PROCEDURE create_new_article(i_session_id      user_session.session_id%TYPE,
                               i_key_id          user_session.key_id%TYPE,
                               i_terminal_ip     user_session.terminal_ip%TYPE,
                               i_article_title   article.article_title%TYPE,
                               i_article_short   article.article_short%TYPE,
                               i_article_content article.article_content%TYPE,
                               i_article_lang    article.article_lang%TYPE,
                               o_error_id        OUT error_desc.error_desc_id%TYPE,
                               o_article_id      OUT article.article_id%TYPE) AS
    /* ��������� �����
    �������:
         ����������� 1004 - ����������� �����������
                     1002 - ���� �� ���� ��� ������
                     1003 - IP ��� ������
    */
  
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE := 14;
  
  BEGIN
    pkg_users.active_session(i_session_id,
                             i_key_id,
                             i_terminal_ip,
                             c_perm_act,
                             o_error_id,
                             v_user_id);
    IF o_error_id <> 0 THEN
      RETURN;
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
  
    RETURN;
  
  EXCEPTION
    WHEN pkg_users.insufficient_privileges THEN
      o_error_id := 1004;
      RETURN;
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
    /* ����������� �����
    �������:
         ����������� 1004 - ����������� �����������
                  ���1002 - ���� �� ���� ��� ������
                     1003 - IP ��� ������
         1006 - �������� ������(���������� �������) ����� �� �������� �� ����������
         1007 - �������� ������(���������� ����������) ����� �� �������� �� ����������
         1008 - �������� ������ ����� �� �������� �� ����������
         1011 - �����
         1012 - �� ������ �� ��������� �� ������ �����
    */
    v_error_id           error_desc.error_desc_id%TYPE := 0;
    v_user_id            user_session.user_id%TYPE;
    c_perm_act           action_type.action_type_id%TYPE := 20;
    v_article_status     article.article_status_id%TYPE;
    v_article_creator_id article.article_creator_id%TYPE;
    v_article_editor_id  article.article_editor_id%TYPE;
  BEGIN
    pkg_users.active_session(i_session_id,
                             i_key_id,
                             i_terminal_ip,
                             c_perm_act,
                             v_error_id,
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
             
             a.article_lang      = i_article_lang,
             a.article_edit_date = CASE
                                     WHEN v_article_editor_id = v_user_id AND
                                          a.article_status_id = 2 THEN
                                      localtimestamp
                                     ELSE
                                      a.article_edit_date
                                   END
       WHERE a.article_id = i_article_id;
    
    ELSE
      UPDATE article a
         SET a.article_title     = i_article_title,
             a.article_short     = i_article_short,
             a.article_content   = i_article_content,
             a.article_lang      = i_article_lang,
             a.article_edit_date = CASE
                                     WHEN v_article_editor_id = v_user_id AND
                                          a.article_status_id = 2 THEN
                                      localtimestamp
                                     ELSE
                                      a.article_edit_date
                                   END
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
                                 i_atricle_status_new article.article_status_id%TYPE,
                                 i_comment            article.article_comment%TYPE)
    RETURN error_desc.error_desc_id%TYPE AS
    /* ���� ������� �����
    �������:
         ����������� 1004 - ����������� �����������
         ����������� 1002 - ���� �� ���� ��� ������
                     1003 - IP ��� ������
            1009 - �������� _����� ������ �����_ ������ ������
            1010 - ���� ������� ����� ���������
            1011 - �����
            1013 - �� ������ �������(����� 5�� �������) ���� ������� �����
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
        --���������� �������
        c_perm_act := 15;
      WHEN 2 THEN
        --���������� ����������
        c_perm_act := 16;
      WHEN 3 THEN
        --������ �� ���������
        c_perm_act := 17;
      WHEN 4 THEN
        --�����������
        c_perm_act := 18;
    END CASE;
  
    pkg_users.active_session(i_session_id,
                             i_key_id,
                             i_terminal_ip,
                             c_perm_act,
                             v_error_id,
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
        --���������� �������
        IF v_article_status = 3 AND v_user_id = v_article_creator_id THEN
          UPDATE article a
             SET a.article_status_id = i_atricle_status_new
           WHERE a.article_id = i_article_id;
        ELSIF v_article_status = 2 AND v_user_id = v_article_editor_id THEN
          IF i_comment IS NULL OR length(i_comment) <= 5 THEN
            RETURN 1013;
          END IF;
          UPDATE article a
             SET a.article_status_id = i_atricle_status_new,
                 a.article_comment   = i_comment
           WHERE a.article_id = i_article_id;
        ELSE
          RETURN 1010;
        END IF;
      WHEN 2 THEN
        --���������� ����������
        IF v_article_status IN (2, 3) AND v_is_editor THEN
          UPDATE article a
             SET a.article_status_id = i_atricle_status_new,
                 a.article_editor_id = v_user_id,
                 a.article_edit_date = localtimestamp
           WHERE a.article_id = i_article_id;
        ELSE
          RETURN 1010;
        END IF;
      WHEN 3 THEN
        --������ �� ���������
        IF v_article_status = 1 AND v_user_id = v_article_creator_id THEN
          UPDATE article a
             SET a.article_status_id   = i_atricle_status_new,
                 a.article_create_date = localtimestamp
           WHERE a.article_id = i_article_id;
        ELSIF v_article_status = 2 AND v_user_id = v_article_editor_id THEN
          UPDATE article a
             SET a.article_status_id = i_atricle_status_new
           WHERE a.article_id = i_article_id;
        ELSIF v_article_status = 4 AND v_is_editor THEN
          IF i_comment IS NULL OR length(i_comment) <= 5 THEN
            RETURN 1013;
          END IF;
          UPDATE article a
             SET a.article_status_id = i_atricle_status_new,
                 a.article_comment   = i_comment
           WHERE a.article_id = i_article_id;
        
        ELSE
          RETURN 1010;
        END IF;
      
      WHEN 4 THEN
        --�����������
        IF v_article_status = 2 AND v_user_id = v_article_editor_id AND
           v_is_editor THEN
          UPDATE article a
             SET a.article_status_id   = i_atricle_status_new,
                 a.article_public_date = localtimestamp,
                 a.article_comment     = NULL
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

  PROCEDURE get_last_edit_active_article(i_session_id       user_session.session_id%TYPE,
                                         i_key_id           user_session.key_id%TYPE,
                                         i_terminal_ip      user_session.terminal_ip%TYPE,
                                         o_error_id         OUT error_desc.error_desc_id%TYPE,
                                         o_article_id       OUT article.article_id%TYPE,
                                         o_article_title    OUT article.article_title%TYPE,
                                         o_article_short    OUT article.article_short%TYPE,
                                         o_article_content  OUT article.article_content%TYPE,
                                         o_article_lang     OUT article.article_lang%TYPE,
                                         o_article_category OUT VARCHAR2,
                                         o_comment          OUT article.article_comment%TYPE) AS
    /* ��������� ������ ��� � ������ ����������� �������
    �������:
         ����������� 1004 - ����������� �����������
                  ���1002 - ���� �� ���� ��� ������
                     1003 - IP ��� ������
                 1011 - �����
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE := 19;
  BEGIN
    pkg_users.active_session(i_session_id,
                             i_key_id,
                             i_terminal_ip,
                             c_perm_act,
                             o_error_id,
                             v_user_id);
  
    IF o_error_id <> 0 THEN
      RETURN;
    END IF;
  
    SELECT a.article_id,
           a.article_title,
           a.article_short,
           a.article_content,
           a.article_lang,
           a.article_comment
      INTO o_article_id,
           o_article_title,
           o_article_short,
           o_article_content,
           o_article_lang,
           o_comment
      FROM article a
     WHERE a.article_creator_id = v_user_id
       AND a.article_status_id = 1
       AND rownum() < 2;
  
    SELECT listagg(c.category_id, ',') within GROUP(ORDER BY c.category_id)
      INTO o_article_category
      FROM category_article_link c
     WHERE c.article_id = o_article_id;
  
    RETURN;
  EXCEPTION
    WHEN no_data_found THEN
      o_error_id := 1011;
      RETURN;
    WHEN pkg_users.insufficient_privileges THEN
      o_error_id := 1004;
      RETURN;
  END get_last_edit_active_article;

  PROCEDURE get_edit_my_article(i_session_id       user_session.session_id%TYPE,
                                i_key_id           user_session.key_id%TYPE,
                                i_terminal_ip      user_session.terminal_ip%TYPE,
                                i_article_id       article.article_id%TYPE,
                                o_error_id         OUT error_desc.error_desc_id%TYPE,
                                o_article_title    OUT article.article_title%TYPE,
                                o_article_short    OUT article.article_short%TYPE,
                                o_article_content  OUT article.article_content%TYPE,
                                o_article_lang     OUT article.article_lang%TYPE,
                                o_article_category OUT VARCHAR2,
                                o_comment          OUT article.article_comment%TYPE) AS
    /* ��������� ������ ��� � ������ ����������� ������������ �� ����� �� ����������� �� � �
    �������:
         ����������� 1004 - ����������� �����������
                  ���1002 - ���� �� ���� ��� ������
                     1003 - IP ��� ������
                 1011 - �����
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE := 20;
  
  BEGIN
    pkg_users.active_session(i_session_id,
                             i_key_id,
                             i_terminal_ip,
                             c_perm_act,
                             o_error_id,
                             v_user_id);
  
    IF o_error_id <> 0 THEN
      RETURN;
    END IF;
  
    SELECT a.article_title,
           a.article_short,
           a.article_content,
           a.article_lang,
           a.article_comment
      INTO o_article_title,
           o_article_short,
           o_article_content,
           o_article_lang,
           o_comment
      FROM article a
     WHERE a.article_creator_id = v_user_id
       AND a.article_status_id = 1
       AND a.article_id = i_article_id;
  
    SELECT listagg(c.category_id, ',') within GROUP(ORDER BY c.category_id)
      INTO o_article_category
      FROM category_article_link c
     WHERE c.article_id = i_article_id;
  
    RETURN;
  EXCEPTION
    WHEN no_data_found THEN
      o_error_id := 1011;
      RETURN;
    WHEN pkg_users.insufficient_privileges THEN
      o_error_id := 1004;
      RETURN;
  END get_edit_my_article;

  PROCEDURE get_edit_editor_article(i_session_id       user_session.session_id%TYPE,
                                    i_key_id           user_session.key_id%TYPE,
                                    i_terminal_ip      user_session.terminal_ip%TYPE,
                                    i_article_id       article.article_id%TYPE,
                                    o_error_id         OUT error_desc.error_desc_id%TYPE,
                                    o_article_title    OUT article.article_title%TYPE,
                                    o_article_short    OUT article.article_short%TYPE,
                                    o_article_content  OUT article.article_content%TYPE,
                                    o_article_lang     OUT article.article_lang%TYPE,
                                    o_article_category OUT VARCHAR2,
                                    o_comment          OUT article.article_comment%TYPE) AS
    /* ��������� ������ ��� � ������ ����������� ���������� �� ����� �� ���������� �� � �
    �������:
         ����������� 1004 - ����������� �����������
                  ���1002 - ���� �� ���� ��� ������
                     1003 - IP ��� ������
                 1011 - �����
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE := 21;
  
  BEGIN
    pkg_users.active_session(i_session_id,
                             i_key_id,
                             i_terminal_ip,
                             c_perm_act,
                             o_error_id,
                             v_user_id);
  
    IF o_error_id <> 0 THEN
      RETURN;
    END IF;
    IF NOT user_is_editor(v_user_id) THEN
      o_error_id := 1004;
      RETURN;
    END IF;
  
    SELECT a.article_title,
           a.article_short,
           a.article_content,
           a.article_lang,
           a.article_comment
      INTO o_article_title,
           o_article_short,
           o_article_content,
           o_article_lang,
           o_comment
      FROM article a
     WHERE a.article_editor_id = v_user_id
       AND a.article_status_id = 2
       AND a.article_id = i_article_id;
  
    SELECT listagg(c.category_id, ',') within GROUP(ORDER BY c.category_id)
      INTO o_article_category
      FROM category_article_link c
     WHERE c.article_id = i_article_id;
  
    RETURN;
  EXCEPTION
    WHEN no_data_found THEN
      o_error_id := 1011;
      RETURN;
    WHEN pkg_users.insufficient_privileges THEN
      o_error_id := 1004;
      RETURN;
  END get_edit_editor_article;

  PROCEDURE get_my_article_list(i_session_id        user_session.session_id%TYPE,
                                i_key_id            user_session.key_id%TYPE,
                                i_terminal_ip       user_session.terminal_ip%TYPE,
                                i_article_status_id article.article_status_id%TYPE,
                                o_error_id          OUT error_desc.error_desc_id%TYPE,
                                o_items             OUT SYS_REFCURSOR) AS
    /* ��������� �� ����� ��� � ������� ������
    �������:
         ����������� 1004 - ����������� �����������
                  ���1002 - ���� �� ���� ��� ������
                     1003 - IP ��� ������
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE := 26;
  
  BEGIN
    pkg_users.active_session(i_session_id,
                             i_key_id,
                             i_terminal_ip,
                             c_perm_act,
                             o_error_id,
                             v_user_id);
  
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
             (SELECT listagg(c.category_id, ',') within GROUP(ORDER BY c.category_id)
                FROM category_article_link c
               WHERE c.article_id = a.article_id) article_category,
             a.article_comment
        FROM article a
       WHERE (i_article_status_id IS NULL OR
             a.article_status_id = i_article_status_id)
         AND a.article_creator_id = v_user_id;
  
    RETURN;
  EXCEPTION
    WHEN pkg_users.insufficient_privileges THEN
      o_error_id := 1004;
      RETURN;
  END get_my_article_list;

  PROCEDURE get_editor_article_list(i_session_id        user_session.session_id%TYPE,
                                    i_key_id            user_session.key_id%TYPE,
                                    i_terminal_ip       user_session.terminal_ip%TYPE,
                                    i_article_status_id article.article_status_id%TYPE,
                                    i_my_working        NUMBER, --1 � ��������, 2-����, null-���������
                                    o_error_id          OUT error_desc.error_desc_id%TYPE,
                                    o_items             OUT SYS_REFCURSOR) AS
    /* ��������� ����� ��� � ������� ������ ��� �� ���� null
    �������:
         ����������� 1004 - ����������� �����������
                  ���1002 - ���� �� ���� ��� ������
                     1003 - IP ��� ������
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE := 23;
  
  BEGIN
    pkg_users.active_session(i_session_id,
                             i_key_id,
                             i_terminal_ip,
                             c_perm_act,
                             o_error_id,
                             v_user_id);
  
    IF o_error_id <> 0 THEN
      RETURN;
    END IF;
    IF NOT user_is_editor(v_user_id) THEN
      o_error_id := 1004;
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
             (SELECT listagg(c.category_id, ',') within GROUP(ORDER BY c.category_id)
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
    WHEN pkg_users.insufficient_privileges THEN
      o_error_id := 1004;
      RETURN;
  END get_editor_article_list;

  PROCEDURE get_article_list_public(i_session_id     user_session.session_id%TYPE,
                                    i_key_id         user_session.key_id%TYPE,
                                    i_terminal_ip    user_session.terminal_ip%TYPE,
                                    i_article_cat_id category_article.category_id%TYPE,
                                    i_lang_id        article.article_lang%TYPE,
                                    o_error_id       OUT error_desc.error_desc_id%TYPE,
                                    o_items          OUT SYS_REFCURSOR) AS
    /* ��������� ����� �� �����������
    �������:
         ����������� 1004 - ����������� �����������
                  ���1002 - ���� �� ���� ��� ������
                     1003 - IP ��� ������
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE := 24;
  
  BEGIN
    pkg_users.active_session(i_session_id,
                             i_key_id,
                             i_terminal_ip,
                             c_perm_act,
                             o_error_id,
                             v_user_id);
  
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
             (SELECT listagg(c.category_id, ',') within GROUP(ORDER BY c.category_id)
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
             --���� 1.���� � ������ �� ��������� �� ����� �������
             (i_article_cat_id = 1 AND
             0 = (SELECT COUNT(1)
                      FROM category_article_link l2
                     WHERE l2.article_id = a.article_id)))
            --����
         AND (i_lang_id IS NULL OR a.article_lang = i_lang_id);
  
    RETURN;
  EXCEPTION
    WHEN pkg_users.insufficient_privileges THEN
      o_error_id := 1004;
      RETURN;
  END get_article_list_public;

  PROCEDURE get_article_list_public_new5(i_session_id  user_session.session_id%TYPE,
                                         i_key_id      user_session.key_id%TYPE,
                                         i_terminal_ip user_session.terminal_ip%TYPE,
                                         o_error_id    OUT error_desc.error_desc_id%TYPE,
                                         o_items       OUT SYS_REFCURSOR) AS
    /* ��������� ����� �� ����������� (�������� 5 ������������)
    �������:
         ����������� 1004 - ����������� �����������
                  ���1002 - ���� �� ���� ��� ������
                     1003 - IP ��� ������
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE := 24;
  
  BEGIN
    pkg_users.active_session(i_session_id,
                             i_key_id,
                             i_terminal_ip,
                             c_perm_act,
                             o_error_id,
                             v_user_id);
  
    IF o_error_id <> 0 THEN
      RETURN;
    END IF;
  
    OPEN o_items FOR
      SELECT sort.*
        FROM (SELECT a.article_id,
                     a.article_title,
                     a.article_lang,
                     a.article_public_date,
                     u.user_login
                FROM article a, users u
               WHERE a.article_status_id = 4
                 AND a.article_creator_id = u.user_id
               ORDER BY a.article_public_date DESC) sort
       WHERE rownum <= 5;
  
  EXCEPTION
    WHEN pkg_users.insufficient_privileges THEN
      o_error_id := 1004;
  END get_article_list_public_new5;

  PROCEDURE get_article(i_session_id       user_session.session_id%TYPE,
                        i_key_id           user_session.key_id%TYPE,
                        i_terminal_ip      user_session.terminal_ip%TYPE,
                        i_article_id       article.article_id%TYPE,
                        o_error_id         OUT error_desc.error_desc_id%TYPE,
                        o_article_title    OUT article.article_title%TYPE,
                        o_article_short    OUT article.article_short%TYPE,
                        o_article_content  OUT article.article_content%TYPE,
                        o_article_lang     OUT article.article_lang%TYPE,
                        o_creator          OUT VARCHAR2,
                        o_public_date      OUT article.article_public_date%TYPE,
                        o_article_category OUT VARCHAR2) AS
    /* ��������� ������ ��� � ������ ����������� (��� ���� ������� �� ��������, �� � ������ ������)
    �������:
         ����������� 1004 - ����������� �����������
                  ���1002 - ���� �� ���� ��� ������
                     1003 - IP ��� ������
                 1011 - �����
    */
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE := 25;
  BEGIN
    pkg_users.active_session(i_session_id,
                             i_key_id,
                             i_terminal_ip,
                             c_perm_act,
                             o_error_id,
                             v_user_id);
  
    IF o_error_id <> 0 THEN
      RETURN;
    END IF;
  
    SELECT a.article_title,
           a.article_short,
           a.article_content,
           a.article_lang,
           uc.user_login,
           a.article_public_date
      INTO o_article_title,
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
  
    SELECT listagg(c.category_id, ',') within GROUP(ORDER BY c.category_id)
      INTO o_article_category
      FROM category_article_link c
     WHERE c.article_id = i_article_id;
  
    RETURN;
  EXCEPTION
    WHEN no_data_found THEN
      o_error_id := 1011;
      RETURN;
    WHEN pkg_users.insufficient_privileges THEN
      o_error_id := 1004;
      RETURN;
  END get_article;

  FUNCTION del_my_article(i_session_id  user_session.session_id%TYPE,
                          i_key_id      user_session.key_id%TYPE,
                          i_terminal_ip user_session.terminal_ip%TYPE,
                          i_article_id  article.article_id%TYPE)
    RETURN error_desc.error_desc_id%TYPE AS
    /* �������� ��� ������ � ������ ����������� ������������
    �������:
         ����������� 1004 - ����������� �����������
                  ���1002 - ���� �� ���� ��� ������
                     1003 - IP ��� ������
    */
    v_error_id error_desc.error_desc_id%TYPE := 0;
    v_user_id  user_session.user_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE := 27;
  BEGIN
    pkg_users.active_session(i_session_id,
                             i_key_id,
                             i_terminal_ip,
                             c_perm_act,
                             v_error_id,
                             v_user_id);
  
    IF v_error_id <> 0 THEN
      RETURN v_error_id;
    END IF;
  
    DELETE FROM article a
     WHERE a.article_id = i_article_id
       AND a.article_status_id = 1
       AND a.article_creator_id = v_user_id;
  
    RETURN v_error_id;
  EXCEPTION
    WHEN pkg_users.insufficient_privileges THEN
      v_error_id := 1004;
      RETURN v_error_id;
  END del_my_article;

END pkg_article;
/