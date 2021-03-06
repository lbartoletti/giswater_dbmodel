/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

-- 2020/01/10
DELETE FROM audit_cat_param_user WHERE id IN ('audit_project_plan_result', 'audit_project_epa_result');


UPDATE audit_cat_param_user SET formname='hidden_value', label='Skip demand pattern' WHERE id= 'inp_options_skipdemandpattern';
		