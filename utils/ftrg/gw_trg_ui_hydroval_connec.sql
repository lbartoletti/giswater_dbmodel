/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

--FUNCTION CODE: 1328


CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_trg_ui_hydroval_connec()  RETURNS trigger AS $BODY$ 

    
BEGIN

    EXECUTE 'SET search_path TO '||quote_literal(TG_TABLE_SCHEMA)||', public';
    
   
    -- Control insertions ID
    IF TG_OP = 'INSERT' THEN
        -- to do PERFORM audit_function(1030,1310); 
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN

        UPDATE ext_rtc_hydrometer_x_data 
        SET custom_sum=NEW.custom_sum
        WHERE id=OLD.id;
        -- to do PERFORM audit_function(2,1310); 
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        --to do PERFORM audit_function(1032,1310); 
        RETURN NEW;
    
    END IF;
       
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


