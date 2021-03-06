/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--2020/03/07
DELETE FROM typevalue_fk WHERE target_table = 'man_addfields_parameter' AND target_field='widgettype_id';
DELETE FROM edit_typevalue WHERE typevalue = 'man_addfields_cat_widgettype';


CREATE INDEX man_addfields_parameter_cat_feature_id_index
ON man_addfields_parameter USING btree  (cat_feature_id);
  