class Session < AuthRecord
  belongs_to :user

  before_validation :generate_device_token, on: :create

  validates :device_token, presence: true, uniqueness: true
  validates :platform, presence: true

  enum :platform, { ios: 0, android: 1, web: 2 }

  scope :push_enabled, -> { where(push_enabled: true) }
  scope :with_push_registration, -> {
    where("(platform = ? AND push_token IS NOT NULL) OR (platform = ? AND push_endpoint IS NOT NULL)",
          platforms[:ios], platforms[:android])
  }

  def push_notify(title:, body:, url: nil)
    return unless push_enabled?

    case platform.to_sym
    when :ios
      return unless push_token.present?
      Push::ApnsSender.send(self, title:, body:, url:)
    when :android
      return unless push_endpoint.present?
      Push::UnifiedPushSender.send(self, title:, body:, url:)
    when :web
      # no push transport (yet) — no-op
    end
  end

  def deliver_push_token!(token)
    update!(push_token: token, push_token_updated_at: Time.current)
  end

  def deliver_push_endpoint!(endpoint)
    update!(push_endpoint: endpoint, push_token_updated_at: Time.current)
  end

  def clear_push_registration!
    update!(push_token: nil, push_endpoint: nil, push_enabled: false)
  end

  private

  def generate_device_token
    self.device_token ||= SecureRandom.urlsafe_base64(32)
  end
end
