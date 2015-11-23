---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- File 09-trig.sql create DataBase triggers.                                              --
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_user_session
  AFTER INSERT OR UPDATE OR DELETE ON user_session
  FOR EACH ROW
DECLARE
  v_act NUMBER(1);
BEGIN
  IF inserting THEN
    v_act := 1;
  ELSIF updating THEN
    v_act := 2;
  ELSE
    v_act := 3;
  END IF;

  IF deleting THEN
    INSERT INTO user_session_hist
      (session_id,
       key_id,
       user_id,
       terminal_ip,
       l_date,
       l_action_type_id,
       r_date,
       l_is_success,
       terminal_client,
       a_date,
       a_act)
    VALUES
      (:old.session_id,
       :old.key_id,
       :old.user_id,
       :old.terminal_ip,
       :old.l_date,
       :old.l_action_type_id,
       :old.r_date,
       :old.l_is_success,
       :old.terminal_client,
       localtimestamp,
       v_act);
  ELSE
    INSERT INTO user_session_hist
      (session_id,
       key_id,
       user_id,
       terminal_ip,
       l_date,
       l_action_type_id,
       r_date,
       l_is_success,
       terminal_client,
       a_date,
       a_act)
    VALUES
      (:new.session_id,
       :new.key_id,
       :new.user_id,
       :new.terminal_ip,
       :new.l_date,
       :new.l_action_type_id,
       :new.r_date,
       :new.l_is_success,
       :new.terminal_client,
       localtimestamp,
       v_act);
  END IF;

END trg_user_session_hist;
/

