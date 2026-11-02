package com.matthewblott.todos.services

import android.app.Activity
import com.google.firebase.messaging.FirebaseMessaging

object PushRegistrar {
  fun register(activity: Activity) {
    FirebaseMessaging.getInstance().token.addOnSuccessListener { token ->
      PushEndpointUploader.upload(activity, token, provider = "fcm")
    }
  }
}
