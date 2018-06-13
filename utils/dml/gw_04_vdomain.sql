﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;



------------------------------
--sys_combo
------------------------------

INSERT INTO sys_combo_cat VALUES (1, NULL);
INSERT INTO sys_combo_cat VALUES (2, NULL);
INSERT INTO sys_combo_cat VALUES (3, NULL);


INSERT INTO sys_combo_values VALUES (1, 1, 'combo1', NULL);
INSERT INTO sys_combo_values VALUES (1, 2, 'combo2', NULL);
INSERT INTO sys_combo_values VALUES (1, 3, 'combo3', NULL);
INSERT INTO sys_combo_values VALUES (1, 4, 'combo4', NULL);
INSERT INTO sys_combo_values VALUES (1, 5, 'combo5', NULL);
INSERT INTO sys_combo_values VALUES (2, 1, 'combo1', NULL);
INSERT INTO sys_combo_values VALUES (2, 2, 'combo2', NULL);
INSERT INTO sys_combo_values VALUES (2, 3, 'combo3', NULL);
INSERT INTO sys_combo_values VALUES (3, 1, 'combo1', NULL);
INSERT INTO sys_combo_values VALUES (3, 2, 'combo2', NULL);
INSERT INTO sys_combo_values VALUES (3, 3, 'combo3', NULL);
INSERT INTO sys_combo_values VALUES (3, 4, 'combo4', NULL);



--------------------------
--sys_api
--------------------------

INSERT INTO sys_api_cat_datatype VALUES (1, 2, 'double');
INSERT INTO sys_api_cat_datatype VALUES (2, 2, 'string');
INSERT INTO sys_api_cat_datatype VALUES (3, 2, 'date');
INSERT INTO sys_api_cat_datatype VALUES (4, 2, 'boolean');
INSERT INTO sys_api_cat_datatype VALUES (5, 2, 'double');
INSERT INTO sys_api_cat_datatype VALUES (1, 1, 'integer');
INSERT INTO sys_api_cat_datatype VALUES (2, 1, 'text');
INSERT INTO sys_api_cat_datatype VALUES (3, 1, 'date');
INSERT INTO sys_api_cat_datatype VALUES (4, 1, 'boolean');
INSERT INTO sys_api_cat_datatype VALUES (5, 1, 'numeric');


INSERT INTO sys_api_cat_widgettype VALUES (1, 1, 'QLineEdit');
INSERT INTO sys_api_cat_widgettype VALUES (2, 1, 'QComboBox');
INSERT INTO sys_api_cat_widgettype VALUES (3, 1, 'QCheckBox');
INSERT INTO sys_api_cat_widgettype VALUES (4, 1, 'QDateEdit');
INSERT INTO sys_api_cat_widgettype VALUES (5, 1, 'QDateTimeEdit');
INSERT INTO sys_api_cat_widgettype VALUES (6, 1, 'QTextEdit');
INSERT INTO sys_api_cat_widgettype VALUES (1, 2, 'text');
INSERT INTO sys_api_cat_widgettype VALUES (2, 2, 'combo');
INSERT INTO sys_api_cat_widgettype VALUES (3, 2, 'checkbox');
INSERT INTO sys_api_cat_widgettype VALUES (4, 2, 'date');
INSERT INTO sys_api_cat_widgettype VALUES (5, 2, 'date');
INSERT INTO sys_api_cat_widgettype VALUES (6, 2, 'textarea');









INSERT INTO sys_api_cat_formtab VALUES (1, 'tabConnect');
INSERT INTO sys_api_cat_formtab VALUES (2, 'tabRelations');
INSERT INTO sys_api_cat_formtab VALUES (3, 'tabDoc');
INSERT INTO sys_api_cat_formtab VALUES (4, 'tabElement');
INSERT INTO sys_api_cat_formtab VALUES (5, 'tabVisit');
INSERT INTO sys_api_cat_formtab VALUES (6, 'tabHydro');
INSERT INTO sys_api_cat_formtab VALUES (7, 'tabMincut');
INSERT INTO sys_api_cat_formtab VALUES (8, 'tabCost');

/*
INSERT INTO sys_api_cat_form VALUES (11, 'custom_form','F11', 'INFO_UD_NODE');
INSERT INTO sys_api_cat_form VALUES (12, 'custom_form','F12', 'INFO_WS_NODE');
INSERT INTO sys_api_cat_form VALUES (13, 'custom_form','F13', 'INFO_UTILS_ARC');
INSERT INTO sys_api_cat_form VALUES (14, 'custom_form','F14', 'INFO_UTILS_CONNEC');
INSERT INTO sys_api_cat_form VALUES (15, 'custom_form','F15', 'INFO_UD_GULLY');
INSERT INTO sys_api_cat_form VALUES (16, 'custom_form','F16', 'GENERIC');
INSERT INTO sys_api_cat_form VALUES (21, NULL, 'F21', 'VISIT');
INSERT INTO sys_api_cat_form VALUES (22, NULL, 'F22', 'VISIT_EVENT_STANDARD');
INSERT INTO sys_api_cat_form VALUES (23, NULL, 'F23', 'VISIT_EVENT_UD_ARC_STANDARD');
INSERT INTO sys_api_cat_form VALUES (24, NULL, 'F24', 'VISIT_EVENT_UD_ARC_REHABIT');
INSERT INTO sys_api_cat_form VALUES (25, NULL, 'F25', 'VISIT_MANAGER');
INSERT INTO sys_api_cat_form VALUES (26, NULL, 'F26', 'ADD_MULTIPLE_VISIT');
INSERT INTO sys_api_cat_form VALUES (27, NULL, 'F27', 'GALLERY');
INSERT INTO sys_api_cat_form VALUES (31, NULL, 'F31', 'SEARCH');
INSERT INTO sys_api_cat_form VALUES (32, NULL, 'F32', 'PRINT');
INSERT INTO sys_api_cat_form VALUES (33, NULL, 'F33', 'FILTER');
INSERT INTO sys_api_cat_form VALUES (41, NULL, 'F41', 'MINCUT_NEW');
INSERT INTO sys_api_cat_form VALUES (42, NULL, 'F42', 'MINCUT_ADD_CONNEC');
INSERT INTO sys_api_cat_form VALUES (43, NULL, 'F43', 'MINCUT_ADD_HYDROMETER');
INSERT INTO sys_api_cat_form VALUES (44, NULL, 'F44', 'MINCUT_END');
INSERT INTO sys_api_cat_form VALUES (45, NULL, 'F45', 'MINCUT_MANAGEMENT');

*/


	


-------------------------------
--config_api_layer_field
----------------------------

INSERT INTO "SCHEMA_NAME".config_api_layer_field (table_id, column_id, ismandatory, sys_api_cat_datatype_id, field_length, num_decimals, 
placeholder, form_label, sys_api_cat_widgettype_id, orderby, layout_id, layout_order, iseditable)
SELECT  
tables.table_name, 
column_name, 
(CASE WHEN is_nullable='YES' THEN FALSE ELSE TRUE END),
(CASE WHEN udt_name='varchar' THEN 2 WHEN udt_name='text' THEN 2 WHEN udt_name='bool' THEN 4 WHEN udt_name='numeric' THEN 5
 WHEN udt_name='int2' THEN 1 WHEN udt_name='int4' THEN 1 WHEN udt_name='int8' THEN 1 WHEN udt_name='date' THEN 3 END),
numeric_precision,
numeric_scale,
concat('Ex.:',column_name),
column_name,
(CASE WHEN udt_name='varchar' THEN 1 WHEN udt_name='text' THEN 1 WHEN udt_name='bool' THEN 3 WHEN udt_name='numeric' THEN 1
 WHEN udt_name='int2' THEN 1 WHEN udt_name='int4' THEN 1 WHEN udt_name='int8' THEN 1 WHEN udt_name='date' THEN 4 END),
ordinal_position,
1,
ordinal_position,
true
FROM information_schema.columns, information_schema.tables
	WHERE tables.table_schema='SCHEMA_NAME' 
	AND columns.table_name=tables.table_name and columns.table_schema=tables.table_schema 
	AND tables.table_name in (select distinct table_name FROM information_schema.columns where table_schema='SCHEMA_NAME')
	AND tables.table_name ilike 've_%' and tables.table_name !='version'
	AND udt_name!='geometry';
	
	


update config_api_layer_field set dv_table='cat_node', dv_id_column='id', dv_name_column='id',form_label='nodecat_id', sys_api_cat_widgettype_id=2, ismandatory=TRUE, 
dv_querytext='SELECT id, id as idval FROM cat_node WHERE id IS NOT NULL', dv_filterbyfield= 'nodetype_id' WHERE column_id='nodecat_id';	

update config_api_layer_field set dv_table='cat_arc', dv_id_column='id', dv_name_column='id',form_label='arccat_id', sys_api_cat_widgettype_id=2, ismandatory=TRUE, 
dv_querytext='SELECT id, id as idval FROM cat_arc WHERE id IS NOT NULL', dv_filterbyfield= 'arctype_id' WHERE column_id='arccat_id';

update config_api_layer_field set dv_table='cat_connec', dv_id_column='id', dv_name_column='id',form_label='connecat_id', sys_api_cat_widgettype_id=2, ismandatory=TRUE, 
dv_querytext='SELECT id, id as idval FROM cat_connec WHERE id IS NOT NULL', dv_filterbyfield= 'connectype_id' WHERE column_id='connecat_id';

UPDATE config_api_layer_field SET dv_table='exploitation', dv_id_column='expl_id', dv_name_column='name', form_label='exploitation' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT expl_id as id, name as idval FROM exploitation WHERE expl_id IS NOT NULL' WHERE column_id='expl_id';

UPDATE config_api_layer_field SET dv_table='dma', dv_id_column='dma_id', dv_name_column='name', form_label='dma' , sys_api_cat_widgettype_id=2, 
dv_querytext='SELECT dma_id as id, name as idval FROM dma WHERE dma_id IS NOT NULL', dv_filterbyfield='expl_id' WHERE column_id='dma_id';

UPDATE config_api_layer_field SET dv_table='cat_presszone', dv_id_column='id', dv_name_column='id', form_label='cat_presszone' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT id, id as idval FROM cat_presszone WHERE id IS NOT NULL', dv_filterbyfield='expl_id' WHERE column_id='presszonecat_id';

UPDATE config_api_layer_field SET dv_table='value_state', dv_id_column='id', dv_name_column='name', form_label='state' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT id, name as idval FROM value_state WHERE id IS NOT NULL' WHERE column_id='state';

UPDATE config_api_layer_field SET dv_table='value_state_type', dv_id_column='id', dv_name_column='name', form_label='state' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT id, name as idval FROM value_state_type WHERE id IS NOT NULL',  dv_filterbyfield='state' WHERE column_id='state_type';

UPDATE config_api_layer_field SET dv_table='inp_node_type', dv_id_column='id', dv_name_column='id', form_label='epa type' , sys_api_cat_widgettype_id=2, 
dv_querytext='SELECT id, id as idval FROM inp_node_type WHERE id IS NOT NULL'WHERE column_id='epa_type' and table_id ilike 've_node%';

UPDATE config_api_layer_field SET dv_table='inp_arc_type', dv_id_column='id', dv_name_column='id', form_label='epa type' , sys_api_cat_widgettype_id=2, 
dv_querytext='SELECT id, id as idval FROM inp_arc_type WHERE id IS NOT NULL'WHERE column_id='epa_type' and table_id ilike 've_arc%';

UPDATE config_api_layer_field SET dv_table='sector', dv_id_column='sector_id', dv_name_column='name', form_label='sector' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT sector_id as id,name as idval FROM sector WHERE sector_id IS NOT NULL', dv_filterbyfield='macrosector_id' WHERE column_id='sector_id';

UPDATE config_api_layer_field SET dv_table='macrosector', dv_id_column='macrosector_id', dv_name_column='name', form_label='macrosector' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT macrosector_id as id,name as idval FROM macrosector WHERE macrosector_id IS NOT NULL' WHERE column_id='macrosector_id';

UPDATE config_api_layer_field SET dv_table='arc', dv_id_column='arc_id', dv_name_column='arc_id', form_label='arc_id' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT arc_id as id, arc_id as idval FROM arc WHERE arc_id IS NOT NULL' WHERE column_id='arc_id' and (table_id ilike 've_node%' or table_id ilike 've_connec%');


UPDATE config_api_layer_field SET dv_table='cat_soil', dv_id_column='id', dv_name_column='name', form_label='soilcat_id' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT id, id as idval FROM cat_soil WHERE id IS NOT NULL' WHERE column_id='soilcat_id';

UPDATE config_api_layer_field SET dv_table='cat_work', dv_id_column='id', dv_name_column='id', form_label='work_id' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT id, id as idval FROM cat_work WHERE id IS NOT NULL' WHERE column_id='workcat_id';

UPDATE config_api_layer_field SET dv_table='cat_work', dv_id_column='id', dv_name_column='id', form_label='work_id_end' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT id, id as idval FROM cat_work WHERE id IS NOT NULL' WHERE column_id='workcat_id_end';

UPDATE config_api_layer_field SET dv_table='cat_buildet', dv_id_column='id', dv_name_column='id', form_label='builder' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT id, id as idval FROM cat_builder WHERE id IS NOT NULL' WHERE column_id='buildercat_id';

UPDATE config_api_layer_field SET dv_table='cat_owner', dv_id_column='id', dv_name_column='id', form_label='owner' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT id, id as idval FROM cat_owner WHERE id IS NOT NULL' WHERE column_id='ownercat_id';

UPDATE config_api_layer_field SET dv_table='ext_municipality', dv_id_column='muni_id', dv_name_column='name', form_label='municipality' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT muni_id as id, name as idval FROM ext_municipality WHERE muni_id IS NOT NULL' WHERE column_id='muni_id';

UPDATE config_api_layer_field SET dv_table='ext_streetaxis', dv_id_column='id', dv_name_column='name', form_label='streetaxis_id' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT id,name as idval FROM ext_streetaxis WHERE id IS NOT NULL', dv_filterbyfield='muni_id'  WHERE column_id='streetaxis_id';

UPDATE config_api_layer_field SET dv_table='ext_streetaxis', dv_id_column='id', dv_name_column='name', form_label='streetaxis_id2' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT id,name as idval FROM ext_streetaxis WHERE id IS NOT NULL', dv_filterbyfield='muni_id'  WHERE column_id='streetaxis_id2';

UPDATE config_api_layer_field SET dv_table='value_verified', dv_id_column='id', dv_name_column='id', form_label='verified' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT id, id as idval FROM value_verified WHERE id IS NOT NULL' WHERE column_id='verified';




UPDATE config_api_layer_field SET dv_table='man_type_function', dv_id_column='function_type', dv_name_column='function_type', form_label='function_type' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT function_type as id, function_type as idval FROM man_type_function WHERE (featurecat_id is null AND feature_type=''NODE'')', dv_filterbyfield='nodetype_id'
WHERE column_id='function_type' and table_id ilike 've_node%';

UPDATE config_api_layer_field SET dv_table='man_type_function', dv_id_column='function_type', dv_name_column='function_type', form_label='function_type' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT function_type as id, function_type as idval FROM man_type_function WHERE (featurecat_id is null AND feature_type=''ARC'')', dv_filterbyfield='arctype_id' 
WHERE column_id='function_type' and table_id ilike 've_arc%';

UPDATE config_api_layer_field SET dv_table='man_type_function', dv_id_column='function_type', dv_name_column='function_type', form_label='function_type' , sys_api_cat_widgettype_id=2,
dv_querytext='SELECT function_type as id, function_type as idval FROM man_type_function WHERE (featurecat_id is null AND feature_type=''CONNEC'')', dv_filterbyfield='connectype_id' 
WHERE column_id='function_type' and table_id ilike 've_connec%';



UPDATE config_api_layer_field SET dv_table='man_type_fluid', dv_id_column='fluid_type', dv_name_column='fluid_type', form_label='fluid_type' , sys_api_cat_widgettype_id=2, 
dv_querytext='SELECT fluid_type as id, fluid_type as idval FROM man_type_fluid WHERE (featurecat_id is null AND feature_type=''NODE'')', dv_filterbyfield='nodetype_id'
WHERE column_id='fluid_type' and table_id ilike 've_node%';

UPDATE config_api_layer_field SET dv_table='man_type_fluid', dv_id_column='fluid_type', dv_name_column='fluid_type', form_label='fluid_type' , sys_api_cat_widgettype_id=2, 
dv_querytext='SELECT  fluid_type as id, fluid_type as idval FROM man_type_fluid WHERE (featurecat_id is null AND feature_type=''ARC'')', dv_filterbyfield='arctype_id'
WHERE column_id='fluid_type' and table_id ilike 've_arc%';

UPDATE config_api_layer_field SET dv_table='man_type_fluid', dv_id_column='category_type', dv_name_column='fluid_type', form_label='fluid_type' , sys_api_cat_widgettype_id=2, 
dv_querytext='SELECT  fluid_type as id, fluid_type as idval FROM man_type_fluid WHERE (featurecat_id is null AND feature_type=''CONNEC'')', dv_filterbyfield='connectype_id'
WHERE column_id='fluid_type' and table_id ilike 've_connec%';


UPDATE config_api_layer_field SET dv_table='man_type_fluid', dv_id_column='category_type', dv_name_column='category_type', form_label='category_type' , sys_api_cat_widgettype_id=2 ,
dv_querytext='SELECT category_type as id, category_type as idval FROM man_type_category WHERE (featurecat_id is null AND feature_type=''NODE'')', dv_filterbyfield='nodetype_id'
WHERE column_id='category_type' and table_id ilike 've_node%';

UPDATE config_api_layer_field SET dv_table='man_type_fluid', dv_id_column='category_type', dv_name_column='category_type', form_label='category_type' , sys_api_cat_widgettype_id=2, 
dv_querytext='SELECT category_type as id, category_type as idval FROM man_type_category WHERE (featurecat_id is null AND feature_type=''ARC'')', dv_filterbyfield='arctype_id'
WHERE column_id='category_type' and table_id ilike 've_arc%';

UPDATE config_api_layer_field SET dv_table='man_type_fluid', dv_id_column='category_type', dv_name_column='category_type', form_label='category_type' , sys_api_cat_widgettype_id=2, 
dv_querytext='SELECT category_type as id, category_type as idval FROM man_type_category WHERE (featurecat_id is null AND feature_type=''CONNEC'')', dv_filterbyfield='connectype_id'
WHERE column_id='category_type' and table_id ilike 've_connec%';


UPDATE config_api_layer_field SET dv_table='man_type_fluid', dv_id_column='location_type', dv_name_column='location_type', form_label='location_type' , sys_api_cat_widgettype_id=2, 
dv_querytext='SELECT location_type as id, location_type as idval FROM man_type_location WHERE (featurecat_id is null AND feature_type=''NODE'')', dv_filterbyfield='nodetype_id'
WHERE column_id='location_type' and table_id ilike 've_node%';

UPDATE config_api_layer_field SET dv_table='man_type_fluid', dv_id_column='location_type', dv_name_column='location_type', form_label='location_type' , sys_api_cat_widgettype_id=2, 
dv_querytext='SELECT location_type as id, location_type as idval FROM man_type_location WHERE (featurecat_id is null AND feature_type=''ARC'')', dv_filterbyfield='arctype_id'
WHERE column_id='location_type' and table_id ilike 've_arc%';

UPDATE config_api_layer_field SET dv_table='man_type_fluid', dv_id_column='location_type', dv_name_column='location_type', form_label='location_type' , sys_api_cat_widgettype_id=2, 
dv_querytext='SELECT location_type as id, location_type as idval FROM man_type_location WHERE (featurecat_id is null AND feature_type=''CONNEC'')', dv_filterbyfield='connectype_id'
WHERE column_id='location_type' and table_id ilike 've_connec%';


update config_api_layer_field set isnavigationbutton=TRUE where column_id='arc_id' OR  column_id='node_id' OR  column_id='conenc_id' OR  column_id='node_1' 
	OR column_id='node_2' OR  column_id='gully_id' OR  column_id='workcat_id' OR  column_id='workcat_id_end';

UPDATE config_api_layer_field SET ismandatory=FALSE, iseditable=FALSE WHERE column_id='cat_matcat_id';
UPDATE config_api_layer_field SET ismandatory=FALSE, iseditable=FALSE WHERE column_id='cat_pnom';	
UPDATE config_api_layer_field SET ismandatory=FALSE, iseditable=FALSE WHERE column_id='cat_dnom';		
UPDATE config_api_layer_field SET ismandatory=FALSE, iseditable=FALSE WHERE column_id='macrosector_id';		
UPDATE config_api_layer_field SET ismandatory=FALSE, iseditable=FALSE WHERE column_id='link';			
UPDATE config_api_layer_field SET ismandatory=TRUE, iseditable=FALSE WHERE column_id='node_id';
UPDATE config_api_layer_field SET ismandatory=TRUE, iseditable=FALSE WHERE column_id='connec_id';
UPDATE config_api_layer_field SET ismandatory=TRUE, iseditable=FALSE WHERE column_id='arc_id';

