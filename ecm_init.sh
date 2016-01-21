#!/bin/bash

# select LISTAGG(owner, ',') WITHIN GROUP (ORDER BY owner) from (select distinct owner from dba_objects where owner like '%MGR');

DIR=$PWD/schema
OWNERS="ITHACA NOLIJ"
TYPES="FUNCTIONS MATERIALIZED_VIEWS PACKAGES PACKAGE_BODIES PROCEDURES SEQUENCES TABLES TRIGGERS TYPES VIEWS"

echo '-- Create Directories' > create_directories.sql
echo 'SET DEFINE OFF TERM ON ECHO ON SERVEROUTPUT ON BUFFER 1048576' >> create_directories.sql

cat >> create_directories.sql <<EOD
declare
v_chk number;
ITHACA_DDL_EXPORT_NOT_LOADED EXCEPTION;
begin
select 1 into v_chk
from all_objects
where object_type='PACKAGE' and object_name='ITHACA_DDL_EXPORT' and owner='ITHACA';
exception when no_data_found then
dbms_output.put_line('Use ddl_export_package.sql to install the ITHACA.ITHACA_DDL_EXPORT package.');
raise ITHACA_DDL_EXPORT_NOT_LOADED;
end;
/

EOD

echo '-- Drop Directories' > drop_directories.sql
echo 'SET DEFINE OFF TERM ON ECHO ON SERVEROUTPUT ON BUFFER 1048576' >> drop_directories.sql

for o in $OWNERS
do
  for t in $TYPES
  do
    mkdir -p $DIR/$o/${t:0:30}
    NAME="EXPORT_${o}_${t}"
    printf "create or replace directory %s as '%s/%s/%s';\n" ${NAME:0:30} $DIR $o $t >> create_directories.sql
    printf "drop directory %s;\n" ${NAME:0:30} >> drop_directories.sql
  done
done

printf "\nexit\n\n" >> create_directories.sql
printf "\nexit\n\n" >> drop_directories.sql
