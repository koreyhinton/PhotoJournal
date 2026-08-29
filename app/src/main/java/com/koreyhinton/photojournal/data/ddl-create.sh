#!/bin/bash

v="$1"

ci=${DB_INITIAL_VERSION}
while [[ ci -lte ${DB_VERSION} ]]
do
    ` ./schema${ci}.sh ${v} ` # assigns sql to kotlin ${v}Ddl var
    ` ./db-exec.sh ${v} ` # uses ${v}Ddl kotlin var to execute transaction
    (( ci++ ))
done
