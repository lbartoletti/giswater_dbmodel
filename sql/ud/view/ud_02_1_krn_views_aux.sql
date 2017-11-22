﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = "SCHEMA_NAME", public, pg_catalog;

-- COMMON SQL (WS & UD)


-------------------------------------------------------
-- STATE VIEWS & JOINED WITH MASTERPLAN (ALTERNATIVES)
-------------------------------------------------------


DROP VIEW IF EXISTS v_state_arc CASCADE;;
CREATE VIEW v_state_arc AS
SELECT 
	arc_id
	FROM selector_state,selector_expl, arc
	WHERE arc.state=selector_state.state_id AND arc.expl_id=selector_expl.expl_id
	AND selector_state.cur_user=current_user

EXCEPT SELECT
	arc_id
	FROM selector_psector,plan_arc_x_psector
	WHERE plan_arc_x_psector.psector_id=selector_psector.psector_id
	AND selector_psector.cur_user=current_user AND state=0

UNION SELECT
	arc_id
	FROM selector_psector,plan_arc_x_psector
	WHERE plan_arc_x_psector.psector_id=selector_psector.psector_id
	AND selector_psector.cur_user=current_user AND state=1;
	


DROP VIEW IF EXISTS v_state_node CASCADE;;
CREATE VIEW v_state_node AS
SELECT 
	node_id
	FROM selector_state,selector_expl, node
	WHERE node.state=selector_state.state_id AND node.expl_id=selector_expl.expl_id
	AND selector_state.cur_user=current_user

EXCEPT SELECT
	node_id
	FROM selector_psector,plan_node_x_psector
	WHERE plan_node_x_psector.psector_id=selector_psector.psector_id
	AND selector_psector.cur_user=current_user AND state=0

UNION SELECT
	node_id
	FROM selector_psector,plan_node_x_psector
	WHERE plan_node_x_psector.psector_id=selector_psector.psector_id
	AND selector_psector.cur_user=current_user AND state=1;
	
	
	

DROP VIEW IF EXISTS v_state_connec CASCADE;;
CREATE VIEW v_state_connec AS
SELECT 
	connec_id
	FROM selector_state,selector_expl, connec
	WHERE connec.state=selector_state.state_id
	AND selector_state.cur_user=current_user AND connec.expl_id=selector_expl.expl_id;


	

DROP VIEW IF EXISTS v_state_gully CASCADE;
CREATE VIEW v_state_gully AS
SELECT 
	gully_id
	FROM selector_state, selector_expl, gully
	WHERE gully.state=selector_state.state_id
	AND selector_state.cur_user=current_user AND gully.expl_id=selector_expl.expl_id;

		
	
-- ----------------------------
-- View structure for v_arc_x_node
-- ----------------------------

DROP VIEW IF EXISTS v_arc CASCADE;
CREATE OR REPLACE VIEW v_arc AS 
SELECT 
arc.arc_id, 
arc.code,
arc.node_1, 
arc.node_2,
y1,
y2,
custom_y1,
custom_y2,
elev1,
elev2,
custom_elev1,
custom_elev2,
(CASE 
	WHEN (arc.custom_y1 IS NOT NULL) THEN arc.custom_y1::numeric (12,3)    
	ELSE y1::numeric (12,3) END) AS sys_y1,													-- field to customize the different options of y1 (mts or cms, field name or behaviour about the use of y1/custom_y1 fields
(CASE 
	WHEN (arc.custom_y2 IS NOT NULL) THEN arc.custom_y2::numeric (12,3)		
	ELSE y2::numeric (12,3) END) AS sys_y2,													-- field to customize the different options of y2 (mts or cms, field name or behaviour about the use of y2/custom_y2 fields
CASE
	WHEN arc.custom_elev1 IS NOT NULL THEN arc.custom_elev1
    ELSE arc.elev1
    END AS sys_elev1,
CASE
    WHEN arc.custom_elev2 IS NOT NULL THEN arc.custom_elev2
    ELSE arc.elev2
    END AS sys_elev2,												
arc.arc_type,
arc.arccat_id,
cat_arc.matcat_id,																	-- field to customize de source of the data matcat_id (from arc catalog or directly from arc table)
cat_arc.shape,
cat_arc.geom1,
cat_arc.width,
arc.epa_type,
arc.sector_id, 
CASE
	WHEN arc.builtdate IS NOT NULL THEN arc.builtdate
	ELSE '1900-01-01'::date
	END AS builtdate, 
arc.state,
arc.state_type,
arc.annotation,
st_length2d(arc.the_geom)::numeric(12,2) AS gis_length,
arc.observ, 
arc."comment",
arc.inverted_slope,
arc.custom_length,
arc.dma_id,
arc.soilcat_id,
arc.function_type,
arc.category_type,
arc.fluid_type,
arc.location_type,
arc.workcat_id,
arc.workcat_id_end,
arc.buildercat_id,
arc.enddate,
arc.ownercat_id,
arc.muni_id,
arc.streetaxis_id,
arc.address_01,
arc.address_02,
arc.address_03,
arc.descript,
arc.link,
arc.verified,
arc.the_geom,
arc.undelete,
arc.label_x,
arc.label_y,
arc.label_rotation,
arc.publish,
arc.inventory,
arc.uncertain,	
arc.expl_id,
arc.num_value
FROM selector_expl,arc
	JOIN v_state_arc ON arc.arc_id=v_state_arc.arc_id
	JOIN cat_arc ON arc.arccat_id = cat_arc.id
	WHERE arc.expl_id = selector_expl.expl_id AND selector_expl.cur_user = "current_user"()::text;



DROP VIEW IF EXISTS v_node CASCADE;
CREATE OR REPLACE VIEW v_node AS
SELECT
node.node_id,
node.code,
node.top_elev,
node.custom_top_elev,
(CASE WHEN (node.custom_top_elev IS NOT NULL) THEN node.custom_top_elev::numeric (12,3) ELSE top_elev::numeric (12,3) END) AS sys_top_elev,										
node.ymax,
node.custom_ymax,
(CASE WHEN (node.custom_ymax IS NOT NULL) THEN node.custom_ymax::numeric (12,3) ELSE ymax::numeric (12,3) END) AS sys_ymax,												
node.elev,
node.custom_elev,
(CASE WHEN (node.elev IS NOT NULL AND node.custom_elev IS NULL) THEN node.elev WHEN node.custom_elev IS NOT NULL THEN node.custom_elev ELSE (node.top_elev - node.ymax)::numeric(12,3) END)AS sys_elev,
node.node_type,
node.nodecat_id,
cat_node.matcat_id AS "cat_matcat_id",
node.epa_type,
node.sector_id, 
sector.macrosector_id,
node."state", 
node.state_type,
node.annotation, 
node.observ, 
node."comment",
node.dma_id,
node.soilcat_id,
node.function_type,
node.category_type,
node.fluid_type,
node.location_type,
node.workcat_id,
node.workcat_id_end,
node.buildercat_id,
node.builtdate,
node.enddate,
node.ownercat_id,
node.muni_id,
node.streetaxis_id,
node.address_01,
node.address_02,
node.address_03,
node.descript,
cat_node.svg AS "cat_svg",
node.rotation,
concat(node_type.link_path,node.link) as link,
node.verified,
node.the_geom,
node.undelete,
node.label_x,
node.label_y,
node.label_rotation,
node.publish,
node.inventory,
node.uncertain,
node.xyz_date,
node.unconnected,
dma.macrodma_id,
node.expl_id,
node.num_value
FROM node
	JOIN v_state_node ON node.node_id=v_state_node.node_id
	LEFT JOIN cat_node ON ((node.nodecat_id) = (cat_node.id))
	LEFT JOIN node_type ON node_type.id=node.node_type
	LEFT JOIN dma ON node.dma_id = dma.dma_id	
	LEFT JOIN sector ON node.sector_id = sector.sector_id;


DROP VIEW IF EXISTS v_node_x_arc CASCADE;
CREATE OR REPLACE VIEW v_node_x_arc AS
SELECT
node.node_id,
(CASE WHEN (node.custom_top_elev IS NOT NULL) THEN node.custom_top_elev::numeric (12,3) ELSE top_elev::numeric (12,3) END) AS sys_top_elev,										
(CASE WHEN (node.custom_ymax IS NOT NULL) THEN node.custom_ymax::numeric (12,3) ELSE ymax::numeric (12,3) END) AS sys_ymax
FROM node;

   	 

DROP VIEW IF EXISTS v_arc_x_node CASCADE;
CREATE OR REPLACE VIEW v_arc_x_node AS 
SELECT 
v_arc.arc_id,
v_arc.code,
node_1,
v_arc.y1,
v_arc.custom_y1,
v_arc.elev1,
v_arc.custom_elev1,
(CASE WHEN v_arc.sys_elev1 IS NOT NULL THEN v_arc.sys_elev1 ELSE a.sys_top_elev - v_arc.sys_y1 END) AS sys_elev1,
v_arc.sys_y1 - geom1 AS r1,
(CASE WHEN (a.sys_ymax IS NULL OR sys_y1 IS NULL) THEN 0 ELSE a.sys_ymax - v_arc.sys_y1 END) AS z1,
    
node_2,
v_arc.y2,
v_arc.custom_y2,
v_arc.elev2,
v_arc.custom_elev2,
(CASE WHEN v_arc.sys_elev2 IS NOT NULL THEN v_arc.sys_elev2 ELSE b.sys_top_elev - v_arc.sys_y2 END) AS sys_elev2,
v_arc.sys_y2 - geom1 AS r2,
(CASE WHEN (b.sys_ymax IS NULL OR sys_y2 IS NULL) THEN 0 ELSE b.sys_ymax - v_arc.sys_y2 END) AS z2,
(CASE
WHEN (gis_length=0 AND custom_length IS NULL) THEN NULL::float
WHEN ((CASE WHEN v_arc.sys_elev1 IS NOT NULL THEN v_arc.sys_elev1 ELSE a.sys_top_elev - v_arc.sys_y1 END)-(CASE WHEN v_arc.sys_elev2 IS NOT NULL THEN v_arc.sys_elev2 ELSE b.sys_top_elev - v_arc.sys_y2 END))
	/((CASE WHEN (custom_length IS NOT NULL) THEN custom_length::numeric (12,3) ELSE gis_length END)) > 1::double precision THEN NULL::float
	
ELSE ((CASE WHEN v_arc.sys_elev1 IS NOT NULL THEN v_arc.sys_elev1 ELSE a.sys_top_elev - v_arc.sys_y1 END) - (CASE WHEN v_arc.sys_elev2 IS NOT NULL THEN v_arc.sys_elev2 ELSE b.sys_top_elev - v_arc.sys_y2 END))
	/((CASE WHEN (custom_length IS NOT NULL) THEN custom_length::numeric (12,3) ELSE gis_length END))::float
END) AS slope,
arc_type,
arccat_id,
matcat_id,																	
shape,
geom1,
width,
v_arc.epa_type,
v_arc.sector_id, 
sector.macrosector_id,
v_arc.state,
v_arc.state_type,
v_arc.annotation,
custom_length,
gis_length,
v_arc.observ, 
v_arc.comment,
inverted_slope,
v_arc.dma_id,
dma.macrodma_id,
v_arc.soilcat_id,
v_arc.function_type,
v_arc.category_type,
v_arc.fluid_type,
v_arc.location_type,
v_arc.workcat_id,
v_arc.workcat_id_end,
v_arc.buildercat_id,
v_arc.builtdate,
v_arc.enddate,
v_arc.ownercat_id,
v_arc.muni_id,
v_arc.streetaxis_id,
v_arc.address_01,
v_arc.address_02,
v_arc.address_03,
v_arc.descript,
concat(arc_type.link_path,v_arc.link) as link,
v_arc.verified,
v_arc.the_geom,
v_arc.undelete,
v_arc.label_x,
v_arc.label_y,
v_arc.label_rotation,
v_arc.publish,
v_arc.inventory,
v_arc.uncertain,	
v_arc.expl_id,
v_arc.num_value
FROM v_arc
	JOIN sector ON sector.sector_id=v_arc.sector_id
	JOIN arc_type ON arc_type=arc_type.id
	JOIN dma ON v_arc.dma_id=dma.dma_id
	LEFT JOIN v_node_x_arc a ON a.node_id=node_1
	LEFT JOIN v_node_x_arc b ON b.node_id=node_2;
