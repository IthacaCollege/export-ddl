#!/usr/bin/env bash

# select LISTAGG(owner, ',') WITHIN GROUP (ORDER BY owner) from (select distinct owner from dba_objects where owner like '%MGR');

. ./functions.sh

OWNERS="APPS ITHACA WEBSVC"
TYPES="FUNCTIONS MATERIALIZED_VIEWS PACKAGES PACKAGE_BODIES PROCEDURES SEQUENCES TABLES TRIGGERS TYPES VIEWS"

runInit
