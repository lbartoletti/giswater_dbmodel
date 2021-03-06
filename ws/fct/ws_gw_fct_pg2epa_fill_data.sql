/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2328

DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_pg2epa_fill_data(varchar);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_pg2epa_fill_data(result_id_var varchar)  RETURNS integer AS 
$BODY$

DECLARE     

v_usedmapattern boolean;

BEGIN

--  Search path
    SET search_path = "SCHEMA_NAME", public;

--  Get variables
    v_usedmapattern = (SELECT value FROM config_param_user WHERE parameter='inp_options_use_dma_pattern' AND cur_user=current_user);

-- Delete previous results on rpt_inp_node & arc tables
   DELETE FROM rpt_inp_node WHERE result_id=result_id_var;
   DELETE FROM rpt_inp_arc WHERE result_id=result_id_var;

-- Insert on node rpt_inp table
-- the strategy of selector_sector is not used for nodes. The reason is to enable the posibility to export the sector=-1. In addition using this it's impossible to export orphan nodes
	INSERT INTO rpt_inp_node (result_id, node_id, elevation, elev, node_type, nodecat_id, epa_type, sector_id, state, state_type, annotation, the_geom, expl_id)
	SELECT DISTINCT ON (v_node.node_id)
	result_id_var,
	v_node.node_id, elevation, elevation-depth as elev, nodetype_id, nodecat_id, epa_type, a.sector_id, v_node.state, v_node.state_type, v_node.annotation, v_node.the_geom, v_node.expl_id
	FROM node v_node 
		JOIN (SELECT node_1 AS node_id, sector_id FROM vi_parent_arc UNION SELECT node_2, sector_id FROM vi_parent_arc)a USING (node_id)
		JOIN cat_node c ON c.id=nodecat_id;
		
	UPDATE rpt_inp_node SET demand=inp_junction.demand, pattern_id=inp_junction.pattern_id FROM inp_junction WHERE rpt_inp_node.node_id=inp_junction.node_id AND result_id=result_id_var;


-- Insert on arc rpt_inp table
	INSERT INTO rpt_inp_arc (result_id, arc_id, node_1, node_2, arc_type, arccat_id, epa_type, sector_id, state, state_type, annotation, diameter, roughness, 
	length, status, the_geom, minorloss, expl_id)
	SELECT
	result_id_var,
	v_arc.arc_id, node_1, node_2, v_arc.arctype_id, arccat_id, epa_type, v_arc.sector_id, v_arc.state, v_arc.state_type, v_arc.annotation,
	CASE
		WHEN custom_dint IS NOT NULL THEN custom_dint
		ELSE dint
	END AS diameter, 
	CASE
		WHEN custom_roughness IS NOT NULL THEN custom_roughness
		ELSE roughness
	END AS roughness,
	length,
	CASE WHEN inp_pipe.status IS NULL THEN 'OPEN'
	ELSE inp_pipe.status END AS status,
	v_arc.the_geom,
	inp_pipe.minorloss,
	v_arc.expl_id
	FROM inp_selector_sector, v_arc
		LEFT JOIN value_state_type ON id=state_type
		LEFT JOIN cat_arc ON v_arc.arccat_id = cat_arc.id
		LEFT JOIN cat_mat_arc ON cat_arc.matcat_id = cat_mat_arc.id
		LEFT JOIN inp_pipe ON v_arc.arc_id = inp_pipe.arc_id
		LEFT JOIN inp_cat_mat_roughness ON inp_cat_mat_roughness.matcat_id = cat_mat_arc.id 
		WHERE (now()::date - (CASE WHEN builtdate IS NULL THEN '1900-01-01'::date ELSE builtdate END))/365 >= inp_cat_mat_roughness.init_age 
		AND (now()::date - (CASE WHEN builtdate IS NULL THEN '1900-01-01'::date ELSE builtdate END))/365 < inp_cat_mat_roughness.end_age
		AND ((is_operative IS TRUE) OR (is_operative IS NULL))
		AND v_arc.sector_id=inp_selector_sector.sector_id AND inp_selector_sector.cur_user=current_user;

    RETURN 1;
		
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;