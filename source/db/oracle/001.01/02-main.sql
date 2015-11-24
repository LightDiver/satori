---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- File 02-main.sql create next DataBase objects:                                          --
--    SEQUENCES                                                                            --
--    TABLES                                                                               --
--    INDEXES                                                                              --
--    FOREIGN KEYS CONSTRAINT                                                              --
--    CHECK  CONSTRAINT                                                                    --
--    UNIQUE CONSTRAINT                                                                    --
--    TYPES                                                                                --
--                                                                                         --
-- Each object's chapter start from next comment :                                         --
--                                                                                         --
--    /* -------------------------------- */                                               --
--    /*           Object name            */                                               --
--    /* -------------------------------- */                                               --
--                                                                                         --
--  for example:                                                                           --
--                                                                                         --
--   /* -------------------------------- */                                                --
--   /*           SEQUENCES              */                                                --
--   /* -------------------------------- */                                                --
--                                                                                         --
--                                                                                         --
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

/* -------------------------------- */
/*           SEQUENCES              */
/* -------------------------------- */
CREATE SEQUENCE session_id_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NOCACHE
  CYCLE;

CREATE SEQUENCE translate_dict_id_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1
  NOCACHE;

CREATE SEQUENCE users_id_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1000
  NOCACHE;



/* -------------------------------- */
/*           TABLES                 */
/* -------------------------------- */
--*************
--Користувачі, Ролева модель
--*************
create table USER_STATE (
   STATE_ID             NUMBER(2)           not null,
   STATE_NAME           VARCHAR2(55)          not null,
   translate_pls_id NUMBER(5) not null,
   constraint USER_STATE_PK primary key (STATE_ID)
);
comment on column USER_STATE.translate_pls_id is 'Дивиться на довідник TRANSLATE_DICT';


create table USERS (
   USER_ID              NUMBER(18)          not null,
   USER_LOGIN           VARCHAR2(30)          not null,
   USER_PASS            VARCHAR2(55)          null,
   USER_NAME            VARCHAR2(55)          null,
   USER_EMAIL           VARCHAR2(55)          null,
   STATE_ID             NUMBER(2)           not null,
   USER_SEX             VARCHAR2(1)         not null,
   LANG_ID		VARCHAR2(2) DEFAULT 'UA' not null,
   R_DATE               DATE                 not null,
   constraint USERS_PK primary key (USER_ID)
);
comment on column USERS.user_sex is 'M - Мужчина W - Жінка. Підарам тут не місце. ';

create table ROLES (
   ROLE_ID              NUMBER(5)          not null,
   ROLE_NAME            VARCHAR2(55)         not null,
   ROLE_SHORT_NAME      VARCHAR2(30)         not null,
   translate_pls_id NUMBER(5) not null,
   constraint ROLES_PK primary key (ROLE_ID)
);
comment on column ROLES.translate_pls_id is 'Дивиться на довідник TRANSLATE_DICT';

create table USERS_ROLE (
   USER_ID              NUMBER(18)          not null,
   ROLE_ID              NUMBER(5)          not null,
   R_DATE               DATE         default localtimestamp        not null
);

create table ACTION_TYPE (
   ACTION_TYPE_ID       NUMBER(10)          not null,
   ACTION_NAME          VARCHAR2(50)          not null,
   ACTION_DESCRIPTION   VARCHAR2(255)         null,
   translate_pls_id NUMBER(5) not null,
   constraint ACTION_TYPE_PK primary key (ACTION_TYPE_ID)
);
comment on table ACTION_TYPE is 'Довідник можливих дій в системі';
comment on column ACTION_TYPE.translate_pls_id is 'Дивиться на довідник TRANSLATE_DICT';

create table ROLES_PERM_ACTION (
   ROLE_ID              NUMBER(5)          not null,
   ACTION_TYPE_ID       NUMBER(10)          not null
);

create table USER_SESSION (
   session_id           number(18,0)          not null,
   key_id    varchar2(40), 
   user_id              number(18,0),
   terminal_ip    varchar2(15) not NULL,
   terminal_client  VARCHAR2(255) default 'unknown' not null,
   l_date               timestamp NOT NULL,
   l_action_type_id     number(10,0) NOT NULL,
   r_date               timestamp NOT NULL,
   l_is_success     NUMBER(1) default 1 not null,
   constraint USER_SESSION_PK primary key (SESSION_ID)
);
create table USER_SESSION_HIST
(
  session_id       NUMBER(18) not null,
  key_id           VARCHAR2(40),
  user_id          NUMBER(18),
  terminal_ip      VARCHAR2(15) not null,
  l_date           TIMESTAMP(6) not null,
  l_action_type_id NUMBER(10) not null,
  r_date           TIMESTAMP(6) not null,
  l_is_success     NUMBER(1) default 1 not null,
  terminal_client  VARCHAR2(255) default 'unknown' not null,
  a_date           DATE default localtimestamp not null,
  a_act            NUMBER(1) not null
);
comment on column USER_SESSION_HIST.a_act is '1-INS, 2-UPD, 3-DEL';

create table USER_SESS_SUCCESS
(
  is_success_id   NUMBER(1) not null,
  is_success_name VARCHAR2(20) not null,
  translate_pls_id NUMBER(5) not null,
  constraint IS_SUCCESS_ID_PK primary key (IS_SUCCESS_ID)
);


create table SUPP_LANG
(
  lang_id   VARCHAR2(2) not null,
  lang_name VARCHAR2(80) not null,
  is_system NUMBER(1) default 0 not null,
  constraint SUPP_LANG_LANG_ID_PK primary key (LANG_ID)
);
comment on table SUPP_LANG is 'мови що підтримуються';

create table TRANSLATE_DICT
(
  translate_dict_id NUMBER(10) not null,
  translate_pls_id  NUMBER(5) not null,
  lang_id           VARCHAR2(2) not null,
  translate_name    VARCHAR2(255) not null,
  translate_desc    VARCHAR2(2048)
  constraint TRANSLATE_DICT_PLS_LANG_PK primary key (TRANSLATE_PLS_ID, LANG_ID)
);
comment on table TRANSLATE_DICT is 'переклад довідників системи';

create table ERROR_DESC
(
  error_desc_id    NUMBER(5) not null,
  error_desc       VARCHAR2(255) not null,
  translate_pls_id NUMBER(5) not null
);
comment on table ERROR_DESC is 'Опис помилок в системі';
-- Add comments to the columns 
comment on column ERROR_DESC.translate_pls_id is 'Дивиться на довідник TRANSLATE_DICT';

/* -------------------------------- */
/*             INDEXES              */
/* -------------------------------- */
create index USER_SESSION_HIST_A_DATE_IDX on USER_SESSION_HIST (A_DATE)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255;



/* -------------------------------- */
/*           FOREIGN                */
/* -------------------------------- */
alter table USERS
   add constraint USERS_USER_STATE_ID_FK foreign key (STATE_ID)
      references USER_STATE (STATE_ID);
alter table USERS
   add constraint USERS_LANG_ID_FK foreign key (LANG_ID)
      references supp_lang (LANG_ID);


alter table USERS_ROLE
   add constraint USERS_ID_ROLES_FK foreign key (USER_ID)
      references USERS (USER_ID);
alter table USERS_ROLE
   add constraint USERS_ROLE_ID_FK foreign key (ROLE_ID)
      references ROLES (ROLE_ID); 

alter table ROLES_PERM_ACTION
   add constraint ROLES_PERM_ACTION_ID_FK foreign key (ACTION_TYPE_ID)
      references ACTION_TYPE (ACTION_TYPE_ID);
alter table ROLES_PERM_ACTION
   add constraint ROLES_PERM_ROLE_ID_FK foreign key (ROLE_ID)
      references ROLES (ROLE_ID);

alter table USER_SESSION
   add constraint USER_SESS_USER_ID_FK foreign key (USER_ID)
      references USERS (USER_ID);
alter table USER_SESSION
   add constraint user_sess_action_id_fk FOREIGN KEY (l_action_type_id)
      REFERENCES action_type (action_type_id);     
alter table USER_SESSION
  add constraint USER_SESS_SUCCESS_FK foreign key (L_IS_SUCCESS)
  references USER_SESS_SUCCESS (IS_SUCCESS_ID);

alter table TRANSLATE_DICT
  add constraint TRANSLATE_DICT_LANG_ID_PK foreign key (LANG_ID)
  references SUPP_LANG (LANG_ID);

/* -------------------------------- */
/*            CHECK                 */
/* -------------------------------- */


/* -------------------------------- */
/*            UNIQUE                */
/* -------------------------------- */
CREATE UNIQUE INDEX users_login_idx ON users(user_login);
CREATE UNIQUE INDEX roles_idx ON roles(ROLE_SHORT_NAME);
CREATE UNIQUE INDEX users_role_idx ON users_role (user_id, role_id);
create unique index TRANSLATE_DICT_ID_IDX1 on TRANSLATE_DICT (TRANSLATE_DICT_ID);
create unique index ERROR_DESC_ID_IDX1 on ERROR_DESC (ERROR_DESC_ID);
/* -------------------------------- */
/*            TYPES                 */
/* -------------------------------- */

