/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2222

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_pg2epa(character varying, boolean, boolean, boolean);
DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_pg2epa(character varying, boolean, boolean);
CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_pg2epa(p_data json)  
RETURNS json AS 
$BODY$

/*example
SELECT SCHEMA_NAME.gw_fct_pg2epa($${"client":{"device":3, "infoType":100, "lang":"ES"},
"data":{"status":"off", "resultId":"test1", "useNetworkGeom":"true", "dumpSubcatch":"true"}}$$)
*/

DECLARE
v_return json;
v_input json;
v_result text;
v_usenetworkgeom boolean;
v_dumpsubcatch boolean;
v_inpoptions json;
v_file json;
v_body json;

BEGIN

	-- set search path
    SET search_path = "SCHEMA_NAME", public;

	-- get input data
	v_result =  (p_data->>'data')::json->>'resultId';
	v_usenetworkgeom =  (p_data->>'data')::json->>'useNetworkGeom';
	v_dumpsubcatch =  (p_data->>'data')::json->>'dumpSubcatch';
	
	-- upsert on node rpt_inp result manager table
	DELETE FROM inp_selector_result WHERE cur_user=current_user;
	INSERT INTO inp_selector_result (result_id, cur_user) VALUES (v_result, current_user);

	-- delete audit table
	DELETE FROM audit_check_data WHERE fprocesscat_id = 127 AND user_name=current_user;

	-- setting variables
	v_input = concat('{"data":{"parameters":{"resultId":"',v_result,'", "fprocesscatId":127}}}')::json;

	v_inpoptions = (SELECT (replace (replace (replace (array_to_json(array_agg(json_build_object((t.parameter),(t.value))))::text,'},{', ' , '),'[',''),']',''))::json 
				FROM (SELECT parameter, value FROM config_param_user 
				JOIN audit_cat_param_user a ON a.id=parameter	WHERE cur_user=current_user AND formname='epaoptions')t);
	
	RAISE NOTICE '1 - check system data';
	PERFORM gw_fct_pg2epa_check_data(v_input);

	RAISE NOTICE '2 - Set value default';
	UPDATE inp_outfall SET outfall_type=(SELECT value FROM config_param_user WHERE parameter='epa_outfall_type_vdefault' AND cur_user=current_user) WHERE outfall_type IS NULL;
	UPDATE inp_conduit SET q0=(SELECT value FROM config_param_user WHERE parameter='epa_conduit_q0_vdefault' AND cur_user=current_user)::float WHERE q0 IS NULL;
	UPDATE inp_conduit SET barrels=(SELECT value FROM config_param_user WHERE parameter='epa_conduit_barrels_vdefault' AND cur_user=current_user)::integer WHERE barrels IS NULL;
	UPDATE inp_junction SET y0=(SELECT value FROM config_param_user WHERE parameter='epa_junction_y0_vdefault' AND cur_user=current_user)::float WHERE y0 IS NULL;
	UPDATE raingage SET scf=(SELECT value FROM config_param_user WHERE parameter='epa_rgage_scf_vdefault' AND cur_user=current_user)::float WHERE scf IS NULL;

	RAISE NOTICE '3 - Upsert on rpt_cat_table';
	DELETE FROM rpt_cat_result WHERE result_id=v_result;
	INSERT INTO rpt_cat_result (result_id, inpoptions) VALUES (v_result, v_inpoptions);
		
	RAISE NOTICE '4 - Fill inprpt tables';
	PERFORM gw_fct_pg2epa_fill_data(v_result);
	
	RAISE NOTICE '5 - Make virtual arcs (EPA) transparents for hydraulic model';
	PERFORM gw_fct_pg2epa_join_virtual(v_result);
	
	RAISE NOTICE '6 - Call nod2arc function';
	PERFORM gw_fct_pg2epa_nod2arc_geom(v_result);
	
	RAISE NOTICE '7 - Calling for gw_fct_pg2epa_flowreg_additional function';
	PERFORM gw_fct_pg2epa_nod2arc_data(v_result);
	
	RAISE NOTICE '8 - Try to dump subcatchments';
	IF v_dumpsubcatch THEN
		PERFORM gw_fct_pg2epa_dump_subcatch ();
	END IF;
	
	RAISE NOTICE '9 - check result previous exportation';
	SELECT gw_fct_pg2epa_check_result(v_input) INTO v_return ;
	
	RAISE NOTICE '10 - Create the inp file structure';	
	SELECT gw_fct_pg2epa_create_inp(v_result, null) INTO v_file;
	
	-- manage return message
	v_body = gw_fct_json_object_set_key((v_return->>'body')::json, 'file', v_file);
	v_return = gw_fct_json_object_set_key(v_return, 'body', v_body);
	v_return = replace(v_return::text, '"message":{"priority":1, "text":"Data quality analysis done succesfully"}', '"message":{"priority":1, "text":"Inp export done succesfully"}')::json;
	
	RETURN v_return;	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;