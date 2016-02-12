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
  CACHE 1
  CYCLE;

CREATE SEQUENCE users_id_seq
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START WITH 1000
  CACHE 1;

create sequence ARTICLE_ID_SEQ
minvalue 1
maxvalue 100000
start with 1001
increment by 1
CACHE 1;



/* -------------------------------- */
/*           TABLES                 */
/* -------------------------------- */
--*************
--Користувачі, Ролева модель
--*************
create table USER_STATE (
   STATE_ID             NUMERIC(2)           not null,
   STATE_NAME           VARCHAR(55)          not null,
   constraint USER_STATE_PK primary key (STATE_ID)
);

create table USERS (
   USER_ID              NUMERIC(18)          not null,
   USER_LOGIN           VARCHAR(30)          not null,
   USER_PASS            VARCHAR(55)          null,
   USER_NAME            VARCHAR(55)          null,
   USER_EMAIL           VARCHAR(55)          null,
   STATE_ID             NUMERIC(2)           not null,
   USER_SEX             VARCHAR(1)         not null,
   LANG_ID		VARCHAR(2) DEFAULT 'UA' not null,
   R_DATE               DATE                 not null,
   constraint USERS_PK primary key (USER_ID)
);
comment on column USERS.user_sex is 'M - Мужчина W - Жінка. Підарам тут не місце. ';

create table ROLES (
   ROLE_ID              NUMERIC(5)          not null,
   ROLE_NAME            VARCHAR(55)         not null,
   ROLE_SHORT_NAME      VARCHAR(30)         not null,
   constraint ROLES_PK primary key (ROLE_ID)
);

create table USERS_ROLE (
   USER_ID              NUMERIC(18)          not null,
   ROLE_ID              NUMERIC(5)          not null,
   R_DATE               DATE         default localtimestamp        not null
);

create table ACTION_TYPE (
   ACTION_TYPE_ID       NUMERIC(10)          not null,
   ACTION_NAME          VARCHAR(50)          not null,
   ACTION_DESCRIPTION   VARCHAR(255)         null,
   constraint ACTION_TYPE_PK primary key (ACTION_TYPE_ID)
);
comment on table ACTION_TYPE is 'Довідник можливих дій в системі';

create table ROLES_PERM_ACTION (
   ROLE_ID              NUMERIC(5)          not null,
   ACTION_TYPE_ID       NUMERIC(10)          not null
);

create table USER_SESSION (
   session_id           NUMERIC(18,0)          not null,
   key_id    VARCHAR(40), 
   user_id              NUMERIC(18,0),
   terminal_ip    VARCHAR(15) not NULL,
   terminal_client  VARCHAR(255) default 'unknown' not null,
   l_date               timestamp NOT NULL,
   l_action_type_id     NUMERIC(10,0) NOT NULL,
   r_date               timestamp NOT NULL,
   l_is_success     NUMERIC(1) default 1 not null,
   constraint USER_SESSION_PK primary key (SESSION_ID)
);
create table USER_SESSION_HIST
(
  session_id       NUMERIC(18) not null,
  key_id           VARCHAR(40),
  user_id          NUMERIC(18),
  terminal_ip      VARCHAR(15) not null,
  l_date           TIMESTAMP(6) not null,
  l_action_type_id NUMERIC(10) not null,
  r_date           TIMESTAMP(6) not null,
  l_is_success     NUMERIC(1) default 1 not null,
  terminal_client  VARCHAR(255) default 'unknown' not null,
  a_date           DATE default localtimestamp not null,
  a_act            NUMERIC(1) not null
);
comment on column USER_SESSION_HIST.a_act is '1-INS, 2-UPD, 3-DEL';

create table USER_SESS_SUCCESS
(
  is_success_id   NUMERIC(1) not null,
  is_success_name VARCHAR(20) not null,
  constraint IS_SUCCESS_ID_PK primary key (IS_SUCCESS_ID)
);


create table SUPP_LANG
(
  lang_id   VARCHAR(2) not null,
  lang_name VARCHAR(80) not null,
  is_system NUMERIC(1) default 0 not null,
  constraint SUPP_LANG_LANG_ID_PK primary key (LANG_ID)
);
comment on table SUPP_LANG is 'мови що підтримуються';

create table ERROR_DESC
(
  error_desc_id    NUMERIC(5) not null,
  error_desc       VARCHAR(255) not null
);
comment on table ERROR_DESC is 'Опис помилок в системі';

create table ARTICLE_STATUS
(
  status_id   NUMERIC(1) not null,
  status_name VARCHAR(50) not null,
  constraint STATUS_ID_PK primary key (STATUS_ID)
);

create table ARTICLE
(
  article_id          NUMERIC(5) not null,
  article_title       VARCHAR(300),
  article_short       VARCHAR(2000),
  article_content     TEXT,
  article_status_id   NUMERIC(1) not null,
  article_create_date TIMESTAMP(6) not null,
  article_creator_id  NUMERIC(18) not null,
  article_public_date TIMESTAMP(6),
  article_editor_id   NUMERIC(18),
  article_edit_date   TIMESTAMP(6),
  article_lang        VARCHAR(2),
  article_comment     VARCHAR(255),
  constraint ARTICLE_ID_PK primary key (ARTICLE_ID)
);
comment on column ARTICLE.article_create_date
  is 'Дата створення або дата відправки на перегляд редактору(момент Готовий до публікації)';
comment on column ARTICLE.article_edit_date
  is 'Дата останнього редагування редактором';
comment on column ARTICLE.article_comment
  is 'Коментар при зміні статусу при поверненні на доопрацювання';

create table CATEGORY_ARTICLE
(
  category_id   NUMERIC(2) not null,
  category_name VARCHAR(50) not null,
  constraint CATEGORY_ID_PK primary key (CATEGORY_ID)
);

create table CATEGORY_ARTICLE_LINK
(
  category_id NUMERIC(2) not null,
  article_id  NUMERIC(5) not null
);

create table SYS_VERSION
(
  id        NUMERIC not null,
  major     NUMERIC(3),
  minor     NUMERIC(3),
  user_note VARCHAR(255),
  user_name VARCHAR(30),
  user_date DATE
);

/* -------------------------------- */
/*             INDEXES              */
/* -------------------------------- */
create index USER_SESSION_HIST_A_DATE_IDX on USER_SESSION_HIST (A_DATE);

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

alter table ARTICLE
  add constraint ARTICLE_CREATOR_ID_FK foreign key (ARTICLE_CREATOR_ID)
  references USERS (USER_ID);
alter table ARTICLE
  add constraint ARTICLE_EDITOR_ID_FK foreign key (ARTICLE_EDITOR_ID)
  references USERS (USER_ID);
alter table ARTICLE
  add constraint ARTICLE_STATUS_ID_FK foreign key (ARTICLE_STATUS_ID)
  references ARTICLE_STATUS (STATUS_ID);
alter table ARTICLE
  add constraint ARTICLE_LANG_FK foreign key (ARTICLE_LANG)
  references SUPP_LANG (LANG_ID);

alter table CATEGORY_ARTICLE_LINK
  add constraint ARTICLE_ID_FK foreign key (ARTICLE_ID)
  references ARTICLE (ARTICLE_ID);
alter table CATEGORY_ARTICLE_LINK
  add constraint CATEGORY_ID_FK foreign key (CATEGORY_ID)
  references CATEGORY_ARTICLE (CATEGORY_ID);
/* -------------------------------- */
/*            CHECK                 */
/* -------------------------------- */


/* -------------------------------- */
/*            UNIQUE                */
/* -------------------------------- */
CREATE UNIQUE INDEX users_login_idx ON users(user_login);
CREATE UNIQUE INDEX roles_idx ON roles(ROLE_SHORT_NAME);
CREATE UNIQUE INDEX users_role_idx ON users_role (user_id, role_id);
create unique index ERROR_DESC_ID_IDX1 on ERROR_DESC (ERROR_DESC_ID);
create unique index ARTICLE_CATEGORY_UNIQ on CATEGORY_ARTICLE_LINK (ARTICLE_ID, CATEGORY_ID);
create unique index role_action_idx on ROLES_PERM_ACTION (role_id, action_type_id);
create unique index VERS_UNIQ on SYS_VERSION (MAJOR, MINOR);
/* -------------------------------- */
/*            TYPES                 */
/* -------------------------------- */

