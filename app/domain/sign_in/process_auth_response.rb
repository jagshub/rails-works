# frozen_string_literal: true

module SignIn
  module ProcessAuthResponse
    extend self

    def call(auth_response, via_app_id = nil)
      user = find_or_create_from_auth_response(auth_response)

      if user.first_time_user?
        SignIn::SetFirstTimeUserAttributes.call(user, auth_response, via_app_id)

        SpamChecks.check_user_signup(user) if user.email.present?
      end

      accept_maker_suggestions auth_response

      FriendSync.sync_later(user) if auth_response.token_params.present?

      user
    end

    private

    def find_or_create_from_auth_response(auth_response)
      user = auth_response.find_user

      if user.present?
        user.increment :login_count

        user_params = auth_response.user_params.except(:name, :email, :image, :website_url)
        user.update! user_params

        email = auth_response.user_params[:email]

        if email.present? && user.email.blank? && !Subscriber.with_user.where(email: email).exists?
          Subscribers.register_and_verify(
            user: user,
            email: email,
          )
        end
      else
        user = SignIn.create_user(auth_response)
      end

      create_or_update_token(user, auth_response.token_params) if auth_response.token_params.present?

      user
    end

    def create_or_update_token(user, token_params)
      token = user.access_tokens.find_or_initialize_by(token_type: AccessToken.token_types[token_params.delete(:token_type)])
      token.update! token_params
    end

    def accept_maker_suggestions(auth_response)
      username = auth_response.user_params[:twitter_username]
      # NOTE(DZ): We can only accept maker suggestions when the user logs in
      # twitter, since we don't know what username they'll have on other
      # platforms.
      return if username.blank?

      MakerSuggestion.approved.not_joined.by_username(username).each do |suggestion|
        maker = ProductMakers::Maker.from_suggestion suggestion, auth: auth_response
        ProductMakers.accept maker: maker
      end
    end
  end
end
