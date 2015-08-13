
-- sqlplus -S / as sysdba @run_export.sql

set serveroutput on linesize 1000 long 100000 echo off heading off feedback off verify off pagesize 0

declare
rc ithaca.ithaca_ddl_export.rc;
begin
open rc for
SELECT owner, object_type, object_name FROM sys.dba_objects WHERE owner='ITHACA'
AND object_type IN ('FUNCTION','MATERIALIZED VIEW','PACKAGE','PACKAGE BODY','PROCEDURE','SEQUENCE','SYNONYM','TABLE','TRIGGER','TYPE','VIEW')
UNION
select distinct owner, TYPE, NAME from dba_source where upper(text) like '%ITHACA%'
and owner in ('BANINST1', 'GENERAL', 'SATURN') or owner like '%MGR'
AND type IN ('FUNCTION','MATERIALIZED VIEW','PACKAGE','PACKAGE BODY','PROCEDURE','SEQUENCE','SYNONYM','TABLE','TRIGGER','TYPE','VIEW');
ithaca.ithaca_ddl_export.p_object_script(rc,'schema/');
end;
/

exit
