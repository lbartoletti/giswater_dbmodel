/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
--FUNCTION CODE: 2564

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_api_get_widgetjson(
    label_arg text,
    name_arg text,
    type_arg text,
    datatype_arg text,
    placeholder_arg text,
    disabled_arg boolean,
    value_arg text)
  RETURNS json AS
$BODY$
DECLARE

--	Variables
	widget_json json;
	schemas_array name[];
	value_type text;

BEGIN

--	Set search path to local schema
	SET search_path = "SCHEMA_NAME", public;
	schemas_array := current_schemas(FALSE);

--	Create JSON
	widget_json := json_build_object('label', label_arg, 'name', name_arg, 'type', type_arg, 'dataType', datatype_arg, 'placeholder', placeholder_arg, 'disabled', disabled_arg);

--	Cast value
	IF datatype_arg = 'integer' THEN
		value_type = 'INTEGER';
	ELSIF datatype_arg = 'double' THEN
		value_type = 'DOUBLE PRECISION';
	ELSIF datatype_arg = 'boolean' THEN
		value_type = 'BOOLEAN';
	ELSE
		value_type = 'TEXT';
	END IF;
	
--	Add 'value' field
	IF value_arg ISNULL THEN
		widget_json := gw_fct_json_object_set_key(widget_json, 'value', 'NULL'::TEXT);
	ELSE
		EXECUTE 'SELECT gw_fct_json_object_set_key($1, ''value'', CAST(' || quote_literal(value_arg) || ' AS ' || quote_literal(value_type) || '))'    
			INTO widget_json
			USING widget_json;
	END IF;
	
	RETURN widget_json;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
