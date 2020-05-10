/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

-- 2020/05/09
ALTER TABLE sys_csv2pg_config RENAME TO config_csv_param;
ALTER TABLE sys_fprocess_cat RENAME TO sys_fprocess;
ALTER TABLE sys_typevalue_cat RENAME TO sys_typevalue;
ALTER TABLE sys_csv2pg_cat RENAME TO config_csv;
ALTER TABLE audit_cat_function RENAME TO sys_function;

ALTER TABLE audit_cat_param_user RENAME TO sys_param_user;
ALTER TABLE audit_cat_error RENAME TO sys_message;
ALTER TABLE audit_cat_table RENAME TO sys_table;
ALTER TABLE audit_cat_sequence RENAME TO sys_sequence;


CREATE TABLE config_toolbox (
id integer PRIMARY KEY,
alias text,
isparametric boolean,
functionparams json,
inputparams json,
observ text
);


INSERT INTO config_toolbox
SELECT id, alias, isparametric, input_params::json, return_type::json, context FROM sys_function WHERE istoolbox IS TRUE;


SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"sys_function", "column":"istoolbox"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"sys_function", "column":"isparametric"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"sys_function", "column":"context"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"sys_function", "column":"alias"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"DROP","table":"config_csv", "column":"name_i18n"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"config_csv", "column":"name", "newName":"alias"}}$$);

ALTER TABLE audit_check_feature RENAME to _audit_check_feature_ ;
ALTER TABLE audit_log_feature RENAME to _audit_log_feature_ ;
ALTER TABLE audit_log_project RENAME to _audit_log_project_ ;
ALTER TABLE audit_log_csv2pg RENAME to _audit_log_csv2pg_ ;
ALTER TABLE audit_log_arc_traceability RENAME to audit_arc_traceability;
ALTER TABLE typevalue_fk RENAME to config_typevalue_fk;


ALTER TABLE audit_cat_column RENAME to _audit_cat_column_;
ALTER TABLE audit_price_simple RENAME to _audit_price_simple_;


--create iscustom param
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"sys_fprocess", "column":"iscustom", "dataType":"boolean"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"sys_function", "column":"iscustom", "dataType":"boolean"}}$$);

-- create fprocesstype
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"audit_log_data", "column":"addparam", "dataType":"json"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"audit_log_data", "column":"addparam", "dataType":"json"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"audit_log_data", "column":"addparam", "dataType":"json"}}$$);


--harmonize audit_check_data
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"audit_check_data", "column":"feature_type", "dataType":"text"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"audit_check_data", "column":"feature_id", "dataType":"text"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"audit_check_data", "column":"addparam", "dataType":"json"}}$$);

SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"om_visit_class", "column":"formname", "dataType":"text"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"ADD","table":"om_visit_class", "column":"tablename", "dataType":"text"}}$$);

-- harmonize cur_user
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"audit_log_data", "column":"user_name", "newName":"cur_user"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"audit_check_data", "column":"user_name", "newName":"cur_user"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"audit_check_project", "column":"user_name", "newName":"cur_user"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"temp_table", "column":"user_name", "newName":"cur_user"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"audit_log_arc_traceability", "column":"user", "newName":"cur_user"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"temp_csv2pg", "column":"user_name", "newName":"cur_user"}}$$);
SELECT gw_fct_admin_manage_fields($${"data":{"action":"RENAME","table":"rpt_cat_result", "column":"user_name", "newName":"cur_user"}}$$);


-- harmonize selectors
ALTER TABLE inp_selector_result RENAME to selector_inp_result ;
ALTER TABLE inp_selector_sector RENAME to selector_sector ;
ALTER TABLE rpt_selector_compare RENAME to selector_rpt_compare ;
ALTER TABLE rpt_selector_result RENAME to selector_rpt_main ;
ALTER TABLE plan_result_selector RENAME to selector_plan_result;
ALTER TABLE plan_psector_selector RENAME to selector_plan_psector;


-- remove id from all selectors
ALTER TABLE selector_audit DROP CONSTRAINT selector_audit_fprocesscat_id_cur_user_unique;
ALTER TABLE selector_audit DROP CONSTRAINT selector_audit_pkey;
ALTER TABLE selector_audit ADD CONSTRAINT selector_audit_pkey PRIMARY KEY(fprocesscat_id, cur_user);
ALTER TABLE selector_audit DROP COLUMN id;

ALTER TABLE selector_date DROP CONSTRAINT selector_date_pkey;
ALTER TABLE selector_date ADD CONSTRAINT selector_date_pkey PRIMARY KEY(context, cur_user);
ALTER TABLE selector_date DROP COLUMN id;

ALTER TABLE selector_expl DROP CONSTRAINT expl_id_cur_user_unique;
ALTER TABLE selector_expl DROP CONSTRAINT selector_expl_pkey;
ALTER TABLE selector_expl ADD CONSTRAINT selector_expl_pkey PRIMARY KEY(expl_id, cur_user);
ALTER TABLE selector_expl DROP COLUMN id;

ALTER TABLE selector_hydrometer DROP CONSTRAINT selector_hydrometer_state_id_cur_user_unique;
ALTER TABLE selector_hydrometer DROP CONSTRAINT selector_hydrometer_pkey;
ALTER TABLE selector_hydrometer ADD CONSTRAINT selector_hydrometer_pkey PRIMARY KEY(state_id, cur_user);
ALTER TABLE selector_hydrometer DROP COLUMN id;

ALTER TABLE selector_inp_result DROP CONSTRAINT inp_selector_result_result_id_cur_user_unique;
ALTER TABLE selector_inp_result DROP CONSTRAINT inp_selector_result_pkey;
ALTER TABLE selector_inp_result ADD CONSTRAINT selector_inp_result_pkey PRIMARY KEY(result_id, cur_user);
ALTER TABLE selector_inp_result DROP COLUMN id;

ALTER TABLE selector_lot DROP CONSTRAINT selector_lot_lot_id_cur_user_unique;
ALTER TABLE selector_lot DROP CONSTRAINT selector_lot_pkey;
ALTER TABLE selector_lot ADD CONSTRAINT selector_lot_pkey PRIMARY KEY(lot_id, cur_user);
ALTER TABLE selector_lot DROP COLUMN id;

ALTER TABLE selector_plan_result DROP CONSTRAINT plan_result_selector_result_id_cur_user_unique;
ALTER TABLE selector_plan_result DROP CONSTRAINT plan_result_selector_pkey;
ALTER TABLE selector_plan_result ADD CONSTRAINT selector_plan_result_pkey PRIMARY KEY(result_id, cur_user);
ALTER TABLE selector_plan_result DROP COLUMN id;

ALTER TABLE selector_psector DROP CONSTRAINT psector_id_cur_user_unique;
ALTER TABLE selector_psector DROP CONSTRAINT selector_psector_pkey;
ALTER TABLE selector_psector ADD CONSTRAINT selector_psector_pkey PRIMARY KEY(psector_id, cur_user);
ALTER TABLE selector_psector DROP COLUMN id;

ALTER TABLE selector_sector DROP CONSTRAINT inp_selector_sector_sector_id_cur_user_unique;
ALTER TABLE selector_sector DROP CONSTRAINT inp_selector_sector_pkey;
ALTER TABLE selector_sector ADD CONSTRAINT selector_sector_pkey PRIMARY KEY(sector_id, cur_user);
ALTER TABLE selector_sector DROP COLUMN id;

ALTER TABLE selector_state DROP CONSTRAINT state_id_cur_user_unique;
ALTER TABLE selector_state DROP CONSTRAINT selector_state_pkey;
ALTER TABLE selector_state ADD CONSTRAINT selector_state_pkey PRIMARY KEY(state_id, cur_user);
ALTER TABLE selector_state DROP COLUMN id;

ALTER TABLE selector_workcat DROP CONSTRAINT selector_workcat_workcat_cur_user_unique;
ALTER TABLE selector_workcat DROP CONSTRAINT selector_workcat_pkey;
ALTER TABLE selector_workcat ADD CONSTRAINT selector_workcat_pkey PRIMARY KEY(workcat_id, cur_user);
ALTER TABLE selector_workcat DROP COLUMN id;

ALTER TABLE selector_plan_psector DROP CONSTRAINT plan_psector_selector_pkey;
ALTER TABLE selector_plan_psector ADD CONSTRAINT plan_psector_selector_pkey PRIMARY KEY(psector_id, cur_user);
ALTER TABLE selector_plan_psector DROP COLUMN id;