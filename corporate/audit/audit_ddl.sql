/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


CREATE SCHEMA audit;


CREATE TABLE audit.log (
id serial8 PRIMARY KEY,
schema text, 
table_name text,
id_name text,
user_name text,
action text,
olddata json,
newdata json,
query text,
tstamp timestamp default now()
);



ALTER TABLE SCHEMA_NAME.audit_cat_table add column isaudit boolean;
ALTER TABLE SCHEMA_NAME.audit_cat_table add column keepauditdays integer;
