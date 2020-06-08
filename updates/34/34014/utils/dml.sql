/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- 2020/06/02
UPDATE sys_table SET id='cat_feature_arc' WHERE id = 'arc_type';
UPDATE sys_table SET id='cat_feature_node' WHERE id = 'node_type';
UPDATE sys_table SET id='cat_feature_connec' WHERE id = 'connec_type';