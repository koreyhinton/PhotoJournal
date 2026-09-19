#!/bin/bash

v=${1:-jsi_}
priv=${RANDOM}_
# maps
export ${v}${priv}_list_S3ClientBuild=${v}${priv}_build_S3ClientBuild
export ${v}${priv}_objects_S3ClientBuild=${v}${priv}_build_S3ClientBuild
export ${v}${priv}objects_S3Bucket=b

cat << EOF

package com.koreyhinton.photojournal.web

import android.content.Context
import android.webkit.JavascriptInterface
import com.koreyhinton.photojournal.R
import com.koreyhinton.photojournal.data.DbHelper
import com.koreyhinton.photojournal.models.S3ClientBuild
import com.koreyhinton.photojournal.MainActivity
import android.widget.LinearLayout
import android.widget.EditText
import android.widget.TextView
import android.text.InputType
import android.app.AlertDialog
import android.content.DialogInterface
import android.webkit.WebView
import java.io.File

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

        val cacheFile = File(context.cacheDir, ".pj-s3-cache")
        val unicodeFieldSep = "\u001F"

        var cachedAccessKey: String? = null
        var cachedRegion: String? = null
        var cachedUrl: String? = null
        if (cacheFile.exists()) {
            val values = cacheFile.readText().split(unicodeFieldSep)
            var i = 0;
            if (values.size > i)
                cachedAccessKey = values[i++]
            if (values.size > i)
                cachedRegion = values[i++]
            if (values.size > i)
                cachedUrl = values[i]
        }

        activity.runOnUiThread {
            val layout = LinearLayout(activity).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(48, 24, 48, 8)
            }

            // Access Key
            var accessKeyLbl = TextView(activity).apply {
            }
            accessKeyLbl.setText("Access Key")
            layout.addView(accessKeyLbl)
            var accessKeyEditText = EditText(activity).apply {
                hint = "Access key"
                inputType = InputType.TYPE_CLASS_TEXT
            }
            if (cachedAccessKey != null)
                accessKeyEditText.setText(cachedAccessKey)
            layout.addView(accessKeyEditText)

            // Secret Key
            var secretKeyLbl = TextView(activity).apply {
            }
            secretKeyLbl.setText("Secret Key")
            layout.addView(secretKeyLbl)
            val secretEditText = EditText(activity).apply {
                hint = "Secret key"
                inputType = InputType.TYPE_CLASS_TEXT or
                    InputType.TYPE_TEXT_VARIATION_PASSWORD
            }
            layout.addView(secretEditText)

            // Region
            var regLbl = TextView(activity).apply {
            }
            regLbl.setText("Region")
            layout.addView(regLbl)
            var regEditText = EditText(activity).apply {
                hint = "Region"
                inputType = InputType.TYPE_CLASS_TEXT
            }
            if (cachedRegion != null)
                regEditText.setText(cachedRegion)
            layout.addView(regEditText)

            // Url
            var urlLbl = TextView(activity).apply {
            }
            urlLbl.setText("Url")
            layout.addView(urlLbl)
            var urlEditText = EditText(activity).apply {
                hint = "Url"
                inputType = InputType.TYPE_CLASS_TEXT
            }
            if (cachedUrl != null)
                urlEditText.setText(cachedUrl)
            layout.addView(urlEditText)

            val conn = { dialog: DialogInterface, which: Int ->

                Thread {
                    cacheFile.writeText(
                        accessKeyEditText.text.toString() + unicodeFieldSep +
                        regEditText.text.toString() + unicodeFieldSep +
                        urlEditText.text.toString()
                    )
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

                    var counts = mutableListOf<Int>()

                    ` ${ORC_S3}/snippets/build-client.sh ${v}${priv}build_ `
                    ` ${ORC_S3}/snippets/list-buckets.sh ${v}${priv}list_ `
                    for (b in ${v}${priv}list_S3BucketCsv.split(",")) {
                        ` ${ORC_S3}/snippets/list-files.sh ${v}${priv}objects_ `
                        counts.add(
                            ${v}${priv}objects_S3FilesCsv.split(",").count())
                    }

                    activity.runOnUiThread {
                        var webV = activity.findViewById<WebView>(R.id.webby)
                        webV.post {
                            webV.evaluateJavascript("document.write('"+${v}${priv}list_S3BucketCsv+counts.joinToString(separator="-")+"');", null)
                        }
                    }
                }.start()



                Unit
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
