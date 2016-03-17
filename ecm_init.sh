#!/usr/bin/env bash

# select LISTAGG(owner, ',') WITHIN GROUP (ORDER BY owner) from (select distinct owner from dba_objects where owner like '%MGR');

. ./functions.sh

OWNERS="ITHACA NOLIJ"

runInit
