/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2206

DROP FUNCTION IF EXISTS "SCHEMA_NAME".gw_fct_anl_node_exit_upper_intro(p_data json);
CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_anl_node_exit_upper_intro(p_data json) 
RETURNS json AS 
$BODY$

/*EXAMPLE
	SELECT SCHEMA_NAME.gw_fct_anl_node_exit_upper_intro($${
	"client":{"device":3, "infoType":100, "lang":"ES"},
	"feature":{"tableName":"v_edit_man_manhole", "id":["60"]},
	"data":{"selectionMode":"previousSelection",
		"saveOnDatabase":true}}$$)
*/


DECLARE
	sys_elev1_var numeric(12,3);
	sys_elev2_var numeric(12,3);
	rec_node record;
	rec_arc record;
	v_version text;
	v_saveondatabase boolean;
	v_result json;
	v_id json;
    v_selectionmode text;
    v_worklayer text;
    v_array text;
    v_sql text;

BEGIN


	SET search_path = "SCHEMA_NAME", public;

	-- Reset values
	DELETE FROM anl_node WHERE cur_user="current_user"() AND fprocesscat_id=11;
    
    	-- select version
	SELECT giswater INTO v_version FROM version order by 1 desc limit 1;

	-- getting input data 	
	v_id :=  ((p_data ->>'feature')::json->>'id')::json;
	v_array :=  replace(replace(replace (v_id::text, ']', ')'),'"', ''''), '[', '(');
	v_worklayer := ((p_data ->>'feature')::json->>'tableName')::text;
	v_selectionmode :=  ((p_data ->>'data')::json->>'selectionMode')::text;
	v_saveondatabase :=  ((p_data ->>'data')::json->>'saveOnDatabase')::boolean;


	-- Computing process
	IF v_array != '()' THEN
		v_sql:= 'SELECT * FROM '||v_worklayer||' where node_id in (select node_1 from v_edit_arc) 
		and node_id in (select node_2 from v_edit_arc) and node_id IN '||v_array||';';
	ELSE
		v_sql:= ('SELECT * FROM '||v_worklayer||' where node_id in (select node_1 from v_edit_arc) 
		and node_id in (select node_2 from v_edit_arc)');
	END IF;
	

	FOR rec_node IN EXECUTE v_sql
		LOOP
			-- Init variables
			sys_elev1_var=0;
			sys_elev2_var=0;

			FOR rec_arc IN SELECT * FROM v_edit_arc where node_1=rec_node.node_id
			LOOP
				sys_elev1_var=greatest(sys_elev1_var,rec_arc.sys_elev1);
			END LOOP;

			FOR rec_arc IN SELECT * FROM v_edit_arc where node_2=rec_node.node_id
			LOOP
				sys_elev2_var=greatest(sys_elev2_var,rec_arc.sys_elev2);
			END LOOP;
			
			IF sys_elev1_var > sys_elev2_var THEN
				INSERT INTO anl_node (node_id, nodecat_id, expl_id, fprocesscat_id, the_geom, arc_distance, state) VALUES
				(rec_node.node_id,rec_node.nodecat_id, rec_node.expl_id, 11, rec_node.the_geom,sys_elev1_var - sys_elev2_var,rec_node.state );
			END IF;
		
		END LOOP;

	-- get results
	SELECT array_to_json(array_agg(row_to_json(row))) INTO v_result FROM (SELECT * FROM anl_node WHERE cur_user="current_user"() AND fprocesscat_id=11) row; 

	IF v_saveondatabase IS FALSE THEN 
		-- delete previous results
		DELETE FROM anl_node WHERE cur_user="current_user"() AND fprocesscat_id=11;
	ELSE
		-- set selector
		DELETE FROM selector_audit WHERE fprocesscat_id=11 AND cur_user=current_user;    
		INSERT INTO selector_audit (fprocesscat_id,cur_user) VALUES (11, current_user);
	END IF;
		
	--    Control nulls
	v_result := COALESCE(v_result, '[]'); 

	--  Return
	RETURN ('{"status":"Accepted", "message":{"priority":1, "text":"This is a test message"}, "version":"'||v_version||'"'||
	     ',"body":{"form":{}'||
		     ',"data":{"result":' || v_result ||
			     '}'||
		       '}'||
	    '}')::json;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;