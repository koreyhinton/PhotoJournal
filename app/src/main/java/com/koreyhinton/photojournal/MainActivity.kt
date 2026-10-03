package com.koreyhinton.photojournal

import android.database.sqlite.SQLiteDatabase
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.koreyhinton.photojournal.data.DbHelper
import com.koreyhinton.photojournal.web.LocalContentWebViewClient
import com.koreyhinton.photojournal.web.JSIface
import androidx.webkit.WebViewAssetLoader
import androidx.webkit.WebViewAssetLoader.AssetsPathHandler
import androidx.webkit.WebViewAssetLoader.ResourcesPathHandler
import android.webkit.WebView
import android.text.InputType
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import android.app.AlertDialog
import android.content.DialogInterface
import android.os.Build
import java.util.Locale

class MainActivity : AppCompatActivity() {
    lateinit var db: SQLiteDatabase
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)
        val dbHelper = DbHelper(this)
        dbHelper.getWritableDatabase() // ensure db gets created first
        db = dbHelper.writableDatabase

        var assetLoader = WebViewAssetLoader.Builder()
            .addPathHandler("/assets/", AssetsPathHandler(this))
            .addPathHandler("/res/", ResourcesPathHandler(this))
            .build()

        var webV = findViewById<WebView>(R.id.webby)
        webV.webViewClient = LocalContentWebViewClient(assetLoader)
        webV.settings.builtInZoomControls = true
        webV.settings.domStorageEnabled = true
        webV.settings.javaScriptEnabled = true
        webV.settings.loadWithOverviewMode = true
        webV.settings.useWideViewPort = true
        webV.settings.displayZoomControls = false
        webV.settings.setSupportZoom(true)
        webV.settings.defaultTextEncodingName = "utf-8"
        webV.addJavascriptInterface(JSIface(applicationContext, this, dbHelper), "JSIface")
        webV.loadUrl("https://appassets.androidplatform.net/assets/index.html")

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        Thread {
            if (dbHelper.retrieveThisDeviceAlias() != null)
                return@Thread;

            var make = Build.MANUFACTURER
            var model = Build.MODEL

            this.runOnUiThread {
                val layout = LinearLayout(this).apply {
                    orientation = LinearLayout.VERTICAL
                    setPadding(48, 24, 48, 8)
                }
                var infoLbl = TextView(this).apply {
                }
                infoLbl.setText("Short name for this phone camera (ie: MYPXL)")
                layout.addView(infoLbl)
                var aliasEditText = EditText(this).apply {
                    hint = "Device short name"
                    inputType = InputType.TYPE_CLASS_TEXT
                }
                layout.addView(aliasEditText)
        
                val conn = { dialog: DialogInterface, which: Int ->
                    Thread click@ {
                        if (aliasEditText.text.toString() == "") {
                            this.runOnUiThread {
                                Toast.makeText(this, "Error: empty field, please try again", Toast.LENGTH_SHORT).show()
                            }
                            return@click
                        }
                        var alias = aliasEditText.text.toString()
                        dbHelper.insertThisDeviceAlias(
                            make = make,
                            model = model,
                            alias = alias
                        )
                        this.runOnUiThread {
                            Toast.makeText(this, "Phone device alias saved", Toast.LENGTH_SHORT).show()
                        }
                    }.start()
                    Unit
                }
                window.decorView.post {
                    AlertDialog.Builder(this)
                        .setTitle("This device alias")
                        .setView(layout)
                        .setMessage("Short name to recognize your device, ie: MYPXL (my pixel)")
                        .setPositiveButton(
                            "Save",
                            DialogInterface.OnClickListener(function = conn))
                        .show()
                }
            }
        }.start()
    }
}
