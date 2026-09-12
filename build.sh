#!/bin/bash

# this is a prebuild that generates the kotlin files
# first run this script, then run via android studio

orc=$(realpath ../orc)
export NSMAP=${orc}/lib/src/main/bash/com/koreyhinton/nsmap
export ORC_S3=${orc}/lib/src/templates/kotlin/com/koreyhinton/s3

if [[ ! -f "${NSMAP}/bind" ]]; then
    echo "Cannot locate orc lib's bind script at ${NSMAP}/bind" 1>&2
    exit 1
fi

export S3_CLIENT_BUILD_CLASS_FULL=com.koreyhinton.photojournal.models.S3ClientBuild

cd ./app/src/main/java/com/koreyhinton/photojournal/data/
./DbHelper.sh > ./DbHelper.kt || exit 1
cd ../web
./JSIface.sh > ./JSIface.kt || exit 1
cd ../models
./Models.sh > ./Models.kt || exit 1
echo done
