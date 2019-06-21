/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2314

DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_pg2epa(character varying, boolean, boolean);
DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_fct_pg2epa(character varying, boolean);
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_pg2epa(p_data json)  
RETURNS json AS 
$BODY$

/*EXAMPLE
SELECT SCHEMA_NAME.gw_fct_pg2epa_recursive($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"data":{"status":"start", "resultId":"test1", "useNetworkGeom":"true"}}$$)
*/

DECLARE
	v_mandatory_nodarc boolean = false;
	v_return json;
	v_input json;
	v_result text;
	v_usnetworkgeom boolean;
      
BEGIN

	--  Get input data
	v_result =  (p_data->>'data')::json->>'resultId';
	v_usnetworkgeom =  (p_data->>'data')::json->>'useNetworkGeom';
	

	--  Search path
	SET search_path = "SCHEMA_NAME", public;

	-- Getting user parameteres
	v_mandatory_nodarc = (SELECT value FROM config_param_user WHERE parameter='inp_options_nodarc_onlymandatory' AND cur_user=current_user);
	
	RAISE NOTICE 'Starting pg2epa process.';

	-- Upsert on rpt_cat_table
	DELETE FROM rpt_cat_result WHERE result_id=result_id_var;
	INSERT INTO rpt_cat_result (result_id) VALUES (result_id_var);
	
	-- Upsert on node rpt_inp result manager table
	DELETE FROM inp_selector_result WHERE cur_user=current_user;
	INSERT INTO inp_selector_result (result_id, cur_user) VALUES (result_id_var, current_user);
	
	IF v_usenetworkgeom IS FALSE THEN
		-- Fill inprpt tables
		PERFORM gw_fct_pg2epa_fill_data(result_id_var);
	END IF;
	
	-- Update demand values filtering by dscenario
	PERFORM gw_fct_pg2epa_dscenario(result_id_var);

	IF v_usenetworkgeom IS FALSE THEN
		-- Calling for gw_fct_pg2epa_nod2arc function
		PERFORM gw_fct_pg2epa_nod2arc(result_id_var, v_mandatory_nodarc);
			
		-- Calling for gw_fct_pg2epa_pump_additional function;
		PERFORM gw_fct_pg2epa_pump_additional(result_id_var);
		
	END IF;

	-- set demand and patterns in function of demand type and pattern method choosed
	PERFORM gw_fct_pg2epa_rtc(result_id_var);				

	-- Calling for modify the valve status
	PERFORM gw_fct_pg2epa_valve_status(result_id_var, v_mandatory_nodarc);
	
	-- Calling for the export function
	PERFORM gw_fct_utils_csv2pg_export_epanet_inp(result_id_var, null);
	
	-- manage return message
	v_input = concat('{"client":{"device":3, "infoType":100, "lang":"ES"},"feature":{},"data":{"parameters":{"resultId":"',result_id_var,'"},"saveOnDatabase":true}}')::json;
	SELECT gw_fct_pg2epa_check_data(v_input) INTO v_return;

	v_return = replace(v_return::text, '"message":{"priority":1, "text":"Data quality analysis done succesfully"}', '"message":{"priority":1, "text":"Inp export done succesfully"}')::json;
	
RETURN v_return;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;