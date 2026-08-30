#!/bin/bash

# this is a prebuild that generates the kotlin files
# first run this script, then run via android studio

orc=$(realpath ../orc)
export NSMAP=${orc}/lib/src/main/bash/com/koreyhinton/nsmap

if [[ ! -f "${NSMAP}/bind" ]]; then
    echo "Cannot locate orc lib's bind script at ${NSMAP}/bind" 1>&2
    exit 1
fi

cd ./app/src/main/java/com/koreyhinton/photojournal/data/
./DbHelper.sh > ./DbHelper.kt || exit 1
echo done
