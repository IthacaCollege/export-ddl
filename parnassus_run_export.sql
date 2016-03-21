set serveroutput on linesize 1000 long 100000 echo off heading off feedback off verify off pagesize 0

declare
rc ithaca.ithaca_ddl_export.rc;
begin

-- allow package in ITHACA to run with AUTHID CURRENT_USER for the SYS user
EXECUTE IMMEDIATE 'GRANT INHERIT PRIVILEGES ON USER "SYS" TO "ITHACA"';

-- cursor for objects to export
open rc for
SELECT owner, object_type, object_name FROM sys.dba_objects
WHERE (((owner = 'APPS' AND
        (object_name LIKE 'IC%'
        AND object_name NOT LIKE 'ICX%'
        AND object_name NOT LIKE 'IC_ITEM%'
        AND object_name NOT LIKE 'IC_CLDR%'
        AND NOT ( 
          object_name LIKE 'IC\_%' ESCAPE '\'
          AND object_type = 'VIEW'
        )
        OR object_name LIKE 'IC_ECOMM_UNSENT%'
        OR object_name LIKE 'IC_ACCOUNTING_FLEX%'
        OR object_name LIKE 'IC_BI_USER%'
        OR object_name LIKE 'IC_GRAD_TERM%'
        OR object_name LIKE 'IC_REPORT_DIST%'
        OR object_name LIKE 'EZ%'
        OR object_name LIKE 'ECOMM%'
        OR object_name LIKE 'ISS%'
        OR object_name LIKE 'ITHC%'
        OR object_name LIKE 'HRP%'
        OR object_name = 'PARMARRAY'
        ))
    OR owner IN ('ITHACA', 'WEBSVC')
    )
AND type IN ('FUNCTION','MATERIALIZED VIEW','PACKAGE','PACKAGE BODY','PROCEDURE','SEQUENCE','SYNONYM','TABLE','TRIGGER','TYPE','VIEW')

  );

-- run the export
ithaca.ithaca_ddl_export.p_object_script(rc);

-- restore privileges
EXECUTE IMMEDIATE 'REVOKE INHERIT PRIVILEGES ON USER "SYS" FROM "ITHACA"';

end;
/

exit
