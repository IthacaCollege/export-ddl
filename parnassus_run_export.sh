#!/bin/bash

DIR=$1

if [[ ! -d "$DIR" ]]
then
    echo "Usage: $0 path"
    exit
fi

cd $DIR
svn info
if [[ $? -gt 0 ]]
then
    echo "$DIR is not an svn working copy."
    exit
fi
svn up

sqlplus -S / as sysdba @create_directories
sqlplus -S / as sysdba @parnassus_run_export
sqlplus -S / as sysdba @drop_directories

msg="Auto commit from "`date '+%m/%d/%Y %H:%M:%S'`
svn ci -m "$msg"
