WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

CONN &1/&2@&3

DECLARE
  v_i NUMBER(3);
BEGIN
--  SELECT MAX(article_id) INTO v_i FROM article WHERE article_id < 1000;
  FOR cur IN (SELECT * FROM lob_obj)
  LOOP
--    v_i := v_i + 1;
    INSERT INTO article(article_id,
                        article_title,
                        article_short,
                        article_content,
                        article_status_id,
                        article_create_date,
                        article_creator_id,
                        article_public_date,
                        article_editor_id,
                        article_lang,
                        article_edit_date,
                        article_comment)
                        VALUES(cur.id, --v_i,
                        cur.name_content,
                        cur.short_content,
                        cur.clob_content,
                        4,
                        LOCALTIMESTAMP,
                        3,
                        LOCALTIMESTAMP,
                        3,
                        cur.lang_content,
                        NULL,
                        NULL
                        );

      IF cur.category_content IS NOT NULL THEN
        FOR cur_c IN (SELECT regexp_substr(str, '[^:]+', 1, LEVEL) str
                      FROM (SELECT cur.category_content str
                              FROM dual) t
                    CONNECT BY instr(str, ':', 1, LEVEL - 1) > 0) LOOP
          INSERT INTO category_article_link
          VALUES
            (to_number(cur_c.str), cur.id);
        END LOOP;
      END IF;

  END LOOP;
  EXECUTE IMMEDIATE 'TRUNCATE TABLE lob_obj';
END;
/

EXIT SQL.SQLCODE;
