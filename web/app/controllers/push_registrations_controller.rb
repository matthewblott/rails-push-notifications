class PushRegistrationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:update]

  ALLOWED_PLATFORMS = %w[ios android].freeze

  def update
    return head :unauthorized unless Current.session

    unless ALLOWED_PLATFORMS.include?(params[:platform])
      return render json: { error: 'invalid platform' }, status: :unprocessable_entity
    end

    provider = params[:provider].presence || (params[:platform] == 'ios' ? 'apns' : 'unifiedpush')

    case provider
    when 'apns', 'fcm'
      Current.session.update!(
        platform: params[:platform],
        push_token: params[:push_token],
        push_endpoint: nil,
        push_token_updated_at: Time.current
      )
    when 'unifiedpush'
      Current.session.update!(
        platform: params[:platform],
        push_endpoint: params[:push_token], # the UnifiedPush endpoint arrives in the push_token param
        push_token: nil,
        push_token_updated_at: Time.current
      )
    else
      return render json: { error: 'invalid provider' }, status: :unprocessable_entity
    end

    head :no_content
  end
end
