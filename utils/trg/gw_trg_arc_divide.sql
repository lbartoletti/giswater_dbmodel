﻿CREATE OR REPLACE FUNCTION ws.gw_trg_node_arc_divide()
  RETURNS trigger AS
$BODY$
DECLARE 

rec record;
arc_id_aux varchar;

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
	

--  Only enabled on insert
	IF TG_OP = 'INSERT' THEN

		SELECT * INTO rec FROM config;
	
		SELECT arc_id INTO arc_id_aux FROM v_edit_arc WHERE ST_DWithin(NEW.the_geom, v_edit_arc.the_geom, rec.node_proximity) AND NEW.state>0 LIMIT 1;
		IF arc_id_aux IS NOT NULL THEN
			PERFORM gw_fct_arc_divide(NEW.node_id);	

		END IF;	

   	END IF;

RETURN NEW;
    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ws.gw_trg_node_arc_divide()
  OWNER TO postgres;



drop trigger gw_trg_node_arc_divide ON ws.node;
  CREATE TRIGGER gw_trg_node_arc_divide   AFTER INSERT  ON ws.node
    FOR EACH ROW  EXECUTE PROCEDURE ws.gw_trg_node_arc_divide();
    