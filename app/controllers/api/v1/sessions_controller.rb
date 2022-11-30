# frozen_string_literal: true

class API::V1::SessionsController < API::V1::BaseController
  before_action :load_app, only: %i(create update)
  # NOTE(andreasklinger): requests an string from twitter that the client
  #   can use to request an access_token from twitter
  #
  # Note(LukasFittl): This is deprecated and unused since at least iOS release 3.0
  def create
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = @oauth_app.twitter_consumer_key
      config.consumer_secret     = @oauth_app.twitter_consumer_secret
    end

    render json: { reverse_auth_parameters: client.reverse_token }, status: :created
  end

  # NOTE(andreasklinger): After the client did the oauth flow with twitter
  #   they sends us their token and secret
  def update
    auth_response = SignIn.auth_response_from_api(params, @oauth_app)

    if auth_response.blank?
      render_error(
        error: 'app_sign_in_error',
        error_description: 'Invalid or expired token.',
        details: 'Send new token',
      )
      return
    end

    # NOTE(rstankov): Handle duplicated accounts
    #   we just auto-merge google login (which should be the most login)
    #   if mobile app can handle duplicates show errors, otherwise ignore
    duplicated_provider = SignIn.duplicated_user_provider(auth_response, @oauth_app.id)
    if duplicated_provider.present?
      if params[:handle_duplicates]
        render_error(
          error: 'app_duplicated_account',
          error_description: "You have an existing login with #{ duplicated_provider }. Please login with #{ duplicated_provider }.",
          details: duplicated_provider,
        )
        return
      end
    end

    user = SignIn.process_auth_response(auth_response, @oauth_app.id)

    # find_or_create_for(app_id, user_id, scopes, expires_in, use_refresh_token)
    scopes = Doorkeeper::OAuth::Scopes.from_string 'public private'
    token = Doorkeeper::AccessToken.find_or_create_for(application: @oauth_app, resource_owner: user.id, scopes: scopes)

    render json: { access_token: token.token, type: 'bearer', first_time_user: user.first_time_user? }, status: :created
  end

  private

  def render_error(error:, error_description:, details:)
    render json: { error: error, error_description: error_description, details: details }, status: :unprocessable_entity
  end

  def load_app
    @oauth_app = OAuth::Application.find_by(twitter_app_name: params[:app])
    handle_known_app_not_found(params[:app]) unless @oauth_app.present? && @oauth_app.twitter_auth_allowed?
  end

  def public_endpoint?
    true
  end
end
