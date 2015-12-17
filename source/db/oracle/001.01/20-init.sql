/* БАЗОВЫЕ скрипты инициализации */      
PROMPT --===========================--
PROMPT insert data for USERS (State, Type Roles i.e.)

INSERT INTO supp_lang VALUES('UA','Українська мова солов''їна',1);
INSERT INTO supp_lang VALUES('EN','English',0);
INSERT INTO supp_lang VALUES('RU','Раша',0);

INSERT INTO user_state(state_id, state_name)
VALUES(1, 'Активований');
INSERT INTO user_state(state_id, state_name)
VALUES(2, 'Заблокований');
INSERT INTO user_state(state_id, state_name)
VALUES(3, 'Видалиний');

--можливі дії в системі
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(1, 'Вхід',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(2, 'Вихід',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(3, 'Список всіх користувачів',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(4, 'Список дій користувачів в системі',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(5, 'Реєстрація нового користувача в системі',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(6, 'Інформація про себе',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(7, 'main.xhtml',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(8, 'about.xhtml',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(9, 'register.xhtml',NULL);


INSERT INTO roles (role_id, role_name, role_short_name)
VALUES(1, 'Адміністратори', 'ADMIN');
INSERT INTO roles (role_id, role_name, role_short_name)
VALUES(2, 'Зареєстровані', 'REGISTERED');
INSERT INTO roles (role_id, role_name, role_short_name)
VALUES(3, 'Гості', 'GUEST');
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
       'Адмін',NULL, 1, localtimestamp, 'EN','M'
       );
INSERT INTO users(user_id,user_login, user_pass, user_name, user_email, state_id, r_date, lang_id, user_sex)
VALUES(2,'GUEST',
       'пароль невикористовується',
       'Гість',NULL, 1, localtimestamp, 'UA','W'
       );
--assign role
INSERT INTO users_role(user_id, role_id) VALUES(1, 1);
INSERT INTO users_role(user_id, role_id) VALUES(2, 3);
       
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1001, 'Помилковий логін або пароль');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1002, 'Сесія не існує або минула');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1003, 'IP сесії невірне');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1004, 'Недостатньо повноважень');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1005, 'Невірно вказані дата початку або дата кінця');

--довідничок 
INSERT INTO user_sess_success(is_success_id, is_success_name)
VALUES(1, 'Успіх');
INSERT INTO user_sess_success(is_success_id, is_success_name)
VALUES(0, 'Відмовлено');

COMMIT;