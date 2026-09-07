package com.koreyhinton.photojournal.web

import android.content.Context
import android.webkit.JavascriptInterface
import com.koreyhinton.photojournal.data.DbHelper
import com.koreyhinton.photojournal.MainActivity
import android.widget.LinearLayout
import android.widget.EditText
import android.text.InputType
import android.app.AlertDialog

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

            layout.addView(EditText(activity).apply {
                hint = "Access key"
                inputType = InputType.TYPE_CLASS_TEXT
            })

            layout.addView(EditText(activity).apply {
                hint = "Secret key"
                inputType = InputType.TYPE_CLASS_TEXT or
                    InputType.TYPE_TEXT_VARIATION_PASSWORD
            })

            AlertDialog.Builder(activity)
                .setTitle("S3 credentials")
                .setView(layout)
                .setNegativeButton("Cancel", null)
                .setPositiveButton("Connect", null)
                .show()
        }
    }
}
