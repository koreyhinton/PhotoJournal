#!/bin/bash

v="$1"

ci=${DB_INITIAL_VERSION}
while [[ $ci -le ${DB_VERSION} ]]
do
    # assign sql to kotlin ${v}Ddl var
    echo "val ${v}Ddl = \"\"\""
        ./schema${ci}.sh ${v}
    echo '"""'

    # uses ${v}Ddl kotlin var to execute transaction:
    ./db-exec.sh ${v}
    (( ci++ ))
done
