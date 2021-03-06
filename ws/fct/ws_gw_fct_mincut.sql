/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2304
	
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_mincut( element_id_arg character varying, type_element_arg character varying, result_id_arg integer)
  RETURNS json AS
$BODY$

/*EXAMPLE
INSERT INTO SCHEMA_NAME.anl_mincut_result_cat VALUES (-1);
SELECT SCHEMA_NAME.gw_fct_mincut('25733', 'arc', -1)
*/

DECLARE
node_1_aux text;
node_2_aux text;
controlValue integer;
exists_id text;
polygon_aux public.geometry;
polygon_aux2 public.geometry;
arc_aux public.geometry;
node_aux public.geometry;    
srid_schema text;
expl_id_arg integer;
macroexpl_id_arg integer;
v_return json;
cont1 integer default 0;
v_publish_user text;
v_muni_id integer;
v_numarcs integer;
v_length double precision;
v_numconnecs integer;
v_numhydrometer integer;
v_debug Boolean;
v_overlap text;
v_geometry text;
v_data json;
v_volume float;
v_priority json;
v_count int2;
v_mincutversion integer;
v_mincutdetails	text;
v_output json;

BEGIN
    -- Search path
    SET search_path = SCHEMA_NAME, public;

    SELECT value::boolean INTO v_debug FROM config_param_system WHERE parameter='om_mincut_debug';
    SELECT value::int2 INTO v_mincutversion FROM config_param_system WHERE parameter='om_mincut_version';

    IF v_debug THEN
	RAISE NOTICE '1-Delete previous data from same result_id';
    END IF;
    DELETE FROM "anl_mincut_result_node" where result_id=result_id_arg;
    DELETE FROM "anl_mincut_result_arc" where result_id=result_id_arg;
    DELETE FROM "anl_mincut_result_polygon" where result_id=result_id_arg;
    DELETE FROM "anl_mincut_result_connec" where result_id=result_id_arg;
    DELETE FROM "anl_mincut_result_hydrometer" where result_id=result_id_arg; 
    DELETE FROM "anl_mincut_result_valve" where result_id=result_id_arg;

    IF v_debug THEN
	RAISE NOTICE '2-Identification exploitation, macroexploitation and municipality';
    END IF;
    IF type_element_arg='node' OR type_element_arg='NODE' THEN
		SELECT expl_id INTO expl_id_arg FROM node WHERE node_id=element_id_arg;
		SELECT muni_id INTO v_muni_id FROM node WHERE node_id=element_id_arg;
    ELSE
		SELECT expl_id INTO expl_id_arg FROM arc WHERE arc_id=element_id_arg;
		SELECT muni_id INTO v_muni_id FROM arc WHERE arc_id=element_id_arg;
    END IF;
    
    SELECT macroexpl_id INTO macroexpl_id_arg FROM exploitation WHERE expl_id=expl_id_arg;

    UPDATE anl_mincut_result_cat SET muni_id=v_muni_id WHERE id=result_id_arg;
    
    IF v_debug THEN
	RAISE NOTICE '3-Update user selectors';
    END IF; 

    -- set exploitation selector
    INSERT INTO selector_expl (expl_id, cur_user)
    SELECT expl_id, current_user from exploitation 
    where macroexpl_id=macroexpl_id_arg and expl_id not in (select expl_id from selector_expl);

    -- save state selector 
    DELETE FROM temp_table WHERE fprocesscat_id=99 AND user_name=current_user;
    INSERT INTO temp_table (fprocesscat_id, text_column)  
    SELECT 99, (array_agg(state_id)) FROM selector_state WHERE cur_user=current_user;

    -- save psector selector
    IF 'role_master' IN (SELECT rolname FROM pg_roles WHERE pg_has_role( current_user, oid, 'member')) THEN
	DELETE FROM selector_psector WHERE cur_user = current_user;
	DELETE FROM temp_table WHERE fprocesscat_id=287 AND user_name=current_user;
	INSERT INTO temp_table (fprocesscat_id, text_column)  
	SELECT 287, (array_agg(psector_id)) FROM selector_psector WHERE cur_user=current_user;
    END IF;
	
    -- set state selector
    DELETE FROM selector_state WHERE cur_user=current_user;
    INSERT INTO selector_state (state_id ,cur_user) VALUES (1, current_user);
	    
    IF v_debug THEN
	RAISE NOTICE '4-update values of mincut cat table';
    END IF;
    UPDATE anl_mincut_result_cat SET expl_id=expl_id_arg WHERE id=result_id_arg;
    UPDATE anl_mincut_result_cat SET macroexpl_id=macroexpl_id_arg WHERE id=result_id_arg;

    IF v_debug THEN
	RAISE NOTICE '5-Start mincut process';
    END IF;     
    INSERT INTO anl_mincut_result_valve (result_id, node_id, unaccess, closed, broken, the_geom) 
    SELECT result_id_arg, node.node_id, false::boolean, closed, broken, node.the_geom
    FROM v_anl_mincut_selected_valve
    JOIN node on node.node_id=v_anl_mincut_selected_valve.node_id
    JOIN exploitation ON node.expl_id=exploitation.expl_id
    WHERE macroexpl_id=macroexpl_id_arg;

    IF v_debug THEN
	RAISE NOTICE '6-Identify unaccess valves';
    END IF;
    UPDATE anl_mincut_result_valve SET unaccess=true, proposed = false WHERE result_id=result_id_arg AND node_id IN 
    (SELECT node_id FROM anl_mincut_result_valve_unaccess WHERE result_id=result_id_arg);

     -- The element to isolate could be an arc or a node
    IF type_element_arg = 'arc' OR type_element_arg='ARC' THEN
	
		IF (SELECT state FROM arc WHERE (arc_id = element_id_arg))=0 THEN
			PERFORM audit_function(3002,2304,element_id_arg);
		END IF;
		
        -- Check an existing arc
        SELECT COUNT(*) INTO controlValue FROM v_edit_arc JOIN value_state_type ON state_type=value_state_type.id 
        WHERE (arc_id = element_id_arg) AND (is_operative IS TRUE);
		
        IF controlValue = 1 THEN
	
		-- Select public.geometry
		SELECT the_geom INTO arc_aux FROM v_edit_arc WHERE arc_id = element_id_arg;

		-- call engine to determinate the isolated area
		IF v_mincutversion = 4 OR v_mincutversion = 5 THEN
		
			-- call graf analytics function (step:1)
			v_data = concat ('{"data":{"grafClass":"MINCUT", "arc":"', element_id_arg ,'", "step":1, "parameters":{"id":', result_id_arg, '}}}');
			RAISE NOTICE 'v_data MINCUT %', v_data;
			PERFORM gw_fct_grafanalytics_mincut(v_data);
		
		ELSIF v_mincutversion = 3 THEN
		
			-- insert the initial arc
			INSERT INTO anl_mincut_result_arc (arc_id, the_geom, result_id) 
			SELECT arc_id, the_geom, result_id_arg FROM arc WHERE arc_id = element_id_arg;
 	
			-- Run for extremes node
			SELECT node_1, node_2 INTO node_1_aux, node_2_aux FROM v_edit_arc WHERE arc_id = element_id_arg;

			IF node_1_aux IS NULL OR node_2_aux IS NULL THEN
				PERFORM audit_function(3006,2304);
			END IF;
    

			-- Check extreme being a valve
			SELECT COUNT(*) INTO controlValue FROM anl_mincut_result_valve 
			WHERE node_id = node_1_aux AND result_id=result_id_arg AND ((unaccess = FALSE AND broken = FALSE) OR (closed = TRUE));

			IF controlValue = 1 THEN
				-- Set proposed valve
				UPDATE anl_mincut_result_valve SET proposed = TRUE WHERE node_id=node_1_aux AND result_id=result_id_arg;
				
			ELSE
				-- Check if extreme if being a inlet
				SELECT COUNT(*) INTO controlValue FROM anl_mincut_inlet_x_exploitation WHERE node_id = node_1_aux;
			
				IF controlValue = 0 THEN
					-- Compute the tributary area using DFS
					PERFORM gw_fct_mincut_engine(node_1_aux, result_id_arg);	
				ELSE
					SELECT the_geom INTO node_aux FROM v_edit_node WHERE node_id = node_1_aux;
					INSERT INTO anl_mincut_result_node (node_id, the_geom, result_id) VALUES (node_1_aux, node_aux, result_id_arg);	
				END IF;
			END IF;

			-- Check other extreme being a valve
			SELECT COUNT(*) INTO controlValue FROM anl_mincut_result_valve 
			WHERE node_id = node_2_aux AND result_id=result_id_arg AND ((unaccess = FALSE AND broken = FALSE) OR (closed = TRUE));
			IF controlValue = 1 THEN

				-- Check if the valve is already computed
				SELECT node_id INTO exists_id FROM anl_mincut_result_valve 
				WHERE node_id = node_2_aux AND (proposed = TRUE) AND result_id=result_id_arg;
	
				-- Compute proceed
				IF NOT FOUND THEN
					-- Set proposed valve
					UPDATE anl_mincut_result_valve SET proposed = TRUE 
					WHERE node_id=node_2_aux AND result_id=result_id_arg;
				END IF;
			ELSE
				-- Check if extreme if being a inlet
				SELECT COUNT(*) INTO controlValue FROM anl_mincut_inlet_x_exploitation WHERE node_id = node_2_aux;
				IF controlValue = 0 THEN
					-- Compute the tributary area using DFS
					PERFORM gw_fct_mincut_engine(node_2_aux, result_id_arg);	
				ELSE 
					SELECT the_geom INTO node_aux FROM v_edit_node WHERE node_id = node_2_aux;
					INSERT INTO anl_mincut_result_node (node_id, the_geom, result_id) VALUES(node_2_aux, node_aux, result_id_arg);		
				END IF;	
			END IF;
			
		END IF;
		
		-- The arc_id was not found
		ELSE 
			PERFORM audit_function(1082,2304,element_id_arg);
		END IF;

    ELSE
		RAISE EXCEPTION 'Only arc is avaliable to execute a mincut';
    END IF;

	IF v_debug THEN	RAISE NOTICE '7-Compute flow trace on network';	END IF;	
	
	SELECT gw_fct_mincut_inverted_flowtrace(result_id_arg) into cont1;

	IF v_debug THEN RAISE NOTICE '8-Delete valves not proposed, not unaccessible, not closed and not broken'; END IF;
	
	DELETE FROM anl_mincut_result_valve WHERE node_id NOT IN (SELECT node_1 FROM arc JOIN anl_mincut_result_arc ON anl_mincut_result_arc.arc_id=arc.arc_id 
					WHERE result_id=result_id_arg UNION 
					SELECT node_2 FROM arc JOIN anl_mincut_result_arc ON anl_mincut_result_arc.arc_id=arc.arc_id WHERE result_id=result_id_arg)
					AND result_id=result_id_arg;
					
	UPDATE anl_mincut_result_valve SET proposed = FALSE WHERE closed = TRUE AND result_id=result_id_arg ;


	IF v_debug THEN	RAISE NOTICE '10-Update mincut selector'; END IF;
	
	--    Update the selector
	-- current user
	DELETE FROM anl_mincut_result_selector WHERE result_id = result_id_arg AND cur_user = current_user;
	INSERT INTO anl_mincut_result_selector(cur_user, result_id) VALUES (current_user, result_id_arg);

	-- publish user
	SELECT value FROM config_param_system WHERE parameter='api_publish_user' INTO v_publish_user;
	
	IF v_publish_user IS NOT NULL THEN
		DELETE FROM anl_mincut_result_selector WHERE result_id = result_id_arg AND cur_user = v_publish_user;
		INSERT INTO anl_mincut_result_selector(cur_user, result_id) VALUES (v_publish_user, result_id_arg);
	END IF;	
	
	IF v_debug THEN	RAISE NOTICE '11-Insert into anl_mincut_result_connec table ';	END IF;			
	
	INSERT INTO anl_mincut_result_connec (result_id, connec_id, the_geom)
	SELECT result_id_arg, connec_id, connec.the_geom FROM connec JOIN anl_mincut_result_arc ON connec.arc_id=anl_mincut_result_arc.arc_id WHERE result_id=result_id_arg AND state=1;

	IF v_debug THEN RAISE NOTICE '12-Insert into anl_mincut_result_hydrometer table ';	END IF;
	
	INSERT INTO anl_mincut_result_hydrometer (result_id, hydrometer_id)
	SELECT result_id_arg,rtc_hydrometer_x_connec.hydrometer_id FROM rtc_hydrometer_x_connec 
	JOIN anl_mincut_result_connec ON rtc_hydrometer_x_connec.connec_id=anl_mincut_result_connec.connec_id 
	LEFT JOIN v_rtc_hydrometer ON v_rtc_hydrometer.hydrometer_id=rtc_hydrometer_x_connec.hydrometer_id
	WHERE result_id=result_id_arg;

	-- Insert hazard values on audit_log_data table
	-- count arcs
	SELECT count(arc_id), sum(st_length(arc.the_geom))::numeric(12,2) INTO v_numarcs, v_length FROM anl_mincut_result_arc JOIN arc USING (arc_id) WHERE result_id=result_id_arg group by result_id;
	SELECT sum(area*st_length(arc.the_geom))::numeric(12,2) INTO v_volume FROM anl_mincut_result_arc JOIN arc USING (arc_id) JOIN cat_arc ON arccat_id=cat_arc.id WHERE result_id=result_id_arg group by result_id, arccat_id;

	-- count connec
	SELECT count(connec_id) INTO v_numconnecs FROM connec JOIN anl_mincut_result_arc ON connec.arc_id=anl_mincut_result_arc.arc_id WHERE result_id=result_id_arg AND state=1;

	-- count hydrometers
	SELECT count (rtc_hydrometer_x_connec.hydrometer_id) INTO v_numhydrometer FROM rtc_hydrometer_x_connec JOIN anl_mincut_result_connec ON rtc_hydrometer_x_connec.connec_id=anl_mincut_result_connec.connec_id 
	JOIN v_rtc_hydrometer ON v_rtc_hydrometer.hydrometer_id=rtc_hydrometer_x_connec.hydrometer_id
	JOIN connec ON connec.connec_id=v_rtc_hydrometer.connec_id WHERE result_id=result_id_arg;

	-- priority hydrometers
	v_priority = 	(SELECT (array_to_json(array_agg((b)))) FROM (SELECT concat('{"category":"',category_id,'","number":"', count(rtc_hydrometer_x_connec.hydrometer_id), '"}')::json as b FROM rtc_hydrometer_x_connec 
			JOIN anl_mincut_result_connec ON rtc_hydrometer_x_connec.connec_id=anl_mincut_result_connec.connec_id 
			JOIN v_rtc_hydrometer ON v_rtc_hydrometer.hydrometer_id=rtc_hydrometer_x_connec.hydrometer_id
			JOIN connec ON connec.connec_id=v_rtc_hydrometer.connec_id WHERE result_id=result_id_arg GROUP BY category_id ORDER BY category_id)a);
				
	IF v_priority IS NULL THEN v_priority='{}'; END IF;
	
	v_mincutdetails = (concat('"minsector_id":"',element_id_arg,'","arcs":{"number":"',v_numarcs,'", "length":"',v_length,'", "volume":"', 
	v_volume, '"}, "connecs":{"number":"',v_numconnecs,'","hydrometers":{"total":"',v_numhydrometer,'","classified":',v_priority,'}}'));

	v_output = concat ('{', v_mincutdetails , '}');
			
	INSERT INTO audit_log_data (fprocesscat_id, feature_type, feature_id, log_message) VALUES (29, 'arc', element_id_arg, v_output);

	--update output results
	UPDATE anl_mincut_result_cat SET output = v_output WHERE id = result_id_arg;

	-- calculate the boundary of mincut using arcs and valves
	EXECUTE ' SELECT st_astext(st_envelope(st_extent(st_buffer(the_geom,20)))) FROM (SELECT the_geom FROM anl_mincut_result_arc WHERE result_id='||result_id_arg||
		' UNION SELECT the_geom FROM anl_mincut_result_valve WHERE result_id='||result_id_arg||') a'    
	        INTO v_geometry;

	RAISE NOTICE 'v_output %', v_output;
			
	-- restore state selector
	INSERT INTO selector_state (state_id, cur_user)
	select unnest(text_column::integer[]), current_user from temp_table where fprocesscat_id=99 and user_name=current_user
	ON CONFLICT (state_id, cur_user) DO NOTHING;
	
	-- restore psector selector
	IF 'role_master' IN (SELECT rolname FROM pg_roles WHERE pg_has_role( current_user, oid, 'member')) THEN
		INSERT INTO selector_psector (psector_id, cur_user)
		select unnest(text_column::integer[]), current_user from temp_table where fprocesscat_id=287 and user_name=current_user
		ON CONFLICT (psector_id, cur_user) DO NOTHING;
	END IF;

	-- returning
	v_return = concat('{"mincutOverlap":"',v_overlap,'", "geometry":"',v_geometry,'",', v_mincutdetails, '}');

	IF v_debug THEN RAISE NOTICE 'End of process ';	END IF;
	
	RETURN v_return;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



