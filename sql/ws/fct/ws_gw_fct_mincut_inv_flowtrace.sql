﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2320

DROP FUNCTION IF EXISTS ws.gw_fct_mincut_inverted_flowtrace(integer);
CREATE OR REPLACE FUNCTION ws.gw_fct_mincut_inverted_flowtrace(result_id_arg integer)
RETURNS integer AS
$BODY$
DECLARE

rec_valve 	record;
rec_tank	record;
mincut_rec	record;
exists_id      	text;
arc_aux    	public.geometry;
polygon_aux2   	public.geometry;
node_aux      	public.geometry;    
rec_table      	record;
rec_result 	record;
first_row      	boolean;
inlet_path      boolean;
element_id_arg  varchar(16);
controlValue	smallint;
node_1_aux	varchar(16);
node_2_aux	varchar(16);

BEGIN

    -- Search path
    SET search_path = "ws", public;
    inlet_path=true;

    -- starting process
    SELECT * INTO mincut_rec FROM anl_mincut_result_cat WHERE id=result_id_arg;

    -- Delete previous data from same result_id
  --  DELETE FROM "anl_mincut_result_node" where result_id=result_id_arg;
   -- DELETE FROM "anl_mincut_result_arc" where result_id=result_id_arg;
   DELETE FROM "anl_mincut_result_polygon" where result_id=result_id_arg;
   -- DELETE FROM "anl_mincut_result_connec" where result_id=result_id_arg;
   -- DELETE FROM "anl_mincut_result_hydrometer" where result_id=result_id_arg; 


    -- Loop for all the proposed valves
    FOR rec_valve IN SELECT node_id FROM anl_mincut_result_valve WHERE result_id=result_id_arg AND proposed=TRUE
    LOOP
	FOR rec_tank IN SELECT v_edit_node.node_id, v_edit_node.the_geom FROM v_edit_node 
	JOIN value_state_type ON state_type=value_state_type.id JOIN node_type ON node_type.id=nodetype_id
	JOIN exploitation ON v_edit_node.expl_id=exploitation.expl_id
	WHERE ( type='TANK' OR type = 'SOURCE') AND (is_operative IS TRUE) AND (macroexpl_id=mincut_rec.macroexpl_id) AND v_edit_node.the_geom IS NOT NULL
	ORDER BY 1
	LOOP
		SELECT * INTO rec_result FROM pgr_dijkstra(

		'SELECT v_edit_arc.arc_id::integer as id, node_1::integer as source, node_2::integer as target, 
		(case when closed=true then 0 else 1 end) as cost,
		(case when closed=true then 0 else 1 end) as reverse_cost
		FROM ws.v_edit_arc 
		JOIN ws.exploitation ON v_edit_arc.expl_id=exploitation.expl_id 
		LEFT JOIN (
		select arc_id, true as closed FROM ws.v_edit_arc 
		JOIN ws.exploitation ON v_edit_arc.expl_id=exploitation.expl_id 
		where macroexpl_id=1
		and ( node_1 IN (select node_id FROM ws.anl_mincut_result_valve WHERE closed IS TRUE and result_id=1) or node_2 
		IN (select node_id FROM ws.anl_mincut_result_valve WHERE closed IS TRUE and result_id=result_id_arg)))a
		ON a.arc_id=v_edit_arc.arc_id
		where macroexpl_id=1 AND (node_1 is not null or node_2 is not null)'
		,rec_valve.node_id, rec_tank.node_id);

		IF rec_result IS NOT NULL THEN
			EXIT;
		ELSE 
			inlet_path=false;
		END IF;
			
	END LOOP;

	IF inlet_path IS FALSE THEN
	
		--Finding additional affectations
		SELECT INTO element_id_arg FROM v_edit_arc WHERE (node_1=rec_valve.node_id OR node_2=rec_valve.node_id) 
		AND arc_id NOT IN (SELECT arc_id FROM anl_mincut_result_arc WHERE result_id=result_id_arg);
		
		SELECT COUNT(*) INTO controlValue FROM v_edit_arc JOIN value_state_type ON state_type=value_state_type.id 
		WHERE (arc_id = element_id_arg) AND (is_operative IS TRUE);
		IF controlValue = 1 THEN

			-- Select public.geometry
			SELECT the_geom INTO arc_aux FROM v_edit_arc WHERE arc_id = element_id_arg;
	
			-- Insert arc id
			INSERT INTO "anl_mincut_result_arc" (arc_id, the_geom, result_id) VALUES (element_id_arg, arc_aux, result_id_arg);
		
			-- Run for extremes node
			SELECT node_1, node_2 INTO node_1_aux, node_2_aux FROM v_edit_arc WHERE arc_id = element_id_arg;
	
			-- Check extreme being a closed valve
			SELECT COUNT(*) INTO controlValue FROM anl_mincut_result_valve 
			WHERE node_id = node_1_aux AND ((closed=TRUE) OR (proposed=TRUE)) AND result_id=result_id_arg;
			IF controlValue = 0 THEN
				-- Compute the tributary area using DFS
				PERFORM gw_fct_mincut_inverted_flowtrace_engine(node_1_aux, result_id_arg);
			END IF;
	
			-- Check other extreme being a closed valve
			SELECT COUNT(*) INTO controlValue FROM anl_mincut_result_valve 
			WHERE node_id = node_2_aux AND ((closed=TRUE) OR (proposed=TRUE)) AND result_id=result_id_arg;
			IF controlValue = 1 THEN
					-- Compute the tributary area using DFS
				PERFORM gw_fct_mincut_inverted_flowtrace_engine(node_2_aux, result_id_arg);
			END IF;

		END IF;
	
		--Valve has no exit. Update proposed value
		UPDATE ws.anl_mincut_result_valve SET proposed=FALSE WHERE result_id=result_id_arg AND node_id=rec_valve.node_id;
		
	END IF;
			
    END LOOP;
	

   
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;