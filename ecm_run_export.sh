#!/bin/bash

STARTDIR=$PWD
CHECKDIR=$1

if [[ ! -d "$CHECKDIR" ]]
then
    echo "Usage: $0 path"
    exit
fi

cd $CHECKDIR
svn info
if [[ $? -gt 0 ]]
then
    echo "$CHECKDIR is not an svn working copy."
    exit
fi
svn up

cd $STARTDIR
sqlplus -S / as sysdba @create_directories
sqlplus -S / as sysdba @ecm_run_export
sqlplus -S / as sysdba @drop_directories

cd $CHECKDIR
msg="Auto commit from "`date '+%m/%d/%Y %H:%M:%S'`
svn ci -m "$msg"
