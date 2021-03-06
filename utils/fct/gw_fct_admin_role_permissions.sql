/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2552

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_admin_role_permissions();
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_admin_role_permissions() RETURNS void AS
$BODY$

/*
SELECT SCHEMA_NAME.gw_fct_admin_role_permissions() 
*/

DECLARE 
	v_roleexists text;
	v_dbnname varchar;
	v_schema_array name[];
	v_schemaname varchar;
	v_tablerecord record;
	v_project_type text;
	v_query_text text;
	v_function_name text;
	v_apiservice boolean;	
	v_rolepermissions boolean;
	v_apipublishuser varchar;
	

BEGIN 

	-- search path
	SET search_path = "SCHEMA_NAME", public;
	
	-- Looking for project type
	SELECT wsoftware INTO v_project_type FROM version LIMIT 1;
	
	v_dbnname =  (SELECT current_database());
	v_schema_array := current_schemas(FALSE);
	v_schemaname :=v_schema_array[1];
	
    v_rolepermissions = (SELECT value::boolean FROM config_param_system WHERE parameter='sys_role_permissions');
	v_apiservice = (SELECT value::boolean FROM config_param_system WHERE parameter='sys_api_service');
	
	-- role permissions for schema
	IF v_rolepermissions THEN 
	
		-- Create (if not exists) roles
		SELECT rolname into v_roleexists FROM pg_roles WHERE rolname = 'role_basic';
		IF v_roleexists is null THEN
			CREATE ROLE "role_basic" NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
		END IF;
	
		SELECT rolname into v_roleexists FROM pg_roles WHERE rolname = 'role_om';
		IF v_roleexists is null THEN
			CREATE ROLE "role_om" NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
		END IF;
	
		SELECT rolname into v_roleexists FROM pg_roles WHERE rolname = 'role_edit';
		IF v_roleexists is null THEN
			CREATE ROLE "role_edit" NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
		END IF;
	
		SELECT rolname into v_roleexists FROM pg_roles WHERE rolname = 'role_epa';
		IF v_roleexists is null THEN
			CREATE ROLE "role_epa" NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
		END IF;
	
		SELECT rolname into v_roleexists FROM pg_roles WHERE rolname = 'role_master';
		IF v_roleexists is null THEN
			CREATE ROLE "role_master" NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
		END IF;
	
		SELECT rolname into v_roleexists FROM pg_roles WHERE rolname = 'role_admin';
		IF v_roleexists is null THEN
			CREATE ROLE "role_admin" NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
		END IF;
	
		SELECT rolname into v_roleexists FROM pg_roles WHERE rolname = 'role_crm';
		IF v_roleexists is null THEN
			CREATE ROLE "role_crm" NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;
		END IF;

		-- Grant permissions
		GRANT role_basic TO role_om;
		GRANT role_om TO role_edit;
		GRANT role_edit TO role_epa;
		GRANT role_epa TO role_master;
		GRANT role_master TO role_admin;
	
		-- Grant role admin to postgres user
		GRANT role_admin TO postgres; 	
	
		-- Grant generic permissions
		v_query_text:= 'GRANT ALL ON DATABASE '||v_dbnname||' TO "role_basic";';
		EXECUTE v_query_text;	
	
		v_query_text:= 'GRANT ALL ON SCHEMA '||v_schemaname||' TO "role_basic";';
		EXECUTE v_query_text;
	
		v_query_text:= 'GRANT SELECT ON ALL TABLES IN SCHEMA '||v_schemaname||' TO "role_basic";';
		EXECUTE v_query_text;
	
		v_query_text:= 'GRANT ALL ON ALL SEQUENCES IN SCHEMA  '||v_schemaname||' TO "role_basic";'; 
		EXECUTE v_query_text;
		
		-- Grant all in order to ensure the functionality. We need to review the catalog function before downgrade ALL to SELECT
		v_query_text:= 'GRANT ALL ON ALL FUNCTIONS IN SCHEMA '||v_schemaname||' TO role_basic'; 
		EXECUTE v_query_text;

		-- Grant specificic permissions for tables
		FOR v_tablerecord IN SELECT * FROM audit_cat_table WHERE sys_role_id IS NOT NULL AND isdeprecated != TRUE AND id IN 
		(SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname = 'SCHEMA_NAME' 
		UNION
		SELECT viewname FROM pg_catalog.pg_views WHERE schemaname != 'pg_catalog' AND schemaname = 'SCHEMA_NAME')
		
		LOOP
			v_query_text:= 'GRANT ALL ON TABLE '||v_tablerecord.id||' TO '||v_tablerecord.sys_role_id||';';
			EXECUTE v_query_text;
		END LOOP;
	
		-- Grant specificic permissions for functions
		/* todo
		FOR v_tablerecord IN SELECT * FROM audit_cat_function WHERE project_type=v_project_type
		LOOP
			v_function_name=concat(v_tablerecord.function_name,'(',v_tablerecord.input_params,')');
			v_query_text:= 'GRANT ALL ON FUNCTION '||v_tablerecord.id||' TO '||v_tablerecord.sys_role_id||';';
			EXECUTE v_query_text;
		END LOOP;
		*/

	END IF;

	-- role permissions for api
	IF v_apiservice THEN
	
	    v_apipublishuser = (SELECT value FROM config_param_system WHERE parameter='api_publish_user');
	
		-- Grant generic permissions
		v_query_text:= 'GRANT ALL ON DATABASE '||v_dbnname||' TO '||v_apipublishuser;
		EXECUTE v_query_text;	
	
		v_query_text:= 'GRANT ALL ON SCHEMA '||v_schemaname||' TO '||v_apipublishuser;
		EXECUTE v_query_text;
	
		v_query_text:= 'GRANT SELECT ON ALL TABLES IN SCHEMA '||v_schemaname||' TO '||v_apipublishuser;
		EXECUTE v_query_text;	
	
	END IF;
	
			
RETURN ;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

