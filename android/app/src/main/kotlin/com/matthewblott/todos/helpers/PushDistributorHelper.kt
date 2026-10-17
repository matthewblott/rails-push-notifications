package com.matthewblott.todos.helpers

import android.app.Activity
import androidx.appcompat.app.AlertDialog
import android.content.Context
import android.content.Intent
import android.net.Uri
import org.unifiedpush.android.connector.UnifiedPush

object PushDistributorHelper {

  private const val NTFY_PACKAGE = "io.heckel.ntfy"
  private const val FDROID_NTFY_URL = "https://f-droid.org/packages/$NTFY_PACKAGE/"

  fun ensureDistributorAndRegister(context: Context, onNoDistributor: () -> Unit) {
    val distributors = UnifiedPush.getDistributors(context)

    when {
      distributors.isEmpty() -> onNoDistributor()
      distributors.size == 1 -> {
        // This is idempotent
        UnifiedPush.saveDistributor(context, distributors.first())
        UnifiedPush.register(context)
      }
      else -> {
        // Multiple distributors installed — default to the first for now;
        // revisit with a picker UI if this becomes common among your users
        UnifiedPush.saveDistributor(context, distributors.first())
        UnifiedPush.register(context)
      }
    }
  }

  fun showInstallPrompt(activity: Activity) {
    AlertDialog.Builder(activity)
      .setTitle("Enable notifications")
      .setMessage(
        "To receive notifications, install ntfy — a small, open-source " +
          "notification app. It doesn't require Google Play services."
      )
      .setPositiveButton("Install ntfy") { _, _ ->
        openNtfyInstallPage(activity)
      }
      .setNegativeButton("Not now", null)
      .show()
  }

  private fun openNtfyInstallPage(context: Context) {
    // Prefer opening directly in the F-Droid app if it's installed
    val fdroidIntent = Intent(Intent.ACTION_VIEW).apply {
      data = Uri.parse("market://details?id=$NTFY_PACKAGE")
      setPackage("org.fdroid.fdroid")
    }

    val resolved = fdroidIntent.resolveActivity(context.packageManager) != null

    val intent = if (resolved) {
      fdroidIntent
    } else {
      // Fall back to the F-Droid web page — works even without F-Droid installed
      Intent(Intent.ACTION_VIEW, Uri.parse(FDROID_NTFY_URL))
    }

    context.startActivity(intent)
  }
}