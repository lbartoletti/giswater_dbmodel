/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 1302

CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_edit_arc()
  RETURNS trigger AS
$BODY$
DECLARE 

    v_inp_table varchar;
    v_man_table varchar;
    v_sql varchar;
	v_code_autofill_bool boolean;
	v_count integer;
	v_promixity_buffer double precision;
	v_edit_enable_arc_nodes_update boolean;
	v_link_path varchar;
	v_new_arc_type text;
	v_old_arc_type text;
	v_customfeature text;
	v_addfields record;
	v_new_value_param text;
	v_old_value_param text;
	v_featurecat text;

BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
	        v_man_table:= TG_ARGV[0];

	--modify values for custom view inserts	
	IF v_man_table IN (SELECT id FROM arc_type) THEN
		v_customfeature:=v_man_table;
		v_man_table:=(SELECT man_table FROM arc_type WHERE id=v_man_table);
	END IF;

	v_promixity_buffer = (SELECT "value" FROM config_param_system WHERE "parameter"='proximity_buffer');
	v_edit_enable_arc_nodes_update = (SELECT "value" FROM config_param_system WHERE "parameter"='edit_enable_arc_nodes_update');

	-- profilactic issue to keep to keep stable edit_disable_statetopocontrol
	--UPDATE config_param_user SET value=FALSE WHERE parameter = 'edit_disable_statetopocontrol' AND cur_user=current_user;					
	
    IF TG_OP = 'INSERT' THEN
    
        -- Arc ID
        IF (NEW.arc_id IS NULL) THEN
			PERFORM setval('urn_id_seq', gw_fct_setvalurn(),true);
            NEW.arc_id:= (SELECT nextval('urn_id_seq'));
        END IF;
        
        -- Arc catalog ID
		IF (NEW.arccat_id IS NULL) THEN
			IF ((SELECT COUNT(*) FROM cat_arc) = 0) THEN
				RETURN audit_function(1020,1302); 
			END IF; 

			-- get vdefault values using config user values
			IF v_customfeature IS NOT NULL THEN
				NEW.arccat_id:= (SELECT "value" FROM config_param_user WHERE "parameter"=lower(concat(v_customfeature,'_vdefault')) AND "cur_user"="current_user"() LIMIT 1);
			ELSE
				NEW.arccat_id:= (SELECT "value" FROM config_param_user WHERE "parameter"='arccat_vdefault' AND "cur_user"="current_user"() LIMIT 1);

				-- get first value (last chance)
				IF (NEW.arccat_id IS NULL) THEN
					NEW.arccat_id := (SELECT id FROM cat_arc LIMIT 1);
				END IF;    
			END IF;

			-- get values using proximity
			IF (NEW.arccat_id IS NULL) THEN
				NEW.arccat_id := (SELECT arccat_id from arc WHERE ST_DWithin(NEW.the_geom, arc.the_geom,0.001) LIMIT 1);
			END IF;

			IF (NEW.arccat_id IS NULL) THEN
				PERFORM audit_function(1088,1302);
			END IF;
   
		END IF;

        -- Sector ID
        IF (NEW.sector_id IS NULL) THEN
			IF ((SELECT COUNT(*) FROM sector) = 0) THEN
                RETURN audit_function(1008,1302);  
			END IF;
				SELECT count(*)into v_count FROM sector WHERE ST_DWithin(NEW.the_geom, sector.the_geom,0.001);
			IF v_count = 1 THEN
				NEW.sector_id = (SELECT sector_id FROM sector WHERE ST_DWithin(NEW.the_geom, sector.the_geom,0.001) LIMIT 1);
			ELSIF v_count > 1 THEN
				NEW.sector_id =(SELECT sector_id FROM v_edit_node WHERE ST_DWithin(NEW.the_geom, v_edit_node.the_geom, v_promixity_buffer) 
				order by ST_Distance (NEW.the_geom, v_edit_node.the_geom) LIMIT 1);
			END IF;	
			IF (NEW.sector_id IS NULL) THEN
				NEW.sector_id := (SELECT "value" FROM config_param_user WHERE "parameter"='sector_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			END IF;
			IF (NEW.sector_id IS NULL) THEN
                RETURN audit_function(1010,1302,NEW.arc_id);          
            END IF;            
        END IF;
        
	-- Dma ID
        IF (NEW.dma_id IS NULL) THEN
			IF ((SELECT COUNT(*) FROM dma) = 0) THEN
                RETURN audit_function(1012,1302);  
            END IF;
				SELECT count(*)into v_count FROM dma WHERE ST_DWithin(NEW.the_geom, dma.the_geom,0.001);
			IF v_count = 1 THEN
				NEW.dma_id := (SELECT dma_id FROM dma WHERE ST_DWithin(NEW.the_geom, dma.the_geom,0.001) LIMIT 1);
			ELSIF v_count > 1 THEN
				NEW.dma_id =(SELECT dma_id FROM v_edit_node WHERE ST_DWithin(NEW.the_geom, v_edit_node.the_geom, v_promixity_buffer) 
				order by ST_Distance (NEW.the_geom, v_edit_node.the_geom) LIMIT 1);
			END IF;
			IF (NEW.dma_id IS NULL) THEN
				NEW.dma_id := (SELECT "value" FROM config_param_user WHERE "parameter"='dma_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			END IF; 
            IF (NEW.dma_id IS NULL) THEN
                RETURN audit_function(1014,1302,NEW.arc_id);  
            END IF;            
        END IF;
	
		-- Verified
        IF (NEW.verified IS NULL) THEN
            NEW.verified := (SELECT "value" FROM config_param_user WHERE "parameter"='verified_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;
		
		-- Presszone
        IF (NEW.presszonecat_id IS NULL) THEN
            NEW.presszonecat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='presszone_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;

		-- State
        IF (NEW.state IS NULL) THEN
            NEW.state := (SELECT "value" FROM config_param_user WHERE "parameter"='state_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;

		-- State_type
		IF (NEW.state_type IS NULL) THEN
			NEW.state_type := (SELECT "value" FROM config_param_user WHERE "parameter"='statetype_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;

		--check relation state - state_type
        IF NEW.state_type NOT IN (SELECT id FROM value_state_type WHERE state = NEW.state) THEN
        	RETURN audit_function(3036,1318,NEW.state::text);
       	END IF;

		--Inventory	
		NEW.inventory := (SELECT "value" FROM config_param_system WHERE "parameter"='edit_inventory_sysvdefault');

		--Publish
		NEW.publish := (SELECT "value" FROM config_param_system WHERE "parameter"='edit_publish_sysvdefault');	
			
		-- Exploitation
		IF (NEW.expl_id IS NULL) THEN
			NEW.expl_id := (SELECT "value" FROM config_param_user WHERE "parameter"='exploitation_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			IF (NEW.expl_id IS NULL) THEN
				NEW.expl_id := (SELECT expl_id FROM exploitation WHERE ST_DWithin(NEW.the_geom, exploitation.the_geom,0.001) LIMIT 1);
				IF (NEW.expl_id IS NULL) THEN
					PERFORM audit_function(2012,1302,NEW.arc_id);
				END IF;		
			END IF;
		END IF;

		-- Municipality 
		IF (NEW.muni_id IS NULL) THEN
			NEW.muni_id := (SELECT "value" FROM config_param_user WHERE "parameter"='municipality_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			IF (NEW.muni_id IS NULL) THEN
				NEW.muni_id := (SELECT muni_id FROM ext_municipality WHERE ST_DWithin(NEW.the_geom, ext_municipality.the_geom,0.001) LIMIT 1);
				IF (NEW.muni_id IS NULL) THEN
					PERFORM audit_function(2024,1302,NEW.arc_id);
				END IF;	
			END IF;
		END IF;

		SELECT code_autofill INTO v_code_autofill_bool FROM arc_type JOIN cat_arc ON arc_type.id=cat_arc.arctype_id WHERE cat_arc.id=NEW.arccat_id;
	
		--Copy id to code field	
		IF (NEW.code IS NULL AND v_code_autofill_bool IS TRUE) THEN 
			NEW.code=NEW.arc_id;
		END IF;

        -- Set EPA type
       	IF (NEW.epa_type IS NULL) THEN
			NEW.epa_type = 'PIPE';   
		END IF;       
    
		-- Workcat_id
		IF (NEW.workcat_id IS NULL) THEN
			NEW.workcat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='workcat_vdefault' AND "cur_user"="current_user"() LIMIT 1);
		END IF;
		
		-- Ownercat_id
        IF (NEW.ownercat_id IS NULL) THEN
            NEW.ownercat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='ownercat_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;
		
		-- Soilcat_id
        IF (NEW.soilcat_id IS NULL) THEN
            NEW.soilcat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='soilcat_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;

		-- Builtdate
		IF (NEW.builtdate IS NULL) THEN
			NEW.builtdate :=(SELECT "value" FROM config_param_user WHERE "parameter"='builtdate_vdefault' AND "cur_user"="current_user"() LIMIT 1);
		END IF;
				
	
		-- LINK
	    IF (SELECT "value" FROM config_param_system WHERE "parameter"='edit_automatic_insert_link')::boolean=TRUE THEN
	       NEW.link=NEW.arc_id;
	    END IF;
		
		v_featurecat = (SELECT arctype_id FROM cat_arc WHERE id = NEW.arccat_id);

		--Location type
		IF NEW.location_type IS NULL AND (SELECT value FROM config_param_user WHERE parameter = 'feature_location_vdefault' AND cur_user = current_user)  = v_featurecat THEN
			NEW.location_type = (SELECT value FROM config_param_user WHERE parameter = 'featureval_location_vdefault' AND cur_user = current_user);
		END IF;

		IF NEW.location_type IS NULL THEN
			NEW.location_type = (SELECT value FROM config_param_user WHERE parameter = 'arc_location_vdefault' AND cur_user = current_user);
		END IF;

		--Fluid type
		IF NEW.fluid_type IS NULL AND (SELECT value FROM config_param_user WHERE parameter = 'feature_fluid_vdefault' AND cur_user = current_user)  = v_featurecat THEN
			NEW.fluid_type = (SELECT value FROM config_param_user WHERE parameter = 'featureval_fluid_vdefault' AND cur_user = current_user);
		END IF;

		IF NEW.fluid_type IS NULL THEN
			NEW.fluid_type = (SELECT value FROM config_param_user WHERE parameter = 'arc_fluid_vdefault' AND cur_user = current_user);
		END IF;

		--Category type
		IF NEW.category_type IS NULL AND (SELECT value FROM config_param_user WHERE parameter = 'feature_category_vdefault' AND cur_user = current_user)  = v_featurecat THEN
			NEW.category_type = (SELECT value FROM config_param_user WHERE parameter = 'featureval_category_vdefault' AND cur_user = current_user);
		END IF;

		IF NEW.category_type IS NULL THEN
			NEW.category_type = (SELECT value FROM config_param_user WHERE parameter = 'arc_category_vdefault' AND cur_user = current_user);
		END IF;	

		--Function type
		IF NEW.function_type IS NULL AND (SELECT value FROM config_param_user WHERE parameter = 'feature_function_vdefault' AND cur_user = current_user)  = v_featurecat THEN
			NEW.function_type = (SELECT value FROM config_param_user WHERE parameter = 'featureval_function_vdefault' AND cur_user = current_user);
		END IF;

		IF NEW.function_type IS NULL THEN
			NEW.function_type = (SELECT value FROM config_param_user WHERE parameter = 'arc_function_vdefault' AND cur_user = current_user);
		END IF;

        -- FEATURE INSERT
		INSERT INTO arc (arc_id, code, node_1,node_2, arccat_id, epa_type, sector_id, "state", state_type, annotation, observ,"comment",custom_length,dma_id, presszonecat_id, soilcat_id, function_type, category_type, fluid_type, location_type,
					workcat_id, workcat_id_end, buildercat_id, builtdate,enddate, ownercat_id, muni_id, postcode, streetaxis_id, postnumber, postcomplement,
					streetaxis2_id,postnumber2, postcomplement2,descript,link,verified,the_geom,undelete,label_x,label_y,label_rotation,  publish, inventory, expl_id,num_value)
					VALUES (NEW.arc_id, NEW.code, NEW.node_1, NEW.node_2, NEW.arccat_id, NEW.epa_type, NEW.sector_id, NEW."state", NEW.state_type, NEW.annotation, NEW.observ, NEW.comment, NEW.custom_length,NEW.dma_id,NEW. presszonecat_id, 
					NEW.soilcat_id, NEW.function_type, NEW.category_type, NEW.fluid_type, NEW.location_type, NEW.workcat_id, NEW.workcat_id_end, NEW.buildercat_id, NEW.builtdate,NEW.enddate, NEW.ownercat_id,
					NEW.muni_id, NEW.postcode, NEW.streetaxis_id,NEW.postnumber, NEW.postcomplement, NEW.streetaxis2_id, NEW.postnumber2, NEW.postcomplement2, NEW.descript,NEW.link, NEW.verified, 
                    NEW.the_geom,NEW.undelete,NEW.label_x,NEW.label_y,NEW.label_rotation, NEW.publish, NEW.inventory, NEW.expl_id, NEW.num_value);

		-- this overwrites triger topocontrol arc values (triggered before insertion) just in that moment: In order to make more profilactic this issue only will be overwrited in case of NEW.node_* not nulls
		IF v_edit_enable_arc_nodes_update IS TRUE THEN
			IF NEW.node_1 IS NOT NULL THEN
				UPDATE arc SET node_1=NEW.node_1 WHERE arc_id=NEW.arc_id;
			END IF;
			IF NEW.node_2 IS NOT NULL THEN
				UPDATE arc SET node_2=NEW.node_2 WHERE arc_id=NEW.arc_id;
			END IF;
		END IF;

					
		-- MAN INSERT
		IF v_man_table='man_pipe' THEN 			
				INSERT INTO man_pipe (arc_id) VALUES (NEW.arc_id);			
			
		ELSIF v_man_table='man_varc' THEN		
				INSERT INTO man_varc (arc_id) VALUES (NEW.arc_id);

		ELSIF v_man_table='parent' THEN
			v_man_table := (SELECT arc_type.man_table FROM arc_type JOIN cat_arc ON (((arc_type.id)::text = (cat_arc.arctype_id)::text)) WHERE cat_arc.id=NEW.arccat_id);
        	IF v_man_table IS NOT NULL THEN
            	v_sql:= 'INSERT INTO '||v_man_table||' (arc_id) VALUES ('||quote_literal(NEW.arc_id)||')';    
           		EXECUTE v_sql;
      		END IF;		
		END IF;

	-- man addfields insert
		IF v_customfeature IS NOT NULL THEN
			FOR v_addfields IN SELECT * FROM man_addfields_parameter 
			WHERE (cat_feature_id = v_customfeature OR cat_feature_id is null) AND active IS TRUE AND iseditable IS TRUE
			LOOP
				EXECUTE 'SELECT $1."' || v_addfields.param_name||'"'
					USING NEW
					INTO v_new_value_param;

				IF v_new_value_param IS NOT NULL THEN
					EXECUTE 'INSERT INTO man_addfields_value (feature_id, parameter_id, value_param) VALUES ($1, $2, $3)'
						USING NEW.arc_id, v_addfields.id, v_new_value_param;
				END IF;	
			END LOOP;
		END IF;		

        -- EPA INSERT
        IF (NEW.epa_type = 'PIPE') THEN 
            v_inp_table:= 'inp_pipe';
            v_sql:= 'INSERT INTO '||v_inp_table||' (arc_id) VALUES ('||quote_literal(NEW.arc_id)||')';
            EXECUTE v_sql;
        END IF;
		
        RETURN NEW;
    
    ELSIF TG_OP = 'UPDATE' THEN

		-- epa type
		IF (NEW.epa_type != OLD.epa_type) THEN    
			IF (OLD.epa_type = 'PIPE') THEN
				v_inp_table:= 'inp_pipe';            
				v_sql:= 'DELETE FROM '||v_inp_table||' WHERE arc_id = '||quote_literal(OLD.arc_id);
				EXECUTE v_sql;
			END IF;
			v_inp_table := NULL;

			IF (NEW.epa_type = 'PIPE') THEN
				v_inp_table:= 'inp_pipe';   
				v_sql:= 'INSERT INTO '||v_inp_table||' (arc_id) VALUES ('||quote_literal(NEW.arc_id)||')';
				EXECUTE v_sql;
			END IF;
		END IF;
	
		-- State
		IF (NEW.state != OLD.state) THEN
			UPDATE arc SET state=NEW.state WHERE arc_id = OLD.arc_id;
			IF NEW.state = 2 AND OLD.state=1 THEN
				INSERT INTO plan_psector_x_arc (arc_id, psector_id, state, doable)
				VALUES (NEW.arc_id, (SELECT config_param_user.value::integer AS value FROM config_param_user WHERE config_param_user.parameter::text
				= 'psector_vdefault'::text AND config_param_user.cur_user::name = "current_user"() LIMIT 1), 1, true);
			END IF;
			IF NEW.state = 1 AND OLD.state=2 THEN
				DELETE FROM plan_psector_x_arc WHERE arc_id=NEW.arc_id;					
			END IF;			
		END IF;
		
		-- State_type
		IF NEW.state=0 AND OLD.state=1 THEN
			IF (SELECT state FROM value_state_type WHERE id=NEW.state_type) != NEW.state THEN
			NEW.state_type=(SELECT "value" FROM config_param_user WHERE parameter='statetype_end_vdefault' AND "cur_user"="current_user"() LIMIT 1);
				IF NEW.state_type IS NULL THEN
				NEW.state_type=(SELECT id from value_state_type WHERE state=0 LIMIT 1);
					IF NEW.state_type IS NULL THEN
					RETURN audit_function(2110,1318);
					END IF;
				END IF;
			END IF;
		END IF;

		--check relation state - state_type
	    IF (NEW.state_type != OLD.state_type) AND NEW.state_type NOT IN (SELECT id FROM value_state_type WHERE state = NEW.state) THEN
        	RETURN audit_function(3036,1318,NEW.state::text);
       	END IF;	
       			
		-- The geom
		IF st_orderingequals(NEW.the_geom, OLD.the_geom) IS FALSE  THEN
			UPDATE arc SET the_geom=NEW.the_geom WHERE arc_id = OLD.arc_id;
		END IF;

		--link_path
		SELECT link_path INTO v_link_path FROM arc_type JOIN cat_arc ON cat_arc.arctype_id=arc_type.id WHERE cat_arc.id=NEW.arccat_id;
		
		IF v_link_path IS NOT NULL THEN
			NEW.link = replace(NEW.link, v_link_path,'');
		END IF;

		 -- Arc type for parent view
    	IF v_man_table='parent' THEN
	    	IF (NEW.arccat_id != OLD.arccat_id) THEN
				v_new_arc_type= (SELECT type FROM arc_type JOIN cat_arc ON arc_type.id=arctype_id where cat_arc.id=NEW.arccat_id);
				v_old_arc_type= (SELECT type FROM arc_type JOIN cat_arc ON arc_type.id=arctype_id where cat_arc.id=OLD.arccat_id);
				IF v_new_arc_type != v_old_arc_type THEN
					v_sql='INSERT INTO man_'||lower(v_new_arc_type)||' (arc_id) VALUES ('||NEW.arc_id||')';
					EXECUTE v_sql;
					v_sql='DELETE FROM man_'||lower(v_old_arc_type)||' WHERE arc_id='||quote_literal(OLD.arc_id);
					EXECUTE v_sql;
				END IF;
			END IF;
		END IF;


		UPDATE arc
		SET code=NEW.code, arccat_id=NEW.arccat_id, epa_type=NEW.epa_type, sector_id=NEW.sector_id,  state_type=NEW.state_type, annotation= NEW.annotation, "observ"=NEW.observ, 
				"comment"=NEW.comment, custom_length=NEW.custom_length, dma_id=NEW.dma_id, presszonecat_id=NEW.presszonecat_id, soilcat_id=NEW.soilcat_id, function_type=NEW.function_type,
				category_type=NEW.category_type, fluid_type=NEW.fluid_type, location_type=NEW.location_type, workcat_id=NEW.workcat_id, workcat_id_end=NEW.workcat_id_end, 
				buildercat_id=NEW.buildercat_id, builtdate=NEW.builtdate, enddate=NEW.enddate, ownercat_id=NEW.ownercat_id, muni_id=NEW.muni_id, streetaxis_id=NEW.streetaxis_id, 
				streetaxis2_id=NEW.streetaxis2_id,postcode=NEW.postcode, postnumber=NEW.postnumber, postnumber2=NEW.postnumber2,descript=NEW.descript, verified=NEW.verified, 
				undelete=NEW.undelete, label_x=NEW.label_x,
				postcomplement=NEW.postcomplement, postcomplement2=NEW.postcomplement2,label_y=NEW.label_y,label_rotation=NEW.label_rotation, publish=NEW.publish, inventory=NEW.inventory, 
				expl_id=NEW.expl_id,num_value=NEW.num_value, link=NEW.link, lastupdate=now(), lastupdate_user=current_user
			WHERE arc_id=OLD.arc_id;


-- man addfields update
	IF v_customfeature IS NOT NULL THEN
		FOR v_addfields IN SELECT * FROM man_addfields_parameter 
		WHERE (cat_feature_id = v_customfeature OR cat_feature_id is null) AND active IS TRUE AND iseditable IS TRUE
		LOOP

			EXECUTE 'SELECT $1."' || v_addfields.param_name||'"'
				USING NEW
				INTO v_new_value_param;
 
			EXECUTE 'SELECT $1."' || v_addfields.param_name||'"'
				USING OLD
				INTO v_old_value_param;

			IF v_new_value_param IS NOT NULL THEN 

				EXECUTE 'INSERT INTO man_addfields_value(feature_id, parameter_id, value_param) VALUES ($1, $2, $3) 
					ON CONFLICT (feature_id, parameter_id)
					DO UPDATE SET value_param=$3 WHERE man_addfields_value.feature_id=$1 AND man_addfields_value.parameter_id=$2'
					USING NEW.arc_id , v_addfields.id, v_new_value_param;	

			ELSIF v_new_value_param IS NULL AND v_old_value_param IS NOT NULL THEN

				EXECUTE 'DELETE FROM man_addfields_value WHERE feature_id=$1 AND parameter_id=$2'
					USING NEW.arc_id , v_addfields.id;
			END IF;
		
		END LOOP;
    END IF;       
		

        RETURN NEW;

     ELSIF TG_OP = 'DELETE' THEN 
	 
		PERFORM gw_fct_check_delete(OLD.arc_id, 'ARC');
	 
        DELETE FROM arc WHERE arc_id = OLD.arc_id;
        
		--Delete addfields
  		DELETE FROM man_addfields_value WHERE feature_id = OLD.arc_id  and parameter_id in 
  		(SELECT id FROM man_addfields_parameter WHERE cat_feature_id IS NULL OR cat_feature_id =OLD.arc_type);

        RETURN NULL;
     
     END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
      