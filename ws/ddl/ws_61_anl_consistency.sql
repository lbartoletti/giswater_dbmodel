/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;



DROP TABLE IF EXISTS anl_node_topological_consistency CASCADE;
CREATE TABLE anl_node_topological_consistency (
  node_id character varying(16) NOT NULL,
  node_type character varying(30),
  num_arcs integer,  
  the_geom geometry(Point,SRID_VALUE),
  CONSTRAINT anl_node_topological_consistency_pkey PRIMARY KEY (node_id)
);

