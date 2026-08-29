#!/bin/bash

v="$1"

ui=${DB_INITIAL_VERSION}
while [[ ui -lte ${DB_VERSION} ]]
do
    echo "if(oldVersion<${ui}) {"
    ` ./schema${ui}.sh ${v} ` # assigns sql to kotlin ${v}Ddl var
    ` ./db-exec.sh ${v} ` # uses ${v}Ddl kotlin var to execute transaction
    echo "}"
    (( ui++ ))
done
