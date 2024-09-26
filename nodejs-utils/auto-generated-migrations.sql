BEGIN;

--------- START case_comments ------------

-- reverting column id from bigserial -> integer
alter table if exists case_comments alter column id set data type integer;

-- reverting column case_id from varchar(255) -> text
alter table if exists case_comments alter column case_id set data type text;

-- reverting column author from varchar(255) -> text
alter table if exists case_comments alter column author set data type text;

-- reverting column created from timestamp(6) -> timestamp
alter table if exists case_comments alter column created set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists case_comments alter column created_by set data type text;

-- reverting column created_by_uuid from varchar(255) -> uuid USING created_by_uuid::uuid
alter table if exists case_comments alter column created_by_uuid set data type uuid USING created_by_uuid::uuid;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists case_comments alter column last_updated set data type timestamp;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists case_comments alter column last_updated_by set data type text;

--------- END case_comments ------------


--------- START case_marker ------------

-- reverting column id from bigserial -> integer
alter table if exists case_marker alter column id set data type integer;

-- reverting column type_description from varchar(255) -> text
alter table if exists case_marker alter column type_description set data type text;

-- reverting column created from timestamp(6) -> timestamp
alter table if exists case_marker alter column created set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists case_marker alter column created_by set data type text;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists case_marker alter column last_updated set data type timestamp;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists case_marker alter column last_updated_by set data type text;

--------- END case_marker ------------


--------- START court ------------

-- reverting column id from bigserial -> integer
alter table if exists court alter column id set data type integer;

-- reverting column name from varchar(255) -> text
alter table if exists court alter column name set data type text;

-- reverting column court_code from varchar(255) -> text
alter table if exists court alter column court_code set data type text;

-- reverting column created from timestamp(6) -> timestamp
alter table if exists court alter column created set data type timestamp;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists court alter column last_updated set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists court alter column created_by set data type text;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists court alter column last_updated_by set data type text;

--------- END court ------------


--------- START court_case ------------

-- reverting column id from int8 -> int4
alter table if exists court_case alter column id set data type int4;

-- reverting column case_id from varchar(255) -> text
alter table if exists court_case alter column case_id set data type text;

-- reverting column case_no from varchar(255) -> text
alter table if exists court_case alter column case_no set data type text;

-- reverting column created from timestamp(6) -> timestamp
alter table if exists court_case alter column created set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists court_case alter column created_by set data type text;

-- reverting column source_type from varchar(255) -> text
alter table if exists court_case alter column source_type set data type text;

-- reverting column urn from varchar(255) -> text
alter table if exists court_case alter column urn set data type text;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists court_case alter column last_updated set data type timestamp;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists court_case alter column last_updated_by set data type text;

--------- END court_case ------------


--------- START defendant ------------

-- reverting column id from bigserial -> integer
alter table if exists defendant alter column id set data type integer;

-- reverting column defendant_name from varchar(255) -> text
alter table if exists defendant alter column defendant_name set data type text;

-- reverting column type from varchar(255) -> text
alter table if exists defendant alter column type set data type text;

-- reverting column crn from varchar(255) -> text
alter table if exists defendant alter column crn set data type text;

-- reverting column pnc from varchar(255) -> text
alter table if exists defendant alter column pnc set data type text;

-- reverting column cro from varchar(255) -> text
alter table if exists defendant alter column cro set data type text;

-- reverting column sex from varchar(255) -> text
alter table if exists defendant alter column sex set data type text;

-- reverting column nationality_1 from varchar(255) -> text
alter table if exists defendant alter column nationality_1 set data type text;

-- reverting column nationality_2 from varchar(255) -> text
alter table if exists defendant alter column nationality_2 set data type text;

-- reverting column created from timestamp(6) -> timestamp
alter table if exists defendant alter column created set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists defendant alter column created_by set data type text;

-- reverting column defendant_id from varchar(255) -> uuid USING defendant_id::uuid
alter table if exists defendant alter column defendant_id set data type uuid USING defendant_id::uuid;

-- reverting column person_id from varchar(255) -> uuid USING person_id::uuid
alter table if exists defendant alter column person_id set data type uuid USING person_id::uuid;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists defendant alter column last_updated set data type timestamp;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists defendant alter column last_updated_by set data type text;

--------- END defendant ------------


--------- START hearing ------------

-- reverting column id from bigserial -> integer
alter table if exists hearing alter column id set data type integer;

-- reverting column hearing_id from varchar(255) -> text
alter table if exists hearing alter column hearing_id set data type text;

-- reverting column created from timestamp(6) -> timestamp
alter table if exists hearing alter column created set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists hearing alter column created_by set data type text;

-- reverting column first_created from timestamp(6) -> timestamp
alter table if exists hearing alter column first_created set data type timestamp;

-- reverting column hearing_event_type from varchar(255) -> text
alter table if exists hearing alter column hearing_event_type set data type text;

-- reverting column hearing_type from varchar(255) -> text
alter table if exists hearing alter column hearing_type set data type text;

-- reverting column list_no from varchar(255) -> text
alter table if exists hearing alter column list_no set data type text;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists hearing alter column last_updated set data type timestamp;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists hearing alter column last_updated_by set data type text;

-- reverting column fk_hearing_outcome from int8 -> int4
alter table if exists hearing alter column fk_hearing_outcome set data type int4;

--------- END hearing ------------


--------- START hearing_day ------------

-- reverting column id from bigserial -> integer
alter table if exists hearing_day alter column id set data type integer;

-- reverting column hearing_time from time(6) -> time
alter table if exists hearing_day alter column hearing_time set data type time;

-- reverting column court_code from varchar(255) -> text
alter table if exists hearing_day alter column court_code set data type text;

-- reverting column court_room from varchar(255) -> text
alter table if exists hearing_day alter column court_room set data type text;

-- reverting column created from timestamp(6) -> timestamp
alter table if exists hearing_day alter column created set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists hearing_day alter column created_by set data type text;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists hearing_day alter column last_updated set data type timestamp;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists hearing_day alter column last_updated_by set data type text;

--------- END hearing_day ------------


--------- START hearing_defendant ------------

-- reverting column id from bigserial -> integer
alter table if exists hearing_defendant alter column id set data type integer;

-- reverting column created from timestamp(6) -> timestamp
alter table if exists hearing_defendant alter column created set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists hearing_defendant alter column created_by set data type text;

-- reverting column defendant_id from varchar(255) -> uuid USING defendant_id::uuid
alter table if exists hearing_defendant alter column defendant_id set data type uuid USING defendant_id::uuid;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists hearing_defendant alter column last_updated set data type timestamp;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists hearing_defendant alter column last_updated_by set data type text;

--------- END hearing_defendant ------------


--------- START hearing_notes ------------

-- reverting column id from bigserial -> integer
alter table if exists hearing_notes alter column id set data type integer;

-- reverting column hearing_id from varchar(255) -> text
alter table if exists hearing_notes alter column hearing_id set data type text;

-- reverting column note from varchar(255) -> text
alter table if exists hearing_notes alter column note set data type text;

-- reverting column author from varchar(255) -> text
alter table if exists hearing_notes alter column author set data type text;

-- reverting column created from timestamp(6) -> timestamp
alter table if exists hearing_notes alter column created set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists hearing_notes alter column created_by set data type text;

-- reverting column created_by_uuid from varchar(255) -> uuid USING created_by_uuid::uuid
alter table if exists hearing_notes alter column created_by_uuid set data type uuid USING created_by_uuid::uuid;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists hearing_notes alter column last_updated set data type timestamp;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists hearing_notes alter column last_updated_by set data type text;

--------- END hearing_notes ------------


--------- START hearing_outcome ------------

-- reverting column id from bigserial -> integer
alter table if exists hearing_outcome alter column id set data type integer;

-- reverting column outcome_type from varchar(255) -> text
alter table if exists hearing_outcome alter column outcome_type set data type text;

-- reverting column created from timestamp(6) -> timestamp
alter table if exists hearing_outcome alter column created set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists hearing_outcome alter column created_by set data type text;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists hearing_outcome alter column last_updated set data type timestamp;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists hearing_outcome alter column last_updated_by set data type text;

-- reverting column outcome_date from timestamp(6) -> timestamp
alter table if exists hearing_outcome alter column outcome_date set data type timestamp;

-- reverting column state from varchar(255) -> text
alter table if exists hearing_outcome alter column state set data type text;

-- reverting column assigned_to from varchar(255) -> text
alter table if exists hearing_outcome alter column assigned_to set data type text;

-- reverting column assigned_to_uuid from varchar(255) -> uuid USING assigned_to_uuid::uuid
alter table if exists hearing_outcome alter column assigned_to_uuid set data type uuid USING assigned_to_uuid::uuid;

-- reverting column resulted_date from timestamp(6) -> timestamp
alter table if exists hearing_outcome alter column resulted_date set data type timestamp;

--------- END hearing_outcome ------------


--------- START judicial_result ------------

-- reverting column id from bigserial -> integer
alter table if exists judicial_result alter column id set data type integer;

-- reverting column created from timestamp(6) -> timestamp
alter table if exists judicial_result alter column created set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists judicial_result alter column created_by set data type text;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists judicial_result alter column last_updated set data type timestamp;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists judicial_result alter column last_updated_by set data type text;

--------- END judicial_result ------------


--------- START offence ------------

-- reverting column id from bigserial -> integer
alter table if exists offence alter column id set data type integer;

-- reverting column title from varchar(255) -> text
alter table if exists offence alter column title set data type text;

-- reverting column act from varchar(255) -> text
alter table if exists offence alter column act set data type text;

-- reverting column created from timestamp(6) -> timestamp
alter table if exists offence alter column created set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists offence alter column created_by set data type text;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists offence alter column last_updated set data type timestamp;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists offence alter column last_updated_by set data type text;

-- reverting column offence_code from varchar(255) -> text
alter table if exists offence alter column offence_code set data type text;

-- reverting column plea_id from int8 -> int4
alter table if exists offence alter column plea_id set data type int4;

-- reverting column verdict_id from int8 -> int4
alter table if exists offence alter column verdict_id set data type int4;

--------- END offence ------------


--------- START offender ------------

-- reverting column id from bigserial -> integer
alter table if exists offender alter column id set data type integer;

-- reverting column crn from varchar(255) -> text
alter table if exists offender alter column crn set data type text;

-- reverting column probation_status from varchar(255) -> text
alter table if exists offender alter column probation_status set data type text;

-- reverting column created from timestamp(6) -> timestamp
alter table if exists offender alter column created set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists offender alter column created_by set data type text;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists offender alter column last_updated set data type timestamp;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists offender alter column last_updated_by set data type text;

-- reverting column pnc from varchar(255) -> text
alter table if exists offender alter column pnc set data type text;

-- reverting column cro from varchar(255) -> text
alter table if exists offender alter column cro set data type text;

--------- END offender ------------


--------- START offender_match ------------

-- reverting column created from timestamp(6) -> timestamp
alter table if exists offender_match alter column created set data type timestamp;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists offender_match alter column last_updated set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists offender_match alter column created_by set data type text;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists offender_match alter column last_updated_by set data type text;

--------- END offender_match ------------


--------- START offender_match_group ------------

-- reverting column created from timestamp(6) -> timestamp
alter table if exists offender_match_group alter column created set data type timestamp;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists offender_match_group alter column last_updated set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists offender_match_group alter column created_by set data type text;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists offender_match_group alter column last_updated_by set data type text;

-- reverting column case_id from varchar(255) -> text
alter table if exists offender_match_group alter column case_id set data type text;

-- reverting column defendant_id from varchar(255) -> text
alter table if exists offender_match_group alter column defendant_id set data type text;

--------- END offender_match_group ------------


--------- START plea ------------

-- reverting column id from bigserial -> integer
alter table if exists plea alter column id set data type integer;

-- reverting column value from varchar(255) -> text
alter table if exists plea alter column value set data type text;

-- reverting column created from timestamp(6) -> timestamp
alter table if exists plea alter column created set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists plea alter column created_by set data type text;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists plea alter column last_updated set data type timestamp;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists plea alter column last_updated_by set data type text;

-- reverting column date from date -> timestamp
alter table if exists plea alter column date set data type timestamp;

--------- END plea ------------


--------- START verdict ------------

-- reverting column id from bigserial -> integer
alter table if exists verdict alter column id set data type integer;

-- reverting column type_description from varchar(255) -> text
alter table if exists verdict alter column type_description set data type text;

-- reverting column date from date -> timestamp
alter table if exists verdict alter column date set data type timestamp;

-- reverting column created from timestamp(6) -> timestamp
alter table if exists verdict alter column created set data type timestamp;

-- reverting column created_by from varchar(255) -> text
alter table if exists verdict alter column created_by set data type text;

-- reverting column last_updated from timestamp(6) -> timestamp
alter table if exists verdict alter column last_updated set data type timestamp;

-- reverting column last_updated_by from varchar(255) -> text
alter table if exists verdict alter column last_updated_by set data type text;

--------- END verdict ------------


END;

