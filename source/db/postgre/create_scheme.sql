--—хеми тут зам≥нник пакет≥в в ќракл≥
CREATE SCHEMA pkg_users AUTHORIZATION :User_name;
CREATE SCHEMA pkg_systeminfo AUTHORIZATION :User_name;
CREATE SCHEMA pkg_article AUTHORIZATION :User_name;

CREATE SCHEMA tools AUTHORIZATION :User_name;
CREATE EXTENSION dblink SCHEMA tools;
CREATE EXTENSION pgcrypto;
