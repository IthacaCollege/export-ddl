#!/bin/bash

# select LISTAGG(owner, ',') WITHIN GROUP (ORDER BY owner) from (select distinct owner from dba_objects where owner like '%MGR');

DIR=$PWD/schema
OWNERS="ITHACA BANINST1 GENERAL SATURN BWGMGR BWLMGR BWRMGR BWSMGR FAISMGR FIMSMGR ICMGR ODSMGR TAISMGR"
TYPES="FUNCTIONS MATERIALIZED_VIEWS PACKAGES PACKAGE_BODIES PROCEDURES SEQUENCES TABLES TRIGGERS TYPES VIEWS"

echo '-- Create Directories' > create_directories.sql
echo 'set serveroutput off echo off heading off feedback off verify off pagesize 0' >> create_directories.sql

echo '-- Drop Directories' > drop_directories.sql
echo 'set serveroutput off echo off heading off feedback off verify off pagesize 0' >> drop_directories.sql

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
