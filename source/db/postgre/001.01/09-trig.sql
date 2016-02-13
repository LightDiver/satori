---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- File 09-trig.sql create DataBase triggers.                                              --
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
CREATE TRIGGER user_session_a_iud
  AFTER UPDATE OR DELETE 
  ON user_session FOR EACH ROW 
  EXECUTE PROCEDURE trg_user_session();