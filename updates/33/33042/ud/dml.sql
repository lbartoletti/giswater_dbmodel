/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


INSERT INTO audit_cat_param_user (id, formname, descript, sys_role_id, label, isenabled, project_type, isparent , isautoupdate, datatype, widgettype,
vdefault,ismandatory, isdeprecated)
VALUES 
('inp_options_settings', 'hidden_value', 'Additional settings for go2epa', 'role_epa', 'Additional settings for go2epa', true, 'ws', false, false, 'text', 'linetext', 
'{"vdefault":{"text":"Default values for user of q0, outfall_type, barrels, y0 and scf for user have been taken"},
  "advanced": {"text":"There is no advanced settings configured"},
  "debug":{"onlyExport":false, "onlyIsOperative":true}
 }',
true, false)
ON conflict (id) DO NOTHING;
