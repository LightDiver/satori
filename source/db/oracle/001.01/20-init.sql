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
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(10, 'Others Pages','������� �� �������������� �� ����(������ �� ���� �� �� ��������������� ������)');
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(11, 'news.xhtml',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(12, 'article.xhtml',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(13, 'interest.xhtml',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(14, '��������� �����',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(15, '���� ������� ����� �� ���������� �������',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(16, '���� ������� ����� �� ���������� ����������',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(17, '���� ������� ����� �� ������ �� ���������',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(18, '���� ������� ����� �� �����������',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(19, '������ ��� ������ � ����������� �������',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(20, '����������� �����',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(21, '����������� ����� ����������',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(22, 'editoreditarticle.xhtml',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(23, '������ ������� ��� ���������',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(24, '������ ������������ �������',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(25, '����������� ������',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(26, '�� �����',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(27, '�������� ��� ������',NULL);




                                                  
INSERT INTO roles (role_id, role_name, role_short_name)
VALUES(1, '������������', 'ADMIN');
INSERT INTO roles (role_id, role_name, role_short_name)
VALUES(2, '�����������', 'REGISTERED');
INSERT INTO roles (role_id, role_name, role_short_name)
VALUES(3, '����', 'GUEST');
INSERT INTO roles (role_id, role_name, role_short_name)
VALUES(4, '��������� �������', 'EDITOR');

--ADMIN
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,1);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,2);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,3);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,4);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,6);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,7);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,8);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,9);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,10);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,11);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,12);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,13);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,14);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,15);
--INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,16);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,17);
--INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,18);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,19);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,20);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,24);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,25);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,26);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,27);

--REGISTERED
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,1);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,2);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,6);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,7);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,8);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,9);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,10);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,11);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,12);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,13);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,14);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,15);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,17);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,19);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,20);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,24);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,25);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,26);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,27);

--GUEST
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,1);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,5);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,6);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,7);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,8);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,9);
--INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,10);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,11);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,12);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,13);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,24);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,25);

--EDITOR
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(4,16);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(4,18);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(4,21);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(4,22);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(4,23);

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
INSERT INTO users(user_id,user_login, user_pass, user_name, user_email, state_id, r_date, lang_id, user_sex)
VALUES(3,'EDITOR',
       lower(rawtohex(dbms_crypto.hash(src => utl_raw.cast_to_raw('EDITORqwerty'), typ => /*dbms_crypto.hash_sh1*/3))),
       '��������',NULL, 1, localtimestamp, 'UA','M'
       );

--assign role
INSERT INTO users_role(user_id, role_id) VALUES(1, 1);
INSERT INTO users_role(user_id, role_id) VALUES(1, 4);

INSERT INTO users_role(user_id, role_id) VALUES(2, 3);

INSERT INTO users_role(user_id, role_id) VALUES(3, 2);
INSERT INTO users_role(user_id, role_id) VALUES(3, 4);


INSERT INTO article_status(status_id, status_name)VALUES(1,'���������� �������');
INSERT INTO article_status(status_id, status_name)VALUES(2,'���������� ����������');
INSERT INTO article_status(status_id, status_name)VALUES(3,'������ �� ���������');
INSERT INTO article_status(status_id, status_name)VALUES(4,'�����������');

       
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
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1006, '�������� ������(���������� �������) ����� �� �������� �� ����������');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1007, '�������� ������(���������� ����������) ����� �� �������� �� ����������');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1008, '�������� ������ ����� �� �������� �� ����������');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1009, '�������� _����� ������ �����_ ������ ������');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1010, '���� ������� ����� ���������');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1011, '����� ����');--!(select empty)
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1012, '�� ������ � ��������� � ������ �����');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1013, '�� ������ �������(����� 5�� �������) ���� ������� �����');



--��������� 
INSERT INTO user_sess_success(is_success_id, is_success_name)
VALUES(1, '����');
INSERT INTO user_sess_success(is_success_id, is_success_name)
VALUES(0, '³��������');

INSERT INTO category_article(category_id, category_name) VALUES(1, '����');
INSERT INTO category_article(category_id, category_name) VALUES(2, '������ �������');
INSERT INTO category_article(category_id, category_name) VALUES(3, '����� �� ���''���');
INSERT INTO category_article(category_id, category_name) VALUES(4, 'ֳ���� ����������');





COMMIT;