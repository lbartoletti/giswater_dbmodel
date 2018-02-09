﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;

----------------------------
--GIS EDITING VIEWS
----------------------------


DROP VIEW IF EXISTS v_edit_macrodma CASCADE;
CREATE VIEW v_edit_macrodma AS SELECT
	macrodma.macrodma_id,
	macrodma.name,
	macrodma.descript,
	macrodma.the_geom,
	macrodma.undelete,
	macrodma.expl_id
FROM selector_expl, macrodma 
WHERE ((macrodma.expl_id)=(selector_expl.expl_id)
AND selector_expl.cur_user="current_user"());
  

  
DROP VIEW IF EXISTS v_edit_dma CASCADE;
CREATE VIEW v_edit_dma AS SELECT
	dma.dma_id,
	dma.name,
	dma.macrodma_id,
	dma.descript,
	dma.the_geom,
	dma.undelete,
	dma.expl_id
	FROM selector_expl, dma 
WHERE ((dma.expl_id)=(selector_expl.expl_id)
AND selector_expl.cur_user="current_user"());
  


DROP VIEW IF EXISTS v_edit_sector CASCADE;
CREATE VIEW v_edit_sector AS SELECT
	sector.sector_id,
	sector.name,
	sector.descript,
	sector.macrosector_id,
	sector.the_geom,
	sector.undelete
FROM inp_selector_sector,sector 
WHERE ((sector.sector_id)=(inp_selector_sector.sector_id) 
AND inp_selector_sector.cur_user="current_user"());




DROP VIEW IF EXISTS v_edit_node CASCADE;
CREATE OR REPLACE VIEW v_edit_node AS
SELECT 
node_id, 
code,
elevation, 
depth, 
nodetype_id AS nodetype_id,
sys_type,
nodecat_id,
cat_matcat_id,
cat_pnom, 
cat_dnom,
epa_type,
v_node.sector_id,
sector.macrosector_id,
arc_id,
parent_id,
state, 
state_type,
annotation, 
observ, 
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
buildercat_id,
workcat_id_end,
builtdate,
enddate,
ownercat_id,
muni_id ,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
v_node.descript,
svg,
rotation,
link,
verified,
v_node.the_geom,
v_node.undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value
FROM v_node
	LEFT JOIN sector ON v_node.sector_id = sector.sector_id;


DROP VIEW IF EXISTS v_edit_arc CASCADE;
CREATE OR REPLACE VIEW v_edit_arc AS
SELECT 
arc_id,
code,
node_1,
node_2,
arccat_id, 
arctype_id AS "cat_arctype_id",
sys_type,
matcat_id AS "cat_matcat_id",
pnom AS "cat_pnom",
dnom AS "cat_dnom",
epa_type,
v_arc.sector_id, 
sector.macrosector_id,
state, 
state_type,
annotation, 
observ, 
comment,
gis_length,
custom_length,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id ,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
v_arc.descript,
link,
verified,
v_arc.the_geom,
v_arc.undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
num_value
FROM v_arc
	LEFT JOIN sector ON v_arc.sector_id = sector.sector_id;

DROP VIEW IF EXISTS v_edit_man_pipe CASCADE;
CREATE OR REPLACE VIEW v_edit_man_pipe AS
SELECT 
v_arc.arc_id,
code,
node_1,
node_2,
arccat_id, 
arctype_id AS "cat_arctype_id",
matcat_id AS "matcat_id",
pnom AS "cat_pnom",
dnom AS "cat_dnom",
epa_type,
sector_id, 
macrosector_id,
state,
state_type,
annotation,
observ,
"comment",
gis_length,
custom_length,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
link,
verified,
the_geom,
undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
num_value
FROM v_arc
	JOIN man_pipe ON man_pipe.arc_id=v_arc.arc_id;



DROP VIEW IF EXISTS v_edit_man_varc CASCADE;
CREATE OR REPLACE VIEW v_edit_man_varc AS
SELECT 
v_arc.arc_id,
code,
node_1,
node_2,
arccat_id, 
arctype_id AS "cat_arctype_id",
matcat_id AS "matcat_id",
pnom  AS "cat_pnom",
pnom  AS "cat_dnom",
epa_type,
sector_id, 
macrosector_id,
state,
state_type,
annotation,
observ,
comment,
gis_length,
custom_length,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
link,
verified,
the_geom,
undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
num_value
FROM v_arc 
	JOIN man_varc ON man_varc.arc_id=v_arc.arc_id;


DROP VIEW IF EXISTS v_edit_man_hydrant CASCADE;
CREATE OR REPLACE VIEW v_edit_man_hydrant AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
link,
verified,
the_geom,
undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
num_value,
hemisphere,
man_hydrant.fire_code,
man_hydrant.communication,
man_hydrant.valve,
man_hydrant.valve_diam
FROM v_node
    JOIN man_hydrant ON man_hydrant.node_id = v_node.node_id;  

	
	 
DROP VIEW IF EXISTS v_edit_man_junction CASCADE;
CREATE OR REPLACE VIEW v_edit_man_junction AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
"state",
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
label_x,
label_y,
label_rotation,
link,
verified,
the_geom,
undelete,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value
FROM v_node
	JOIN man_junction ON v_node.node_id = man_junction.node_id;

  

	 
DROP VIEW IF EXISTS v_edit_man_manhole CASCADE;
CREATE OR REPLACE VIEW v_edit_man_manhole AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation ,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
label_x,
label_y,
label_rotation,
link,
verified,
the_geom,
undelete,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value,
man_manhole.name
FROM v_node
	JOIN man_manhole ON v_node.node_id = man_manhole.node_id;



DROP VIEW IF EXISTS v_edit_man_meter CASCADE;
CREATE OR REPLACE VIEW v_edit_man_meter AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
link,
label_x,
label_y,
label_rotation,
verified,
the_geom,
undelete,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value
FROM v_node 
	JOIN man_meter ON man_meter.node_id = v_node.node_id;

	
	 
DROP VIEW IF EXISTS v_edit_man_pump CASCADE;
CREATE OR REPLACE VIEW v_edit_man_pump AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
label_x,
label_y,
label_rotation,
link,
verified,
the_geom,
undelete,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value,
man_pump.max_flow,
man_pump.min_flow,
man_pump.nom_flow,
man_pump."power",
man_pump.pressure,
man_pump.elev_height,
man_pump.name,
man_pump.pump_number
FROM v_node
	JOIN man_pump ON man_pump.node_id = v_node.node_id;

	
	
DROP VIEW IF EXISTS v_edit_man_reduction CASCADE;
CREATE OR REPLACE VIEW v_edit_man_reduction AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
link,
verified,
the_geom,
undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value,
man_reduction.diam1,
man_reduction.diam2
FROM v_node 
	JOIN man_reduction ON man_reduction.node_id = v_node.node_id;
	


DROP VIEW IF EXISTS v_edit_man_source CASCADE;
CREATE OR REPLACE VIEW v_edit_man_source AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
link,
verified,
the_geom,
undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value,
man_source.name
FROM v_node
	JOIN man_source ON v_node.node_id = man_source.node_id;
 
	 
DROP VIEW IF EXISTS v_edit_man_valve CASCADE;
CREATE OR REPLACE VIEW v_edit_man_valve AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
link,
verified,
the_geom,
undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value,
man_valve.closed,
man_valve.broken,
man_valve.buried,
man_valve.irrigation_indicator,
man_valve.pression_entry,
man_valve.pression_exit,
man_valve.depth_valveshaft,
man_valve.regulator_situation,
man_valve.regulator_location,
man_valve.regulator_observ,
man_valve.lin_meters,
man_valve.exit_type,
man_valve.exit_code,
man_valve.drive_type,
man_valve.valve_diam,
man_valve.cat_valve2
FROM v_node
	JOIN man_valve ON man_valve.node_id = v_node.node_id;

	 
DROP VIEW IF EXISTS v_edit_man_waterwell CASCADE;
CREATE OR REPLACE VIEW v_edit_man_waterwell AS 
SELECT
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
link,
verified,
the_geom,
undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value,
man_waterwell.name
FROM v_node
	JOIN man_waterwell ON v_node.node_id = man_waterwell.node_id;
	
   
DROP VIEW IF EXISTS v_edit_man_tank CASCADE;
CREATE OR REPLACE VIEW v_edit_man_tank AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
link,
verified,
the_geom,
undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value,
man_tank.pol_id,
man_tank.vmax,
man_tank.vutil,
man_tank.area,
man_tank.chlorination,
man_tank.name
FROM v_node
	JOIN man_tank ON man_tank.node_id = v_node.node_id;
	
	
DROP VIEW IF EXISTS v_edit_man_tank_pol CASCADE;
CREATE OR REPLACE VIEW v_edit_man_tank_pol AS 
SELECT 
man_tank.pol_id,
v_node.node_id,
polygon.the_geom
FROM v_node
	JOIN man_tank ON man_tank.node_id = v_node.node_id
	JOIN polygon ON polygon.pol_id=man_tank.pol_id;
	

DROP VIEW IF EXISTS v_edit_man_filter CASCADE;
CREATE OR REPLACE VIEW v_edit_man_filter AS 
SELECT
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
label_x,
label_y,
label_rotation,
link,
verified,
the_geom,
undelete,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value
FROM v_node
	JOIN man_filter ON v_node.node_id = man_filter.node_id;
	
	
DROP VIEW IF EXISTS v_edit_man_register CASCADE;
CREATE OR REPLACE VIEW v_edit_man_register AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
link,
verified,
the_geom,
undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value,
man_register.pol_id
FROM v_node
	JOIN man_register ON v_node.node_id = man_register.node_id;
	

	
DROP VIEW IF EXISTS v_edit_man_register_pol CASCADE;
CREATE OR REPLACE VIEW v_edit_man_register_pol AS 
SELECT 
man_register.pol_id,
v_node.node_id,
polygon.the_geom
FROM v_node
	JOIN man_register ON v_node.node_id = man_register.node_id
	JOIN polygon ON polygon.pol_id = man_register.pol_id;
	
	
	
DROP VIEW IF EXISTS v_edit_man_netwjoin CASCADE;
CREATE OR REPLACE VIEW v_edit_man_netwjoin AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
link,
verified,
v_node.the_geom,
undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
v_node.expl_id,
hemisphere,
num_value,
man_netwjoin.customer_code,
man_netwjoin.top_floor,
man_netwjoin.cat_valve
FROM v_node
	JOIN man_netwjoin ON v_node.node_id = man_netwjoin.node_id;

	
	
DROP VIEW IF EXISTS v_edit_man_flexunion CASCADE;
CREATE OR REPLACE VIEW v_edit_man_flexunion AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
link,
verified,
the_geom,
undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value
FROM v_node
	JOIN man_flexunion ON v_node.node_id = man_flexunion.node_id;
	
	
DROP VIEW IF EXISTS v_edit_man_wtp CASCADE;
CREATE OR REPLACE VIEW v_edit_man_wtp AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
link,
verified,
the_geom,
undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value,
man_wtp.name
FROM v_node
	JOIN man_wtp ON v_node.node_id = man_wtp.node_id;
	
	
DROP VIEW IF EXISTS v_edit_man_expansiontank CASCADE;
CREATE OR REPLACE VIEW v_edit_man_expansiontank AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
link,
verified,
the_geom,
undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value
FROM v_node
	JOIN man_expansiontank ON v_node.node_id = man_expansiontank .node_id;
	
	

DROP VIEW IF EXISTS v_edit_man_netsamplepoint CASCADE;
CREATE OR REPLACE VIEW v_edit_man_netsamplepoint AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
link,
verified,
the_geom,
undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value,
man_netsamplepoint.lab_code
FROM v_node
	JOIN man_netsamplepoint ON v_node.node_id = man_netsamplepoint .node_id;
	
	

DROP VIEW IF EXISTS v_edit_man_netelement CASCADE;
CREATE OR REPLACE VIEW v_edit_man_netelement AS 
SELECT 
v_node.node_id,
code,
elevation,
depth,
nodetype_id,
nodecat_id,
cat_matcat_id,
cat_pnom,
cat_dnom,
epa_type,
sector_id,
macrosector_id,
arc_id,
parent_id, 
state,
state_type,
annotation,
observ,
comment,
dma_id,
presszonecat_id,
soilcat_id,
function_type,
category_type,
fluid_type,
location_type,
workcat_id,
workcat_id_end,
buildercat_id,
builtdate,
enddate,
ownercat_id,
muni_id,
postcode,
streetaxis_id,
postnumber,
postcomplement,
postcomplement2,
streetaxis2_id,
postnumber2,
descript,
svg,
rotation,
link,
verified,
the_geom,
undelete,
label_x,
label_y,
label_rotation,
publish,
inventory,
macrodma_id,
expl_id,
hemisphere,
num_value,
man_netelement.serial_number
FROM v_node
	JOIN man_netelement ON v_node.node_id = man_netelement .node_id;
	

	
DROP  VIEW  IF EXISTS v_edit_link;
CREATE OR REPLACE VIEW v_edit_link AS 
 SELECT link.link_id,
    link.feature_type,
    link.feature_id,
    link.exit_type,
    link.exit_id,
        CASE
            WHEN link.feature_type::text = 'CONNEC'::text THEN connec.sector_id
            ELSE vnode.sector_id
        END AS sector_id,
	sector.macrosector_id,
        CASE
            WHEN link.feature_type::text = 'CONNEC'::text THEN connec.dma_id
            ELSE vnode.dma_id
        END AS dma_id,
	dma.macrodma_id,
        CASE
            WHEN link.feature_type::text = 'CONNEC'::text THEN connec.expl_id
            ELSE vnode.expl_id
        END AS expl_id,
    link.state,
    st_length2d(link.the_geom) AS gis_length,
    link.userdefined_geom,
    link.the_geom
   FROM selector_expl,    selector_state,    link
     LEFT JOIN connec ON link.feature_id::text = connec.connec_id::text AND link.feature_type::text = 'CONNEC'::text
     LEFT JOIN vnode ON link.feature_id::text = vnode.vnode_id::text AND link.feature_type::text = 'VNODE'::text
	 LEFT JOIN sector ON sector.sector_id::text=connec.sector_id::text OR sector.sector_id::text=vnode.sector_id::text 
  WHERE link.expl_id = selector_expl.expl_id AND selector_expl.cur_user = "current_user"()::text 
  AND link.state = selector_state.state_id AND selector_state.cur_user = "current_user"()::text;


  
DROP VIEW IF EXISTS v_edit_vnode CASCADE;
CREATE VIEW v_edit_vnode AS SELECT
vnode_id,
vnode_type,
vnode.sector_id,
vnode.dma_id,
vnode.state,
annotation,
vnode.the_geom,
vnode.expl_id
FROM selector_expl, selector_state, vnode
	WHERE 
	vnode.expl_id=selector_expl.expl_id AND selector_expl.cur_user="current_user"() AND
	vnode.state=selector_state.state_id AND selector_state.cur_user="current_user"();


	

DROP VIEW IF EXISTS v_edit_pond CASCADE;
CREATE VIEW v_edit_pond AS 
SELECT
pond_id,
connec_id,
pond.dma_id,
dma.macrodma_id,
pond."state",
pond.the_geom,
pond.expl_id
FROM selector_expl,pond
LEFT JOIN dma ON pond.dma_id = dma.dma_id
WHERE ((pond.expl_id)=(selector_expl.expl_id)
AND selector_expl.cur_user="current_user"());


DROP VIEW IF EXISTS v_edit_pool CASCADE;
CREATE VIEW v_edit_pool AS 
SELECT
pool_id,
connec_id,
pool.dma_id,
dma.macrodma_id,
pool."state",
pool.the_geom,
pool.expl_id
FROM selector_expl,pool
LEFT JOIN dma ON pool.dma_id = dma.dma_id
WHERE ((pool.expl_id)=(selector_expl.expl_id)
AND selector_expl.cur_user="current_user"());



DROP VIEW IF EXISTS v_edit_samplepoint CASCADE;
CREATE VIEW v_edit_samplepoint AS SELECT
	samplepoint.sample_id,
	code,
	lab_code,
	feature_id,
	featurecat_id,
	samplepoint.dma_id,
	dma.macrodma_id,
	presszonecat_id,
	state,
	builtdate,
	enddate,
	workcat_id,
	workcat_id_end,
	rotation,
	muni_id,
	streetaxis_id,
	postnumber,
	postcode,
	streetaxis2_id,
	postnumber2,
	postcomplement,
	postcomplement2,
	place_name,
	cabinet,
	observations,
	verified,
	samplepoint.the_geom,
	samplepoint.expl_id
FROM selector_expl,samplepoint
JOIN v_state_samplepoint ON samplepoint.sample_id=v_state_samplepoint.sample_id
LEFT JOIN dma ON dma.dma_id=samplepoint.dma_id
WHERE ((samplepoint.expl_id)=(selector_expl.expl_id)
AND selector_expl.cur_user="current_user"());



DROP VIEW IF EXISTS v_value_cat_connec CASCADE;
CREATE OR REPLACE VIEW v_value_cat_connec AS 
 SELECT cat_connec.id,
    cat_connec.connectype_id AS connec_type,
    connec_type.type
   FROM cat_connec
     JOIN connec_type ON connec_type.id::text = cat_connec.connectype_id::text;


 
DROP VIEW IF EXISTS v_value_cat_node CASCADE;
CREATE OR REPLACE VIEW v_value_cat_node AS 
 SELECT cat_node.id,
    cat_node.nodetype_id,
    node_type.type
   FROM cat_node
     JOIN node_type ON node_type.id::text = cat_node.nodetype_id::text;

