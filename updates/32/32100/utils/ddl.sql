/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

-----------------------
-- remove all the tables that are refactored in the v3.2
-----------------------
/*
DROP TABLE IF EXISTS config;

DROP TABLE IF EXISTS ext_cat_hydrometer_priority;
DROP TABLE IF EXISTS ext_cat_hydrometer_type;

DROP TABLE IF EXISTS "inp_typevalue_energy";
DROP TABLE IF EXISTS "inp_typevalue_pump";
DROP TABLE IF EXISTS "inp_typevalue_reactions_gl";
DROP TABLE IF EXISTS "inp_typevalue_source";
DROP TABLE IF EXISTS "inp_typevalue_valve";
DROP TABLE IF EXISTS "inp_value_ampm";
DROP TABLE IF EXISTS "inp_value_curve";
DROP TABLE IF EXISTS "inp_value_mixing";
DROP TABLE IF EXISTS "inp_value_noneall";
DROP TABLE IF EXISTS "inp_value_opti_headloss";
DROP TABLE IF EXISTS "inp_value_opti_hyd";
DROP TABLE IF EXISTS "inp_value_opti_qual";
DROP TABLE IF EXISTS "inp_value_opti_rtc_coef";
DROP TABLE IF EXISTS "inp_value_opti_unbal";
DROP TABLE IF EXISTS "inp_value_opti_units";
DROP TABLE IF EXISTS "inp_value_opti_valvemode";
DROP TABLE IF EXISTS "inp_value_param_energy";
DROP TABLE IF EXISTS "inp_value_reactions_el";
DROP TABLE IF EXISTS "inp_value_reactions_gl";
DROP TABLE IF EXISTS "inp_value_status_pipe";
DROP TABLE IF EXISTS "inp_value_status_pump";
DROP TABLE IF EXISTS "inp_value_status_valve";
DROP TABLE IF EXISTS "inp_value_times";
DROP TABLE IF EXISTS "inp_value_yesno";
DROP TABLE IF EXISTS "inp_value_yesnofull";

DROP TABLE IF EXISTS "man_addfields_cat_combo";
DROP TABLE IF EXISTS "man_addfields_cat_datatype";
DROP TABLE IF EXISTS "man_addfields_cat_widgettype";

DROP TABLE IF EXISTS selector_composer;
*/

-----------------------
-- create inp tables
-----------------------
CREATE TABLE inp_typevalue
(  typevalue character varying(50) NOT NULL,
  id character varying(30) NOT NULL,
  idval character varying(30),
  descript text,
  CONSTRAINT inp_typevalue_pkey PRIMARY KEY (typevalue, id)
);



-----------------------
-- create om tables
-----------------------
CREATE TABLE om_visit_class
(  id serial NOT NULL,
  idval character varying(30),
  descript text,
  active boolean DEFAULT true,
  ismultifeature boolean,
  ismultievent boolean,
  feature_type text,
  sys_role_id character varying(30),
  CONSTRAINT om_visit_class_pkey PRIMARY KEY (id)
);


/* created in 3.106
CREATE TABLE om_visit_class_x_parameter
(  id serial,
  class_id integer NOT NULL,
  parameter_id character varying(50) NOT NULL,
  CONSTRAINT om_visit_class_x_parameter PRIMARY KEY (class_id, parameter_id)
);

CREATE TABLE sys_combo_cat
( id serial NOT NULL,
  idval text,
  CONSTRAINT sys_combo_cat_pkey PRIMARY KEY (id)
);

CREATE TABLE sys_combo_values
( sys_combo_cat_id integer NOT NULL,
  id integer NOT NULL,
  idval text,
  descript text,
  CONSTRAINT sys_combo_pkey PRIMARY KEY (sys_combo_cat_id, id)
);
*/

CREATE TABLE om_visit_typevalue
( typevalue character varying(50) NOT NULL,
  id character varying(30) NOT NULL,
  idval character varying(30),
  descript text,
  CONSTRAINT om_visit_typevalue_pkey PRIMARY KEY (typevalue, id)
);


CREATE TABLE rpt_selector_hourly_compare
( id serial NOT NULL,
  "time" character varying(100) NOT NULL,
  cur_user text NOT NULL,
  CONSTRAINT rpt_selector_result_hourly_compare_pkey PRIMARY KEY (id)
);




CREATE TABLE audit_cat_table_x_column
( id text,
  table_id text NOT NULL,
  column_id text NOT NULL,
  column_type text,
  ordinal_position smallint,
  description text,
  sys_role_id character varying(30),
  CONSTRAINT audit_cat_table_x_column_pkey PRIMARY KEY (table_id, column_id)
);


CREATE TABLE value_type
(  typevalue character varying(50) NOT NULL,
  id character varying(30) NOT NULL,
  idval character varying(100),
  descript text,
  CONSTRAINT value_type_pkey PRIMARY KEY (typevalue, id)
);


-----------------------
-- create new fields
----------------------

--created in 3.106
ALTER TABLE audit_cat_param_user ADD COLUMN formname text;
--ALTER TABLE audit_cat_param_user ADD COLUMN label text;
--ALTER TABLE audit_cat_param_user ADD COLUMN dv_querytext text;
--ALTER TABLE audit_cat_param_user ADD COLUMN dv_parent_id text;
--ALTER TABLE audit_cat_param_user ADD COLUMN isenabled boolean;
--ALTER TABLE audit_cat_param_user ADD COLUMN layout_id integer;
--ALTER TABLE audit_cat_param_user ADD COLUMN layout_order integer;
--ALTER TABLE audit_cat_param_user ADD COLUMN project_type character varying(30);
--ALTER TABLE audit_cat_param_user ADD COLUMN isparent boolean;
--ALTER TABLE audit_cat_param_user ADD COLUMN dv_querytext_filterc text;
--ALTER TABLE audit_cat_param_user ADD COLUMN feature_field_id text;
--ALTER TABLE audit_cat_param_user ADD COLUMN feature_dv_parent_value text;
--ALTER TABLE audit_cat_param_user ADD COLUMN isautoupdate boolean;
--ALTER TABLE audit_cat_param_user ADD COLUMN datatype character varying(30);
--ALTER TABLE audit_cat_param_user ADD COLUMN widgettype character varying(30);
ALTER TABLE audit_cat_param_user ADD COLUMN ismandatory boolean;
ALTER TABLE audit_cat_param_user ADD COLUMN widgetcontrols json;
--ALTER TABLE audit_cat_param_user ADD COLUMN vdefault text;

ALTER TABLE cat_arc ADD COLUMN  dn integer;
ALTER TABLE cat_arc ADD COLUMN  pn integer;

ALTER TABLE cat_connec ADD COLUMN dn integer;
ALTER TABLE cat_connec ADD COLUMN  pn integer;

ALTER TABLE cat_node ADD COLUMN dn integer;
ALTER TABLE cat_node ADD COLUMN  pn integer;

ALTER TABLE cat_feature ADD COLUMN  type character varying(30);
ALTER TABLE cat_feature ADD COLUMN shortcut_key character varying(100);
ALTER TABLE cat_feature ADD COLUMN parent_layer character varying(100);
ALTER TABLE cat_feature ADD COLUMN child_layer character varying(100);
ALTER TABLE cat_feature ADD COLUMN orderby integer;
ALTER TABLE cat_feature ADD COLUMN active boolean;
ALTER TABLE cat_feature ADD COLUMN code_autofill boolean;

ALTER TABLE config_param_system ADD COLUMN dt integer;
ALTER TABLE config_param_system ADD COLUMN wt integer;
ALTER TABLE config_param_system ADD COLUMN label text;
ALTER TABLE config_param_system ADD COLUMN dv_querytext text;
ALTER TABLE config_param_system ADD COLUMN dv_filterbyfield text;
ALTER TABLE config_param_system ADD COLUMN isenabled boolean;
ALTER TABLE config_param_system ADD COLUMN orderby integer;
ALTER TABLE config_param_system ADD COLUMN layout_id integer;
ALTER TABLE config_param_system ADD COLUMN layout_order integer;
ALTER TABLE config_param_system ADD COLUMN project_type character varying;
ALTER TABLE config_param_system ADD COLUMN dv_isparent boolean;
ALTER TABLE config_param_system ADD COLUMN isautoupdate boolean;
ALTER TABLE config_param_system ADD COLUMN datatype character varying;
ALTER TABLE config_param_system ADD COLUMN widgettype character varying;
ALTER TABLE config_param_system ADD COLUMN tooltip text;

--rename instead of add column?
ALTER TABLE ext_rtc_hydrometer ADD COLUMN hydrometer_id character varying(16);
ALTER TABLE ext_rtc_hydrometer ADD COLUMN client_name text;
ALTER TABLE ext_rtc_hydrometer ADD COLUMN instalation_date date;
ALTER TABLE ext_rtc_hydrometer ADD COLUMN hydrometer_number integer;
ALTER TABLE ext_rtc_hydrometer ADD COLUMN state smallint;
ALTER TABLE ext_rtc_hydrometer ADD COLUMN connec_customer_code character varying(30);

ALTER TABLE om_visit ADD COLUMN class_id integer;
ALTER TABLE om_visit ADD COLUMN suspendendcat_id integer;

ALTER TABLE om_visit_cat ADD COLUMN extusercat_id integer;
ALTER TABLE om_visit_cat ADD COLUMN duration text;

--created in 3.106
--ALTER TABLE om_visit_parameter ADD COLUMN  short_descript character varying(30);

ALTER TABLE sys_feature_type ADD COLUMN  icon character varying(30);

--table v_project_type???