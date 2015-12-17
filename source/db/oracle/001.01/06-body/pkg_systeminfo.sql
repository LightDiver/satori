CREATE OR REPLACE PACKAGE BODY pkg_systeminfo IS

  FUNCTION get_description_error(i_error_id error_desc.error_desc_id%TYPE)
    RETURN VARCHAR2 AS
    v_error_desc error_desc.error_desc%TYPE;
  BEGIN
    SELECT ed.error_desc         
      INTO v_error_desc
      FROM error_desc ed
     WHERE ed.error_desc_id = i_error_id;
  
    RETURN v_error_desc;
  END get_description_error;

  FUNCTION get_langs RETURN SYS_REFCURSOR AS
    v_res SYS_REFCURSOR;
  BEGIN
    OPEN v_res FOR
      SELECT l.lang_id, l.lang_name FROM supp_lang l;
    RETURN v_res;
  END get_langs;

END pkg_systeminfo;
/