/*
This file is part of Giswater 2.0
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

-- This file customize the customer request. Two items: ZONA & NO




/*
ZONA  (Already used by category_type)


CREATE TABLE "SCHEMA_NAME"."prdistrict" (
"prdistrict_id" varchar(30)   NOT NULL,
"sector_id" varchar(30)  ,
"descript" varchar(255)  ,
"observ" character varying(512),
"the_geom" public.geometry (MULTIPOLYGON, SRID_VALUE),
CONSTRAINT prdistrict_pkey PRIMARY KEY (prdistrict_id)
);


ALTER TABLE "SCHEMA_NAME"."prdistrict" ADD FOREIGN KEY ("sector_id") REFERENCES "SCHEMA_NAME"."sector" ("sector_id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "SCHEMA_NAME"."node" ADD FOREIGN KEY ("adress_01") REFERENCES "SCHEMA_NAME"."prdistrict" ("prdistrict_id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "SCHEMA_NAME"."arc" ADD FOREIGN KEY ("adress_01") REFERENCES "SCHEMA_NAME"."prdistrict" ("prdistrict_id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "SCHEMA_NAME"."connec" ADD FOREIGN KEY ("adress_01") REFERENCES "SCHEMA_NAME"."prdistrict" ("prdistrict_id") ON DELETE RESTRICT ON UPDATE CASCADE;

*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;

-- NO

CREATE TABLE "ppoint" (
"ppoint_id" varchar(30) NOT NULL,
"category_type" varchar(50),
"number" int4,
"observ" character varying(512),
"the_geom" public.geometry (MULTIPOLYGON, SRID_VALUE),
CONSTRAINT prdistrict_pkey PRIMARY KEY (ppoint_id)
);



-- ALTER TABLE "SCHEMA_NAME"."node" ADD FOREIGN KEY ("adress_01") REFERENCES "SCHEMA_NAME"."ppoint" ("ppoint_id") ON DELETE RESTRICT ON UPDATE CASCADE;
-- ALTER TABLE "SCHEMA_NAME"."arc" ADD FOREIGN KEY ("adress_01") REFERENCES "SCHEMA_NAME"."ppoint" ("ppoint_id") ON DELETE RESTRICT ON UPDATE CASCADE;
-- ALTER TABLE "SCHEMA_NAME"."connec" ADD FOREIGN KEY ("adress_01") REFERENCES "SCHEMA_NAME"."ppoint" ("ppoint_id") ON DELETE RESTRICT ON UPDATE CASCADE;

