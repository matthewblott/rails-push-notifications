package com.matthewblott.todos.services

import android.app.Activity
import com.matthewblott.todos.helpers.PushDistributorHelper
import org.unifiedpush.android.connector.UnifiedPush

object PushRegistrar {
  fun register(activity: Activity) {
     val distributors = UnifiedPush.getDistributors(activity)
     if (distributors.isEmpty()) {
       // No distributor installed — prompt to install one
       PushDistributorHelper.ensureDistributorAndRegister(activity) {
         PushDistributorHelper.showInstallPrompt(activity)
       }
     } else if (distributors.size == 1) {
       // Only one available — just use it, no need to ask the user to choose
       // The user needs to be signed in prior to running this because cookies are used
       // and the push notifications are tied to the signed-in session.
       UnifiedPush.saveDistributor(activity, distributors.first())
       UnifiedPush.register(activity)
     } else {
       // Multiple distributors — let the user pick (rare for most users, but possible)
     }
  }
}