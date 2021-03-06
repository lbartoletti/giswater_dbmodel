/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
-- The code of this inundation function have been provided by Enric Amat (FISERSA)

--FUNCTION CODE: 2706

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_grafanalytics_minsector(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_grafanalytics_minsector(p_data json)
RETURNS json AS
$BODY$

/*
delete from temp_anlgraf
TO EXECUTE
SELECT SCHEMA_NAME.gw_fct_grafanalytics_minsector('{"data":{"parameters":{"exploitation":"[1,2]", "usePsectors":TRUE, "updateFeature":"TRUE", "updateMinsectorGeom":"TRUE","concaveHullParam":0.85}}}');
SELECT SCHEMA_NAME.gw_fct_grafanalytics_minsector('{"data":{"parameters":{"arc":"2002", "usePsectors":TRUE, "updateFeature":"TRUE", "updateMinsectorGeom":"TRUE","concaveHullParam":0.85, "buffer":15}}}')

delete from SCHEMA_NAME.audit_log_data;
delete from SCHEMA_NAME.temp_anlgraf

SELECT * FROM SCHEMA_NAME.anl_arc WHERE fprocesscat_id=34 AND cur_user=current_user
SELECT * FROM SCHEMA_NAME.anl_node WHERE fprocesscat_id=34 AND cur_user=current_user
SELECT * FROM SCHEMA_NAME.audit_log_data WHERE fprocesscat_id=34 AND user_name=current_user


*/

DECLARE
affected_rows 		numeric;
cont1 			integer default 0;
v_class 		text = 'MINSECTOR';
v_feature 		record;
v_expl 			json;
v_data 			json;
v_fprocesscat_id 	integer;
v_addparam 		record;
v_attribute 		text;
v_arcid 		text;
v_featuretype		text;
v_featureid 		integer;
v_querytext 		text;
v_updatefeature 	boolean;
v_arc			text;
v_result_info 		json;
v_result_point		json;
v_result_line 		json;
v_result_polygon	json;
v_result 		text;
v_count			integer;
v_version		text;
v_updatemapzgeom 	boolean;
v_concavehull		float;
v_srid			integer;
v_buffer		float;
v_input			json;
v_visible_layer		text;
v_usepsectors		boolean;

BEGIN

    -- Search path
    SET search_path = "SCHEMA_NAME", public;


	-- get variables
	v_arcid = (SELECT ((p_data::json->>'data')::json->>'parameters')::json->>'arc');
	v_updatefeature = (SELECT ((p_data::json->>'data')::json->>'parameters')::json->>'updateFeature');
	v_expl = (SELECT ((p_data::json->>'data')::json->>'parameters')::json->>'exploitation');
	v_updatemapzgeom = (SELECT ((p_data::json->>'data')::json->>'parameters')::json->>'updateMapZone');
	v_concavehull = (SELECT ((p_data::json->>'data')::json->>'parameters')::json->>'concaveHullParam');
	v_buffer = (SELECT ((p_data::json->>'data')::json->>'parameters')::json->>'buffer');
	v_usepsectors = (SELECT ((p_data::json->>'data')::json->>'parameters')::json->>'usePsectors');


	-- select config values
	SELECT giswater, epsg INTO v_version, v_srid FROM version order by 1 desc limit 1;
	v_visible_layer = 'v_minsector';

	-- set variables
	v_fprocesscat_id=34;  
	v_featuretype='arc';

	-- data quality analysis
	v_input = '{"client":{"device":3, "infoType":100, "lang":"ES"},"feature":{},"data":{"parameters":{"selectionMode":"userSelectors"}}}'::json;
	PERFORM gw_fct_om_check_data(v_input);

	-- check criticity of data in order to continue or not
	SELECT count(*) INTO v_count FROM audit_check_data WHERE user_name="current_user"() AND fprocesscat_id=25 AND criticity=3;
	IF v_count > 3 THEN
	
		SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
		FROM (SELECT id, error_message as message FROM audit_check_data WHERE user_name="current_user"() AND fprocesscat_id=25 order by criticity desc, id asc) row;

		v_result := COALESCE(v_result, '{}'); 
		v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');

		-- Control nulls
		v_result_info := COALESCE(v_result_info, '{}'); 
		
		--  Return
		RETURN ('{"status":"Accepted", "message":{"priority":3, "text":"Mapzones dynamic analysis canceled. Data is not ready to work with"}, "version":"'||v_version||'"'||
		',"body":{"form":{}, "data":{ "info":'||v_result_info||'}}}')::json;	
	END IF;
 
	-- reset graf & audit_log tables
	DELETE FROM temp_anlgraf;
	DELETE FROM audit_log_data WHERE fprocesscat_id=v_fprocesscat_id AND user_name=current_user;
	DELETE FROM anl_node WHERE fprocesscat_id=34 AND cur_user=current_user;
	DELETE FROM anl_arc WHERE fprocesscat_id=34 AND cur_user=current_user;
	DELETE FROM audit_check_data WHERE fprocesscat_id=34 AND user_name=current_user;

	-- Starting process
	INSERT INTO audit_check_data (fprocesscat_id, error_message) VALUES (v_fprocesscat_id, concat('MINSECTOR DYNAMIC SECTORITZATION'));
	INSERT INTO audit_check_data (fprocesscat_id, error_message) VALUES (v_fprocesscat_id, concat('---------------------------------------------------'));
	IF v_usepsectors THEN
		SELECT count(*) INTO v_count FROM selector_psector WHERE cur_user = current_user;
		INSERT INTO audit_check_data (fprocesscat_id, error_message) VALUES (v_fprocesscat_id, 
		concat('INFO: Plan psector strategy is enabled. The number of psectors used on this analysis is ', v_count));
	ELSE 
		INSERT INTO audit_check_data (fprocesscat_id, error_message) VALUES (v_fprocesscat_id, 
		concat('INFO: All psectors have been disabled to execute this analysis'));
	END IF;

	
		
	-- reset selectors
	DELETE FROM selector_state WHERE cur_user=current_user;
	INSERT INTO selector_state (state_id, cur_user) VALUES (1, current_user);

	-- use masterplan
	IF v_usepsectors IS NOT TRUE THEN
		DELETE FROM selector_psector WHERE cur_user=current_user;
	END IF;

	-- reset exploitation
	IF v_expl IS NOT NULL THEN
		DELETE FROM selector_expl WHERE cur_user=current_user;
		INSERT INTO selector_expl (expl_id, cur_user) SELECT expl_id, current_user FROM exploitation where macroexpl_id IN
		(SELECT distinct(macroexpl_id) FROM SCHEMA_NAME.exploitation JOIN (SELECT (json_array_elements_text(v_expl))::integer AS expl)a  ON expl=expl_id);
	END IF;

	-- create graf
	INSERT INTO temp_anlgraf ( arc_id, node_1, node_2, water, flag, checkf )
	SELECT  arc_id::integer, node_1::integer, node_2::integer, 0, 0, 0 FROM v_edit_arc JOIN value_state_type ON state_type=id 
	WHERE node_1 IS NOT NULL AND node_2 IS NOT NULL AND is_operative=TRUE
	UNION
	SELECT  arc_id::integer, node_2::integer, node_1::integer, 0, 0, 0 FROM v_edit_arc JOIN value_state_type ON state_type=id 
	WHERE node_1 IS NOT NULL AND node_2 IS NOT NULL AND is_operative=TRUE;
	
	-- set boundary conditions of graf table	
	UPDATE temp_anlgraf SET flag=2 FROM node_type a JOIN cat_node b ON a.id=nodetype_id JOIN node c ON nodecat_id=b.id 
	WHERE c.node_id::integer=temp_anlgraf.node_1 AND graf_delimiter !='NONE' ;
			
	-- starting process
	LOOP
		EXIT WHEN cont1 = -1;
		cont1 = 0;

		-- reset water flag
		UPDATE temp_anlgraf SET water=0;

		------------------
		-- starting engine
		-- when arc_id is provided as a parameter
		IF v_arcid IS NULL THEN
			SELECT a.arc_id INTO v_arc FROM (SELECT arc_id, max(checkf) as checkf FROM temp_anlgraf GROUP by arc_id) a 
			JOIN v_edit_arc b ON a.arc_id::integer=b.arc_id::integer WHERE checkf=0 LIMIT 1;
		END IF;

		EXIT WHEN v_arc IS NULL;
				
		-- set the starting element
		v_querytext = 'UPDATE temp_anlgraf SET flag=1, water=1, checkf=1 WHERE arc_id='||quote_literal(v_arc)||'::integer';
		EXECUTE v_querytext;

		-- inundation process
		LOOP	
			cont1 = cont1+1;
			UPDATE temp_anlgraf n SET water= 1, flag=n.flag+1, checkf=1 FROM v_anl_graf a WHERE n.node_1::integer = a.node_1::integer AND n.arc_id = a.arc_id;
			GET DIAGNOSTICS affected_rows =row_count;
			EXIT WHEN affected_rows = 0;
			EXIT WHEN cont1 = 200;
		END LOOP;
		
		-- finish engine
		----------------
		
		-- insert arc results into audit table
		EXECUTE 'INSERT INTO anl_arc (fprocesscat_id, arccat_id, arc_id, the_geom, descript) 
			SELECT DISTINCT ON (arc_id)'||v_fprocesscat_id||', arccat_id, a.arc_id, the_geom, '||(v_arc)||' 
			FROM (SELECT arc_id, max(water) as water FROM temp_anlgraf WHERE water=1 GROUP by arc_id) a JOIN v_edit_arc b ON a.arc_id::integer=b.arc_id::integer';
	
		-- insert node results into audit table
		EXECUTE 'INSERT INTO anl_node (fprocesscat_id, nodecat_id, node_id, the_geom, descript) 
			SELECT DISTINCT ON (node_id) '||v_fprocesscat_id||', nodecat_id, b.node_id, the_geom, '||(v_arc)||' FROM (SELECT node_1 as node_id FROM
			(SELECT node_1,water FROM temp_anlgraf UNION SELECT node_2,water FROM temp_anlgraf)a
			GROUP BY node_1, water HAVING water=1)b JOIN v_edit_node c ON c.node_id::integer=b.node_id::integer';

		-- insert node delimiters into audit table
		EXECUTE 'INSERT INTO anl_node (fprocesscat_id, nodecat_id, node_id, the_geom, descript) 
			SELECT DISTINCT ON (node_id) '||v_fprocesscat_id||', nodecat_id, b.node_id, the_geom, 0 FROM 
			(SELECT node_1 as node_id FROM (SELECT node_1,water FROM temp_anlgraf UNION ALL SELECT node_2,water FROM temp_anlgraf)a
			GROUP BY node_1, water HAVING water=1 AND count(node_1)=2)b JOIN v_edit_node c ON c.node_id::integer=b.node_id::integer';
		-- NOTE: node delimiter are inserted two times in table, as node from minsector trace and as node delimiter

				
	END LOOP;
	
	IF v_updatefeature THEN 
	
		-- due URN concept whe can update massively feature from anl_node without check if is arc/node/connec.....
		UPDATE arc SET minsector_id = a.descript::integer FROM anl_arc a WHERE fprocesscat_id=34 AND a.arc_id=arc.arc_id AND cur_user=current_user;
	
		-- update graf nodes inside minsector
		UPDATE node SET minsector_id = a.descript::integer FROM anl_node a WHERE fprocesscat_id=34 AND a.node_id=node.node_id AND a.descript::integer >0 AND cur_user=current_user;
	
		-- update graf nodes on the border of minsectors
		UPDATE node SET minsector_id = 0 FROM anl_node a JOIN v_edit_node USING (node_id) JOIN node_type c ON c.id=node_type 
		WHERE fprocesscat_id=34 AND a.node_id=node.node_id AND a.descript::integer =0 AND graf_delimiter!='NONE' AND cur_user=current_user;
			
		-- update non graf nodes (not connected) using arc_id parent on v_edit_node (not used node table because the exploitation filter).
		UPDATE v_edit_node SET minsector_id = a.minsector_id FROM arc a WHERE a.arc_id=v_edit_node.arc_id;
	
		-- used v_edit_connec to the exploitation filter. Rows before is not neeeded because on table anl_* is data filtered by the process...
		UPDATE v_edit_connec SET minsector_id = a.minsector_id FROM arc a WHERE a.arc_id=v_edit_connec.arc_id;

		-- insert into minsector table
		DELETE FROM minsector WHERE expl_id IN (SELECT expl_id FROM selector_expl WHERE cur_user=current_user);
		INSERT INTO minsector (minsector_id, dma_id, dqa_id, presszonecat_id, sector_id, expl_id) 
		SELECT distinct ON (minsector_id) minsector_id, dma_id, dqa_id, presszonecat_id::integer, sector_id, expl_id FROM arc WHERE minsector_id is not null;

		-- update graf on minsector_graf
		DELETE FROM minsector_graf;
		INSERT INTO minsector_graf 
		SELECT DISTINCT ON (node_id) node_id, nodecat_id, a.minsector_id as minsector_1, b.minsector_id as minsector_2 
		FROM node join arc a on a.node_1=node_id join arc b on b.node_2=node_id WHERE node.minsector_id=0 order by 1;

		-- message
		INSERT INTO audit_check_data (fprocesscat_id, error_message) 
		VALUES (v_fprocesscat_id, concat('WARNING: Minsector attribute (minsector_id) on arc/node/connec features have been updated by this process'));
		
	ELSE
		-- message
		INSERT INTO audit_check_data (fprocesscat_id, error_message) 
		VALUES (v_fprocesscat_id, concat('INFO: Minsector attribute (minsector_id) on arc/node/connec features keeps same value previous function. Nothing have been updated by this process'));
		VALUES (v_fprocesscat_id, concat('INFO: To take a look on results you can do querys like this:'));
		VALUES (v_fprocesscat_id, concat('SELECT * FROM anl_arc WHERE fprocesscat_id = 34  AND cur_user=current_user;'));
		VALUES (v_fprocesscat_id, concat('SELECT * FROM anl_node WHERE fprocesscat_id = 34  AND cur_user=current_user;'));
	
	END IF;

	-- update geometry of mapzones
	IF v_updatemapzgeom THEN

			IF v_buffer IS NOT NULL THEN

				v_querytext = '	UPDATE minsector set the_geom = geom FROM
					(SELECT minsector_id, (st_buffer(st_collect(the_geom),'||v_buffer||')) as geom from arc where minsector_id > 0 group by minsector_id)a 
					WHERE a.minsector_id = minsector.minsector_id';

			ELSIF v_concavehull IS NOT NULL THEN 

				v_querytext = 'UPDATE minsector set the_geom = (a.the_geom) 
					FROM (with polygon AS (SELECT st_collect (the_geom) as g, minsector_id FROM arc group by minsector_id)
					SELECT minsector_id, CASE WHEN st_geometrytype(st_concavehull(g, '||v_concavehull||')) = ''ST_Polygon''::text THEN st_buffer(st_concavehull(g, '||v_concavehull||'), 3)::geometry(Polygon,'||v_srid||')
					ELSE st_expand(st_buffer(g, 3::double precision), 1::double precision)::geometry(Polygon, '||v_srid||') END AS the_geom FROM polygon
					)a WHERE a.minsector_id = minsector.minsector_id';
			END IF;
			
			EXECUTE v_querytext;	

			-- message
			INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
			VALUES (v_fprocesscat_id, 2, concat('WARNING: Geometry of minsector ',v_class ,' have been modified by this process'));
		END IF;
	
	
	-- set selector
	DELETE FROM selector_audit WHERE cur_user=current_user;
	INSERT INTO selector_audit (fprocesscat_id, cur_user) VALUES (v_fprocesscat_id, current_user);

	-- get results
	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, error_message as message FROM audit_check_data WHERE user_name="current_user"() AND fprocesscat_id=v_fprocesscat_id order by id) row; 
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');
	
	--points
	v_result = null;
	v_result := COALESCE(v_result, '{}'); 
	v_result_point = concat ('{"geometryType":"Point", "values":',v_result, '}');

	--lines
	v_result = null;
	v_result := COALESCE(v_result, '{}'); 
	v_result_line = concat ('{"geometryType":"LineString", "values":',v_result, '}');

	--polygons
	v_result = null;
	v_result := COALESCE(v_result, '{}'); 
	v_result_polygon = concat ('{"geometryType":"Polygon", "values":',v_result, '}');
	
	--    Control nulls
	v_result_info := COALESCE(v_result_info, '{}'); 
	v_visible_layer := COALESCE(v_visible_layer, '{}'); 
	v_result_point := COALESCE(v_result_point, '{}'); 
	v_result_line := COALESCE(v_result_line, '{}'); 
	v_result_polygon := COALESCE(v_result_polygon, '{}');
	

--  Return
    RETURN ('{"status":"Accepted", "message":{"priority":1, "text":"Mapzones dynamic analysis done succesfully"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||','||
				'"setVisibleLayers":["'||v_visible_layer||'"],'||
				'"point":'||v_result_point||','||
				'"line":'||v_result_line||','||
				'"polygon":'||v_result_polygon||'}'||
		       '}'||
	    '}')::json;
	
RETURN cont1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
