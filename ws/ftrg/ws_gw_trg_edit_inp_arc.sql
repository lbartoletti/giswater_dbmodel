/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 1306


CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_edit_inp_arc()  RETURNS trigger AS $BODY$
DECLARE 
    arc_table varchar;
    man_table varchar;
    v_sql varchar;    

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
    arc_table:= TG_ARGV[0];
    
    IF TG_OP = 'INSERT' THEN
        PERFORM audit_function(1026,1306);
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN

		-- State
		IF (NEW.state != OLD.state) THEN
			UPDATE arc SET state=NEW.state WHERE arc_id = OLD.arc_id;
		END IF;
			
		-- The geom
		IF st_equals(NEW.the_geom, OLD.the_geom) IS FALSE  THEN
			UPDATE arc SET the_geom=NEW.the_geom WHERE arc_id = OLD.arc_id;
		END IF;
	
	
        UPDATE arc 
        SET arccat_id=NEW.arccat_id, sector_id=NEW.sector_id, "state"=NEW."state", annotation= NEW.annotation, 
            custom_length=NEW.custom_length
        WHERE arc_id = OLD.arc_id;

        IF arc_table = 'inp_pipe' THEN   
            UPDATE inp_pipe SET minorloss=NEW.minorloss, status=NEW.status, custom_roughness=NEW.custom_roughness, custom_dint=NEW.custom_dint WHERE arc_id=OLD.arc_id;
        ELSIF arc_table = 'inp_virtualvalve' THEN   
            UPDATE inp_virtualvalve SET valv_type=NEW.valv_type, pressure=NEW.pressure, flow=NEW.flow, coef_loss=NEW.coef_loss, curve_id=NEW.curve_id,
            minorloss=NEW.minorloss, to_arc=NEW.to_arc, status=NEW.status WHERE arc_id=OLD.arc_id;
        END IF;

        PERFORM audit_function(2,1306); 
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        PERFORM audit_function(1028,1306); 
        RETURN NEW;
    
    END IF;
    
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
   