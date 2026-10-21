import BridgeComponents
import HotwireNative
import UIKit
import UserNotifications
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
#if DEBUG
    Hotwire.config.debugLoggingEnabled = true
#endif
    Hotwire.registerBridgeComponents(
      Bridgework.coreComponents + [
        AuthenticatedComponent.self,
      ]
    )
    
    let localPathConfigURL = Bundle.main.url(forResource: "path-configuration", withExtension: "json")!

    Hotwire.loadPathConfiguration(from: [
      .file(localPathConfigURL),
    ])
    Hotwire.config.defaultViewController = { ViewController(url: $0) }
    Hotwire.config.applicationUserAgentPrefix = "Todos;"
    UNUserNotificationCenter.current().delegate = self
    return true
  }
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    PushTokenUploader.upload(tokenString)
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    // token registration failed — log it, don't block app usage
  }
  
  func requestPushAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      guard granted else { return }
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    defer { completionHandler() }
    
    print("📬 didReceive fired, userInfo: \(response.notification.request.content.userInfo)")
    
    guard let urlString = response.notification.request.content.userInfo["url"] as? String,
          let url = URL(string: urlString) else {
      print("📬 Failed to extract URL from userInfo")
      return
    }
    
    print("📬 Routing to: \(url)")
    
    NotificationRouter.route(to: url)
  }
  
  // Optional but worth adding: controls whether a notification shows
  // its banner/sound while the app is in the foreground
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound])
  }
}

enum NotificationRouter {
  static func route(to url: URL) {
    guard let sceneDelegate = UIApplication.shared.connectedScenes
      .first?.delegate as? SceneDelegate else {
      print("📬 Could not get SceneDelegate")
      return
    }
   
    guard let baseURL = Endpoint.baseURL,
          let resolvedURL = URL(string: url.relativeString, relativeTo: baseURL)?.absoluteURL else {
      print("📬 Failed to resolve notification URL against base URL")
      return
    }
    
    print("📬 Calling navigator.route(\(url))")
    sceneDelegate.navigator.route(resolvedURL)
  }
}

enum PushTokenUploader {
  static func upload(_ token: String) {
    guard let baseURL = Endpoint.baseURL else { return }
    let uploadURL = baseURL.appendingPathComponent("sessions/current/push_token")
    
    WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
      var request = URLRequest(url: uploadURL)
      request.httpMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
      let cookieHeader = HTTPCookie.requestHeaderFields(with: cookies)
      request.allHTTPHeaderFields = cookieHeader
      
      let body: [String: String] = ["push_token": token, "platform": "ios"]
      request.httpBody = try? JSONSerialization.data(withJSONObject: body)
      
      URLSession.shared.dataTask(with: request) { _, response, error in
        if let error = error {
          // log, retry later — don't block app usage on this failing
          print("Push token upload failed: \(error)")
          return
        }
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
          print("Push token upload returned \(http.statusCode)")
        }
      }.resume()
    }
  }
}
