class PushNotificationJob < ApplicationJob
  queue_as :default

  def perform(session_id, title:, body:, url: nil)
    session = Session.find_by(id: session_id)
    return unless session

    session.push_notify(title:, body:, url:)
  end
end
