/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 1344

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_topocontrol_arc() RETURNS trigger AS $BODY$
DECLARE 
    nodeRecord1 record; 
    nodeRecord2 record;  
    vnoderec record;
    newPoint public.geometry;    
    connecPoint public.geometry;
    v_sys_statetopocontrol boolean;
    connec_id_aux varchar;
    array_agg varchar [];
	v_dsbl_error boolean;
	v_samenode_init_end_control boolean;
	v_nodeinsert_arcendpoint boolean;
	v_arc_searchnodes_control boolean;
	v_arc_searchnodes double precision;
	v_user_dis_statetopocontrol boolean;
	
BEGIN 

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
    
 -- Get data from config table 
    SELECT value::boolean INTO v_sys_statetopocontrol FROM config_param_system WHERE parameter='state_topocontrol';
   	SELECT value::boolean INTO v_dsbl_error FROM config_param_system WHERE parameter='edit_topocontrol_dsbl_error' ;
   	SELECT value::boolean INTO v_samenode_init_end_control FROM config_param_system WHERE parameter='samenode_init_end_control' ;
	SELECT value::boolean INTO v_nodeinsert_arcendpoint  FROM config_param_system WHERE parameter='nodeinsert_arcendpoint';
	SELECT ((value::json)->>'activated') INTO v_arc_searchnodes_control FROM config_param_system WHERE parameter='arc_searchnodes';
	SELECT ((value::json)->>'value') INTO v_arc_searchnodes FROM config_param_system WHERE parameter='arc_searchnodes';
	SELECT value::boolean INTO v_user_dis_statetopocontrol FROM config_param_user WHERE parameter='edit_disable_statetopocontrol';


    -- disable trigger
    IF v_arc_searchnodes_control IS FALSE THEN
	RETURN NEW;
    END IF;
	
    IF v_sys_statetopocontrol IS NOT TRUE OR v_user_dis_statetopocontrol IS TRUE THEN

		SELECT * INTO nodeRecord1 FROM node WHERE ST_DWithin(ST_startpoint(NEW.the_geom), node.the_geom, v_arc_searchnodes)
		ORDER BY ST_Distance(node.the_geom, ST_startpoint(NEW.the_geom)) LIMIT 1;

		SELECT * INTO nodeRecord2 FROM node WHERE ST_DWithin(ST_endpoint(NEW.the_geom), node.the_geom, v_arc_searchnodes)
		ORDER BY ST_Distance(node.the_geom, ST_endpoint(NEW.the_geom)) LIMIT 1;      
    ELSE

	-- Looking for state control
	PERFORM gw_fct_state_control('ARC', NEW.arc_id, NEW.state, TG_OP);

	-- Lookig for state=0
	IF NEW.state=0 THEN
		RETURN NEW;
        END IF;
	
	-- Starting process
	IF TG_OP='INSERT' THEN  

		SELECT * INTO nodeRecord1 FROM node WHERE ST_DWithin(ST_startpoint(NEW.the_geom), node.the_geom, v_arc_searchnodes)
		AND ((NEW.state=1 AND node.state=1)
		
					-- looking for existing nodes that not belongs on the same alternatives that arc
					OR (NEW.state=2 AND node.state=1 AND node_id NOT IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=node.node_id AND state=0 AND psector_id=
							(SELECT value::integer FROM config_param_user 
							WHERE parameter='psector_vdefault' AND cur_user="current_user"() LIMIT 1)))
					
					-- looking for planified nodes that belongs on the same alternatives that arc
					OR (NEW.state=2 AND node.state=2 AND node_id IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=node.node_id AND state=1 AND psector_id=
							(SELECT value::integer FROM config_param_user 
							WHERE parameter='psector_vdefault' AND cur_user="current_user"() LIMIT 1))))

		ORDER BY ST_Distance(node.the_geom, ST_startpoint(NEW.the_geom)) LIMIT 1;

	
		SELECT * INTO nodeRecord2 FROM node WHERE ST_DWithin(ST_endpoint(NEW.the_geom), node.the_geom, v_arc_searchnodes) 
		AND ((NEW.state=1 AND node.state=1)

					-- looking for existing nodes that not belongs on the same alternatives that arc
					OR (NEW.state=2 AND node.state=1 AND node_id NOT IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=node.node_id AND state=0 AND psector_id=
							(SELECT value::integer FROM config_param_user 
							WHERE parameter='psector_vdefault' AND cur_user="current_user"() LIMIT 1)))
					
					-- looking for planified nodes that belongs on the same alternatives that arc
					OR (NEW.state=2 AND node.state=2 AND node_id IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=node.node_id AND state=1 AND psector_id=
							(SELECT value::integer FROM config_param_user 
							WHERE parameter='psector_vdefault' AND cur_user="current_user"() LIMIT 1))))

		ORDER BY ST_Distance(node.the_geom, ST_endpoint(NEW.the_geom)) LIMIT 1;

	ELSIF TG_OP='UPDATE' THEN


		SELECT * INTO nodeRecord1 FROM node WHERE ST_DWithin(ST_startpoint(NEW.the_geom), node.the_geom, v_arc_searchnodes)
		AND ((NEW.state=1 AND node.state=1)
					-- looking for existing nodes that not belongs on the same alternatives that arc

					OR (NEW.state=2 AND node.state=1 AND node_id NOT IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=node.node_id AND state=0 AND psector_id IN 
							(SELECT psector_id FROM plan_psector_x_arc WHERE arc_id=NEW.arc_id)))
							

					-- looking for planified nodes that belongs on the same alternatives that arc
					OR (NEW.state=2 AND node.state=2 AND node_id IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=node.node_id AND state=1 AND psector_id IN
							(SELECT psector_id FROM plan_psector_x_arc WHERE arc_id=NEW.arc_id))))

		ORDER BY ST_Distance(node.the_geom, ST_startpoint(NEW.the_geom)) LIMIT 1;

	
		SELECT * INTO nodeRecord2 FROM node WHERE ST_DWithin(ST_endpoint(NEW.the_geom), node.the_geom, v_arc_searchnodes) 
		AND ((NEW.state=1 AND node.state=1)

					-- looking for existing nodes that not belongs on the same alternatives that arc

					OR (NEW.state=2 AND node.state=1 AND node_id NOT IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=node.node_id AND state=0 AND psector_id IN 
							(SELECT psector_id FROM plan_psector_x_arc WHERE arc_id=NEW.arc_id)))
							

					-- looking for planified nodes that belongs on the same alternatives that arc
					OR (NEW.state=2 AND node.state=2 AND node_id IN 
						(SELECT node_id FROM plan_psector_x_node 
						 WHERE plan_psector_x_node.node_id=node.node_id AND state=1 AND psector_id IN
							(SELECT psector_id FROM plan_psector_x_arc WHERE arc_id=NEW.arc_id))))

		ORDER BY ST_Distance(node.the_geom, ST_endpoint(NEW.the_geom)) LIMIT 1;

	END IF;

   END IF;

	--  Control of start/end node
	IF (nodeRecord1.node_id IS NOT NULL) AND (nodeRecord2.node_id IS NOT NULL) THEN
   
		-- Control of same node initial and final
		IF (nodeRecord1.node_id = nodeRecord2.node_id) AND (v_samenode_init_end_control IS TRUE) THEN
			IF v_dsbl_error IS NOT TRUE THEN
				PERFORM audit_function (1040,1344, nodeRecord1.node_id);	
			ELSE
				INSERT INTO audit_log_data (fprocesscat_id, feature_id, log_message) VALUES (3, NEW.arc_id, 'Node_1 and Node_2 are the same');
			END IF;
			
		ELSE
			-- Update coordinates
			NEW.the_geom:= ST_SetPoint(NEW.the_geom, 0, nodeRecord1.the_geom);
			NEW.the_geom:= ST_SetPoint(NEW.the_geom, ST_NumPoints(NEW.the_geom) - 1, nodeRecord2.the_geom);
			NEW.node_1:= nodeRecord1.node_id; 
			NEW.node_2:= nodeRecord2.node_id;

		END IF;
			
	-- Check auto insert end nodes
	ELSIF (nodeRecord1.node_id IS NOT NULL) AND (nodeRecord2.node_id IS NULL) AND v_nodeinsert_arcendpoint THEN
		IF TG_OP = 'INSERT' THEN
			INSERT INTO node (node_id, sector_id, epa_type, nodecat_id, dma_id, the_geom) 
				VALUES (
				(SELECT nextval('urn_id_seq')),
				(SELECT sector_id FROM sector WHERE (ST_endpoint(NEW.the_geom) @ sector.the_geom) LIMIT 1), 
				'JUNCTION'::text,
				(SELECT "value" FROM config_param_user WHERE "parameter"='nodecat_vdefault' AND "cur_user"="current_user"()),
				(SELECT dma_id FROM dma WHERE (ST_endpoint(NEW.the_geom) @ dma.the_geom) LIMIT 1), 
				ST_endpoint(NEW.the_geom)
				);

			INSERT INTO inp_junction (node_id) VALUES ((SELECT currval('urn_id_seq')));
			INSERT INTO man_junction (node_id) VALUES ((SELECT currval('urn_id_seq')));

			-- Update coordinates
			NEW.the_geom:= ST_SetPoint(NEW.the_geom, 0, nodeRecord1.the_geom);
			NEW.node_1:= nodeRecord1.node_id; 
			NEW.node_2:= (SELECT currval('urn_id_seq'));  
		END IF;
		
	--Error, no existing nodes
	ELSIF ((nodeRecord1.node_id IS NULL) OR (nodeRecord2.node_id IS NULL)) AND (v_arc_searchnodes_control IS TRUE) THEN
		IF v_dsbl_error IS NOT TRUE THEN
			PERFORM audit_function (1042,1344, NEW.arc_id);	
		ELSE
			INSERT INTO audit_log_data (fprocesscat_id, feature_id, log_message) VALUES (4, NEW.arc_id, concat('Node_1 ', nodeRecord1.node_id, ' or Node_2 ', nodeRecord2.node_id, ' does not exists or does not has compatible state with arc'));
		END IF;
		
	--Not existing nodes but accepted insertion
	ELSIF ((nodeRecord1.node_id IS NULL) OR (nodeRecord2.node_id IS NULL)) AND (v_arc_searchnodes_control IS FALSE) THEN
		RETURN NEW;
		
	ELSE		
		IF v_dsbl_error IS NOT TRUE THEN
			PERFORM audit_function (1042,1344, nodeRecord1.node_id);	
		ELSE
			INSERT INTO audit_log_data (fprocesscat_id, feature_id, log_message) VALUES (4, NEW.arc_id, concat('Node_1 ', nodeRecord1.node_id, ' or Node_2 ', nodeRecord2.node_id, ' does not exists or does not has compatible state with arc'));
		END IF;
	END IF;
	
RETURN NEW;
		
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
