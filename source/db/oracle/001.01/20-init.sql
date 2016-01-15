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
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(10, 'Others Pages','Сторінки які відслідковуються як інші(можуть ще бути які не відсклідковуються взагалі)');
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(11, 'news.xhtml',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(12, 'article.xhtml',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(13, 'interest.xhtml',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(14, 'Додавання статті',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(15, 'Зміна статусу статті на редагується автором',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(16, 'Зміна статусу статті на редагується редактором',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(17, 'Зміна статусу статті на готова до публікації',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(18, 'Зміна статусу статті на опубліковано',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(19, 'Знайти мою статтю в Редагування автором',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(20, 'Редагування статті',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(21, 'Редагування статті редактором',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(22, 'editoreditarticle.xhtml',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(23, 'Список статтей для редактора',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(24, 'Список опублікованих статтей',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(25, 'Опублікована стаття',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(26, 'Мої статті',NULL);
INSERT INTO action_type(action_type_id, action_name, action_description)
VALUES(27, 'Видалити мою статтю',NULL);




                                                  
INSERT INTO roles (role_id, role_name, role_short_name)
VALUES(1, 'Адміністратори', 'ADMIN');
INSERT INTO roles (role_id, role_name, role_short_name)
VALUES(2, 'Зареєстровані', 'REGISTERED');
INSERT INTO roles (role_id, role_name, role_short_name)
VALUES(3, 'Гості', 'GUEST');
INSERT INTO roles (role_id, role_name, role_short_name)
VALUES(4, 'Редактори статтей', 'EDITOR');

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
       'Адмін',NULL, 1, localtimestamp, 'EN','M'
       );
INSERT INTO users(user_id,user_login, user_pass, user_name, user_email, state_id, r_date, lang_id, user_sex)
VALUES(2,'GUEST',
       'пароль невикористовується',
       'Гість',NULL, 1, localtimestamp, 'UA','W'
       );
INSERT INTO users(user_id,user_login, user_pass, user_name, user_email, state_id, r_date, lang_id, user_sex)
VALUES(3,'EDITOR',
       lower(rawtohex(dbms_crypto.hash(src => utl_raw.cast_to_raw('EDITORqwerty'), typ => /*dbms_crypto.hash_sh1*/3))),
       'Редактор',NULL, 1, localtimestamp, 'UA','M'
       );

--assign role
INSERT INTO users_role(user_id, role_id) VALUES(1, 1);
INSERT INTO users_role(user_id, role_id) VALUES(1, 4);

INSERT INTO users_role(user_id, role_id) VALUES(2, 3);

INSERT INTO users_role(user_id, role_id) VALUES(3, 2);
INSERT INTO users_role(user_id, role_id) VALUES(3, 4);


INSERT INTO article_status(status_id, status_name)VALUES(1,'Редагується автором');
INSERT INTO article_status(status_id, status_name)VALUES(2,'Редагується редактором');
INSERT INTO article_status(status_id, status_name)VALUES(3,'Готова до публікації');
INSERT INTO article_status(status_id, status_name)VALUES(4,'Опубліковано');

       
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
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1006, 'Поточний статус(редагується автором) статті не дозволяє її редагувати');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1007, 'Поточний статус(редагується редактором) статті не дозволяє її редагувати');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1008, 'Поточний статус статті не дозволяє її редагувати');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1009, 'Параметр _новий статус статті_ задано невірно');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1010, 'Зміна статусу статті неможлива');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1011, 'Даних немає');--!(select empty)
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1012, 'Не задано ні заголовку ні тексту статті');
INSERT INTO error_desc (error_desc_id, error_desc)
VALUES (1013, 'Не задана причина(більше 5ти символів) зміни статусу статті');



--довідничок 
INSERT INTO user_sess_success(is_success_id, is_success_name)
VALUES(1, 'Успіх');
INSERT INTO user_sess_success(is_success_id, is_success_name)
VALUES(0, 'Відмовлено');

INSERT INTO category_article(category_id, category_name) VALUES(1, 'Інше');
INSERT INTO category_article(category_id, category_name) VALUES(2, 'Швидке читання');
INSERT INTO category_article(category_id, category_name) VALUES(3, 'Увага та пам''ять');
INSERT INTO category_article(category_id, category_name) VALUES(4, 'Цікава математика');





COMMIT;