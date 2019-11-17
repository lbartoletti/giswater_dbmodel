/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/
-- The code of this inundation function have been provided by Enric Amat (FISERSA)

--FUNCTION CODE: 2708

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_fct_grafanalytics_mincut(p_data json)
RETURNS integer AS
$BODY$

/*
TO EXECUTE
INSERT INTO anl_mincut_result_cat values (-1);
SELECT SCHEMA_NAME.gw_fct_grafanalytics_mincut('{"data":{"arc":"2001", "parameters":{"id":-1, "process":"base"}}}')
SELECT SCHEMA_NAME.gw_fct_grafanalytics_mincut('{"data":{"arc":"2001", "parameters":{"id":-1, "process":"extended"}}}')

*/


DECLARE
v_class text = 'MINCUT';
v_feature record;
v_data json;
v_arcid text;
v_mincutid integer;
v_mincutprocess text;
v_arc integer;
v_querytext text;
affected_rows numeric;
cont1 integer default 0;

BEGIN

    -- Search path
    SET search_path = "SCHEMA_NAME", public;

	-- get variables
	v_mincutprocess = ((SELECT (p_data::json->>'data')::json->>'parameters')::json->>'process');
	v_arc = (SELECT (p_data::json->>'data')::json->>'arc');
	v_mincutid = ((SELECT (p_data::json->>'data')::json->>'parameters')::json->>'id');

	-- reset graf & audit_log tables
	DELETE FROM temp_anlgraf;
	
	-- reset selectors
	DELETE FROM selector_state WHERE cur_user=current_user;
	INSERT INTO selector_state (state_id, cur_user) VALUES (1, current_user);
	DELETE FROM selector_psector WHERE cur_user=current_user;
	
	-- create graf
	INSERT INTO temp_anlgraf (arc_id, node_1, node_2, water, flag, checkf )
	SELECT arc_id::integer, node_1::integer, node_2::integer, 0, 0, 0 FROM v_edit_arc JOIN value_state_type ON state_type=id 
	WHERE node_1 IS NOT NULL AND node_2 IS NOT NULL AND is_operative=TRUE
	UNION
	SELECT arc_id::integer, node_2::integer, node_1::integer, 0, 0, 0 FROM v_edit_arc JOIN value_state_type ON state_type=id 
	WHERE node_1 IS NOT NULL AND node_2 IS NOT NULL AND is_operative=TRUE;
	
	
	-- set boundary conditions of graf table	
	IF v_mincutprocess = 'base' THEN
		UPDATE temp_anlgraf SET flag=1
		FROM anl_mincut_result_valve WHERE result_id=v_mincutid AND ((unaccess = FALSE AND broken = FALSE) OR (broken = TRUE))
		AND (temp_anlgraf.node_1 = anl_mincut_result_valve.node_id::integer OR temp_anlgraf.node_2 = anl_mincut_result_valve.node_id::integer);
			
	ELSIF v_mincutprocess = 'extended' THEN 
		UPDATE temp_anlgraf SET flag=1
		FROM anl_mincut_result_valve WHERE result_id=v_mincutid AND closed=TRUE 
		AND (temp_anlgraf.node_1 = anl_mincut_result_valve.node_id::integer OR temp_anlgraf.node_2 = anl_mincut_result_valve.node_id::integer);
	END IF;
				
	-- reset water flag
	UPDATE temp_anlgraf SET water=0;
	
	------------------
	-- starting engine
				
	-- set the starting element
	v_querytext = 'UPDATE temp_anlgraf SET water=1 WHERE arc_id='||quote_literal(v_arc)||' AND flag=0'; 
	EXECUTE v_querytext;
			
	EXECUTE v_querytext;-- inundation process
	LOOP	
		cont1 = cont1+1;
		UPDATE temp_anlgraf n SET water= 1, flag=n.flag+1, checkf=1 FROM v_anl_graf a WHERE n.node_1::integer = a.node_1::integer AND n.arc_id::integer = a.arc_id::integer;
		GET DIAGNOSTICS affected_rows =row_count;
		EXIT WHEN affected_rows = 0;
		EXIT WHEN cont1 = 100;
	END LOOP;
	
	-- finish engine
	----------------
	
	-- insert arc results into table
	EXECUTE 'INSERT INTO anl_mincut_result_arc (result_id, arc_id)
		SELECT '||v_mincutid||', a.arc_id FROM (SELECT arc_id FROM temp_anlgraf WHERE water=1)a';

	-- insert node results into table
	EXECUTE 'INSERT INTO anl_mincut_result_node (result_id, node_id)
		SELECT '||v_mincutid||', b.node_1 FROM (SELECT node_1 FROM
		(SELECT node_1,water FROM temp_anlgraf UNION SELECT node_2,water FROM temp_anlgraf)a
		GROUP BY node_1, water HAVING water=1) b';

	-- insert delimiters into table
	IF v_mincutprocess = 'base' THEN
		EXECUTE 'UPDATE anl_mincut_result_valve SET proposed=TRUE WHERE result_id = '||v_mincutid||' AND node_id IN 
			(select node_1::varchar from (SELECT node_1, water FROM temp_anlgraf UNION ALL SELECT node_2,water FROM temp_anlgraf)a
			GROUP BY node_1, water HAVING water=1 AND count(node_1)=2)';
			
	ELSIF v_mincutprocess = 'extended' THEN
		EXECUTE 'INSERT INTO anl_mincut_result_node (result_id, node_id)
			SELECT '||v_mincutid||', b.node_1 FROM (SELECT node_1::varchar FROM
			(SELECT node_1,water FROM temp_anlgraf UNION ALL SELECT node_2,water FROM temp_anlgraf)a
			GROUP BY node_1, water HAVING water=1 AND count(node_1)=2) b';
	END IF;

RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;