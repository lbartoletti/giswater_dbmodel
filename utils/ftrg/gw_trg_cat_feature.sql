/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 2758


DROP FUNCTION IF EXISTS SCHEMA_NAME.gw_trg_update_child_view()cascade;
CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_cat_feature()
  RETURNS trigger AS
$BODY$


DECLARE 
	v_schemaname text;
	v_viewname text;
	v_definition text;
	v_id text;
	v_sql text;
	v_layout integer;
	v_projecttype text;
	v_layout_order integer;
	v_partialquerytext text;
	v_querytext text;
	v_table text;
	v_feature_field_id text;
	v_feature record;
	v_query text;

BEGIN	

	
	-- search path
	SET search_path = "SCHEMA_NAME", public;

	-- get input parameters
	v_schemaname = 'SCHEMA_NAME';

	--  Get project type
	SELECT wsoftware INTO v_projecttype FROM version LIMIT 1;
	IF (TG_OP = 'INSERT' OR  TG_OP = 'UPDATE') THEN
		--Controls on update or insert of cat_feature.id check if the new id or child layer has accents, dots or dashes. If so, give an error.
		v_id = array_to_string(ts_lexize('unaccent',NEW.id),',','*');
		
		IF v_id IS NOT NULL OR NEW.id ilike '%.%' OR NEW.id ilike '%-%' THEN
			PERFORM audit_function(3038,2758,NEW.id);
		END IF;

		v_id = array_to_string(ts_lexize('unaccent',NEW.child_layer),',','*');
		
		IF v_id IS NOT NULL OR NEW.child_layer ilike '%-%' OR NEW.child_layer ilike '%.%' THEN
		 	PERFORM audit_function(3038,2758,NEW.child_layer);
		END IF;	

		-- set v_id
		v_id = (lower(NEW.id));
	END IF;


	-- manage audit_cat_param_user parameters
	IF (TG_OP = 'INSERT' OR  TG_OP = 'UPDATE') THEN

		-- get layout_id
		IF NEW.feature_type='NODE' THEN
			v_layout = 9;
		ELSIF  NEW.feature_type='ARC' THEN
			v_layout = 10;
		ELSIF NEW.feature_type='CONNEC' THEN
			v_layout = 12;
		END IF;

		-- get layout_order
		SELECT max(layout_order)+1 INTO v_layout_order FROM audit_cat_param_user WHERE formname='config' and layout_id=v_layout;

		IF v_projecttype = 'WS' THEN
			v_partialquerytext =  concat('JOIN ',lower(NEW.feature_type),'_type ON ',lower(NEW.feature_type),'_type.id = ',
			lower(NEW.feature_type),'type_id WHERE ',lower(NEW.feature_type),'_type.id = ',quote_literal(NEW.id));
			
		ELSIF  v_projecttype = 'UD' THEN
			v_partialquerytext =  concat('LEFT JOIN ',lower(NEW.feature_type),'_type ON ',lower(NEW.feature_type),'_type.id = ',
			lower(NEW.feature_type),'_type WHERE ',lower(NEW.feature_type),'_type.id = ',quote_literal(NEW.id),' OR ',lower(NEW.feature_type),'_type.id IS NULL');
		END IF;
				
		v_table = concat ('cat_',lower(NEW.feature_type));
		
		IF v_table = 'cat_node' OR v_table = 'cat_arc' THEN
			v_feature_field_id = concat (lower(NEW.feature_type), 'cat_id');
			
		ELSIF v_table = 'cat_connec' THEN
			v_feature_field_id = concat (lower(NEW.feature_type), 'at_id');

		ELSIF v_table = 'cat_gully' then 
			v_table ='cat_grate'; 
			v_feature_field_id = 'gratecat_id';
			
		END IF;
		
		v_querytext = concat('SELECT ',v_table,'.id, ', v_table,'.id AS idval FROM ', v_table,' ', v_partialquerytext);

		-- insert parameter
        IF TG_OP = 'UPDATE' THEN
            DELETE FROM audit_cat_param_user WHERE id = concat(lower(OLD.id),'_vdefault');
        END IF;

		INSERT INTO audit_cat_param_user(id, formname, description, sys_role_id, label, isenabled, layout_id, layout_order, 
		dv_querytext, feature_field_id, project_type, isparent, isautoupdate, datatype, widgettype, ismandatory, isdeprecated)
		VALUES (concat(v_id,'_vdefault'),'config',concat ('Value default catalog for ',v_id,' cat_feature'), 'role_edit', concat ('Default catalog for ', v_id), true, v_layout ,v_layout_order,
		v_querytext, v_feature_field_id, lower(v_projecttype),false,false,'text', 'combo',true,false);


	END IF;

	IF TG_OP = 'INSERT' THEN
	
		-- insert into *_type tables new register from cat_feature
		EXECUTE 'SELECT * FROM '||concat(lower(NEW.feature_type),'_type')||' WHERE type = '''||NEW.system_id||''' LIMIT 1'
		INTO v_feature;
	
		IF lower(NEW.feature_type)='arc' THEN
			EXECUTE 'INSERT INTO arc_type (id, type, epa_default, man_table, epa_table, active, code_autofill) 
			VALUES ('''||NEW.id||''', '''||NEW.system_id||''', '''||v_feature.epa_default||''', '''||v_feature.man_table||''', '''||v_feature.epa_table||''', TRUE, '''||v_feature.code_autofill||''')';
		ELSIF lower(NEW.feature_type)='node' THEN
			EXECUTE 'INSERT INTO node_type (id, type, epa_default, man_table, epa_table, active, code_autofill, choose_hemisphere, isarcdivide) 
			VALUES ('''||NEW.id||''', '''||NEW.system_id||''', '''||v_feature.epa_default||''', '''||v_feature.man_table||''', '''||v_feature.epa_table||''', TRUE, '''||v_feature.code_autofill||''', '''||v_feature.choose_hemisphere||''', '''||v_feature.isarcdivide||''')';
		ELSE
			EXECUTE 'INSERT INTO ' || concat(lower(NEW.feature_type),'_type')||' (id, type, man_table, active, code_autofill) VALUES ('''||NEW.id||''', '''||NEW.system_id||''', '''||v_feature.man_table||''', TRUE, '''||v_feature.code_autofill||''')';
		END IF;

		--create child view
		v_query='{"client":{"device":9, "infoType":100, "lang":"ES"}, "form":{}, "feature":{"catFeature":"'||NEW.id||'"}, "data":{"filterFields":{}, "pageInfo":{}, "multi_create":"False" }}';
		PERFORM gw_fct_admin_manage_child_views(v_query::json);
		

		
		--insert definition into config_api_tableinfo_x_infotype if its not present already
		IF NEW.child_layer NOT IN (SELECT tableinfo_id from config_api_tableinfo_x_infotype)
		and NEW.child_layer IS NOT NULL THEN
			INSERT INTO config_api_tableinfo_x_infotype (tableinfo_id,infotype_id,tableinfotype_id)
			VALUES (NEW.child_layer,100,NEW.child_layer);
		END IF;
		RETURN new;

	ELSIF TG_OP = 'UPDATE' THEN

		-- update child views
		--on update and change of cat_feature.id or child layer name		
		IF NEW.child_layer != OLD.child_layer or NEW.id != OLD.id THEN
		
			SELECT child_layer INTO v_viewname FROM cat_feature WHERE id = NEW.id;

			--if cat_feature has changed, rename the id in the definition of a child view
			IF NEW.id != OLD.id THEN
				
				IF v_viewname IS NOT NULL THEN
					--get the old view definition
					EXECUTE 'SELECT pg_get_viewdef('''||v_schemaname||'.'||v_viewname||''', true);'
					INTO v_definition;		

					--replace cat_feture.id in the view definition
					v_definition = replace(v_definition,quote_literal(OLD.id),quote_literal(NEW.id));

					--replace the existing view and drop the old trigger
					EXECUTE 'CREATE OR REPLACE VIEW '||v_schemaname||'.'||NEW.child_layer||' AS '||v_definition||';';   
					EXECUTE 'DROP TRIGGER IF EXISTS gw_trg_edit_'||lower(NEW.feature_type)||'_'||lower(OLD.id)||' ON '||v_viewname||';';		

				END IF;

			END IF;

			--if child layer name has changed, rename it
			IF NEW.child_layer != OLD.child_layer  AND NEW.child_layer IS NOT NULL THEN

				--SELECT child_layer INTO v_viewname FROM cat_feature WHERE id = NEW.id;

				IF v_viewname IS NOT NULL THEN
					--get the old view definition
					EXECUTE 'SELECT pg_get_viewdef('''||v_schemaname||'.'||OLD.child_layer||''', true);'
					INTO v_definition;	

					--replace the existing view
					EXECUTE 'CREATE OR REPLACE VIEW '||v_schemaname||'.'||NEW.child_layer||' AS '||v_definition||';';   
					EXECUTE 'DROP VIEW '||v_schemaname||'.'||OLD.child_layer||';';
				END IF;

				--rename config_api_form_fields formname
				UPDATE config_api_form_fields SET formname=NEW.child_layer WHERE formname=OLD.child_layer AND formtype='feature';

				--rename config_api_tableinfo_x_infotype tableinfo_id and tableinfotype_id
				UPDATE config_api_tableinfo_x_infotype SET tableinfo_id=v_viewname WHERE tableinfo_id=OLD.child_layer;
				UPDATE config_api_tableinfo_x_infotype SET tableinfotype_id=v_viewname WHERE tableinfotype_id=OLD.child_layer;
			END IF;
		
			--create the trigger
			IF v_viewname IS NOT NULL THEN
				EXECUTE 'CREATE TRIGGER gw_trg_edit_'||lower(NEW.feature_type)||'_'||lower(NEW.id)||'
				INSTEAD OF INSERT OR UPDATE OR DELETE ON '||v_viewname||' FOR EACH ROW EXECUTE PROCEDURE gw_trg_edit_'||lower(NEW.feature_type)||'('''||NEW.id||''');';
			END IF;
		END IF;
		
		RETURN NEW;

	ELSIF TG_OP = 'DELETE' THEN

		-- delete child views

		--delete definition from config_api_tableinfo_x_infotype
		DELETE FROM config_api_tableinfo_x_infotype where tableinfo_id=OLD.child_layer OR tableinfotype_id=OLD.child_layer;

		-- delete audit_cat_param_user parameters
		DELETE FROM audit_cat_param_user WHERE id = concat(lower(OLD.id),'_vdefault');

		RETURN NULL;

	END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;