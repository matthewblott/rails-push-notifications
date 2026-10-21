package com.matthewblott.todos.components

import android.util.Log
import com.matthewblott.todos.MainActivity
import dev.hotwire.core.bridge.BridgeComponent
import dev.hotwire.core.bridge.BridgeDelegate
import dev.hotwire.core.bridge.Message
import dev.hotwire.navigation.destinations.HotwireDestination
import dev.hotwire.navigation.fragments.HotwireFragment
import kotlinx.serialization.Serializable

class AuthenticatedComponent(
  value: String,
  private val bridgeDelegate: BridgeDelegate<HotwireDestination>
) : BridgeComponent<HotwireDestination>(value, bridgeDelegate) {
  private val fragment: HotwireFragment
    get() = bridgeDelegate.destination.fragment as HotwireFragment

  override fun onReceive(message: Message) {
    when (message.event) {
      "connect" -> {
        val data = message.data<MessageData>() ?: return
          val activity = fragment.activity as MainActivity 
          activity.requestNotificationPermission()
      }
      else -> Log.w("AuthenticatedComponent", "Unknown event for message: $message")
    }
  }

  @Serializable
  data class MessageData(
    val value: String,
  )
}
