#!/bin/bash

v=${1:-jsi_}
priv=${RANDOM}_

# local
PJ_APP_S3_ID=".pj_app_s3_id"
PJ_APP_BUCKET_ID=".pj_app_bucket_id"

# maps
export ${v}${priv}_list_S3ClientBuild=${v}${priv}_build_S3ClientBuild
export ${v}${priv}_objects_S3ClientBuild=${v}${priv}_build_S3ClientBuild
export ${v}${priv}objects_S3Bucket=b
export ${v}ft_S3File=${v}fe_S3File
cat << EOF

package com.koreyhinton.photojournal.web

import android.content.Context
import android.webkit.JavascriptInterface
import com.koreyhinton.photojournal.R
import com.koreyhinton.photojournal.data.DbHelper
import com.koreyhinton.photojournal.models.S3File
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
                    val buckets = ${v}${priv}list_S3BucketCsv.split(",")

                    var s3Id: Long? = null
                    for (b in buckets) {
                        val ${v}fe_S3File = S3File(
                            bucket = b,
                            name = "${PJ_APP_S3_ID}"
                        )
                        ` ${ORC_S3}/snippets/file-exists.sh ${v}fe_ `
                        if (${v}fe_S3ConfirmedFile.exists) {
                            ` ${ORC_S3}/snippets/file-text.sh ${v}ft_ `
                            if (${v}ft_S3FileText == null)
                                throw Exception("Error: Id file exists but failed on read. Cannot continue to create possible duplicate db records. Resolve manually (look at logs and either retry in case of s3 failure, or either fix the corrupt .${PJ_APP_S3_ID} file or delete them from respective buckets after confirming it is safe to proceed to create all the image db records)")
                            s3Id = ${v}ft_S3FileText.toLong()
                            break;
                        }
                    }

                    if (s3Id == null) {
                        // write new s3 and bucket records to the database
                        // each paired with 2 dot id files saved in each bucket
                        s3Id = dbHelper.insertS3()
                        for (b in buckets) {
                            var bucketId = dbHelper.insertBucket(s3Id)

                            // write both dot id files
                            val ${v}s3_S3File = S3File(
                                bucket = b,
                                name = "${PJ_APP_S3_ID}"
                            )
                            val ${v}s3_Text = s3Id.toString()
                            ` ${ORC_S3}/snippets/create-file.sh ${v}s3_`
                            if (!${v}s3_S3ConfirmedFile.exists)
                                throw Exception("Unable to create s3 dot id file")
                            
                            val ${v}bucket_S3File = S3File(
                                bucket = b,
                                name = "${PJ_APP_BUCKET_ID}"
                            )
                            val ${v}bucket_Text = s3Id.toString()
                            ` ${ORC_S3}/snippets/create-file.sh ${v}bucket_`
                            if (!${v}bucket_S3ConfirmedFile.exists)
                                throw Exception("Unable to create bucket dot id file for bucket: " + b)

                        }
                    }

                    for (b in buckets) {

                        // todo: obtain the bucketId from the dot id file
                        // todo: same code as when retrieving s3id above,
                        //       possibly factor out into its own sh file

                        // todo: sync from s3 to create bucket_dcim/dcim records
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
