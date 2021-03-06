/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2316

DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_pg2epa_nod2arc(varchar);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_pg2epa_nod2arc(result_id_var varchar, p_only_mandatory_nodarc boolean)  RETURNS integer 
AS $BODY$

/*example
select SCHEMA_NAME.gw_fct_pg2epa_nod2arc ('testbgeo3', true)
*/

DECLARE
	record_node SCHEMA_NAME.rpt_inp_node%ROWTYPE;
	record_arc1 SCHEMA_NAME.rpt_inp_arc%ROWTYPE;
	record_arc2 SCHEMA_NAME.rpt_inp_arc%ROWTYPE;
	record_new_arc SCHEMA_NAME.rpt_inp_arc%ROWTYPE;
	node_diameter double precision;
	valve_arc_geometry geometry;
	valve_arc_node_1_geom geometry;
	valve_arc_node_2_geom geometry;
	arc_reduced_geometry geometry;
	node_id_aux text;
	num_arcs integer;
	shortpipe_record record;
	to_arc_aux text;
	arc_id_aux text;
	error_var text;
	v_nod2arc float;
	v_query_text text;
	v_arcsearchnodes float;
	v_status text;
	v_nodarc_min float;
	v_count integer = 1;
	v_buildupmode int2 = 2;

BEGIN

	--  Search path
	SET search_path = "SCHEMA_NAME", public;


	SELECT value INTO v_buildupmode FROM config_param_user WHERE parameter = 'inp_options_buildup_mode' AND cur_user=current_user;


	--  Looking for nodarc values
	SELECT min(st_length(the_geom)) FROM rpt_inp_arc JOIN inp_selector_sector ON inp_selector_sector.sector_id=rpt_inp_arc.sector_id WHERE result_id=result_id_var
		INTO v_nodarc_min;

	v_nod2arc := (SELECT value::float FROM config_param_user WHERE parameter = 'inp_options_nodarc_length' and cur_user=current_user limit 1)::float;
	IF v_nod2arc is null then 
		v_nod2arc = 0.3;
	END IF;
	
	IF v_nod2arc > v_nodarc_min-0.01 THEN
		v_nod2arc = v_nodarc_min-0.01;
	END IF;

	v_arcsearchnodes := 0.1;
    
	--  Move valves to arc
	RAISE NOTICE 'Start loop.....';

	-- taking nod2arcs with less than two arcs
	DELETE FROM anl_node WHERE fprocesscat_id=67 and cur_user=current_user;
	INSERT INTO anl_node (fprocesscat_id, node_id, nodecat_id, the_geom, descript)
	SELECT 67, a.node_id, a.nodecat_id, a.the_geom, 'Node2arc with less than two arcs' FROM (
		SELECT node_id, nodecat_id, v_edit_node.the_geom FROM v_edit_node JOIN v_edit_arc a1 ON node_id=a1.node_1
		WHERE v_edit_node.epa_type IN ('SHORTPIPE', 'VALVE', 'PUMP') AND a1.sector_id IN (SELECT sector_id FROM inp_selector_sector WHERE cur_user=current_user)
			UNION ALL
		SELECT node_id, nodecat_id, v_edit_node.the_geom FROM v_edit_node JOIN v_edit_arc a1 ON node_id=a1.node_2
		WHERE v_edit_node.epa_type IN ('SHORTPIPE', 'VALVE', 'PUMP') AND a1.sector_id IN (SELECT sector_id FROM inp_selector_sector WHERE cur_user=current_user))a
	GROUP by node_id, nodecat_id, the_geom
	HAVING count(*) < 2;


	IF v_buildupmode = 1 THEN

		-- taking nod2arcs with more than two arcs
		DELETE FROM anl_node WHERE fprocesscat_id=66 and cur_user=current_user;
		INSERT INTO anl_node (fprocesscat_id, node_id, nodecat_id, the_geom, descript)
		SELECT 66, a.node_id, a.nodecat_id, a.the_geom, 'Node2arc with more than two arcs' FROM (
			SELECT node_id, nodecat_id, v_edit_node.the_geom FROM v_edit_node JOIN v_edit_arc a1 ON node_id=a1.node_1
			WHERE v_edit_node.epa_type IN ('SHORTPIPE', 'VALVE', 'PUMP') AND a1.sector_id IN (SELECT sector_id FROM inp_selector_sector WHERE cur_user=current_user)
			UNION ALL
			SELECT node_id, nodecat_id, v_edit_node.the_geom FROM v_edit_node JOIN v_edit_arc a1 ON node_id=a1.node_2
			WHERE v_edit_node.epa_type IN ('SHORTPIPE', 'VALVE', 'PUMP') AND a1.sector_id IN (SELECT sector_id FROM inp_selector_sector WHERE cur_user=current_user))a
		GROUP by node_id, nodecat_id, the_geom
		HAVING count(*) > 2;
	
		v_query_text = 'SELECT a.node_id FROM rpt_inp_node a JOIN inp_valve ON a.node_id=inp_valve.node_id WHERE result_id='||quote_literal(result_id_var)||'
				AND a.node_id NOT IN (SELECT node_id FROM anl_node WHERE fprocesscat_id IN (66,67) and cur_user=current_user) UNION 
				SELECT a.node_id FROM rpt_inp_node a JOIN inp_pump ON a.node_id=inp_pump.node_id WHERE result_id='||quote_literal(result_id_var)||'
				AND a.node_id NOT IN (SELECT node_id FROM anl_node WHERE fprocesscat_id IN (66,67) and cur_user=current_user) UNION 
				SELECT a.node_id FROM rpt_inp_node a JOIN inp_shortpipe ON a.node_id=inp_shortpipe.node_id WHERE result_id='||quote_literal(result_id_var)||
				' AND to_arc IS NOT NULL AND a.node_id NOT IN (SELECT node_id FROM anl_node WHERE fprocesscat_id IN (66,67) and cur_user=current_user)';

	ELSIF v_buildupmode > 1 AND p_only_mandatory_nodarc THEN
		v_query_text = 'SELECT a.node_id FROM rpt_inp_node a JOIN inp_valve ON a.node_id=inp_valve.node_id WHERE result_id='||quote_literal(result_id_var)||' 
				AND a.node_id NOT IN (SELECT node_id FROM anl_node WHERE fprocesscat_id IN (67) and cur_user=current_user) UNION  
				SELECT a.node_id FROM rpt_inp_node a JOIN inp_pump ON a.node_id=inp_pump.node_id WHERE result_id='||quote_literal(result_id_var)||' 
				AND a.node_id NOT IN (SELECT node_id FROM anl_node WHERE fprocesscat_id IN (67) and cur_user=current_user) UNION 
				SELECT a.node_id FROM rpt_inp_node a JOIN inp_shortpipe ON a.node_id=inp_shortpipe.node_id WHERE result_id='||quote_literal(result_id_var)||
				' AND to_arc IS NOT NULL AND a.node_id NOT IN (SELECT node_id FROM anl_node WHERE fprocesscat_id IN (67) and cur_user=current_user)';
			
	ELSIF v_buildupmode > 1 AND p_only_mandatory_nodarc IS FALSE THEN
		v_query_text = 'SELECT a.node_id FROM rpt_inp_node a JOIN inp_valve ON a.node_id=inp_valve.node_id WHERE result_id ='||quote_literal(result_id_var)||' 
				 AND a.node_id NOT IN (SELECT node_id FROM anl_node WHERE fprocesscat_id IN (67) and cur_user=current_user) UNION 
				SELECT a.node_id FROM rpt_inp_node a JOIN inp_pump ON a.node_id=inp_pump.node_id WHERE result_id ='||quote_literal(result_id_var)||' 
				 AND a.node_id NOT IN (SELECT node_id FROM anl_node WHERE fprocesscat_id IN (67) and cur_user=current_user) UNION 
				SELECT a.node_id FROM rpt_inp_node a JOIN inp_shortpipe ON a.node_id=inp_shortpipe.node_id WHERE result_id ='||quote_literal(result_id_var)||'
				 AND a.node_id NOT IN (SELECT node_id FROM anl_node WHERE fprocesscat_id IN (67) and cur_user=current_user)';
	END IF;

    FOR node_id_aux IN EXECUTE v_query_text
    LOOP
    
	v_count = v_count + 1;
	
        -- Get node data
	SELECT * INTO record_node FROM rpt_inp_node WHERE node_id = node_id_aux AND result_id=result_id_var;

        -- Get arc data
        SELECT COUNT(*) INTO num_arcs FROM rpt_inp_arc WHERE (node_1 = node_id_aux OR node_2 = node_id_aux) AND result_id=result_id_var;

        -- Get arcs
        SELECT * INTO record_arc1 FROM rpt_inp_arc WHERE node_1 = node_id_aux AND result_id=result_id_var;
        SELECT * INTO record_arc2 FROM rpt_inp_arc WHERE node_2 = node_id_aux AND result_id=result_id_var;


        -- Just 1 arcs
        IF num_arcs = 1 THEN

            -- Compute valve geometry
            IF record_arc2 ISNULL THEN

                -- Use arc 1 as reference
                record_new_arc = record_arc1;
    
                -- TODO: Control pipe shorter than 0.5 m!
                valve_arc_node_1_geom := ST_StartPoint(record_arc1.the_geom);
                valve_arc_node_2_geom := ST_LineInterpolatePoint(record_arc1.the_geom, v_nod2arc / ST_Length(record_arc1.the_geom));

                -- Correct arc geometry
                arc_reduced_geometry := ST_LineSubstring(record_arc1.the_geom,ST_LineLocatePoint(record_arc1.the_geom,valve_arc_node_2_geom),1);
       		IF ST_GeometryType(arc_reduced_geometry) != 'ST_LineString' THEN
			error_var = concat(record_arc1.arc_id,',',ST_GeometryType(arc_reduced_geometry));
			PERFORM audit_function(2022,2316,error_var);
		END IF;    
		UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_1 = (SELECT concat(node_id_aux, '_n2a_2')) WHERE arc_id = record_arc1.arc_id AND result_id=result_id_var; 
 	    
            ELSIF record_arc1 ISNULL THEN
 
                -- Use arc 2 as reference
                record_new_arc = record_arc2;

                valve_arc_node_2_geom := ST_EndPoint(record_arc2.the_geom);
                valve_arc_node_1_geom := ST_LineInterpolatePoint(record_arc2.the_geom, 1 - v_nod2arc / ST_Length(record_arc2.the_geom));

                -- Correct arc geometry
                arc_reduced_geometry := ST_LineSubstring(record_arc2.the_geom,0,ST_LineLocatePoint(record_arc2.the_geom,valve_arc_node_1_geom));
		IF ST_GeometryType(arc_reduced_geometry) != 'ST_LineString' THEN
			error_var = concat(record_arc1.arc_id,',',ST_GeometryType(arc_reduced_geometry));
			PERFORM audit_function(2022,2316,error_var);
		END IF;
                UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_2 = (SELECT concat(node_id_aux, '_n2a_1')) WHERE arc_id = record_arc2.arc_id AND result_id=result_id_var;

            END IF;

        -- Two arcs
        ELSIF num_arcs = 2 THEN

            -- Two 'node_2' arcs
            IF record_arc1 ISNULL THEN

                -- Get arcs
                SELECT * INTO record_arc2 FROM rpt_inp_arc WHERE node_2 = node_id_aux AND result_id=result_id_var ORDER BY arc_id DESC LIMIT 1;
                SELECT * INTO record_arc1 FROM rpt_inp_arc WHERE node_2 = node_id_aux AND result_id=result_id_var ORDER BY arc_id ASC LIMIT 1;

                -- Use arc 1 as reference (TODO: Why?)
                record_new_arc = record_arc1;
    
                -- TODO: Control pipe shorter than 0.5 m!
                valve_arc_node_1_geom := ST_LineInterpolatePoint(record_arc2.the_geom, 1 - v_nod2arc / ST_Length(record_arc2.the_geom) / 2);
                valve_arc_node_2_geom := ST_LineInterpolatePoint(record_arc1.the_geom, 1 - v_nod2arc / ST_Length(record_arc1.the_geom) / 2);

                -- Correct arc geometry
                arc_reduced_geometry := ST_LineSubstring(record_arc1.the_geom,0,ST_LineLocatePoint(record_arc1.the_geom,valve_arc_node_2_geom));
		IF ST_GeometryType(arc_reduced_geometry) != 'ST_LineString' THEN
			error_var = concat(record_arc1.arc_id,',',ST_GeometryType(arc_reduced_geometry));
			PERFORM audit_function(2022,2316,error_var);
		END IF;
                UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_2 = (SELECT concat(node_id_aux, '_n2a_2')) WHERE a.arc_id = record_arc1.arc_id AND result_id=result_id_var; 

                arc_reduced_geometry := ST_LineSubstring(record_arc2.the_geom,0,ST_LineLocatePoint(record_arc2.the_geom,valve_arc_node_1_geom));
		IF ST_GeometryType(arc_reduced_geometry) != 'ST_LineString' THEN
			error_var = concat(record_arc1.arc_id,',',ST_GeometryType(arc_reduced_geometry));
			PERFORM audit_function(2022,2316,error_var);
		END IF;
                UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_2 = (SELECT concat(node_id_aux, '_n2a_1')) WHERE a.arc_id = record_arc2.arc_id AND result_id=result_id_var;


            -- Two 'node_1' arcs
            ELSIF record_arc2 ISNULL THEN

                -- Get arcs
                SELECT * INTO record_arc1 FROM rpt_inp_arc WHERE node_1 = node_id_aux AND result_id=result_id_var ORDER BY arc_id DESC LIMIT 1;
                SELECT * INTO record_arc2 FROM rpt_inp_arc WHERE node_1 = node_id_aux AND result_id=result_id_var ORDER BY arc_id ASC LIMIT 1;

                -- Use arc 1 as reference (TODO: Why?)
                record_new_arc = record_arc1;
    
                -- TODO: Control arc shorter than 0.5 m!
                valve_arc_node_1_geom := ST_LineInterpolatePoint(record_arc2.the_geom, v_nod2arc / ST_Length(record_arc2.the_geom) / 2);
                valve_arc_node_2_geom := ST_LineInterpolatePoint(record_arc1.the_geom, v_nod2arc / ST_Length(record_arc1.the_geom) / 2);

                -- Correct arc geometry
                arc_reduced_geometry := ST_LineSubstring(record_arc1.the_geom,ST_LineLocatePoint(record_arc1.the_geom,valve_arc_node_2_geom),1);
		IF ST_GeometryType(arc_reduced_geometry) != 'ST_LineString' THEN
			error_var = concat(record_arc1.arc_id,',',ST_GeometryType(arc_reduced_geometry));
			PERFORM audit_function(2022,2316,error_var);
		END IF;
                UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_1 = (SELECT concat(node_id_aux, '_n2a_2')) WHERE a.arc_id = record_arc1.arc_id AND result_id=result_id_var; 

                arc_reduced_geometry := ST_LineSubstring(record_arc2.the_geom,ST_LineLocatePoint(record_arc2.the_geom,valve_arc_node_1_geom),1);
		IF ST_GeometryType(arc_reduced_geometry) != 'ST_LineString' THEN
			error_var = concat(record_arc1.arc_id,',',ST_GeometryType(arc_reduced_geometry));
			PERFORM audit_function(2022,2316,error_var);
		END IF;
                UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_1 = (SELECT concat(node_id_aux, '_n2a_1')) WHERE a.arc_id = record_arc2.arc_id AND result_id=result_id_var;
                        

            -- One 'node_1' and one 'node_2'
            ELSE

                -- Use arc 1 as reference (TODO: Why?)
                record_new_arc = record_arc1;

		-- control pipes
                IF ST_Length(record_arc2.the_geom)/2 < v_nod2arc OR ST_Length(record_arc1.the_geom)/2 <  v_nod2arc THEN
			RAISE EXCEPTION 'It''s impossible to continue. Nodarc % has close pipes with length:( %, % ) versus nodarc length ( % )', node_id_aux, ST_Length(record_arc2.the_geom), ST_Length(record_arc1.the_geom),v_nod2arc ;
                END IF;
    
                valve_arc_node_1_geom := ST_LineInterpolatePoint(record_arc2.the_geom, 1 - v_nod2arc / ST_Length(record_arc2.the_geom) / 2);
                valve_arc_node_2_geom := ST_LineInterpolatePoint(record_arc1.the_geom, v_nod2arc / ST_Length(record_arc1.the_geom) / 2);

                -- Correct arc geometry
                arc_reduced_geometry := ST_LineSubstring(record_arc1.the_geom,ST_LineLocatePoint(record_arc1.the_geom,valve_arc_node_2_geom),1);
		IF ST_GeometryType(arc_reduced_geometry) != 'ST_LineString' THEN
			error_var = concat(record_arc1.arc_id,',',ST_GeometryType(arc_reduced_geometry));
			PERFORM audit_function(2022,2316,error_var);
		END IF;
                UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_1 = (SELECT concat(a.node_1, '_n2a_2')) WHERE a.arc_id = record_arc1.arc_id AND result_id=result_id_var; 

                arc_reduced_geometry := ST_LineSubstring(record_arc2.the_geom,0,ST_LineLocatePoint(record_arc2.the_geom,valve_arc_node_1_geom));
		IF ST_GeometryType(arc_reduced_geometry) != 'ST_LineString' THEN
			error_var = concat(record_arc1.arc_id,',',ST_GeometryType(arc_reduced_geometry));
			PERFORM audit_function(2022,2316,error_var);
		END IF;
                UPDATE rpt_inp_arc AS a SET the_geom = arc_reduced_geometry, node_2 = (SELECT concat(a.node_2, '_n2a_1')) WHERE a.arc_id = record_arc2.arc_id AND result_id=result_id_var;
                        
            END IF;

        -- num_arcs 0 or > 2
        ELSE

            CONTINUE;
                        
        END IF;

        -- Create new arc geometry
        valve_arc_geometry := ST_MakeLine(valve_arc_node_1_geom, valve_arc_node_2_geom);

        -- Values to insert into arc table
        record_new_arc.arc_id := concat(node_id_aux, '_n2a');   
	record_new_arc.arccat_id := record_node.nodecat_id;
	record_new_arc.epa_type := record_node.epa_type;
        record_new_arc.sector_id := record_node.sector_id;
        record_new_arc.state := record_node.state;
        record_new_arc.state_type := record_node.state_type;
        record_new_arc.annotation := record_node.annotation;
        record_new_arc.length := ST_length2d(valve_arc_geometry);
        record_new_arc.the_geom := valve_arc_geometry;
        

        -- Identifing and updating (if it's needed) the right direction
	SELECT to_arc,status INTO to_arc_aux, v_status FROM (SELECT node_id,to_arc,status FROM inp_valve UNION SELECT node_id,to_arc,status FROM inp_shortpipe UNION 
								SELECT node_id,to_arc,status FROM inp_pump) a WHERE node_id=node_id_aux;

	SELECT arc_id INTO arc_id_aux FROM rpt_inp_arc WHERE (ST_DWithin(ST_endpoint(record_new_arc.the_geom), rpt_inp_arc.the_geom, v_arcsearchnodes)) AND result_id=result_id_var
			ORDER BY ST_Distance(rpt_inp_arc.the_geom, ST_endpoint(record_new_arc.the_geom)) LIMIT 1;

	IF arc_id_aux=to_arc_aux THEN
		record_new_arc.node_1 := concat(node_id_aux, '_n2a_1');
		record_new_arc.node_2 := concat(node_id_aux, '_n2a_2');
	ELSE
		record_new_arc.node_2 := concat(node_id_aux, '_n2a_1');
		record_new_arc.node_1 := concat(node_id_aux, '_n2a_2');
		record_new_arc.the_geom := st_reverse(record_new_arc.the_geom);
	END IF; 


        -- Inserting new arc into arc table
        INSERT INTO rpt_inp_arc (result_id, arc_id, node_1, node_2, arc_type, arccat_id, epa_type, sector_id, state, state_type, diameter, roughness, annotation, length, status, the_geom)
	VALUES(result_id_var, record_new_arc.arc_id, record_new_arc.node_1, record_new_arc.node_2, 'NODE2ARC', record_new_arc.arccat_id, record_new_arc.epa_type, record_new_arc.sector_id, 
	record_new_arc.state, record_new_arc.state_type, record_new_arc.diameter, record_new_arc.roughness, record_new_arc.annotation, record_new_arc.length, v_status, record_new_arc.the_geom);

        -- Inserting new nodes into node table
        record_node.epa_type := 'JUNCTION';
        record_node.the_geom := valve_arc_node_1_geom;
        record_node.node_id := concat(node_id_aux, '_n2a_1');
		
        INSERT INTO rpt_inp_node (result_id, node_id, elevation, elev, node_type, nodecat_id, epa_type, sector_id, state, state_type, annotation, demand, the_geom) 
	VALUES(result_id_var, record_node.node_id, record_node.elevation, record_node.elev, 'NODE2ARC', record_node.nodecat_id, record_node.epa_type, 
	record_node.sector_id, record_node.state, record_node.state_type, record_node.annotation, 0, record_node.the_geom);

        record_node.the_geom := valve_arc_node_2_geom;
        record_node.node_id := concat(node_id_aux, '_n2a_2');
        INSERT INTO rpt_inp_node (result_id, node_id, elevation, elev, node_type, nodecat_id, epa_type, sector_id, state, state_type, annotation, demand, the_geom) 
	VALUES(result_id_var, record_node.node_id, record_node.elevation, record_node.elev, 'NODE2ARC', record_node.nodecat_id, record_node.epa_type, 
	record_node.sector_id, record_node.state, record_node.state_type, record_node.annotation, 0, record_node.the_geom);


        -- Deleting old node from node table
        DELETE FROM rpt_inp_node WHERE node_id =  node_id_aux AND result_id=result_id_var;


    END LOOP;


    RETURN 1;


		
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
