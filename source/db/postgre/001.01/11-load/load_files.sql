SET CLIENT_ENCODING TO 'WIN1251';
  --1
  COPY lob_obj(short_content) FROM :path_to_file\article_short1.txt' ENCODING 'WIN1251' DELIMITER '';
  COPY lob_obj(CLOB_CONTENT) FROM :path_to_file\article_content1.txt' ENCODING 'WIN1251' DELIMITER '';
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
  select 
          1,
          'Одна книга в неделю',
          replace((select string_agg(short_content,chr(10)) from lob_obj where short_content is not null),'path_to_site',:path_to_site') short_content, 
          replace((select string_agg(clob_content,chr(10)) from lob_obj where clob_content is not null),'path_to_site',:path_to_site') clob_content, 
          4,
          localtimestamp,
          3,
          localtimestamp,
          3,
          'RU',
          NULL,
          NULL; 
  INSERT INTO category_article_link(category_id, article_id) VALUES (1, 1);
  INSERT INTO category_article_link(category_id, article_id) VALUES (2, 1);
  truncate table lob_obj;
  --2
  COPY lob_obj(short_content) FROM :path_to_file\article_short2.txt' ENCODING 'WIN1251' DELIMITER '';
  COPY lob_obj(CLOB_CONTENT) FROM :path_to_file\article_content2.txt' ENCODING 'WIN1251' DELIMITER '';
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
  select 
          2,
          'Как начать много читать',
          replace((select string_agg(short_content,chr(10)) from lob_obj where short_content is not null),'path_to_site',:path_to_site') short_content, 
          replace((select string_agg(clob_content,chr(10)) from lob_obj where clob_content is not null),'path_to_site',:path_to_site') clob_content, 
          4,
          localtimestamp,
          3,
          localtimestamp,
          3,
          'RU',
          NULL,
          NULL; 
  INSERT INTO category_article_link(category_id, article_id) VALUES (2, 2);
  truncate table lob_obj; 
  --3
  COPY lob_obj(short_content) FROM :path_to_file\article_short3.txt' ENCODING 'WIN1251' DELIMITER '';
  COPY lob_obj(CLOB_CONTENT) FROM :path_to_file\article_content3.txt' ENCODING 'WIN1251' DELIMITER '';
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
  select 
          3,
          'Числа Фибоначчи: нескучные математические факты',
          replace((select string_agg(short_content,chr(10)) from lob_obj where short_content is not null),'path_to_site',:path_to_site') short_content, 
          replace((select string_agg(clob_content,chr(10)) from lob_obj where clob_content is not null),'path_to_site',:path_to_site') clob_content, 
          4,
          localtimestamp,
          3,
          localtimestamp,
          3,
          'RU',
          NULL,
          NULL; 
  INSERT INTO category_article_link(category_id, article_id) VALUES (4, 3);
  truncate table lob_obj; 
  --4
  COPY lob_obj(short_content) FROM :path_to_file\article_short4.txt' ENCODING 'WIN1251' DELIMITER '';
  COPY lob_obj(CLOB_CONTENT) FROM :path_to_file\article_content4.txt' ENCODING 'WIN1251' DELIMITER '';
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
  select 
          4,
          'Читання для діток. Цікаво знати.',
          (select string_agg(short_content,chr(10)) from lob_obj where short_content is not null) short_content , 
          replace((select string_agg(clob_content,chr(10)) from lob_obj where clob_content is not null),'path_to_site',:path_to_site') clob_content , 
          4,
          localtimestamp,
          3,
          localtimestamp,
          3,
          'UA',
          NULL,
          NULL; 
  INSERT INTO category_article_link(category_id, article_id) VALUES (2, 4);
  truncate table lob_obj; 
  --5
  COPY lob_obj(short_content) FROM :path_to_file\article_short5.txt' ENCODING 'WIN1251' DELIMITER '';
  COPY lob_obj(CLOB_CONTENT) FROM :path_to_file\article_content5.txt' ENCODING 'WIN1251' DELIMITER '';
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
  select 
          5,
          'Як навчитися швидко читати',
          (select string_agg(short_content,chr(10)) from lob_obj where short_content is not null) short_content , 
          replace((select string_agg(clob_content,chr(10)) from lob_obj where clob_content is not null),'path_to_site',:path_to_site') clob_content, 
          4,
          localtimestamp,
          3,
          localtimestamp,
          3,
          'UA',
          NULL,
          NULL; 
  INSERT INTO category_article_link(category_id, article_id) VALUES (2, 5);
  truncate table lob_obj; 
  --6
  COPY lob_obj(short_content) FROM :path_to_file\article_short6.txt' ENCODING 'WIN1251' DELIMITER '';
  COPY lob_obj(CLOB_CONTENT) FROM :path_to_file\article_content6.txt' ENCODING 'WIN1251' DELIMITER '';
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
  select 
          6,
          'Класичне оцінювання техніки читання у школах.',
          replace((select string_agg(short_content,chr(10)) from lob_obj where short_content is not null),'path_to_site',:path_to_site') short_content, 
          replace((select string_agg(clob_content,chr(10)) from lob_obj where clob_content is not null),'path_to_site',:path_to_site') clob_content, 
          4,
          localtimestamp,
          3,
          localtimestamp,
          3,
          'UA',
          NULL,
          NULL; 
  INSERT INTO category_article_link(category_id, article_id) VALUES (1, 6);
  truncate table lob_obj; 

  