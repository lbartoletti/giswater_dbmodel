/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE:2764

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_odbc2pg_check_data(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_odbc2pg_check_data(p_data json)
  RETURNS json AS
$BODY$


/*EXAMPLE

SELECT SCHEMA_NAME.gw_fct_odbc2pg_check_data($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{},"data":{"parameters":{"exploitation":"557", "period":"4T", "year":"2019"}}}$$)

*/


DECLARE
	v_expl			integer;
	v_period		text;
	v_year			integer;
	v_project_type		text;
	v_version		text;
	v_result 		json;
	v_result_info		json;
	v_result_point		json;
	v_result_line		json;
	v_querytext		text;
	v_count			integer;
	v_qmlpointpath		text;
	v_qmllinepath		text;

BEGIN

	--  Search path	
	SET search_path = "SCHEMA_NAME", public;

	-- getting input data 	
	v_expl := (((p_data ->>'data')::json->>'parameters')::json->>'exploitation')::integer;
	v_year := (((p_data ->>'data')::json->>'parameters')::json->>'year')::integer;
	v_period := (((p_data ->>'data')::json->>'parameters')::json->>'period')::text;
	
	-- select config values
	SELECT wsoftware, giswater INTO v_project_type, v_version FROM version order by id desc limit 1;

	SELECT value INTO v_qmlpointpath FROM config_param_user WHERE parameter='qgis_qml_pointlayer_path' AND cur_user=current_user;
	SELECT value INTO v_qmllinepath FROM config_param_user WHERE parameter='qgis_qml_linelayer_path' AND cur_user=current_user;


	-- delete old values on result table
	DELETE FROM audit_check_data WHERE fprocesscat_id=73 AND user_name=current_user;
	DELETE FROM anl_arc WHERE fprocesscat_id=90 and cur_user=current_user;
	DELETE FROM anl_connec WHERE fprocesscat_id=92 and cur_user=current_user;

	
	-- Starting process
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (73, NULL, 4, concat('DATA ANALYSIS ACORDING ODBC IMPORT-EXPORT RULES'));
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (73, NULL, 4, '--------------------------------------------------------------');
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (73, NULL, 2, 'WARNINGS');	
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (73, NULL, 2, '--------------');	


	-- get results

	-- get arcs with dma=0 (fprocesscat = 90)
	v_querytext = 'SELECT arc_id, dma_id, arccat_id, the_geom FROM v_edit_arc WHERE expl_id = '||v_expl||' AND dma_id=0';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
	IF v_count > 0 THEN
		DELETE FROM anl_arc WHERE fprocesscat_id=90 and cur_user=current_user;
		EXECUTE concat ('INSERT INTO anl_arc (fprocesscat_id, arc_id, arccat_id, descript, the_geom) SELECT 90, arc_id, arccat_id, ''arcs without DMA'', the_geom FROM (', v_querytext,')a');
		INSERT INTO audit_check_data (fprocesscat_id,  criticity, error_message) 
		VALUES (73, 2, concat('WARNING: There is/are ',v_count,' arc(s) that have disconnected some part of network. Please check your data before continue'));
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (73, 2, concat('HINT: SELECT * FROM anl_arc WHERE fprocesscat_id=90 AND cur_user=current_user'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (73, 1, 'INFO: No arcs with dma_id=0 have been exported using the ODBC system');
	END IF;


	-- get connecs with dma=0 (fprocesscat = 92)
	v_querytext = 'SELECT connec_id, dma_id, connecat_id, the_geom FROM v_edit_connec WHERE expl_id = '||v_expl||' AND dma_id=0';

	EXECUTE concat('SELECT count(*) FROM (',v_querytext,')a') INTO v_count;
	IF v_count > 0 THEN
		EXECUTE concat ('INSERT INTO anl_connec (fprocesscat_id, connec_id, connecat_id, descript, the_geom) SELECT 92, connec_id, connecat_id, ''Connecs without DMA'', the_geom FROM (', v_querytext,')a');
		INSERT INTO audit_check_data (fprocesscat_id,  criticity, error_message) 
		VALUES (73, 2, concat('WARNING: There is/are ',v_count,' connec(s) NOT exported through the ODBC system. Please check your data before continue'));
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (73, 2, concat('HINT: SELECT * FROM anl_connec WHERE fprocesscat_id=90 AND cur_user=current_user'));
	ELSE
		INSERT INTO audit_check_data (fprocesscat_id, criticity, error_message) 
		VALUES (73, 1, 'INFO: No connecs with dma_id=0 have been exported using the ODBC system');
	END IF;

	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (73, NULL, 4, '');	
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (73, NULL, 2, '');	


	-- get results (73 odbc process, 45 dma process)
	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, message FROM (SELECT id, criticity, error_message as message FROM audit_check_data WHERE user_name="current_user"() AND fprocesscat_id=73 UNION
	      SELECT id, criticity, error_message as message FROM audit_check_data WHERE user_name="current_user"() AND fprocesscat_id=45 AND criticity = 1 order by criticity desc, id asc)a )row; 
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');

	-- points
	v_result = null;
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, connec_id, connecat_id, state, expl_id, descript, the_geom FROM anl_connec WHERE cur_user="current_user"() AND fprocesscat_id=92) row; 
	v_result := COALESCE(v_result, '{}'); 
	v_result_point = concat ('{"geometryType":"Point", "qmlPath":"',v_qmlpointpath,'", "values":',v_result, '}');

	-- lines
	v_result = null;
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result 
	FROM (SELECT id, arc_id, arccat_id, state, expl_id, descript, the_geom FROM anl_arc WHERE cur_user="current_user"() AND fprocesscat_id=90) row; 
	v_result := COALESCE(v_result, '{}'); 
	v_result_line = concat ('{"geometryType":"LineString", "qmlPath":"',v_qmllinepath,'", "values":',v_result, '}');
	
	-- Control nulls
	v_result_info := COALESCE(v_result_info, '{}'); 

	raise notice 'result_line %', v_result_line;
	
--  Return
    RETURN ('{"status":"Accepted", "message":{"level":1, "text":"ODBC connection analysis done succesfully"}, "version":"'||v_version||'"'||
             ',"body":{"form":{}'||
		     ',"data":{ "info":'||v_result_info||','||
				'"point":'||v_result_point||','||
				'"line":'||v_result_line||
		     '}}}')::json;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
