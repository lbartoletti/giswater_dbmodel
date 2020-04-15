/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--2020/04/14
UPDATE config_api_form_fields set layout_order = 4 WHERE (formname = 've_connec' OR formname = 'v_edit_connec') AND column_id = 'state_type';
UPDATE config_api_form_fields set layout_order = 3 WHERE (formname = 've_connec' OR formname = 'v_edit_connec') AND column_id = 'state';


--2020/04/15
SELECT setval('SCHEMA_NAME.config_api_form_fields_id_seq', (SELECT max(id) FROM config_api_form_fields), true);

UPDATE config_api_form_fields SET layoutname = 'lyt_data_1' where formname ilike 'v_edit_inp%';
UPDATE config_api_form_fields SET layout_order = 1 where formname!='v_edit_inp_demand' and formname ilike 'v_edit_inp%' and (column_id='node_id' OR column_id='arc_id' or column_id='connec_id');
UPDATE config_api_form_fields SET layout_order = 2 where formname!='v_edit_inp_demand' and formname!='v_edit_inp_pipe' and formname!='v_edit_inp_virtualvalve'and formname ilike 'v_edit_inp%' and (column_id='elevation');
UPDATE config_api_form_fields SET layout_order = 3 where formname!='v_edit_inp_demand' and formname!='v_edit_inp_pipe' and formname!='v_edit_inp_virtualvalve' and formname ilike 'v_edit_inp%' and (column_id='depth');
UPDATE config_api_form_fields SET layout_order = 4 where formname!='v_edit_inp_demand' and formname!='v_edit_inp_pipe' and formname!='v_edit_inp_virtualvalve' and formname ilike 'v_edit_inp%' and (column_id='nodecat_id');
UPDATE config_api_form_fields SET layout_order = 5 where formname!='v_edit_inp_demand'  and formname!='v_edit_inp_virtualvalve' and formname ilike 'v_edit_inp%' and (column_id='sector_id');
UPDATE config_api_form_fields SET layout_order = 6 where formname!='v_edit_inp_demand'  and formname!='v_edit_inp_virtualvalve' and formname ilike 'v_edit_inp%' and (column_id='macrosector_id');
UPDATE config_api_form_fields SET layout_order = 7 where formname!='v_edit_inp_demand' and formname!='v_edit_inp_virtualvalve' and formname ilike 'v_edit_inp%' and (column_id='dma_id');
UPDATE config_api_form_fields SET layout_order = 8 where formname!='v_edit_inp_demand' and formname!='v_edit_inp_virtualvalve' and formname ilike 'v_edit_inp%' and (column_id='state');
UPDATE config_api_form_fields SET layout_order = 9 where formname!='v_edit_inp_demand'  and formname!='v_edit_inp_virtualvalve' and formname ilike 'v_edit_inp%' and (column_id='state_type');
UPDATE config_api_form_fields SET layout_order = 10 where formname!='v_edit_inp_demand'  and formname!='v_edit_inp_virtualvalve' and formname ilike 'v_edit_inp%' and (column_id='annotation');
UPDATE config_api_form_fields SET layout_order = 11 where formname!='v_edit_inp_demand'and formname!='v_edit_inp_virtualvalve' and formname ilike 'v_edit_inp%' and (column_id='expl_id');


UPDATE config_api_form_fields SET layout_order = 12 where formname='v_edit_inp_junction' and column_id='demand';
UPDATE config_api_form_fields SET layout_order = 13 where formname='v_edit_inp_junction' and column_id='pattern_id';

UPDATE config_api_form_fields SET layout_order = 4 where formname='v_edit_inp_connec' and column_id='connecat_id';
UPDATE config_api_form_fields SET layout_order = 5 where formname='v_edit_inp_connec' and column_id='arc_id';
UPDATE config_api_form_fields SET layout_order = 6 where formname='v_edit_inp_connec' and column_id='sector_id';
UPDATE config_api_form_fields SET layout_order = 7 where formname='v_edit_inp_connec' and column_id='dma_id';
UPDATE config_api_form_fields SET layout_order = 8 where formname='v_edit_inp_connec' and column_id='state';
UPDATE config_api_form_fields SET layout_order = 9 where formname='v_edit_inp_connec' and column_id='state_type';
UPDATE config_api_form_fields SET layout_order = 10 where formname='v_edit_inp_connec' and column_id='annotation';
UPDATE config_api_form_fields SET layout_order = 11 where formname='v_edit_inp_connec' and column_id='expl_id';
UPDATE config_api_form_fields SET layout_order = 12 where formname='v_edit_inp_connec' and column_id='pjoint_type';
UPDATE config_api_form_fields SET layout_order = 13 where formname='v_edit_inp_connec' and column_id='pjoint_id';
UPDATE config_api_form_fields SET layout_order = 14 where formname='v_edit_inp_connec' and column_id='demand';
UPDATE config_api_form_fields SET layout_order = 15 where formname='v_edit_inp_connec' and column_id='pattern_id';

UPDATE config_api_form_fields SET layout_order = 1 where formname='v_edit_inp_demand' and column_id='id';
UPDATE config_api_form_fields SET layout_order = 2 where formname='v_edit_inp_demand' and column_id='node_id';
UPDATE config_api_form_fields SET layout_order = 3 where formname='v_edit_inp_demand' and column_id='demand';
UPDATE config_api_form_fields SET layout_order = 4 where formname='v_edit_inp_demand' and column_id='pattern_id';
UPDATE config_api_form_fields SET layout_order = 5 where formname='v_edit_inp_demand' and column_id='deman_type';
UPDATE config_api_form_fields SET layout_order = 6 where formname='v_edit_inp_demand' and column_id='dscenario_id';

UPDATE config_api_form_fields SET layout_order = 12 where formname='v_edit_inp_inlet' and column_id='initlevel';
UPDATE config_api_form_fields SET layout_order = 13 where formname='v_edit_inp_inlet' and column_id='minlevel';
UPDATE config_api_form_fields SET layout_order = 14 where formname='v_edit_inp_inlet' and column_id='maxlevel';
UPDATE config_api_form_fields SET layout_order = 15 where formname='v_edit_inp_inlet' and column_id='diameter';
UPDATE config_api_form_fields SET layout_order = 16 where formname='v_edit_inp_inlet' and column_id='minvol';
UPDATE config_api_form_fields SET layout_order = 17 where formname='v_edit_inp_inlet' and column_id='curve_id';
UPDATE config_api_form_fields SET layout_order = 18 where formname='v_edit_inp_inlet' and column_id='pattern_id';

UPDATE config_api_form_fields SET layout_order = 12 where formname='v_edit_inp_pump' and column_id='power';
UPDATE config_api_form_fields SET layout_order = 13 where formname='v_edit_inp_pump' and column_id='curve_id';
UPDATE config_api_form_fields SET layout_order = 14 where formname='v_edit_inp_pump' and column_id='speed';
UPDATE config_api_form_fields SET layout_order = 15 where formname='v_edit_inp_pump' and column_id='pattern';
UPDATE config_api_form_fields SET layout_order = 16 where formname='v_edit_inp_pump' and column_id='to_arc';
UPDATE config_api_form_fields SET layout_order = 17 where formname='v_edit_inp_pump' and column_id='status';
UPDATE config_api_form_fields SET layout_order = 18 where formname='v_edit_inp_pump' and column_id='pump_type';

UPDATE config_api_form_fields SET layout_order = 12 where formname='v_edit_inp_reservoir' and column_id='pattern_id';
DELETE FROM config_api_form_fields  WHERE formname='v_edit_inp_reservoir' and column_id='to_arc';

UPDATE config_api_form_fields SET layout_order = 12 where formname='v_edit_inp_shortpipe' and column_id='minorloss';
UPDATE config_api_form_fields SET layout_order = 13 where formname='v_edit_inp_shortpipe' and column_id='to_arc';
UPDATE config_api_form_fields SET layout_order = 14 where formname='v_edit_inp_shortpipe' and column_id='status';

UPDATE config_api_form_fields SET layout_order = 12 where formname='v_edit_inp_tank' and column_id='initlevel';
UPDATE config_api_form_fields SET layout_order = 13 where formname='v_edit_inp_tank' and column_id='minlevel';
UPDATE config_api_form_fields SET layout_order = 14 where formname='v_edit_inp_tank' and column_id='maxlevel';
UPDATE config_api_form_fields SET layout_order = 15 where formname='v_edit_inp_tank' and column_id='diameter';
UPDATE config_api_form_fields SET layout_order = 16 where formname='v_edit_inp_tank' and column_id='minvol';
UPDATE config_api_form_fields SET layout_order = 17 where formname='v_edit_inp_tank' and column_id='curve_id';
UPDATE config_api_form_fields SET layout_order = 18 where formname='v_edit_inp_tank' and column_id='pattern_id';

UPDATE config_api_form_fields SET layout_order = 12 where formname='v_edit_inp_valve' and column_id='valv_type';
UPDATE config_api_form_fields SET layout_order = 13 where formname='v_edit_inp_valve' and column_id='pressure';
UPDATE config_api_form_fields SET layout_order = 14 where formname='v_edit_inp_valve' and column_id='flow';
UPDATE config_api_form_fields SET layout_order = 15 where formname='v_edit_inp_valve' and column_id='coef_loss';
UPDATE config_api_form_fields SET layout_order = 16 where formname='v_edit_inp_valve' and column_id='curve_id';
UPDATE config_api_form_fields SET layout_order = 17 where formname='v_edit_inp_valve' and column_id='minorloss';
UPDATE config_api_form_fields SET layout_order = 18 where formname='v_edit_inp_valve' and column_id='to_arc';
UPDATE config_api_form_fields SET layout_order = 19 where formname='v_edit_inp_valve' and column_id='status';

UPDATE config_api_form_fields SET layout_order = 2 where formname='v_edit_inp_virtualvalve' and formname!='v_edit_inp_pipe' and column_id='node_1';
UPDATE config_api_form_fields SET layout_order = 3 where formname='v_edit_inp_virtualvalve' and formname!='v_edit_inp_pipe' and column_id='node_2';
UPDATE config_api_form_fields SET layout_order = 12 where formname='v_edit_inp_pipe' and  column_id='minorloss';
UPDATE config_api_form_fields SET layout_order = 13 where formname='v_edit_inp_pipe' and  column_id='status';
UPDATE config_api_form_fields SET layout_order = 14 where formname='v_edit_inp_pipe' and  column_id='custom_roughness';
UPDATE config_api_form_fields SET layout_order = 15 where formname='v_edit_inp_pipe' and  column_id='custom_dint';

DELETE FROM config_api_form_fields  WHERE formname='v_edit_inp_virtualvalve' and column_id='id';
UPDATE config_api_form_fields SET layout_order = 4 where formname='v_edit_inp_virtualvalve' and (column_id='elevation');
UPDATE config_api_form_fields SET layout_order = 5 where formname='v_edit_inp_virtualvalve' and (column_id='depth');
UPDATE config_api_form_fields SET layout_order = 6 where formname='v_edit_inp_virtualvalve' and (column_id='arccat_id');
UPDATE config_api_form_fields SET layout_order = 7 where formname='v_edit_inp_virtualvalve' and (column_id='sector_id');
UPDATE config_api_form_fields SET layout_order = 8 where formname='v_edit_inp_virtualvalve' and (column_id='macrosector_id');
UPDATE config_api_form_fields SET layout_order = 9 where formname='v_edit_inp_virtualvalve' and (column_id='dma_id');
UPDATE config_api_form_fields SET layout_order = 10 where formname='v_edit_inp_virtualvalve' and (column_id='state');
UPDATE config_api_form_fields SET layout_order = 11 where formname='v_edit_inp_virtualvalve' and (column_id='state_type');
UPDATE config_api_form_fields SET layout_order = 12 where formname='v_edit_inp_virtualvalve' and (column_id='annotation');
UPDATE config_api_form_fields SET layout_order = 13 where formname='v_edit_inp_virtualvalve' and (column_id='expl_id');

UPDATE config_api_form_fields SET layout_order = 14 where formname='v_edit_inp_virtualvalve' and column_id='valv_type';
UPDATE config_api_form_fields SET layout_order = 15 where formname='v_edit_inp_virtualvalve' and column_id='pressure';
UPDATE config_api_form_fields SET layout_order = 16 where formname='v_edit_inp_virtualvalve' and column_id='flow';
UPDATE config_api_form_fields SET layout_order = 17 where formname='v_edit_inp_virtualvalve' and column_id='coef_loss';
UPDATE config_api_form_fields SET layout_order = 18 where formname='v_edit_inp_virtualvalve' and column_id='curve_id';
UPDATE config_api_form_fields SET layout_order = 19 where formname='v_edit_inp_virtualvalve' and column_id='minorloss';
UPDATE config_api_form_fields SET layout_order = 20 where formname='v_edit_inp_virtualvalve' and column_id='to_arc';
UPDATE config_api_form_fields SET layout_order = 21 where formname='v_edit_inp_virtualvalve' and column_id='status';


INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_order,  datatype, widgettype, label, widgetdim, tooltip, placeholder, 
ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, 
widgetfunction, linkedaction, stylesheet, listfilterparam, layoutname, widgetcontrols, hidden) 
VALUES ('v_edit_inp_pipe', 'form', 'node_1', 2 , 'string', 'text', 'Node 1', NULL, 
'node_1 - Identificador del nodo inicial del tramo',
'node_1', FALSE, FALSE, TRUE, FALSE, 
NULL,false, FALSE, null,null, NULL, NULL, NULL, NULL, 'lyt_data_1', NULL, FALSE) ON CONFLICT (formname, formtype, column_id) DO NOTHING;

INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_order,  datatype, widgettype, label, widgetdim, tooltip, placeholder, 
ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, 
widgetfunction, linkedaction, stylesheet, listfilterparam, layoutname, widgetcontrols, hidden) 
VALUES ('v_edit_inp_pipe', 'form', 'node_2', 3 , 'string', 'text', 'Node 2', NULL, 
'node_2 - Identificador del nodo final del tramo',
'node_2', FALSE, FALSE, TRUE, FALSE, 
NULL,false, FALSE, null,null, NULL, NULL, NULL, NULL, 'lyt_data_1', NULL, FALSE) ON CONFLICT (formname, formtype, column_id) DO NOTHING;


INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_order,  datatype, widgettype, label, widgetdim, tooltip, placeholder, 
ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, 
widgetfunction, linkedaction, stylesheet, listfilterparam, layoutname, widgetcontrols, hidden) 
VALUES ('v_edit_inp_virtualvalve', 'form', 'node_1', 2 , 'string', 'text', 'Node 1', NULL, 
'node_1 - Identificador del nodo inicial del tramo','node_1', FALSE, FALSE, TRUE, FALSE, 
NULL,false, FALSE, null,null, NULL, NULL, NULL, NULL, 'lyt_data_1', NULL, FALSE) ON CONFLICT (formname, formtype, column_id) DO NOTHING;

INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_order,  datatype, widgettype, label, widgetdim, tooltip, placeholder, 
ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, 
widgetfunction, linkedaction, stylesheet, listfilterparam, layoutname, widgetcontrols, hidden) 
VALUES ('v_edit_inp_virtualvalve', 'form', 'node_2', 3 , 'string', 'text', 'Node 2', NULL, 
'node_2 - Identificador del nodo final del tramo', 'node_2', FALSE, FALSE, TRUE, FALSE, 
NULL,false, FALSE, null,null, NULL, NULL, NULL, NULL, 'lyt_data_1', NULL, FALSE) ON CONFLICT (formname, formtype, column_id) DO NOTHING;
