# frozen_string_literal: true

class MultiFactorTokenController < ApplicationController
  skip_before_action :verify_authenticity_token

  def authenticate
    token = MultiFactorToken.find_by(token: params[:token])
    user = token&.user

    if user && !token.expired?
      token.update!(expires_at: Time.zone.now)
      session[:user_id] = user.id

      redirect_to root_path
    else
      redirect_to my_multi_factor_token_path
    end
  end
end
