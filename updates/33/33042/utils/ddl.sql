/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--2020/07/06
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_anlgraf", "column":"length", "dataType":"numeric(12,4)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_anlgraf", "column":"cost", "dataType":"numeric(12,4)", "isUtils":"False"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"temp_anlgraf", "column":"value", "dataType":"numeric(12,4)", "isUtils":"False"}}$$);
