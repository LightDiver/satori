/* -------------------------------- */
/*           SPECIFICATION          */
/* -------------------------------- */
CREATE OR REPLACE PACKAGE pkg_users IS

  -- Author  : SERJ
  -- Created : 03.11.2015 12:16:32
  -- Purpose : 

  insufficient_privileges EXCEPTION; --��� ���������� ����������� ������� 1004 

  -- Public function and procedure declarations

  /* ��������� ���
    ��� �������:
    ����������� 1001 - ���������� ���� ��� ������
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

  /* ��������� ���
  */
  FUNCTION logout(i_session_id user_session.session_id%TYPE,
                  i_key_id     user_session.key_id%TYPE)
    RETURN error_desc.error_desc_id%TYPE;

  /* �������� �� ��������� ���.
  ��� ������� ���� ����� � ����� �������� 䳿 �����������
      �������� ����� �� ��������� 䳿 i_act
          
       ��� �������:
       ����������� 1002 - ���� �� ���� ��� ������
                   1003 - IP ��� ������
           �������-���������� 
                   insufficient_privileges - ����������� ����������� (������������� � ������������� 1004)        
     
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

  /* ������ ��� ������������
  �������:
               1004 - ����������� �����������
  */
  FUNCTION list_users(i_session_id  user_session.session_id%TYPE,
                      i_key_id      user_session.key_id%TYPE,
                      i_terminal_ip user_session.terminal_ip%TYPE,
                      i_lang_id     supp_lang.lang_id%TYPE,
                      o_items       OUT SYS_REFCURSOR)
    RETURN error_desc.error_desc_id%TYPE;
  /* ������ �� ������������ � ������
     �������:
             1004 - ����������� �����������
             1005 - ������ ������ ���� ������� ��� ���� ����
  */
  FUNCTION list_users_action(i_session_id   user_session.session_id%TYPE,
                             i_key_id       user_session.key_id%TYPE,
                             i_terminal_ip  user_session.terminal_ip%TYPE,
                             i_lang_id      supp_lang.lang_id%TYPE,
                             i_start_date   user_session_hist.a_date%TYPE,
                             i_end_date     user_session_hist.a_date%TYPE,
                             i_user_id      user_session.user_id%TYPE,
                             i_l_is_success user_session.l_is_success%TYPE,
                             o_items        OUT SYS_REFCURSOR)
    RETURN error_desc.error_desc_id%TYPE;

    /* ��������� ������ �����������
      ��� �������:
                  1004 - ����������� �����������
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

  /* ���� ����������� �� ���� �� �����
  �������:
       ����������� 1004 - ����������� �����������
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

  FUNCTION get_description_error(i_error_id error_desc.error_desc_id%TYPE,
                                 i_lang_id  users.lang_id%TYPE DEFAULT 'UA')
    RETURN VARCHAR2;

  FUNCTION get_langs RETURN SYS_REFCURSOR;    

END pkg_systeminfo;
/