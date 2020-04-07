/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = ws, public, pg_catalog;

CREATE INDEX anl_node_node_id_index ON anl_node USING btree (node_id);
CREATE INDEX anl_node_fprocesscat_id_index ON anl_node USING btree (fprocesscat_id);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_inp_node", "column":"nodeparent", "dataType":"character varying(16)"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_inp_arc", "column":"arcparent", "dataType":"character varying(16)"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"rpt_inp_node", "column":"arcposition", "dataType":"int2"}}$$);

CREATE INDEX rpt_inp_node_nodeparent ON rpt_inp_node USING btree (nodeparent);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"anl_node", "column":"state_type", "dataType":"integer"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"anl_node", "column":"sector_id", "dataType":"integer"}}$$);

INSERT INTO sys_fprocess_cat(id, fprocess_name, context, project_type)
VALUES (124,'Go2epa-temporal nodarcs','ws', 'epa') ON CONFLICT (id) DO NOTHING;



