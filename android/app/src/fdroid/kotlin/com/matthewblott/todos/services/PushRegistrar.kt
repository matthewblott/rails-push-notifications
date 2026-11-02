package com.matthewblott.todos.services

import android.app.Activity
import com.matthewblott.todos.helpers.PushDistributorHelper

object PushRegistrar {
  fun register(activity: Activity) {
    PushDistributorHelper.ensureDistributorAndRegister(activity) {
      PushDistributorHelper.showInstallPrompt(activity)
    }
  }
}