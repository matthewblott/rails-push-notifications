import HotwireNative
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  let navigator = Navigator(configuration: .init(
    name: "main",
    startLocation: Endpoint.baseURL!
  ))
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    
    window = UIWindow(windowScene: windowScene)
    navigator.delegate = self
    window?.rootViewController = navigator.rootViewController
    window?.makeKeyAndVisible()
    navigator.start()
    
    // The following needs to happen after the user has signed in or push notifications won't work
    (UIApplication.shared.delegate as? AppDelegate)?.requestPushAuthorization()
  }
}

extension SceneDelegate: NavigatorDelegate {
  func handle(proposal: VisitProposal) -> ProposalResult {
    return .accept
  }
}
