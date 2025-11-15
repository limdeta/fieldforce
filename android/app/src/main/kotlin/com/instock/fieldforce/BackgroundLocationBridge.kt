package com.instock.fieldforce

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodChannel

/**
 * Shared bridge so background services can send status callbacks to Flutter.
 */
object BackgroundLocationBridge {
    @Volatile
    var methodChannel: MethodChannel? = null

    fun sendStatus(status: String) {
        val channel = methodChannel ?: run {
            Log.d("BackgroundBridge", "MethodChannel not ready; dropping status=$status")
            return
        }
        Handler(Looper.getMainLooper()).post {
            channel.invokeMethod("onStatus", status)
        }
    }
}
