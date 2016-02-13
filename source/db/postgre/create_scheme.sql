SET CLIENT_ENCODING TO 'WIN1251';
--—хеми тут зам≥нник пакет≥в в ќракл≥
CREATE SCHEMA pkg_users AUTHORIZATION :pg_User_name;
CREATE SCHEMA pkg_systeminfo AUTHORIZATION :pg_User_name;
CREATE SCHEMA pkg_article AUTHORIZATION :pg_User_name;

CREATE SCHEMA tools AUTHORIZATION :pg_User_name;
CREATE EXTENSION dblink SCHEMA tools;
CREATE EXTENSION pgcrypto;
