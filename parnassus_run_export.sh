#!/bin/bash

sqlplus -S / as sysdba @create_directories
sqlplus -S / as sysdba @parnassus_run_export
sqlplus -S / as sysdba @drop_directories
