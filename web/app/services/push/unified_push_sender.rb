module Push
  class UnifiedPushSender
    def self.send(device, title:, body:, url: nil)
      payload = { title:, body:, url: }.compact.to_json
      response = HTTParty.post(device.push_endpoint, body: payload)

      if response.code == 410 # Gone — endpoint no longer valid
        device.update!(push_endpoint: nil, push_enabled: false)
      end
    end
  end
end
