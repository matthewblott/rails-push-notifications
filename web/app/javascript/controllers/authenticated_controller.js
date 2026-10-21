import { BridgeComponent } from '@hotwired/hotwire-native-bridge'

export default class extends BridgeComponent {
  static component = 'authenticated'

  connect() {
    super.connect()
    const data = { value: this.bridgeElement.element.value }
    this.send('connect', data)
  }
}
