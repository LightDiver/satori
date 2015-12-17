@@00-base.sql
@@01-user.sql
@@02-main.sql
@@03-exts.sql
@@04-spec.sql
@@05-head.sql
@@06-body.sql
@@07-proc.sql
@@08-func.sql
@@09-trig.sql
@@20-init.sql

PROMPT RECOMPILE ALL OBJECTS
EXEC DBMS_UTILITY.COMPILE_SCHEMA(USER);
/
