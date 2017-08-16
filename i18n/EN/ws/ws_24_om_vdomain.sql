/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/

SET search_path = "SCHEMA_NAME", public, pg_catalog;
/*
-- ----------------------------
-- Records of event om_visit_parameter_type table
-- ----------------------------
INSERT INTO om_visit_parameter_type (id) VALUES ('INSPECTION');
INSERT INTO om_visit_parameter_type (id)  VALUES ('REPAIR');
INSERT INTO om_visit_parameter_type (id) VALUES ('RECONSTRUCT');
INSERT INTO om_visit_parameter_type (id) VALUES ('OTHER');
INSERT INTO om_visit_parameter_type (id) VALUES ('PICTURE');



-- ----------------------------
-- Records of event om_visit_parameter table
-- ----------------------------
INSERT INTO om_visit_parameter (id, parameter_type, featurecat_id, data_type, descript) VALUES ('insp_node_p1','INSPECTION','NODE', 'TEXT', 'Inspection node parameter 1');
INSERT INTO om_visit_parameter (id, parameter_type, featurecat_id, data_type, descript)  VALUES ('insp_arc_p1','INSPECTION','ARC', 'TEXT', 'Inspection arc parameter 1');
INSERT INTO om_visit_parameter (id, parameter_type, featurecat_id, data_type, descript)  VALUES ('insp_node_p2','INSPECTION','NODE', 'TEXT', 'Inspection node parameter 2');
INSERT INTO om_visit_parameter (id, parameter_type, featurecat_id, data_type, descript)  VALUES ('insp_arc_p2','INSPECTION','ARC', 'TEXT', 'Inspection arc parameter 2');
INSERT INTO om_visit_parameter (id, parameter_type, featurecat_id, data_type, descript)  VALUES ('insp_node_p3','INSPECTION','NODE', 'TEXT', 'Inspection node parameter 3');
INSERT INTO om_visit_parameter (id, parameter_type, featurecat_id, data_type, descript)  VALUES ('insp_arc_p3','INSPECTION','ARC', 'TEXT', 'Inspection arc parameter 3');
INSERT INTO om_visit_parameter (id, parameter_type, featurecat_id, data_type, descript)  VALUES ('insp_connec_p1','INSPECTION','CONNEC', 'TEXT', 'Inspection connec parameter 1');
INSERT INTO om_visit_parameter (id, parameter_type, featurecat_id, data_type, descript)  VALUES ('insp_connec_p2','INSPECTION','CONNEC', 'TEXT', 'Inspection connec parameter 2');
INSERT INTO om_visit_parameter (id, parameter_type, featurecat_id, data_type, descript)  VALUES ('png','PICTURE','ALL', '', '');


-- ----------------------------
-- Records of event om_visit_value_position table
-- ----------------------------
INSERT INTO om_visit_value_position VALUES ('bottom', 'NODE', 'description');
INSERT INTO om_visit_value_position VALUES ('top', 'NODE', 'description');*/