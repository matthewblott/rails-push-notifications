class PushRegistrationsController < ApplicationController
  # relies on your existing before_action (likely `load_current_user`
  # or whatever wraps it) having already set Current.session
  skip_before_action :verify_authenticity_token, only: [:update]

  def update
    unless Current.session
      return head :unauthorized
    end

    unless ALLOWED_PLATFORMS.include?(params[:platform])
      return render json: { error: 'invalid platform' }, status: :unprocessable_entity
    end

    case params[:platform]
    when 'ios'
      Current.session.update!(
        platform: params[:platform],
        push_token: params[:push_token],
        push_token_updated_at: Time.current
      )
    when 'android'
      Current.session.update!(
        platform: params[:platform],
        push_endpoint: params[:push_token], # Android sends its UnifiedPush endpoint through the same param
        push_token_updated_at: Time.current
      )
    end

    head :no_content
  end

  private

  ALLOWED_PLATFORMS = %w[ios android].freeze
end
