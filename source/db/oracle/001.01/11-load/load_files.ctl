LOAD DATA
INFILE *
REPLACE
   INTO TABLE lob_obj
   FIELDS TERMINATED BY ','
   (ID             CHAR(10),
    NAME_CONTENT   CHAR(100),
    LANG_CONTENT   CHAR(2),
    CATEGORY_CONTENT   CHAR(100),
    NAME_FILE1      FILLER CHAR(100),
    SHORT_CONTENT LOBFILE(NAME_FILE1) TERMINATED BY EOF,
    NAME_FILE2      FILLER CHAR(100),
    CLOB_CONTENT   LOBFILE(NAME_FILE2) TERMINATED BY EOF)
BEGINDATA
1,���� ����� � ������,RU,2:1,article_short1.txt,article_content1.txt
2,��� ������ ����� ������,RU,2,article_short2.txt,article_content2.txt
3,����� ���������: ��������� �������������� �����,RU,4,article_short3.txt,article_content3.txt
4,������� ��� ����. ֳ���� �����.,UA,2,article_short4.txt,article_content4.txt
5,�� ��������� ������ ������,UA,2,article_short5.txt,article_content5.txt
6,�������� ���������� ������ ������� � ������.,UA,1,article_short6.txt,article_content6.txt