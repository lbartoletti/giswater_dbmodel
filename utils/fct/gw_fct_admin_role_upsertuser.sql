/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2780

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_admin_role_upsertuser(json);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_admin_role_upsertuser(p_data json)
  RETURNS json AS
$BODY$

/*
SELECT SCHEMA_NAME.gw_fct_admin_role_upsertuser($${
"client":{"device":9, "infoType":100, "lang":"ES"}, 
"form":{}, 
"data":{"filterFields":{}, "pageInfo":{}, "user_name":"john", "password":"123", "role":"role_basic", "action":"insert", 
"manager_id":["1","2"], "gw_schema":["SCHEMA_NAME","SCHEMA_NAME"]}}$$);

SELECT SCHEMA_NAME.gw_fct_admin_role_upsertuser($${
"client":{"device":9, "infoType":100, "lang":"ES"}, 
"form":{}, 
"data":{"filterFields":{}, "pageInfo":{}, "user_name":"john", "password":"32", "role":"role_edit", "action":"update","manager_id":["1"],
"gw_schema":["SCHEMA_NAME","SCHEMA_NAME"]}}$$);

SELECT SCHEMA_NAME.gw_fct_admin_role_upsertuser($${
"client":{"device":9, "infoType":100, "lang":"ES"}, 
"form":{}, 
"data":{"filterFields":{}, "pageInfo":{}, "user_name":"john", "password":"456", "role":null, "action":"update",
"gw_schema":["SCHEMA_NAME","SCHEMA_NAME"]}}$$);

SELECT SCHEMA_NAME.gw_fct_admin_role_upsertuser($${
"client":{"device":9, "infoType":100, "lang":"ES"}, 
"form":{}, "data":{"filterFields":{}, "pageInfo":{}, "user_name":"john", "password":null, "role":null, "action":"delete","manager_id":null,
"gw_schema":["SCHEMA_NAME","SCHEMA_NAME"]}}$$);
*/


DECLARE
	v_user_name text;
	v_password text;
	v_role text;
	v_action text;
	v_current_role text;
	v_version text;
	v_manager json;
	v_manager_array text[];
	v_expl_array integer[];
	v_current_manager text[];
	v_sys_expl_x_user boolean;
	v_gw_schema json;
	v_gw_schema_array text[];

	v_result_point json;
	v_result_line json;
	v_result_polygon json;
	v_result json;
	v_result_info json;	
	v_return json;	

	rec_schema text;
	rec_expl integer;
	rec_manager text;
	rec record;

BEGIN

	SET search_path = 'SCHEMA_NAME' , public;

	SELECT  giswater INTO  v_version FROM version order by id desc limit 1;

	v_user_name = lower(((p_data ->>'data')::json->>'user_name')::text);
	v_password = ((p_data ->>'data')::json->>'password')::text;
	v_role = ((p_data ->>'data')::json->>'role')::text;
	v_action = ((p_data ->>'data')::json->>'action')::text;
	v_manager = ((p_data->>'data')::json->>'manager_id')::text;
	v_gw_schema = ((p_data->>'data')::json->>'gw_schema')::text;
	
	--change managers and schema list into array
	v_manager_array=(SELECT array_agg(value) AS list FROM json_array_elements_text(v_manager) );
	v_gw_schema_array=(SELECT array_agg(value) AS list FROM json_array_elements_text(v_gw_schema) );

	-- delete old values on result table
	DELETE FROM audit_check_data WHERE fprocesscat_id=107 AND user_name=current_user;
	
	-- Starting process
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (107, null, 4, 'ROLE MANAGEMENT');
	INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) VALUES (107, null, 4, '-------------------------------------------------------------');
    

	IF v_action = 'insert' THEN


		--create user in  a database, encrypt password and assign a role	
		IF (SELECT 1 FROM pg_roles WHERE rolname=v_user_name) is null THEN
		
			EXECUTE 'CREATE USER '||v_user_name||' WITH ENCRYPTED PASSWORD '''||v_password||''';';

			INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) 
			VALUES (107, null, 1, concat('INFO: User ',v_user_name,' created in a database'));
	
		ELSE
			RETURN audit_function(3040,2780);
		END IF;

		EXECUTE 'GRANT '||v_role||' TO '||v_user_name||';';
		
		INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) 
		VALUES (107, null, 1, concat('INFO: Role ',v_role,' granted.'));
		
		FOREACH rec_schema IN ARRAY v_gw_schema_array LOOP
			--insert user into user catalog
			EXECUTE 'INSERT INTO '||rec_schema||'.cat_users (id,name,sys_role) 
			VALUES ('''||v_user_name||''','''||v_user_name||''','''||v_role||''') ON CONFLICT (id) DO NOTHING;';

			INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) 
			VALUES (107, null, 1, concat('INFO: User ',v_user_name,' inserted into cat_users of schema ',rec_schema,'.'));

			EXECUTE 'SELECT value::boolean  
			FROM '||rec_schema||'.config_param_system WHERE parameter = ''sys_exploitation_x_user'''
			INTO v_sys_expl_x_user;

			IF v_sys_expl_x_user THEN
				--insert user into related cat_manager and exploitation if managing exploitation for user is used (true)
				FOREACH rec_manager IN ARRAY v_manager_array LOOP
					EXECUTE 'UPDATE '||rec_schema||'.cat_manager 
					SET username = array_append(username,'''||v_user_name||''') WHERE id = '||rec_manager::integer||';';
				END LOOP;
				
				INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) 
				VALUES (107, null, 1, concat('INFO: User ',v_user_name,' inserted into cat_manager of schema ',rec_schema,'.'));

				--insert values for the new user into basic selectors
				EXECUTE 'INSERT INTO '||rec_schema||'.selector_state (state_id, cur_user) 
				VALUES (1,'''||v_user_name||''') ON CONFLICT (state_id,cur_user) DO NOTHING';

				EXECUTE 'INSERT INTO '||rec_schema||'.selector_expl (expl_id, cur_user) 
				SELECT expl_id, '''||v_user_name||''' FROM '||rec_schema||'.exploitation_x_user 
				WHERE username= '''||v_user_name||''' ON CONFLICT (expl_id,cur_user) DO NOTHING';
	
				INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) 
				VALUES (107, null, 1, concat('INFO: User ',v_user_name,' inserted into expl and state selectors of schema ',rec_schema,'.'));

			ELSE
				--insert values for the new user into basic selectors
				EXECUTE 'INSERT INTO '||rec_schema||'.selector_state (state_id, cur_user) 
				VALUES (1,'''||v_user_name||''') ON CONFLICT (state_id,cur_user) DO NOTHING';
	
				EXECUTE 'INSERT INTO '||rec_schema||'.selector_expl (expl_id, cur_user) 
				SELECT expl_id, '''||v_user_name||''' FROM '||rec_schema||'.exploitation 
				ON CONFLICT (expl_id,cur_user) DO NOTHING';
	
				INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) 
				VALUES (107, null, 1, concat('INFO: User ',v_user_name,' inserted into expl and state selectors of schema ',rec_schema,'.'));

			END IF;


		END LOOP;

	ElSIF v_action = 'update' THEN

		--assign a new password if its not null
		IF v_password IS NOT NULL THEN

			EXECUTE 'ALTER USER '||v_user_name||' WITH ENCRYPTED PASSWORD '''||v_password||''';';

			INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) 
			VALUES (107, null, 1, concat('INFO: Password changed for user ',v_user_name,'.'));
		END IF;

		--check users current role
		EXECUTE 'SELECT rolname FROM pg_user u JOIN pg_auth_members m ON (m.member = u.usesysid) JOIN pg_roles r ON (r.oid = m.roleid)
		WHERE  u.usename = '''||v_user_name||''';'
		INTO v_current_role;

		--assign a new role if its different than the current one and change values in users catalog
		IF v_role != v_current_role AND v_role IS NOT NULL THEN

			EXECUTE ' REVOKE '||v_current_role||' FROM '||v_user_name||';';

			EXECUTE ' GRANT '||v_role||' TO '||v_user_name||';';

			INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) 
			VALUES (107, null, 1, concat('INFO: Role changed to ',v_role,'.'));

		FOREACH rec_schema IN ARRAY v_gw_schema_array LOOP

			--update cat_users with new role
			IF v_role != v_current_role AND v_role IS NOT NULL THEN

				EXECUTE 'UPDATE '||rec_schema||'.cat_users SET sys_role = '''||v_role||''' WHERE id = '''||v_user_name||''';';

			END IF;
			
			EXECUTE 'SELECT value::boolean 
			FROM '||rec_schema||'.config_param_system WHERE parameter = ''sys_exploitation_x_user'''
			INTO v_sys_expl_x_user;

			--if managing exploitation for user is used (true)
			IF v_sys_expl_x_user THEN

				--check to which manager user is assigned
				EXECUTE 'select array_agg(id) 
				from (select id, username as users from '||rec_schema||'.cat_manager) a where '''||v_user_name||''' =any(users)'
				INTO v_current_manager ;

				--change assignation to managers if it changed
				IF (v_current_manager <> v_manager_array) OR (v_current_manager is null and v_manager_array iS NOT NULL) THEN
					--remove user from current managers
					EXECUTE 'UPDATE '||rec_schema||'.cat_manager 
					SET username = array_remove(username,'''||v_user_name||''') WHERE '''||v_user_name||''' = any(username);';

					--add user to new managers
					FOREACH rec_manager IN ARRAY v_manager_array LOOP
						EXECUTE 'UPDATE '||rec_schema||'.cat_manager 
						SET username = array_append(username,'''||v_user_name||''') WHERE id = '||rec_manager::integer||';';

						INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) 
						VALUES (107, null, 1, concat('INFO: User ',v_user_name,' assigned to new managers.'));
					END LOOP;
				END IF;

			END IF;
		END LOOP;
		END IF;

	ElSIF v_action = 'delete' THEN

		FOREACH rec_schema IN ARRAY v_gw_schema_array LOOP
			--remove values for user from all the selectors and delete user
			FOR rec IN EXECUTE 'SELECT * FROM information_schema.tables 
			WHERE table_name ilike ''%selector%'' AND table_name!=''anl_mincut_selector_valve'' 
			AND table_schema= '''||rec_schema||'''' LOOP

				EXECUTE 'DELETE FROM '||rec_schema||'.'||rec.table_name||' WHERE cur_user = '''||v_user_name||''';';
			END LOOP;

			INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) 
			VALUES (107, null, 1, concat('INFO: User ',v_user_name,' deleted from selectors.'));

			EXECUTE 'SELECT value::boolean  
			FROM '||rec_schema||'.config_param_system WHERE parameter = ''sys_exploitation_x_user'''			
			INTO v_sys_expl_x_user;

			--if managing exploitation for user is used (true)
			IF v_sys_expl_x_user THEN
				--remove user from cat_manager
				EXECUTE 'UPDATE '||rec_schema||'.cat_manager 
				SET username = array_remove(username,'''||v_user_name||''') WHERE '''||v_user_name||''' = any(username);';

				INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) 
				VALUES (107, null, 1, concat('INFO: User ',v_user_name,' deleted from cat_manager.'));
			END IF;

			--remove user from users catalog
			EXECUTE 'DELETE FROM '||rec_schema||'.cat_users WHERE id = '''||v_user_name||''';';
			
			INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) 
			VALUES (107, null, 1, concat('INFO: User ',v_user_name,' deleted from cat_users.'));

		END LOOP;

		

		EXECUTE 'DROP USER '||v_user_name||';';

		INSERT INTO audit_check_data (fprocesscat_id, result_id, criticity, error_message) 
		VALUES (107, null, 1, concat('INFO: User ',v_user_name,' deleted from database.'));

	END IF;
	
	-- get results
	-- info
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result
	FROM (SELECT id, error_message as message FROM audit_check_data WHERE user_name="current_user"() 
	AND fprocesscat_id=107 order by criticity desc, id asc) row; 
	v_result := COALESCE(v_result, '{}'); 
	v_result_info = concat ('{"geometryType":"", "values":',v_result, '}');
	v_result_point:=COALESCE(v_result_point,'{}');
	v_result_line:=COALESCE(v_result_line,'{}');
	v_result_polygon:=COALESCE(v_result_polygon,'{}');

		--return definition for v_audit_check_result
	v_return= ('{"status":"Accepted", "message":{"level":1, "text":"Data quality analysis done succesfully"}, "version":"'||v_version||'"'||
		     ',"body":{"form":{}'||
			     ',"data":{ "info":'||v_result_info||','||
					'"point":'||v_result_point||','||
					'"line":'||v_result_line||','||
					'"polygon":'||v_result_polygon||
			      '}}}')::json;

	RETURN v_return;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
