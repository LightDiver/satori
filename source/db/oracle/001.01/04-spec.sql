/* -------------------------------- */
/*           SPECIFICATION          */
/* -------------------------------- */
CREATE OR REPLACE PACKAGE pkg_users IS

  -- Author  : SERJ
  -- Created : 03.11.2015 12:16:32
  -- Purpose : 

  insufficient_privileges EXCEPTION; --Щоб незабувати оброблювати помилку 1004 

  -- Public function and procedure declarations

  /* Реєстрація сесії
        Помилки:
                1001 - помилковий логін або пароль
  */

  FUNCTION login(i_user_login      users.user_login%TYPE,
                 i_pass            users.user_pass%TYPE,
                 i_terminal_ip     user_session.terminal_ip%TYPE,
                 i_terminal_client user_session.terminal_client%TYPE,
                 o_session_id      OUT user_session.session_id%TYPE,
                 o_key_id          OUT user_session.key_id%TYPE,
                 o_lang_id         OUT users.lang_id%TYPE,
                 o_roles_list      OUT SYS_REFCURSOR)
    RETURN error_desc.error_desc_id%TYPE;

  /* Видалення сесії
  */
  FUNCTION logout(i_session_id user_session.session_id%TYPE,
                  i_key_id     user_session.key_id%TYPE)
    RETURN error_desc.error_desc_id%TYPE;

  /* Перевірка на аткивність сесії.
      Оновлює сесію часом і типом останньої дії користувача
      Перевіряє дозвіл на виконання дії i_act
          
           Помилки:
                   1002 - Сесія не існує або минула
                   1003 - IP сесії невірне
           Помилка-виключення 
                   insufficient_privileges - Недостатньо повноважень (Перехоплювати і встановлювати 1004)        
     
   */
  FUNCTION active_session(i_session_id  user_session.session_id%TYPE,
                          i_key_id      user_session.key_id%TYPE,
                          i_terminal_ip user_session.terminal_ip%TYPE,
                          i_act         user_session.l_action_type_id%TYPE,
                          o_user_id     OUT user_session.user_id%TYPE)
    RETURN error_desc.error_desc_id%TYPE;

   FUNCTION active_session(i_session_id  user_session.session_id%TYPE,
                          i_key_id      user_session.key_id%TYPE,
                          i_terminal_ip user_session.terminal_ip%TYPE,
                          i_act         user_session.l_action_type_id%TYPE)
    RETURN error_desc.error_desc_id%TYPE;

  /*Обгортка active_session ДЛЯ ВИКОРИСТАННЯ ВИКЛИКІВ ІЗ ЗОВНІ
    !Нотебене, Ахтунг: Не використовувати в коді PL/SQL
                      0 - Функція спрацювала без помилок
                      
                   1004 - Недостатньо повноважень для дії i_act
       
                   1002 - Сесія не існує або минула
                   1003 - IP сесії невірне
  */
  FUNCTION check_user_sess_active(i_session_id  user_session.session_id%TYPE,
                                  i_key_id      user_session.key_id%TYPE,
                                  i_terminal_ip user_session.terminal_ip%TYPE,
                                  i_act         user_session.l_action_type_id%TYPE)
    RETURN error_desc.error_desc_id%TYPE;

  /* Список всіх користувачів
  Помилки:
               1004 - Недостатньо повноважень
  */
  FUNCTION list_users(i_session_id  user_session.session_id%TYPE,
                      i_key_id      user_session.key_id%TYPE,
                      i_terminal_ip user_session.terminal_ip%TYPE,
                      o_items       OUT SYS_REFCURSOR)
    RETURN error_desc.error_desc_id%TYPE;
  /* Список дій користувачів в системі
     Помилки:
             1004 - Недостатньо повноважень
             1005 - Невірно вказані дата початку або дата кінця
  */
  FUNCTION list_users_action(i_session_id   user_session.session_id%TYPE,
                             i_key_id       user_session.key_id%TYPE,
                             i_terminal_ip  user_session.terminal_ip%TYPE,
                             i_start_date   user_session_hist.a_date%TYPE,
                             i_end_date     user_session_hist.a_date%TYPE,
                             i_user_id      user_session.user_id%TYPE,
                             i_l_is_success user_session.l_is_success%TYPE,
                             o_items        OUT SYS_REFCURSOR)
    RETURN error_desc.error_desc_id%TYPE;

    /* Реєстрація нового користувача
          Помилки:
                  1004 - Недостатньо повноважень
    */      
  FUNCTION registr(i_session_id  user_session.session_id%TYPE,
                   i_key_id      user_session.key_id%TYPE,
                   i_terminal_ip user_session.terminal_ip%TYPE,
                   
                   i_newuser_login users.user_login%TYPE,
                   i_newuser_pass  users.user_pass%TYPE,
                   i_user_name     users.user_name%TYPE,
                   i_user_email    users.user_email%TYPE,
                   i_user_sex      users.user_sex%TYPE,
                   i_lang_id       users.lang_id%TYPE)
    RETURN error_desc.error_desc_id%TYPE;

  FUNCTION is_user_exist(i_user_login VARCHAR2) RETURN NUMBER;

  /* Інфо користувача по сессії та ключу
  Помилки:
                   1004 - Недостатньо повноважень
  */
  FUNCTION user_info(i_session_id  user_session.session_id%TYPE,
                     i_key_id      user_session.key_id%TYPE,
                     i_terminal_ip user_session.terminal_ip%TYPE,
                     o_user_id     OUT users.user_id%TYPE,
                     o_user_login  OUT users.user_login%TYPE,
                     o_user_name   OUT users.user_name%TYPE,
                     o_user_email  OUT users.user_email%TYPE,
                     o_state_name  OUT user_state.state_name%TYPE,
                     o_r_date      OUT users.r_date%TYPE,
                     o_user_sex    OUT users.user_sex%TYPE,
                     o_lang_id     OUT supp_lang.lang_id%TYPE, 
		o_roles       OUT SYS_REFCURSOR)
    RETURN error_desc.error_desc_id%TYPE;

END pkg_users;
/

CREATE OR REPLACE PACKAGE pkg_systeminfo IS

  -- Author  : SERJ
  -- Created : 01.12.2015 14:28:40
  -- Purpose : 

  FUNCTION get_description_error(i_error_id error_desc.error_desc_id%TYPE)
    RETURN VARCHAR2;

  FUNCTION get_langs RETURN SYS_REFCURSOR;    

END pkg_systeminfo;
/
CREATE OR REPLACE PACKAGE pkg_article IS
  /* Додавання статті
  Помилки:
                   1004 - Недостатньо повноважень
                   1002 - Сесія не існує або минула
                   1003 - IP сесії невірне
  */
  FUNCTION create_new_article(i_session_id      user_session.session_id%TYPE,
                              i_key_id          user_session.key_id%TYPE,
                              i_terminal_ip     user_session.terminal_ip%TYPE,
                              o_article_id      OUT article.article_id%TYPE,
                              i_article_title   article.article_title%TYPE,
                              i_article_short   article.article_short%TYPE,
                              i_article_content article.article_content%TYPE,
                              i_article_lang    article.article_lang%TYPE)
    RETURN error_desc.error_desc_id%TYPE;

  /* Редагування статті
  Помилки:
                   1004 - Недостатньо повноважень
                   1002 - Сесія не існує або минула
                   1003 - IP сесії невірне
       1006 - Поточний статус(редагується автором) статті не дозволяє її редагувати
       1007 - Поточний статус(редагується редактором) статті не дозволяє її редагувати
       1008 - Поточний статус статті не дозволяє її редагувати
       1011 - Пусто
  */
  FUNCTION edit_article(i_session_id       user_session.session_id%TYPE,
                        i_key_id           user_session.key_id%TYPE,
                        i_terminal_ip      user_session.terminal_ip%TYPE,
                        i_article_id       article.article_id%TYPE,
                        i_article_title    article.article_title%TYPE,
                        i_article_short    article.article_short%TYPE,
                        i_article_content  article.article_content%TYPE,
                        i_article_lang     article.article_lang%TYPE,
                        i_article_category VARCHAR2)
    RETURN error_desc.error_desc_id%TYPE;

  /* Зміна статусу статті
  Помилки:
                   1004 - Недостатньо повноважень
                   1002 - Сесія не існує або минула
                   1003 - IP сесії невірне
          1009 - Параметр _новий статус статті_ задано невірно
          1010 - Зміна статусу статті неможлива
          1011 - Пусто
       
       */
  FUNCTION change_status_article(i_session_id         user_session.session_id%TYPE,
                                 i_key_id             user_session.key_id%TYPE,
                                 i_terminal_ip        user_session.terminal_ip%TYPE,
                                 i_article_id         article.article_id%TYPE,
                                 i_atricle_status_new article.article_status_id%TYPE)
    RETURN error_desc.error_desc_id%TYPE;
  /* Повернути статтю яка в статусі Редагування автором
  Помилки:
                   1004 - Недостатньо повноважень
                   1002 - Сесія не існує або минула
                   1003 - IP сесії невірне
              1011 - Пусто
  */
  FUNCTION get_last_edit_active_article(i_session_id       user_session.session_id%TYPE,
                                        i_key_id           user_session.key_id%TYPE,
                                        i_terminal_ip      user_session.terminal_ip%TYPE,
                                        o_article_id       OUT article.article_id%TYPE,
                                        o_article_title    OUT article.article_title%TYPE,
                                        o_article_short    OUT article.article_short%TYPE,
                                        o_article_content  OUT article.article_content%TYPE,
                                        o_article_lang     OUT article.article_lang%TYPE,
                                        o_article_category OUT VARCHAR2)
    RETURN error_desc.error_desc_id%TYPE;

  /* Повернути статтю яка в статусі Редагування редактором за умови що редактором він і є
  Помилки:
                   1004 - Недостатньо повноважень
                   1002 - Сесія не існує або минула
                   1003 - IP сесії невірне
               1011 - Пусто
  */
  FUNCTION get_edit_editor_article(i_session_id       user_session.session_id%TYPE,
                                   i_key_id           user_session.key_id%TYPE,
                                   i_terminal_ip      user_session.terminal_ip%TYPE,
                                   i_article_id       article.article_id%TYPE,
                                   o_article_title    OUT article.article_title%TYPE,
                                   o_article_short    OUT article.article_short%TYPE,
                                   o_article_content  OUT article.article_content%TYPE,
                                   o_article_lang     OUT article.article_lang%TYPE,
                                   o_article_category OUT VARCHAR2)
    RETURN error_desc.error_desc_id%TYPE;

  /* Повернути статті яка в певному статусі або всі якщо null 
  Помилки:
                   1004 - Недостатньо повноважень
                   1002 - Сесія не існує або минула
                   1003 - IP сесії невірне
  */
  FUNCTION get_editor_article_list(i_session_id        user_session.session_id%TYPE,
                                   i_key_id            user_session.key_id%TYPE,
                                   i_terminal_ip       user_session.terminal_ip%TYPE,
                                   i_article_status_id article.article_status_id%TYPE,
                                   o_items             OUT SYS_REFCURSOR)
    RETURN error_desc.error_desc_id%TYPE;

END pkg_article;
/