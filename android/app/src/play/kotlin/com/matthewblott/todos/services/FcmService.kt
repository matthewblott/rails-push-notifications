package com.matthewblott.todos.services

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class FcmService : FirebaseMessagingService() {
  override fun onNewToken(token: String) {
    PushEndpointUploader.upload(this, token, provider = "fcm")
  }

  override fun onMessageReceived(message: RemoteMessage) {
    val d = message.data
    NotificationHelper.show(this, d["title"] ?: "Todos", d["body"] ?: "", d["url"])
  }
}
