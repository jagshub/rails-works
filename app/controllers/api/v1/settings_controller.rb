# frozen_string_literal: true

class API::V1::SettingsController < API::V1::BaseController
  before_action -> { doorkeeper_authorize! :public }, only: :all

  def show
    return unless stale?(current_user)

    if params[:format] == 'oauth'
      render json: serialize_resource(API::V1::OAuthUserInfoSerializer, current_user, cache: false, root: false)
    elsif doorkeeper_token.scopes.include?('private')
      render json: serialize_resource(API::V1::SettingsSerializer, current_user, cache: false)
    else
      render json: serialize_resource(API::V1::UserSerializer, current_user, cache: false)
    end
  end

  def update
    authorize! :update, current_user

    settings = My::UserSettings.new(current_user)

    # NOTE(rstankov): Handle legacy comment_notifications param
    user_params[:send_mention_email] = user_params[:comment_notifications] if user_params.key? :comment_notifications

    if settings.update(user_params)
      render json: serialize_resource(API::V1::SettingsSerializer, current_user)
    else
      handle_error_validation settings
    end
  end

  private

  def user_params
    params.require(:user)
  end
end
