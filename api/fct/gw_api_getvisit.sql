﻿/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2604

CREATE OR REPLACE FUNCTION ws_sample.gw_api_getvisit(p_data json)
  RETURNS json AS
$BODY$

/*EXAMPLE:
--tab data new visit
SELECT ws_sample.gw_api_getvisit($${
"client":{"device":3,"infoType":100,"lang":"es"},
"feature":{"featureType":"visit", "visit_id":null},
"form":{},
"data":{"relatedFeature":{"type":"arc", "id":"2080"},
	"filterFields":{},"pageInfo":null}}$$)

--tab files
SELECT ws_sample.gw_api_getvisit($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"featureType":"visit","tableName":"ve_visit_arc_insp","idName":"visit_id","id":10002},
"form":{"tabData":{"active":false}, "tabFiles":{"active":true}}, 
"data":{"relatedFeature":{"type":"arc"},
	"filterFields":{"filetype":"doc","limit":10},
	"pageInfo":{"orderBy":"tstamp", "orderType":"DESC", "currentPage":3}
	}}$$)

--insertfile action with insert visit (visit null or visit not existing yet on database)
SELECT ws_sample.gw_api_getvisit($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"featureType":"visit","tableName":"ve_visit_arc_insp","idName":"visit_id","id":},
"form":{"tabData":{"active":true},
    "tabFiles":{"active":false}},
"data":{"relatedFeature":{"type":"arc", "id":"2001"},
    "fields":{"class_id":"1","arc_id":"2001","visitcat_id":"1","desperfectes_arc":"2","neteja_arc":"3"},
    "pageInfo":{"orderBy":"tstamp", "orderType":"DESC", "currentPage":3},
    "newFile": {"fileFields":{"visit_id":, "hash":"testhash", "url":"urltest", "filetype":"png"},
            "deviceTrace":{"xcoord":8597877, "ycoord":5346534, "compass":123}}}}$$)

--insertfile action with insert visit
SELECT ws_sample.gw_api_getvisit($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"featureType":"visit","tableName":"ve_visit_arc_insp","idName":"visit_id","id":1},
"form":{"tabData":{"active":true},
    "tabFiles":{"active":false}},
"data":{"relatedFeature":{"type":"arc", "id":"2001"},
    "fields":{"class_id":"1","arc_id":"2001","visitcat_id":"1","desperfectes_arc":"2","neteja_arc":"3"},
    "pageInfo":{"orderBy":"tstamp", "orderType":"DESC", "currentPage":3},
    "newFile": {"fileFields":{"visit_id":1, "hash":"testhash", "url":"urltest", "filetype":"png"},
            "deviceTrace":{"xcoord":8597877, "ycoord":5346534, "compass":123}}}}$$)


-- deletefile action
SELECT ws_sample.gw_api_getvisit($${
"client":{"device":3, "infoType":100, "lang":"ES"},
"feature":{"id":1135},
"form":{"tabData":{"active":false},
    "tabFiles":{"active":true}},
"data":{"relatedFeature":{"type":"arc"},
    "filterFields":{"filetype":"doc","limit":10},
    "pageInfo":{"orderBy":"tstamp", "orderType":"DESC", "currentPage":3},
    "deleteFile": {"feature":{"id":1127}}}}$$)
*/

DECLARE
	v_apiversion text;
	v_schemaname text;
	v_featuretype text;
	v_visitclass integer;
	v_id text;
	v_device integer;
	v_formname text;
	v_tablename text;
	v_fields json [];
	v_fields_text text [];
	v_fields_json json;
	v_forminfo json;
	v_formheader text;
	v_formactions text;
	v_formtabs text;
	v_tabaux json;
	v_active boolean;
	v_featureid varchar ;
	aux_json json;
	v_tab record;
	v_projecttype varchar;
	v_list json;
	v_activedatatab boolean;
	v_activefilestab boolean;
	v_client json;
	v_pageinfo json;
	v_layermanager json;
	v_filterfields json;
	v_data json;
	isnewvisit boolean;
	v_feature json;
	v_newfile json;
	v_deletefile json;
	v_filefeature json;
	v_fileid text;
	v_message json;
	v_message1 text;
	v_message2 text;
	v_return json;

BEGIN

	-- Set search path to local schema
	SET search_path = "ws_sample", public;
	v_schemaname := 'ws_sample';

	--  get api version
	EXECUTE 'SELECT row_to_json(row) FROM (SELECT value FROM config_param_system WHERE parameter=''ApiVersion'') row'
		INTO v_apiversion;

	-- get project type
	SELECT wsoftware INTO v_projecttype FROM version LIMIT 1;

	--  get parameters from input
	v_client = (p_data ->>'client')::json;
	v_device = ((p_data ->>'client')::json->>'device')::integer;
	v_id = ((p_data ->>'feature')::json->>'id')::integer;
	v_featureid = (((p_data ->>'data')::json->>'relatedFeature')::json->>'id');
	v_featuretype = (((p_data ->>'data')::json->>'relatedFeature')::json->>'type');
	v_activedatatab = (((p_data ->>'form')::json->>'tabData')::json->>'active')::boolean;
	v_activefilestab = (((p_data ->>'form')::json->>'tabFiles')::json->>'active')::boolean;
	v_newfile = ((p_data ->>'data')::json->>'newFile')::json;
	v_deletefile = ((p_data ->>'data')::json->>'deleteFile')::json;


	--  get visitclass
	IF v_id IS NULL OR (SELECT id FROM ws_sample.om_visit WHERE id=v_id::bigint) IS NULL THEN
	
		-- TODO: for new visit enhance the visit type using the feature_id
		v_visitclass := (SELECT value FROM config_param_user WHERE parameter = concat('visitclass_vdefault_', v_featuretype) AND cur_user=current_user)::integer;
		IF v_visitclass IS NULL THEN
			v_visitclass := (SELECT id FROM om_visit_class WHERE feature_type=upper(v_featuretype) LIMIT 1);
		END IF;
	ELSE 
		v_visitclass := (SELECT class_id FROM ws_sample.om_visit WHERE id=v_id::bigint);
		IF v_visitclass IS NULL THEN
			v_visitclass := 0;
		END IF;
	END IF;
	
	-- getting visit id
	IF v_id IS NULL THEN
		v_id := ((SELECT max(id)+1 FROM om_visit)+1);
		isnewvisit = true;
	ELSE
		isnewvisit = false;
	END IF;

	--  get formname and tablename
	v_formname := (SELECT formname FROM config_api_visit WHERE visitclass_id=v_visitclass);
	v_tablename := (SELECT tablename FROM config_api_visit WHERE visitclass_id=v_visitclass);

	RAISE NOTICE 'featuretype: %,  visitclass: %,  v_visit: %,  formname: %,  tablename: %,  device: %',v_featuretype, v_visitclass, v_id, v_formname, v_tablename, v_device;

	-- manage actions
	v_filefeature = '{"featureType":"file", "tableName":"om_visit_file", "idName": "id"}';
	IF v_newfile IS NOT NULL THEN

		-- inserting visit on database when visit don't exists
		IF (select id FROM om_visit WHERE id=v_id::int8) IS NULL THEN 
			-- calling setvisit function
			SELECT gw_api_setvisit (p_data) INTO v_return;
			v_id = ((v_return->>'body')::json->>'feature')::json->>'id';
			v_message1 = (v_return->>'message')::json->>'text';
		END IF;

		-- setting input for insert files function
		v_fields_json = gw_fct_json_object_set_key((v_newfile->>'fileFields')::json,'visit_id', v_id::text);
		v_newfile = gw_fct_json_object_set_key(v_newfile, 'fileFields', v_fields_json);
		v_newfile = replace (v_newfile::text, 'fileFields', 'fields');
		v_newfile = concat('{"data":',v_newfile::text,'}');
		v_newfile = gw_fct_json_object_set_key(v_newfile, 'feature', v_filefeature);
		v_newfile = gw_fct_json_object_set_key(v_newfile, 'client', v_client);
	
		-- calling insert files function
		SELECT gw_api_setfileinsert (v_newfile) INTO v_newfile;

		-- building message
		v_message = (v_newfile->>'message');
		v_message = gw_fct_json_object_set_key(v_message, 'hint', v_message1);

	ELSIF v_deletefile IS NOT NULL THEN

		-- setting input function
		v_fileid = ((v_deletefile ->>'feature')::json->>'id')::text;
		v_filefeature = gw_fct_json_object_set_key(v_filefeature, 'id', v_fileid);
		v_deletefile = gw_fct_json_object_set_key(v_deletefile, 'feature', v_filefeature);

		raise notice 'v_deletefile %', v_deletefile;

		-- calling input function
		SELECT gw_api_setdelete(v_deletefile) INTO v_deletefile;
		v_message = (v_deletefile ->>'message')::json;
		
	END IF;
   
	--  Create tabs array	
	v_formtabs := '[';
       
		-- Data tab
		-----------
		--filling tab (only if it's active)
		IF v_activedatatab OR (v_activedatatab IS NOT TRUE AND v_visitclass > 0 AND v_activefilestab IS NOT TRUE) THEN
			IF isnewvisit IS TRUE THEN
				SELECT gw_api_get_formfields( v_formname, 'visit', 'data', null, null, null, null, 'INSERT', null, v_device) INTO v_fields;

				FOREACH aux_json IN ARRAY v_fields
				LOOP

					-- setting feature id value
					IF (aux_json->>'column_id') = 'arc_id' OR (aux_json->>'column_id')='node_id' OR (aux_json->>'column_id')='connec_id' OR (aux_json->>'column_id') ='gully_id' THEN
						v_fields[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields[(aux_json->>'orderby')::INT], 'value', v_featureid);
					END IF;

					-- setting visit id value
					IF (aux_json->>'column_id') = 'visit_id' THEN
						v_fields[(aux_json->>'orderby')::INT] := gw_fct_json_object_set_key(v_fields[(aux_json->>'orderby')::INT], 'value', v_id);	
					END IF;
				END LOOP;
			ELSE 
				SELECT gw_api_get_formfields( v_formname, 'visit', 'data', null, null, null, null, 'INSERT', null, v_device) INTO v_fields;
			END IF;	

			v_fields_json = array_to_json (v_fields);

			v_fields_json := COALESCE(v_fields_json, '{}');		

		END IF;

		-- building tab
		SELECT * INTO v_tab FROM config_api_form_tabs WHERE formname='visit' AND tabname='tabData' and device = v_device LIMIT 1;

		IF v_tab IS NULL THEN 
			SELECT * INTO v_tab FROM config_api_form_tabs WHERE formname='visit' AND tabname='tabData' LIMIT 1;
		END IF;

		v_tabaux := json_build_object('tabName',v_tab.tabname,'tabLabel',v_tab.tablabel, 'tabText',v_tab.tabtext, 
			'tabFunction', v_tab.tabfunction::json, 'tabActions', v_tab.tabactions::json, 'active',v_activedatatab);
		v_tabaux := gw_fct_json_object_set_key(v_tabaux, 'fields', v_fields_json);
		v_formtabs := v_formtabs || v_tabaux::text;


		-- Events tab
		-------------
		IF v_visitclass=0 THEN
		
			-- building tab
			v_tabaux := json_build_object('tabName','tabEvent','tabLabel','Events','tabText','Test text for tab','active',false);
			v_tabaux := gw_fct_json_object_set_key(v_tabaux, 'fields', v_fields_json);
			v_formtabs := v_formtabs || ',' || v_tabaux::text;
		END IF;


		-- Files tab
		------------
		--show tab only if it is not new visit
		IF isnewvisit IS FALSE THEN

			--filling tab (only if it's active)
			IF v_activefilestab THEN

				-- getting filterfields
				v_filterfields := ((p_data->>'data')::json->>'fields')::json;
				v_filterfields := gw_fct_json_object_set_key(v_filterfields, 'visit_id', v_id);

				-- setting filterfields
				v_data := (p_data->>'data');
				v_data := gw_fct_json_object_set_key(v_data, 'filterFields', v_filterfields);
				p_data := gw_fct_json_object_set_key(p_data, 'data', v_data);

				-- getting feature
				v_feature := '{"tableName":"om_visit_file"}';		
			
				-- setting feature
				p_data := gw_fct_json_object_set_key(p_data, 'feature', v_feature);

				--refactor tabNames
				p_data := replace (p_data::text, 'tabFeature', 'feature');

				raise notice 'p_data %', p_data;
				
				-- calling getlist function with modified json
				SELECT gw_api_getlist (p_data) INTO v_fields_json;
			
				-- getting pageinfo and list values
				v_pageinfo = ((v_fields_json->>'body')::json->>'data')::json->>'pageInfo';
				v_fields_json = ((v_fields_json->>'body')::json->>'data')::json->>'fields';
			END IF;
	
			v_fields_json := COALESCE(v_fields_json, '{}');

			-- building tab
			SELECT * INTO v_tab FROM config_api_form_tabs WHERE formname='visit' AND tabname='tabFiles' and device = v_device LIMIT 1;
		
			IF v_tab IS NULL THEN 
				SELECT * INTO v_tab FROM config_api_form_tabs WHERE formname='visit' AND tabname='tabFiles' LIMIT 1;
			END IF;
		
			v_tabaux := json_build_object('tabName',v_tab.tabname,'tabLabel',v_tab.tablabel, 'tabText',v_tab.tabtext, 
				'tabFunction', v_tab.tabfunction::json, 'tabActions', v_tab.tabactions::json, 'active', v_activefilestab);
				
			v_tabaux := gw_fct_json_object_set_key(v_tabaux, 'fields', v_fields_json);

	 		-- setting pageInfo
			v_tabaux := gw_fct_json_object_set_key(v_tabaux, 'pageInfo', v_pageinfo);
			v_formtabs := v_formtabs  || ',' || v_tabaux::text;
		END IF; 		

	--closing tabs array
	v_formtabs := (v_formtabs ||']');

	-- header form
	v_formheader :=concat('VISIT - ',v_id);	

	-- actions and layermanager
	EXECUTE 'SELECT actions, layermanager FROM config_api_form WHERE formname = ''visit'' AND projecttype ='||quote_literal(LOWER(v_projecttype))
			INTO v_formactions, v_layermanager;

	v_forminfo := gw_fct_json_object_set_key(v_forminfo, 'formActions', v_formactions);
		
	-- Create new form
	v_forminfo := gw_fct_json_object_set_key(v_forminfo, 'formId', 'F11'::text);
	v_forminfo := gw_fct_json_object_set_key(v_forminfo, 'formName', v_formheader);
	v_forminfo := gw_fct_json_object_set_key(v_forminfo, 'formTabs', v_formtabs::json);

	--  Control NULL's
	v_apiversion := COALESCE(v_apiversion, '{}');
	v_id := COALESCE(v_id, '{}');
	v_message := COALESCE(v_message, '{}');
	v_forminfo := COALESCE(v_forminfo, '{}');
	v_tablename := COALESCE(v_tablename, '{}');
	v_layermanager := COALESCE(v_layermanager, '{}');
  
	-- Return
	RETURN ('{"status":"Accepted", "message":'||v_message||', "apiVersion":'||v_apiversion||
             ',"body":{"feature":{"featureType":"visit", "tableName":"'||v_tablename||'", "idname":"visit_id", "id":'||v_id||'}'||
		    ', "form":'||v_forminfo||
		    ', "data":{"layerManager":'||v_layermanager||'}}'||
		    '}')::json;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



