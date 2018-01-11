﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: XXXX

DROP FUNCTION IF EXISTS ws_data.gw_fct_audit_project(integer);
CREATE OR REPLACE FUNCTION ws_data.gw_fct_audit_project(fprocesscat_id_aux integer)
  RETURNS integer AS
$BODY$

DECLARE 
table_record 	record;
query_text 	text;
sys_rows_aux 	text;
audit_rows_aux 	integer;
compare_sign_aux text;
enabled_bool 	boolean;
diference_aux 	integer;

BEGIN 


	-- search path
	SET search_path = "ws_data", public;

	-- init process
	enabled_bool:=FALSE;

	
	IF fprocesscat_id_aux=1 THEN

		-- start process
		FOR table_record IN SELECT * FROM audit_cat_table WHERE qgis_role_id IN (SELECT rolname FROM pg_authid  WHERE pg_has_role('user_basic', pg_authid.oid, 'member'))
		LOOP
			IF table_record.id NOT IN (SELECT table_id FROM audit_project WHERE user_name=current_user AND fprocesscat_id=fprocesscat_id_aux) THEN
				INSERT INTO audit_project VALUES (table_record.id, 1, table_record.qgis_criticity, FALSE, table_record.qgis_message);
			ELSE 
				UPDATE audit_project SET criticity=table_record.qgis_criticity, enabled=true, message=table_record.qgis_message;
			END IF;		

		END LOOP;

	ELSIF fprocesscat_id_aux=2 THEN

		DELETE FROM audit_project WHERE user_name=current_user AND fprocesscat_id=fprocesscat_id_aux;

		-- start process
		FOR table_record IN SELECT * FROM audit_cat_table WHERE sys_criticity>0
		LOOP	
			-- audit rows
			query_text:= 'SELECT count(*) FROM '||table_record.id;
			EXECUTE query_text INTO audit_rows_aux;
	
			-- system rows
			compare_sign_aux= substring(table_record.sys_rows from 1 for 1);
			sys_rows_aux=substring(table_record.sys_rows from 2 for 999);
			IF (sys_rows_aux>='0' and sys_rows_aux<'9999999') THEN
	
			ELSIF sys_rows_aux like'@%' THEN 
				query_text=substring(table_record.sys_rows from 3 for 999);
				IF query_text IS NULL THEN
					raise exception 'query_text %', table_record.id;
				END IF;
				EXECUTE query_text INTO sys_rows_aux;
			ELSE
				query_text='SELECT count(*) FROM '||sys_rows_aux;
				IF query_text IS NULL THEN
					raise exception 'query_text %', table_record.id;
				END IF;
				EXECUTE query_text INTO sys_rows_aux;
			END IF;
	
			IF compare_sign_aux='>'THEN 
				compare_sign_aux='=>';
			END IF;
	
			diference_aux=audit_rows_aux-sys_rows_aux::integer;
		
			-- compare audit rows & system rows
			IF compare_sign_aux='=' THEN
					IF diference_aux=0 THEN
					enabled_bool=TRUE;
				ELSE
					enabled_bool=FALSE;
				END IF;
					
			ELSIF compare_sign_aux='=>' THEN
				IF diference_aux >= 0 THEN
					enabled_bool=TRUE;
				ELSE	
					enabled_bool=FALSE;
				END IF;	
			END IF;

			
			INSERT INTO audit_project VALUES (table_record.id,  fprocesscat_id_aux, table_record.sys_criticity, enabled_bool, concat('Table needs ',compare_sign_aux,' ',sys_rows_aux,' rows and it has ',audit_rows_aux,' rows'), (SELECT current_user));
		END LOOP;
	END IF;

		
RETURN 1;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



