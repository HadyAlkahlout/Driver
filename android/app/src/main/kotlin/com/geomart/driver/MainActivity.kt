package com.geomart.driver

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context

import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val NOTIFICATIONS_CHANNEL = "notifications.manage"
    private val LIFECYCLE_CHANNEL = "app.lifecycle/events"

    private var lifecycleMethodChannel: MethodChannel? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Existing notifications channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATIONS_CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getChannels") {
                val notificationChannels = getNotificationChannels()
                if (notificationChannels != null) {
                    result.success(notificationChannels)
                } else {
                    result.error("UNAVAILABLE", "No notification channels", null)
                }
            } else if (call.method == "deleteChannel") {
                deleteNotificationChannel(call.argument("id")!!)
                result.success("Notification channel deleted")
            } else {
                result.notImplemented()
            }
        }

        // New lifecycle events channel
        lifecycleMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LIFECYCLE_CHANNEL)
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        // Notify Flutter that user is leaving app (before background)
        lifecycleMethodChannel?.invokeMethod("onUserLeaveHint", null)
    }

    private fun getNotificationChannels(): List<String>? {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager.notificationChannels.map { it -> "${it.id} -- ${it.name}" }.toList()
        } else {
            null
        }
    }

    private fun deleteNotificationChannel(channelId: String) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager.deleteNotificationChannel(channelId)
        }
    }
}
