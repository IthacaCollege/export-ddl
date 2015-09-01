--------------------------------------------------------
--  DDL for Package ITHACA_DDL_EXPORT
--------------------------------------------------------

  -- GRANT EXECUTE ON UTL_FILE TO "ITHACA";
  -- GRANT INHERIT PRIVILEGES ON USER "SYS" TO "ITHACA"; -- http://docs.oracle.com/database/121/DBSEG/dr_ir.htm#DBSEG653

  CREATE OR REPLACE PACKAGE "ITHACA"."ITHACA_DDL_EXPORT" AUTHID CURRENT_USER AS

--
-- set linesize 32767 long 100000 echo off heading off feedback off verify off pagesize 0
-- select 'mkdir -p schema/{'||(LISTAGG(OBJECT_DIR, ',') WITHIN GROUP (ORDER BY OBJECT_DIR))||'}' from (select CASE WHEN OBJECT_TYPE like '%Y' then REPLACE(SUBSTR(OBJECT_TYPE,1,LENGTH(OBJECT_TYPE)-1)||'IES',' ','_') WHEN OBJECT_TYPE like '%X' OR OBJECT_TYPE like '%S' then REPLACE(OBJECT_TYPE||'ES',' ','_') else REPLACE(OBJECT_TYPE||'S',' ','_') end OBJECT_DIR from (select distinct owner||'/'||object_type object_type from dba_objects where object_name not like 'SYS%' and object_name not like '%$%'));
--
--
-- set serveroutput on linesize 1000 long 100000 echo off heading off feedback off verify off pagesize 0
--
-- declare
-- rc ithaca.ithaca_ddl_export.rc;
-- begin
-- open rc for select owner, object_name, object_type from dba_objects where owner='ITHACA' and object_name not like 'SYS%' and object_name not like '%$%';
-- ithaca.ithaca_ddl_export.p_object_script(rc);
-- end;
-- /
--
--

  type obj_row is RECORD (
    owner all_objects.owner%type,
    object_type all_objects.object_type%type,
    object_name all_objects.object_name%type
  );
  TYPE rc IS REF CURSOR return obj_row;

procedure p_object_script( obj_c in rc );
PROCEDURE P_OBJECT_DDL(
  P_SCHEMA IN VARCHAR2,
  P_OBJECT_TYPE IN VARCHAR2,
  P_OBJECT_NAME IN VARCHAR2
);

PROCEDURE P_WRITE_CLOB_TO_FILE( P_FILE IN SYS.UTL_FILE.FILE_TYPE, P_CLOB IN CLOB );

FUNCTION F_OBJECT_DIRECTORY(
  P_OWNER VARCHAR2,
  P_OBJECT_TYPE VARCHAR2
) RETURN VARCHAR2;

FUNCTION F_OBJECT_FILENAME(
  P_OBJECT_TYPE VARCHAR2,
  P_OBJECT_NAME VARCHAR2
) RETURN VARCHAR2;

end ITHACA_DDL_EXPORT;

/

--------------------------------------------------------
--  DDL for Package Body ITHACA_DDL_EXPORT
--------------------------------------------------------



  CREATE OR REPLACE PACKAGE BODY "ITHACA"."ITHACA_DDL_EXPORT" AS
procedure p_object_script( obj_c in rc )
AS
  v_path varchar2(100);
  obj obj_row;
BEGIN
  LOOP
    fetch obj_c into obj;
    exit when obj_c%notfound;
    if obj.object_name like '%$%' or obj.object_name like 'SYS%' then continue; end if;
    if obj.object_type='PACKAGE' then
      ITHACA.ITHACA_DDL_EXPORT.P_OBJECT_DDL( obj.owner, 'PACKAGE_SPEC', obj.object_name);
    elsif obj.object_type='PACKAGE BODY' then
      ITHACA.ITHACA_DDL_EXPORT.P_OBJECT_DDL( obj.owner, 'PACKAGE_BODY', obj.object_name);
    else
      ITHACA.ITHACA_DDL_EXPORT.P_OBJECT_DDL( obj.owner, REPLACE(obj.object_type,' ','_'), obj.object_name);
    end if;
  END LOOP;
END P_OBJECT_SCRIPT;

PROCEDURE P_OBJECT_DDL(
  P_SCHEMA IN VARCHAR2,
  P_OBJECT_TYPE IN VARCHAR2,
  P_OBJECT_NAME IN VARCHAR2
)
AS
  DDL_FILE SYS.UTL_FILE.FILE_TYPE;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Saving '||P_SCHEMA||'.'||P_OBJECT_TYPE||'.'||P_OBJECT_NAME||' to '||
    F_OBJECT_DIRECTORY(P_SCHEMA,P_OBJECT_TYPE)||', '||
    F_OBJECT_FILENAME(P_OBJECT_TYPE,P_OBJECT_NAME));
  DDL_FILE := SYS.UTL_FILE.FOPEN(
    F_OBJECT_DIRECTORY(P_SCHEMA,P_OBJECT_TYPE),
    F_OBJECT_FILENAME(P_OBJECT_TYPE,P_OBJECT_NAME),'W',32767); 
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',FALSE);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'CONSTRAINTS_AS_ALTER',TRUE);
  SYS.UTL_FILE.PUT_LINE(DDL_FILE,'--------------------------------------------------------');
  SYS.UTL_FILE.PUT_LINE(DDL_FILE,'--  DDL for '||P_OBJECT_TYPE||' '||P_OBJECT_NAME);
  SYS.UTL_FILE.PUT_LINE(DDL_FILE,'--------------------------------------------------------');
  SYS.UTL_FILE.PUT_LINE(DDL_FILE,'');
  P_WRITE_CLOB_TO_FILE(DDL_FILE,DBMS_METADATA.GET_DDL(P_OBJECT_TYPE,P_OBJECT_NAME,P_SCHEMA));
  SYS.UTL_FILE.PUT_LINE(DDL_FILE,'');
  FOR GRT IN (
    SELECT '  GRANT '||PRIVILEGE||' ON "'||TABLE_SCHEMA||'"."'||TABLE_NAME||'" TO "'||GRANTEE||'";' STR
    FROM ALL_TAB_PRIVS
    WHERE TABLE_SCHEMA = P_SCHEMA
    AND TABLE_NAME = P_OBJECT_NAME
    ORDER BY GRANTEE
  ) LOOP
    SYS.UTL_FILE.PUT_LINE(DDL_FILE,GRT.STR);
  END LOOP;
  SYS.UTL_FILE.FCLOSE(DDL_FILE);
END P_OBJECT_DDL;

PROCEDURE P_WRITE_CLOB_TO_FILE( P_FILE IN SYS.UTL_FILE.FILE_TYPE, P_CLOB IN CLOB )
AS
    V_AMT    NUMBER DEFAULT 32000;
    V_OFFSET NUMBER DEFAULT 1;
    V_LENGTH NUMBER DEFAULT NVL(DBMS_LOB.GETLENGTH(P_CLOB),0);
BEGIN
  WHILE ( V_OFFSET < V_LENGTH )
  LOOP
    UTL_FILE.PUT(P_FILE,DBMS_LOB.SUBSTR(P_CLOB,V_AMT,V_OFFSET) );
    UTL_FILE.FFLUSH(P_FILE);
    V_OFFSET := V_OFFSET + V_AMT;
  END LOOP;
  UTL_FILE.NEW_LINE(P_FILE);
END P_WRITE_CLOB_TO_FILE;

FUNCTION F_OBJECT_DIRECTORY(
  P_OWNER VARCHAR2,
  P_OBJECT_TYPE VARCHAR2
) RETURN VARCHAR2
AS
  V_RET VARCHAR2(100);
BEGIN
  if P_OBJECT_TYPE='PACKAGE_SPEC' then
    V_RET := 'PACKAGES';
  elsif P_OBJECT_TYPE like '%Y' then
    V_RET := SUBSTR(P_OBJECT_TYPE,1,LENGTH(P_OBJECT_TYPE)-1)||'IES';
  elsif P_OBJECT_TYPE like '%X' OR P_OBJECT_TYPE like '%S' then
    V_RET := P_OBJECT_TYPE||'ES';
  else
    V_RET := P_OBJECT_TYPE||'S';
  end if;
  v_RET := SUBSTR('EXPORT_'||P_OWNER||'_'||REPLACE(V_RET,' ','_'),1,30);
  RETURN V_RET;
END F_OBJECT_DIRECTORY;

FUNCTION F_OBJECT_FILENAME(
  P_OBJECT_TYPE VARCHAR2,
  P_OBJECT_NAME VARCHAR2
) RETURN VARCHAR2
AS
  V_RET VARCHAR2(100);
BEGIN
  v_RET := P_OBJECT_NAME||'.';
  CASE P_OBJECT_TYPE
    WHEN 'FUNCTION' THEN V_RET := V_RET||'fnc';
    WHEN 'PACKAGE' THEN V_RET := V_RET||'pks';
    WHEN 'PACKAGE BODY' THEN V_RET := V_RET||'pkb';
    WHEN 'PACKAGE_SPEC' THEN V_RET := V_RET||'pks';
    WHEN 'PACKAGE_BODY' THEN V_RET := V_RET||'pkb';
    WHEN 'PROCEDURE' THEN V_RET := V_RET||'prc';
    WHEN 'TRIGGER' THEN V_RET := V_RET||'trg';
    WHEN 'TYPE' THEN V_RET := V_RET||'tps';
    WHEN 'VIEW' THEN V_RET := V_RET||'vw';
    ELSE V_RET := V_RET||'sql';
  END CASE;
  RETURN V_RET;
END F_OBJECT_FILENAME;

end ITHACA_DDL_EXPORT;

/

