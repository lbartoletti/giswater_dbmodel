/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;

DROP VIEW IF EXISTS v_edit_plan_psector CASCADE;
CREATE VIEW v_edit_plan_psector AS SELECT
	plan_psector.psector_id,
    plan_psector.name,
    plan_psector.descript,
    plan_psector.priority,
    plan_psector.text1,
    plan_psector.text2,
    plan_psector.observ,
    plan_psector.rotation,
    plan_psector.scale,
    plan_psector.sector_id,
    plan_psector.atlas_id,
    plan_psector.gexpenses,
    plan_psector.vat,
    plan_psector.other,
    plan_psector.the_geom,
    plan_psector.expl_id,
    plan_psector.psector_type
FROM selector_expl,plan_psector
WHERE ((plan_psector.expl_id)=(selector_expl.expl_id)
AND selector_expl.cur_user="current_user"());


DROP VIEW IF EXISTS v_edit_plan_psector_x_other;
CREATE OR REPLACE VIEW v_edit_plan_psector_x_other AS 
 SELECT plan_other_x_psector.id,
    plan_other_x_psector.psector_id,
    v_price_compost.unit,
    v_price_compost.id AS price_id,
    v_price_compost.descript,
    v_price_compost.price,
    plan_other_x_psector.measurement,
    (plan_other_x_psector.measurement * v_price_compost.price)::numeric(14,2) AS total_budget,
    plan_psector.atlas_id
   FROM plan_other_x_psector
     JOIN v_price_compost ON v_price_compost.id::text = plan_other_x_psector.price_id::text
     JOIN plan_psector ON plan_psector.psector_id = plan_other_x_psector.psector_id
  ORDER BY plan_other_x_psector.psector_id;