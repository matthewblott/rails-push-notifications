require 'net/http'
require 'googleauth'

module Push
  class FcmSender
    SCOPE = 'https://www.googleapis.com/auth/firebase.messaging'.freeze

    def self.send(session, title:, body:, url: nil)
      project_id = Rails.application.credentials.fcm[:project_id]
      uri = URI("https://fcm.googleapis.com/v1/projects/#{project_id}/messages:send")

      payload = {
        message: {
          token: session.push_token,
          data: { title:, body:, url: }.compact.transform_values(&:to_s), # FCM data values must be strings
          android: { priority: 'high' }
        }
      }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri,
        'Content-Type' => 'application/json',
        "Authorization" => "Bearer #{access_token}")
      request.body = payload.to_json

      handle_response(http.request(request), session)
    end

    def self.handle_response(response, session)
      return if response.is_a?(Net::HTTPSuccess)

      if response.code.to_i == 404
        session.update!(push_token: nil) # unregistered token
      else
        Rails.logger.error("FCM send failed (#{response.code}): #{response.body}")
      end
    end

    def self.access_token
      Rails.cache.fetch('fcm_access_token', expires_in: 50.minutes) do
        creds = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File.open(Rails.root.join(Rails.application.credentials.fcm[:key_path])),
          scope: SCOPE
        )
        creds.fetch_access_token!['access_token']
      end
    end
  end
end
