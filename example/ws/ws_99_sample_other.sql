/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;


INSERT INTO anl_mincut_inlet_x_exploitation VALUES (2, 113766, 1);
INSERT INTO anl_mincut_inlet_x_exploitation VALUES (3, 113952, 2);

INSERT INTO anl_mincut_selector_valve VALUES ('SHUTOFF-VALVE');

INSERT INTO doc VALUES ('Demo document', 'OTHER', 'https://github.com/Giswater/docs/blob/master/user/manual_usuario_giswater3.doc', NULL, '2018-03-11 19:40:20.449663', 'postgres', '2018-03-11 19:40:20.449663');

SELECT gw_fct_plan_result( 'Starting prices', 1, 1, 'Demo prices for reconstruction');
SELECT gw_fct_fill_doc_tables();
SELECT gw_fct_fill_om_tables();

UPDATE plan_arc_x_pavement SET pavcat_id = 'Asphalt';


UPDATE plan_psector_x_arc SET psector_id = 2 WHERE arc_id = '20651';

INSERT INTO plan_psector_x_arc VALUES (4, '2065', 2, 0, false, NULL);
INSERT INTO plan_psector_x_arc VALUES (5, '2085', 1, 0, false, NULL);
INSERT INTO plan_psector_x_arc VALUES (8, '2086', 1, 0, false, NULL);

INSERT INTO plan_psector_x_node VALUES (2, '1076', 1, 0, false, NULL);






