SET DEFINE OFF TERM ON ECHO ON SERVEROUTPUT ON BUFFER 1048576
declare
  v_chk number;
begin
  select count(*)
  into v_chk
  from dba_objects
  where owner='ITHACA'
  and object_name='ITHACA_DDL_EXPORT';
  if v_chk > 0 then
    dbms_output.put_line('OK');
  else
    dbms_output.put_line('Not installed');
  end if;
end;
/
exit
