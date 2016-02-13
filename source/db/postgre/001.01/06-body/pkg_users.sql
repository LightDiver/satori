SET CLIENT_ENCODING TO 'WIN1251';

/*===============================*/
--PACKAGE BODY pkg_users
/*===============================*/
CREATE OR REPLACE FUNCTION pkg_users.get_roles_list(i_user_id    numeric,
                          i_session_id numeric,
                          i_key_id     varchar,
                          o_error_id   OUT numeric,
                          o_items      OUT refcursor) RETURNS record AS
$BODY$
DECLARE
    /* Список ролей користувача */
    v_user_id  user_session.user_id%TYPE;
  
  BEGIN
    o_error_id = 0;
    IF i_user_id IS NOT NULL THEN
      v_user_id = i_user_id;
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
  
    RETURN;
  END;
$BODY$
  LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION pkg_users.login(IN i_user_login character varying,
    IN i_pass character varying,
    IN i_terminal_ip character varying,
    IN i_terminal_client character varying,
    OUT o_error_id numeric,
    OUT o_session_id numeric,
    OUT o_key_id character varying,
    OUT o_lang_id character varying,
    OUT o_roles_list refcursor)
    RETURNS record AS
  $body$
DECLARE
    /* Реєстрація сесії
          Помилки:
                  1001 - помилковий логін або пароль
    */
 
    v_user_id  user_session.user_id%TYPE;
  BEGIN
    o_error_id = 0;
    SELECT user_id, lang_id
      INTO v_user_id, o_lang_id
      FROM users
     WHERE user_login = i_user_login
       AND state_id = 1
       AND (user_pass = i_pass OR user_login = 'GUEST');
       
       --помилковий логін або пароль
    if v_user_id is null then  
      o_error_id = 1001;
      RETURN;
    end if;  
  
    o_session_id = nextval('session_id_seq');
    select encode(digest('' || o_session_id ||  v_user_id,'sha1'),'hex') into o_key_id ;                                         
  
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
  
    select  o.o_error_id, o.o_items from  pkg_users.get_roles_list(v_user_id, NULL, NULL) o into o_error_id, o_roles_list;
    RETURN;      
    
  END;
$body$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION pkg_users.logout(
    i_session_id numeric,
    i_key_id character varying)
  RETURNS numeric AS
$BODY$
    /* Видалення сесії
    */
  
  BEGIN
    UPDATE user_session
       SET l_action_type_id = 2 --натяк системі що робимо логаут
     WHERE session_id = i_session_id
       AND key_id = i_key_id;
  
    DELETE FROM user_session
     WHERE session_id = i_session_id
       AND key_id = i_key_id;
    RETURN 0;
  
  END;
$BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pkg_users.list_users(
    IN i_session_id numeric,
    IN i_key_id character varying,
    IN i_terminal_ip character varying,
    OUT o_error_id numeric,
    OUT o_items refcursor)
  RETURNS record AS
$BODY$
                       DECLARE
    /* Список всіх користувачів
    Помилки:
                     1004 - Недостатньо повноважень
    */
    c_perm_act action_type.action_type_id%TYPE = 3;
  
  BEGIN
    select o.o_error_id from pkg_users.active_session(i_session_id,
                                 i_key_id,
                                 i_terminal_ip,
                                 c_perm_act) o
    into o_error_id;
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
    WHEN SQLSTATE 'NPRIV' THEN
      o_error_id = 1004;
    
  END ;

$BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pkg_users.list_users_action(
    IN i_session_id numeric,
    IN i_key_id character varying,
    IN i_terminal_ip character varying,
    IN i_start_date date,
    IN i_end_date date,
    IN i_user_id numeric,
    IN i_l_is_success numeric,
    OUT o_error_id numeric,
    OUT o_items refcursor)
  RETURNS record AS
$BODY$
                       DECLARE
    /* Список дій користувачів в системі
       Помилки:
               1004 - Недостатньо повноважень
               1005 - Невірно вказані дата початку або дата кінця
    */
    c_perm_act action_type.action_type_id%TYPE = 4;
  
  BEGIN
    select o.o_error_id from pkg_users.active_session(i_session_id,
                                 i_key_id,
                                 i_terminal_ip,
                                 c_perm_act) o
    into o_error_id;

    IF o_error_id = 0 THEN
      IF i_start_date IS NULL OR i_end_date IS NULL THEN
        o_error_id = 1005;
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
    WHEN SQLSTATE 'NPRIV' THEN
      o_error_id = 1004;
  END ;

$BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pkg_users.registr(
    i_session_id numeric,
    i_key_id character varying,
    i_terminal_ip character varying,
    i_newuser_login character varying,
    i_newuser_pass character varying,
    i_user_name character varying,
    i_user_email character varying,
    i_user_sex character varying,
    i_lang_id character varying)
  RETURNS numeric AS
$BODY$
                       DECLARE
  
    /* Реєстрація нового користувача
          Помилки:
                  1004 - Недостатньо повноважень
    */
  
    v_error_id error_desc.error_desc_id%TYPE;
    c_perm_act action_type.action_type_id%TYPE = 5;
    v_user_id numeric(10,0);
  BEGIN
    select o.o_error_id from pkg_users.active_session(i_session_id,
                                 i_key_id,
                                 i_terminal_ip,
                                 c_perm_act) o
    into v_error_id;

	v_user_id = nextval('users_id_seq');
  
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
        (v_user_id,
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
      (v_user_id, 2);
  
    RETURN v_error_id;
  
  EXCEPTION
    WHEN SQLSTATE 'NPRIV' THEN
      v_error_id = 1004;
      RETURN v_error_id;
    
  END ;                             
$BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pkg_users.is_user_exist(i_user_login character varying)
  RETURNS numeric AS
$BODY$
                       DECLARE
    v_is NUMERIC(1);
  BEGIN
    SELECT COUNT(1)
      INTO v_is
      FROM users
     WHERE lower(TRIM(user_login)) = lower(TRIM(i_user_login));
    RETURN v_is;
  END;
$BODY$
  LANGUAGE plpgsql;

  CREATE OR REPLACE FUNCTION pkg_users.update_user_session(i_session_id   numeric,
                                i_key_id       varchar,
                                i_act          numeric,
                                i_l_is_success numeric) RETURNS void AS $$
  BEGIN
    UPDATE user_session
       SET l_date           = localtimestamp,
           l_action_type_id = i_act,
           l_is_success     = i_l_is_success
     WHERE session_id = i_session_id
       AND key_id = i_key_id;
  END;
  $$
   LANGUAGE 'plpgsql';

  CREATE OR REPLACE FUNCTION pkg_users.is_permission(i_user_id  numeric(18,0),
                         i_perm_act numeric(10,0))
    RETURNS BOOLEAN AS
    $$
    DECLARE
    /* Проверка прав на выполнение действия */
    v_cnt NUMERIC(2);
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
  END;
  $$
   LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION pkg_users.active_session(
    IN i_session_id numeric(18,0),
    IN i_key_id character varying,
    IN i_terminal_ip character varying,
    IN i_act numeric(10,0),
    OUT o_error_id numeric,
    OUT o_user_id numeric(18,0))
    RETURNS record AS
$BODY$
    /* Перевірка на аткивність сесії.
        Оновлює сесію часом і типом останньої дії користувача
        Перевіряє дозвіл на виконання дії i_act
    
             Помилки:
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
             Помилка-виключення
                     insufficient_privileges - Недостатньо повноважень (Перехоплювати і встановлювати 1004)
    
     */
     DECLARE
    v_terminal_ip  user_session.terminal_ip%TYPE;
    v_l_is_success user_session.l_is_success%TYPE;
  
  BEGIN
    o_error_id = 0;
    SELECT us.terminal_ip, us.user_id
      INTO v_terminal_ip, o_user_id
      FROM user_session us, users u
     WHERE us.user_id = u.user_id
       AND u.state_id = 1
       AND us.session_id = i_session_id
       AND key_id = i_key_id;
  
    IF v_terminal_ip <> i_terminal_ip THEN
      o_error_id = 1003; --IP сесії невірне
      RETURN;
    END IF;
  
    IF pkg_users.is_permission(o_user_id, i_act) THEN
      v_l_is_success = 1;
    ELSE
      v_l_is_success = 0;
    END IF;
  
    --відпрацювати задачу автономної транзакції (dblink ?)
    perform pkg_users.update_user_session(i_session_id, i_key_id, i_act, v_l_is_success);
  
    IF v_l_is_success = 0 THEN
      RAISE EXCEPTION SQLSTATE 'NPRIV';
    END IF;
  
    RETURN;
  
  EXCEPTION
    WHEN no_data_found THEN
      o_error_id = 1002; --Сесія не існує або минула
      RETURN;
  END;
$BODY$
    LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION pkg_users.check_user_sess_active(
    i_session_id numeric(18,0),
    i_key_id character varying,
    i_terminal_ip character varying,
    i_act numeric(10,0))
  RETURNS numeric AS
    $$
    DECLARE
    /*Обгортка active_session ДЛЯ ВИКОРИСТАННЯ ВИКЛИКІВ ІЗ ЗОВНІ
      !Нотебене, Ахтунг: Не використовувати в коді PL/SQL
                        0 - Функція спрацювала без помилок
                        
                     1004 - Недостатньо повноважень для дії i_act
         
                     1002 - Сесія не існує або минула
                     1003 - IP сесії невірне
    */
    v_error_id error_desc.error_desc_id%TYPE;
  BEGIN
    /*
    v_error_id = active_session(i_session_id,
                                 i_key_id,
                                 i_terminal_ip,
                                 i_act);
    */
    select o.o_error_id from pkg_users.active_session(i_session_id,
                                 i_key_id,
                                 i_terminal_ip,
                                 i_act) o
    into v_error_id;
  
    RETURN v_error_id;
  EXCEPTION
    WHEN SQLSTATE 'NPRIV' THEN
      v_error_id = 1004;
      RETURN v_error_id;
  END;
  $$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION pkg_users.user_info(
    IN i_session_id numeric,
    IN i_key_id character varying,
    IN i_terminal_ip character varying,
    OUT o_error_id numeric,
    OUT o_user_id numeric,
    OUT o_user_login character varying,
    OUT o_user_name character varying,
    OUT o_user_email character varying,
    OUT o_state_name character varying,
    OUT o_r_date timestamp,
    OUT o_user_sex character varying,
    OUT o_lang_id character varying,
    OUT o_roles refcursor)
  RETURNS record AS
$BODY$
    DECLARE
    /* Інфо користувача по сессії та ключу
    Помилки:
                     1004 - Недостатньо повноважень
    */
    c_perm_act action_type.action_type_id%TYPE := 6;
    
  BEGIN
    SELECT o.o_error_id, o.o_user_id FROM pkg_users.active_session(i_session_id,
                                           i_key_id,
                                           i_terminal_ip,
                                           c_perm_act
                                           ) o
    INTO o_error_id, o_user_id;
    
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
    
      SELECT o.o_error_id, o.o_items FROM pkg_users.get_roles_list(o_user_id, NULL, NULL) o
      INTO o_error_id, o_roles;
    
    END IF;
    RETURN;
  
  EXCEPTION
    WHEN SQLSTATE 'NPRIV' THEN
      o_error_id = 1004;
      RETURN;
  END;
$BODY$
  LANGUAGE plpgsql;

/*===============================*/
--END PACKAGE BODY pkg_users
/*===============================*/
