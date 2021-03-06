/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2744



CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_typevalue_fk()
  RETURNS trigger AS
$BODY$
DECLARE 


DECLARE
	v_table text;
	v_typevalue_fk text;
	rec record;
	v_list TEXT[];
	v_new_field text;
	v_new_data json;
	v_new_param integer;
BEGIN
	EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
	
	v_table:= TG_ARGV[0];

	--select typevalue for the table
	v_typevalue_fk = 'SELECT * FROM typevalue_fk WHERE target_table='''||v_table||''';';
	
	--insert new fields values into json
	v_new_data := row_to_json(NEW.*);

	--in case that field is one of the addfields capture the parameter_id
	v_new_param = (v_new_data ->>'parameter_id')::text;

	IF v_typevalue_fk IS NOT NULL THEN
	
		--loop over defined typevalues
		FOR rec IN EXECUTE v_typevalue_fk LOOP
			
			--capture new value of a target field
			v_new_field = (v_new_data ->>rec.target_field)::text;
		
			IF  v_new_param = rec.parameter_id or v_new_param IS NULL THEN
				--create a list of possible values of the field
				EXECUTE 'SELECT array_agg(id) FROM '||rec.typevalue_table||' 
				WHERE typevalue='''||rec.typevalue_name||''';'
				INTO v_list;		
				--compare the new value with the list of possible options
				IF  v_new_field = ANY(v_list) OR v_new_field IS NULL  THEN
					CONTINUE;
				ELSE 
					PERFORM audit_function(3022,2744,concat(rec.typevalue_table,', ',rec.target_field));

				END IF;
				
			END IF;
		END LOOP;
		
	END IF;
	
	RETURN NULL;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

