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

  PROCEDURE login(i_user_login      users.user_login%TYPE,
                  i_pass            users.user_pass%TYPE,
                  i_terminal_ip     user_session.terminal_ip%TYPE,
                  i_terminal_client user_session.terminal_client%TYPE,
                  o_error_id        OUT error_desc.error_desc_id%TYPE,
                  o_session_id      OUT user_session.session_id%TYPE,
                  o_key_id          OUT user_session.key_id%TYPE,
                  o_lang_id         OUT users.lang_id%TYPE,
                  o_roles_list      OUT SYS_REFCURSOR) AS
  
    /* ��������� ���
      ��� �������:
      ����������� 1001 - ���������� ���� ��� ������
    */
  
    v_user_id user_session.user_id%TYPE;
  BEGIN
    o_error_id := 0;
    SELECT user_id, lang_id
      INTO v_user_id, o_lang_id
      FROM users
     WHERE user_login = i_user_login
       AND state_id = 1
       AND (user_pass = i_pass OR user_login = 'GUEST');
  
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
  
    o_error_id := get_roles_list(v_user_id, NULL, NULL, o_roles_list);
  
  EXCEPTION
    WHEN no_data_found THEN
      --���������� ���� ��� ������
      o_error_id := 1001;
    
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

  PROCEDURE update_user_session(i_session_id   user_session.session_id%TYPE,
                                i_key_id       user_session.key_id%TYPE,
                                i_act          user_session.l_action_type_id%TYPE,
                                i_l_is_success user_session.l_is_success%TYPE) AS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE user_session
       SET l_date           = localtimestamp,
           l_action_type_id = i_act,
           l_is_success     = i_l_is_success
     WHERE session_id = i_session_id
       AND key_id = i_key_id;
    COMMIT;
  END;

  PROCEDURE active_session(i_session_id  user_session.session_id%TYPE,
                           i_key_id      user_session.key_id%TYPE,
                           i_terminal_ip user_session.terminal_ip%TYPE,
                           i_act         user_session.l_action_type_id%TYPE,
                           o_error_id    OUT error_desc.error_desc_id%TYPE,
                           o_user_id     OUT user_session.user_id%TYPE) AS
    /* �������� �� ���������� ���.
    ��� ������� ���� ����� � ����� �������� 䳿 �����������
        �������� ����� �� ��������� 䳿 i_act
    
         ��� �������:
         ����������� 1002 - ���� �� ���� ��� ������
                     1003 - IP ��� ������
             �������-����������
                     insufficient_privileges - ����������� ����������� (������������� � ������������� 1004)
    
     */
    v_terminal_ip  user_session.terminal_ip%TYPE;
    v_l_is_success user_session.l_is_success%TYPE;
  
  BEGIN
    o_error_id := 0;
    SELECT us.terminal_ip, us.user_id
      INTO v_terminal_ip, o_user_id
      FROM user_session us, users u
     WHERE us.user_id = u.user_id
       AND u.state_id = 1
       AND us.session_id = i_session_id
       AND key_id = i_key_id;
  
    IF v_terminal_ip <> i_terminal_ip THEN
      o_error_id := 1003; --IP ��� ������
      RETURN;
    END IF;
  
    IF is_permission(o_user_id, i_act) THEN
      v_l_is_success := 1;
    ELSE
      v_l_is_success := 0;
    END IF;
  
    update_user_session(i_session_id, i_key_id, i_act, v_l_is_success);
  
    IF v_l_is_success = 0 THEN
      RAISE insufficient_privileges;
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      o_error_id := 1002; --���� �� ���� ��� ������
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
    active_session(i_session_id,
                   i_key_id,
                   i_terminal_ip,
                   i_act,
                   v_error_id,
                   v_user_id);
    RETURN v_error_id;
  END active_session;

  FUNCTION check_user_sess_active(i_session_id  user_session.session_id%TYPE,
                                  i_key_id      user_session.key_id%TYPE,
                                  i_terminal_ip user_session.terminal_ip%TYPE,
                                  i_act         user_session.l_action_type_id%TYPE)
    RETURN error_desc.error_desc_id%TYPE AS
    /*�������� active_session ��� ������������ �����ʲ� �� ���Ͳ
      !��������, ������: �� ��������������� � ��� PL/SQL
                        0 - ������� ���������� ��� �������
    
         ����������� 1004 - ����������� ����������� ��� 䳿 i_act
    
                     1002 - ���� �� ���� ��� ������
                     1003 - IP ��� ������
    */
    v_error_id error_desc.error_desc_id%TYPE;
  BEGIN
    v_error_id := active_session(i_session_id,
                                 i_key_id,
                                 i_terminal_ip,
                                 i_act);
  
    RETURN v_error_id;
  EXCEPTION
    WHEN insufficient_privileges THEN
      v_error_id := 1004;
      RETURN v_error_id;
  END check_user_sess_active;

  PROCEDURE list_users(i_session_id  user_session.session_id%TYPE,
                       i_key_id      user_session.key_id%TYPE,
                       i_terminal_ip user_session.terminal_ip%TYPE,
                       o_error_id    OUT error_desc.error_desc_id%TYPE,
                       o_items       OUT SYS_REFCURSOR) AS
    /* ������ ��� ������������
    �������:
         ����������� 1004 - ����������� �����������
    */
    c_perm_act action_type.action_type_id%TYPE := 3;
  
  BEGIN
    o_error_id := active_session(i_session_id,
                                 i_key_id,
                                 i_terminal_ip,
                                 c_perm_act);
    IF o_error_id = 0 THEN
      OPEN o_items FOR
        SELECT u.user_id,
               u.user_login,
               u.user_name,
               u.user_email,
               us.state_name,
               u.lang_id,
               u.r_date
          FROM users u, user_state us
         WHERE u.state_id = us.state_id;
    END IF;
  
  EXCEPTION
    WHEN insufficient_privileges THEN
      o_error_id := 1004;
    
  END list_users;

  PROCEDURE list_users_action(i_session_id   user_session.session_id%TYPE,
                              i_key_id       user_session.key_id%TYPE,
                              i_terminal_ip  user_session.terminal_ip%TYPE,
                              i_start_date   user_session_hist.a_date%TYPE,
                              i_end_date     user_session_hist.a_date%TYPE,
                              i_user_id      user_session.user_id%TYPE,
                              i_l_is_success user_session.l_is_success%TYPE,
                              o_error_id     OUT error_desc.error_desc_id%TYPE,
                              o_items        OUT SYS_REFCURSOR) AS
    /* ������ �� ������������ � ������
       �������:
               1004 - ����������� �����������
               1005 - ������ ������� ���� ������� ��� ���� ����
    */
    c_perm_act action_type.action_type_id%TYPE := 4;
  
  BEGIN
    o_error_id := active_session(i_session_id,
                                 i_key_id,
                                 i_terminal_ip,
                                 c_perm_act);
    IF o_error_id = 0 THEN
      IF i_start_date IS NULL OR i_end_date IS NULL THEN
        o_error_id := 1005;
        RETURN;
      END IF;
    
      OPEN o_items FOR
        SELECT ush.user_id,
               u.user_login,
               us.state_name,
               ush.terminal_ip,
               ush.terminal_client,
               ush.l_date,
               at.action_name,
               ush.r_date,
               uss.is_success_name
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
           AND (i_l_is_success IS NULL OR ush.l_is_success = i_l_is_success)
         ORDER BY ush.l_date DESC;
    
    END IF;
  
  EXCEPTION
    WHEN insufficient_privileges THEN
      o_error_id := 1004;
  END list_users_action;

  FUNCTION registr(i_session_id  user_session.session_id%TYPE,
                   i_key_id      user_session.key_id%TYPE,
                   i_terminal_ip user_session.terminal_ip%TYPE,
                   
                   i_newuser_login users.user_login%TYPE,
                   i_newuser_pass  users.user_pass%TYPE,
                   i_user_name     users.user_name%TYPE,
                   i_user_email    users.user_email%TYPE,
                   i_user_sex      users.user_sex%TYPE,
                   i_lang_id       users.lang_id%TYPE)
    RETURN error_desc.error_desc_id%TYPE AS
  
    /* ��������� ������ �����������
      ��� �������:
                  1004 - ����������� �����������
    */
  
    v_error_id error_desc.error_desc_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE := 5;
  BEGIN
    v_error_id := active_session(i_session_id,
                                 i_key_id,
                                 i_terminal_ip,
                                 c_perm_act);
  
    IF v_error_id = 0 THEN
      INSERT INTO users
        (user_id,
         user_login,
         user_pass,
         user_name,
         user_email,
         state_id,
         r_date,
         user_sex,
         lang_id)
      VALUES
        (users_id_seq.nextval,
         TRIM(i_newuser_login),
         i_newuser_pass,
         TRIM(i_user_name),
         i_user_email,
         1,
         localtimestamp,
         i_user_sex,
         i_lang_id);
    END IF;
  
    INSERT INTO users_role
      (user_id, role_id)
    VALUES
      (users_id_seq.currval, 2);
  
    RETURN v_error_id;
  
  EXCEPTION
    WHEN insufficient_privileges THEN
      v_error_id := 1004;
      RETURN v_error_id;
    
  END registr;

  FUNCTION is_user_exist(i_user_login VARCHAR2) RETURN NUMBER AS
    v_is NUMBER(1);
  BEGIN
    SELECT COUNT(1)
      INTO v_is
      FROM users
     WHERE lower(TRIM(user_login)) = lower(TRIM(i_user_login));
    RETURN v_is;
  END is_user_exist;

  PROCEDURE user_info(i_session_id  user_session.session_id%TYPE,
                      i_key_id      user_session.key_id%TYPE,
                      i_terminal_ip user_session.terminal_ip%TYPE,
                      o_error_id    OUT error_desc.error_desc_id%TYPE,
                      o_user_id     OUT users.user_id%TYPE,
                      o_user_login  OUT users.user_login%TYPE,
                      o_user_name   OUT users.user_name%TYPE,
                      o_user_email  OUT users.user_email%TYPE,
                      o_state_name  OUT user_state.state_name%TYPE,
                      o_r_date      OUT users.r_date%TYPE,
                      o_user_sex    OUT users.user_sex%TYPE,
                      o_lang_id     OUT supp_lang.lang_id%TYPE,
                      o_roles       OUT SYS_REFCURSOR) AS
    /* ���� ����������� �� ���� �� �����
    �������:
         ����������� 1004 - ����������� �����������
    */
    c_perm_act action_type.action_type_id%TYPE := 6;
  
  BEGIN
    active_session(i_session_id,
                   i_key_id,
                   i_terminal_ip,
                   c_perm_act,
                   o_error_id,
                   o_user_id);
    IF o_error_id = 0 THEN
      SELECT u.user_login,
             u.user_name,
             u.user_email,
             us.state_name,
             u.r_date,
             u.user_sex,
             u.lang_id
        INTO o_user_login,
             o_user_name,
             o_user_email,
             o_state_name,
             o_r_date,
             o_user_sex,
             o_lang_id
        FROM users u, user_state us
       WHERE u.state_id = us.state_id
         AND u.user_id = o_user_id;
    
      o_error_id := get_roles_list(o_user_id, NULL, NULL, o_roles);
    
    END IF;
  
  EXCEPTION
    WHEN insufficient_privileges THEN
      o_error_id := 1004;
  END user_info;

--BEGIN
-- Initialization
--< STATEMENT >;
END pkg_users;
/