These scripts provide a way to automatically commit changes made to database code back to a subversion repository.

## Setting Up

1. Copy this directory to the database server
1. Check out a directory that will hold the database files
1. Install ddl_export_package.sql by running `sqlplus / as sysdba @ddl_export_package`
1. Run the respective init script e.g. ./ecm_init.sh /u04/subversion
1. Run the respective run script e.g. ./ecm_run_export.sh /u04/subversion
1. Schedule the run script in crontab e.g. `0 4 * * * su - oracle -c "cd export-ddl; ./ecm_run_export.sh /u04/subversion 2>&1 > ecm_run_export.log"`