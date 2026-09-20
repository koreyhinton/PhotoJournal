#!/bin/bash

v=${1}
# maps
. ${NSMAP}/bind ${v} S3File Id

cat << EOF

    ` ${ORC_S3}/snippets/file-exists.sh ${v} `
    if (${v}S3ConfirmedFile.exists) {
        ` ${ORC_S3}/snippets/file-text.sh ${v} `
        if (${v}S3FileText == null)
            throw Exception("Error: Id file exists but failed on read. Cannot continue to create possible duplicate db records. Resolve manually (look at logs and either retry in case of s3 failure, or either fix the corrupt .${PJ_APP_S3_ID} file or delete them from respective buckets after confirming it is safe to proceed to create all the image db records)")
        ${!id} = ${v}S3FileText.toLong()
    }

EOF
