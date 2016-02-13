SET CLIENT_ENCODING TO 'WIN1251';
--PACKAGE BODY pkg_systeminfo

  CREATE OR REPLACE FUNCTION pkg_systeminfo.get_description_error(i_error_id numeric)
    RETURNS VARCHAR AS
    $BODY$
  DECLARE 
    v_error_desc error_desc.error_desc%TYPE;
  BEGIN
    SELECT ed.error_desc
      INTO v_error_desc
      FROM error_desc ed
     WHERE ed.error_desc_id = i_error_id;
  
    RETURN v_error_desc;
  END;
  $BODY$
  LANGUAGE 'plpgsql';

  CREATE OR REPLACE FUNCTION pkg_systeminfo.get_langs() RETURNS refcursor AS
    $BODY$
  DECLARE 
    v_res refcursor;
  BEGIN
    OPEN v_res FOR
      SELECT l.lang_id, l.lang_name FROM supp_lang l;
    RETURN v_res;
  END;
  $BODY$
  LANGUAGE 'plpgsql';

  CREATE OR REPLACE FUNCTION pkg_systeminfo.check_version(i_major numeric) RETURNS NUMERIC AS
  $BODY$
  DECLARE 
    v_res NUMERIC(1,0);
    /* 0 - Остання версія не співпадає
      > 0 - Співпадає
    */
  BEGIN
    SELECT COUNT(*)
      INTO v_res
      FROM sys_version s
     WHERE s.major = i_major
       AND s.user_date = (SELECT MAX(user_date) FROM sys_version);
    RETURN v_res;
  END;
  $BODY$
  LANGUAGE 'plpgsql';
/*===============================*/
--END PACKAGE BODY pkg_systeminfo
/*===============================*/