CREATE OR REPLACE PACKAGE BODY pkg_users IS

  FUNCTION get_roles_list(i_user_id    user_session.user_id%TYPE,
                          i_session_id user_session.session_id%TYPE,
                          i_key_id     user_session.key_id%TYPE,
                          o_items      OUT SYS_REFCURSOR) RETURN NUMBER AS
  
    /* ������ ����� ����������� */
    v_error_id error_desc.error_desc_id%TYPE;
    v_user_id  user_session.user_id%TYPE;
  
  BEGIN
    v_error_id := 0;
    IF i_user_id IS NOT NULL THEN
      v_user_id := i_user_id;
    ELSE
      SELECT user_id
        INTO v_user_id
        FROM user_session
       WHERE session_id = i_session_id
         AND key_id = i_key_id;
    END IF;
    OPEN o_items FOR
      SELECT r.role_id, r.role_name, r.role_short_name
        FROM roles r
       INNER JOIN users_role ur
          ON ur.role_id = r.role_id
         AND ur.user_id = v_user_id;
  
    RETURN v_error_id;
  END get_roles_list;

  FUNCTION login(i_user_login      users.user_login%TYPE,
                 i_pass            users.user_pass%TYPE,
                 i_terminal_ip     user_session.terminal_ip%TYPE,
                 i_terminal_client user_session.terminal_client%TYPE,
                 o_session_id      OUT user_session.session_id%TYPE,
                 o_key_id          OUT user_session.key_id%TYPE,
                 o_lang_id         OUT users.lang_id%TYPE,
                 o_roles_list      OUT SYS_REFCURSOR)
    RETURN error_desc.error_desc_id%TYPE AS
  
    /* ��������� ���
      ��� �������:
      ����������� 1001 - ���������� ���� ��� ������
    */
  
    v_error_id error_desc.error_desc_id%TYPE;
    v_user_id  user_session.user_id%TYPE;
  BEGIN
    v_error_id := 0;
    SELECT user_id, lang_id
      INTO v_user_id, o_lang_id
      FROM users
     WHERE user_login = i_user_login
       AND user_pass = i_pass;
  
    o_session_id := session_id_seq.nextval;
    o_key_id     := rawtohex(dbms_crypto.hash(src => utl_raw.cast_to_raw(o_session_id ||
                                                                         v_user_id),
                                              typ => dbms_crypto.hash_sh1));
  
    INSERT INTO user_session
      (session_id,
       key_id,
       user_id,
       terminal_ip,
       terminal_client,
       l_date,
       l_action_type_id,
       r_date)
    VALUES
      (o_session_id,
       o_key_id,
       v_user_id,
       i_terminal_ip,
       substr(i_terminal_client, 1, 255),
       localtimestamp,
       1,
       localtimestamp);
  
    v_error_id := get_roles_list(v_user_id, NULL, NULL, o_roles_list);
    RETURN v_error_id;
  
  EXCEPTION
    WHEN no_data_found THEN
      --���������� ���� ��� ������
      v_error_id := 1001;
      RETURN v_error_id;
    
  END login;

  FUNCTION logout(i_session_id user_session.session_id%TYPE,
                  i_key_id     user_session.key_id%TYPE)
    RETURN error_desc.error_desc_id%TYPE AS
  
    /* ��������� ���
    */
  
  BEGIN
    UPDATE user_session
       SET l_action_type_id = 2 --����� ������ �� ������ ������
     WHERE session_id = i_session_id
       AND key_id = i_key_id;
  
    DELETE FROM user_session
     WHERE session_id = i_session_id
       AND key_id = i_key_id;
    RETURN 0;
  
  END logout;

  FUNCTION is_permission(i_user_id  users.user_id%TYPE,
                         i_perm_act action_type.action_type_id%TYPE)
    RETURN BOOLEAN AS
    /* �������� ���� �� ���������� �������� */
    v_cnt NUMBER(2);
  BEGIN
    SELECT COUNT(*)
      INTO v_cnt
      FROM users_role ur
     INNER JOIN roles_perm_action pa
        ON pa.role_id = ur.role_id
       AND action_type_id = i_perm_act
     WHERE ur.user_id = i_user_id;
    IF v_cnt > 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END is_permission;

  FUNCTION active_session(i_session_id  user_session.session_id%TYPE,
                          i_key_id      user_session.key_id%TYPE,
                          i_terminal_ip user_session.terminal_ip%TYPE,
                          i_act         user_session.l_action_type_id%TYPE,
                          o_user_id     OUT user_session.user_id%TYPE)
    RETURN error_desc.error_desc_id%TYPE AS
    /* �������� �� ��������� ���.
    ��� ������� ���� ����� � ����� �������� 䳿 �����������
        �������� ����� �� ��������� 䳿 i_act
            
         ��� �������:
         ����������� 1002 - ���� �� ���� ��� ������
                     1003 - IP ��� ������
             �������-���������� 
                     insufficient_privileges - ����������� ����������� (������������� � ������������� 1004)        
       
     */
    v_terminal_ip  user_session.terminal_ip%TYPE;
    v_error_id     error_desc.error_desc_id%TYPE;
    v_l_is_success user_session.l_is_success%TYPE;
  
  BEGIN
    v_error_id := 0;
    SELECT us.terminal_ip, us.user_id
      INTO v_terminal_ip, o_user_id
      FROM user_session us
     WHERE us.session_id = i_session_id
       AND key_id = i_key_id;
  
    IF v_terminal_ip <> i_terminal_ip THEN
      v_error_id := 1003; --IP ��� ������
      RETURN v_error_id;
    END IF;
  
    IF is_permission(o_user_id, i_act) THEN
      v_l_is_success := 1;
    ELSE
      v_l_is_success := 0;
    END IF;
  
    UPDATE user_session
       SET l_date           = localtimestamp,
           l_action_type_id = i_act,
           l_is_success     = v_l_is_success
     WHERE session_id = i_session_id
       AND key_id = i_key_id;
  
    IF v_l_is_success = 0 THEN
      RAISE insufficient_privileges;
    END IF;
  
    RETURN 0;
  
  EXCEPTION
    WHEN no_data_found THEN
      v_error_id := 1002; --���� �� ���� ��� ������
      RETURN v_error_id;
  END active_session;

  FUNCTION active_session(i_session_id  user_session.session_id%TYPE,
                          i_key_id      user_session.key_id%TYPE,
                          i_terminal_ip user_session.terminal_ip%TYPE,
                          i_act         user_session.l_action_type_id%TYPE)
    RETURN error_desc.error_desc_id%TYPE AS
    /*������������� ����ֲ�. �������� ��� ����- �� ������� ������������� �����������*/
    v_error_id error_desc.error_desc_id%TYPE;
    v_user_id  user_session.user_id%TYPE; --�� �� �� ��� �������
  BEGIN
    v_error_id := active_session(i_session_id,
                                 i_key_id,
                                 i_terminal_ip,
                                 i_act,
                                 v_user_id);
    RETURN v_error_id;
  END active_session;

  FUNCTION list_users(i_session_id  user_session.session_id%TYPE,
                      i_key_id      user_session.key_id%TYPE,
                      i_terminal_ip user_session.terminal_ip%TYPE,
                      i_lang_id     supp_lang.lang_id%TYPE,
                      o_items       OUT SYS_REFCURSOR)
    RETURN error_desc.error_desc_id%TYPE AS
    /* ������ ��� ������������
    �������:
         ����������� 1004 - ����������� �����������
    */
    c_perm_act action_type.action_type_id%TYPE := 3;
    v_error_id error_desc.error_desc_id%TYPE;
  BEGIN
    v_error_id := active_session(i_session_id,
                                 i_key_id,
                                 i_terminal_ip,
                                 c_perm_act);
    IF v_error_id = 0 THEN
      OPEN o_items FOR
        SELECT u.user_id,
               u.user_login,
               u.user_name,
               u.user_email,
               (CASE
                 WHEN i_lang_id = 'UA' OR i_lang_id IS NULL THEN
                  us.state_name
                 ELSE
                  (SELECT td.translate_name
                     FROM translate_dict td
                    WHERE td.translate_pls_id = us.translate_pls_id
                      AND td.lang_id = i_lang_id)
               END) AS state_name,
               u.lang_id,
               u.r_date
          FROM users u, user_state us
         WHERE u.state_id = us.state_id;
    END IF;
    RETURN v_error_id;
  
  EXCEPTION
    WHEN insufficient_privileges THEN
      v_error_id := 1004;
      RETURN v_error_id;
  END list_users;

  FUNCTION list_users_action(i_session_id   user_session.session_id%TYPE,
                             i_key_id       user_session.key_id%TYPE,
                             i_terminal_ip  user_session.terminal_ip%TYPE,
                             i_lang_id      supp_lang.lang_id%TYPE,
                             i_start_date   user_session_hist.a_date%TYPE,
                             i_end_date     user_session_hist.a_date%TYPE,
                             i_user_id      user_session.user_id%TYPE,
                             i_l_is_success user_session.l_is_success%TYPE,
                             o_items        OUT SYS_REFCURSOR)
    RETURN error_desc.error_desc_id%TYPE AS
    /* ������ �� ������������ � ������
       �������:
               1004 - ����������� �����������
               1005 - ������ ������ ���� ������� ��� ���� ����
    */
    c_perm_act action_type.action_type_id%TYPE := 4;
    v_error_id error_desc.error_desc_id%TYPE;
  BEGIN
    v_error_id := active_session(i_session_id,
                                 i_key_id,
                                 i_terminal_ip,
                                 c_perm_act);
    IF v_error_id = 0 THEN
      IF i_start_date IS NULL OR i_end_date IS NULL THEN
        v_error_id := 1005;
        RETURN v_error_id;
      
      END IF;
      OPEN o_items FOR
        SELECT ush.user_id,
               u.user_login,
               (CASE
                 WHEN i_lang_id = 'UA' OR i_lang_id IS NULL THEN
                  us.state_name
                 ELSE
                  (SELECT td.translate_name
                     FROM translate_dict td
                    WHERE td.translate_pls_id = us.translate_pls_id
                      AND td.lang_id = i_lang_id)
               END) AS state_name,
               ush.terminal_ip,
               ush.terminal_client,
               ush.l_date,
               (CASE
                 WHEN i_lang_id = 'UA' OR i_lang_id IS NULL THEN
                  at.action_name
                 ELSE
                  (SELECT td.translate_name
                     FROM translate_dict td
                    WHERE td.translate_pls_id = at.translate_pls_id
                      AND td.lang_id = i_lang_id)
               END) AS action_name,
               ush.a_date,
               (CASE
                 WHEN i_lang_id = 'UA' OR i_lang_id IS NULL THEN
                  uss.is_success_name
                 ELSE
                  (SELECT td.translate_name
                     FROM translate_dict td
                    WHERE td.translate_pls_id = uss.translate_pls_id
                      AND td.lang_id = i_lang_id)
               END) AS succes_name
          FROM user_session_hist ush,
               action_type       at,
               user_sess_success uss,
               users             u,
               user_state        us
         WHERE ush.l_action_type_id = at.action_type_id
           AND ush.l_is_success = uss.is_success_id
           AND ush.user_id = u.user_id
           AND u.state_id = us.state_id
           AND ush.a_date BETWEEN i_start_date AND i_end_date
           AND (i_user_id IS NULL OR ush.user_id = i_user_id)
           AND (i_l_is_success IS NULL OR
               ush.l_action_type_id = i_l_is_success);
    
    END IF;
    RETURN v_error_id;
  
  EXCEPTION
    WHEN insufficient_privileges THEN
      v_error_id := 1004;
      RETURN v_error_id;
  END list_users_action;
  --BEGIN
-- Initialization
--< STATEMENT >;
END pkg_users;
/