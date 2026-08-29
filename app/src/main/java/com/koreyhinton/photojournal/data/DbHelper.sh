#!/bin/bash

export DB_INITIAL_VERSION=1
export DB_VERSION=1

v="${1:-db_}"
# maps
export ${v}crt_db=db
export ${v}upg_db=db

cat << EOF

    import android.database.sqlite.SQLiteDatabase
    import android.database.sqlite.SQLiteOpenHelper

    class DbHelper(context: Context) : SQLiteOpenHelper(
        context, "photo_journal.db", null, ${DB_VERSION}
    ) {

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

