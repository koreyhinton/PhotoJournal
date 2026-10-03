package com.koreyhinton.photojournal.log

import android.util.Log

/*
    Hamburger icon
        > View (top-level menu item)
            > Tool windows
                > Logcat
                    Click the dropdown to change from emulator to my device name
                        * Note the selected icon w/ a cat face on it in the
                          narrow left-pane to open it again faster next time
*/

fun Log(message: String) {
    Log.d("DEBUG", message)
}
