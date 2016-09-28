These scripts provide a way to automatically commit changes made to database code back to a subversion repository.

## Setting Up

1. Copy this directory to the database server
1. Check out a directory that will hold the database files
1. Install ddl_export_package.sql by running `sqlplus / as sysdba @ddl_export_package`
1. Run the respective init script e.g. ./ecm_init.sh /u04/subversion
1. Run the respective run script e.g. ./ecm_run_export.sh /u04/subversion
1. Schedule the run script in crontab e.g. `10 18 * * * su oracle -c /home/oracle/export-ddl-sisqa.sh > /home/oracle/export-ddl/homer_run_export-sisqa-cron.log 2>&1`
 

## Wrapper Script

Here is an example wrapper script to get around the prompt for instance name:

```
#!/bin/bash --noprofile

. /etc/profile
. /etc/bashrc

export PATH=$PATH:/usr/local/bin

#. /home/oracle/.bash_profile

export ORACLE_SID=sisqa
export ORAENV_ASK=NO
. oraenv
export ORAENV_ASK=YES
export NLS_LANG=American_America.AL32UTF8

cd $([[ $0 = /* ]] && dirname "$0" || dirname "$PWD/${0#./}")/export-ddl
./homer_run_export.sh /u01/sisqa_svn 2>&1 > homer_run_export-sisqa.log
```
