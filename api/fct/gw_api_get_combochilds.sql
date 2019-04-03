-- Function: SCHEMA_NAME.gw_api_get_combochilds(character varying, character varying, character varying, character varying, character varying, character varying)

-- DROP FUNCTION SCHEMA_NAME.gw_api_get_combochilds(character varying, character varying, character varying, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_api_get_combochilds(
    p_table_id character varying,
    p_id character varying,
    p_idname character varying,
    p_comboparent character varying,
    p_combovalue character varying,
    p_geom_type character varying)
  RETURNS json AS
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_api_get_combochilds('ve_arc_pipe', '2001', 'arc_id', 'state' ,  '1', 'arc')
*/

DECLARE

--    Variables
    v_fields json;
    v_fields_array json[];
    v_combo_rows_child json[];
    v_aux_json_child json;    
    combo_json_child json;
    schemas_array name[];
    api_version json;
    query_text text;
    v_current_value text;
    v_column_type varchar;
    v_parameter text;
    v_formtype varchar;
    v_config_param_user record;


BEGIN

	-- Set search path to local schema
	SET search_path = "SCHEMA_NAME", public;

	-- Get schema name
	schemas_array := current_schemas(FALSE);

	-- get api version
	EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
		INTO api_version;
		
	-- get column type of idname
        EXECUTE 'SELECT data_type FROM information_schema.columns  WHERE table_schema = $1 AND table_name = ' || quote_literal(p_table_id) || ' AND column_name = $2'
            USING schemas_array[1], p_idname
            INTO v_column_type;

	IF (p_table_id = 'config') THEN

	--  Combo rows child CONFIG
		EXECUTE 'SELECT array_agg(row_to_json(a)) FROM (SELECT id as column_id, widgettype, datatype, id as widgetname,
		dv_querytext, isparent, dv_parent_id, row_number()over(ORDER BY layout_id, layout_order) AS orderby , dv_querytext_filterc, isautoupdate
		FROM audit_cat_param_user WHERE dv_parent_id='||quote_literal(p_comboparent)||' ORDER BY orderby) a WHERE widgettype = ''combo'''
		INTO v_combo_rows_child;
		v_combo_rows_child := COALESCE(v_combo_rows_child, '{}');
		v_formtype='config';

	ELSIF (p_table_id = 'catalog') THEN

		-- Get parameter to seacrh
		v_parameter:= 'upsert_catalog_' || p_geom_type;

		--  Combo rows child CATALOG
		EXECUTE 'SELECT array_agg(row_to_json(a)) FROM (SELECT column_id, widgettype, column_id as widgetname,
		dv_querytext, isparent, dv_parent_id, row_number()over(ORDER BY layout_id, layout_order) AS orderby , dv_querytext_filterc, isautoupdate
		FROM config_api_form_fields WHERE formname = '''||v_parameter||''' AND dv_parent_id='||quote_literal(p_comboparent)||' ORDER BY orderby) a WHERE widgettype = ''combo'''
		INTO v_combo_rows_child;
		v_combo_rows_child := COALESCE(v_combo_rows_child, '{}');
		v_formtype='catalog';

	ELSE
		--  Combo rows child
		EXECUTE 'SELECT array_agg(row_to_json(a)) FROM (SELECT id, column_id, widgettype, datatype, concat(''data_'',column_id) as widgetname,
		dv_querytext, isparent, dv_parent_id, row_number()over(ORDER BY layout_id, layout_order) AS orderby , dv_querytext_filterc, isautoupdate
		FROM config_api_form_fields WHERE formname = $1 AND dv_parent_id='||quote_literal(p_comboparent)||' ORDER BY orderby) a WHERE widgettype = ''combo'''
		INTO v_combo_rows_child
		USING p_table_id;
		v_combo_rows_child := COALESCE(v_combo_rows_child, '{}');
		v_formtype='feature';
	END IF;

	FOREACH v_aux_json_child IN ARRAY v_combo_rows_child
	LOOP

		-- Get combo child name
		v_fields_array[(v_aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields_array[(v_aux_json_child->>'orderby')::INT], 'widgetname', (v_aux_json_child->>'widgetname'));
		
		-- Get combo id's
		IF (v_aux_json_child->>'dv_querytext_filterc') IS NOT NULL AND p_combovalue IS NOT NULL THEN
			query_text= 'SELECT array_to_json(array_agg(id)) FROM ('||(v_aux_json_child->>'dv_querytext')||(v_aux_json_child->>'dv_querytext_filterc')||' '||quote_literal(p_combovalue)||'
			 ORDER BY idval) a';
			execute query_text INTO combo_json_child;
		ELSE 	
			EXECUTE 'SELECT array_to_json(array_agg(id)) FROM ('||(v_aux_json_child->>'dv_querytext')||' ORDER BY idval)a' INTO combo_json_child;
		END IF;
		combo_json_child := COALESCE(combo_json_child, '[]');
		v_fields_array[(v_aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields_array[(v_aux_json_child->>'orderby')::INT], 'comboIds', COALESCE(combo_json_child, '[]'));
		
		-- Get combo value's
		IF (v_aux_json_child->>'dv_querytext_filterc') IS NOT NULL AND p_combovalue IS NOT NULL THEN
			query_text= 'SELECT array_to_json(array_agg(idval)) FROM ('||(v_aux_json_child->>'dv_querytext')||(v_aux_json_child->>'dv_querytext_filterc')||' '||quote_literal(p_combovalue)||' ORDER BY idval) a';
			execute query_text INTO combo_json_child;
		ELSE 	
			EXECUTE 'SELECT array_to_json(array_agg(idval)) FROM ('||(v_aux_json_child->>'dv_querytext')||' ORDER BY idval)a'
				INTO combo_json_child;
		END IF;
		combo_json_child := COALESCE(combo_json_child, '[]');
		v_fields_array[(v_aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields_array[(v_aux_json_child->>'orderby')::INT], 'comboNames', combo_json_child);

		-- Set current value
		IF v_formtype != 'feature' THEN
			v_fields_array[(v_aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields_array[(v_aux_json_child->>'orderby')::INT], 'selectedId', combo_json_child->0);
		ELSE
			--looping for the differents velues on audit_cat_param_user that are coincident with the child parameter
			FOR v_config_param_user IN SELECT * FROM audit_cat_param_user WHERE feature_field_id = (v_aux_json_child->>'column_id')
			LOOP
				IF v_config_param_user.feature_dv_parent_value IS NULL THEN 
					-- if there is only one because dv_parent_value is null then
					v_current_value = (SELECT value FROM config_param_user JOIN audit_cat_param_user ON audit_cat_param_user.id=config_param_user.parameter 
							WHERE feature_field_id = (v_aux_json_child->>'column_id')
							AND cur_user=current_user);			
				ELSE
					-- if there are more than one, taking that parameter with the same feature_dv_parent_value
					v_current_value = (SELECT value FROM config_param_user JOIN audit_cat_param_user ON audit_cat_param_user.id=config_param_user.parameter 
							WHERE feature_field_id = quote_ident(v_aux_json_child->>'column_id')
							AND feature_dv_parent_value = p_combovalue
							AND cur_user=current_user);
				END IF;
			END LOOP;
			
			v_fields_array[(v_aux_json_child->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields_array[(v_aux_json_child->>'orderby')::INT], 'selectedId', v_current_value);           		
		END IF;


	END LOOP;
	
--    Convert to json
    v_fields := array_to_json(v_fields_array);

--    Control NULL's
	api_version := COALESCE(api_version, '[]');
    v_fields := COALESCE(v_fields, '[]');    
    
--    Return
    RETURN ('{"status":"Accepted"' ||
       ', "apiVersion":'|| api_version ||
        ', "fields":' || v_fields ||
        '}')::json;

--    Exception handling
 --   EXCEPTION WHEN OTHERS THEN 
   --     RETURN ('{"status":"Failed","SQLERR":' || to_json(SQLERRM) || ', "apiVersion":'|| api_version ||',"SQLSTATE":' || to_json(SQLSTATE) || '}')::json;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;