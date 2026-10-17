require "net/http"

module Push
  class UnifiedPushSender
    def self.send(session, title:, body:, url: nil)
      payload = { title:, body:, url: }.compact.to_json
      uri = URI.parse(session.push_endpoint)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"

      request = Net::HTTP::Post.new(uri.request_uri)
      request["Content-Type"] = "application/json"
      request.body = payload

      response = http.request(request)
      handle_response(response, session)
    end

    def self.handle_response(response, session)
      return if response.is_a?(Net::HTTPSuccess)

      case response.code.to_i
      when 404, 410
        session.update!(push_endpoint: nil)
      else
        Rails.logger.error("UnifiedPush send failed (#{response.code}): #{response.body}")
      end
    end
  end
end
