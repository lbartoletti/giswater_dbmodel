/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;


-- 2020/02/10

CREATE TABLE doc_x_workcat
(
  id serial NOT NULL,
  doc_id character varying(30),
  workcat_id character varying (30),
  CONSTRAINT doc_x_workcat_pkey PRIMARY KEY (id),
  CONSTRAINT doc_x_workcat_doc_id_fkey FOREIGN KEY (doc_id)
      REFERENCES doc (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT doc_x_workcat_workcat_id_fkey FOREIGN KEY (workcat_id)
      REFERENCES cat_work (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
);


