/* FOR LOAD FILES */
/*
DROP TABLE LOB_OBJ;
*/

CREATE TABLE lob_obj
(
  id numeric(5,0),
  name_content character varying(100),
  lang_content character varying(2),
  category_content character varying(100),
  short_content text,
  clob_content text,
  user_name character varying(30) DEFAULT "current_user"(),
  user_date timestamp without time zone DEFAULT now()
);