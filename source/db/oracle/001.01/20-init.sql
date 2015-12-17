/* ������� ������� ������������� */      
PROMPT --===========================--
PROMPT insert data for USERS (State, Type Roles i.e.)

INSERT INTO supp_lang VALUES('UA','��������� ���� �����''���',1);

INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,1,'UA','�����������',NULL);
INSERT INTO user_state(state_id, state_name, translate_pls_id)
VALUES(1, '�����������',1);
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,2,'UA','������������',NULL);
INSERT INTO user_state(state_id, state_name, translate_pls_id)
VALUES(2, '������������',2);
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,3,'UA','���������',NULL);
INSERT INTO user_state(state_id, state_name, translate_pls_id)
VALUES(3, '���������',3);


INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,4,'UA','����',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description, translate_pls_id)
VALUES(1, '����',NULL,4);
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,5,'UA','�����',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description, translate_pls_id)
VALUES(2, '�����',NULL,5);
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,6,'UA','������ ��� ������������',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description, translate_pls_id)
VALUES(3, '������ ��� ������������',NULL,6);

INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,7,'UA','������������',NULL);
INSERT INTO roles (role_id, role_name, role_short_name, translate_pls_id)
VALUES(1, '������������', 'ADMIN', 7);
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,8,'UA','�����������',NULL);
INSERT INTO roles (role_id, role_name, role_short_name, translate_pls_id)
VALUES(2, '�����������', 'REGISTERED', 8);
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,9,'UA','����',NULL);
INSERT INTO roles (role_id, role_name, role_short_name, translate_pls_id)
VALUES(3, '����', 'GUEST', 9);
--ADMIN
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,1);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,2);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,3);
--REGISTERED
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,1);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,2);
--GUEST
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,1);

--Special users
INSERT INTO users(user_id,user_login, user_pass, user_name, user_email, state_id, r_date, lang_id)
VALUES(1,'ADMIN',
       lower(rawtohex(dbms_crypto.hash(src => utl_raw.cast_to_raw('ADMINqwerty'), typ => /*dbms_crypto.hash_sh1*/3))),
       '����',NULL, 1, localtimestamp, 'UA'
       );
INSERT INTO users(user_id,user_login, user_pass, user_name, user_email, state_id, r_date, lang_id)
VALUES(2,'GUEST',
       '������ �����������������',
       'ó���',NULL, 1, localtimestamp, 'UA'
       );
--assign role
INSERT INTO users_role(user_id, role_id) VALUES(1, 1);
INSERT INTO users_role(user_id, role_id) VALUES(2, 3);
       
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,10,'UA','1001','���������� ���� ��� ������');      
INSERT INTO error_desc (error_desc_id, error_desc, translate_pls_id)
VALUES (1001, '���������� ���� ��� ������',10);
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,11,'UA','1002','���� �� ���� ��� ������');      
INSERT INTO error_desc (error_desc_id, error_desc, translate_pls_id)
VALUES (1002, '���� �� ���� ��� ������',11);
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,12,'UA','1003','IP ��� ������');      
INSERT INTO error_desc (error_desc_id, error_desc, translate_pls_id)
VALUES (1003, 'IP ��� ������',12);
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,13,'UA','1004','����������� �����������');      
INSERT INTO error_desc (error_desc_id, error_desc, translate_pls_id)
VALUES (1004, '����������� �����������',13);

--�� 䳿
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,14,'UA','������ �� ������������ � ������',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description, translate_pls_id)
VALUES(4, '������ �� ������������ � ������',NULL,14);
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,15,'UA','��������� ������ ����������� � ������',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description, translate_pls_id)
VALUES(5, '��������� ������ ����������� � ������',NULL,15);
--ADMIN
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,4);
--REGISTERED
--GUEST
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,5);

--�� ���� �������
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,16,'UA','1005','������ ������ ���� ������� ��� ���� ����');      
INSERT INTO error_desc (error_desc_id, error_desc, translate_pls_id)
VALUES (1005, '������ ������ ���� ������� ��� ���� ����',16);

--��������� 
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,17,'UA','����',NULL);
INSERT INTO user_sess_success(is_success_id, is_success_name, translate_pls_id)
VALUES(1, '����', 17);
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,18,'UA','³��������',NULL);
INSERT INTO user_sess_success(is_success_id, is_success_name, translate_pls_id)
VALUES(0, '³��������', 18);

--ĳ�
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,19,'UA','���������� ��� ����',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description, translate_pls_id)
VALUES(6, '���������� ��� ����',NULL,19);
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,20,'UA','main.xhtml',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description, translate_pls_id)
VALUES(7, 'main.xhtml',NULL,19);
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,21,'UA','about.xhtml',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description, translate_pls_id)
VALUES(8, 'about.xhtml',NULL,21);
INSERT INTO translate_dict(translate_dict_id, translate_pls_id, lang_id, translate_name, translate_desc) 
VALUES (translate_dict_id_seq.nextval,22,'UA','registr.xhtml',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description, translate_pls_id)
VALUES(9, 'registr.xhtml',NULL,22);

--ADMIN
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,6);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,7);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,8);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(1,9);
--REGISTERED
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,6);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,7);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,8);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(2,9);
--GUEST
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,6);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,7);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,8);
INSERT INTO roles_perm_action(role_id, action_type_id) VALUES(3,9);


COMMIT;