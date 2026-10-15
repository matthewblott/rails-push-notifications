import HotwireNative
import UIKit

class ViewController: HotwireWebViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let properties = Hotwire.config.pathConfiguration.properties(for: currentVisitableURL)
    let hideBack = properties["hide_back_button"] as? Bool ?? false
    self.navigationItem.hidesBackButton = hideBack
  }
}
