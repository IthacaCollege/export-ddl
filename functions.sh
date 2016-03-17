#!/usr/bin/env bash

function getStartDir {
    echo $([[ $1 = /* ]] && dirname "$1" || dirname "$PWD/${1#./}")
}

function getCreateDirSqlFile {
    SAFENAME=$(echo $2 | sed 's/[^A-Za-z0-9]//g')
    SAFEHASH=$(echo $2 | sha1sum | awk '{print substr($1,0,8)}')
    echo $1/create_directories_${SAFENAME}_${SAFEHASH}.sql
}

function getDropDirSqlFile {
    SAFENAME=$(echo $2 | sed 's/[^A-Za-z0-9]//g')
    SAFEHASH=$(echo $2 | sha1sum | awk '{print substr($1,0,8)}')
    echo $1/drop_directories_${SAFENAME}_${SAFEHASH}.sql
}

function runInit {
    if [[ ! -d "$CHECKDIR" ]]
    then
        echo "Usage: $0 path"
        exit
    fi

    echo '-- Create Directories' > ${CREATEDIR}
    echo 'SET DEFINE OFF TERM ON ECHO ON SERVEROUTPUT ON BUFFER 1048576' >> ${CREATEDIR}

    cat >> ${CREATEDIR} <<EOD
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

    echo '-- Drop Directories' > ${DROPDIR}
    echo 'SET DEFINE OFF TERM ON ECHO ON SERVEROUTPUT ON BUFFER 1048576' >> ${DROPDIR}

    for o in ${OWNERS}
    do
        for t in ${TYPES}
        do
            mkdir -p ${CHECKDIR}/$o/${t:0:30}
            NAME="EXPORT_${o}_${t}"
            printf "create or replace directory %s as '%s/%s/%s';\n" ${NAME:0:30} $CHECKDIR $o $t >> ${CREATEDIR}
            printf "drop directory %s;\n" ${NAME:0:30} >> ${DROPDIR}
        done
    done

    printf "\nexit\n\n" >> ${CREATEDIR}
    printf "\nexit\n\n" >> ${DROPDIR}
}

function runExport {
    if [[ ! -d "${CHECKDIR}" ]]
    then
        echo "Usage: $SCRIPTNAME path"
        exit
    fi

    cd ${CHECKDIR}
    svn info

    if [[ $? -gt 0 ]]
    then
        echo "$CHECKDIR is not an svn working copy."
        exit
    fi

    if [[ ! -f "$CREATEDIR" ]]
    then
        echo "Before using $SCRIPTNAME please run"
        echo "${STARTDIR}/${1}_init.sh $CHECKDIR"
        exit
    fi

    svn up

    cd $STARTDIR
    sqlplus -S / as sysdba @${CREATEDIR}
    sqlplus -S / as sysdba @${1}_run_export
    sqlplus -S / as sysdba @${DROPDIR}

    cd $CHECKDIR
    svn st | egrep '^[?]' | awk '{print $2}' | xargs svn add --force --quiet
    svn st | egrep '^[!]' | awk '{print $2}' | xargs svn rm --force --quiet
    msg="Auto commit from "`date '+%m/%d/%Y %H:%M:%S'`
    svn ci -m "$msg"
}

SCRIPTNAME=$0
OWNERS="ITHACA"
TYPES="FUNCTIONS MATERIALIZED_VIEWS PACKAGES PACKAGE_BODIES PROCEDURES SEQUENCES SYNONYMS TABLES TRIGGERS TYPES VIEWS"
STARTDIR=$(getStartDir $0)
CHECKDIR=$1
CREATEDIR=$(getCreateDirSqlFile ${STARTDIR} ${CHECKDIR})
DROPDIR=$(getDropDirSqlFile ${STARTDIR} ${CHECKDIR})
