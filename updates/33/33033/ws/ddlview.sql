/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--2020/03/12
CREATE OR REPLACE VIEW v_edit_link AS 
SELECT a.link_id,
    a.feature_type,
    a.feature_id,
    a.exit_type,
    a.exit_id,
    a.sector_id,
    a.macrosector_id,
    a.dma_id,
    a.macrodma_id,
    a.expl_id,
    a.state,
    a.gis_length,
    a.userdefined_geom,
    a.the_geom,
    a.ispsectorgeom,
    a.psector_rowid,
	a.fluid_type
   FROM ( SELECT link.link_id,
            link.feature_type,
            link.feature_id,
            link.exit_type,
            link.exit_id,
            arc.sector_id,
            sector.macrosector_id,
            arc.dma_id,
            dma.macrodma_id,
            arc.expl_id,
                CASE
                    WHEN plan_psector_x_connec.link_geom IS NULL THEN link.state
                    ELSE plan_psector_x_connec.state
                END AS state,
            st_length2d(link.the_geom) AS gis_length,
                CASE
                    WHEN plan_psector_x_connec.link_geom IS NULL THEN link.userdefined_geom
                    ELSE plan_psector_x_connec.userdefined_geom
                END AS userdefined_geom,
                CASE
                    WHEN plan_psector_x_connec.link_geom IS NULL THEN link.the_geom
                    ELSE plan_psector_x_connec.link_geom
                END AS the_geom,
                CASE
                    WHEN plan_psector_x_connec.link_geom IS NULL THEN false
                    ELSE true
                END AS ispsectorgeom,
                CASE
                    WHEN plan_psector_x_connec.link_geom IS NULL THEN NULL::integer
                    ELSE plan_psector_x_connec.id
                END AS psector_rowid,
			arc.fluid_type
           FROM link
             JOIN v_state_connec ON link.feature_id::text = v_state_connec.connec_id::text
             LEFT JOIN arc USING (arc_id)
             LEFT JOIN sector ON sector.sector_id::text = arc.sector_id::text
             LEFT JOIN dma ON dma.dma_id::text = arc.dma_id::text
             LEFT JOIN plan_psector_x_connec USING (arc_id, connec_id)) a
  WHERE a.state < 2;


  
DROP VIEW IF EXISTS v_edit_sector;
CREATE OR REPLACE VIEW v_edit_sector AS 
 SELECT sector.sector_id,
    sector.name,
    sector.descript,
    sector.macrosector_id,
    sector.the_geom,
    sector.undelete,
    sector.grafconfig::text AS grafconfig
   FROM inp_selector_sector,
    sector
  WHERE sector.sector_id = inp_selector_sector.sector_id AND inp_selector_sector.cur_user = "current_user"()::text;
