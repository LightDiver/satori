CREATE OR REPLACE FUNCTION trg_user_session() RETURNS TRIGGER AS $$
DECLARE
    v_act NUMERIC(1);
BEGIN

  IF TG_OP = 'INSERT' THEN
    v_act := 1;
  ELSIF TG_OP = 'UPDATE' THEN
    v_act := 2;
  ELSE
    v_act := 3;
  END IF;


  IF TG_OP = 'DELETE' THEN
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
      (old.session_id,
       old.key_id,
       old.user_id,
       old.terminal_ip,
       old.l_date,
       old.l_action_type_id,
       old.r_date,
       old.l_is_success,
       old.terminal_client,
       localtimestamp,
       v_act);
    RETURN OLD;
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
      (new.session_id,
       new.key_id,
       new.user_id,
       new.terminal_ip,
       new.l_date,
       new.l_action_type_id,
       new.r_date,
       new.l_is_success,
       new.terminal_client,
       localtimestamp,
       v_act);
     RETURN NEW;
  END IF;

END;
$$ LANGUAGE plpgsql;
