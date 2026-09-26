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
export ${v}seek_s3id_Id=s3Id
export ${v}seek_buckid_Id=bucketId
export ${v}newfound_bucket_Text="bucketId.toString()"
export ${v}newfound_bucket_s3_Text="s3Id.toString()"
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
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
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

        // there could be 2 phones accessing same s3 bucket, so we need to add
        // a device hash component so it writes to its own surrogate id files
        var dvcHash = java.security.MessageDigest.getInstance("SHA-256").digest(
            android.provider.Settings.Secure.getString(
                context.getContentResolver(),
                android.provider.Settings.Secure.ANDROID_ID
                ).toByteArray(Charsets.UTF_8)
        ).joinToString("") { "\$02x".format(it) }

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

                    // Save to cache before the early-return, so that the
                    // fields aren't re-entered once the dialog is opened anew

                    cacheFile.writeText(
                        accessKeyEditText.text.toString() + unicodeFieldSep +
                        regEditText.text.toString() + unicodeFieldSep +
                        urlEditText.text.toString()
                    )

                    if (
                        regEditText.text.toString() == "" ||
                        accessKeyEditText.text.toString() == "" ||
                        urlEditText.text.toString() == "" ||
                        secretEditText.text.toString() == ""
                    ) {
                        secretEditText.text = null
                        accessKeyEditText.text = null
                        urlEditText.text = null
                        regEditText.text = null
                        activity.runOnUiThread {
                            Toast.makeText(activity, "Error: empty field, please try again", Toast.LENGTH_SHORT).show()
                        }
                        return@Thread
                    }

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

                    var progressDialog: AlertDialog? = null
                    activity.runOnUiThread {
                        progressDialog = AlertDialog.Builder(activity)
                            .setTitle("Syncing")
                            .setMessage("Please wait...")
                            .setView(ProgressBar(context).apply {
                                isIndeterminate = true
                                setPadding(40, 40, 40, 40)
                            })
                            .setCancelable(false)
                            .create()
                        progressDialog.show()
                    }

                    var counts = mutableListOf<Int>()

                    ` ${ORC_S3}/snippets/build-client.sh ${v}${priv}build_ `
                    if (${S3_CLIENT_BUILD_CLASS_FULL}.client == null) {
                        activity.runOnUiThread {
                            progressDialog?.dismiss()
                            Toast.makeText(
                                activity,
                                "Error: failed to initialize s3 client, " +
                                    "please try again and verify login",
                                Toast.LENGTH_SHORT
                            ).show()
                        }
                        return@Thread
                    }
                    ` ${ORC_S3}/snippets/list-buckets.sh ${v}${priv}list_ `
                    val buckets = ${v}${priv}list_S3BucketCsv.split(",")

                    var s3Id: Long? = null
                    for (b in buckets) {
                        val ${v}seek_s3id_S3File = S3File(
                            bucket = b,
                            name = "${PJ_APP_S3_ID}" + dvcHash
                        )
                        ` ./JSIface-read-id.sh ${v}seek_s3id_ `
                        if (s3Id != null)
                            break;
                    }

                    if (s3Id == null || dbHelper.zeroS3Data()) {
                        // write new s3 and bucket records to the database
                        // each paired with 2 dot id files saved in each bucket
                        s3Id = dbHelper.insertS3()
                        for (b in buckets) {
                            var bucketId = dbHelper.insertBucket(s3Id)

                            // write both dot id files
                            val ${v}s3_S3File = S3File(
                                bucket = b,
                                name = "${PJ_APP_S3_ID}" + dvcHash
                            )
                            val ${v}s3_Text = s3Id.toString()
                            ` ${ORC_S3}/snippets/create-file.sh ${v}s3_`
                            if (!${v}s3_S3ConfirmedFile.exists)
                                throw Exception("Unable to create s3 dot id file")

                            val ${v}bucket_S3File = S3File(
                                bucket = b,
                                name = "${PJ_APP_BUCKET_ID}" + dvcHash
                            )
                            val ${v}bucket_Text = s3Id.toString()
                            ` ${ORC_S3}/snippets/create-file.sh ${v}bucket_`
                            if (!${v}bucket_S3ConfirmedFile.exists)
                                throw Exception("Unable to create bucket dot id file for bucket: " + b)
                        }
                    }

                    for (b in buckets) {

                        var bucketId: Long? = null
                        val ${v}seek_buckid_S3File = S3File(
                            bucket = b,
                            name = "${PJ_APP_BUCKET_ID}" + dvcHash
                        )
                        ` ./JSIface-read-id.sh ${v}seek_buckid_ `
                        if (bucketId == null) {
                            bucketId = dbHelper.insertBucket(s3Id)
                            val ${v}newfound_bucket_S3File = S3File(
                                bucket = b,
                                name = "${PJ_APP_BUCKET_ID}" + dvcHash
                            )
                            ` ${ORC_S3}/snippets/create-file.sh ${v}newfound_bucket_ `
                            if (!${v}newfound_bucket_S3ConfirmedFile.exists)
                                throw Exception("unable to create bucket id in bucket: " + b)

                            val ${v}newfound_bucket_s3_S3File = S3File(
                                bucket = b,
                                name = "${PJ_APP_S3_ID}" + dvcHash
                            )
                            ` ${ORC_S3}/snippets/create-file.sh ${v}newfound_bucket_s3_ `
                            if (!${v}newfound_bucket_s3_S3ConfirmedFile.exists)
                                throw Exception("unable to create s3 id in bucket: " + b)
                        }

                        // todo: sync from s3 to create bucket_dcim/dcim records
                        ` ${ORC_S3}/snippets/list-files.sh ${v}${priv}objects_ `
                        counts.add(
                            ${v}${priv}objects_S3FilesCsv.split(",").count())
                    }

                    activity.runOnUiThread {
                        progressDialog?.dismiss()
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
