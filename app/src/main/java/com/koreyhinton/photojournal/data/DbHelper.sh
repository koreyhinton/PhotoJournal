#!/bin/bash

export DB_INITIAL_VERSION=1
export DB_VERSION=1

v="${1:-db_}"
# maps
export ${v}crt_db=db
export ${v}upg_db=db

cat << EOF
    package com.koreyhinton.photojournal.data
    import android.content.Context
    import android.content.ContentValues
    import android.database.sqlite.SQLiteDatabase
    import android.database.sqlite.SQLiteOpenHelper
    import com.koreyhinton.photojournal.models.S3File

    class DbHelper(context: Context) : SQLiteOpenHelper(
        context, "photo_journal.db", null, ${DB_VERSION}
    ) {

        fun retrieveDays(): String {
            val db = readableDatabase
            var csv = ""
            db.rawQuery(
                """
                select distinct capture_date from dcim
                """, null
            ).use { cursor ->
                while (cursor.moveToNext()) {
                    if (!csv.isEmpty())
                        csv += ","
                    csv += cursor.getString(0)
                }
            }
            return csv
        }

        fun zeroS3Data(): Boolean {
            // If the app was uninstalled and reinstalled
            // s3 buckets have ids but the tables are
            // now gone. So, a force-overwrite s3 id file
            // mode will be enabled if zeroS3Data returns true
            val db = readableDatabase
            db.rawQuery(
                "select exists(select 1 from s3 limit 1);",
                null
            ).use { cursor ->
                if (cursor.moveToFirst()) {
                    var hasRows = cursor.getInt(0) == 1
                    return !hasRows
                }
            }
            return true

        }

        fun insertS3(): Long {
            val db = writableDatabase
            var values = ContentValues()
            values.putNull("id")
            return db.insertOrThrow("s3", null, values)
        }

        fun insertBucket(s3Id: Long): Long {
            var values = ContentValues()
            values.putNull("id")
            values.put("s3_id", s3Id)
            val db = writableDatabase
            return db.insertOrThrow("bucket", null, values)
        }

        override fun onCreate(db: SQLiteDatabase) {
            ` ./ddl-create.sh ${v}crt_ `
        }

        override fun onUpgrade(
            db: SQLiteDatabase,
            oldVersion: Int,
            newVersion: Int
        ) {
            ` ./ddl-upgrade.sh ${v}upg_ `
        }

        // OnDowngrade is not overriden and will throw an exception

    }

EOF

