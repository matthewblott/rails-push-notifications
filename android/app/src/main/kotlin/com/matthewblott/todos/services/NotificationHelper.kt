package com.matthewblott.todos.services

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.matthewblott.todos.MainActivity
import com.matthewblott.todos.R

object NotificationHelper {
  private const val CHANNEL_ID = "todos_default"

  fun show(context: Context, title: String, body: String, url: String?) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
      ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS)
      != PackageManager.PERMISSION_GRANTED
    ) {
      Log.w("TodosPush", "Notification permission not granted — dropping push")
      return
    }

    val notificationManager = context.getSystemService(NotificationManager::class.java)

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      notificationManager.createNotificationChannel(
        NotificationChannel(CHANNEL_ID, "General notifications", NotificationManager.IMPORTANCE_DEFAULT)
      )
    }

    val intent = Intent(context, MainActivity::class.java).apply {
      flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
      putExtra("notification_url", url)
    }

    val pendingIntent = PendingIntent.getActivity(
      context, 0, intent,
      PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
    )

    val notification = NotificationCompat.Builder(context, CHANNEL_ID)
      .setContentTitle(title)
      .setContentText(body)
      .setSmallIcon(R.drawable.ic_notification)
      .setAutoCancel(true)
      .setContentIntent(pendingIntent)
      .build()

    notificationManager.notify(System.currentTimeMillis().toInt(), notification)
  }
}