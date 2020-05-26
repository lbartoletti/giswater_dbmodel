/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


--FUNCTION CODE: 2796

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_api_getselectors(p_data json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_getselectors(p_data json)
  RETURNS json AS
$BODY$

/*example
CURRENT
SELECT gw_fct_getselectors($${"client":{"device":9, "infoType":100, "lang":"ES"}, "form":{}, "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "selector_type":{"mincut": {"ids":[]}}}}$$);
SELECT gw_fct_getselectors($${"client":{"device":9, "infoType":100, "lang":"ES"}, "form":{}, "feature":{}, "data":{"filterFields":{}, "pageInfo":{}, "selector_type":{"exploitation": {"ids":[]}}}}$$);
*/

DECLARE

-- Variables
selected_json json;	
form_json json;
v_formTabsAux  json;
v_formTabs text;
json_array json[];
v_version json;
rec_tab record;
v_active boolean=true;
v_firsttab boolean=false;
v_selectors_list text;
v_selector_type json;
v_aux_json json;
fields_array json[];
v_result_list text[];
v_filter_name text;
v_parameter_selector json;
v_label text;
v_table text;
v_selector text;
v_table_id text;
v_selector_id text;
v_query_filter text;
v_query_filteradd text;
v_manageall boolean;
v_typeaheadFilter text;
v_expl_x_user boolean;

BEGIN

	-- Set search path to local schema
	SET search_path = "SCHEMA_NAME", public;

	--  get api version
	EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''admin_version'') row'
		INTO v_version;

	-- Get input parameters:
	v_selector_type := (p_data ->> 'data')::json->> 'selector_type';
	v_selectors_list := (((p_data ->> 'data')::json->>'selector_type')::json ->>'mincut')::json->>'ids';

	-- get system variables:
	v_expl_x_user = (SELECT value FROM config_param_system WHERE parameter = 'admin_exploitation_x_user');
	
	-- Manage list ids
	v_selectors_list = replace(replace(v_selectors_list, '[', '('), ']', ')');

	-- Start the construction of the tabs array
	v_formTabs := '[';
	
	SELECT array_agg(row_to_json(a)) FROM (SELECT * FROM json_object_keys(v_selector_type))a into fields_array;

	
	FOREACH v_aux_json IN ARRAY fields_array
	LOOP		

	SELECT * INTO rec_tab FROM config_form_tabs WHERE formname=v_aux_json->>'json_object_keys';
	IF rec_tab.id IS NOT NULL THEN

		-- get selector parameters
		v_parameter_selector = (SELECT value::json FROM config_param_system WHERE parameter = concat('basic_selector_', lower(v_aux_json->>'json_object_keys')::text));
		
		v_label = v_parameter_selector->>'label';
		v_table = v_parameter_selector->>'table';
		v_selector = v_parameter_selector->>'selector';
		v_table_id = v_parameter_selector->>'table_id';
		v_selector_id = v_parameter_selector->>'selector_id';
		v_query_filteradd = v_parameter_selector->>'query_filter';
		v_manageall = v_parameter_selector->>'manageAll';
		v_typeaheadFilter = v_parameter_selector->>'typeaheadFilter';

		IF v_selector = 'selector_expl' AND v_expl_x_user THEN
			v_query_filteradd = concat (v_query_filteradd, ' AND expl_id IN (SELECT expl_id FROM config_exploitation_x_user WHERE username = current_user)');
		END IF;

		-- Manage selectors list
		IF v_selectors_list IS NULL THEN
			v_query_filter = '';
		ELSIF v_selectors_list = '()' THEN
			v_query_filter = ' AND ' || v_table_id || ' IN (-1) ';
		ELSE
			v_query_filter = ' AND ' || v_table_id || ' IN '|| v_selectors_list || ' ';
		END IF;

		IF v_query_filteradd IS NULL THEN v_query_filteradd ='' ; END IF;

		RAISE NOTICE ' % % % % % % % % ', v_label, v_table_id, v_selector_id, v_table, v_selector_id, v_selector, v_query_filter, v_query_filteradd;

		-- Get exploitations, selected and unselected with selectors list
		EXECUTE 'SELECT array_to_json(array_agg(row_to_json(a))) FROM (
		SELECT concat(' || v_label || ') AS label, ' || v_table_id || '::text as widgetname, ''' || v_selector_id || ''' as column_id, ''check'' as type, ''boolean'' as "dataType", true as "value" 
		FROM '|| v_table ||' WHERE ' || v_table_id || ' IN (SELECT ' || v_selector_id || ' FROM '|| v_selector ||' WHERE cur_user=' || quote_literal(current_user) || ') '|| v_query_filter ||' '
		||v_query_filteradd||' 
		UNION 
		SELECT concat(' || v_label || ') AS label, ' || v_table_id || '::text as widgetname, ''' || v_selector_id || ''' as column_id, ''check'' as type, ''boolean'' as "dataType", false as "value" 
		FROM '|| v_table ||' WHERE ' || v_table_id || ' NOT IN (SELECT ' || v_selector_id || ' FROM '|| v_selector ||' WHERE cur_user=' || quote_literal(current_user) || ') '|| v_query_filter ||' '
		||v_query_filteradd||'  ORDER BY label) a'
		INTO v_formTabsAux;
		
		-- Add tab name to json
		IF v_formTabsAux IS NULL THEN
			v_formTabsAux := ('{"fields":[]}')::json;
		ELSE
			v_formTabsAux := ('{"fields":' || v_formTabsAux || '}')::json;
		END IF;

		v_formTabsAux := gw_fct_json_object_set_key(v_formTabsAux, 'tabName', rec_tab.tabname::TEXT);
		v_formTabsAux := gw_fct_json_object_set_key(v_formTabsAux, 'tableName', v_selector);
		v_formTabsAux := gw_fct_json_object_set_key(v_formTabsAux, 'tabLabel', rec_tab.label::TEXT);
		v_formTabsAux := gw_fct_json_object_set_key(v_formTabsAux, 'tooltip', rec_tab.tooltip::TEXT);
		v_formTabsAux := gw_fct_json_object_set_key(v_formTabsAux, 'selectorType', rec_tab.formname::TEXT);
		v_formTabsAux := gw_fct_json_object_set_key(v_formTabsAux, 'manageAll', v_manageall::TEXT);
		v_formTabsAux := gw_fct_json_object_set_key(v_formTabsAux, 'typeaheadFilter', v_typeaheadFilter::TEXT);


		-- Create tabs array
		IF v_firsttab THEN 
			v_formTabs := v_formTabs || ',' || v_formTabsAux::text;
		ELSE 
			v_formTabs := v_formTabs || v_formTabsAux::text;
		END IF;

		v_firsttab := TRUE;
		v_active :=FALSE;
	END IF;
	
	END LOOP;

	-- Finish the construction of the tabs array
	v_formTabs := v_formTabs ||']';

	-- Check null
	v_formTabs := COALESCE(v_formTabs, '[]');	

	-- Return
	IF v_firsttab IS FALSE THEN
		-- Return not implemented
		RETURN ('{"status":"Accepted"' ||
		', "version":'|| v_version ||
		', "message":"Not implemented"'||
		'}')::json;
	ELSE 
		-- Return formtabs
		RETURN ('{"status":"Accepted", "version":'||v_version||
			',"body":{"message":{"priority":1, "text":"This is a test message"}'||
			',"form":{"formName":"", "formLabel":"", "formText":""'|| 
			',"formTabs":'||v_formTabs||
			',"formActions":[]}'||
			',"feature":{}'||
			',"data":{}}'||
		    '}')::json;
	END IF;

	-- Exception handling
	EXCEPTION WHEN OTHERS THEN 
	RETURN ('{"status":"Failed","SQLERR":' || to_json(SQLERRM) || ', "version":'|| v_version || ',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
