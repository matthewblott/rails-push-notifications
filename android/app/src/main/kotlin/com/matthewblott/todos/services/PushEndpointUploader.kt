package com.matthewblott.todos.services

import android.content.Context
import android.util.Log
import android.webkit.CookieManager
import com.matthewblott.todos.Settings
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

object PushEndpointUploader {
  fun upload(context: Context, endpointUrl: String) {
    val baseUrl = Settings.current.url
    val uploadUrl = "$baseUrl/sessions/current/push_token"

    val cookieManager = CookieManager.getInstance()
    val cookies = cookieManager.getCookie(baseUrl) // e.g. "session_token=...; device_token=..."

    cookies?.split(";")?.forEach { cookie ->
      val value = cookie.trim()
      Log.d("Cookies", value)
    } 
    
    Thread {
      try {
        val connection = URL(uploadUrl).openConnection() as HttpURLConnection
        connection.requestMethod = "POST"
        connection.doOutput = true
        connection.setRequestProperty("Content-Type", "application/json")
        connection.setRequestProperty("Cookie", cookies)

        val body = JSONObject().apply {
          put("push_token", endpointUrl)
          put("platform", "android")
        }

        connection.outputStream.use { it.write(body.toString().toByteArray()) }

        val responseCode = connection.responseCode
        if (responseCode !in 200..299) {
          Log.w("PushEndpointUploader", "Upload failed: $responseCode")
        }
      } catch (e: Exception) {
        Log.e("PushEndpointUploader", "Upload error", e)
      }
    }.start()
  }
}