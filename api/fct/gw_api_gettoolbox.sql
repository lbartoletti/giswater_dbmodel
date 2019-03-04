﻿-- Function: SCHEMA_NAME.gw_api_gettoolbox(json)

-- DROP FUNCTION SCHEMA_NAME.gw_api_gettoolbox(json);

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_api_gettoolbox(p_data json)
  RETURNS json AS
$BODY$

/*EXAMPLE:
SELECT SCHEMA_NAME.gw_api_gettoolbox($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"data":{"filterText":""}}$$)
*/


DECLARE
	v_apiversion text;
	v_role text;
	v_projectype text;
	v_filter text;
	v_om_fields json;
	v_edit_fields json;
	v_epa_fields json;
	v_master_fields json;
	v_admin_fields json;

		
BEGIN

-- Set search path to local schema
    SET search_path = "SCHEMA_NAME", public;
  
--  get api version
    EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
        INTO v_apiversion;

-- get input parameter
	v_filter := (p_data ->> 'data')::json->> 'filterText';
	v_filter := COALESCE(v_filter, '');
-- get project type
        SELECT lower(wsoftware) INTO v_projectype FROM version LIMIT 1;
		

-- get om toolbox parameters

	EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
		 SELECT alias, descript, input_params::json,return_type::json, sys_role_id, function_name as functionname, isparametric
		 FROM audit_cat_function
		 WHERE istoolbox is TRUE AND alias LIKE ''%'|| v_filter ||'%'' AND sys_role_id =''role_om''
		 AND (project_type='||quote_literal(v_projectype)||' or project_type=''utils'')) a'
		USING v_filter
		INTO v_om_fields;
		
-- get edit toolbox parameters

	EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
		 SELECT alias, descript, input_params::json,return_type::json, sys_role_id, function_name as functionname, isparametric
		 FROM audit_cat_function
		 WHERE istoolbox is TRUE AND alias LIKE ''%'|| v_filter ||'%'' AND sys_role_id =''role_edit''
		 AND ( project_type='||quote_literal(v_projectype)||' or project_type=''utils'')) a'
		USING v_filter
		INTO v_edit_fields;

-- get epa toolbox parameters

	EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
		 SELECT alias, descript, input_params::json,return_type::json, sys_role_id, function_name as functionname, isparametric
		 FROM audit_cat_function
		 WHERE istoolbox is TRUE AND alias LIKE ''%'|| v_filter ||'%'' AND sys_role_id =''role_epa''
		 AND ( project_type='||quote_literal(v_projectype)||' or project_type=''utils'')) a'
		USING v_filter
		INTO v_epa_fields;

		
-- get master toolbox parameters

	EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
		 SELECT alias, descript, input_params::json,return_type::json, sys_role_id, function_name as functionname, isparametric
		 FROM audit_cat_function
		 WHERE istoolbox is TRUE AND alias LIKE ''%'|| v_filter ||'%'' AND sys_role_id =''role_master''
		 AND (project_type='||quote_literal(v_projectype)||' OR project_type=''utils'')) a'
		USING v_filter
		INTO v_master_fields;
        
-- get admin toolbox parameters

	EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
		 SELECT alias, descript, input_params::json,return_type::json, sys_role_id, function_name as functionname, isparametric
		 FROM audit_cat_function
		 WHERE istoolbox is TRUE AND alias LIKE ''%'|| v_filter ||'%'' AND sys_role_id =''role_admin''
		 AND (project_type='||quote_literal(v_projectype)||' or project_type=''utils'')) a'
		USING v_filter
		INTO v_admin_fields;
		
		--    Control NULL's
	v_om_fields := COALESCE(v_om_fields, '[]');
	v_edit_fields := COALESCE(v_edit_fields, '[]');
	v_epa_fields := COALESCE(v_epa_fields, '[]');
	v_master_fields := COALESCE(v_master_fields, '[]');
	v_admin_fields := COALESCE(v_admin_fields, '[]');

		
--    Return
    RETURN ('{"status":"Accepted", "message":{"priority":1, "text":"This is a test message"}, "apiVersion":'||v_apiversion||
             ',"body":{"form":{}'||
		     ',"feature":{}'||
		     ',"data":{"fields":{'||
					   ' "om":' || v_om_fields ||
					 ' , "edit":' || v_edit_fields ||
					 ' , "epa":' || v_epa_fields ||
					 ' , "master":' || v_master_fields ||
					 ' , "admin":' || v_admin_fields ||'}}}'||
	    '}')::json;
       
--    Exception handling
--    EXCEPTION WHEN OTHERS THEN 
        --RETURN ('{"status":"Failed","SQLERR":' || to_json(SQLERRM) || ', "apiVersion":'|| v_apiversion || ',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION SCHEMA_NAME.gw_api_gettoolbox(json)
  OWNER TO postgres;
