/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

-- 27/06/2019

CREATE OR REPLACE FUNCTION gw_trg_plan_psector_x_gully()
  RETURNS trigger AS
$BODY$
DECLARE 
    featurecat_aux text;
    psector_vdefault_var integer;
    insert_into_psector_aux integer;
    gully_1_aux varchar;
    gully_2_aux varchar;
    gully_geom_aux public.geometry;
    state_aux smallint;
    is_doable_aux boolean;
	

BEGIN 

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';

	SELECT gully.state INTO state_aux FROM gully WHERE gully_id=NEW.gully_id;
		IF state_aux=1	THEN 
			NEW.state=0;
			NEW.doable=false;
		ELSIF state_aux=2 THEN
			NEW.state=1;
			NEW.doable=true;
		END IF;

RETURN NEW;

END;  
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION gw_trg_plan_psector_x_gully()
  OWNER TO postgres;


-- Trigger: gw_trg_plan_psector_x_gully on plan_psector_x_gully

-- DROP TRIGGER gw_trg_plan_psector_x_gully ON plan_psector_x_gully;

CREATE TRIGGER gw_trg_plan_psector_x_gully
  BEFORE INSERT OR UPDATE OF gully_id
  ON plan_psector_x_gully
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_plan_psector_x_gully();

-- Trigger: gw_trg_plan_psector_x_gully_geom on plan_psector_x_gully

-- DROP TRIGGER gw_trg_plan_psector_x_gully_geom ON plan_psector_x_gully;

CREATE TRIGGER gw_trg_plan_psector_x_gully_geom
  AFTER INSERT OR UPDATE OR DELETE
  ON plan_psector_x_gully
  FOR EACH ROW
  EXECUTE PROCEDURE gw_trg_plan_psector_geom('plan');
  