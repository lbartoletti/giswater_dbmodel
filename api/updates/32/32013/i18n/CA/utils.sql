
/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

UPDATE config_api_form_tabs SET tabtext = 'Llista de documents' WHERE formname ilike 'v_edit_%' AND tabname = 'tab_documents';
UPDATE config_api_form_tabs SET tabtext = 'Llista de abonats' WHERE formname ilike 'v_edit_%' AND tabname = 'tab_hydrometer';
UPDATE config_api_form_tabs SET tabtext = 'Llista de eventos de l''element' WHERE formname ilike 'v_edit_%' AND tabname = 'tab_visit';
UPDATE config_api_form_tabs SET tabtext = 'Llista de eventos de l''element' WHERE formname ilike 'v_edit_%' AND tabname = 'tab_om';
UPDATE config_api_form_tabs SET tabtext = 'Valors de consum per abonat' WHERE formname ilike 'v_edit_%' AND tabname = 'tab_hydrometer_val';
UPDATE config_api_form_tabs SET tabtext = 'Partides de l''element' WHERE formname ilike 'v_edit_%' AND tabname = 'tab_plan';
UPDATE config_api_form_tabs SET tabtext = 'Llista d''elements relacionats' WHERE formname ilike 'v_edit_%' AND tabname = 'tab_elements';

--basic visit configuration
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'image1', 1, 2, true, 'bytea', 'image', NULL, NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, 'SELECT row_to_json(res) FROM (SELECT encode(image, ''base64'') AS image FROM config_api_images WHERE id=1) res;', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'visit_id', 1, 3, true, 'double', 'text', 'Visit id:', NULL, NULL, NULL, 12, 0, false, NULL, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'lot_id', 1, 5, true, 'integer', 'combo', 'Lot id:', NULL, NULL, NULL, NULL, NULL, true, NULL, false, NULL, 'SELECT id , idval FROM om_visit_lot WHERE active IS TRUE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'divider', 1, 11, true, NULL, 'formDivider', NULL, NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'feature_id', 1, 4, true, 'double', 'text', 'Feature_id', NULL, NULL, NULL, 12, 0, false, NULL, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'lot_id', 1, 4, true, 'integer', 'combo', 'Lot id:', NULL, NULL, NULL, NULL, NULL, true, NULL, false, NULL, 'SELECT id , idval FROM om_visit_lot WHERE active IS TRUE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'event_id', 1, 2, true, 'double', 'text', 'Event id:', NULL, NULL, NULL, 12, 0, false, NULL, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'visit_id', 1, 3, true, 'double', 'text', 'Visit id:', NULL, NULL, NULL, 12, 0, false, NULL, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'user_name', 1, 10, true, 'string', 'text', 'Usuari:', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'status', 1, 13, true, 'integer', 'combo', 'Estatut:', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, 'SELECT DISTINCT (id) AS id,  idval  AS idval FROM om_typevalue WHERE id IS NOT NULL AND typevalue=''visit_cat_status'' ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'position_value', 1, 13, true, 'double', 'text', 'Valor posició:', NULL, NULL, 'Ex.: 34.57', 12, 2, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'status', 1, 16, true, 'integer', 'combo', 'Estatut:', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, 'SELECT DISTINCT (id) AS id,  idval  AS idval FROM om_typevalue WHERE id IS NOT NULL AND typevalue=''visit_cat_status'' ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'startdate', 1, 14, true, 'date', 'text', 'Data inici:', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'class_id', 1, 1, true, 'integer', 'combo', 'Tipus visita:', NULL, NULL, NULL, 12, 0, true, NULL, true, NULL, 'SELECT id, idval FROM om_visit_class WHERE feature_type=''ARC'' AND  active IS TRUE AND sys_role_id IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, ''member''))', NULL, NULL, NULL, NULL, 'gwGetVisit', NULL, true, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'enddate', 1, 15, true, 'date', 'datepickertime', 'Data fin:', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'acceptbutton', 9, 1, true, NULL, 'button', 'Acceptar', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, 'gwSetVisit', NULL, NULL, NULL, NULL, NULL, NULL, 'data_9', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'acceptbutton', 9, 1, true, NULL, 'button', 'Acceptar', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, 'gwSetVisit', NULL, NULL, NULL, NULL, NULL, NULL, 'data_9', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'backbutton', 9, 2, true, NULL, 'button', 'Enrere', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, 'backButtonClicked', NULL, NULL, NULL, NULL, NULL, NULL, 'data_9', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'backbutton', 9, 2, true, NULL, 'button', 'Enrere', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, 'backButtonClicked', NULL, NULL, NULL, NULL, NULL, NULL, 'data_9', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'class_id', 1, 1, true, 'integer', 'combo', 'Tipus visita:', NULL, NULL, NULL, NULL, NULL, true, NULL, true, NULL, 'SELECT id, idval FROM om_visit_class WHERE feature_type=''ARC'' AND  active IS TRUE AND sys_role_id IN (SELECT rolname FROM pg_roles WHERE  pg_has_role( current_user, oid, ''member''))', NULL, NULL, NULL, NULL, 'gwGetVisit', NULL, true, NULL, true, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'enddate', 1, 12, true, 'date', 'datepickertime', 'Data fin:', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'startdate', 1, 11, true, 'date', 'datepickertime', 'Data inici:', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'ext_code', 1, 6, true, 'string', 'text', 'Codi:', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'position_id', 1, 12, true, 'string', 'combo', 'Posició id:', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, 'SELECT id, idval FROM (SELECT node_1 AS id, node_1 AS idval FROM arc UNION SELECT DISTINCT node_2 AS id, node_2 AS idval FROM arc) WHERE id IS NOT NULL', NULL, NULL, 'arc_id', ' AND arc.arc_id.arc_id=', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'visitcat_id', 1, 9, true, 'string', 'combo', 'Catàleg visita:', NULL, NULL, NULL, NULL, NULL, false, NULL, true, false, 'SELECT id , name as idval FROM om_visit_cat WHERE id IS NOT NULL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'descript', 1, 10, true, 'string', 'text', 'Descripció:', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'feature_id', 1, 5, true, 'string', 'text', 'Feature_id', NULL, NULL, NULL, NULL, NULL, false, NULL, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'ext_code', 1, 6, true, 'string', 'text', 'Codi:', NULL, NULL, 'Ex.: Work order code', NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'user_name', 1, 11, true, 'string', 'text', 'Usuari:', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'visitcat_id', 1, 7, true, 'string', 'combo', 'Catàleg visita:', NULL, NULL, NULL, NULL, NULL, false, NULL, true, false, 'SELECT id , name as idval FROM om_visit_cat WHERE id IS NOT NULL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'descript', 1, 9, true, 'string', 'text', 'Descripció:', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_multievent', 'visit', 'expl_id', 1, 8, true, 'string', 'combo', 'Explotació:', NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, 'SELECT expl_id as id , name as idval FROM exploitation WHERE expl_id IS NOT NULL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'parameter_id', 1, 7, true, 'string', 'combo', 'Paràmetre:', NULL, NULL, NULL, NULL, NULL, false, NULL, false, NULL, 'SELECT id AS id, descript AS idval FROM om_visit_parameter WHERE feature_type=''ARC''', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'event_code', 1, 8, true, 'string', 'text', 'Event codi:', NULL, NULL, 'Ex.: Parameter code', NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);
INSERT INTO config_api_form_fields (formname, formtype, column_id, layout_id, layout_order, isenabled, datatype, widgettype, label, widgetdim, tooltip, placeholder, field_length, num_decimals, ismandatory, isparent, iseditable, isautoupdate, dv_querytext, dv_orderby_id, dv_isnullvalue, dv_parent_id, dv_querytext_filterc, widgetfunction, action_function, isreload, stylesheet, isnotupdate, typeahead, listfilterparam, layout_name, editability, widgetcontrols) VALUES ('visit_singlevent', 'visit', 'divider', 1, 14, true, NULL, 'formDivider', NULL, NULL, NULL, NULL, NULL, NULL, false, NULL, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'data_1', NULL, NULL);

