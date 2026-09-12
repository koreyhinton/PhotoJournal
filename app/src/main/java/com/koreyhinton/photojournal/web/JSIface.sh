#!/bin/bash

v=${1:-jsi_}
priv=${RANDOM}_
# maps

cat << EOF

package com.koreyhinton.photojournal.web

import android.content.Context
import android.webkit.JavascriptInterface
import com.koreyhinton.photojournal.data.DbHelper
import com.koreyhinton.photojournal.models.S3ClientBuild
import com.koreyhinton.photojournal.MainActivity
import android.widget.LinearLayout
import android.widget.EditText
import android.text.InputType
import android.app.AlertDialog
import android.content.DialogInterface

class JSIface(
        private val context: Context,
        private val activity: MainActivity,
        private val dbHelper: DbHelper
    ) {
    @JavascriptInterface
    fun retrieveDays(): String {
        return dbHelper.retrieveDays()
    }
    @JavascriptInterface
    fun signIn() {
        activity.runOnUiThread {
            val layout = LinearLayout(activity).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(48, 24, 48, 8)
            }

            var accessKeyEditText = EditText(activity).apply {
                hint = "Access key"
                inputType = InputType.TYPE_CLASS_TEXT
            }
            layout.addView(accessKeyEditText)

            val secretEditText = EditText(activity).apply {
                hint = "Secret key"
                inputType = InputType.TYPE_CLASS_TEXT or
                    InputType.TYPE_TEXT_VARIATION_PASSWORD
            }
            layout.addView(secretEditText)

            var regEditText = EditText(activity).apply {
                hint = "Region"
                inputType = InputType.TYPE_CLASS_TEXT
            }
            layout.addView(regEditText)

            var urlEditText = EditText(activity).apply {
                hint = "Url"
                inputType = InputType.TYPE_CLASS_TEXT
            }
            layout.addView(urlEditText)

            val conn = { dialog: DialogInterface, which: Int ->
                val ${v}${priv}build_S3ClientBuild = S3ClientBuild(
                    awsRegion = regEditText.text.toString(),
                    awsUrl = urlEditText.text.toString(),
                    awsAccessKeyId = accessKeyEditText.text.toString(),
                    awsSecretAccessKey = secretEditText.text.toString()
                )
                secretEditText.text = null
                accessKeyEditText.text = null
                urlEditText.text = null
                regEditText.text = null
                ` ${ORC_S3}/snippets/build-client.sh ${v}${priv}build_ `
            }

            AlertDialog.Builder(activity)
                .setTitle("S3 credentials")
                .setView(layout)
                .setNegativeButton("Cancel", null)
                .setPositiveButton(
                    "Connect",
                    DialogInterface.OnClickListener(function = conn))
                .show()
        }
    }
}

EOF
