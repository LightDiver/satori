/* ������� ������� ������������� */      
PROMPT --===========================--
PROMPT insert data for USERS (State, Type Roles i.e.)

INSERT INTO supp_lang VALUES('UA','��������� ���� �����''���',1);
INSERT INTO supp_lang VALUES('EN','English',0);
INSERT INTO supp_lang VALUES('RU','����',0);

INSERT INTO user_state(state_id, state_name)
VALUES(1, '�����������');
INSERT INTO user_state(state_id, state_name)
VALUES(2, '������������');
INSERT INTO user_state(state_id, state_name)
VALUES(3, '���������');

--������ 䳿 � ������
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(1, '����',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(2, '�����',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(3, '������ ��� ������������',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(4, '������ �� ������������ � ������',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(5, '��������� ������ ����������� � ������',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(6, '���������� ��� ����',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(7, 'main.xhtml',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(8, 'about.xhtml',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(9, 'register.xhtml',NULL);


INSERT INTO roles (role_id, role_name, role_short_name)
VALUES(1, '������������', 'ADMIN');
INSERT INTO roles (role_id, role_name, role_short_name)
VALUES(2, '�����������', 'REGISTERED');
INSERT INTO roles (role_id, role_name, role_short_name)
VALUES(3, '����', 'GUEST');
--ADMIN
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,1);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,2);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,3);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,4);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,6);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,7);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,8);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,9);

--REGISTERED
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,1);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,2);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,6);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,7);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,8);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,9);
--GUEST
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,1);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,5);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,6);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,7);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,8);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,9);

--Special users
INSERT INTO users(user_id,user_login, user_pass, user_name, user_email, state_id, r_date, lang_id, user_sex)
VALUES(1,'ADMIN',
       lower(rawtohex(dbms_crypto.hash(src => utl_raw.cast_to_raw('ADMINqwerty'), typ => /*dbms_crypto.hash_sh1*/3))),
       '����',NULL, 1, localtimestamp, 'EN','M'
       );
INSERT INTO users(user_id,user_login, user_pass, user_name, user_email, state_id, r_date, lang_id, user_sex)
VALUES(2,'GUEST',
       '������ �����������������',
       'ó���',NULL, 1, localtimestamp, 'UA','W'
       );
--assign role
INSERT INTO users_role(user_id, role_id) VALUES(1, 1);
INSERT INTO users_role(user_id, role_id) VALUES(2, 3);
       
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1001, '���������� ���� ��� ������');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1002, '���� �� ���� ��� ������');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1003, 'IP ��� ������');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1004, '����������� �����������');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1005, '������ ������ ���� ������� ��� ���� ����');

--��������� 
INSERT INTO user_sess_success(is_success_id, is_success_name)
VALUES(1, '����');
INSERT INTO user_sess_success(is_success_id, is_success_name)
VALUES(0, '³��������');

COMMIT;