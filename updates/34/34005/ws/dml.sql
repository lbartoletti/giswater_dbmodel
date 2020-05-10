/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


--2020/03/18
UPDATE audit_cat_table SET isdeprecated = true 
WHERE id IN ('v_arc_dattrib','v_node_dattrib','vi_parent_node','v_connec_dattrib','vp_epa_node','vp_epa_arc'
			'v_plan_aux_arc_ml','v_plan_aux_arc_cost','v_plan_aux_arc_connec','v_plan_aux_arc_pavement');

INSERT INTO audit_cat_table(id, context, descript, sys_role_id, sys_criticity, qgis_role_id, isdeprecated) 
VALUES ('v_connec', 'GIS feature', 'Auxiliar view for connecs', 'role_basic', 0, 'role_basic', false);


--30/04/2020
INSERT INTO edit_typevalue (typevalue, id, idval) VALUES ('valve_ordinarystatus', '0', 'closed') ON CONFLICT (typevalue, id) DO NOTHING;
INSERT INTO edit_typevalue (typevalue, id, idval) VALUES ('valve_ordinarystatus', '1', 'opened') ON CONFLICT (typevalue, id) DO NOTHING;
INSERT INTO edit_typevalue (typevalue, id, idval) VALUES ('valve_ordinarystatus', '2', 'maybe') ON CONFLICT (typevalue, id) DO NOTHING;

INSERT INTO typevalue_fk (id,typevalue_table, typevalue_name, target_table, target_field) 
VALUES (52,'edit_typevalue', 'valve_ordinarystatus', 'man_valve', 'ordinarystatus') ON CONFLICT (id) DO NOTHING;