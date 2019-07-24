/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


CREATE TRIGGER gw_trg_edit_inp_connec INSTEAD OF INSERT OR UPDATE OR DELETE
ON SCHEMA_NAME.v_edit_inp_connec FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_edit_inp_connec();

DROP TRIGGER gw_trg_connec_update ON connec;
DROP TRIGGER gw_trg_update_link_arc_id ON connec;

CREATE TRIGGER gw_trg_connect_update AFTER UPDATE OF arc_id, pjoint_id, pjoint_type, the_geom
ON SCHEMA_NAME.connec FOR EACH ROW EXECUTE PROCEDURE SCHEMA_NAME.gw_trg_update_link_arc_id('connec');

