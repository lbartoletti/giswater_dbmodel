/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2104

DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_anl_arc_same_startend();
CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_anl_arc_same_startend(p_data json) RETURNS json AS 
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_anl_arc_same_startend($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"tableName":"v_edit_man_pipe", "id":["1004","1005"]},
"data":{"selectionMode":"previousSelection",
	"parameters":{"saveOnDatabase":true}}}$$)
*/

DECLARE
v_id json;
v_selectionmode 	text;
v_connectolerance 	float;
v_saveondatabase 	boolean;
v_worklayer 		text;
v_result 		json;
v_result_info		json;
v_result_line 		json;
v_array 		text;
v_version 		text;
v_qmllinepath text;

BEGIN

	SET search_path = "SCHEMA_NAME", public;

	-- select version
	SELECT giswater INTO v_version FROM version order by 1 desc limit 1;

	-- getting input data 	
	v_id :=  ((p_data ->>'feature')::json->>'id')::json;
	v_array :=  replace(replace(replace (v_id::text, ']', ')'),'"', ''''), '[', '(');
	v_worklayer := ((p_data ->>'feature')::json->>'tableName')::text;
	v_selectionmode :=  ((p_data ->>'data')::json->>'selectionMode')::text;
	v_saveondatabase :=  (((p_data ->>'data')::json->>'parameters')::json->>'saveOnDatabase')::boolean;

	--select default geometry style
	SELECT regexp_replace(row(value)::text, '["()"]', '', 'g') INTO v_qmllinepath FROM config_param_user WHERE parameter='qgis_qml_linelayer_path' AND cur_user=current_user;

	-- Reset values
	DELETE FROM anl_arc WHERE cur_user="current_user"() AND fprocesscat_id=4;
	
	-- Computing process
	IF v_array != '()' THEN
		EXECUTE 'INSERT INTO anl_arc (arc_id, state, expl_id, fprocesscat_id, the_geom, arccat_id)
				SELECT arc_id, state, expl_id, 4, the_geom, arccat_id
				FROM '||v_worklayer||' WHERE node_1::text=node_2::text AND arc_id IN '||v_array||';';
	ELSE
		EXECUTE 'INSERT INTO anl_arc (arc_id, state, expl_id, fprocesscat_id, the_geom, arccat_id)
				SELECT arc_id, state, expl_id, 4, the_geom, arccat_id
				FROM '||v_worklayer||' WHERE node_1::text=node_2::text;';
	END IF;

	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, error_message as message FROM audit_check_data WHERE user_name="current_user"() AND fprocesscat_id=4 order by id) row; 
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');

	--lines
	v_result = null;
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, arc_id, arccat_id, state, expl_id, descript, the_geom, fprocesscat_id FROM anl_arc WHERE cur_user="current_user"() AND fprocesscat_id=4) row; 
	v_result := COALESCE(v_result, '{}'); 
	v_result_line = concat ('{"geometryType":"LineString", "qmlPath":"',v_qmllinepath,'", "values":',v_result, '}');

	IF v_saveondatabase IS FALSE THEN 
		-- delete previous results
		DELETE FROM anl_arc WHERE cur_user="current_user"() AND fprocesscat_id=4;
	ELSE
		-- set selector
		DELETE FROM selector_audit WHERE fprocesscat_id=4 AND cur_user=current_user;    
		INSERT INTO selector_audit (fprocesscat_id,cur_user) VALUES (4, current_user);
	END IF;
		
	--    Control nulls
	v_result_info := COALESCE(v_result_info, '{}'); 
	v_result_line := COALESCE(v_result_line, '{}'); 

--  Return
    RETURN ('{"status":"Accepted", "message":{"priority":1, "text":"This is a test message"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||','||
				'"line":'||v_result_line||','||
				'"setVisibleLayers":[]'||
		       '}}'||
	    '}')::json; 

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

