# frozen_string_literal: true

class NewSocialLoginController < ApplicationController
  skip_before_action :verify_authenticity_token

  def authenticate
    social_login = Users::NewSocialLogin.processable.find_by token: params[:token]
    new_social_login_id = SignIn.session_new_social_login_id(session)

    if social_login.blank?
      redirect_to not_found_path

    elsif new_social_login_id.blank? ||
          new_social_login_id != social_login.id
      social_login.browser_invalid!
      # TODO(DZ): This should be error notifying they need another session
      redirect_to not_found_path

    elsif SignIn.merge_new_social_login(social_login)
      SignIn.reset_session_new_social_login_id(session)
      session[:user_id] = social_login.user_id
      track_sign_in social_login.user

      redirect_to root_path

    else
      redirect_to root_path
    end
  end

  def track_sign_in(user)
    Metrics.track_signin(
      user: user,
      options: {
        first_time: user.first_time_user?,
        provider: 'email',
        link_location: 'new_social_login_controller',
      },
    )
  end
end
