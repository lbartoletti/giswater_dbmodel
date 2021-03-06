-- Function: SCHEMA_NAME.gw_trg_edit_man_gully()

-- DROP FUNCTION SCHEMA_NAME.gw_trg_edit_man_gully();

CREATE OR REPLACE FUNCTION SCHEMA_NAME.gw_trg_edit_custom_gully()
  RETURNS trigger AS
$BODY$
DECLARE 
    v_sql varchar;
	gully_geometry varchar;
    gully_id_seq int8;
	count_aux integer;
	promixity_buffer_aux double precision;
	v_customfeature text;
	v_addfields record;
	v_new_value_param text;
	v_old_value_param text;


BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
	
	promixity_buffer_aux = (SELECT "value" FROM config_param_system WHERE "parameter"='proximity_buffer');
	
	v_customfeature:= TG_ARGV[0];
    
    -- Control insertions ID
    IF TG_OP = 'INSERT' THEN

        -- gully ID
        IF (NEW.gully_id IS NULL) THEN
			PERFORM setval('urn_id_seq', gw_fct_setvalurn(),true);
            NEW.gully_id:= (SELECT nextval('urn_id_seq'));
        END IF;

		
		-- gully type 
		   IF (NEW.gully_type IS NULL) THEN
			   NEW.gully_type:= (SELECT "value" FROM config_param_user WHERE "parameter"='gullycat_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			IF (NEW.gully_type IS NULL) THEN
				NEW.gully_type:=(SELECT id FROM gully_type LIMIT 1);
			END IF;
        END IF;
		
		
        -- grate Catalog ID
        IF (NEW.gratecat_id IS NULL) THEN
				NEW.gratecat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='gratecat_vdefault' AND "cur_user"="current_user"() LIMIT 1);
							IF (NEW.gratecat_id IS NULL) THEN
				NEW.gratecat_id:=(SELECT id FROM cat_grate LIMIT 1);
			END IF;
        END IF;

        
        -- Arc Catalog ID
        IF (NEW.connec_arccat_id IS NULL) THEN
				NEW.connec_arccat_id := (SELECT "value" FROM config_param_user WHERE "parameter"='connecat_vdefault' AND "cur_user"="current_user"() LIMIT 1);
							IF (NEW.connec_arccat_id IS NULL) THEN
				NEW.connec_arccat_id:=(SELECT id FROM cat_connec LIMIT 1);

			END IF;
			
        END IF;

        -- Sector ID
        IF (NEW.sector_id IS NULL) THEN
			IF ((SELECT COUNT(*) FROM sector) = 0) THEN
                RETURN audit_function(1008,1216);  
			END IF;
				SELECT count(*)into count_aux FROM sector WHERE ST_DWithin(NEW.the_geom, sector.the_geom,0.001);
			IF count_aux = 1 THEN
				NEW.sector_id = (SELECT sector_id FROM sector WHERE ST_DWithin(NEW.the_geom, sector.the_geom,0.001) LIMIT 1);
			ELSIF count_aux > 1 THEN
				NEW.sector_id =(SELECT sector_id FROM v_edit_node WHERE ST_DWithin(NEW.the_geom, v_edit_node.the_geom, promixity_buffer_aux) 
				order by ST_Distance (NEW.the_geom, v_edit_node.the_geom) LIMIT 1);
			END IF;	
			IF (NEW.sector_id IS NULL) THEN
				NEW.sector_id := (SELECT "value" FROM config_param_user WHERE "parameter"='sector_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			END IF;
			IF (NEW.sector_id IS NULL) THEN
                RETURN audit_function(1010,1216,NEW.gully_id);          
            END IF;            
        END IF;
        
	-- Dma ID
        IF (NEW.dma_id IS NULL) THEN
			IF ((SELECT COUNT(*) FROM dma) = 0) THEN
                RETURN audit_function(1012,1216);  
            END IF;
				SELECT count(*)into count_aux FROM dma WHERE ST_DWithin(NEW.the_geom, dma.the_geom,0.001);
			IF count_aux = 1 THEN
				NEW.dma_id := (SELECT dma_id FROM dma WHERE ST_DWithin(NEW.the_geom, dma.the_geom,0.001) LIMIT 1);
			ELSIF count_aux > 1 THEN
				NEW.dma_id =(SELECT dma_id FROM v_edit_node WHERE ST_DWithin(NEW.the_geom, v_edit_node.the_geom, promixity_buffer_aux) 
				order by ST_Distance (NEW.the_geom, v_edit_node.the_geom) LIMIT 1);
			END IF;
			IF (NEW.dma_id IS NULL) THEN
				NEW.dma_id := (SELECT "value" FROM config_param_user WHERE "parameter"='dma_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			END IF; 
            IF (NEW.dma_id IS NULL) THEN
                RETURN audit_function(1014,1216,NEW.gully_id);  
            END IF;            
        END IF;

  	    -- Verified
        IF (NEW.verified IS NULL) THEN
            NEW.verified := (SELECT "value" FROM config_param_user WHERE "parameter"='verified_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;

		-- State
        IF (NEW.state IS NULL) THEN
            NEW.state := (SELECT "value" FROM config_param_user WHERE "parameter"='state_vdefault' AND "cur_user"="current_user"() LIMIT 1);
        END IF;
		
		-- State_type
		IF (NEW.state_type IS NULL) THEN
			NEW.state_type := (SELECT "value" FROM config_param_user WHERE "parameter"='statetype_vdefault' AND "cur_user"="current_user"() LIMIT 1);
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
	
		--Builtdate
		IF (NEW.builtdate IS NULL) THEN
			NEW.builtdate :=(SELECT "value" FROM config_param_user WHERE "parameter"='builtdate_vdefault' AND "cur_user"="current_user"() LIMIT 1);
		END IF;  

		--Inventory	
		NEW.inventory := (SELECT "value" FROM config_param_system WHERE "parameter"='edit_inventory_sysvdefault');

		--Publish
		NEW.publish := (SELECT "value" FROM config_param_system WHERE "parameter"='edit_publish_sysvdefault');	

		--Uncertain
		NEW.uncertain := (SELECT "value" FROM config_param_system WHERE "parameter"='edit_uncertain_sysvdefault');		
        		
		-- Exploitation
		IF (NEW.expl_id IS NULL) THEN
			NEW.expl_id := (SELECT "value" FROM config_param_user WHERE "parameter"='exploitation_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			IF (NEW.expl_id IS NULL) THEN
				NEW.expl_id := (SELECT expl_id FROM exploitation WHERE ST_DWithin(NEW.the_geom, exploitation.the_geom,0.001) LIMIT 1);
				IF (NEW.expl_id IS NULL) THEN
					PERFORM audit_function(2012,1216,NEW.gully_id);
				END IF;		
			END IF;
		END IF;	

		-- Municipality 
		IF (NEW.muni_id IS NULL) THEN
			NEW.muni_id := (SELECT "value" FROM config_param_user WHERE "parameter"='municipality_vdefault' AND "cur_user"="current_user"() LIMIT 1);
			IF (NEW.muni_id IS NULL) THEN
				NEW.muni_id := (SELECT muni_id FROM ext_municipality WHERE ST_DWithin(NEW.the_geom, ext_municipality.the_geom,0.001) LIMIT 1);
				IF (NEW.muni_id IS NULL) THEN
					PERFORM audit_function(2024,1216,NEW.gully_id);
				END IF;	
			END IF;
		END IF;
			
		--Units
		IF (NEW.units IS NULL) THEN
			NEW.units :='1';
		END IF; 

		--Inventory
		IF (NEW.inventory IS NULL) THEN
			NEW.inventory :='TRUE';
		END IF; 
		
	    -- LINK
	    IF (SELECT "value" FROM config_param_system WHERE "parameter"='edit_automatic_insert_link')::boolean=TRUE THEN
	       NEW.link=NEW.gully_id;
	    END IF;
	
        -- FEATURE INSERT
	IF gully_geometry = 'gully' THEN
        INSERT INTO gully (gully_id, code, top_elev, "ymax",sandbox, matcat_id, gully_type, gratecat_id, units, groove, connec_arccat_id, connec_length, connec_depth, siphon, arc_id, sector_id,
					"state",state_type, annotation, "observ", "comment", dma_id, soilcat_id, function_type, category_type, fluid_type, location_type, workcat_id, workcat_id_end, buildercat_id,
					builtdate, enddate, ownercat_id, muni_id, postcode, streetaxis_id, postnumber, postcomplement, streetaxis2_id, postnumber2, postcomplement2,
					descript,rotation, link,verified, the_geom,	undelete,featurecat_id, feature_id,label_x, label_y,label_rotation, expl_id, publish, inventory,uncertain, num_value)
					VALUES (NEW.gully_id, NEW.code, NEW.top_elev, NEW."ymax",NEW.sandbox, NEW.matcat_id, NEW.gully_type, NEW.gratecat_id, NEW.units, NEW.groove, NEW.connec_arccat_id,  NEW.connec_length,
					NEW.connec_depth, NEW.siphon, NEW.arc_id, NEW.sector_id, NEW."state", NEW.state_type, NEW.annotation, NEW."observ", NEW."comment", NEW.dma_id, NEW.soilcat_id, NEW.function_type,
					NEW.category_type, NEW.fluid_type, NEW.location_type, NEW.workcat_id, NEW.workcat_id_end, NEW.buildercat_id, NEW.builtdate, NEW.enddate, NEW.ownercat_id,
					NEW.muni_id, NEW.postcode, NEW.streetaxis_id, NEW.postnumber, NEW.postcomplement, NEW.streetaxis2_id, NEW.postnumber2, NEW.postcomplement2,
					NEW.descript, NEW.rotation, NEW.link, NEW.verified, NEW.the_geom, NEW.undelete,NEW.featurecat_id,
					NEW.feature_id,NEW.label_x, NEW.label_y,NEW.label_rotation,  NEW.expl_id , NEW.publish, NEW.inventory,  NEW.uncertain, NEW.num_value);


        ELSIF gully_geometry = 'gully_pol' THEN
        INSERT INTO gully (gully_id, code, top_elev, "ymax",sandbox, matcat_id, gully_type, gratecat_id, units, groove, connec_arccat_id, connec_length, connec_depth, siphon, arc_id, sector_id, "state",
					state_type, annotation, "observ", "comment", dma_id, soilcat_id, function_type, category_type, fluid_type, location_type, workcat_id, workcat_id_end, buildercat_id, builtdate, 
					enddate, ownercat_id, muni_id, postcode, streetaxis_id, postnumber, postcomplement, streetaxis2_id, postnumber2, postcomplement2,
					descript,rotation, link,verified, the_geom_pol,	undelete,featurecat_id, feature_id,label_x, label_y,label_rotation, expl_id, publish, inventory, uncertain, num_value)
					VALUES (NEW.gully_id, NEW.code, NEW.top_elev, NEW."ymax",NEW.sandbox, NEW.matcat_id, NEW.gully_type, NEW.gratecat_id, NEW.units, NEW.groove, NEW.connec_arccat_id,  NEW.connec_length,
					NEW.connec_depth, NEW.siphon, NEW.arc_id, NEW.sector_id, NEW."state", NEW.state_type, NEW.annotation, NEW."observ", NEW."comment", NEW.dma_id, NEW.soilcat_id, NEW.function_type,
					NEW.category_type, NEW.fluid_type, NEW.location_type, NEW.workcat_id, NEW.workcat_id_end, NEW.buildercat_id, NEW.builtdate, NEW.enddate, NEW.ownercat_id, NEW.muni_id, NEW.postcode,
					NEW.streetaxis_id, NEW.postnumber, NEW.postcomplement, NEW.streetaxis2_id, NEW.postnumber2, NEW.postcomplement2, NEW.descript, NEW.rotation, NEW.link, NEW.verified, NEW.the_geom_pol,
					NEW.undelete,NEW.featurecat_id, NEW.feature_id,NEW.label_x, NEW.label_y,NEW.label_rotation,  NEW.expl_id , NEW.publish, NEW.inventory, NEW.uncertain, NEW.num_value);
        END IF;  

		-- Control of automatic insert of link and vnode
		IF (SELECT value::boolean FROM config_param_user WHERE parameter='edit_connect_force_automatic_connect2network' 
		AND cur_user=current_user LIMIT 1) IS TRUE THEN
			PERFORM gw_fct_connect_to_network((select array_agg(NEW.gully_id)), 'GULLY');
		END IF;

		-- man addfields insert
		FOR v_addfields IN SELECT * FROM man_addfields_parameter WHERE cat_feature_id = v_customfeature OR cat_feature_id is null
		LOOP
			EXECUTE 'SELECT $1."' || v_addfields.param_name||'"'
				USING NEW
				INTO v_new_value_param;

			IF v_new_value_param IS NOT NULL THEN
				EXECUTE 'INSERT INTO man_addfields_value (feature_id, parameter_id, value_param) VALUES ($1, $2, $3)'
					USING NEW.gully_id, v_addfields.id, v_new_value_param;
			END IF;	
		END LOOP;
		
        RETURN NEW;
        


    ELSIF TG_OP = 'UPDATE' THEN

        -- UPDATE geom
        IF (NEW.the_geom IS DISTINCT FROM OLD.the_geom)THEN   
			UPDATE gully SET the_geom=NEW.the_geom WHERE gully_id = OLD.gully_id;		
        END IF;
		
		-- Reconnect arc_id
		IF NEW.arc_id != OLD.arc_id OR OLD.arc_id IS NULL THEN
			UPDATE gully SET arc_id=NEW.arc_id where gully_id=NEW.gully_id;
			IF (SELECT link_id FROM link WHERE feature_id=NEW.gully_id AND feature_type='GULLY' LIMIT 1) IS NOT NULL THEN
				PERFORM gw_fct_connect_to_network((select array_agg(NEW.gully_id)), 'GULLY');
			ELSIF (SELECT value::boolean FROM config_param_user WHERE parameter='edit_connect_force_automatic_connect2network' AND cur_user=current_user LIMIT 1) IS TRUE THEN
				PERFORM gw_fct_connect_to_network((select array_agg(NEW.gully_id)), 'GULLY');
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
			
			-- Control of automatic downgrade of associated link/vnode
			IF (SELECT value::boolean FROM config_param_user WHERE parameter='edit_connect_force_downgrade_linkvnode' 
			AND cur_user=current_user LIMIT 1) IS TRUE THEN	
				UPDATE link SET state=0 WHERE feature_id=OLD.gully_id;
				UPDATE vnode SET state=0 WHERE vnode_id=(SELECT exit_id FROM link WHERE feature_id=OLD.gully_id LIMIT 1)::integer;
			END IF;
		END IF;

        -- Looking for state control
        IF (NEW.state != OLD.state) THEN   
		PERFORM gw_fct_state_control('GULLY', NEW.gully_id, NEW.state, TG_OP);	
		END IF;
      
        -- UPDATE values
		IF gully_geometry = 'gully' THEN
			UPDATE gully 
			SET code=NEW.code, top_elev=NEW.top_elev, ymax=NEW."ymax", sandbox=NEW.sandbox, matcat_id=NEW.matcat_id, gully_type=NEW.gully_type, gratecat_id=NEW.gratecat_id, units=NEW.units, groove=NEW.groove, 
			connec_arccat_id=NEW.connec_arccat_id, connec_length=NEW.connec_length, connec_depth=NEW.connec_depth, siphon=NEW.siphon, sector_id=NEW.sector_id, "state"=NEW."state",  state_type=NEW.state_type, 
			annotation=NEW.annotation, "observ"=NEW."observ", 	"comment"=NEW."comment", dma_id=NEW.dma_id, soilcat_id=NEW.soilcat_id, function_type=NEW.function_type, category_type=NEW.category_type, 
            fluid_type=NEW.fluid_type, location_type=NEW.location_type, workcat_id=NEW.workcat_id, workcat_id_end=NEW.workcat_id_end,buildercat_id=NEW.buildercat_id, builtdate=NEW.builtdate, enddate=NEW.enddate,
            ownercat_id=NEW.ownercat_id, postcode=NEW.postcode, streetaxis2_id=NEW.streetaxis2_id, postnumber2=NEW.postnumber2, postcomplement=NEW.postcomplement, postcomplement2=NEW.postcomplement2, descript=NEW.descript,
            rotation=NEW.rotation, link=NEW.link, verified=NEW.verified, the_geom=NEW.the_geom,undelete=NEW.undelete,featurecat_id=NEW.featurecat_id, feature_id=NEW.feature_id,
			label_x=NEW.label_x, label_y=NEW.label_y,label_rotation=NEW.label_rotation, publish=NEW.publish, inventory=NEW.inventory, 
			muni_id=NEW.muni_id, streetaxis_id=NEW.streetaxis_id, postnumber=NEW.postnumber,  expl_id=NEW.expl_id, uncertain=NEW.uncertain, num_value=NEW.num_value
			WHERE gully_id = OLD.gully_id;

        ELSIF gully_geometry = 'gully_pol' THEN
			UPDATE gully 
			SET code=NEW.code, top_elev=NEW.top_elev, ymax=NEW."ymax", sandbox=NEW.sandbox, matcat_id=NEW.matcat_id, gully_type=NEW.gully_type, gratecat_id=NEW.gratecat_id, units=NEW.units, groove=NEW.groove, 
			connec_arccat_id=NEW.connec_arccat_id, connec_length=NEW.connec_length, connec_depth=NEW.connec_depth, siphon=NEW.siphon, sector_id=NEW.sector_id, "state"=NEW."state",  
			state_type=NEW.state_type, annotation=NEW.annotation, "observ"=NEW."observ", "comment"=NEW."comment", dma_id=NEW.dma_id, soilcat_id=NEW.soilcat_id, function_type=NEW.function_type, category_type=NEW.category_type, 
            fluid_type=NEW.fluid_type, location_type=NEW.location_type, workcat_id=NEW.workcat_id, workcat_id_end=NEW.workcat_id_end, buildercat_id=NEW.buildercat_id, builtdate=NEW.builtdate, enddate=NEW.enddate,
            ownercat_id=NEW.ownercat_id, postcode=NEW.postcode, streetaxis2_id=NEW.streetaxis2_id, postnumber2=NEW.postnumber2, postcomplement=NEW.postcomplement, postcomplement2=NEW.postcomplement2, descript=NEW.descript,
            rotation=NEW.rotation, link=NEW.link, verified=NEW.verified, the_geom_pol=NEW.the_geom_pol,undelete=NEW.undelete,featurecat_id=NEW.featurecat_id, feature_id=NEW.feature_id,
			label_x=NEW.label_x, label_y=NEW.label_y,label_rotation=NEW.label_rotation, publish=NEW.publish, inventory=NEW.inventory, 
			muni_id=NEW.muni_id, streetaxis_id=NEW.streetaxis_id, postnumber=NEW.postnumber,expl_id=NEW.expl_id, uncertain=NEW.uncertain, num_value=NEW.num_value
			WHERE gully_id = OLD.gully_id;
        END IF;  

        	-- man addfields update
		FOR v_addfields IN SELECT * FROM man_addfields_parameter WHERE cat_feature_id = v_customfeature OR cat_feature_id is null
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
					USING NEW.gully_id, v_addfields.id, v_new_value_param;	

			ELSIF v_new_value_param IS NULL AND v_old_value_param IS NOT NULL THEN

				EXECUTE 'DELETE FROM man_addfields_value WHERE feature_id=$1 AND parameter_id=$2'
					USING NEW.gully_id, v_addfields.id;
			END IF;
		
		END LOOP;
                
        RETURN NEW;
    

    ELSIF TG_OP = 'DELETE' THEN
	
		PERFORM gw_fct_check_delete(OLD.gully_id, 'GULLY');
	
        DELETE FROM gully WHERE gully_id = OLD.gully_id;

        RETURN NULL;
   
    END IF;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



