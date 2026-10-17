package com.matthewblott.todos.services

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.matthewblott.todos.R
import org.json.JSONObject
import org.unifiedpush.android.connector.FailedReason
import org.unifiedpush.android.connector.PushService
import org.unifiedpush.android.connector.data.PushEndpoint
import org.unifiedpush.android.connector.data.PushMessage

class PushServiceImpl : PushService() {

  override fun onNewEndpoint(endpoint: PushEndpoint, instance: String) {
    PushEndpointUploader.upload(this, endpoint.url)
  }

  override fun onMessage(message: PushMessage, instance: String) {
    val json = try {
      JSONObject(String(message.content, Charsets.UTF_8))
    } catch (e: Exception) {
      Log.e("Push", "Failed to parse push payload", e)
      return
    }

    val title = json.optString("title", "Skribl")
    val body = json.optString("body", "")
    val url = json.optString("url", null)

    showNotification(title, body, url) 
  }

  override fun onRegistrationFailed(reason: FailedReason, instance: String) {
    Log.w("Push", "Registration failed: $reason")
  }

  override fun onUnregistered(instance: String) {
    // Distributor dropped you: tell your backend to stop using the old endpoint
    Log.w("Push", "Unregistered")
  }
  
  private fun showNotification(title: String, body: String, url: String?) {
    val channelId = "todos_default"

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
      ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
      != PackageManager.PERMISSION_GRANTED
    ) {
      Log.w("Push", "Notification permission not granted — dropping push")
      return
    }
    
    val notificationManager =
      getSystemService(NotificationManager::class.java)

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val channel = NotificationChannel(
        channelId,
        "General notifications",
        NotificationManager.IMPORTANCE_DEFAULT
      )
      notificationManager.createNotificationChannel(channel)
    }

    val notification = NotificationCompat.Builder(this, channelId)
      .setContentTitle(title)
      .setContentText(body)
      .setSmallIcon(R.drawable.ic_notification)
      .setAutoCancel(true)
      .build()

    notificationManager.notify(System.currentTimeMillis().toInt(), notification)
  } 
}