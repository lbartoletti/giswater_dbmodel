/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

-----------------------
-- config api values
-----------------------
INSERT INTO config_api_cat_datatype VALUES ('nodatatype', NULL);
INSERT INTO config_api_cat_datatype VALUES ('string', NULL);
INSERT INTO config_api_cat_datatype VALUES ('double', NULL);
INSERT INTO config_api_cat_datatype VALUES ('date', NULL);
INSERT INTO config_api_cat_datatype VALUES ('boolean', NULL);
INSERT INTO config_api_cat_datatype VALUES ('integer', NULL);

INSERT INTO config_api_cat_formtemplate VALUES ('generic', NULL);
INSERT INTO config_api_cat_formtemplate VALUES ('custom_feature', NULL);
INSERT INTO config_api_cat_formtemplate VALUES ('config', NULL);
INSERT INTO config_api_cat_formtemplate VALUES ('go2epa', NULL);

INSERT INTO config_api_cat_widgettype VALUES ('label', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('hspacer', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('nowidget', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('checkbox', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('button', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('line', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('date', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('spinbox', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('areatext', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('linetext', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('combo', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('combotext', NULL);
INSERT INTO config_api_cat_widgettype VALUES ('hyperlink', NULL);


INSERT INTO config_api_form_actions VALUES (22, 've_node', 'actionCatalog', 'Catalog', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (23, 've_arc', 'actionCatalog', 'Catalog', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (24, 've_connec', 'actionCatalog', 'Catalog', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (25, 've_node', 'actionWorkcat', 'Workcat', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (26, 've_arc', 'actionWorkcat', 'Workcat', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (27, 've_connec', 'actionWorkcat', 'Workcat', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (28, 've_arc', 'actionSection', 'Show section', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (16, 've_arc', 'actionHelp', 'Help', NULL, 'ud');
INSERT INTO config_api_form_actions VALUES (9, 've_node', 'actionInterpolate', 'Interpolate', NULL, 'ud');
INSERT INTO config_api_form_actions VALUES (8, 've_node', 'actionHelp', 'Help', NULL, 'ud');
INSERT INTO config_api_form_actions VALUES (29, 've_arc', 'actionAdd', 'Add row', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (30, 've_arc', 'actionInfo', 'info row', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (31, 've_arc', 'actionDelete', 'Delete roe', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (1, 've_node', 'actionZoom', 'Zoom', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (21, 've_connec', 'actionLink', 'Link', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (20, 've_connec', 'actionZoomOut', 'Zoom Out', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (18, 've_connec', 'actionCentered', 'Centered', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (17, 've_connec', 'actionZoom', 'Zoom', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (15, 've_arc', 'actionCopyPaste', 'Copy&Paste', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (14, 've_arc', 'actionLink', 'Link', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (13, 've_arc', 'actionZoomOut', 'Zoom Out', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (11, 've_arc', 'actionCentered', 'Centered', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (10, 've_arc', 'actionZoom', 'Zoom', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (6, 've_node', 'actionLink', 'Link', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (5, 've_node', 'actionRotation', 'Rotation', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (3, 've_node', 'actionZoomOut', 'Zoom Out', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (2, 've_node', 'actionCentered', 'Centered', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (4, 've_node', 'actionCopyPaste', 'Copy&Paste', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (7, 've_node', 'actionEdit', 'Edit', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (12, 've_arc', 'actionEdit', 'Edit', NULL, 'utils');
INSERT INTO config_api_form_actions VALUES (19, 've_connec', 'actionEdit', 'Edit', NULL, 'utils');


INSERT INTO config_api_form_groupbox VALUES (12, 'go2epa', 1, 'Pre-process options');
INSERT INTO config_api_form_groupbox VALUES (13, 'go2epa', 2, 'File manager');
INSERT INTO config_api_form_groupbox VALUES (14, 'epaoptions', 1, 'Options');
INSERT INTO config_api_form_groupbox VALUES (15, 'epaoptions', 2, 'Times');
INSERT INTO config_api_form_groupbox VALUES (16, 'epaoptions', 3, 'Report');
INSERT INTO config_api_form_groupbox VALUES (1, 'config', 1, 'gb1');
INSERT INTO config_api_form_groupbox VALUES (11, 'config', 99, 'gb99');
INSERT INTO config_api_form_groupbox VALUES (2, 'config', 2, 'gb2');
INSERT INTO config_api_form_groupbox VALUES (3, 'config', 3, 'gb3');
INSERT INTO config_api_form_groupbox VALUES (4, 'config', 4, 'gb4');
INSERT INTO config_api_form_groupbox VALUES (5, 'config', 5, 'gb5');
INSERT INTO config_api_form_groupbox VALUES (6, 'config', 6, 'gb6');
INSERT INTO config_api_form_groupbox VALUES (7, 'config', 7, 'gb7');
INSERT INTO config_api_form_groupbox VALUES (8, 'config', 8, 'gb8');
INSERT INTO config_api_form_groupbox VALUES (9, 'config', 9, 'gb9');
INSERT INTO config_api_form_groupbox VALUES (10, 'config', 10, 'gb10');


INSERT INTO config_api_form_tabs VALUES (561, 've_arc', 'tab_inp', 'EPA inp', NULL, 'role_epa', NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (303, 've_arc', 'tab_relations', 'Rel', 'Lista de relaciones', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (563, 've_node', 'tab_inp', 'EPA inp', NULL, 'role_epa', NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (408, 've_connec', 'tab_elements', 'Elem', 'Lista de elementos relacionados', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (208, 've_node', 'tab_documents', 'Doc', 'Lista de documentos', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (566, 've_connec', 'tab_hydrometer_val', 'Consumos', 'Valores de consumo para abonado', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (411, 've_connec', 'tab_visit', 'Visit', 'Lista de eventos del elemento', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (210, 've_node', 'tab_plan', 'Cost', 'Partidas del elemento', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (307, 've_arc', 'tab_documents', 'Doc', 'Lista de documentos', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (412, 've_connec', 'tab_documents', 'Doc', 'Lista de documentos', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (309, 've_arc', 'tab_plan', 'Cos', 'Partidas del elemento', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (500, 'config', 'tabUser', 'User', NULL, 'role_basic', NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (560, 'config', 'tabAdmin', 'Admin', NULL, 'role_admin', NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (7, 'search', 'tab_network', 'Xarxa', 'Elements de xarxa', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (9, 'search', 'tab_address', 'Carrerer', 'Carrerer dades PG', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (10, 'search', 'tab_hydro', 'Abonat', 'Abonat', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (11, 'search', 'tab_workcat', 'Expedient', 'Expedients', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (306, 've_arc', 'tab_om', 'OM', 'Lista de eventos del elemento', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (12, 'search', 'tab_psector', 'Psector', 'Sectors de planejament', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (8, 'search_', 'tab_search', 'Cercador', 'Carrerer API web', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (565, 'search', 'tab_visit', 'Visita', 'Visita', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (1, 'filters', 'tabExploitation', 'Explotacions', 'Explotacions actives', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (2, 'filters', 'tabNetworkState', 'Elements xarxa', 'Elements de xarxa', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (3, 'filters', 'tabHydroState', 'Abonats', 'Abonats', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (562, 've_arc', 'tab_rpt', 'EPA results', NULL, 'role_om', NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (564, 've_node', 'tab_rpt', 'EPA results', NULL, 'role_om', NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (311, 've_arc', 'tab_visit', 'Visit', 'Lista de eventos del elemento', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (409, 've_connec', 'tab_hydrometer', 'Abonados', 'Lista de abonados', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (204, 've_node', 'tab_elements', 'Elem', 'Lista de elementos relacionados', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (206, 've_node', 'tab_connections', 'Conn', '{"Elementos aguas arriba","Elementos aguas abajo"}', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (207, 've_node', 'tab_visit', 'Visit', 'Lista de eventos del elemento', NULL, NULL, NULL, NULL);
INSERT INTO config_api_form_tabs VALUES (302, 've_arc', 'tab_elements', 'Elem', 'Lista de elementos relacionados', NULL, NULL, NULL, NULL);


INSERT INTO config_api_message VALUES (10, 2, 'There are not exists the class of visit provided', NULL);


INSERT INTO config_api_visit VALUES (2, 'visit_connec_insp', 've_visit_multievent_x_connec');
INSERT INTO config_api_visit VALUES (1, 'visit_arc_leak', 've_visit_singlevent_x_arc');
INSERT INTO config_api_visit VALUES (6, 'visit_arc_insp', 've_visit_multievent_x_arc');
INSERT INTO config_api_visit VALUES (5, 'visit_node_insp', 've_visit_multievent_x_node');
INSERT INTO config_api_visit VALUES (4, 'visit_connec_leak', 've_visit_singlevent_x_connec');
INSERT INTO config_api_visit VALUES (3, 'visit_node_leak', 've_visit_singlevent_x_node');

-----------------------
-- sys values
-----------------------
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

-----------------------
-- value type values
-----------------------

INSERT INTO value_type VALUES ('verified', '1', 'SI', NULL);
INSERT INTO value_type VALUES ('verified', '2', 'NO', NULL);
INSERT INTO value_type VALUES ('yesno', '2', 'NO', NULL);
INSERT INTO value_type VALUES ('verified', '3', 'PENDIENTE', NULL);
INSERT INTO value_type VALUES ('yesno', '1', 'SI', NULL);
INSERT INTO value_type VALUES ('priority', '1', 'ALTA', NULL);
INSERT INTO value_type VALUES ('priority', '2', 'MEDIA', NULL);
INSERT INTO value_type VALUES ('priority', '3', 'BAJA', NULL);
INSERT INTO value_type VALUES ('listlimit', '1', '10', NULL);
INSERT INTO value_type VALUES ('listlimit', '2', '50', NULL);
INSERT INTO value_type VALUES ('listlimit', '3', '100', NULL);
INSERT INTO value_type VALUES ('listlimit', '4', '500', NULL);
INSERT INTO value_type VALUES ('listlimit', '5', '1000', NULL);
INSERT INTO value_type VALUES ('nullvalue', '0', NULL, NULL);