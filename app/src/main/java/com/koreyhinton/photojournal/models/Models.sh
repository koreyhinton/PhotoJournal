#!/bin/bash

${ORC_S3}/classes/S3ClientBuild.sh
${ORC_S3}/classes/S3File.sh | grep -v package
${ORC_S3}/classes/S3ConfirmedFile.sh | grep -v package
