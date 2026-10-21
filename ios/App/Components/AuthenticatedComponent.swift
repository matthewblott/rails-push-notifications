import HotwireNative
import UIKit

public final class AuthenticatedComponent: BridgeComponent {
  override public nonisolated class var name: String { "authenticated" }
  
  override public func onReceive(message: Message) {
    guard let event = Event(rawValue: message.event) else { return }
    
    switch event {
    case .connect:
      if let data: MessageData = message.data() {
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        if let sceneDelegate {
          sceneDelegate.requestPushAuthorization()
        }
      }
      
      return
    case .disconnect:
      return
    }
  }
  
}

private extension AuthenticatedComponent {
  enum Event: String {
    case connect
    case disconnect
  }
}

private extension AuthenticatedComponent {
  struct MessageData: Decodable {
    let value: String
    
    enum CodingKeys: String, CodingKey {
      case value
    }
  }
}

