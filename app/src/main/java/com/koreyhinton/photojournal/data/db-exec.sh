#!/bin/bash

v=$1
. ${NSMAP}/bind ${v} Ddl

cat << EOF
            db.beginTransaction()
            try {
                val ddl = ${!ddl} /*context.assets.open("database/schema.sql")
                    .bufferedReader().use { it.readText() }*/
                val statements = ddl.split(";").map { it.trim() }
                    .filter { it.isNotEmpty() }
                for (statement in statements) {
                    db.execSQL(statement)
                }
                db.setTransactionSuccessful()
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                db.endTransaction()
            }
EOF
