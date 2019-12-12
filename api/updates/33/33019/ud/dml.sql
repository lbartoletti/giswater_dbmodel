/*
This file is part of Giswater 3
The program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This version of Giswater is provided by Giswater Association
*/


SET search_path = SCHEMA_NAME, public, pg_catalog;

--12/12/2019
UPDATE config_api_form_fields SET widgettype='typeahead',
typeahead='{"fieldToSearch": "id", "threshold": 3, "noresultsMsg": "No results", "loadingMsg": "Searching"}'
WHERE column_id in ('nodecat_id', 'arccat_id', 'connecat_id');
