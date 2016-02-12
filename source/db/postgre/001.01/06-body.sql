--PACKAGE BODY pkg_systeminfo

  CREATE OR REPLACE FUNCTION pkg_systeminfo.get_description_error(i_error_id error_desc.error_desc_id%TYPE)
    RETURNS VARCHAR AS
    $BODY$
  DECLARE 
    v_error_desc error_desc.error_desc%TYPE;
  BEGIN
    SELECT ed.error_desc
      INTO v_error_desc
      FROM error_desc ed
     WHERE ed.error_desc_id = i_error_id;
  
    RETURN v_error_desc;
  END;
  $BODY$
  LANGUAGE 'plpgsql';

  CREATE OR REPLACE FUNCTION pkg_systeminfo.get_langs() RETURNS refcursor AS
    $BODY$
  DECLARE 
    v_res refcursor;
  BEGIN
    OPEN v_res FOR
      SELECT l.lang_id, l.lang_name FROM supp_lang l;
    RETURN v_res;
  END;
  $BODY$
  LANGUAGE 'plpgsql';

  CREATE OR REPLACE FUNCTION pkg_systeminfo.check_version(i_major NUMERIC) RETURNS NUMERIC AS
  $BODY$
  DECLARE 
    v_res NUMERIC(1);
    /* 0 - Остання версія не співпадає
      > 0 - Співпадає
    */
  BEGIN
    SELECT COUNT(*)
      INTO v_res
      FROM sys_version s
     WHERE s.major = i_major
       AND s.user_date = (SELECT MAX(user_date) FROM sys_version);
    RETURN v_res;
  END;
  $BODY$
  LANGUAGE 'plpgsql';
/*===============================*/
--END PACKAGE BODY pkg_systeminfo
/*===============================*/

/*===============================*/
--PACKAGE BODY pkg_users
/*===============================*/
CREATE OR REPLACE FUNCTION pkg_users.get_roles_list(i_user_id    user_session.user_id%TYPE,
                          i_session_id user_session.session_id%TYPE,
                          i_key_id     user_session.key_id%TYPE,
                          o_error_id   OUT error_desc.error_desc_id%TYPE,
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

CREATE OR REPLACE FUNCTION pkg_users.login(i_user_login      users.user_login%TYPE,
                 i_pass            users.user_pass%TYPE,
                 i_terminal_ip     user_session.terminal_ip%TYPE,
                 i_terminal_client user_session.terminal_client%TYPE,
		 o_error_id 	   OUT error_desc.error_desc_id%TYPE,
                 o_session_id      OUT user_session.session_id%TYPE,
                 o_key_id          OUT user_session.key_id%TYPE,
                 o_lang_id         OUT users.lang_id%TYPE,
                 o_roles_list      OUT REFCURSOR)
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
  
    o_session_id = session_id_seq.nextval;
    o_key_id     = rawtohex(dbms_crypto.hash(src => utl_raw.cast_to_raw(o_session_id ||
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
  
    o_error_id = get_roles_list(v_user_id, NULL, NULL, o_roles_list);
    RETURN;      
    
  END;
$body$
LANGUAGE 'plpgsql';

  CREATE OR REPLACE FUNCTION pkg_users.update_user_session(i_session_id   user_session.session_id%TYPE,
                                i_key_id       user_session.key_id%TYPE,
                                i_act          user_session.l_action_type_id%TYPE,
                                i_l_is_success user_session.l_is_success%TYPE) RETURNS void AS $$
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

  CREATE OR REPLACE FUNCTION pkg_users.is_permission(i_user_id  users.user_id%TYPE,
                         i_perm_act action_type.action_type_id%TYPE)
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

  CREATE OR REPLACE FUNCTION pkg_users.active_session(i_session_id  user_session.session_id%TYPE,
                          i_key_id      user_session.key_id%TYPE,
                          i_terminal_ip user_session.terminal_ip%TYPE,
                          i_act         user_session.l_action_type_id%TYPE,
                          o_error_id 	OUT error_desc.error_desc_id%TYPE,
                          o_user_id     OUT user_session.user_id%TYPE)
    RETURNS record AS
    $$
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
  
    IF is_permission(o_user_id, i_act) THEN
      v_l_is_success = 1;
    ELSE
      v_l_is_success = 0;
    END IF;
  
    --відпрацювати задачу автономної транзакції (dblink ?)
    perform update_user_session(i_session_id, i_key_id, i_act, v_l_is_success);
  
    IF v_l_is_success == 0 THEN
      RAISE EXCEPTION SQLSTATE 'NPRIV';
    END IF;
  
    RETURN;
  
  EXCEPTION
    WHEN no_data_found THEN
      o_error_id = 1002; --Сесія не існує або минула
      RETURN;
  END;
  $$
    LANGUAGE 'plpgsql';




  create or replace FUNCTION pkg_users.check_user_sess_active(i_session_id  user_session.session_id%TYPE,
                                  i_key_id      user_session.key_id%TYPE,
                                  i_terminal_ip user_session.terminal_ip%TYPE,
                                  i_act         user_session.l_action_type_id%TYPE)
    RETURNS error_desc.error_desc_id%TYPE AS
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

/*===============================*/
--END PACKAGE BODY pkg_users
/*===============================*/
