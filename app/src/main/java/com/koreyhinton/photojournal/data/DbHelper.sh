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

        fun retrieveThisDeviceAlias(): String? {
            var db = readableDatabase
            var alias: String? = null
            db.rawQuery(
                """
                select dc_alias from dc where is_this_device = 1 limit 1
                """, null
            ).use { cursor ->
                while (cursor.moveToNext()) {
                    alias = cursor.getString(0)
                }
            }
            return alias
        }

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

        fun readZPH(): List<String> {
            val db = readableDatabase
            var rows = mutableListOf<String>()
            db.rawQuery(
                // zphoto id is a unique photo id across all buckets or filesystems
                """
                    select "ZPH~"||dc_alias||"~"||capture_date||"~"||orig_name
                    as zph
                    from dcim
                """, null
            ).use { cursor ->
                while (cursor.moveToNext()) {
                    rows.add(cursor.getString(0))
                }
            }
            return rows
        }

        fun insertThisDeviceAlias(
            make: String,
            model: String,
            alias: String
        ) {
            if (retrieveThisDeviceAlias() != null)
                throw Exception("Device alias is already set")
            var db = writableDatabase
            var stmt = db.compileStatement(
                """
                    insert into dc (make, model, dc_alias, is_this_device)
                    values (?, ?, ?, 1)
                """)
            try {
                stmt.bindString(1, make)
                stmt.bindString(2, model)
                stmt.bindString(3, alias)
                stmt.executeInsert()
            }catch(e: Exception) {
                ${S3_ERR_LOG}("Warning: " + e.javaClass.simpleName  +
                    " exception. Attempted to insert this device record, make:"+
                    make + ", model:" + model +", alias: " + alias +
                        ", and failed with exception: " + e.message + "\n" +
                            e.stackTraceToString())
                throw e
            } catch(e: Throwable) {
                ${S3_ERR_LOG}("Warning: " + e.javaClass.simpleName  +
                    " exception. Attempted to insert this device record, make:"+
                    make + ", model:" + model +", alias: " + alias +
                        ", and failed with exception: " + e.message + "\n" +
                            e.stackTraceToString())
                throw e
            } finally {
                stmt.close()
            }
        }

        fun insertZPH(
            zphotoId: String,
            bucketId: Long
        ): String /* error string */ {
            val db = writableDatabase

            var components = zphotoId.split("~")
            // ZPH~{DEVICE}~{DATE}~{ORIG_NAME}
            if (components.count() != 4 && components[0] != "ZPH")
                return "" // not a zphoto and doesn't warrant returning an error string

            if (components.count() != 4)
                return "incorrect ZPH found: " + zphotoId

            if (components[2].count() != 10 || components[2].split("-").count() != 3) {
                return "invalid date for zphoto: " + zphotoId
            }

            var rows = mutableListOf<String>()
            var stmt = db.compileStatement(
                """
                    insert into dcim (dc_alias, capture_date, orig_name)
                    values (?, ?, ?)
                """)
            stmt.bindString(1, components[1])
            stmt.bindString(2, components[2])
            stmt.bindString(3, components[3])
            try {
                var dcimId = stmt.executeInsert()
                var linkTblStmt = db.compileStatement(
                """
                    insert into bucket_dcim (bucket_id, dcim_id)
                    values (?, ?)
                """)
                linkTblStmt.bindLong(1, bucketId)
                linkTblStmt.bindLong(2, dcimId)
                linkTblStmt.executeInsert()
            } catch(e: Exception) {
                ${S3_ERR_LOG}("Warning: " + e.javaClass.simpleName  +
                    " exception. Attempted to insert record ZPH~" + components[1] + "~" + components[2]+"~"+components[3] + " vs " + zphotoId +
                        " and failed with exception: " + e.message + "\n" +
                            e.stackTraceToString())
                throw e
            } catch(e: Throwable) {
                ${S3_ERR_LOG}("Warning: " + e.javaClass.simpleName  +
                    " exception. Attempted to insert record ZPH~" + components[1] + "~" + components[2]+"~"+components[3] + " vs " + zphotoId +
                        " and failed with exception: " + e.message + "\n" +
                            e.stackTraceToString())
                throw e
            } finally {
                stmt.close()
            }
            return ""
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

