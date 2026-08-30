#!/bin/bash

v="$1"

ui=${DB_INITIAL_VERSION}
(( ui++ )) # 'oldVersion < 1' will never happen so skip that one
while [[ $ui -le ${DB_VERSION} ]]
do
    echo "if(oldVersion<${ui}) {"
        echo "val ${v}Ddl = \"\"\""
            ./schema${ui}.sh ${v} # assigns sql to kotlin ${v}Ddl var
         echo '"""'
        ./db-exec.sh ${v} # uses ${v}Ddl kotlin var to execute transaction
    echo "}"
    (( ui++ ))
done
