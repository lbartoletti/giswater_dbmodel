﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: XXXX

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_admin_schema_manage_ct(p_data json)
  RETURNS json AS
$BODY$

/*
SELECT SCHEMA_NAME.gw_fct_admin_schema_manage_ct($${
"client":{"lang":"ES"}, 
"data":{"action":"DROP"}}$$)

SELECT SCHEMA_NAME.gw_fct_admin_schema_manage_ct($${
"client":{"lang":"ES"}, 
"data":{"action":"ADD"}}$$)

*/

DECLARE
	v_schemaname text;
	v_tablerecord record;
	v_query_text text;
	v_action text;
	v_return json;
	v_36 integer=0;
	v_37 integer=0;
BEGIN


	-- search path
	SET search_path = "SCHEMA_NAME", public;
	v_schemaname = 'SCHEMA_NAME';
	
	v_action = (p_data->>'data')::json->>'action';

	IF v_action = 'DROP' THEN

		DELETE FROM temp_table WHERE fprocesscat_id=36;

		-- fk
		INSERT INTO temp_table (fprocesscat_id, text_column)
		SELECT distinct on (conname)
		36,
		concat(
		'{"tablename":"',
		conrelid::regclass,
		'","constraintname":"',
		conname,
		'","definition":"',
		pg_get_constraintdef(c.oid),
		'"}')
		FROM   pg_constraint c
		JOIN   pg_namespace n ON n.oid = c.connamespace
		join   information_schema.table_constraints tc ON conname=constraint_name
		WHERE  contype IN ('f')
		AND nspname ='SCHEMA_NAME';

		-- ckeck
		INSERT INTO temp_table (fprocesscat_id, text_column)
		SELECT distinct on (conname)
		36,
		concat(
		'{"tablename":"',
		conrelid::regclass,
		'","constraintname":"',
		conname,
		'","definition":"',
		pg_get_constraintdef(c.oid),
		'"}')
		FROM   pg_constraint c
		JOIN   pg_namespace n ON n.oid = c.connamespace
		join   information_schema.table_constraints tc ON conname=constraint_name
		WHERE  contype IN ('c')
		AND nspname ='SCHEMA_NAME';

		-- unique
		INSERT INTO temp_table (fprocesscat_id, text_column)
		SELECT distinct on (conname)
		36,
		concat(
		'{"tablename":"',
		conrelid::regclass,
		'","constraintname":"',
		conname,
		'","definition":"',
		replace (pg_get_constraintdef(c.oid),'"',''),
		'"}')
		FROM   pg_constraint c
		JOIN   pg_namespace n ON n.oid = c.connamespace
		join   information_schema.table_constraints tc ON conname=constraint_name
		WHERE  contype IN ('u')
		AND nspname ='SCHEMA_NAME';

		-- Insert not null on temp_table
		DELETE FROM temp_table WHERE fprocesscat_id=37;

		INSERT INTO temp_table (fprocesscat_id, text_column)
		SELECT distinct
				37,
				concat(
				'{"tablename":"',
				table_name,
				'","attributename":"',
				column_name,
				'","definition":"',
				--pg_get_attributedef(c.oid),
				'"}')
		FROM information_schema.columns
		WHERE table_schema = 'SCHEMA_NAME'
		AND is_nullable='NO' and concat(column_name,'_',table_name) not in (select concat(kcu.column_name,'_',tc.table_name)  FROM 
 		 	  information_schema.table_constraints AS tc 
  			  JOIN information_schema.key_column_usage AS kcu
  			  ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema
			  WHERE tc.constraint_type = 'PRIMARY KEY' OR tc.constraint_type ='UNIQUE');


		-- Insert unique on temp_table
		DELETE FROM temp_table WHERE fprocesscat_id=38;
		
		INSERT INTO temp_table (fprocesscat_id, text_column)
		SELECT distinct on (conname)
		38,
		concat(
		'{"tablename":"',
		conrelid::regclass,
		'","constraintname":"',
		conname,
		'","definition":"',
		pg_get_constraintdef(c.oid),
		'"}')
		FROM   pg_constraint c
		JOIN   pg_namespace n ON n.oid = c.connamespace
		join   information_schema.table_constraints tc ON conname=constraint_name
		WHERE  contype IN ('u')
		AND nspname ='SCHEMA_NAME';


		-- Insert check on temp_table
		DELETE FROM temp_table WHERE fprocesscat_id=39;
		
		INSERT INTO temp_table (fprocesscat_id, text_column)
		SELECT distinct on (conname)
		39,
		concat(
		'{"tablename":"',
		conrelid::regclass,
		'","constraintname":"',
		conname,
		'","definition":"',
		pg_get_constraintdef(c.oid),
		'"}')
		FROM   pg_constraint c
		JOIN   pg_namespace n ON n.oid = c.connamespace
		join   information_schema.table_constraints tc ON conname=constraint_name
		WHERE  contype IN ('c')
		AND nspname ='SCHEMA_NAME';


		-- Drop fk
		FOR v_tablerecord IN SELECT * FROM temp_table WHERE fprocesscat_id=36
		LOOP
			v_query_text:= 'ALTER TABLE '||((v_tablerecord.text_column)::json->>'tablename')||
				       ' DROP CONSTRAINT IF EXISTS '||((v_tablerecord.text_column)::json->>'constraintname')||';';
			raise notice 'fk  %',v_query_text;
			EXECUTE v_query_text;
			v_36=v_36+1;
		END LOOP;

		FOR v_tablerecord IN SELECT * FROM temp_table WHERE fprocesscat_id=37
		LOOP
			v_query_text:= 'ALTER TABLE '||((v_tablerecord.text_column)::json->>'tablename')||
				       ' ALTER COLUMN '||((v_tablerecord.text_column)::json->>'attributename')||' DROP NOT NULL;';
			raise notice 'NOTNULL %',v_query_text;
			EXECUTE v_query_text;
			v_37=v_37+1;
		END LOOP;

		v_return = concat('{"constraints dropped":"',v_36,'","notnull dropped":"',v_37,'"}');


	ELSIF v_action = 'ADD' THEN
		
		FOR v_tablerecord IN SELECT * FROM temp_table WHERE fprocesscat_id=36 order by 1 desc
		LOOP
			v_query_text:=  'ALTER TABLE '||((v_tablerecord.text_column::json)->>'tablename')|| 
							' ADD CONSTRAINT '||((v_tablerecord.text_column::json)->>'constraintname')||
							' '||((v_tablerecord.text_column::json)->>'definition');
			EXECUTE v_query_text;
			v_36=v_36+1;
		END LOOP;

		
		FOR v_tablerecord IN SELECT * FROM temp_table WHERE fprocesscat_id=37 order by 1 desc
		LOOP
			v_query_text:=  'ALTER TABLE '||((v_tablerecord.text_column::json)->>'tablename')|| 
							' ALTER COLUMN '||((v_tablerecord.text_column::json)->>'attributename')||' SET NOT NULL;' ;
		raise notice 'SET NOTNULL %',v_query_text;
			EXECUTE v_query_text;
			v_37=v_37+1;	
		END LOOP;

		v_return = concat('{"constraints reloaded":"',v_36,'","notnull reloaded":"',v_37,'"}');
	END IF;


RETURN v_return;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;