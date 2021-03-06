/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


--DROP CONSTRAINT
DROP INDEX IF EXISTS shortcut_unique;

--ADD CONSTRAINT
CREATE UNIQUE INDEX shortcut_unique ON cat_feature USING btree (shortcut_key COLLATE pg_catalog."default");
