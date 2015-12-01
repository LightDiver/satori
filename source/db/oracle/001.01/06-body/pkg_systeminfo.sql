CREATE OR REPLACE PACKAGE BODY pkg_systeminfo IS

  FUNCTION get_description_error(i_error_id error_desc.error_desc_id%TYPE,
                                 i_lang_id  users.lang_id%TYPE DEFAULT 'UA')
    RETURN VARCHAR2 AS
    v_error_desc error_desc.error_desc%TYPE;
  BEGIN
    SELECT (CASE
             WHEN i_lang_id = 'UA' THEN
              ed.error_desc
             ELSE
              (SELECT td.translate_name
                 FROM translate_dict td
                WHERE td.translate_pls_id = ed.translate_pls_id
                  AND td.lang_id = i_lang_id)
           END)
      INTO v_error_desc
      FROM error_desc ed
     WHERE ed.error_desc_id = i_error_id;
  
    RETURN v_error_desc;
  END get_description_error;
END pkg_systeminfo;
/