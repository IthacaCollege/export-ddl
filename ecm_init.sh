#!/bin/bash

# select LISTAGG(owner, ',') WITHIN GROUP (ORDER BY owner) from (select distinct owner from dba_objects where owner like '%MGR');

STARTDIR=`[[ $0 = /* ]] && dirname "$0" || dirname "$PWD/${0#./}"`
CHECKDIR=$1
OWNERS="ITHACA NOLIJ"
TYPES="FUNCTIONS MATERIALIZED_VIEWS PACKAGES PACKAGE_BODIES PROCEDURES SEQUENCES TABLES TRIGGERS TYPES VIEWS"

if [[ ! -d "$CHECKDIR" ]]
then
    echo "Usage: $0 path"
    exit
fi

echo '-- Create Directories' > $STARTDIR/create_directories.sql
echo 'SET DEFINE OFF TERM ON ECHO ON SERVEROUTPUT ON BUFFER 1048576' >> $STARTDIR/create_directories.sql

cat >> $STARTDIR/create_directories.sql <<EOD
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

echo '-- Drop Directories' > $STARTDIR/drop_directories.sql
echo 'SET DEFINE OFF TERM ON ECHO ON SERVEROUTPUT ON BUFFER 1048576' >> $STARTDIR/drop_directories.sql

for o in $OWNERS
do
  for t in $TYPES
  do
    mkdir -p $CHECKDIR/$o/${t:0:30}
    NAME="EXPORT_${o}_${t}"
    printf "create or replace directory %s as '%s/%s/%s';\n" ${NAME:0:30} $CHECKDIR $o $t >> $STARTDIR/create_directories.sql
    printf "drop directory %s;\n" ${NAME:0:30} >> $STARTDIR/drop_directories.sql
  done
done

printf "\nexit\n\n" >> $STARTDIR/create_directories.sql
printf "\nexit\n\n" >> $STARTDIR/drop_directories.sql
