package com.matthewblott.todos

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.View
import android.webkit.CookieManager
import androidx.activity.enableEdgeToEdge
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import dev.hotwire.navigation.activities.HotwireActivity
import dev.hotwire.navigation.navigator.NavigatorConfiguration
import dev.hotwire.navigation.util.applyDefaultImeWindowInsets
import dev.hotwire.core.bridge.KotlinXJsonConverter
import dev.hotwire.core.config.Hotwire
import dev.hotwire.navigation.config.registerBridgeComponents
import dev.hotwire.core.bridge.BridgeComponentFactory
import dev.hotwire.core.turbo.config.PathConfiguration
import com.matthewblott.todos.components.ButtonComponent
import com.matthewblott.todos.components.ToastComponent
import com.matthewblott.todos.helpers.PushDistributorHelper
import org.unifiedpush.android.connector.UnifiedPush

class MainActivity : HotwireActivity() {
  
  companion object {
    private const val REQUEST_CODE_LOCAL_NETWORK = 1001
    private const val NOTIFICATION_PERMISSION_REQUEST_CODE = 1001
  }
  override fun onCreate(savedInstanceState: Bundle?) {
    enableEdgeToEdge()

    val distributors = UnifiedPush.getDistributors(this)

    if (distributors.isEmpty()) {
      // No distributor installed — prompt to install one
      requestNotificationPermissionIfNeeded(this) 
      PushDistributorHelper.ensureDistributorAndRegister(this) {
        PushDistributorHelper.showInstallPrompt(this)
      }
    } else if (distributors.size == 1) {
      // Only one available — just use it, no need to ask the user to choose
      UnifiedPush.saveDistributor(this, distributors.first())
      UnifiedPush.register(this)
    } else {
      // Multiple distributors — let the user pick (rare for most users, but possible)
    }
    
    Hotwire.loadPathConfiguration(
      context = this,
      location = PathConfiguration.Location(
        assetFilePath = "json/path-configuration.json",
      ),
    )

    Hotwire.config.jsonConverter = KotlinXJsonConverter()

    Hotwire.registerBridgeComponents(
      BridgeComponentFactory("button", ::ButtonComponent),
      BridgeComponentFactory("toast", ::ToastComponent),
    )
    
    super.onCreate(savedInstanceState)
    setContentView(R.layout.activity_main)
    findViewById<View>(R.id.main_nav_host).applyDefaultImeWindowInsets()

    if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_LOCAL_NETWORK)
      != PackageManager.PERMISSION_GRANTED) {
      ActivityCompat.requestPermissions(
        this,
        arrayOf(Manifest.permission.ACCESS_LOCAL_NETWORK),
        REQUEST_CODE_LOCAL_NETWORK
      )
    }
  }

  override fun navigatorConfigurations() = listOf(
    NavigatorConfiguration(
      name = "main",
      startLocation = Settings.current.url,
      navigatorHostId = R.id.main_nav_host
    )
  )
  
  fun requestNotificationPermissionIfNeeded(activity: Activity) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      if (ContextCompat.checkSelfPermission(
          activity, Manifest.permission.POST_NOTIFICATIONS
        ) != PackageManager.PERMISSION_GRANTED
      ) {
        ActivityCompat.requestPermissions(
          activity,
          arrayOf(Manifest.permission.POST_NOTIFICATIONS),
          NOTIFICATION_PERMISSION_REQUEST_CODE
        )
      }
    }
  } 
}