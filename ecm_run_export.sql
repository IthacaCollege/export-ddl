set serveroutput on linesize 1000 long 100000 echo off heading off feedback off verify off pagesize 0

declare
rc ithaca.ithaca_ddl_export.rc;
begin

-- allow package in ITHACA to run with AUTHID CURRENT_USER for the SYS user
EXECUTE IMMEDIATE 'GRANT INHERIT PRIVILEGES ON USER "SYS" TO "ITHACA"';

-- cursor for objects to export
open rc for
SELECT owner, object_type, object_name FROM sys.dba_objects WHERE owner in ('ITHACA','NOLIJ')
AND object_type IN ('FUNCTION','MATERIALIZED VIEW','PACKAGE','PACKAGE BODY','PROCEDURE','SEQUENCE','SYNONYM','TABLE','TRIGGER','TYPE','VIEW');

-- run the export
ithaca.ithaca_ddl_export.p_object_script(rc);

-- restore privileges
EXECUTE IMMEDIATE 'REVOKE INHERIT PRIVILEGES ON USER "SYS" FROM "ITHACA"';

end;
/

exit
