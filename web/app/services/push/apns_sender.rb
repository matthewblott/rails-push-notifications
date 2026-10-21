module Push
  class ApnsSender
    class << self
      def send(session, title:, body:, url: nil)
        notification = build_notification(session.push_token, title:, body:, url:)
        response = connection.push(notification)

        unless response
          Rails.logger.error("APNs push timed out for session #{session.id}")
          return
        end

        handle_response(response, session)
      end

      private

      def build_notification(token, title:, body:, url:)
        notification = Apnotic::Notification.new(token)
        notification.alert = { title: title, body: body }
        notification.sound = "default"
        notification.topic = Rails.application.credentials.apns[:bundle_id]
        notification.custom_payload = { url: url }.compact
        notification
      end

      def handle_response(response, session)
        return if response.ok?

        case response.status
        when "410"
          session.update!(push_token: nil)
        when "400"
          if response.body.is_a?(Hash) && response.body["reason"] == "BadDeviceToken"
            session.update!(push_token: nil)
          else
            Rails.logger.error("APNs rejected push: #{response.body}")
          end
        else
          Rails.logger.error("APNs push failed (#{response.status}): #{response.body}")
        end
      end

      def connection
        Thread.current[:apnotic_connection] ||= build_connection
      end

      def build_connection
        opts = {
          auth_method: :token,
          cert_path: Rails.root.join(Rails.application.credentials.apns[:key_path]).to_s,
          key_id: Rails.application.credentials.apns[:key_id],
          team_id: Rails.application.credentials.apns[:team_id]
        }

        apns_environment == :production ? Apnotic::Connection.new(**opts) : Apnotic::Connection.development(**opts)
      end

      def apns_environment
        Rails.application.credentials.apns[:environment]&.to_sym || :development
      end

    end
  end
end
