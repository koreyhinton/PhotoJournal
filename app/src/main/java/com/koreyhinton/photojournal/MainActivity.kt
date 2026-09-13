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

class MainActivity : AppCompatActivity() {
    lateinit var db: SQLiteDatabase
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)
        val dbHelper = DbHelper(this)
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
    }
}
