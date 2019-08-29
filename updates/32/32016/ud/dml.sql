/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

UPDATE audit_cat_function SET isdeprecated=TRUE where id=1248;

UPDATE audit_cat_param_user SET vdefault='NO' WHERE id='inp_report_input';
UPDATE audit_cat_param_user SET vdefault='NONE' WHERE id='inp_report_nodes';
UPDATE audit_cat_param_user SET vdefault='NONE' WHERE id='inp_report_subcatchments';
UPDATE audit_cat_param_user SET vdefault='NONE' WHERE id='inp_report_links';

UPDATE inp_timser_id SET idval = id;

UPDATE audit_cat_param_user SET dv_querytext='SELECT id, idval FROM inp_timser_id WHERE timser_type=''Rainfall''',vdefault=null, 
dv_isnullvalue=true, layout_id=2, layout_order=14, layoutname='grl_general_2' WHERE id='inp_options_setallraingages';

UPDATE audit_cat_param_user SET layoutname='grl_general_1', layout_id=1, layout_order=68, vdefault=null, dv_isnullvalue=true WHERE id='inp_options_dwfscenario';

UPDATE audit_cat_param_user SET layout_order=2 WHERE id='inp_options_rtc_period_id';

INSERT INTO audit_cat_table VALUES ('om_visit_lot_x_gully', 'O&M', 'Table of gullys related to lots', 'role_om', 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE, NULL);
INSERT INTO audit_cat_table VALUES ('vp_basic_gully', 'Auxiliar view', 'Auxiliar view for gullys with id and type', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE, NULL);
INSERT INTO audit_cat_table VALUES ('ve_node', 'Editable view', 'Editable view for nodes', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE, NULL);
INSERT INTO audit_cat_table VALUES ('ve_connec', 'Editable view', 'Editable view for conncs', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE, NULL);
INSERT INTO audit_cat_table VALUES ('ve_gully', 'Editable view', 'Editable view for gullys', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE, NULL);
INSERT INTO audit_cat_table VALUES ('ve_pol_chamber', 'Editable view', 'Editable view for chamber polygons', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE, NULL);
INSERT INTO audit_cat_table VALUES ('ve_pol_gully', 'Editable view', 'Editable view for gully polygons', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE, NULL);
INSERT INTO audit_cat_table VALUES ('ve_pol_netgully', 'Editable view', 'Editable view for netgully polygons', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE, NULL);
INSERT INTO audit_cat_table VALUES ('ve_pol_storage', 'Editable view', 'Editable view for storage polygons', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE, NULL);
INSERT INTO audit_cat_table VALUES ('ve_pol_wwtp', 'Editable view', 'Editable view for wwtp polygons', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, FALSE, NULL);

