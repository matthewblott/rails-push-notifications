class GuestSessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: :create

  def create
    if Current.user
      return redirect_to user_home_path(Current.user)
    end

    platform = helpers.detect_platform(request)

    user = User.create!
    session = user.sessions.create!(platform: platform) 

    cookies.permanent.encrypted[:device_token] = {
      value: session.device_token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }

    Current.session = session
    Current.user = user

    redirect_to user_home_path(Current.user)
  end

end
